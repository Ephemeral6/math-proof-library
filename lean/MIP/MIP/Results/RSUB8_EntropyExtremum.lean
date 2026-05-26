/-
Result R-SUB.8 — `H(π)` extremum principle (vertex characterization).

Reference: `workspace/subdomain_competition.md` §6.8 (A 无条件 for the
extremum identification; absorbency requires SGD geometry — out of scope).

**Statement (algebraic kernel for the minimum).** The Shannon entropy
`H(π) := −Σ_i π_i log π_i` of a finite distribution `π : ι → ℝ≥0`
(`Σ_i π_i = 1`) vanishes iff `π` is concentrated on a single index — a
"vertex" of the probability simplex.

This is the "specialist state" minimum: zero entropy ⟺ pure subdomain
focus.

The dual claim — maximum at uniform with value `log m` — requires the
concavity of `x ↦ −x log x` (Jensen's inequality), which is the
content of `Real.entropy_le_log` in extended Mathlib.  Here we prove
only the minimum-characterisation kernel.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace EntropyExtremum

open scoped BigOperators
open Real

/-- **Per-term vanishing:** `x · log x = 0  ⟺  x ∈ {0, 1}`
(for `0 ≤ x ≤ 1`; we use the convention `Real.log 0 = 0`).

For `x = 0`: `0 · log 0 = 0` (anything times 0).
For `x = 1`: `1 · log 1 = 1 · 0 = 0`.
For `0 < x < 1`: `log x < 0`, so `x · log x < 0`, in particular non-zero. -/
theorem x_log_x_zero_iff
    (x : ℝ) (hx_nonneg : 0 ≤ x) (hx_le_one : x ≤ 1) :
    x * Real.log x = 0 ↔ x = 0 ∨ x = 1 := by
  constructor
  · intro h
    rcases mul_eq_zero.mp h with hx0 | hlog
    · exact Or.inl hx0
    · -- log x = 0 with x ≥ 0; mathlib's `Real.log_eq_zero` gives x ∈ {0, 1, -1}.
      rcases Real.log_eq_zero.mp hlog with h0 | h1 | h_neg1
      · exact Or.inl h0
      · exact Or.inr h1
      · -- x = -1 impossible since x ≥ 0
        exact absurd h_neg1 (by linarith)
  · rintro (rfl | rfl)
    · simp
    · simp

/-- **Per-term sign:** `x · log x ≤ 0` for `0 ≤ x ≤ 1`. -/
theorem x_log_x_nonpos
    (x : ℝ) (hx_nonneg : 0 ≤ x) (hx_le_one : x ≤ 1) :
    x * Real.log x ≤ 0 := by
  rcases eq_or_lt_of_le hx_nonneg with hx0 | hx_pos
  · rw [← hx0]; simp
  · -- 0 < x ≤ 1 ⟹ log x ≤ 0 ⟹ x · log x ≤ 0.
    have h_log : Real.log x ≤ 0 := Real.log_nonpos (le_of_lt hx_pos) hx_le_one
    exact mul_nonpos_of_nonneg_of_nonpos (le_of_lt hx_pos) h_log

/-- **R-SUB.8 minimum kernel:** Sum-form of vanishing entropy.

For a finite type `ι` and `π : ι → ℝ` with `0 ≤ π i ≤ 1` for every `i`:

    Σ_i (π_i · log π_i) = 0  ⟺  ∀ i, π_i = 0 ∨ π_i = 1 .

Combined with the normalisation `Σ_i π_i = 1`, the right-hand side
forces `π` to be a vertex (`π_{i₀} = 1`, `π_j = 0` for `j ≠ i₀`). -/
theorem R_SUB_8_entropy_zero_iff
    {ι : Type} [Fintype ι] [DecidableEq ι] (π : ι → ℝ)
    (h_nonneg : ∀ i, 0 ≤ π i) (h_le_one : ∀ i, π i ≤ 1) :
    (∑ i, π i * Real.log (π i) = 0) ↔ ∀ i, π i = 0 ∨ π i = 1 := by
  constructor
  · intro h_sum i
    have h_per_term_nonpos : ∀ j, π j * Real.log (π j) ≤ 0 :=
      fun j => x_log_x_nonpos (π j) (h_nonneg j) (h_le_one j)
    -- Sum of nonpos terms is zero ⟹ each term is zero (by contradiction).
    have h_per_term_zero : π i * Real.log (π i) = 0 := by
      by_contra h_ne
      have h_strict : π i * Real.log (π i) < 0 :=
        lt_of_le_of_ne (h_per_term_nonpos i) h_ne
      have h_other_nonpos :
          ∑ k ∈ Finset.univ.erase i, π k * Real.log (π k) ≤ 0 :=
        Finset.sum_nonpos (fun k _ => h_per_term_nonpos k)
      have h_split : ∑ k, π k * Real.log (π k)
                      = π i * Real.log (π i)
                        + ∑ k ∈ Finset.univ.erase i, π k * Real.log (π k) := by
        rw [← Finset.add_sum_erase _ _ (Finset.mem_univ i)]
      have h_sum_neg : ∑ k, π k * Real.log (π k) < 0 := by
        rw [h_split]; linarith
      linarith
    exact (x_log_x_zero_iff (π i) (h_nonneg i) (h_le_one i)).mp h_per_term_zero
  · intro h_vertex
    apply Finset.sum_eq_zero
    intro i _
    exact (x_log_x_zero_iff (π i) (h_nonneg i) (h_le_one i)).mpr (h_vertex i)

end EntropyExtremum

end MIP
