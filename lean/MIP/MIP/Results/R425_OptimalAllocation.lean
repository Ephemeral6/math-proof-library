/-
Result R.425 — Optimal R/T/C allocation under the central constraint
`N ≈ r · |log κ| · Z` via marginal equalization (Lagrange/KKT).

Reference: `workspace/coe_mip_unification.md` §R.425 (A 级, R.046 移植).
Algebraic style follows R.62 (`R62_KKTMarginalEquality.lean`).

**Statement (CoE × MIP mapping).** With a token budget `B` allocated as
`(x_R, x_T, x_C)` under `c_R·x_R + c_T·x_T + c_C·x_C = B`, the cost
`N = r · |log κ| · Z` has the three partial derivatives (chain rule through
`N`'s factors):

* `∂N/∂x_R = |log κ| · Z · (∂r/∂x_R)`,
* `∂N/∂x_T = r · |log κ| · (∂Z/∂x_T)`,
* `∂N/∂x_C = (− r · Z / κ) · (∂κ/∂x_C)`.

The Lagrangian `L = N − λ·(Σ cᵢ xᵢ − B)` has KKT stationarity
`∂L/∂xᵢ = 0 ⟹ ∂N/∂xᵢ = λ·cᵢ`. Dividing by `cᵢ` gives the
**marginal-equalization** optimality condition:

    (∂N/∂x_R)/c_R  =  (∂N/∂x_T)/c_T  =  (∂N/∂x_C)/c_C  =  λ .

I.e. at the optimum every primitive's marginal effect per unit cost equals a
common shadow price `λ`.

**Pure-math content.** Identical algebraic kernel to R.62: given
`∂N/∂xᵢ = λ·cᵢ` with `cᵢ ≠ 0`, dividing by `cᵢ` yields the common value
`λ` across the three primitives. We also expose the closed-form marginal
ratios (R.425.a) so that the divide-by-cost identity is stated in the
explicit CoE form.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace OptimalAllocation

/-- **R.425 — pairwise marginal equality (divide-by-cost core).**

If `∂N/∂x_i = λ · c_i` and `∂N/∂x_j = λ · c_j` with `c_i, c_j ≠ 0`,
then `(∂N/∂x_i)/c_i = (∂N/∂x_j)/c_j`. (Same kernel as R.62.) -/
theorem R_425_pairwise_marginal_equality
    (dN_i dN_j c_i c_j lam : ℝ)
    (h_ci_ne : c_i ≠ 0) (h_cj_ne : c_j ≠ 0)
    (h_stat_i : dN_i = lam * c_i)
    (h_stat_j : dN_j = lam * c_j) :
    dN_i / c_i = dN_j / c_j := by
  rw [h_stat_i, h_stat_j]
  rw [mul_div_assoc, div_self h_ci_ne, mul_one]
  rw [mul_div_assoc, div_self h_cj_ne, mul_one]

/-- **R.425 — three-primitive marginal equalization (R/T/C).**

KKT stationarity `∂N/∂x_X = λ·c_X` for `X ∈ {R, T, C}` with `c_X ≠ 0`
yields a single shadow price `λ` shared by all three cost-normalised
marginals:

    (∂N/∂x_R)/c_R = (∂N/∂x_T)/c_T = (∂N/∂x_C)/c_C = λ . -/
theorem R_425_marginal_equalization
    (dN_R dN_T dN_C c_R c_T c_C lam : ℝ)
    (h_cR_ne : c_R ≠ 0) (h_cT_ne : c_T ≠ 0) (h_cC_ne : c_C ≠ 0)
    (h_stat_R : dN_R = lam * c_R)
    (h_stat_T : dN_T = lam * c_T)
    (h_stat_C : dN_C = lam * c_C) :
    dN_R / c_R = dN_T / c_T ∧
    dN_T / c_T = dN_C / c_C ∧
    dN_R / c_R = lam := by
  refine ⟨?_, ?_, ?_⟩
  · exact R_425_pairwise_marginal_equality dN_R dN_T c_R c_T lam
      h_cR_ne h_cT_ne h_stat_R h_stat_T
  · exact R_425_pairwise_marginal_equality dN_T dN_C c_T c_C lam
      h_cT_ne h_cC_ne h_stat_T h_stat_C
  · rw [h_stat_R, mul_div_assoc, div_self h_cR_ne, mul_one]

/-- **R.425 — chain-rule marginals from the central relation.**

With `N = r · |log κ| · Z`, the three partials factor through the central
relation. Encoding the factor-wise chain rule as hypotheses, the partials are

* `∂N/∂x_R = |log κ| · Z · ∂r/∂x_R`,
* `∂N/∂x_T = r · |log κ| · ∂Z/∂x_T`,
* `∂N/∂x_C = (− r · Z / κ) · ∂κ/∂x_C`,

and KKT stationarity `∂N/∂x_X = λ·c_X` then equalizes the cost-normalised
marginals. This lemma packages the marginal *forms* and reduces to the
divide-by-cost identity. -/
theorem R_425_central_relation_marginals
    (r absLogκ Z κ
     dr_R dZ_T dκ_C
     c_R c_T c_C lam : ℝ)
    (h_cR_ne : c_R ≠ 0) (h_cT_ne : c_T ≠ 0) (h_cC_ne : c_C ≠ 0)
    -- chain-rule marginal forms (R.102 total differential):
    (dN_R dN_T dN_C : ℝ)
    (h_mR : dN_R = absLogκ * Z * dr_R)
    (h_mT : dN_T = r * absLogκ * dZ_T)
    (h_mC : dN_C = (-(r * Z / κ)) * dκ_C)
    -- KKT stationarity:
    (h_stat_R : dN_R = lam * c_R)
    (h_stat_T : dN_T = lam * c_T)
    (h_stat_C : dN_C = lam * c_C) :
    (absLogκ * Z * dr_R) / c_R = (r * absLogκ * dZ_T) / c_T ∧
    (r * absLogκ * dZ_T) / c_T = ((-(r * Z / κ)) * dκ_C) / c_C := by
  constructor
  · rw [← h_mR, ← h_mT]
    exact R_425_pairwise_marginal_equality dN_R dN_T c_R c_T lam
      h_cR_ne h_cT_ne h_stat_R h_stat_T
  · rw [← h_mT, ← h_mC]
    exact R_425_pairwise_marginal_equality dN_T dN_C c_T c_C lam
      h_cT_ne h_cC_ne h_stat_T h_stat_C

end OptimalAllocation

end MIP
