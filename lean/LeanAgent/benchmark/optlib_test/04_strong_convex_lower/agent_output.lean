import Mathlib
import LeanAgent.Generated.sub_normsquare_gradient_helper_depth1_idx1
import LeanAgent.Generated.convex_monotone_gradient_prime_helper_depth1_idx2

namespace LeanAgent.Generated

open InnerProductSpace

/-- If f is strongly convex on s with parameter m and has gradient f' x at every point of s,
then the gradient is m-strongly monotone:
  ⟨f' x - f' y, x - y⟩ ≥ m * ‖x - y‖²    for all x, y ∈ s. -/
theorem strong_convex_gradient_lower_bound
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
    {s : Set E} {f : E → ℝ} {m : ℝ} {f' : E → E}
    (hsc : StrongConvexOn s m f)
    (hf : ∀ x ∈ s, HasGradientAt f (f' x) x) :
    ∀ x ∈ s, ∀ y ∈ s, inner ℝ (f' x - f' y) (x - y) ≥ m * ‖x - y‖ ^ 2 := by
  -- step 1: convert StrongConvexOn → ConvexOn for g := f - (m/2)‖·‖²
  have hconv : ConvexOn ℝ s (fun x => f x - m / 2 * ‖x‖ ^ 2) :=
    strongConvexOn_iff_convex.mp hsc
  -- step 2: gradient of g at x is f' x - m • x
  have hgg : ∀ x ∈ s, HasGradientAt (fun x => f x - m / 2 * ‖x‖ ^ 2) (f' x - m • x) x :=
    sub_normsquare_gradient_helper_depth1_idx1 hf m
  -- step 3: monotone gradient applied to g, g'
  have hmono : ∀ x ∈ s, ∀ y ∈ s,
      inner ℝ ((f' x - m • x) - (f' y - m • y)) (x - y) ≥ (0 : ℝ) :=
    convex_monotone_gradient_prime_helper_depth1_idx2 hconv hgg
  -- step 4: simplify and conclude
  intro x xs y ys
  have h := hmono x xs y ys
  -- Rewrite (f' x - m•x) - (f' y - m•y) = (f' x - f' y) - m • (x - y), then use bilinearity.
  have hexpand : ((f' x - m • x) - (f' y - m • y) : E) = (f' x - f' y) - m • (x - y) := by
    rw [smul_sub]; abel
  rw [hexpand, inner_sub_left, real_inner_smul_left, real_inner_self_eq_norm_sq] at h
  linarith

end LeanAgent.Generated
