-- Source: optlib/Optlib/Function/Proximal.lean line 414
-- Theorem: proximal_shift
-- Layer 2, Item 09 (substitute for Fenchel involution)

import Optlib.Function.Proximal

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable {x : E}

open Set InnerProductSpace

theorem proximal_shift (a : E) {t : ℝ} (tnz : t ≠ 0) (f : E → ℝ):
    ∀ z : E, prox_prop (fun x ↦ f (t • x + a)) x z ↔
      prox_prop (t ^ 2 • f) (t • x + a) (t • z + a) := by
  intro z
  rw [prox_prop, prox_prop, isMinOn_univ_iff, isMinOn_univ_iff]
  simp
  constructor
  · intro cond y
    specialize cond (t⁻¹ • (y - a))
    rw [← smul_assoc, smul_eq_mul, mul_inv_cancel₀] at cond
    simp at cond
    calc
      t ^ 2 * f (t • z + a) + ‖t • z - t • x‖ ^ 2 / 2 =
          t ^ 2 * (f (t • z + a) + ‖z - x‖ ^ 2 / 2) := by
        rw [← smul_sub, norm_smul, mul_pow, mul_add]; field_simp
      _ ≤ t ^ 2 * (f y + ‖t⁻¹ • (y - a) - x‖ ^ 2 / 2) := by
        rw [mul_le_mul_left]; use cond; rw [sq_pos_iff]; use tnz
      _ = t ^ 2 * f y + ‖t • ((1 / t) • (y - a) - x)‖ ^ 2 / 2 := by
        rw [mul_add, norm_smul, mul_pow]; field_simp
      _ = t ^ 2 * f y + ‖y - (t • x + a)‖ ^ 2 / 2 := by
        rw [smul_sub, ← smul_assoc, smul_eq_mul, ← sub_sub, sub_right_comm]; field_simp
    use tnz
  · intro cond y
    specialize cond (t • y + a)
    rw [← smul_sub, norm_smul, mul_pow] at cond; simp at cond
    rw [← smul_sub, norm_smul, mul_pow] at cond; simp at cond
    rw [mul_div_assoc, ← mul_add, mul_div_assoc, ← mul_add] at cond
    rw [mul_le_mul_left] at cond; use cond; rw [sq_pos_iff]; use tnz
