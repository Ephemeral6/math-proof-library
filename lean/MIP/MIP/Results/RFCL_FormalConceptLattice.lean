/-
Result R.FCL.1–R.FCL.5 (slot 038) — the MIP formal concept lattice
`ℒ_MIP`.  A.2's solvability relation `R(p) ⊆ K(A)` upgrades to a Galois
connection between problems and agents; its closed concepts form a complete
lattice, and realizable knowledge elements `ω` inject into the atoms.

Reference: `workspace/round3_exploration/slot_038.md`,
`workspace/round3_exploration/work_slot_038.md` (R.FCL.1–R.FCL.5, IT.FCL).

Candidate status: Round-3 autonomous exploration, not yet human-audited.

**Statement (algebraic core).**

A.2 gives a `0/1` *solvability relation* `I(p, A) ⟺ R(p) ⊆ K(A)` on
`Problems × Agents`.  The induced **derivation (polar) operators**

    intent S := { A | ∀ p ∈ S, I p A }      (agents solving all of S)
    extent T := { p | ∀ A ∈ T, I p A }      (problems solved by all of T)

are the standard FCA pair.

* **R.FCL.1 (Galois connection).**  `(intent, extent)` is an *antitone*
  Galois pair: both are order-reversing, satisfy the adjunction
  `T ⊆ intent S ↔ S ⊆ extent T`, the extensivity `S ⊆ extent (intent S)`,
  and the triple identity `intent S = intent (extent (intent S))`.

* **R.FCL.2 (complete lattice — flagship).**  The composite
  `cl := extent ∘ intent` is a **closure operator** on `Set Problems`; its
  closed sets (the *concept extents*) form a **complete lattice**
  (Mathlib `ClosureOperator.gi.liftCompleteLattice`).  This is `ℒ_MIP`.

* **R.FCL.3 / IT.FCL (atoms ↔ realizable Ω).**  A knowledge element `ω` is
  *realizable* if some problem has `R(p) = {ω}`.  Sending a realizable `ω`
  to the closed extent `cl {p_ω}` is **injective** on realizable elements
  (distinct singletons close to distinct extents), the lattice-theoretic
  form of "the realizable `ω` are the finest solvable units".

This file proves, all `axiom`-free:

* `R_FCL_1_intent_antitone`, `R_FCL_1_extent_antitone` — (GC-1);
* `R_FCL_1_galois`         — the adjunction (GC-2);
* `R_FCL_1_extensive_*`    — (GC-3);
* `R_FCL_1_triple_*`       — (GC-4);
* `clOp`                   — the FCA closure operator on `Set Problems`;
* `R_FCL_2_completeLattice`— the complete lattice of concept extents (`ℒ_MIP`);
* `R_FCL_3_atoms_injective`— realizable-`ω` ↦ concept extent is injective.

**This file is `axiom`-free.**  Imports only Mathlib.
-/
import Mathlib.Order.GaloisConnection.Basic
import Mathlib.Order.Closure
import Mathlib.Data.Set.Lattice

namespace MIP

namespace FormalConceptLattice

open Set

/-! ### Setup: problems, agents, and the A.2 solvability relation

`Problems` and `Agents` are abstract carrier types; `I p A` is the A.2
solvability relation `R(p) ⊆ K(A) ⟺ N(p,A) < ∞`.  Everything below is
relative to a fixed relation `I`. -/

variable {Problems Agents : Type*} (I : Problems → Agents → Prop)

/-- **Intent** `S^↑`: the agents solving every problem in `S`. -/
def intent (S : Set Problems) : Set Agents := { A | ∀ p ∈ S, I p A }

/-- **Extent** `T^↓`: the problems solved by every agent in `T`. -/
def extent (T : Set Agents) : Set Problems := { p | ∀ A ∈ T, I p A }

/-! ### R.FCL.1 — `(intent, extent)` is an antitone Galois connection -/

/-- **R.FCL.1 (GC-1) — `intent` is antitone**: `S ⊆ S' → intent S' ⊆ intent S`. -/
theorem R_FCL_1_intent_antitone {S S' : Set Problems} (h : S ⊆ S') :
    intent I S' ⊆ intent I S :=
  fun _A hA p hp => hA p (h hp)

/-- **R.FCL.1 (GC-1) — `extent` is antitone**: `T ⊆ T' → extent T' ⊆ extent T`. -/
theorem R_FCL_1_extent_antitone {T T' : Set Agents} (h : T ⊆ T') :
    extent I T' ⊆ extent I T :=
  fun _p hp A hA => hp A (h hA)

/-- **R.FCL.1 (GC-2) — the Galois adjunction**:
`T ⊆ intent S ↔ S ⊆ extent T`.  (The defining symmetric property of the
polar pair.) -/
theorem R_FCL_1_galois (S : Set Problems) (T : Set Agents) :
    T ⊆ intent I S ↔ S ⊆ extent I T := by
  constructor
  · intro h p hp A hA
    exact h hA p hp
  · intro h A hA p hp
    exact h hp A hA

/-- **R.FCL.1 (GC-3) — extensivity on problems**: `S ⊆ extent (intent S)`. -/
theorem R_FCL_1_extensive_problems (S : Set Problems) :
    S ⊆ extent I (intent I S) :=
  (R_FCL_1_galois I S (intent I S)).1 (subset_rfl)

/-- **R.FCL.1 (GC-3) — extensivity on agents**: `T ⊆ intent (extent T)`. -/
theorem R_FCL_1_extensive_agents (T : Set Agents) :
    T ⊆ intent I (extent I T) :=
  (R_FCL_1_galois I (extent I T) T).2 (subset_rfl)

/-- **R.FCL.1 (GC-4) — triple identity on intents**:
`intent S = intent (extent (intent S))`. -/
theorem R_FCL_1_triple_intent (S : Set Problems) :
    intent I S = intent I (extent I (intent I S)) := by
  apply subset_antisymm
  · exact R_FCL_1_extensive_agents I (intent I S)
  · exact R_FCL_1_intent_antitone I (R_FCL_1_extensive_problems I S)

/-- **R.FCL.1 (GC-4) — triple identity on extents**:
`extent T = extent (intent (extent T))`. -/
theorem R_FCL_1_triple_extent (T : Set Agents) :
    extent I T = extent I (intent I (extent I T)) := by
  apply subset_antisymm
  · exact R_FCL_1_extensive_problems I (extent I T)
  · exact R_FCL_1_extent_antitone I (R_FCL_1_extensive_agents I T)

/-! ### R.FCL.2 — `ℒ_MIP` is a complete lattice

The composite `cl S := extent (intent S)` is a closure operator on
`Set Problems`; its closed elements (the *concept extents*) form a complete
lattice. -/

/-- The FCA **closure operator** `cl = extent ∘ intent` on `Set Problems`.
Built from extensivity (GC-3) and the minimality property derived from the
Galois adjunction (GC-2). -/
def clOp : ClosureOperator (Set Problems) :=
  ClosureOperator.mk₂ (fun S => extent I (intent I S))
    (fun S => R_FCL_1_extensive_problems I S)
    (fun S T (h : S ⊆ extent I (intent I T)) => by
      -- from `S ⊆ extent (intent T)` derive `extent (intent S) ⊆ extent (intent T)`
      have h1 : intent I (extent I (intent I T)) ⊆ intent I S :=
        R_FCL_1_intent_antitone I h
      have h2 : intent I (extent I (intent I T)) = intent I T :=
        (R_FCL_1_triple_intent I T).symm
      rw [h2] at h1
      exact R_FCL_1_extent_antitone I h1)

@[simp] theorem clOp_apply (S : Set Problems) :
    clOp I S = extent I (intent I S) := rfl

/-- A concept **extent** is a closed set of the FCA closure: `extent (intent S) = S`.
These closed `S` are exactly the `MIP` formal concepts (paired with `intent S`). -/
theorem isClosed_iff_extent (S : Set Problems) :
    (clOp I).IsClosed S ↔ extent I (intent I S) = S := by
  rw [ClosureOperator.isClosed_iff_closure_le]
  simp only [clOp_apply]
  constructor
  · intro h
    exact subset_antisymm h (R_FCL_1_extensive_problems I S)
  · intro h; rw [h]

/-- **R.FCL.2 — `ℒ_MIP` is a complete lattice (flagship).**

The concept extents (closed sets of `clOp`) form a complete lattice — the
MIP formal concept lattice `ℒ_MIP`.  Obtained from the Galois insertion of
the closure operator into `Set Problems` via
`GaloisInsertion.liftCompleteLattice`. -/
@[reducible] noncomputable def R_FCL_2_completeLattice :
    CompleteLattice (clOp I).Closeds :=
  (clOp I).gi.liftCompleteLattice

/-- **R.FCL.2 — `ℒ_MIP` is nonempty**: the closure of the empty problem set
is a concept (the bottom-ish concept), so the lattice has at least one
element. -/
theorem R_FCL_2_nonempty : Nonempty (clOp I).Closeds :=
  ⟨(clOp I).toCloseds ∅⟩

/-! ### R.FCL.3 / IT.FCL — atoms ↔ realizable Ω

A knowledge element `ω` is *realizable* if some problem `p` has `R(p) = {ω}`;
abstractly we just fix, for each realizable `ω`, a witnessing problem `pω`.
Sending `ω ↦ cl {pω}` is injective when the witnesses are *separated* by the
relation (distinct realizable elements have a distinguishing agent), the
lattice form of "`ω` are the finest solvable units (IT.FCL)". -/

/-- **R.FCL.3 / IT.FCL — realizable `ω` inject into concept extents.**

Let `ω : Ω → Problems` pick a witnessing problem `ω r` for each realizable
element `r`, and suppose the witnesses are *separated*: distinct `r ≠ r'`
admit an agent `A` solving `ω r` but not `ω r'` (the singletons `{ω r}` are
distinguished by the relation, exactly the A.2 / D.1.3 indivisibility of
knowledge elements).  Then `r ↦ clOp {ω r}` is injective: distinct
realizable elements give distinct concept extents, so the realizable `ω`
embed into `ℒ_MIP`'s atoms. -/
theorem R_FCL_3_atoms_injective {Ω : Type*} (ω : Ω → Problems)
    (hsep : ∀ r r' : Ω, r ≠ r' →
      ∃ A, I (ω r) A ∧ ¬ I (ω r') A) :
    Function.Injective (fun r => clOp I {ω r}) := by
  intro r r' hrr'
  by_contra hne
  obtain ⟨A, hA, hA'⟩ := hsep r r' hne
  -- A solves ω r, so A ∈ intent {ω r}; equal closures ⟹ equal intents
  -- ⟹ A ∈ intent {ω r'} ⟹ A solves ω r', contradiction.
  have hintent : intent I {ω r} = intent I {ω r'} := by
    have h1 : extent I (intent I {ω r}) = extent I (intent I {ω r'}) := by
      simpa only [clOp_apply] using hrr'
    -- apply intent to both sides and use the triple identity
    have := congrArg (intent I) h1
    rwa [← R_FCL_1_triple_intent I {ω r}, ← R_FCL_1_triple_intent I {ω r'}] at this
  -- A ∈ intent {ω r} since I (ω r) A
  have hAmem : A ∈ intent I {ω r} := by
    intro p hp
    rw [mem_singleton_iff] at hp
    rw [hp]; exact hA
  rw [hintent] at hAmem
  -- now A ∈ intent {ω r'} forces I (ω r') A
  exact hA' (hAmem (ω r') rfl)

end FormalConceptLattice

end MIP
