/-
Result R.800 = T.32 — Cognitive Boundary Lower Bound (IBΦ).

Reference: `proofs/derived/A4_grade.md` R.800 (A 无条件, A.4 + D.3.1).

**Statement.** For `k` problems `p_1, …, p_k` that are K(X)-projection
homogeneous (IBΦ-i) with pairwise-disjoint correct-answer events (IBΦ-ii),
the per-problem success probabilities `e^{−Φ₀(X, pᵢ)}` are the probabilities
of disjoint events under one common output distribution, so by the Boole /
union bound

    Σᵢ e^{−Φ₀(X, pᵢ)} ≤ 1 .

Consequently (AM–min), if the `k` problems are indistinguishable
(`Φ₀(X, pᵢ) = c` for all `i`) then `k · e^{−c} ≤ 1`, hence

    c ≥ log k        (k ≥ 1).

**Pure-math kernel (this file).** The probabilistic content (A.4
indistinguishability collapsing all `pᵢ` to one distribution `P`; disjointness
of the correct-answer events `Eᵢ`) enters as the explicit hypotheses

* `pr : ι → ℝ`, the realised success probabilities, with `pr i = e^{−Φ₀ i}`,
* `0 ≤ pr i` and `∑_{i∈I} pr i ≤ 1`   (Boole on disjoint events under `P`).

From these we conclude `∑_{i∈I} e^{−Φ₀ i} ≤ 1` (Step 2), and then the
indistinguishable-class corollary `c ≥ log k` (Step 3).

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Finset.Basic

open Finset

namespace MIP

namespace BoundaryLowerBound

/-- **R.800 Step 2 — Boole / union-bound core.**

Given an index set `I`, a potential `Φ₀ : ι → ℝ`, and a realised
probability assignment `pr : ι → ℝ` arising from the disjoint-event
structure (each `pr i = e^{−Φ₀ i}` is the success probability of `pᵢ`, the
events are disjoint so their probabilities sum to `≤ 1`), one has

    ∑_{i ∈ I} e^{−Φ₀ i} ≤ 1 . -/
theorem R_800_boundary_lower_bound
    {ι : Type*} [DecidableEq ι] (I : Finset ι) (Φ₀ : ι → ℝ) (pr : ι → ℝ)
    (h_eq : ∀ i ∈ I, pr i = Real.exp (-(Φ₀ i)))
    (h_sum_le : ∑ i ∈ I, pr i ≤ 1) :
    ∑ i ∈ I, Real.exp (-(Φ₀ i)) ≤ 1 := by
  -- The two sums are equal termwise on `I`, so the bound transports.
  have h_sum_eq : ∑ i ∈ I, Real.exp (-(Φ₀ i)) = ∑ i ∈ I, pr i :=
    Finset.sum_congr rfl (fun i hi => (h_eq i hi).symm)
  rw [h_sum_eq]
  exact h_sum_le

/-- **R.800 Step 3 — indistinguishable-class corollary (`k · e^{−c} ≤ 1`).**

If all `k` problems share the same potential value `Φ₀ i = c` (they are
indistinguishable under X), then the Boole bound `∑ e^{−Φ₀ i} ≤ 1`
collapses to `k · e^{−c} ≤ 1`, where `k = |I|`. -/
theorem R_800_indistinguishable_sum
    {ι : Type*} [DecidableEq ι] (I : Finset ι) (Φ₀ : ι → ℝ) (pr : ι → ℝ)
    (c : ℝ)
    (h_const : ∀ i ∈ I, Φ₀ i = c)
    (h_eq : ∀ i ∈ I, pr i = Real.exp (-(Φ₀ i)))
    (h_sum_le : ∑ i ∈ I, pr i ≤ 1) :
    (I.card : ℝ) * Real.exp (-c) ≤ 1 := by
  have h_boole : ∑ i ∈ I, Real.exp (-(Φ₀ i)) ≤ 1 :=
    R_800_boundary_lower_bound I Φ₀ pr h_eq h_sum_le
  -- Each term equals the constant `exp(-c)`, so the sum is `card · exp(-c)`.
  have h_const_term : ∀ i ∈ I, Real.exp (-(Φ₀ i)) = Real.exp (-c) :=
    fun i hi => by rw [h_const i hi]
  have h_sum_const : ∑ i ∈ I, Real.exp (-(Φ₀ i)) = (I.card : ℝ) * Real.exp (-c) := by
    rw [Finset.sum_congr rfl h_const_term, Finset.sum_const, nsmul_eq_mul]
  rw [h_sum_const] at h_boole
  exact h_boole

/-- **R.800 Step 3 — `log k` lower bound for an indistinguishable class.**

If the `k = |I| ≥ 1` problems are indistinguishable (`Φ₀ i = c`), then the
common potential satisfies `c ≥ log k`.  (This is the per-problem corollary
`min_i Φ₀(X, pᵢ) ≥ log k`, which for an indistinguishable class is exactly
`c ≥ log k`.) -/
theorem R_800_log_lower_bound
    {ι : Type*} [DecidableEq ι] (I : Finset ι) (Φ₀ : ι → ℝ) (pr : ι → ℝ)
    (c : ℝ)
    (h_nonempty : 1 ≤ I.card)
    (h_const : ∀ i ∈ I, Φ₀ i = c)
    (h_eq : ∀ i ∈ I, pr i = Real.exp (-(Φ₀ i)))
    (h_sum_le : ∑ i ∈ I, pr i ≤ 1) :
    Real.log I.card ≤ c := by
  have h_card_pos : (0 : ℝ) < I.card := by exact_mod_cast h_nonempty
  have h_kc : (I.card : ℝ) * Real.exp (-c) ≤ 1 :=
    R_800_indistinguishable_sum I Φ₀ pr c h_const h_eq h_sum_le
  -- e^{−c} ≤ 1/k  ⟹  −c ≤ log(1/k) = −log k  ⟹  c ≥ log k.
  have h_exp_le : Real.exp (-c) ≤ 1 / (I.card : ℝ) := by
    rw [le_div_iff₀ h_card_pos]
    calc Real.exp (-c) * (I.card : ℝ) = (I.card : ℝ) * Real.exp (-c) := by ring
      _ ≤ 1 := h_kc
  have h_exp_pos : (0 : ℝ) < Real.exp (-c) := Real.exp_pos _
  have h_log_le : -c ≤ Real.log (1 / (I.card : ℝ)) := by
    have := Real.log_le_log h_exp_pos h_exp_le
    rwa [Real.log_exp] at this
  rw [Real.log_div one_ne_zero (ne_of_gt h_card_pos), Real.log_one] at h_log_le
  linarith

end BoundaryLowerBound

end MIP
