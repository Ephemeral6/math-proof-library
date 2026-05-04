import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.Normed.Group.Basic

namespace LeanAgent.Generated

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- `prox_prop f x z` says that `z` minimizes `u ↦ f u + ‖u - x‖^2 / 2` over the whole space. -/
def prox_prop (f : E → ℝ) (x z : E) : Prop :=
  ∀ y : E, f z + ‖z - x‖ ^ 2 / 2 ≤ f y + ‖y - x‖ ^ 2 / 2

variable {x : E} {f : E → ℝ}

/-- Proximal addition with a quadratic. If `l > 0`, then `z` is a proximal point of `x` for
`f(·) + (l/2)·‖· - a‖^2` if and only if `z` is a proximal point of `(1/(l+1)) · (x + l • a)`
for the scaled function `(1/(l+1)) • f`. -/
theorem proximal_add_sq (a : E) {l : ℝ} (lpos : 0 < l) (f : E → ℝ) :
    ∀ z : E, prox_prop (fun u ↦ f u + l / 2 * ‖u - a‖ ^ 2) x z ↔
      prox_prop ((1 / (l + 1)) • f) ((1 / (l + 1)) • (x + l • a)) z := by
  intro z
  -- Key algebraic identity: for any v, the squared-distance from v to (1/(l+1))·(x + l•a)
  -- expands as (l+1)⁻¹ * [l/2 ‖v - a‖² + ‖v - x‖²/2] + (constant in v).
  set c : ℝ := ((l + 1)⁻¹ * (‖x + l • a‖ ^ 2) - ‖x‖ ^ 2 - l * ‖a‖ ^ 2) / 2 with c_def
  have hl1_pos : (0 : ℝ) < l + 1 := by linarith
  have hl1_ne : (l + 1 : ℝ) ≠ 0 := ne_of_gt hl1_pos
  -- The auxiliary identity
  have aux : ∀ v : E, ‖v - (1 / (l + 1)) • (x + l • a)‖ ^ 2 / 2
              = (l + 1)⁻¹ * (l / 2 * ‖v - a‖ ^ 2 + ‖v - x‖ ^ 2 / 2 + c) := by
    intro v
    -- Expand both sides via norm_sub_sq_real and inner-product identities.
    rw [norm_sub_sq_real]
    have hsmul_norm : ‖(1 / (l + 1)) • (x + l • a)‖ ^ 2
                    = (l + 1)⁻¹ ^ 2 * ‖x + l • a‖ ^ 2 := by
      rw [norm_smul, mul_pow, Real.norm_eq_abs, sq_abs, one_div]
    have hinner_smul : inner ℝ v ((1 / (l + 1)) • (x + l • a))
                     = (l + 1)⁻¹ * inner ℝ v (x + l • a) := by
      rw [inner_smul_right, one_div]
    rw [hsmul_norm, hinner_smul]
    rw [@inner_add_right ℝ E, inner_smul_right]
    rw [norm_sub_sq_real v x, norm_sub_sq_real v a]
    rw [c_def]
    field_simp
    ring
  -- Now show the equivalence using aux on both sides
  constructor
  · -- Forward: if z minimizes the LHS objective, it minimizes the RHS objective.
    intro hz w
    specialize hz w
    -- LHS hypothesis: f z + l/2 ‖z - a‖² + ‖z - x‖²/2 ≤ f w + l/2 ‖w - a‖² + ‖w - x‖²/2
    -- Want: (1/(l+1))•f z + ‖z - (1/(l+1))(x+l•a)‖²/2 ≤ same with w.
    -- Apply aux to z, w; multiply by (l+1).
    have hauz := aux z
    have hauw := aux w
    show ((1 / (l + 1)) • f) z + ‖z - (1 / (l + 1)) • (x + l • a)‖ ^ 2 / 2
       ≤ ((1 / (l + 1)) • f) w + ‖w - (1 / (l + 1)) • (x + l • a)‖ ^ 2 / 2
    rw [hauz, hauw]
    simp only [Pi.smul_apply, smul_eq_mul, one_div]
    -- Goal: (l+1)⁻¹ * f z + (l+1)⁻¹ * (l/2 ‖z-a‖² + ‖z-x‖²/2 + c) ≤ same with w
    -- Equivalent to: (l+1)⁻¹ * (f z + l/2 ‖z-a‖² + ‖z-x‖²/2 + c)
    --              ≤ (l+1)⁻¹ * (f w + l/2 ‖w-a‖² + ‖w-x‖²/2 + c)
    -- Which follows from hz (after subtracting c on both sides) and (l+1)⁻¹ > 0.
    have hl1_inv_pos : (0 : ℝ) < (l + 1)⁻¹ := inv_pos.mpr hl1_pos
    have key : f z + l / 2 * ‖z - a‖ ^ 2 + ‖z - x‖ ^ 2 / 2
             ≤ f w + l / 2 * ‖w - a‖ ^ 2 + ‖w - x‖ ^ 2 / 2 := by
      have := hz; linarith [this]
    nlinarith [key, hl1_inv_pos]
  · -- Backward: symmetric.
    intro hz w
    specialize hz w
    have hauz := aux z
    have hauw := aux w
    show f z + l / 2 * ‖z - a‖ ^ 2 + ‖z - x‖ ^ 2 / 2
       ≤ f w + l / 2 * ‖w - a‖ ^ 2 + ‖w - x‖ ^ 2 / 2
    rw [hauz, hauw] at hz
    simp only [Pi.smul_apply, smul_eq_mul, one_div] at hz
    -- hz : (l+1)⁻¹ * f z + (l+1)⁻¹ * (l/2 ‖z-a‖² + ‖z-x‖²/2 + c)
    --    ≤ (l+1)⁻¹ * f w + (l+1)⁻¹ * (l/2 ‖w-a‖² + ‖w-x‖²/2 + c)
    have hl1_inv_pos : (0 : ℝ) < (l + 1)⁻¹ := inv_pos.mpr hl1_pos
    nlinarith [hz, hl1_inv_pos]

end LeanAgent.Generated

#print axioms LeanAgent.Generated.proximal_add_sq
