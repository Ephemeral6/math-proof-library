/-
Result R.91 (T.20) — Training-stability lower bound (pointwise form).

Reference: `workspace/new_results.md` R.91 (升 A 无条件, 2026-05-17 Slot 016).

**Statement (pointwise core).**  Under the Ohm-law product form, write
`N(p) = Φ₀(p) · Z̄ + ε(p)` with `|ε(p)| ≤ Φ₀(p) · σ_Z / 2`.  Let `m`
denote any reference value (typically `E[N]`) and `mΦ` denote any
reference value of `Φ₀` with `m = mΦ · Z̄ + e_m`, `|e_m| ≤ Φ_sup · σ_Z / 2`.

Then for any single problem `p`:

    |N(p) − m|
      ≤ Z̄ · |Φ₀(p) − mΦ|
        + 2 · σ_Z · max(Φ₀(p), Φ_sup) .

In particular, taking `Φ_sup ≥ Φ₀(p)`:

    |N(p) − m| ≤ Z̄ · |Φ₀(p) − mΦ| + 2 · σ_Z · Φ_sup .

This is the **σ_Z-controlled stability bound**: the worst-case
deviation of `N` is bounded by the `Φ₀` deviation (scaled by `Z̄`) plus
a `σ_Z`-driven term.

This file proves the **pure algebraic kernel** without committing to a
particular distribution or definition of expectation.  The natural
language proof in `workspace/new_results.md` then composes this with
`sup_{p ∈ P'}` to recover the distribution-level statement.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Algebra.Order.AbsoluteValue.Basic
import Mathlib.Algebra.Order.Ring.Abs
import Mathlib.Data.Fintype.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Finset.Lattice.Fold

namespace MIP

namespace StabilityBound

/-- **R.91 — pointwise stability bound (algebraic kernel).**

Given the Ohm-law decomposition `N = Φ · Z̄ + ε` with controlled
residual `|ε| ≤ Φ · σ_Z / 2` and a reference value `m = mΦ · Z̄ + e_m`
with `|e_m| ≤ Φ_sup · σ_Z / 2` and `Φ ≤ Φ_sup`, the per-problem
deviation is bounded by `Z̄·|Φ − mΦ| + 2·σ_Z·Φ_sup`. -/
theorem R_91_pointwise_bound
    (N Φ Z_bar ε m mΦ e_m σ_Z Φ_sup : ℝ)
    (h_N_decomp : N = Φ * Z_bar + ε)
    (h_m_decomp : m = mΦ * Z_bar + e_m)
    (h_ε_bound : |ε| ≤ Φ * σ_Z / 2)
    (h_e_m_bound : |e_m| ≤ Φ_sup * σ_Z / 2)
    (h_Φ_le_sup : Φ ≤ Φ_sup)
    (h_Φ_nonneg : 0 ≤ Φ)
    (h_σ_Z_nonneg : 0 ≤ σ_Z) :
    |N - m| ≤ |Z_bar| * |Φ - mΦ| + 2 * σ_Z * Φ_sup := by
  -- Decompose N - m = Z_bar · (Φ - mΦ) + (ε - e_m).
  have h_diff : N - m = Z_bar * (Φ - mΦ) + (ε - e_m) := by
    rw [h_N_decomp, h_m_decomp]; ring
  -- Triangle inequality.
  have h_tri : |N - m| ≤ |Z_bar * (Φ - mΦ)| + |ε - e_m| := by
    rw [h_diff]; exact abs_add_le _ _
  -- |Z_bar · (Φ - mΦ)| = |Z_bar| · |Φ - mΦ|.
  have h_mul : |Z_bar * (Φ - mΦ)| = |Z_bar| * |Φ - mΦ| := abs_mul _ _
  -- |ε - e_m| = |ε + (-e_m)| ≤ |ε| + |-e_m| = |ε| + |e_m|.
  have h_ε_diff : |ε - e_m| ≤ |ε| + |e_m| := by
    have h := abs_add_le ε (-e_m)
    rwa [← sub_eq_add_neg, abs_neg] at h
  have h_Φσ_bound : Φ * σ_Z / 2 ≤ Φ_sup * σ_Z / 2 := by
    have h_mul_le : Φ * σ_Z ≤ Φ_sup * σ_Z :=
      mul_le_mul_of_nonneg_right h_Φ_le_sup h_σ_Z_nonneg
    linarith
  have h_Φ_sup_nonneg : 0 ≤ Φ_sup := le_trans h_Φ_nonneg h_Φ_le_sup
  have h_Φsup_σ_nonneg : 0 ≤ Φ_sup * σ_Z :=
    mul_nonneg h_Φ_sup_nonneg h_σ_Z_nonneg
  have h_residual :
      |ε - e_m| ≤ 2 * σ_Z * Φ_sup := by
    calc |ε - e_m|
        ≤ |ε| + |e_m| := h_ε_diff
      _ ≤ Φ * σ_Z / 2 + Φ_sup * σ_Z / 2 := by linarith
      _ ≤ Φ_sup * σ_Z / 2 + Φ_sup * σ_Z / 2 := by linarith
      _ = Φ_sup * σ_Z := by ring
      _ ≤ 2 * σ_Z * Φ_sup := by linarith
  -- Combine.
  calc |N - m|
      ≤ |Z_bar * (Φ - mΦ)| + |ε - e_m| := h_tri
    _ = |Z_bar| * |Φ - mΦ| + |ε - e_m| := by rw [h_mul]
    _ ≤ |Z_bar| * |Φ - mΦ| + 2 * σ_Z * Φ_sup := by linarith

/-- **Sup-form (R.91 distribution version).**

If the pointwise bound `|N(p) − m| ≤ Z̄·|Φ(p) − mΦ| + 2·σ_Z·Φ_sup` holds
for every `p` in a nonempty finite set `P'`, then taking `sup_{p ∈ P'}`
on both sides preserves the bound. -/
theorem R_91_sup_form
    {ι : Type} [Fintype ι] [Nonempty ι]
    (N Φ : ι → ℝ) (Z_bar mΦ σ_Z Φ_sup m_const : ℝ)
    (h_point : ∀ p,
      |N p - m_const| ≤ |Z_bar| * |Φ p - mΦ| + 2 * σ_Z * Φ_sup) :
    ∀ p, |N p - m_const| ≤
        |Z_bar| * (Finset.univ.sup' Finset.univ_nonempty
                    (fun p => |Φ p - mΦ|)) + 2 * σ_Z * Φ_sup := by
  intro p
  have h_Φ_le_sup :
      |Φ p - mΦ| ≤ Finset.univ.sup' Finset.univ_nonempty
                    (fun p => |Φ p - mΦ|) :=
    Finset.le_sup' (fun p => |Φ p - mΦ|) (Finset.mem_univ p)
  have h_abs_Z_bar_nonneg : 0 ≤ |Z_bar| := abs_nonneg _
  calc |N p - m_const|
      ≤ |Z_bar| * |Φ p - mΦ| + 2 * σ_Z * Φ_sup := h_point p
    _ ≤ |Z_bar| * (Finset.univ.sup' Finset.univ_nonempty
                    (fun q => |Φ q - mΦ|)) + 2 * σ_Z * Φ_sup := by
        have := mul_le_mul_of_nonneg_left h_Φ_le_sup h_abs_Z_bar_nonneg
        linarith

end StabilityBound

end MIP
