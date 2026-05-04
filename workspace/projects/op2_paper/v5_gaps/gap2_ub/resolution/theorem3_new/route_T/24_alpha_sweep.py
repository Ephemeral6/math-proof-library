"""Route A1: Sweep α (= w_{t+1} - w_t, the per-step weight increment) at high β.

CURRENT LMI: fixed α = 1, minimize W. Bound: F_T ≤ V_0/(T·α + W - α).
GENERALIZED: free α, fix W = some value, check feasibility. Bound has C_eff = S/α (asymptotic).

KEY INSIGHT: If we let α grow with t (polynomial schedule), then:
  - At t = 0, α_0 is smallest (most stringent LMI).
  - At t > 0, α_t > α_0 ⇒ LMI gets MORE slack (easier).
  - So feasibility is determined by t = 0.

For polynomial schedule w_t = (t+a)^p / p with p > 1:
  α_0 = ((a+1)^p - a^p) / p.
  For p = 2: α_0 = a + 1/2.
  For p large: α_0 ≈ a^{p-1} grows fast with a.

At fixed (β, η), can we find (W, α) with W ≥ α such that LMI is feasible AND C_eff = S/α is small?

If S grows faster than α as α increases, polynomial schedule doesn't help.
If S grows slower than α, polynomial schedule helps (S/α → 0 as α → ∞).
"""
from pathlib import Path
import sys, json
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
m = import_module("16_clarabel_test")
build_lmi_clarabel = m.build_lmi_clarabel


def lmi_with_alpha(L, beta, eta, alpha_target, W_target=None):
    """Solve the 2-step LMI with fixed alpha = alpha_target.

    If W_target is None, minimize W subject to W >= alpha. Bound is C_eff = S/alpha.
    """
    # The existing build_lmi_clarabel takes fix_alpha. Call it.
    if W_target is None:
        # Default: minimize W with alpha fixed
        return build_lmi_clarabel(L, beta, eta, fix_alpha=alpha_target, minimize="W")
    else:
        # W = W_target, check feasibility
        # We need a different LMI variant. Use minimize="C" with constraints (manually).
        # For simplicity, just call build_lmi_clarabel with fix_alpha and check status.
        return build_lmi_clarabel(L, beta, eta, fix_alpha=alpha_target, minimize="C")


def main():
    L = 1.0
    print("=" * 80)
    print("Sweep α (= w_{t+1} - w_t) at high β to test polynomial schedule feasibility.")
    print("=" * 80)
    print()

    # For each β at LMI boundary or beyond, sweep α and find min S / max α.
    cases = [
        (0.95, [0.005, 0.008, 0.01, 0.015, 0.02, 0.03, 0.05, 0.08, 0.10]),
        (0.96, [0.005, 0.008, 0.01, 0.015, 0.02, 0.03, 0.05, 0.08, 0.10]),
        (0.97, [0.005, 0.008, 0.01, 0.015, 0.02, 0.03, 0.05, 0.08, 0.10]),
        (0.98, [0.005, 0.008, 0.01, 0.015, 0.02, 0.03, 0.05]),
    ]
    alpha_grid = [0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0]

    rows = []
    for beta, eta_list in cases:
        for alpha in alpha_grid:
            best = None
            for eta in eta_list:
                try:
                    r = build_lmi_clarabel(L, beta, eta, fix_alpha=alpha, minimize="C")
                except Exception:
                    continue
                if r["status"] != "optimal" or r.get("C_Lya") is None: continue
                if r.get("W") is None or r["W"] < alpha - 1e-3: continue
                # Compute C_eff = S/alpha (asymptotic constant)
                S = r["S"]
                C_eff = S / alpha
                # If best, save
                if best is None or C_eff < best["C_eff"]:
                    best = {"beta": beta, "alpha": alpha, "eta": eta,
                            "W": r["W"], "S": S, "C_eff": C_eff,
                            "status": r["status"]}
            if best is not None:
                print(f"β={beta:.3f}, α={alpha:>5}: η_opt={best['eta']:.4f}, "
                      f"W={best['W']:.3f}, S={best['S']:.3f}, **C_eff = S/α = {best['C_eff']:.4f}**")
                rows.append(best)
            else:
                print(f"β={beta:.3f}, α={alpha:>5}: no feasible (η, W)")
        print()

    out = Path(__file__).parent / "24_alpha_sweep_results.json"
    out.write_text(json.dumps(rows, indent=2))
    print(f"Saved: {out}")

    # Find best C_eff per β
    print("\n" + "=" * 80)
    print("BEST C_eff = S/α per β:")
    print("=" * 80)
    by_beta = {}
    for r in rows:
        b = r["beta"]
        if b not in by_beta or r["C_eff"] < by_beta[b]["C_eff"]:
            by_beta[b] = r
    for b in sorted(by_beta):
        r = by_beta[b]
        print(f"β={b:.3f}: best (α={r['alpha']}, η={r['eta']:.4f}) → "
              f"C_eff = S/α = {r['C_eff']:.4f}, W = {r['W']:.3f}")


if __name__ == "__main__":
    main()
