"""Route T, step #2: re-run V_t monotonicity on a NON strongly-convex L-smooth f.

The previous step used a positive-definite quadratic (mu > 0), so the slopes of f(y_t) - f*
were ~ -5 (linear convergence) and not informative for our O(1/T) target.

For Theorem 3 we want the L-smooth convex regime with mu = 0. The cleanest generic test
problems:

(A) "Rank-1 quadratic": f(y) = 0.5 (a^T y - b)^2 with a in R^d, b in R.
    Then nabla f(y) = (a^T y - b) a, and L = ||a||^2. mu = 0 (kernel of dim d-1).
    Optimal set: { y : a^T y = b }.
    Hard for SHB since gradients only point along a; momentum easily overshoots.

(B) Nesterov "worst-case" quadratic (DT2014 worst-case for GD).
    Uses a tridiagonal quadratic with first-row gap.

(C) Huber on a thin design (matches Garrigos's test case).

We use (A) for the Lyapunov check: simple, L is exact, mu = 0, last-iterate decay is
visibly slower than for SC. The expected log-log slope of f(y_t) - f* is roughly -2
for SHB at fixed eta (since rank-1 quadratic + GD/SHB converges quadratically *to the
optimal subspace* but the energy collapse rate matches GD's ~ T^{-2} schedule of acceleration).

We focus on the QUALITATIVE check: V_t monotone on twisted, NON-monotone on naive.

Variants tested (same as step #1):
  T-A1: twist, w=1, gamma=0
  T-A2: twist, w=1, gamma=1
  T-A3: twist, w=1, gamma=1/eta
  T-B1: twist, w=t+1, gamma=0
  T-B2: twist, w=t+1, gamma=1
  T-D1: NAIVE, w=1, gamma=0
  T-D2: NAIVE, w=t+1, gamma=0

Also: a "DT-worst" Nesterov-style quadratic for further confirmation.
"""
import json
from pathlib import Path
import numpy as np


def shb_run(grad_f, y0, eta, beta, T):
    y_prev = np.array(y0, dtype=float).copy()
    y_curr = np.array(y0, dtype=float).copy()
    ys = [y_curr.copy()]
    for _ in range(T):
        g = grad_f(y_curr)
        y_next = y_curr - eta * g + beta * (y_curr - y_prev)
        y_prev = y_curr
        y_curr = y_next
        ys.append(y_curr.copy())
    return ys


def make_rank1(d=10, seed=0):
    rng = np.random.default_rng(seed)
    a = rng.standard_normal(d)
    a = a / np.linalg.norm(a) * np.sqrt(d)  # ||a||^2 = d
    b = 0.0
    L = float(a @ a)
    y_star = np.zeros(d)  # any y with a^T y = 0 is optimal; choose 0
    f_star = 0.0

    def f(y):
        r = float(a @ y - b)
        return 0.5 * r * r

    def grad_f(y):
        r = float(a @ y - b)
        return r * a

    return f, grad_f, L, y_star, f_star


def make_dt_worst(d=10):
    """DT2014 worst-case quadratic: f(y) = 0.5 sum_i (y_{i+1} - y_i)^2 + (1/2) y_1 - sum_i y_i (?)
    Simpler: tridiagonal Laplacian-style positive-semi-definite quadratic with mu = 0.

    f(y) = 0.5 y^T L_T y where L_T is the d x d matrix with 2 on diag, -1 off-diag, but
    the (1,1) and (d,d) corners are 1 (so that 1 vec is in kernel). This is the path graph
    Laplacian, mu = 0 (kernel = constant), L = 4 sin^2((d-1)pi/(2d-2)) ~ 4.

    Optimal: any constant vector. Pick y* = 0.
    """
    L_mat = -np.eye(d, k=1) - np.eye(d, k=-1) + 2 * np.eye(d)
    L_mat[0, 0] = 1
    L_mat[-1, -1] = 1
    eigs = np.linalg.eigvalsh(L_mat)
    L = float(eigs.max())
    y_star = np.zeros(d)
    f_star = 0.0

    def f(y):
        return 0.5 * float(y @ L_mat @ y)

    def grad_f(y):
        return L_mat @ y

    return f, grad_f, L, y_star, f_star


def lyapunov(ys, eta, beta, gamma, w_fn, f, f_star, y_star, twisted):
    alpha = (1.0 - beta) / eta
    Vs = []
    for t, y in enumerate(ys):
        if t == 0:
            v = np.zeros_like(y)
        else:
            v = (y - ys[t - 1]) / eta
        if twisted:
            twist = alpha * (y - y_star) + v
            quad = 0.5 * float(twist @ twist)
        else:
            quad = 0.5 * float((y - y_star) @ (y - y_star)) + 0.5 * float(v @ v)
        Vt = w_fn(t) * (f(y) - f_star) + quad + 0.5 * gamma * float((y - y_star) @ (y - y_star))
        Vs.append(float(Vt))
    return np.array(Vs)


def loglog_slope(ts, Vs, skip=2):
    mask = (ts > skip) & (Vs > 1e-15)
    if mask.sum() < 4:
        return float("nan")
    x = np.log(ts[mask])
    y = np.log(Vs[mask])
    s, _ = np.polyfit(x, y, 1)
    return float(s)


def run_variants(name, beta, eta, T, f, grad_f, L_actual, y_star, f_star, seed=123):
    rng = np.random.default_rng(seed)
    d = len(y_star)
    y0 = rng.standard_normal(d)
    y0 = y0 / np.linalg.norm(y0)  # ||y0 - y*|| = 1
    ys = shb_run(grad_f, y0, eta, beta, T)

    f_vals = np.array([f(y) - f_star for y in ys])
    print(f"\n--- {name} | beta={beta}, eta={eta:.4f}, T={T}, L={L_actual:.3f} ---")
    print(f"f(y_0)-f* = {f_vals[0]:.4e}, f(y_T)-f* = {f_vals[-1]:.4e}")
    print(f"slope log f(y_t)-f* (t>=2) = {loglog_slope(np.arange(len(f_vals)), f_vals):.4f}")

    variants = [
        ("T-A1 twist, w=1, gamma=0",            1.0, lambda t: 1.0, True),
        ("T-A2 twist, w=1, gamma=1",            1.0, lambda t: 1.0, True),
        ("T-A3 twist, w=1, gamma=1/eta",        1.0/eta, lambda t: 1.0, True),
        ("T-B1 twist, w=t+1, gamma=0",          0.0, lambda t: t + 1.0, True),
        ("T-B2 twist, w=t+1, gamma=1",          1.0, lambda t: t + 1.0, True),
        ("T-B3 twist, w=t+1, gamma=1/eta",      1.0/eta, lambda t: t + 1.0, True),
        ("T-C  twist, w=sqrt(t+1), gamma=1",    1.0, lambda t: np.sqrt(t + 1.0), True),
        ("T-D1 NAIVE, w=1, gamma=0",            0.0, lambda t: 1.0, False),
        ("T-D2 NAIVE, w=t+1, gamma=0",          0.0, lambda t: t + 1.0, False),
    ]

    rows = []
    ts = np.arange(T + 1)
    for vname, gamma, w_fn, twisted in variants:
        Vs = lyapunov(ys, eta, beta, gamma, w_fn, f, f_star, y_star, twisted)
        diffs = np.diff(Vs)
        max_inc = float(np.max(diffs))
        monotone = max_inc <= 1e-9 * max(1.0, abs(Vs[0]))
        slope_V = loglog_slope(ts, Vs)
        rows.append({
            "variant": vname,
            "twisted": twisted,
            "gamma": gamma,
            "V0": float(Vs[0]),
            "VT": float(Vs[-1]),
            "max_inc": max_inc,
            "monotone": bool(monotone),
            "slope_V": slope_V,
        })
        flag = "✓" if monotone else "✗"
        print(f"  {flag} {vname:40s}  V_0={Vs[0]:.3e}  V_T={Vs[-1]:.3e}  "
              f"max_inc={max_inc:+.2e}  slope={slope_V:+.3f}")
    return rows


def main():
    all_results = {}

    # 1. Rank-1 quadratic
    f, grad_f, L_actual, y_star, f_star = make_rank1(d=10, seed=0)
    eta = 0.5 / L_actual
    rows = run_variants("rank-1 quadratic, beta=0.3", 0.3, eta, 200, f, grad_f, L_actual, y_star, f_star)
    all_results["rank1_beta0.3"] = rows

    rows = run_variants("rank-1 quadratic, beta=0.5", 0.5, eta, 200, f, grad_f, L_actual, y_star, f_star)
    all_results["rank1_beta0.5"] = rows

    # 2. DT worst-case (path Laplacian)
    f2, grad_f2, L2, y_star2, f_star2 = make_dt_worst(d=10)
    eta2 = 0.5 / L2
    rows = run_variants("DT-worst Laplacian, beta=0.3", 0.3, eta2, 200, f2, grad_f2, L2, y_star2, f_star2)
    all_results["dt_beta0.3"] = rows
    rows = run_variants("DT-worst Laplacian, beta=0.5", 0.5, eta2, 200, f2, grad_f2, L2, y_star2, f_star2)
    all_results["dt_beta0.5"] = rows

    out = Path(__file__).parent / "02_numerical_Vt_nonSC_results.json"
    out.write_text(json.dumps(all_results, indent=2))
    print(f"\nResults written to {out}")


if __name__ == "__main__":
    main()
