# Agent 8 — Multi-agent triangle structure: Summary

**Territory.** Multi-agent interactions, especially triangle-like
inequalities relating `N(p, A)`, `N(p, B)`, `N(p, C)`.

**Setting.** The MIP signatures expose two-agent results in
`Results/R813_JointCoverage.lean` (union coverage, transfer bottleneck)
and `Results/R816_FlywheelTrap.lean` (flywheel/fragile/trap trichotomy),
plus `Corollaries/C6_PosetMonotone.lean` (finiteness transfer along
`K X ⊆ K Y`). Agent 8 extends this two-agent corpus to **three agents**
and isolates the precise obstruction to a numeric triangle inequality
on `N`.

---

## Files produced

| File | STATUS | Headline |
|---|---|---|
| `Agent8_ThreeAgent_Chain.lean` | DISCOVERY | `K A ⊆ K B ⊆ K C → N p A ≠ ⊤ → N p B ≠ ⊤ ∧ N p C ≠ ⊤` (chain transfer of finiteness) and contrapositive `top` chain. |
| `Agent8_ThreeAgent_UnionCoverage.lean` | DISCOVERY | `N p A ≠ ⊤ ∨ N p B ≠ ⊤ ∨ N p C ≠ ⊤ → ∃ R' ∈ ℛ(p), R' ⊆ K A ∪ K B ∪ K C` + the three-agent flywheel zone `TripleFlywheel` with all-three-finite consequence. |
| `Agent8_WeakPhi0Symmetry.lean` | DISCOVERY | `Phi0 X p = 0 ∧ Phi0 Y p = 0 → N p X = N p Y = 0` (bridge-free "weak symmetry") + three-agent and trivial-problem extensions. |
| `Agent8_TriangleWitness.lean` | DISCOVERY | Triple-shared-witness ⟹ triple-intersection coverage ⟹ all three A.2-finite; AND the precise GAP that pairwise A.2 does NOT imply a shared witness. |
| `Agent8_ThreeAgent_Bidirectional.lean` | DISCOVERY | Three-agent T.6 kernel: `Σ_{B_A} + Σ_{B_B} + Σ_{B_C} ≤ (|B_A| + |B_B| + |B_C|) * nmax`, plus the partitioned form using `Finset.card_union_of_disjoint`. |
| `Agent8_ThreeAgent_Uncertainty.lean` | DISCOVERY | Three-agent extension of Cj.52: the joint product `N(A)·N(B)·N(C)·Var(A) ≥ f > 0` is REFUTED by the same constant-agent witness; also the `(Var(A)+Var(B)+Var(C))` variant. |
| `Agent8_TriangleInequality_Obstruction.lean` | OBSERVATION | The central obstruction: `N p A ≤ N p B + N p C` requires a `MergeBridge p B C M` (external data) plus a monotonicity bridge `N p A ≤ N p M`. Both bridges are NOT derivable from A.1–A.4. The trivial-problem case holds unconditionally (all zero). |
| `Agent8_Phi0_CrossAgent_DeadEnd.lean` | DEAD END | `K A = K B → Phi0 A p = Phi0 B p` is NOT derivable: A.4 only swaps tokens within one agent and says nothing cross-agent. Documents why `Agent1_A1A4_Phi0Invariance` carries a separate `hPhiBridge`. |

**Total: 6 DISCOVERY, 1 OBSERVATION, 1 DEAD END.** All compile, zero
`sorry`, zero new `axiom`.

---

## Single most interesting result

`Agent8_ThreeAgent_Chain.ne_top_chain`:

> If `K A ⊆ K B ⊆ K C` and `N p A ≠ ⊤`, then `N p B ≠ ⊤ ∧ N p C ≠ ⊤`.

This is the clean three-agent generalization of `Corollary_C6.finiteness_transfer`
(which only handled two agents). The contrapositive `Agent8_ThreeAgent_Chain.top_chain`
gives the "infection" direction: `N p C = ⊤` forces `N p A = N p B = ⊤`.

The most subtle DISCOVERY is `Agent8_TriangleWitness.demand_in_triple_inter_of_shared`,
which makes precise the difference between *pairwise* A.2-finiteness (which gives
*possibly distinct* witnesses per agent, by `distinct_witnesses_per_agent`) and
*joint* intersection coverage (which requires a *shared* witness). This is the
genuinely new content not in `R813` or `R816`.

---

## Central obstruction to a triangle inequality on N

`Agent8_TriangleInequality_Obstruction` formalizes the negative finding:

> The natural multi-agent triangle inequality
>
>     N p A ≤ N p B + N p C
>
> is NOT derivable from A.1–A.4.

The obstruction is structural:

1. **No agent-merge operator.** `Agent α := Str α → PMF (Str α)` is
   opaque; nothing combines `B` and `C` into a single `M = B ⊕ C` whose
   `K M = K B ∪ K C` and `N p M ≤ N p B + N p C`.

2. **A.2 is per-agent.** The witnesses for `N p B ≠ ⊤` and `N p C ≠ ⊤`
   may differ; A.2 gives no joint statement of the form `K A ⊆ K B ∪
   K C → (some bound on N p A)`.

3. **A.4 is intra-agent.** It only swaps tokens for a fixed agent.

What IS derivable is the **finiteness-side triangle** — `N · ≠ ⊤`
statements that mirror set-theoretic union/intersection facts via A.2.
The numeric sum bound is genuinely beyond A.1–A.4 in their opaque form.

---

## Per-group results

* **Group A (knowledge coverage triangle).** Items 2 and 3 (disjunction
  → union coverage) are DISCOVERY in `Agent8_ThreeAgent_UnionCoverage`.
  Item 1 (intersection from pairwise finiteness) is shown to require a
  shared witness in `Agent8_TriangleWitness` — the GAP that bare A.2
  cannot close.
* **Group B (knowledge subset → finiteness preservation).** The two-agent
  form (Item 4) is already in `Corollary_C6.finiteness_transfer`. Item
  6 (K-equality → finiteness iff) is already in
  `Agent1_A1A2A4_TrivialProblemCoverage.N_ne_top_invariant_under_K_eq`.
  Re-derived for self-containment in `Agent8_ThreeAgent_Chain.ne_top_of_subset`.
* **Group C (three-agent equi-finiteness).** Item 7 is the headline
  DISCOVERY: `Agent8_ThreeAgent_Chain.ne_top_chain`.
* **Group D (Phi0 invariance under same K).** DEAD END
  (`Agent8_Phi0_CrossAgent_DeadEnd`): A.4 is per-agent and cannot
  compare Phi0 across agents.
* **Group E (numeric triangle on N).** OBSERVATION
  (`Agent8_TriangleInequality_Obstruction`): documented as the central
  obstruction; the bridge-conditional form is given.
* **Group F (symmetry / permutation).** Item 8 (`K equal ∧ Phi0 equal
  → N equal`) — partially handled at `K equal` by Agent 1's iff;
  declined here. Item 9 (weak symmetry: `Phi0 = 0 both ⟹ N = 0 both`)
  is DISCOVERY in `Agent8_WeakPhi0Symmetry`.
* **Group G (bidirectional + triangle).** Three-agent T.6 *kernel*
  (pure-math sum bound) is DISCOVERY in `Agent8_ThreeAgent_Bidirectional`.
  The full N_bi-triangulation is blocked at the same place T.6 itself
  is blocked (no `N_bi` opaque, no protocol formalization).
* **Group H (three-agent uncertainty).** DISCOVERY in
  `Agent8_ThreeAgent_Uncertainty`: extends Cj.52's specific-candidate
  refutation to three agents with the same constant-variance witness
  collapsing the product to zero.

---

## Compilation

All eight files compiled with `lake env lean MIP/Discoveries/Agent8_*.lean`
from `C:\Users\12729\Desktop\Math\lean\MIP\`. Each is independent (no
mutual imports between Agent8 files); each pulls only from `MIP.Axioms`
and standard Mathlib pieces.
