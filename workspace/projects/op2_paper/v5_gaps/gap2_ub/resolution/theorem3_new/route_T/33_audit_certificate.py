"""Audit 1: Manual numerical verification of the k=1 lookahead Lyapunov certificate.

Pick the point (β=0.95, η=0.02) for which the lookahead LMI claims C=12.08.
1. Extract (a0, a1, a2, c01, c02, c12, W) from the LMI solution.
2. Verify V_{t+1} - V_t ≤ 0 numerically on a worst-case-ish smooth convex function.
3. Verify f(y_T) ≤ C·LD²/(T+W-1) bound.

Test functions (all L-smooth convex):
  T1: f(x) = (L/2) x²  (1-D quadratic, eigenvalue analysis exact)
  T2: f(x) = (L/2) (x² + ε x⁴) for small ε  (smooth perturbation)
  T3: f(x) = log(1 + e^x) on 1-D (logistic, L = 1/4, but generally smooth)
  T4: Random L-smooth convex via Drori-Teboulle worst-case style
"""
from pathlib import Path
import sys, json
import numpy as np
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
import warnings; warnings.filterwarnings("ignore")

m = import_module("26_lookahead_lmi")
build = m.build_lookahead_lmi


def extract_certificate(L, beta, eta):
    """Solve LMI and extract Lyapunov coefficients."""
    r = build(L, beta, eta, fix_alpha=1.0, minimize="C")
    return r


def simulate_shb_1d(L, beta, eta, x0, T, f_func, grad_func):
    """Simulate SHB on 1-D function. Returns x_t and f(x_t)."""
    xs = [x0, x0]  # x_{-1} = x_0
    for t in range(T):
        x_new = xs[-1] - eta * grad_func(xs[-1]) + beta * (xs[-1] - xs[-2])
        xs.append(x_new)
    return np.array(xs[1:])


def compute_V(t, w0, alpha, a0, a1, a2, c01, c02, c12, X_star, x_t, x_tm1, x_tm2, f_val):
    """V_t = w_t (f_t - f*) + Q(X_t, X_{t-1}, X_{t-2})."""
    w_t = w0 + alpha * t
    Xt = x_t - X_star
    Xt1 = x_tm1 - X_star
    Xt2 = x_tm2 - X_star
    Q = a0 * Xt**2 + a1 * Xt1**2 + a2 * Xt2**2 + c01 * Xt * Xt1 + c02 * Xt * Xt2 + c12 * Xt1 * Xt2
    return w_t * f_val + Q


def main():
    L = 1.0
    beta = 0.95
    eta = 0.02

    print("=" * 80)
    print(f"Audit 1: k=1 lookahead LMI certificate at β={beta}, η={eta}")
    print("=" * 80)

    # Step 1: Extract certificate
    print("\n[1] Extracting Lyapunov certificate from LMI...")
    r = extract_certificate(L, beta, eta)
    print(f"  status: {r['status']}")
    if r["status"] not in ("optimal", "optimal_inaccurate"):
        print("  FAILED: cannot extract certificate")
        return
    print(f"  W   = {r['W']:.6f}")
    print(f"  a0  = {r['a0']:.6f}")
    print(f"  a1  = {r['a1']:.6f}")
    print(f"  a2  = {r['a2']:.6f}")
    print(f"  c01 = {r['c01']:.6f}")
    print(f"  c02 = {r['c02']:.6f}")
    print(f"  c12 = {r['c12']:.6f}")
    print(f"  S   = {r['S']:.6f}")
    print(f"  C   = {r['C_Lya']:.6f}")
    cert = r

    W = cert["W"]
    alpha = 1.0
    w0 = W - alpha  # weight at t=0
    a0, a1, a2 = cert["a0"], cert["a1"], cert["a2"]
    c01, c02, c12 = cert["c01"], cert["c02"], cert["c12"]
    C_Lya = cert["C_Lya"]

    # Step 2: Verify Q PSD
    Q_mat = np.array([
        [a0, c01/2, c02/2],
        [c01/2, a1, c12/2],
        [c02/2, c12/2, a2]
    ])
    eigs = np.linalg.eigvalsh(Q_mat)
    print(f"\n[2] Q matrix eigenvalues: {eigs}")
    print(f"  Q PSD? {all(e >= -1e-6 for e in eigs)}")

    # Step 3: Test on quadratic f(x) = (L/2) x²
    print("\n[3] Test on f(x) = (L/2) x² (1-D quadratic):")
    x0 = 1.0  # ‖y_0 - y*‖² = 1, D = 1
    D2 = x0**2
    xs = simulate_shb_1d(L, beta, eta, x0, 200,
                          lambda x: 0.5 * L * x**2,
                          lambda x: L * x)
    fs = 0.5 * L * xs**2  # f - f* = (L/2) x²

    # Compute V_t for t = 0, 1, ..., 199
    Vs = []
    for t in range(len(fs)):
        if t < 2:
            x_t = xs[t]; x_tm1 = xs[max(0, t-1)]; x_tm2 = xs[max(0, t-2)]
        else:
            x_t = xs[t]; x_tm1 = xs[t-1]; x_tm2 = xs[t-2]
        V = compute_V(t, w0, alpha, a0, a1, a2, c01, c02, c12,
                      0.0, x_t, x_tm1, x_tm2, fs[t])
        Vs.append(V)
    Vs = np.array(Vs)

    # Check V_{t+1} ≤ V_t for t ≥ 2 (need 3 lagged states)
    diffs = np.diff(Vs[2:])
    print(f"  V_t at t=0,1,2,5,10,50,100,199:")
    for tt in [0,1,2,5,10,50,100,199]:
        print(f"    V_{tt} = {Vs[tt]:.6e}")
    print(f"  V_{{t+1}} - V_t ≤ 0 for all t ≥ 2? {np.all(diffs <= 1e-6)}")
    print(f"  max V_{{t+1}} - V_t for t ≥ 2: {np.max(diffs):.6e}")

    # Step 4: Check f_T ≤ C·LD²/(T+W-1)
    print("\n[4] Bound check: f(y_T) - f* ≤ C·LD²/(T+W-1)")
    print(f"  C = {C_Lya:.4f}, W = {W:.4f}, L = {L}, D² = {D2}")
    for T in [10, 50, 100, 199]:
        bound = C_Lya * L * D2 / (T + W - 1)
        actual = fs[T]
        ratio = actual / bound if bound > 0 else float("inf")
        ok = actual <= bound + 1e-6
        print(f"  T={T:>3}: f(y_T)={actual:.6e}, bound={bound:.6e}, ratio={ratio:.4f}, OK? {ok}")

    # Step 5: Test on f(x) = log(1 + e^x)
    print("\n[5] Test on f(x) = log(1 + e^x) (logistic, L = 1/4):")
    L2 = 0.25
    # Need to re-solve LMI with L=0.25? Or just use the same coefficients (which are L-dependent).
    # The LMI's coefficients are L-specific. So we need to solve LMI with L=0.25.
    r2 = build(L2, beta, eta, fix_alpha=1.0, minimize="C")
    if r2["status"] not in ("optimal", "optimal_inaccurate"):
        print(f"  LMI infeasible at L={L2}, β={beta}, η={eta}: {r2['status']}")
        # Try other η
        for eta2 in [0.05, 0.08, 0.1]:
            r2 = build(L2, beta, eta2, fix_alpha=1.0, minimize="C")
            if r2["status"] in ("optimal", "optimal_inaccurate"):
                eta = eta2
                break
        if r2["status"] not in ("optimal", "optimal_inaccurate"):
            print("  Still infeasible — skipping logistic test")
            return
    print(f"  L={L2} certificate: η={eta}, C={r2['C_Lya']:.4f}, W={r2['W']:.4f}")

    x0 = 5.0  # gives ‖y_0 - y*‖ ≈ 5 (y* = -∞)
    # Actually for logistic, optimum is at -∞. We can't compute distance to optimum.
    # Use a regularized version: f(x) = log(1+e^x) + (μ/2) x² with small μ. Then optimum exists.
    # Or just check that f(y_t) is decreasing and bounded.
    fs_log = []
    xs_log = simulate_shb_1d(L2, beta, eta, x0, 200,
                              lambda x: np.log1p(np.exp(np.minimum(x, 700))),
                              lambda x: 1.0 - 1.0 / (1.0 + np.exp(np.minimum(x, 700))))
    fs_log = np.log1p(np.exp(np.minimum(xs_log, 700)))
    print(f"  f at t=0,10,50,100,199: {[f'{fs_log[i]:.4e}' for i in [0,10,50,100,199]]}")


if __name__ == "__main__":
    main()
