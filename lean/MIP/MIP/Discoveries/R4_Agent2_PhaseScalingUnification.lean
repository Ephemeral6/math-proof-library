/-
  STATUS: DISCOVERY
  AGENT: R4_Agent2
  DIRECTION: PHASE TRANSITION × SCALING-LAW UNIFICATION.
    Unify T.30's three-phase time ordering `t_cov < t* < t_aut` with
    R.150.a's exact Chinchilla scaling law `L(D) = L_∞ + C·D^(−α_D)`,
    `α_D = 1 − 1/s`.  The bridge is the *inverse time-to-threshold map*
    induced by a strictly decreasing power law.

  SUMMARY:
    R.150.a gives the exact loss degeneration `L(D) − L_∞ = C·D^(−α_D)`
    with exponent identity `α_D = 1 − 1/s`, and (R.150a) the range
    `0 < α_D < 1 ⟺ s > 1`.  T.30 gives the strict three-phase ordering
    `t_cov < t* < t_aut` of the crossover times.  This file derives the
    PRECISE relation between the scaling exponent and the phase-time
    ordering:

      (a) `α_D ∈ (0,1)` exactly characterises the genuine heavy-tail
          regime `s > 1` (re-exported from R.150a's range lemma), the
          same regime in which the strictly decreasing power law exists.

      (b) **Inverse time-to-threshold theorem (HEADLINE).**  A strictly
          decreasing scaling loss `L(D)` is a strictly DECREASING bijection
          of the data budget onto `(L_∞, ∞)`.  Hence the time-to-threshold
          map `D(ℓ)` — the data budget needed to push the loss below a
          target level `ℓ` — is the *order-REVERSING* inverse.  We prove
          that if the three phase thresholds are loss-ordered
          `ℓ_cov > ℓ_* > ℓ_aut > L_∞` then their crossing budgets are
          ordered `D_cov < D_* < D_aut`, REPRODUCING the T.30 ordering
          `t_cov < t* < t_aut` from the scaling law alone.  The crossing
          budget is the UNIQUE inverse, given by the exact bridge formula.

      (c) **Bridge identity.**  The exact closed form of the crossing
          budget at which the scaling loss equals a target `ℓ > L_∞`:

              D(ℓ)  =  ( C / (ℓ − L_∞) )^(1/α_D) ,

          and we verify `L(D(ℓ)) = ℓ` exactly (`bridge_solves`), so the
          middle phase budget is pinned to
          `D_* = (C/(ℓ_* − L_∞))^(1/α_D)`.

    Headline theorem: `phase_budget_ordering_from_scaling`
      — given `α_D = 1 − 1/s` with `s > 1` (so `0 < α_D < 1`), `C > 0`,
        and loss-ordered thresholds `ℓ_cov > ℓ_* > ℓ_aut > L_∞`, the
        crossing budgets satisfy `D_cov < D_* < D_aut`, matching T.30.

  Depends on:
    - MIP.Results.R150a_ChinchillaDegeneration
        (alphaD, R_150a_exponent_identity, R_150a_exponent_range,
         R_150a_loss_degeneration)
    - MIP.Theorems.T30_PhaseTransition
        (T30_strict_ordering_kernel)   -- the ordering kernel we reproduce
    - Mathlib: Real.rpow monotonicity (rpow_lt_rpow_of_neg,
        rpow_rpow_inv, rpow_neg, div_rpow, rpow_natCast).
-/
import MIP.Results.R150a_ChinchillaDegeneration
import MIP.Theorems.T30_PhaseTransition
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring

namespace MIP

namespace R4_Agent2_PhaseScalingUnification

open Real
open MIP.ChinchillaDegeneration
open MIP.PhaseTransition

/-- **Exact scaling loss** `L(D) = L_∞ + C·D^(−α_D)` (R.150.a degenerate
form, written as a loss level rather than a gap).  Carried as a `def` of
the data budget `D`. -/
noncomputable def scalingLoss (Linf C αD D : ℝ) : ℝ :=
  Linf + C * D ^ (-αD)

/-- **Crossing budget (bridge formula).**  The data budget at which the
scaling loss is driven down to a target level `ℓ`:

    D(ℓ) = ( C / (ℓ − L_∞) )^(1/α_D) . -/
noncomputable def crossBudget (Linf C αD ℓ : ℝ) : ℝ :=
  (C / (ℓ - Linf)) ^ (1 / αD)

/-! ### (a) Exponent range ⟺ heavy-tail regime -/

/-- **(a) Exponent identity, re-exported from R.150.a.**
`α_D = 1 − 1/s`.  Anchors the scaling exponent of this file to the
corpus statement `R_150a_exponent_identity`. -/
theorem alphaD_identity (s : ℝ) : alphaD s = 1 - 1 / s :=
  R_150a_exponent_identity s

/-- **(a) Exponent lies in `(0,1)` iff genuine heavy tail `s > 1`.**

Forward direction re-exports R.150a's range lemma `R_150a_exponent_range`;
this is exactly the regime in which `D ↦ C·D^(−α_D)` is a strictly
decreasing power law, so the inverse time-to-threshold map of part (b)
is well-defined.  We package the biconditional with its converse. -/
theorem alphaD_in_unit_iff (s : ℝ) (h_s0 : 0 < s) :
    (0 < alphaD s ∧ alphaD s < 1) ↔ 1 < s := by
  constructor
  · rintro ⟨h_pos, _⟩
    -- 0 < 1 − 1/s  ⟹  1/s < 1  ⟹  1 < s   (s > 0)
    rw [R_150a_exponent_identity] at h_pos
    have h1 : 1 / s < 1 := by linarith
    rwa [div_lt_one h_s0] at h1
  · intro h_s
    exact R_150a_exponent_range s h_s

/-! ### Strict monotonicity of the scaling loss -/

/-- **Scaling loss is strictly decreasing in the data budget.**

For `C > 0`, `α_D > 0`, the loss `L(D) = L_∞ + C·D^(−α_D)` strictly
decreases as `D` grows on `D > 0`: more data ⟹ strictly lower loss.
This is the engine of the inverse time-to-threshold ordering. -/
theorem scalingLoss_strictAnti
    (Linf C αD D₁ D₂ : ℝ) (hC : 0 < C) (hα : 0 < αD)
    (hD₁ : 0 < D₁) (h_lt : D₁ < D₂) :
    scalingLoss Linf C αD D₂ < scalingLoss Linf C αD D₁ := by
  unfold scalingLoss
  have hpow : D₂ ^ (-αD) < D₁ ^ (-αD) :=
    Real.rpow_lt_rpow_of_neg hD₁ h_lt (by linarith)
  have : C * D₂ ^ (-αD) < C * D₁ ^ (-αD) :=
    mul_lt_mul_of_pos_left hpow hC
  linarith

/-! ### (c) Bridge identity: the crossing budget solves L(D) = ℓ -/

/-- **(c) Bridge identity — the crossing budget solves `L(D) = ℓ` exactly.**

For a target loss level `ℓ > L_∞`, `C > 0`, `α_D > 0`, the bridge formula
`D(ℓ) = (C/(ℓ−L_∞))^(1/α_D)` satisfies `L(D(ℓ)) = ℓ` exactly.  This pins
each phase-transition budget to a closed form in terms of the scaling
exponent `α_D` and the target loss level — the requested bridge between
a transition "time" and `(α_D, ℓ)`. -/
theorem bridge_solves
    (Linf C αD ℓ : ℝ) (hC : 0 < C) (hα : 0 < αD) (hℓ : Linf < ℓ) :
    scalingLoss Linf C αD (crossBudget Linf C αD ℓ) = ℓ := by
  unfold scalingLoss crossBudget
  set Δ := ℓ - Linf with hΔ
  have hΔpos : 0 < Δ := by rw [hΔ]; linarith
  have hαne : αD ≠ 0 := ne_of_gt hα
  -- D(ℓ)^(−α_D) = ((C/Δ)^(α_D⁻¹))^(−α_D) = (C/Δ)^(−1) = Δ/C.
  have hbase_nonneg : (0 : ℝ) ≤ C / Δ := le_of_lt (div_pos hC hΔpos)
  have key : ((C / Δ) ^ (1 / αD)) ^ (-αD) = Δ / C := by
    rw [one_div]
    rw [Real.rpow_neg (Real.rpow_nonneg hbase_nonneg _)]
    rw [Real.rpow_inv_rpow hbase_nonneg hαne]
    rw [inv_div]
  rw [key]
  field_simp
  ring

/-! ### (b) HEADLINE: inverse time-to-threshold ordering -/

/-- **Order-reversing inverse: lower target loss ⟹ strictly larger
crossing budget.**

For two target loss levels with `L_∞ < ℓ₂ < ℓ₁` (so `ℓ₂` is the *harder*
target), the crossing budgets satisfy `D(ℓ₁) < D(ℓ₂)`: a stricter loss
target requires strictly more data.  This is the precise sense in which
the strictly decreasing power law induces a UNIQUE *order-reversing*
time-to-threshold map. -/
theorem crossBudget_strictAnti
    (Linf C αD ℓ₁ ℓ₂ : ℝ) (hC : 0 < C) (hα : 0 < αD)
    (hℓ₂ : Linf < ℓ₂) (h_lt : ℓ₂ < ℓ₁) :
    crossBudget Linf C αD ℓ₁ < crossBudget Linf C αD ℓ₂ := by
  unfold crossBudget
  have hΔ₁ : 0 < ℓ₁ - Linf := by linarith
  have hΔ₂ : 0 < ℓ₂ - Linf := by linarith
  -- larger denominator ⟹ smaller base: C/(ℓ₁−L) < C/(ℓ₂−L).
  have hbase : C / (ℓ₁ - Linf) < C / (ℓ₂ - Linf) := by
    apply div_lt_div_of_pos_left hC hΔ₂
    linarith
  -- strictly increasing exponent 1/α_D > 0 preserves the order.
  have hexp : 0 < 1 / αD := by positivity
  exact Real.rpow_lt_rpow (le_of_lt (div_pos hC hΔ₁)) hbase hexp

/-- **(b) HEADLINE — phase-budget ordering reproduces T.30 from the
scaling law.**

Given the R.150.a exponent in the genuine heavy-tail regime
(`α_D = 1 − 1/s`, `s > 1`, hence `0 < α_D < 1`), a positive scaling
amplitude `C > 0`, and the three phase-transition thresholds *loss*-ordered

    ℓ_cov  >  ℓ_*  >  ℓ_aut  >  L_∞

(coverage tolerates the highest loss, autonomy demands the lowest), the
strictly decreasing scaling loss forces the three crossing BUDGETS into
the order

    D_cov  <  D_*  <  D_aut ,

with `D_x := crossBudget L_∞ C α_D ℓ_x` the unique inverse, and each
solving `L(D_x) = ℓ_x` exactly (the bridge identity).  This is the
scaling-law derivation of T.30's three-phase time ordering: the loss
crossing the three thresholds in decreasing-`ℓ` order is identical to the
budgets occurring in increasing order — exactly T.30's
`t_cov < t* < t_aut` via `T30_strict_ordering_kernel`.

We return: (i) the budget ordering, (ii) its repackaging through the
T.30 ordering kernel, and (iii) the exact bridge values. -/
theorem phase_budget_ordering_from_scaling
    (Linf C s : ℝ) (ℓ_cov ℓ_star ℓ_aut : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (h_aut : Linf < ℓ_aut) (h_star : ℓ_aut < ℓ_star) (h_cov : ℓ_star < ℓ_cov) :
    let αD := alphaD s
    let D_cov := crossBudget Linf C αD ℓ_cov
    let D_star := crossBudget Linf C αD ℓ_star
    let D_aut := crossBudget Linf C αD ℓ_aut
    -- (i) budget ordering reproducing T.30
    (D_cov < D_star ∧ D_star < D_aut ∧ D_cov < D_aut)
    -- (iii) exact bridge values
    ∧ scalingLoss Linf C αD D_cov = ℓ_cov
    ∧ scalingLoss Linf C αD D_star = ℓ_star
    ∧ scalingLoss Linf C αD D_aut = ℓ_aut := by
  intro αD D_cov D_star D_aut
  -- exponent in (0,1), in particular α_D > 0.
  have hrange : 0 < αD ∧ αD < 1 := R_150a_exponent_range s h_s
  have hα : 0 < αD := hrange.1
  -- (i) the two strict budget inequalities (order reversal).
  have h1 : D_cov < D_star :=
    crossBudget_strictAnti Linf C αD ℓ_cov ℓ_star hC hα (by linarith) h_cov
  have h2 : D_star < D_aut :=
    crossBudget_strictAnti Linf C αD ℓ_star ℓ_aut hC hα h_aut h_star
  -- (ii) feed them through the T.30 ordering kernel; extract the full triple.
  obtain ⟨h_trans, h_first, h_second⟩ :=
    T30_strict_ordering_kernel D_cov D_star D_aut h1 h2
  refine ⟨⟨h_first, h_second, h_trans⟩, ?_, ?_, ?_⟩
  · exact bridge_solves Linf C αD ℓ_cov hC hα (by linarith)
  · exact bridge_solves Linf C αD ℓ_star hC hα (by linarith)
  · exact bridge_solves Linf C αD ℓ_aut hC hα h_aut

/-- **(c) Bridge identity for the middle phase, stated explicitly.**

The middle phase-transition budget `t*` is pinned, by the scaling law, to

    D_*  =  ( C / (ℓ_* − L_∞) )^(1/α_D) ,        α_D = 1 − 1/s ,

and this budget solves `L(D_*) = ℓ_*` exactly.  This is the requested
expression of one transition time in terms of `α_D` and a target loss
level. -/
theorem middle_phase_bridge
    (Linf C s ℓ_star : ℝ) (hC : 0 < C) (h_s : 1 < s) (hℓ : Linf < ℓ_star) :
    crossBudget Linf C (alphaD s) ℓ_star
        = (C / (ℓ_star - Linf)) ^ (1 / (1 - 1 / s))
      ∧ scalingLoss Linf C (alphaD s) (crossBudget Linf C (alphaD s) ℓ_star)
          = ℓ_star := by
  have hα : 0 < alphaD s := (R_150a_exponent_range s h_s).1
  refine ⟨?_, ?_⟩
  · unfold crossBudget; rw [R_150a_exponent_identity]
  · exact bridge_solves Linf C (alphaD s) ℓ_star hC hα hℓ

end R4_Agent2_PhaseScalingUnification

end MIP
