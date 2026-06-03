/-
  STATUS: OBSERVATION
  AGENT: 7
  DIRECTION: Constant-N trajectories cannot exhibit a strict three-phase transition.
  SUMMARY:
    T.30's `PhaseTransitionPrereq Xs p` asserts the strict ordering
    `t_cov < t* < t_aut` of the three crossover times. A constant
    trajectory has N(Xs t) constant in t, so either the trajectory is
    always Phase I (no t_cov ever exists in the colloquial sense),
    always Phase II, or always Phase III — none of which exhibit two
    *strict* phase boundaries. We cannot prove the negation directly
    because `crossover_times` is opaque (the values are not pinned down
    by the constancy of Xs); but we can record the CONDITIONAL OBSERVATION
    that IF the prereq holds, the three crossover times are pairwise
    distinct (necessarily so by strict ordering), which is what a
    constant trajectory cannot achieve through its own dynamics.

    We prove the *clean* derivable observation: a trajectory satisfying
    `PhaseTransitionPrereq` necessarily has three pairwise distinct
    crossover times. This is a corollary of T30 and is a structural
    necessary-condition statement for the prerequisite to be satisfiable.
-/
import MIP.Axioms
import MIP.Theorems.T30_PhaseTransition

namespace MIP

namespace Agent7_ConstantNoPhaseTransition

open MIP.PhaseTransition

variable {α : Type}

/-! ## (1) Pairwise distinctness of the three crossover times. -/

/-- **Necessary condition for `PhaseTransitionPrereq`**: the three
    crossover times are pairwise distinct. Corollary of T30's strict
    ordering. -/
theorem crossover_times_distinct
    (Xs : ℕ → Agent α) (p : Problem α)
    (h : PhaseTransitionPrereq Xs p) :
    (crossover_times Xs p).1 ≠ (crossover_times Xs p).2.1
      ∧ (crossover_times Xs p).2.1 ≠ (crossover_times Xs p).2.2
      ∧ (crossover_times Xs p).1 ≠ (crossover_times Xs p).2.2 := by
  obtain ⟨h12, h23⟩ := h
  refine ⟨ne_of_lt h12, ne_of_lt h23, ?_⟩
  exact ne_of_lt (lt_trans h12 h23)

/-- **Phase-prereq forces three different times** (set form). -/
theorem crossover_set_size_three
    (Xs : ℕ → Agent α) (p : Problem α)
    (h : PhaseTransitionPrereq Xs p) :
    ({(crossover_times Xs p).1, (crossover_times Xs p).2.1,
      (crossover_times Xs p).2.2} : Set ℝ).ncard = 3 := by
  obtain ⟨h12, h23⟩ := h
  have h13 : (crossover_times Xs p).1 < (crossover_times Xs p).2.2 :=
    lt_trans h12 h23
  have hne12 : (crossover_times Xs p).1 ≠ (crossover_times Xs p).2.1 := ne_of_lt h12
  have hne23 : (crossover_times Xs p).2.1 ≠ (crossover_times Xs p).2.2 := ne_of_lt h23
  have hne13 : (crossover_times Xs p).1 ≠ (crossover_times Xs p).2.2 := ne_of_lt h13
  rw [Set.ncard_eq_three]
  refine ⟨(crossover_times Xs p).1, (crossover_times Xs p).2.1,
    (crossover_times Xs p).2.2, hne12, hne13, hne23, ?_⟩
  rfl

/-! ## (2) Observation: PhaseTransitionPrereq forces non-degeneracy.

The book interpretation is: a constant trajectory (one that does not
evolve in t) cannot have a *temporal* phase transition. In Lean, since
`crossover_times` is opaque, we cannot directly *refute* the prereq for
a constant Xs without further axioms about `crossover_times`. What we
*can* derive is the necessary condition that the three times are
pairwise distinct, recorded above. -/

/-- **Existential form**: if `PhaseTransitionPrereq` holds, the three
    crossover times form a strictly increasing 3-tuple. -/
theorem strict_increasing_triple_of_prereq
    (Xs : ℕ → Agent α) (p : Problem α)
    (h : PhaseTransitionPrereq Xs p) :
    ∃ a b c : ℝ, a < b ∧ b < c ∧
      (crossover_times Xs p) = (a, b, c) := by
  refine ⟨(crossover_times Xs p).1, (crossover_times Xs p).2.1,
    (crossover_times Xs p).2.2, h.1, h.2, ?_⟩
  -- The triple equals itself by definition of (.1, .2.1, .2.2).
  rcases hCT : crossover_times Xs p with ⟨a, b, c⟩
  rfl

/-! ## (3) The prereq is preserved under any trajectory transformation
that fixes `crossover_times`. -/

/-- **Trivial transport**: if two trajectories give the same
    `crossover_times`, they share the prerequisite. -/
theorem prereq_transport
    (Xs Ys : ℕ → Agent α) (p : Problem α)
    (h : crossover_times Xs p = crossover_times Ys p)
    (hPrereq : PhaseTransitionPrereq Xs p) :
    PhaseTransitionPrereq Ys p := by
  unfold PhaseTransitionPrereq at *
  rw [h] at hPrereq
  exact hPrereq

end Agent7_ConstantNoPhaseTransition

end MIP
