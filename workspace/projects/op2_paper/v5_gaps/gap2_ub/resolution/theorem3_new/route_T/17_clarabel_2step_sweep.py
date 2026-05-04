"""High-precision (CLARABEL) 2-step LMI sweep.

Replaces the SCS-based sweeps in steps 13/14 which gave inaccurate certificates.
Sweep:
  - Dense β grid [0, 0.95] (or wherever feasibility holds)
  - Fine η grid
  - Record only CLARABEL-status='optimal' results.
  - Locate β* = the largest β where the LMI remains feasible (= 2-step's view of phase boundary).
"""
from pathlib import Path
import sys
import json
import numpy as np
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
m = import_module("16_clarabel_test")
build_lmi_clarabel = m.build_lmi_clarabel


def main():
    L = 1.0
    # Coarse-then-fine: coarse β grid first, then localize β* with finer steps.
    betas_coarse = np.round(np.arange(0.00, 0.96, 0.05), 4).tolist()
    eta_grid = [0.3, 0.5, 0.7, 0.9, 1.0, 1.1, 1.2, 1.3, 1.5, 1.7, 1.9]

    print(f"β grid (coarse): {len(betas_coarse)} points: {betas_coarse}")
    print(f"η grid: {eta_grid}")
    print()

    results = []
    print(f"{'β':>5} {'η_opt':>6} {'W':>8} {'C_Lya':>8} {'#feas':>6}  {'opt-status@η_opt'}")
    print("-" * 70)
    for beta in betas_coarse:
        feas = []
        for eta in eta_grid:
            try:
                r = build_lmi_clarabel(L, beta, eta, fix_alpha=1.0, minimize="C")
            except Exception:
                continue
            # Only accept "optimal" (CLARABEL's tight certificate)
            if r["status"] != "optimal" or r.get("C_Lya") is None:
                continue
            # Sanity: W >= 1
            if r["W"] < 0.999: continue
            feas.append((r["C_Lya"], r["W"], eta, r))
        feas.sort()
        if not feas:
            print(f"{beta:>5.2f}: no CLARABEL-optimal feasible η")
            results.append({"beta": float(beta), "feasible": False})
            continue
        C_best, W_best, eta_best, r_best = feas[0]
        print(f"{beta:>5.2f} {eta_best:>6.2f} {W_best:>8.4f} {C_best:>8.4f} {len(feas):>6}  optimal")
        results.append({
            "beta": float(beta), "feasible": True, "n_feasible_etas": len(feas),
            "eta_opt": float(eta_best), "W": float(W_best), "C_Lya": float(C_best),
            "a0": float(r_best["a0"]), "a1": float(r_best["a1"]), "a2": float(r_best["a2"]),
            "c01": float(r_best["c01"]), "c02": float(r_best["c02"]), "c12": float(r_best["c12"]),
            "S": float(r_best["S"]),
        })

    out = Path(__file__).parent / "17_clarabel_2step_sweep_results.json"
    out.write_text(json.dumps(results, indent=2))
    print(f"\nWritten: {out}")

    # Identify boundary
    print("\n" + "=" * 70)
    print("Feasibility boundary (CLARABEL-tight)")
    print("=" * 70)
    last_feas = max((r["beta"] for r in results if r["feasible"]), default=None)
    first_infeas = min((r["beta"] for r in results if not r["feasible"]), default=None)
    print(f"  Last feasible β:    {last_feas}")
    print(f"  First infeasible β: {first_infeas}")


if __name__ == "__main__":
    main()
