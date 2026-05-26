/-
Result R.401 — Mixture of Experts (MoE) as a `K(A)` block partition with
top-k routing.

Reference: `~/Desktop/MIP/workspace/theory_unification.md` §R.401
("Mixture of Experts (MoE) 作为 K(A) 分块结构 + 路由投影", 2026-05-16).

**Mapping conditions (taken as explicit hypotheses).**
* **(M1) Block partition.** The knowledge set `K(A)` splits into `N_e`
  pairwise-disjoint expert blocks `K₁, …, K_{N_e}` whose union is `K(A)`.
* **(M3) Top-k router.** A router `g` selects, for a problem `p`, an
  index subset `I(p) ⊆ {1,…,N_e}` (top-k routing: `|I(p)| = k`).
* **(M4) Perfect routing.** The active knowledge
  `K_eff(A,p) := ⋃_{i ∈ I(p)} Kᵢ` covers the demand: `R(p) ⊆ K_eff`.

**Statement (the structural core).**  We model the knowledge universe by
a type `Ω`, the partition by an indexed family `block : ι → Finset Ω`
together with a `SubdomainPartition`-style bundle (pairwise-disjoint +
covers `K(A)`), and routing by a `Finset ι` selector `I`.  We prove:

1. **Active-knowledge identity** — `K_eff = ⋃_{i ∈ I} block i`, and this
   is a *subset* of `K(A)` (routing restricts, never invents).
2. **Monotone routing** — enlarging `I` enlarges `K_eff`; full routing
   (`I = univ`) recovers all of `K(A)`.
3. **Perfect-routing coverage** — under (M4) the active knowledge covers
   `R(p)`; equivalently, `R(p) ⊆ K_eff ↔` MoE solves `p` with the active
   experts only.
4. **Routing-error gap** — if a demanded element lives in an *unselected*
   block, coverage on `K_eff` fails even though the *global* `K(A)`
   covers it; this is the A.2 routing-failure that A.3 then repairs.
5. **Disjointness ⇒ block-counting** — selected blocks are pairwise
   disjoint, so `|K_eff| = Σ_{i ∈ I} |Kᵢ|` (the size bookkeeping behind
   the global `κ ≈ 1/N_e` dilution).

**This file is `axiom`-free.**  Imports only Mathlib; the mapping
conditions are explicit structure fields / hypotheses, and the
active-knowledge identity is what is proved.
-/
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

namespace MoEPartition

open Finset

variable {Ω : Type*} [DecidableEq Ω] {ι : Type*} [DecidableEq ι] [Fintype ι]

/-- **(M1) MoE block partition of `K(A)`.**

`block i` is expert block `Kᵢ`; `support` is the full knowledge set
`K(A)`.  Fields encode the partition axioms: blocks are pairwise disjoint
and their union over the (finite) expert index type is `K(A)`. -/
structure MoEKnowledge (Ω : Type*) [DecidableEq Ω] (ι : Type*)
    [DecidableEq ι] [Fintype ι] where
  /-- Expert block `Kᵢ ⊆ K(A)`. -/
  block : ι → Finset Ω
  /-- The full knowledge set `K(A)`. -/
  support : Finset Ω
  /-- Blocks are pairwise disjoint (cross-expert: `Kᵢ ∩ Kⱼ = ∅`). -/
  disjoint : ∀ i j, i ≠ j → Disjoint (block i) (block j)
  /-- Blocks cover `K(A)`: `⋃ᵢ Kᵢ = K(A)`. -/
  cover : Finset.univ.biUnion block = support

/-- Active knowledge under routing selection `I ⊆ {1,…,N_e}`:
`K_eff(A,p) := ⋃_{i ∈ I} Kᵢ`. -/
def activeKnowledge (M : MoEKnowledge Ω ι) (I : Finset ι) : Finset Ω :=
  I.biUnion M.block

/-- **R.401 (i) — active-knowledge identity (definitional unfolding).**

The active knowledge is exactly the union of the selected expert blocks. -/
theorem R_401_i_active_eq_biUnion (M : MoEKnowledge Ω ι) (I : Finset ι) :
    activeKnowledge M I = I.biUnion M.block := rfl

/-- **R.401 (i)′ — routing restricts: `K_eff ⊆ K(A)`.**

Selecting any subset of experts yields knowledge contained in the full
set `K(A)`; routing never invents knowledge outside the partition. -/
theorem R_401_i_active_subset_support (M : MoEKnowledge Ω ι) (I : Finset ι) :
    activeKnowledge M I ⊆ M.support := by
  rw [activeKnowledge, ← M.cover]
  exact Finset.biUnion_subset_biUnion_of_subset_left M.block (Finset.subset_univ I)

/-- **R.401 (ii) — routing is monotone in the selected expert set.**

A larger top-k selection activates more knowledge:
`I ⊆ J ⟹ K_eff(I) ⊆ K_eff(J)`. -/
theorem R_401_ii_active_mono (M : MoEKnowledge Ω ι) {I J : Finset ι}
    (h : I ⊆ J) : activeKnowledge M I ⊆ activeKnowledge M J :=
  Finset.biUnion_subset_biUnion_of_subset_left M.block h

/-- **R.401 (ii)′ — full routing recovers all of `K(A)`.**

Selecting every expert (`I = univ`, dense limit) recovers the full
knowledge set: `K_eff(univ) = K(A)`. -/
theorem R_401_ii_full_routing (M : MoEKnowledge Ω ι) :
    activeKnowledge M Finset.univ = M.support := by
  rw [activeKnowledge, M.cover]

/-- **R.401 (iii) — perfect-routing coverage (M4).**

If the router's selection `I(p)` is such that the demand sits inside the
union of selected blocks, then the active knowledge covers `R(p)`.  This
is the structural form of "MoE solves `p` with the active experts only";
the cost identity `N(p, A_MoE) ≈ N(p, A_eq_dense)` rests on this set
inclusion. -/
theorem R_401_iii_perfect_routing_cover (M : MoEKnowledge Ω ι)
    (R : Finset Ω) (I : Finset ι)
    (hRoute : R ⊆ I.biUnion M.block) :
    R ⊆ activeKnowledge M I := by
  rwa [activeKnowledge]

/-- **R.401 (iv) — routing-error gap (A.2 failure that A.3 repairs).**

Suppose a demanded element `ω ∈ R(p)` lives in expert block `Kⱼ` whose
index `j` was *not* selected (`j ∉ I`).  By partition disjointness `ω`
lies in *no other* block, so it is in no selected block, and coverage on
the active knowledge fails (`R(p) ⊄ K_eff`) even though `ω ∈ K(A)`
globally.  This is the MoE routing error: A.2 fails on `K_eff` while the
global set still covers — the gap A.3 closes via a metacognitive
intervention that re-routes.

All four hypotheses are load-bearing: disjointness + `j ∉ I` is what
forces `ω` out of every selected block. -/
theorem R_401_iv_routing_error
    (M : MoEKnowledge Ω ι) (R : Finset Ω) (I : Finset ι) {ω : Ω} {j : ι}
    (hDemand : ω ∈ R)                       -- ω is demanded
    (hInBlock : ω ∈ M.block j)              -- ω lives in expert block j
    (hUnsel : j ∉ I)                        -- but j is not routed
    : ¬ R ⊆ activeKnowledge M I := by
  intro hCover
  -- ω ∈ R ⊆ K_eff = ⋃_{i∈I} block i, so ω ∈ block i for some selected i.
  have hωEff : ω ∈ activeKnowledge M I := hCover hDemand
  rw [activeKnowledge, Finset.mem_biUnion] at hωEff
  obtain ⟨i, hiI, hωi⟩ := hωEff
  -- i ≠ j since i ∈ I but j ∉ I; then disjointness of blocks i, j is
  -- contradicted by ω ∈ block i ∩ block j.
  have hij : i ≠ j := fun h => hUnsel (h ▸ hiI)
  exact (Finset.disjoint_left.mp (M.disjoint i j hij) hωi) hInBlock

/-- **R.401 (v) — selected blocks are pairwise disjoint, hence additive.**

Restricting the partition's disjointness to a selection `I` gives a
pairwise-disjoint family, so the active-knowledge cardinality is the sum
of selected block sizes: `|K_eff| = Σ_{i ∈ I} |Kᵢ|`.  This is the
counting identity behind the global `κ ≈ 1/N_e` dilution (each cross-block
pair contributes nothing to composability). -/
theorem R_401_v_active_card (M : MoEKnowledge Ω ι) (I : Finset ι) :
    (activeKnowledge M I).card = ∑ i ∈ I, (M.block i).card := by
  rw [activeKnowledge]
  refine Finset.card_biUnion ?_
  intro i _ j _ hij
  exact M.disjoint i j hij

end MoEPartition

end MIP
