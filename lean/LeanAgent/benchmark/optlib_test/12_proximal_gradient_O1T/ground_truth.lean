-- Source: optlib/Optlib/Algorithm/ProximalGradient.lean line 39
-- Theorem: proximal_gradient_method_converge
-- Layer 3, Item 12 — O(1/T) for proximal gradient
--
-- NOTE: The external `Optlib` package is not available in this repository, so
-- the import is retargeted to the project's own *certified* re-implementation
-- under `LeanAgent.OptLib2.*` (Mathlib-based, sorry-free). The benchmark's
-- local `proximal_gradient_method` class is field-identical to
-- `LeanAgent.OptLib2.proximal_gradient_method`, so the theorem is discharged
-- by building an OptLib2 instance from the benchmark `alg`'s fields and
-- invoking the certified `LeanAgent.OptLib2.proximal_gradient_method_converge`.

import LeanAgent.OptLib2.Basic.Defs
import LeanAgent.OptLib2.Basic.Smoothness
import LeanAgent.OptLib2.Basic.Convexity
import LeanAgent.OptLib2.Proximal.Defs
import LeanAgent.OptLib2.Proximal.Properties
import LeanAgent.OptLib2.Algorithms.ProximalGradient

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
variable [ProperSpace E]
variable {x₀ : E} {f : E → ℝ} {f' : E → E} {h : E → ℝ}

open Set

class proximal_gradient_method (f h : E → ℝ) (f' : E → E) (x₀ : E) where
  (xm : E) (t : ℝ) (x : ℕ → E) (L : NNReal)
  (fconv : ConvexOn ℝ univ f) (hconv : ConvexOn ℝ univ h)
  (h₁ : ∀ x₁ : E, HasGradientAt f (f' x₁) x₁) (h₂ : LipschitzWith L f')
  (h₃ : ContinuousOn h univ) (minphi : IsMinOn (f + h) Set.univ xm)
  (tpos : 0 < t) (step : t ≤ 1 / L) (ori : x 0 = x₀) (hL : L > (0 : ℝ))
  (update : ∀ (k : ℕ),
    LeanAgent.OptLib2.prox_prop (t • h) (x k - t • f' (x k)) (x (k + 1)))

variable {alg : proximal_gradient_method f h f' x₀}

omit [ProperSpace E] in
theorem proximal_gradient_method_converge : ∀ (k : ℕ+),
    (f (alg.x k) + h (alg.x k) - f alg.xm - h alg.xm)
    ≤ 1 / (2 * k * alg.t) * ‖x₀ - alg.xm‖ ^ 2 := by
  -- Build the certified OptLib2 instance from the benchmark `alg`'s fields.
  let algC : LeanAgent.OptLib2.proximal_gradient_method f h f' x₀ :=
    { xm := alg.xm, t := alg.t, x := alg.x, L := alg.L
      fconv := alg.fconv, hconv := alg.hconv
      h₁ := alg.h₁, h₂ := alg.h₂, h₃ := alg.h₃
      minphi := alg.minphi, tpos := alg.tpos, step := alg.step
      ori := alg.ori, hL := alg.hL, update := alg.update }
  exact LeanAgent.OptLib2.proximal_gradient_method_converge (alg := algC)
