/-
Corollary C.7 — Unified metric.  Reference: `proofs/corollaries.md` C.7
(and `corollaries/index.md` row C.7).

**Statement.** The unified difficulty metric

    E(P, A, F) = E_{p ∼ P}[ N(p, A, F) ]

(the expectation of the emergence cost `N` over a problem distribution
`P`) simultaneously encodes problem difficulty, AI capability, framework
quality and human metacognitive level.  In particular (dimension 2, the
rigorous one, via C.6) `E` is monotone in AI capability:
`A₁ ≼ A₂ ⟹ E(P, A₂, F) ≤ E(P, A₁, F)`.

**Kernel formalized here.** The expectation kernel as a clean finite
weighted sum over a problem index set:

    E p N = Σ_{i ∈ s} (p i) · (N i)

with `p i ≥ 0` the distribution weights and `N i ≥ 0` the per-problem
costs.  We prove:
* `expectedCost_nonneg`  — `E ≥ 0`;
* `expectedCost_linear`  — linearity in the cost vector `N`;
* `expectedCost_mono`    — pointwise monotonicity (the C.6 → C.7 step):
  if `N₂ i ≤ N₁ i` for all `i`, then `E[N₂] ≤ E[N₁]`.

Pure real/Finset mathematics; no MIP opaques are committed.

Axiom-free (only A.1–A.4).
-/
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Ring

namespace MIP

namespace Corollary_C7

open Finset

variable {ι : Type*}

/-- **C.7 — unified-metric expectation kernel.**

`E[N] := Σ_{i ∈ s} p i · N i` — the expected emergence cost over a
problem index set `s` weighted by the distribution `p`. -/
def expectedCost (s : Finset ι) (p N : ι → ℝ) : ℝ :=
  ∑ i ∈ s, p i * N i

/-- **Nonnegativity.** With nonnegative weights and nonnegative costs,
the unified metric is nonnegative. -/
theorem expectedCost_nonneg
    (s : Finset ι) (p N : ι → ℝ)
    (hp : ∀ i ∈ s, 0 ≤ p i) (hN : ∀ i ∈ s, 0 ≤ N i) :
    0 ≤ expectedCost s p N := by
  unfold expectedCost
  apply Finset.sum_nonneg
  intro i hi
  exact mul_nonneg (hp i hi) (hN i hi)

/-- **Linearity** of the unified metric in the cost vector:
`E[N₁ + N₂] = E[N₁] + E[N₂]`. -/
theorem expectedCost_add
    (s : Finset ι) (p N₁ N₂ : ι → ℝ) :
    expectedCost s p (fun i => N₁ i + N₂ i)
      = expectedCost s p N₁ + expectedCost s p N₂ := by
  unfold expectedCost
  simp only []
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  ring

/-- **Scalar homogeneity** in the cost vector:
`E[c · N] = c · E[N]`. -/
theorem expectedCost_smul
    (s : Finset ι) (p N : ι → ℝ) (c : ℝ) :
    expectedCost s p (fun i => c * N i) = c * expectedCost s p N := by
  unfold expectedCost
  simp only []
  rw [Finset.mul_sum s (fun i => p i * N i) c]
  apply Finset.sum_congr rfl
  intro i _
  ring

/-- **C.7 dimension 2 (AI capability) — monotonicity kernel.**

This is the rigorous half of C.7: taking the expectation of the C.6
pointwise inequality `N₂ i ≤ N₁ i`.  With nonnegative weights `p`,

    (∀ i, N₂ i ≤ N₁ i)  ⟹  E[N₂] ≤ E[N₁].

So `A₁ ≼ A₂ ⟹ E(P, A₂, F) ≤ E(P, A₁, F)`. -/
theorem expectedCost_mono
    (s : Finset ι) (p N₁ N₂ : ι → ℝ)
    (hp : ∀ i ∈ s, 0 ≤ p i)
    (hmono : ∀ i ∈ s, N₂ i ≤ N₁ i) :
    expectedCost s p N₂ ≤ expectedCost s p N₁ := by
  unfold expectedCost
  apply Finset.sum_le_sum
  intro i hi
  exact mul_le_mul_of_nonneg_left (hmono i hi) (hp i hi)

end Corollary_C7

end MIP
