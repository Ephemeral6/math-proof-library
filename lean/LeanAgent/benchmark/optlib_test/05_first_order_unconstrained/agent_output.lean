import Mathlib.Analysis.Calculus.Gradient.Basic
import Mathlib.Analysis.Calculus.LocalExtr.Basic
import Mathlib.Analysis.InnerProductSpace.Dual

namespace LeanAgent.Generated

open InnerProductSpace Filter Set

/-- If `f` has a gradient `f'(x)` at every point and attains its minimum at `xm` over
the entire space, then the gradient at the minimum is zero. -/
theorem first_order_unconstrained
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
    {xm : E} {f : E → ℝ} {f' : E → E}
    (hf : ∀ x : E, HasGradientAt f (f' x) x)
    (min : IsMinOn f Set.univ xm)
    (_hfc : ContinuousOn f' Set.univ) :
    f' xm = 0 := by
  -- step 1: From IsMinOn over univ, derive IsLocalMin (univ ∈ 𝓝 xm).
  have hloc : IsLocalMin f xm := IsMinOn.isLocalMin min Filter.univ_mem
  -- step 2: At a local min, fderiv = 0.
  have hfderiv : fderiv ℝ f xm = 0 := IsLocalMin.fderiv_eq_zero hloc
  -- step 3: hf gives HasGradientAt f (f' xm) xm; convert to HasFDerivAt and read off fderiv.
  have h_dual : (toDual ℝ E) (f' xm) = 0 := by
    rw [← hfderiv]; exact ((hf xm).hasFDerivAt).fderiv.symm
  -- step 4: toDual ℝ E is a linear isometry equiv; map_eq_zero gives f' xm = 0.
  exact (toDual ℝ E).map_eq_zero_iff.mp h_dual

end LeanAgent.Generated
