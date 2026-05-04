/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: OptExt contributors

# Stochastic first-order oracle

A stochastic first-order oracle (SFO) for a function `f : E → ℝ` returns,
for each query point `x : E`, a random vector `g : E` whose expectation is
`∇f x` and whose squared deviation from `∇f x` is bounded by `σ²`.

This module defines the oracle abstractly (parameterised by a probability
space `(Ω, ℙ)`) and proves elementary properties.

## Main definitions

* `IsUnbiasedFOOracle`     — `g ω x` is unbiased: `𝔼[g ω x] = ∇f x`.
* `HasBoundedVariance σ`   — `𝔼‖g ω x − ∇f x‖² ≤ σ²` uniformly in `x`.
* `IsSFO σ`                — both conditions; the standard `(σ²)`-SFO.

## Reuse from optlib

* `Optlib.IsLSmooth`               — gradient Lipschitz; we keep that as the
                                     deterministic smoothness assumption.
* `Optlib.Function.Lsmooth.lipschitz_continuos_upper_bound'` — descent lemma.

## References

* Nemirovski, Juditsky, Lan, Shapiro (2009).  Robust stochastic
  approximation approach to stochastic programming.
* Ghadimi, Lan (2013).  Stochastic first- and zeroth-order methods for
  nonconvex stochastic programming.
-/

import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.Calculus.Gradient.Basic
import Mathlib.MeasureTheory.Integral.Bochner
import Mathlib.MeasureTheory.Function.L2Space

-- Reuse optlib's smoothness layer.  These imports are local to the
-- (locally cloned) optlib package and are resolved via the `path` require
-- in `lakefile.lean`.
import Optlib.Function.Lsmooth
import OptExt.Util.ExpectationInner

open MeasureTheory

namespace OptExt

variable {E : Type*}
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
  [MeasurableSpace E] [BorelSpace E] [SecondCountableTopology E]

variable {Ω : Type*} [MeasurableSpace Ω] (ℙ : Measure Ω) [IsProbabilityMeasure ℙ]

/-- A *stochastic first-order oracle* for `f` is a measurable map
`g : Ω → E → E` such that, when sampled, `g ω x` returns a random vector
intended to estimate `∇f x`. -/
structure SFO (f : E → ℝ) where
  /-- The random gradient field. -/
  query  : Ω → E → E
  /-- Measurability in the sample variable for every fixed query point. -/
  measurable_query : ∀ x : E, Measurable (fun ω => query ω x)

variable {f : E → ℝ} {f' : E → E}

/-- The oracle is *unbiased* if for every query point, the expected
returned vector equals the true gradient. -/
def IsUnbiasedFOOracle (G : SFO (E := E) (Ω := Ω) f) (f' : E → E) : Prop :=
  ∀ x : E, ∫ ω, G.query ω x ∂ℙ = f' x

/-- The oracle has *bounded variance `σ²`* if the expected squared error
`𝔼‖g ω x − f' x‖²` is uniformly bounded by `σ²`. -/
def HasBoundedVariance (G : SFO (E := E) (Ω := Ω) f) (f' : E → E) (σ : ℝ) : Prop :=
  ∀ x : E, ∫ ω, ‖G.query ω x - f' x‖ ^ 2 ∂ℙ ≤ σ ^ 2

/-- Standard `(σ²)`-stochastic first-order oracle: unbiased with bounded
variance.  The expected query equals `f' x` and the variance is at most `σ²`. -/
structure IsSFO (G : SFO (E := E) (Ω := Ω) f) (f' : E → E) (σ : ℝ) : Prop where
  unbiased : IsUnbiasedFOOracle ℙ G f'
  variance : HasBoundedVariance ℙ G f' σ

/-! ### Elementary consequences -/

/-- An unbiased oracle has zero-mean noise (assuming integrability of the
oracle output, which holds for any oracle whose variance is bounded). -/
theorem unbiased_noise_mean_zero
    (G : SFO (E := E) (Ω := Ω) f) (hG : IsUnbiasedFOOracle ℙ G f') (x : E)
    (hint : Integrable (fun ω => G.query ω x) ℙ) :
    ∫ ω, (G.query ω x - f' x) ∂ℙ = 0 := by
  rw [integral_sub hint (integrable_const _), hG x, integral_const,
      measure_univ, ENNReal.one_toReal, one_smul, sub_self]

/-- For an `(σ²)`-SFO the second moment of the query is bounded by
`‖f' x‖² + σ²`. -/
theorem second_moment_bound
    (G : SFO (E := E) (Ω := Ω) f) (f' : E → E) (σ : ℝ)
    (hG : IsSFO ℙ G f' σ) (x : E)
    (h_int_g : Integrable (fun ω => G.query ω x) ℙ)
    (h_int_diff_sq : Integrable (fun ω => ‖G.query ω x - f' x‖ ^ 2) ℙ)
    (h_int_inner : Integrable (fun ω => inner (𝕜 := ℝ) (G.query ω x) (f' x)) ℙ) :
    ∫ ω, ‖G.query ω x‖ ^ 2 ∂ℙ ≤ ‖f' x‖ ^ 2 + σ ^ 2 := by
  -- ∫ ⟪g, μ⟫ ∂ℙ = ⟪μ, ∫ g ∂ℙ⟫ = ⟪μ, μ⟫ = ‖μ‖²
  have h_inner_val : ∫ ω, inner (𝕜 := ℝ) (G.query ω x) (f' x) ∂ℙ = ‖f' x‖ ^ 2 := by
    have hcomm : (fun ω => inner (𝕜 := ℝ) (G.query ω x) (f' x))
                  = (fun ω => inner (𝕜 := ℝ) (f' x) (G.query ω x)) := by
      funext ω; exact real_inner_comm _ _
    rw [hcomm, integral_inner h_int_g, hG.unbiased x, real_inner_self_eq_norm_sq]
  -- Pointwise polarisation rewrites the integrand.
  have eq_int : ∫ ω, ‖G.query ω x‖ ^ 2 ∂ℙ
              = ∫ ω, (‖G.query ω x - f' x‖ ^ 2
                  + 2 * inner (𝕜 := ℝ) (G.query ω x) (f' x)
                  - ‖f' x‖ ^ 2) ∂ℙ := by
    apply integral_congr_ae
    filter_upwards with ω
    exact norm_sq_eq_sub_inner_sub _ _
  -- Split the RHS integral.
  have h_int_2inner : Integrable (fun ω => 2 * inner (𝕜 := ℝ) (G.query ω x) (f' x)) ℙ :=
    h_int_inner.const_mul 2
  have h_int_sum : Integrable (fun ω => ‖G.query ω x - f' x‖ ^ 2
                                  + 2 * inner (𝕜 := ℝ) (G.query ω x) (f' x)) ℙ :=
    h_int_diff_sq.add h_int_2inner
  rw [eq_int,
      integral_sub h_int_sum (integrable_const _),
      integral_add h_int_diff_sq h_int_2inner,
      integral_const_prob,
      integral_mul_left,
      h_inner_val]
  -- Goal: ∫ ‖g - μ‖² + 2 * ‖μ‖² - ‖μ‖² ≤ ‖μ‖² + σ²
  have hvar := hG.variance x
  linarith

end OptExt
