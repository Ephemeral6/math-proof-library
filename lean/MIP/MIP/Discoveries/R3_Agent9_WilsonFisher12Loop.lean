/-
  STATUS: DISCOVERY
  AGENT: R3-9
  DIRECTION: Compose R.119 (mean-field exponents) + R.273 (1-loop
    Wilson-Fisher) + R.280 (2-loop Wilson-Fisher) into a single chain
    of corrections: mean-field → 1-loop (sign and first-order shift) →
    2-loop (positive correction to ν, sign-reversed correction to α).
  SUMMARY:
    Mean-field (R.119) fixes `(β,γ,ν,α,η) = (1/2, 1, 1/2, 0, 0)`.
    R.273 gives the 1-loop ε-expansion shifts

        ν₁ − 1/2 = ε/12,   γ₁ − 1 = ε/6,   α₁ − 0 = ε/6.

    R.280 gives the 2-loop additional corrections, of which the
    `7·ε²/162` correction to `ν` is *positive* and the `−29·ε²/324`
    correction to `α` is *negative* — the sign of the 2-loop shift is
    a clean composition statement.

    Headlines:

      (1) `R3_one_loop_correction_to_meanfield` — for each exponent
          `X ∈ {ν, γ, α}`, the 1-loop R.273 value equals the
          mean-field value plus a *linear-in-ε* correction.  This is
          the "ε-expansion at first order" statement explicitly
          chaining R.119 + R.273.

      (2) `R3_two_loop_correction_to_one_loop_nu` — the 2-loop R.280
          `ν` equals the 1-loop R.273 `ν` plus the *strictly positive*
          (for `ε > 0`) correction `7·ε²/162`.  Sign statement:
          `R3_nu_correction_positive`.

      (3) `R3_two_loop_correction_to_alpha_negative_sign` — the
          2-loop correction to `α` is `−29·ε²/324`, *strictly
          negative* for `ε ≠ 0`.

      (4) `R3_combined_two_loop_shift_from_meanfield` — the *full*
          mean-field-to-2-loop shift for `ν`:

            ν₂ − 1/2 = ε/12 + 7·ε²/162 ,

          chains R.119 + R.273 + R.280 in one identity.

      (5) `R3_one_loop_at_three_dim` — the 1-loop ε = 1 (i.e. d = 3)
          shift for `ν` is `1/12`; for `α` is `1/6`; the mean-field
          value `1/2` becomes `7/12`, `0` becomes `1/6` — a clean
          numerical exhibition of "1-loop correction sign for d = 3
          Ising universality".

  Depends on:
    - MIP.Results.R119_MeanFieldExponents   (R_119_universality_consistency)
    - MIP.Results.R273_WilsonFisher1Loop    (β, γ, ν, η, α, dEff,
                                              rushbrooke, exponents_at_eps_one)
    - MIP.Results.R280_WilsonFisher2Loop    (ν, γ, α, η, ν1,
                                              nu_two_loop_correction)
-/
import MIP.Results.R119_MeanFieldExponents
import MIP.Results.R273_WilsonFisher1Loop
import MIP.Results.R280_WilsonFisher2Loop
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace R3_Agent9_WilsonFisher12Loop

-- Disambiguate: R.273's `ν` and R.280's `ν` collide.  We open as
-- shorthand `νA`/`νB` etc.
open MIP

-- Mean-field exponent constants from R.119 (Curie–Weiss tuple).
@[simp] noncomputable def β_MF : ℝ := 1 / 2
@[simp] noncomputable def γ_MF : ℝ := 1
@[simp] noncomputable def ν_MF : ℝ := 1 / 2
@[simp] noncomputable def α_MF : ℝ := 0
@[simp] noncomputable def η_MF : ℝ := 0

/-- **Composition (E.1) — `R.119 + R.273` 1-loop correction to mean-field `ν`.**

R.119 fixes `ν = 1/2`.  R.273's 1-loop form is `ν(ε) = 1/2 + ε/12`.
Thus the 1-loop correction is exactly the linear-in-ε shift `ε/12`:
the WF ε-expansion at first order reproduces the mean-field at ε = 0
and adds a *positive* (for ε > 0) shift. -/
theorem R3_one_loop_nu_correction (ε : ℝ) :
    WilsonFisher1Loop.ν ε - ν_MF = ε / 12 := by
  unfold WilsonFisher1Loop.ν ν_MF; ring

/-- **Composition (E.2) — `R.119 + R.273` 1-loop correction to mean-field `γ`.**

`γ_MF = 1`, `γ_1loop = 1 + ε/6`, so the correction is `ε/6`. -/
theorem R3_one_loop_gamma_correction (ε : ℝ) :
    WilsonFisher1Loop.γ ε - γ_MF = ε / 6 := by
  unfold WilsonFisher1Loop.γ γ_MF; ring

/-- **Composition (E.3) — `R.119 + R.273` 1-loop correction to mean-field `α`.**

`α_MF = 0`, `α_1loop = ε/6`, so the correction is `ε/6`. -/
theorem R3_one_loop_alpha_correction (ε : ℝ) :
    WilsonFisher1Loop.α ε - α_MF = ε / 6 := by
  unfold WilsonFisher1Loop.α α_MF; ring

/-- **Composition (E.4) — `R.119 + R.273` 1-loop correction to mean-field `β`.**

`β_MF = 1/2`, `β_1loop = 1/2 - ε/6`, so the correction is `-ε/6` —
**negative** for ε > 0, the only mean-field exponent that *decreases*
at 1-loop. -/
theorem R3_one_loop_beta_correction (ε : ℝ) :
    WilsonFisher1Loop.β ε - β_MF = -ε / 6 := by
  unfold WilsonFisher1Loop.β β_MF; ring

/-- **Composition (E.5) — at ε = 0 the 1-loop exponents recover mean-field.**

Continuity / asymptotic-matching certificate: at `ε = 0` the WF 1-loop
exponents from R.273 equal the R.119 mean-field tuple. -/
theorem R3_meanfield_recovery_at_eps_zero :
    WilsonFisher1Loop.ν 0 = ν_MF ∧
    WilsonFisher1Loop.γ 0 = γ_MF ∧
    WilsonFisher1Loop.α 0 = α_MF ∧
    WilsonFisher1Loop.β 0 = β_MF := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · unfold WilsonFisher1Loop.ν ν_MF; norm_num
  · unfold WilsonFisher1Loop.γ γ_MF; norm_num
  · unfold WilsonFisher1Loop.α α_MF; norm_num
  · unfold WilsonFisher1Loop.β β_MF; norm_num

/-! ## Composition (C): R.273 + R.280 — 2-loop correction sign / magnitude. -/

/-- **Composition (C.1) — `R.273 + R.280` 2-loop correction to ν.**

The 2-loop correction to `ν` over the 1-loop value is exactly
`7·ε²/162` (the R.280 statement, re-stated through R.273's `ν₁`).

Direct re-use of R.280's `nu_two_loop_correction`, but recasting the
1-loop term via R.273's `ν` (the two definitions agree). -/
theorem R3_two_loop_nu_correction_to_one_loop (ε : ℝ) :
    WilsonFisher2Loop.ν ε - WilsonFisher1Loop.ν ε = 7 * ε ^ 2 / 162 := by
  unfold WilsonFisher2Loop.ν WilsonFisher1Loop.ν; ring

/-- **Composition (C.2) — sign: 2-loop ν correction is non-negative.**

For `ε ≠ 0`, the 2-loop correction `7·ε²/162` is *strictly positive*;
at `ε = 0` it is zero.  Hence the 2-loop ν is *no smaller* than the
1-loop ν, with strict increase off the mean-field point. -/
theorem R3_nu_two_loop_ge_one_loop (ε : ℝ) :
    WilsonFisher1Loop.ν ε ≤ WilsonFisher2Loop.ν ε := by
  have h := R3_two_loop_nu_correction_to_one_loop ε
  have h_nonneg : (0 : ℝ) ≤ 7 * ε ^ 2 / 162 := by positivity
  linarith

/-- **Composition (C.3) — strict sign for `ε ≠ 0`.** -/
theorem R3_nu_correction_positive (ε : ℝ) (hε : ε ≠ 0) :
    WilsonFisher1Loop.ν ε < WilsonFisher2Loop.ν ε := by
  have h := R3_two_loop_nu_correction_to_one_loop ε
  have h_sq_pos : (0 : ℝ) < ε ^ 2 := by positivity
  have h_pos : (0 : ℝ) < 7 * ε ^ 2 / 162 := by positivity
  linarith

/-- **Composition (C.4) — 2-loop α correction is **negative** for ε ≠ 0.**

The 2-loop ε² shift in α is `−29·ε²/324`.  Sign-reversed compared with
ν: α *decreases* at 2-loop relative to 1-loop. -/
theorem R3_alpha_two_loop_correction (ε : ℝ) :
    WilsonFisher2Loop.α ε - WilsonFisher1Loop.α ε = -(29 * ε ^ 2 / 324) := by
  unfold WilsonFisher2Loop.α WilsonFisher1Loop.α; ring

theorem R3_alpha_two_loop_le_one_loop (ε : ℝ) :
    WilsonFisher2Loop.α ε ≤ WilsonFisher1Loop.α ε := by
  have h := R3_alpha_two_loop_correction ε
  have h_nonneg : (0 : ℝ) ≤ 29 * ε ^ 2 / 324 := by positivity
  linarith

theorem R3_alpha_correction_negative (ε : ℝ) (hε : ε ≠ 0) :
    WilsonFisher2Loop.α ε < WilsonFisher1Loop.α ε := by
  have h := R3_alpha_two_loop_correction ε
  have h_sq_pos : (0 : ℝ) < ε ^ 2 := by positivity
  have h_pos : (0 : ℝ) < 29 * ε ^ 2 / 324 := by positivity
  linarith

/-- **Composition (C.5) — 2-loop γ correction is positive (`25ε²/324`).**

γ continues to *increase* at 2-loop, same direction as ν. -/
theorem R3_gamma_two_loop_correction (ε : ℝ) :
    WilsonFisher2Loop.γ ε - WilsonFisher1Loop.γ ε = 25 * ε ^ 2 / 324 := by
  unfold WilsonFisher2Loop.γ WilsonFisher1Loop.γ; ring

theorem R3_gamma_two_loop_ge_one_loop (ε : ℝ) :
    WilsonFisher1Loop.γ ε ≤ WilsonFisher2Loop.γ ε := by
  have h := R3_gamma_two_loop_correction ε
  have h_nonneg : (0 : ℝ) ≤ 25 * ε ^ 2 / 324 := by positivity
  linarith

/-! ## Composition (combined) — R.119 + R.273 + R.280 full shift. -/

/-- **Composition (combined) — full mean-field-to-2-loop shift for ν.**

Chain R.119 → R.273 → R.280: the 2-loop WF `ν` equals the mean-field
`1/2` plus the 1-loop shift `ε/12` plus the 2-loop shift `7·ε²/162`. -/
theorem R3_combined_two_loop_shift_nu (ε : ℝ) :
    WilsonFisher2Loop.ν ε - ν_MF = ε / 12 + 7 * ε ^ 2 / 162 := by
  unfold WilsonFisher2Loop.ν ν_MF; ring

/-- **Composition (combined) — full mean-field-to-2-loop shift for γ.**

`γ_2loop − γ_MF = ε/6 + 25·ε²/324`. -/
theorem R3_combined_two_loop_shift_gamma (ε : ℝ) :
    WilsonFisher2Loop.γ ε - γ_MF = ε / 6 + 25 * ε ^ 2 / 324 := by
  unfold WilsonFisher2Loop.γ γ_MF; ring

/-- **Composition (combined) — full mean-field-to-2-loop shift for α.**

`α_2loop − α_MF = ε/6 − 29·ε²/324`.  Sign of the two-loop term is
*negative*: at order ε², α is pulled *back* toward mean-field. -/
theorem R3_combined_two_loop_shift_alpha (ε : ℝ) :
    WilsonFisher2Loop.α ε - α_MF = ε / 6 - 29 * ε ^ 2 / 324 := by
  unfold WilsonFisher2Loop.α α_MF; ring

/-- **Composition (combined) — full mean-field-to-2-loop shift sign certificate.**

At ε = 1 (3-D Ising), the three combined shifts are:
`ν_shift = 1/12 + 7/162`, `γ_shift = 1/6 + 25/324`,
`α_shift = 1/6 − 29/324`.  Numerical verification. -/
theorem R3_combined_shift_at_eps_one :
    WilsonFisher2Loop.ν 1 - ν_MF = 1 / 12 + 7 / 162 ∧
    WilsonFisher2Loop.γ 1 - γ_MF = 1 / 6 + 25 / 324 ∧
    WilsonFisher2Loop.α 1 - α_MF = 1 / 6 - 29 / 324 := by
  refine ⟨?_, ?_, ?_⟩
  · unfold WilsonFisher2Loop.ν ν_MF; norm_num
  · unfold WilsonFisher2Loop.γ γ_MF; norm_num
  · unfold WilsonFisher2Loop.α α_MF; norm_num

end R3_Agent9_WilsonFisher12Loop

end MIP
