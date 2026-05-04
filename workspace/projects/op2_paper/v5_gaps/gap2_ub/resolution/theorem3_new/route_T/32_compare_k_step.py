"""Compare baseline (k=0), 1-step, 2-step lookahead at the same β to see bulk tightening."""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
import warnings; warnings.filterwarnings("ignore")

m0 = import_module("16_clarabel_test")  # baseline 2-step (no lookahead)
m1 = import_module("26_lookahead_lmi")  # 1-step lookahead
m2 = import_module("29_lookahead2_lmi")  # 2-step lookahead


def best_C(builder, L, beta, eta_grid, fix_alpha=1.0):
    feas = []
    for eta in eta_grid:
        r = builder(L, beta, eta, fix_alpha=fix_alpha, minimize="C")
        s = r.get('status'); C = r.get('C_Lya')
        if s in ("optimal", "optimal_inaccurate") and C is not None and C > 0:
            W = r.get('W')
            if W is not None and W >= 0.999:
                feas.append((C, W, eta, s))
    feas.sort()
    return feas[0] if feas else None


def main():
    L = 1.0
    eta_grid = [0.005, 0.008, 0.01, 0.015, 0.02, 0.025, 0.03, 0.04, 0.05, 0.07, 0.1, 0.15, 0.2, 0.3, 0.5, 0.7, 1.0, 1.3, 1.5]

    print(f"{'β':>6} {'k=0':>14} {'k=1':>14} {'k=2':>14}")
    print("-" * 60)

    for beta in [0.0, 0.3, 0.5, 0.7, 0.85, 0.9, 0.93, 0.95, 0.96, 0.97, 0.978, 0.99]:
        r0 = best_C(m0.build_lmi_clarabel, L, beta, eta_grid)
        r1 = best_C(m1.build_lookahead_lmi, L, beta, eta_grid)
        r2 = best_C(m2.build_lookahead2_lmi, L, beta, eta_grid)
        c0 = f"{r0[0]:.3f}" if r0 else "INF"
        c1 = f"{r1[0]:.3f}" if r1 else "INF"
        c2 = f"{r2[0]:.3f}" if r2 else "INF"
        print(f"{beta:>6.3f} {c0:>14} {c1:>14} {c2:>14}")


if __name__ == "__main__":
    main()
