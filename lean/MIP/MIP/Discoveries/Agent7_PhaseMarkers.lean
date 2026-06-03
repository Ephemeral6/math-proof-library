/-
  STATUS: DISCOVERY
  AGENT: 7
  DIRECTION: Three phase markers from N — Phase I/II/III partition along a trajectory.
  SUMMARY:
    Along a training trajectory `Xs : ℕ → Agent α`, the value `N p (Xs t)`
    classifies each time step into exactly one of three phases:
      Phase I  (knowledge-deficient): `N p (Xs t) = ⊤`,
      Phase II (emergent):            `0 < N p (Xs t) < ⊤`,
      Phase III (solved):             `N p (Xs t) = 0`.
    We prove these three are pairwise disjoint and exhaustive (a value-level
    trichotomy on ℕ∞, restricted to N(Xs t)), and we package the membership
    as a `Decidable` (classically) phase indicator. This is the trajectory-
    level reformulation of Agent 2's `N_trichotomy`.
-/
import MIP.Axioms

namespace MIP

namespace Agent7_PhaseMarkers

variable {α : Type}

/-! ## (1) The three phases as predicates on a single index. -/

/-- **Phase I (knowledge-deficient)**: `N p (Xs t) = ⊤`. -/
def InPhaseI (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) : Prop :=
  N p (Xs t) = ⊤

/-- **Phase II (emergent)**: `0 < N p (Xs t) < ⊤`. -/
def InPhaseII (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) : Prop :=
  0 < N p (Xs t) ∧ N p (Xs t) < ⊤

/-- **Phase III (solved)**: `N p (Xs t) = 0`. -/
def InPhaseIII (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) : Prop :=
  N p (Xs t) = 0

/-! ## (2) Exhaustiveness: every index is in exactly one phase. -/

/-- **Exhaustiveness**: every index `t` is in at least one phase. -/
theorem phases_exhaustive (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    InPhaseI Xs p t ∨ InPhaseII Xs p t ∨ InPhaseIII Xs p t := by
  unfold InPhaseI InPhaseII InPhaseIII
  by_cases hTop : N p (Xs t) = ⊤
  · exact Or.inl hTop
  · by_cases hZero : N p (Xs t) = 0
    · exact Or.inr (Or.inr hZero)
    · refine Or.inr (Or.inl ⟨?_, ?_⟩)
      · exact Ne.lt_of_le' hZero bot_le
      · exact lt_top_iff_ne_top.mpr hTop

/-! ## (3) Pairwise disjointness. -/

/-- **Phase I and Phase II are disjoint**. -/
theorem phaseI_phaseII_disjoint
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    ¬ (InPhaseI Xs p t ∧ InPhaseII Xs p t) := by
  rintro ⟨h1, _, h2⟩
  rw [h1] at h2
  exact lt_irrefl _ h2

/-- **Phase I and Phase III are disjoint**. -/
theorem phaseI_phaseIII_disjoint
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    ¬ (InPhaseI Xs p t ∧ InPhaseIII Xs p t) := by
  rintro ⟨h1, h3⟩
  unfold InPhaseI at h1
  unfold InPhaseIII at h3
  rw [h1] at h3
  exact ENat.top_ne_zero h3

/-- **Phase II and Phase III are disjoint**. -/
theorem phaseII_phaseIII_disjoint
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    ¬ (InPhaseII Xs p t ∧ InPhaseIII Xs p t) := by
  rintro ⟨⟨hPos, _⟩, h3⟩
  unfold InPhaseIII at h3
  rw [h3] at hPos
  exact absurd hPos (by decide)

/-! ## (4) Phase trichotomy: exactly one of three. -/

/-- **Phase trichotomy**: every index is in exactly one of Phase I/II/III. -/
theorem phase_trichotomy (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    (InPhaseI Xs p t ∧ ¬ InPhaseII Xs p t ∧ ¬ InPhaseIII Xs p t)
      ∨ (¬ InPhaseI Xs p t ∧ InPhaseII Xs p t ∧ ¬ InPhaseIII Xs p t)
      ∨ (¬ InPhaseI Xs p t ∧ ¬ InPhaseII Xs p t ∧ InPhaseIII Xs p t) := by
  rcases phases_exhaustive Xs p t with h1 | h2 | h3
  · refine Or.inl ⟨h1, ?_, ?_⟩
    · intro h2; exact phaseI_phaseII_disjoint Xs p t ⟨h1, h2⟩
    · intro h3; exact phaseI_phaseIII_disjoint Xs p t ⟨h1, h3⟩
  · refine Or.inr (Or.inl ⟨?_, h2, ?_⟩)
    · intro h1; exact phaseI_phaseII_disjoint Xs p t ⟨h1, h2⟩
    · intro h3; exact phaseII_phaseIII_disjoint Xs p t ⟨h2, h3⟩
  · refine Or.inr (Or.inr ⟨?_, ?_, h3⟩)
    · intro h1; exact phaseI_phaseIII_disjoint Xs p t ⟨h1, h3⟩
    · intro h2; exact phaseII_phaseIII_disjoint Xs p t ⟨h2, h3⟩

/-! ## (5) Phase indicator: classical decidability. -/

/-- **Classical decidability of `InPhaseI`.** Used downstream for `Nat.find`. -/
noncomputable instance instDecidableInPhaseI
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    Decidable (InPhaseI Xs p t) :=
  Classical.dec _

/-- **Classical decidability of `InPhaseII`.** -/
noncomputable instance instDecidableInPhaseII
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    Decidable (InPhaseII Xs p t) :=
  Classical.dec _

/-- **Classical decidability of `InPhaseIII`.** -/
noncomputable instance instDecidableInPhaseIII
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    Decidable (InPhaseIII Xs p t) :=
  Classical.dec _

/-! ## (6) Phase preservation across equal agents. -/

/-- **Phase preservation under cycle.** If `Xs s = Xs t`, then both indices
    are in the same phase. -/
theorem phase_eq_of_agent_eq
    (Xs : ℕ → Agent α) (p : Problem α) {s t : ℕ} (h : Xs s = Xs t) :
    (InPhaseI Xs p s ↔ InPhaseI Xs p t)
      ∧ (InPhaseII Xs p s ↔ InPhaseII Xs p t)
      ∧ (InPhaseIII Xs p s ↔ InPhaseIII Xs p t) := by
  unfold InPhaseI InPhaseII InPhaseIII
  rw [h]
  exact ⟨Iff.rfl, Iff.rfl, Iff.rfl⟩

end Agent7_PhaseMarkers

end MIP
