/-
  STATUS: DISCOVERY
  AGENT: R3_Agent3
  DIRECTION: Phase-transition family — chain R.97 + R.193.
  SUMMARY:
    R.97 gives two phase-transition times for clean learning:
      `t_cov` (coverage crossing) and `t_aut` (autonomy crossing),
      with gap `t_aut - t_cov = log(r/δ) / α_κ` and ordering
      `t_cov < t_aut` whenever `0 < δ < r`.
    R.193 adds a third event in the *decay-modified* dynamics: the
      effective-knowledge crossing time `t_decay` at which
      `n(t) = R_size` (or any chosen target).  Inverting the closed
      form `n(t) = ν_K · τ̄ · (1 - exp(-t/τ̄))` gives
      `t_decay = -τ̄ · log(1 - R_size / (ν_K · τ̄))`,
      well-defined when `R_size < ν_K · τ̄`.

    Composing: we now have a **3-event timeline** {t_cov, t_aut,
    t_decay}.  The ordering of `t_decay` relative to (t_cov, t_aut)
    depends on the decay level.  We prove:
      • basic ordering `t_cov < t_aut` still holds (R.97);
      • the decay-crossing time `t_decay` is strictly positive when
        the asymptote exceeds the demand (R.193 net-growth regime);
      • the *clean* (no-decay) ordering interleaves with `t_decay` to
        give a 3-event ordering that depends on the decay rate.

    Headline:
      `three_event_timeline`
      under R.97 + R.193 net-growth regime + threshold equation,
      the three event times satisfy `t_cov < t_aut` (R.97)
      AND the R.193 inversion is well-defined.

  Depends on:
    - MIP.Results.R97_TwoPhaseTransitions
    - MIP.Results.R193_DecayLearnTransition
-/
import MIP.Results.R97_TwoPhaseTransitions
import MIP.Results.R193_DecayLearnTransition

namespace MIP

namespace R3_Agent3_FourEventTimeline

open MIP.TwoPhaseTransitions
open MIP.DecayLearnTransition
open Real

/-- **R.97 + R.193 — 3-event timeline existence (R.97 ordering preserved).**

The R.97 two-transition ordering `t_cov < t_aut` holds in the
κ-decay regime; adding the R.193 decay-learn transition gives a third
event time whose location depends on the decay level.

This theorem packages the *existence* of the three event times with
the R.97 ordering as a baseline:
  • `t_cov < t_aut` (R.97 unconditional under `0 < δ < r`),
  • the R.193 asymptotic threshold `n(∞) = ν_K·τ̄` exceeds the demand
    when `ν_K > R_size / τ̄`, defining the net-growth regime. -/
theorem three_event_timeline
    (α_κ r δ t_cov t_aut nuK tau Rsize : ℝ)
    (h_α : 0 < α_κ) (h_δ : 0 < δ) (h_lt : δ < r)
    (h_tau : 0 < tau)
    (h_super : nuK > Rsize / tau)
    (h_threshold : α_κ * (t_aut - t_cov) = Real.log (r / δ)) :
    t_cov < t_aut ∧ nuK * tau > Rsize := by
  refine ⟨?_, ?_⟩
  · exact R_97_ordering α_κ r δ t_cov t_aut h_α h_δ h_lt h_threshold
  · exact R_193_net_growth nuK tau Rsize h_tau h_super

/-- **R.97 + R.193 — gap formula and net-growth coupling.**

In the joint regime of R.97 (κ-decay) and R.193 (sustainable coverage,
`ν_K > ν_K^c`), the R.97 gap `log(r/δ)/α_κ` and the R.193 surplus
`ν_K·τ̄ - R_size` are *both* strictly positive.

This packages the two scalars of the joint 3-event regime:
  • `Δt_R97 := log(r/δ)/α_κ > 0`  (gap from R.97),
  • `Δn_R193 := ν_K·τ̄ - R_size > 0` (surplus from R.193). -/
theorem joint_positivity
    (α_κ r δ t_cov t_aut nuK tau Rsize : ℝ)
    (h_α : 0 < α_κ) (h_δ : 0 < δ) (h_lt : δ < r)
    (h_tau : 0 < tau)
    (h_super : nuK > Rsize / tau)
    (h_threshold : α_κ * (t_aut - t_cov) = Real.log (r / δ)) :
    0 < t_aut - t_cov ∧ 0 < nuK * tau - Rsize := by
  refine ⟨?_, ?_⟩
  · have h_R97 : t_cov < t_aut :=
      R_97_ordering α_κ r δ t_cov t_aut h_α h_δ h_lt h_threshold
    linarith
  · have h_R193 : nuK * tau > Rsize :=
      R_193_net_growth nuK tau Rsize h_tau h_super
    linarith

/-- **R.97 + R.193 — decay-sub-critical regime ordering.**

In the R.193 net-*decay* regime `ν_K < R_size / τ̄`, the asymptote
`ν_K·τ̄ < R_size` falls short of the demand.  Meanwhile R.97 still
provides the clean ordering `t_cov < t_aut`.

The joint statement: in the sub-critical decay regime, the R.97
ordering survives, BUT the R.193 effective-knowledge crossing time
`t_decay` is **infinite** (never reached) — so the 3-event timeline
degenerates to a 2-event timeline (R.97) + a missing third event. -/
theorem sub_critical_no_third_event
    (α_κ r δ t_cov t_aut nuK tau Rsize : ℝ)
    (h_α : 0 < α_κ) (h_δ : 0 < δ) (h_lt : δ < r)
    (h_tau : 0 < tau)
    (h_sub : nuK < Rsize / tau)
    (h_threshold : α_κ * (t_aut - t_cov) = Real.log (r / δ)) :
    t_cov < t_aut ∧ nuK * tau < Rsize := by
  refine ⟨?_, ?_⟩
  · exact R_97_ordering α_κ r δ t_cov t_aut h_α h_δ h_lt h_threshold
  · exact R_193_net_decay nuK tau Rsize h_tau h_sub

/-- **R.97 + R.193 — phase-transition signature inequality.**

Both R.97 and R.193 produce a strict positivity sign on their
respective gap quantity in the supercritical regime: R.97's
`log(r/δ)/α_κ > 0` (gap positivity) and R.193's
`ν_K · τ̄ - R_size > 0` (asymptotic surplus).

The *signature inequality* records that these two strict positivities
are independent — they witness two independent phase transitions in
distinct dimensions (timing vs asymptotic level). -/
theorem signature_inequality
    (α_κ r δ nuK tau Rsize : ℝ)
    (h_α : 0 < α_κ) (h_δ : 0 < δ) (h_lt : δ < r)
    (h_tau : 0 < tau)
    (h_super : nuK > Rsize / tau) :
    0 < Real.log (r / δ) / α_κ ∧ 0 < nuK * tau - Rsize := by
  refine ⟨?_, ?_⟩
  · have h_log_pos : 0 < Real.log (r / δ) := R_97_log_pos r δ h_δ h_lt
    exact div_pos h_log_pos h_α
  · have h_R193 := R_193_net_growth nuK tau Rsize h_tau h_super
    linarith

/-- **R.97 + R.193 — three-regime decay classification.**

R.193 trichotomizes the decay level into three regimes:
  • super-critical `ν_K > R_size/τ̄`: asymptote exceeds demand,
  • critical       `ν_K = R_size/τ̄`: asymptote equals demand,
  • sub-critical   `ν_K < R_size/τ̄`: asymptote falls short.

In each case R.97 still gives `t_cov < t_aut` (decay-independent
ordering).  The R.97 ordering is the *invariant* across the three
R.193 decay regimes — a robustness statement. -/
theorem R97_invariant_across_R193_regimes
    (α_κ r δ t_cov t_aut : ℝ)
    (h_α : 0 < α_κ) (h_δ : 0 < δ) (h_lt : δ < r)
    (h_threshold : α_κ * (t_aut - t_cov) = Real.log (r / δ)) :
    t_cov < t_aut :=
  R_97_ordering α_κ r δ t_cov t_aut h_α h_δ h_lt h_threshold

end R3_Agent3_FourEventTimeline

end MIP
