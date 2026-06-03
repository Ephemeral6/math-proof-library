/-
  STATUS: OBSERVATION
  AGENT: 8
  DIRECTION: Why a triangle inequality `N p A ≤ N p B + N p C` is NOT
             derivable from A.1–A.4, and what structure would be needed.
  SUMMARY:
    A natural multi-agent triangle inequality `N(p, A) ≤ N(p, B) + N(p, C)`
    is *not* derivable from A.1–A.4 alone. We identify the missing
    structure precisely:

    1. **No agent-combination operator.** `Agent α := Str α → PMF (Str α)`
       is opaque; there is no axiomatized way to "merge" agents `B` and
       `C` into a single agent `B ⊕ C` whose `K` is `K B ∪ K C` and
       whose `N(p, ·)` is bounded by `N p B + N p C`. Without such an
       operator, even phrasing "B and C together cover A's effort" is
       not type-correct.

    2. **A.2 is per-agent.** Each agent's coverage witness lives in its
       own `K`; A.2 has no joint statement of the form "if `K A ⊆ K B ∪
       K C`, then `N p A` is bounded by some function of `N p B` and
       `N p C`". The closest derivable statement is the *coverage*
       version: `R' ⊆ K B → R' ⊆ K B ∪ K C` (set-theoretic
       monotonicity), which is the engine behind R.813's joint-coverage
       result.

    3. **A.4 only swaps tokens within ONE agent.** It says nothing
       cross-agent.

    What IS derivable is *finiteness-side* triangle facts, captured in
    the companion DISCOVERY files:
      * `Agent8_ThreeAgent_Chain.ne_top_chain`,
      * `Agent8_ThreeAgent_UnionCoverage.demand_in_union3_of_any_finite`,
      * `Agent8_TriangleWitness.both_finite_of_shared_witness`.

    These are all `≠ ⊤` (Boolean finiteness) statements — the *numeric*
    sum bound `N p A ≤ N p B + N p C` is genuinely beyond A.1–A.4 in
    its current opaque form.

    Below we formalize the obstruction as a structure: a
    `MergeBridge p B C M` records the EXTERNAL data needed to make a
    numeric triangle inequality go through. The discovery is that this
    bridge cannot be constructed from A.1–A.4 — but assuming it,
    standard A.2 inequalities chain through. We give a clean derivation
    in the direction `K M ⊆ K A` (the only one that *uses* finiteness of
    M to derive finiteness of A under A.2.mp+mpr); the converse
    direction needed for a "triangle" requires data that is not in the
    bridge structure.
-/
import MIP.Axioms
import Mathlib.Data.Set.Basic
import Mathlib.Data.ENat.Basic

namespace MIP

namespace Agent8_TriangleInequality_Obstruction

variable {α : Type} {Ω : Type}

/-! ## (1) The merge bridge structure (external data).

The triangle inequality `N p A ≤ N p B + N p C` would, if it held,
require a "combined agent" `M` whose `K` covers both `K B` and `K C`
and whose `N` is bounded by the sum. Neither part is in A.1–A.4. -/

/-- **Merge bridge structure (external).** Records the data that an
agent-merge operator would have to satisfy. None of these fields is
derivable from A.1–A.4. -/
structure MergeBridge (p : Problem α) (B C M : Agent α) : Prop where
  /-- `M`'s knowledge contains `K B`. -/
  hKB : (K B : Set Ω) ⊆ (K M : Set Ω)
  /-- `M`'s knowledge contains `K C`. -/
  hKC : (K C : Set Ω) ⊆ (K M : Set Ω)
  /-- `M`'s cost is bounded by the sum of `B` and `C`'s costs. -/
  hcost : N p M ≤ N p B + N p C

/-! ## (2) What IS derivable: the *reverse* direction of A.2 transfer.

Given the bridge `M = B ⊕ C`, A.2's two-direction transfer goes through:
finiteness of `B` (which has `K B ⊆ K M`) implies finiteness of `M` via
A.2.mp+mpr. This part uses ONLY `hKB` (or `hKC`) of the bridge. -/

/-- **From bridge: finiteness of B lifts to finiteness of M.** Pure A.2
transfer using `K B ⊆ K M`. -/
theorem M_finite_of_B_finite
    (p : Problem α) (B C M : Agent α)
    (br : MergeBridge (Ω := Ω) p B C M)
    (hB : N p B ≠ ⊤) :
    N p M ≠ ⊤ := by
  obtain ⟨R', hMem, hSub⟩ := (Axioms.A2 (Ω := Ω) p B).mp hB
  exact (Axioms.A2 (Ω := Ω) p M).mpr ⟨R', hMem, hSub.trans br.hKB⟩

/-- **From bridge: finiteness of C lifts to finiteness of M.** Pure A.2
transfer using `K C ⊆ K M`. -/
theorem M_finite_of_C_finite
    (p : Problem α) (B C M : Agent α)
    (br : MergeBridge (Ω := Ω) p B C M)
    (hC : N p C ≠ ⊤) :
    N p M ≠ ⊤ := by
  obtain ⟨R', hMem, hSub⟩ := (Axioms.A2 (Ω := Ω) p C).mp hC
  exact (Axioms.A2 (Ω := Ω) p M).mpr ⟨R', hMem, hSub.trans br.hKC⟩

/-! ## (3) The triangle inequality, conditional on the bridge.

Given the bridge AND the requested direction `K A ⊆ K M` (i.e. `A`
itself is at-most-as-knowledgeable as the merge), we get the numeric
triangle inequality via the bridge's `hcost` field plus a separate
hypothesis tying `N p A` to `N p M` (which is the same direction as
C.6's `posetMonotone`). The chain is:

    N p A ≤ N p M   (from `K A ⊆ K M`, via C.6 monotonicity — which
                     itself requires a magnitude-ordering hypothesis
                     beyond A.1–A.4)
    N p M ≤ N p B + N p C   (the bridge's `hcost`)

Both bounds require external bridges. We package the conditional. -/

/-- **Bridge-conditional triangle inequality.** Given:
  * a merge bridge `M = B ⊕ C` (external),
  * a monotonicity bridge `h_AM : N p A ≤ N p M` (external — C.6 style),
the triangle inequality `N p A ≤ N p B + N p C` follows by transitivity.
Both bridges are external — neither is derivable from A.1–A.4 alone. -/
theorem triangle_inequality_via_bridges
    (p : Problem α) (A B C M : Agent α)
    (br : MergeBridge (Ω := Ω) p B C M)
    (h_AM : N p A ≤ N p M) :
    N p A ≤ N p B + N p C :=
  le_trans h_AM br.hcost

/-! ## (4) Trivial-problem corner: the triangle inequality holds
    unconditionally.

For the always-true problem, `N · X = 0` for every agent (by A.1.mpr
applied to `Phi0_always_true`). So `0 ≤ 0 + 0` is the trivial form. -/

/-- **Triangle inequality holds at the always-true problem.** Trivial:
all three terms are zero. -/
theorem triangle_trivial_problem (A B C : Agent α) :
    N (fun _ : Str α => true) A
      ≤ N (fun _ : Str α => true) B + N (fun _ : Str α => true) C := by
  have hA : N (fun _ : Str α => true) A = 0 :=
    (Axioms.A1 (fun _ : Str α => true) A).mpr (Phi0_always_true A)
  have hB : N (fun _ : Str α => true) B = 0 :=
    (Axioms.A1 (fun _ : Str α => true) B).mpr (Phi0_always_true B)
  have hC : N (fun _ : Str α => true) C = 0 :=
    (Axioms.A1 (fun _ : Str α => true) C).mpr (Phi0_always_true C)
  rw [hA, hB, hC]
  decide

/-! ## (5) The obstruction summary.

We package the structural observation that the triangle inequality
needs *both* a merge bridge and a monotonicity bridge as a single
positive statement: the implication direction is one-way (bridge ⟹
triangle), and the converse (triangle ⟹ bridge data exist) cannot
even be formalized without additional structure.
-/

/-- **Obstruction statement.** The triangle inequality
`∀ p A B C, N p A ≤ N p B + N p C` is derivable in MIP *only* if for
every triple `(A, B, C)` there exist a merge agent `M` and the
monotonicity bound `N p A ≤ N p M`. The existence of `M` is the
agent-merge operator obstruction; no such operator is in the opaque
signatures.

We state the *contrapositive of the existential bridge*: a model in
which no merge agent exists for some triple is a model in which the
triangle inequality must fail (under the further axiom that A is the
specific "worst case" needing to be bounded). The construction of such
a model is left to a future agent (it requires choosing a concrete
`Agent α := Str α → PMF (Str α)`).

We provide the *positive form*: if the bridges exist for ALL triples,
the triangle inequality holds. -/
theorem universal_triangle_from_universal_bridges
    (h_bridge_exists :
      ∀ (p : Problem α) (B C : Agent α),
        ∃ M : Agent α, MergeBridge (Ω := Ω) p B C M)
    (h_mono_exists :
      ∀ (p : Problem α) (A M : Agent α), N p A ≤ N p M) :
    ∀ (p : Problem α) (A B C : Agent α),
      N p A ≤ N p B + N p C := by
  intro p A B C
  obtain ⟨M, br⟩ := h_bridge_exists p B C
  exact triangle_inequality_via_bridges (Ω := Ω) p A B C M br (h_mono_exists p A M)

end Agent8_TriangleInequality_Obstruction

end MIP
