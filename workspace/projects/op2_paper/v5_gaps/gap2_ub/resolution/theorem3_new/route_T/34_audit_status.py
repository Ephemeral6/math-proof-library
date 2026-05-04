"""Audit 2: Check CLARABEL solver status across all 'certified' points.

For each (β, η) in the round-3 and round-4 tables, query the LMI again and report:
  - solver status (optimal vs optimal_inaccurate)
  - if optimal_inaccurate: what's the violation magnitude in V_{t+1} - V_t numerically?

Truly certified = "optimal" status. "optimal_inaccurate" requires further validation.
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
import warnings; warnings.filterwarnings("ignore")
import numpy as np

m0 = import_module("16_clarabel_test")  # baseline 2-step (no lookahead)
m1 = import_module("26_lookahead_lmi")  # 1-step lookahead
m2 = import_module("29_lookahead2_lmi")  # 2-step lookahead


def numerical_violation(L, beta, eta, cert):
    """Simulate SHB on f(x) = (L/2) x² and check V_{t+1} - V_t over t ∈ [2, 199]."""
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
        V = (w0 + 1.0 * t) * f_val + Q
        Vs.append(V)
    Vs = np.array(Vs)
    diffs = np.diff(Vs[2:])
    return {"max_violation": float(np.max(diffs)), "max_V": float(np.max(np.abs(Vs)))}


def audit_point(name, builder, L, beta, eta):
    r = builder(L, beta, eta, fix_alpha=1.0, minimize="C")
    if r.get("a0") is None:
        return {"point": name, "status": r.get("status"), "feasible": False}
    cert = r
    viol = numerical_violation(L, beta, eta, cert)
    rel = viol["max_violation"] / max(viol["max_V"], 1e-12)
    return {
        "point": name,
        "beta": beta, "eta": eta,
        "status": r["status"],
        "C": r["C_Lya"],
        "max_V_violation": viol["max_violation"],
        "max_V": viol["max_V"],
        "rel_violation": rel,
    }


def main():
    L = 1.0
    print(f"{'Point':>30} {'status':>20} {'C':>10} {'V_max':>10} {'V_violation':>12} {'rel':>10}")
    print("-" * 100)

    results = []

    # Baseline (no lookahead) — recheck a few
    cases_baseline = [(0.0, 1.5), (0.5, 0.5), (0.7, 0.3), (0.9, 0.08), (0.95, 0.03)]
    for beta, eta in cases_baseline:
        r = audit_point(f"k=0 β={beta},η={eta}", m0.build_lmi_clarabel, L, beta, eta)
        results.append(r)
        print(f"{r.get('point'):>30} {r.get('status'):>20} "
              f"{r.get('C', 0):>10.3f} {r.get('max_V', 0):>10.3f} "
              f"{r.get('max_V_violation', 0):>12.4e} {r.get('rel_violation', 0):>10.4f}")

    # k=1 lookahead
    cases_k1 = [(0.0, 1.5), (0.5, 0.3), (0.7, 0.15), (0.9, 0.02),
                (0.93, 0.025), (0.95, 0.02), (0.97, 0.025), (0.978, 0.02)]
    for beta, eta in cases_k1:
        r = audit_point(f"k=1 β={beta},η={eta}", m1.build_lookahead_lmi, L, beta, eta)
        results.append(r)
        print(f"{r.get('point'):>30} {r.get('status'):>20} "
              f"{r.get('C', 0):>10.3f} {r.get('max_V', 0):>10.3f} "
              f"{r.get('max_V_violation', 0):>12.4e} {r.get('rel_violation', 0):>10.4f}")

    # k=2 lookahead
    cases_k2 = [(0.0, 1.5), (0.5, 0.3), (0.97, 0.030), (0.98, 0.015),
                (0.99, 0.005), (0.992, 0.010)]
    for beta, eta in cases_k2:
        r = audit_point(f"k=2 β={beta},η={eta}", m2.build_lookahead2_lmi, L, beta, eta)
        results.append(r)
        print(f"{r.get('point'):>30} {r.get('status'):>20} "
              f"{r.get('C', 0):>10.3f} {r.get('max_V', 0):>10.3f} "
              f"{r.get('max_V_violation', 0):>12.4e} {r.get('rel_violation', 0):>10.4f}")

    # Summary
    print()
    print("=" * 80)
    print("Summary:")
    print("=" * 80)
    n_optimal = sum(1 for r in results if r.get("status") == "optimal")
    n_optimal_inacc = sum(1 for r in results if r.get("status") == "optimal_inaccurate")
    n_other = sum(1 for r in results if r.get("status") not in ("optimal", "optimal_inaccurate"))
    print(f"  optimal:            {n_optimal}")
    print(f"  optimal_inaccurate: {n_optimal_inacc}")
    print(f"  other:              {n_other}")

    # Identify rel_violation > 1e-3 cases
    suspect = [r for r in results if r.get("rel_violation", 0) > 1e-3]
    if suspect:
        print(f"\n  POINTS WITH SIGNIFICANT V VIOLATION (rel > 1e-3): {len(suspect)}")
        for r in suspect:
            print(f"    {r['point']}: status={r['status']}, rel_violation={r['rel_violation']:.4f}")


if __name__ == "__main__":
    main()
