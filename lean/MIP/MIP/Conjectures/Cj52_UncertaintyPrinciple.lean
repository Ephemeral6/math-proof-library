/-
Conjecture Cj.52 — Is there a genuine MIP uncertainty principle?

Reference: `~/Desktop/MIP/conjectures/index.md` Cj.52 (lines ~324-361).

================================================================================
FAITHFUL NL CONJECTURE
================================================================================
The general open problem (Cj.52): does there exist an intrinsic *dual quantity*
`Q(X)` of an agent `X` such that for every solvable problem `p`

        N(p, X) · Q(X) ≥ C(p)                                            (UP)

AND a genuine TRADEOFF holds — the two factors `N` and `Q` cannot be reduced
simultaneously by any choice of `X` (training/parameterisation)?  "Reducing one
necessarily increases the other."  This is what distinguishes a real uncertainty
principle from "a product of two independent lower bounds".

The index records a SPECIFIC CC candidate for `Q`:

        N(p, X) · Var_{p∼P}[N(p, X)] ≥ f(Φ₀, |M|)                        (CC)

with the physical intuition: training `X` to lower `N` on some problems
(specialisation) must raise `N` on others (loss of generality), so
mean × variance has a joint positive lower bound.

================================================================================
FORMALIZATION CHOICES
================================================================================
We separate the two readings precisely (per the prompt's "be precise about which
you refute"):

  * `Cj52_candidate_Statement` : the SPECIFIC, UNCONDITIONAL candidate (CC) with
    `Q = Var_P[N]`. Faithful reading: there is a uniform positive bound `f > 0`
    such that *every* agent `X` satisfies `N(X) · Var_P[N(·,X)] ≥ f`. (If no
    such uniform `f > 0` exists, the candidate provides no nontrivial tradeoff
    lower bound — the inequality (CC) is vacuous.)

  * `Cj52_general_exists_Statement` : the GENERAL existence question — does SOME
    dual `Q` with a true tradeoff exist? We leave this OPEN (it is not refuted by
    the candidate's failure).

Agents are an abstract type. Each agent carries:
  * `N X > 0`              — its emergence cost on a fixed solvable problem
                            (positive: the problem is solvable but nontrivial);
  * `VarN X ≥ 0`           — `Var_P[N(·, X)]`, a genuine variance, hence `≥ 0`,
                            and `= 0` exactly when `N(·, X)` is constant over `P`
                            (a "constant-N" / perfectly uniform agent).

The mathematical heart: a constant-`N` agent has `Var_P[N] = 0` but `N > 0`, so
`N · Var_P[N] = 0`, which cannot be `≥ f` for any `f > 0`.

================================================================================
VERDICT: REFUTED  (for the specific candidate `Q = Var_P[N]`).
================================================================================
The specific unconditional candidate (CC) is refuted: a constant-`N` agent
(`Var_P[N] = 0`, `N > 0`) gives `N · Var_P[N] = 0 < f` for every `f > 0`. Such an
agent is genuinely admissible (a perfectly-calibrated/uniform solver: it spends
the same nonzero effort on every problem), so this is not a strawman — it is
exactly the regime where "no tradeoff" is possible, falsifying the claim that
`Var_P[N]` can serve as the dual quantity with a uniform positive lower bound.

The GENERAL existence question (some other `Q` with a true tradeoff) is NOT
settled here and is recorded as OPEN below.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace Cj52

variable {Agent : Type*}

/-- A faithful model of the candidate uncertainty principle. Each agent `X` has
* `N X`     : emergence cost on a fixed solvable problem, with `N X > 0`;
* `VarN X`  : `Var_P[N(·, X)]`, a genuine variance (`VarN X ≥ 0`).
The data also exhibits a `constant` agent whose `N` is constant over `P`, so
`VarN constant = 0` (zero spread), while `N constant > 0` (the problem is
solvable but costs positive effort). -/
structure Model (Agent : Type*) where
  N        : Agent → ℝ
  VarN     : Agent → ℝ
  hN_pos   : ∀ X, 0 < N X
  hVar_nn  : ∀ X, 0 ≤ VarN X
  constant : Agent
  hconst   : VarN constant = 0          -- the constant-N / uniform agent

/-- **Cj.52 — SPECIFIC candidate (CC), unconditional reading.**

`∃ f > 0, ∀ X, N(X) · Var_P[N(·,X)] ≥ f`: there is a uniform positive lower
bound on the product `N · Var_P[N]`. This is the candidate
`N · Var_P[N] ≥ f(Φ₀, |M|)` read as a genuine (positive, hence nonvacuous)
tradeoff lower bound holding for ALL agents. -/
def Cj52_candidate_Statement (M : Model Agent) : Prop :=
  ∃ f : ℝ, 0 < f ∧ ∀ X : Agent, f ≤ M.N X * M.VarN X

/-- **Cj.52 specific candidate — REFUTED.**

The constant-`N` agent has `Var_P[N] = 0` and `N > 0`, so the product is `0`,
which cannot meet any positive uniform bound `f > 0`. Hence no such `f` exists:
`Var_P[N]` fails as the dual quantity. -/
theorem Cj52_candidate_refuted (M : Model Agent) :
    ¬ Cj52_candidate_Statement M := by
  rintro ⟨f, hf_pos, hbound⟩
  -- At the constant agent: product = N · 0 = 0.
  have hprod : M.N M.constant * M.VarN M.constant = 0 := by
    rw [M.hconst, mul_zero]
  have hle : f ≤ M.N M.constant * M.VarN M.constant := hbound M.constant
  rw [hprod] at hle
  -- f ≤ 0 contradicts f > 0.
  linarith

/-- **Concrete witness model** (so the refutation is not vacuous over `Agent`).

A single-agent model on `Unit`: the unique agent is the constant-`N` agent,
`N = 1 > 0`, `Var_P[N] = 0`. -/
def constModel : Model Unit where
  N        := fun _ => 1
  VarN     := fun _ => 0
  hN_pos   := by intro _; norm_num
  hVar_nn  := by intro _; norm_num
  constant := ()
  hconst   := rfl

/-- The candidate fails on the concrete constant-`N` model. -/
theorem Cj52_candidate_refuted_concrete :
    ¬ Cj52_candidate_Statement constModel :=
  Cj52_candidate_refuted constModel

/-- **Sharp form of the witness:** the product `N · Var_P[N]` is exactly `0` for
the constant-`N` agent — it is not merely "below `f`", it is the smallest
possible nonnegative value, so the candidate's product has *no* positive lower
bound whatsoever. -/
theorem Cj52_constant_product_zero (M : Model Agent) :
    M.N M.constant * M.VarN M.constant = 0 := by
  rw [M.hconst, mul_zero]

/-! ### GENERAL existence question (Cj.52 proper) — VERDICT: OPEN

`Cj52_general_exists_Statement` below states the *general* uncertainty
principle: there EXISTS some intrinsic dual `Q : Agent → ℝ` and intrinsic
"problem complexity" bound such that `N(X) · Q(X) ≥ C` for all `X` AND a genuine
tradeoff holds (no `X` reduces both `N` and `Q`). The refutation above kills the
*specific* candidate `Q = Var_P[N]`; it says NOTHING about whether some other
`Q` works.

BLOCKED AT / MISSING (why the general question stays OPEN, no sorry-backed
theorem is asserted for it):
  1. No formalisation of "X's training resource constraint" (MDL / parameter
     budget) inside `MIP.Axioms`; the index lists this as prerequisite (i).
  2. `Var_P[N]` is not yet a D.x first-class object (prerequisite (ii)); a
     genuine tradeoff requires a *coupling* between `N` and `Q` along the
     admissible-`X` manifold, which has no current Lean scaffolding.
  3. The "genuine tradeoff" clause (cannot reduce both simultaneously) is a
     statement about the *image* of the map `X ↦ (N(X), Q(X))` avoiding the
     lower-left orthant — formalising it needs the admissible-agent space, which
     is exactly the open modelling gap. -/

/-- **Cj.52 — general existence statement (left OPEN, NOT claimed).**

We *state* it faithfully for the record; we prove neither it nor its negation.
A dual `Q` and a positive complexity bound `C` with the product lower bound
`N · Q ≥ C` for all agents, PLUS a genuine tradeoff: no agent simultaneously
strictly undercuts a fixed reference agent on both `N` and `Q`. -/
def Cj52_general_exists_Statement (M : Model Agent) : Prop :=
  ∃ (Q : Agent → ℝ) (C : ℝ), 0 < C ∧
    (∀ X : Agent, C ≤ M.N X * Q X) ∧
    (∃ X₀ : Agent, ¬ ∃ X : Agent, M.N X < M.N X₀ ∧ Q X < Q X₀)

end Cj52

end MIP
