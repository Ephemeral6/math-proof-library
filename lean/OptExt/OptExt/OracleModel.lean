/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: OptExt contributors

# First-order oracle complexity model

The standard *deterministic* first-order oracle model (Nemirovski–Yudin
1983, Nesterov 2004): an algorithm queries `f(x)` and `∇f(x)` at chosen
points; lower bounds are stated against the entire class of such
algorithms.

The defining structural restriction is the *span condition*: the
`(k+1)`-th query point must lie in the affine hull of the initial point
plus the linear span of all gradients seen so far,
`x₀ + span{∇f(x₀), …, ∇f(x_k)}`.  Lower bounds for the function class
become "for any span-restricted algorithm there exists `f` such that …".

## Main definitions

* `FirstOrderAlgorithm`     — any sequence-producing algorithm with access
                              to the gradient oracle of `f`.
* `IsSpanRestricted`        — algorithm respects the span condition.
* `gradientSpan f x₀ T`     — the cumulative gradient span at iteration `T`.

The lower-bound theorems live in `OptExt.NesterovLowerBound` and
`OptExt.StrongConvexLowerBound`.

## References

* Nesterov (2004).  Introductory lectures on convex optimization, Theorem 2.1.7.
* Nemirovski–Yudin (1983).  Problem complexity and method efficiency.
-/

import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.Calculus.Gradient.Basic
import Mathlib.LinearAlgebra.Span

import Optlib.Function.Lsmooth

namespace OptExt

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

/-- A first-order algorithm: a function producing a query sequence given
the initial point and an oracle for the gradient.  Stated abstractly so
that lower-bound arguments can quantify over all possible algorithms. -/
structure FirstOrderAlgorithm (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℝ E] where
  /-- The iterate produced at step `k`, given the initial point `x₀` and the
  gradient oracle `f' : E → E`. -/
  iterate : E → (E → E) → ℕ → E

/-- The cumulative *gradient span* at iteration `T`, defined as the linear
span of `f' (x_0), f' (x_1), …, f' (x_T)`. -/
noncomputable def gradientSpan (alg : FirstOrderAlgorithm E)
    (f' : E → E) (x₀ : E) (T : ℕ) : Submodule ℝ E :=
  Submodule.span ℝ
    (Set.range (fun k : Fin (T + 1) => f' (alg.iterate x₀ f' k.val)))

/-- The *span restriction*: each iterate must lie in the affine hull
`x₀ + gradientSpan f' x₀ k`.  Most natural first-order methods (GD,
heavy ball, Nesterov, conjugate gradient) satisfy this. -/
def IsSpanRestricted (alg : FirstOrderAlgorithm E) : Prop :=
  ∀ (f' : E → E) (x₀ : E) (T : ℕ),
    alg.iterate x₀ f' (T + 1) - x₀ ∈ gradientSpan alg f' x₀ T

/-- Achieves accuracy `ε` in `T` steps. -/
def AchievesAccuracy
    (alg : FirstOrderAlgorithm E)
    (f : E → ℝ) (f' : E → E) (x₀ xstar : E) (ε : ℝ) (T : ℕ) : Prop :=
  f (alg.iterate x₀ f' T) - f xstar ≤ ε

end OptExt
