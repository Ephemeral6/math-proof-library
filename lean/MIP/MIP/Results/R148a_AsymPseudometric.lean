/-
Result R.148.a — The weighted-L1 cognitive asymmetry `Asym` is a
pseudometric on impedance profiles (Wasserstein metric inheritance).

Reference: `workspace/asym_wasserstein_bridge.md` §3 R.148.a and §5
("辅助分布层的形式同构", 2026-05-16). The bridge R.148 shows
`Asym = W_1^{d_AH}(μ_A^aux, μ_H^aux)`; since `W_1` is a (pseudo)metric on
probability measures, `Asym` inherits the pseudometric axioms. Here we
prove those axioms *directly* from the weighted-L1 definition, so the
result is self-contained and does not depend on importing OT theory.

**Statement.** For a finite barrier set `s`, fixed difficulty weights
`Φ : ι → ℝ` with `Φ(b) ≥ 0`, and impedance profiles `Z_A, Z_H, Z_C : ι → ℝ`
(one profile per agent), define

    Asym(Z_A, Z_H)  :=  Σ_b  Φ(b) · |Z_A(b) − Z_H(b)| .

Then `Asym` satisfies the pseudometric axioms on the space of impedance
profiles:

* **(nonneg)**     `Asym(Z_A, Z_H) ≥ 0`,
* **(self-zero)**  `Asym(Z_A, Z_A) = 0`,
* **(symmetry)**   `Asym(Z_A, Z_H) = Asym(Z_H, Z_A)`,
* **(triangle)**   `Asym(Z_A, Z_H) ≤ Asym(Z_A, Z_C) + Asym(Z_C, Z_H)`.

It is a *pseudo*metric (not a metric) because distinct profiles can collide
on the support of `Φ` (where `Φ(b) = 0`); `Asym(Z_A, Z_H) = 0` only forces
`Z_A = Z_H` on `{b : Φ(b) > 0}`.

**Bundled OT facts.** None. The metric properties of `W_1` would normally
be the bundled fact, but here we prove them at the algebraic L1 level,
which is exactly what `W_1` inherits via the R.148 bridge. The weights
nonnegativity `Φ(b) ≥ 0` (difficulty weights, D.3.1) is the only structural
hypothesis.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Algebra.Order.Ring.Abs
import Mathlib.Tactic.Ring

namespace MIP

open scoped BigOperators

namespace AsymPseudometric

variable {ι : Type*}

/-- Weighted-L1 cognitive asymmetry between two impedance profiles
`X, Y : ι → ℝ` over the finite barrier set `s`, with difficulty weights
`Φ`:  `Asym(X, Y) := Σ_b Φ(b)·|X(b) − Y(b)|`. -/
noncomputable def Asym (s : Finset ι) (Φ X Y : ι → ℝ) : ℝ :=
  ∑ b ∈ s, Φ b * |X b - Y b|

/-- **R.148.a (nonnegativity).** `Asym(X, Y) ≥ 0` when `Φ ≥ 0`. Each summand
`Φ(b)·|X(b)−Y(b)|` is a product of nonnegatives. -/
theorem R_148a_nonneg
    (s : Finset ι) (Φ X Y : ι → ℝ) (hΦ : ∀ b ∈ s, 0 ≤ Φ b) :
    0 ≤ Asym s Φ X Y := by
  unfold Asym
  apply Finset.sum_nonneg
  intro b hb
  exact mul_nonneg (hΦ b hb) (abs_nonneg _)

/-- **R.148.a (self-zero).** `Asym(X, X) = 0`: each summand carries
`|X(b) − X(b)| = 0`. This is the Type-S degeneracy `Asym = 0` of §6 (iii). -/
theorem R_148a_self_zero
    (s : Finset ι) (Φ X : ι → ℝ) :
    Asym s Φ X X = 0 := by
  unfold Asym
  apply Finset.sum_eq_zero
  intro b _
  simp

/-- **R.148.a (symmetry).** `Asym(X, Y) = Asym(Y, X)`, since
`|X(b) − Y(b)| = |Y(b) − X(b)|`. -/
theorem R_148a_symm
    (s : Finset ι) (Φ X Y : ι → ℝ) :
    Asym s Φ X Y = Asym s Φ Y X := by
  unfold Asym
  apply Finset.sum_congr rfl
  intro b _
  rw [abs_sub_comm]

/-- **R.148.a (triangle inequality).**
`Asym(X, Y) ≤ Asym(X, W) + Asym(W, Y)` when `Φ ≥ 0`.

Per-barrier: `|X(b) − Y(b)| ≤ |X(b) − W(b)| + |W(b) − Y(b)|`
(`abs_sub_le`), scaled by the nonnegative weight `Φ(b)` and summed. -/
theorem R_148a_triangle
    (s : Finset ι) (Φ X Y W : ι → ℝ) (hΦ : ∀ b ∈ s, 0 ≤ Φ b) :
    Asym s Φ X Y ≤ Asym s Φ X W + Asym s Φ W Y := by
  unfold Asym
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro b hb
  have htri : |X b - Y b| ≤ |X b - W b| + |W b - Y b| := abs_sub_le _ _ _
  have hstep : Φ b * |X b - Y b| ≤ Φ b * (|X b - W b| + |W b - Y b|) :=
    mul_le_mul_of_nonneg_left htri (hΦ b hb)
  have hdist : Φ b * (|X b - W b| + |W b - Y b|) = Φ b * |X b - W b| + Φ b * |W b - Y b| := by
    ring
  rw [hdist] at hstep
  exact hstep

/-- **R.148.a (pseudometric bundle).** All four pseudometric axioms of
`Asym` packaged together. -/
theorem R_148a_pseudometric
    (s : Finset ι) (Φ X Y W : ι → ℝ) (hΦ : ∀ b ∈ s, 0 ≤ Φ b) :
    0 ≤ Asym s Φ X Y ∧
    Asym s Φ X X = 0 ∧
    Asym s Φ X Y = Asym s Φ Y X ∧
    Asym s Φ X Y ≤ Asym s Φ X W + Asym s Φ W Y :=
  ⟨R_148a_nonneg s Φ X Y hΦ,
   R_148a_self_zero s Φ X,
   R_148a_symm s Φ X Y,
   R_148a_triangle s Φ X Y W hΦ⟩

end AsymPseudometric

end MIP
