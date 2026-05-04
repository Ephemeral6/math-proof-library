/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: OptExt contributors

# Expectation, inner product, and norm-squared helpers

The polarisation identity in inner-product form, plus its expected-value
counterpart for unbiased random vectors with bounded variance.  These are
the workhorses of the SGD analysis chain (`OptExt.SGD`) and any
expected-error bound on stochastic algorithms.
-/

import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.MeasureTheory.Integral.Bochner
import Mathlib.MeasureTheory.Function.L2Space
import Mathlib.Tactic

open MeasureTheory

namespace OptExt

variable {E : Type*}
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

variable {Ω : Type*} [MeasurableSpace Ω] {ℙ : Measure Ω} [IsProbabilityMeasure ℙ]

/-- Pointwise polarisation around a fixed centre `μ : E`:
`‖g‖² = ‖g − μ‖² + 2⟪g, μ⟫_ℝ − ‖μ‖²`. -/
lemma norm_sq_eq_sub_inner_sub (g μ : E) :
    ‖g‖ ^ 2 = ‖g - μ‖ ^ 2 + 2 * (inner (𝕜 := ℝ) g μ) - ‖μ‖ ^ 2 := by
  have := norm_sub_sq_real g μ
  linarith

/-- The integral of a constant equals the constant (probability measure). -/
lemma integral_const_prob (c : ℝ) :
    ∫ _, c ∂ℙ = c := by
  rw [integral_const, measure_univ, ENNReal.one_toReal, smul_eq_mul, one_mul]

end OptExt
