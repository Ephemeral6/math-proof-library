"""Quick 3-step lookahead test — CLARABEL only, no SCS fallback."""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
import warnings; warnings.filterwarnings("ignore")

# Override the SCS fallback by re-importing and modifying
m = import_module("30_lookahead3_lmi")

# Monkey-patch: build a CLARABEL-only version
import cvxpy as cp
import sympy as sp


def quick_test():
    L = 1.0
    print("3-step lookahead CLARABEL-only:")
    print()
    # Sanity
    r = m.build_lookahead3_lmi(L, 0.0, 1.5, fix_alpha=1.0, minimize="C")
    print(f"  β=0: status={r['status']}, C={r.get('C_Lya')}")
    r = m.build_lookahead3_lmi(L, 0.5, 0.3, fix_alpha=1.0, minimize="C")
    print(f"  β=0.5: status={r['status']}, C={r.get('C_Lya')}")
    print()
    # Critical test points
    for beta in [0.99, 0.992, 0.993, 0.995, 0.997, 0.999]:
        feas = []
        for eta in [0.001, 0.002, 0.005, 0.01, 0.02]:
            r = m.build_lookahead3_lmi(L, beta, eta, fix_alpha=1.0, minimize="C")
            s = r.get('status'); C = r.get('C_Lya')
            if s in ("optimal", "optimal_inaccurate") and C is not None and C > 0:
                feas.append((C, r.get('W'), eta, s))
        if feas:
            feas.sort()
            C, W, eta, st = feas[0]
            print(f"  β={beta:.4f}: C={C:.2f}, η={eta}, W={W:.1f}, status={st}")
        else:
            print(f"  β={beta:.4f}: NO FEASIBLE")


if __name__ == "__main__":
    quick_test()
