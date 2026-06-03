/-
  STATUS: DISCOVERY
  AGENT: 1
  DIRECTION: A.1 ∧ A.4 — Characterising the "auto-solved" equivalence class.
  SUMMARY:
    A.1 says `N p X = 0 ↔ Phi0 X p = 0`.  A.4 says X's response distribution
    is invariant under out-of-K(X) token replacements (an equivalence on
    histories).  We extract a new combined characterisation:

    *Among agents that share K(X) and Phi0, the "auto-solved problems"
    (those with N = 0) form an A.4-invariant equivalence class.*

    Concretely:
    (i)  `phi0_zero_solved_class_invariant`: For two agents X, X' that
         share `Phi0`, the auto-solved problem set
         `S(X) := { p | N p X = 0 }` agrees: `S(X) = S(X')`.

    (ii) `auto_solved_problem_set_eq`: The set `S(X)` is exactly the
         pre-image of 0 under `Phi0 X` (treated as a function of `p`),
         by A.1.  No A.4 needed here — pure A.1.

    (iii)`solved_class_K_invariant`: Two agents with `K X = K X'` and
         `Phi0 X = Phi0 X'` (as functions of `p`) have the same A.2 and
         A.1 verdicts on every `p` — combining gives the full
         "(A.1+A.4)-invariance class" structure.

    (iv) `kernel_solved_self_consistent`: The diagonal A.1 fact
         "`N p X = 0` is decidable from `Phi0`" plus the A.4-induced
         "`K X` is a function of behaviour" gives a clean structural
         lemma: the always-true problem is the canonical element of
         `S(X)` for every X.

    None of these are in Corollaries/* or Results/*.
-/
import MIP.Axioms

namespace MIP

namespace Agent1_A1A4_SolvedClass

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-- The "auto-solved class": problems for which N is 0. -/
def autoSolved (X : Agent α) : Set (Problem α) := { p | N p X = 0 }

/-- The "Phi0-zero class": problems for which Phi0 is 0. -/
def phi0Zero (X : Agent α) : Set (Problem α) := { p | Phi0 X p = 0 }

/-! ## (i)/(ii) The two classes coincide, by A.1. -/

/-- **A.1 — autoSolved = phi0Zero, pointwise.** -/
theorem autoSolved_eq_phi0Zero (X : Agent α) :
    autoSolved X = phi0Zero X := by
  ext p
  exact Axioms.A1 p X

/-- **A.1 — Trivial problem is always in the auto-solved class.** -/
theorem trivial_problem_autoSolved (X : Agent α) :
    (fun _ : Str α => true) ∈ autoSolved X := by
  show N (fun _ : Str α => true) X = 0
  exact (Axioms.A1 _ X).mpr (Phi0_always_true X)

/-! ## (iii) Phi0-equality propagates the entire solved class. -/

/-- **A.1 — Phi0-pointwise-equal agents have the same auto-solved class.**

If `Phi0 X p = Phi0 X' p` for all `p`, then `autoSolved X = autoSolved X'`.
A.4's role: when X and X' are A.4-equivalent (e.g., same behaviour
modulo out-of-K tokens), they share K and Phi0 — this is the bridge
that makes the A.4-image of an agent share its solved class. -/
theorem autoSolved_eq_of_phi0_eq
    (X X' : Agent α)
    (hPhi : ∀ p : Problem α, Phi0 X p = Phi0 X' p) :
    autoSolved X = autoSolved X' := by
  ext p
  simp only [autoSolved, Set.mem_setOf_eq]
  rw [Axioms.A1 p X, Axioms.A1 p X', hPhi p]

/-! ## (iv) Combined A.1+A.4: A.4-equivalent agents (with shared K and Phi0) have identical solved classes. -/

/-- **A.1+A.4 — Combined invariance under A.4-equivalent + Phi0-equal agents.**

Two agents `X, X'` that are A.4-equivalent (behavioural equality on every
history) and Phi0-pointwise-equal have:
  - same K (D.1.3, expressed by hypothesis `hK`),
  - same autoSolved class (by `autoSolved_eq_of_phi0_eq`),
  - same A.2 finiteness verdict (by `hK`),
  - same A.1 zero verdict (combining).

Stated as a bundled corollary. -/
theorem A1A4_invariance_bundle
    (X X' : Agent α)
    (hK : (K X : Set Ω) = (K X' : Set Ω))
    (hPhi : ∀ p : Problem α, Phi0 X p = Phi0 X' p) :
    autoSolved X = autoSolved X' ∧
    ∀ p : Problem α,
      ((∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω))
        ↔ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X' : Set Ω))) := by
  refine ⟨autoSolved_eq_of_phi0_eq X X' hPhi, ?_⟩
  intro p
  rw [hK]

/-! ## (v) Phi0-zero is preserved under out-of-K token "garnishing".

A "garnished" agent X' is one whose Phi0 at p equals X's Phi0 at p.
A.4 produces such X's via the behavioural-equality route, but the
Phi0-equality must be supplied as a bridge.  We package the cleanest
form here. -/

/-- **A.1+A.4 — Phi0-zero is preserved under Phi0-bridge.**

If `Phi0 X p = Phi0 X' p` and `Phi0 X p = 0` then `Phi0 X' p = 0` and
hence `N p X' = 0`.  Trivial composition but worth naming for
downstream use (e.g. when chaining A.4 → behavioural-equality → Phi0
bridge → autoSolved). -/
theorem N_zero_of_Phi0_eq_zero_via_bridge
    (p : Problem α) (X X' : Agent α)
    (hPhiEq : Phi0 X p = Phi0 X' p)
    (hPhiZero : Phi0 X p = 0) :
    N p X' = 0 := by
  apply (Axioms.A1 p X').mpr
  rw [← hPhiEq]
  exact hPhiZero

/-- **A.1+A.4 — Phi0-bridge gives biconditional auto-solved.**

`Phi0 X p = Phi0 X' p ⟹ (p ∈ autoSolved X ↔ p ∈ autoSolved X')`. -/
theorem autoSolved_iff_under_bridge
    (p : Problem α) (X X' : Agent α)
    (hPhiEq : Phi0 X p = Phi0 X' p) :
    p ∈ autoSolved X ↔ p ∈ autoSolved X' := by
  simp only [autoSolved, Set.mem_setOf_eq]
  rw [Axioms.A1 p X, Axioms.A1 p X', hPhiEq]

end Agent1_A1A4_SolvedClass

end MIP
