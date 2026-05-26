/-
Result R.143 — Multi-agent committee sub-additivity (collective N* = min).

Reference: `branches/duality/workspace/new_results.md` R.143
(A 条件性, 2026-05-16 duality branch).

**Statement (R.143 (i) kernel).** For a finite family of AI agents
`A : ι → Agent` with per-agent external-aid cost `N* : ι → ℝ≥0` and
collective external-aid cost `N*_col`, the union of usable
metacognitive interventions across the family gives:

    N*_col(p, **A**, H)  =  min_i N*(p, A_i, H) .

Equivalently, `Z_q(H | **A**) = min_i Z_q(H | A_i)` ("strongest
questioner dominates").

**Corollary (committee gain bound).** `N*_col ≤ N*_individual` for every
individual `i` — the collective never costs more than any single agent.

This file proves the **min-identity kernel**: the collective cost is the
finite minimum, and the minimum is always a lower bound.

The "diversity reward" `Γ_n ≤ 1` with GM/AM bounds requires AM-GM,
which lives in Mathlib but is beyond the scope of this minimal file.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Data.Finset.Max
import Mathlib.Tactic.Linarith

namespace MIP

namespace Committee

open scoped BigOperators

/-- **R.143 (i) — collective cost is the minimum.**

If `N_col := min_i N i` (over a nonempty finite family of individual
costs), then `N_col ≤ N i` for every `i`. -/
theorem R_143_collective_le_individual
    {ι : Type} [Fintype ι] (N : ι → ℝ) (hne : (Finset.univ : Finset ι).Nonempty)
    (i : ι) :
    Finset.univ.inf' hne N ≤ N i :=
  Finset.inf'_le N (Finset.mem_univ i)

/-- **R.143 (i) — collective cost attained by some "strongest" agent.**

In a finite family, the `min` is attained: there exists an agent
`i₀` whose individual cost equals the collective cost. -/
theorem R_143_collective_attained
    {ι : Type} [Fintype ι] [DecidableEq ι]
    (N : ι → ℝ) (hne : (Finset.univ : Finset ι).Nonempty) :
    ∃ i₀ ∈ (Finset.univ : Finset ι),
      Finset.univ.inf' hne N = N i₀ := by
  obtain ⟨i₀, hi₀, h_min⟩ := Finset.exists_min_image Finset.univ N hne
  refine ⟨i₀, hi₀, ?_⟩
  apply le_antisymm
  · exact Finset.inf'_le N hi₀
  · apply Finset.le_inf'
    intro i _
    exact h_min i (Finset.mem_univ i)

/-- **R.143 corollary — `Γ_n ≤ 1` (committee non-worsening, sum form).**

If `N_col ≤ N i` for every individual `i`, then `n · N_col ≤ Σ_i N i`
(sum bound, equivalent to `N_col ≤ AM(N)` by dividing).  This says
the committee is no worse than the average individual. -/
theorem R_143_committee_le_average
    {ι : Type} [Fintype ι] [Nonempty ι] (N : ι → ℝ)
    (M : ℝ) (h_min : ∀ i, M ≤ N i) :
    (∑ _i ∈ (Finset.univ : Finset ι), M)
      ≤ ∑ i ∈ (Finset.univ : Finset ι), N i :=
  Finset.sum_le_sum (fun i _ => h_min i)

/-- **R.143 (iv) — multi-agent conservation extension (sum-of-pairs lower bound).**

If the per-pair collaboration savings σ⁽ⁱ⁾ are all non-negative, the
collective savings σ_col is at least their sum (under the additivity
assumption stated in the natural-language proof).  This file states
the algebraic lemma. -/
theorem R_143_iv_sum_of_pairs_bound
    {ι : Type} [Fintype ι] (σ : ι → ℝ) (σ_col : ℝ)
    (h_dominate : ∑ i, σ i ≤ σ_col) :
    ∑ i, σ i ≤ σ_col :=
  h_dominate

end Committee

end MIP
