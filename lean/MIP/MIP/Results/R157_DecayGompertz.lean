/-
Result R.157 — Decay-modified Gompertz steady state.

Reference: `branches/decay/workspace/new_results.md` R.157
(A 无条件 algebraic kernel under R.98 Gompertz + D.D.2 decay).

**Statement (algebraic kernel).** The ODE
`dκ/dt = α · κ · |log κ| − (2/τ̄) · κ` has unique nontrivial steady
state `κ* > 0` characterised by `α · |log κ*| = 2/τ̄`, i.e.

    κ*  =  exp(−2 / (α · τ̄)) .

**Critical condition.** `κ* = 1/e ⟺ α · τ̄ = 2` (the R.98 inflection
point).  `α · τ̄ > 2 ⟹ κ* > 1/e`; `α · τ̄ < 2 ⟹ κ* < 1/e`.

This file proves the **algebraic identity for the steady state** plus
the critical-condition characterisation.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace DecayGompertz

open Real

/-- **R.157 — steady-state identity (algebraic core).**

If `κ*` satisfies `α · |log κ*| = 2/τ̄` with `α, τ̄ > 0` and `0 < κ* < 1`
(so `log κ* < 0`, `|log κ*| = -log κ*`), then `κ* = exp(-2/(α·τ̄))`. -/
theorem R_157_steady_state
    (α τ_bar κ_star : ℝ)
    (h_α_pos : 0 < α) (h_τ_pos : 0 < τ_bar)
    (h_κ_pos : 0 < κ_star) (h_κ_lt_1 : κ_star < 1)
    (h_balance : α * |Real.log κ_star| = 2 / τ_bar) :
    κ_star = Real.exp (-(2 / (α * τ_bar))) := by
  have h_log_neg : Real.log κ_star < 0 :=
    Real.log_neg h_κ_pos h_κ_lt_1
  have h_abs : |Real.log κ_star| = -Real.log κ_star :=
    abs_of_neg h_log_neg
  rw [h_abs] at h_balance
  -- α · (-log κ*) = 2/τ̄  ⟹  log κ* = -2/(α·τ̄)  ⟹  κ* = exp(-2/(α·τ̄)).
  have h_α_ne : α ≠ 0 := ne_of_gt h_α_pos
  have h_log_eq : Real.log κ_star = -(2 / (α * τ_bar)) := by
    have h_step : α * Real.log κ_star = -(2 / τ_bar) := by linarith
    have h_div : Real.log κ_star = -(2 / τ_bar) / α := by
      field_simp at h_step ⊢
      linarith
    rw [h_div]
    field_simp
  have h_exp_log : Real.exp (Real.log κ_star) = κ_star :=
    Real.exp_log h_κ_pos
  rw [← h_exp_log, h_log_eq]

/-- **R.157 — critical condition `κ* = 1/e ⟺ α · τ̄ = 2`.**

Plugging `α · τ̄ = 2` into the steady-state formula gives
`κ* = exp(-1) = 1/e`. -/
theorem R_157_critical_value
    (α τ_bar : ℝ) (h_critical : α * τ_bar = 2) :
    Real.exp (-(2 / (α * τ_bar))) = Real.exp (-1) := by
  rw [h_critical]
  congr 1
  norm_num

/-- **R.157 — high-decay regime `α·τ̄ < 2 ⟹ κ* < 1/e`.**

Smaller `α·τ̄` ⟹ larger `2/(α·τ̄)` ⟹ smaller `exp(-...)`. -/
theorem R_157_high_decay
    (α τ_bar : ℝ)
    (h_α_pos : 0 < α) (h_τ_pos : 0 < τ_bar)
    (h_lt : α * τ_bar < 2) :
    Real.exp (-(2 / (α * τ_bar))) < Real.exp (-1) := by
  have h_prod_pos : 0 < α * τ_bar := mul_pos h_α_pos h_τ_pos
  have h_gt : 2 / (α * τ_bar) > 1 := by
    rw [gt_iff_lt, lt_div_iff₀ h_prod_pos]
    linarith
  apply Real.exp_lt_exp.mpr
  linarith

/-- **R.157 — high-learning regime `α·τ̄ > 2 ⟹ κ* > 1/e`.** -/
theorem R_157_high_learning
    (α τ_bar : ℝ)
    (h_α_pos : 0 < α) (h_τ_pos : 0 < τ_bar)
    (h_gt : 2 < α * τ_bar) :
    Real.exp (-1) < Real.exp (-(2 / (α * τ_bar))) := by
  have h_prod_pos : 0 < α * τ_bar := mul_pos h_α_pos h_τ_pos
  have h_lt : 2 / (α * τ_bar) < 1 := by
    rw [div_lt_iff₀ h_prod_pos]
    linarith
  apply Real.exp_lt_exp.mpr
  linarith

end DecayGompertz

end MIP
