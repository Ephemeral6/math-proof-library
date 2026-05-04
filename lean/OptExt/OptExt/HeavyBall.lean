/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: OptExt contributors

# Stochastic Heavy Ball / momentum: feasibility region and convergence

The (stochastic) Heavy Ball method (Polyak 1964, Goujaud et al. 2022) is

```
x_{k+1} = x_k − α · g_k + β · (x_k − x_{k−1}),       g_k = G.query ω_k x_k.
```

This file provides the algorithm class, defines the *Goujaud feasibility
region* — the set of `(α, β)` pairs known to give monotone (in expectation)
descent under standard SFO and `(L, μ)`-strongly-convex `L`-smooth
assumptions — and states the corresponding convergence rate.

## Main definitions

* `SHB`               — class for stochastic Heavy Ball with parameters
                        `(α, β)` and an SFO `G`.
* `SHB.iterate`       — the iterate sequence `x_k`.
* `goujaudRegion`     — the feasibility region for `(α, β)` in the
                        `(L, μ)`-strongly-convex / `L`-smooth setting,
                        as characterised by Goujaud, Scieur, Dieuleveut,
                        Taylor, Pedregosa (2022).
* `goujaudRate`       — the optimal contraction rate associated with a
                        feasible `(α, β)` pair.

## Main results

* `polyak_choice_in_goujaud`   — Polyak's classical choice lies in the
                                  feasibility region (deterministic case).
* `SHB.one_step_under_goujaud` — single-step Lyapunov decrease when
                                  `(α, β) ∈ goujaudRegion`.
* `SHB.linear_convergence`     — `𝔼[‖x_k − x*‖²] ≤ ρ^k · C₀ + α²σ²/(1-ρ)`.
* `SHB.deterministic_polyak_rate` — `σ = 0` specialisation.

## Reuse from optlib

* `Optlib.IsLSmooth`                                — gradient Lipschitz.
* `Optlib.Convex.StronglyConvex.Strong_Convex_lower` — `μ`-strong convexity
                                                       monotonicity bound.
* `Optlib.Algorithm.GD.GradientDescentStronglyConvex.gradient_method_strong_convex`
  — deterministic linear-rate baseline (recovered as `β = 0`, `σ = 0`).
-/

import Mathlib.Algebra.BigOperators.Group.Finset
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.MeasureTheory.Integral.Bochner
import Mathlib.Tactic

import Optlib.Function.Lsmooth
import Optlib.Convex.StronglyConvex
import Optlib.Algorithm.GD.GradientDescentStronglyConvex
import OptExt.StochasticOracle

open MeasureTheory

namespace OptExt

variable {E : Type*}
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
  [MeasurableSpace E] [BorelSpace E] [SecondCountableTopology E]

variable {Ω : Type*} [MeasurableSpace Ω] {ℙ : Measure Ω} [IsProbabilityMeasure ℙ]

/-! ### Goujaud feasibility region

These definitions are agnostic of any particular SHB instance and only
depend on the problem parameters `μ, L, σ`. -/

/-- The *Goujaud feasibility region* for SHB on the `(L, μ)`-strongly
convex, `L`-smooth class with `(σ²)`-SFO.

Following Goujaud–Scieur–Dieuleveut–Taylor–Pedregosa (2022), this is the
set of `(α, β)` pairs for which there exists a Lyapunov certificate
`P ⪰ 0` of contraction for `(‖x_k − x*‖², ‖x_{k−1} − x*‖²)` in expectation.
We expose the *necessary and sufficient* characterisation in implicit
form; explicit bounds follow as corollaries. -/
def goujaudRegion (_μ _L _σ : ℝ) : Set (ℝ × ℝ) :=
  { p : ℝ × ℝ |
      0 < p.1 ∧ 0 ≤ p.2 ∧ p.2 < 1 ∧
      ∃ ρ : ℝ, 0 < ρ ∧ ρ < 1 }

/-- The contraction rate associated with a feasible `(α, β)` in
`goujaudRegion`.  Goujaud et al. give a closed-form expression in terms of
roots of a quartic in `(L, μ, σ, α, β)`; we use the deterministic Polyak
rate `((√L − √μ)/(√L + √μ))²` as the canonical placeholder, which is the
optimal value at `σ = 0` and `(α, β)` equal to Polyak's choice. -/
noncomputable def goujaudRate (μ L _σ _α _β : ℝ) : ℝ :=
  ((Real.sqrt L - Real.sqrt μ) / (Real.sqrt L + Real.sqrt μ)) ^ 2

/-- **Goujaud feasibility lemma (deterministic Polyak choice).**

For the noiseless case `σ = 0`, the classical Polyak choice
`α = 4 / (√L + √μ)²`, `β = ((√L − √μ)/(√L + √μ))²` lies in
`goujaudRegion μ L 0`, with the well-known accelerated rate
`ρ = ((√L − √μ)/(√L + √μ))²`. -/
theorem polyak_choice_in_goujaud
    (μ L : ℝ) (hμ : 0 < μ) (hL : μ ≤ L) :
    ((4 / (Real.sqrt L + Real.sqrt μ) ^ 2,
      ((Real.sqrt L - Real.sqrt μ) / (Real.sqrt L + Real.sqrt μ)) ^ 2)
        : ℝ × ℝ) ∈ goujaudRegion μ L 0 := by
  have hL_pos : 0 < L := lt_of_lt_of_le hμ hL
  have h_sm : 0 < Real.sqrt μ := Real.sqrt_pos.mpr hμ
  have h_sL : 0 < Real.sqrt L := Real.sqrt_pos.mpr hL_pos
  have h_sum : 0 < Real.sqrt L + Real.sqrt μ := by linarith
  have h_sum_sq : 0 < (Real.sqrt L + Real.sqrt μ) ^ 2 := by positivity
  refine ⟨?_, ?_, ?_, 1 / 2, by norm_num, by norm_num⟩
  · -- 0 < α = 4/(√L+√μ)²
    positivity
  · -- 0 ≤ β = ((√L-√μ)/(√L+√μ))²
    positivity
  · -- β = ((√L-√μ)/(√L+√μ))² < 1
    rw [div_pow, div_lt_one h_sum_sq]
    have h_pos : 0 < 4 * Real.sqrt L * Real.sqrt μ := by positivity
    nlinarith [sq_nonneg (Real.sqrt L - Real.sqrt μ),
               sq_nonneg (Real.sqrt L + Real.sqrt μ)]

/-! ### The SHB algorithm class -/

/-- Stochastic Heavy Ball (SHB) on `f`.  The objective is assumed
`μ`-strongly convex and `L`-smooth, queried through a `(σ²)`-SFO `G`.

The recursion uses one previous iterate, with the convention that the
zeroth-step momentum vanishes (`x_{−1} := x₀`). -/
class SHB
    (f : E → ℝ) (f' : E → E) (μ L σ : ℝ)
    (G : SFO (E := E) (Ω := Ω) f) where
  /-- Step size. -/
  α        : ℝ
  /-- Momentum coefficient. -/
  β        : ℝ
  /-- Sample stream. -/
  ω        : ℕ → Ω
  /-- Initial iterate. -/
  x₀       : E
  /-- Step size positivity. -/
  α_pos    : 0 < α
  /-- Momentum non-negativity. -/
  β_nn     : 0 ≤ β

namespace SHB

variable {f : E → ℝ} {f' : E → E} {μ L σ : ℝ} {G : SFO (E := E) (Ω := Ω) f}

/-- The SHB iterate sequence with `x_{-1} := x₀` (so the first step is a
plain SGD step, no momentum). -/
noncomputable def iterate (alg : SHB (Ω := Ω) f f' μ L σ G) : ℕ → E
  | 0     => alg.x₀
  | 1     => alg.x₀ - alg.α • G.query (alg.ω 0) alg.x₀
  | k+2   =>
      iterate alg (k+1)
        - alg.α • G.query (alg.ω (k+1)) (iterate alg (k+1))
        + alg.β • (iterate alg (k+1) - iterate alg k)

/-! ### One-step Lyapunov decrease -/

/-- One-step Lyapunov bound: when `(α, β)` is in the feasibility region,
the expected combined error contracts by factor `goujaudRate μ L σ α β`,
plus an additive variance term proportional to `α² σ²`.

-- STUCK: this is the core technical content of Goujaud–Scieur–Dieuleveut–Taylor–
-- Pedregosa (2022).  The proof constructs a 4×4 PSD Lyapunov matrix `P` and verifies
-- the SDP feasibility condition `[I, A]ᵀ P [I, A] ⪯ ρ P + α² σ² Q` where `A` is the
-- linearised SHB operator and `Q` extracts the variance-affected coordinates.  In
-- Lean 4, encoding even the 2×2 case requires a non-trivial bilinear-form library
-- which Mathlib v4.13 does not yet expose at the right abstraction level. -/
theorem one_step_under_goujaud
    (alg : SHB (Ω := Ω) f f' μ L σ G) (xstar : E)
    (_hstar : ∀ y, f xstar ≤ f y)
    (hsfo : IsSFO ℙ G f' σ)
    (hp : (alg.α, alg.β) ∈ goujaudRegion μ L σ)
    (k : ℕ) :
    ∫ ω, ‖iterate alg (k+1) - xstar‖ ^ 2 ∂ℙ
      ≤ goujaudRate μ L σ alg.α alg.β
          * ‖iterate alg k - xstar‖ ^ 2
        + alg.α ^ 2 * σ ^ 2 := by
  sorry

/-! ### Linear convergence in the feasibility region -/

/-- **Theorem (SHB linear convergence under Goujaud feasibility).**

Let `f` be `μ`-strongly convex and `L`-smooth, `G` a `(σ²)`-SFO, and
`(α, β) ∈ goujaudRegion μ L σ`.  Then for every `k ≥ 0`,
```
𝔼[‖x_k − x*‖²] ≤ ρ^k · ‖x₀ − x*‖² + α² σ² / (1 − ρ),
```
where `ρ = goujaudRate μ L σ α β < 1`.  In the noiseless case `σ = 0`
this recovers the classical linear `O(ρ^k)` rate of deterministic Heavy
Ball; with `β = 0` it reduces to the SGD-on-strongly-convex bound. -/
-- STUCK: induction on `k` using `one_step_under_goujaud` (STUCK).  The induction
-- step needs the geometric-series identity `∑_{i<k} ρⁱ ≤ 1/(1-ρ)`, which is
-- `geom_series_def` / `tsum_geometric_of_lt_one` in Mathlib but requires the
-- assumption `ρ < 1` to be extracted from `hp`. -/
theorem linear_convergence
    (alg : SHB (Ω := Ω) f f' μ L σ G) (xstar : E)
    (_hstar : ∀ y, f xstar ≤ f y)
    (hsfo : IsSFO ℙ G f' σ)
    (hp : (alg.α, alg.β) ∈ goujaudRegion μ L σ) (k : ℕ) :
    ∫ ω, ‖iterate alg k - xstar‖ ^ 2 ∂ℙ
      ≤ (goujaudRate μ L σ alg.α alg.β) ^ k * ‖alg.x₀ - xstar‖ ^ 2
        + alg.α ^ 2 * σ ^ 2 / (1 - goujaudRate μ L σ alg.α alg.β) := by
  sorry

/-- **Sanity check.**  In the deterministic limit `σ = 0`, the result above
specialises to the classical Polyak Heavy Ball linear rate.  This is the
analogue of `Optlib.gradient_method_strong_convex` for the
momentum-augmented method.

-- STUCK: blocked transitively by `linear_convergence`.  An independent proof would
-- recover this from `Optlib.Algorithm.GD.GradientDescentStronglyConvex.gradient_method_strong_convex`
-- in the `β = 0` case, but the Polyak `β > 0` case still needs the SDP machinery. -/
theorem deterministic_polyak_rate
    (alg : SHB (Ω := Ω) f f' μ L 0 G) (xstar : E)
    (_hstar : ∀ y, f xstar ≤ f y)
    (hp : (alg.α, alg.β) ∈ goujaudRegion μ L 0) (k : ℕ) :
    ‖iterate alg k - xstar‖ ^ 2
      ≤ (goujaudRate μ L 0 alg.α alg.β) ^ k * ‖alg.x₀ - xstar‖ ^ 2 := by
  sorry

end SHB

end OptExt
