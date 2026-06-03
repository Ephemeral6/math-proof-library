/-
  STATUS: DISCOVERY
  AGENT: 6
  DIRECTION: Group 1.2 — `H_K = 0 ↔ point mass` (pure-expert characterisation).
  SUMMARY:
    Combines three pieces:
      (a) `Real.negMulLog` is nonneg on `[0, 1]` (Mathlib).
      (b) A finite sum of nonneg terms is zero iff every term is zero
          (`Finset.sum_eq_zero_iff_of_nonneg`).
      (c) For `0 ≤ x ≤ 1`, `negMulLog x = 0 ↔ x = 0 ∨ x = 1`.
    Using the normalisation `∑ p ω = 1`, exactly-one mass is `1` and all
    others are `0` — the "pure expert" point-mass profile.

    Forward direction (`H_K_zero_imp_point_mass`):
      `H_K(d) = 0 ⟹ ∃ ω₀, d.p ω₀ = 1 ∧ ∀ ω ≠ ω₀, d.p ω = 0`.
    Reverse direction (`point_mass_imp_H_K_zero`):
      direct evaluation.
    Iff (`H_K_eq_zero_iff_point_mass`): the headline DISCOVERY.
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent6_HK_Nonneg
import Mathlib.Analysis.SpecialFunctions.Log.NegMulLog
import Mathlib.Algebra.Order.BigOperators.Group.Finset

namespace MIP

namespace Agent6

open scoped BigOperators

variable {Ω : Type} [Fintype Ω]

/-! ### Pointwise characterisation of `negMulLog x = 0` on `[0,1]`. -/

/-- For `0 ≤ x ≤ 1`, `Real.negMulLog x = 0 ↔ x = 0 ∨ x = 1`. -/
lemma negMulLog_eq_zero_iff_unit {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) :
    Real.negMulLog x = 0 ↔ x = 0 ∨ x = 1 := by
  constructor
  · intro hx
    -- `negMulLog x = -(x · log x) = 0` ⟹ `x · log x = 0` ⟹ `x = 0` or `log x = 0`.
    rw [Real.negMulLog, neg_mul, neg_eq_zero] at hx
    rcases mul_eq_zero.mp hx with hxz | hlx
    · exact Or.inl hxz
    · -- `log x = 0 ↔ x = 0 ∨ x = 1 ∨ x = -1`; with `x ≥ 0` the `-1` case dies.
      rcases Real.log_eq_zero.mp hlx with h | h | h
      · exact Or.inl h
      · exact Or.inr h
      · exfalso; linarith
  · rintro (rfl | rfl)
    · simp [Real.negMulLog]
    · simp [Real.negMulLog]

/-! ### The sum vanishes iff every summand vanishes. -/

/-- If `∑ ω, negMulLog (d.p ω) = 0` then every `d.p ω` is `0` or `1`. -/
lemma all_terms_unit_of_entropy_zero (d : ActivationDist Ω)
    (h : knowledgeEntropy d = 0) :
    ∀ ω, (d.p ω : ℝ) = 0 ∨ (d.p ω : ℝ) = 1 := by
  rw [knowledgeEntropy_eq_sum_negMulLog] at h
  -- Each summand is nonneg; their sum is 0; so each summand is 0.
  have h_each_zero : ∀ ω ∈ (Finset.univ : Finset Ω),
      Real.negMulLog (d.p ω : ℝ) = 0 := by
    have hnn : ∀ ω ∈ (Finset.univ : Finset Ω), 0 ≤ Real.negMulLog (d.p ω : ℝ) := by
      intro ω _
      obtain ⟨h0, h1⟩ := p_coe_mem_unit_interval d ω
      exact Real.negMulLog_nonneg h0 h1
    exact (Finset.sum_eq_zero_iff_of_nonneg hnn).mp h
  intro ω
  obtain ⟨h0, h1⟩ := p_coe_mem_unit_interval d ω
  exact (negMulLog_eq_zero_iff_unit h0 h1).mp (h_each_zero ω (Finset.mem_univ ω))

/-! ### Forward direction: `H_K = 0 ⟹ point mass`. -/

/-- **(Forward part of the DISCOVERY.)** If `knowledgeEntropy d = 0` then
the distribution is a point mass: there is a (necessarily unique) `ω₀`
with `d.p ω₀ = 1` and `d.p ω = 0` for every other `ω`. -/
theorem H_K_zero_imp_point_mass (d : ActivationDist Ω)
    (h : knowledgeEntropy d = 0) :
    ∃ ω₀ : Ω, (d.p ω₀ : ℝ) = 1 ∧ ∀ ω ≠ ω₀, (d.p ω : ℝ) = 0 := by
  classical
  -- From `all_terms_unit_of_entropy_zero`, each `d.p ω` is 0 or 1.
  have hbin := all_terms_unit_of_entropy_zero d h
  -- The sum is 1 (normalised), and each summand is 0 or 1; so exactly one is 1.
  -- Filter the indices where the mass is 1.
  set S := (Finset.univ : Finset Ω).filter (fun ω => (d.p ω : ℝ) = 1) with hS
  -- ∑ d.p ω = ∑_{ω ∈ S} 1 + ∑_{ω ∉ S} 0  = S.card.
  have h_split :
      ∑ ω, (d.p ω : ℝ) = (S.card : ℝ) := by
    rw [← Finset.sum_filter_add_sum_filter_not (s := (Finset.univ : Finset Ω))
        (p := fun ω => (d.p ω : ℝ) = 1)]
    have h_in : ∑ ω ∈ S, (d.p ω : ℝ) = (S.card : ℝ) := by
      have hcalc :
          ∑ ω ∈ S, (d.p ω : ℝ) = ∑ _ω ∈ S, (1 : ℝ) := by
        apply Finset.sum_congr rfl
        intro ω hω
        exact (Finset.mem_filter.mp hω).2
      rw [hcalc]
      simp
    have h_out :
        ∑ ω ∈ (Finset.univ.filter (fun ω => ¬ ((d.p ω : ℝ) = 1))),
          (d.p ω : ℝ) = 0 := by
      apply Finset.sum_eq_zero
      intro ω hω
      have hne : (d.p ω : ℝ) ≠ 1 := (Finset.mem_filter.mp hω).2
      rcases hbin ω with h0 | h1
      · exact h0
      · exact absurd h1 hne
    rw [hS] at h_in
    rw [h_in, h_out, add_zero]
  -- Now use the normalisation `∑ d.p ω = 1` (in ℝ).
  have h_norm_R : (∑ ω, (d.p ω : ℝ)) = 1 := by
    have : ((∑ ω, d.p ω : NNReal) : ℝ) = ∑ ω, (d.p ω : ℝ) := by
      push_cast; rfl
    rw [← this, d.normalized]; simp
  rw [h_norm_R] at h_split
  -- So `S.card = 1`, meaning `S` is a singleton.
  have h_card : S.card = 1 := by
    have hRe : (S.card : ℝ) = 1 := h_split.symm
    exact_mod_cast hRe
  obtain ⟨ω₀, hω₀⟩ := Finset.card_eq_one.mp h_card
  refine ⟨ω₀, ?_, ?_⟩
  · -- `ω₀ ∈ S` because `S = {ω₀}`.
    have : ω₀ ∈ S := by rw [hω₀]; exact Finset.mem_singleton.mpr rfl
    exact (Finset.mem_filter.mp this).2
  · intro ω hne
    -- `ω ∉ S` because `S = {ω₀}` and `ω ≠ ω₀`; so `d.p ω ≠ 1`; with `hbin`, `d.p ω = 0`.
    have hnotin : ω ∉ S := by
      rw [hω₀]; intro hin
      exact hne (Finset.mem_singleton.mp hin)
    have hne1 : (d.p ω : ℝ) ≠ 1 := by
      intro h1
      apply hnotin
      rw [hS]
      exact Finset.mem_filter.mpr ⟨Finset.mem_univ ω, h1⟩
    rcases hbin ω with h0 | h1
    · exact h0
    · exact absurd h1 hne1

/-! ### Reverse direction: point mass ⟹ H_K = 0. -/

/-- **(Reverse part of the DISCOVERY.)** A point-mass distribution has
zero entropy. -/
theorem point_mass_imp_H_K_zero (d : ActivationDist Ω)
    (h_pm : ∃ ω₀ : Ω, (d.p ω₀ : ℝ) = 1 ∧ ∀ ω ≠ ω₀, (d.p ω : ℝ) = 0) :
    knowledgeEntropy d = 0 := by
  classical
  obtain ⟨ω₀, h1, h0⟩ := h_pm
  rw [knowledgeEntropy_eq_sum_negMulLog]
  -- Split the sum at ω₀.
  rw [← Finset.sum_erase_add (Finset.univ : Finset Ω) _ (Finset.mem_univ ω₀)]
  have h_rest :
      ∑ ω ∈ (Finset.univ : Finset Ω).erase ω₀,
        Real.negMulLog ((d.p ω : ℝ)) = 0 := by
    apply Finset.sum_eq_zero
    intro ω hω
    have hne : ω ≠ ω₀ := (Finset.mem_erase.mp hω).1
    rw [h0 ω hne]
    simp [Real.negMulLog]
  rw [h_rest, zero_add, h1]
  simp [Real.negMulLog]

/-! ### Headline DISCOVERY: the iff. -/

/-- **HEADLINE DISCOVERY (Group 1.2).** Knowledge entropy is zero iff the
activation distribution is a point mass — the "pure expert" profile. -/
theorem H_K_eq_zero_iff_point_mass (d : ActivationDist Ω) :
    knowledgeEntropy d = 0 ↔
      ∃ ω₀ : Ω, (d.p ω₀ : ℝ) = 1 ∧ ∀ ω ≠ ω₀, (d.p ω : ℝ) = 0 := by
  refine ⟨H_K_zero_imp_point_mass d, point_mass_imp_H_K_zero d⟩

end Agent6

end MIP
