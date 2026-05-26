/-
Result R-SUB.3 — Overlap synergy law: `Σ_i π_i ≥ π_∪`.

Reference: `workspace/subdomain_competition.md` §6.3 (A 无条件).

**Statement (pair form).** For two subdomains `K₁, K₂ ⊆ Ω` and a
nonnegative mass function `p : Ω → ℝ≥0`,

    Σ_{ω ∈ K₁ ∪ K₂} p ω  ≤  Σ_{ω ∈ K₁} p ω  +  Σ_{ω ∈ K₂} p ω

(the union mass is at most the sum of subdomain masses).  Equality
holds iff `K₁` and `K₂` are disjoint.

**Physical meaning (MIP).** Training a knowledge element `ω ∈ K_i ∩ K_j`
*simultaneously* raises both `π_i` and `π_j` — the "transfer learning"
geometric root.

This file proves the pair-form inequality from elementary
finset / nonneg-mass facts: union = K₁ ⊔ (K₂ \ K₁), and `Σ_{K₂\K₁} ≤
Σ_{K₂}` by subset monotonicity.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.NNReal.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Finset.Lattice.Basic
import Mathlib.Data.Finset.SDiff
import Mathlib.Tactic.Linarith

namespace MIP

namespace OverlapSynergy

open scoped BigOperators

/-- **R-SUB.3 — pair-form inequality.**

`π_{K₁ ∪ K₂} ≤ π_{K₁} + π_{K₂}` for any nonneg mass function `p`. -/
theorem R_SUB_3_pair_inequality
    {Ω : Type} [DecidableEq Ω]
    (K1 K2 : Finset Ω) (p : Ω → NNReal) :
    (∑ ω ∈ K1 ∪ K2, p ω) ≤ (∑ ω ∈ K1, p ω) + (∑ ω ∈ K2, p ω) := by
  -- K1 ∪ K2 = K1 ⊔ (K2 \ K1) — disjoint union.
  have h_disjoint : Disjoint K1 (K2 \ K1) := Finset.disjoint_sdiff
  have h_union_eq : K1 ∪ K2 = K1 ∪ (K2 \ K1) := by
    ext x; constructor
    · intro h
      rcases Finset.mem_union.mp h with h | h
      · exact Finset.mem_union_left _ h
      · by_cases hx : x ∈ K1
        · exact Finset.mem_union_left _ hx
        · exact Finset.mem_union_right _ (Finset.mem_sdiff.mpr ⟨h, hx⟩)
    · intro h
      rcases Finset.mem_union.mp h with h | h
      · exact Finset.mem_union_left _ h
      · exact Finset.mem_union_right _ (Finset.mem_sdiff.mp h).1
  rw [h_union_eq, Finset.sum_union h_disjoint]
  -- ∑_{K2 \ K1} p ≤ ∑_{K2} p by subset monotonicity (p ≥ 0).
  have h_subset : K2 \ K1 ⊆ K2 := Finset.sdiff_subset
  have h_sub_le : ∑ ω ∈ K2 \ K1, p ω ≤ ∑ ω ∈ K2, p ω :=
    Finset.sum_le_sum_of_subset h_subset
  exact add_le_add (le_refl _) h_sub_le

/-- **R-SUB.3 — equality case (disjoint K₁, K₂).**

When `K₁` and `K₂` are disjoint, the inequality becomes equality:
`π_{K₁ ∪ K₂} = π_{K₁} + π_{K₂}`. -/
theorem R_SUB_3_disjoint_equality
    {Ω : Type} [DecidableEq Ω]
    (K1 K2 : Finset Ω) (p : Ω → NNReal) (h : Disjoint K1 K2) :
    (∑ ω ∈ K1 ∪ K2, p ω) = (∑ ω ∈ K1, p ω) + (∑ ω ∈ K2, p ω) :=
  Finset.sum_union h

/-- **R-SUB.3 — n-family inequality (Boole's inequality).**

For a family `K : J → Finset Ω` indexed by a finite `J`:
`π_{⋃_j K_j} ≤ Σ_j π_{K_j}`.  This is Boole's inequality / countable
sub-additivity restricted to finite-finset masses. -/
theorem R_SUB_3_family_inequality
    {Ω J : Type} [DecidableEq Ω] [DecidableEq J]
    (s : Finset J) (K : J → Finset Ω) (p : Ω → NNReal) :
    (∑ ω ∈ s.biUnion K, p ω) ≤ ∑ j ∈ s, ∑ ω ∈ K j, p ω := by
  -- Induction on s.
  induction s using Finset.induction_on with
  | empty => simp
  | insert j s hjs ih =>
    rw [Finset.sum_insert hjs, Finset.biUnion_insert]
    calc (∑ ω ∈ K j ∪ s.biUnion K, p ω)
        ≤ (∑ ω ∈ K j, p ω) + (∑ ω ∈ s.biUnion K, p ω) :=
          R_SUB_3_pair_inequality _ _ _
      _ ≤ (∑ ω ∈ K j, p ω) + ∑ j ∈ s, ∑ ω ∈ K j, p ω :=
          add_le_add (le_refl _) ih

end OverlapSynergy

end MIP
