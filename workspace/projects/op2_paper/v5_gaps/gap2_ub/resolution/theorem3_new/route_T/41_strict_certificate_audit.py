"""Audit strict-margin certificates: at ε small but positive, are the certificates
GENUINELY clean (M PSD, FE coefs zero, V_{t+1} ≤ V_t pointwise)?
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).parent))
import warnings; warnings.filterwarnings("ignore")
import numpy as np
from importlib import import_module

m = import_module("39_strict_lmi")


def numerical_violation(L, beta, eta, cert):
    a0, a1, a2 = cert["a0"], cert["a1"], cert["a2"]
    c01, c02, c12 = cert["c01"], cert["c02"], cert["c12"]
    W = cert["W"]; w0 = W - 1.0
    x0 = 1.0
    xs = [x0, x0]
    for t in range(200):
        x_new = xs[-1] * (1 - eta * L + beta) - beta * xs[-2]
        xs.append(x_new)
    xs = np.array(xs[1:])
    Vs = []
    for t in range(len(xs)):
        x_t = xs[t]; x_tm1 = xs[max(0, t-1)]; x_tm2 = xs[max(0, t-2)]
        f_val = 0.5 * L * x_t**2
        Q = (a0 * x_t**2 + a1 * x_tm1**2 + a2 * x_tm2**2
             + c01 * x_t * x_tm1 + c02 * x_t * x_tm2 + c12 * x_tm1 * x_tm2)
        Vs.append((w0 + 1.0 * t) * f_val + Q)
    Vs = np.array(Vs)
    diffs = np.diff(Vs[2:])
    return {"max_violation": float(np.max(diffs)),
            "max_V": float(np.max(np.abs(Vs))),
            "V_T_at_500": float(Vs[-1])}


def main():
    L = 1.0
    print("=" * 90)
    print("Audit: strict ε-PSD certificates — does numerical V_{t+1} ≤ V_t hold cleanly?")
    print("=" * 90)
    print(f"\n{'point':>30} {'ε':>10} {'C':>10} {'a0_max':>10} {'V violation':>14} {'V_T_500':>12}")
    print("-" * 90)
    points = [(0.5, 0.3), (0.7, 0.15), (0.9, 0.02), (0.95, 0.02), (0.97, 0.025)]
    for beta, eta in points:
        # First, ε=0 (default)
        r0 = m.build_strict_lookahead_lmi(L, beta, eta, fix_alpha=1.0, minimize="C", epsilon=0.0)
        if r0.get("a0") is not None:
            v0 = numerical_violation(L, beta, eta, r0)
            max_a = max(abs(r0["a0"]), abs(r0["a1"]), abs(r0["a2"]),
                        abs(r0["c01"]), abs(r0["c02"]), abs(r0["c12"]))
            print(f"β={beta},η={eta:>5}, ε=0:    {0.0:>10.0e} {r0['C_Lya']:>10.4f} {max_a:>10.1f} "
                  f"{v0['max_violation']:>14.3e} {v0['V_T_at_500']:>12.3e}")

        # Find largest feasible ε
        for eps in [1e-6, 1e-4, 1e-3, 5e-3, 1e-2, 5e-2, 1e-1]:
            r = m.build_strict_lookahead_lmi(L, beta, eta, fix_alpha=1.0, minimize="C", epsilon=eps)
            if r.get("a0") is None: continue
            v = numerical_violation(L, beta, eta, r)
            max_a = max(abs(r["a0"]), abs(r["a1"]), abs(r["a2"]),
                        abs(r["c01"]), abs(r["c02"]), abs(r["c12"]))
            print(f"  ε={eps:.0e}: {r['status']:>22} C={r['C_Lya']:>8.4f} "
                  f"a_max={max_a:>9.1f} V_viol={v['max_violation']:>11.3e}")
        print()


if __name__ == "__main__":
    main()
