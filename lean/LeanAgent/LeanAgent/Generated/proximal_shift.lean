import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.Normed.Group.Basic

namespace LeanAgent.Generated

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- `prox_prop f x z` says that `z` minimizes `u ↦ f u + ‖u - x‖^2 / 2` over the whole space. -/
def prox_prop (f : E → ℝ) (x z : E) : Prop :=
  ∀ y : E, f z + ‖z - x‖ ^ 2 / 2 ≤ f y + ‖y - x‖ ^ 2 / 2

variable {x : E} {f : E → ℝ}

/-- Proximal shift identity. Let `a ∈ E`, `t ≠ 0`. Then `z` is a proximal point of `x` for the
function `u ↦ f(t • u + a)` if and only if `t • z + a` is a proximal point of `t • x + a` for
the scaled function `t^2 • f`. -/
theorem proximal_shift (a : E) {t : ℝ} (tnz : t ≠ 0) (f : E → ℝ) :
    ∀ z : E, prox_prop (fun u ↦ f (t • u + a)) x z ↔
      prox_prop (t ^ 2 • f) (t • x + a) (t • z + a) := by
  intro z
  have ht_sq_pos : (0 : ℝ) < t ^ 2 := by positivity
  -- Algebraic helpers
  have hsmul_sub (u v : E) : t • u - t • v = t • (u - v) := by rw [smul_sub]
  have hnorm_t (u v : E) : ‖t • u - t • v‖ = |t| * ‖u - v‖ := by
    rw [hsmul_sub, norm_smul, Real.norm_eq_abs]
  -- Reformulate both sides as inequalities; then show equivalence by the substitution y = t • w + a
  constructor
  · -- Forward: from prox_prop on f∘(t•·+a) at x, derive prox_prop on t^2 • f at (t•x+a).
    intro hz w
    -- Choose witness y = t⁻¹ • (w - a) on the original side
    have hyw : t • (t⁻¹ • (w - a)) + a = w := by
      rw [smul_smul, mul_inv_cancel₀ tnz, one_smul, sub_add_cancel]
    -- Apply hz at y = t⁻¹ • (w - a)
    specialize hz (t⁻¹ • (w - a))
    -- Beta-reduce the lambda inside hz, then rewrite using hyw to identify the value as f w.
    show (t ^ 2 • f) (t • z + a) + ‖t • z + a - (t • x + a)‖ ^ 2 / 2
       ≤ (t ^ 2 • f) w + ‖w - (t • x + a)‖ ^ 2 / 2
    have hz' : f (t • z + a) + ‖z - x‖ ^ 2 / 2
             ≤ f w + ‖t⁻¹ • (w - a) - x‖ ^ 2 / 2 := by
      have hbeta : f (t • t⁻¹ • (w - a) + a) = f w := by rw [hyw]
      simpa [hbeta] using hz
    -- Multiply both sides by t^2 (positive):
    have key : t ^ 2 * (f (t • z + a) + ‖z - x‖ ^ 2 / 2)
             ≤ t ^ 2 * (f w + ‖t⁻¹ • (w - a) - x‖ ^ 2 / 2) :=
      mul_le_mul_of_nonneg_left hz' (le_of_lt ht_sq_pos)
    -- Identify t^2 * (... ‖z - x‖^2 / 2) with ‖t • z - t • x‖^2 / 2
    -- and t^2 * ‖t⁻¹ • (w - a) - x‖^2 / 2 with ‖(w - a) - t • x‖^2 / 2
    have lhs_eq : t ^ 2 * (f (t • z + a) + ‖z - x‖ ^ 2 / 2)
                = (t ^ 2 • f) (t • z + a) + ‖t • z + a - (t • x + a)‖ ^ 2 / 2 := by
      have h1 : ‖t • z + a - (t • x + a)‖ = |t| * ‖z - x‖ := by
        rw [show t • z + a - (t • x + a) = t • z - t • x from by abel]
        exact hnorm_t z x
      rw [h1]
      simp only [Pi.smul_apply, smul_eq_mul, mul_pow, sq_abs]
      ring
    have rhs_eq : t ^ 2 * (f w + ‖t⁻¹ • (w - a) - x‖ ^ 2 / 2)
                = (t ^ 2 • f) w + ‖w - (t • x + a)‖ ^ 2 / 2 := by
      have h2 : t • (t⁻¹ • (w - a) - x) = (w - a) - t • x := by
        rw [smul_sub, smul_smul, mul_inv_cancel₀ tnz, one_smul]
      have h3 : |t| * ‖t⁻¹ • (w - a) - x‖ = ‖w - (t • x + a)‖ := by
        rw [← Real.norm_eq_abs, ← norm_smul]
        congr 1
        rw [show (w - a) - t • x = w - (t • x + a) from by abel] at h2
        rw [show t • (t⁻¹ • (w - a) - x) = w - (t • x + a) from h2]
      have hsq : (|t| * ‖t⁻¹ • (w - a) - x‖) ^ 2 = ‖w - (t • x + a)‖ ^ 2 := by rw [h3]
      have hsq' : t ^ 2 * ‖t⁻¹ • (w - a) - x‖ ^ 2 = ‖w - (t • x + a)‖ ^ 2 := by
        have : (|t| * ‖t⁻¹ • (w - a) - x‖) ^ 2
             = |t| ^ 2 * ‖t⁻¹ • (w - a) - x‖ ^ 2 := by ring
        rw [this, sq_abs] at hsq; exact hsq
      simp [Pi.smul_apply, smul_eq_mul]
      linarith [hsq']
    rw [lhs_eq, rhs_eq] at key
    exact key
  · -- Backward: symmetric.
    intro hz y
    -- Choose witness w = t • y + a on the scaled side.
    specialize hz (t • y + a)
    -- hz says:
    -- (t^2 • f) (t • z + a) + ‖t•z+a - (t•x+a)‖^2/2 ≤ (t^2 • f) (t•y+a) + ‖t•y+a - (t•x+a)‖^2/2
    have lhs_eq : (t ^ 2 • f) (t • z + a) + ‖t • z + a - (t • x + a)‖ ^ 2 / 2
                = t ^ 2 * (f (t • z + a) + ‖z - x‖ ^ 2 / 2) := by
      have h1 : ‖t • z + a - (t • x + a)‖ = |t| * ‖z - x‖ := by
        rw [show t • z + a - (t • x + a) = t • z - t • x from by abel]
        exact hnorm_t z x
      rw [h1]
      simp only [Pi.smul_apply, smul_eq_mul, mul_pow, sq_abs]
      ring
    have rhs_eq : (t ^ 2 • f) (t • y + a) + ‖t • y + a - (t • x + a)‖ ^ 2 / 2
                = t ^ 2 * (f (t • y + a) + ‖y - x‖ ^ 2 / 2) := by
      have h1 : ‖t • y + a - (t • x + a)‖ = |t| * ‖y - x‖ := by
        rw [show t • y + a - (t • x + a) = t • y - t • x from by abel]
        exact hnorm_t y x
      rw [h1]
      simp only [Pi.smul_apply, smul_eq_mul, mul_pow, sq_abs]
      ring
    rw [lhs_eq, rhs_eq] at hz
    exact le_of_mul_le_mul_left hz ht_sq_pos

end LeanAgent.Generated

#print axioms LeanAgent.Generated.proximal_shift
