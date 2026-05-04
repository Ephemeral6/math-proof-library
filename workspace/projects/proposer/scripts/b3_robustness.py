"""B3 Robustness — 30+ random seeds for HIGH-confidence anomalies.

Anomalies tested:
  R1: Adam diverges on SC quadratic (final_gap >> min_gap)
  R2: Adam fails to drive Q-SC gap to ~0 (final gap >> 0)
  R3: SHB(0.9) on Goujaud2D: cesaro / pr much better than last
  R4: Quartic: GD/SHB/NAG empirical alpha ≈ -2 (consistent)
  R5: Adam dimension-scaling: gap explodes with d (slope of log f vs log d > 1)
"""
import numpy as np
import csv
import os

OUT_DIR = "workspace/proposer/results"
os.makedirs(OUT_DIR, exist_ok=True)

NSEED = 30


# ---------- helpers ----------

def make_sc_quad(d, seed):
    rng = np.random.default_rng(seed)
    Q, _ = np.linalg.qr(rng.standard_normal((d, d)))
    eigs = rng.uniform(0.05, 1.0, size=d)
    eigs[0] = 0.05; eigs[-1] = 1.0
    A = (Q * eigs) @ Q.T
    A = 0.5 * (A + A.T)
    return A, eigs.max()


def adam(A, x0, T, eta, b1=0.9, b2=0.999, eps=1e-8):
    x = x0.copy(); m = np.zeros_like(x); v = np.zeros_like(x)
    fs = np.empty(T)
    for t in range(1, T + 1):
        g = A @ x
        m = b1 * m + (1 - b1) * g
        v = b2 * v + (1 - b2) * g * g
        mh = m / (1 - b1 ** t); vh = v / (1 - b2 ** t)
        x = x - eta * mh / (np.sqrt(vh) + eps)
        fs[t - 1] = 0.5 * x @ A @ x
    return fs


def shb(A, x0, T, eta, beta):
    x = x0.copy(); xp = x0.copy()
    fs = np.empty(T)
    for t in range(T):
        g = A @ x
        xn = x - eta * g + beta * (x - xp)
        xp = x; x = xn
        fs[t] = 0.5 * x @ A @ x
    return fs


def nag(A, x0, T, eta, beta):
    x = x0.copy(); xp = x0.copy()
    fs = np.empty(T)
    for t in range(T):
        y = x + beta * (x - xp)
        xn = y - eta * (A @ y)
        xp = x; x = xn
        fs[t] = 0.5 * x @ A @ x
    return fs


def gd(A, x0, T, eta):
    x = x0.copy(); fs = np.empty(T)
    for t in range(T):
        x = x - eta * (A @ x)
        fs[t] = 0.5 * x @ A @ x
    return fs


def coeff_var(arr):
    arr = np.asarray(arr, dtype=float)
    arr = arr[np.isfinite(arr)]
    if arr.size == 0 or np.mean(arr) == 0:
        return None
    return float(np.std(arr) / np.abs(np.mean(arr)))


def report(name, vals, threshold=None):
    vals = np.array(vals)
    finite = np.isfinite(vals)
    arr = vals[finite]
    if arr.size == 0:
        print(f"{name}: all NaN/inf")
        return None
    cov = float(np.std(arr) / np.abs(np.mean(arr))) if np.mean(arr) != 0 else float("inf")
    print(f"{name}: n={arr.size}, mean={np.mean(arr):.3e}, std={np.std(arr):.3e}, CoV={cov:.3f}, min={arr.min():.3e}, max={arr.max():.3e}")
    return cov


# ---------- R1 + R2: Adam SC divergence and gap-floor ----------

def r1_r2():
    print("\n=== R1/R2: Adam on SC quadratic d=10, T=10000, eta=1/L ===")
    div_ratios = []
    final_gaps = []
    min_gaps = []
    for seed in range(NSEED):
        A, L = make_sc_quad(d=10, seed=seed)
        rng = np.random.default_rng(seed + 1000)
        x0 = rng.standard_normal(10)
        fs = adam(A, x0, 10000, 1.0 / L)
        div_ratios.append(fs[-1] / fs.min() if fs.min() > 0 else np.inf)
        final_gaps.append(fs[-1])
        min_gaps.append(fs.min())
    cov_div = report("R1: Adam div ratio (final/min)", div_ratios)
    cov_final = report("R2: Adam final gap", final_gaps)
    return {
        "R1_div": (div_ratios, cov_div),
        "R2_final": (final_gaps, cov_final),
    }


# ---------- R3: SHB(0.9) Goujaud — averaging beats last ----------

def r3():
    print("\n=== R3: SHB(0.9) on a 2D ill-conditioned quadratic, T=1000, ratio Cesaro/last ===")
    # Note: deterministic algorithm, varying x0 gives different runs
    ratios_pr = []
    ratios_ces = []
    for seed in range(NSEED):
        rng = np.random.default_rng(seed)
        A = np.diag([1.0, 1e-3])
        # rotate by random angle to break alignment
        theta = rng.uniform(0, 2 * np.pi)
        c, s = np.cos(theta), np.sin(theta)
        R = np.array([[c, -s], [s, c]])
        A = R @ A @ R.T
        L = 1.0
        x0 = rng.standard_normal(2)
        fs_traj = []
        x = x0.copy(); xp = x0.copy()
        xs = [x0.copy()]
        for _ in range(1000):
            g = A @ x
            xn = x - (1 / L) * g + 0.9 * (x - xp)
            xp = x; x = xn
            xs.append(x.copy())
        xs = np.array(xs[1:])
        gs = np.array([0.5 * x @ A @ x for x in xs])
        last = gs[-1]
        ces = xs.mean(axis=0)
        ces_gap = 0.5 * ces @ A @ ces
        w = np.arange(1, 1001) / np.sum(np.arange(1, 1001))
        pr = (w[:, None] * xs).sum(axis=0)
        pr_gap = 0.5 * pr @ A @ pr
        if last > 0:
            ratios_pr.append(pr_gap / last)
            ratios_ces.append(ces_gap / last)
    cov_pr = report("R3: PR/last", ratios_pr)
    cov_ces = report("R3: Cesaro/last", ratios_ces)
    return {
        "R3_pr": (ratios_pr, cov_pr),
        "R3_ces": (ratios_ces, cov_ces),
    }


# ---------- R4: Quartic empirical alpha for GD/SHB/NAG ----------

def r4():
    print("\n=== R4: Quartic alpha = log(gap_10k / gap_1k)/log(10) ===")
    res = {}
    for alg_name, alg in [
        ("SGD", lambda x0, T, L: gd_quartic(x0, T, L)),
        ("SHB_0.5", lambda x0, T, L: shb_quartic(x0, T, L, 0.5)),
        ("SHB_0.9", lambda x0, T, L: shb_quartic(x0, T, L, 0.9)),
        ("NAG_0.5", lambda x0, T, L: nag_quartic(x0, T, L, 0.5)),
        ("NAG_0.9", lambda x0, T, L: nag_quartic(x0, T, L, 0.9)),
    ]:
        alphas = []
        for seed in range(NSEED):
            rng = np.random.default_rng(seed)
            d = 10
            x0 = rng.standard_normal(d) * 0.5
            L = 4.0 * float(np.sum(x0 * x0))
            fs1 = alg(x0.copy(), 1000, L)
            fs10 = alg(x0.copy(), 10000, L)
            g1 = max(fs1[-1], 1e-300); g10 = max(fs10[-1], 1e-300)
            a = (np.log(g10) - np.log(g1)) / (np.log(10000) - np.log(1000))
            alphas.append(a)
        cov = report(f"R4: {alg_name} alpha", alphas)
        res[alg_name] = (alphas, cov)
    return res


def gd_quartic(x, T, L):
    eta = 1.0 / L
    fs = np.empty(T)
    for t in range(T):
        s = float(np.sum(x * x))
        g = s * x
        x = x - eta * g
        s2 = float(np.sum(x * x))
        fs[t] = 0.25 * s2 * s2
    return fs


def shb_quartic(x, T, L, beta):
    eta = 1.0 / L
    xp = x.copy(); fs = np.empty(T)
    for t in range(T):
        s = float(np.sum(x * x))
        g = s * x
        xn = x - eta * g + beta * (x - xp)
        xp = x; x = xn
        s2 = float(np.sum(x * x))
        fs[t] = 0.25 * s2 * s2
    return fs


def nag_quartic(x, T, L, beta):
    eta = 1.0 / L
    xp = x.copy(); fs = np.empty(T)
    for t in range(T):
        y = x + beta * (x - xp)
        sy = float(np.sum(y * y))
        g = sy * y
        xn = y - eta * g
        xp = x; x = xn
        s2 = float(np.sum(x * x))
        fs[t] = 0.25 * s2 * s2
    return fs


# ---------- R5: Adam dim scaling slope ----------

def r5():
    print("\n=== R5: Adam dimension-scaling slope across 30 seeds ===")
    dims = [2, 10, 50, 200, 500]
    T = 5000
    slopes = []
    for seed in range(NSEED):
        gaps = []
        for d in dims:
            rng = np.random.default_rng(seed)
            Q, _ = np.linalg.qr(rng.standard_normal((d, d)))
            eigs = rng.uniform(1e-3, 1.0, size=d); eigs[0] = 1e-3; eigs[-1] = 1.0
            A = (Q * eigs) @ Q.T; A = 0.5 * (A + A.T)
            x_star = rng.standard_normal(d); b = A @ x_star
            f_star = -0.5 * x_star @ b
            x0 = x_star + rng.standard_normal(d)
            x = x0.copy(); m = np.zeros_like(x); v = np.zeros_like(x)
            for t in range(1, T + 1):
                g = A @ x - b
                m = 0.9 * m + 0.1 * g
                v = 0.999 * v + 0.001 * g * g
                mh = m / (1 - 0.9 ** t); vh = v / (1 - 0.999 ** t)
                x = x - 1.0 * mh / (np.sqrt(vh) + 1e-8)  # eta = 1/L = 1
            gap = max(0.5 * x @ A @ x - b @ x - f_star, 1e-300)
            gaps.append(np.log10(gap))
        slope, _ = np.polyfit(np.log10(dims), gaps, 1)
        slopes.append(slope)
    cov = report("R5: Adam dim-scaling slope", slopes)
    return {"R5_slope": (slopes, cov)}


def main():
    out = {}
    out.update(r1_r2())
    out.update(r3())
    out.update(r4())
    out.update(r5())
    # write csv
    rows = [["anomaly", "n_finite", "mean", "std", "CoV", "verdict"]]
    for k, (vals, cov) in out.items():
        arr = np.array(vals); arr = arr[np.isfinite(arr)]
        if arr.size == 0:
            rows.append([k, 0, "n/a", "n/a", "n/a", "FAIL"])
            continue
        m = float(np.mean(arr)); s = float(np.std(arr))
        verdict = "ROBUST" if cov is not None and cov < 0.15 else ("FRAGILE" if cov is not None and cov < 0.5 else "NEEDS_MORE")
        rows.append([k, arr.size, f"{m:.3e}", f"{s:.3e}", f"{cov:.3f}" if cov is not None else "n/a", verdict])
    with open(os.path.join(OUT_DIR, "b3_robustness.csv"), "w", newline="") as f:
        csv.writer(f).writerows(rows)
    print(f"\nSaved {OUT_DIR}/b3_robustness.csv")
    for r in rows[1:]:
        print("  ", r)


if __name__ == "__main__":
    main()
