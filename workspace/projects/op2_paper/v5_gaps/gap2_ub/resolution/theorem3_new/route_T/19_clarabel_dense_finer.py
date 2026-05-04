"""Finer CLARABEL 2-step LMI sweep for clean C(β) curve and pinned-down β*.

Two regions:
  (A) β ∈ [0, 0.5] step 0.025 — dense curve in the easy regime.
  (B) β ∈ [0.78, 0.86] step 0.01 — pinpoint LMI feasibility boundary.
"""
from pathlib import Path
import sys, json
import numpy as np
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
m = import_module("16_clarabel_test")
build_lmi_clarabel = m.build_lmi_clarabel


def sweep_C_beta(L, betas, eta_grid, label):
    print(f"\n{'='*70}")
    print(f"{label} — β grid: {len(betas)} pts, η grid: {len(eta_grid)} pts")
    print(f"{'='*70}")
    print(f"{'β':>6} {'η_opt':>6} {'W':>8} {'C_Lya':>8} {'#feas':>6}")
    print("-" * 50)
    rows = []
    for beta in betas:
        feas = []
        for eta in eta_grid:
            try:
                r = build_lmi_clarabel(L, beta, eta, fix_alpha=1.0, minimize="C")
            except Exception:
                continue
            if r["status"] != "optimal" or r.get("C_Lya") is None:
                continue
            if r["W"] < 0.999: continue
            feas.append((r["C_Lya"], r["W"], eta, r))
        feas.sort()
        if not feas:
            print(f"{beta:>6.3f}: no feasible η (INFEASIBLE)")
            rows.append({"beta": float(beta), "feasible": False})
            continue
        C_best, W_best, eta_best, r_best = feas[0]
        print(f"{beta:>6.3f} {eta_best:>6.2f} {W_best:>8.4f} {C_best:>8.4f} {len(feas):>6}")
        rows.append({
            "beta": float(beta), "feasible": True, "n_feasible_etas": len(feas),
            "eta_opt": float(eta_best), "W": float(W_best), "C_Lya": float(C_best),
            "a0": float(r_best["a0"]), "a1": float(r_best["a1"]), "a2": float(r_best["a2"]),
            "c01": float(r_best["c01"]), "c02": float(r_best["c02"]), "c12": float(r_best["c12"]),
            "S": float(r_best["S"]),
        })
    return rows


def main():
    L = 1.0

    # Region A: dense curve
    betas_A = np.round(np.arange(0.00, 0.51, 0.025), 4).tolist()
    eta_A = [0.5, 0.7, 0.9, 1.0, 1.1, 1.2, 1.3, 1.5, 1.7]
    rows_A = sweep_C_beta(L, betas_A, eta_A, "REGION A: dense [0, 0.5]")

    # Region B: feasibility boundary
    betas_B = np.round(np.arange(0.78, 0.87, 0.01), 4).tolist()
    eta_B = [0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.5]  # small η since η_opt → 0 at large β
    rows_B = sweep_C_beta(L, betas_B, eta_B, "REGION B: pinpoint [0.78, 0.86]")

    out = Path(__file__).parent / "19_clarabel_dense_finer_results.json"
    out.write_text(json.dumps({"region_A": rows_A, "region_B": rows_B}, indent=2))
    print(f"\nSaved: {out}")

    # Find β* from region B
    print("\n" + "=" * 70)
    print("LMI feasibility boundary — fine resolution")
    print("=" * 70)
    last_feas = max((r["beta"] for r in rows_B if r["feasible"]), default=None)
    first_infeas = min((r["beta"] for r in rows_B if not r["feasible"]), default=None)
    print(f"  Last feasible β:    {last_feas}")
    print(f"  First infeasible β: {first_infeas}")
    print(f"  → LMI β* ∈ ({last_feas}, {first_infeas}]")


if __name__ == "__main__":
    main()
