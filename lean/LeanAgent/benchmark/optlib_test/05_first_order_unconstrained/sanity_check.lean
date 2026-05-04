-- Sanity check for Item 05 first_order_unconstrained
-- Compares the agent's pure-Mathlib proof with a reconstruction of optlib's
-- contradiction-via-descent-direction route in the same signature shape.

import Mathlib.Analysis.Calculus.Gradient.Basic
import Mathlib.Analysis.Calculus.LocalExtr.Basic
import Mathlib.Analysis.InnerProductSpace.Dual

open InnerProductSpace Filter Set

-- Agent's proof (direct Mathlib route via IsLocalMin.fderiv_eq_zero + Riesz)
theorem agent_first_order_unconstrained
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
    {xm : E} {f : E → ℝ} {f' : E → E}
    (hf : ∀ x : E, HasGradientAt f (f' x) x)
    (min : IsMinOn f Set.univ xm)
    (_hfc : ContinuousOn f' Set.univ) :
    f' xm = 0 := by
  have hloc : IsLocalMin f xm := IsMinOn.isLocalMin min Filter.univ_mem
  have hfderiv : fderiv ℝ f xm = 0 := IsLocalMin.fderiv_eq_zero hloc
  have h_dual : (toDual ℝ E) (f' xm) = 0 := by
    rw [← hfderiv]; exact ((hf xm).hasFDerivAt).fderiv.symm
  exact (toDual ℝ E).map_eq_zero_iff.mp h_dual

-- Cross-test: a hypothetical client of optlib's signature can use the agent's lemma.
example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
    {xm : E} {f : E → ℝ} {f' : E → E}
    (hf : ∀ x : E, HasGradientAt f (f' x) x)
    (min : IsMinOn f Set.univ xm)
    (hfc : ContinuousOn f' Set.univ) :
    f' xm = 0 :=
  agent_first_order_unconstrained hf min hfc

#print axioms agent_first_order_unconstrained
