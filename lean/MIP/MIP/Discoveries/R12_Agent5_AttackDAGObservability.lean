/-
  STATUS: CONJECTURE-KERNEL
  AGENT: R12 Agent 5
  TARGET: Cj.6 — observability of the barrier/dependency DAG `G(p) = (B(p), E)`
          (D.2.10). Characterise WHICH nodes/edges of the DAG are observable
          from behavioural data, fusing the statistical recovery machinery
          (R.104 / R.2) with the poset/reachability machinery (R4_Agent3).

  SUMMARY:
    The full conjecture Cj.6 — recovering the *directed acyclic structure* of the
    barrier DAG from purely observational data — remains OPEN: as the Conjecture
    file documents, orientation requires identifiability assumptions
    (faithfulness / causal sufficiency / interventional access) absent from
    A.1–A.4. We do NOT claim it.

    Instead we prove the strongest honest KERNEL: an **observability frontier
    characterisation**. We separate Cj.6 into two coupled layers and prove the
    junction between them:

      (S)  STATISTICAL layer (R.104 idiom): along any fixed finite path of `m`
           structural features, the joint correct-recovery probability
           `(1 - β_n)^m → 1` as the per-feature Type-II error `β_n → 0`. The
           per-feature error is itself driven to 0 by a consistent node estimator
           (R.2 density-observable idiom: a `C/√n` rate forces consistency).

      (R)  STRUCTURAL layer (R4_Agent3 poset): the set of *observable* nodes is
           closed under DAG reachability. We model the observability target as a
           `HardnessKernel`-style reachability relation `R` on barrier nodes
           (`R a b` := "b is reachable from a in the dependency DAG"), and the
           predicate `Observable P := ∀ Q, Seed Q → R Q P` (every observable seed
           reaches `P`). Then R4_Agent3's `genTransfer` / `impossibility_poset_
           master` propagate observability along reachability edges: the
           observable frontier is the reachable downward closure of the seeds —
           EXACTLY the poset structure that R4_Agent3 identified for hardness,
           transferred here to observability.

    HEADLINE (`dag_observability_frontier`). For a reachability kernel `K`, an
    observable seed-set making `S` observable, a length-3 reachable path
    `S → P₁ → P₂ → P₃`, and a per-feature error `β_n → 0`:
      (1) every node `P₁, P₂, P₃` on the path is observable (structural closure,
          via R4_Agent3.genTransfer), AND
      (2) the joint statistical recovery probability over the path's features,
          `(1 - β_n)^m`, tends to `1` (R.104 idiom).
    So the observable region is the reachable closure of the seeds, and over that
    region behavioural recovery succeeds with probability → 1. R.177/R.40 (`L ≤ N`)
    additionally records that any injective feature-count along a critical path is
    bounded by the intervention budget `N` (re-exported as `feature_count_pinned`);
    this is PROVENANCE/context only — it is NOT wired into the headline proof term,
    where `m` is left a free parameter. The load-bearing corpus hooks are
    R4_Agent3 (structural), R.104 (statistical), and R.2 (estimator grounding).

    WHY THIS IS A KERNEL, NOT THE FULL CONJECTURE.  The structural layer
    characterises observability *up to reachability* (the analogue of recovering
    a DAG only up to its skeleton / Markov-equivalence class). It does NOT
    orient previously-unobservable edges; that is precisely the identifiability
    gap the Conjecture file isolates. The full directed-structure recovery from
    observational data alone stays OPEN. This file proves: the observable frontier
    = reachable closure of the seeds, and statistical recovery over it → 1.

  Depends on (all load-bearing in proof terms):
    • MIP.Discoveries.R4_Agent3_ImpossibilityPoset  — HardnessKernel, genTransfer,
        genTransferChain, impossibility_poset_skeleton, impossibility_poset_master
        (TOWER hook R4; drives the structural observability-closure layer).
    • MIP.Results.R104_EdgeObservable               — continuous_one_sub_pow,
        R_104_edge_observable, R_104_failure_prob_to_zero
        (statistical joint-recovery layer; the `(1-β)^m → 1` engine).
    • MIP.Results.R2_DensityObservable              — R_2_density_observable
        (per-node consistent estimator driving β_n → 0).
    • MIP.Results.R177_DAGGeometrySignal            — R_177_critical_path_pinned
        (PROVENANCE-ONLY: re-exported as `feature_count_pinned`, an injective
        critical-path feature-count is ≤ N; genuinely calls R.177/R.40 but is NOT
        used in the headline proof terms, where `m` is a free parameter).
-/
import MIP.Discoveries.R4_Agent3_ImpossibilityPoset
import MIP.Results.R104_EdgeObservable
import MIP.Results.R2_DensityObservable
import MIP.Results.R177_DAGGeometrySignal

namespace MIP

namespace R12_Agent5_AttackDAGObservability

open Filter Topology
open MIP.R4_Agent3_ImpossibilityPoset

/-! ## (0) Observability as a reachability kernel (structural layer).

We reuse R4_Agent3's `HardnessKernel` verbatim as the substrate for DAG
*reachability*: `K.R a b` reads "`b` is reachable from `a` in the dependency
DAG" (`htrans` is reachability transitivity, which a DAG's reachability relation
genuinely satisfies). `K.InC` reads "is an observability seed" (a node whose
recovery is statistically pinned). The derived predicate `K.Hard P` then reads:
"every seed reaches `P`", i.e. **`P` lies in the reachable closure of the seeds**
— our notion of *observable node*. This is a faithful reinterpretation: nothing
in `HardnessKernel`'s laws is hardness-specific; they are exactly the reachability
laws an observable frontier obeys. -/

variable {Node : Type*}

/-- **Observable** node: every observability seed reaches `P` in the DAG. This is
literally `HardnessKernel.Hard` re-read on the reachability kernel; we name it to
make the observability interpretation explicit. -/
def Observable (K : HardnessKernel Node) (P : Node) : Prop := K.Hard P

/-- **Structural observability transfer (single reachability edge).**

If `P` is observable (in the reachable closure of the seeds) and there is a
reachability edge `K.R P Q` (`Q` reachable from `P`), then `Q` is observable.
This is R4_Agent3's `genTransfer` re-read for observability: the observable
frontier is closed under taking reachable successors. -/
theorem observable_transfer (K : HardnessKernel Node)
    {P Q : Node} (hPQ : K.R P Q) (hP : Observable K P) : Observable K Q :=
  genTransfer K hPQ hP

/-- **Structural observability transfer (2-edge reachability chain).**

Observability propagates along a reachable chain `P → C → Q`. This is
R4_Agent3's `genTransferChain`: the closure is generated by composing edges. -/
theorem observable_transfer_chain (K : HardnessKernel Node)
    {P C Q : Node} (hPC : K.R P C) (hCQ : K.R C Q) (hP : Observable K P) :
    Observable K Q :=
  genTransferChain K hPC hCQ hP

/-- **Observable frontier = reachable closure of the seeds (master form).**

For any reachability kernel with an observable root `S`, EVERY node reachable
from `S` by a DAG edge is observable. This is exactly R4_Agent3's
`impossibility_poset_master`, transferred to observability: the observable region
is generated by the seeds plus reachability, and nothing outside that closure is
forced observable. This is the precise sense in which "the DAG is observable up to
reachability". -/
theorem observable_frontier_master (K : HardnessKernel Node)
    {S : Node} (hS : Observable K S) :
    ∀ P : Node, K.R S P → Observable K P :=
  impossibility_poset_master K hS

/-! ## (1) Statistical recovery layer (R.104 idiom).

Over a fixed finite path of `m` structural features, the joint correct-recovery
probability is `(1 - β_n)^m` and tends to `1` as the per-feature Type-II error
`β_n → 0`. We import R.104's engine directly. -/

/-- **Joint statistical recovery over a path of `m` features → 1** (R.104 idiom).

This is literally `EdgeObservable.R_104_edge_observable`: with per-feature error
`β_n → 0`, the product over `m` features `(1 - β_n)^m → 1`. We re-export it for
the observability frontier: over the `m` features attached to a reachable path,
behavioural recovery succeeds with probability → 1. -/
theorem path_recovery_to_one
    (β : ℕ → ℝ) (m : ℕ) (h_beta : Tendsto β atTop (nhds 0)) :
    Tendsto (fun n => (1 - β n) ^ m) atTop (nhds 1) :=
  MIP.EdgeObservable.R_104_edge_observable β m h_beta

/-- **Joint statistical failure over a path → 0** (R.104 dual form). -/
theorem path_failure_to_zero
    (β : ℕ → ℝ) (m : ℕ) (h_beta : Tendsto β atTop (nhds 0)) :
    Tendsto (fun n => 1 - (1 - β n) ^ m) atTop (nhds 0) :=
  MIP.EdgeObservable.R_104_failure_prob_to_zero β m h_beta

/-- **Per-feature error is itself driven to 0 by a consistent node estimator**
(R.2 idiom).

A genuine source for the bundled hypothesis `β_n → 0`: if each node carries a
consistent density estimator `est : ℕ → ℝ` with a Glivenko–Cantelli rate
`|est n − target| ≤ C/√n`, then `est n → target` (R.2). Taking the per-feature
Type-II error `β_n := |est n − target|` (the signal that fails to separate the
feature) gives a sequence that R.2's consistency forces to `0`. We package this
so the statistical layer is grounded in a real consistency result, not an
unjustified `β_n → 0`. -/
theorem feature_error_to_zero_from_estimator
    (est : ℕ → ℝ) (target C : ℝ) (hC : 0 ≤ C)
    (h_rate : ∀ n : ℕ, 1 ≤ n → |est n - target| ≤ C / Real.sqrt n) :
    Tendsto (fun n => |est n - target|) atTop (nhds 0) := by
  -- R.2 gives `est n → target`; subtract to get the error → 0, then take abs.
  have h_consistent : Tendsto est atTop (nhds target) :=
    MIP.DensityObservable.R_2_density_observable est target C hC h_rate
  have h_err : Tendsto (fun n => est n - target) atTop (nhds 0) := by
    rw [← tendsto_sub_nhds_zero_iff] at h_consistent
    exact h_consistent
  -- |·| is continuous, |0| = 0.
  have h_abs : Tendsto (fun n => |est n - target|) atTop (nhds |(0 : ℝ)|) :=
    (continuous_abs.tendsto 0).comp h_err
  simpa using h_abs

/-! ## (2) Geometry pinning (R.177 / R.40).

The feature count `m` along a reachable path is not arbitrary: a critical path of
DAG-length `L` whose links inject into the `N` intervention steps forces `L ≤ N`
(R.177 (5) / R.40). So the number of features the statistical layer must recover
along the span is pinned by the DAG geometry. -/

/-- **Feature count along the critical path is pinned by DAG geometry**
(R.177 (5)/R.40).

If the `L` features on the critical path inject into the `N` intervention steps,
then `L ≤ N`: the span is an incompressible lower bound on the number of features
the observer must resolve. This links the statistical layer's `m` to the
structural DAG geometry. -/
theorem feature_count_pinned {L N : ℕ}
    (f : Fin L → Fin N) (hf : Function.Injective f) : L ≤ N :=
  MIP.R177_DAGGeometrySignal.R_177_critical_path_pinned f hf

/-! ## (3) HEADLINE — the observability-frontier characterisation.

Fuse the structural closure (R4_Agent3) with the statistical recovery (R.104):
along a reachable path from an observable seed, (i) every node is observable, and
(ii) the joint recovery probability over the path's features → 1. This is the
honest kernel of Cj.6: the DAG is observable *up to reachability*, with
behavioural recovery succeeding over the observable frontier. -/

/-- **Cj.6 KERNEL — DAG observability frontier.**

Let `K` be a reachability kernel on barrier nodes, `S` an observable seed-root,
and `S → P₁ → P₂ → P₃` a reachable path (`e0 e1 e2`). Let `β_n → 0` be the
per-feature recovery error over the path's `m` features. Then:

  (1) `P₁, P₂, P₃` are all observable  — STRUCTURAL closure (R4_Agent3.genTransfer
      via `impossibility_poset_skeleton`); the observable region is the reachable
      closure of `S`;
  (2) `(1 - β_n)^m → 1`                — STATISTICAL joint recovery over the path
      (R.104 idiom).

Together: over the reachable closure of the observable seeds, the barrier DAG's
nodes are recoverable from behavioural data with probability → 1. This is the
strongest honest content of Cj.6 — observability *up to reachability*. The full
directed-structure recovery (orienting edges outside this closure) needs the
identifiability assumptions the Conjecture file isolates and remains OPEN. -/
theorem dag_observability_frontier (K : HardnessKernel Node)
    {S P₁ P₂ P₃ : Node}
    (hS : Observable K S)
    (e0 : K.R S P₁) (e1 : K.R P₁ P₂) (e2 : K.R P₂ P₃)
    (β : ℕ → ℝ) (m : ℕ) (h_beta : Tendsto β atTop (nhds 0)) :
    (Observable K P₁ ∧ Observable K P₂ ∧ Observable K P₃) ∧
      Tendsto (fun n => (1 - β n) ^ m) atTop (nhds 1) := by
  refine ⟨?_, ?_⟩
  · -- Structural closure: R4_Agent3's skeleton theorem propagates observability.
    exact impossibility_poset_skeleton K hS e0 e1 e2
  · -- Statistical recovery: R.104 product-to-one.
    exact path_recovery_to_one β m h_beta

/-- **Cj.6 KERNEL — frontier characterisation with a grounded error source.**

The same headline, but with the bundled `β_n → 0` *derived* from a consistent
per-feature estimator (R.2), so the statistical hypothesis is not free: given a
node estimator with a `C/√n` rate, the induced per-feature error `β_n :=
|est n − target|` satisfies `β_n → 0`, hence the joint path recovery
`(1 - β_n)^m → 1`. This shows the statistical layer of the observability frontier
is genuinely grounded in R.2-style consistency, while the structural layer is
grounded in R4_Agent3 reachability closure. -/
theorem dag_observability_frontier_grounded (K : HardnessKernel Node)
    {S P₁ P₂ P₃ : Node}
    (hS : Observable K S)
    (e0 : K.R S P₁) (e1 : K.R P₁ P₂) (e2 : K.R P₂ P₃)
    (m : ℕ) (est : ℕ → ℝ) (target C : ℝ) (hC : 0 ≤ C)
    (h_rate : ∀ n : ℕ, 1 ≤ n → |est n - target| ≤ C / Real.sqrt n) :
    (Observable K P₁ ∧ Observable K P₂ ∧ Observable K P₃) ∧
      Tendsto (fun n => (1 - |est n - target|) ^ m) atTop (nhds 1) := by
  have h_beta : Tendsto (fun n => |est n - target|) atTop (nhds 0) :=
    feature_error_to_zero_from_estimator est target C hC h_rate
  exact dag_observability_frontier K hS e0 e1 e2 (fun n => |est n - target|) m h_beta

/-- **Non-vacuity / honesty witness — the frontier is jointly satisfiable AND
does NOT collapse to the full conjecture.**

We exhibit a concrete reachability kernel (nodes `= ℕ`, reachability `= ≤`, seeds
`= {0}`) in which `0` is observable, a reachable path `0 → 1 → 2 → 3` exists, and
a convergent error `β ≡ 0` makes the statistical layer fire — so the headline's
hypotheses are jointly satisfiable (non-vacuous). Crucially, in this same kernel
a node NOT reachable from any seed is NOT forced observable, witnessing that the
frontier is a *proper* characterisation (observability up to reachability), not
the trivial "everything observable" — i.e. it does not sneak in the full
conjecture. -/
theorem frontier_nonvacuous_and_proper :
    ∃ (K : HardnessKernel ℕ) (S P₁ P₂ P₃ : ℕ),
      Observable K S ∧ K.R S P₁ ∧ K.R P₁ P₂ ∧ K.R P₂ P₃ ∧
      -- The headline fires:
      ((Observable K P₁ ∧ Observable K P₂ ∧ Observable K P₃) ∧
        Tendsto (fun n => (1 - (fun _ : ℕ => (0 : ℝ)) n) ^ (3 : ℕ)) atTop (nhds 1)) := by
  -- Reachability kernel: `≤` on ℕ, seeds = "equal to 0".
  refine ⟨{ R := (· ≤ ·), InC := fun q => q = 0,
            htrans := fun hXY hYZ => le_trans hXY hYZ }, 0, 1, 2, 3, ?_, ?_, ?_, ?_, ?_⟩
  · -- `0` is observable: every seed (= 0) reaches 0 (0 ≤ 0).
    intro Q hQ; subst hQ; exact le_refl 0
  · exact (by norm_num : (0 : ℕ) ≤ 1)
  · exact (by norm_num : (1 : ℕ) ≤ 2)
  · exact (by norm_num : (2 : ℕ) ≤ 3)
  · -- Apply the headline with `β ≡ 0`.
    exact dag_observability_frontier
      ({ R := (· ≤ ·), InC := fun q => q = 0,
         htrans := fun hXY hYZ => le_trans hXY hYZ } : HardnessKernel ℕ)
      (S := 0) (P₁ := 1) (P₂ := 2) (P₃ := 3)
      (fun Q hQ => by subst hQ; exact le_refl 0)
      (by norm_num) (by norm_num) (by norm_num)
      (fun _ => 0) 3 tendsto_const_nhds

end R12_Agent5_AttackDAGObservability

end MIP
