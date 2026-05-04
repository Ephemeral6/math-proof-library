"""Precise LMI β* localization, step 0.001 in [0.950, 0.965]."""
from pathlib import Path
import sys, json
import numpy as np
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
m = import_module("16_clarabel_test")
build_lmi_clarabel = m.build_lmi_clarabel


def main():
    L = 1.0
    betas = np.round(np.arange(0.950, 0.966, 0.001), 4).tolist()
    eta_grid = [0.003, 0.005, 0.008, 0.01, 0.015, 0.02, 0.03, 0.05]

    print(f"β grid (fine): {betas}")
    print(f"η grid: {eta_grid}")
    print()
    print(f"{'β':>6} {'η_opt':>7} {'W':>10} {'C_Lya':>10} {'#feas':>6}")
    print("-" * 55)
    rows = []
    for beta in betas:
        feas = []
        for eta in eta_grid:
            try:
                r = build_lmi_clarabel(L, beta, eta, fix_alpha=1.0, minimize="C")
            except Exception:
                continue
            if r["status"] != "optimal" or r.get("C_Lya") is None: continue
            if r["W"] < 0.999: continue
            feas.append((r["C_Lya"], r["W"], eta, r))
        feas.sort()
        if not feas:
            print(f"{beta:>6.3f}: INFEASIBLE")
            rows.append({"beta": float(beta), "feasible": False})
            continue
        C_best, W_best, eta_best, r_best = feas[0]
        print(f"{beta:>6.3f} {eta_best:>7.3f} {W_best:>10.4f} {C_best:>10.4f} {len(feas):>6}")
        rows.append({
            "beta": float(beta), "feasible": True,
            "eta_opt": eta_best, "W": W_best, "C_Lya": C_best,
        })
        # Save partial
        partial = Path(__file__).parent / "21_lmi_boundary_precise_partial.json"
        partial.write_text(json.dumps(rows, indent=2))

    out = Path(__file__).parent / "21_lmi_boundary_precise_results.json"
    out.write_text(json.dumps(rows, indent=2))
    print(f"\nSaved: {out}")
    last_feas = max((r["beta"] for r in rows if r["feasible"]), default=None)
    first_infeas = min((r["beta"] for r in rows if not r["feasible"]), default=None)
    print(f"\nβ*_LMI: last feasible = {last_feas}, first infeasible = {first_infeas}")


if __name__ == "__main__":
    main()
