/-
Result R.89 (T.19) — Variance decomposition of `N = Φ₀ · Z`.

Reference: `proofs/derived/stability.md` R.89 (A 无条件 under T.8 + D.4.9
+ independence of `Φ₀` and `Z` over the problem distribution).

**Statement (independent-variables identity form).** For two independent
nonnegative random variables `X, Y` (in MIP: `X = Z`, `Y = Φ₀`):

    Var[X · Y]  =  Var[X] · E[Y]²  +  Var[Y] · E[X²] .

In MIP notation with `X = Z`, `Y = Φ₀`:

    Var[N] = σ_Z² · E[Φ₀]² + Var[Φ₀] · E[Z²]  ,

which matches `Z̄² · Var[Φ₀] + σ_Z² · E[Φ₀²]` when `σ_Z = 0` (then
`E[Z²] = Z̄²`).

This file proves the **pure-algebraic kernel** of the variance
identity, given the four moments `(E[X], E[X²], E[Y], E[Y²])` and
their squared-product `E[(XY)²] = E[X²] · E[Y²]` from independence.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring

namespace MIP

namespace VarianceProduct

/-- **Var(XY) algebraic identity (R.89 kernel).**

Given:
* `eX, eX2`: `E[X]`, `E[X²]`,
* `eY, eY2`: `E[Y]`, `E[Y²]`,
* `varX`  : `E[X²] − E[X]²` (definition of variance),
* `varY`  : `E[Y²] − E[Y]²`,

the algebraic identity

    E[X²]·E[Y²] − E[X]²·E[Y]²  =  Var[X] · E[Y]²  +  Var[Y] · E[X²]

holds purely by ring algebra.  Under independence,
`E[(XY)²] = E[X²]·E[Y²]` and `E[XY] = E[X]·E[Y]`, so the left-hand side
equals `Var[X·Y]`, yielding R.89. -/
theorem var_product_algebraic
    (eX eX2 eY eY2 varX varY : ℝ)
    (h_varX : varX = eX2 - eX ^ 2)
    (h_varY : varY = eY2 - eY ^ 2) :
    eX2 * eY2 - eX ^ 2 * eY ^ 2 = varX * eY ^ 2 + varY * eX2 := by
  rw [h_varX, h_varY]; ring

/-- **R.89 (Var[X·Y] form for independent X, Y).**

If `X, Y` are independent (so `E[(XY)²] = E[X²]·E[Y²]` and
`E[XY] = E[X]·E[Y]`), then `Var[XY] = Var[X]·E[Y]² + Var[Y]·E[X²]`. -/
theorem R_89_var_product
    (eX eX2 eY eY2 eXY eXY2 varXY varX varY : ℝ)
    (h_indep_first  : eXY  = eX * eY)
    (h_indep_second : eXY2 = eX2 * eY2)
    (h_varXY : varXY = eXY2 - eXY ^ 2)
    (h_varX  : varX = eX2 - eX ^ 2)
    (h_varY  : varY = eY2 - eY ^ 2) :
    varXY = varX * eY ^ 2 + varY * eX2 := by
  rw [h_varXY, h_indep_first, h_indep_second]
  -- Goal: eX2 * eY2 - (eX * eY)^2 = varX * eY^2 + varY * eX2
  have h_sq : (eX * eY) ^ 2 = eX ^ 2 * eY ^ 2 := by ring
  rw [h_sq]
  exact var_product_algebraic eX eX2 eY eY2 varX varY h_varX h_varY

/-- **R.89 (MIP form).**

Specialising the independent-variable identity to `X = Z`, `Y = Φ₀`:

    Var[N] = σ_Z² · E[Φ₀]² + Var[Φ₀] · E[Z²] .

When `σ_Z² = E[Z²] − E[Z]²` (definition), and using
`E[Z²] = E[Z]² + σ_Z² = Z̄² + σ_Z²`, this rearranges to
`Var[N] = Z̄² · Var[Φ₀] + σ_Z² · (E[Φ₀²])` — exactly the form quoted
in `proofs/derived/stability.md` R.89. -/
theorem R_89_MIP_form
    (Z_bar σ_Z2 EPhi VarPhi EPhi2 VarN : ℝ)
    (h_EPhi2 : EPhi2 = VarPhi + EPhi ^ 2)
    (h_indep_decomp : VarN = σ_Z2 * EPhi ^ 2 + VarPhi * (Z_bar ^ 2 + σ_Z2)) :
    VarN = Z_bar ^ 2 * VarPhi + σ_Z2 * EPhi2 := by
  rw [h_indep_decomp, h_EPhi2]; ring

end VarianceProduct

end MIP
