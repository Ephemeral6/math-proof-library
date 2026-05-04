"""Localize the lookahead LMI feasibility boundary in [0.97, 0.98]."""
from pathlib import Path
import sys, json
import numpy as np
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
m = import_module("26_lookahead_lmi")
build = m.build_lookahead_lmi


def main():
    L = 1.0
    betas = np.round(np.arange(0.970, 0.985, 0.002), 4).tolist()
    eta_grid = [0.005, 0.008, 0.01, 0.015, 0.02, 0.025, 0.03, 0.04, 0.05, 0.07]

    print(f"β grid: {betas}")
    print(f"η grid: {eta_grid}")
    print()
    print(f"{'β':>6} {'η_opt':>7} {'W':>8} {'C':>9} {'#feas':>6}")
    print("-" * 50)
    rows = []
    for beta in betas:
        feas = []
        for eta in eta_grid:
            r = build(L, beta, eta, fix_alpha=1.0, minimize="C")
            s = r.get('status'); C = r.get('C_Lya')
            if s in ("optimal", "optimal_inaccurate") and C is not None and C > 0:
                feas.append((C, r.get('W'), eta))
        feas.sort()
        if not feas:
            print(f"{beta:>6.3f}: INFEASIBLE")
            rows.append({"beta": float(beta), "feasible": False})
            continue
        C_best, W_best, eta_best = feas[0]
        print(f"{beta:>6.3f} {eta_best:>7.3f} {W_best:>8.2f} {C_best:>9.4f} {len(feas):>6}")
        rows.append({"beta": float(beta), "feasible": True,
                     "eta_opt": eta_best, "W": W_best, "C_Lya": C_best})

    out = Path(__file__).parent / "27_lookahead_boundary_results.json"
    out.write_text(json.dumps(rows, indent=2))
    print(f"\nSaved: {out}")
    last_feas = max((r["beta"] for r in rows if r["feasible"]), default=None)
    first_infeas = min((r["beta"] for r in rows if not r["feasible"]), default=None)
    print(f"\nLookahead LMI β*: last_feasible={last_feas}, first_infeasible={first_infeas}")


if __name__ == "__main__":
    main()
