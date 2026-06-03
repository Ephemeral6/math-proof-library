/-
  STATUS: DISCOVERY
  AGENT: 4
  DIRECTION: Explicit projection lemmas for `b_synth`, plus extended
    injectivity (in agent, problem and step simultaneously) and the
    "chain" identity linking consecutive synthetic barriers.
  SUMMARY:
    The synthetic-barrier function `b_synth X p i = ⟨⟨X,p,i⟩, ⟨X,p,i+1⟩, _, _⟩`
    has clean projection identities on `s_pre` / `s_post` that
    `Barriers.lean` only hints at. We expose them as `@[simp]` lemmas and
    prove the stronger statement: `b_synth` is jointly injective in
    `(X, p, i)` — if two synthetic barriers are equal they were built from
    the same agent, problem AND step. The headline chain identity is
    `(b_synth X p i).s_post = (b_synth X p (i+1)).s_pre`, giving B_data a
    "time-stamped progress meter" structure.
-/
import MIP.Axioms
import MIP.Defs.Barriers

namespace MIP

namespace Agent4_BSynth_Projections

variable {α : Type}

/-! ## (1) Explicit projection lemmas. -/

/-- `s_pre` of `b_synth X p i` is `⟨X, p, i⟩`. -/
@[simp] theorem b_synth_s_pre (X : Agent α) (p : Problem α) (i : ℕ) :
    (b_synth X p i).s_pre = ⟨X, p, i⟩ := rfl

/-- `s_post` of `b_synth X p i` is `⟨X, p, i+1⟩`. -/
@[simp] theorem b_synth_s_post (X : Agent α) (p : Problem α) (i : ℕ) :
    (b_synth X p i).s_post = ⟨X, p, i + 1⟩ := rfl

/-- The agent of `s_pre` of a synthetic barrier is the input agent. -/
@[simp] theorem b_synth_s_pre_agent (X : Agent α) (p : Problem α) (i : ℕ) :
    (b_synth X p i).s_pre.agent = X := rfl

/-- The problem of `s_pre` of a synthetic barrier is the input problem. -/
@[simp] theorem b_synth_s_pre_problem (X : Agent α) (p : Problem α) (i : ℕ) :
    (b_synth X p i).s_pre.problem = p := rfl

/-- The step of `s_pre` of a synthetic barrier is the input step. -/
@[simp] theorem b_synth_s_pre_step (X : Agent α) (p : Problem α) (i : ℕ) :
    (b_synth X p i).s_pre.step = i := rfl

/-- The agent of `s_post` is the input agent. -/
@[simp] theorem b_synth_s_post_agent (X : Agent α) (p : Problem α) (i : ℕ) :
    (b_synth X p i).s_post.agent = X := rfl

/-- The problem of `s_post` is the input problem. -/
@[simp] theorem b_synth_s_post_problem (X : Agent α) (p : Problem α) (i : ℕ) :
    (b_synth X p i).s_post.problem = p := rfl

/-- The step of `s_post` is the input step + 1. -/
@[simp] theorem b_synth_s_post_step (X : Agent α) (p : Problem α) (i : ℕ) :
    (b_synth X p i).s_post.step = i + 1 := rfl

/-! ## (2) Extended injectivity (agent / problem / step). -/

/-- **Joint injectivity in `(X, p, i)`.** If two synthetic barriers are
equal, then the agents, problems and step indices coincide. -/
theorem b_synth_eq_iff
    (X Y : Agent α) (p q : Problem α) (i j : ℕ) :
    b_synth X p i = b_synth Y q j ↔ X = Y ∧ p = q ∧ i = j := by
  refine ⟨?_, ?_⟩
  · intro h
    have hpre : (b_synth X p i).s_pre = (b_synth Y q j).s_pre := by rw [h]
    -- ⟨X, p, i⟩ = ⟨Y, q, j⟩ as InternalState
    have hX : (⟨X, p, i⟩ : InternalState α) = ⟨Y, q, j⟩ := hpre
    -- Use the ext lemma in reverse — extract the three component equalities.
    have hAgent : X = Y := by
      have := congrArg InternalState.agent hX
      simpa using this
    have hProblem : p = q := by
      have := congrArg InternalState.problem hX
      simpa using this
    have hStep : i = j := by
      have := congrArg InternalState.step hX
      simpa using this
    exact ⟨hAgent, hProblem, hStep⟩
  · rintro ⟨rfl, rfl, rfl⟩; rfl

/-- **Agent-distinction**: differing agents give differing synthetic
barriers. -/
theorem b_synth_ne_of_agent_ne
    {X Y : Agent α} (p : Problem α) (i j : ℕ) (h : X ≠ Y) :
    b_synth X p i ≠ b_synth Y p j := by
  intro heq
  exact h ((b_synth_eq_iff X Y p p i j).mp heq).1

/-- **Problem-distinction**: differing problems give differing synthetic
barriers. -/
theorem b_synth_ne_of_problem_ne
    (X : Agent α) {p q : Problem α} (i j : ℕ) (h : p ≠ q) :
    b_synth X p i ≠ b_synth X q j := by
  intro heq
  exact h ((b_synth_eq_iff X X p q i j).mp heq).2.1

/-! ## (3) Chain structure: `s_post` of step `i` equals `s_pre` of step `i+1`. -/

/-- **Chain identity.** Consecutive synthetic barriers share an endpoint:
`(b_synth X p i).s_post = (b_synth X p (i+1)).s_pre`. Both equal
`⟨X, p, i+1⟩`. -/
@[simp] theorem b_synth_chain (X : Agent α) (p : Problem α) (i : ℕ) :
    (b_synth X p i).s_post = (b_synth X p (i + 1)).s_pre := rfl

/-- **Difference of step indices.** The step of `s_post` minus the step of
`s_pre` is always `1`. -/
theorem b_synth_step_diff (X : Agent α) (p : Problem α) (i : ℕ) :
    (b_synth X p i).s_post.step = (b_synth X p i).s_pre.step + 1 := rfl

end Agent4_BSynth_Projections

end MIP
