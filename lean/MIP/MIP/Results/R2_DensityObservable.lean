/-
Result R.2 — Knowledge density `Cₑ` is observable (estimable to any precision).

Reference: `proofs/derived/A_grade.md` R.2 (A 无条件 under A.3 + D.3.6).

**Statement.** The expertise-density quantity `Cₑ` (D.3.6) is observable:
there is an estimation algorithm approaching `Cₑ` to any precision.  The
proof rests on the statistical estimability of the total-variation distance
`d_TV` from empirical distributions, with sample error `O(n^{-1/2})`
(Glivenko–Cantelli rate).

**Pure-math kernel (Hypothesis-Bundle encoding).** The per-sample estimator
sequence `Cₑ_hat : ℕ → ℝ` comes with the bundled Glivenko–Cantelli rate
hypothesis

    |Cₑ_hat n − Cₑ| ≤ C / sqrt n        (for `n ≥ 1`, with `C ≥ 0`),

and we prove the **consistency** consequence

    Filter.Tendsto Cₑ_hat atTop (nhds Cₑ) ,

i.e. the estimate converges to the true knowledge density.  This is the
formal content of "Cₑ is observable": a consistent estimator exists.

The kernel: `C / sqrt n → 0` (since `sqrt n → ∞`), then a squeeze on the
error bound forces `Cₑ_hat n → Cₑ`.

**This file is `axiom`-free.**  The MIP-side machinery (A.3 regularity,
D.3.6 definition, `d_TV` estimability) enters only through the explicit
error-bound hypothesis.
-/
import Mathlib.Data.Real.Sqrt
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Order.Filter.Basic
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Tactic.Linarith

namespace MIP

namespace DensityObservable

open Filter Topology

/-- **Auxiliary: `C / sqrt n → 0` as `n → ∞`.**

Since `sqrt n → ∞` (along `atTop` of `ℕ`), the reciprocal `1 / sqrt n → 0`,
hence `C / sqrt n → 0` for any constant `C`. -/
theorem tendsto_const_div_sqrt (C : ℝ) :
    Tendsto (fun n : ℕ => C / Real.sqrt n) atTop (nhds 0) := by
  -- sqrt n → ∞
  have h_sqrt : Tendsto (fun n : ℕ => Real.sqrt n) atTop atTop := by
    have h_nat : Tendsto (fun n : ℕ => (n : ℝ)) atTop atTop :=
      tendsto_natCast_atTop_atTop
    exact Real.tendsto_sqrt_atTop.comp h_nat
  -- C / sqrt n = C * (sqrt n)⁻¹ → C * 0 = 0
  have h_inv : Tendsto (fun n : ℕ => (Real.sqrt n)⁻¹) atTop (nhds 0) :=
    h_sqrt.inv_tendsto_atTop
  have h_mul : Tendsto (fun n : ℕ => C * (Real.sqrt n)⁻¹) atTop (nhds (C * 0)) :=
    tendsto_const_nhds.mul h_inv
  simp only [mul_zero] at h_mul
  simpa [div_eq_mul_inv] using h_mul

/-- **R.2 — knowledge density `Cₑ` is observable (consistency of the estimator).**

Given an estimator sequence `Cₑ_hat : ℕ → ℝ` for the true density `Cₑ`, with
the bundled Glivenko–Cantelli rate `|Cₑ_hat n − Cₑ| ≤ C / sqrt n` for all
`n ≥ 1` (and `C ≥ 0`), the estimator is **consistent**:

    Cₑ_hat n → Cₑ    as `n → ∞`.

Hence `Cₑ` can be approached to any precision by sampling, i.e. it is an
observable quantity. -/
theorem R_2_density_observable
    (Cₑ_hat : ℕ → ℝ) (Cₑ C : ℝ)
    (_hC : 0 ≤ C)
    (h_rate : ∀ n : ℕ, 1 ≤ n → |Cₑ_hat n - Cₑ| ≤ C / Real.sqrt n) :
    Tendsto Cₑ_hat atTop (nhds Cₑ) := by
  -- It suffices to show the error `Cₑ_hat n − Cₑ → 0`.
  rw [← tendsto_sub_nhds_zero_iff]
  -- Squeeze `|Cₑ_hat n − Cₑ|` between `0` and `C / sqrt n → 0`.
  rw [tendsto_zero_iff_abs_tendsto_zero]
  apply squeeze_zero' (f := fun n : ℕ => |Cₑ_hat n - Cₑ|)
      (g := fun n : ℕ => C / Real.sqrt n)
  · -- 0 ≤ |Cₑ_hat n − Cₑ| eventually (in fact always).
    exact Eventually.of_forall (fun n => abs_nonneg _)
  · -- |Cₑ_hat n − Cₑ| ≤ C / sqrt n  eventually (for n ≥ 1).
    filter_upwards [eventually_ge_atTop 1] with n hn
    exact h_rate n hn
  · -- C / sqrt n → 0.
    exact tendsto_const_div_sqrt C

end DensityObservable

end MIP
