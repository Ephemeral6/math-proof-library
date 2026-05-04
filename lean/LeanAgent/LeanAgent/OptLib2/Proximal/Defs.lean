/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: LeanAgent

# Proximal operator

The proximal point: `u` is a proximal point of `f` at `x` if `u` minimises
`z ↦ f z + ‖z - x‖² / 2`.

## Main definitions

* `prox_prop f x u` — `u` minimises `z ↦ f z + ‖z - x‖² / 2`.
-/

import Mathlib.Analysis.InnerProductSpace.Basic
import LeanAgent.OptLib2.Basic.Defs

namespace LeanAgent.OptLib2

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- `prox_prop f x u` says `u : E` minimises the proximal objective
`z ↦ f z + ‖z - x‖² / 2` over all of `E`. -/
def prox_prop (f : E → ℝ) (x u : E) : Prop :=
  ∀ y : E, f u + ‖u - x‖ ^ 2 / 2 ≤ f y + ‖y - x‖ ^ 2 / 2

end LeanAgent.OptLib2
