/-
Result R.82 — Dynamical training-efficiency ratio `ρ(t) = Z(t)/Φ₀(t)`.

Reference: `workspace/new_results.md` R.82
(B 级 — 推论; the stage-switching being an empirical training criterion is
bundled here as explicit sign hypotheses on `Z'`, `Φ₀'`. We encode the
quotient-rule calculus kernel.)

**Statement.** Generalising the static efficiency ratio `ρ = Z/Φ₀`
(D.3.8) to a time-dependent quantity along the training trajectory,

    ρ(t) := Z(t) / Φ₀(t) .

Differentiating by the quotient rule,

    dρ/dt  =  (Z'(t)·Φ₀(t) − Z(t)·Φ₀'(t)) / Φ₀(t)² .

Since the denominator `Φ₀² > 0`, the **sign** of `dρ/dt` is the sign of
the numerator `Z'·Φ₀ − Z·Φ₀'`. This is the stage-switch criterion:

* `ρ` rising (`dρ/dt > 0`)  ⇔  `Z'·Φ₀ > Z·Φ₀'`,
* `ρ` falling (`dρ/dt < 0`) ⇔  `Z'·Φ₀ < Z·Φ₀'`.

The empirical claim "ρ(t) usually decreases monotonically (scaling-first
early, refinement-first late)" is recorded as the sign hypothesis
`Z'·Φ₀ < Z·Φ₀'` (refinement regime), which we prove forces `dρ/dt < 0`.

**Pure-math content.** `HasDerivAt.div` (quotient rule) plus a sign
analysis: with `Φ₀ ≠ 0` the denominator `Φ₀²` is strictly positive, so
the sign of the quotient equals the sign of the numerator. The
stage-switch criterion is exactly this sign translation.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.Calculus.Deriv.Inv
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.FieldSimp

namespace MIP

namespace RhoDynamics

/-- The dynamical efficiency ratio `ρ(t) = Z(t) / Φ₀(t)`. -/
noncomputable def rho (Z Φ₀ : ℝ → ℝ) (t : ℝ) : ℝ := Z t / Φ₀ t

/-- **R.82 — quotient-rule derivative of `ρ`.**

Given `HasDerivAt Z Z' t`, `HasDerivAt Φ₀ Φ₀' t`, and `Φ₀ t ≠ 0`,

    dρ/dt  =  (Z'·Φ₀(t) − Z(t)·Φ₀') / Φ₀(t)² . -/
theorem R_82_hasDerivAt_rho
    (Z Φ₀ : ℝ → ℝ) (Z' Φ₀' t : ℝ)
    (hZ : HasDerivAt Z Z' t) (hΦ : HasDerivAt Φ₀ Φ₀' t)
    (hΦ_ne : Φ₀ t ≠ 0) :
    HasDerivAt (rho Z Φ₀)
      ((Z' * Φ₀ t - Z t * Φ₀') / (Φ₀ t) ^ 2) t :=
  hZ.div hΦ hΦ_ne

/-- **R.82 — sign of `dρ/dt` is the sign of the numerator (rising case).**

The denominator `Φ₀(t)² > 0`, so `dρ/dt > 0` exactly when the numerator
`Z'·Φ₀ − Z·Φ₀' > 0`. This is the scaling-first stage criterion. -/
theorem R_82_drho_pos
    (Z Φ₀ : ℝ → ℝ) (Z' Φ₀' t : ℝ)
    (hZ : HasDerivAt Z Z' t) (hΦ : HasDerivAt Φ₀ Φ₀' t)
    (hΦ_ne : Φ₀ t ≠ 0)
    (h_switch : Z t * Φ₀' < Z' * Φ₀ t) :
    HasDerivAt (rho Z Φ₀) ((Z' * Φ₀ t - Z t * Φ₀') / (Φ₀ t) ^ 2) t ∧
      (Z' * Φ₀ t - Z t * Φ₀') / (Φ₀ t) ^ 2 > 0 := by
  refine ⟨hZ.div hΦ hΦ_ne, ?_⟩
  have hden : (0 : ℝ) < (Φ₀ t) ^ 2 := by positivity
  have hnum : (0 : ℝ) < Z' * Φ₀ t - Z t * Φ₀' := by linarith
  exact div_pos hnum hden

/-- **R.82 — stage-switch criterion (falling / refinement regime).**

The empirical "ρ monotonically decreasing" claim is the sign hypothesis
`Z'·Φ₀ < Z·Φ₀'`. Combined with `Φ₀(t) ≠ 0` (so `Φ₀² > 0`), the quotient
rule gives `dρ/dt` and forces

    dρ/dt  =  (Z'·Φ₀ − Z·Φ₀') / Φ₀²  <  0 ,

i.e. the efficiency ratio is strictly decreasing — the refinement-first
training stage. -/
theorem R_82_drho_neg
    (Z Φ₀ : ℝ → ℝ) (Z' Φ₀' t : ℝ)
    (hZ : HasDerivAt Z Z' t) (hΦ : HasDerivAt Φ₀ Φ₀' t)
    (hΦ_ne : Φ₀ t ≠ 0)
    (h_switch : Z' * Φ₀ t < Z t * Φ₀') :
    HasDerivAt (rho Z Φ₀) ((Z' * Φ₀ t - Z t * Φ₀') / (Φ₀ t) ^ 2) t ∧
      (Z' * Φ₀ t - Z t * Φ₀') / (Φ₀ t) ^ 2 < 0 := by
  refine ⟨hZ.div hΦ hΦ_ne, ?_⟩
  have hden : (0 : ℝ) < (Φ₀ t) ^ 2 := by positivity
  have hnum : Z' * Φ₀ t - Z t * Φ₀' < 0 := by linarith
  exact div_neg_of_neg_of_pos hnum hden

/-- **R.82 — log-derivative form of the stage criterion.**

When `Z(t), Φ₀(t) > 0`, the numerator sign translates to the ratio of
*logarithmic* rates quoted in the statement
`ρ = −(d log Φ₀/dt)/(d log Z/dt)`-style comparison: `dρ/dt` has the sign
of `Z'/Z − Φ₀'/Φ₀` (relative growth rate of `Z` minus that of `Φ₀`).
Concretely the numerator factors as

    Z'·Φ₀ − Z·Φ₀'  =  Z·Φ₀·(Z'/Z − Φ₀'/Φ₀) . -/
theorem R_82_numerator_logform
    (Z Φ₀ Z' Φ₀' : ℝ) (hZ : Z ≠ 0) (hΦ : Φ₀ ≠ 0) :
    Z' * Φ₀ - Z * Φ₀' = Z * Φ₀ * (Z' / Z - Φ₀' / Φ₀) := by
  field_simp

end RhoDynamics

end MIP
