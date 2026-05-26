/-
Result R.805 — Augmentation Gain Bound (AGB).

Reference: `proofs/derived/A4_grade.md` R.805 (A 无条件, ε → 0 semantics).

**Statement.** Let an optimal `X_total` protocol use `k_aug(p)` calls to the
augmentation `X_aug`, each of knowledge density `≤ C_aug`.  By R.801 (UEA) /
the A.3-style approximation, each such call can be replaced by a purely
meta-cognitive sequence of length `≤ C_aug · log(1/ε)`.  Summing over the
`k_aug` calls, the augmentation gain is logarithmically bounded:

    0 ≤ AugGain(p, X) ≤ k_aug(p) · C_aug · log(1/ε) .

**Pure-math kernel (this file).** The A.3 / R.801 approximation enters as the
explicit per-call hypothesis: each of the `k_aug = |I|` calls contributes a
nonneg `gain i` with `gain i ≤ C_aug · log(1/ε)`.  Summing gives

    ∑_{i ∈ I} gain i ≤ |I| · (C_aug · log(1/ε)) = k_aug · C_aug · log(1/ε),

and nonnegativity `0 ≤ ∑ gain i` transports from the per-call nonneg bounds.

**Dependency.** R.801 (UEA) — supplies the per-call bound
`gain i ≤ C_aug · log(1/ε)`.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset

open Finset

namespace MIP

namespace AugmentationGain

/-- **R.805 — augmentation-gain upper bound (algebraic core).**

If each of the `k_aug = |I|` augmentation calls contributes
`gain i ≤ C_aug · log(1/ε)`, then the total gain is bounded by
`k_aug · C_aug · log(1/ε)`. -/
theorem R_805_aug_gain_upper
    {ι : Type*} (I : Finset ι) (gain : ι → ℝ) (C_aug ε : ℝ)
    (h_per_call : ∀ i ∈ I, gain i ≤ C_aug * Real.log (1 / ε)) :
    ∑ i ∈ I, gain i ≤ (I.card : ℝ) * (C_aug * Real.log (1 / ε)) := by
  -- Each term is bounded by the common constant `C_aug · log(1/ε)`.
  have h := Finset.sum_le_card_nsmul I gain (C_aug * Real.log (1 / ε)) h_per_call
  -- `card • x = card * x` over ℝ.
  rwa [nsmul_eq_mul] at h

/-- **R.805 — augmentation-gain nonnegativity.**

If each per-call gain is nonneg, the total gain is nonneg
(`AugGain(p, X) ≥ 0`). -/
theorem R_805_aug_gain_nonneg
    {ι : Type*} (I : Finset ι) (gain : ι → ℝ)
    (h_nonneg : ∀ i ∈ I, 0 ≤ gain i) :
    0 ≤ ∑ i ∈ I, gain i :=
  Finset.sum_nonneg h_nonneg

/-- **R.805 — full Augmentation Gain Bound.**

Combining nonnegativity and the logarithmic upper bound:

    0 ≤ AugGain(p, X) ≤ k_aug · C_aug · log(1/ε) ,

with `AugGain := ∑_{i ∈ I} gain i` and `k_aug := |I|`. -/
theorem R_805_augmentation_gain_bound
    {ι : Type*} (I : Finset ι) (gain : ι → ℝ) (C_aug ε : ℝ)
    (h_nonneg : ∀ i ∈ I, 0 ≤ gain i)
    (h_per_call : ∀ i ∈ I, gain i ≤ C_aug * Real.log (1 / ε)) :
    0 ≤ ∑ i ∈ I, gain i ∧
      ∑ i ∈ I, gain i ≤ (I.card : ℝ) * (C_aug * Real.log (1 / ε)) :=
  ⟨R_805_aug_gain_nonneg I gain h_nonneg,
   R_805_aug_gain_upper I gain C_aug ε h_per_call⟩

end AugmentationGain

end MIP
