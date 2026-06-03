/-
  STATUS: DISCOVERY
  AGENT: R2-5
  DIRECTION: Phase-change points along the trajectory — classical
             decidability and the forced-observable-change theorem.
  SUMMARY:
    Define `phaseChangePoints Xs p : Set ℕ` as the set of indices `t`
    where any of the three phase markers differs between `t` and `t+1`.
    We prove:
      (1) The set is classically decidable (Prop-extensionality + LEM).
      (2) **Forced observable change.** At any phase-change point `t`,
          either `Phi0` changes its "is zero?" status, or `K`-coverage
          changes its "exists?" status, between `t` and `t+1`.
          Contrapositive: if both observables are stable across `(t, t+1)`,
          then the phase doesn't change.
      (3) The phase markers as Prop-valued sequences match A.1 and A.2:
          `InPhaseIII Xs p t ↔ Phi0 (Xs t) p = 0` (via A.1),
          `InPhaseI Xs p t ↔ ∀ R'∈ℛ(p), ¬ R' ⊆ K (Xs t)` (via A.2).
      (4) `coverageAcquired Xs p t := ∃ R' ∈ ℛ(p), R' ⊆ K (Xs t)` is
          equivalent to `¬ InPhaseI Xs p t`.
-/
import MIP.Axioms

namespace MIP

namespace R2_Agent5_PhaseChangePoints

variable {α : Type}

/-! ## (1) Local phase markers (Agent 7 copies). -/

def InPhaseI (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) : Prop :=
  N p (Xs t) = ⊤

def InPhaseII (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) : Prop :=
  0 < N p (Xs t) ∧ N p (Xs t) < ⊤

def InPhaseIII (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) : Prop :=
  N p (Xs t) = 0

/-! ## (2) Observable predicates. -/

/-- **Coverage-acquired** at index `t`: some demand is covered by the
    agent's knowledge.  By A.2, this is equivalent to `N p (Xs t) ≠ ⊤`. -/
def coverageAcquired {Ω : Type} (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) : Prop :=
  ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Xs t) : Set Ω)

/-- **Φ₀ is zero** at index `t`.  By A.1, equivalent to `N p (Xs t) = 0`. -/
def phi0IsZero (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) : Prop :=
  Phi0 (Xs t) p = 0

/-! ## (3) Equivalences with phase markers. -/

/-- **Phase III iff `Phi0 = 0`** (A.1 indexed). -/
theorem phaseIII_iff_phi0_zero
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    InPhaseIII Xs p t ↔ phi0IsZero Xs p t :=
  Axioms.A1 p (Xs t)

/-- **¬ Phase I iff coverage acquired** (A.2 indexed). -/
theorem not_phaseI_iff_coverageAcquired
    {Ω : Type} (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    ¬ InPhaseI Xs p t ↔ coverageAcquired (Ω := Ω) Xs p t := by
  unfold InPhaseI coverageAcquired
  exact Axioms.A2 p (Xs t)

/-- **Phase I iff coverage NOT acquired**. -/
theorem phaseI_iff_not_coverageAcquired
    {Ω : Type} (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    InPhaseI Xs p t ↔ ¬ coverageAcquired (Ω := Ω) Xs p t := by
  rw [← not_phaseI_iff_coverageAcquired (Ω := Ω)]
  exact (Classical.not_not).symm

/-! ## (4) Phase-change set + decidability. -/

/-- **Phase-change points.** The set of indices where at least one of
    the three phase markers flips between `t` and `t+1`. -/
def phaseChangePoints (Xs : ℕ → Agent α) (p : Problem α) : Set ℕ :=
  { t | (InPhaseI Xs p t ↔ ¬ InPhaseI Xs p (t + 1))
        ∨ (InPhaseII Xs p t ↔ ¬ InPhaseII Xs p (t + 1))
        ∨ (InPhaseIII Xs p t ↔ ¬ InPhaseIII Xs p (t + 1)) }

/-- **Classical decidability of membership in `phaseChangePoints`.** -/
noncomputable instance
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    Decidable (t ∈ phaseChangePoints Xs p) :=
  Classical.dec _

/-! ## (5) Forced observable change at a phase-change point.

The key derivable structural fact: at a phase-change point, the pair
of observables `(phi0IsZero, coverageAcquired)` must differ between
`t` and `t+1`.  In other words: phases are functions of those two
observables. -/

/-- **Observable signature of a phase.** Given an index, we package
    the pair (Phi0-zero?, coverage-acquired?). -/
def obsSig {Ω : Type} (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) : Prop × Prop :=
  (phi0IsZero Xs p t, coverageAcquired (Ω := Ω) Xs p t)

/-- **Iff equivalence: phase change occurs only if the (Phi0-zero,
    coverage) signature changes.**  Contrapositive: if the signature is
    stable across `(t, t+1)`, then the phase is stable.

    Proof strategy: each phase marker is a Boolean function of the
    signature via A.1 (Phase III ↔ Phi0=0) and A.2 (Phase I ↔ ¬coverage).
    Phase II is the complement. -/
theorem phase_stable_of_obs_stable
    {Ω : Type} (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ)
    (hPhi : phi0IsZero Xs p t ↔ phi0IsZero Xs p (t + 1))
    (hCov : coverageAcquired (Ω := Ω) Xs p t
              ↔ coverageAcquired (Ω := Ω) Xs p (t + 1)) :
    (InPhaseI Xs p t ↔ InPhaseI Xs p (t + 1))
      ∧ (InPhaseII Xs p t ↔ InPhaseII Xs p (t + 1))
      ∧ (InPhaseIII Xs p t ↔ InPhaseIII Xs p (t + 1)) := by
  -- Phase III iff Phi0-zero.
  have hIII : InPhaseIII Xs p t ↔ InPhaseIII Xs p (t + 1) := by
    rw [phaseIII_iff_phi0_zero, phaseIII_iff_phi0_zero]
    exact hPhi
  -- Phase I iff ¬ coverage.
  have hI : InPhaseI Xs p t ↔ InPhaseI Xs p (t + 1) := by
    rw [phaseI_iff_not_coverageAcquired (Ω := Ω),
        phaseI_iff_not_coverageAcquired (Ω := Ω)]
    constructor
    · intro h hc; exact h (hCov.mpr hc)
    · intro h hc; exact h (hCov.mp hc)
  -- Phase II is the complement: ¬I ∧ ¬III.
  -- More precisely: Phase II ↔ 0 < N < ⊤, which is ¬ (N = ⊤) ∧ ¬ (N = 0).
  -- Using A.1, A.2 this is `coverage ∧ ¬Phi0-zero`.
  have hII : InPhaseII Xs p t ↔ InPhaseII Xs p (t + 1) := by
    constructor
    · intro ⟨hPos, hLtTop⟩
      -- N (Xs t) > 0 and < ⊤. We have ¬Phase III and ¬Phase I.
      have h_notIII_t : ¬ InPhaseIII Xs p t := by
        intro hZ; unfold InPhaseIII at hZ; rw [hZ] at hPos; exact absurd hPos (by decide)
      have h_notI_t : ¬ InPhaseI Xs p t := by
        intro hTop; unfold InPhaseI at hTop; rw [hTop] at hLtTop; exact lt_irrefl _ hLtTop
      have h_notIII_s : ¬ InPhaseIII Xs p (t + 1) := fun h => h_notIII_t (hIII.mpr h)
      have h_notI_s : ¬ InPhaseI Xs p (t + 1) := fun h => h_notI_t (hI.mpr h)
      refine ⟨?_, ?_⟩
      · -- 0 < N p (Xs (t+1)). N ≠ 0 by ¬Phase III.
        exact Ne.lt_of_le' h_notIII_s bot_le
      · exact lt_top_iff_ne_top.mpr h_notI_s
    · intro ⟨hPos, hLtTop⟩
      have h_notIII_s : ¬ InPhaseIII Xs p (t + 1) := by
        intro hZ; unfold InPhaseIII at hZ; rw [hZ] at hPos; exact absurd hPos (by decide)
      have h_notI_s : ¬ InPhaseI Xs p (t + 1) := by
        intro hTop; unfold InPhaseI at hTop; rw [hTop] at hLtTop; exact lt_irrefl _ hLtTop
      have h_notIII_t : ¬ InPhaseIII Xs p t := fun h => h_notIII_s (hIII.mp h)
      have h_notI_t : ¬ InPhaseI Xs p t := fun h => h_notI_s (hI.mp h)
      refine ⟨?_, ?_⟩
      · exact Ne.lt_of_le' h_notIII_t bot_le
      · exact lt_top_iff_ne_top.mpr h_notI_t
  exact ⟨hI, hII, hIII⟩

/-- **Forced observable change at a phase-change point.**  At any phase-
    change point `t ∈ phaseChangePoints Xs p`, at least one of the two
    observables (Phi0-zero, coverage-acquired) must change between `t`
    and `t+1`. -/
theorem obs_change_of_phase_change
    {Ω : Type} (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ)
    (h : t ∈ phaseChangePoints Xs p) :
    ¬ ((phi0IsZero Xs p t ↔ phi0IsZero Xs p (t + 1))
         ∧ (coverageAcquired (Ω := Ω) Xs p t
              ↔ coverageAcquired (Ω := Ω) Xs p (t + 1))) := by
  intro ⟨hPhi, hCov⟩
  -- The phase is stable, contradicting `h`.
  have hStable := phase_stable_of_obs_stable (Ω := Ω) Xs p t hPhi hCov
  obtain ⟨hI, hII, hIII⟩ := hStable
  unfold phaseChangePoints at h
  simp only [Set.mem_setOf_eq] at h
  rcases h with h | h | h
  · -- h : InPhaseI Xs p t ↔ ¬ InPhaseI Xs p (t+1). Combined with hI gives contradiction.
    -- From hI: InPhaseI t ↔ InPhaseI (t+1).
    -- From h:  InPhaseI t ↔ ¬ InPhaseI (t+1).
    -- So InPhaseI (t+1) ↔ ¬ InPhaseI (t+1), contradiction by classical logic.
    by_cases hP : InPhaseI Xs p (t + 1)
    · have : ¬ InPhaseI Xs p (t + 1) := h.mp (hI.mpr hP)
      exact this hP
    · have : InPhaseI Xs p (t + 1) := hI.mp (h.mpr hP)
      exact hP this
  · by_cases hP : InPhaseII Xs p (t + 1)
    · have : ¬ InPhaseII Xs p (t + 1) := h.mp (hII.mpr hP)
      exact this hP
    · have : InPhaseII Xs p (t + 1) := hII.mp (h.mpr hP)
      exact hP this
  · by_cases hP : InPhaseIII Xs p (t + 1)
    · have : ¬ InPhaseIII Xs p (t + 1) := h.mp (hIII.mpr hP)
      exact this hP
    · have : InPhaseIII Xs p (t + 1) := hIII.mp (h.mpr hP)
      exact hP this

/-! ## (6) Negative observation: `coverageAcquired` as a subset of ℕ is
    unconstrained.

The set `{ t | coverageAcquired Xs p t }` need not be upward-closed:
A.1–A.4 do NOT include a "knowledge growth" axiom `K (Xs t) ⊆ K (Xs (t+1))`,
so coverage can be acquired and then lost.  This is the dual of Agent 7's
`Agent7_DiscreteDerivative` central obstruction.  We record it as an
example of a non-derivable claim. -/

/-- **Hypothetical statement** (NOT a theorem): "coverage is upward-
    closed".  Renamed to a `Prop` to make explicit that this is a
    candidate axiom, not a derived fact. -/
def CoverageUpwardClosed {Ω : Type} (Xs : ℕ → Agent α) (p : Problem α) : Prop :=
  ∀ t, coverageAcquired (Ω := Ω) Xs p t →
        coverageAcquired (Ω := Ω) Xs p (t + 1)

/-- **Vacuous instance**: constant trajectories trivially have upward-
    closed coverage. -/
theorem coverageUpwardClosed_of_const
    {Ω : Type} (Xs : ℕ → Agent α) (X : Agent α) (p : Problem α)
    (hConst : ∀ t, Xs t = X) :
    CoverageUpwardClosed (Ω := Ω) Xs p := by
  intro t hCov
  unfold coverageAcquired at hCov ⊢
  rw [hConst (t + 1), ← hConst t]
  exact hCov

end R2_Agent5_PhaseChangePoints

end MIP
