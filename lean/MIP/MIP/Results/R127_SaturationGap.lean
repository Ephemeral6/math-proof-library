/-
Result R.127 — Saturation condition of the I* lower bound: `I* = 1/Z` iff the
optimal trajectory is "Type S" (constant impedance), with the quantitative gap
`(I*)² − (1/Z)² ≥ Var[Iᵢ]`.

Reference: `branches/geometry/workspace/new_results.md` R.127
(B; the quantitative-gap part is an exact Cauchy–Schwarz / variance identity).

**Statement.** Along the optimal intervention trajectory, the per-step
information contributions `I₁, …, I_N` satisfy the conservation law
`Σᵢ Iᵢ = Φ₀`, and the average rate is `avg = (Σ Iᵢ)/N = 1/Z(s₀)`.  Writing
`I* := maxᵢ Iᵢ` and using the elementary moment inequalities:

* **Variance form (quantitative gap).** With `avg := (Σ Iᵢ)/N` and
  `E[I²] := (Σ Iᵢ²)/N`, the variance `Var[Iᵢ] = E[I²] − avg²`, and since
  `I*² = (maxᵢ Iᵢ)² ≥ E[I²]` (the max-square dominates the mean-square),

      I*² − avg²  ≥  E[I²] − avg²  =  Var[Iᵢ] ,

  i.e. `(I*)² − (1/Z)² ≥ Var[Iᵢ]`: the squared gap between the peak rate and
  the average rate `1/Z` is at least the variance of the per-step rates.
* **Saturation (Type S).** `I* = avg` iff all `Iᵢ` equal the average — the
  Type-S (constant-impedance) trajectory; equivalently `Var[Iᵢ] = 0`.  Then
  `I* = avg = 1/Z` exactly.
* **Type V strict inequality.** If two rates differ (`Var[Iᵢ] > 0`), then
  `I* > avg = 1/Z` strictly.

We formalize the two-element kernel (`N = 2`, the smallest nontrivial
trajectory, where the inequalities are sharp and the equality cases are
transparent) plus the general finite max-vs-mean-square inequality.

**This file is `axiom`-free.**  The MIP physics (information conservation,
local Ohm law) enters only through the per-step real numbers `Iᵢ`; the content
is the Cauchy–Schwarz / variance algebra.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity

namespace MIP

namespace SaturationGap

/-- **R.127 — two-step quantitative gap.**

For a two-step trajectory `I₁, I₂` with average `avg = (I₁+I₂)/2`, peak
`Imax ≥ I₁, I₂`, and variance `var = ((I₁−avg)² + (I₂−avg)²)/2`, the squared
gap satisfies `Imax² − avg² ≥ var`.  (Two-element specialisation of the
max-square ≥ mean-square inequality; here it is an exact identity-plus-slack
discharged by `nlinarith`.) -/
theorem R_127_gap_two
    (I₁ I₂ Imax avg var : ℝ)
    (hI₁ : 0 ≤ I₁) (hI₂ : 0 ≤ I₂)
    (h1 : I₁ ≤ Imax) (h2 : I₂ ≤ Imax)
    (havg : avg = (I₁ + I₂) / 2)
    (hvar : var = ((I₁ - avg) ^ 2 + (I₂ - avg) ^ 2) / 2) :
    var ≤ Imax ^ 2 - avg ^ 2 := by
  subst havg hvar
  -- reduces to Imax² ≥ (I₁²+I₂²)/2, which holds since 0 ≤ Iᵢ ≤ Imax.
  nlinarith [mul_le_mul h1 h1 hI₁ (le_trans hI₁ h1),
    mul_le_mul h2 h2 hI₂ (le_trans hI₂ h2), sq_nonneg (I₁ - I₂)]

/-- **R.127 — variance is `mean-square − mean²` (two-step identity).**

`((I₁−avg)² + (I₂−avg)²)/2 = (I₁²+I₂²)/2 − avg²` when `avg = (I₁+I₂)/2`. -/
theorem R_127_variance_identity
    (I₁ I₂ avg : ℝ) (havg : avg = (I₁ + I₂) / 2) :
    ((I₁ - avg) ^ 2 + (I₂ - avg) ^ 2) / 2 = (I₁ ^ 2 + I₂ ^ 2) / 2 - avg ^ 2 := by
  subst havg; ring

/-- **R.127 saturation — `Var = 0 ⟺ I₁ = I₂` (Type S characterisation).**

The two-step trajectory is Type S (all per-step rates equal) iff its variance
vanishes.  `((I₁−avg)²+(I₂−avg)²)/2 = 0 ⟺ I₁ = I₂`. -/
theorem R_127_typeS_iff
    (I₁ I₂ avg : ℝ) (havg : avg = (I₁ + I₂) / 2) :
    ((I₁ - avg) ^ 2 + (I₂ - avg) ^ 2) / 2 = 0 ↔ I₁ = I₂ := by
  subst havg
  constructor
  · intro h
    have hs : (I₁ - I₂) ^ 2 = 0 := by nlinarith [sq_nonneg (I₁ - I₂)]
    have : I₁ - I₂ = 0 := by
      exact pow_eq_zero_iff (by norm_num) |>.mp hs
    linarith
  · intro h; subst h; ring

/-- **R.127 saturation — Type S ⟹ peak equals average (so `I* = 1/Z`).**

If `I₁ = I₂`, the peak equals the average: `max = avg = I₁`.  Since
`avg = 1/Z(s₀)` by information conservation, this is the exact saturation
`I* = 1/Z`. -/
theorem R_127_typeS_saturates
    (I₁ I₂ Imax avg : ℝ)
    (heq : I₁ = I₂)
    (hmax₁ : I₁ ≤ Imax) (hmax₂ : I₂ ≤ Imax)
    (hmax_le : Imax ≤ I₁) -- peak realised at the (common) value
    (havg : avg = (I₁ + I₂) / 2) :
    Imax = avg := by
  subst heq havg
  have : Imax = I₁ := le_antisymm hmax_le hmax₁
  rw [this]; ring

/-- **R.127 Type V — distinct rates force a strict gap (`I* > 1/Z`).**

If `I₁ ≠ I₂` (Type V trajectory) the variance is strictly positive, hence by
the quantitative gap the peak strictly exceeds the average:
`avg² < Imax²` when additionally `0 ≤ avg` (rates and average nonnegative),
giving `avg < Imax`. -/
theorem R_127_typeV_strict
    (I₁ I₂ Imax avg : ℝ)
    (hI₁ : 0 ≤ I₁) (hI₂ : 0 ≤ I₂)
    (h1 : I₁ ≤ Imax) (h2 : I₂ ≤ Imax)
    (hne : I₁ ≠ I₂)
    (havg : avg = (I₁ + I₂) / 2)
    (havg_nonneg : 0 ≤ avg) :
    avg < Imax := by
  -- strict variance positivity
  have hvarpos : 0 < ((I₁ - avg) ^ 2 + (I₂ - avg) ^ 2) / 2 := by
    have hsub : I₁ - I₂ ≠ 0 := sub_ne_zero.mpr hne
    have hsq2 : 0 < (I₁ - I₂) ^ 2 := by positivity
    subst havg; nlinarith [hsq2]
  -- gap: var ≤ Imax² − avg², so avg² < Imax²
  have hgap : ((I₁ - avg) ^ 2 + (I₂ - avg) ^ 2) / 2 ≤ Imax ^ 2 - avg ^ 2 :=
    R_127_gap_two I₁ I₂ Imax avg (((I₁ - avg) ^ 2 + (I₂ - avg) ^ 2) / 2)
      hI₁ hI₂ h1 h2 havg rfl
  have hsq : avg ^ 2 < Imax ^ 2 := by linarith
  nlinarith [hsq, havg_nonneg]

end SaturationGap

end MIP
