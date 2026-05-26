/-
Result R.59 — Flywheel dual-engine effective decay rate.

Reference: `proofs/derived/A_grade.md` R.59 (A 无条件 under T.5 + T.8 +
D.4.3 framework).

**Statement.** Suppose `Φ₀,ₜ = (1−α_Φ)ᵗ · Φ₀,₀` and `Zₜ = (1−α_Z)ᵗ · Z₀`
(D.4.3 exponential decay of the two engines).  Then `Nₜ = Φ₀,ₜ · Zₜ`
(T.8 Ohm law, Z-uniform regime) decays exponentially with rate `α_eff`
defined by `1 − α_eff := (1−α_Φ)(1−α_Z)`, i.e.

    α_eff = α_Φ + α_Z − α_Φ · α_Z .

For small `α_Φ, α_Z` the cross term `α_Φ · α_Z` is negligible and
`α_eff ≈ α_Φ + α_Z`: the two independent engines add additively.

This file proves the **pure algebraic core**: the exact identity for
`α_eff` and the product-factorisation of `Nₜ`.  No MIP-specific
opaques are touched.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring

namespace MIP

namespace Flywheel

/-- **Defining identity of `α_eff` (R.59 core).**

`1 − α_eff = (1 − α_Φ)(1 − α_Z)` algebraically expands to
`α_eff = α_Φ + α_Z − α_Φ · α_Z`. -/
theorem alpha_eff_expansion (α_Φ α_Z : ℝ) :
    1 - (α_Φ + α_Z - α_Φ * α_Z) = (1 - α_Φ) * (1 - α_Z) := by
  ring

/-- **R.59 (product factorisation form).**

Under the Ohm-law substitution `Nₜ = Φ₀,ₜ · Zₜ` and the engine-wise
exponential decays `Φ₀,ₜ = (1−α_Φ)ᵗ · Φ₀,₀`, `Zₜ = (1−α_Z)ᵗ · Z₀`, the
product decays at the combined rate `(1−α_Φ)(1−α_Z)` per step:

    Nₜ = [(1−α_Φ)(1−α_Z)]ᵗ · N₀ . -/
theorem R_59_flywheel_product
    (α_Φ α_Z Φ0 Z0 : ℝ) (t : ℕ) :
    ((1 - α_Φ) ^ t * Φ0) * ((1 - α_Z) ^ t * Z0)
      = ((1 - α_Φ) * (1 - α_Z)) ^ t * (Φ0 * Z0) := by
  rw [mul_pow]
  ring

/-- **R.59 (effective-rate form).**

`(1−α_eff)ᵗ · N₀ = Nₜ` with `α_eff := α_Φ + α_Z − α_Φ · α_Z`. -/
theorem R_59_alpha_eff
    (α_Φ α_Z Φ0 Z0 : ℝ) (t : ℕ) :
    (1 - (α_Φ + α_Z - α_Φ * α_Z)) ^ t * (Φ0 * Z0)
      = ((1 - α_Φ) ^ t * Φ0) * ((1 - α_Z) ^ t * Z0) := by
  rw [alpha_eff_expansion]
  rw [R_59_flywheel_product]

/-- **Small-α approximation residual.**

`α_eff − (α_Φ + α_Z) = −α_Φ · α_Z`, so the additive approximation
`α_eff ≈ α_Φ + α_Z` has explicit residual `−α_Φ · α_Z`.  In particular,
when one engine stalls (`α_Φ → 0`), `α_eff → α_Z` exactly. -/
theorem alpha_eff_minus_additive (α_Φ α_Z : ℝ) :
    (α_Φ + α_Z - α_Φ * α_Z) - (α_Φ + α_Z) = -(α_Φ * α_Z) := by
  ring

/-- **One-engine stall.**  When `α_Φ = 0`, `α_eff = α_Z` exactly. -/
theorem alpha_eff_stall_Phi (α_Z : ℝ) :
    (0 + α_Z - 0 * α_Z) = α_Z := by ring

/-- **One-engine stall (dual).**  When `α_Z = 0`, `α_eff = α_Φ` exactly. -/
theorem alpha_eff_stall_Z (α_Φ : ℝ) :
    (α_Φ + 0 - α_Φ * 0) = α_Φ := by ring

end Flywheel

end MIP
