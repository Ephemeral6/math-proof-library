/-
Result R.140 — Teaching-direction irreversibility theorem.

Reference: `branches/duality/workspace/new_results.md` R.140
(A 无条件, 2026-05-16 duality branch).

**Three structural claims.**

* **(i) Teaching asymmetry identity.**
  `ΔT := N* − N = M_H − M_A`, where `M_X := Σ_b Φ(b)·Z_X(b)` is X's
  Φ-weighted impedance moment.

* **(ii) Asymmetry-bounds-asymmetry.**
  `|ΔT| ≤ Asym`, where `Asym := Σ_b Φ(b)·|Z_A(b) − Z_H(b)|`.  This is the
  triangle inequality for finite sums.

* **(iii) Knowledge irreversibility (set-theoretic core).**
  If `K(A) ⊇ K(H)`, then `K(H) \ K(A) = ∅`, so the maximum knowledge
  H can teach A is `|K(H) \ K(A)| = 0`.  Teaching from H to A
  contributes no new knowledge to A once A is already a strict
  superset of H's knowledge.

This file proves the **pure algebraic / set-theoretic kernels** of all
three parts.  The MIP wrappers (assigning physical meaning to `M_X`,
`Asym`, `K(X)`) live in the natural-language proof.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Algebra.Order.Ring.Abs
import Mathlib.Data.Set.Basic

namespace MIP

namespace TeachingIrreversibility

open scoped BigOperators

/-! ## Part (i) — Teaching-asymmetry identity ΔT = M_H − M_A -/

/-- **R.140 (i) — algebraic core.**

Given the R.132-style decomposition `N − N* = Σ_b Φ(b)·(Z_A(b) − Z_H(b))`
and the moment definitions `M_X := Σ_b Φ(b)·Z_X(b)`, we recover
`ΔT := N* − N = M_H − M_A`. -/
theorem R_140_i_delta_T_identity
    {β : Type} [Fintype β] [DecidableEq β]
    (Φ Z_A Z_H : β → ℝ) (N N_star M_A M_H : ℝ)
    (h_diff : N - N_star = ∑ b, Φ b * (Z_A b - Z_H b))
    (h_M_A : M_A = ∑ b, Φ b * Z_A b)
    (h_M_H : M_H = ∑ b, Φ b * Z_H b) :
    N_star - N = M_H - M_A := by
  have hexpand :
      ∑ b, Φ b * (Z_A b - Z_H b)
        = (∑ b, Φ b * Z_A b) - ∑ b, Φ b * Z_H b := by
    rw [← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro b _; ring
  rw [hexpand, ← h_M_A, ← h_M_H] at h_diff
  linarith

/-! ## Part (ii) — `|ΔT| ≤ Asym` -/

/-- **R.140 (ii) — `|ΔT| ≤ Asym` via finite-sum triangle inequality.**

For nonnegative weights `Φ b ≥ 0`, the absolute value of the signed
weighted sum is bounded by the weighted sum of absolute values:

    |Σ_b Φ(b)·(Z_A(b) − Z_H(b))| ≤ Σ_b Φ(b)·|Z_A(b) − Z_H(b)| .

Combined with R.140 (i), this yields `|ΔT| ≤ Asym`. -/
theorem R_140_ii_delta_T_le_Asym
    {β : Type} [Fintype β] [DecidableEq β]
    (Φ Z_A Z_H : β → ℝ) (N N_star Asym : ℝ)
    (h_diff : N - N_star = ∑ b, Φ b * (Z_A b - Z_H b))
    (h_Asym : Asym = ∑ b, Φ b * |Z_A b - Z_H b|)
    (h_Φ_nonneg : ∀ b, 0 ≤ Φ b) :
    |N_star - N| ≤ Asym := by
  -- |N* − N| = |−(N − N*)| = |N − N*|.
  have h_sub_swap : N_star - N = -(N - N_star) := by ring
  rw [h_sub_swap, abs_neg, h_diff, h_Asym]
  -- |Σ Φ(Z_A − Z_H)| ≤ Σ |Φ(Z_A − Z_H)| = Σ Φ |Z_A − Z_H|.
  calc |∑ b, Φ b * (Z_A b - Z_H b)|
      ≤ ∑ b, |Φ b * (Z_A b - Z_H b)| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ b, Φ b * |Z_A b - Z_H b| := by
        apply Finset.sum_congr rfl
        intro b _
        rw [abs_mul, abs_of_nonneg (h_Φ_nonneg b)]

/-! ## Part (iii) — Knowledge-irreversibility set-theoretic core -/

/-- **R.140 (iii) — set-theoretic core.**

If `K_A ⊇ K_H`, then `K_H \ K_A = ∅`.  Hence the maximum new knowledge
H can teach A (bounded by `K_H \ K_A`) is zero: teaching is unidirectional
once A's knowledge strictly contains H's. -/
theorem R_140_iii_set_irreversibility
    {Ω : Type} (K_A K_H : Set Ω) (h_sub : K_H ⊆ K_A) :
    K_H \ K_A = ∅ := by
  rw [Set.diff_eq_empty]
  exact h_sub

/-- **R.140 (iii) — finite cardinality version.**

If `K_A ⊇ K_H` (as finsets), the cardinality of the new-knowledge set
`K_H \ K_A` is zero. -/
theorem R_140_iii_finset_irreversibility
    {Ω : Type} [DecidableEq Ω] (K_A K_H : Finset Ω) (h_sub : K_H ⊆ K_A) :
    (K_H \ K_A).card = 0 := by
  rw [Finset.card_eq_zero, Finset.sdiff_eq_empty_iff_subset]
  exact h_sub

end TeachingIrreversibility

end MIP
