/-
  STATUS: DISCOVERY
  AGENT: 7
  DIRECTION: Training-dynamics: constant / equal-index trajectories preserve N.
  SUMMARY:
    The simplest training-dynamics sanity lemmas. If a training trajectory
    `Xs : ℕ → Agent α` is constant — i.e. `Xs t = X` for some fixed agent `X`
    and all `t` — then the induced emergence sequence `t ↦ N p (Xs t)` is
    constant. If two indices `s, t` carry the same agent then they carry
    the same N. These are trivial congruence corollaries but the codebase
    has no explicit "constant trajectory" lemma — they form the entry point
    for the whole Group A / B trajectory calculus.
-/
import MIP.Axioms

namespace MIP

namespace Agent7_ConstantTrajectory

variable {α : Type}

/-! ## (1) Constant trajectory: pointwise N. -/

/-- **Constant trajectory pointwise**: if `Xs t = X` for every `t`,
    then `N p (Xs t) = N p X` for every `t`. -/
theorem N_const_of_traj_const
    (Xs : ℕ → Agent α) (X : Agent α) (p : Problem α)
    (hConst : ∀ t, Xs t = X) (t : ℕ) :
    N p (Xs t) = N p X := by
  rw [hConst t]

/-- **Constant trajectory: zero change.** Adjacent indices of a constant
    trajectory give the same `N`. -/
theorem N_step_eq_of_traj_const
    (Xs : ℕ → Agent α) (X : Agent α) (p : Problem α)
    (hConst : ∀ t, Xs t = X) (t : ℕ) :
    N p (Xs (t + 1)) = N p (Xs t) := by
  rw [hConst (t + 1), hConst t]

/-- **Constant trajectory: zero change (general index pair).** Any two
    indices of a constant trajectory give the same `N`. -/
theorem N_any_pair_eq_of_traj_const
    (Xs : ℕ → Agent α) (X : Agent α) (p : Problem α)
    (hConst : ∀ t, Xs t = X) (s t : ℕ) :
    N p (Xs s) = N p (Xs t) := by
  rw [hConst s, hConst t]

/-! ## (2) Equality preservation: equal agents at two indices give equal N. -/

/-- **Equality preservation**: if `Xs s = Xs t` (the same agent reappears
    at two indices), then `N p (Xs s) = N p (Xs t)`. Pure congruence — no
    axioms needed. -/
theorem N_eq_of_agent_eq
    (Xs : ℕ → Agent α) (p : Problem α) {s t : ℕ}
    (h : Xs s = Xs t) :
    N p (Xs s) = N p (Xs t) := by
  rw [h]

/-- **Phi0-side equality preservation.** Symmetric statement on the
    potential side. -/
theorem Phi0_eq_of_agent_eq
    (Xs : ℕ → Agent α) (p : Problem α) {s t : ℕ}
    (h : Xs s = Xs t) :
    Phi0 (Xs s) p = Phi0 (Xs t) p := by
  rw [h]

/-- **Constant-trajectory N-sequence packaged as a constant function.** -/
theorem N_seq_const_of_traj_const
    (Xs : ℕ → Agent α) (X : Agent α) (p : Problem α)
    (hConst : ∀ t, Xs t = X) :
    (fun t => N p (Xs t)) = (fun _ => N p X) := by
  funext t
  exact N_const_of_traj_const Xs X p hConst t

end Agent7_ConstantTrajectory

end MIP
