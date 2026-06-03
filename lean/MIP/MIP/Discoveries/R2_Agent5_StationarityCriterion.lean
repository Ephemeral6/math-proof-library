/-
  STATUS: DISCOVERY
  AGENT: R2-5
  DIRECTION: Trajectory stationarity criteria — when a fixed point of `Xs`
             or a (K, Φ₀)-equality forces phase invariance.
  SUMMARY:
    Round-1 Agent 7 noted that constant trajectories give constant
    phases (`N_const_of_traj_const`).  Round 2 strengthens this in two
    directions:
      (1) **Fixed-point eventual stationarity.** If the trajectory
          becomes constant from index `t` onward (`∀ k, Xs (t+k+1) = Xs t`),
          then `N`, `Phi0`, `K`, and the three phase markers are
          constant on `[t, ∞)`.  This is a pure congruence chain.
      (2) **Single-step fixed-point.** If `Xs (t+1) = Xs t` at one
          step, then `N`, `Phi0`, `K`, and the phase agree at `t` and
          `t+1`.
    These are the cleanest derivable "stationarity criteria" that A.1
    *makes available* (via the trajectory-indexed Axioms.A1 chain).
    Compared with Agent 7's pointwise lemmas, we package the chain as
    a single eventual-constancy theorem so downstream callers don't
    re-derive it.
-/
import MIP.Axioms

namespace MIP

namespace R2_Agent5_StationarityCriterion

variable {α : Type}

/-! ## (0) Local phase markers (copies of Agent 7 definitions, since the
Discoveries directory is not part of the build target). -/

/-- **Phase I (knowledge-deficient)**: `N p (Xs t) = ⊤`. -/
def InPhaseI (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) : Prop :=
  N p (Xs t) = ⊤

/-- **Phase II (emergent)**: `0 < N p (Xs t) < ⊤`. -/
def InPhaseII (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) : Prop :=
  0 < N p (Xs t) ∧ N p (Xs t) < ⊤

/-- **Phase III (solved)**: `N p (Xs t) = 0`. -/
def InPhaseIII (Xs : ℕ → Agent α) (p : Problem α) (t : ℕ) : Prop :=
  N p (Xs t) = 0

/-- Phase preservation under agent equality (local copy of Agent 7's
    `phase_eq_of_agent_eq`). -/
theorem phase_eq_of_agent_eq
    (Xs : ℕ → Agent α) (p : Problem α) {s t : ℕ} (h : Xs s = Xs t) :
    (InPhaseI Xs p s ↔ InPhaseI Xs p t)
      ∧ (InPhaseII Xs p s ↔ InPhaseII Xs p t)
      ∧ (InPhaseIII Xs p s ↔ InPhaseIII Xs p t) := by
  unfold InPhaseI InPhaseII InPhaseIII
  rw [h]
  exact ⟨Iff.rfl, Iff.rfl, Iff.rfl⟩

/-! ## (1) Single-step fixed-point ⇒ adjacent invariants agree. -/

/-- **Single-step N invariance.** If `Xs (t+1) = Xs t`, then `N` agrees
    at the two indices. -/
theorem N_step_eq_of_fixed_step
    (Xs : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : Xs (t + 1) = Xs t) :
    N p (Xs (t + 1)) = N p (Xs t) := by
  rw [h]

/-- **Single-step Phi0 invariance.** -/
theorem Phi0_step_eq_of_fixed_step
    (Xs : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : Xs (t + 1) = Xs t) :
    Phi0 (Xs (t + 1)) p = Phi0 (Xs t) p := by
  rw [h]

/-- **Single-step K invariance.** -/
theorem K_step_eq_of_fixed_step
    {Ω : Type} (Xs : ℕ → Agent α) {t : ℕ}
    (h : Xs (t + 1) = Xs t) :
    (K (Xs (t + 1)) : Set Ω) = (K (Xs t) : Set Ω) := by
  rw [h]

/-- **Single-step phase invariance.** All three phase markers transport. -/
theorem phase_step_eq_of_fixed_step
    (Xs : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : Xs (t + 1) = Xs t) :
    (InPhaseI Xs p (t + 1) ↔ InPhaseI Xs p t)
      ∧ (InPhaseII Xs p (t + 1) ↔ InPhaseII Xs p t)
      ∧ (InPhaseIII Xs p (t + 1) ↔ InPhaseIII Xs p t) :=
  phase_eq_of_agent_eq Xs p h

/-! ## (2) Eventual-constant trajectory ⇒ constant phase forever. -/

/-- **Trajectory is eventually constant at `t`.** -/
def EventuallyConstantAt (Xs : ℕ → Agent α) (t : ℕ) : Prop :=
  ∀ k, Xs (t + k) = Xs t

/-- **Eventually-constant trajectories preserve `N`.** -/
theorem N_eventually_const
    (Xs : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : EventuallyConstantAt Xs t) (k : ℕ) :
    N p (Xs (t + k)) = N p (Xs t) := by
  rw [h k]

/-- **Eventually-constant trajectories preserve `Phi0`.** -/
theorem Phi0_eventually_const
    (Xs : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : EventuallyConstantAt Xs t) (k : ℕ) :
    Phi0 (Xs (t + k)) p = Phi0 (Xs t) p := by
  rw [h k]

/-- **Eventually-constant trajectories preserve `K`.** -/
theorem K_eventually_const
    {Ω : Type} (Xs : ℕ → Agent α) {t : ℕ}
    (h : EventuallyConstantAt Xs t) (k : ℕ) :
    (K (Xs (t + k)) : Set Ω) = (K (Xs t) : Set Ω) := by
  rw [h k]

/-- **Phase markers are constant from `t` onward** for an eventually-
    constant trajectory. -/
theorem phase_eventually_const
    (Xs : ℕ → Agent α) (p : Problem α) {t : ℕ}
    (h : EventuallyConstantAt Xs t) (k : ℕ) :
    (InPhaseI Xs p (t + k) ↔ InPhaseI Xs p t)
      ∧ (InPhaseII Xs p (t + k) ↔ InPhaseII Xs p t)
      ∧ (InPhaseIII Xs p (t + k) ↔ InPhaseIII Xs p t) :=
  phase_eq_of_agent_eq Xs p (h k)

/-! ## (3) Closed-form fixed-step ⇒ eventual constancy.

If `Xs (t+1) = Xs t` AND the dynamics is *deterministic* from `Xs t`
onward, then `Xs (t+k) = Xs t` for every `k`. But A.1–A.4 are silent
on the dynamics map `Xs n ↦ Xs (n+1)`, so we cannot derive eventual
constancy from a single-step fixed point — the next index is free.
We therefore state the criterion as: GIVEN the hypothesis that
adjacent equality propagates, eventual constancy follows. -/

/-- **From adjacent equality at every later step to eventual constancy.**
    If for every `k`, `Xs (t + k + 1) = Xs (t + k)`, then
    `Xs (t + k) = Xs t` for all `k`. -/
theorem eventuallyConst_of_all_adjacent_fixed
    (Xs : ℕ → Agent α) {t : ℕ}
    (h : ∀ k, Xs (t + k + 1) = Xs (t + k)) :
    EventuallyConstantAt Xs t := by
  intro k
  induction k with
  | zero => simp
  | succ k ih =>
      -- Xs (t + (k + 1)) = Xs (t + k + 1) = Xs (t + k) = Xs t
      have h1 : Xs (t + (k + 1)) = Xs (t + k + 1) := rfl
      rw [h1, h k, ih]

/-! ## (4) "(K, Φ₀)-stationarity" criterion.

A.1 says `N = 0 ↔ Phi0 = 0`.  A.2 says `N ≠ ⊤ ↔ ∃ R' ∈ ℛ(p), R' ⊆ K`.
Together: if Phi0 and the "is there a covered demand" predicate agree
at two indices, then N agrees at those two indices.  This is what
"stationarity in the observables Phi0 and K-coverage" buys us. -/

/-- **`N`-equality from `Phi0`-equality and coverage-equality.**
    If at indices `s` and `t` we have the same Phi0 (so by A.1 the same
    "is zero?" status) and the same coverage predicate (so by A.2 the
    same "is finite?" status), AND the two indices are either both
    Phase III, both Phase I, or both Phase II with `N p (Xs s) = N p (Xs t)`
    explicitly, then `N` agrees.

    Honest weakening: A.1 + A.2 alone do *not* let us derive a single
    number for `N` in the Phase II case; only the predicates "= 0" and
    "= ⊤" are forced.  We package what IS derivable. -/
theorem N_phase_class_eq_of_observables_eq
    {Ω : Type} (Xs : ℕ → Agent α) (p : Problem α) {s t : ℕ}
    (hPhi : Phi0 (Xs s) p = Phi0 (Xs t) p)
    (hCov : (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Xs s) : Set Ω))
              ↔ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K (Xs t) : Set Ω))) :
    (N p (Xs s) = 0 ↔ N p (Xs t) = 0)
      ∧ (N p (Xs s) = ⊤ ↔ N p (Xs t) = ⊤) := by
  refine ⟨?_, ?_⟩
  · constructor
    · intro h
      have hPs : Phi0 (Xs s) p = 0 := (Axioms.A1 p (Xs s)).mp h
      have hPt : Phi0 (Xs t) p = 0 := by rw [← hPhi]; exact hPs
      exact (Axioms.A1 p (Xs t)).mpr hPt
    · intro h
      have hPt : Phi0 (Xs t) p = 0 := (Axioms.A1 p (Xs t)).mp h
      have hPs : Phi0 (Xs s) p = 0 := by rw [hPhi]; exact hPt
      exact (Axioms.A1 p (Xs s)).mpr hPs
  · constructor
    · intro h
      -- N (Xs s) = ⊤, so by A.2 contrapositive there's no covered demand at s.
      have hNoneS : ¬ ∃ R' ∈ (demandFamily p : Set (Set Ω)),
                          R' ⊆ (K (Xs s) : Set Ω) := by
        intro hex
        have : N p (Xs s) ≠ ⊤ := (Axioms.A2 (Ω := Ω) p (Xs s)).mpr hex
        exact this h
      have hNoneT : ¬ ∃ R' ∈ (demandFamily p : Set (Set Ω)),
                          R' ⊆ (K (Xs t) : Set Ω) := by
        intro hex
        exact hNoneS (hCov.mpr hex)
      -- Therefore N (Xs t) = ⊤.
      by_contra hNT
      exact hNoneT ((Axioms.A2 (Ω := Ω) p (Xs t)).mp hNT)
    · intro h
      have hNoneT : ¬ ∃ R' ∈ (demandFamily p : Set (Set Ω)),
                          R' ⊆ (K (Xs t) : Set Ω) := by
        intro hex
        have : N p (Xs t) ≠ ⊤ := (Axioms.A2 (Ω := Ω) p (Xs t)).mpr hex
        exact this h
      have hNoneS : ¬ ∃ R' ∈ (demandFamily p : Set (Set Ω)),
                          R' ⊆ (K (Xs s) : Set Ω) := by
        intro hex
        exact hNoneT (hCov.mp hex)
      by_contra hNS
      exact hNoneS ((Axioms.A2 (Ω := Ω) p (Xs s)).mp hNS)

/-! ## (5) Negative observation. The full `N p (Xs s) = N p (Xs t)`
    derivation from `Phi0`-equality + coverage-equality is *not*
    available: in the Phase II regime the cardinal value `N` ∈ (0, ∞)
    is not pinned down by A.1 + A.2 alone.  Agent 7's
    `Agent7_DiscreteDerivative` documents the same obstruction
    asymmetrically.  We therefore state only the class-level result
    (`= 0`, `= ⊤`, both excluded) as the honest "stationarity
    criterion". -/

end R2_Agent5_StationarityCriterion

end MIP
