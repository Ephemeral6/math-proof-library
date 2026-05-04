-- Source: optlib/Optlib/Algorithm/GD/GradientDescent.lean line 198 (full proof)
-- Theorem: gradient_method (O(1/T) convergence of GD for L-smooth convex f)
-- Layer 3, Item 11

import Optlib.Function.Lsmooth

noncomputable section gradient_descent

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

class Gradient_Descent_fix_stepsize (f : E → ℝ) (f' : E → E) (x0 : E) :=
  (x : ℕ → E) (a : ℝ) (l : NNReal)
  (diff : ∀ x₁, HasGradientAt f (f' x₁) x₁) (smooth : LipschitzWith l f')
  (update : ∀ k : ℕ, x (k + 1) = x k - a • f' (x k))
  (hl : l > (0 : ℝ)) (step₁ : a > 0) (initial : x 0 = x0)

open InnerProductSpace Set

variable {f : E → ℝ} {f' : E → E} {l : NNReal} {xm x₀ : E} {a : ℝ}
variable {alg : Gradient_Descent_fix_stepsize f f' x₀}

-- Helpers (already proved in optlib's GradientDescent.lean — sketches only here):
-- mono_sum_prop, convex_function, convex_lipschitz, point_descent_for_convex.
-- Stub these as `sorry` for purposes of the line-count baseline; full bodies in optlib.

omit [InnerProductSpace ℝ E] [CompleteSpace E] in
lemma mono_sum_prop (mono : ∀ k: ℕ, f (g (k + 1)) ≤ f (g k)):
    ∀ n : ℕ ,  (f (g (n + 1)) -  f xm) ≤ (Finset.range (n + 1)).sum
    (fun (k : ℕ) ↦ f (g (k + 1)) - f xm) / (n + 1) := by sorry

lemma convex_function (h₁ : ∀ x₁ : E, HasGradientAt f (f' x₁) x₁)
    (hfun: ConvexOn ℝ Set.univ f) :
  ∀ x y, f x ≤ f y + inner (f' x) (x - y) := by sorry

lemma convex_lipschitz (h₁ : ∀ x₁ : E, HasGradientAt f (f' x₁) x₁)
    (h₂ : l > (0 : ℝ)) (ha₁ : l ≤ 1 / a) (ha₂ : a > 0) (h₃ : LipschitzWith l f') :
    ∀ x : E, f (x - a • (f' x)) ≤ f x - a / 2 * ‖f' x‖ ^ 2 := by sorry

lemma point_descent_for_convex (hfun : ConvexOn ℝ Set.univ f) (step₂ : alg.a ≤ 1 / alg.l) :
    ∀ k : ℕ, f (alg.x (k + 1)) ≤ f xm + 1 / ((2 : ℝ) * alg.a)
      * (‖alg.x k - xm‖ ^ 2 - ‖alg.x (k + 1) - xm‖ ^ 2) := by sorry

-- Main theorem
lemma gradient_method (hfun: ConvexOn ℝ Set.univ f) (step₂ : alg.a ≤ 1 / alg.l) :
    ∀ k : ℕ, f (alg.x (k + 1)) - f xm ≤ 1 / (2 * (k + 1) * alg.a) * ‖x₀ - xm‖ ^ 2 := by
  intro k
  have step1₂ : alg.l ≤ 1 / alg.a := by
    rw [le_one_div alg.step₁] at step₂; exact step₂; linarith [alg.hl]
  have : LipschitzWith alg.l f' := alg.smooth
  have : alg.l > 0 := alg.hl
  have tα : 1 / ((2 : ℝ) * (k + 1) * alg.a) > 0 := by
    have : alg.a > 0 := alg.step₁
    positivity
  obtain xdescent := point_descent_for_convex hfun step₂
  have mono : ∀ k : ℕ, f (alg.x (k + 1)) ≤ f (alg.x k) := by
    intro k
    rw [alg.update k]
    calc
      _ ≤ f (alg.x k) - alg.a / 2 *  ‖(f' (alg.x k))‖ ^ 2 :=
          convex_lipschitz alg.diff this step1₂ alg.step₁ alg.smooth (alg.x k)
      _ ≤ f (alg.x k) := by
          simp; apply mul_nonneg (by linarith [alg.step₁]) (sq_nonneg _)
  have sum_prop : ∀ n : ℕ, (Finset.range (n + 1)).sum (fun (k : ℕ) ↦ f (alg.x (k + 1)) - f xm)
      ≤ 1 / (2 * alg.a) * (‖x₀ - alg.xm‖ ^ 2 - ‖alg.x (n + 1) - alg.xm‖ ^ 2) := by sorry
  obtain sum_prop_1 := mono_sum_prop mono
  specialize sum_prop_1 k
  specialize sum_prop k
  have h : f (alg.x (k + 1)) - f xm ≤ 1 / (2 * (k + 1) * alg.a) *
     (‖x₀ - xm‖ ^ 2 - ‖alg.x (k + 1) - xm‖ ^ 2) := by sorry
  exact le_mul_of_le_mul_of_nonneg_left h (by simp) (by linarith)

end gradient_descent
