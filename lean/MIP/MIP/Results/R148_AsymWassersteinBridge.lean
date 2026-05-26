/-
Result R.148 — Asym ↔ Wasserstein cross-branch bridge
(duality D.4.15 ↔ optimal_transport R.141-R.146).

Reference: `workspace/asym_wasserstein_bridge.md` §3 R.148
("A 级形式构造", 2026-05-16).

**Statement.** Fix the collaboration triple `(p, A, H)` with barrier set
`B(p) = {b_1, …, b_n}` (indexed by a finite set `s`). The D.4.15 cognitive
asymmetry is the weighted L1 functional

    Asym(p, A, H)  :=  Σ_b  Φ(b) · |Z_A(b) − Z_H(b)| .

The bridge (§2 candidate 2) builds, for each barrier `b`, an auxiliary
two-point measure `ξ_X^{(b)}` on `{0_b, 1_b}` encoding `Z_X(b)/Z_max`
as a probability scale, and forms the product auxiliary measures
`μ_A^aux := ⊗_b ξ_A^{(b)}`, `μ_H^aux := ⊗_b ξ_H^{(b)}` on `{0,1}^n`, under
the weighted-ℓ₁ ground metric `d_AH(x,y) := Σ_b Φ(b)·Z_max·|x_b − y_b|`.

Then the discrete 1-Wasserstein cost equals Asym:

    W_1^{d_AH}(μ_A^aux, μ_H^aux)  =  Asym(p, A, H) .

**Bundled OT facts (entered as explicit hypotheses, NOT built here).**
Per the project HYPOTHESIS-BUNDLE convention, optimal-transport facts enter
as hypotheses; we encode the underlying algebraic identity.

* **(B1) product-measure decoupling** (Villani 2009, Prop. 7.16 form):
  for a product measure with a weighted-ℓ₁ ground metric, `W_1` decouples
  into the per-coordinate sum
      `W1 = Σ_b Φ(b) · Z_max · W1_b`,
  where `W1_b` is the per-barrier two-point `W_1`.  Entered as `hW1`.
* **(B2) two-point optimal coupling value**: the per-barrier two-point
  `W_1` on `{0_b,1_b}` with mass-scale `Z_X(b)/Z_max` is the absolute
  difference of the scaled masses,
      `W1_b = |Z_A(b) − Z_H(b)| / Z_max`.
  Entered as `hcoup` (the optimal-coupling value as bundled OT hypothesis).

We prove the algebraic equality `W1 = Asym` from (B1)+(B2), with
`Z_max > 0` (well-posedness of the normalisation).

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.Ring.Abs
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp

namespace MIP

open scoped BigOperators

namespace AsymWassersteinBridge

variable {ι : Type*}

/-- The D.4.15 cognitive asymmetry as a weighted L1 functional over the
finite barrier set `s`:  `Asym := Σ_b Φ(b)·|Z_A(b) − Z_H(b)|`. -/
noncomputable def Asym (s : Finset ι) (Φ ZA ZH : ι → ℝ) : ℝ :=
  ∑ b ∈ s, Φ b * |ZA b - ZH b|

/-- **R.148 — the Asym ↔ W_1 bridge (algebraic core).**

Given the two bundled optimal-transport facts

* **(B1)** product decoupling `W1 = Σ_b Φ(b)·Z_max·W1_b`  (`hW1`),
* **(B2)** two-point optimal coupling value
  `W1_b = |Z_A(b) − Z_H(b)| / Z_max`  (`hcoup`),

with `Z_max > 0`, the discrete 1-Wasserstein cost of the auxiliary product
measures equals the weighted-L1 Asym:

    W1  =  Asym(p, A, H). -/
theorem R_148_bridge
    (s : Finset ι) (Φ ZA ZH W1b : ι → ℝ)
    (Zmax W1 : ℝ)
    (hZmax : 0 < Zmax)
    (hW1 : W1 = ∑ b ∈ s, Φ b * Zmax * W1b b)
    (hcoup : ∀ b ∈ s, W1b b = |ZA b - ZH b| / Zmax) :
    W1 = Asym s Φ ZA ZH := by
  rw [hW1, Asym]
  apply Finset.sum_congr rfl
  intro b hb
  rw [hcoup b hb]
  -- Φ b * Zmax * (|ZA b − ZH b| / Zmax) = Φ b * |ZA b − ZH b|
  field_simp

/-- **R.148 — symmetric (forward) form.**

Re-stated with the conclusion oriented `Asym = W1` to match the boxed
identity in §3 of the source. -/
theorem R_148_asym_eq_W1
    (s : Finset ι) (Φ ZA ZH W1b : ι → ℝ)
    (Zmax W1 : ℝ)
    (hZmax : 0 < Zmax)
    (hW1 : W1 = ∑ b ∈ s, Φ b * Zmax * W1b b)
    (hcoup : ∀ b ∈ s, W1b b = |ZA b - ZH b| / Zmax) :
    Asym s Φ ZA ZH = W1 :=
  (R_148_bridge s Φ ZA ZH W1b Zmax W1 hZmax hW1 hcoup).symm

/-- **R.148 — per-barrier two-point Wasserstein value (B2 derivation).**

The bundled fact (B2) is itself an elementary discrete identity: for the
two-point measure on `{0_b, 1_b}` with masses scaled by `Z_X(b)/Z_max`,
the 1-Wasserstein cost (= total variation × unit ground distance) is the
absolute mass difference.  We record the *defining* algebraic content:

    |Z_A(b)/Z_max − Z_H(b)/Z_max|  =  |Z_A(b) − Z_H(b)| / Z_max,

valid for `Z_max > 0`.  This is the algebraic heart of the two-point
coupling value entered as `hcoup` above. -/
theorem R_148_two_point_W1
    (zA zH Zmax : ℝ) (hZmax : 0 < Zmax) :
    |zA / Zmax - zH / Zmax| = |zA - zH| / Zmax := by
  rw [div_sub_div_same, abs_div, abs_of_pos hZmax]

end AsymWassersteinBridge

end MIP
