-- Source: optlib/Optlib/Convex/StronglyConvex.lean line 133
-- Theorem: Strong_Convex_lower
-- Layer 1, Item 04 — strong-convex monotone gradient lower bound

import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Analysis.Convex.Strong
import Optlib.Function.Lsmooth
import Optlib.Convex.ConvexFunction

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
variable {s : Set E} {f : E → ℝ} {m : ℝ} {f' : E → E}

open Set InnerProductSpace

theorem Strong_Convex_lower (hsc : StrongConvexOn s m f) (hf : ∀ x ∈ s, HasGradientAt f (f' x) x) :
    ∀ x ∈ s, ∀ y ∈ s, inner (f' x - f' y) (x - y) ≥ m * ‖x - y‖ ^ 2 := by
  intro x xs y ys
  have cvx := strongConvexOn_iff_convex.mp hsc
  have grd := sub_normsquare_gradient hf m
  have grm := Convex_monotone_gradient' cvx grd x xs y ys
  rw [sub_sub, add_sub, add_comm, ← add_sub, ← sub_sub, inner_sub_left, ← smul_sub] at grm
  apply le_of_sub_nonneg at grm
  rw [real_inner_smul_left, real_inner_self_eq_norm_sq] at grm
  apply grm
