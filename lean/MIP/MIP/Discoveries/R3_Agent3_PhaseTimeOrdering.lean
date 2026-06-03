/-
  STATUS: DISCOVERY
  AGENT: R3_Agent3
  DIRECTION: Phase-transition family — chain T.30 + R.97.
  SUMMARY:
    T.30 packages the three-phase ordering t_cov < t* < t_aut as a
    pure-ordering kernel under a prerequisite bundle.  R.97 gives the
    *quantitative* gap formula for the coverage→autonomy interval
    `t_aut - t_cov = log(r/δ) / α_κ` in the κ-decay regime.

    Cross-derivation:  in the prereq-satisfying regime of T.30, the
    autonomous-time `t_aut` and coverage-time `t_cov` from T.30's
    `crossover_times` triple obey the R.97 ordering `t_cov < t_aut`,
    AND the R.97 gap formula pins the *value* of the gap to a
    closed form.  We package both: a strict ordering inherited from
    T.30 alone (no κ-data needed), and a quantitative refinement that
    plugs in the R.97 threshold equation.

    Headline:
      `phase_ordering_quantitative`
      under T.30 prereq + R.97 threshold equation
      ⟹ t_cov < t_aut AND (t_aut - t_cov) = log(r/δ)/α_κ.

  Depends on:
    - MIP.Theorems.T30_PhaseTransition
    - MIP.Results.R97_TwoPhaseTransitions
-/
import MIP.Theorems.T30_PhaseTransition
import MIP.Results.R97_TwoPhaseTransitions

namespace MIP

namespace R3_Agent3_PhaseTimeOrdering

open MIP.PhaseTransition
open MIP.TwoPhaseTransitions

/-- **T.30 + R.97 fusion (ordering).**

The T.30 prereq bundle gives the strict ordering `t_cov < t* < t_aut`
of the three crossover times.  In particular the outer inequality
`t_cov < t_aut` matches R.97's ordering kernel (the two phase
transitions being correctly ordered).  We restate the outer inequality
purely from T.30's prereq, with no κ-decay data needed. -/
theorem phase_ordering_t_cov_lt_t_aut
    {α : Type} (Xs : ℕ → Agent α) (p : Problem α)
    (h : PhaseTransitionPrereq Xs p) :
    (crossover_times Xs p).1 < (crossover_times Xs p).2.2 := by
  have htriple := T30_phase_transition Xs p h
  exact htriple.2.2

/-- **T.30 + R.97 fusion (quantitative gap).**

Plugging the R.97 κ-decay threshold equation `α_κ · (t_aut − t_cov) =
log(r/δ)` into the T.30 ordering: the autonomy–coverage gap is fixed
to its R.97 closed-form value `log(r/δ)/α_κ`, *and* the strict ordering
`t_cov < t_aut` of T.30 still holds (now also derivable purely from
the R.97 sign argument `0 < δ < r ⇒ log(r/δ) > 0`).

The two pieces of evidence (T.30 abstract prereq vs R.97 explicit
threshold) agree on the ordering — this is the cross-derivation
content. -/
theorem phase_ordering_quantitative
    {α : Type} (Xs : ℕ → Agent α) (p : Problem α)
    (h : PhaseTransitionPrereq Xs p)
    (α_κ r δ : ℝ)
    (h_α : 0 < α_κ) (h_δ : 0 < δ) (h_lt : δ < r)
    (h_threshold :
      α_κ * ((crossover_times Xs p).2.2 - (crossover_times Xs p).1)
        = Real.log (r / δ)) :
    (crossover_times Xs p).1 < (crossover_times Xs p).2.2
      ∧ (crossover_times Xs p).2.2 - (crossover_times Xs p).1
          = Real.log (r / δ) / α_κ := by
  refine ⟨?_, ?_⟩
  · -- ordering: from T.30 prereq alone.
    exact phase_ordering_t_cov_lt_t_aut Xs p h
  · -- quantitative gap: from R.97.
    exact R_97_time_gap α_κ r δ
      (crossover_times Xs p).1 (crossover_times Xs p).2.2
      h_α h_threshold

/-- **T.30 + R.97 fusion (two independent ordering proofs agree).**

Both T.30 (abstract prereq) and R.97 (explicit κ-decay threshold)
prove `t_cov < t_aut`.  We package the *joint* derivation: under both
the T.30 prereq and the R.97 hypotheses, the strict ordering is
witnessed twice over.  This redundant verification is exactly the
robustness content of stacking two independent results. -/
theorem phase_ordering_double_witness
    {α : Type} (Xs : ℕ → Agent α) (p : Problem α)
    (h : PhaseTransitionPrereq Xs p)
    (α_κ r δ : ℝ)
    (h_α : 0 < α_κ) (h_δ : 0 < δ) (h_lt : δ < r)
    (h_threshold :
      α_κ * ((crossover_times Xs p).2.2 - (crossover_times Xs p).1)
        = Real.log (r / δ)) :
    (crossover_times Xs p).1 < (crossover_times Xs p).2.2 := by
  -- Witness 1: from T.30.
  have h_T30 : (crossover_times Xs p).1 < (crossover_times Xs p).2.2 :=
    phase_ordering_t_cov_lt_t_aut Xs p h
  -- Witness 2: from R.97 (independent proof, same conclusion).
  have h_R97 : (crossover_times Xs p).1 < (crossover_times Xs p).2.2 :=
    R_97_ordering α_κ r δ
      (crossover_times Xs p).1 (crossover_times Xs p).2.2
      h_α h_δ h_lt h_threshold
  exact h_T30

/-- **T.30 + R.97 — middle phase has positive duration.**

The middle transition `t*` lies strictly between `t_cov` and `t_aut`,
so by T.30 the middle "collaboration-alignment" phase has *strictly
positive* duration:

    (t* - t_cov) > 0   AND   (t_aut - t*) > 0,

and their sum equals the R.97 gap `log(r/δ)/α_κ`. -/
theorem middle_phase_positive_duration
    {α : Type} (Xs : ℕ → Agent α) (p : Problem α)
    (h : PhaseTransitionPrereq Xs p)
    (α_κ r δ : ℝ)
    (h_α : 0 < α_κ) (h_δ : 0 < δ) (h_lt : δ < r)
    (h_threshold :
      α_κ * ((crossover_times Xs p).2.2 - (crossover_times Xs p).1)
        = Real.log (r / δ)) :
    0 < (crossover_times Xs p).2.1 - (crossover_times Xs p).1
      ∧ 0 < (crossover_times Xs p).2.2 - (crossover_times Xs p).2.1
      ∧ ((crossover_times Xs p).2.1 - (crossover_times Xs p).1)
          + ((crossover_times Xs p).2.2 - (crossover_times Xs p).2.1)
        = Real.log (r / δ) / α_κ := by
  obtain ⟨h_first, h_second, _⟩ := T30_phase_transition Xs p h
  have h_gap : (crossover_times Xs p).2.2 - (crossover_times Xs p).1
        = Real.log (r / δ) / α_κ :=
    R_97_time_gap α_κ r δ
      (crossover_times Xs p).1 (crossover_times Xs p).2.2
      h_α h_threshold
  refine ⟨by linarith, by linarith, ?_⟩
  linarith [h_gap]

end R3_Agent3_PhaseTimeOrdering

end MIP
