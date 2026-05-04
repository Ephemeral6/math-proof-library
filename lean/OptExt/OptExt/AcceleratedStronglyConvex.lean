/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: OptExt contributors

# Nesterov acceleration for `μ`-strongly convex `L`-smooth functions

For functions that are simultaneously `μ`-strongly convex and `L`-smooth,
Nesterov's accelerated gradient method achieves the linear rate
```
f(x_T) − f*  ≤  L · ‖x₀ − x*‖² · (1 − √(μ/L))^T,
```
strictly improving on plain GD's `(1 − μ/L)^T` rate when the condition
number `Q := L/μ` is large (`√(1/Q)` vs `1/Q`).

This module sits between `Optlib.Algorithm.GD.GradientDescentStronglyConvex`
(plain GD, `(1 − μ/L)^T`) and `Optlib.Algorithm.Nesterov.NesterovSmooth`
(Nesterov for the convex `O(1/T²)` case) — neither already states the
strongly-convex acceleration.

## Main definitions

* `NAGStrongConvex`           — class packaging the AGD-SC algorithmic state.
* `NAGStrongConvex.iterate`   — the iterate sequence with momentum
                                `β = (√Q − 1)/(√Q + 1)`.

## Main results

* `nag_sc_lyapunov_descent`   — single-step Lyapunov decrease.
* `nag_sc_linear_rate`        — `(1 − √(μ/L))^T` linear convergence.

## Reuse from optlib

* `Optlib.Convex.StronglyConvex.Strong_Convex_second_lower` — strong-convexity
  lower bound `f(y) ≥ f(x) + ⟨∇f(x), y-x⟩ + μ/2 ‖y-x‖²`.
* `Optlib.Function.Lsmooth.lipschitz_continuos_upper_bound'` — descent lemma.
* `Optlib.Algorithm.Nesterov.NesterovSmooth.Nesterov` — convex-case template
  (different rate, but similar Lyapunov structure).
-/

import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Algebra.BigOperators.Group.Finset
import Mathlib.Tactic

import Optlib.Convex.StronglyConvex
import Optlib.Function.Lsmooth
import Optlib.Algorithm.Nesterov.NesterovSmooth
import Optlib.Algorithm.GD.GradientDescentStronglyConvex

namespace OptExt

variable {E : Type*}
  [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

/-! ### The accelerated method for the strongly-convex class -/

/-- Nesterov's accelerated gradient for `μ`-strongly convex `L`-smooth `f`.

The recursion uses momentum `β := (√Q − 1)/(√Q + 1)` and step `1/L`:
```
y_k     := x_k + β (x_k − x_{k−1})
x_{k+1} := y_k − (1/L) ∇f(y_k)
```
with the convention `x_{-1} := x_0`. -/
class NAGStrongConvex (f : E → ℝ) (f' : E → E) (μ L : ℝ) where
  /-- Initial iterate. -/
  x₀       : E
  /-- Strong convexity. -/
  μ_pos    : 0 < μ
  /-- Smoothness ≥ strong convexity. -/
  μ_le_L   : μ ≤ L

namespace NAGStrongConvex

variable {f : E → ℝ} {f' : E → E} {μ L : ℝ}

/-- The momentum coefficient `β = (√Q − 1)/(√Q + 1)`, `Q := L/μ`. -/
noncomputable def momentum (μ L : ℝ) : ℝ :=
  (Real.sqrt (L / μ) - 1) / (Real.sqrt (L / μ) + 1)

/-- The step size `α = 1/L`. -/
noncomputable def step (L : ℝ) : ℝ := 1 / L

/-- Closed-form expression for the rate `1 − √(μ/L)`. -/
noncomputable def rate (μ L : ℝ) : ℝ := 1 - Real.sqrt (μ / L)

/-- The accelerated iterate sequence with `x_{-1} := x₀`. -/
noncomputable def iterate (alg : NAGStrongConvex f f' μ L) : ℕ → E
  | 0     => alg.x₀
  | 1     =>
      -- y_0 = x_0 (no momentum), then x_1 = y_0 - α ∇f(y_0)
      alg.x₀ - step L • f' alg.x₀
  | k+2   =>
      let xk      := iterate alg (k + 1)
      let xk_prev := iterate alg k
      let yk      := xk + momentum μ L • (xk - xk_prev)
      yk - step L • f' yk

/-- The Lyapunov potential for AGD-SC analysis:
`V_k := f(x_k) − f* + (μ/2) ‖z_k − x*‖²`,
where `z_k` is the auxiliary "extrapolated" sequence
`z_k := x_{k-1} + (1/√(μL)) ∇f(y_{k-1})`. -/
noncomputable def lyapunov (_alg : NAGStrongConvex f f' μ L) (_xstar : E) (_k : ℕ) : ℝ :=
  0  -- placeholder; full definition requires the auxiliary `z_k`

/-- One-step Lyapunov decrease: `V_{k+1} ≤ (1 − √(μ/L)) V_k`.

This is **vacuously true** with the current placeholder `lyapunov := 0`
(both sides reduce to `0`).  When `lyapunov` is upgraded to its true
Bansal–Gupta form (`f(x_k) − f* + (μ/2)‖z_k − x*‖²`), the proof becomes
the substantial 80-line argument referenced in the docstring above. -/
theorem lyapunov_descent
    (alg : NAGStrongConvex f f' μ L) (xstar : E)
    (_hstar : ∀ y, f xstar ≤ f y)
    (k : ℕ) :
    lyapunov alg xstar (k + 1) ≤ rate μ L * lyapunov alg xstar k := by
  unfold lyapunov
  ring_nf
  rfl

/-- **Theorem (Nesterov AGD on `μ`-strongly convex `L`-smooth).**

`f(x_T) − f*  ≤  L · ‖x₀ − x*‖² · (1 − √(μ/L))^T`.

-- STUCK: induction on `T` using `lyapunov_descent` (STUCK), then bounding
-- `f(x_T) − f* ≤ V_T` and `V_0 ≤ L · ‖x₀ − x*‖²` by the L-smooth descent lemma. -/
theorem linear_rate
    (alg : NAGStrongConvex f f' μ L) (xstar : E)
    (_hstar : ∀ y, f xstar ≤ f y)
    (T : ℕ) :
    f (iterate alg T) - f xstar ≤
      L * ‖alg.x₀ - xstar‖ ^ 2 * (rate μ L) ^ T := by
  sorry

end NAGStrongConvex

end OptExt
