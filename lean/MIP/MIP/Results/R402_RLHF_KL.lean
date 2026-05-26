/-
Result R.402 — RLHF / DPO objective as `max E[r] − β · KL_MIP(A_RL ‖ A_ref)`.

Reference: `~/Desktop/MIP/workspace/theory_unification.md` §R.402
("RLHF / DPO 作为 H_K 重塑 + KL_MIP 约束训练", 2026-05-16).

**Mapping conditions (taken as explicit hypotheses).**
* **Objective.** `J := Er − β · KLval`, the RLHF/DPO objective
  `max E[r_φ] − β · KL(π_θ ‖ π_ref)`, with
  * `Er`    — expected reward `E[r_φ]` (a real),
  * `β ≥ 0` — the KL regularisation weight,
  * `KLval ≥ 0` — the MIP KL divergence `KL_MIP(A_t ‖ A_0)`.
* **KL_MIP (sum form, D.3.10).** Given activation distributions
  `p_{A_t}, p_{A_0}` over the (finite) shared knowledge support, the
  co-support term of `C_train` is `Σ_ω p_{A_t}(ω) · log(p_{A_t}(ω)/p_{A_0}(ω))`.
  We prove this is `≥ 0` (finite **Gibbs inequality**), so `KLval ≥ 0` is
  not an external assumption but a theorem under the probability axioms.

**Statement (the objective algebra).**  We prove:

1. **Reward ceiling** `J ≤ Er` — regularisation can only lower the
   objective below the raw reward (since `β, KLval ≥ 0`).
2. **Monotone decreasing in KL** — for fixed `Er, β`, larger KL gives a
   smaller objective: `KL₁ ≤ KL₂ ⟹ J(KL₂) ≤ J(KL₁)`.
3. **The reference optimum** — `J = Er` iff there is no drift
   (`β = 0` or `KLval = 0`); the reference policy `π_ref` (`KLval = 0`)
   attains the reward ceiling.
4. **Trade-off identity** — `J(β) = Er − β·KLval` is affine and
   nonincreasing in `β`; the "alignment tax" `Er − J = β·KLval` is the
   product of weight and drift.
5. **Gibbs inequality (KL_MIP ≥ 0)** — the sum form of `KL_MIP` is
   nonnegative for any two finite probability distributions on the shared
   support, justifying `KLval ≥ 0`.

**This file is `axiom`-free.**  Imports only Mathlib; the objective
properties are pure inequality algebra and the Gibbs bound is proved from
`Real.log_le_sub_one_of_pos`.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace RLHFObjective

open Finset Real

/-- The RLHF/DPO objective `J := Er − β · KLval`. -/
def J (Er β KLval : ℝ) : ℝ := Er - β * KLval

/-- **R.402 (i) — reward ceiling: `J ≤ Er`.**

With nonnegative weight `β ≥ 0` and nonnegative divergence `KLval ≥ 0`,
the regularised objective never exceeds the raw expected reward.  KL
regularisation is a *penalty*. -/
theorem R_402_i_reward_ceiling
    (Er β KLval : ℝ) (hβ : 0 ≤ β) (hKL : 0 ≤ KLval) :
    J Er β KLval ≤ Er := by
  have hpen : 0 ≤ β * KLval := mul_nonneg hβ hKL
  unfold J; linarith

/-- **R.402 (ii) — monotone decreasing in KL.**

For fixed reward and weight `β ≥ 0`, increasing the divergence lowers the
objective: `KL₁ ≤ KL₂ ⟹ J(KL₂) ≤ J(KL₁)`.  More drift from the reference
costs objective value. -/
theorem R_402_ii_antitone_in_KL
    (Er β KL₁ KL₂ : ℝ) (hβ : 0 ≤ β) (hKL : KL₁ ≤ KL₂) :
    J Er β KL₂ ≤ J Er β KL₁ := by
  unfold J
  have : β * KL₁ ≤ β * KL₂ := mul_le_mul_of_nonneg_left hKL hβ
  linarith

/-- **R.402 (iii) — the reference optimum attains the ceiling.**

`J = Er` exactly when there is no penalty, i.e. `β = 0` or `KLval = 0`.
In particular the reference policy (`KLval = 0`, no drift) attains the
reward ceiling `J = Er`. -/
theorem R_402_iii_optimum_iff
    (Er β KLval : ℝ) :
    J Er β KLval = Er ↔ β * KLval = 0 := by
  unfold J
  constructor
  · intro h; linarith
  · intro h; linarith

/-- **R.402 (iii)′ — reference policy reaches the ceiling.**

If there is no divergence from the reference (`KLval = 0`), the objective
equals the raw reward regardless of `β`. -/
theorem R_402_iii_reference_ceiling (Er β : ℝ) :
    J Er β 0 = Er := by
  unfold J; ring

/-- **R.402 (iv) — alignment-tax identity.**

The "alignment tax" — the gap between the raw reward and the achieved
objective — is exactly the product of the KL weight and the drift:
`Er − J(β) = β · KLval`.  It is `0` at `β = 0` and grows linearly in `β`. -/
theorem R_402_iv_alignment_tax (Er β KLval : ℝ) :
    Er - J Er β KLval = β * KLval := by
  unfold J; ring

/-- **R.402 (iv)′ — objective is antitone in the weight `β` (fixed `KLval ≥ 0`).**

If divergence is fixed and positive-or-zero, raising the regularisation
weight `β₁ ≤ β₂` cannot raise the objective: `J(β₂) ≤ J(β₁)`. -/
theorem R_402_iv_antitone_in_beta
    (Er KLval β₁ β₂ : ℝ) (hKL : 0 ≤ KLval) (hβ : β₁ ≤ β₂) :
    J Er β₂ KLval ≤ J Er β₁ KLval := by
  unfold J
  have : β₁ * KLval ≤ β₂ * KLval := mul_le_mul_of_nonneg_right hβ hKL
  linarith

/-- **R.402 (v) — finite Gibbs inequality: `KL_MIP ≥ 0`.**

For two probability distributions `p, q` on a finite support `s`
(`Σ p = 1 = Σ q`, with `p i, q i > 0` on `s`), the KL sum form
`Σ_{i ∈ s} p i · log(p i / q i)` is nonnegative.  This justifies taking
`KLval ≥ 0` in the objective.

Proof: `−Σ p log(p/q) = Σ p log(q/p) ≤ Σ p (q/p − 1) = Σ q − Σ p = 0`,
using `log x ≤ x − 1` (`Real.log_le_sub_one_of_pos`). -/
theorem R_402_v_gibbs_nonneg
    {ι : Type*} (s : Finset ι) (p q : ι → ℝ)
    (hp : ∀ i ∈ s, 0 < p i) (hq : ∀ i ∈ s, 0 < q i)
    (hsump : ∑ i ∈ s, p i = 1) (hsumq : ∑ i ∈ s, q i = 1) :
    0 ≤ ∑ i ∈ s, p i * Real.log (p i / q i) := by
  -- It suffices to show  -(KL) ≤ 0, i.e.  ∑ p · log(q/p) ≤ 0.
  -- Termwise:  p · log(q/p) ≤ p · (q/p − 1) = q − p   (using log x ≤ x−1).
  have hterm : ∀ i ∈ s, p i * Real.log (q i / p i) ≤ q i - p i := by
    intro i hi
    have hpi := hp i hi
    have hqi := hq i hi
    have hratio_pos : 0 < q i / p i := div_pos hqi hpi
    have hlog : Real.log (q i / p i) ≤ q i / p i - 1 :=
      Real.log_le_sub_one_of_pos hratio_pos
    calc p i * Real.log (q i / p i)
        ≤ p i * (q i / p i - 1) :=
          mul_le_mul_of_nonneg_left hlog (le_of_lt hpi)
      _ = q i - p i := by
          field_simp
    -- p i * (q i / p i - 1) = q i - p i  (p i ≠ 0)
  -- Sum the termwise bound.
  have hsum_neg : ∑ i ∈ s, p i * Real.log (q i / p i) ≤ ∑ i ∈ s, (q i - p i) :=
    Finset.sum_le_sum hterm
  have hsum_rhs : ∑ i ∈ s, (q i - p i) = 0 := by
    rw [Finset.sum_sub_distrib, hsumq, hsump]; ring
  -- Relate ∑ p log(q/p) to −∑ p log(p/q).
  have hneg : ∀ i ∈ s, p i * Real.log (q i / p i) = -(p i * Real.log (p i / q i)) := by
    intro i hi
    have hpi := hp i hi
    have hqi := hq i hi
    have : Real.log (q i / p i) = -Real.log (p i / q i) := by
      rw [← Real.log_inv]
      congr 1
      rw [inv_div]
    rw [this]; ring
  have hrewrite : ∑ i ∈ s, p i * Real.log (q i / p i)
      = -∑ i ∈ s, p i * Real.log (p i / q i) := by
    rw [← Finset.sum_neg_distrib]
    exact Finset.sum_congr rfl hneg
  rw [hrewrite, hsum_rhs] at hsum_neg
  linarith

end RLHFObjective

end MIP
