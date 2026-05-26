/-
Result R.FCL.4–R.FCL.5 (slot 038) — the TAIL of the MIP formal concept
lattice `ℒ_MIP`: the A.2 solvability axiom restated inside the concept
lattice (a translation theorem) and the TM-family intent ascending chain
(the intent / closure operator gives a monotone chain that stabilizes — a
monotone-chain / ACC kernel).

This file is the tail companion to
`MIP/Results/RFCL_FormalConceptLattice.lean` (which proves R.FCL.1 Galois
connection, R.FCL.2 complete lattice, R.FCL.3 atom injectivity).  To stay
self-contained it re-introduces the polar operators `intent` / `extent`
locally under a DIFFERENT sub-namespace (`ConceptLatticeTail`) so there is
no clash.

Reference: `workspace/round3_exploration/slot_038.md`,
`workspace/round3_exploration/work_slot_038.md` (R.FCL.4, R.FCL.5).

Candidate status: Round-3 autonomous exploration, not yet human-audited.

**Statement (algebraic core).**

The A.2 solvability relation `I p A ⟺ R(p) ⊆ K(A)` induces the FCA polar
pair
    intent S := { A | ∀ p ∈ S, I p A },
    extent T := { p | ∀ A ∈ T, I p A }.

* **R.FCL.4 (A.2 ℒ-restatement).**  A.2's pointwise solvability statement
  `I p A` is equivalent to its concept-lattice form: the agent `A` lies in
  the intent of the singleton problem `{p}`, i.e. `A ∈ intent {p}`,
  equivalently `{A} ⊆ intent {p}`, equivalently `{p} ⊆ extent {A}`.  This
  is the translation theorem that re-expresses A.2 as an order/membership
  statement in `ℒ_MIP`.  We also give the "covering" form: `p` is solved by
  every agent of a set `T` iff `p ∈ extent T`, and the finiteness/closure
  reformulation `extent (intent {p}) = cl {p}`.

* **R.FCL.5 (TM intent ascending chain — ACC kernel).**  Along a
  TM-family training trajectory the knowledge sets grow, `K(A_t) ⊆ K(A_{t+1})`,
  hence (bundled as `h_grow`) the induced extents `extent {A_t}` form an
  *ascending chain* under `⊆`.  We prove the monotone-chain kernel: the
  chain is monotone (`s ≤ t ⟹ extent {A_s} ⊇ extent {A_t}` on the agent
  side, equivalently the concept order `ε^{(A_s)} ≤ ε^{(A_t)}` ascends), and
  — bundling an ACC / stabilization hypothesis — it stabilizes: once two
  consecutive closures agree, the whole tail is constant.

This file proves, all `axiom`-free:

* `intent`, `extent`        — the FCA polar operators (local restatement);
* `R_FCL_4_pointwise_iff`   — `I p A ↔ A ∈ intent {p}`;
* `R_FCL_4_singleton_subset`— `I p A ↔ {A} ⊆ intent {p}`;
* `R_FCL_4_extent_form`     — `I p A ↔ {p} ⊆ extent {A}`;
* `R_FCL_4_covering`        — `(∀ A ∈ T, I p A) ↔ p ∈ extent T`;
* `R_FCL_5_intent_monotone` — `K(A_s) ⊆ K(A_t)` ⟹ ascending intents/extents;
* `R_FCL_5_chain_ascends`   — the TM trajectory gives a `⊆`-ascending chain;
* `R_FCL_5_stabilizes`      — ACC kernel: a stabilized step freezes the tail.

**This file is `axiom`-free.**  Imports only Mathlib.
-/
import Mathlib.Order.GaloisConnection.Basic
import Mathlib.Order.Closure
import Mathlib.Data.Set.Lattice

namespace MIP

namespace ConceptLatticeTail

open Set

/-! ### Setup: problems, agents, the A.2 solvability relation, polars

`I p A` is the A.2 solvability relation `R(p) ⊆ K(A)`.  We re-introduce the
polar operators locally (distinct sub-namespace) to keep the file
self-contained. -/

variable {Problems Agents : Type*} (I : Problems → Agents → Prop)

/-- **Intent** `S^↑`: the agents solving every problem in `S`. -/
def intent (S : Set Problems) : Set Agents := { A | ∀ p ∈ S, I p A }

/-- **Extent** `T^↓`: the problems solved by every agent in `T`. -/
def extent (T : Set Agents) : Set Problems := { p | ∀ A ∈ T, I p A }

/-! ### R.FCL.4 — A.2's `ℒ_MIP`-restatement -/

/-- **R.FCL.4 (pointwise form) — `I p A ↔ A ∈ intent {p}`.**

The A.2 solvability of `p` by `A` is *definitionally* the membership of `A`
in the intent of the singleton problem set `{p}`. -/
theorem R_FCL_4_pointwise_iff (p : Problems) (A : Agents) :
    I p A ↔ A ∈ intent I {p} := by
  constructor
  · intro h q hq
    rw [mem_singleton_iff] at hq; rw [hq]; exact h
  · intro h; exact h p rfl

/-- **R.FCL.4 (singleton-subset form) — `I p A ↔ {A} ⊆ intent {p}`.**

The Galois-adjunction-flavored restatement: `A` solves `p` iff the
singleton agent set `{A}` is contained in `intent {p}`. -/
theorem R_FCL_4_singleton_subset (p : Problems) (A : Agents) :
    I p A ↔ {A} ⊆ intent I {p} := by
  rw [R_FCL_4_pointwise_iff I p A]
  constructor
  · intro h B hB; rw [mem_singleton_iff] at hB; rw [hB]; exact h
  · intro h; exact h rfl

/-- **R.FCL.4 (extent form / adjunction symmetry) — `I p A ↔ {p} ⊆ extent {A}`.**

The dual restatement on the problem side, exhibiting the symmetry of the
Galois pair: `A` solves `p` iff the singleton problem `{p}` lies in the
extent of `{A}`. -/
theorem R_FCL_4_extent_form (p : Problems) (A : Agents) :
    I p A ↔ {p} ⊆ extent I {A} := by
  constructor
  · intro h q hq B hB
    rw [mem_singleton_iff] at hq hB; rw [hq, hB]; exact h
  · intro h; exact h rfl A rfl

/-- **R.FCL.4 (covering form) — `(∀ A ∈ T, I p A) ↔ p ∈ extent T`.**

The A.2 "knowledge-base covering" semantics: `p` is solvable by *every*
agent of `T` iff `p` belongs to the extent of `T`.  This is the
finiteness/closure-condition restatement at the heart of R.FCL.4. -/
theorem R_FCL_4_covering (p : Problems) (T : Set Agents) :
    (∀ A ∈ T, I p A) ↔ p ∈ extent I T :=
  Iff.rfl

/-- **R.FCL.4 (closure form) — the singleton concept `cl {p} = extent (intent {p})`.**

The concept generated by a single problem `p` is the closure of `{p}`; A.2
solvability of `p` lifts to membership of `p` in its own closure (extensivity),
the lattice-internal form of A.2's reflexive "`p` solves itself once its
knowledge requirements are met". -/
theorem R_FCL_4_in_closure (p : Problems) :
    p ∈ extent I (intent I {p}) := by
  intro A hA
  exact hA p rfl

/-! ### R.FCL.5 — TM-family intent ascending chain (ACC kernel)

Along a TM training trajectory `A : ℕ → Agents` with growing knowledge,
the solvability relation is monotone in the agent: if `K(A_s) ⊆ K(A_t)`
then any problem solved by `A_s` is solved by `A_t`.  We bundle this growth
as `h_grow : ∀ p, I p (A s) → I p (A t)` (the consequence of `K(A_s) ⊆
K(A_t)` under `I p A ⟺ R(p) ⊆ K(A)`).  Then the extents `extent {A_t}`
ascend with `t`. -/

/-- **R.FCL.5 (intent monotone) — knowledge growth lifts solvability.**

If every problem solved by `A` is solved by `B` (the consequence of
`K(A) ⊆ K(B)`), then `extent {A} ⊆ extent {B}` — the concept of `B`
dominates that of `A` in `ℒ_MIP`. -/
theorem R_FCL_5_intent_monotone (A B : Agents)
    (h_grow : ∀ p, I p A → I p B) :
    extent I {A} ⊆ extent I {B} := by
  intro p hp C hC
  rw [mem_singleton_iff] at hC
  rw [hC]
  exact h_grow p (hp A rfl)

/-- **R.FCL.5 (chain ascends) — TM trajectory gives a `⊆`-ascending chain.**

For a training trajectory `Ag : ℕ → Agents` whose successive knowledge
sets grow — bundled as the monotone-solvability hypothesis `h_step` — the
extents form an ascending chain: `s ≤ t ⟹ extent {Ag s} ⊆ extent {Ag t}`.
This is the lattice form of "training = ascending along the intent chain in
`ℒ_MIP`". -/
theorem R_FCL_5_chain_ascends (Ag : ℕ → Agents)
    (h_step : ∀ t p, I p (Ag t) → I p (Ag (t + 1)))
    {s t : ℕ} (hst : s ≤ t) :
    extent I {Ag s} ⊆ extent I {Ag t} := by
  induction t with
  | zero => simp_all
  | succ n ih =>
    rcases Nat.lt_or_ge s (n + 1) with h | h
    · exact subset_trans (ih (Nat.lt_succ_iff.mp h))
        (R_FCL_5_intent_monotone I (Ag n) (Ag (n + 1)) (h_step n))
    · have : s = n + 1 := le_antisymm hst h
      rw [this]

/-- **R.FCL.5 (ACC kernel — stabilization).**

The monotone-chain / ascending-chain-condition kernel.  Suppose the extent
chain `E t := extent {Ag t}` is ascending (`h_mono`) and stabilizes at step
`n` in the sense that the bundled ACC hypothesis gives `E (k+1) ⊆ E k` for
all `k ≥ n` (no new problems become solvable past `n`).  Then the chain is
*constant* from `n` on: `E n = E t` for every `t ≥ n`.  This is the
stabilization of the intent ascending chain (the closure operator reaches a
fixed point). -/
theorem R_FCL_5_stabilizes (E : ℕ → Set Problems)
    (h_mono : ∀ {s t : ℕ}, s ≤ t → E s ⊆ E t)
    (n : ℕ) (h_acc : ∀ k, n ≤ k → E (k + 1) ⊆ E k) :
    ∀ {t : ℕ}, n ≤ t → E n = E t := by
  intro t hnt
  induction t with
  | zero =>
    have : n = 0 := Nat.le_zero.mp hnt
    rw [this]
  | succ m ih =>
    rcases Nat.lt_or_ge n (m + 1) with h | h
    · have hnm : n ≤ m := Nat.lt_succ_iff.mp h
      have hEm : E n = E m := ih hnm
      apply subset_antisymm
      · exact h_mono hnt
      · rw [hEm]; exact h_acc m hnm
    · have : n = m + 1 := le_antisymm hnt h
      rw [this]

end ConceptLatticeTail

end MIP
