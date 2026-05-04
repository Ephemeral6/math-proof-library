/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: LeanAgent

# Basic optimization definitions

This module provides foundational definitions for optimization theory:

* `IsLSmooth` — `f` has an `L`-Lipschitz gradient `f'`.
* `HasSubgradientAt` — `g` is a subgradient of `f` at `x`.
* `SubderivAt` — the subdifferential of `f` at `x` (set of subgradients).

These are stated in terms of Mathlib's `HasGradientAt` and `LipschitzWith`,
with no dependency on optlib.
-/

import Mathlib.Analysis.Calculus.Gradient.Basic
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Topology.EMetricSpace.Lipschitz

namespace LeanAgent.OptLib2

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

section Smooth
variable [CompleteSpace E]

/-- `f : E → ℝ` is **`L`-smooth** with gradient `f' : E → E` if `f'` is the
gradient of `f` at every point and is `L`-Lipschitz. -/
structure IsLSmooth (f : E → ℝ) (f' : E → E) (L : NNReal) : Prop where
  /-- `f'` is the gradient of `f` at every point. -/
  hasGradient : ∀ x : E, HasGradientAt f (f' x) x
  /-- `f'` is `L`-Lipschitz. -/
  lipschitz : LipschitzWith L f'

end Smooth

/-- `g : E` is a **subgradient** of `f` at `x` if `f x + ⟨g, y - x⟩ ≤ f y`
for every `y`. This is the standard convex-analysis subgradient condition. -/
def HasSubgradientAt (f : E → ℝ) (g x : E) : Prop :=
  ∀ y : E, f x + inner ℝ g (y - x) ≤ f y

/-- The **subdifferential** of `f` at `x` is the set of all subgradients of
`f` at `x`. -/
def SubderivAt (f : E → ℝ) (x : E) : Set E :=
  {g | HasSubgradientAt f g x}

@[simp]
theorem mem_SubderivAt {f : E → ℝ} {g x : E} :
    g ∈ SubderivAt f x ↔ ∀ y, f x + inner ℝ g (y - x) ≤ f y :=
  Iff.rfl

end LeanAgent.OptLib2
