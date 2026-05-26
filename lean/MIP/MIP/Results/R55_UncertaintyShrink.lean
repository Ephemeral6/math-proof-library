/-
Result R.55 — Bidirectional-emergence-bound shrinkage under T.5 flywheel.

Reference: `proofs/derived/A_grade.md` R.55 (A 无条件 under C.11 + T.5).

**Statement.** As training proceeds, `|B_t(p)| ≤ (1−α)^t · |B_0(p)|`
(T.5 geometric decay of barrier count).  The C.11 product lower bound
`N(p, A_t, H) · N(p, H, A_t) ≥ |B_t(p)|²` then shrinks like
`(1−α)^{2t}`:

    |B_t(p)|²  ≤  (1−α)^{2t} · |B_0(p)|² .

**Pure-math kernel.** Squaring preserves order on nonnegatives:
`0 ≤ a ≤ b ⟹ a² ≤ b²`.  Apply to `a = |B_t|`, `b = (1−α)^t · |B_0|`,
then expand the square `((1−α)^t)² = (1−α)^{2t}`.

This file proves the **algebraic kernel** without committing to MIP
opaques.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Algebra.Order.Ring.Abs

namespace MIP

namespace UncertaintyShrink

/-- **R.55 — squared geometric decay kernel.**

If `0 ≤ b_t ≤ (1−α) ^ t · b_0` for nonneg base `b_0`, `α ∈ [0, 1]`,
then `b_t² ≤ (1−α)^(2t) · b_0²`. -/
theorem R_55_squared_decay
    (b_t b_0 α : ℝ) (t : ℕ)
    (h_nonneg : 0 ≤ b_t)
    (h_decay : b_t ≤ (1 - α) ^ t * b_0)
    (h_α_le_one : α ≤ 1) (h_b0_nonneg : 0 ≤ b_0) :
    b_t ^ 2 ≤ (1 - α) ^ (2 * t) * b_0 ^ 2 := by
  have h_1_minus_α_nonneg : 0 ≤ 1 - α := by linarith
  have h_RHS_nonneg : 0 ≤ (1 - α) ^ t * b_0 := by
    apply mul_nonneg
    · exact pow_nonneg h_1_minus_α_nonneg t
    · exact h_b0_nonneg
  -- Square the inequality (both sides nonneg).
  have h_sq : b_t ^ 2 ≤ ((1 - α) ^ t * b_0) ^ 2 :=
    pow_le_pow_left₀ h_nonneg h_decay 2
  -- Expand RHS: ((1-α)^t * b_0)^2 = (1-α)^(2t) * b_0^2.
  have h_expand : ((1 - α) ^ t * b_0) ^ 2
                    = (1 - α) ^ (2 * t) * b_0 ^ 2 := by
    rw [mul_pow]
    rw [show ((1 - α) ^ t) ^ 2 = (1 - α) ^ (2 * t) by
      rw [← pow_mul]; ring_nf]
  linarith [h_sq, h_expand.le, h_expand.ge]

/-- **R.55 — C.11 bound shrinks geometrically.**

The bidirectional product lower bound `N · N* ≥ |B|²` (C.11) shrinks
like `(1−α)^{2t}` under the T.5 geometric decay of `|B|`. -/
theorem R_55_lower_bound_shrinks
    (B_t B_0 α : ℝ) (t : ℕ)
    (h_nonneg : 0 ≤ B_t)
    (h_T5_decay : B_t ≤ (1 - α) ^ t * B_0)
    (h_α_le_one : α ≤ 1) (h_B0_nonneg : 0 ≤ B_0) :
    B_t ^ 2 ≤ (1 - α) ^ (2 * t) * B_0 ^ 2 :=
  R_55_squared_decay B_t B_0 α t h_nonneg h_T5_decay h_α_le_one h_B0_nonneg

end UncertaintyShrink

end MIP
