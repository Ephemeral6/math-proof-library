-- Source: optlib/Optlib/Algorithm/GD/GradientDescent.lean line 198 (full proof)
-- Theorem: gradient_method (O(1/T) convergence of GD for L-smooth convex f)
-- Layer 3, Item 11
--
-- NOTE: The external `Optlib` package is not available in this repository, so
-- the import is retargeted to the project's own *certified* re-implementation
-- under `LeanAgent.OptLib2.Basic.*` (Mathlib-based, sorry-free). All six
-- helper/proof obligations below — previously `sorry` line-count stubs — are
-- now fully proved by porting the bodies from
-- `LeanAgent/OptLib2/Algorithms/GradientDescent.lean`. The `inner` calls use
-- the current-Mathlib explicit-field form `inner ℝ _ _`.

import LeanAgent.OptLib2.Basic.Defs
import LeanAgent.OptLib2.Basic.Smoothness
import LeanAgent.OptLib2.Basic.Convexity

open LeanAgent.OptLib2

noncomputable section gradient_descent

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

class Gradient_Descent_fix_stepsize (f : E → ℝ) (f' : E → E) (x0 : E) where
  x : ℕ → E
  a : ℝ
  l : NNReal
  diff : ∀ x₁, HasGradientAt f (f' x₁) x₁
  smooth : LipschitzWith l f'
  update : ∀ k : ℕ, x (k + 1) = x k - a • f' (x k)
  hl : l > (0 : ℝ)
  step₁ : a > 0
  initial : x 0 = x0

open InnerProductSpace Set

variable {f : E → ℝ} {f' : E → E} {l : NNReal} {xm x₀ : E} {a : ℝ}
variable {alg : Gradient_Descent_fix_stepsize f f' x₀}

-- Helpers (proved below; ported from the project's certified OptLib2 proof).

omit [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E] in
lemma mono_sum_prop {g : ℕ → E} (mono : ∀ k : ℕ, f (g (k + 1)) ≤ f (g k)) :
    ∀ n : ℕ, (f (g (n + 1)) - f xm) ≤ (Finset.range (n + 1)).sum
    (fun (k : ℕ) ↦ f (g (k + 1)) - f xm) / (n + 1) := by
  intro n
  set b : ℕ → ℝ := fun k => f (g (k + 1)) - f xm with hb
  have hmono_b : ∀ k : ℕ, b (k + 1) ≤ b k := by
    intro k; simp only [hb]; linarith [mono (k + 1)]
  have hb_antitone : Antitone b := antitone_nat_of_succ_le hmono_b
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

lemma convex_function (h₁ : ∀ x₁ : E, HasGradientAt f (f' x₁) x₁)
    (hfun : ConvexOn ℝ Set.univ f) :
    ∀ x y, f x ≤ f y + inner ℝ (f' x) (x - y) := by
  intro x y
  have h := convex_first_order_condition (h := h₁ x) hfun (mem_univ x) y (mem_univ y)
  have inner_neg : inner ℝ (f' x) (y - x) = - inner ℝ (f' x) (x - y) := by
    rw [show y - x = -(x - y) from by abel, inner_neg_right]
  linarith [h, inner_neg]

lemma convex_lipschitz (h₁ : ∀ x₁ : E, HasGradientAt f (f' x₁) x₁)
    (_h₂ : l > (0 : ℝ)) (ha₁ : l ≤ 1 / a) (ha₂ : a > 0) (h₃ : LipschitzWith l f') :
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

lemma point_descent_for_convex (hfun : ConvexOn ℝ Set.univ f) (step₂ : alg.a ≤ 1 / alg.l) :
    ∀ k : ℕ, f (alg.x (k + 1)) ≤ f xm + 1 / ((2 : ℝ) * alg.a)
      * (‖alg.x k - xm‖ ^ 2 - ‖alg.x (k + 1) - xm‖ ^ 2) := by
  intro k
  have ha_pos : (0 : ℝ) < alg.a := alg.step₁
  have hl_pos : (0 : ℝ) < (alg.l : ℝ) := alg.hl
  have hla : (alg.l : ℝ) ≤ 1 / alg.a := by
    rw [le_div_iff₀ ha_pos]
    rw [le_div_iff₀ hl_pos] at step₂
    linarith
  have hcvx := convex_function alg.diff hfun (alg.x k) xm
  have hdesc := convex_lipschitz alg.diff hl_pos hla ha_pos alg.smooth (alg.x k)
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

-- Main theorem
lemma gradient_method (hfun : ConvexOn ℝ Set.univ f) (step₂ : alg.a ≤ 1 / alg.l) :
    ∀ k : ℕ, f (alg.x (k + 1)) - f xm ≤ 1 / (2 * (k + 1) * alg.a) * ‖x₀ - xm‖ ^ 2 := by
  intro k
  have ha_pos : (0 : ℝ) < alg.a := alg.step₁
  -- Monotone decrease of `f` along the iterates.
  have mono_f : ∀ j : ℕ, f (alg.x (j + 1)) ≤ f (alg.x j) := by
    intro j
    have hl_pos : (0 : ℝ) < (alg.l : ℝ) := alg.hl
    have hla : (alg.l : ℝ) ≤ 1 / alg.a := by
      rw [le_div_iff₀ ha_pos]; rw [le_div_iff₀ hl_pos] at step₂; linarith
    have hdesc := convex_lipschitz alg.diff hl_pos hla ha_pos alg.smooth (alg.x j)
    rw [← alg.update j] at hdesc
    have h_nn : 0 ≤ alg.a / 2 * ‖f' (alg.x j)‖ ^ 2 := by positivity
    linarith
  -- Telescoping identity for the squared-distance differences.
  have telescope_id : ∀ n : ℕ,
      (Finset.range (n + 1)).sum
          (fun j => ‖alg.x j - xm‖ ^ 2 - ‖alg.x (j + 1) - xm‖ ^ 2)
        = ‖alg.x 0 - xm‖ ^ 2 - ‖alg.x (n + 1) - xm‖ ^ 2 := by
    intro n
    induction n with
    | zero => simp
    | succ m ih => rw [Finset.sum_range_succ, ih]; ring
  -- `sum_prop`: telescoped bound on the partial sum of optimality gaps.
  have sum_prop : (Finset.range (k + 1)).sum (fun j => f (alg.x (j + 1)) - f xm)
      ≤ 1 / (2 * alg.a) * (‖x₀ - xm‖ ^ 2 - ‖alg.x (k + 1) - xm‖ ^ 2) := by
    have hpd : ∀ j : ℕ, f (alg.x (j + 1)) - f xm ≤
        1 / (2 * alg.a) * (‖alg.x j - xm‖ ^ 2 - ‖alg.x (j + 1) - xm‖ ^ 2) := by
      intro j
      have := point_descent_for_convex (alg := alg) (xm := xm) hfun step₂ j
      linarith
    calc (Finset.range (k + 1)).sum (fun j => f (alg.x (j + 1)) - f xm)
        ≤ (Finset.range (k + 1)).sum (fun j =>
            1 / (2 * alg.a) * (‖alg.x j - xm‖ ^ 2 - ‖alg.x (j + 1) - xm‖ ^ 2)) :=
          Finset.sum_le_sum (fun j _ => hpd j)
      _ = 1 / (2 * alg.a) * (Finset.range (k + 1)).sum
            (fun j => ‖alg.x j - xm‖ ^ 2 - ‖alg.x (j + 1) - xm‖ ^ 2) := by
            rw [← Finset.mul_sum]
      _ = 1 / (2 * alg.a) * (‖x₀ - xm‖ ^ 2 - ‖alg.x (k + 1) - xm‖ ^ 2) := by
            rw [telescope_id k, alg.initial]
  -- Drop the (nonnegative) trailing distance term.
  have h_sum_bound : (Finset.range (k + 1)).sum (fun j => f (alg.x (j + 1)) - f xm)
      ≤ 1 / (2 * alg.a) * ‖x₀ - xm‖ ^ 2 := by
    have h_inv_nn : 0 ≤ 1 / (2 * alg.a) := by positivity
    have h_sq_nn : 0 ≤ ‖alg.x (k + 1) - xm‖ ^ 2 := sq_nonneg _
    nlinarith [sum_prop, h_inv_nn, h_sq_nn]
  -- Average bound via the monotone-sum property.
  have h_avg := mono_sum_prop (f := f) (g := alg.x) (xm := xm) mono_f k
  have hk1_pos : (0 : ℝ) < (k : ℝ) + 1 := by positivity
  -- `h`: assemble the per-iterate O(1/T) bound.
  have h : f (alg.x (k + 1)) - f xm
      ≤ (1 / (2 * alg.a) * ‖x₀ - xm‖ ^ 2) / ((k : ℝ) + 1) :=
    le_trans h_avg ((div_le_div_iff_of_pos_right hk1_pos).mpr h_sum_bound)
  calc f (alg.x (k + 1)) - f xm
      ≤ (1 / (2 * alg.a) * ‖x₀ - xm‖ ^ 2) / ((k : ℝ) + 1) := h
    _ = 1 / (2 * ((k : ℝ) + 1) * alg.a) * ‖x₀ - xm‖ ^ 2 := by
          field_simp

end gradient_descent
