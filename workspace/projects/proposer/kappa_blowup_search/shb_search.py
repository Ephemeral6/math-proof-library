"""SHB iterate-type kappa-blowup search at 50-digit precision.

Sweeps (beta, eta*L, kappa, T, function, init) and computes f-suboptimality
for last/Cesaro/Polyak-Ruppert/suffix/best iterates. Saves raw_data.csv.
"""
import mpmath as mp
import csv
import os
import sys
import time
from collections import deque

mp.mp.dps = 50

ZERO = mp.mpf(0)
ONE = mp.mpf(1)
TWO = mp.mpf(2)
HALF = mp.mpf("0.5")

# ---------------------------------------------------------------------------
# Function classes
# ---------------------------------------------------------------------------

def f1_factory(kappa):
    """f(x) = (L/2) x1^2 + (mu/2) x2^2, L=kappa, mu=1, dim=2."""
    L = mp.mpf(kappa)
    mu = ONE
    lams = [L, mu]
    dim = 2

    def f(x):
        return HALF * sum(lams[i] * x[i] * x[i] for i in range(dim))

    def grad(x):
        return [lams[i] * x[i] for i in range(dim)]

    return {"f": f, "grad": grad, "dim": dim, "fstar": ZERO,
            "x0_default": [ONE] * dim, "L_smooth": L, "lams": lams}


def f2_factory(kappa):
    """f(x) = sum_i (lam_i/2) x_i^2, lam_i logspaced from 1 to kappa, dim=10."""
    L = mp.mpf(kappa)
    mu = ONE
    dim = 10
    if dim == 1:
        lams = [L]
    else:
        # logspaced from mu to L
        log_mu = mp.log(mu)
        log_L = mp.log(L)
        lams = [mp.exp(log_mu + (log_L - log_mu) * mp.mpf(i) / mp.mpf(dim - 1))
                for i in range(dim)]

    def f(x):
        return HALF * sum(lams[i] * x[i] * x[i] for i in range(dim))

    def grad(x):
        return [lams[i] * x[i] for i in range(dim)]

    return {"f": f, "grad": grad, "dim": dim, "fstar": ZERO,
            "x0_default": [ONE] * dim, "L_smooth": L, "lams": lams}


def f3_factory(kappa):
    """f(x) = L*huber(x1) + huber(x2), L=kappa, delta=1.

    huber(z) = z^2/2 if |z|<=1 else |z| - 1/2.
    Smoothness constant max(L, 1) = L. Non-SC outside |z|<=1.
    """
    L = mp.mpf(kappa)
    delta = ONE
    dim = 2

    def huber(z):
        a = abs(z)
        if a <= delta:
            return HALF * z * z
        return delta * (a - HALF * delta)

    def hgrad(z):
        a = abs(z)
        if a <= delta:
            return z
        return delta if z > 0 else -delta

    def f(x):
        return L * huber(x[0]) + huber(x[1])

    def grad(x):
        return [L * hgrad(x[0]), hgrad(x[1])]

    return {"f": f, "grad": grad, "dim": dim, "fstar": ZERO,
            "x0_default": [ONE] * dim, "L_smooth": L, "lams": None}


def f4_factory(kappa):
    """f(x) = (1-x1)^2 + kappa*(x2-x1^2)^2, Rosenbrock-like.

    Minimum at (1,1) with f*=0. We start at (-1,1) since (1,1) is the min.
    Smoothness near min: Hessian = [[2 + 12*kappa*(x1^2 - x2/3 ...)]]; not SC globally.
    """
    K = mp.mpf(kappa)
    dim = 2

    def f(x):
        a = ONE - x[0]
        b = x[1] - x[0] * x[0]
        return a * a + K * b * b

    def grad(x):
        a = ONE - x[0]
        b = x[1] - x[0] * x[0]
        # df/dx1 = -2(1-x1) - 4*K*x1*(x2 - x1^2)
        g0 = -TWO * a - mp.mpf(4) * K * x[0] * b
        # df/dx2 = 2*K*(x2 - x1^2)
        g1 = TWO * K * b
        return [g0, g1]

    return {"f": f, "grad": grad, "dim": dim, "fstar": ZERO,
            "x0_default": [-ONE, ONE], "L_smooth": K, "lams": None}


FUNCTIONS = {
    "f1_quad2d": f1_factory,
    "f2_quad10d": f2_factory,
    "f3_huber": f3_factory,
    "f4_rosen": f4_factory,
}


# ---------------------------------------------------------------------------
# SHB iteration with iterate-type tracking
# ---------------------------------------------------------------------------

def run_shb(fdict, beta, eta, T, x0, x_minus1, snapshot_Ts, max_norm=mp.mpf("1e30")):
    """Run SHB for T steps. At each snapshot in snapshot_Ts, evaluate all 5 iterate types.

    Returns: dict {snapshot_T: {iterate_type: f_value}} and a "diverged" flag.
    """
    dim = fdict["dim"]
    f = fdict["f"]
    grad = fdict["grad"]
    fstar = fdict["fstar"]

    x_prev = list(x_minus1)
    x_curr = list(x0)

    # Tracking accumulators
    cesaro_sum = list(x_curr)  # sum of x_t for t=0..T
    pr_sum = [v for v in x_curr]  # sum of (t+1)*x_t starting with t=0 -> weight 1
    pr_weight_sum = ONE  # sum of (t+1) for t=0..T

    # Suffix buffer: keep last k iterates where k = isqrt(snapshot_T)
    # We'll keep a deque of size sqrt(max_T) and shrink at snapshot.
    max_k = int(mp.sqrt(mp.mpf(max(snapshot_Ts))).__float__()) + 1
    suffix_buf = deque(maxlen=max_k)
    suffix_buf.append(list(x_curr))

    # Best tracking
    best_fval = f(x_curr)
    best_x = list(x_curr)

    snapshots = {}
    snapshot_set = set(snapshot_Ts)
    diverged = False

    for t in range(1, T + 1):
        g = grad(x_curr)
        x_new = [x_curr[i] - eta * g[i] + beta * (x_curr[i] - x_prev[i])
                 for i in range(dim)]

        # Divergence check
        norm_sq = sum(v * v for v in x_new)
        if norm_sq > max_norm * max_norm:
            diverged = True
            # Fill remaining snapshots with NaN-like (mpf inf)
            for sT in snapshot_Ts:
                if sT not in snapshots:
                    snapshots[sT] = {k: mp.mpf("inf") for k in
                                     ["last", "cesaro", "pr", "suffix", "best"]}
            return snapshots, diverged

        x_prev = x_curr
        x_curr = x_new

        # Update accumulators
        for i in range(dim):
            cesaro_sum[i] = cesaro_sum[i] + x_curr[i]
        weight_t = mp.mpf(t + 1)
        for i in range(dim):
            pr_sum[i] = pr_sum[i] + weight_t * x_curr[i]
        pr_weight_sum = pr_weight_sum + weight_t

        suffix_buf.append(list(x_curr))

        f_curr = f(x_curr)
        if f_curr < best_fval:
            best_fval = f_curr
            best_x = list(x_curr)

        if t in snapshot_set:
            n_iters = mp.mpf(t + 1)
            # Cesaro
            cesaro_x = [cesaro_sum[i] / n_iters for i in range(dim)]
            # PR
            pr_x = [pr_sum[i] / pr_weight_sum for i in range(dim)]
            # Suffix: last k iterates where k=floor(sqrt(t)), but at most len(suffix_buf)
            k_target = max(1, int(mp.sqrt(mp.mpf(t)).__float__()))
            # Use last min(k_target, len(suffix_buf)) entries
            k_use = min(k_target, len(suffix_buf))
            buf_list = list(suffix_buf)
            recent = buf_list[-k_use:]
            suffix_x = [sum(item[i] for item in recent) / mp.mpf(k_use)
                        for i in range(dim)]

            snap = {
                "last": f(x_curr) - fstar,
                "cesaro": f(cesaro_x) - fstar,
                "pr": f(pr_x) - fstar,
                "suffix": f(suffix_x) - fstar,
                "best": best_fval - fstar,
            }
            snapshots[t] = snap

    return snapshots, diverged


# ---------------------------------------------------------------------------
# Sweep driver
# ---------------------------------------------------------------------------

def sweep(out_csv, betas, etaLs, kappas, snapshot_Ts, function_names, inits,
          progress_every=10):
    """Run full sweep. Append rows to out_csv as (key columns, fvalue)."""
    fieldnames = ["function", "beta", "etaL", "kappa", "init", "T",
                  "iterate_type", "fvalue"]

    # Open file - resume if exists by reading completed combos
    seen = set()
    if os.path.exists(out_csv):
        with open(out_csv, "r", newline="", encoding="utf-8") as fp:
            reader = csv.DictReader(fp)
            for row in reader:
                key = (row["function"], row["beta"], row["etaL"],
                       row["kappa"], row["init"], row["T"], row["iterate_type"])
                seen.add(key)

    write_header = not os.path.exists(out_csv) or os.path.getsize(out_csv) == 0
    fp = open(out_csv, "a", newline="", encoding="utf-8")
    writer = csv.DictWriter(fp, fieldnames=fieldnames)
    if write_header:
        writer.writeheader()

    total_jobs = (len(betas) * len(etaLs) * len(kappas) *
                  len(function_names) * len(inits))
    done = 0
    t0 = time.time()

    for func_name in function_names:
        for init_name in inits:
            for beta in betas:
                for etaL in etaLs:
                    for kappa in kappas:
                        # Check if all snapshots*iterates already done
                        all_present = True
                        for sT in snapshot_Ts:
                            for it_type in ["last", "cesaro", "pr", "suffix", "best"]:
                                key = (func_name, str(beta), str(etaL),
                                       str(kappa), init_name, str(sT), it_type)
                                if key not in seen:
                                    all_present = False
                                    break
                            if not all_present:
                                break
                        if all_present:
                            done += 1
                            continue

                        # Build function
                        fdict = FUNCTIONS[func_name](kappa)
                        L = fdict["L_smooth"]
                        eta = mp.mpf(etaL) / L

                        # Build init
                        dim = fdict["dim"]
                        if func_name == "f4_rosen":
                            x0 = [mp.mpf(-1), mp.mpf(1)]
                        else:
                            x0 = [ONE] * dim
                        if init_name == "zero_mom":
                            x_minus1 = list(x0)
                        elif init_name == "alt_mom":
                            x_minus1 = [x0[i] * ((-ONE) ** i) for i in range(dim)]
                        else:
                            raise ValueError(init_name)

                        beta_mpf = mp.mpf(beta)
                        T_max = max(snapshot_Ts)
                        try:
                            snaps, diverged = run_shb(fdict, beta_mpf, eta, T_max,
                                                     x0, x_minus1, snapshot_Ts)
                        except Exception as e:
                            sys.stderr.write(
                                f"Error for {func_name},beta={beta},etaL={etaL},"
                                f"kappa={kappa},init={init_name}: {e}\n")
                            done += 1
                            continue

                        for sT in snapshot_Ts:
                            snap = snaps.get(sT, {})
                            for it_type in ["last", "cesaro", "pr", "suffix", "best"]:
                                fval = snap.get(it_type, mp.mpf("nan"))
                                if mp.isinf(fval) or mp.isnan(fval):
                                    fval_s = "inf" if mp.isinf(fval) else "nan"
                                else:
                                    fval_s = mp.nstr(fval, 30)
                                writer.writerow({
                                    "function": func_name,
                                    "beta": beta,
                                    "etaL": etaL,
                                    "kappa": kappa,
                                    "init": init_name,
                                    "T": sT,
                                    "iterate_type": it_type,
                                    "fvalue": fval_s,
                                })
                        fp.flush()
                        done += 1
                        if done % progress_every == 0:
                            elapsed = time.time() - t0
                            rate = done / max(elapsed, 1e-9)
                            sys.stderr.write(
                                f"[{done}/{total_jobs}] elapsed={elapsed:.1f}s "
                                f"rate={rate:.2f}/s last={func_name},b={beta},"
                                f"eL={etaL},k={kappa}\n")
                            sys.stderr.flush()

    fp.close()


if __name__ == "__main__":
    out_csv = os.path.join(os.path.dirname(os.path.abspath(__file__)), "raw_data.csv")

    # Full grid per spec
    betas = [0.5, 0.7, 0.9, 0.95, 0.99]
    etaLs = [0.5, 1.0, 1.5, 2.0, 2.5, 2.9]
    kappas = [10, 100, 1000, 10000]
    snapshot_Ts = [100, 1000, 10000]
    function_names = ["f1_quad2d", "f2_quad10d", "f3_huber", "f4_rosen"]
    inits = ["zero_mom", "alt_mom"]

    # Allow CLI override for pilot
    if len(sys.argv) > 1 and sys.argv[1] == "pilot":
        betas = [0.5, 0.9, 0.99]
        etaLs = [1.0, 2.0]
        kappas = [10, 100, 1000, 10000]
        snapshot_Ts = [100, 1000]
        function_names = ["f1_quad2d", "f3_huber"]
        inits = ["zero_mom"]
        out_csv = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                              "raw_data_pilot.csv")

    sweep(out_csv, betas, etaLs, kappas, snapshot_Ts,
          function_names, inits, progress_every=5)
    print("DONE")
