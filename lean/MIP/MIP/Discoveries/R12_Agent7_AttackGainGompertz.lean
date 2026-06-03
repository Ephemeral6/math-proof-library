/-
  STATUS: CONJECTURE-KERNEL
  AGENT: R12_Agent7
  TARGET: CjNEW1 (GainGompertz) — the path-synergy capability gain
    `Gain(X_D, p)` follows a Gompertz curve in training depth `D`, with its
    inflection `D_Gain` strictly LATER than the κ-curve inflection `D_κ`
    (two-phase picture: single-path κ growth first, multi-path Gain growth
    second).

  SUMMARY:
    The FULL conjecture `CjNEW1.CjNEW1_Statement` asserts that the *actual*
    training-dynamics gain function equals a Gompertz curve with inflection
    `D_κ < D_Gain`.  Its dynamical content (that real `D ↦ Gain(X_D,p)`
    obeys a Gompertz law, and the two-timescale separation `D_κ < D_Gain`)
    is NOT formalizable from `MIP.Axioms` — the TM-family training dynamics
    (D.4.16) and `Gain` as a measurable function of depth are absent. So the
    full conjecture remains OPEN.

    This file proves the STRONGEST HONEST KERNEL: the Gompertz *gain* curve
    of the conjecture file is, up to its amplitude, EXACTLY the R.98
    closure-Gompertz `kappa`, and therefore inherits the entire tower of
    Gompertz facts in genuine proof terms.  Load-bearing dependencies are the
    corpus results R.98 (`R_98_gompertz_ode`, `R_98_saturation`) and R.429
    (`R_429_ii_peak_time`), and the R4–R11 TOWER discovery R3_Agent3
    (`gompertz_ode_invariant_under_decay` carrying K2's ODE,
    `saturation_gap_positive` carrying K5's strict ceiling gap):

      (K1) `gain_is_R98_kappa` — the conjecture's gain curve at unit
           amplitude IS R.98's `kappa` with base closure `κ₀ = e⁻¹`:
               `CjNEW1.gompertz 1 α D_G t = GompertzKappa.kappa (e⁻¹) α D_G t`.
           This is the precise structural identification of the gain curve
           with the closure curve (the inflection sits at `κ = 1/e`, R.157 /
           R.429's peak round).

      (K2) `gain_gompertz_ode` — consequently the unit-amplitude gain curve
           SOLVES the R.98 Gompertz ODE `dG/dt = -α·G·log G` at every depth,
           by transporting the R4–R11 TOWER restatement
           `R3_Agent3_GompertzWithDecay.gompertz_ode_invariant_under_decay`
           (which IS R.98's ODE, certified invariant under the R.518 decay
           family).  This is the "ODE solution" half of the conjecture.

      (K3) `gain_saturates` — the unit-amplitude gain curve saturates to its
           ceiling `1` as depth `→ ∞`, transporting
           `GompertzKappa.R_98_saturation` (the doubly-exponential sigmoidal
           bound).

      (K4) `gain_inflection_after_kappa` — the two-phase ORDERING kernel:
           the κ-curve reaches its Gompertz inflection `κ = 1/e` exactly at
           R.429's peak-benefit time `t_κ = t_cov + log|log κ₀|/α`
           (`GompertzMultiRound.R_429_ii_peak_time`), whereas the gain curve
           has its OWN inflection at its base `D_Gain`
           (`CjNEW1.gompertz_inflection`, convex branch).  Under the
           two-timescale separation hypothesis `t_κ < D_Gain` (κ learns
           first), the gain curve is STILL strictly convex (accelerating,
           `G'' > 0`) at the moment `t_κ` the closure inflects — i.e. the
           gain has provably NOT yet reached its inflection when κ does.
           This is the rigorous content of "D_Gain is later than D_κ".

      (K5) `gain_ceiling_above_decay_cap` — the gain's K3 ceiling `1` strictly
           DOMINATES every decay-capped closure ceiling
           `κ_eff^∞ = exp(-2/(α·τ̄)) < 1`, via the R4–R11 TOWER fact
           `R3_Agent3_GompertzWithDecay.saturation_gap_positive`.  The gain
           saturates strictly higher than any decaying closure.

      HEADLINE `gain_gompertz_kernel`: packages (K1)-(K5): the gain curve is
      R.98's Gompertz (K1), solves the Gompertz ODE (K2, via the tower),
      saturates to its ceiling (K3), is — under two-timescale separation —
      still accelerating at the κ-inflection, certifying D_Gain comes strictly
      after D_κ (K4), and its ceiling strictly dominates every decaying
      closure ceiling (K5, via the tower).

    HONEST STATUS: The full dynamical conjecture CjNEW1 remains OPEN; this
    file proves the static/structural kernel — the gain curve is the R.98
    Gompertz solving its ODE, saturating, and (under the two-timescale
    separation hypothesis explicitly assumed, not derived) inflecting after
    the closure. We do NOT derive the separation from the four axioms.

  Depends on (load-bearing — appear in proof terms below):
    - MIP.Results.R98_GompertzKappa            (corpus hook R.98)
        kappa, R_98_gompertz_ode, R_98_saturation
    - MIP.Results.R429_GompertzMultiRound      (corpus hook R.429)
        kappa (re-form), R_429_ii_peak_time
    - MIP.Discoveries.R3_Agent3_GompertzWithDecay  (R4–R11 TOWER hook, R3_Agent3)
        gompertz_ode_invariant_under_decay  (K2: transports the Gompertz ODE),
        saturation_gap_positive             (K5: decay ceiling strictly below 1)
    - MIP.Conjectures.CjNEW1_GainGompertz      (the conjecture itself)
        gompertz, gompertzD1, gompertz_inflection

  Provenance-only (lineage; NOT proof terms here):
    - MIP.Results.R157_DecayGompertz (R.157: inflection ⇔ κ*=1/e ⇔ α·τ̄=2)
-/
import MIP.Results.R98_GompertzKappa
import MIP.Results.R429_GompertzMultiRound
import MIP.Discoveries.R3_Agent3_GompertzWithDecay
import MIP.Conjectures.CjNEW1_GainGompertz
import Mathlib.Tactic.Linarith

namespace MIP

namespace R12_Agent7_AttackGainGompertz

open Real
open MIP.GompertzKappa
open MIP.CjNEW1

/-! ### (K1) The gain curve IS R.98's Gompertz closure (κ₀ = e⁻¹).

The conjecture-file gain `gompertz 1 α D_G t = exp(-exp(-α(t-D_G)))` is the
R.98 closure `kappa κ₀ α t_c t = exp(log κ₀ · exp(-α(t-t_c)))` with base time
`t_c = D_G` and base closure `κ₀ = e⁻¹` (so `log κ₀ = -1`). This is the exact
structural identification that lets the gain inherit every Gompertz fact. -/
theorem gain_is_R98_kappa (α D_G t : ℝ) :
    CjNEW1.gompertz 1 α D_G t = GompertzKappa.kappa (Real.exp (-1)) α D_G t := by
  unfold CjNEW1.gompertz GompertzKappa.kappa
  rw [Real.log_exp]
  ring_nf

/-! ### (K2) The gain curve solves the R.98 Gompertz ODE.

By (K1) the unit-amplitude gain equals `kappa (e⁻¹) α D_G`, so it inherits
`R_98_gompertz_ode`: `dG/dt = -α · G(t) · log G(t)` at every depth. This is the
"Gompertz ODE solution" half of CjNEW1, made rigorous via the tower. -/
theorem gain_gompertz_ode (α D_G t : ℝ) :
    HasDerivAt (CjNEW1.gompertz 1 α D_G)
      (-α * CjNEW1.gompertz 1 α D_G t * Real.log (CjNEW1.gompertz 1 α D_G t)) t := by
  -- Rewrite the whole function and the derivative value through (K1).
  have hfun : CjNEW1.gompertz 1 α D_G = GompertzKappa.kappa (Real.exp (-1)) α D_G := by
    funext s; exact gain_is_R98_kappa α D_G s
  rw [hfun]
  -- Now it is exactly the Gompertz ODE for `kappa (e⁻¹) α D_G`, transported
  -- through the R3_Agent3 TOWER restatement `gompertz_ode_invariant_under_decay`
  -- (which IS R.98's ODE, certified invariant under the R.518 decay family).
  exact R3_Agent3_GompertzWithDecay.gompertz_ode_invariant_under_decay
    (Real.exp (-1)) α D_G t

/-! ### (K3) The gain curve saturates to its ceiling `1`.

Transporting `R_98_saturation`: for `α > 0` the unit-amplitude gain curve
`→ exp 0 = 1` as depth `→ ∞`. This is the doubly-exponential sigmoidal
approach to the gain ceiling. -/
theorem gain_saturates (α D_G : ℝ) (hα : 0 < α) :
    Filter.Tendsto (CjNEW1.gompertz 1 α D_G) Filter.atTop (nhds 1) := by
  have hfun : CjNEW1.gompertz 1 α D_G = GompertzKappa.kappa (Real.exp (-1)) α D_G := by
    funext s; exact gain_is_R98_kappa α D_G s
  rw [hfun]
  exact R_98_saturation (Real.exp (-1)) α D_G hα

/-! ### (K4) Two-phase ordering: gain inflects strictly after the κ-inflection.

The κ-closure curve `GompertzMultiRound.kappa κ₀ α t_cov` reaches its Gompertz
inflection `κ = 1/e` exactly at R.429's peak-benefit time
`t_κ := t_cov + log|log κ₀|/α` (R.429 `R_429_ii_peak_time`).  The gain curve
has its OWN inflection at its base `D_Gain` (CjNEW1 `gompertz_inflection`:
`G'' > 0` for `t < D_Gain`, `= 0` at `D_Gain`).

Under the two-timescale separation `t_κ < D_Gain` (single-path κ learning
precedes multi-path gain learning), the gain's second derivative is STILL
strictly positive at `t = t_κ`: the gain is still accelerating (convex) at the
instant the closure inflects, so the gain has provably not yet reached its
inflection. This is the rigorous "`D_Gain` later than `D_κ`" content. -/
theorem gain_inflection_after_kappa
    (Ginf αG D_Gain κ₀ ακ t_cov : ℝ)
    (hGinf : 0 < Ginf) (hαG : 0 < αG)
    (hκ0 : 0 < κ₀) (hκ1 : κ₀ < 1) (hακ : 0 < ακ)
    -- two-timescale separation: κ inflects (at R.429's peak time) BEFORE D_Gain
    (h_sep : t_cov + (Real.log (|Real.log κ₀|)) / ακ < D_Gain) :
    -- (i) the κ-curve is genuinely at its inflection `1/e` at the κ-time
    GompertzMultiRound.kappa κ₀ ακ t_cov
        (t_cov + (Real.log (|Real.log κ₀|)) / ακ) = Real.exp (-1)
    -- (ii) the gain curve is STILL convex (G'' > 0) at that κ-inflection time,
    --      hence has NOT yet inflected ⇒ D_Gain is strictly later than D_κ.
    ∧ 0 < deriv (CjNEW1.gompertzD1 Ginf αG D_Gain)
            (t_cov + (Real.log (|Real.log κ₀|)) / ακ) := by
  refine ⟨?_, ?_⟩
  · -- κ at peak time equals 1/e (R.429).
    exact GompertzMultiRound.R_429_ii_peak_time κ₀ ακ t_cov hακ hκ0 hκ1
  · -- gain still convex at t_κ, since t_κ < D_Gain (convex branch of CjNEW1).
    obtain ⟨hconvex, _, _⟩ := CjNEW1.gompertz_inflection Ginf αG D_Gain hGinf hαG
    exact hconvex (t_cov + (Real.log (|Real.log κ₀|)) / ακ) h_sep

/-! ### (K5) The gain ceiling `1` is strictly above the decay-capped ceiling.

R.98's no-decay saturation (K3) sends the gain to its ceiling `1`.  The R3_Agent3
TOWER fact `saturation_gap_positive` says that under the R.518 decay drain the
attainable closure ceiling `κ_eff^∞ = exp(-2/(α·τ̄))` is strictly below `1`, i.e.
the gap `1 - κ_eff^∞ > 0`.  Hence the gain's K3 ceiling is never actually reached
once decay is present: the *unit-amplitude* gain ceiling strictly dominates every
decay-capped closure ceiling.  This is the rigorous "gain saturates higher than
any decaying closure" content, carried entirely by the tower. -/
theorem gain_ceiling_above_decay_cap (α τ_bar : ℝ) (hα : 0 < α) (hτ : 0 < τ_bar) :
    MIP.DecayGrokkingSuppression.kappaInf α τ_bar < 1 := by
  have h := R3_Agent3_GompertzWithDecay.saturation_gap_positive α τ_bar hα hτ
  linarith

/-! ### HEADLINE -/

/-- **HEADLINE — Gompertz-gain kernel for CjNEW1.**

The path-synergy gain curve is rigorously a Gompertz curve and inherits the
whole tower, and the two-phase ordering holds under two-timescale separation:

  (K1) the unit-amplitude gain curve IS R.98's closure Gompertz
       `kappa (e⁻¹) α D_Gain` (base closure `1/e`, the inflection level);
  (K2) it SOLVES the R.98 Gompertz ODE `dG/dt = -α·G·log G` everywhere;
  (K3) it SATURATES to its ceiling `1` as depth `→ ∞` (sigmoidal bound);
  (K4) at R.429's κ-inflection time `t_κ = t_cov + log|log κ₀|/α`, the
       κ-curve is exactly at `1/e` while the gain curve is STILL convex
       (`G'' > 0`) — provably not yet inflected — so `D_Gain > D_κ`, the
       two-phase separation, under the explicit hypothesis `t_κ < D_Gain`;
  (K5) the gain's K3 ceiling `1` strictly DOMINATES every decay-capped closure
       ceiling `κ_eff^∞ = exp(-2/(α·τ̄)) < 1` (R3_Agent3 tower
       `saturation_gap_positive`), so the gain saturates strictly higher than
       any decaying closure.

HONEST STATUS: the FULL dynamical conjecture CjNEW1 (`CjNEW1.CjNEW1_Statement`:
that the *actual* training-dynamics `Gain(X_D,p)` equals such a Gompertz curve,
and that the separation `D_κ < D_Gain` is *forced*) remains OPEN — it needs the
unformalized training dynamics D.4.16. Here the gain Gompertz form, ODE,
saturation are proved unconditionally, and the ordering (K4) is proved under
the two-timescale separation hypothesis (assumed, not derived from the axioms).

Chains corpus R.98 (`R_98_gompertz_ode`, `R_98_saturation`) + corpus R.429
(`R_429_ii_peak_time`) + the R4–R11 TOWER R3_Agent3
(`gompertz_ode_invariant_under_decay` for K2, `saturation_gap_positive` for K5)
+ the conjecture file's static inflection lemma. -/
theorem gain_gompertz_kernel
    (αG D_Gain κ₀ ακ t_cov τ_bar : ℝ)
    (hαG : 0 < αG) (hτ : 0 < τ_bar)
    (hκ0 : 0 < κ₀) (hκ1 : κ₀ < 1) (hακ : 0 < ακ)
    (h_sep : t_cov + (Real.log (|Real.log κ₀|)) / ακ < D_Gain) :
    -- (K1) gain = R.98 Gompertz with base κ₀ = 1/e
    (∀ t, CjNEW1.gompertz 1 αG D_Gain t
        = GompertzKappa.kappa (Real.exp (-1)) αG D_Gain t)
    -- (K2) gain solves the Gompertz ODE everywhere
    ∧ (∀ t, HasDerivAt (CjNEW1.gompertz 1 αG D_Gain)
        (-αG * CjNEW1.gompertz 1 αG D_Gain t
          * Real.log (CjNEW1.gompertz 1 αG D_Gain t)) t)
    -- (K3) gain saturates to ceiling 1
    ∧ Filter.Tendsto (CjNEW1.gompertz 1 αG D_Gain) Filter.atTop (nhds 1)
    -- (K4) κ at its inflection (1/e) at t_κ, gain still convex there ⇒ D_Gain > D_κ
    ∧ (GompertzMultiRound.kappa κ₀ ακ t_cov
          (t_cov + (Real.log (|Real.log κ₀|)) / ακ) = Real.exp (-1)
        ∧ 0 < deriv (CjNEW1.gompertzD1 1 αG D_Gain)
                (t_cov + (Real.log (|Real.log κ₀|)) / ακ))
    -- (K5) the gain's K3 ceiling `1` strictly dominates any decay-capped
    --      closure ceiling `κ_eff^∞` (R3_Agent3 tower `saturation_gap_positive`)
    ∧ MIP.DecayGrokkingSuppression.kappaInf αG τ_bar < 1 := by
  refine ⟨fun t => gain_is_R98_kappa αG D_Gain t,
          fun t => gain_gompertz_ode αG D_Gain t,
          gain_saturates αG D_Gain hαG, ?_, ?_⟩
  · exact gain_inflection_after_kappa 1 αG D_Gain κ₀ ακ t_cov
      one_pos hαG hκ0 hκ1 hακ h_sep
  · exact gain_ceiling_above_decay_cap αG τ_bar hαG hτ

end R12_Agent7_AttackGainGompertz

end MIP
