-- Sanity check for Item 02 stronglyConvexOn_def
-- The agent's signature is type-equivalent to optlib's original. We verify by
-- proving it both ways in the same file: once with the agent's tactic body,
-- once via direct constructor (which is what optlib does).

import Mathlib.Analysis.Convex.Strong
import Mathlib.Analysis.InnerProductSpace.Basic

-- Agent's signature
theorem agent_strongly_convex_on_def
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {s : Set E} {f : E → ℝ} {m : ℝ}
    (hs : Convex ℝ s)
    (hfun : ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s →
      ∀ ⦃a⦄, 0 ≤ a → ∀ ⦃b⦄, 0 ≤ b → a + b = 1 →
      f (a • x + b • y) ≤ a * f x + b * f y - m / 2 * a * b * ‖x - y‖ ^ 2) :
    StrongConvexOn s m f := by
  refine ⟨?_, ?_⟩
  · exact hs
  intro x hx y hy a b ha hb hab
  have h_hfun : f (a • x + b • y) ≤ a * f x + b * f y - m / 2 * a * b * ‖x - y‖ ^ 2 :=
    hfun hx hy ha hb hab
  dsimp
  have h_rewrite : m / 2 * a * b * ‖x - y‖ ^ 2 = a * b * (m / 2 * ‖x - y‖ ^ 2) := by ring
  linarith [h_hfun, h_rewrite]

-- Optlib's original signature (renamed to avoid clash) — same hypotheses, same conclusion
theorem optlib_stronglyConvexOn_def
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {s : Set E} {f : E → ℝ} {m : ℝ}
    (hs : Convex ℝ s)
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
  simp at this
  rw [← this]; exact hfun

-- Cross-test: agent's theorem can be invoked from optlib's hypotheses, and vice-versa.
example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {s : Set E} {f : E → ℝ} {m : ℝ}
    (hs : Convex ℝ s)
    (hfun : ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s →
      ∀ ⦃a⦄, 0 ≤ a → ∀ ⦃b⦄, 0 ≤ b → a + b = 1 →
      f (a • x + b • y) ≤ a * f x + b * f y - m / 2 * a * b * ‖x - y‖ ^ 2) :
    StrongConvexOn s m f :=
  agent_strongly_convex_on_def hs hfun

example {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    {s : Set E} {f : E → ℝ} {m : ℝ}
    (hs : Convex ℝ s)
    (hfun : ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s →
      ∀ ⦃a⦄, 0 ≤ a → ∀ ⦃b⦄, 0 ≤ b → a + b = 1 →
      f (a • x + b • y) ≤ a * f x + b * f y - m / 2 * a * b * ‖x - y‖ ^ 2) :
    StrongConvexOn s m f :=
  optlib_stronglyConvexOn_def hs hfun

#print axioms agent_strongly_convex_on_def
#print axioms optlib_stronglyConvexOn_def
