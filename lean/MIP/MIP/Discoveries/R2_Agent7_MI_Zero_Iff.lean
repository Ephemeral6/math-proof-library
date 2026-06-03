/-
  STATUS: DISCOVERY
  AGENT: R2-7
  DIRECTION: Mutual-information vanishing characterisation:
              MI(d, P) = 0  iff  each positively-massed part hosts a
              within-part point-mass.
  SUMMARY:
    Agent 10 defines `mutualInformation d P := H_K(d) - H_π(P, d)` and
    proves the chain-rule identity

        MI(d, P)  =  ∑_S π_S · condEntropy S d

    (`mutualInformation_eq_expected_condEntropy`) together with
    nonnegativity (`mutualInformation_nonneg`).  We sharpen this with the
    equality case `MI = 0`.

    NOTE on the framing: in the MIP "coarse-graining" gauge, the mutual
    information `MI(d, P) = H_K - H_π` is the *conditional* entropy
    `H(d | partition)` (the expected within-part entropy), not the
    classical `I(X; Y) = H(X) + H(Y) - H(X, Y)` (no joint distribution
    is formalised here).  Hence `MI = 0` does *not* mean "X and Y are
    independent"; it means "every positively-massed part hosts a within-
    part point-mass" (equivalently, the partition refines the support of
    `d` in the sense that each non-empty `S ∩ supp d` is a singleton).

    The prompt's reading "d is constant on each S" is the *opposite*
    extreme — within-part uniform — which corresponds to *maximal*
    conditional entropy (Jensen-saturation per part), not zero. We
    state the correct point-mass equivalence.

    Results:

      • `MI_eq_zero_iff_part_or_pointmass`
            `MI = 0 ↔ ∀ S ∈ parts, π_S = 0 ∨ condEntropy S d = 0`.

      • `MI_eq_zero_iff_HK_eq_Hpi`
            `MI = 0 ↔ H_K(d) = H_π(P, d)` (lossless coarse-graining).

      • `MI_pos_iff_some_part_with_residual`
            `MI > 0 ↔ ∃ S ∈ parts, 0 < π_S ∧ 0 < condEntropy S d`.
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent10_PartitionEntropyReduction
import MIP.Discoveries.Agent10_EntropyChainRule
import MIP.Discoveries.R2_Agent7_CondEntropy_PointMass

namespace MIP

namespace R2_Agent7_MI_Zero_Iff

open scoped BigOperators
open MIP.Agent10 (condProb condEntropy condEntropy_nonneg mutualInformation
  mutualInformation_eq_expected_condEntropy mutualInformation_nonneg
  Hpi_le_knowledgeEntropy)
open MIP.R2_Agent7_CondEntropy_PointMass (condEntropyTotal
  condEntropyTotal_eq_MI condEntropy_total_eq_zero_iff
  condEntropy_total_eq_zero_iff_part_or_pointmass)

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- **MI = 0 iff each part is either empty-mass or point-mass.**

Combines Agent 10's chain-rule identity with the per-summand
nonnegativity analysis (file `R2_Agent7_CondEntropy_PointMass`). -/
theorem MI_eq_zero_iff_part_or_pointmass
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    mutualInformation d P = 0
      ↔ ∀ S ∈ P.parts,
          ((P.subdomainMass d S : NNReal) : ℝ) = 0 ∨ condEntropy S d = 0 := by
  have h_mi_eq : mutualInformation d P = condEntropyTotal d P :=
    (condEntropyTotal_eq_MI d P).symm
  rw [h_mi_eq]
  exact condEntropy_total_eq_zero_iff_part_or_pointmass d P

/-- **MI = 0 iff coarse-graining is lossless `H_K = H_π`.** -/
theorem MI_eq_zero_iff_HK_eq_Hpi
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    mutualInformation d P = 0
      ↔ knowledgeEntropy d = MIP.Agent3_PiEntropyBounds.Hpi d P := by
  unfold mutualInformation
  constructor
  · intro h; linarith
  · intro h; linarith

/-- **MI > 0 iff some positively-massed part hosts within-part residual
entropy.**

Equivalent contrapositive of `MI_eq_zero_iff_part_or_pointmass`. -/
theorem MI_pos_iff_some_part_with_residual
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    0 < mutualInformation d P
      ↔ ∃ S ∈ P.parts,
          0 < ((P.subdomainMass d S : NNReal) : ℝ) ∧ 0 < condEntropy S d := by
  have h_nn := mutualInformation_nonneg d P
  constructor
  · intro h_pos
    -- 0 < MI ⟹ ¬ (MI = 0) ⟹ some summand has both factors positive.
    by_contra h_no
    push Not at h_no
    -- Want: MI = 0 from "for each S, either π_S ≤ 0 or condEntropy S d ≤ 0".
    -- Combined with nonnegativity, each π_S = 0 or condEntropy S d = 0.
    have h_per : ∀ S ∈ P.parts,
        ((P.subdomainMass d S : NNReal) : ℝ) = 0 ∨ condEntropy S d = 0 := by
      intro S hS
      have h_or := h_no S hS
      have h_pi_nn : (0 : ℝ) ≤ ((P.subdomainMass d S : NNReal) : ℝ) :=
        NNReal.coe_nonneg _
      have h_H_nn : 0 ≤ condEntropy S d := condEntropy_nonneg S d
      by_cases h_pi_pos : 0 < ((P.subdomainMass d S : NNReal) : ℝ)
      · -- Then condEntropy S d ≤ 0 by h_or, combined with nonneg gives 0.
        have h_H_le : condEntropy S d ≤ 0 := h_or h_pi_pos
        exact Or.inr (le_antisymm h_H_le h_H_nn)
      · -- π_S ≤ 0, combined with nonneg gives 0.
        push Not at h_pi_pos
        exact Or.inl (le_antisymm h_pi_pos h_pi_nn)
    have h_mi_zero : mutualInformation d P = 0 :=
      (MI_eq_zero_iff_part_or_pointmass d P).mpr h_per
    linarith
  · intro ⟨S, hS, h_pi_pos, h_H_pos⟩
    -- Some positive summand; combined with all-nonneg, sum > 0.
    rw [mutualInformation_eq_expected_condEntropy]
    apply Finset.sum_pos'
    · intro T _hT
      apply mul_nonneg
      · exact NNReal.coe_nonneg _
      · exact condEntropy_nonneg T d
    · exact ⟨S, hS, mul_pos h_pi_pos h_H_pos⟩

end R2_Agent7_MI_Zero_Iff

end MIP
