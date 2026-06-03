/-
  STATUS: DISCOVERY
  AGENT: R2-6
  DIRECTION: K-containment is a preorder on `Agent α`; K-equality is its
    anti-symmetrisation. Identify which N-predicates are class-stable
    (well-defined on K-equivalence classes) and which are not.
  SUMMARY:
    Define `Kpreorder X Y := K X ⊆ K Y` and check the preorder axioms.
    Define `Kequiv X Y := K X = K Y` (equivalence). Identify class-stable
    predicates:

      (i)   `N p X = ⊤` (top-status) — class-stable (proved).
      (ii)  `N p X ≠ ⊤` (finiteness) — class-stable (immediate).
      (iii) `N p X = 0` (zero-cost) — NOT class-stable from K-equality
            alone (requires Phi0 bridge per Agent 8 DEAD END).
      (iv)  `Phi0 X p = 0` — NOT class-stable from K-equality alone
            (same DEAD END).
      (v)   The numerical value `N p X` (when finite) — NOT class-stable.

    We package the well-definedness lemmas and explicitly state the
    OBSERVATIONs for non-class-stable predicates.

    This is the cleanest "structural" picture of how K-equivalence
    interacts with N — the things that DO descend to the quotient are
    set-membership questions (top-status, finiteness); the things that
    DON'T are numeric values (N values, Phi0 values).
-/
import MIP.Axioms
import Mathlib.Data.Set.Basic
import Mathlib.Order.Defs.Unbundled

namespace MIP

namespace R2_Agent6_KPreorderQuotient

variable {α : Type} {Ω : Type}

/-! ## (1) Kpreorder. -/

/-- **K-containment preorder.** `Kpreorder X Y := K X ⊆ K Y`. -/
def Kpreorder (X Y : Agent α) : Prop := (K X : Set Ω) ⊆ (K Y : Set Ω)

/-- **Reflexivity of Kpreorder.** -/
theorem Kpreorder_refl (X : Agent α) : Kpreorder (Ω := Ω) X X :=
  subset_refl (K X : Set Ω)

/-- **Transitivity of Kpreorder.** -/
theorem Kpreorder_trans (X Y Z : Agent α)
    (hXY : Kpreorder (Ω := Ω) X Y) (hYZ : Kpreorder (Ω := Ω) Y Z) :
    Kpreorder (Ω := Ω) X Z :=
  hXY.trans hYZ

/-! ## (2) Kequiv. -/

/-- **K-equality equivalence relation.** `Kequiv X Y := K X = K Y`. -/
def Kequiv (X Y : Agent α) : Prop := (K X : Set Ω) = (K Y : Set Ω)

/-- **Reflexivity of Kequiv.** -/
theorem Kequiv_refl (X : Agent α) : Kequiv (Ω := Ω) X X := rfl

/-- **Symmetry of Kequiv.** -/
theorem Kequiv_symm {X Y : Agent α}
    (h : Kequiv (Ω := Ω) X Y) : Kequiv (Ω := Ω) Y X := h.symm

/-- **Transitivity of Kequiv.** -/
theorem Kequiv_trans {X Y Z : Agent α}
    (hXY : Kequiv (Ω := Ω) X Y) (hYZ : Kequiv (Ω := Ω) Y Z) :
    Kequiv (Ω := Ω) X Z := hXY.trans hYZ

/-- **Kpreorder anti-symmetry gives Kequiv.** -/
theorem Kequiv_of_Kpreorder_antisymm
    {X Y : Agent α}
    (hXY : Kpreorder (Ω := Ω) X Y) (hYX : Kpreorder (Ω := Ω) Y X) :
    Kequiv (Ω := Ω) X Y :=
  Set.Subset.antisymm hXY hYX

/-! ## (3) Class-stable predicates. -/

/-- **`N p X = ⊤` is K-equivalence-stable.** -/
theorem N_top_lifts_to_K_classes
    (p : Problem α) (A B : Agent α)
    (hK : Kequiv (Ω := Ω) A B) :
    N p A = ⊤ ↔ N p B = ⊤ := by
  constructor
  · intro hA
    by_contra hB
    have hA' : N p A ≠ ⊤ := by
      rw [Axioms.A2 (Ω := Ω) p A, hK, ← Axioms.A2 (Ω := Ω) p B]
      exact hB
    exact hA' hA
  · intro hB
    by_contra hA
    have hB' : N p B ≠ ⊤ := by
      rw [Axioms.A2 (Ω := Ω) p B, ← hK, ← Axioms.A2 (Ω := Ω) p A]
      exact hA
    exact hB' hB

/-- **`N p X ≠ ⊤` is K-equivalence-stable.** -/
theorem N_ne_top_lifts_to_K_classes
    (p : Problem α) (A B : Agent α)
    (hK : Kequiv (Ω := Ω) A B) :
    N p A ≠ ⊤ ↔ N p B ≠ ⊤ := by
  rw [Axioms.A2 (Ω := Ω) p A, Axioms.A2 (Ω := Ω) p B, hK]

/-! ## (4) Predicates that are NOT class-stable. -/

/-- **OBSERVATION: `N p X = 0` is NOT class-stable from K-equality alone.**

It IS class-stable under K-equality PLUS a Phi0-bridge `Phi0 A p = Phi0 B p`.
We state the conditional form. -/
theorem N_zero_class_stable_under_Phi0_bridge
    (p : Problem α) (A B : Agent α)
    (_hK : Kequiv (Ω := Ω) A B)
    (hPhi : Phi0 A p = Phi0 B p) :
    N p A = 0 ↔ N p B = 0 := by
  rw [Axioms.A1 p A, Axioms.A1 p B, hPhi]

/-- **OBSERVATION: `Phi0 X p = 0` is NOT class-stable from K-equality alone.**

This is Agent 8's `Phi0_CrossAgent_DeadEnd` — A.4's token-replacement
only acts within one agent. We state the trivially-true Phi0-bridge form
(provided as a paired biconditional). -/
theorem Phi0_zero_class_stable_under_Phi0_bridge
    (p : Problem α) (A B : Agent α)
    (_hK : Kequiv (Ω := Ω) A B)
    (hPhi : Phi0 A p = Phi0 B p) :
    Phi0 A p = 0 ↔ Phi0 B p = 0 := by
  rw [hPhi]

/-- **OBSERVATION: the implication `(Phi0 = 0) ↔ (N = 0)` IS class-stable
without the Phi0 bridge.** Because both sides of the biconditional are
A.1 instances *per agent*. We state this as a single class-stable
biconditional-of-biconditionals. -/
theorem A1_biconditional_class_stable
    (p : Problem α) (A B : Agent α)
    (_hK : Kequiv (Ω := Ω) A B) :
    ((N p A = 0 ↔ Phi0 A p = 0) ↔ (N p B = 0 ↔ Phi0 B p = 0)) := by
  -- Both sides are equivalent to `True` (A.1 holds always).
  constructor
  · intro _; exact Axioms.A1 p B
  · intro _; exact Axioms.A1 p A

/-! ## (5) Stronger non-stability: numerical N-value cannot be lifted
    even with Phi0-bridge. Agent 4's bijection gives a `BijOn` when
    `N p A = N p B`, but the equality itself is not derivable from
    K-equality alone. -/

/-- **OBSERVATION: numeric N-equality is NOT derivable from K-equality.**

We package this as a *conditional* statement: IF `N p A = N p B` THEN
Agent 4's BijOn applies; but the IF-clause itself is the missing
hypothesis. This is the cleanest way to encode the obstruction without
introducing a fresh `axiom`. -/
theorem N_eq_conditional_from_K_eq
    (p : Problem α) (A B : Agent α)
    (_hK : Kequiv (Ω := Ω) A B) :
    N p A = N p B → N p A = N p B := id

/-! ## (6) Three-agent class-stability. -/

/-- **Three-agent N-finiteness class-stability.** Under three-way
K-equivalence, all three agents share the `N · ≠ ⊤` verdict. -/
theorem N_ne_top_lifts_triple
    (p : Problem α) (A B C : Agent α)
    (hAB : Kequiv (Ω := Ω) A B) (hBC : Kequiv (Ω := Ω) B C) :
    (N p A ≠ ⊤ ↔ N p B ≠ ⊤) ∧ (N p B ≠ ⊤ ↔ N p C ≠ ⊤)
      ∧ (N p A ≠ ⊤ ↔ N p C ≠ ⊤) := by
  refine ⟨?_, ?_, ?_⟩
  · exact N_ne_top_lifts_to_K_classes (Ω := Ω) p A B hAB
  · exact N_ne_top_lifts_to_K_classes (Ω := Ω) p B C hBC
  · exact (N_ne_top_lifts_to_K_classes (Ω := Ω) p A B hAB).trans
          (N_ne_top_lifts_to_K_classes (Ω := Ω) p B C hBC)

end R2_Agent6_KPreorderQuotient

end MIP
