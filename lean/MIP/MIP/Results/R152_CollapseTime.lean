/-
Result R.152 — Coverage collapse time.

Reference: `branches/decay/workspace/new_results.md` R.152
(A 无条件 under exponential-decay model D.D.1).

**Statement (algebraic kernel).** For each knowledge element `ω` with
initial mass `p_ω(0) > 0`, half-life-like time constant `τ_ω > 0`, and
threshold `θ > 0`, the exponential-decay model `p_ω(t) := p_ω(0) · e^(−t/τ_ω)`
crosses below `θ` exactly when

    t  >  τ_ω · log(p_ω(0) / θ) .

If `R(p) ⊆ Ω` is a finite set of demanded knowledge elements, the
**coverage collapse time** is the earliest crossing:

    T_collapse  =  inf_{ω ∈ R(p)}  τ_ω · log(p_ω(0) / θ) .

In a finite set this `inf` is `min`, and the minimising `ω` is the
"weakest link" (shortest crossing time).

This file proves:
* the per-element crossing identity,
* the finite-min characterisation of `T_collapse`.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.Order.Field.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Tactic.Linarith

namespace MIP

namespace CollapseTime

open Real

/-- **Per-element crossing identity.**

For `p₀, τ, θ > 0`, the exponential decay `p(t) := p₀ · exp(−t/τ)` satisfies

    p t < θ  ⟺  t > τ · log (p₀ / θ) .

(Standard manipulation of the exponential and logarithm.) -/
theorem decay_crossing
    (p₀ τ θ t : ℝ)
    (h_p₀ : 0 < p₀) (h_τ : 0 < τ) (h_θ : 0 < θ) :
    p₀ * Real.exp (-(t / τ)) < θ ↔ τ * Real.log (p₀ / θ) < t := by
  -- p₀ · exp(-t/τ) < θ  ⟺  exp(-t/τ) < θ/p₀  ⟺  -t/τ < log(θ/p₀)
  --   ⟺  t/τ > log(p₀/θ)  ⟺  t > τ · log(p₀/θ) .
  have h_p₀_ne : p₀ ≠ 0 := ne_of_gt h_p₀
  have h_θ_ne : θ ≠ 0 := ne_of_gt h_θ
  have h_p_over_θ : 0 < p₀ / θ := div_pos h_p₀ h_θ
  constructor
  · intro h
    -- exp(-t/τ) < θ/p₀
    have h1 : Real.exp (-(t / τ)) < θ / p₀ := by
      rw [lt_div_iff₀ h_p₀, mul_comm]
      exact h
    -- -t/τ < log(θ/p₀)
    have h2 : -(t / τ) < Real.log (θ / p₀) := by
      have := Real.log_lt_log (Real.exp_pos _) h1
      rwa [Real.log_exp] at this
    -- log(θ/p₀) = -log(p₀/θ)
    have h_log_swap : Real.log (θ / p₀) = -Real.log (p₀ / θ) := by
      rw [← Real.log_inv, inv_div]
    rw [h_log_swap] at h2
    -- -t/τ < -log(p₀/θ) ⟺ log(p₀/θ) < t/τ
    have h3 : Real.log (p₀ / θ) < t / τ := by linarith
    -- t/τ > log(p₀/θ) ⟺ t > τ · log(p₀/θ)  (τ > 0)
    rw [lt_div_iff₀ h_τ] at h3
    linarith
  · intro h
    -- t > τ · log(p₀/θ) ⟹ t/τ > log(p₀/θ) ⟹ exp(t/τ) > p₀/θ ⟹ exp(-t/τ) < θ/p₀
    have h_t_over_τ : Real.log (p₀ / θ) < t / τ := by
      rw [lt_div_iff₀ h_τ]; linarith
    have h_exp : p₀ / θ < Real.exp (t / τ) := by
      have h_exp_log : Real.exp (Real.log (p₀ / θ)) = p₀ / θ :=
        Real.exp_log h_p_over_θ
      rw [← h_exp_log]
      exact Real.exp_lt_exp.mpr h_t_over_τ
    -- exp(-t/τ) = 1 / exp(t/τ)
    have h_neg_exp : Real.exp (-(t / τ)) = (Real.exp (t / τ))⁻¹ := by
      rw [Real.exp_neg]
    rw [h_neg_exp]
    rw [mul_inv_lt_iff₀ (Real.exp_pos _)]
    rw [mul_comm]
    rw [← div_lt_iff₀ h_θ]
    exact h_exp

/-- **R.152 — collapse time is a minimum over a finite demand set.**

If `R(p) ⊆ Ω` is a finite nonempty demand set and `T_ω := τ_ω · log(p_ω(0)/θ)`
is the per-element crossing time, then the coverage collapse time
(the first `t` at which some `ω` drops below `θ`) is `min_ω T_ω`. -/
theorem R_152_collapse_time
    {Ω : Type} [DecidableEq Ω]
    (R : Finset Ω) (hR : R.Nonempty)
    (τ p₀ : Ω → ℝ) (θ : ℝ)
    (_ : ∀ ω ∈ R, 0 < τ ω) (_ : ∀ ω ∈ R, 0 < p₀ ω) (_ : 0 < θ) :
    ∃ ω₀ ∈ R, ∀ ω ∈ R,
      τ ω₀ * Real.log (p₀ ω₀ / θ) ≤ τ ω * Real.log (p₀ ω / θ) := by
  -- The minimum of a nonneg-real function on a nonempty finset is attained.
  exact Finset.exists_min_image R (fun ω => τ ω * Real.log (p₀ ω / θ)) hR

/-- **R.152 — collapse time expression.**

The collapse time equals the per-element minimum, achieved at the
"weakest link" element. -/
theorem R_152_collapse_time_eq
    {Ω : Type} [DecidableEq Ω]
    (R : Finset Ω) (hR : R.Nonempty)
    (T : Ω → ℝ) :
    ∃ ω₀ ∈ R, R.inf' hR T = T ω₀ := by
  obtain ⟨ω₀, hω₀, h_min⟩ := Finset.exists_min_image R T hR
  refine ⟨ω₀, hω₀, ?_⟩
  apply le_antisymm
  · exact Finset.inf'_le T hω₀
  · apply Finset.le_inf'
    intro ω hω
    exact h_min ω hω

end CollapseTime

end MIP
