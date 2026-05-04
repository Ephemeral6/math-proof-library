"""Try Lyapunov with quadratic time schedule:
   V_t = w_t F_t + Q(X_t, X_{t-1}, X_{t-2})  with w_t = (t+W)^2 / 2
not just w_t = t + W - 1.

This may push β*_LMI past 0.957.

The key change: V_{t+1} - V_t now involves a quadratic-in-t coefficient on F_{t+1},
which couples differently to the smoothness inequality.

For convergence, we want V_T ≤ V_0 + ... where V_T ≥ w_T F_T = (T+W)²/2 · F_T.
Then F_T ≤ V_0 · 2/(T+W)², which would give an O(1/T²) bound — that's STRONGER
than O(1/T). If feasible, this would be Nesterov-style acceleration.

Note: HB is famously NOT accelerated on smooth convex (Goujaud et al. 2025), so this
LMI is expected to FAIL. But let's check at what β it fails first.

Modified LMI: minimize K such that
   V_{t+1} - V_t + Σ λ_i G_i = -SOS, where w_t = (t+W)² / (2K)
   so that V_T ≤ V_0 ⇒ F_T ≤ K · V_0 / (T+W)² (if Q PSD on init).
"""
from pathlib import Path
import sys, json
sys.path.insert(0, str(Path(__file__).parent))
import sympy as sp
import cvxpy as cp


def build_quadratic_lmi(L_val, beta_val, eta_val, W_val=2.0):
    """LMI with w_t = (t+W)² and check feasibility for given (β, η, W).

    NOTE: w_{t+1} - w_t = 2(t+W) + 1 — depends on t. So the LMI is TIME-VARYING.
    For a TIME-INVARIANT LMI, we'd need to absorb t into a free variable.

    Simplification: treat w_t = (t+W)² as a constant (unknown). Set w_{t+1} = w_t + α(t),
    where α(t) = 2(t+W) + 1 grows with t.

    For a worst-case LMI we want feasibility for ALL t ≥ 0. As t → ∞, α(t) → ∞.
    The LMI becomes (V_{t+1} - V_t)/(2(t+W)+1) ≤ 0, which equals
       (FE_{t+1} - (1 - 1/(2(t+W)+1)) FE_t) · 2(t+W)+1
    + remainder/2(t+W)+1.

    This is messy. Easier: write w_{t+1} - w_t = β_α (free variable, "growth rate").
    Then LMI gives: F_T ≤ V_0 / w_T. For w_t to be ~t² or ~t, we need β_α(t) → const
    (linear w_t) or β_α(t) → 2(t+W)+1 (quadratic w_t).

    For SHB, the standard analysis already uses linear w_t. Trying quadratic is an
    aspirational test; it probably fails (not accelerated).
    """
    # We'll just try fixing α to large constant value and see if feasibility holds.
    # Specifically: w_{t+1} = w_t + α with α a large constant. If LMI feasible for
    # large α, that's a "stronger than O(1/T)" bound.
    pass


def main():
    """Quick sanity check on whether quadratic time schedule is worth pursuing.

    Just modify the existing 2-step LMI to allow alpha (= w_{t+1} - w_t) to be
    a free non-negative variable that we MAXIMIZE. If the maximum α is finite,
    we get O(1/T) bound. If it's unbounded, we get faster.

    We already know (Goujaud et al.) that HB doesn't accelerate, so we expect
    α* < ∞.
    """
    print("Note: HB is provably NOT accelerated on smooth convex (Goujaud et al. 2025,")
    print("'Provable non-accelerations of the heavy-ball method', Math. Programming 2025).")
    print("So a w_t = t² schedule is expected to fail. Will skip this experiment.")
    print()
    print("Instead, focus on improving the constant in the O(1/T) bound by:")
    print("  - Adding more generators (e.g., 4-anchor convexity).")
    print("  - Using α = w_{t+1} - w_t as a free variable to maximize (already done).")
    print()


if __name__ == "__main__":
    main()
