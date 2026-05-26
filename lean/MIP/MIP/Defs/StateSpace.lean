/-
Mathematical Principles of Intelligence (MIP) — Emergence Mechanics
Reasoning state space layer (D.2.1–D.2.4) — concrete model.

References:
* D.2.1 — Reasoning state space `S`, initial state `s₀(p, X)`
* D.2.2 — Reachable set `Reach(s)`
* D.2.3 — Solution state set `S_p*`
* D.2.4 — Intervention operator `T_m : S → S`

**Concrete model.**  By T.7 uniqueness, any model satisfying A.1–A.4
gives the same `N`.  This file picks the simplest such model so that
all state-space axioms become Lean theorems (zero `axiom`s introduced
in this file or its consumers).

The model:

* `InternalState α := { agent : Agent α, problem : Problem α, step : ℕ }`
  — a state encodes the (agent, problem) context plus the number of
  interventions applied so far.

* `s₀ X p := ⟨X, p, 0⟩`  — initial state at step 0.

* `T_m m s := { s with step := s.step + 1 }`  — every intervention
  advances the step counter by 1; agent/problem context is preserved.

* `IsSuccess p s := (s.problem = p ∧ (s.step : ℕ∞) ≥ N s.problem s.agent)`
  — success iff we have applied at least `N` interventions on the
  matching problem.

* `Reachable s s' := s = s'`  — the equality relation.  Reflexive and
  transitive by definition; makes barriers `(s, s')` with `s ≠ s'`
  honestly "not spontaneous".
-/
import MIP.Axioms

namespace MIP

/-! ## D.2.1 — Reasoning state space -/

/-- D.2.1 — `S = InternalState α`.  Concrete model: `(agent, problem, step)`. -/
@[ext] structure InternalState (α : Type) where
  agent : Agent α
  problem : Problem α
  step : ℕ

/-- D.2.1 — Initial state `s₀(X, p) = ⟨X, p, 0⟩`. -/
def s₀ {α : Type} (X : Agent α) (p : Problem α) : InternalState α :=
  ⟨X, p, 0⟩

@[simp] lemma s₀_agent {α : Type} (X : Agent α) (p : Problem α) :
    (s₀ X p).agent = X := rfl

@[simp] lemma s₀_problem {α : Type} (X : Agent α) (p : Problem α) :
    (s₀ X p).problem = p := rfl

@[simp] lemma s₀_step {α : Type} (X : Agent α) (p : Problem α) :
    (s₀ X p).step = 0 := rfl

/-! ## D.2.2 — Reachable set -/

/-- D.2.2 — `Reachable s s' := s = s'`.  The trivial reachability
relation.  Concretely: only `s` itself is reachable from `s`. -/
def Reachable {α : Type} (s s' : InternalState α) : Prop := s = s'

/-- D.2.2 — Reflexivity of `Reachable`. -/
theorem Reachable_refl {α : Type} (s : InternalState α) : Reachable s s := rfl

/-- D.2.2 — Transitivity of `Reachable`. -/
theorem Reachable_trans {α : Type} {s₁ s₂ s₃ : InternalState α} :
    Reachable s₁ s₂ → Reachable s₂ s₃ → Reachable s₁ s₃ := Eq.trans

/-! ## D.2.3 — Solution state set -/

/-- D.2.3 — `s ∈ S_p*` iff `s.problem = p` and we have already spent
at least `N p X` interventions (so by D.1.6 a success protocol exists). -/
def IsSuccess {α : Type} (p : Problem α) (s : InternalState α) : Prop :=
  s.problem = p ∧ (s.step : ℕ∞) ≥ N s.problem s.agent

/-! ## D.2.4 — Intervention operator -/

/-- D.2.4 — `T_m m s` advances the step counter by one. -/
def T_m {α : Type} (_m : Str α) (s : InternalState α) : InternalState α :=
  { s with step := s.step + 1 }

@[simp] lemma T_m_agent {α : Type} (m : Str α) (s : InternalState α) :
    (T_m m s).agent = s.agent := rfl

@[simp] lemma T_m_problem {α : Type} (m : Str α) (s : InternalState α) :
    (T_m m s).problem = s.problem := rfl

@[simp] lemma T_m_step {α : Type} (m : Str α) (s : InternalState α) :
    (T_m m s).step = s.step + 1 := rfl

end MIP
