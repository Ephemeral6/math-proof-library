/-
Lemma L.7 — Unidirectional N lower bound (H ← A).
Reference: `proofs/L7.md`.

**Statement.** In a unidirectional H←A collaboration (the AI asks, the human is
the solver), decompose `B(p)` into `B_H` (human-favourable), `B_S` (symmetric),
`B_A` (AI-favourable). Then

    N(p, H, A) ≥ |B_H| + |B_S| + C'·|B_A| ,

where `C' := (1/|B_A|)·Σ_{b∈B_A} Z_H(b)/Z_A(b) > 1`.

**Proof skeleton (from L7.md).** Structurally symmetric to L.6, swapping A↔H.
For each barrier `b` let `n(b)` be the number of interventions to break `b`
with the human as solver.
* `b ∈ B_H` or `b ∈ B_S`: by T.1, `n(b) ≥ 1`.
* `b ∈ B_A` (so `Z_A(b) < Z_H(b)`): by Ohm law (T.8) and `Φ(b)·Z_A(b) ≥ 1`,
  `n(b) ≥ Z_H(b)/Z_A(b) > 1`.
Summing: `N ≥ |B_H| + |B_S| + Σ_{b∈B_A} Z_H/Z_A = |B_H| + |B_S| + C'·|B_A|`.

**Kernel formalized here.** Identical Finset-summation kernel to L.6 with the
roles relabelled: lower bounds `≥ 1` on `B_H ∪ B_S`, `≥ ratio' b` on `B_A`,
where `ratio' b = Z_H b / Z_A b ≥ 1`, give

    Σ n  ≥  |B_H| + |B_S| + C'·|B_A| ,   and   C' > 1 .

**Bridge.** Same as L.6: `N(p,H,A) = Σ_b n(b)`; the per-barrier bounds are the
hypothesis bundle (T.1 + T.8 + `Φ·Z_A ≥ 1`); the algebraic sum is the kernel.

This file is axiom-free (no A.1–A.4 needed; pure Finset/real arithmetic).
-/
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic

namespace MIP

namespace Lemma_L7

open scoped BigOperators

variable {ι : Type*} [DecidableEq ι]

/-- **L.7 — per-class summation lower bound (kernel).**

Let `B_H, B_S, B_A : Finset ι` be the three barrier classes and `n : ι → ℝ`
the per-barrier intervention cost (human as solver). Assume

* `hH`: `∀ b ∈ B_H, 1 ≤ n b`               (T.1 on human-favourable barriers),
* `hS`: `∀ b ∈ B_S, 1 ≤ n b`               (T.1 on symmetric barriers),
* `hA`: `∀ b ∈ B_A, ratio' b ≤ n b`        (T.8 on AI-favourable barriers).

Then the total cost over `B_H ∪ B_S ∪ B_A` is bounded below by
`|B_H| + |B_S| + Σ_{b∈B_A} ratio' b`. -/
theorem N_lower_bound_HA
    (B_H B_S B_A : Finset ι) (n ratio' : ι → ℝ)
    (hHS  : Disjoint B_H B_S)
    (hHSA : Disjoint (B_H ∪ B_S) B_A)
    (hH : ∀ b ∈ B_H, (1 : ℝ) ≤ n b)
    (hS : ∀ b ∈ B_S, (1 : ℝ) ≤ n b)
    (hA : ∀ b ∈ B_A, ratio' b ≤ n b) :
    (B_H.card : ℝ) + (B_S.card : ℝ) + (∑ b ∈ B_A, ratio' b)
      ≤ ∑ b ∈ (B_H ∪ B_S ∪ B_A), n b := by
  rw [Finset.sum_union hHSA, Finset.sum_union hHS]
  have hH_sum : (B_H.card : ℝ) ≤ ∑ b ∈ B_H, n b := by
    calc (B_H.card : ℝ) = ∑ _b ∈ B_H, (1 : ℝ) := by
            rw [Finset.sum_const, nsmul_eq_mul, mul_one]
      _ ≤ ∑ b ∈ B_H, n b := Finset.sum_le_sum hH
  have hS_sum : (B_S.card : ℝ) ≤ ∑ b ∈ B_S, n b := by
    calc (B_S.card : ℝ) = ∑ _b ∈ B_S, (1 : ℝ) := by
            rw [Finset.sum_const, nsmul_eq_mul, mul_one]
      _ ≤ ∑ b ∈ B_S, n b := Finset.sum_le_sum hS
  have hA_sum : (∑ b ∈ B_A, ratio' b) ≤ ∑ b ∈ B_A, n b :=
    Finset.sum_le_sum hA
  linarith

omit [DecidableEq ι] in
/-- **L.7 — `C'·|B_A|` reformulation.**

If `C' := (1/|B_A|)·Σ_{b∈B_A} ratio' b` (with `B_A` nonempty), then
`Σ_{b∈B_A} ratio' b = C'·|B_A|`. -/
theorem sum_ratio_eq_C'_card
    (B_A : Finset ι) (ratio' : ι → ℝ) (hne : B_A.Nonempty) :
    let C' : ℝ := (∑ b ∈ B_A, ratio' b) / (B_A.card : ℝ)
    (∑ b ∈ B_A, ratio' b) = C' * (B_A.card : ℝ) := by
  intro C'
  have hcard_pos : 0 < (B_A.card : ℝ) := by
    have : 0 < B_A.card := Finset.card_pos.mpr hne
    exact_mod_cast this
  show (∑ b ∈ B_A, ratio' b)
      = ((∑ b ∈ B_A, ratio' b) / (B_A.card : ℝ)) * (B_A.card : ℝ)
  field_simp

omit [DecidableEq ι] in
/-- **L.7 — the average impedance ratio `C' > 1`.**

If every AI-favourable barrier `b ∈ B_A` has `ratio' b > 1` (which holds
because `Z_H(b) > Z_A(b)` on `B_A`), and `B_A` is nonempty, then
`C' := (1/|B_A|)·Σ ratio' b > 1`. -/
theorem C'_gt_one
    (B_A : Finset ι) (ratio' : ι → ℝ) (hne : B_A.Nonempty)
    (hratio : ∀ b ∈ B_A, (1 : ℝ) < ratio' b) :
    (1 : ℝ) < (∑ b ∈ B_A, ratio' b) / (B_A.card : ℝ) := by
  have hcard_pos : 0 < (B_A.card : ℝ) := by
    have : 0 < B_A.card := Finset.card_pos.mpr hne
    exact_mod_cast this
  rw [lt_div_iff₀ hcard_pos, one_mul]
  calc (B_A.card : ℝ) = ∑ _b ∈ B_A, (1 : ℝ) := by
          rw [Finset.sum_const, nsmul_eq_mul, mul_one]
    _ < ∑ b ∈ B_A, ratio' b :=
          Finset.sum_lt_sum_of_nonempty hne hratio

/-- **L.7 — combined statement.**

Under the per-class lower bounds and `ratio' > 1` on `B_A` (nonempty), with
`C' := (1/|B_A|)·Σ ratio'`, the total cost satisfies

    |B_H| + |B_S| + C'·|B_A|  ≤  Σ_{B_H∪B_S∪B_A} n   (= N(p,H,A)),

and moreover `C' > 1`. -/
theorem L7_full
    (B_H B_S B_A : Finset ι) (n ratio' : ι → ℝ)
    (hHS  : Disjoint B_H B_S)
    (hHSA : Disjoint (B_H ∪ B_S) B_A)
    (hne  : B_A.Nonempty)
    (hH : ∀ b ∈ B_H, (1 : ℝ) ≤ n b)
    (hS : ∀ b ∈ B_S, (1 : ℝ) ≤ n b)
    (hA : ∀ b ∈ B_A, ratio' b ≤ n b)
    (hratio : ∀ b ∈ B_A, (1 : ℝ) < ratio' b) :
    let C' : ℝ := (∑ b ∈ B_A, ratio' b) / (B_A.card : ℝ)
    (1 : ℝ) < C' ∧
    (B_H.card : ℝ) + (B_S.card : ℝ) + C' * (B_A.card : ℝ)
      ≤ ∑ b ∈ (B_H ∪ B_S ∪ B_A), n b := by
  intro C'
  refine ⟨C'_gt_one B_A ratio' hne hratio, ?_⟩
  have hbound := N_lower_bound_HA B_H B_S B_A n ratio' hHS hHSA hH hS hA
  have hCeq := sum_ratio_eq_C'_card B_A ratio' hne
  rw [← hCeq]
  exact hbound

end Lemma_L7

end MIP
