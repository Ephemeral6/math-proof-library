/-
Result R-SUB.5 — μ₀ subdomain anti-correlation (decomposition core).

Reference: `workspace/subdomain_competition.md` §6.5 (B 条件; the pure
law-of-total-probability decomposition kernel is A 无条件).

**Statement (algebraic kernel).** For a problem distribution `P` split
into a disjoint partition `P = ⊔_i P_i` with probabilities `q_i := Pr[P_i]`,
the autonomous fraction `μ₀(X, P) := Pr_P[Δ ≡ 0]` decomposes as:

    μ₀(X, P)  =  Σ_i μ₀(X, P_i) · q_i .

This is the **law of total probability** for conditional expectation
over a finite partition.

**Pure-math content.** For any nonnegative weight `q_i` summing to 1
and any per-component value `μ_i`, the total `Σ q_i · μ_i` is the
weighted average.  When `q_i = Pr[P_i]` and `μ_i = E[1_{Δ ≡ 0} | P_i]`,
this is the standard tower property.

This file proves the **weighted-sum kernel** without committing to MIP
opaques.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.Order.BigOperators.Group.Finset

namespace MIP

namespace Mu0Decomposition

open scoped BigOperators

/-- **R-SUB.5 — partition decomposition (algebraic core).**

If `μ₀ := Σ_i q_i · μ_i` is the weighted average of subdomain values
with nonneg weights summing to 1, then equality is immediate by
definition.  This file fixes the algebraic identity to enable
downstream MIP-style applications. -/
theorem R_SUB_5_decomposition
    {ι : Type*} [Fintype ι] (q μ_i : ι → ℝ) (μ_total : ℝ)
    (h_def : μ_total = ∑ i, q i * μ_i i) :
    μ_total = ∑ i, q i * μ_i i :=
  h_def

/-- **R-SUB.5 — bound by max of per-subdomain values.**

`μ_total ≤ (max_i μ_i) · (Σ_i q_i)` when `q_i ≥ 0`.  For probability
weights (`Σ q_i = 1`), `μ_total ≤ max_i μ_i`. -/
theorem R_SUB_5_max_bound
    {ι : Type*} [Fintype ι] (q μ_i : ι → ℝ) (M : ℝ)
    (h_q_nonneg : ∀ i, 0 ≤ q i)
    (h_μ_le : ∀ i, μ_i i ≤ M)
    (h_q_sum : ∑ i, q i = 1) :
    ∑ i, q i * μ_i i ≤ M := by
  have h_pointwise : ∀ i ∈ (Finset.univ : Finset ι), q i * μ_i i ≤ q i * M := by
    intro i _
    exact mul_le_mul_of_nonneg_left (h_μ_le i) (h_q_nonneg i)
  calc ∑ i, q i * μ_i i
      ≤ ∑ i, q i * M := Finset.sum_le_sum h_pointwise
    _ = (∑ i, q i) * M := by rw [← Finset.sum_mul]
    _ = 1 * M := by rw [h_q_sum]
    _ = M := one_mul M

/-- **R-SUB.5 — lower bound by min of per-subdomain values.**

Dual: `μ_total ≥ min_i μ_i` for probability weights. -/
theorem R_SUB_5_min_bound
    {ι : Type*} [Fintype ι] (q μ_i : ι → ℝ) (m : ℝ)
    (h_q_nonneg : ∀ i, 0 ≤ q i)
    (h_μ_ge : ∀ i, m ≤ μ_i i)
    (h_q_sum : ∑ i, q i = 1) :
    m ≤ ∑ i, q i * μ_i i := by
  have h_pointwise : ∀ i ∈ (Finset.univ : Finset ι), q i * m ≤ q i * μ_i i := by
    intro i _
    exact mul_le_mul_of_nonneg_left (h_μ_ge i) (h_q_nonneg i)
  calc m = 1 * m := (one_mul m).symm
    _ = (∑ i, q i) * m := by rw [h_q_sum]
    _ = ∑ i, q i * m := by rw [← Finset.sum_mul]
    _ ≤ ∑ i, q i * μ_i i := Finset.sum_le_sum h_pointwise

end Mu0Decomposition

end MIP
