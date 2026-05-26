/-
Result R.277 — Microscopic train–test coupling coefficient `λ₁₂`.

Reference: `branches/thermodynamics/workspace/new_results.md` R.277
(λ₁₂ microscopic derivation, A under mean-field + bivariate-Gaussian,
2026-05-18 thermodynamics branch).

**Statement.**  In the double-Landau free energy of R.275 the train–test order
parameters `ψ = θ_train`, `φ = θ_test` are coupled by `(λ₁₂/2)·(ψ − φ)²`.
Matching the quadratic form to the bivariate-Gaussian joint fluctuation action
(covariance `Σ` with Pearson correlation `ρ`), and using the FDT relations
`σ_ψ² = T·χ¹`, `σ_φ² = T·χ²` (R.270), the temperature cancels and one obtains
the explicit micro-formula

    λ₁₂ = ρ / ((1 − ρ²) · √(χ¹·χ²)) ,                                  (♠')

with `ρ ∈ (−1, 1)` the generalization correlation coefficient and
`χ¹, χ² > 0` the train / test susceptibilities.

This file formalises (♠') as a `def` plus its core properties:

* **well-defined** — for `ρ ∈ (−1,1)`, `χ¹, χ² > 0`, the denominator is `≠ 0`;
* **sign** — `λ₁₂ > 0 ↔ ρ > 0` (the coupling carries the sign of the
  generalization correlation: positive transfer ⇒ positive coupling, negative
  transfer `ρ < 0` ⇒ `λ₁₂ < 0`);
* **decoupling at ρ = 0** — `λ₁₂ = 0` (no generalization ⇒ no coupling);
* **critical scaling** — for fixed `ρ`, `λ₁₂ → 0` as the susceptibility product
  `χ¹·χ² → ∞` (near criticality the intrinsic susceptibilities dominate and the
  cross-coupling weakens).

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Sqrt
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Tactic.Positivity

namespace MIP

namespace CouplingFormula

open Filter Topology

/-- The explicit train–test coupling coefficient
`λ₁₂ = ρ / ((1 − ρ²) · √(χ¹·χ²))`  (R.277 (♠')). -/
noncomputable def lam12 (ρ χ₁ χ₂ : ℝ) : ℝ :=
  ρ / ((1 - ρ ^ 2) * Real.sqrt (χ₁ * χ₂))

/-- **R.277 — the denominator is positive** for `ρ ∈ (−1,1)`, `χ₁, χ₂ > 0`.

`1 − ρ² > 0` because `|ρ| < 1`; `√(χ₁·χ₂) > 0` because `χ₁·χ₂ > 0`. -/
theorem R_277_denom_pos
    (ρ χ₁ χ₂ : ℝ) (hρlo : -1 < ρ) (hρhi : ρ < 1) (hχ₁ : 0 < χ₁) (hχ₂ : 0 < χ₂) :
    0 < (1 - ρ ^ 2) * Real.sqrt (χ₁ * χ₂) := by
  have h1 : 0 < 1 - ρ ^ 2 := by nlinarith [hρlo, hρhi]
  have h2 : 0 < Real.sqrt (χ₁ * χ₂) := Real.sqrt_pos.mpr (mul_pos hχ₁ hχ₂)
  exact mul_pos h1 h2

/-- **R.277 — well-definedness:** the denominator is nonzero, so `λ₁₂` is a
genuine real number. -/
theorem R_277_well_defined
    (ρ χ₁ χ₂ : ℝ) (hρlo : -1 < ρ) (hρhi : ρ < 1) (hχ₁ : 0 < χ₁) (hχ₂ : 0 < χ₂) :
    (1 - ρ ^ 2) * Real.sqrt (χ₁ * χ₂) ≠ 0 :=
  ne_of_gt (R_277_denom_pos ρ χ₁ χ₂ hρlo hρhi hχ₁ hχ₂)

/-- **R.277 (sign) — `λ₁₂ > 0 ↔ ρ > 0`.**

The coupling carries the sign of the generalization correlation: a positive
denominator means `λ₁₂` has the same sign as `ρ`.  In particular negative
transfer (`ρ < 0`) gives anti-coupling `λ₁₂ < 0`. -/
theorem R_277_sign
    (ρ χ₁ χ₂ : ℝ) (hρlo : -1 < ρ) (hρhi : ρ < 1) (hχ₁ : 0 < χ₁) (hχ₂ : 0 < χ₂) :
    0 < lam12 ρ χ₁ χ₂ ↔ 0 < ρ := by
  unfold lam12
  exact div_pos_iff_of_pos_right (R_277_denom_pos ρ χ₁ χ₂ hρlo hρhi hχ₁ hχ₂)

/-- **R.277 (decoupling) — at `ρ = 0`, `λ₁₂ = 0`.**

No generalization (`ρ = 0`) ⇒ the double Landau decouples into two independent
Landau theories. -/
theorem R_277_decouple (χ₁ χ₂ : ℝ) : lam12 0 χ₁ χ₂ = 0 := by
  unfold lam12; simp

/-- **R.277 (critical scaling) — `λ₁₂ → 0` as `χ¹·χ² → ∞`.**

For fixed `ρ ≠ ±1`, treating the coupling as a function of the susceptibility
product `s := χ¹·χ²`, `λ₁₂(s) = ρ / ((1−ρ²)·√s) → 0` as `s → ∞`.  Near
criticality the intrinsic susceptibilities diverge and the cross-coupling
vanishes.

We package `λ₁₂` as a function of `s` directly: `g s = ρ / ((1−ρ²)·√s)`. -/
theorem R_277_critical_scaling (ρ : ℝ) (hρlo : -1 < ρ) (hρhi : ρ < 1) :
    Tendsto (fun s : ℝ => ρ / ((1 - ρ ^ 2) * Real.sqrt s)) atTop (𝓝 0) := by
  -- √s → ∞, and (1−ρ²) > 0, so the denominator (1−ρ²)·√s → ∞.
  have hpos : 0 < 1 - ρ ^ 2 := by nlinarith [hρlo, hρhi]
  have hsqrt : Tendsto (fun s : ℝ => Real.sqrt s) atTop atTop :=
    Real.tendsto_sqrt_atTop
  have hdenom : Tendsto (fun s : ℝ => (1 - ρ ^ 2) * Real.sqrt s) atTop atTop :=
    Tendsto.const_mul_atTop hpos hsqrt
  -- Constant `ρ` over a quantity tending to `+∞` tends to `0`.
  exact hdenom.const_div_atTop ρ

end CouplingFormula

end MIP
