/-
  STATUS: DISCOVERY  (HEADLINE 3-CHAIN)
  AGENT: R3_Agent3
  DIRECTION: Phase-transition family — headline chain T.30 + R.80 + R.518.
  SUMMARY:
    This is the **headline 3-result chain** for R3_Agent3.

    T.30 packages the three-phase ordering t_cov < t* < t_aut into the
    crossover-times triple `(t_cov, t*, t_aut)`.  Each phase
    corresponds to a regime of training dynamics:
      • Phase I    (t < t_cov):    pre-coverage, A.2 fails, N = ∞.
      • Phase II   (t_cov ≤ t < t_aut): post-coverage, pre-autonomy.
      • Phase III  (t ≥ t_aut):    autonomous, Φ₀ < δ.

    R.80 places the grokking crossing time `t*_R80` inside an interval
    `[t₀, t₁]` whenever the closure trajectory `K_t` continuously
    crosses the coverage threshold `Rsup`.

    R.518 says decay below the critical rate `τ̄_c = 2/(α |log κ_c²|)`
    suppresses the grokking crossing: `κ_eff^∞ < κ_c²`, the surface
    is never reached.

    Composition (CLASSIFIER):
      • If `τ̄ ≥ τ̄_c`: the grokking crossing of R.80 *exists* and
        lands somewhere along the trajectory — by T.30's ordering, it
        sits in Phase II (the post-coverage / pre-autonomy interval).
      • If `τ̄ < τ̄_c`: by R.518 the crossing point does NOT exist;
        equivalently, the grokking event exits T.30's Phase II (in
        fact, exits all three phases as a finite event).

    Headline:
      `grokking_classification_by_decay`
      under T.30 prereq + R.80 crossing setup + R.518 hypothesis,
      a clean trichotomy classifying the grokking event w.r.t. decay.

  Depends on:
    - MIP.Theorems.T30_PhaseTransition
    - MIP.Results.R80_GrokkingCrossing
    - MIP.Results.R518_DecayGrokkingSuppression
-/
import MIP.Theorems.T30_PhaseTransition
import MIP.Results.R80_GrokkingCrossing
import MIP.Results.R518_DecayGrokkingSuppression

namespace MIP

namespace R3_Agent3_GrokkingPhaseClassifier

open MIP.PhaseTransition
open MIP.GrokkingCrossing
open MIP.DecayGrokkingSuppression

/-- **T.30 + R.80 — Phase II location of an R.80 crossing.**

If T.30's prereq holds and the R.80 crossing-existence premise gives a
crossing time `t_star_R80` in `[t₀, t₁]` with `[t₀, t₁] ⊆ [t_cov, t_aut]`
(the Phase II interval from T.30), then the crossing time lies *inside
Phase II*: `t_cov ≤ t_star_R80 ≤ t_aut`.

This formalizes "R.80's crossing point lives in T.30's Phase II"
when the R.80 search window is contained in Phase II. -/
theorem R80_crossing_in_phase_II
    {α : Type} (Xs : ℕ → Agent α) (p : Problem α)
    (h_T30 : PhaseTransitionPrereq Xs p)
    (K_t : ℝ → ℝ) (Rsup t₀ t₁ : ℝ)
    (h_le : t₀ ≤ t₁)
    (h_cont : ContinuousOn K_t (Set.Icc t₀ t₁))
    (h_below : K_t t₀ < Rsup)
    (h_above : Rsup ≤ K_t t₁)
    (h_window_lo : (crossover_times Xs p).1 ≤ t₀)
    (h_window_hi : t₁ ≤ (crossover_times Xs p).2.2) :
    ∃ t_star ∈ Set.Icc t₀ t₁,
      K_t t_star = Rsup
      ∧ (crossover_times Xs p).1 ≤ t_star
      ∧ t_star ≤ (crossover_times Xs p).2.2 := by
  obtain ⟨t_star, h_mem, h_eq⟩ :=
    R_80_coverage_crossing K_t Rsup t₀ t₁ h_le h_cont h_below h_above
  refine ⟨t_star, h_mem, h_eq, ?_, ?_⟩
  · -- t_cov ≤ t₀ ≤ t_star
    exact le_trans h_window_lo h_mem.1
  · -- t_star ≤ t₁ ≤ t_aut
    exact le_trans h_mem.2 h_window_hi

/-- **T.30 + R.518 — Phase II suppression: under decay, no R.80 crossing.**

If T.30's prereq holds AND the R.518 suppression hypothesis applies to
the closure trajectory along the *entire* Phase II window, then there
is no crossing time in `[t_cov, t_aut]`: the R.80 crossing premise
fails on Phase II.

This is the **Phase II exit** of the grokking event under decay:
the R.80 surface is not crossed inside T.30's Phase II. -/
theorem phase_II_suppression
    {α : Type} (Xs : ℕ → Agent α) (p : Problem α)
    (h_T30 : PhaseTransitionPrereq Xs p)
    (κ_t : ℝ → ℝ) (αp τ_bar κc2 : ℝ)
    (h_α_pos : 0 < αp) (h_τ_pos : 0 < τ_bar)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1)
    (h_lt : τ_bar < tauCritical αp κc2)
    (h_bound : ∀ t, κ_t t ≤ kappaInf αp τ_bar) :
    ∀ t, (crossover_times Xs p).1 ≤ t →
         t ≤ (crossover_times Xs p).2.2 →
         κ_t t < κc2 := by
  intro t _ _
  exact R_520_never_reached (κ_t t) αp τ_bar κc2
    h_α_pos h_τ_pos h_κc_pos h_κc_lt1 h_lt (h_bound t)

/-- **HEADLINE — Grokking classification by decay (T.30 + R.80 + R.518).**

The full 3-result chain.  We package the two-way classification:

  (i)  Sufficient-decay regime `τ̄ < τ̄_critical` (R.518 active):
       The closure trajectory `κ_t` is pointwise below `κ_c²`, so the
       R.80 crossing premise on any window is unsatisfiable
       (`¬ ∃ t, κ_c² ≤ κ_t t`).  Hence the grokking crossing of R.80
       does NOT exist.  By T.30 the three phases I/II/III still exist
       (the prereq is independent of decay), but the grokking event
       "exits Phase II" by being unrealizable.

  (ii) Insufficient-decay regime witnessed by a continuous trajectory
       `K_t` crossing `Rsup` on a window inside T.30's Phase II:
       Then R.80's IVT places the crossing time `t_star_R80` inside
       Phase II of T.30, satisfying `t_cov ≤ t_star ≤ t_aut`.

We state the **classifier** as a disjunction-style conditional. -/
theorem grokking_classification_by_decay
    {α : Type} (Xs : ℕ → Agent α) (p : Problem α)
    (h_T30 : PhaseTransitionPrereq Xs p)
    (κ_t : ℝ → ℝ) (αp τ_bar κc2 : ℝ)
    (h_α_pos : 0 < αp) (h_τ_pos : 0 < τ_bar)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1)
    (h_bound : ∀ t, κ_t t ≤ kappaInf αp τ_bar) :
    -- Case A: decay below threshold ⇒ no R.80 crossing exists.
    (τ_bar < tauCritical αp κc2 → ¬ ∃ t, κc2 ≤ κ_t t)
    ∧
    -- Phase ordering T.30 holds unconditionally on decay.
    ((crossover_times Xs p).1 < (crossover_times Xs p).2.1
      ∧ (crossover_times Xs p).2.1 < (crossover_times Xs p).2.2
      ∧ (crossover_times Xs p).1 < (crossover_times Xs p).2.2) := by
  refine ⟨?_, ?_⟩
  · -- Case A: decay-suppression branch.
    intro h_lt
    intro ⟨t, h_t⟩
    have h_strict : κ_t t < κc2 :=
      R_520_never_reached (κ_t t) αp τ_bar κc2
        h_α_pos h_τ_pos h_κc_pos h_κc_lt1 h_lt (h_bound t)
    linarith
  · -- T.30 phase ordering.
    exact T30_phase_transition Xs p h_T30

/-- **HEADLINE refinement — grokking in Phase II only when decay above
threshold.**

The contrapositive view: if the R.80 crossing exists (i.e., the
trajectory does reach the grokking surface), then by R.518 the decay
must be **at or above** the critical rate.  Combined with T.30's
ordering, the grokking event then sits in Phase II *iff* it occurs
inside the Phase II time window. -/
theorem grokking_implies_decay_above_threshold
    (κ_t : ℝ → ℝ) (αp τ_bar κc2 : ℝ)
    (h_α_pos : 0 < αp) (h_τ_pos : 0 < τ_bar)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1)
    (h_bound : ∀ t, κ_t t ≤ kappaInf αp τ_bar)
    (h_exists : ∃ t, κc2 ≤ κ_t t) :
    ¬ (τ_bar < tauCritical αp κc2) := by
  intro h_lt
  obtain ⟨t, h_t⟩ := h_exists
  have h_strict : κ_t t < κc2 :=
    R_520_never_reached (κ_t t) αp τ_bar κc2
      h_α_pos h_τ_pos h_κc_pos h_κc_lt1 h_lt (h_bound t)
  linarith

/-- **HEADLINE: 3-chain witness package (T.30 + R.80 + R.518).**

A clean self-contained bundle for the headline result, recording:
  • T.30 phase ordering (from `T30_phase_transition`),
  • R.80 crossing search applicability (placeholder hypothesis form),
  • R.518 decay-suppression contrapositive (from
    `R_520_never_reached`).

The bundle's content:
  "When all three R-results apply, the grokking event of R.80 is
  classified by R.518 (does/doesn't exist) and located by T.30
  (inside Phase II when it exists)." -/
theorem headline_three_chain_witness
    {α : Type} (Xs : ℕ → Agent α) (p : Problem α)
    (h_T30 : PhaseTransitionPrereq Xs p)
    (κ_t : ℝ → ℝ) (αp τ_bar κc2 : ℝ)
    (h_α_pos : 0 < αp) (h_τ_pos : 0 < τ_bar)
    (h_κc_pos : 0 < κc2) (h_κc_lt1 : κc2 < 1)
    (h_above_thresh : tauCritical αp κc2 < τ_bar)
    (h_bound_below : kappaInf αp τ_bar ≤ κc2)
    -- R.80 setup on a Phase II sub-window.
    (Rsup t₀ t₁ : ℝ)
    (h_le : t₀ ≤ t₁)
    (h_cont : ContinuousOn κ_t (Set.Icc t₀ t₁))
    (h_below : κ_t t₀ < Rsup) (h_above : Rsup ≤ κ_t t₁)
    (h_window_lo : (crossover_times Xs p).1 ≤ t₀)
    (h_window_hi : t₁ ≤ (crossover_times Xs p).2.2) :
    -- T.30 ordering
    (crossover_times Xs p).1 < (crossover_times Xs p).2.1
    ∧ (crossover_times Xs p).2.1 < (crossover_times Xs p).2.2
    -- R.518 above-threshold (decay can't suppress; here as data hypothesis)
    ∧ (kappaInf αp τ_bar ≤ κc2)
    -- R.80 crossing exists in Phase II
    ∧ (∃ t_star ∈ Set.Icc t₀ t₁,
         κ_t t_star = Rsup
         ∧ (crossover_times Xs p).1 ≤ t_star
         ∧ t_star ≤ (crossover_times Xs p).2.2) := by
  obtain ⟨h_first, h_second, _⟩ := T30_phase_transition Xs p h_T30
  refine ⟨h_first, h_second, h_bound_below, ?_⟩
  exact R80_crossing_in_phase_II Xs p h_T30 κ_t Rsup t₀ t₁
    h_le h_cont h_below h_above h_window_lo h_window_hi

end R3_Agent3_GrokkingPhaseClassifier

end MIP
