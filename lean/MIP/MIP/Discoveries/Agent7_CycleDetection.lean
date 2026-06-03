/-
  STATUS: DISCOVERY
  AGENT: 7
  DIRECTION: Training-dynamics: cycles and eventual periodicity in trajectories.
  SUMMARY:
    A "cycle" in training is a pair of distinct indices `s ≠ t` with
    `Xs s = Xs t`. Trivially `N p (Xs s) = N p (Xs t)` at any such pair.
    The stronger eventual-periodicity theorem: if `∃ T₀ T > 0, ∀ t ≥ T₀,
    Xs (t + T) = Xs t`, then the N-sequence `t ↦ N p (Xs t)` is itself
    eventually periodic with the same period. Both results are pure
    congruence corollaries, but the codebase has no explicit "cycle"
    lemma, and the periodicity statement is a useful structural fact.
-/
import MIP.Axioms

namespace MIP

namespace Agent7_CycleDetection

variable {α : Type}

/-! ## (1) Simple cycle: equal agents at distinct indices give equal N. -/

/-- **Cycle preserves N.** If `Xs s = Xs t` for some pair of indices,
    then `N p (Xs s) = N p (Xs t)`. The "s ≠ t" is not even needed —
    pure congruence. -/
theorem N_eq_of_cycle
    (Xs : ℕ → Agent α) (p : Problem α) {s t : ℕ}
    (h : Xs s = Xs t) :
    N p (Xs s) = N p (Xs t) := by
  rw [h]

/-- **Existential cycle.** If there exist `s < t` with `Xs s = Xs t`,
    then there exist indices with equal N. -/
theorem exists_cycle_of_existential
    (Xs : ℕ → Agent α) (p : Problem α)
    (h : ∃ s t, s < t ∧ Xs s = Xs t) :
    ∃ s t, s < t ∧ N p (Xs s) = N p (Xs t) := by
  obtain ⟨s, t, hLt, hEq⟩ := h
  exact ⟨s, t, hLt, N_eq_of_cycle Xs p hEq⟩

/-! ## (2) Eventual periodicity: if Xs is eventually periodic, N is too. -/

/-- **Eventually-periodic trajectory propagates to eventually-periodic
    N-sequence.** If for every `t ≥ T₀` the trajectory satisfies
    `Xs (t + T) = Xs t`, then the same holds for `N p (Xs ·)`. -/
theorem N_eventually_periodic_of_traj_eventually_periodic
    (Xs : ℕ → Agent α) (p : Problem α) (T₀ T : ℕ)
    (hPer : ∀ t ≥ T₀, Xs (t + T) = Xs t) :
    ∀ t ≥ T₀, N p (Xs (t + T)) = N p (Xs t) := by
  intro t ht
  rw [hPer t ht]

/-- **Purely periodic trajectory.** Special case `T₀ = 0`. -/
theorem N_periodic_of_traj_periodic
    (Xs : ℕ → Agent α) (p : Problem α) (T : ℕ)
    (hPer : ∀ t, Xs (t + T) = Xs t) :
    ∀ t, N p (Xs (t + T)) = N p (Xs t) := by
  intro t
  rw [hPer t]

/-- **Period equality across iterations.** If `Xs (t + T) = Xs t` for
    all `t`, then `Xs (t + k * T) = Xs t` for every `k`. -/
theorem traj_periodic_iterate
    (Xs : ℕ → Agent α) (T : ℕ) (hPer : ∀ t, Xs (t + T) = Xs t)
    (t k : ℕ) :
    Xs (t + k * T) = Xs t := by
  induction k with
  | zero => simp
  | succ n ih =>
      have : t + (n + 1) * T = (t + n * T) + T := by ring
      rw [this, hPer (t + n * T), ih]

/-- **N is periodic across iterations.** Combining `traj_periodic_iterate`
    with congruence. -/
theorem N_periodic_iterate
    (Xs : ℕ → Agent α) (p : Problem α) (T : ℕ)
    (hPer : ∀ t, Xs (t + T) = Xs t) (t k : ℕ) :
    N p (Xs (t + k * T)) = N p (Xs t) := by
  rw [traj_periodic_iterate Xs T hPer t k]

end Agent7_CycleDetection

end MIP
