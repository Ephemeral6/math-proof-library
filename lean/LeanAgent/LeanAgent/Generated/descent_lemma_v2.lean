import Mathlib
import LeanAgent.OptLib2.Basic.Smoothness

namespace LeanAgent.Generated

open scoped InnerProductSpace

/-- Descent lemma. -/
theorem descent_lemma_v2 {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [CompleteSpace E]
    {f : E → ℝ} {L : NNReal}
    (hf : Differentiable ℝ f)
    (hL : LipschitzWith L (fun z => gradient f z))
    (x y : E) :
    f y ≤ f x + ⟪gradient f x, y - x⟫_ℝ + (L : ℝ) / 2 * ‖y - x‖^2 :=
  LeanAgent.OptLib2.descent_lemma_gradient_form
    (fun z => (hf z).hasGradientAt) hL x y

end LeanAgent.Generated
