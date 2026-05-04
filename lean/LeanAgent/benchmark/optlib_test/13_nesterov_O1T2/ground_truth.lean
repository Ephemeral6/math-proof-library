-- Source: optlib/Optlib/Algorithm/Nesterov/NesterovAccelerationFirst.lean line 41
-- Theorem: Nesterov_first_converge
-- Layer 3, Item 13 — O(1/T^2) for Nesterov AGD

import Optlib.Function.Proximal

local notation "⟪" x ", " y "⟫" => @inner ℝ _ _ x y

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
variable {f h : E → ℝ} {f' : E → E} {x0 : E}

open Set Real

class Nesterov_first (f h: E → ℝ) (f' : E → E) (x0 : E) :=
  (l : NNReal) (x y : ℕ → E) (t γ : ℕ → ℝ) (hl : l > (0 : ℝ))
  (h₁ : ∀ x : E, HasGradientAt f (f' x) x) (convf : ConvexOn ℝ univ f)
  (h₂ : LipschitzWith l f') (convh : ConvexOn ℝ univ h)
  (oriy : y 0 = x 0) (oriγ : γ 0 = 1) (initial : x 0 = x0)
  (cond : ∀ n : ℕ+, (1 - γ n) * t n / γ n ^ 2 ≤ t (n - 1) / γ (n - 1) ^ 2)
  (tbound : ∀ k : ℕ, 0 < t k ∧ t k ≤ 1 / l) (γbound : ∀ n : ℕ, 0 < γ n ∧ γ n ≤ 1)
  (update1 : ∀ k : ℕ+, y k = x k + (γ k * (1 - γ (k - 1)) / γ (k - 1)) • (x k - x (k - 1)))
  (update2 : ∀ k : ℕ, prox_prop (t k • h) (y k - t k • f' (y k)) (x (k + 1)))

variable {alg : Nesterov_first f h f' x0}
variable {xm : E}

theorem Nesterov_first_converge (minφ : IsMinOn (f + h) univ xm) :
    ∀ k, f (alg.x (k + 1)) + h (alg.x (k + 1)) -
    f xm - h xm ≤ (alg.γ k) ^ 2 / (2 * alg.t k) * ‖x0 - xm‖ ^ 2 := by
  sorry  -- 290-line proof in optlib; uses:
  --   * descent lemma f(x_{k+1}) ≤ f(y_k) + ⟨f'(y_k), x_{k+1} - y_k⟩ + L/2 · ‖x_{k+1} - y_k‖^2
  --   * prox_iff_subderiv (subdifferential characterization of prox iterate)
  --   * Convex_first_order_condition' (convexity of f at y_k)
  --   * Lyapunov function:  V_k = (t_k / γ_k^2) (φ(x_k) - φ(xm)) + (1/2) ‖z_k - xm‖^2
  --     where z_k = x_{k-1} + (1/γ_{k-1}) (x_k - x_{k-1})
  --   * Show V_k monotone non-increasing using cond and tbound
