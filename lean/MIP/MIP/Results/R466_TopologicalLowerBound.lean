/-
Result R.466 — persistent homology is a topological lower bound for `N(p, A_t)`.

Reference: `workspace/k_a_simplicial_homology.md` §2.5 (R.466)
(等级 B / grade-B: `w_n(p)` not yet formalised; bridge to T.8 not built).

**Statement.** For a fixed problem `p`, the MIP number `N(p, A_t)` is bounded
below by a weighted sum of homology dimensions:
```
    N(p, A_t)  ≥  Σ_n dim H_n(Δ_∘(K(A_t))) · w_n(p) ,
```
where `w_n(p)` is the emergence weight of order-`n` combinations on `p`. The
source argues: each unfilled `n`-hole `[γ] ∈ H_n` forces ≥ `n+1` compositional
interventions, so the weighted hole count is `≤ N`.

The full statement needs `w_n(p)` formalised and a bridge to T.8 (the source
marks it **grade-B**). We reduce to the **inequality kernel** the argument
ultimately rests on: given a finite index set of homology degrees, nonnegative
hole counts `H : ι → ℝ`, nonnegative weights `w : ι → ℝ`, and the *per-degree
budget hypothesis* `cost n ≥ H n · w n` (each degree's homological demand is
met by its share of `N`), with `N ≥ Σ cost`, we prove
```
    N  ≥  Σ_n H n · w n
```
via `Finset.sum_le_sum`. We also give the direct form (sum of per-degree lower
bounds) and the nonnegativity of the bound.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Linarith

namespace MIP

namespace TopologicalLowerBound

open Finset

variable {ι : Type*}

/-- **R.466 — the weighted-sum lower bound (kernel).**

Let `s : Finset ι` index the homology degrees in play, `H n ≥ 0` the dimension
of `H_n`, `w n ≥ 0` the emergence weight, and `cost n` the share of `N`
allocated to degree `n`. If each degree's share dominates its homological
demand (`H n · w n ≤ cost n`) and `N` covers the total cost
(`∑ cost ≤ N`), then
```
    ∑_{n ∈ s} H n · w n  ≤  N .
```
This is the algebraic core of `N(p, A_t) ≥ Σ_n dim H_n · w_n(p)`. -/
theorem R_466_lower_bound
    (s : Finset ι) (N : ℝ) (H w cost : ι → ℝ)
    (h_demand : ∀ n ∈ s, H n * w n ≤ cost n)
    (h_cover : ∑ n ∈ s, cost n ≤ N) :
    ∑ n ∈ s, H n * w n ≤ N :=
  le_trans (Finset.sum_le_sum h_demand) h_cover

/-- **R.466 — the lower bound, stated as `N ≥ …`.** Same content, oriented as in
the source. -/
theorem R_466_N_ge
    (s : Finset ι) (N : ℝ) (H w cost : ι → ℝ)
    (h_demand : ∀ n ∈ s, H n * w n ≤ cost n)
    (h_cover : ∑ n ∈ s, cost n ≤ N) :
    N ≥ ∑ n ∈ s, H n * w n :=
  R_466_lower_bound s N H w cost h_demand h_cover

/-- **R.466 — the weighted hole-count is nonnegative.**

With nonnegative dimensions and weights, the topological lower bound is itself
`≥ 0` (consistent with `N ≥ 1` from A.3): `0 ≤ Σ_n dim H_n · w_n`. -/
theorem R_466_bound_nonneg
    (s : Finset ι) (H w : ι → ℝ)
    (hH : ∀ n ∈ s, 0 ≤ H n) (hw : ∀ n ∈ s, 0 ≤ w n) :
    0 ≤ ∑ n ∈ s, H n * w n :=
  Finset.sum_nonneg fun n hn => mul_nonneg (hH n hn) (hw n hn)

/-- **R.466 — monotonicity in the hole counts.**

If every degree has at least as many holes (`H n ≤ H' n`) under nonnegative
weights, the topological lower bound only increases: more unfilled holes demand
more interventions. -/
theorem R_466_mono_in_H
    (s : Finset ι) (H H' w : ι → ℝ)
    (hw : ∀ n ∈ s, 0 ≤ w n) (hHH : ∀ n ∈ s, H n ≤ H' n) :
    ∑ n ∈ s, H n * w n ≤ ∑ n ∈ s, H' n * w n :=
  Finset.sum_le_sum fun n hn =>
    mul_le_mul_of_nonneg_right (hHH n hn) (hw n hn)

/-- **R.466 — direct form via per-degree budgets.**

The natural instantiation: take `cost n := H n * w n` itself. Then the demand
hypothesis is trivial, and the bound is exactly: if `N` covers the total
weighted hole count, the inequality holds. This isolates the *one* nontrivial
modelling hypothesis (the T.8 bridge `∑ H_n·w_n ≤ N`) the source leaves open. -/
theorem R_466_direct
    (s : Finset ι) (N : ℝ) (H w : ι → ℝ)
    (h_cover : ∑ n ∈ s, H n * w n ≤ N) :
    ∑ n ∈ s, H n * w n ≤ N :=
  h_cover

end TopologicalLowerBound

end MIP
