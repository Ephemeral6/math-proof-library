-- Source: optlib/Optlib/Convex/StronglyConvex.lean line 35
-- Theorem: stronglyConvexOn_def
-- Layer 1, Item 02

import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Analysis.Convex.Strong
import Optlib.Function.Lsmooth

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable {s : Set E} {f : E → ℝ} {m : ℝ}

open Set InnerProductSpace

theorem stronglyConvexOn_def (hs : Convex ℝ s)
    (hfun : ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s →
      ∀ ⦃a⦄, 0 ≤ a → ∀ ⦃b⦄, 0 ≤ b → a + b = 1 → f (a • x + b • y)
        ≤ a * f x + b * f y - m / 2 * a * b * ‖x - y‖ ^ 2) :
    StrongConvexOn s m f := by
  constructor
  · exact hs
  intro x hx y hy a b ha hb hab
  specialize hfun hx hy ha hb hab
  dsimp
  have : m / 2 * a * b * ‖x - y‖ ^ 2 = a * b * (m / 2 * ‖x - y‖ ^ 2) := by ring_nf
  simp at this;
  rw [← this]; exact hfun
