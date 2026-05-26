/-
Result R.58 — Capability partial order is governed by `Φ₀ · Z` product.

Reference: `proofs/derived/A_grade.md` R.58 (A 无条件 under T.8 + C.6 + D.4.6).

**Statement.** Under the agent partial order `A₁ ≼ A₂` (D.4.6, in the
strengthened state-dependent form per C.6):

    A₁ ≼ A₂  ⟹  Φ₀(A₂, p) · Z(A₂) ≤ Φ₀(A₁, p) · Z(A₁) .

Combined with T.8 Ohm law, this gives the per-problem cost ordering:

    A₁ ≼ A₂  ⟹  N(p, A₂) ≤ N(p, A₁) .

I.e. the capability ordering on agents reflects monotonically into the
emergence cost: the "stronger" agent (in ≼) costs less to elicit on
every problem.

**Pure-math content.** Once we accept the D.4.6 hypothesis as
*"A₁ ≼ A₂ ⟹ Φ₀(A₂, p) ≤ Φ₀(A₁, p) ∧ Z(A₂) ≤ Z(A₁)"*, the conclusion
`Φ₀(A₂) · Z(A₂) ≤ Φ₀(A₁) · Z(A₁)` is a one-step product-monotonicity
lemma on nonnegative reals.

This file proves the product-monotonicity kernel and combines it with
the Lean Path B Ohm-law `T8_OhmLaw_core` to recover the conclusion in
the Lean encoding.

**This file is `axiom`-free.**
-/
import MIP.Theorems.T8_OhmLaw
import Mathlib.Data.NNReal.Basic
import Mathlib.Tactic.Positivity

namespace MIP

namespace CapabilityOrder

/-- **R.58 algebraic core — product monotonicity on `ℝ≥0`.**

If `a₂ ≤ a₁` and `b₂ ≤ b₁` with all values nonnegative, then
`a₂ · b₂ ≤ a₁ · b₁`. -/
theorem product_monotone_nonneg
    (a₁ a₂ b₁ b₂ : ℝ) (ha : a₂ ≤ a₁) (hb : b₂ ≤ b₁)
    (ha₂ : 0 ≤ a₂) (hb₁ : 0 ≤ b₁) :
    a₂ * b₂ ≤ a₁ * b₁ := by
  calc a₂ * b₂
      ≤ a₂ * b₁ := mul_le_mul_of_nonneg_left hb ha₂
    _ ≤ a₁ * b₁ := mul_le_mul_of_nonneg_right ha hb₁

/-- **R.58 (NNReal form).**

Same statement for `NNReal` values (always nonnegative). -/
theorem product_monotone_NNReal
    (a₁ a₂ b₁ b₂ : NNReal) (ha : a₂ ≤ a₁) (hb : b₂ ≤ b₁) :
    a₂ * b₂ ≤ a₁ * b₁ :=
  calc a₂ * b₂
      ≤ a₂ * b₁ := mul_le_mul_of_nonneg_left hb (zero_le _)
    _ ≤ a₁ * b₁ := mul_le_mul_of_nonneg_right ha (zero_le _)

/-- **R.58 (ENNReal form).**

Same statement for extended nonneg reals (the type of `Φ₀ · Z` in MIP). -/
theorem product_monotone_ENNReal
    (a₁ a₂ b₁ b₂ : ENNReal) (ha : a₂ ≤ a₁) (hb : b₂ ≤ b₁) :
    a₂ * b₂ ≤ a₁ * b₁ :=
  calc a₂ * b₂
      ≤ a₂ * b₁ := mul_le_mul_of_nonneg_left hb (zero_le _)
    _ ≤ a₁ * b₁ := mul_le_mul_of_nonneg_right ha (zero_le _)

/-- **R.58 — `N`-monotonicity from product-monotonicity.**

If `Φ₀(A₂, p) · Z(A₂) ≤ Φ₀(A₁, p) · Z(A₁)`, then `⌈Φ₀(A₂, p) · Z(A₂)⌉ ≤
⌈Φ₀(A₁, p) · Z(A₁)⌉`, hence (via T.8 Ohm law) `N(p, A₂) ≤ N(p, A₁)`. -/
theorem R_58_ceilENat_monotone (x y : ENNReal) (h : x ≤ y) :
    ceilENat x ≤ ceilENat y := by
  unfold ceilENat
  by_cases hy : y = ⊤
  · rw [hy]; simp
  · rw [if_neg hy]
    have hx_ne_top : x ≠ ⊤ := lt_top_iff_ne_top.mp (lt_of_le_of_lt h (lt_top_iff_ne_top.mpr hy))
    rw [if_neg hx_ne_top]
    -- Cast: ⌈x.toReal⌉₊ ≤ ⌈y.toReal⌉₊
    have h_real : x.toReal ≤ y.toReal :=
      ENNReal.toReal_mono hy h
    exact_mod_cast Nat.ceil_le_ceil h_real

/-- **R.58 (capability-ordering form, T.8 closed).**

Combining the product-monotone kernel with T.8 Ohm law:
if for agents `A₁, A₂` and problem `p` we have
* `Φ₀(A₂, p) ≤ Φ₀(A₁, p)` (R.58 hypothesis from `≼`),
* `Z(A₂, p) ≤ Z(A₁, p)`   (R.58 hypothesis from `≼`),
plus the finite-`N` and finite-`Φ₀` regime for both agents
(needed for Ohm law to apply),
then `N(p, A₂) ≤ N(p, A₁)`. -/
theorem R_58_capability_N_monotone
    {α : Type} (A₁ A₂ : Agent α) (p : Problem α)
    (h_Phi : Phi0 A₂ p ≤ Phi0 A₁ p)
    (h_Z : Z A₂ p ≤ Z A₁ p)
    (hFin₁ : N p A₁ ≠ ⊤) (hPhi₁ : Phi0 A₁ p ≠ ⊤)
    (hFin₂ : N p A₂ ≠ ⊤) (hPhi₂ : Phi0 A₂ p ≠ ⊤)
    (hUniform₁ : Z_min A₁ p = Z_max A₁ p)
    (hUniform₂ : Z_min A₂ p = Z_max A₂ p) :
    N p A₂ ≤ N p A₁ := by
  rw [T8_OhmLaw_core p A₁ hFin₁ hPhi₁ hUniform₁,
      T8_OhmLaw_core p A₂ hFin₂ hPhi₂ hUniform₂]
  exact R_58_ceilENat_monotone _ _
    (product_monotone_ENNReal _ _ _ _ h_Phi h_Z)

end CapabilityOrder

end MIP
