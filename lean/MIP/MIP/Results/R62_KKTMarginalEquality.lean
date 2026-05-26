/-
Result R.62 — Three-dimensional training-resource optimal allocation.

Reference: `proofs/derived/A_grade.md` R.62 (A 条件 (R.61s IID 假设),
2026-05-19 v2.2 等级继承修复).

**Statement (algebraic KKT kernel).** For the Lagrangian
`L(x, λ) := N(x_1, x_2, x_3) − λ · (c_1 x_1 + c_2 x_2 + c_3 x_3 − B)`,
the stationarity condition `∂L/∂x_i = 0` gives `∂N/∂x_i = λ · c_i`,
hence:

    (∂N/∂x_1) / c_1  =  (∂N/∂x_2) / c_2  =  (∂N/∂x_3) / c_3  =  λ .

I.e. the marginal cost-normalised derivatives are equal at the optimum.

**Pure-math content.** Pure algebraic manipulation: given
`∂N/∂x_i = λ · c_i` for `i ∈ {1, 2, 3}` with `c_i ≠ 0`, dividing both
sides by `c_i` gives the common value `λ`.

This file proves the **divide-by-cost identity** without committing to
multivariate calculus.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace KKTMarginalEquality

/-- **R.62 — pairwise marginal equality (algebraic core).**

If `∂N/∂x_1 = λ · c_1` and `∂N/∂x_2 = λ · c_2` with `c_1, c_2 ≠ 0`,
then `(∂N/∂x_1) / c_1 = (∂N/∂x_2) / c_2`. -/
theorem R_62_pairwise_marginal_equality
    (dN_dx1 dN_dx2 c_1 c_2 lam : ℝ)
    (h_c1_ne : c_1 ≠ 0) (h_c2_ne : c_2 ≠ 0)
    (h_stationary_1 : dN_dx1 = lam * c_1)
    (h_stationary_2 : dN_dx2 = lam * c_2) :
    dN_dx1 / c_1 = dN_dx2 / c_2 := by
  rw [h_stationary_1, h_stationary_2]
  rw [mul_div_assoc, div_self h_c1_ne, mul_one]
  rw [mul_div_assoc, div_self h_c2_ne, mul_one]

/-- **R.62 — three-way marginal equality.**

Extending to three dimensions: stationarity gives a common `λ` value. -/
theorem R_62_three_way_marginal_equality
    (dN_dx1 dN_dx2 dN_dx3 c_1 c_2 c_3 lam : ℝ)
    (h_c1_ne : c_1 ≠ 0) (h_c2_ne : c_2 ≠ 0) (h_c3_ne : c_3 ≠ 0)
    (h_stationary_1 : dN_dx1 = lam * c_1)
    (h_stationary_2 : dN_dx2 = lam * c_2)
    (h_stationary_3 : dN_dx3 = lam * c_3) :
    dN_dx1 / c_1 = dN_dx2 / c_2 ∧
    dN_dx2 / c_2 = dN_dx3 / c_3 ∧
    dN_dx1 / c_1 = lam := by
  refine ⟨?_, ?_, ?_⟩
  · exact R_62_pairwise_marginal_equality dN_dx1 dN_dx2 c_1 c_2 lam
      h_c1_ne h_c2_ne h_stationary_1 h_stationary_2
  · exact R_62_pairwise_marginal_equality dN_dx2 dN_dx3 c_2 c_3 lam
      h_c2_ne h_c3_ne h_stationary_2 h_stationary_3
  · rw [h_stationary_1]
    rw [mul_div_assoc, div_self h_c1_ne, mul_one]

end KKTMarginalEquality

end MIP
