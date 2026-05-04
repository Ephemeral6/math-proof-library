-- Source: optlib/Optlib/Function/Proximal.lean line 550
-- Theorem: prox_iff_subderiv
-- Layer 2, Item 08

import Optlib.Function.Proximal

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
variable {f : E → ℝ} {x u : E}

open Set InnerProductSpace

theorem prox_iff_subderiv (f : E → ℝ) (hfun : ConvexOn ℝ univ f) :
    ∀ u : E, prox_prop f x u ↔ x - u ∈ SubderivAt f u := by
  intro u; rw [prox_prop, ← HasSubgradientAt_zero_iff_isMinOn, mem_SubderivAt]
  let g := fun u ↦ ‖u - x‖ ^ 2 / 2
  have hg : ConvexOn ℝ Set.univ g := by apply convex_of_norm_sq x (convex_univ)
  have hcg : ContinuousOn g univ := by
    simp [g]; apply ContinuousOn.div
    apply ContinuousOn.pow _
    · apply ContinuousOn.norm
      apply ContinuousOn.sub continuousOn_id continuousOn_const
    · apply continuousOn_const
    · simp
  show 0 ∈ SubderivAt (f + g) u ↔ x - u ∈ SubderivAt f u
  have : SubderivAt (f + g) u = SubderivAt (g + f) u := by
    unfold SubderivAt; ext z; rw [Set.mem_setOf, Set.mem_setOf];
    constructor
    repeat
    unfold HasSubgradientAt; intro hy y; specialize hy y; simp at hy ⊢; linarith
  rw [this, ← SubderivAt.add hg hfun hcg]
  have subg : SubderivAt g u = {u - x} := by
    let g' := fun u ↦ u - x
    have gderiv : ∀ x, HasGradientAt g (g' x) x := gradient_of_sq
    have : SubderivWithinAt g univ u = {g' u} := by
      apply SubderivWithinAt_eq_gradient; simp
      have gconv : ConvexOn ℝ univ g := by
        rcases hfun with ⟨conv, _⟩
        apply convex_of_norm_sq
        apply conv
      apply gconv; apply gderiv
    rw [← Subderivat_eq_SubderivWithinAt_univ, this]
  rw [subg]; simp
