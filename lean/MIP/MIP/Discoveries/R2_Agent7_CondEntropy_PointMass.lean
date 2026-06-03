/-
  STATUS: DISCOVERY
  AGENT: R2-7
  DIRECTION: Conditional entropy `H(d|P) = 0` iff `d` is a point-mass
              on each part (where the part has positive mass).
  SUMMARY:
    The conditional entropy on a partition is the expected within-part
    entropy:

        H(d|P) := ∑_{S ∈ parts} π_S · condEntropy S d,

    where each term `π_S · condEntropy S d ≥ 0` (since `π_S ≥ 0` and
    `condEntropy S d ≥ 0` by Agent 10's `condEntropy_nonneg`).

    Hence `H(d|P) = 0` iff every term `π_S · condEntropy S d = 0`, which
    in turn means: for every part `S`, either

      (a) `π_S = 0`           (the part has no mass), or
      (b) `condEntropy S d = 0`  (within-part distribution is a point-mass).

    Two named results:

      • `condEntropy_total_eq_zero_iff`
          `H(d|P) = 0 ↔ ∀ S ∈ parts, π_S · condEntropy S d = 0`.
          Direct from `Finset.sum_eq_zero_iff_of_nonneg`.

      • `condEntropy_total_eq_zero_iff_part_or_pointmass`
          `H(d|P) = 0 ↔ ∀ S ∈ parts, π_S = 0 ∨ condEntropy S d = 0`.
          The "point-mass on each positively-massed part" reading.

    The corollary `H_K(d) = H_π(P, d)` (zero conditional entropy iff
    coarse-graining is lossless) follows by the chain rule in Agent 10
    (`entropy_chain_rule_dist`).  We do not duplicate it here.
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent10_PartitionEntropyReduction
import MIP.Discoveries.Agent10_EntropyChainRule

namespace MIP

namespace R2_Agent7_CondEntropy_PointMass

open scoped BigOperators
open MIP.Agent10 (condProb condEntropy condEntropy_nonneg mutualInformation
  mutualInformation_eq_expected_condEntropy mutualInformation_nonneg)

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- **Total conditional entropy of `d` given the partition `P`.**

`H(d|P) := ∑_{S ∈ parts} π_S · condEntropy S d`. -/
noncomputable def condEntropyTotal
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) : ℝ :=
  ∑ S ∈ P.parts,
    ((P.subdomainMass d S : NNReal) : ℝ) * condEntropy S d

/-- **`H(d|P)` is exactly the mutual information `MI(d, P)`.**

By Agent 10's chain rule (`mutualInformation_eq_expected_condEntropy`),
`MI(d, P) = ∑_S π_S · condEntropy S d = condEntropyTotal d P`. -/
theorem condEntropyTotal_eq_MI
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    condEntropyTotal d P = mutualInformation d P := by
  unfold condEntropyTotal
  rw [mutualInformation_eq_expected_condEntropy]

/-- **`H(d|P) ≥ 0`.**

Each summand `π_S · condEntropy S d ≥ 0` (both factors nonneg). -/
theorem condEntropyTotal_nonneg
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    0 ≤ condEntropyTotal d P := by
  unfold condEntropyTotal
  apply Finset.sum_nonneg
  intro S _
  apply mul_nonneg
  · exact NNReal.coe_nonneg _
  · exact condEntropy_nonneg S d

/-! ### Equality case: `H(d|P) = 0`. -/

/-- **`H(d|P) = 0` iff every per-part summand vanishes.**

Direct from `Finset.sum_eq_zero_iff_of_nonneg`. -/
theorem condEntropy_total_eq_zero_iff
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    condEntropyTotal d P = 0
      ↔ ∀ S ∈ P.parts,
          ((P.subdomainMass d S : NNReal) : ℝ) * condEntropy S d = 0 := by
  unfold condEntropyTotal
  rw [Finset.sum_eq_zero_iff_of_nonneg]
  intro S _
  apply mul_nonneg
  · exact NNReal.coe_nonneg _
  · exact condEntropy_nonneg S d

/-- **`H(d|P) = 0` iff each part is either empty-mass or hosts a within-
part point-mass.**

For each part `S`, either `π_S = 0` (the part has no mass) or
`condEntropy S d = 0` (within-part distribution has zero entropy). -/
theorem condEntropy_total_eq_zero_iff_part_or_pointmass
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    condEntropyTotal d P = 0
      ↔ ∀ S ∈ P.parts,
          ((P.subdomainMass d S : NNReal) : ℝ) = 0 ∨ condEntropy S d = 0 := by
  rw [condEntropy_total_eq_zero_iff]
  constructor
  · intro h S hS
    have h_term := h S hS
    -- π_S · condEntropy S d = 0 ⟹ π_S = 0 ∨ condEntropy S d = 0.
    rcases mul_eq_zero.mp h_term with h | h
    · exact Or.inl h
    · exact Or.inr h
  · intro h S hS
    rcases h S hS with h | h
    · rw [h]; ring
    · rw [h]; ring

/-! ### Implications for the chain rule. -/

/-- **`H_K(d) = H_π(P, d)` iff `H(d|P) = 0`.**

A corollary of Agent 10's chain rule `H_K = H_π + H(d|P)`. Coarse-
graining is *lossless* exactly when the within-part conditional entropies
all vanish (point-mass on each positively-massed part). -/
theorem coarse_graining_lossless_iff_condEntropy_zero
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    knowledgeEntropy d = MIP.Agent3_PiEntropyBounds.Hpi d P
      ↔ condEntropyTotal d P = 0 := by
  rw [condEntropyTotal_eq_MI]
  unfold mutualInformation
  constructor
  · intro h; linarith
  · intro h; linarith

end R2_Agent7_CondEntropy_PointMass

end MIP
