/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: OptExt contributors

# Stochastic gradient descent: `O(σ/√T + L D² / T)` convergence

For an `L`-smooth convex `f` queried through a `(σ²)`-stochastic first-order
oracle, fixed-stepsize SGD with `a = min(1/L, D/(σ√T))` satisfies, after
`T` iterations,
```
𝔼[f(x̄_T) - f*] ≤ L D² / (2 T) + σ D / √T,
```
where `x̄_T = (1/T) ∑ x_t` is the running average and
`D ≥ ‖x₀ − x*‖`.

## Main definitions

* `SGD`               — class packaging fixed-stepsize SGD on a sample stream.
* `SGD.avgIterate`    — running-average iterate `x̄_T`.

## Main results

* `SGD.one_step_in_expectation` — single-step bound used by the analysis.
* `SGD.avg_converge`            — `O(σ/√T + L D² / T)` rate for the average.
* `SGD.sample_complexity`       — corollary `O(1/ε² + 1/ε)` sample complexity.

## Reuse from optlib

* `Optlib.IsLSmooth`                          — gradient Lipschitz constant.
* `Optlib.Function.Lsmooth.lipschitz_continuos_upper_bound'` — descent lemma.
* `Optlib.Convex.ConvexFunction.Convex_first_order_condition` — convexity
  inequality `f(y) ≥ f(x) + ⟨∇f(x), y-x⟩`.
-/

import Mathlib.Algebra.BigOperators.Group.Finset
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.MeasureTheory.Integral.Bochner
import Mathlib.Tactic

import Optlib.Function.Lsmooth
import Optlib.Convex.ConvexFunction
import OptExt.StochasticOracle

open MeasureTheory

namespace OptExt

variable {E : Type*}
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
  [MeasurableSpace E] [BorelSpace E] [SecondCountableTopology E]

variable {Ω : Type*} [MeasurableSpace Ω] {ℙ : Measure Ω} [IsProbabilityMeasure ℙ]

/-- Fixed-stepsize stochastic gradient descent on `f`.

The update reads `x_{k+1} = x_k − a · g(ω_k, x_k)`, where `ω : ℕ → Ω` is
the sample stream.  The objective `f` is assumed convex and `L`-smooth, and
`G` is the `(σ²)`-stochastic first-order oracle. -/
class SGD
    (f : E → ℝ) (f' : E → E) (L σ : ℝ)
    (G : SFO (E := E) (Ω := Ω) f) where
  /-- Fixed step size. -/
  a       : ℝ
  /-- Sample stream. -/
  ω       : ℕ → Ω
  /-- Initial iterate. -/
  x₀      : E
  /-- Step size positivity. -/
  a_pos   : 0 < a
  /-- `f` is convex on `Set.univ`. -/
  convex  : ConvexOn ℝ Set.univ f

namespace SGD

variable {f : E → ℝ} {f' : E → E} {L σ : ℝ} {G : SFO (E := E) (Ω := Ω) f}

/-- The SGD iterate sequence. -/
noncomputable def iterate (alg : SGD (Ω := Ω) f f' L σ G) : ℕ → E
  | 0     => alg.x₀
  | k+1   => iterate alg k - alg.a • G.query (alg.ω k) (iterate alg k)

/-- Running-average iterate `x̄_T = (1/T) ∑_{k<T} x_k`.  Defined to be `x₀`
when `T = 0`. -/
noncomputable def avgIterate (alg : SGD (Ω := Ω) f f' L σ G) (T : ℕ) : E :=
  if 0 < T then
    (T : ℝ)⁻¹ • ∑ k ∈ Finset.range T, iterate alg k
  else
    alg.x₀

/-! ### One-step bound -/

/-- One-step descent bound *in expectation* for SGD on an `L`-smooth convex
`f` with `(σ²)`-SFO and fixed stepsize `a ∈ (0, 1/L]`:
```
𝔼[‖x_{k+1} - x*‖²] ≤ ‖x_k - x*‖² - 2a (𝔼[f(x_k)] - f*) + a² σ².
```
This is the workhorse for both fixed and decaying step-size analyses.

-- STUCK: full proof requires the chain
--   ‖x - a·g - x*‖² = ‖x - x*‖² - 2a⟨g, x - x*⟩ + a²‖g‖²
-- followed by taking expectation, applying unbiased + variance bound, then using
-- convexity (`Optlib.Convex.ConvexFunction.Convex_first_order_condition`) to bound
-- the inner product `⟨∇f(x), x - x*⟩ ≥ f(x) - f(x*)`.  The expectation manipulation
-- needs `MeasureTheory.integral_add` / `integral_sub` with explicit integrability
-- bookkeeping for each summand — non-trivial in Lean v4.13. -/
theorem one_step_in_expectation
    (alg : SGD (Ω := Ω) f f' L σ G) (xstar : E)
    (hstar : ∀ y, f xstar ≤ f y)
    (haL : alg.a ≤ 1 / L)
    (hsfo : IsSFO ℙ G f' σ)
    (k : ℕ) :
    ∫ ω, ‖iterate alg k - xstar‖ ^ 2 ∂ℙ
      ≤ ‖iterate alg k - xstar‖ ^ 2
        - 2 * alg.a * (f (iterate alg k) - f xstar)
        + alg.a ^ 2 * σ ^ 2 := by
  sorry

/-! ### Convergence of the running average -/

/-- **Theorem (SGD on convex L-smooth, bounded SFO).**
Let `f : E → ℝ` be convex and `L`-smooth, `G` a `(σ²)`-SFO with gradient
`f'`, and let `D ≥ ‖x₀ − x*‖`.  With fixed step
`a = min (1/L) (D / (σ √T))` (and `T ≥ 1`), the SGD running average
satisfies
```
𝔼[f(x̄_T)] - f* ≤ L D² / (2 T) + σ D / √T.
```

-- STUCK: relies on `one_step_in_expectation` (still STUCK), then telescopes the
-- bound `𝔼‖x_{k+1}-x*‖² ≤ 𝔼‖x_k-x*‖² - 2a(𝔼f(x_k)-f*) + a²σ²` over k = 0..T-1,
-- divides by 2aT, and uses Jensen for the average iterate `f(x̄_T) ≤ (1/T)∑ f(x_k)`.
-- The Jensen step alone needs `ConvexOn.smul_le_sum` from Mathlib applied to the
-- finite uniform average, which requires careful indexing. -/
theorem avg_converge
    (alg : SGD (Ω := Ω) f f' L σ G) (xstar : E)
    (hstar : ∀ y, f xstar ≤ f y)
    (hsfo : IsSFO ℙ G f' σ)
    (D : ℝ) (hD : ‖alg.x₀ - xstar‖ ≤ D) (hD_nn : 0 ≤ D)
    (hσ_nn : 0 ≤ σ)
    (T : ℕ) (hT : 0 < T)
    (ha_choice : alg.a = min (1 / L) (D / (σ * Real.sqrt T))) :
    (∫ ω, f (avgIterate alg T) ∂ℙ) - f xstar
      ≤ L * D ^ 2 / (2 * T) + σ * D / Real.sqrt T := by
  sorry

/-- **Corollary.**  Picking `T ≥ ⌈4 σ² D² / ε²⌉` and `T ≥ ⌈2 L D² / ε⌉`
gives `𝔼[f(x̄_T)] - f* ≤ ε`.  This is the standard `O(1/ε² + 1/ε)`
sample complexity bound.

**Statement note:** added `(hL_nn : 0 ≤ L)` and `(hT_pos : 0 < T)`
hypotheses; the latter is implied when `LD² > 0` or `σD > 0` from the
two bounds, but we make it explicit for cleaner proof. -/
theorem sample_complexity
    (alg : SGD (Ω := Ω) f f' L σ G) (xstar : E)
    (hstar : ∀ y, f xstar ≤ f y)
    (hsfo : IsSFO ℙ G f' σ)
    (D ε : ℝ) (hD : ‖alg.x₀ - xstar‖ ≤ D) (hD_nn : 0 ≤ D)
    (hσ_nn : 0 ≤ σ) (hε_pos : 0 < ε)
    (hL_nn : 0 ≤ L)
    (T : ℕ) (hT_pos : 0 < T)
    (hT₁ : (4 * σ ^ 2 * D ^ 2 / ε ^ 2 : ℝ) ≤ T)
    (hT₂ : (2 * L * D ^ 2 / ε : ℝ) ≤ T)
    (ha_choice : alg.a = min (1 / L) (D / (σ * Real.sqrt T))) :
    (∫ ω, f (avgIterate alg T) ∂ℙ) - f xstar ≤ ε := by
  have h_avg := avg_converge alg xstar hstar hsfo D hD hD_nn hσ_nn T hT_pos ha_choice
  -- h_avg : gap ≤ L*D²/(2T) + σ*D/√T
  have hT_pos_real : (0 : ℝ) < T := by exact_mod_cast hT_pos
  have hT_nn_real : (0 : ℝ) ≤ T := hT_pos_real.le
  have h_sqrtT_pos : 0 < Real.sqrt T := Real.sqrt_pos.mpr hT_pos_real
  -- Bound 1: L*D²/(2T) ≤ ε/4 from hT₂.
  have h1 : L * D ^ 2 / (2 * T) ≤ ε / 4 := by
    have h_2εT_pos : 0 < 2 * (T : ℝ) := by linarith
    rw [div_le_div_iff h_2εT_pos (by norm_num : (0:ℝ) < 4)]
    have hT₂' : 2 * L * D ^ 2 ≤ ε * T := by
      have := hT₂
      rw [div_le_iff hε_pos] at this
      linarith
    nlinarith
  -- Bound 2: σ*D/√T ≤ ε/2 from hT₁.
  have h2 : σ * D / Real.sqrt T ≤ ε / 2 := by
    have h_2σD_nn : 0 ≤ 2 * σ * D := by positivity
    have h_εsqrtT_nn : 0 ≤ ε * Real.sqrt T := by positivity
    -- (2σD)² ≤ (ε * √T)² = ε² * T
    have h_sq : (2 * σ * D) ^ 2 ≤ (ε * Real.sqrt T) ^ 2 := by
      have h_eq : (ε * Real.sqrt T) ^ 2 = ε ^ 2 * T := by
        rw [mul_pow, Real.sq_sqrt hT_nn_real]
      rw [h_eq]
      have hT₁' : 4 * σ ^ 2 * D ^ 2 ≤ ε ^ 2 * T := by
        have := hT₁
        rw [div_le_iff (by positivity : (0:ℝ) < ε ^ 2)] at this
        linarith
      nlinarith
    -- Take square root: 2σD ≤ ε * √T
    have h_lin : 2 * σ * D ≤ ε * Real.sqrt T := by
      have := Real.sqrt_le_sqrt h_sq
      rwa [Real.sqrt_sq h_2σD_nn, Real.sqrt_sq h_εsqrtT_nn] at this
    rw [div_le_iff h_sqrtT_pos]
    linarith
  linarith

end SGD

end OptExt
