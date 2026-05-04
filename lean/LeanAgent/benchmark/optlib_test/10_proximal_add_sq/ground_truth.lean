-- Source: optlib/Optlib/Function/Proximal.lean line 512
-- Theorem: proximal_add_sq
-- Layer 2, Item 10 (substitute for projection firm-nonexpansiveness)

import Optlib.Function.Proximal

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable {x : E}

open Set InnerProductSpace

theorem proximal_add_sq (a : E) {l : ℝ} (lpos : 0 < l) (f : E → ℝ):
    ∀ z : E, prox_prop (fun x ↦ f x + l / 2 * ‖x - a‖ ^ 2) x z ↔
      prox_prop ((1 / (l + 1)) • f) ((1 / (l + 1)) • (x + l • a)) z := by
  intro z
  rw [prox_prop, prox_prop, isMinOn_univ_iff, isMinOn_univ_iff]
  have aux (v : E) : ‖v - (1 / (l + 1)) • (x + l • a)‖ ^ 2 / 2 =
      (l + 1)⁻¹ * (l / 2 * ‖v - a‖ ^ 2 + ‖v - x‖ ^ 2 / 2 + (((l + 1)⁻¹ * (‖x + l • a‖ ^ 2)
        - ‖x‖ ^ 2 - l * ‖a‖ ^ 2) / 2)) := by
    rw [div_mul_eq_mul_div, ← add_div, ← add_div, ← mul_div_assoc, div_left_inj']
    rw [norm_sub_sq_real, norm_smul, mul_pow, mul_add, sub_sub, mul_sub, ← mul_assoc, ← pow_two]
    rw [Real.norm_eq_abs, sq_abs, ← inv_eq_one_div, add_sub, add_sub_right_comm]
    rw [add_right_cancel_iff, norm_sub_sq_real, norm_sub_sq_real]
    rw [← mul_sub, mul_add, ← add_assoc, ← sub_sub, inner_smul_right]; simp
    rw [add_sub_right_comm]; simp; rw [mul_sub, ← add_sub_right_comm, ← add_sub_assoc]
    nth_rw 3 [← one_mul (‖v‖ ^ 2)]; rw [← add_mul, ← mul_assoc l, mul_comm l 2, sub_sub]
    rw [mul_assoc, ← mul_add, ← inner_smul_right _ _ l, ← inner_add_right]
    field_simp; rw [mul_comm]; simp
  constructor
  · intro cond y
    specialize cond y
    rw [aux, aux]; simp; rw [← mul_add, ← mul_add, mul_le_mul_left]
    linarith [cond]; simp; linarith
  · intro cond y
    specialize cond y
    rw [aux, aux] at cond; simp at cond; rw [← mul_add, ← mul_add, mul_le_mul_left] at cond
    linarith [cond]; simp; linarith
