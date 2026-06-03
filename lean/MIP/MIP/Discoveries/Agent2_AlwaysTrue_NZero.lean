/-
  STATUS: DISCOVERY
  AGENT: 2
  DIRECTION: The always-true problem `p = fun _ => true` has N = 0 for every agent.
  SUMMARY:
    `Phi0_always_true` (in `Axioms.lean`) gives `Phi0 X (fun _ => true) = 0`
    by definition for every agent X. Combined with A.1 this forces
    `N (fun _ => true) X = 0` for every X. From there, A.2 forces coverage
    of the always-true problem's demand family by every agent. This is the
    explicit standalone statement (used inline in T18.2 but never abstracted).
    Headline: every agent solves the trivial problem in zero steps.
-/
import MIP.Axioms

namespace MIP

namespace Agent2_AlwaysTrue_NZero

variable {α : Type} {Ω : Type}

/-- **Always-true problem has emergence degree zero, for every agent.**
Combining `Phi0_always_true` with A.1.mpr. -/
theorem N_always_true_eq_zero (X : Agent α) :
    N (fun _ : Str α => true) X = 0 :=
  (Axioms.A1 _ X).mpr (Phi0_always_true X)

/-- **Always-true problem has finite emergence degree.** -/
theorem N_always_true_ne_top (X : Agent α) :
    N (fun _ : Str α => true) X ≠ ⊤ := by
  rw [N_always_true_eq_zero]; decide

/-- **Always-true problem has finite emergence degree (lt form).** -/
theorem N_always_true_lt_top (X : Agent α) :
    N (fun _ : Str α => true) X < ⊤ := by
  rw [N_always_true_eq_zero]; decide

/-- **Every agent covers the always-true problem.** By A.2 applied to the
always-true problem's finite-N fact.  Universally quantified over `X`. -/
theorem coverage_of_always_true (X : Agent α) :
    ∃ R' ∈ (demandFamily (fun _ : Str α => true) : Set (Set Ω)),
      R' ⊆ (K X : Set Ω) :=
  (Axioms.A2 (Ω := Ω) _ X).mp (N_always_true_ne_top X)

/-- **Demand family of the always-true problem is non-empty for every
agent's coverage.** Existence of *some* admissible demand covered by *some*
agent — but since `X` is universally quantifiable, the demand family is
non-empty as a set of sets (some `R'` exists in `ℛ(true)`). -/
theorem demandFamily_always_true_nonempty (X : Agent α) :
    (demandFamily (fun _ : Str α => true) : Set (Set Ω)).Nonempty := by
  obtain ⟨R', hR', _⟩ := coverage_of_always_true (Ω := Ω) X
  exact ⟨R', hR'⟩

/-- **Universal-quantifier form**: `N (fun _ => true) = 0` (as a function of X). -/
theorem N_always_true_const_zero :
    ∀ X : Agent α, N (fun _ : Str α => true) X = 0 :=
  N_always_true_eq_zero

end Agent2_AlwaysTrue_NZero

end MIP
