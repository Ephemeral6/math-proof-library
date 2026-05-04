/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: LeanAgent

# Proximal gradient method: O(1/T) convergence

Fixed-stepsize proximal gradient method on `min f + h`, with `f` convex and
`L`-smooth and `h` convex (continuous on the whole space). After `k` iterations,
the optimality gap is bounded by `‖x₀ - x*‖² / (2 k t)`.

## Main definitions

* `proximal_gradient_method` — class packaging the proximal-gradient state.

## Main results

* `proximal_gradient_method_converge` — O(1/T) convergence.
-/

import Mathlib.Analysis.Convex.Function
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Order.Monotone.Basic
import Mathlib.Tactic
import LeanAgent.OptLib2.Basic.Defs
import LeanAgent.OptLib2.Basic.Smoothness
import LeanAgent.OptLib2.Basic.Convexity
import LeanAgent.OptLib2.Proximal.Defs
import LeanAgent.OptLib2.Proximal.Properties

namespace LeanAgent.OptLib2

open Set InnerProductSpace

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

/-- Fixed-stepsize proximal gradient setup for `min f + h` with `f` convex
`L`-smooth and `h` convex. -/
class proximal_gradient_method (f h : E → ℝ) (f' : E → E) (x₀ : E) where
  /-- A minimizer of `f + h`. -/
  xm : E
  /-- Step size. -/
  t : ℝ
  /-- Iterates. -/
  x : ℕ → E
  /-- Lipschitz constant of the gradient of `f`. -/
  L : NNReal
  /-- `f` is convex. -/
  fconv : ConvexOn ℝ univ f
  /-- `h` is convex. -/
  hconv : ConvexOn ℝ univ h
  /-- `f'` is the gradient of `f`. -/
  h₁ : ∀ x₁ : E, HasGradientAt f (f' x₁) x₁
  /-- `f'` is `L`-Lipschitz. -/
  h₂ : LipschitzWith L f'
  /-- `h` is continuous on `univ`. -/
  h₃ : ContinuousOn h univ
  /-- `xm` minimises `f + h`. -/
  minphi : IsMinOn (f + h) Set.univ xm
  /-- Step size positive. -/
  tpos : 0 < t
  /-- Step size at most `1 / L`. -/
  step : t ≤ 1 / L
  /-- Initial point. -/
  ori : x 0 = x₀
  /-- Lipschitz constant positive. -/
  hL : (L : ℝ) > 0
  /-- Recurrence: `x (k + 1)` is the proximal point of `t • h` at `x k - t • f' (x k)`. -/
  update : ∀ k : ℕ, prox_prop (t • h) (x k - t • f' (x k)) (x (k + 1))

variable {f h : E → ℝ} {f' : E → E} {x₀ : E}
variable {alg : proximal_gradient_method f h f' x₀}

/-- **Per-step three-point inequality.** For any `z : E`,
`φ(x_{k+1}) ≤ φ(z) + (1/t) ⟨x_k - x_{k+1}, x_{k+1} - z⟩
  + (1/(2t)) ‖x_{k+1} - x_k‖²`. -/
private lemma phi_three_point (k : ℕ) (z : E) :
    f (alg.x (k + 1)) + h (alg.x (k + 1)) ≤ f z + h z
      + (1 / alg.t) * inner ℝ (alg.x k - alg.x (k + 1)) (alg.x (k + 1) - z)
      + (1 / (2 * alg.t)) * ‖alg.x (k + 1) - alg.x k‖ ^ 2 := by
  set xk := alg.x k with hxk
  set xk1 := alg.x (k + 1) with hxk1
  have htpos : (0 : ℝ) < alg.t := alg.tpos
  have hLpos : (0 : ℝ) < (alg.L : ℝ) := alg.hL
  have hdesc := descent_lemma_gradient_form alg.h₁ alg.h₂ xk xk1
  have h_tL_le_one : alg.t * (alg.L : ℝ) ≤ 1 := by
    have := alg.step
    rw [le_div_iff₀ hLpos] at this
    linarith
  have h_L_le_inv_t : (alg.L : ℝ) ≤ 1 / alg.t := by
    rw [le_div_iff₀ htpos]; linarith
  have h_norm_sq_nn : 0 ≤ ‖xk1 - xk‖ ^ 2 := sq_nonneg _
  have hLhalf : (alg.L : ℝ) / 2 ≤ 1 / (2 * alg.t) := by
    have h_inv_eq : (1 : ℝ) / (2 * alg.t) = (1 / alg.t) / 2 := by field_simp
    rw [h_inv_eq]; linarith
  have hdesc' : f xk1 ≤ f xk + inner ℝ (f' xk) (xk1 - xk)
      + (1 / (2 * alg.t)) * ‖xk1 - xk‖ ^ 2 := by
    have hmul := mul_le_mul_of_nonneg_right hLhalf h_norm_sq_nn
    linarith [hdesc, hmul]
  have hcvx_f := convex_first_order_condition
    (h := alg.h₁ xk) alg.fconv (mem_univ xk) z (mem_univ z)
  have hth_conv : ConvexOn ℝ univ (alg.t • h) := alg.hconv.smul (le_of_lt htpos)
  have hupdate : prox_prop (alg.t • h) (xk - alg.t • f' xk) xk1 := alg.update k
  rw [prox_iff_subderiv (alg.t • h) hth_conv xk1] at hupdate
  have hsub_z : (alg.t • h) xk1 + inner ℝ ((xk - alg.t • f' xk) - xk1) (z - xk1) ≤
      (alg.t • h) z := hupdate z
  simp only [Pi.smul_apply, smul_eq_mul] at hsub_z
  have h_inner_split :
      inner ℝ ((xk - alg.t • f' xk) - xk1) (z - xk1)
        = inner ℝ (xk - xk1) (z - xk1) - alg.t * inner ℝ (f' xk) (z - xk1) := by
    have hrw : (xk - alg.t • f' xk) - xk1 = (xk - xk1) - alg.t • f' xk := by abel
    rw [hrw, inner_sub_left, real_inner_smul_left]
  rw [h_inner_split] at hsub_z
  have h_step_h : h xk1 + (1 / alg.t) * inner ℝ (xk - xk1) (z - xk1)
      ≤ h z + inner ℝ (f' xk) (z - xk1) := by
    have ht_ne : alg.t ≠ 0 := ne_of_gt htpos
    have hmul_le : alg.t * (h xk1 + (1 / alg.t) * inner ℝ (xk - xk1) (z - xk1))
        ≤ alg.t * (h z + inner ℝ (f' xk) (z - xk1)) := by
      have hl_eq : alg.t * (h xk1 + (1 / alg.t) * inner ℝ (xk - xk1) (z - xk1))
          = alg.t * h xk1 + inner ℝ (xk - xk1) (z - xk1) := by field_simp
      have hr_eq : alg.t * (h z + inner ℝ (f' xk) (z - xk1))
          = alg.t * h z + alg.t * inner ℝ (f' xk) (z - xk1) := by ring
      rw [hl_eq, hr_eq]; linarith [hsub_z]
    exact le_of_mul_le_mul_left hmul_le htpos
  have h_inner_zero :
      inner ℝ (f' xk) (xk1 - xk) - inner ℝ (f' xk) (z - xk)
        + inner ℝ (f' xk) (z - xk1) = 0 := by
    have h1 : inner ℝ (f' xk) (xk1 - xk) - inner ℝ (f' xk) (z - xk)
        + inner ℝ (f' xk) (z - xk1)
        = inner ℝ (f' xk) ((xk1 - xk) - (z - xk) + (z - xk1)) := by
      rw [← inner_sub_right, ← inner_add_right]
    have hzero : (xk1 - xk) - (z - xk) + (z - xk1) = (0 : E) := by abel
    rw [h1, hzero, inner_zero_right]
  have h_inner_flip : inner ℝ (xk - xk1) (xk1 - z) = - inner ℝ (xk - xk1) (z - xk1) := by
    rw [show (xk1 - z : E) = -(z - xk1) from by abel, inner_neg_right]
  have h_inner_flip_t :
      (1 / alg.t) * inner ℝ (xk - xk1) (xk1 - z)
        = -(1 / alg.t) * inner ℝ (xk - xk1) (z - xk1) := by
    rw [h_inner_flip]; ring
  linarith [hdesc', hcvx_f, h_step_h, h_inner_zero, h_inner_flip_t]

/-- `φ` is monotone non-increasing along the iterates. -/
private lemma phi_monotone (k : ℕ) :
    f (alg.x (k + 1)) + h (alg.x (k + 1)) ≤ f (alg.x k) + h (alg.x k) := by
  have hps := phi_three_point (alg := alg) k (alg.x k)
  have h_inner :
      inner ℝ (alg.x k - alg.x (k + 1)) (alg.x (k + 1) - alg.x k)
        = - ‖alg.x k - alg.x (k + 1)‖ ^ 2 := by
    rw [show (alg.x (k + 1) - alg.x k : E) = -(alg.x k - alg.x (k + 1)) from by abel,
        inner_neg_right, real_inner_self_eq_norm_sq]
  have hnorm_sym :
      ‖alg.x (k + 1) - alg.x k‖ ^ 2 = ‖alg.x k - alg.x (k + 1)‖ ^ 2 := by
    rw [norm_sub_rev]
  rw [h_inner, hnorm_sym] at hps
  have htpos : (0 : ℝ) < alg.t := alg.tpos
  have h_norm_sq_nn : 0 ≤ ‖alg.x k - alg.x (k + 1)‖ ^ 2 := sq_nonneg _
  have h_inv_nn : 0 ≤ 1 / (2 * alg.t) := by positivity
  have hcoef : (1 / alg.t) * (- ‖alg.x k - alg.x (k + 1)‖ ^ 2)
      + (1 / (2 * alg.t)) * ‖alg.x k - alg.x (k + 1)‖ ^ 2
      = - (1 / (2 * alg.t)) * ‖alg.x k - alg.x (k + 1)‖ ^ 2 := by
    field_simp; ring
  have hsum_nn : (1 / alg.t) * (- ‖alg.x k - alg.x (k + 1)‖ ^ 2)
      + (1 / (2 * alg.t)) * ‖alg.x k - alg.x (k + 1)‖ ^ 2 ≤ 0 := by
    rw [hcoef]
    have := mul_nonneg h_inv_nn h_norm_sq_nn
    linarith
  linarith

/-- The per-step three-point inequality at `z = xm`, after polarisation. -/
private lemma phi_distance (k : ℕ) :
    f (alg.x (k + 1)) + h (alg.x (k + 1)) - f alg.xm - h alg.xm
      ≤ (1 / (2 * alg.t)) * (‖alg.x k - alg.xm‖ ^ 2 - ‖alg.x (k + 1) - alg.xm‖ ^ 2) := by
  have hps := phi_three_point (alg := alg) k alg.xm
  have hpolar :
      2 * inner ℝ (alg.x k - alg.x (k + 1)) (alg.x (k + 1) - alg.xm)
        = ‖alg.x k - alg.xm‖ ^ 2 - ‖alg.x k - alg.x (k + 1)‖ ^ 2
            - ‖alg.x (k + 1) - alg.xm‖ ^ 2 := by
    have hsum_eq :
        (alg.x k - alg.x (k + 1)) + (alg.x (k + 1) - alg.xm) = alg.x k - alg.xm := by abel
    have hexp := norm_add_sq_real (alg.x k - alg.x (k + 1)) (alg.x (k + 1) - alg.xm)
    rw [hsum_eq] at hexp
    linarith
  have hnorm_sym : ‖alg.x k - alg.x (k + 1)‖ ^ 2 = ‖alg.x (k + 1) - alg.x k‖ ^ 2 := by
    rw [show (alg.x k - alg.x (k + 1) : E) = -(alg.x (k + 1) - alg.x k) from by abel,
        norm_neg]
  rw [hnorm_sym] at hpolar
  have htpos : (0 : ℝ) < alg.t := alg.tpos
  have h_inner_eq :
      inner ℝ (alg.x k - alg.x (k + 1)) (alg.x (k + 1) - alg.xm)
        = (1 / 2) * (‖alg.x k - alg.xm‖ ^ 2 - ‖alg.x (k + 1) - alg.x k‖ ^ 2
            - ‖alg.x (k + 1) - alg.xm‖ ^ 2) := by
    linarith
  rw [h_inner_eq] at hps
  have ht_inv_nn : 0 ≤ 1 / (2 * alg.t) := by positivity
  have hcoef :
      (1 / alg.t) * ((1 / 2) * (‖alg.x k - alg.xm‖ ^ 2 - ‖alg.x (k + 1) - alg.x k‖ ^ 2
              - ‖alg.x (k + 1) - alg.xm‖ ^ 2))
        + (1 / (2 * alg.t)) * ‖alg.x (k + 1) - alg.x k‖ ^ 2
        = (1 / (2 * alg.t)) * (‖alg.x k - alg.xm‖ ^ 2 - ‖alg.x (k + 1) - alg.xm‖ ^ 2) := by
    field_simp; ring
  linarith [hps, hcoef]

/-- Pure telescoping identity. -/
private lemma sum_diff_telescope_pgm {g : ℕ → ℝ} (n : ℕ) :
    (Finset.range (n + 1)).sum (fun k => g k - g (k + 1)) = g 0 - g (n + 1) := by
  induction n with
  | zero => simp
  | succ m ih =>
    rw [Finset.sum_range_succ, ih]; ring

/-- Telescoped bound on the cumulative cost-deficit sum. -/
private lemma sum_phi_bound (n : ℕ) :
    (Finset.range (n + 1)).sum
      (fun k => f (alg.x (k + 1)) + h (alg.x (k + 1)) - f alg.xm - h alg.xm)
      ≤ (1 / (2 * alg.t)) * (‖x₀ - alg.xm‖ ^ 2 - ‖alg.x (n + 1) - alg.xm‖ ^ 2) := by
  have hpd : ∀ k : ℕ,
      f (alg.x (k + 1)) + h (alg.x (k + 1)) - f alg.xm - h alg.xm
        ≤ (1 / (2 * alg.t)) * (‖alg.x k - alg.xm‖ ^ 2 - ‖alg.x (k + 1) - alg.xm‖ ^ 2) :=
    fun k => phi_distance (alg := alg) k
  have htel := sum_diff_telescope_pgm (g := fun k => ‖alg.x k - alg.xm‖ ^ 2) n
  rw [alg.ori] at htel
  calc (Finset.range (n + 1)).sum
        (fun k => f (alg.x (k + 1)) + h (alg.x (k + 1)) - f alg.xm - h alg.xm)
      ≤ (Finset.range (n + 1)).sum
          (fun k => (1 / (2 * alg.t)) *
            (‖alg.x k - alg.xm‖ ^ 2 - ‖alg.x (k + 1) - alg.xm‖ ^ 2)) :=
        Finset.sum_le_sum (fun k _ => hpd k)
    _ = (1 / (2 * alg.t)) *
          (Finset.range (n + 1)).sum
            (fun k => ‖alg.x k - alg.xm‖ ^ 2 - ‖alg.x (k + 1) - alg.xm‖ ^ 2) := by
          rw [← Finset.mul_sum]
    _ = (1 / (2 * alg.t)) * (‖x₀ - alg.xm‖ ^ 2 - ‖alg.x (n + 1) - alg.xm‖ ^ 2) := by
          rw [htel]

/-- A decreasing real sequence is bounded above by the average of its first
`n + 1` terms. -/
private lemma mono_sum_avg_pgm {b : ℕ → ℝ} (mono : ∀ k : ℕ, b (k + 1) ≤ b k) (n : ℕ) :
    b n ≤ (Finset.range (n + 1)).sum b / (n + 1) := by
  have hb_antitone : Antitone b := antitone_nat_of_succ_le mono
  have hsum_bound :
      (Finset.range (n + 1)).sum (fun _ : ℕ => b n) ≤ (Finset.range (n + 1)).sum b := by
    apply Finset.sum_le_sum
    intro k hk
    rw [Finset.mem_range] at hk
    exact hb_antitone (Nat.lt_succ_iff.mp hk)
  have hcard : (Finset.range (n + 1)).sum (fun _ : ℕ => b n) = ((n : ℝ) + 1) * b n := by
    rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul, Nat.cast_add, Nat.cast_one]
  rw [hcard] at hsum_bound
  have hn_pos : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  rw [le_div_iff₀ hn_pos]; linarith [hsum_bound]

/-- Convergence stated for `k : ℕ` (predecessor form). -/
private lemma proximal_gradient_method_converge_aux (k : ℕ) :
    f (alg.x (k + 1)) + h (alg.x (k + 1)) - f alg.xm - h alg.xm
      ≤ 1 / (2 * ((k : ℝ) + 1) * alg.t) * ‖x₀ - alg.xm‖ ^ 2 := by
  set b : ℕ → ℝ := fun n =>
    f (alg.x (n + 1)) + h (alg.x (n + 1)) - f alg.xm - h alg.xm with hb_def
  have b_mono : ∀ n : ℕ, b (n + 1) ≤ b n := by
    intro n
    simp only [hb_def]
    linarith [phi_monotone (alg := alg) (n + 1)]
  have h_avg : b k ≤ (Finset.range (k + 1)).sum b / ((k : ℝ) + 1) :=
    mono_sum_avg_pgm b_mono k
  have hatpos : (0 : ℝ) < alg.t := alg.tpos
  have h_sum_bound :
      (Finset.range (k + 1)).sum b
        ≤ (1 / (2 * alg.t)) * ‖x₀ - alg.xm‖ ^ 2 := by
    have h := sum_phi_bound (alg := alg) k
    have h_sq_nn : 0 ≤ ‖alg.x (k + 1) - alg.xm‖ ^ 2 := sq_nonneg _
    have h_inv_nn : 0 ≤ 1 / (2 * alg.t) := by positivity
    nlinarith [h, h_inv_nn, h_sq_nn]
  have hk1_pos : (0 : ℝ) < (k : ℝ) + 1 := by positivity
  calc f (alg.x (k + 1)) + h (alg.x (k + 1)) - f alg.xm - h alg.xm
      = b k := rfl
    _ ≤ (Finset.range (k + 1)).sum b / ((k : ℝ) + 1) := h_avg
    _ ≤ ((1 / (2 * alg.t)) * ‖x₀ - alg.xm‖ ^ 2) / ((k : ℝ) + 1) :=
        (div_le_div_iff_of_pos_right hk1_pos).mpr h_sum_bound
    _ = 1 / (2 * ((k : ℝ) + 1) * alg.t) * ‖x₀ - alg.xm‖ ^ 2 := by
        have ht_ne : alg.t ≠ 0 := ne_of_gt hatpos
        have hk1_ne : (k : ℝ) + 1 ≠ 0 := ne_of_gt hk1_pos
        field_simp

/-- **Proximal gradient O(1/T) convergence.** After `k` proximal-gradient
steps, the cost gap is `O(1/(k·t))`. -/
theorem proximal_gradient_method_converge :
    ∀ k : ℕ+,
      f (alg.x k) + h (alg.x k) - f alg.xm - h alg.xm
        ≤ 1 / (2 * (k : ℝ) * alg.t) * ‖x₀ - alg.xm‖ ^ 2 := by
  rintro ⟨n, hn_pos⟩
  rcases Nat.exists_eq_succ_of_ne_zero hn_pos.ne' with ⟨k, hk_eq⟩
  subst hk_eq
  have aux := proximal_gradient_method_converge_aux (alg := alg) k
  have hcast : (((⟨k + 1, hn_pos⟩ : ℕ+) : ℕ) : ℝ) = (k : ℝ) + 1 := by
    push_cast; rfl
  show f (alg.x (k + 1)) + h (alg.x (k + 1)) - f alg.xm - h alg.xm
      ≤ 1 / (2 * (((⟨k + 1, hn_pos⟩ : ℕ+) : ℕ) : ℝ) * alg.t) * ‖x₀ - alg.xm‖ ^ 2
  rw [hcast]
  exact aux

end LeanAgent.OptLib2
