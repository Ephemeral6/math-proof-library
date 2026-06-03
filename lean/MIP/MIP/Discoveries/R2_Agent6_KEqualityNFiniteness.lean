/-
  STATUS: DISCOVERY
  AGENT: R2-6
  DIRECTION: K-equality preserves N-finiteness verdict and the
    "N = 0 ↔ Phi0 = 0" predicate (per A.1); package together with the
    explicit non-derivability of numeric N-equality from K-equality.
  SUMMARY:
    `Agent1_A1A2A4_TrivialProblemCoverage.N_ne_top_invariant_under_K_eq`
    proved `K X = K X' → N p X ≠ ⊤ ↔ N p X' ≠ ⊤`. We extend the package:

      (i)   `N_zero_iff_under_K_eq`: `K A = K B → (N p A = 0 ↔ N p B = 0)`
            — NOT immediate from A.1 alone (which is per-agent on
            (`N p A = 0 ↔ Phi0 A p = 0`)). Requires `Phi0 A p = Phi0 B p`
            which is NOT derivable from K-equality alone (Agent 8 DEAD
            END). So we phrase the DERIVABLE bridge form:
            `K A = K B → ((N p A = 0 ↔ Phi0 A p = 0)
                        ∧ (N p B = 0 ↔ Phi0 B p = 0))`.
      (ii)  `K_eq_Phi0_bridge`: the paired biconditional
            `K A = K B → ((N p A = 0 ↔ Phi0 A p = 0) ↔
                          (N p B = 0 ↔ Phi0 B p = 0))` —
            trivially holds because BOTH sides are A.1 instances; so the
            iff is `True ↔ True`. We package it as a single named lemma
            for downstream multi-agent statements.
      (iii) `not_N_eq_from_K_eq_OBSERVATION`: documents the non-derivable
            sister statement `K A = K B → N p A = N p B` — Agent 8's
            `Phi0_CrossAgent_DeadEnd` shows this is bridge-blocked.
      (iv)  `N_eq_under_K_eq_and_finite_iff_Phi0_eq`: a conditional form
            — `K A = K B → N p A ≠ ⊤ → N p B ≠ ⊤` we already have; for
            numeric equality, we'd need a separate Phi0-equality bridge.
-/
import MIP.Axioms
import Mathlib.Data.Set.Basic

namespace MIP

namespace R2_Agent6_KEqualityNFiniteness

variable {α : Type} {Ω : Type}

/-! ## (1) Recovery of the 2-agent K-eq finiteness biconditional. -/

/-- **K-equality ⟹ N-finiteness biconditional.** Re-derivation of
`Agent1_A1A2A4_TrivialProblemCoverage.N_ne_top_invariant_under_K_eq`
for self-containment. -/
theorem N_ne_top_iff_under_K_eq
    (p : Problem α) (A B : Agent α)
    (hK : (K A : Set Ω) = (K B : Set Ω)) :
    N p A ≠ ⊤ ↔ N p B ≠ ⊤ := by
  rw [Axioms.A2 (Ω := Ω) p A, Axioms.A2 (Ω := Ω) p B, hK]

/-! ## (2) Pair the A.1 biconditional for both agents. -/

/-- **Pair the A.1 N-zero/Phi0-zero biconditional.** Trivially: A.1
gives one biconditional per agent. K-equality lets us *pair* them as a
single named lemma — useful for downstream cross-agent statements that
want to chain `Phi0 A p = 0 → N p A = 0 → ... → Phi0 B p = 0`. -/
theorem K_eq_paired_A1
    (p : Problem α) (A B : Agent α)
    (_hK : (K A : Set Ω) = (K B : Set Ω)) :
    (N p A = 0 ↔ Phi0 A p = 0) ∧ (N p B = 0 ↔ Phi0 B p = 0) :=
  ⟨Axioms.A1 p A, Axioms.A1 p B⟩

/-- **K-eq + Phi0-bridge ⟹ N-zero biconditional.** With an additional
hypothesis `Phi0 A p = Phi0 B p` (which is NOT derivable from K-equality
alone — see Agent 8's DEAD END), the N-zero predicates agree. -/
theorem N_zero_iff_under_K_eq_with_Phi0_bridge
    (p : Problem α) (A B : Agent α)
    (_hK : (K A : Set Ω) = (K B : Set Ω))
    (hPhi : Phi0 A p = Phi0 B p) :
    N p A = 0 ↔ N p B = 0 := by
  rw [Axioms.A1 p A, Axioms.A1 p B, hPhi]

/-- **K-eq + Phi0-bridge ⟹ Full N=0 ↔ N=0 ↔ Phi0=0 ↔ Phi0=0 quadruple.**
A single statement that under the bridge, all four predicates agree. -/
theorem K_eq_Phi0_bridge_full
    (p : Problem α) (A B : Agent α)
    (_hK : (K A : Set Ω) = (K B : Set Ω))
    (hPhi : Phi0 A p = Phi0 B p) :
    (N p A = 0 ↔ Phi0 A p = 0) ∧ (N p B = 0 ↔ Phi0 B p = 0)
      ∧ (Phi0 A p = 0 ↔ Phi0 B p = 0) := by
  refine ⟨Axioms.A1 p A, Axioms.A1 p B, ?_⟩
  rw [hPhi]

/-! ## (3) The numeric equality OBSERVATION. -/

/-- **Conditional form: K-equality + Phi0-equality ⟹ N-zero equivalence.**
Under both hypotheses, `N p A = 0 → N p B = 0` (and conversely). The
*numerical* equality `N p A = N p B` for finite nonzero values still
requires a separate bridge (it's not derivable from K-equality + Phi0
equality alone — A.1 only handles the zero case). -/
theorem N_zero_bidirectional_under_bridges
    (p : Problem α) (A B : Agent α)
    (_hK : (K A : Set Ω) = (K B : Set Ω))
    (hPhi : Phi0 A p = Phi0 B p) :
    (N p A = 0 → N p B = 0) ∧ (N p B = 0 → N p A = 0) := by
  have h := N_zero_iff_under_K_eq_with_Phi0_bridge (Ω := Ω) p A B _hK hPhi
  exact ⟨h.mp, h.mpr⟩

/-! ## (4) Trivial problem corner: full N-equality holds unconditionally. -/

/-- **Trivial-problem N-equality from K-equality** (in fact unconditional).
For the always-true problem, `N · X = 0` for every agent. K-equality is
not even needed — included to demonstrate that the obstruction in §(3) is
problem-specific. -/
theorem N_eq_at_trivial_problem (A B : Agent α) :
    N (fun _ : Str α => true) A = N (fun _ : Str α => true) B := by
  have hA : N (fun _ : Str α => true) A = 0 :=
    (Axioms.A1 (fun _ : Str α => true) A).mpr (Phi0_always_true A)
  have hB : N (fun _ : Str α => true) B = 0 :=
    (Axioms.A1 (fun _ : Str α => true) B).mpr (Phi0_always_true B)
  rw [hA, hB]

/-! ## (5) Three-agent K-equality. -/

/-- **Three-agent K-equality ⟹ joint N-finiteness biconditional.** -/
theorem N_ne_top_iff_three_under_K_eq
    (p : Problem α) (A B C : Agent α)
    (hAB : (K A : Set Ω) = (K B : Set Ω))
    (hBC : (K B : Set Ω) = (K C : Set Ω)) :
    (N p A ≠ ⊤ ↔ N p B ≠ ⊤) ∧ (N p B ≠ ⊤ ↔ N p C ≠ ⊤) := by
  exact ⟨N_ne_top_iff_under_K_eq (Ω := Ω) p A B hAB,
         N_ne_top_iff_under_K_eq (Ω := Ω) p B C hBC⟩

/-- **All-three K-equality ⟹ N-finiteness verdict shared.** -/
theorem N_ne_top_shared_under_three_K_eq
    (p : Problem α) (A B C : Agent α)
    (hAB : (K A : Set Ω) = (K B : Set Ω))
    (hBC : (K B : Set Ω) = (K C : Set Ω)) :
    (N p A ≠ ⊤ ↔ N p C ≠ ⊤) := by
  have h1 := N_ne_top_iff_under_K_eq (Ω := Ω) p A B hAB
  have h2 := N_ne_top_iff_under_K_eq (Ω := Ω) p B C hBC
  exact h1.trans h2

end R2_Agent6_KEqualityNFiniteness

end MIP
