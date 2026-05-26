import Mathlib.Analysis.Calculus.Gradient.Basic
import Mathlib.Analysis.InnerProductSpace.Basic
import LeanAgent.OptLib2.Basic.Smoothness

open scoped InnerProductSpace

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

/-- Descent lemma: an L-smooth function is bounded above by its quadratic upper model. -/
theorem descent_lemma {f : E → ℝ} {L : NNReal}
    (hf : Differentiable ℝ f)
    (hLip : LipschitzWith L (gradient f)) (x y : E) :
    f y ≤ f x + ⟪gradient f x, y - x⟫_ℝ + (L : ℝ) / 2 * ‖y - x‖ ^ 2 :=
  LeanAgent.OptLib2.descent_lemma_gradient_form
    (fun z => (hf z).hasGradientAt) hLip x y
