-- Source: optlib/Optlib/Convex/ConvexFunction.lean line 219
-- Theorem: Convex_first_order_condition' (gradient form)
-- Layer 2, Item 06

import Mathlib.Analysis.Convex.Function
import Mathlib.Analysis.Calculus.MeanValue
import Optlib.Differential.Calculation
import Optlib.Differential.Lemmas
import Optlib.Convex.ConvexFunction

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
variable {f : E → ℝ} {f' : E → E} {s : Set E} {x : E}

open Set InnerProductSpace

theorem Convex_first_order_condition' (h : HasGradientAt f (f' x) x) (hf : ConvexOn ℝ s f)
    (xs : x ∈ s) : ∀ (y : E), y ∈ s → f x + inner (f' x) (y - x) ≤ f y := by
  show ∀ (y : E), y ∈ s → f x + (toDual ℝ E) (f' x) (y - x) ≤ f y
  apply Convex_first_order_condition _ hf xs
  apply h
