/-
  STATUS: DISCOVERY
  AGENT: 6
  DIRECTION: Group 2.4 — `H_K = log |Ω|` iff `d` is uniform.
  SUMMARY:
    Strict concavity of `Real.negMulLog` on `[0, ∞)` (Mathlib
    `Real.strictConcaveOn_negMulLog`) gives the *equality case* of
    Jensen via `StrictConcaveOn.eq_of_map_sum_eq`.

    Forward direction (`H_K_eq_log_card_imp_uniform`): if
    `knowledgeEntropy d = log |Ω|` then for all `ω₁, ω₂`,
    `(d.p ω₁ : ℝ) = (d.p ω₂ : ℝ)`, and consequently every mass equals
    `1 / |Ω|`.
    Reverse direction is in `Agent6_HK_LogCard.lean`
    (`H_K_uniform_eq_log_card`).

    Headline iff: `H_K_eq_log_card_iff_uniform`.
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent6_HK_Nonneg
import MIP.Discoveries.Agent6_HK_LogCard
import MIP.Conjectures.CjNEW13_HpiMaxAtTStar
import Mathlib.Analysis.Convex.Jensen
import Mathlib.Analysis.SpecialFunctions.Log.NegMulLog

namespace MIP

namespace Agent6

open scoped BigOperators
open Real

variable {Ω : Type} [Fintype Ω]

/-! ### Forward direction of the uniform-saturation iff. -/

/-- **DISCOVERY (Group 2.4, forward — the hard direction).** If
`knowledgeEntropy d = Real.log (Fintype.card Ω)` then every mass equals
`1 / (Fintype.card Ω : ℝ)`.

Strategy: apply the equality case of Jensen for `strictConcaveOn_negMulLog`
with uniform weights `w_i = 1/m`.  We then get `∀ ω₁ ω₂, (d.p ω₁ : ℝ) =
(d.p ω₂ : ℝ)`; coupled with the normalisation `∑ d.p ω = 1`, every mass
must equal `1/m`. -/
theorem H_K_eq_log_card_imp_uniform [Nonempty Ω] [DecidableEq Ω]
    (d : ActivationDist Ω)
    (h : knowledgeEntropy d = Real.log (Fintype.card Ω : ℝ)) :
    ∀ ω, (d.p ω : ℝ) = 1 / (Fintype.card Ω : ℝ) := by
  classical
  set m : ℕ := Fintype.card Ω with hm
  have hm_pos : 0 < m := Fintype.card_pos
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm_pos
  -- Uniform weights.
  set w : Ω → ℝ := fun _ => 1 / (m : ℝ) with hw
  have hw_pos : ∀ i ∈ (Finset.univ : Finset Ω), 0 < w i := by
    intro i _; rw [hw]; positivity
  have hw_sum : ∑ i, w i = 1 := by
    rw [hw, Finset.sum_const, Finset.card_univ, ← hm, nsmul_eq_mul]
    field_simp
  have hmem : ∀ i ∈ (Finset.univ : Finset Ω), (d.p i : ℝ) ∈ Set.Ici (0 : ℝ) :=
    fun i _ => (d.p i).coe_nonneg
  -- We compute the value of the LHS and RHS of Jensen's equality case.
  -- LHS (concave Jensen): `negMulLog (∑ w_i • p_i)` = `negMulLog (1/m)` = `(1/m) log m`.
  -- RHS: `∑ w_i • negMulLog (p_i)` = `(1/m) ∑ negMulLog (p_i)` = `(1/m) · H_K(d)` = `(1/m) log m`.
  -- So LHS ≤ RHS (the concave Jensen inequality), which is exactly the hypothesis of
  -- `StrictConcaveOn.eq_of_map_sum_eq`.
  have h_sum_eq : ∑ ω, (d.p ω : ℝ) = 1 := pR_sum d
  have hlhs_arg : (∑ i, w i • (d.p i : ℝ)) = 1 / (m : ℝ) := by
    have : (∑ i, w i • (d.p i : ℝ)) = (1 / (m : ℝ)) * ∑ i, (d.p i : ℝ) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      rw [hw]
      simp [smul_eq_mul]
    rw [this, h_sum_eq, mul_one]
  have hval_lhs : Real.negMulLog (1 / (m : ℝ)) = (1 / (m : ℝ)) * Real.log (m : ℝ) := by
    rw [Real.negMulLog]
    rw [Real.log_div one_ne_zero (ne_of_gt hmR)]
    rw [Real.log_one]
    ring
  -- Compute RHS.
  have hrhs : (∑ i, w i • Real.negMulLog (d.p i : ℝ))
              = (1 / (m : ℝ)) * Real.log (Fintype.card Ω : ℝ) := by
    have : (∑ i, w i • Real.negMulLog (d.p i : ℝ))
              = (1 / (m : ℝ)) * ∑ i, Real.negMulLog (d.p i : ℝ) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      rw [hw]
      simp [smul_eq_mul]
    rw [this]
    -- ∑ negMulLog (d.p i) = knowledgeEntropy d = log (Fintype.card Ω).
    have h_negMulSum : ∑ i, Real.negMulLog (d.p i : ℝ) = knowledgeEntropy d :=
      (knowledgeEntropy_eq_sum_negMulLog d).symm
    rw [h_negMulSum, h, ← hm]
  -- The Jensen inequality (concave form) at equality.
  have h_le_map :
      Real.negMulLog (∑ i, w i • (d.p i : ℝ))
        ≤ ∑ i, w i • Real.negMulLog (d.p i : ℝ) := by
    rw [hlhs_arg, hval_lhs, hrhs, ← hm]
  -- Apply equality-case of strict Jensen.
  have h_all_eq :
      ∀ ⦃j⦄, j ∈ (Finset.univ : Finset Ω) →
      ∀ ⦃k⦄, k ∈ (Finset.univ : Finset Ω) →
      (d.p j : ℝ) = (d.p k : ℝ) :=
    Real.strictConcaveOn_negMulLog.eq_of_map_sum_eq hw_pos hw_sum hmem h_le_map
  -- All `(d.p ω : ℝ)` equal a common value `c`. Use normalisation to conclude `c = 1/m`.
  -- Pick any reference index ω₀.
  obtain ⟨ω₀⟩ := (inferInstance : Nonempty Ω)
  have h_pt :
      ∀ ω, (d.p ω : ℝ) = (d.p ω₀ : ℝ) :=
    fun ω => h_all_eq (Finset.mem_univ ω) (Finset.mem_univ ω₀)
  -- ∑ω, (d.p ω : ℝ) = m * (d.p ω₀ : ℝ) = 1.
  have h_const_sum :
      (∑ ω, (d.p ω : ℝ)) = (m : ℝ) * (d.p ω₀ : ℝ) := by
    calc (∑ ω, (d.p ω : ℝ))
        = ∑ ω : Ω, (d.p ω₀ : ℝ) := by
          apply Finset.sum_congr rfl
          intro ω _
          exact h_pt ω
      _ = (m : ℝ) * (d.p ω₀ : ℝ) := by
          rw [Finset.sum_const, Finset.card_univ, ← hm, nsmul_eq_mul]
  rw [h_const_sum] at h_sum_eq
  -- (m : ℝ) * (d.p ω₀ : ℝ) = 1 ⟹ (d.p ω₀ : ℝ) = 1/m.
  have h_ω₀ : (d.p ω₀ : ℝ) = 1 / (m : ℝ) := by
    rw [eq_div_iff (ne_of_gt hmR)]
    linarith
  intro ω
  rw [h_pt ω, h_ω₀]

/-! ### Headline iff. -/

/-- **HEADLINE DISCOVERY (Group 2.4).** Knowledge entropy attains the
maximum `log (Fintype.card Ω)` iff `d` is the uniform distribution.

This is the *equality case* of Jensen for the strictly concave function
`negMulLog`. -/
theorem H_K_eq_log_card_iff_uniform [Nonempty Ω] [DecidableEq Ω]
    (d : ActivationDist Ω) :
    knowledgeEntropy d = Real.log (Fintype.card Ω : ℝ)
      ↔ ∀ ω, (d.p ω : ℝ) = 1 / (Fintype.card Ω : ℝ) := by
  constructor
  · exact H_K_eq_log_card_imp_uniform d
  · intro h_uni
    -- Compute: ∑ω, negMulLog (1/m) = m · (1/m) log m = log m.
    rw [knowledgeEntropy_eq_sum_negMulLog]
    have hcard : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
      exact_mod_cast Fintype.card_pos
    have : ∀ ω, Real.negMulLog (d.p ω : ℝ)
                = Real.negMulLog (1 / (Fintype.card Ω : ℝ)) := by
      intro ω; rw [h_uni ω]
    rw [Finset.sum_congr rfl (fun ω _ => this ω)]
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    rw [Real.negMulLog]
    rw [Real.log_div one_ne_zero (ne_of_gt hcard), Real.log_one]
    field_simp
    ring

end Agent6

end MIP
