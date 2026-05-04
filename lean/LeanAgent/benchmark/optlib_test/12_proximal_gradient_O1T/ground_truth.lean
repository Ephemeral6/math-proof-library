-- Source: optlib/Optlib/Algorithm/ProximalGradient.lean line 39
-- Theorem: proximal_gradient_method_converge
-- Layer 3, Item 12 — O(1/T) for proximal gradient

import Optlib.Function.Proximal

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
variable [ProperSpace E]
variable {x₀ : E} {f : E → ℝ} {f' : E → E} {h : E → ℝ}

open Set

class proximal_gradient_method (f h: E → ℝ) (f' : E → E) (x₀ : E) :=
  (xm : E) (t : ℝ) (x : ℕ → E) (L : NNReal)
  (fconv : ConvexOn ℝ univ f) (hconv : ConvexOn ℝ univ h)
  (h₁ : ∀ x₁ : E, HasGradientAt f (f' x₁) x₁) (h₂ : LipschitzWith L f')
  (h₃ : ContinuousOn h univ) (minphi : IsMinOn (f + h) Set.univ xm)
  (tpos : 0 < t) (step : t ≤ 1 / L) (ori : x 0 = x₀) (hL : L > (0 : ℝ))
  (update : ∀ (k : ℕ), prox_prop (t • h) (x k - t • f' (x k)) (x (k + 1)))

variable {alg : proximal_gradient_method f h f' x₀}

theorem proximal_gradient_method_converge : ∀ (k : ℕ+),
    (f (alg.x k) + h (alg.x k) - f alg.xm - h alg.xm)
    ≤ 1 / (2 * k * alg.t) * ‖x₀ - alg.xm‖ ^ 2 := by
  sorry  -- 165-line proof in optlib; uses:
  --   * lipschitz_continuos_upper_bound' (descent lemma)
  --   * Convex_first_order_condition' (first-order convex)
  --   * prox_iff_subderiv_smul (proximal subdifferential characterization)
  --   * SubderivAt.add and HasSubgradientAt
  --   * gradient mapping G_t and its properties (analogous to GD's gradient term)
