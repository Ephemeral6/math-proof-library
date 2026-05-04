-- Source: optlib/Optlib/Optimality/OptimalityConditionOfUnconstrainedProblem.lean line 99
-- Theorem: first_order_unconstrained
-- Layer 1, Item 05 — gradient = 0 at unconstrained minimum

import Mathlib.Analysis.Convex.Basic
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Analysis.InnerProductSpace.Positive
import Optlib.Convex.ConvexFunction

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
variable {x xm : E} {f : E → ℝ} {f' : E → E}

open Set InnerProductSpace

theorem first_order_unconstrained (hf : ∀ x : E, HasGradientAt f (f' x) x) (min : IsMinOn f univ xm)
    (hfc : ContinuousOn f' univ) : f' xm = 0 := by
  by_contra h
  have h1: DescentDirection (-f' xm) xm (hf xm) := by
    rw [DescentDirection, inner_neg_right, Left.neg_neg_iff]
    rw [real_inner_self_eq_norm_sq]
    simp [h]
  exact (optimal_no_descent_direction hf min hfc (- f' xm)) h1
