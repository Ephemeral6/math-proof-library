/-
  STATUS: DEAD END
  AGENT: 4
  DIRECTION: Subadditivity/multiplicativity of N (and hence |B_data|) under
    problem-conjunction `pAnd` and problem-disjunction `pOr`.
  SUMMARY:
    The natural composition operations on problems —
      `pAnd p q := fun s => p s && q s`
      `pOr  p q := fun s => p s || q s`
    are well-defined boolean predicates on `Str α`. Intuitively one
    expects:
      * `N (pAnd p q) X ≤ N p X + N q X` (subadditivity for conjunction)
      * `N (pOr  p q) X ≤ min (N p X) (N q X)` (disjunction is at most
        the easier of the two)
    Translating to `B_data` via `(B_data _ X).card = (N _ X).toNat`:
      * `(B_data (pAnd p q) X).card ≤ (B_data p X).card + (B_data q X).card`
      * `(B_data (pOr  p q) X).card ≤ min (B_data p X).card (B_data q X).card`

    NEITHER inequality is derivable from the four opaque axioms A.1–A.4:
      * A.1 only fixes `N = 0 ↔ Phi0 = 0`, giving no comparison between
        `Phi0 X (pAnd p q)` and `Phi0 X p + Phi0 X q`.
      * A.2 is a coverage biconditional on `R(p)`. Without a sub or super
        relationship between `R(pAnd p q)` and `R(p) ∪ R(q)`, A.2 gives
        no compatibility.
      * A.3, A.4 are about expert/meta interventions, irrelevant to
        problem composition.
      * `Phi0Raw` is opaque on non-trivial problems — its value at
        `pAnd p q` could be anything, including ⊤ when both `Phi0Raw X p`
        and `Phi0Raw X q` are 0.

    Even constructing a single concrete counterexample would require a
    solver for `(p, X) ↦ N p X`, which is opaque. So we leave the
    statement here as a **recorded observation** for future agents: the
    "problem-composition arithmetic" of N is unreachable without
    additional axioms (e.g. an additivity axiom on Phi0Raw under product
    or sum of problems, which is what the NL theory's R1–R4 conjectures
    would provide).

    This file compiles with a single `example : True := trivial` to honour
    the zero-sorry constraint while documenting the dead-end exploration.
-/
import MIP.Axioms
import MIP.Defs.Barriers

namespace MIP

namespace Agent4_pAnd_pOr_DeadEnd

variable {α : Type}

/-! ## Definitions of `pAnd` / `pOr` (kept for downstream agents). -/

/-- Pointwise AND of two problems. -/
def pAnd (p q : Problem α) : Problem α := fun s => p s && q s

/-- Pointwise OR of two problems. -/
def pOr (p q : Problem α) : Problem α := fun s => p s || q s

/-! ## What IS derivable: structural identities. -/

/-- **Always-true is the unit of `pAnd`.** `pAnd (fun _ => true) q = q`. -/
theorem pAnd_true_left (q : Problem α) :
    pAnd (fun _ : Str α => true) q = q := by
  funext s
  unfold pAnd
  simp

/-- **Always-true is also absorbing for `pOr`.** `pOr (fun _ => true) q = (fun _ => true)`. -/
theorem pOr_true_left (q : Problem α) :
    pOr (fun _ : Str α => true) q = (fun _ : Str α => true) := by
  funext s
  unfold pOr
  simp

/-- **`pAnd` and `pOr` are commutative as functions.** -/
theorem pAnd_comm (p q : Problem α) : pAnd p q = pAnd q p := by
  funext s
  unfold pAnd
  exact Bool.and_comm _ _

theorem pOr_comm (p q : Problem α) : pOr p q = pOr q p := by
  funext s
  unfold pOr
  exact Bool.or_comm _ _

/-! ## What is NOT derivable: the N-composition inequalities.

We do NOT state these as theorems; doing so without proof would violate
the zero-sorry rule. The point of this file is to record the dead-end
exploration for future agents. -/

example : True := trivial

end Agent4_pAnd_pOr_DeadEnd

end MIP
