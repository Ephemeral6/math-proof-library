-- Source: optlib/Optlib/Function/Lsmooth.lean line 49
-- Theorem: lipschitz_continuous_upper_bound
-- Layer 1, Item 01

import Mathlib.Topology.EMetricSpace.Lipschitz
import Mathlib.Analysis.Calculus.Deriv.Pow
import Optlib.Optimality.OptimalityConditionOfUnconstrainedProblem
import Optlib.Differential.Lemmas

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

open InnerProductSpace Set

variable {f : E → ℝ} {a : ℝ} {f' : E → (E →L[ℝ] ℝ)} {f'' : E → E →L[ℝ] E →L[ℝ] ℝ} {l : NNReal}

theorem lipschitz_continuous_upper_bound {E : Type*}
    [NormedAddCommGroup E] [NormedSpace ℝ E]
    {f : E → ℝ} {f' : E → (E →L[ℝ] ℝ)} {l : NNReal}
    (hd : ∀ x : E, HasFDerivAt f (f' x) x)
    (hl : LipschitzWith l f') :
    ∀ (x y : E), f y ≤ f x + (f' x) (y - x)
      + l / 2 * ‖y - x‖ ^ 2 := by
  intro x y; rw [lipschitzWith_iff_norm_sub_le] at hl
  let g := fun t : ℝ ↦ f (x + t • (y - x))
  let g' := fun t : ℝ ↦ (f' (x + t • (y - x)) (y - x))
  let LL := l * ‖y - x‖ ^ 2
  obtain gderiv : ∀ t₀ : ℝ , HasDerivAt g (g' t₀) t₀ :=
    deriv_function_comp_segment x y hd
  have glip : ∀ u v : ℝ, ‖g' u - g' v‖  ≤
      l * ‖y - x‖ ^ 2 * ‖u - v‖ := by
    intro u v
    calc
      _ ≤ ‖f' (x + u • (y - x)) - f' (x + v • (y - x))‖ * ‖y - x‖ :=
          ContinuousLinearMap.le_opNorm _ (y - x)
      _ ≤ l * ‖x + u • (y - x) - (x + v • (y - x))‖ * ‖y - x‖ :=
          mul_le_mul_of_nonneg (hl _ _) (le_refl _) (norm_nonneg _) (norm_nonneg _)
      _ = l * ‖y - x‖ ^ 2 * ‖u - v‖ := by
        rw [← sub_sub, add_sub_right_comm, sub_self, zero_add, ← sub_smul, norm_smul]; ring_nf
  let u := fun t₀ : ℝ ↦ g 0 + t₀ * (g' 0) +  t₀ ^ 2 * (LL / 2)
  let u' := fun t : ℝ ↦ g' 0 + LL * t
  have hderiv : ∀ t, HasDerivAt u (u' t) t := by
    intro t
    apply HasDerivAt.add
    · apply HasDerivAt.const_add
      · apply hasDerivAt_mul_const
    · have : l * ‖y - x‖ ^ 2 * t = (2 * t) * (l * ‖y - x‖ ^ 2 / 2) := by field_simp; ring_nf
      rw [this]; apply HasDerivAt.mul_const
      obtain hd := HasDerivAt.pow (n := 2) (hasDerivAt_id' t)
      simp at hd; exact hd
  suffices g 1 ≤ u 1 by
    simp [u, g, u', LL, g'] at this
    rw [map_sub]; linarith
  apply image_le_of_deriv_right_le_deriv_boundary (a := 0) (b := 2)
  · exact HasDerivAt.continuousOn (fun x _ ↦ gderiv x)
  · exact fun t _ ↦ HasDerivAt.hasDerivWithinAt (gderiv t)
  · simp [u]
  · exact HasDerivAt.continuousOn (fun x _ ↦ hderiv x)
  · exact fun t _ ↦ HasDerivAt.hasDerivWithinAt (hderiv t)
  · intro t ht
    simp [u', LL]; simp at ht
    apply tsub_le_iff_left.mp
    apply le_trans (le_abs_self _)
    convert (glip t 0); simp; rw [abs_of_nonneg ht.1]
  simp
