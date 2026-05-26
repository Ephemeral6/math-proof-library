/-
Result R.96 (T.22) — Autonomous-transition time.

Reference: `workspace/new_results.md` R.96 (B 条件, but the (b) case
algebraic kernel is A 无条件 — pure exponential threshold crossing).

**Statement (case (b) algebraic core).** Under direct exponential decay
`Φ₀(t) := Φ₀_cov · exp(−α_Φ · (t − t_cov))` (with `Φ₀_cov, α_Φ, δ > 0`),
the autonomous-transition time `t_aut := min {t > t_cov : Φ₀(t) ≤ δ}`
satisfies

    t_aut − t_cov  =  (1/α_Φ) · log(Φ₀_cov / δ) .

(For values `δ ≥ Φ₀_cov`, `t_aut = t_cov` since the threshold is already
satisfied; the equation gives the first nontrivial crossing time.)

**Pure-math content.** Exponential threshold crossing:
`c · exp(−α x) ≤ δ ⟺ x ≥ (1/α) · log(c / δ)` for `c, α, δ > 0`.

This is the same algebraic content as the half-life kernel (R.156), just
applied to an arbitrary threshold `δ` instead of `c / 2`.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith

namespace MIP

namespace AutonomousTransition

open Real

/-- **R.96 (b) algebraic kernel — exponential threshold crossing.**

For `c, α, δ > 0`,  `c · exp(−α · x) ≤ δ  ⟺  x ≥ (1/α) · log(c/δ)`. -/
theorem exponential_threshold_crossing
    (c α δ x : ℝ) (h_c : 0 < c) (h_α : 0 < α) (h_δ : 0 < δ) :
    c * Real.exp (-(α * x)) ≤ δ ↔ Real.log (c / δ) / α ≤ x := by
  have h_c_ne : c ≠ 0 := ne_of_gt h_c
  have h_δ_ne : δ ≠ 0 := ne_of_gt h_δ
  have h_c_over_δ_pos : 0 < c / δ := div_pos h_c h_δ
  constructor
  · intro h
    -- c · exp(-α x) ≤ δ  ⟹  exp(-α x) ≤ δ/c  ⟹  -α x ≤ log(δ/c)
    --                  ⟹  -α x ≤ -log(c/δ)  ⟹  α x ≥ log(c/δ)
    have h1 : Real.exp (-(α * x)) ≤ δ / c := by
      rw [le_div_iff₀ h_c, mul_comm]; exact h
    have h2 : -(α * x) ≤ Real.log (δ / c) := by
      have := Real.log_le_log (Real.exp_pos _) h1
      rwa [Real.log_exp] at this
    have h_log_swap : Real.log (δ / c) = -Real.log (c / δ) := by
      rw [← Real.log_inv, inv_div]
    rw [h_log_swap] at h2
    -- -α x ≤ -log(c/δ) ⟹ α x ≥ log(c/δ) ⟹ x ≥ log(c/δ)/α (α > 0).
    have h3 : Real.log (c / δ) ≤ α * x := by linarith
    rw [div_le_iff₀ h_α]; linarith
  · intro h
    -- x ≥ log(c/δ)/α ⟹ α x ≥ log(c/δ) ⟹ exp(α x) ≥ c/δ ⟹ exp(-α x) ≤ δ/c.
    have h1 : Real.log (c / δ) ≤ α * x := by
      rw [div_le_iff₀ h_α] at h; linarith
    have h2 : c / δ ≤ Real.exp (α * x) := by
      have h_log_eq := Real.exp_log h_c_over_δ_pos
      rw [← h_log_eq]
      exact Real.exp_le_exp.mpr h1
    -- exp(-α x) = 1/exp(α x).
    have h_neg_exp : Real.exp (-(α * x)) = (Real.exp (α * x))⁻¹ :=
      Real.exp_neg _
    rw [h_neg_exp]
    rw [mul_inv_le_iff₀ (Real.exp_pos _)]
    rw [mul_comm]
    rw [← div_le_iff₀ h_δ]
    exact h2

/-- **R.96 (b) — autonomous-transition equation.**

If `Φ₀(t) = Φ₀_cov · exp(−α_Φ · (t − t_cov))` and we want
`Φ₀(t) ≤ δ`, then the minimum such `t − t_cov` is `log(Φ₀_cov/δ) / α_Φ`. -/
theorem R_96_t_aut_minus_t_cov
    (Phi0_cov α_Phi δ Δt : ℝ)
    (h_Phi0_cov : 0 < Phi0_cov) (h_α_Phi : 0 < α_Phi) (h_δ : 0 < δ) :
    Phi0_cov * Real.exp (-(α_Phi * Δt)) ≤ δ
      ↔ Real.log (Phi0_cov / δ) / α_Phi ≤ Δt :=
  exponential_threshold_crossing Phi0_cov α_Phi δ Δt h_Phi0_cov h_α_Phi h_δ

end AutonomousTransition

end MIP
