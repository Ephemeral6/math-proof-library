-- Source: optlib/Optlib/Algorithm/GD/GradientDescent.lean line 133
-- Theorem: convex_lipschitz (sufficient decrease lemma for gradient step)
-- Layer 2, Item 07

import Optlib.Function.Lsmooth

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
variable {f : E → ℝ} {f' : E → E} {l : NNReal} {a : ℝ}

open InnerProductSpace Set

lemma convex_lipschitz (h₁ : ∀ x₁ : E, HasGradientAt f (f' x₁) x₁)
    (h₂ : l > (0 : ℝ)) (ha₁ : l ≤ 1 / a) (ha₂ : a > 0) (h₃ : LipschitzWith l f') :
    ∀ x : E, f (x - a • (f' x)) ≤ f x - a / 2 * ‖f' x‖ ^ 2 := by
  intro x
  calc
    _ ≤ f x + inner (f' x) (x - a • (f' x) - x) + l / 2 * ‖x - a • (f' x) - x‖ ^ 2 :=
        lipschitz_continuos_upper_bound' h₁ h₃ x (x - a • (f' x))
    _ = f x + ((l.1 / 2 * a * a -a) * ‖f' x‖ ^ 2) := by
        simp; ring_nf; simp
        rw [real_inner_smul_right, real_inner_self_eq_norm_sq, norm_smul]; simp
        rw [abs_of_pos ha₂]; ring_nf
    _ ≤ f x + (- a / 2*  ‖(f' x)‖ ^2) := by
        simp only [add_le_add_iff_left, gt_iff_lt, norm_pos_iff, ne_eq]
        apply mul_le_mul_of_nonneg_right
        · simp;
          calc l / 2 * a * a = (l * a) * (a / 2) := by ring_nf
                _  ≤ 1 * (a / 2) := by
                  apply mul_le_mul_of_nonneg _ (by linarith) (by positivity) (by linarith)
                  · exact (le_div_iff₀ ha₂).mp ha₁
                _  = - a / 2 + a := by ring_nf
        · exact sq_nonneg ‖f' x‖
    _ = f x - a / 2 *  ‖f' x‖ ^ 2 := by ring_nf
