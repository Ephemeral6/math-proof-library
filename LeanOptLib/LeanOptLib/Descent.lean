import Mathlib.Analysis.Calculus.Gradient.Basic
import Mathlib.Analysis.InnerProductSpace.Basic

/-!
# Descent lemma for L-smooth functions

If `f : E → ℝ` is differentiable with `L`-Lipschitz gradient, then
`f y ≤ f x + ⟪∇f x, y - x⟫ + (L/2) ‖y - x‖²` for all `x y : E`.

Phase 4 of the Lean setup spec — currently states the theorem with `sorry`
proof; the statement compiling validates that the right Mathlib API
(`gradient`, `LipschitzWith`, real inner product) is in scope.
-/

open scoped InnerProductSpace

namespace LeanOptLib

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

/-- Descent lemma: a `C^{1,1}_L` function is bounded above by its quadratic upper model. -/
theorem descent_lemma {f : E → ℝ} {L : NNReal}
    (_hf : Differentiable ℝ f)
    (_hLip : LipschitzWith L (gradient f)) (x y : E) :
    f y ≤ f x + ⟪gradient f x, y - x⟫_ℝ + (L : ℝ) / 2 * ‖y - x‖ ^ 2 := by
  sorry

end LeanOptLib
