/-
SHB.Foundations.Descent — Layer 2 single-step descent inequalities.

Given `f : E → ℝ` with pointwise gradient `f'` and `LipschitzWith l f'`, the
classical descent lemma yields a sufficient-decrease inequality. We specialise
it to:

  * `shb_step_descent`            — SHB single-step descent
  * `shb_step_descent_expanded`   — same, with the SHB step explicitly substituted
  * `gd_step_descent`             — GD single-step descent (β = 0 reduction)
  * `shb_step_descent_at_beta_zero` — coincidence of SHB and GD descent at β = 0

The descent lemma in gradient form is reused from
`LeanAgent.Generated.descent_lemma_v3` rather than re-proven.
-/
import LeanAgent.Generated.SHB.Defs
import LeanAgent.Generated.SHB.Basic
import LeanAgent.Generated.descent_lemma_v3

namespace SHB
namespace Foundations

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

open scoped InnerProductSpace

/-- **SHB single-step sufficient decrease.**
If `f` has gradient `f'` everywhere and `f'` is `l`-Lipschitz, then for every
SHB iterate pair `(xₜ, xₜ₊₁)`:
`f(xₜ₊₁) ≤ f(xₜ) + ⟨f'(xₜ), xₜ₊₁ − xₜ⟩ + (l/2)·‖xₜ₊₁ − xₜ‖²`. -/
theorem shb_step_descent
    {f : E → ℝ} {f' : E → E} {l : NNReal}
    (h₁ : ∀ x : E, HasGradientAt f (f' x) x)
    (h₂ : LipschitzWith l f')
    (β η : ℝ) (x₀ xPrev : E) (t : ℕ) :
    f (shbIter β η f' x₀ xPrev (t + 1)) ≤
      f (shbIter β η f' x₀ xPrev t) +
        inner ℝ (f' (shbIter β η f' x₀ xPrev t))
          (shbIter β η f' x₀ xPrev (t + 1) - shbIter β η f' x₀ xPrev t) +
        l / 2 * ‖shbIter β η f' x₀ xPrev (t + 1) - shbIter β η f' x₀ xPrev t‖ ^ 2 :=
  LeanAgent.Generated.descent_lemma_gradient_form h₁ h₂ _ _

/-- **SHB single-step descent (expanded form).**
The step `xₜ₊₁ − xₜ = β · (xₜ − xₜ₋₁) − η · f'(xₜ)` is substituted into the
right-hand side, giving an inequality in terms of the gradient and the
"momentum direction". -/
theorem shb_step_descent_expanded
    {f : E → ℝ} {f' : E → E} {l : NNReal}
    (h₁ : ∀ x : E, HasGradientAt f (f' x) x)
    (h₂ : LipschitzWith l f')
    (β η : ℝ) (x₀ xPrev : E) (t : ℕ) :
    f (shbIter β η f' x₀ xPrev (t + 1)) ≤
      f (shbIter β η f' x₀ xPrev t) +
        inner ℝ (f' (shbIter β η f' x₀ xPrev t))
          (β • (shbIter β η f' x₀ xPrev t - shbPrev β η f' x₀ xPrev t) -
            η • f' (shbIter β η f' x₀ xPrev t)) +
        l / 2 * ‖β • (shbIter β η f' x₀ xPrev t - shbPrev β η f' x₀ xPrev t) -
            η • f' (shbIter β η f' x₀ xPrev t)‖ ^ 2 := by
  have hbound := shb_step_descent h₁ h₂ β η x₀ xPrev t
  have hstep : shbIter β η f' x₀ xPrev (t + 1) - shbIter β η f' x₀ xPrev t =
      β • (shbIter β η f' x₀ xPrev t - shbPrev β η f' x₀ xPrev t) -
        η • f' (shbIter β η f' x₀ xPrev t) := by
    rw [shbIter_succ]
    abel
  rw [hstep] at hbound
  exact hbound

/-- **GD single-step sufficient decrease.** Direct specialisation of the
descent lemma to the gradient-descent iterate. -/
theorem gd_step_descent
    {f : E → ℝ} {f' : E → E} {l : NNReal}
    (h₁ : ∀ x : E, HasGradientAt f (f' x) x)
    (h₂ : LipschitzWith l f')
    (η : ℝ) (x₀ : E) (t : ℕ) :
    f (gdIter η f' x₀ (t + 1)) ≤
      f (gdIter η f' x₀ t) +
        inner ℝ (f' (gdIter η f' x₀ t))
          (gdIter η f' x₀ (t + 1) - gdIter η f' x₀ t) +
        l / 2 * ‖gdIter η f' x₀ (t + 1) - gdIter η f' x₀ t‖ ^ 2 :=
  LeanAgent.Generated.descent_lemma_gradient_form h₁ h₂ _ _

/-- **At β = 0, the SHB descent inequality coincides with the GD descent
inequality** applied to the gradient-descent iterates from `x₀`. -/
theorem shb_step_descent_at_beta_zero
    {f : E → ℝ} {f' : E → E} {l : NNReal}
    (h₁ : ∀ x : E, HasGradientAt f (f' x) x)
    (h₂ : LipschitzWith l f')
    (η : ℝ) (x₀ xPrev : E) (t : ℕ) :
    f (shbIter (0 : ℝ) η f' x₀ xPrev (t + 1)) ≤
      f (gdIter η f' x₀ t) +
        inner ℝ (f' (gdIter η f' x₀ t))
          (gdIter η f' x₀ (t + 1) - gdIter η f' x₀ t) +
        l / 2 * ‖gdIter η f' x₀ (t + 1) - gdIter η f' x₀ t‖ ^ 2 := by
  rw [shbIter_beta_zero]
  exact gd_step_descent h₁ h₂ η x₀ t

end Foundations
end SHB
