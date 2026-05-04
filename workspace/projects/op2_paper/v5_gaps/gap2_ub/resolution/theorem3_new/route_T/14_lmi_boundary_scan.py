"""LMI feasibility boundary scan over β ∈ [0.5, 0.9] step 0.02.

We expect the 2-step LMI to become INFEASIBLE somewhere in (0.5, 0.9) — that's the LMI's
view of β*. Cross-check with PEP transition.
"""
from pathlib import Path
import json
import sys
import numpy as np

sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
m = import_module("11_two_step_lmi_corrected")
build_lmi_corrected = m.build_lmi_corrected


def main():
    L = 1.0
    betas = np.round(np.arange(0.50, 0.91, 0.02), 4).tolist()
    eta_grid = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 1.0, 1.2, 1.5, 1.8]

    print(f"β grid: {len(betas)} points in [0.5, 0.9]")
    print(f"η grid: {eta_grid}")

    results = []
    header = f"{'β':>5} {'η*':>5} {'W':>7} {'C_Lya':>8}  {'#feasible':>10}"
    print(header); print("-" * len(header))

    for beta in betas:
        feasible_results = []
        for eta in eta_grid:
            try:
                r = build_lmi_corrected(L, beta, eta, fix_alpha=1.0, minimize="W")
            except Exception:
                continue
            if r["status"] not in ("optimal", "optimal_inaccurate"):
                continue
            if r["W"] is None or r["a0"] is None:
                continue
            S = r["a0"] + r["a1"] + r["a2"] + r["c01"] + r["c02"] + r["c12"]
            C = (r["W"] - 1.0) * (L / 2) + S
            feasible_results.append((C, S, eta, r))
        feasible_results.sort()
        n_feas = len(feasible_results)
        if n_feas == 0:
            print(f"{beta:>5.2f} {'-':>5} {'-':>7} {'INFEAS':>8}  {0:>10}")
            results.append({"beta": float(beta), "feasible": False, "n_feasible_etas": 0})
            continue
        C_best, S_best, eta_best, r_best = feasible_results[0]
        print(f"{beta:>5.2f} {eta_best:>5.2f} {r_best['W']:>7.4f} {C_best:>8.4f}  {n_feas:>10}")
        results.append({
            "beta": float(beta), "feasible": True, "n_feasible_etas": n_feas,
            "eta_opt": float(eta_best),
            "W": float(r_best["W"]), "C_Lya": float(C_best),
            "a0": float(r_best["a0"]), "a1": float(r_best["a1"]), "a2": float(r_best["a2"]),
            "c01": float(r_best["c01"]), "c02": float(r_best["c02"]), "c12": float(r_best["c12"]),
        })

    out = Path(__file__).parent / "14_lmi_boundary_scan_results.json"
    out.write_text(json.dumps(results, indent=2))
    print(f"\nWritten: {out}")

    # Identify boundary
    print("\n" + "=" * 60)
    print("LMI boundary summary")
    print("=" * 60)
    last_feasible_beta = None
    first_infeasible_beta = None
    for r in results:
        if r["feasible"]:
            last_feasible_beta = r["beta"]
        elif first_infeasible_beta is None:
            first_infeasible_beta = r["beta"]
    print(f"Last feasible β: {last_feasible_beta}")
    print(f"First infeasible β: {first_infeasible_beta}")


if __name__ == "__main__":
    main()
