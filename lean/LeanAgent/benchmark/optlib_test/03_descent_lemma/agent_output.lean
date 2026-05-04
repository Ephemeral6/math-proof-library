import Mathlib.Topology.EMetricSpace.Lipschitz
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.FDeriv.Add
import Mathlib.Analysis.Calculus.Gradient.Basic
import Mathlib.Analysis.InnerProductSpace.Dual

namespace LeanAgent.Generated

open InnerProductSpace

section FDerivForm
variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

private lemma deriv_seg
    {f : E → ℝ} {f' : E → (E →L[ℝ] ℝ)}
    (x y : E) (hd : ∀ x₁ : E, HasFDerivAt f (f' x₁) x₁) :
    ∀ t₀ : ℝ, HasDerivAt (fun t : ℝ ↦ f (x + t • (y - x)))
      (f' (x + t₀ • (y - x)) (y - x)) t₀ := by
  intro t₀
  have h_deriv : ∀ t : ℝ, HasDerivAt (fun t : ℝ ↦ x + t • (y - x)) (y - x) t := by
    intro t
    have hd1 : HasDerivAt (fun s : ℝ ↦ s • (y - x)) (y - x) t := by
      simpa using (hasDerivAt_id t).smul_const (y - x)
    exact hd1.const_add x
  exact HasFDerivAt.comp_hasDerivAt _ (hd _) (h_deriv t₀)

theorem lipschitz_continuous_upper_bound
    {f : E → ℝ} {f' : E → (E →L[ℝ] ℝ)} {l : NNReal}
    (hd : ∀ x : E, HasFDerivAt f (f' x) x)
    (hl : LipschitzWith l f') :
    ∀ (x y : E), f y ≤ f x + (f' x) (y - x) + l / 2 * ‖y - x‖ ^ 2 := by
  intro x y
  rw [lipschitzWith_iff_norm_sub_le] at hl
  set g : ℝ → ℝ := fun t ↦ f (x + t • (y - x))
  set g' : ℝ → ℝ := fun t ↦ f' (x + t • (y - x)) (y - x)
  set LL : ℝ := l * ‖y - x‖ ^ 2 with LL_def
  have gderiv : ∀ t₀ : ℝ, HasDerivAt g (g' t₀) t₀ := deriv_seg x y hd
  have glip : ∀ u v : ℝ, ‖g' u - g' v‖ ≤ LL * ‖u - v‖ := by
    intro u v
    calc ‖g' u - g' v‖
        = ‖f' (x + u • (y - x)) (y - x) - f' (x + v • (y - x)) (y - x)‖ := rfl
      _ = ‖(f' (x + u • (y - x)) - f' (x + v • (y - x))) (y - x)‖ := by
            rw [ContinuousLinearMap.sub_apply]
      _ ≤ ‖f' (x + u • (y - x)) - f' (x + v • (y - x))‖ * ‖y - x‖ :=
            ContinuousLinearMap.le_opNorm _ (y - x)
      _ ≤ ↑l * ‖x + u • (y - x) - (x + v • (y - x))‖ * ‖y - x‖ :=
            mul_le_mul_of_nonneg_right (hl _ _) (norm_nonneg _)
      _ = LL * ‖u - v‖ := by
            rw [LL_def]
            simp only [add_sub_add_left_eq_sub, ← sub_smul, norm_smul, Real.norm_eq_abs]
            ring
  set u : ℝ → ℝ := fun t ↦ g 0 + t * g' 0 + t ^ 2 * (LL / 2)
  set u' : ℝ → ℝ := fun t ↦ g' 0 + LL * t
  have hderiv : ∀ t, HasDerivAt u (u' t) t := by
    intro t
    have hd_id : HasDerivAt (fun s : ℝ ↦ s) 1 t := hasDerivAt_id t
    have h1a : HasDerivAt (fun s : ℝ ↦ s * g' 0) (g' 0) t := by
      simpa using hd_id.mul_const (g' 0)
    have h1 : HasDerivAt (fun s : ℝ ↦ g 0 + s * g' 0) (g' 0) t := h1a.const_add _
    have h2 : HasDerivAt (fun s : ℝ ↦ s ^ 2 * (LL / 2)) (LL * t) t := by
      have hp : HasDerivAt (fun s : ℝ ↦ s ^ 2) (2 * t) t := by
        simpa using (hasDerivAt_pow 2 t)
      have hpc : HasDerivAt (fun s : ℝ ↦ s ^ 2 * (LL / 2)) (2 * t * (LL / 2)) t :=
        hp.mul_const (LL / 2)
      have hh : (2 : ℝ) * t * (LL / 2) = LL * t := by ring
      rw [hh] at hpc; exact hpc
    exact h1.add h2
  have hineq : g 1 ≤ u 1 := by
    refine image_le_of_deriv_right_le_deriv_boundary (a := 0) (b := 1)
      (HasDerivAt.continuousOn (fun x _ ↦ gderiv x))
      (fun t _ ↦ (gderiv t).hasDerivWithinAt)
      (by simp [u, g])
      (HasDerivAt.continuousOn (fun x _ ↦ hderiv x))
      (fun t _ ↦ (hderiv t).hasDerivWithinAt)
      ?_ (Set.right_mem_Icc.mpr (by norm_num))
    intro t ht
    have ht0 : 0 ≤ t := ht.1
    have hgnorm := glip t 0
    have ht_abs : |t - 0| = t := by simp [abs_of_nonneg ht0]
    have habs : |g' t - g' 0| ≤ LL * t := by
      have h1 : ‖g' t - g' 0‖ = |g' t - g' 0| := Real.norm_eq_abs _
      have h2 : ‖t - 0‖ = t := by rw [Real.norm_eq_abs]; exact ht_abs
      rw [h1, h2] at hgnorm; exact hgnorm
    have hpos : g' t - g' 0 ≤ LL * t := (abs_le.mp habs).2
    show g' t ≤ g' 0 + LL * t
    linarith
  have hg1 : g 1 = f y := by simp [g]
  have hg0 : g 0 = f x := by simp [g]
  have hg'0 : g' 0 = (f' x) (y - x) := by simp [g']
  have hu1 : u 1 = f x + (f' x) (y - x) + LL / 2 := by
    show g 0 + 1 * g' 0 + 1 ^ 2 * (LL / 2) = f x + (f' x) (y - x) + LL / 2
    rw [hg0, hg'0]; ring
  have hfy : f y ≤ f x + (f' x) (y - x) + LL / 2 := by rw [← hg1, ← hu1]; exact hineq
  have heq : (↑l : ℝ) / 2 * ‖y - x‖ ^ 2 = LL / 2 := by rw [LL_def]; ring
  linarith [hfy, heq]

end FDerivForm

section GradientForm
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

/-- Descent lemma (gradient form). If `f` has gradient `f' x` at every point and `f'` is
`l`-Lipschitz, then `f y ≤ f x + ⟨f' x, y - x⟩ + l / 2 * ‖y - x‖^2`. -/
theorem descent_lemma_gradient_form
    {f : E → ℝ} {f' : E → E} {l : NNReal}
    (h₁ : ∀ x : E, HasGradientAt f (f' x) x) (h₂ : LipschitzWith l f') :
    ∀ x y : E, f y ≤ f x + inner ℝ (f' x) (y - x) + l / 2 * ‖y - x‖ ^ 2 := by
  intro x y
  set F : E → (E →L[ℝ] ℝ) := fun z => (toDual ℝ E) (f' z) with F_def
  have hF : ∀ z : E, HasFDerivAt f (F z) z := fun z => (h₁ z).hasFDerivAt
  have hLF : LipschitzWith l F := by
    rw [lipschitzWith_iff_norm_sub_le]
    intro u v
    rw [lipschitzWith_iff_norm_sub_le] at h₂
    have hiso : ‖(toDual ℝ E) (f' u) - (toDual ℝ E) (f' v)‖ = ‖f' u - f' v‖ := by
      rw [← map_sub]; exact (toDual ℝ E).norm_map _
    show ‖F u - F v‖ ≤ l * ‖u - v‖
    rw [F_def, hiso]
    exact h₂ u v
  have hbound := lipschitz_continuous_upper_bound hF hLF x y
  have heq : (F x) (y - x) = inner ℝ (f' x) (y - x) := by
    simp [F_def, InnerProductSpace.toDual_apply]
  linarith [heq, hbound]

end GradientForm

end LeanAgent.Generated

#print axioms LeanAgent.Generated.descent_lemma_gradient_form
