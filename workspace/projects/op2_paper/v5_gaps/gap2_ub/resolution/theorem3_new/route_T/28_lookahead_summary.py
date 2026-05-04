"""Build a clean C(β) table for the lookahead LMI."""
from pathlib import Path
import sys, json
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
import warnings; warnings.filterwarnings("ignore")
m = import_module("26_lookahead_lmi")


def main():
    L = 1.0
    print(f"{'β':>6} {'η_opt':>7} {'W':>9} {'C':>10}")
    print("-" * 40)
    results = []
    betas = [0.0, 0.3, 0.5, 0.7, 0.8, 0.85, 0.9, 0.93, 0.95, 0.96, 0.97, 0.978]
    eta_grid = [0.005, 0.008, 0.01, 0.015, 0.02, 0.025, 0.03, 0.04, 0.05, 0.07, 0.1, 0.15, 0.2, 0.3, 0.5, 0.7, 1.0, 1.3, 1.5]
    for beta in betas:
        feas = []
        for eta in eta_grid:
            r = m.build_lookahead_lmi(L, beta, eta, fix_alpha=1.0, minimize="C")
            s = r.get("status"); C = r.get("C_Lya")
            if s in ("optimal", "optimal_inaccurate") and C is not None and C > 0:
                feas.append((C, r.get("W"), eta, s))
        if feas:
            feas.sort()
            C, W, eta, st = feas[0]
            print(f"{beta:>6.3f} {eta:>7.3f} {W:>9.2f} {C:>10.4f}")
            results.append({"beta": beta, "eta": eta, "W": W, "C": C, "status": st})
        else:
            print(f"{beta:>6.3f}: INFEASIBLE")
            results.append({"beta": beta, "feasible": False})

    out = Path(__file__).parent / "28_lookahead_summary_results.json"
    out.write_text(json.dumps(results, indent=2))
    print(f"\nSaved: {out}")


if __name__ == "__main__":
    main()
