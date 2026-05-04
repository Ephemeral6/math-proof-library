-- Source: optlib/Optlib/Function/Lsmooth.lean line 146
-- Theorem: lipschitz_continuos_upper_bound'  (note: optlib spelling is "continuos")
-- Layer 1, Item 03 — the descent lemma (gradient form)

import Mathlib.Topology.EMetricSpace.Lipschitz
import Mathlib.Analysis.Calculus.Deriv.Pow
import Optlib.Optimality.OptimalityConditionOfUnconstrainedProblem
import Optlib.Differential.Lemmas
import Optlib.Function.Lsmooth

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

open InnerProductSpace Set

variable {f : E → ℝ} {a : ℝ} {f' : E → E} {xm : E} {l : NNReal}

theorem lipschitz_continuos_upper_bound'
    (h₁ : ∀ x₁ : E, HasGradientAt f (f' x₁) x₁) (h₂ : LipschitzWith l f') :
    ∀ x y : E, f y ≤ f x + inner (f' x) (y - x) + l / 2 * ‖y - x‖ ^ 2 := by
  intro x y
  rw [lipschitzWith_iff_norm_sub_le] at h₂
  let g := fun x ↦ (toDual ℝ E) (f' x)
  have h' : ∀ x : E, HasFDerivAt f (g x) x := h₁
  have equiv : ∀ x y : E, inner (f' x) (y - x) = (g x) (y - x) := by
    intro x y
    rw [InnerProductSpace.toDual_apply]
  have h₂' : LipschitzWith l g := by
    simp only [g, equiv]
    rw [lipschitzWith_iff_norm_sub_le]
    intro x y
    have h1 : ∀ x : E, ‖(toDual ℝ E) x‖ =‖x‖ := by
      simp [LinearIsometryEquiv.norm_map]
    have : ‖(toDual ℝ E) (f' x) - (toDual ℝ E) (f' y)‖ = ‖f' x - f' y‖ := by
      rw [← map_sub (toDual ℝ E) (f' x) (f' y)]
      exact h1 (f' x - f' y)
    rw [this]
    exact h₂ x y
  rw [equiv]
  exact lipschitz_continuous_upper_bound h' h₂' x y
