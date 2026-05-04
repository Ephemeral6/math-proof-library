"""Plan 3: mpmath high-precision verification of existing CLARABEL certificate.

The CLARABEL certificate at (β=0.95, η=0.02, k=1) has huge coefficients (a₀ ~ 8000)
and pointwise V violation ~0.25. Question: is this a TRUE Lyapunov in higher precision,
or does the violation persist?

Method: compute V_t in 50-digit precision (mpmath dps=50). If V_{t+1} - V_t ≤ 0
holds to 50 digits, the certificate is genuine and double-precision is just imprecise.
If it still violates by ~0.25, the certificate is NOT genuine.
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).parent))
import warnings; warnings.filterwarnings("ignore")
import numpy as np
from importlib import import_module

m1 = import_module("26_lookahead_lmi")
m2 = import_module("29_lookahead2_lmi")

try:
    import mpmath
    mpmath.mp.dps = 50  # 50 decimal places
    print(f"Using mpmath dps={mpmath.mp.dps}")
except ImportError:
    print("mpmath not available; using float64")
    mpmath = None


def simulate_mpmath(L, beta, eta, x0, T):
    """Simulate SHB in mpmath precision."""
    L_mp = mpmath.mpf(str(L))
    beta_mp = mpmath.mpf(str(beta))
    eta_mp = mpmath.mpf(str(eta))
    x0_mp = mpmath.mpf(str(x0))
    xs = [x0_mp, x0_mp]
    for t in range(T):
        # f(x) = (L/2)x², gradient = Lx
        g = L_mp * xs[-1]
        x_new = xs[-1] - eta_mp * g + beta_mp * (xs[-1] - xs[-2])
        xs.append(x_new)
    return xs[1:]  # x_0, x_1, ...


def compute_V_mpmath(t, w0, alpha, a0, a1, a2, c01, c02, c12, x_t, x_tm1, x_tm2, f_val):
    """V_t in mpmath precision."""
    w_t = mpmath.mpf(str(w0)) + mpmath.mpf(str(alpha)) * t
    a0_mp = mpmath.mpf(str(a0)); a1_mp = mpmath.mpf(str(a1)); a2_mp = mpmath.mpf(str(a2))
    c01_mp = mpmath.mpf(str(c01)); c02_mp = mpmath.mpf(str(c02)); c12_mp = mpmath.mpf(str(c12))
    Q = (a0_mp * x_t**2 + a1_mp * x_tm1**2 + a2_mp * x_tm2**2
         + c01_mp * x_t * x_tm1 + c02_mp * x_t * x_tm2 + c12_mp * x_tm1 * x_tm2)
    return w_t * f_val + Q


def verify_mpmath(L, beta, eta, cert, T_max=100):
    if mpmath is None:
        print("mpmath unavailable")
        return
    a0, a1, a2 = cert["a0"], cert["a1"], cert["a2"]
    c01, c02, c12 = cert["c01"], cert["c02"], cert["c12"]
    W = cert["W"]; w0 = W - 1.0
    L_mp = mpmath.mpf(str(L))

    xs = simulate_mpmath(L, beta, eta, 1.0, T_max+5)
    Vs = []
    for t in range(T_max):
        x_t = xs[t]; x_tm1 = xs[max(0, t-1)]; x_tm2 = xs[max(0, t-2)]
        f_val = mpmath.mpf("0.5") * L_mp * x_t**2
        V = compute_V_mpmath(t, w0, 1.0, a0, a1, a2, c01, c02, c12,
                              x_t, x_tm1, x_tm2, f_val)
        Vs.append(V)
    diffs = [Vs[t+1] - Vs[t] for t in range(2, len(Vs)-1)]
    max_diff = max(diffs, key=lambda d: float(d))
    return {
        "V0": Vs[0], "V_max_diff": max_diff,
        "V_at_T100": Vs[T_max-1], "max_V_abs": max(abs(V) for V in Vs)
    }


def main():
    L = 1.0
    points = [
        ("k=1, β=0.5, η=0.3",   m1.build_lookahead_lmi, 0.5, 0.3),
        ("k=1, β=0.7, η=0.15",  m1.build_lookahead_lmi, 0.7, 0.15),
        ("k=1, β=0.9, η=0.02",  m1.build_lookahead_lmi, 0.9, 0.02),
        ("k=1, β=0.95, η=0.02", m1.build_lookahead_lmi, 0.95, 0.02),
        ("k=1, β=0.97, η=0.025",m1.build_lookahead_lmi, 0.97, 0.025),
        ("k=2, β=0.99, η=0.005",m2.build_lookahead2_lmi, 0.99, 0.005),
    ]

    print("=" * 100)
    print(f"{'point':>30} {'cert C':>10} {'V_0 (mp)':>12} {'V_500 (mp)':>15} "
          f"{'max V_t+1-V_t':>16} {'V violation < 1e-12?'}")
    print("=" * 100)

    for name, builder, beta, eta in points:
        r = builder(L, beta, eta, fix_alpha=1.0, minimize="C")
        if r.get("a0") is None:
            print(f"{name:>30}  certificate failed")
            continue
        v = verify_mpmath(L, beta, eta, r, T_max=100)
        if v is None: continue
        # max diff is mpmath; convert to float for display
        max_diff_float = float(v["V_max_diff"])
        max_V_float = float(v["max_V_abs"])
        rel = max_diff_float / max(max_V_float, 1e-12)
        ok = max_diff_float < 1e-12
        print(f"{name:>30} {r['C_Lya']:>10.3f} "
              f"{float(v['V0']):>12.4e} {float(v['V_at_T100']):>15.4e} "
              f"{max_diff_float:>16.4e} ({'YES' if ok else 'NO, rel=' + f'{rel:.2e}'})")


if __name__ == "__main__":
    main()
