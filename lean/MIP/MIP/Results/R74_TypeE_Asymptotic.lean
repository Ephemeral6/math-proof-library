/-
Result R.74 — Type-E bidirectional acceleration is asymptotically unbounded.

Reference: `workspace/new_results.md` R.74 (升 A 条件 (n_max = 1) 2026-05-17
Slot 002; pure-math kernel is A 无条件).

**Statement (algebraic kernel).** In Type E (`s = 0`, all barriers
asymmetric), let `u, v > 0` be the per-barrier costs of the two
directions.  The "acceleration ratio"

    Acc := (u + v) / min(u, v)

satisfies `Acc = 1 + max(u,v)/min(u,v)`, which is unbounded as the
ratio `max/min` diverges.  Equivalently, in the geometric-mean
formulation, `(u + v) / (2·√(u v))` is also unbounded.

**Pure-math content.** `(u + v)/min(u, v) = 1 + max(u,v)/min(u,v) ≥ 1 + (any K)` for any K, by choosing `max/min ≥ K`.

This file proves the **algebraic kernel** without committing to MIP
opaques.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.Group.MinMax
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace TypeEAsymptotic

/-- **R.74 algebraic identity — `(u + v) = min(u, v) + max(u, v)`.**

For real `u, v`: their sum equals their min plus max. -/
theorem sum_eq_min_add_max (u v : ℝ) :
    u + v = min u v + max u v := by
  rcases le_or_gt u v with h | h
  · rw [min_eq_left h, max_eq_right h]
  · rw [min_eq_right (le_of_lt h), max_eq_left (le_of_lt h)]; ring

/-- **R.74 acceleration ratio kernel — `(u + v) / min(u, v) = 1 + max/min`.**

For positive `u, v`, the sum-over-min ratio equals `1 + max/min`. -/
theorem R_74_acc_ratio_identity
    (u v : ℝ) (hu : 0 < u) (hv : 0 < v) :
    (u + v) / min u v = 1 + max u v / min u v := by
  have h_min_pos : 0 < min u v := lt_min hu hv
  have h_min_ne : min u v ≠ 0 := ne_of_gt h_min_pos
  rw [sum_eq_min_add_max, add_div, div_self h_min_ne]

/-- **R.74 unboundedness kernel.**

For any `K > 0`, there exist positive `u, v` such that
`(u + v) / min(u, v) > K`.  Take `u = 1, v = K + 1`. -/
theorem R_74_unbounded :
    ∀ K : ℝ, ∃ u v : ℝ, 0 < u ∧ 0 < v ∧ (u + v) / min u v > K := by
  intro K
  refine ⟨1, max K 1 + 1, by norm_num, ?_, ?_⟩
  · -- max K 1 + 1 > 0
    have : (1 : ℝ) ≤ max K 1 := le_max_right _ _
    linarith
  · -- (1 + (max K 1 + 1)) / min 1 (max K 1 + 1) > K.
    have h_max_ge : (1 : ℝ) ≤ max K 1 := le_max_right _ _
    have h_v_ge_1 : (1 : ℝ) ≤ max K 1 + 1 := by linarith
    have h_min_eq : min (1 : ℝ) (max K 1 + 1) = 1 := min_eq_left h_v_ge_1
    rw [h_min_eq, div_one]
    -- 1 + (max K 1 + 1) = 2 + max K 1 ≥ 2 + K > K.
    have h_max_ge_K : K ≤ max K 1 := le_max_left _ _
    linarith

end TypeEAsymptotic

end MIP
