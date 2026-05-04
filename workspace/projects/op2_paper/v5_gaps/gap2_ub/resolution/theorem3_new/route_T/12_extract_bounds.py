"""From the corrected 2-step Lyapunov LMI results, extract:
  - The optimal Lyapunov for each beta (= (β, η) minimizing W).
  - The implied deterministic rate constant S(β, η) = sum of all Q coefficients
    (this is V_0 / D^2 at zero-momentum init).
  - The bias-variance composition giving stochastic O(σD/√T) constant.

Lyapunov: V_t = (t + W - 1)(f - f*) + a_0 X_t² + a_1 X_p1² + a_2 X_p2²
                + c_01 X_t X_p1 + c_02 X_t X_p2 + c_12 X_p1 X_p2.
With α = 1: w_t = t + W - 1; w_T = T + W - 1.
For T >= 1: V_T <= V_0  (since V_{t+1} - V_t <= 0 when LMI feasible).
Then  FE_T <= V_0 / w_T = V_0 / (T + W - 1).

V_0 (zero-momentum init y_-1 = y_-2 = y_0):
  = (W - 1) FE_0 + (a_0 + a_1 + a_2 + c_01 + c_02 + c_12) ||y_0 - y*||²
  = (W - 1) FE_0 + S * D²,    where S := a_0 + a_1 + a_2 + c_01 + c_02 + c_12.

For y_0 with FE_0 ≤ (L/2) D² (smoothness UB on FE_0):
  V_0 ≤ (W - 1)(L/2) D² + S D² = [(W-1)(L/2) + S] D².

So the deterministic rate constant is:
  C(β, η) := (W-1)(L/2) + S.
giving  FE_T ≤ C(β, η) D² / (T + W - 1).

For T large, this is ~ C(β, η) D² / T.

For OP-2 v6 we want the BEST (minimum) C(β, η) per β.
"""
from pathlib import Path
import json
import numpy as np


def main():
    data = json.load(open(Path(__file__).with_name("11_two_step_lmi_corrected_results.json")))

    # Group by β
    by_beta = {}
    for r in data:
        by_beta.setdefault(r["beta"], []).append(r)

    print("=" * 100)
    print("Best 2-step Lyapunov per β (minimizing C(β,η) = (W-1)(L/2) + S, with L = 1).")
    print("=" * 100)
    print(f"{'beta':>5} {'eta':>5} {'W':>7} {'a0':>7} {'a1':>7} {'a2':>7} "
          f"{'c01':>7} {'c02':>7} {'c12':>7} {'S':>7} {'C':>7} ")
    print("-" * 100)

    best_by_beta = {}
    for beta in sorted(by_beta):
        L = 1.0
        candidates = []
        for r in by_beta[beta]:
            if r["W"] is None or r["a0"] is None: continue
            S = r["a0"] + r["a1"] + r["a2"] + r["c01"] + r["c02"] + r["c12"]
            C = (r["W"] - 1.0) * (L / 2) + S
            candidates.append((C, S, r))
        candidates.sort()
        if not candidates:
            print(f"{beta:>5.2f}: no feasible LMI.")
            continue
        C_best, S_best, r_best = candidates[0]
        print(f"{beta:>5.2f} {r_best['eta']:>5.2f} {r_best['W']:>7.4f} "
              f"{r_best['a0']:>7.3f} {r_best['a1']:>7.3f} {r_best['a2']:>7.3f} "
              f"{r_best['c01']:>7.3f} {r_best['c02']:>7.3f} {r_best['c12']:>7.3f} "
              f"{S_best:>7.4f} {C_best:>7.4f}")
        best_by_beta[beta] = r_best | {"S": S_best, "C": C_best}

    print("\n" + "=" * 100)
    print("Stochastic UB (bias-variance, horizon-tuned η_T):")
    print("  E[f(y_T) - f*] ≤ 2 √(C(β) (1-β) L) · σ D / √T")
    print("=" * 100)
    print(f"{'beta':>5} {'C(β)':>9} {'eta_T factor':>14} {'stoch const':>14}  ")
    print("-" * 60)
    for beta, r in sorted(best_by_beta.items()):
        L = 1.0
        C = r["C"]
        # bias-variance: bias ≤ C LD²/(η_T T) (using FE_T ≤ V_0/(T+W-1) ≈ V_0/T = C D²/T = C LD²/(η_T T) ... hmm)
        # Actually, in the non-stochastic case: FE_T ≤ C(β) D² / T.
        # With stochastic noise σ², the variance term is η_T L σ²/(1-β) (standard SHB var bound).
        # Bias term for last-iterate is C(β) D² / T (with η_T appearing only via the worst-case bound — actually
        # the bias-variance composition assumes bias = C(β,η_T) D²/(η_T T), where C depends on η_T.
        # For our LMI, we just take a fixed (β, η) that gives FE_T ≤ C(β) D²/T (deterministic),
        # then add variance σ² η_T L / (1-β) for stochastic. With η_T = D √((1-β)C/(Lσ²T)):
        # combined ≤ 2 √(C L/(1-β)) σ D / √T.
        const_stoch = 2 * np.sqrt(C * L / (1 - beta)) if beta < 1 else float("inf")
        print(f"{beta:>5.2f} {C:>9.4f} {'D√((1-β)C/(Lσ²T))':>14} {const_stoch:>14.4f}  ")


if __name__ == "__main__":
    main()
