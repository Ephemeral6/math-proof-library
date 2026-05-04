/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: LeanAgent

# Proximal operator: subgradient characterisation

The fundamental link between the proximal operator and the subdifferential:
for convex `f`, `u` is a proximal point of `f` at `x` iff `x - u` is a
subgradient of `f` at `u`.

## Main results

* `prox_iff_subderiv` — `prox_prop f x u ↔ x - u ∈ SubderivAt f u`.
-/

import Mathlib.Analysis.Convex.Function
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Tactic
import LeanAgent.OptLib2.Basic.Defs
import LeanAgent.OptLib2.Proximal.Defs

namespace LeanAgent.OptLib2

open Set

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
variable {x : E}

/-- **Proximal-subgradient characterisation.** For `f` convex on `univ`, `u`
is a proximal point of `f` at `x` iff `x - u` is a subgradient of `f` at `u`. -/
theorem prox_iff_subderiv (f : E → ℝ) (hfun : ConvexOn ℝ univ f) :
    ∀ u : E, prox_prop f x u ↔ x - u ∈ SubderivAt f u := by
  intro u
  refine ⟨?_, ?_⟩
  -- (→) Proximal minimum implies subgradient inequality.
  · intro hmin y
    by_cases hyu : y = u
    · simp [hyu]
    have hyu_ne : y - u ≠ 0 := sub_ne_zero.mpr hyu
    have hyu_norm_pos : 0 < ‖y - u‖ ^ 2 := by positivity
    by_contra Hcontr
    push_neg at Hcontr
    set L : ℝ := f u + inner ℝ (x - u) (y - u) - f y with hLdef
    have hL_pos : 0 < L := by simp only [hLdef]; linarith
    set t : ℝ := min 1 (L / ‖y - u‖ ^ 2) with htdef
    have t_pos : 0 < t := lt_min one_pos (div_pos hL_pos hyu_norm_pos)
    have t_le_one : t ≤ 1 := min_le_left _ _
    have t_div_bound : t ≤ L / ‖y - u‖ ^ 2 := min_le_right _ _
    have t_bound : t * ‖y - u‖ ^ 2 ≤ L := by
      have := mul_le_mul_of_nonneg_right t_div_bound (le_of_lt hyu_norm_pos)
      rwa [div_mul_cancel₀ L (ne_of_gt hyu_norm_pos)] at this
    set z : E := (1 - t) • u + t • y with hzdef
    have hmin_z := hmin z
    have hz_minus_x : z - x = (u - x) + t • (y - u) := by
      simp only [hzdef, sub_smul, one_smul, smul_sub]; abel
    have hnorm_sq : ‖z - x‖ ^ 2
        = ‖u - x‖ ^ 2 + 2 * t * inner ℝ (u - x) (y - u) + t ^ 2 * ‖y - u‖ ^ 2 := by
      rw [hz_minus_x, norm_add_sq_real, real_inner_smul_right, norm_smul,
          Real.norm_eq_abs, mul_pow, sq_abs]
      ring
    have h_convex : f z ≤ (1 - t) * f u + t * f y := by
      have ha : (0 : ℝ) ≤ 1 - t := by linarith
      have hb : (0 : ℝ) ≤ t := le_of_lt t_pos
      have hab : (1 - t) + t = 1 := by ring
      have key := hfun.2 (mem_univ u) (mem_univ y) ha hb hab
      simpa [hzdef, smul_eq_mul] using key
    have inner_neg_uxyu : inner ℝ (u - x) (y - u) = - inner ℝ (x - u) (y - u) := by
      rw [show u - x = -(x - u) from by abel, inner_neg_left]
    have step_combined :
        f u + ‖u - x‖ ^ 2 / 2
          ≤ (1 - t) * f u + t * f y + ‖u - x‖ ^ 2 / 2
              + t * inner ℝ (u - x) (y - u) + t ^ 2 / 2 * ‖y - u‖ ^ 2 := by
      calc f u + ‖u - x‖ ^ 2 / 2
          ≤ f z + ‖z - x‖ ^ 2 / 2 := hmin_z
        _ ≤ (1 - t) * f u + t * f y + ‖z - x‖ ^ 2 / 2 := by linarith
        _ = (1 - t) * f u + t * f y +
              (‖u - x‖ ^ 2 + 2 * t * inner ℝ (u - x) (y - u) + t ^ 2 * ‖y - u‖ ^ 2) / 2 := by
            rw [hnorm_sq]
        _ = (1 - t) * f u + t * f y + ‖u - x‖ ^ 2 / 2
              + t * inner ℝ (u - x) (y - u) + t ^ 2 / 2 * ‖y - u‖ ^ 2 := by ring
    have step_isolated :
        t * f u ≤ t * f y + t * inner ℝ (u - x) (y - u) + t ^ 2 / 2 * ‖y - u‖ ^ 2 := by
      linarith [step_combined]
    have step_tL : t * L ≤ t ^ 2 / 2 * ‖y - u‖ ^ 2 := by
      simp only [hLdef]
      nlinarith [step_isolated, inner_neg_uxyu]
    have t_sq_bound : t ^ 2 * ‖y - u‖ ^ 2 ≤ t * L := by
      have hrew : t ^ 2 * ‖y - u‖ ^ 2 = t * (t * ‖y - u‖ ^ 2) := by ring
      rw [hrew]
      exact mul_le_mul_of_nonneg_left t_bound (le_of_lt t_pos)
    have htL_half : t * L ≤ t * L / 2 := by linarith [step_tL, t_sq_bound]
    have htL_pos : 0 < t * L := mul_pos t_pos hL_pos
    linarith
  -- (←) Subgradient implies proximal minimum.
  · intro hsub z
    have hsub_z : f u + inner ℝ (x - u) (z - u) ≤ f z := hsub z
    have inner_swap : inner ℝ (z - u) (u - x) = - inner ℝ (x - u) (z - u) := by
      rw [show u - x = -(x - u) from by abel, inner_neg_right, real_inner_comm]
    have heq : z - x = (z - u) + (u - x) := by abel
    have hid : ‖z - x‖ ^ 2
        = ‖z - u‖ ^ 2 - 2 * inner ℝ (x - u) (z - u) + ‖u - x‖ ^ 2 := by
      calc ‖z - x‖ ^ 2 = ‖(z - u) + (u - x)‖ ^ 2 := by rw [heq]
        _ = ‖z - u‖ ^ 2 + 2 * inner ℝ (z - u) (u - x) + ‖u - x‖ ^ 2 :=
            norm_add_sq_real _ _
        _ = ‖z - u‖ ^ 2 - 2 * inner ℝ (x - u) (z - u) + ‖u - x‖ ^ 2 := by
            rw [inner_swap]; ring
    have h_norm_zu_nn : 0 ≤ ‖z - u‖ ^ 2 := sq_nonneg _
    linarith [hsub_z, hid, h_norm_zu_nn]

end LeanAgent.OptLib2
