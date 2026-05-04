"""Route T, step #1: numerical monotonicity check of the twisted Lyapunov.

Twisted Lyapunov (Bot-Schindler 2025 discretized):
  V_t = w_t (f(y_t) - f*) + 0.5 || alpha (y_t - y*) + (y_t - y_{t-1})/eta ||^2 + (gamma/2) || y_t - y* ||^2

where alpha = (1 - beta) / eta is the friction coefficient.

We test on a quadratic f(y) = 0.5 y^T A y with A = diag(...) so that f is L-smooth convex with L = max eigenvalue.

This script does NOT prove anything; it just sanity-checks that for a sweep of (w_t, gamma) choices,
V_t is non-increasing along SHB trajectories at beta = 0.3, eta = 0.5 / L, T = 100.
A monotone V_t with the right rate baseline is necessary for the symbolic step #2.

Structure tested:
  Variant T-A: w_t = 1 (constant), gamma in {0, 1, 1/eta}.
  Variant T-B: w_t = t + 1 (linear growth), gamma in {0, 1, 1/eta}.
  Variant T-C: w_t = sqrt(t+1).
  Variant T-D: w_t = 1, BUT inner squared norm uses (y_t - y_{t-1})/eta as a CO-velocity (NO twist).
               This is the "naive" baseline.

Output: for each variant, prints
  - V_0
  - V_T
  - max_t (V_{t+1} - V_t)   (>0 means non-monotone)
  - is_monotone flag
  - log-log slope of V_t against t (for the variants that ARE monotone, this should be near -1).

If twist version T-A or T-B is monotone with slope ~ -1 while T-D is NOT, that's evidence
the twist is essential.
"""
import json
from pathlib import Path
import numpy as np


def shb_run(grad_f, y0, eta, beta, T):
    """Run deterministic SHB for T steps from y0, with y_{-1} = y0."""
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


def make_quadratic(d=10, condition=10.0, seed=0):
    rng = np.random.default_rng(seed)
    eigs = np.exp(np.linspace(0, np.log(condition), d))  # in [1, condition]
    Q, _ = np.linalg.qr(rng.standard_normal((d, d)))
    A = Q @ np.diag(eigs) @ Q.T
    L = float(eigs.max())
    y_star = np.zeros(d)
    f_star = 0.0

    def f(y):
        return 0.5 * float(y @ A @ y)

    def grad_f(y):
        return A @ y

    return f, grad_f, L, y_star, f_star


def lyapunov_twisted(ys, eta, beta, gamma, w_fn, f, f_star, y_star):
    """V_t = w_t (f(y_t) - f*) + 0.5 || alpha (y_t - y*) + (y_t - y_{t-1})/eta ||^2 + (gamma/2)||y_t - y*||^2

    For t = 0 we treat (y_0 - y_{-1})/eta = 0 (zero-momentum init).
    """
    alpha = (1.0 - beta) / eta
    Vs = []
    for t, y in enumerate(ys):
        if t == 0:
            v = np.zeros_like(y)
        else:
            v = (y - ys[t - 1]) / eta
        twist = alpha * (y - y_star) + v
        Vt = w_fn(t) * (f(y) - f_star) + 0.5 * float(twist @ twist) + 0.5 * gamma * float(
            (y - y_star) @ (y - y_star))
        Vs.append(float(Vt))
    return np.array(Vs)


def lyapunov_naive(ys, eta, beta, gamma, w_fn, f, f_star, y_star):
    """Baseline (NO twist):
    V_t = w_t (f(y_t)-f*) + 0.5 ||y_t - y*||^2 + 0.5 ||(y_t - y_{t-1})/eta||^2 + (gamma/2)||y_t-y*||^2.
    Velocity and position are SEPARATED, no cross term.
    """
    Vs = []
    for t, y in enumerate(ys):
        if t == 0:
            v = np.zeros_like(y)
        else:
            v = (y - ys[t - 1]) / eta
        Vt = w_fn(t) * (f(y) - f_star) + 0.5 * float((y - y_star) @ (y - y_star)) + 0.5 * float(
            v @ v) + 0.5 * gamma * float((y - y_star) @ (y - y_star))
        Vs.append(float(Vt))
    return np.array(Vs)


def loglog_slope(ts, Vs):
    mask = (ts > 0) & (Vs > 0)
    if mask.sum() < 4:
        return float("nan")
    x = np.log(ts[mask])
    y = np.log(Vs[mask])
    s, b = np.polyfit(x, y, 1)
    return float(s)


def run_one(variant, beta, eta, T, gamma, w_fn, f, grad_f, L, y_star, f_star, twisted=True):
    rng = np.random.default_rng(123)
    d = grad_f(np.zeros_like(y_star)).shape[0] if hasattr(grad_f(np.zeros_like(y_star)), "shape") \
        else len(y_star)
    y0 = rng.standard_normal(d)
    y0 = y0 / np.linalg.norm(y0)  # ||y0 - y*|| = 1

    ys = shb_run(grad_f, y0, eta, beta, T)
    fn = lyapunov_twisted if twisted else lyapunov_naive
    Vs = fn(ys, eta, beta, gamma, w_fn, f, f_star, y_star)

    diffs = np.diff(Vs)
    max_inc = float(np.max(diffs))
    monotone = max_inc <= 1e-10  # tolerance for FP

    ts = np.arange(len(Vs))
    slope = loglog_slope(ts, Vs)
    f_slope = loglog_slope(ts, np.array([f(y) - f_star for y in ys]))
    return {
        "variant": variant,
        "twisted": twisted,
        "beta": beta,
        "eta": eta,
        "T": T,
        "gamma": gamma,
        "V0": float(Vs[0]),
        "VT": float(Vs[-1]),
        "max_increase": max_inc,
        "monotone": bool(monotone),
        "loglog_slope_V": slope,
        "loglog_slope_f": f_slope,
    }


def main():
    L = 1.0
    f, grad_f, L_actual, y_star, f_star = make_quadratic(d=10, condition=10.0, seed=0)
    print(f"L (actual) = {L_actual:.4f}")

    beta = 0.3
    eta = 0.5 / L_actual  # 0.5 / L
    T = 100

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

    results = []
    for name, gamma, w_fn, twisted in variants:
        r = run_one(name, beta, eta, T, gamma, w_fn, f, grad_f, L_actual, y_star, f_star, twisted)
        results.append(r)
        print(f"\n{name}")
        print(f"  V_0={r['V0']:.4e}  V_T={r['VT']:.4e}  "
              f"max_increase={r['max_increase']:+.3e}  monotone={r['monotone']}")
        print(f"  loglog slope V_t = {r['loglog_slope_V']:+.4f}   "
              f"slope f(y_t)-f* = {r['loglog_slope_f']:+.4f}")

    out = Path(__file__).parent / "01_numerical_Vt_results.json"
    out.write_text(json.dumps(results, indent=2))
    print(f"\nResults written to {out}")


if __name__ == "__main__":
    main()
