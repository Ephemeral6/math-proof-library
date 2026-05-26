/-
Result R.104 (T.29) — Barrier-DAG edge set is observable; `P(Ê = E) → 1`.

Reference: `proofs/derived/conjecture_attacks.md` R.104 (A, partial resolution
of Cj.6 edge-set part).

**Statement.** The edge set `E` of the barrier DAG `G(p) = (B(p), E)`
(D.2.10) is observable: there is an algorithm `Algo_DAG` such that, over a
finite set of `m` candidate edges, the probability of recovering the whole
edge set correctly tends to `1`:

    lim_{n→∞} P(Ê = E) = 1 .

The mechanism (R.104 step 3): each per-pair χ² independence test is
consistent, so its **Type-II error** `β_n → 0` as `n → ∞`.  With `m` fixed
finite candidate edges tested independently, the probability that *all*
tests are simultaneously correct is `(1 − β_n)^m`, and

    (1 − β_n)^m  →  1     as   β_n → 0 .

**Pure-math kernel (Hypothesis-Bundle encoding).** The per-pair Type-II
error sequence `β : ℕ → ℝ` carries the bundled χ²-consistency hypothesis
`β_n → 0`.  For a fixed finite number `m` of candidate edges, we prove

    Filter.Tendsto (fun n => (1 - β n) ^ m) atTop (nhds 1) ,

i.e. the probability of correct recovery on all `m` edges converges to `1`.
The kernel: `x ↦ (1 - x)^m` is continuous and sends `0 ↦ 1^m = 1`, so
compose continuity with `β_n → 0` (`Filter.Tendsto.comp` / `Continuous.tendsto`).

**This file is `axiom`-free.**  The MIP-side machinery (D.2.8/D.2.10 DAG
structure, the χ² test, LLN consistency) enters only through the explicit
`β_n → 0` hypothesis and the finite edge count `m`.
-/
import Mathlib.Data.Real.Sqrt
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Topology.Algebra.Ring.Basic
import Mathlib.Order.Filter.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace EdgeObservable

open Filter Topology

/-- **Auxiliary: `x ↦ (1 - x)^m` is continuous.** -/
theorem continuous_one_sub_pow (m : ℕ) :
    Continuous (fun x : ℝ => (1 - x) ^ m) :=
  (continuous_const.sub continuous_id).pow m

/-- **R.104 — edge-set recovery probability tends to 1.**

Given the per-pair Type-II error sequence `β : ℕ → ℝ` with the bundled
χ²-consistency hypothesis `β_n → 0`, and a fixed finite number `m` of
candidate edges tested independently, the probability of correct recovery on
all edges,

    (1 − β_n)^m ,

converges to `1`:

    Tendsto (fun n => (1 - β n) ^ m) atTop (nhds 1) . -/
theorem R_104_edge_observable
    (β : ℕ → ℝ) (m : ℕ)
    (h_beta : Tendsto β atTop (nhds 0)) :
    Tendsto (fun n => (1 - β n) ^ m) atTop (nhds 1) := by
  -- The map  x ↦ (1 - x)^m  is continuous and  0 ↦ (1 - 0)^m = 1.
  have h_cont : Tendsto (fun x : ℝ => (1 - x) ^ m) (nhds 0) (nhds ((1 - 0) ^ m)) :=
    (continuous_one_sub_pow m).tendsto 0
  -- Compose with  β_n → 0  and simplify  (1 - 0)^m = 1.
  have h_comp : Tendsto (fun n => (1 - β n) ^ m) atTop (nhds ((1 - 0) ^ m)) :=
    h_cont.comp h_beta
  simpa using h_comp

/-- **R.104 (probability-of-error form).**

Equivalently, the failure probability `1 − (1 − β_n)^m` (probability of *at
least one* wrong edge among the `m` candidates) tends to `0`. -/
theorem R_104_failure_prob_to_zero
    (β : ℕ → ℝ) (m : ℕ)
    (h_beta : Tendsto β atTop (nhds 0)) :
    Tendsto (fun n => 1 - (1 - β n) ^ m) atTop (nhds 0) := by
  have h := R_104_edge_observable β m h_beta
  have h_sub : Tendsto (fun n => 1 - (1 - β n) ^ m) atTop (nhds (1 - 1)) :=
    tendsto_const_nhds.sub h
  simpa using h_sub

end EdgeObservable

end MIP
