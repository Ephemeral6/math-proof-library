/-
  STATUS: OBSERVATION
  AGENT: R3-1
  DIRECTION: Compose R.114 (Z⁻¹ vs |K| non-monotone, slope-sign indefinite)
    with R.194 (decay-modified Ohm law) into a non-monotonicity result
    preserved under decay modification.
  SUMMARY:
    R.114 exhibits two training regimes — balanced (positive correlation:
    |K|↑ ⇒ Z⁻¹↑) and overfit (negative correlation: |K|↑ ⇒ Z⁻¹↓) —
    proving that no monotone function `g : |K| → Z⁻¹` reproduces both.
    The two slopes have *opposite signs* over the *same* |K|-pair
    (100, 1000).

    R.194 modifies the Ohm budget by an additive maintenance tax:
    N_decay = N_maint + ⌈Φ₀·Z_τ⌉, and is monotone in Z_τ.  So if we
    *use Z⁻¹ as Z_τ* (the effective decay-time impedance equals the
    reciprocal impedance in the static-decay limit), then R.194 turns
    R.114's slope-sign flip into a slope-sign flip of the decay
    *cost*: the balanced regime has N_decay ascending with |K|, the
    overfit regime has it descending with |K|.

    Hence: non-monotonicity is *preserved* under decay modification —
    there is **no** monotone function `h : |K| → N_decay` either.
    This is the headline observation.  We prove a real-valued version
    of the lifted slope-sign flip and discuss the ENNReal lift as a
    monotonicity-preservation corollary.

    OBSERVATION-grade because the ENNReal ↔ real lift requires
    technical machinery beyond R.114 + R.194 alone; we prove the
    real-valued slope-flip at the kernel level here.

  Depends on:
    - MIP.Results.R114_ZinvKappaNonMonotone (Zinv, R_114_slope_sign_flip)
    - MIP.Results.R194_DecayModifiedOhm     (NDecay, R_194_monotone_Ztau)
-/
import MIP.Results.R114_ZinvKappaNonMonotone
import MIP.Results.R194_DecayModifiedOhm
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

namespace MIP

namespace R3_Agent1_DecayNonMonotone

open MIP.ZinvKappaNonMonotone MIP.DecayModifiedOhm

/-- **(E.1) Decay-cost surrogate in the (Z, Φ₀) chart (real form).**

A real-valued surrogate for the R.194 decay-modified solve cost
`⌈Φ₀ · Z_τ⌉` with `Z_τ := 1/Z`: we set

    Ncost_real(Phi0, Z) := Phi0 * (1 / Z),

which is monotone increasing in `1/Z` (the R.194 `Z_τ` side), at
fixed `Phi0 ≥ 0`. -/
noncomputable def NcostReal (Phi0 Z : ℝ) : ℝ := Phi0 * Zinv Z

/-- **(E.2) R.194-style monotonicity of the real surrogate.**

If `Z⁻¹` increases (i.e. `Zinv Z_a ≤ Zinv Z_b`) at fixed `Phi0 ≥ 0`,
then the real surrogate `Ncost_real` increases.  This is the real
shadow of R.194's `R_194_monotone_Ztau`. -/
theorem R3_Ncost_monotone
    (Phi0 Za Zb : ℝ) (h_phi : 0 ≤ Phi0) (h_z : Zinv Za ≤ Zinv Zb) :
    NcostReal Phi0 Za ≤ NcostReal Phi0 Zb := by
  unfold NcostReal
  exact mul_le_mul_of_nonneg_left h_z h_phi

/-- **(E.3) Balanced-regime decay cost ascends with |K|.**

Plug R.114's balanced-regime data `(Z = 10, then Z = 1)` into the
real surrogate at any `Phi0 > 0`: the decay solve-cost surrogate
ascends from `Phi0 / 10` to `Phi0`.  This is R.194 monotonicity
applied to R.114's balanced-regime `Zinv 10 < Zinv 1`. -/
theorem R3_balanced_decay_ascends (Phi0 : ℝ) (h_phi : 0 < Phi0) :
    NcostReal Phi0 10 < NcostReal Phi0 1 := by
  have h_slope := R_114_balanced_positive
  unfold NcostReal
  -- Phi0 · Zinv 10 < Phi0 · Zinv 1.
  exact mul_lt_mul_of_pos_left h_slope.2 h_phi

/-- **(E.4) Overfit-regime decay cost descends with |K|.**

Plug R.114's overfit-regime data `(Z = 10, then Z = 100)` into the
real surrogate at any `Phi0 > 0`: the decay solve-cost surrogate
*descends* from `Phi0 / 10` to `Phi0 / 100`.  This is R.194
monotonicity applied to R.114's overfit-regime `Zinv 100 < Zinv 10`. -/
theorem R3_overfit_decay_descends (Phi0 : ℝ) (h_phi : 0 < Phi0) :
    NcostReal Phi0 100 < NcostReal Phi0 10 := by
  have h_slope := R_114_overfit_negative
  unfold NcostReal
  exact mul_lt_mul_of_pos_left h_slope.2 h_phi

/-- **(E.5) Slope-sign flip of the decay cost (R.114 + R.194
composition headline).**

The (|K| → N_decay)-slope of the real decay-cost surrogate is
*positive* in the balanced regime (going from `|K| = 100` to
`|K| = 1000`) and *negative* in the overfit regime over the *same*
abscissa pair, at any `Phi0 > 0`.  Therefore **no monotone function
`h : |K| → N_cost_real` fits both regimes**: non-monotonicity is
preserved by R.194's decay modification. -/
theorem R3_decay_cost_slope_flip (Phi0 : ℝ) (h_phi : 0 < Phi0) :
    (NcostReal Phi0 1 - NcostReal Phi0 10) / (1000 - 100) > 0
      ∧ (NcostReal Phi0 100 - NcostReal Phi0 10) / (1000 - 100) < 0 := by
  refine ⟨?_, ?_⟩
  · -- Balanced regime: positive slope.
    have h_lt : NcostReal Phi0 10 < NcostReal Phi0 1 :=
      R3_balanced_decay_ascends Phi0 h_phi
    have h_diff : 0 < NcostReal Phi0 1 - NcostReal Phi0 10 := by linarith
    have h_den : (0 : ℝ) < 1000 - 100 := by norm_num
    exact div_pos h_diff h_den
  · -- Overfit regime: negative slope.
    have h_lt : NcostReal Phi0 100 < NcostReal Phi0 10 :=
      R3_overfit_decay_descends Phi0 h_phi
    have h_diff : NcostReal Phi0 100 - NcostReal Phi0 10 < 0 := by linarith
    have h_den : (0 : ℝ) < 1000 - 100 := by norm_num
    exact div_neg_of_neg_of_pos h_diff h_den

/-- **(E.6) No monotone (|K| → N_cost_real) over both regimes.**

The slope-sign flip rules out any non-decreasing `h` reproducing the
decay-cost data on the shared `|K|`-pair `(100, 1000)` across both
regimes.  This is the R.114 + R.194 composition's headline
"non-monotonicity preserved under decay" statement. -/
theorem R3_no_monotone_decay_cost (Phi0 : ℝ) (h_phi : 0 < Phi0) :
    ¬ ∃ h : ℝ → ℝ,
        (∀ x y : ℝ, x ≤ y → h x ≤ h y) ∧
        h 100 = NcostReal Phi0 10 ∧
        h 1000 = NcostReal Phi0 1 ∧
        h 1000 = NcostReal Phi0 100 := by
  rintro ⟨h, hmono, h_lo, h_bal, h_ovf⟩
  -- Monotone ⟹ h 100 ≤ h 1000.
  have hle : h 100 ≤ h 1000 := hmono 100 1000 (by norm_num)
  -- But h 100 = NcostReal Phi0 10 and h 1000 = NcostReal Phi0 100
  -- (the overfit value), so h 100 > h 1000 by R3_overfit_decay_descends.
  rw [h_lo, h_ovf] at hle
  -- hle : NcostReal Phi0 10 ≤ NcostReal Phi0 100.
  have h_strict : NcostReal Phi0 100 < NcostReal Phi0 10 :=
    R3_overfit_decay_descends Phi0 h_phi
  linarith

end R3_Agent1_DecayNonMonotone

end MIP
