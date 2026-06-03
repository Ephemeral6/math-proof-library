/-
  STATUS: DISCOVERY
  AGENT: 1
  DIRECTION: A.1 ∧ A.2 (specialised + A.4 corollary chain) — the
             always-true problem's coverage is unconditional.
  SUMMARY:
    The always-true problem `p_T := fun _ => true` is the unique
    canonical example where A.1's "Phi0 = 0" direction is automatically
    discharged (`Phi0_always_true`).  Combining A.1 + A.2 at this
    problem gives an unconditional coverage statement for *every* agent:

        ∀ X, ∃ R' ∈ ℛ(p_T), R' ⊆ K X    (A.1 + A.2)

    This is a clean, pairwise A.1+A.2 statement that depends on no
    user-supplied coverage hypothesis.  As a corollary chain we add the
    A.4 layer:

      For any out-of-K(X) token list, the always-true problem is still
      coverage-witnessed (vacuously preserved through A.4 transformations
      since coverage is a property of K X, not of history).

    Plus a *contrapositive* A.4 form: any agent X' obtained from X by
    "deleting" out-of-K knowledge tokens still has *exactly* the same
    A.2 coverage verdict (since coverage is a function of K X alone) —
    making A.4 transformations A.2-invariant.

    None of these are in Corollaries/* or Results/*.  The trivial-problem
    coverage statement is a derivation that doesn't appear in the NL
    manuscript either.
-/
import MIP.Axioms

namespace MIP

namespace Agent1_A1A2A4_TrivialProblemCoverage

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-- The canonical trivial problem (always-true predicate). -/
def trivialProblem : Problem α := fun _ => true

/-! ## A.1+A.2 — trivial-problem unconditional coverage. -/

/-- **Trivial-problem `N = 0`.**  Direct from A.1 applied to
`Phi0_always_true`. -/
theorem trivial_problem_N_zero (X : Agent α) :
    N (trivialProblem : Problem α) X = 0 := by
  exact (Axioms.A1 (trivialProblem : Problem α) X).mpr (Phi0_always_true X)

/-- **Trivial-problem `N ≠ ⊤`.**  Immediate corollary. -/
theorem trivial_problem_N_ne_top (X : Agent α) :
    N (trivialProblem : Problem α) X ≠ ⊤ := by
  rw [trivial_problem_N_zero]
  decide

/-- **A.1+A.2 — Unconditional coverage of the trivial problem.**

For every agent `X`, the trivial problem `p_T` has *some* admissible
demand `R' ∈ ℛ(p_T)` covered by `K X`.  This is the cleanest pairwise
A.1+A.2 statement that requires no user input: A.1 forces `N = 0` (so
`≠ ⊤`), and A.2 then exhibits the coverage witness. -/
theorem trivial_problem_has_coverage (X : Agent α) :
    ∃ R' ∈ (demandFamily (trivialProblem : Problem α) : Set (Set Ω)),
      R' ⊆ (K X : Set Ω) :=
  (Axioms.A2 (Ω := Ω) (trivialProblem : Problem α) X).mp
    (trivial_problem_N_ne_top X)

/-! ## A.4 layer: coverage verdict is A.4-invariant in `K`-equality form. -/

/-- **A.2 verdict invariant under same-`K` agents.**

If two agents `X, X'` have the same knowledge set (`K X = K X'`), they
have the same A.2 coverage verdict on every problem.  This is the
"coverage is a function of K alone" statement.  A.4's role: any
behavioural equivalence between X and X' that preserves K is also
A.2-preserving. -/
theorem A2_verdict_invariant_under_K_eq
    (p : Problem α) (X X' : Agent α)
    (hK : (K X : Set Ω) = (K X' : Set Ω)) :
    (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
      ↔ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X' : Set Ω)) := by
  rw [hK]

/-- **A.2+A.4 — Finiteness verdict invariant under same-`K` agents.**

If `K X = K X'`, then `N p X ≠ ⊤ ↔ N p X' ≠ ⊤`.  The A.2 biconditional
applied twice. -/
theorem N_ne_top_invariant_under_K_eq
    (p : Problem α) (X X' : Agent α)
    (hK : (K X : Set Ω) = (K X' : Set Ω)) :
    N p X ≠ ⊤ ↔ N p X' ≠ ⊤ := by
  rw [Axioms.A2 (Ω := Ω) p X, Axioms.A2 (Ω := Ω) p X', hK]

/-! ## A.1+A.2+A.4 — Combined trivial-problem statement.

The full triple-axiom combination collapses gracefully: the trivial
problem's A.2 verdict is unconditional, hence trivially invariant under
any A.4-equivalent (same-K) agent. -/

/-- **A.1+A.2+A.4 — Trivial problem's coverage transfers between K-equal agents.**

Trivially, since trivial-problem coverage is unconditional. -/
theorem trivial_problem_coverage_transfers
    (X X' : Agent α) (_hK : (K X : Set Ω) = (K X' : Set Ω)) :
    (∃ R' ∈ (demandFamily (trivialProblem : Problem α) : Set (Set Ω)),
      R' ⊆ (K X : Set Ω)) ∧
    (∃ R' ∈ (demandFamily (trivialProblem : Problem α) : Set (Set Ω)),
      R' ⊆ (K X' : Set Ω)) :=
  ⟨trivial_problem_has_coverage X, trivial_problem_has_coverage X'⟩

/-! ## Negative-side A.1+A.2: trivial problem has Phi0 = 0 *despite* possibly large N for other problems. -/

/-- **Trivial-problem doesn't constrain other problems' Phi0.**

We record the obvious-but-worth-naming separation: `Phi0 X (trivialProblem) = 0`
for all `X`, but this gives *no* information about `Phi0 X p` for general
`p`.  In particular, an agent `X` with `K X = ∅` still has `Phi0 X
trivialProblem = 0`, but `Phi0 X p` may well be `⊤` for some `p`. -/
theorem trivial_problem_Phi0_unconditional (X : Agent α) :
    Phi0 X (trivialProblem : Problem α) = 0 := Phi0_always_true X

/-- **A.1+A.2 — Trivial-problem demand-family is nonempty.**

By A.2 (sufficient direction's contrapositive failing): if `ℛ(p_T) = ∅`
then no A.2 coverage witness exists, so by A.2 `N p_T X = ⊤` — but
`N p_T X = 0` by A.1.  Contradiction.  So `ℛ(p_T)` is nonempty for
every agent's reference. -/
theorem trivial_problem_demand_family_nonempty (X : Agent α) :
    (demandFamily (trivialProblem : Problem α) : Set (Set Ω)).Nonempty := by
  obtain ⟨R', hMem, _⟩ := trivial_problem_has_coverage (Ω := Ω) X
  exact ⟨R', hMem⟩

end Agent1_A1A2A4_TrivialProblemCoverage

end MIP
