import Mathlib
import LeanAgent.Generated.convex_first_order_condition_grad_depth2_idx1

namespace LeanAgent.Generated

open InnerProductSpace

/-- Synthesized helper at depth 1 (parent: strong_convex_gradient_lower_bound).
    Convex + gradient-everywhere ⇒ monotone gradient (gradient form):
    ⟨f' x - f' y, x - y⟩ ≥ 0  for all x, y ∈ s. -/
theorem convex_monotone_gradient_prime_helper_depth1_idx2
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
    {s : Set E} {f : E → ℝ} {f' : E → E}
    (hfun : ConvexOn ℝ s f)
    (h : ∀ x ∈ s, HasGradientAt f (f' x) x) :
    ∀ x ∈ s, ∀ y ∈ s, inner ℝ (f' x - f' y) (x - y) ≥ (0 : ℝ) := by
  -- step 1: first-order condition (gradient form) — closed by depth-2 child
  have hfo : ∀ x ∈ s, ∀ y ∈ s, f x + inner ℝ (f' x) (y - x) ≤ f y :=
    convex_first_order_condition_grad_depth2_idx1 hfun h
  -- step 2: apply at (x,y) and (y,x), sum
  intro x xs y ys
  have h1 : f x + inner ℝ (f' x) (y - x) ≤ f y := hfo x xs y ys
  have h2 : f y + inner ℝ (f' y) (x - y) ≤ f x := hfo y ys x xs
  have h3 : inner ℝ (f' x) (y - x) + inner ℝ (f' y) (x - y) ≤ 0 := by linarith
  -- inner is bilinear: ⟨f'x, y-x⟩ + ⟨f'y, x-y⟩ = -⟨f'x - f'y, x-y⟩
  have key : inner ℝ (f' x) (y - x) + inner ℝ (f' y) (x - y)
              = - inner ℝ (f' x - f' y) (x - y) := by
    rw [show (y - x : E) = -(x - y) by abel, inner_neg_right, inner_sub_left]
    ring
  linarith [key ▸ h3]

end LeanAgent.Generated
