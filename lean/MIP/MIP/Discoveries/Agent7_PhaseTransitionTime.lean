/-
  STATUS: DISCOVERY
  AGENT: 7
  DIRECTION: Phase I → II transition time as well-defined `Nat.find` (classical decidability).
  SUMMARY:
    Along a training trajectory `Xs : ℕ → Agent α`, a "Phase I → II
    transition" is the existence of `t₀` with all prior steps in Phase I
    (N = ⊤) but step `t₀` no longer in Phase I (N ≠ ⊤). We package this
    transition existence and prove that, given the trajectory is eventually
    out of Phase I (i.e. `∃ t, N p (Xs t) ≠ ⊤`), the first such step
    `firstFiniteStep` exists as a well-defined `Nat.find` over a classically
    decidable predicate. We give the witnessing properties: all earlier
    steps are in Phase I, and the witnessing step itself has finite N.
-/
import MIP.Axioms

namespace MIP

namespace Agent7_PhaseTransitionTime

variable {α : Type}

/-! ## (1) Definition of the Phase I → II transition. -/

/-- **Phase I → II transition predicate**: index `t₀` is a transition point
    if all earlier steps have `N = ⊤` and step `t₀` does not. -/
def IsPhaseITransition (Xs : ℕ → Agent α) (p : Problem α) (t₀ : ℕ) : Prop :=
  (∀ t < t₀, N p (Xs t) = ⊤) ∧ N p (Xs t₀) ≠ ⊤

/-! ## (2) Existence of the transition when N is ever finite. -/

/-- The set of "finite-N" indices, as a predicate. -/
def IsFiniteIndex (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) : Prop :=
  N p (Xs t) ≠ ⊤

noncomputable instance instDecidableIsFiniteIndex
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    Decidable (IsFiniteIndex Xs p t) :=
  Classical.dec _

/-- **First finite step** (when one exists): the least index at which
    `N p (Xs t)` becomes finite, defined classically via `Nat.find`. -/
noncomputable def firstFiniteStep
    (Xs : ℕ → Agent α) (p : Problem α)
    (h : ∃ t, N p (Xs t) ≠ ⊤) : ℕ :=
  Nat.find h

/-- **Spec of `firstFiniteStep`**: it satisfies the transition predicate. -/
theorem firstFiniteStep_isTransition
    (Xs : ℕ → Agent α) (p : Problem α)
    (h : ∃ t, N p (Xs t) ≠ ⊤) :
    IsPhaseITransition Xs p (firstFiniteStep Xs p h) := by
  unfold IsPhaseITransition firstFiniteStep
  refine ⟨?_, Nat.find_spec h⟩
  intro t htLt
  -- `t < Nat.find h` means t does not satisfy the predicate
  have hNot : ¬ (N p (Xs t) ≠ ⊤) := Nat.find_min h htLt
  exact not_ne_iff.mp hNot

/-- **Existence of a transition** when N is ever finite. -/
theorem exists_phaseI_transition
    (Xs : ℕ → Agent α) (p : Problem α)
    (h : ∃ t, N p (Xs t) ≠ ⊤) :
    ∃ t₀, IsPhaseITransition Xs p t₀ :=
  ⟨firstFiniteStep Xs p h, firstFiniteStep_isTransition Xs p h⟩

/-- **Uniqueness** of the transition point: if two indices are both
    transition points, they are equal. -/
theorem isPhaseITransition_unique
    (Xs : ℕ → Agent α) (p : Problem α)
    {t₁ t₂ : ℕ}
    (h₁ : IsPhaseITransition Xs p t₁)
    (h₂ : IsPhaseITransition Xs p t₂) :
    t₁ = t₂ := by
  obtain ⟨hPre₁, hAt₁⟩ := h₁
  obtain ⟨hPre₂, hAt₂⟩ := h₂
  -- Suppose t₁ < t₂: then t₁ < t₂ so hPre₂ says N p (Xs t₁) = ⊤, contradicting hAt₁.
  rcases lt_trichotomy t₁ t₂ with hlt | heq | hgt
  · exfalso
    exact hAt₁ (hPre₂ t₁ hlt)
  · exact heq
  · exfalso
    exact hAt₂ (hPre₁ t₂ hgt)

/-! ## (3) "Trajectory is eventually solved" detection. -/

/-- **Eventually-solved trajectory**: some index has `N = 0`. -/
def IsEventuallySolved (Xs : ℕ → Agent α) (p : Problem α) : Prop :=
  ∃ t, N p (Xs t) = 0

/-- **First solved step.** -/
noncomputable def firstSolvedStep
    (Xs : ℕ → Agent α) (p : Problem α)
    (h : IsEventuallySolved Xs p) : ℕ :=
  Nat.find h

/-- **Spec**: at `firstSolvedStep`, the trajectory has `N = 0`. -/
theorem firstSolvedStep_spec
    (Xs : ℕ → Agent α) (p : Problem α)
    (h : IsEventuallySolved Xs p) :
    N p (Xs (firstSolvedStep Xs p h)) = 0 :=
  Nat.find_spec h

/-- **Minimality**: every index strictly less than `firstSolvedStep` has
    `N ≠ 0`. -/
theorem firstSolvedStep_min
    (Xs : ℕ → Agent α) (p : Problem α)
    (h : IsEventuallySolved Xs p)
    {t : ℕ} (ht : t < firstSolvedStep Xs p h) :
    N p (Xs t) ≠ 0 :=
  Nat.find_min h ht

end Agent7_PhaseTransitionTime

end MIP
