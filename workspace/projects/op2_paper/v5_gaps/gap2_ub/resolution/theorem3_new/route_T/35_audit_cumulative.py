"""Audit 3: V_T ≤ V_0 (cumulative descent) check.

Even if pointwise V_{t+1} ≤ V_t fails (due to large-magnitude coefficients & numerical noise),
the cumulative V_T ≤ V_0 might still hold and give a valid bound.

Also: most importantly, check whether f(y_T) ≤ C·LD²/(T+W-1) holds across many test functions.
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
import warnings; warnings.filterwarnings("ignore")
import numpy as np

m1 = import_module("26_lookahead_lmi")
m2 = import_module("29_lookahead2_lmi")


def test_function_quadratic_perturbed(L, eps):
    """f(x) = (L/2) x² + ε x⁴ but Hessian bounded — actually unbounded above. Use only small x range.
    Better: f(x) = (L/2) x² with linearly bounded slope."""
    return None  # use the quadratic test function for simplicity


def simulate(L, beta, eta, x0, T, grad_func):
    xs = [x0, x0]
    for t in range(T):
        x_new = xs[-1] - eta * grad_func(xs[-1]) + beta * (xs[-1] - xs[-2])
        xs.append(x_new)
    return np.array(xs[1:])


def compute_V_traj(xs, fs, cert):
    a0, a1, a2 = cert["a0"], cert["a1"], cert["a2"]
    c01, c02, c12 = cert["c01"], cert["c02"], cert["c12"]
    W = cert["W"]; w0 = W - 1.0
    Vs = []
    for t in range(len(xs)):
        x_t = xs[t]; x_tm1 = xs[max(0, t-1)]; x_tm2 = xs[max(0, t-2)]
        Q = (a0 * x_t**2 + a1 * x_tm1**2 + a2 * x_tm2**2
             + c01 * x_t * x_tm1 + c02 * x_t * x_tm2 + c12 * x_tm1 * x_tm2)
        Vs.append((w0 + 1.0 * t) * fs[t] + Q)
    return np.array(Vs)


def audit_cumulative(builder, L, beta, eta, T_list=[10, 50, 100, 200, 500]):
    r = builder(L, beta, eta, fix_alpha=1.0, minimize="C")
    if r.get("a0") is None: return None
    cert = r
    W = cert["W"]; C_Lya = cert["C_Lya"]
    print(f"\n  cert: status={cert['status']}, C={C_Lya:.4f}, W={W:.4f}")

    # Test 1: Quadratic
    x0 = 1.0
    xs = simulate(L, beta, eta, x0, max(T_list)+5, lambda x: L * x)
    fs = 0.5 * L * xs**2
    Vs = compute_V_traj(xs, fs, cert)
    V0 = Vs[0]
    print(f"  V_0 = {V0:.4f}, V at T={[f'{Vs[T]:.4e}' for T in T_list]}")

    # Bound check
    print(f"  Bound f(y_T) ≤ C·LD²/(T+W-1):")
    all_ok = True
    for T in T_list:
        actual = fs[T]
        bound = C_Lya * L * x0**2 / (T + W - 1)
        ok = actual <= bound + 1e-9
        all_ok = all_ok and ok
        print(f"    T={T:>3}: f={actual:.4e}, bound={bound:.4e}, ratio={actual/bound:.4f}, OK={ok}")

    # V_T ≤ V_0 check
    V_T_at_max = Vs[max(T_list)]
    cumul_ok = V_T_at_max <= V0 + 1e-6
    print(f"  Cumulative V_T ≤ V_0? V_{max(T_list)}={V_T_at_max:.4e} vs V_0={V0:.4e}: {cumul_ok}")

    return {"all_bounds_ok": all_ok, "cumulative_ok": cumul_ok}


def main():
    L = 1.0
    print("=" * 80)
    print("Audit 3: cumulative V_T ≤ V_0 + bound f(y_T) ≤ C·LD²/(T+W-1)")
    print("=" * 80)

    print("\n=== k=1 lookahead ===")
    points = [(0.5, 0.3), (0.7, 0.15), (0.9, 0.02), (0.95, 0.02), (0.97, 0.025), (0.978, 0.02)]
    for beta, eta in points:
        print(f"\n[k=1] β={beta}, η={eta}")
        audit_cumulative(m1.build_lookahead_lmi, L, beta, eta)

    print("\n=== k=2 lookahead ===")
    points2 = [(0.5, 0.3), (0.97, 0.030), (0.99, 0.005), (0.992, 0.010)]
    for beta, eta in points2:
        print(f"\n[k=2] β={beta}, η={eta}")
        audit_cumulative(m2.build_lookahead2_lmi, L, beta, eta)


if __name__ == "__main__":
    main()
