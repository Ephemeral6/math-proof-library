"""Full audit at tight CLARABEL tolerance: extract cert + reconstruct M + check V."""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).parent))
import warnings; warnings.filterwarnings("ignore")
import numpy as np
import sympy as sp
from importlib import import_module

mb = import_module("42_clarabel_tight_verify")
mck = import_module("40_check_M_psd")


def main():
    L = 1.0
    points = [(0.5, 0.3), (0.7, 0.15), (0.9, 0.02), (0.95, 0.02),
              (0.97, 0.025), (0.978, 0.02)]
    print("=" * 110)
    print("Tight CLARABEL: extract cert, reconstruct M from substituted pos_combo, check FE residuals")
    print("=" * 110)
    print(f"{'point':>30} {'C':>10} {'M_min(direct)':>14} {'FE_resid_max':>14} {'V_viol':>12}")
    print("-" * 110)
    for beta, eta in points:
        # Need lambdas — call build_lookahead_lmi_tight but it doesn't return lambdas.
        # Use 26_lookahead_lmi but with tight tol. Patch via re-import...
        # Easier: solve with tight tol in 42, get coefs; lambdas not available there.
        # Fall back: use 26's lambdas but the tight C_Lya from 42.
        # Best: reuse the build code in 42 but expose lambdas. For now, use 26 (default tol).
        m26 = import_module("26_lookahead_lmi")
        cert_default = m26.build_lookahead_lmi(L, beta, eta, fix_alpha=1.0, minimize="C")
        # And compare with cert_tight (no lambdas in 42 output, just coefs+W)
        cert_tight = mb.build_lookahead_lmi_tight(L, beta, eta, fix_alpha=1.0, minimize="C")

        # Reconstruct M from default cert (has lambdas)
        try:
            M_default, FE_default = mck.reconstruct_M(L, beta, eta, cert_default)
            M_def_eigs = np.linalg.eigvalsh(M_default)
            M_def_min = float(M_def_eigs[0])
            FE_def_max = max(abs(v) for v in FE_default.values())
        except Exception as e:
            M_def_min = float("nan"); FE_def_max = float("nan")

        # V violation for default
        v_default = mb.numerical_violation(L, beta, eta, cert_default)
        v_tight = mb.numerical_violation(L, beta, eta, cert_tight)

        print(f"β={beta},η={eta} (default):  C={cert_default['C_Lya']:.4f} "
              f"M_min={M_def_min:>12.3e} FE_resid={FE_def_max:>10.3e} V_viol={v_default['max_V_violation']:>10.3e}")
        print(f"β={beta},η={eta} (tight):    C={cert_tight['C_Lya']:.4f} "
              f"V_viol={v_tight['max_V_violation']:>10.3e}")
        print()


if __name__ == "__main__":
    main()
