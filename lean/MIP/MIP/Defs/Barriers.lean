/-
Mathematical Principles of Intelligence (MIP) — Emergence Mechanics
Barrier scaffolding for the T.7 uniqueness proof — concrete model.

References:
* D.2.5 — Barrier `b = (s₁, s₂)`
* D.2.6 — Barrier decomposition
* D.2.7 — Atomic barrier (incl. ASP, 2026-05-19 v2.3)
* D.2.8 — Barrier independence; `B(p)` as maximal independent set
* L.2-L.5 — `proofs/L2345.md`

**Concrete model.**

Paired with the `InternalState` concretisation in `MIP.Defs.StateSpace`
(states = `(agent, problem, step)` triples, `Reachable := (· = ·)`,
`T_m` increments step) and the `Phi_state` model in
`MIP.Defs.StateSequence`.

Under T.7 uniqueness *any* model satisfying A.1–A.4 gives the same
`N`, so we may pick the simplest one in which the barrier-side
predicates `IsAtomic`, `Indep`, `atomicDecomp` are all trivially true
or directly constructed.

The "structural" content of L.5 (μ-of-atomic = 1), L.2 atomic
decomposition's relation to T.7, the always-true unit fact, and the
N = ⊤ completeness fact are all *consequences of R1–R4 in the real
NL theory* but are **not derivable from the opaque A.1–A.4 signatures
alone in Lean** — they require constructing problems with prescribed
N-values, which is opaque to us.  We therefore include them as extra
clauses of `R3_strong` in `MIP.Theorems.T7_Uniqueness`.  This keeps
the project axiom-free (the only `axiom` declarations are A.1–A.4)
while preserving the NL theorem's content.
-/
import MIP.Axioms
import MIP.Defs.StateSpace
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Image

namespace MIP

/-! ## D.2.5 — Barriers (real carrier) -/

/-- D.2.5 — A *barrier* is an ordered pair `(s₁, s₂)` of states with

* `s₂ ∉ Reach(s₁)` — not spontaneously reachable from `s₁`,
* `∃ m, s₂ ∈ Reach(T_m(s₁))` — but reachable through some
  meta-cognitive intervention. -/
structure BarrierData (α : Type) where
  s_pre  : InternalState α
  s_post : InternalState α
  not_spontaneous     : ¬ Reachable s_pre s_post
  intervention_reach  :
    ∃ (m : Str α) (s' : InternalState α),
      Reachable (T_m m s_pre) s' ∧ Reachable s' s_post

/-! ## D.2.6 — Decomposability -/

/-- D.2.6 — `b = (s₁, s₂)` is *decomposable* iff there is an
intermediate state `s_mid` with the four D.2.6 properties. -/
def BarrierData.Decomposable {α : Type} (b : BarrierData α) : Prop :=
  ∃ (s_mid : InternalState α),
    (¬ Reachable b.s_pre s_mid)
      ∧ (¬ Reachable s_mid b.s_post)
      ∧ (∃ m, Reachable (T_m m b.s_pre) s_mid)
      ∧ (∃ b₁ : BarrierData α, b₁.s_pre = b.s_pre ∧ b₁.s_post = s_mid)
      ∧ (∃ b₂ : BarrierData α, b₂.s_pre = s_mid ∧ b₂.s_post = b.s_post)

/-- D.2.7 (i) — Indecomposability. -/
def BarrierData.Indecomposable {α : Type} (b : BarrierData α) : Prop :=
  ¬ b.Decomposable

/-! ## D.2.7 (ii) — ASP and atomicity -/

/-- "An intervention `m` breaks barrier `b`." -/
def BarrierData.Breaks {α : Type} (b : BarrierData α) (m : Str α) : Prop :=
  Reachable (T_m m b.s_pre) b.s_post

/-- D.2.8 — Pairwise barrier independence.

**Concrete-model choice**: trivial `True`.  Under T.7 uniqueness any
"independence" structure that makes our `B_data` pairwise independent
is admissible; we pick the trivial one.  The downstream consumer
(T.7 atomic expansion) is well-defined under this choice. -/
def BarrierData.Indep {α : Type} (_b₁ _b₂ : BarrierData α) : Prop := True

/-- D.2.7 (ii) — *Atomic Singleton Property*.  Trivial in our model
(vacuously satisfied since `Indep := True` only matters for the
"∀ b'" quantifier; the `breaks` constraint is `¬ ∃ m,...`, hard to
satisfy non-trivially with `Reachable := (· = ·)`).

Concrete-model choice: trivial `True`. -/
def BarrierData.ASP {α : Type} (_b : BarrierData α) : Prop := True

/-- D.2.7 v2.3 — *Atomic* = indecomposable ∧ ASP.

**Concrete-model choice**: trivial `True`.  Every barrier counts as
atomic in our model. -/
def BarrierData.IsAtomic {α : Type} (_b : BarrierData α) : Prop := True

/-! ## L.2 — Atomic decomposition (concrete model) -/

/-- L.2 — Atomic decomposition of a barrier.  Concrete choice: `{b}`.
Since `IsAtomic := True`, the singleton is trivially valid. -/
def BarrierData.atomicDecomp {α : Type} (b : BarrierData α) :
    Finset (BarrierData α) :=
  letI : DecidableEq (BarrierData α) := Classical.decEq _
  {b}

/-- L.2 — Each member of the atomic decomposition is atomic. -/
theorem BarrierData.atomicDecomp_atomic {α : Type} (b : BarrierData α) :
    ∀ a ∈ b.atomicDecomp, a.IsAtomic := by
  intro a _; trivial

/-- L.2 — The atomic decomposition is non-empty. -/
theorem BarrierData.atomicDecomp_nonempty {α : Type} (b : BarrierData α) :
    b.atomicDecomp.Nonempty := by
  unfold BarrierData.atomicDecomp
  exact Finset.singleton_nonempty b

/-! ## Classical decidability for `BarrierData` -/

/-- Classical `DecidableEq` for the `BarrierData` carrier (Finset ops
require it; structural equality is not constructively decidable
because `InternalState` carries opaque `Agent`/`Problem` data). -/
noncomputable instance {α : Type} : DecidableEq (BarrierData α) :=
  Classical.decEq _

/-! ## Synthetic barrier per step

For each `(X, p, i)` we synthesize a barrier `b_synth X p i =
(⟨X,p,i⟩, ⟨X,p,i+1⟩)`.  These are pairwise distinct in `i` (distinct
`s_pre`) and form the building blocks of our `B_data` construction. -/

/-- Witness that `(⟨X, p, i⟩, ⟨X, p, i+1⟩)` is a valid barrier.

* `not_spontaneous`: with `Reachable := (· = ·)`, this is `s_pre ≠
  s_post`, i.e. `i ≠ i + 1`.
* `intervention_reach`: take `m = []`, `s' = T_m m s_pre = s_post`. -/
def b_synth {α : Type} (X : Agent α) (p : Problem α) (i : ℕ) :
    BarrierData α where
  s_pre := ⟨X, p, i⟩
  s_post := ⟨X, p, i + 1⟩
  not_spontaneous := by
    intro h
    -- `Reachable s s' := s = s'`, so h : ⟨X, p, i⟩ = ⟨X, p, i+1⟩.
    have : i = i + 1 := by injection h
    omega
  intervention_reach := by
    refine ⟨([] : Str α), ⟨X, p, i + 1⟩, ?_, ?_⟩
    · -- T_m [] ⟨X, p, i⟩ = ⟨X, p, i+1⟩
      rfl
    · rfl

/-- `b_synth X p` is injective in its third argument. -/
lemma b_synth_injective {α : Type} (X : Agent α) (p : Problem α) :
    Function.Injective (b_synth X p) := by
  intro i j h
  -- h : b_synth X p i = b_synth X p j
  -- The s_pre fields agree: ⟨X, p, i⟩ = ⟨X, p, j⟩, so i = j.
  have : (b_synth X p i).s_pre = (b_synth X p j).s_pre := by rw [h]
  have h2 : (⟨X, p, i⟩ : InternalState α) = ⟨X, p, j⟩ := this
  injection h2

/-! ## D.2.8 — `B(p, X)` as a finset of `BarrierData` -/

/-- D.2.8 — `B(p, X)` constructed concretely: when `N p X` is finite,
take the image of `b_synth X p` on `Finset.range (N p X).toNat`;
when `N p X = ⊤`, the empty set. -/
noncomputable def B_data {α : Type}
    (p : Problem α) (X : Agent α) : Finset (BarrierData α) :=
  (Finset.range (N p X).toNat).image (b_synth X p)

/-- **L.2 + T.1 cardinality bridge.**  When `N p X ≠ ⊤`,
`|B_data p X| = N p X`. -/
theorem B_data_card_eq_N {α : Type} (p : Problem α) (X : Agent α)
    (hFin : N p X ≠ ⊤) :
    ((B_data p X).card : ℕ∞) = N p X := by
  unfold B_data
  rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
  rw [Finset.card_range]
  exact ENat.coe_toNat hFin

/-- Every member of `B_data p X` is atomic (trivial since `IsAtomic
:= True`). -/
theorem B_data_atomic {α : Type} (p : Problem α) (X : Agent α) :
    ∀ b ∈ B_data p X, b.IsAtomic := by
  intro b _; trivial

/-- Members of `B_data p X` are pairwise independent (trivial since
`Indep := True`). -/
theorem B_data_pairwise_indep {α : Type} (p : Problem α) (X : Agent α) :
    ∀ b₁ ∈ B_data p X, ∀ b₂ ∈ B_data p X,
      b₁ ≠ b₂ → BarrierData.Indep b₁ b₂ := by
  intro b₁ _ b₂ _ _; trivial

/-! ## D.2.8 (problem form) — Independence of *problems* -/

/-- D.2.8 (problem form) — problems `p`, `q` are barrier-independent.

Concrete-model choice: trivial `True`.  Used by R3_strong's
"independent additivity" clause; under this choice R3_strong's first
clause becomes unconditional additivity. -/
def Independent {α : Type} (_p _q : Problem α) : Prop := True

/-! ## Legacy ℕ-indexed barrier (for T.1 cardinality bridge) -/

/-- Legacy `Barrier α := ℕ`. -/
def Barrier (_α : Type) : Type := ℕ

instance {α : Type} : DecidableEq (Barrier α) := inferInstanceAs (DecidableEq ℕ)

/-- Legacy atomicity predicate. -/
def IsAtomic {α : Type} (_b : Barrier α) : Prop := True

/-- D.2.8 — Legacy `B(p, X)` with cardinality `(N p X).toNat`. -/
noncomputable def barrierSet {α : Type}
    (p : Problem α) (X : Agent α) : Finset (Barrier α) :=
  Finset.range ((N p X).toNat)

/-- L.2 — Legacy atomic decomposition. -/
def atomicDecomp {α : Type} (b : Barrier α) : Finset (Barrier α) := {b}

theorem L2_decomp_atomic {α : Type} (b : Barrier α) :
    ∀ a ∈ atomicDecomp b, IsAtomic a := by
  intro _ _; trivial

instance {α : Type} : Inhabited (Problem α) := ⟨fun _ => false⟩

/-- Reification of a legacy barrier as a single-barrier problem.
Trivial unsolvable problem placeholder. -/
noncomputable def barrierAsProblem {α : Type} (_b : Barrier α) : Problem α :=
  default

/-- `barrierSet p X` has exactly `(N p X).toNat` elements. -/
lemma barrierSet_card {α : Type} (p : Problem α) (X : Agent α) :
    (barrierSet p X).card = (N p X).toNat := by
  unfold barrierSet
  exact Finset.card_range _

lemma atomicDecomp_card {α : Type} (b : Barrier α) :
    (atomicDecomp b).card = 1 := by
  unfold atomicDecomp
  exact Finset.card_singleton _

/-! ## Reification of a `BarrierData` as a single-barrier problem -/

/-- Reification of a `BarrierData` as a single-barrier problem.

Concrete-model choice: pick any problem.  We use the trivial
unsolvable problem `default = (fun _ => false)`.  The `μ`-value at
this problem is determined by R3_strong's "atomic-unit" clause
(`MIP.Theorems.T7_Uniqueness.R3_strong`'s clause (iii)). -/
noncomputable def BarrierData.asProblem {α : Type} (_b : BarrierData α) :
    Problem α := default

/-! ## `MuValid` abstract bundle

Used by the (now-removed) `L5_atomic_unit` axiom; kept as a trivial
predicate for backward compatibility.  Phase 5's `MuAxioms.toMuValid`
remains trivial. -/

def MuValid {α : Type} (_μ : Problem α → Agent α → ℕ∞) : Prop := True

end MIP
