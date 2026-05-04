import Mathlib

namespace LeanAgent.Generated

open InnerProductSpace

/-- Synthesized helper (parent: strong_convex_gradient_lower_bound).
    If `f` has gradient `f' x` at every point of `s`, then for any `m : ℝ` the function
    `fun x => f x - (m/2) * ‖x‖²` has gradient `f' x - m • x` at every point of `s`. -/
theorem sub_normsquare_gradient_helper_depth1_idx1
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
    {s : Set E} {f : E → ℝ} {f' : E → E}
    (hf : ∀ x ∈ s, HasGradientAt f (f' x) x) (m : ℝ) :
    ∀ x ∈ s, HasGradientAt (fun x => f x - m / 2 * ‖x‖ ^ 2) (f' x - m • x) x := by
  intro x xs
  -- Unfold HasGradientAt to HasFDerivAt with the toDual map.
  show HasFDerivAt (fun x => f x - m / 2 * ‖x‖ ^ 2) (toDual ℝ E (f' x - m • x)) x
  have hf1 : HasFDerivAt f (toDual ℝ E (f' x)) x := hf x xs
  -- gradient of ‖·‖² is (2 : ℝ) • innerSL ℝ x (as fderiv).
  -- HasFDerivAt.norm_sq gives the (2 : ℕ) • version; we cast to ℝ.
  have hnsN : HasFDerivAt (fun y : E => ‖y‖ ^ 2) ((2 : ℕ) • (innerSL ℝ : E →L[ℝ] E →L[ℝ] ℝ) x) x :=
    (hasFDerivAt_id (𝕜 := ℝ) x).norm_sq
  have hns : HasFDerivAt (fun y : E => ‖y‖ ^ 2) ((2 : ℝ) • (innerSL ℝ : E →L[ℝ] E →L[ℝ] ℝ) x) x := by
    have heq : ((2 : ℕ) • (innerSL ℝ : E →L[ℝ] E →L[ℝ] ℝ) x)
              = ((2 : ℝ) • (innerSL ℝ : E →L[ℝ] E →L[ℝ] ℝ) x) := by
      ext v; simp [two_smul, two_mul]
    rw [← heq]; exact hnsN
  -- multiply by (m/2)
  have hns' : HasFDerivAt (fun y : E => m / 2 * ‖y‖ ^ 2)
      ((m / 2) • ((2 : ℝ) • (innerSL ℝ : E →L[ℝ] E →L[ℝ] ℝ) x)) x := hns.const_mul (m / 2)
  have hsub : HasFDerivAt (fun y : E => f y - m / 2 * ‖y‖ ^ 2)
      (toDual ℝ E (f' x) - (m / 2) • ((2 : ℝ) • (innerSL ℝ : E →L[ℝ] E →L[ℝ] ℝ) x)) x :=
    hf1.sub hns'
  -- now identify the two ContinuousLinearMaps
  convert hsub using 1
  ext v
  simp only [toDual_apply_apply, ContinuousLinearMap.sub_apply,
             ContinuousLinearMap.smul_apply, innerSL_apply_apply, smul_eq_mul,
             inner_sub_left, real_inner_smul_left]
  ring

end LeanAgent.Generated
