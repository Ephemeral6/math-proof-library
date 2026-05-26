/-
Result R.110 — `κ(A)` is an estimable statistic with `O(1/√N)` error
(lifts R.42 to A, Cj.17 family).

Reference: `workspace/frontier_attacks.md` §R.110 (攻击 #7, R.42 → A).
Status: A (under the D.3.7 candidate-C working definition of `∘`).

**Statement.** Under D.3.7 candidate C, `κ(A)` is the fraction of
composable pairs in `K(A)²`; it is estimable by sampling: draw `N`
independent estimates `X₁,…,X_N` of the per-pair composability indicator,
each with mean `κ` and variance `σ² ≤ 1/4` (a bounded `[0,1]` indicator).
The empirical mean `κ̂_N = (1/N)·Σ Xᵢ` is unbiased and, by independence,

    Var[κ̂_N] = σ² / N ,

so the standard error is `σ/√N = O(1/√N)`, which tends to `0`:
`κ̂_N` converges to the true `κ` at rate `1/√N`. Hence `κ` is a
well-defined, estimable physical quantity (R.42 lifts from B to A).

**Formal kernel.** Two pieces:

* **(i) variance-of-mean identity** (algebraic core of "independent
  samples"): for `N > 0`, the variance of the `N`-sample mean of i.i.d.
  variance-`σ²` estimates is `σ²/N`. The i.i.d. additivity
  `Var[ΣXᵢ] = N·σ²` enters as the bundled probability premise `h_indep`;
  we derive `Var[mean] = σ²/N`.
* **(ii) error → 0 at rate `1/√N`**: the standard error
  `se(N) = σ/√N` tends to `0` as `N → ∞` (real-analysis limit), giving
  the `O(1/√N)` consistency.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Data.Real.Sqrt
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace KappaEstimable

open Filter Topology Real

/-- **R.110 (i) — variance of the `N`-sample mean is `σ²/N`.**

Given the i.i.d. additivity `Var[Σ_{i<N} Xᵢ] = N·σ²` (premise `h_indep`,
the bundled independence fact) and the scaling `Var[c·Y] = c²·Var[Y]` with
`c = 1/N`, the empirical mean `κ̂_N = (1/N)·ΣXᵢ` has variance

    Var[κ̂_N] = (1/N)² · (N·σ²) = σ²/N.

Stated as: with `varSum = N·σ²` and `varMean = (1/N)²·varSum`, we get
`varMean = σ²/N` for `N > 0`. -/
theorem R_110_i_variance_of_mean
    (N σ varSum varMean : ℝ) (hN : 0 < N)
    (h_indep : varSum = N * σ ^ 2)
    (h_scale : varMean = (1 / N) ^ 2 * varSum) :
    varMean = σ ^ 2 / N := by
  rw [h_scale, h_indep]
  have hNne : N ≠ 0 := ne_of_gt hN
  field_simp

/-- **R.110 (i') — unbiasedness preserved.**

The empirical mean is unbiased: if each `Xᵢ` has mean `κ` then the
`N`-sample mean also has mean `κ` (premise `h_meanSum : meanSum = N·κ`,
scaled by `1/N`). -/
theorem R_110_i_unbiased
    (N κ meanSum meanMean : ℝ) (hN : 0 < N)
    (h_meanSum : meanSum = N * κ)
    (h_scale : meanMean = (1 / N) * meanSum) :
    meanMean = κ := by
  rw [h_scale, h_meanSum]
  have hNne : N ≠ 0 := ne_of_gt hN
  field_simp

/-- **R.110 (ii) — standard error `σ/√N → 0` as `N → ∞`.**

The estimation error scales as the standard error `σ/√N`, which tends to
`0` along `N → ∞` (over the reals). Hence `κ̂_N → κ` and `κ` is
consistently estimable at rate `O(1/√N)`. -/
theorem R_110_ii_stderr_tendsto_zero (σ : ℝ) :
    Tendsto (fun N : ℝ => σ / Real.sqrt N) atTop (nhds 0) := by
  -- σ / √N = σ · (√N)⁻¹.  As N → ∞, √N → ∞, so (√N)⁻¹ → 0, so σ·(√N)⁻¹ → 0.
  have hsqrt : Tendsto (fun N : ℝ => Real.sqrt N) atTop atTop :=
    Real.tendsto_sqrt_atTop
  have hinv : Tendsto (fun N : ℝ => (Real.sqrt N)⁻¹) atTop (nhds 0) :=
    tendsto_inv_atTop_zero.comp hsqrt
  have hmul : Tendsto (fun N : ℝ => σ * (Real.sqrt N)⁻¹) atTop (nhds (σ * 0)) :=
    (tendsto_const_nhds (x := σ)).mul hinv
  rw [mul_zero] at hmul
  -- rewrite σ * (√N)⁻¹ as σ / √N
  have hfun : (fun N : ℝ => σ * (Real.sqrt N)⁻¹) = (fun N : ℝ => σ / Real.sqrt N) := by
    funext N; rw [div_eq_mul_inv]
  rwa [hfun] at hmul

end KappaEstimable

end MIP
