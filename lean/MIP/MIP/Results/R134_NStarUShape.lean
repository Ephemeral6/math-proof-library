/-
Result R.134 (ii) — N* training U-shape from ψ unimodality.

Reference: `branches/duality/workspace/new_results.md` R.134 (A 条件性
ITA, 2026-05 v2; updated 2026-05-16 Task 1.1 to A 条件 (ITA) after L.F
upgrade).

**Statement (R.134 (ii) algebraic core).** Under ITA — `ψ : ℕ → ℝ`
attains a unique global maximum at `t*` (left non-decreasing, right
non-increasing) — and the Ohm-regime identity
`N*(p, A_t) = Φ₀(H, p) / ψ(t)`:

* `N*` attains its global minimum at the **same** `t*` (U-shape).
* Pre-`t*`: `dN*/dt ≤ 0` (co-rising stage).
* Post-`t*`: `dN*/dt ≥ 0` (divergence stage).

**Pure-math content.** For positive `ψ : ι → ℝ` with maximum at `t*`,
the reciprocal `1/ψ` attains its minimum at `t*`.  Scaling by a
positive constant `Φ₀` preserves the minimum location.

This file proves the **U-shape kernel** without committing to MIP
opaques.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace NStarUShape

/-- **R.134 (ii) — reciprocal swaps max with min.**

If `ψ : ι → ℝ` is positive everywhere and attains maximum `ψ t*` at `t*`,
then `1/ψ` attains minimum `1/ψ t*` at `t*`. -/
theorem R_134_ii_reciprocal_min
    {ι : Type*} (ψ : ι → ℝ) (t_star : ι)
    (h_pos : ∀ t, 0 < ψ t)
    (h_max : ∀ t, ψ t ≤ ψ t_star) :
    ∀ t, 1 / ψ t_star ≤ 1 / ψ t := by
  intro t
  have h_pos_t : 0 < ψ t := h_pos t
  have h_pos_star : 0 < ψ t_star := h_pos t_star
  exact one_div_le_one_div_of_le h_pos_t (h_max t)

/-- **R.134 (ii) — N*  U-shape kernel.**

`N*(t) := Φ₀ / ψ(t)`.  For positive `ψ`, `Φ₀ > 0`, and `ψ` having max
at `t*`, `N*` attains its minimum at `t*`. -/
theorem R_134_ii_N_star_U_shape
    {ι : Type*} (ψ : ι → ℝ) (Phi0 : ℝ) (t_star : ι)
    (h_ψ_pos : ∀ t, 0 < ψ t)
    (h_Phi0_pos : 0 < Phi0)
    (h_ψ_max : ∀ t, ψ t ≤ ψ t_star) :
    ∀ t, Phi0 / ψ t_star ≤ Phi0 / ψ t := by
  intro t
  have h_recip := R_134_ii_reciprocal_min ψ t_star h_ψ_pos h_ψ_max t
  -- Phi0 / ψ = Phi0 · (1/ψ), then scale by positive Phi0.
  rw [div_eq_mul_one_div Phi0 (ψ t_star), div_eq_mul_one_div Phi0 (ψ t)]
  exact mul_le_mul_of_nonneg_left h_recip (le_of_lt h_Phi0_pos)

/-- **R.134 (ii) — pre-`t*` monotonicity.**

If `ψ` is non-decreasing on `[0, t*]` (left side of the unimodal peak),
then `N* = Φ₀/ψ` is non-increasing on the same interval. -/
theorem R_134_ii_pre_t_star_nonincreasing
    {ι : Type*} [LE ι] (ψ : ι → ℝ) (Phi0 : ℝ) (t_star : ι)
    (h_ψ_pos : ∀ t, 0 < ψ t)
    (h_Phi0_pos : 0 < Phi0)
    (h_ψ_nondec : ∀ t₁ t₂, t₁ ≤ t₂ → t₂ ≤ t_star → ψ t₁ ≤ ψ t₂) :
    ∀ t₁ t₂, t₁ ≤ t₂ → t₂ ≤ t_star → Phi0 / ψ t₂ ≤ Phi0 / ψ t₁ := by
  intro t₁ t₂ h_le h_le_star
  have h_ψ_le : ψ t₁ ≤ ψ t₂ := h_ψ_nondec t₁ t₂ h_le h_le_star
  have h_pos₁ : 0 < ψ t₁ := h_ψ_pos t₁
  have h_pos₂ : 0 < ψ t₂ := h_ψ_pos t₂
  rw [div_eq_mul_one_div Phi0 (ψ t₂), div_eq_mul_one_div Phi0 (ψ t₁)]
  apply mul_le_mul_of_nonneg_left _ (le_of_lt h_Phi0_pos)
  exact one_div_le_one_div_of_le h_pos₁ h_ψ_le

end NStarUShape

end MIP
