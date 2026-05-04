import Mathlib

namespace LeanAgent.Generated

open scoped InnerProductSpace
open Real MeasureTheory intervalIntegral

/-- Descent lemma. -/
theorem descent_lemma_v2 {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [CompleteSpace E]
    {f : E → ℝ} {L : NNReal}
    (hf : Differentiable ℝ f)
    (hL : LipschitzWith L (fun z => gradient f z))
    (x y : E) :
    f y ≤ f x + ⟪gradient f x, y - x⟫_ℝ + (L : ℝ) / 2 * ‖y - x‖^2 := by
  -- step 1: define the path γ(t) = x + t • (y - x)
  set γ : ℝ → E := fun t => x + t • (y - x) with hγ
  -- step 2: at every t, t ↦ f (γ t) has derivative ⟪gradient f (γ t), y - x⟫
  have h2 : ∀ t : ℝ, HasDerivAt (fun s => f (γ s))
              (⟪gradient f (γ t), y - x⟫_ℝ) t := by
    sorry  -- STUCK_2: chain rule for f ∘ γ; needs HasFDerivAt.comp and Riesz representation linking gradient to fderiv
  -- step 3: by FTC, f(y) - f(x) = ∫₀¹ ⟪gradient f (γ t), y - x⟫ dt
  have h3 : f y - f x = ∫ t in (0:ℝ)..1, ⟪gradient f (γ t), y - x⟫_ℝ := by
    sorry  -- STUCK_3: FTC application via intervalIntegral.integral_eq_sub_of_hasDerivAt; needs h2 + continuity hypothesis
  -- step 4: split the integrand pointwise
  have h4 : ∀ t : ℝ, ⟪gradient f (γ t), y - x⟫_ℝ
              = ⟪gradient f x, y - x⟫_ℝ + ⟪gradient f (γ t) - gradient f x, y - x⟫_ℝ := by
    intro t
    rw [inner_sub_left]; ring
  -- step 5: split the integral
  have h5 : (∫ t in (0:ℝ)..1, ⟪gradient f (γ t), y - x⟫_ℝ)
              = ⟪gradient f x, y - x⟫_ℝ
                + ∫ t in (0:ℝ)..1, ⟪gradient f (γ t) - gradient f x, y - x⟫_ℝ := by
    have hsplit : (∫ t in (0:ℝ)..1, ⟪gradient f (γ t), y - x⟫_ℝ)
        = (∫ _t in (0:ℝ)..1, ⟪gradient f x, y - x⟫_ℝ)
          + ∫ t in (0:ℝ)..1, ⟪gradient f (γ t) - gradient f x, y - x⟫_ℝ := by
      simp_rw [h4]
      sorry  -- STUCK_1: integrability of ⟪gradient f (γ t) - gradient f x, y - x⟫_ℝ on [0,1]
    rw [hsplit]
    congr 1
    simp
  -- step 6: Cauchy-Schwarz pointwise
  have h6 : ∀ t : ℝ, |⟪gradient f (γ t) - gradient f x, y - x⟫_ℝ|
              ≤ ‖gradient f (γ t) - gradient f x‖ * ‖y - x‖ := by
    intro t
    have h := @norm_inner_le_norm ℝ E _ _ _ (gradient f (γ t) - gradient f x) (y - x)
    simpa [Real.norm_eq_abs] using h
  -- step 7: Lipschitz bound on gradient difference
  have h7 : ∀ t : ℝ, t ∈ Set.Icc (0:ℝ) 1 →
              ‖gradient f (γ t) - gradient f x‖ ≤ (L : ℝ) * t * ‖y - x‖ := by
    intro t ht
    have hLip : ‖gradient f (γ t) - gradient f x‖ ≤ (L : ℝ) * ‖γ t - x‖ := by
      have := hL.dist_le_mul (γ t) x
      simp [dist_eq_norm] at this
      exact this
    have hgamma : γ t - x = t • (y - x) := by
      simp [hγ]
    have hnorm : ‖γ t - x‖ = t * ‖y - x‖ := by
      rw [hgamma, norm_smul, Real.norm_eq_abs, abs_of_nonneg ht.1]
    calc ‖gradient f (γ t) - gradient f x‖
        ≤ (L : ℝ) * ‖γ t - x‖ := hLip
      _ = (L : ℝ) * (t * ‖y - x‖) := by rw [hnorm]
      _ = (L : ℝ) * t * ‖y - x‖ := by ring
  -- step 8: integrate the bound
  have h8 : (∫ t in (0:ℝ)..1, ⟪gradient f (γ t) - gradient f x, y - x⟫_ℝ)
              ≤ (L : ℝ) / 2 * ‖y - x‖^2 := by
    sorry  -- STUCK_4: integral monotonicity + Cauchy-Schwarz pointwise (h6) + Lipschitz bound (h7) + ∫₀¹ t dt = 1/2; needs intervalIntegral.integral_mono
  -- step 9: combine
  have h9 : f y - f x ≤ ⟪gradient f x, y - x⟫_ℝ + (L : ℝ) / 2 * ‖y - x‖^2 := by
    rw [h3, h5]; linarith [h8]
  linarith [h9]

end LeanAgent.Generated
