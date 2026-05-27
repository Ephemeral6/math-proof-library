/-
Lemma L.6 — Unidirectional N lower bound (A ← H).
Reference: `proofs/L6.md`.

**Statement.** In a unidirectional A←H collaboration (the human asks, the AI is
the solver), decompose the barrier set `B(p)` into `B_A` (AI-favourable),
`B_S` (symmetric), `B_H` (human-favourable). Then

    N(p, A, H) ≥ |B_A| + |B_S| + C·|B_H| ,

where `C := (1/|B_H|)·Σ_{b∈B_H} Z_A(b)/Z_H(b) > 1`.

**Proof skeleton (from L6.md).** For each barrier `b`, let `n(b)` be the number
of interventions to break `b` with the AI as solver.
* `b ∈ B_A` or `b ∈ B_S`: by T.1, `n(b) ≥ 1`.
* `b ∈ B_H` (so `Z_H(b) < Z_A(b)`): by the Ohm law (T.8) and
  `Φ(b)·Z_H(b) ≥ 1`, `n(b) ≥ Φ(b)·Z_A(b) ≥ Z_A(b)/Z_H(b) > 1`.
Summing the three classes: `N = Σ_b n(b) ≥ |B_A| + |B_S| + Σ_{b∈B_H} Z_A/Z_H
= |B_A| + |B_S| + C·|B_H|`.

**Kernel formalized here.** The rigorous mathematical content is the
Finset-summation lower bound: a real-valued cost `n : ι → ℝ` over barriers,
partitioned into three finsets, with per-barrier lower bounds (`≥ 1` on
`B_A ∪ B_S`, `≥ ratio b` on `B_H` where `ratio b = Z_A b / Z_H b ≥ 1`), implies

    Σ n  ≥  |B_A| + |B_S| + (Σ_{B_H} ratio) ,   and   Σ_{B_H} ratio = C·|B_H| .

We also prove `C > 1` from each ratio `> 1`, the H-favourable hypothesis.

**Bridge.** `N(p,A,H) = Σ_b n(b)` is the opaque emergence degree expressed as
total intervention cost (T.1 sum form). The per-barrier bounds `n(b) ≥ 1`
(T.1) and `n(b) ≥ Z_A/Z_H` (T.8 + `Φ·Z_H ≥ 1`) are taken as the hypothesis
bundle; the algebraic sum is the proven kernel.

This file is axiom-free (no A.1–A.4 needed; pure Finset/real arithmetic).
-/
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic

namespace MIP

namespace Lemma_L6

open scoped BigOperators

variable {ι : Type*} [DecidableEq ι]

/-- **L.6 — per-class summation lower bound (kernel).**

Let `B_A, B_S, B_H : Finset ι` be the three barrier classes and
`n : ι → ℝ` the per-barrier intervention cost. Assume

* `hA`: `∀ b ∈ B_A, 1 ≤ n b`              (T.1 on AI-favourable barriers),
* `hS`: `∀ b ∈ B_S, 1 ≤ n b`              (T.1 on symmetric barriers),
* `hH`: `∀ b ∈ B_H, ratio b ≤ n b`        (T.8 on human-favourable barriers),

where `ratio : ι → ℝ`. Then the total cost over `B_A ∪ B_S ∪ B_H` is bounded
below by `|B_A| + |B_S| + Σ_{b∈B_H} ratio b`. (Disjointness `hAS`, `hASH`
ensures the union sum splits cleanly.) -/
theorem N_lower_bound_AH
    (B_A B_S B_H : Finset ι) (n ratio : ι → ℝ)
    (hAS  : Disjoint B_A B_S)
    (hASH : Disjoint (B_A ∪ B_S) B_H)
    (hA : ∀ b ∈ B_A, (1 : ℝ) ≤ n b)
    (hS : ∀ b ∈ B_S, (1 : ℝ) ≤ n b)
    (hH : ∀ b ∈ B_H, ratio b ≤ n b) :
    (B_A.card : ℝ) + (B_S.card : ℝ) + (∑ b ∈ B_H, ratio b)
      ≤ ∑ b ∈ (B_A ∪ B_S ∪ B_H), n b := by
  -- Split the sum over (B_A ∪ B_S) ∪ B_H.
  rw [Finset.sum_union hASH, Finset.sum_union hAS]
  -- Bound each piece.
  have hA_sum : (B_A.card : ℝ) ≤ ∑ b ∈ B_A, n b := by
    calc (B_A.card : ℝ) = ∑ _b ∈ B_A, (1 : ℝ) := by
            rw [Finset.sum_const, nsmul_eq_mul, mul_one]
      _ ≤ ∑ b ∈ B_A, n b := Finset.sum_le_sum hA
  have hS_sum : (B_S.card : ℝ) ≤ ∑ b ∈ B_S, n b := by
    calc (B_S.card : ℝ) = ∑ _b ∈ B_S, (1 : ℝ) := by
            rw [Finset.sum_const, nsmul_eq_mul, mul_one]
      _ ≤ ∑ b ∈ B_S, n b := Finset.sum_le_sum hS
  have hH_sum : (∑ b ∈ B_H, ratio b) ≤ ∑ b ∈ B_H, n b :=
    Finset.sum_le_sum hH
  linarith

omit [DecidableEq ι] in
/-- **L.6 — `C·|B_H|` reformulation.**

If `C := (1/|B_H|)·Σ_{b∈B_H} ratio b` (with `B_H` nonempty so `|B_H| > 0`),
then `Σ_{b∈B_H} ratio b = C·|B_H|`. Hence the lower bound `N_lower_bound_AH`
reads `N ≥ |B_A| + |B_S| + C·|B_H|`, the exact form of L.6. -/
theorem sum_ratio_eq_C_card
    (B_H : Finset ι) (ratio : ι → ℝ) (hne : B_H.Nonempty) :
    let C : ℝ := (∑ b ∈ B_H, ratio b) / (B_H.card : ℝ)
    (∑ b ∈ B_H, ratio b) = C * (B_H.card : ℝ) := by
  intro C
  have hcard_pos : 0 < (B_H.card : ℝ) := by
    have : 0 < B_H.card := Finset.card_pos.mpr hne
    exact_mod_cast this
  show (∑ b ∈ B_H, ratio b)
      = ((∑ b ∈ B_H, ratio b) / (B_H.card : ℝ)) * (B_H.card : ℝ)
  field_simp

omit [DecidableEq ι] in
/-- **L.6 — the average impedance ratio `C > 1`.**

If every human-favourable barrier `b ∈ B_H` has `ratio b > 1` (which holds
because `Z_A(b) > Z_H(b)` on `B_H`), and `B_H` is nonempty, then the average
`C := (1/|B_H|)·Σ ratio b > 1`. -/
theorem C_gt_one
    (B_H : Finset ι) (ratio : ι → ℝ) (hne : B_H.Nonempty)
    (hratio : ∀ b ∈ B_H, (1 : ℝ) < ratio b) :
    (1 : ℝ) < (∑ b ∈ B_H, ratio b) / (B_H.card : ℝ) := by
  have hcard_pos : 0 < (B_H.card : ℝ) := by
    have : 0 < B_H.card := Finset.card_pos.mpr hne
    exact_mod_cast this
  rw [lt_div_iff₀ hcard_pos, one_mul]
  -- |B_H| = Σ 1 < Σ ratio b.
  calc (B_H.card : ℝ) = ∑ _b ∈ B_H, (1 : ℝ) := by
          rw [Finset.sum_const, nsmul_eq_mul, mul_one]
    _ < ∑ b ∈ B_H, ratio b :=
          Finset.sum_lt_sum_of_nonempty hne hratio

/-- **L.6 — combined statement.**

Putting the pieces together: under the per-class lower bounds and `ratio > 1`
on `B_H` (nonempty), with `C := (1/|B_H|)·Σ ratio`, the total cost satisfies

    |B_A| + |B_S| + C·|B_H|  ≤  Σ_{B_A∪B_S∪B_H} n   (= N(p,A,H)),

and moreover `C > 1`. -/
theorem L6_full
    (B_A B_S B_H : Finset ι) (n ratio : ι → ℝ)
    (hAS  : Disjoint B_A B_S)
    (hASH : Disjoint (B_A ∪ B_S) B_H)
    (hne  : B_H.Nonempty)
    (hA : ∀ b ∈ B_A, (1 : ℝ) ≤ n b)
    (hS : ∀ b ∈ B_S, (1 : ℝ) ≤ n b)
    (hH : ∀ b ∈ B_H, ratio b ≤ n b)
    (hratio : ∀ b ∈ B_H, (1 : ℝ) < ratio b) :
    let C : ℝ := (∑ b ∈ B_H, ratio b) / (B_H.card : ℝ)
    (1 : ℝ) < C ∧
    (B_A.card : ℝ) + (B_S.card : ℝ) + C * (B_H.card : ℝ)
      ≤ ∑ b ∈ (B_A ∪ B_S ∪ B_H), n b := by
  intro C
  refine ⟨C_gt_one B_H ratio hne hratio, ?_⟩
  have hbound := N_lower_bound_AH B_A B_S B_H n ratio hAS hASH hA hS hH
  have hCeq := sum_ratio_eq_C_card B_H ratio hne
  -- rewrite Σ ratio = C·|B_H| inside the bound.
  rw [← hCeq]
  exact hbound

end Lemma_L6

end MIP
