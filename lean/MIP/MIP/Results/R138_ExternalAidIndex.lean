/-
Result R.138 — External-aid gap and aid index.

Reference: `branches/duality/workspace/new_results.md` R.138
(A 条件性 ITA / S-ITA, 2026-05-16 duality branch).

**Statement (algebraic kernel).** Under the Ohm regime, define
* `N_self(p, X)       := Φ₀(X, p) · Z_q(X | X)` — self-questioning cost,
* `N_external(p, X, Y) := Φ₀(X, p) · Z_q(X | Y)` — external-aid cost,
* `δ(p, X, Y) := N_self − N_external` — external-aid gap.

Then `δ = Φ₀ · (Z_q(X|X) − Z_q(X|Y))`.

The "external-aid index"
`I(X, Y) := 1 − Z_q(X|Y) / Z_q(X|X)`
equals `δ / N_self` (when `N_self ≠ 0`), and reaches `1` when
`Z_q(X|Y) = 0`, `0` when `Z_q(X|Y) = Z_q(X|X)`, negative when external
aid hurts.

The three-way classification (δ > 0, δ = 0, δ < 0) follows from the sign
of `Z_q(X|X) − Z_q(X|Y)`.

This file proves the **pure-algebra kernel**.  The MIP-side definitions
(D.3.9 of `Z_q`, M_X^self etc.) appear only as inputs.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace ExternalAid

/-- **R.138 (i) — `δ = Φ₀ · (Z_self − Z_ext)` (pure algebra).**

If `N_self = Φ₀ · Z_self` and `N_ext = Φ₀ · Z_ext`, then
`N_self − N_ext = Φ₀ · (Z_self − Z_ext)`. -/
theorem R_138_i_gap
    (Phi0 Z_self Z_ext N_self N_ext δ : ℝ)
    (h_self : N_self = Phi0 * Z_self)
    (h_ext  : N_ext  = Phi0 * Z_ext)
    (h_δ    : δ = N_self - N_ext) :
    δ = Phi0 * (Z_self - Z_ext) := by
  rw [h_δ, h_self, h_ext]; ring

/-- **R.138 (ii) — sign trichotomy of `δ`.**

For `Phi0 > 0`, the sign of `δ = Φ₀ · (Z_self − Z_ext)` is determined by
the sign of `Z_self − Z_ext`. -/
theorem R_138_ii_sign
    (Phi0 Z_self Z_ext : ℝ) (h_Phi_pos : 0 < Phi0) :
    (0 < Phi0 * (Z_self - Z_ext) ↔ Z_ext < Z_self) ∧
    (Phi0 * (Z_self - Z_ext) = 0 ↔ Z_self = Z_ext) ∧
    (Phi0 * (Z_self - Z_ext) < 0 ↔ Z_self < Z_ext) := by
  refine ⟨?_, ?_, ?_⟩
  · constructor
    · intro h
      have : 0 < Z_self - Z_ext := by
        rcases (mul_pos_iff.mp h) with ⟨_, hZ⟩ | ⟨h_Phi_neg, _⟩
        · exact hZ
        · exact absurd h_Phi_pos (asymm h_Phi_neg)
      linarith
    · intro h
      have hZ : 0 < Z_self - Z_ext := by linarith
      exact mul_pos h_Phi_pos hZ
  · constructor
    · intro h
      have : Z_self - Z_ext = 0 := by
        rcases mul_eq_zero.mp h with h | h
        · exact absurd h (ne_of_gt h_Phi_pos)
        · exact h
      linarith
    · intro h
      rw [show Z_self - Z_ext = 0 by linarith, mul_zero]
  · constructor
    · intro h
      have : Z_self - Z_ext < 0 := by
        by_contra h_nneg
        have h_nneg' : 0 ≤ Z_self - Z_ext := not_lt.mp h_nneg
        have : 0 ≤ Phi0 * (Z_self - Z_ext) :=
          mul_nonneg (le_of_lt h_Phi_pos) h_nneg'
        linarith
      linarith
    · intro h
      have hZ : Z_self - Z_ext < 0 := by linarith
      have : Phi0 * (Z_self - Z_ext) < Phi0 * 0 := by
        apply mul_lt_mul_of_pos_left hZ h_Phi_pos
      linarith

/-- **R.138 (iii) — external-aid index identity `I = δ / N_self`.**

When `N_self ≠ 0`, the external-aid index
`I := 1 − Z_ext / Z_self = δ / N_self`. -/
theorem R_138_iii_aid_index
    (Phi0 Z_self Z_ext N_self δ : ℝ)
    (h_self : N_self = Phi0 * Z_self)
    (h_δ_eq : δ = Phi0 * (Z_self - Z_ext))
    (h_Phi_ne : Phi0 ≠ 0)
    (h_Z_self_ne : Z_self ≠ 0) :
    1 - Z_ext / Z_self = δ / N_self := by
  rw [h_self, h_δ_eq]
  -- Goal: 1 - Z_ext / Z_self = (Phi0 * (Z_self - Z_ext)) / (Phi0 * Z_self)
  rw [mul_div_mul_left _ _ h_Phi_ne]
  rw [sub_div, div_self h_Z_self_ne]

end ExternalAid

end MIP
