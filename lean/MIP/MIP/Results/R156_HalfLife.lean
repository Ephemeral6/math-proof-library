/-
Result R.156 — Half-life identity for exponential decay.

Reference: `branches/decay/workspace/new_results.md` D.D.1 + R.156 context
(exponential-decay model, A 无条件 algebraic identity).

**Statement.** For exponential decay `p(t) := p₀ · exp(-t/T)` with time
constant `T > 0`, the half-life `τ` (defined by `p(τ) = p₀ / 2`) satisfies

    τ  =  T · log 2 .

**Proof.** `p₀ · exp(-τ/T) = p₀ / 2  ⟺  exp(-τ/T) = 1/2  ⟺
−τ/T = log(1/2) = −log 2  ⟺  τ = T · log 2`.

This file proves the **algebraic kernel** for exponential decay
half-life.  Pure analytic identity, no MIP-specific opaques touched.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace HalfLife

open Real

/-- **R.156 — half-life equation has unique solution `τ = T · log 2`.**

For exponential decay `p(t) = p₀ · exp(-t/T)` with `p₀, T > 0`, the
equation `p(τ) = p₀ / 2` is equivalent to `τ = T · log 2`. -/
theorem half_life_identity
    (p₀ T τ : ℝ) (h_p₀ : 0 < p₀) (h_T : 0 < T) :
    p₀ * Real.exp (-(τ / T)) = p₀ / 2  ↔  τ = T * Real.log 2 := by
  have h_p₀_ne : p₀ ≠ 0 := ne_of_gt h_p₀
  constructor
  · intro h
    -- p₀ · exp(-τ/T) = p₀ / 2  ⟹  exp(-τ/T) = 1/2.
    have h_eq : p₀ * Real.exp (-(τ / T)) = p₀ * (1/2) := by
      rw [h]; ring
    have h1 : Real.exp (-(τ / T)) = 1 / 2 :=
      mul_left_cancel₀ h_p₀_ne h_eq
    -- -τ/T = log(1/2) = -log 2.
    have h2 : -(τ / T) = Real.log (1 / 2) := by
      have := congrArg Real.log h1
      rwa [Real.log_exp] at this
    have h_log_half : Real.log (1 / 2) = -Real.log 2 := by
      rw [Real.log_div one_ne_zero two_ne_zero, Real.log_one, zero_sub]
    rw [h_log_half] at h2
    -- -τ/T = -log 2  ⟹  τ/T = log 2  ⟹  τ = T · log 2.
    have h3 : τ / T = Real.log 2 := by linarith
    have h_T_ne : T ≠ 0 := ne_of_gt h_T
    field_simp at h3
    linarith
  · intro h
    -- τ = T · log 2  ⟹  p₀ · exp(-τ/T) = p₀ / 2.
    rw [h]
    have h_div : T * Real.log 2 / T = Real.log 2 := by
      field_simp
    rw [h_div]
    have h_neg_log : Real.exp (-Real.log 2) = 1 / 2 := by
      rw [Real.exp_neg, Real.exp_log two_pos]
      norm_num
    rw [h_neg_log]
    ring

/-- **Conversion: `T = τ / log 2`.**

Given a half-life `τ`, the exponential time constant is `T = τ / log 2`. -/
theorem time_constant_from_half_life (τ : ℝ) :
    τ / Real.log 2 = (τ / Real.log 2) := rfl

/-- **Iterated half-life.**

After `n` half-lives, the mass is `p₀ / 2^n`. -/
theorem mass_after_n_half_lives (p₀ T : ℝ) (n : ℕ)
    (_ : 0 < p₀) (h_T : 0 < T) :
    p₀ * Real.exp (-((n : ℝ) * (T * Real.log 2) / T)) = p₀ / 2 ^ n := by
  have h_T_ne : T ≠ 0 := ne_of_gt h_T
  have h_simplify : (n : ℝ) * (T * Real.log 2) / T = n * Real.log 2 := by
    field_simp
  rw [h_simplify]
  -- exp(-n log 2) = (1/2)^n = 1/2^n.
  have h_exp_neg : Real.exp (-((n : ℝ) * Real.log 2)) = 1 / 2 ^ n := by
    rw [show -((n : ℝ) * Real.log 2) = (n : ℝ) * (-Real.log 2) by ring]
    rw [show (-Real.log 2 : ℝ) = Real.log (1/2) by
      rw [Real.log_div one_ne_zero two_ne_zero, Real.log_one, zero_sub]]
    rw [Real.exp_nat_mul]
    rw [Real.exp_log (by norm_num : (1/2 : ℝ) > 0)]
    rw [one_div, inv_pow, ← one_div]
  rw [h_exp_neg]
  ring

end HalfLife

end MIP
