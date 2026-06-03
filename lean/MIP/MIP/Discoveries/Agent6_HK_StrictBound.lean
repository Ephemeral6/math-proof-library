/-
  STATUS: DISCOVERY
  AGENT: 6
  DIRECTION: Group 2 bonus — strict version of `H_K < log |Ω|` for
             non-uniform distributions; and `H_K = 0` iff support is a
             singleton.
  SUMMARY:
    Pulling together the iffs of Groups 1.2 and 2.4 gives two sharp
    classifying corollaries:

    (i) `H_K < log |Ω|` iff `d` is NOT the uniform distribution.
        Direct contrapositive of `H_K_eq_log_card_iff_uniform`, combined
        with the bound `H_K ≤ log |Ω|`.

    (ii) `H_K = 0` iff `(supp d).card = 1`.  The point-mass forward of
        Group 1.2 says exactly one ω₀ has mass 1; the support is then
        `{ω₀}`, a singleton.  Conversely, `supp d = {ω₀}` ⟹ all mass is
        on ω₀ ⟹ point mass ⟹ H_K = 0.
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent6_HK_Nonneg
import MIP.Discoveries.Agent6_HK_Zero_PointMass
import MIP.Discoveries.Agent6_HK_LogCard
import MIP.Discoveries.Agent6_HK_Support
import MIP.Discoveries.Agent6_HK_Uniform_Saturation

namespace MIP

namespace Agent6

open scoped BigOperators

variable {Ω : Type} [Fintype Ω]

/-! ### (i) Strict inequality `H_K < log |Ω|` for non-uniform distributions. -/

/-- **DISCOVERY (Group 2 bonus).** For a non-uniform activation
distribution, knowledge entropy is *strictly* less than `log |Ω|`. -/
theorem H_K_lt_log_card_of_not_uniform [Nonempty Ω] [DecidableEq Ω]
    (d : ActivationDist Ω)
    (h_not_uni : ¬ ∀ ω, (d.p ω : ℝ) = 1 / (Fintype.card Ω : ℝ)) :
    knowledgeEntropy d < Real.log (Fintype.card Ω : ℝ) := by
  have h_le := H_K_le_log_card d
  rcases lt_or_eq_of_le h_le with h_lt | h_eq
  · exact h_lt
  · exfalso
    exact h_not_uni ((H_K_eq_log_card_iff_uniform d).mp h_eq)

/-- The contrapositive — uniform iff equality, non-uniform iff strict. -/
theorem H_K_lt_log_card_iff_not_uniform [Nonempty Ω] [DecidableEq Ω]
    (d : ActivationDist Ω) :
    knowledgeEntropy d < Real.log (Fintype.card Ω : ℝ)
      ↔ ¬ ∀ ω, (d.p ω : ℝ) = 1 / (Fintype.card Ω : ℝ) := by
  constructor
  · intro hlt h_uni
    rw [(H_K_eq_log_card_iff_uniform d).mpr h_uni] at hlt
    exact lt_irrefl _ hlt
  · exact H_K_lt_log_card_of_not_uniform d

/-! ### (ii) `H_K = 0` iff support is a singleton. -/

/-- **DISCOVERY (Group 1 bonus).** Knowledge entropy is zero iff the
support is a singleton.  Equivalent rephrasing of the point-mass iff. -/
theorem H_K_eq_zero_iff_supp_card_one [DecidableEq Ω] (d : ActivationDist Ω) :
    knowledgeEntropy d = 0 ↔ (supp d).card = 1 := by
  classical
  constructor
  · intro h
    obtain ⟨ω₀, h1, h0⟩ := H_K_zero_imp_point_mass d h
    -- supp d = {ω₀}.
    have h_supp : supp d = {ω₀} := by
      ext ω
      constructor
      · intro hω
        -- ω ∈ supp d ⟹ d.p ω ≠ 0; if ω ≠ ω₀ then d.p ω = 0 by h0.
        rw [Finset.mem_singleton]
        by_contra hne
        have : (d.p ω : ℝ) = 0 := h0 ω hne
        have hp0 : d.p ω = 0 := by
          have := this
          exact_mod_cast this
        exact (Finset.mem_filter.mp hω).2 hp0
      · intro hω
        rw [Finset.mem_singleton] at hω
        cases hω
        refine Finset.mem_filter.mpr ⟨Finset.mem_univ _, ?_⟩
        intro hp0
        have hcoe : (d.p ω₀ : ℝ) = 0 := by rw [hp0]; simp
        linarith [h1, hcoe]
    rw [h_supp]; simp
  · intro h_card
    -- supp d is a singleton {ω₀}; mass = 1 on ω₀, mass = 0 elsewhere ⟹ H_K = 0.
    obtain ⟨ω₀, hω₀⟩ := Finset.card_eq_one.mp h_card
    -- Claim: d.p ω₀ = 1.  Indeed ∑_{ω ∈ supp d} d.p ω = 1 (supp_pR_sum) so over the
    -- singleton {ω₀} we get (d.p ω₀ : ℝ) = 1.
    have h_sum : ∑ ω ∈ supp d, (d.p ω : ℝ) = 1 := supp_pR_sum d
    rw [hω₀] at h_sum
    rw [Finset.sum_singleton] at h_sum
    have h_other : ∀ ω ≠ ω₀, (d.p ω : ℝ) = 0 := by
      intro ω hne
      -- ω ∉ supp d ⟹ d.p ω = 0.
      have hnotin : ω ∉ supp d := by
        rw [hω₀]; intro h; exact hne (Finset.mem_singleton.mp h)
      have hp0 : d.p ω = 0 := by
        by_contra h0
        exact hnotin (Finset.mem_filter.mpr ⟨Finset.mem_univ ω, h0⟩)
      rw [hp0]; simp
    apply point_mass_imp_H_K_zero
    exact ⟨ω₀, h_sum, h_other⟩

end Agent6

end MIP
