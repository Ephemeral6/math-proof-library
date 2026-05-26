-- Source: optlib/Optlib/Algorithm/Nesterov/NesterovAccelerationFirst.lean line 41
-- Theorem: Nesterov_first_converge
-- Layer 3, Item 13 — O(1/T^2) for Nesterov AGD
--
-- NOTE: The external `Optlib` package is not available in this repository, so
-- the import is retargeted to the project's own *certified* re-implementation
-- under `LeanAgent.OptLib2.*` (Mathlib-based, sorry-free). The benchmark's
-- local `Nesterov_first` class is field-identical to `OptLib2.Nesterov_first`,
-- so `Nesterov_first_converge` is discharged by the "bridge" approach: we build
-- an `OptLib2.Nesterov_first` instance from the benchmark `alg`'s fields and
-- invoke the certified theorem `OptLib2.Nesterov_first_converge` (the full
-- Lyapunov-based O(1/T^2) proof lives in
-- `LeanAgent/OptLib2/Algorithms/Nesterov.lean`).

import LeanAgent.OptLib2.Basic.Defs
import LeanAgent.OptLib2.Basic.Smoothness
import LeanAgent.OptLib2.Basic.Convexity
import LeanAgent.OptLib2.Proximal.Defs
import LeanAgent.OptLib2.Proximal.Properties
import LeanAgent.OptLib2.Algorithms.Nesterov

local notation "⟪" x ", " y "⟫" => @inner ℝ _ _ x y

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
variable {f h : E → ℝ} {f' : E → E} {x0 : E}

open Set Real
open LeanAgent.OptLib2 (prox_prop)

class Nesterov_first (f h: E → ℝ) (f' : E → E) (x0 : E) where
  (l : NNReal) (x y : ℕ → E) (t γ : ℕ → ℝ) (hl : l > (0 : ℝ))
  (h₁ : ∀ x : E, HasGradientAt f (f' x) x) (convf : ConvexOn ℝ univ f)
  (h₂ : LipschitzWith l f') (convh : ConvexOn ℝ univ h)
  (oriy : y 0 = x 0) (oriγ : γ 0 = 1) (initial : x 0 = x0)
  (cond : ∀ n : ℕ+, (1 - γ n) * t n / γ n ^ 2 ≤ t (n - 1) / γ (n - 1) ^ 2)
  (tbound : ∀ k : ℕ, 0 < t k ∧ t k ≤ 1 / l) (γbound : ∀ n : ℕ, 0 < γ n ∧ γ n ≤ 1)
  (update1 : ∀ k : ℕ+, y k = x k + (γ k * (1 - γ (k - 1)) / γ (k - 1)) • (x k - x (k - 1)))
  (update2 : ∀ k : ℕ, prox_prop (t k • h) (y k - t k • f' (y k)) (x (k + 1)))

variable {alg : Nesterov_first f h f' x0}
variable {xm : E}

/-- The benchmark `Nesterov_first` class is field-identical to the certified
`OptLib2.Nesterov_first`. This builds the OptLib2 instance from the benchmark
fields so the certified convergence theorem applies verbatim. -/
@[reducible]
def Nesterov_first.toOptLib2 (alg : Nesterov_first f h f' x0) :
    LeanAgent.OptLib2.Nesterov_first f h f' x0 where
  l := alg.l
  x := alg.x
  y := alg.y
  t := alg.t
  γ := alg.γ
  hl := alg.hl
  h₁ := alg.h₁
  convf := alg.convf
  h₂ := alg.h₂
  convh := alg.convh
  oriy := alg.oriy
  oriγ := alg.oriγ
  initial := alg.initial
  cond := alg.cond
  tbound := alg.tbound
  γbound := alg.γbound
  update1 := alg.update1
  update2 := alg.update2

theorem Nesterov_first_converge (minφ : IsMinOn (f + h) univ xm) :
    ∀ k, f (alg.x (k + 1)) + h (alg.x (k + 1)) -
    f xm - h xm ≤ (alg.γ k) ^ 2 / (2 * alg.t k) * ‖x0 - xm‖ ^ 2 :=
  LeanAgent.OptLib2.Nesterov_first_converge (alg := alg.toOptLib2) minφ
