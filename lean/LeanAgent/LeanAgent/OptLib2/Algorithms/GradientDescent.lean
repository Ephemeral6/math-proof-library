/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: LeanAgent

# Gradient descent: O(1/T) convergence

Fixed-stepsize gradient descent for an `L`-smooth convex objective. After
`k + 1` iterations, the optimality gap is bounded by `‖x₀ - x*‖² / (2 (k+1) a)`.

## Main definitions

* `Gradient_Descent_fix_stepsize` — class packaging the GD algorithmic state.

## Main results

* `gd_sufficient_decrease` — single-step sufficient decrease for L-smooth `f`.
* `gradient_method` — O(1/T) convergence for L-smooth convex `f`.
-/

import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Order.Monotone.Basic
import Mathlib.Tactic
import LeanAgent.OptLib2.Basic.Defs
import LeanAgent.OptLib2.Basic.Smoothness
import LeanAgent.OptLib2.Basic.Convexity

namespace LeanAgent.OptLib2

open Set InnerProductSpace

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

/-- Fixed-stepsize gradient descent setup for the convex problem `min f`. -/
class Gradient_Descent_fix_stepsize (f : E → ℝ) (f' : E → E) (x0 : E) where
  /-- Iterates: `x : ℕ → E`. -/
  x : ℕ → E
  /-- Step size. -/
  a : ℝ
  /-- Lipschitz constant of the gradient. -/
  l : NNReal
  /-- `f'` is the gradient of `f` at every point. -/
  diff : ∀ x₁ : E, HasGradientAt f (f' x₁) x₁
  /-- `f'` is `l`-Lipschitz. -/
  smooth : LipschitzWith l f'
  /-- Recurrence: `x (k + 1) = x k - a • f' (x k)`. -/
  update : ∀ k : ℕ, x (k + 1) = x k - a • f' (x k)
  /-- Lipschitz constant is positive. -/
  hl : (l : ℝ) > 0
  /-- Step size is positive. -/
  step₁ : a > 0
  /-- Initial point. -/
  initial : x 0 = x0

variable {f : E → ℝ} {f' : E → E} {xm x₀ : E}
variable {alg : Gradient_Descent_fix_stepsize f f' x₀}

/-- **GD sufficient decrease.** Under L-smoothness with `a ≤ 1/l`, the GD step
`x ↦ x - a • f' x` decreases `f` by at least `(a/2) ‖f' x‖²`. -/
theorem gd_sufficient_decrease
    {f : E → ℝ} {f' : E → E} {l : NNReal} {a : ℝ}
    (h₁ : ∀ x : E, HasGradientAt f (f' x) x)
    (_h₂ : (l : ℝ) > 0) (ha₁ : (l : ℝ) ≤ 1 / a) (ha₂ : a > 0)
    (h₃ : LipschitzWith l f') :
    ∀ x : E, f (x - a • (f' x)) ≤ f x - a / 2 * ‖f' x‖ ^ 2 := by
  intro x
  set y := x - a • (f' x) with y_def
  have hyx : y - x = -a • (f' x) := by rw [y_def]; simp
  have hbound := descent_lemma_gradient_form h₁ h₃ x y
  have h_inner : inner ℝ (f' x) (y - x) = -a * ‖f' x‖ ^ 2 := by
    rw [hyx, inner_smul_right, real_inner_self_eq_norm_sq]
  have h_norm_sq : ‖y - x‖ ^ 2 = a ^ 2 * ‖f' x‖ ^ 2 := by
    rw [hyx, norm_smul, mul_pow, Real.norm_eq_abs, sq_abs]; ring
  rw [h_inner, h_norm_sq] at hbound
  have ha_pos : (0 : ℝ) < a := ha₂
  have hla : (l : ℝ) * a ≤ 1 := by
    have := mul_le_mul_of_nonneg_right ha₁ (le_of_lt ha_pos)
    rwa [one_div, inv_mul_cancel₀ (ne_of_gt ha_pos)] at this
  have h_coeff : (l : ℝ) / 2 * (a ^ 2 * ‖f' x‖ ^ 2) ≤ a / 2 * ‖f' x‖ ^ 2 := by
    have hsq : ‖f' x‖ ^ 2 ≥ 0 := sq_nonneg _
    have step : (l : ℝ) / 2 * a ^ 2 ≤ a / 2 := by
      have : (l : ℝ) * a * a ≤ 1 * a := mul_le_mul_of_nonneg_right hla (le_of_lt ha_pos)
      nlinarith [this]
    nlinarith [mul_le_mul_of_nonneg_right step hsq]
  linarith [hbound, h_coeff]

/-- A decreasing real sequence is bounded above by the average of its first
`n + 1` terms. -/
private lemma mono_sum_avg {b : ℕ → ℝ} (mono : ∀ k : ℕ, b (k + 1) ≤ b k) (n : ℕ) :
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
  rw [le_div_iff₀ hn_pos]
  linarith [hsum_bound]

/-- Convex first-order condition rearranged: `f x ≤ f y + ⟨f' x, x - y⟩`. -/
private lemma convex_lower_bound (h₁ : ∀ x₁ : E, HasGradientAt f (f' x₁) x₁)
    (hfun : ConvexOn ℝ univ f) (x y : E) :
    f x ≤ f y + inner ℝ (f' x) (x - y) := by
  have h := convex_first_order_condition (h := h₁ x) hfun (mem_univ x) y (mem_univ y)
  have inner_neg : inner ℝ (f' x) (y - x) = - inner ℝ (f' x) (x - y) := by
    rw [show y - x = -(x - y) from by abel, inner_neg_right]
  linarith [h, inner_neg]

/-- Per-step GD bound combining smoothness (descent step) and convexity (FOC). -/
private lemma point_descent_for_convex
    (hfun : ConvexOn ℝ univ f) (step₂ : alg.a ≤ 1 / alg.l) (k : ℕ) :
    f (alg.x (k + 1)) ≤ f xm + 1 / (2 * alg.a)
      * (‖alg.x k - xm‖ ^ 2 - ‖alg.x (k + 1) - xm‖ ^ 2) := by
  have ha_pos : (0 : ℝ) < alg.a := alg.step₁
  have hl_pos : (0 : ℝ) < (alg.l : ℝ) := alg.hl
  have hla : (alg.l : ℝ) ≤ 1 / alg.a := by
    rw [le_div_iff₀ ha_pos]
    rw [le_div_iff₀ hl_pos] at step₂
    linarith
  have hcvx := convex_lower_bound alg.diff hfun (alg.x k) xm
  have hdesc := gd_sufficient_decrease alg.diff hl_pos hla ha_pos alg.smooth (alg.x k)
  rw [← alg.update k] at hdesc
  have hxk1_minus_xm :
      alg.x (k + 1) - xm = (alg.x k - xm) - alg.a • f' (alg.x k) := by
    rw [alg.update k]; abel
  have hnorm_sq_xk1 : ‖alg.x (k + 1) - xm‖ ^ 2
      = ‖alg.x k - xm‖ ^ 2 - 2 * alg.a * inner ℝ (f' (alg.x k)) (alg.x k - xm)
        + alg.a ^ 2 * ‖f' (alg.x k)‖ ^ 2 := by
    rw [hxk1_minus_xm,
        show (alg.x k - xm) - alg.a • f' (alg.x k)
           = (alg.x k - xm) + (-alg.a) • f' (alg.x k) from by rw [neg_smul]; abel,
        norm_add_sq_real, real_inner_smul_right, norm_smul,
        Real.norm_eq_abs, mul_pow, sq_abs, real_inner_comm]
    ring
  have hexpand :
      1 / (2 * alg.a) * (‖alg.x k - xm‖ ^ 2 - ‖alg.x (k + 1) - xm‖ ^ 2)
        = inner ℝ (f' (alg.x k)) (alg.x k - xm) - alg.a / 2 * ‖f' (alg.x k)‖ ^ 2 := by
    rw [hnorm_sq_xk1]
    field_simp
    ring
  linarith [hcvx, hdesc, hexpand]

/-- Pure telescoping identity for `Σ (g k - g (k+1))`. -/
private lemma sum_diff_telescope {g : ℕ → ℝ} (n : ℕ) :
    (Finset.range (n + 1)).sum (fun k => g k - g (k + 1)) = g 0 - g (n + 1) := by
  induction n with
  | zero => simp
  | succ m ih =>
    rw [Finset.sum_range_succ, ih]
    ring

/-- Telescoping bound for the GD partial sums. -/
private lemma gd_telescope_sum
    (hfun : ConvexOn ℝ univ f) (step₂ : alg.a ≤ 1 / alg.l) (n : ℕ) :
    (Finset.range (n + 1)).sum (fun k => f (alg.x (k + 1)) - f xm)
      ≤ 1 / (2 * alg.a) * (‖x₀ - xm‖ ^ 2 - ‖alg.x (n + 1) - xm‖ ^ 2) := by
  have hpd : ∀ k : ℕ, f (alg.x (k + 1)) - f xm ≤
      1 / (2 * alg.a) * (‖alg.x k - xm‖ ^ 2 - ‖alg.x (k + 1) - xm‖ ^ 2) := by
    intro k
    have hpdk := point_descent_for_convex (alg := alg) (xm := xm) hfun step₂ k
    linarith
  have telescope :=
    sum_diff_telescope (g := fun k => ‖alg.x k - xm‖ ^ 2) n
  rw [alg.initial] at telescope
  calc (Finset.range (n + 1)).sum (fun k => f (alg.x (k + 1)) - f xm)
      ≤ (Finset.range (n + 1)).sum (fun k =>
          1 / (2 * alg.a) * (‖alg.x k - xm‖ ^ 2 - ‖alg.x (k + 1) - xm‖ ^ 2)) :=
        Finset.sum_le_sum (fun k _ => hpd k)
    _ = 1 / (2 * alg.a) *
          (Finset.range (n + 1)).sum
            (fun k => ‖alg.x k - xm‖ ^ 2 - ‖alg.x (k + 1) - xm‖ ^ 2) := by
          rw [← Finset.mul_sum]
    _ = 1 / (2 * alg.a) * (‖x₀ - xm‖ ^ 2 - ‖alg.x (n + 1) - xm‖ ^ 2) := by
          rw [telescope]

/-- **Gradient descent O(1/T) convergence.** For an L-smooth convex objective
with step `a ≤ 1/l`, after `k + 1` iterations the optimality gap satisfies
`f (x (k+1)) - f x* ≤ ‖x₀ - x*‖² / (2 (k+1) a)`. -/
theorem gradient_method (hfun : ConvexOn ℝ univ f) (step₂ : alg.a ≤ 1 / alg.l) :
    ∀ k : ℕ, f (alg.x (k + 1)) - f xm ≤ 1 / (2 * (k + 1) * alg.a) * ‖x₀ - xm‖ ^ 2 := by
  intro k
  have ha_pos : (0 : ℝ) < alg.a := alg.step₁
  have hl_pos : (0 : ℝ) < (alg.l : ℝ) := alg.hl
  have hla : (alg.l : ℝ) ≤ 1 / alg.a := by
    rw [le_div_iff₀ ha_pos]
    rw [le_div_iff₀ hl_pos] at step₂
    linarith
  have mono_f : ∀ j : ℕ, f (alg.x (j + 1)) ≤ f (alg.x j) := by
    intro j
    have hdesc := gd_sufficient_decrease alg.diff hl_pos hla ha_pos alg.smooth (alg.x j)
    rw [← alg.update j] at hdesc
    have h_nn : 0 ≤ alg.a / 2 * ‖f' (alg.x j)‖ ^ 2 := by positivity
    linarith
  set b : ℕ → ℝ := fun n => f (alg.x (n + 1)) - f xm with hb_def
  have b_mono : ∀ n : ℕ, b (n + 1) ≤ b n := by
    intro n
    simp only [hb_def]
    linarith [mono_f (n + 1)]
  have h_avg := mono_sum_avg b_mono k
  have h_sum :
      (Finset.range (k + 1)).sum b
        ≤ 1 / (2 * alg.a) * (‖x₀ - xm‖ ^ 2 - ‖alg.x (k + 1) - xm‖ ^ 2) := by
    show (Finset.range (k + 1)).sum (fun n => f (alg.x (n + 1)) - f xm) ≤ _
    exact gd_telescope_sum (alg := alg) hfun step₂ k
  have h_inv_nn : 0 ≤ 1 / (2 * alg.a) := by positivity
  have h_sq_nn : 0 ≤ ‖alg.x (k + 1) - xm‖ ^ 2 := sq_nonneg _
  have h_sum_bound :
      (Finset.range (k + 1)).sum b ≤ 1 / (2 * alg.a) * ‖x₀ - xm‖ ^ 2 := by
    nlinarith [h_sum, h_inv_nn, h_sq_nn]
  have hk1_pos : (0 : ℝ) < (k : ℝ) + 1 := by positivity
  push_cast
  calc f (alg.x (k + 1)) - f xm
      = b k := rfl
    _ ≤ (Finset.range (k + 1)).sum b / ((k : ℝ) + 1) := h_avg
    _ ≤ (1 / (2 * alg.a) * ‖x₀ - xm‖ ^ 2) / ((k : ℝ) + 1) :=
          (div_le_div_iff_of_pos_right hk1_pos).mpr h_sum_bound
    _ = 1 / (2 * ((k : ℝ) + 1) * alg.a) * ‖x₀ - xm‖ ^ 2 := by
          field_simp

end LeanAgent.OptLib2
