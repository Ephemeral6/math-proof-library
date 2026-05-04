import Mathlib.Analysis.Convex.Strong
import Mathlib.Analysis.InnerProductSpace.Basic

namespace LeanAgent.Generated

/-- If `f` satisfies the two-point inequality
  `f (a • x + b • y) ≤ a * f x + b * f y - m / 2 * a * b * ‖x - y‖^2`
for every convex combination on a convex set `s`, then `f` is
`StrongConvexOn s m f`. -/
theorem strongly_convex_on_def
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {s : Set E} {f : E → ℝ} {m : ℝ}
    (hs : Convex ℝ s)
    (hfun : ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s →
      ∀ ⦃a⦄, 0 ≤ a → ∀ ⦃b⦄, 0 ≤ b → a + b = 1 →
      f (a • x + b • y) ≤ a * f x + b * f y - m / 2 * a * b * ‖x - y‖ ^ 2) :
    StrongConvexOn s m f := by
  -- step 1: Open StrongConvexOn record by anonymous constructor.
  refine ⟨?_, ?_⟩
  -- step 2: Discharge the convexity goal directly from hs.
  · exact hs
  -- step 3: Introduce the universal variables.
  intro x hx y hy a b ha hb hab
  -- step 4: Specialize hfun at the introduced variables.
  have h_hfun : f (a • x + b • y) ≤ a * f x + b * f y - m / 2 * a * b * ‖x - y‖ ^ 2 :=
    hfun hx hy ha hb hab
  -- step 5: Unfold StrongConvexOn / UniformConvexOn definitional layers.
  dsimp
  -- step 6: Rewrite m/2 * a * b * ‖x - y‖^2 as a * b * (m/2 * ‖x - y‖^2) by ring.
  have h_rewrite : m / 2 * a * b * ‖x - y‖ ^ 2 = a * b * (m / 2 * ‖x - y‖ ^ 2) := by ring
  -- step 7: Combine and close.
  linarith [h_hfun, h_rewrite]

end LeanAgent.Generated
