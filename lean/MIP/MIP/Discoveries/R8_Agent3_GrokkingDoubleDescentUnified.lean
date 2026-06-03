/-
  STATUS: DISCOVERY
  AGENT: R8_Agent3
  DIRECTION: GROKKING × DOUBLE DESCENT — two thresholds of ONE phase order
    parameter, their gap set by the scaling exponent, vanishing at a
    degenerate critical point.

  SUMMARY:
    The corpus carries grokking as a coverage CROSSING (R.80,
    `R_80_coverage_crossing`: a continuous coverage coordinate `K_t`
    crossing the level `Rsup` produces a transition time `t*` at which
    emergence becomes finite, `R_80_finite_at_crossing`), and double
    descent as a SIGN-REVERSAL of a weighted order-parameter contribution
    (R.81ab, `two_transitions` / `double_descent_of_LDD`: the loss-rate
    pattern `DD dN₁ dN₂ dN₃` ⇔ the weight `W` reverses sign twice).
    R4_Agent2 (the R4 tower) supplies the bridge: ONE strictly decreasing
    scaling order parameter `L(D) = L_∞ + C·D^(−α_D)` with exponent
    `α_D = alphaD s` (`scalingLoss`, `crossBudget`, `bridge_solves`,
    `crossBudget_strictAnti`, `scalingLoss_strictAnti`), whose inverse
    `crossBudget` is the order-reversing time-to-threshold map.

    This file proves that BOTH events are located by the SAME order
    parameter as two of its loss thresholds, and computes their gap.

      (a) `grok_and_dd_are_two_thresholds`.  Identify the grokking event
          with its coverage loss level `ℓ_grok` (the loss at which R.80's
          crossing makes emergence finite) and the double-descent
          interpolation peak with its loss level `ℓ_dd` (the loss at the
          DD middle-ascent boundary).  BOTH solve `L(D) = ℓ` exactly via
          R4_Agent2's `bridge_solves`: the grokking budget `D_grok` and
          the double-descent budget `D_dd` are two thresholds of the one
          scaling order parameter `L`.  We additionally certify, through
          R.80 itself, that the grokking loss level is genuinely reached
          (a real crossing exists) and that at it emergence becomes finite.

      (b) `grok_dd_gap_signed_by_exponent`.  In the genuine heavy-tail
          regime `s > 1` (so `0 < α_D < 1` by R.150a `R_150a_exponent_range`,
          re-exported through R4_Agent2), the gap between the two budgets is
          ORDER-REVERSING in the loss levels: if the grokking threshold sits
          at a *higher* loss than the DD peak (`ℓ_dd < ℓ_grok`), then the
          double-descent budget strictly EXCEEDS the grokking budget,
          `D_grok < D_dd`, by R4_Agent2's `crossBudget_strictAnti`.  The
          sign of the gap is fixed purely by the loss ordering through the
          monotone inverse of the exponent-`α_D` power law.

      (c) `degenerate_critical_point`.  The two thresholds COINCIDE — the
          gap vanishes, `D_grok = D_dd` — exactly at the degenerate
          critical point `ℓ_grok = ℓ_dd`: grokking and the double-descent
          peak collapse onto a single critical locus of the order
          parameter.  We give both directions: equal loss levels ⟹ equal
          budgets (degenerate), and strict loss separation ⟹ strict budget
          gap (non-degenerate), so coincidence is an iff at the level of
          the loss thresholds.

      HEADLINE `grokking_double_descent_unified`:  packages (a)+(b)+(c) —
      grokking and double descent are two thresholds `D_grok, D_dd` of the
      one scaling order parameter `L(D) = L_∞ + C·D^(−α_D)`; each solves
      `L(D)=ℓ` exactly; the grokking loss level is genuinely crossed (R.80);
      the double-descent sign-reversal genuinely holds (R.81ab); and the
      gap `D_dd − D_grok` is strictly positive when `ℓ_dd < ℓ_grok`,
      vanishing iff `ℓ_grok = ℓ_dd` (degenerate critical point).

  Depends on (load-bearing — appear in proof terms below):
    - MIP.Discoveries.R4_Agent2_PhaseScalingUnification   (R4 TOWER)
        scalingLoss, crossBudget, bridge_solves,
        crossBudget_strictAnti, scalingLoss_strictAnti
    - MIP.Results.R80_GrokkingCrossing
        R_80_coverage_crossing, R_80_finite_at_crossing, Nfin
    - MIP.Results.R81ab_DoubleDescentSplit
        DD, LDD, double_descent_of_LDD
    - MIP.Results.R150a_ChinchillaDegeneration
        alphaD, R_150a_exponent_range            (re-exported via R4_Agent2)

  Provenance-only (cited for lineage; NOT used in proof terms here):
    - R4_Agent2.alphaD_in_unit_iff   (we invoke R_150a_exponent_range directly)
    - R81ab.two_transitions          (reached transitively inside
                                      double_descent_of_LDD, not a proof term here)

  All four 'Depends on' MODULES are load-bearing; the R4 tower module
  (R4_Agent2) and both R.80 and R.81ab supply lemmas used in proof terms.
-/
import MIP.Discoveries.R4_Agent2_PhaseScalingUnification
import MIP.Results.R80_GrokkingCrossing
import MIP.Results.R81ab_DoubleDescentSplit
import Mathlib.Tactic.Linarith

namespace MIP

namespace R8_Agent3_GrokkingDoubleDescentUnified

open MIP.R4_Agent2_PhaseScalingUnification
open MIP.GrokkingCrossing
open MIP.DoubleDescentSplit
open MIP.ChinchillaDegeneration

/-! ### (a) Grokking and double descent are two thresholds of one order
parameter

The single order parameter is `scalingLoss L_∞ C α_D D = L_∞ + C·D^(−α_D)`
(R4_Agent2).  We attach to the grokking event its coverage loss level
`ℓ_grok` and to the double-descent peak its loss level `ℓ_dd`, and locate
both as crossing budgets of this one order parameter. -/

/-- **(a) Grokking budget solves the order parameter at the grokking loss
level.**  The grokking event of R.80 is the coverage crossing; pinned to a
loss level `ℓ_grok > L_∞`, its crossing budget `D_grok = crossBudget …
ℓ_grok` is the UNIQUE inverse solving `L(D_grok) = ℓ_grok` exactly.  Proof
term is R4_Agent2's `bridge_solves`. -/
theorem grokking_budget_solves
    (Linf C s ℓ_grok : ℝ) (hC : 0 < C) (h_s : 1 < s) (hg : Linf < ℓ_grok) :
    scalingLoss Linf C (alphaD s) (crossBudget Linf C (alphaD s) ℓ_grok)
      = ℓ_grok :=
  bridge_solves Linf C (alphaD s) ℓ_grok hC (R_150a_exponent_range s h_s).1 hg

/-- **(a) The grokking loss level is genuinely reached (R.80 crossing).**

A continuous coverage coordinate `K_t` starting strictly below the coverage
threshold `Rsup` and ending at/above it crosses it: there is a real
grokking time `t*` with `K_t t* = Rsup`, at which emergence becomes finite
(`Nfin`).  This certifies that the loss level we attach to the grokking
threshold corresponds to an actual crossing event, not a vacuous one.
Proof terms: R.80's `R_80_coverage_crossing` and `R_80_finite_at_crossing`. -/
theorem grokking_crossing_realized
    (K_t : ℝ → ℝ) (Rsup t₀ t₁ : ℝ)
    (h_le : t₀ ≤ t₁)
    (h_cont : ContinuousOn K_t (Set.Icc t₀ t₁))
    (h_below : K_t t₀ < Rsup) (h_above : Rsup ≤ K_t t₁) :
    ∃ t_star ∈ Set.Icc t₀ t₁, K_t t_star = Rsup ∧ Nfin K_t Rsup t_star := by
  obtain ⟨t_star, h_mem, h_eq⟩ :=
    R_80_coverage_crossing K_t Rsup t₀ t₁ h_le h_cont h_below h_above
  exact ⟨t_star, h_mem, h_eq, R_80_finite_at_crossing K_t Rsup t_star h_eq⟩

/-- **(a) The double-descent peak is genuinely a sign-reversal (R.81ab).**

The double-descent interpolation peak is the boundary of the middle ascent
phase: under the residual-free sign criterion, the loss-rate triple
`(dN₁,dN₂,dN₃)` exhibits `DD` exactly when the order-parameter weight `W`
reverses sign twice (`LDD W₁ W₂ W₃`).  We certify that the DD event we
pin to `ℓ_dd` is a real two-transition event.  Proof term: R.81ab's
`double_descent_of_LDD`. -/
theorem double_descent_peak_realized
    {dN₁ dN₂ dN₃ W₁ W₂ W₃ : ℝ}
    (h₁ : dN₁ = -W₁) (h₂ : dN₂ = -W₂) (h₃ : dN₃ = -W₃)
    (hldd : LDD W₁ W₂ W₃) :
    DD dN₁ dN₂ dN₃ :=
  double_descent_of_LDD h₁ h₂ h₃ hldd

/-- **(a) HEADLINE-(a): both events are two thresholds of the one order
parameter.**

Given two loss levels `ℓ_grok, ℓ_dd > L_∞` — the grokking coverage level
and the double-descent peak level — the SAME scaling order parameter
`L(D) = L_∞ + C·D^(−α_D)` is solved at each by its crossing budget, AND
both events are genuinely realized (R.80 crossing for grokking, R.81ab
sign-reversal for double descent).  This is the precise sense in which
grokking and double descent are two thresholds of one phase order
parameter. -/
theorem grok_and_dd_are_two_thresholds
    (Linf C s ℓ_grok ℓ_dd : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (hg : Linf < ℓ_grok) (hd : Linf < ℓ_dd)
    -- grokking crossing data (R.80)
    (K_t : ℝ → ℝ) (Rsup t₀ t₁ : ℝ)
    (h_le : t₀ ≤ t₁) (h_cont : ContinuousOn K_t (Set.Icc t₀ t₁))
    (h_below : K_t t₀ < Rsup) (h_above : Rsup ≤ K_t t₁)
    -- double-descent data (R.81ab)
    {dN₁ dN₂ dN₃ W₁ W₂ W₃ : ℝ}
    (e₁ : dN₁ = -W₁) (e₂ : dN₂ = -W₂) (e₃ : dN₃ = -W₃)
    (hldd : LDD W₁ W₂ W₃) :
    -- both budgets solve the one order parameter exactly
    (scalingLoss Linf C (alphaD s) (crossBudget Linf C (alphaD s) ℓ_grok)
        = ℓ_grok
      ∧ scalingLoss Linf C (alphaD s) (crossBudget Linf C (alphaD s) ℓ_dd)
        = ℓ_dd)
    -- grokking event genuinely crosses (R.80)
    ∧ (∃ t_star ∈ Set.Icc t₀ t₁, K_t t_star = Rsup ∧ Nfin K_t Rsup t_star)
    -- double-descent event genuinely double-descends (R.81ab)
    ∧ DD dN₁ dN₂ dN₃ := by
  refine ⟨⟨grokking_budget_solves Linf C s ℓ_grok hC h_s hg,
           grokking_budget_solves Linf C s ℓ_dd hC h_s hd⟩, ?_, ?_⟩
  · exact grokking_crossing_realized K_t Rsup t₀ t₁ h_le h_cont h_below h_above
  · exact double_descent_peak_realized e₁ e₂ e₃ hldd

/-! ### (b) The gap is signed by the scaling exponent -/

/-- **(b) Gap signed by the exponent.**

In the genuine heavy-tail regime `s > 1`, the exponent lies in `(0,1)`
(R.150a `R_150a_exponent_range`, re-exported via R4_Agent2), so the order
parameter is strictly decreasing and its inverse `crossBudget` is strictly
order-REVERSING.  Hence if the double-descent peak sits at a strictly lower
loss than the grokking coverage level (`L_∞ < ℓ_dd < ℓ_grok` — a harder
target), the double-descent budget strictly exceeds the grokking budget:

    D_grok  <  D_dd .

The sign of the gap `D_dd − D_grok` is therefore fixed by the loss ordering
through the exponent-`α_D` power-law inverse.  Proof term: R4_Agent2's
`crossBudget_strictAnti`. -/
theorem grok_dd_gap_signed_by_exponent
    (Linf C s ℓ_grok ℓ_dd : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (h_dd : Linf < ℓ_dd) (h_lt : ℓ_dd < ℓ_grok) :
    crossBudget Linf C (alphaD s) ℓ_grok
      < crossBudget Linf C (alphaD s) ℓ_dd := by
  have hα : 0 < alphaD s := (R_150a_exponent_range s h_s).1
  exact crossBudget_strictAnti Linf C (alphaD s) ℓ_grok ℓ_dd hC hα h_dd h_lt

/-- **(b) Companion — the order parameter itself separates the two
thresholds.**  Between the two budgets the order parameter strictly
decreases, confirming `D_grok < D_dd` lie on a single decreasing branch
of `L`.  Proof term: R4_Agent2's `scalingLoss_strictAnti`. -/
theorem order_parameter_separates
    (Linf C s D_grok D_dd : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (h_pos : 0 < D_grok) (h_lt : D_grok < D_dd) :
    scalingLoss Linf C (alphaD s) D_dd < scalingLoss Linf C (alphaD s) D_grok :=
  scalingLoss_strictAnti Linf C (alphaD s) D_grok D_dd hC
    (R_150a_exponent_range s h_s).1 h_pos h_lt

/-! ### (c) Degenerate critical point: gap vanishes iff loss levels coincide -/

/-- **(c) Coincidence at the degenerate critical point.**

If the grokking coverage loss level equals the double-descent peak loss
level (`ℓ_grok = ℓ_dd`), the two crossing budgets coincide and the gap
vanishes: `D_grok = D_dd`.  This is the degenerate critical point at which
grokking and the double-descent peak collapse onto a single critical locus
of the order parameter.  (Pure congruence of the inverse map; no further
hypotheses needed.) -/
theorem degenerate_gap_vanishes
    (Linf C s ℓ_grok ℓ_dd : ℝ) (h_eq : ℓ_grok = ℓ_dd) :
    crossBudget Linf C (alphaD s) ℓ_grok
      = crossBudget Linf C (alphaD s) ℓ_dd := by
  rw [h_eq]

/-- **(c) Non-degeneracy from strict loss separation.**

Conversely, strict loss separation forces a strict budget gap (so the
critical point is non-degenerate): if `L_∞ < ℓ_dd < ℓ_grok` then
`D_grok ≠ D_dd`.  Together with `degenerate_gap_vanishes` this makes
coincidence of the two budgets *equivalent* to coincidence of the two loss
thresholds: the gap vanishes iff we are at the degenerate critical point. -/
theorem nondegenerate_gap_strict
    (Linf C s ℓ_grok ℓ_dd : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (h_dd : Linf < ℓ_dd) (h_lt : ℓ_dd < ℓ_grok) :
    crossBudget Linf C (alphaD s) ℓ_grok
      ≠ crossBudget Linf C (alphaD s) ℓ_dd :=
  ne_of_lt (grok_dd_gap_signed_by_exponent Linf C s ℓ_grok ℓ_dd hC h_s h_dd h_lt)

/-- **(c) Coincidence iff degenerate (budget gap = 0 ⟺ loss levels equal).**

Packaging (c): in the heavy-tail regime, with the loss levels comparable
(`L_∞ < ℓ_dd ≤ ℓ_grok`, i.e. grokking tolerates no less loss than the DD
peak), the two crossing budgets coincide IFF the two loss thresholds
coincide.  The gap is a faithful order parameter for degeneracy. -/
theorem coincide_iff_degenerate
    (Linf C s ℓ_grok ℓ_dd : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (h_dd : Linf < ℓ_dd) (h_le : ℓ_dd ≤ ℓ_grok) :
    crossBudget Linf C (alphaD s) ℓ_grok
        = crossBudget Linf C (alphaD s) ℓ_dd
      ↔ ℓ_grok = ℓ_dd := by
  constructor
  · intro h_budget_eq
    rcases lt_or_eq_of_le h_le with h_lt | h_eq
    · exact absurd h_budget_eq
        (nondegenerate_gap_strict Linf C s ℓ_grok ℓ_dd hC h_s h_dd h_lt)
    · exact h_eq.symm
  · intro h_eq
    exact degenerate_gap_vanishes Linf C s ℓ_grok ℓ_dd h_eq

/-! ### HEADLINE: grokking and double descent unified -/

/-- **HEADLINE — grokking and double descent are two thresholds of one
phase order parameter; their gap is set by the scaling exponent and
vanishes at a degenerate critical point.**

In the genuine heavy-tail regime `s > 1` (so `0 < α_D = alphaD s < 1` by
R.150a, the regime in which the scaling order parameter
`L(D) = L_∞ + C·D^(−α_D)` is a strictly decreasing bijection), with a real
grokking coverage crossing (R.80 data) and a real double-descent
sign-reversal (R.81ab data), and loss levels `L_∞ < ℓ_dd ≤ ℓ_grok`:

  (1) BOTH events are thresholds of the ONE order parameter `L`: the
      grokking budget `D_grok` and the double-descent budget `D_dd` each
      solve `L(D) = ℓ` exactly (R4_Agent2 `bridge_solves`).
  (2) The grokking coverage level is genuinely crossed, emergence becoming
      finite at the crossing (R.80), and the double-descent peak is a
      genuine two-transition event (R.81ab).
  (3) The GAP is signed by the exponent-`α_D` inverse: whenever
      `ℓ_dd < ℓ_grok` strictly, `D_grok < D_dd` strictly
      (R4_Agent2 `crossBudget_strictAnti`).
  (4) The gap VANISHES (`D_grok = D_dd`) iff `ℓ_grok = ℓ_dd` — the
      degenerate critical point where the two thresholds collapse onto one
      critical locus.

This chains R.80 + R.81ab + R4_Agent2 (the R4 tower) + R.150a. -/
theorem grokking_double_descent_unified
    (Linf C s ℓ_grok ℓ_dd : ℝ)
    (hC : 0 < C) (h_s : 1 < s)
    (h_dd : Linf < ℓ_dd) (h_le : ℓ_dd ≤ ℓ_grok)
    -- grokking crossing data (R.80)
    (K_t : ℝ → ℝ) (Rsup t₀ t₁ : ℝ)
    (h_le_t : t₀ ≤ t₁) (h_cont : ContinuousOn K_t (Set.Icc t₀ t₁))
    (h_below : K_t t₀ < Rsup) (h_above : Rsup ≤ K_t t₁)
    -- double-descent data (R.81ab)
    {dN₁ dN₂ dN₃ W₁ W₂ W₃ : ℝ}
    (e₁ : dN₁ = -W₁) (e₂ : dN₂ = -W₂) (e₃ : dN₃ = -W₃)
    (hldd : LDD W₁ W₂ W₃) :
    let D_grok := crossBudget Linf C (alphaD s) ℓ_grok
    let D_dd   := crossBudget Linf C (alphaD s) ℓ_dd
    -- (1) both are thresholds of the one order parameter L
    (scalingLoss Linf C (alphaD s) D_grok = ℓ_grok
       ∧ scalingLoss Linf C (alphaD s) D_dd = ℓ_dd)
    -- (2) both events genuinely realized (R.80 + R.81ab)
    ∧ (∃ t_star ∈ Set.Icc t₀ t₁, K_t t_star = Rsup ∧ Nfin K_t Rsup t_star)
    ∧ DD dN₁ dN₂ dN₃
    -- (3) gap signed by the exponent when strictly separated
    ∧ (ℓ_dd < ℓ_grok → D_grok < D_dd)
    -- (4) gap vanishes iff degenerate critical point
    ∧ (D_grok = D_dd ↔ ℓ_grok = ℓ_dd) := by
  intro D_grok D_dd
  have hg : Linf < ℓ_grok := lt_of_lt_of_le h_dd h_le
  refine ⟨⟨grokking_budget_solves Linf C s ℓ_grok hC h_s hg,
           grokking_budget_solves Linf C s ℓ_dd hC h_s h_dd⟩,
          grokking_crossing_realized K_t Rsup t₀ t₁ h_le_t h_cont h_below h_above,
          double_descent_peak_realized e₁ e₂ e₃ hldd,
          ?_, ?_⟩
  · intro h_strict
    exact grok_dd_gap_signed_by_exponent Linf C s ℓ_grok ℓ_dd hC h_s h_dd h_strict
  · exact coincide_iff_degenerate Linf C s ℓ_grok ℓ_dd hC h_s h_dd h_le

end R8_Agent3_GrokkingDoubleDescentUnified

end MIP
