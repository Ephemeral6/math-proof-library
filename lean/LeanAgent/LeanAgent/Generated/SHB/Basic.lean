/-
SHB.Foundations.Basic — Layer 1 structural properties of the SHB iteration.

Contents:

  * `shbPrev`                                — accessor for the trailing iterate `xₜ₋₁`
  * `shbIter_succ` / `shbStochIter_succ`     — closed-form recurrence
  * `gdIter` and `shbIter_beta_zero`         — SHB at `β = 0` reduces to GD
  * `isClosed_stabilityRegion_ineq`          — the defining inequality is closed
  * `stabilityRegion_eq_inter`               — `S(L) = closed inequality ∩ parameter strip`
-/
import LeanAgent.Generated.SHB.Defs

namespace SHB
namespace Foundations

/-! ## Iteration unfolding -/

section Iter
variable {E : Type*} [AddCommGroup E] [Module ℝ E]

/-- The "previous iterate" component `xₜ₋₁` of the SHB state pair at time `t`.
At `t = 0` it returns the seeded `xPrev`; at `t = k+1` it returns the deterministic
iterate `xₖ`. -/
def shbPrev (β η : ℝ) (f' : E → E) (x₀ xPrev : E) (t : ℕ) : E :=
  (shbState β η f' x₀ xPrev t).2

@[simp] lemma shbPrev_zero (β η : ℝ) (f' : E → E) (x₀ xPrev : E) :
    shbPrev β η f' x₀ xPrev 0 = xPrev := rfl

@[simp] lemma shbPrev_succ (β η : ℝ) (f' : E → E) (x₀ xPrev : E) (t : ℕ) :
    shbPrev β η f' x₀ xPrev (t + 1) = shbIter β η f' x₀ xPrev t := rfl

/-- Closed-form recurrence for the deterministic SHB iterate:
`xₜ₊₁ = xₜ - η • f'(xₜ) + β • (xₜ - xₜ₋₁)`. -/
theorem shbIter_succ (β η : ℝ) (f' : E → E) (x₀ xPrev : E) (t : ℕ) :
    shbIter β η f' x₀ xPrev (t + 1) =
      shbIter β η f' x₀ xPrev t
        - η • f' (shbIter β η f' x₀ xPrev t)
        + β • (shbIter β η f' x₀ xPrev t - shbPrev β η f' x₀ xPrev t) := rfl

/-- Closed-form recurrence for the stochastic SHB iterate. -/
theorem shbStochIter_succ
    (β η : ℝ) (f' : E → E) (ξ : ℕ → E) (x₀ xPrev : E) (t : ℕ) :
    shbStochIter β η f' ξ x₀ xPrev (t + 1) =
      shbStochIter β η f' ξ x₀ xPrev t
        - η • (f' (shbStochIter β η f' ξ x₀ xPrev t) + ξ t)
        + β • (shbStochIter β η f' ξ x₀ xPrev t -
                (shbStochState β η f' ξ x₀ xPrev t).2) := rfl

/-! ## Reduction to gradient descent at `β = 0` -/

/-- Plain gradient descent iteration with step size `η` and gradient operator `f'`. -/
def gdIter (η : ℝ) (f' : E → E) (x₀ : E) : ℕ → E
  | 0     => x₀
  | t + 1 => gdIter η f' x₀ t - η • f' (gdIter η f' x₀ t)

@[simp] lemma gdIter_zero (η : ℝ) (f' : E → E) (x₀ : E) :
    gdIter η f' x₀ 0 = x₀ := rfl

lemma gdIter_succ (η : ℝ) (f' : E → E) (x₀ : E) (t : ℕ) :
    gdIter η f' x₀ (t + 1) = gdIter η f' x₀ t - η • f' (gdIter η f' x₀ t) := rfl

/-- At `β = 0`, the deterministic SHB recurrence collapses to a single
gradient-descent step (the momentum term vanishes). -/
lemma shbIter_succ_beta_zero
    (η : ℝ) (f' : E → E) (x₀ xPrev : E) (t : ℕ) :
    shbIter (0 : ℝ) η f' x₀ xPrev (t + 1) =
      shbIter (0 : ℝ) η f' x₀ xPrev t - η • f' (shbIter (0 : ℝ) η f' x₀ xPrev t) := by
  rw [shbIter_succ]
  simp

/-- SHB with `β = 0` produces exactly the gradient-descent iterates from `x₀`,
independently of the seed `xPrev`. -/
theorem shbIter_beta_zero
    (η : ℝ) (f' : E → E) (x₀ xPrev : E) (t : ℕ) :
    shbIter (0 : ℝ) η f' x₀ xPrev t = gdIter η f' x₀ t := by
  induction t with
  | zero => rfl
  | succ t ih =>
      rw [shbIter_succ_beta_zero, gdIter_succ, ih]

end Iter

/-! ## Closedness of the stability region -/

section Region

/-- The defining inequality `η ≤ 2(1+β)/L` of the Polyak stability region
cuts out a closed set in the parameter plane `ℝ × ℝ`. -/
theorem isClosed_stabilityRegion_ineq (L : ℝ) :
    IsClosed {p : ℝ × ℝ | p.2 ≤ 2 * (1 + p.1) / L} := by
  refine isClosed_le ?_ ?_
  · exact continuous_snd
  · exact ((continuous_const.add continuous_fst).const_mul 2).div_const L

/-- Decomposition of the stability region as the intersection of the defining
closed inequality with the parameter half-strip `[0, 1) × (0, ∞)`. This makes
the relative closedness of `stabilityRegion L` in the parameter strip
immediate. -/
theorem stabilityRegion_eq_inter (L : ℝ) :
    stabilityRegion L =
      {p : ℝ × ℝ | p.2 ≤ 2 * (1 + p.1) / L}
        ∩ (Set.Ico (0 : ℝ) 1 ×ˢ Set.Ioi (0 : ℝ)) := by
  ext ⟨β, η⟩
  constructor
  · rintro ⟨h1, h2, h3, h4⟩
    exact ⟨h4, ⟨h1, h2⟩, h3⟩
  · rintro ⟨h4, ⟨h1, h2⟩, h3⟩
    exact ⟨h1, h2, h3, h4⟩

end Region

end Foundations
end SHB
