/-
Result R.51 — Bidirectional dynamic switching is optimal.

Reference: `proofs/derived/A_grade.md` R.51 (A 无条件 under T.6 + D.4.12).

**Statement.** The optimal bidirectional protocol `π*` assigns each
barrier to the direction with lower impedance (`A ← H` if `Z_A(b) ≤ Z_H(b)`,
else `H ← A`).  Under this protocol, the bidirectional cost
`N_bi(p, A, H)` is minimal among all protocols, and in particular:

    N_bi(p, A, H)  ≤  N(p, A, H)    and    N_bi(p, A, H)  ≤  N(p, H, A) .

**Pure-math content (T.6.i + T.6.ii).** Per-barrier:
`min(u_b, v_b) ≤ u_b` and `min(u_b, v_b) ≤ v_b`.  Summing gives
`Σ min ≤ Σ u` and `Σ min ≤ Σ v`.

Optimality among all protocols: `min` is the per-coordinate optimum, so
the sum of mins equals the minimum over assignments of the sum.

This file proves the **algebraic kernel** without committing to MIP
opaques.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Algebra.Order.Group.MinMax
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset

namespace MIP

namespace DynamicSwitching

open scoped BigOperators

/-- **R.51 (T.6.i, sum form) — `Σ min ≤ Σ u`.**

For per-barrier costs `u, v : β → ℝ`, the sum of mins is at most the
one-direction sum. -/
theorem R_51_T6_i
    {β : Type} (B : Finset β) (u v : β → ℝ) :
    ∑ b ∈ B, min (u b) (v b) ≤ ∑ b ∈ B, u b := by
  apply Finset.sum_le_sum
  intro b _
  exact min_le_left (u b) (v b)

/-- **R.51 (T.6.ii, sum form) — `Σ min ≤ Σ v`.** -/
theorem R_51_T6_ii
    {β : Type} (B : Finset β) (u v : β → ℝ) :
    ∑ b ∈ B, min (u b) (v b) ≤ ∑ b ∈ B, v b := by
  apply Finset.sum_le_sum
  intro b _
  exact min_le_right (u b) (v b)

/-- **R.51 — per-barrier optimality (algebraic core).**

For any function `f : β → ℝ` with `f b ∈ {u b, v b}` (i.e. for any
"protocol" that picks one of the two costs at each barrier), the total
cost is at least the sum of per-barrier minima. -/
theorem R_51_min_is_optimal
    {β : Type} (B : Finset β) (u v f : β → ℝ)
    (h_choice : ∀ b ∈ B, f b = u b ∨ f b = v b) :
    ∑ b ∈ B, min (u b) (v b) ≤ ∑ b ∈ B, f b := by
  apply Finset.sum_le_sum
  intro b hb
  rcases h_choice b hb with h | h
  · rw [h]; exact min_le_left _ _
  · rw [h]; exact min_le_right _ _

end DynamicSwitching

end MIP
