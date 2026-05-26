/-
Result R.75 — Empirical measurement formula for the collaboration-asymmetry
index ξ (estimator consistency).

Reference: `workspace/new_results.md` R.75 (B 级; deps R.70, R.71, C.11;
limited by Cj.1 / Cj.2 uncomputability).

**Statement.** R.71 introduces the collaboration-asymmetry index ξ; R.75 gives
the empirical estimator

    ξ_est(p, A, H) := N(A,H) · N(H,A) / |B(p)|² − 1 ,

obtained by measuring the two one-directional collaboration costs `N(A,H)`,
`N(H,A)` and the barrier count `|B(p)|`. R.75 is graded **B** because the
exact measurement of `N(p, A, H)` lies in the Cj.2-uncomputable régime and
`|B(p)|` partitioning lies in the Cj.1 régime; only on the **computable
sub-domain** (where empirical upper bounds and barrier estimates are
available) is ξ_est usable. The substantive, formalizable claim is that on
this computable sub-domain the estimator is **consistent**: the per-sample
estimate `ξ̂ₙ` converges to the true ξ as the sample size grows.

**Pure-math kernel (this file, R.2 / R.42 consistent-estimator pattern).**
The estimator sequence `ξ̂ : ℕ → ℝ` comes with the bundled finite-sample error
bound (Glivenko–Cantelli / plug-in rate on the computable sub-domain)

    |ξ̂ₙ − ξ| ≤ C / sqrt n        (for `n ≥ 1`, with `C ≥ 0`),

and we prove the consistency consequence

    Filter.Tendsto ξ̂ atTop (nhds ξ) ,

i.e. the measurement formula is consistent: ξ̂ₙ → ξ. The kernel is identical
to R.2: `C / sqrt n → 0`, then a squeeze on the error bound.

We additionally record the Type S/B/E sign reading of the limit (ξ ≥ 0; ξ = 0
⟺ symmetric Type S), and a relaxed `o(1)`-rate version (any error sequence
tending to 0 yields consistency), so the result is not tied to the specific
`1/√n` rate.

**This file is `axiom`-free.** The MIP-side machinery (R.70 quantitative
uncertainty, R.71 definition of ξ, C.11, and the Cj.1/Cj.2-restricted
estimability of `N`, `|B(p)|`) enters only through the explicit error-bound
hypothesis.
-/
import Mathlib.Data.Real.Sqrt
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Order.Filter.Basic
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Tactic.Linarith

namespace MIP

namespace XiMeasurement

open Filter Topology

/-- **Auxiliary: `C / sqrt n → 0` as `n → ∞`.**

Since `sqrt n → ∞` (along `atTop` of `ℕ`), the reciprocal `(sqrt n)⁻¹ → 0`,
hence `C / sqrt n → 0` for any constant `C`. (Same kernel as R.2.) -/
theorem tendsto_const_div_sqrt (C : ℝ) :
    Tendsto (fun n : ℕ => C / Real.sqrt n) atTop (nhds 0) := by
  have h_sqrt : Tendsto (fun n : ℕ => Real.sqrt n) atTop atTop := by
    have h_nat : Tendsto (fun n : ℕ => (n : ℝ)) atTop atTop :=
      tendsto_natCast_atTop_atTop
    exact Real.tendsto_sqrt_atTop.comp h_nat
  have h_inv : Tendsto (fun n : ℕ => (Real.sqrt n)⁻¹) atTop (nhds 0) :=
    h_sqrt.inv_tendsto_atTop
  have h_mul : Tendsto (fun n : ℕ => C * (Real.sqrt n)⁻¹) atTop (nhds (C * 0)) :=
    tendsto_const_nhds.mul h_inv
  simp only [mul_zero] at h_mul
  simpa [div_eq_mul_inv] using h_mul

/-- **R.75 — ξ-measurement consistency (Glivenko–Cantelli rate).**

Given an estimator sequence `ξ̂ : ℕ → ℝ` for the true asymmetry index `ξ`
(computed from empirical `N(A,H)·N(H,A)/|B|² − 1` on the computable
sub-domain), with the bundled finite-sample error bound
`|ξ̂ₙ − ξ| ≤ C / sqrt n` for all `n ≥ 1` (and `C ≥ 0`), the estimator is
**consistent**:

    ξ̂ₙ → ξ    as `n → ∞`.

Hence the empirical measurement formula recovers ξ to any precision on the
computable sub-domain. -/
theorem R_75_xi_measurement_consistent
    (xiHat : ℕ → ℝ) (xi C : ℝ)
    (_hC : 0 ≤ C)
    (h_rate : ∀ n : ℕ, 1 ≤ n → |xiHat n - xi| ≤ C / Real.sqrt n) :
    Tendsto xiHat atTop (nhds xi) := by
  rw [← tendsto_sub_nhds_zero_iff]
  rw [tendsto_zero_iff_abs_tendsto_zero]
  apply squeeze_zero' (f := fun n : ℕ => |xiHat n - xi|)
      (g := fun n : ℕ => C / Real.sqrt n)
  · exact Eventually.of_forall (fun n => abs_nonneg _)
  · filter_upwards [eventually_ge_atTop 1] with n hn
    exact h_rate n hn
  · exact tendsto_const_div_sqrt C

/-- **R.75 — ξ-measurement consistency (general `o(1)` rate).**

The consistency conclusion does not depend on the specific `1/√n` rate: any
nonnegative error-bound sequence `err n` with `err n → 0` and
`|ξ̂ₙ − ξ| ≤ err n` already forces `ξ̂ₙ → ξ`. This decouples R.75 from the
particular sampling scheme. -/
theorem R_75_xi_measurement_consistent_of_rate
    (xiHat : ℕ → ℝ) (xi : ℝ) (err : ℕ → ℝ)
    (_h_err_nonneg : ∀ n : ℕ, 0 ≤ err n)
    (h_err_to_zero : Tendsto err atTop (nhds 0))
    (h_bound : ∀ n : ℕ, |xiHat n - xi| ≤ err n) :
    Tendsto xiHat atTop (nhds xi) := by
  rw [← tendsto_sub_nhds_zero_iff]
  rw [tendsto_zero_iff_abs_tendsto_zero]
  apply squeeze_zero' (f := fun n : ℕ => |xiHat n - xi|) (g := err)
  · exact Eventually.of_forall (fun n => abs_nonneg _)
  · exact Eventually.of_forall h_bound
  · exact h_err_to_zero

/-- **R.75 — sign reading transfers to the limit (Type S/B/E classification).**

The estimator interpretation `ξ_est ≥ 0` (R.70 lower bound: `N→·N← ≥ |B|²`,
so `N→·N←/|B|² − 1 ≥ 0`) passes to the limit: if every estimate satisfies
`ξ̂ₙ ≥ 0` and `ξ̂ₙ → ξ`, then the true index `ξ ≥ 0`. In particular the
"Type S ⟺ ξ = 0 symmetric barriers" boundary is well-defined as the lower
endpoint of the consistent estimates. -/
theorem R_75_xi_nonneg_limit
    (xiHat : ℕ → ℝ) (xi : ℝ)
    (h_nonneg : ∀ n : ℕ, 0 ≤ xiHat n)
    (h_lim : Tendsto xiHat atTop (nhds xi)) :
    0 ≤ xi :=
  le_of_tendsto_of_tendsto' tendsto_const_nhds h_lim h_nonneg

end XiMeasurement

end MIP
