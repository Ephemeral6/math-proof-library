/-
Result R.422 — T-primitive (impedance reduction) effect formula and sign.

Reference: `workspace/coe_mip_unification.md` §R.422 (T 主推 Z⁻¹,
A 条件性; the formal in-system statement (i)/(ii) is A 无条件 algebra).

**Statement (CoE × MIP mapping).** The T-primitive injects state-transition
trajectories that lower the impedance `Z`. Map the model conditions into
hypotheses:

* `Φ₀`   — initial potential, set by the query, **unchanged by T**,
* `Z`    — baseline impedance, `Z_T` — post-T impedance,
* By R.008 the emergence cost is `N ≈ Φ₀ · Z`, so the T-effect is

      ΔN_T = N − N_T = Φ₀ · Z − Φ₀ · Z_T = Φ₀ · (Z − Z_T) .

The theorem package:

* **(formula)** `ΔN_T = Φ₀ · (Z − Z_T)`.
* **(sign)** under `Z_T ≤ Z` (T never raises impedance) and `Φ₀ ≥ 0`,
  `ΔN_T ≥ 0`.
* **(monotone)** `ΔN_T` is increasing in the impedance gap `Z − Z_T`:
  larger gap ⟹ larger effect; and (for fixed gap-ratio) the effect scales
  with `Z`, so high-impedance domains gain most.

**Pure-math content.** Algebraic: the formula is a `ring` identity; the
sign is a product of non-negatives; monotonicity is a one-variable
inequality in the gap.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace TPrimitive

/-- **R.422 (ii) — T-effect formula.**

With `N = Φ₀ · Z` and `N_T = Φ₀ · Z_T` (T leaves `Φ₀` fixed), the effect is

    ΔN_T = N − N_T = Φ₀ · (Z − Z_T) . -/
theorem R_422_effect_formula
    (Φ₀ Z Z_T N N_T : ℝ)
    (h_N  : N  = Φ₀ * Z)
    (h_NT : N_T = Φ₀ * Z_T) :
    N - N_T = Φ₀ * (Z - Z_T) := by
  rw [h_N, h_NT]; ring

/-- **R.422 (i) — sign of the T-effect (`Z_T ≤ Z ⟹ ΔN_T ≥ 0`).**

If T does not raise impedance (`Z_T ≤ Z`) and `Φ₀ ≥ 0`, then
`ΔN_T = Φ₀ · (Z − Z_T) ≥ 0`. -/
theorem R_422_effect_nonneg
    (Φ₀ Z Z_T : ℝ)
    (h_Φ₀_nonneg : 0 ≤ Φ₀)
    (h_Z_drop : Z_T ≤ Z) :
    0 ≤ Φ₀ * (Z - Z_T) := by
  apply mul_nonneg h_Φ₀_nonneg
  linarith

/-- **R.422 (iii)(a) — monotone in the impedance gap.**

For fixed `Φ₀ ≥ 0`, the effect `Φ₀ · gap` is non-decreasing in the gap
`gap := Z − Z_T`: a larger drop yields at least as large an effect.
(Strictly increasing when `Φ₀ > 0`; here the monotone form.) -/
theorem R_422_monotone_in_gap
    (Φ₀ gap₁ gap₂ : ℝ)
    (h_Φ₀_nonneg : 0 ≤ Φ₀)
    (h_gap_le : gap₁ ≤ gap₂) :
    Φ₀ * gap₁ ≤ Φ₀ * gap₂ :=
  mul_le_mul_of_nonneg_left h_gap_le h_Φ₀_nonneg

/-- **R.422 (iii)(a, scaling) — high-impedance domains gain most.**

Write the effect as `Φ₀ · Z · (1 − Z_T/Z)`. For a fixed retention ratio
`ρ := Z_T/Z ∈ [0,1]` and `Φ₀ ≥ 0`, the effect `Φ₀ · Z · (1 − ρ)` is
non-decreasing in the baseline impedance `Z ≥ 0`: larger `Z` ⟹ larger
absolute T-effect. -/
theorem R_422_scales_with_impedance
    (Φ₀ ρ Z₁ Z₂ : ℝ)
    (h_Φ₀_nonneg : 0 ≤ Φ₀)
    (h_ρ_le_one : ρ ≤ 1)
    (h_Z_le : Z₁ ≤ Z₂) :
    Φ₀ * Z₁ * (1 - ρ) ≤ Φ₀ * Z₂ * (1 - ρ) := by
  have h_one_sub_nonneg : 0 ≤ 1 - ρ := by linarith
  apply mul_le_mul_of_nonneg_right _ h_one_sub_nonneg
  exact mul_le_mul_of_nonneg_left h_Z_le h_Φ₀_nonneg

end TPrimitive

end MIP
