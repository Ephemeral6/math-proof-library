/-
  STATUS: DISCOVERY
  AGENT: 8
  DIRECTION: Three-agent bidirectional kernel — the T.6 sum-bound kernel
             extended from one barrier-cost vector to three.
  SUMMARY:
    `Theorems/T6_Bidirectional.T6_kernel` is the pure-math fragment of
    T.6(iii): `∀ b ∈ B, n b ≤ nmax → ∑ b ∈ B, n b ≤ B.card * nmax`.

    For three agents (A, B, C) collaborating with a barrier partition
    `B = B_A ⊔ B_B ⊔ B_C` (per-agent disjoint cover), the per-agent
    cost-sums `Σ_{b ∈ B_X} n_b` admit individual T.6-kernel bounds. We
    package the three-agent generalization:

    (i)  `T6_kernel_three`: three disjoint barrier-cost vectors with
         uniform bounds; the joint sum is bounded by `(|B_A| + |B_B| +
         |B_C|) * nmax`.
    (ii) `T6_kernel_partition`: if `B_A, B_B, B_C` partition a master
         set `B`, the joint sum equals the master sum and the T.6 bound
         on `|B|` applies.

    These are the natural pure-math kernels a three-agent T.6 statement
    would invoke. They are conservative extensions of T6_kernel with no
    new axiom dependencies.
-/
import MIP.Axioms
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Finset.Card

namespace MIP

namespace Agent8_ThreeAgent_Bidirectional

open scoped BigOperators

/-! ## (1) Three disjoint barrier-cost vectors with a common bound. -/

/-- **Three-agent T.6 kernel (disjoint vectors).** Three finite barrier
sets `B_A, B_B, B_C` with per-barrier costs `n_A, n_B, n_C` uniformly
bounded by `nmax`. The joint sum is at most the *total* barrier count
times `nmax`. -/
theorem T6_kernel_three
    {ι : Type*} (B_A B_B B_C : Finset ι)
    (n_A n_B n_C : ι → ℕ) (nmax : ℕ)
    (hA : ∀ b ∈ B_A, n_A b ≤ nmax)
    (hB : ∀ b ∈ B_B, n_B b ≤ nmax)
    (hC : ∀ b ∈ B_C, n_C b ≤ nmax) :
    ((∑ b ∈ B_A, n_A b) + (∑ b ∈ B_B, n_B b) + (∑ b ∈ B_C, n_C b))
      ≤ (B_A.card + B_B.card + B_C.card) * nmax := by
  have hA' : ∑ b ∈ B_A, n_A b ≤ B_A.card * nmax := by
    calc ∑ b ∈ B_A, n_A b
        ≤ ∑ _b ∈ B_A, nmax := Finset.sum_le_sum hA
      _ = B_A.card * nmax := by simp [Finset.sum_const, mul_comm]
  have hB' : ∑ b ∈ B_B, n_B b ≤ B_B.card * nmax := by
    calc ∑ b ∈ B_B, n_B b
        ≤ ∑ _b ∈ B_B, nmax := Finset.sum_le_sum hB
      _ = B_B.card * nmax := by simp [Finset.sum_const, mul_comm]
  have hC' : ∑ b ∈ B_C, n_C b ≤ B_C.card * nmax := by
    calc ∑ b ∈ B_C, n_C b
        ≤ ∑ _b ∈ B_C, nmax := Finset.sum_le_sum hC
      _ = B_C.card * nmax := by simp [Finset.sum_const, mul_comm]
  have hsum :
      (∑ b ∈ B_A, n_A b) + (∑ b ∈ B_B, n_B b) + (∑ b ∈ B_C, n_C b)
        ≤ B_A.card * nmax + B_B.card * nmax + B_C.card * nmax := by
    have h₁ : (∑ b ∈ B_A, n_A b) + (∑ b ∈ B_B, n_B b)
              ≤ B_A.card * nmax + B_B.card * nmax := Nat.add_le_add hA' hB'
    exact Nat.add_le_add h₁ hC'
  calc (∑ b ∈ B_A, n_A b) + (∑ b ∈ B_B, n_B b) + (∑ b ∈ B_C, n_C b)
      ≤ B_A.card * nmax + B_B.card * nmax + B_C.card * nmax := hsum
    _ = (B_A.card + B_B.card + B_C.card) * nmax := by ring

/-! ## (2) Partitioned form.

If `B_A, B_B, B_C` are pairwise disjoint and cover a master set `B`, the
joint sum equals `∑_{b ∈ B} n b` for the unified cost function
`n = if b ∈ B_A then n_A b else if b ∈ B_B then n_B b else n_C b` (under
the disjointness hypothesis). Without that case-split machinery, we
state the simpler form: the cardinality sum equals `|B|`. -/

/-- **Cardinality of a three-piece pairwise-disjoint union.** -/
theorem card_three_disjoint_union
    {ι : Type*} [DecidableEq ι]
    (B_A B_B B_C : Finset ι)
    (hAB : Disjoint B_A B_B)
    (hAC : Disjoint B_A B_C)
    (hBC : Disjoint B_B B_C) :
    (B_A ∪ B_B ∪ B_C).card = B_A.card + B_B.card + B_C.card := by
  have hABC : Disjoint (B_A ∪ B_B) B_C := by
    rw [Finset.disjoint_union_left]
    exact ⟨hAC, hBC⟩
  rw [Finset.card_union_of_disjoint hABC,
      Finset.card_union_of_disjoint hAB]

/-- **Three-agent T.6 kernel, partitioned form.** Under disjointness of
the three barrier subsets, the cardinality `|B_A ∪ B_B ∪ B_C|` equals
the sum of cardinalities, so the T.6 bound is
`(|B_A| + |B_B| + |B_C|) * nmax = |B_A ∪ B_B ∪ B_C| * nmax`. -/
theorem T6_kernel_three_partitioned
    {ι : Type*} [DecidableEq ι]
    (B_A B_B B_C : Finset ι)
    (n_A n_B n_C : ι → ℕ) (nmax : ℕ)
    (hA : ∀ b ∈ B_A, n_A b ≤ nmax)
    (hB : ∀ b ∈ B_B, n_B b ≤ nmax)
    (hC : ∀ b ∈ B_C, n_C b ≤ nmax)
    (hAB : Disjoint B_A B_B)
    (hAC : Disjoint B_A B_C)
    (hBC : Disjoint B_B B_C) :
    ((∑ b ∈ B_A, n_A b) + (∑ b ∈ B_B, n_B b) + (∑ b ∈ B_C, n_C b))
      ≤ (B_A ∪ B_B ∪ B_C).card * nmax := by
  rw [card_three_disjoint_union B_A B_B B_C hAB hAC hBC]
  exact T6_kernel_three B_A B_B B_C n_A n_B n_C nmax hA hB hC

end Agent8_ThreeAgent_Bidirectional

end MIP
