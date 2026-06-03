/-
  STATUS: DISCOVERY
  AGENT: R2-5
  DIRECTION: Two-trajectory coupling — when matching observables across
             two trajectories force matching phase classifications.
  SUMMARY:
    Round-1 Agent 7 worked with a single trajectory.  Round 2 adds
    two-trajectory coupling lemmas.  Given `Xs, Ys : ℕ → Agent α`:
      (a) Pointwise agent equality `Xs t = Ys t` gives pointwise N,
          Phi0, K, and phase equality (pure congruence).
      (b) Pointwise (Phi0, coverage) agreement forces matching
          Phase III and Phase I classifications, hence matching Phase II.
      (c) The N-value in Phase II is NOT determined by (Phi0, coverage)
          alone — A.1 + A.2 only pin down the "= 0" and "= ⊤" cases.
          This is the trajectory analogue of Agent 8's "Φ₀-equality does
          NOT imply N-equality" cross-agent obstruction.
    We additionally prove that `firstSolvedStep` agrees across two
    trajectories that share Phi0-zero status pointwise.
-/
import MIP.Axioms

namespace MIP

namespace R2_Agent5_TrajectoryCoupling

variable {α : Type}

/-! ## (1) Pointwise-equal trajectories. -/

/-- **Pointwise-equal trajectories share `N`**. -/
theorem N_eq_of_traj_eq
    (Xs Ys : ℕ → Agent α) (p : Problem α)
    (h : ∀ t, Xs t = Ys t) (t : ℕ) :
    N p (Xs t) = N p (Ys t) := by
  rw [h t]

/-- **Pointwise-equal trajectories share `Phi0`**. -/
theorem Phi0_eq_of_traj_eq
    (Xs Ys : ℕ → Agent α) (p : Problem α)
    (h : ∀ t, Xs t = Ys t) (t : ℕ) :
    Phi0 (Xs t) p = Phi0 (Ys t) p := by
  rw [h t]

/-- **Pointwise-equal trajectories share `K`**. -/
theorem K_eq_of_traj_eq
    {Ω : Type} (Xs Ys : ℕ → Agent α)
    (h : ∀ t, Xs t = Ys t) (t : ℕ) :
    (K (Xs t) : Set Ω) = (K (Ys t) : Set Ω) := by
  rw [h t]

/-! ## (2) Observable-coupled trajectories: matching (Phi0-zero, coverage)
gives matching "is in Phase III?" and "is in Phase I?" classifications. -/

/-- **Matching Phi0-zero status at index `t`** ⇒ matching `N = 0` status. -/
theorem N_zero_iff_of_phi0_match
    (Xs Ys : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : Phi0 (Xs t) p = 0 ↔ Phi0 (Ys t) p = 0) :
    N p (Xs t) = 0 ↔ N p (Ys t) = 0 := by
  rw [Axioms.A1 p (Xs t), Axioms.A1 p (Ys t)]
  exact h

/-- **Matching coverage-acquired status at index `t`** ⇒ matching `N ≠ ⊤`
    status. -/
theorem N_finite_iff_of_coverage_match
    {Ω : Type} (Xs Ys : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Xs t) : Set Ω))
            ↔ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Ys t) : Set Ω))) :
    N p (Xs t) ≠ ⊤ ↔ N p (Ys t) ≠ ⊤ := by
  rw [Axioms.A2 (Ω := Ω) p (Xs t), Axioms.A2 (Ω := Ω) p (Ys t)]
  exact h

/-- **Coupling: matching observables ⇒ matching `N = ⊤` (Phase I).** -/
theorem N_top_iff_of_coverage_match
    {Ω : Type} (Xs Ys : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Xs t) : Set Ω))
            ↔ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Ys t) : Set Ω))) :
    N p (Xs t) = ⊤ ↔ N p (Ys t) = ⊤ := by
  constructor
  · intro hT
    by_contra hT'
    have : N p (Xs t) ≠ ⊤ := (N_finite_iff_of_coverage_match (Ω := Ω) Xs Ys p h).mpr hT'
    exact this hT
  · intro hT
    by_contra hT'
    have : N p (Ys t) ≠ ⊤ := (N_finite_iff_of_coverage_match (Ω := Ω) Xs Ys p h).mp hT'
    exact this hT

/-! ## (3) Coupled trajectory-wide statement. -/

/-- **Trajectory-wide coupling**: if `Phi0`-zero status agrees pointwise,
    then `firstSolvedStep`-style sets agree. -/
theorem solvedSet_eq_of_phi0_pointwise_match
    (Xs Ys : ℕ → Agent α) (p : Problem α)
    (h : ∀ t, Phi0 (Xs t) p = 0 ↔ Phi0 (Ys t) p = 0) :
    { t | N p (Xs t) = 0 } = { t | N p (Ys t) = 0 } := by
  ext t
  exact N_zero_iff_of_phi0_match Xs Ys p (h t)

/-- **Trajectory-wide coupling**: matching coverage pointwise ⇒
    matching Phase-I-index sets. -/
theorem phaseI_set_eq_of_coverage_pointwise_match
    {Ω : Type} (Xs Ys : ℕ → Agent α) (p : Problem α)
    (h : ∀ t, (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Xs t) : Set Ω))
                ↔ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Ys t) : Set Ω))) :
    { t | N p (Xs t) = ⊤ } = { t | N p (Ys t) = ⊤ } := by
  ext t
  exact N_top_iff_of_coverage_match (Ω := Ω) Xs Ys p (h t)

/-! ## (4) `Nat.find`-level coupling of `firstSolvedStep`.

If both trajectories are eventually-solved AND their solved-index sets
agree as subsets of ℕ, then their `firstSolvedStep`s are equal. -/

noncomputable instance instDecidableSolvedX
    (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) :
    Decidable (N p (Xs t) = 0) := Classical.dec _

/-- **`firstSolvedStep` agrees across coupled trajectories**.  If
    `Phi0`-zero status matches pointwise, the first solved step is the
    same for both trajectories. -/
theorem firstSolvedStep_eq_of_phi0_match
    (Xs Ys : ℕ → Agent α) (p : Problem α)
    (h : ∀ t, Phi0 (Xs t) p = 0 ↔ Phi0 (Ys t) p = 0)
    (hX : ∃ t, N p (Xs t) = 0)
    (hY : ∃ t, N p (Ys t) = 0) :
    Nat.find hX = Nat.find hY := by
  -- Both are the least t in the same set { t | N p (·s t) = 0 } = { t | Phi0 (·s t) p = 0 }.
  have hPair : ∀ t, N p (Xs t) = 0 ↔ N p (Ys t) = 0 :=
    fun t => N_zero_iff_of_phi0_match Xs Ys p (h t)
  -- Lift to find-equality via antisymmetry.
  apply Nat.le_antisymm
  · apply Nat.find_le
    exact (hPair _).mpr (Nat.find_spec hY)
  · apply Nat.find_le
    exact (hPair _).mp (Nat.find_spec hX)

/-! ## (5) Negative observation: the Phase II value is NOT determined
by observables.

Even if `Phi0 (Xs t) p = Phi0 (Ys t) p` AND coverage agrees, A.1+A.2 do
not let us conclude `N p (Xs t) = N p (Ys t)` in the Phase II regime
where `0 < N < ⊤`.  This mirrors Agent 8's "Φ₀-equality does NOT imply
N-equality" cross-agent obstruction at the trajectory level. -/

/-- **Hypothetical "trajectory N-determinacy" claim** (not a theorem):
    matching `Phi0` and coverage forces matching N.  Stated as a Prop
    candidate; not derivable from A.1–A.4 in the Phase II case. -/
def NDeterminedByObs {Ω : Type} (p : Problem α)
    (Xs Ys : ℕ → Agent α) : Prop :=
  ∀ t, Phi0 (Xs t) p = Phi0 (Ys t) p →
       ((∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Xs t) : Set Ω))
          ↔ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Ys t) : Set Ω))) →
       N p (Xs t) = N p (Ys t)

/-- **Vacuous instance**: if `Xs = Ys` pointwise the determinacy claim
    holds trivially (just pointwise N-equality). -/
theorem NDeterminedByObs_of_traj_eq
    {Ω : Type} (p : Problem α) (Xs Ys : ℕ → Agent α)
    (h : ∀ t, Xs t = Ys t) :
    NDeterminedByObs (Ω := Ω) p Xs Ys := by
  intro t _ _
  exact N_eq_of_traj_eq Xs Ys p h t

end R2_Agent5_TrajectoryCoupling

end MIP
