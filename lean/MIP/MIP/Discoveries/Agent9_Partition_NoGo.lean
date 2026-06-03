/-
  STATUS: DISCOVERY
  AGENT: 9
  DIRECTION: Partition mass impossibility theorems — no part can overshoot, undershoot relative bounds.
  SUMMARY:
    `T18_10_conservation` says: partition masses sum to 1.  As a no-go,
    this rules out *several* configurations:
      (i)   No part of a partition has mass > 1.
      (ii)  No partition has the property "all parts have mass > 1/|parts|"
            (each strictly above average) — Mathlib pigeonhole.
      (iii) No partition has the property "all parts have mass < 1/|parts|"
            (each strictly below average) — by the same pigeonhole.
      (iv)  No partition can have negative mass (vacuously — `NNReal`).
    These are direct no-go corollaries of T.18.10 + standard inequality
    facts, but they're never stated in `T18_10_Conservation.lean` as
    impossibility theorems.  We state them as `False`-conclusion
    statements.

    Headline: "no partition can have *every* part strictly larger than
    average" — a clean impossibility, by `Finset.sum_lt_sum_of_nonempty`
    contradiction.
-/
import MIP.Axioms
import MIP.Theorems.T18_10_Conservation
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

namespace Agent9_Partition_NoGo

open scoped BigOperators

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-! ## (i) No part can have mass > 1. -/

/-- **No part of a normalised partition has mass > 1.** -/
theorem impossible_part_mass_gt_one
    (p_X : Ω → NNReal) (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    (S : Finset Ω) (hS : S ∈ parts)
    (h_overshoot : 1 < (∑ ω ∈ S, p_X ω)) :
    False := by
  -- Total = 1, but S contributes > 1 ⟹ rest contributes < 0 — impossible in NNReal.
  have hsum : ∑ T ∈ parts, ∑ ω ∈ T, p_X ω = 1 :=
    MIP.T18_10_conservation p_X h_norm parts h_disjoint h_cover
  have h_split : (∑ ω ∈ S, p_X ω) + (∑ T ∈ parts.erase S, ∑ ω ∈ T, p_X ω) = 1 := by
    rw [← hsum]; exact Finset.add_sum_erase parts (fun T => ∑ ω ∈ T, p_X ω) hS
  -- Then ∑_S p ≤ 1, but we have ∑_S p > 1.
  have h_le_one : (∑ ω ∈ S, p_X ω) ≤ 1 := by
    calc (∑ ω ∈ S, p_X ω)
        ≤ (∑ ω ∈ S, p_X ω) + (∑ T ∈ parts.erase S, ∑ ω ∈ T, p_X ω) :=
          le_add_of_nonneg_right (zero_le _)
      _ = 1 := h_split
  exact absurd h_le_one (not_le.mpr h_overshoot)

/-! ## (ii) Headline no-go: no partition has every part strictly above average.

When `parts.card > 0` the average mass per part is `1 / parts.card`.
We phrase the inequality in the multiplied form to avoid NNReal division. -/

/-- **No partition can have every part with mass strictly above `1/|parts|`.**

By pigeonhole: if every part has mass > 1/m (m = |parts|), then the sum of
m parts exceeds m · (1/m) = 1.  But the sum equals 1 by T.18.10.  We
state it in the multiplied-out form to avoid NNReal division. -/
theorem impossible_all_parts_above_average
    (p_X : Ω → NNReal) (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    (h_nonempty : parts.Nonempty)
    (h_above : ∀ S ∈ parts, (parts.card : NNReal) * (∑ ω ∈ S, p_X ω) > 1) :
    False := by
  -- Conservation
  have hsum_eq : ∑ T ∈ parts, ∑ ω ∈ T, p_X ω = 1 :=
    MIP.T18_10_conservation p_X h_norm parts h_disjoint h_cover
  -- ∑_S parts.card * mass_S > ∑_S 1 = parts.card
  have h1 : (∑ S ∈ parts, (parts.card : NNReal) * (∑ ω ∈ S, p_X ω))
          > (∑ S ∈ parts, (1 : NNReal)) := by
    apply Finset.sum_lt_sum_of_nonempty h_nonempty
    intro S hS; exact h_above S hS
  -- LHS = parts.card * 1 = parts.card; RHS = parts.card.
  have hLHS : (∑ S ∈ parts, (parts.card : NNReal) * (∑ ω ∈ S, p_X ω))
            = (parts.card : NNReal) := by
    rw [← Finset.mul_sum, hsum_eq, mul_one]
  have hRHS : (∑ _S ∈ parts, (1 : NNReal)) = (parts.card : NNReal) := by
    rw [Finset.sum_const]
    simp
  rw [hLHS, hRHS] at h1
  exact absurd h1 (lt_irrefl _)

/-! ## (iii) Dual: no partition has every part strictly below average. -/

/-- **No partition can have every part with mass strictly below `1/|parts|`.**

Dual of (ii): the sum of m strictly-below-average parts is < m · (1/m) = 1,
but equals 1 by conservation. -/
theorem impossible_all_parts_below_average
    (p_X : Ω → NNReal) (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    (h_nonempty : parts.Nonempty)
    (h_below : ∀ S ∈ parts, (parts.card : NNReal) * (∑ ω ∈ S, p_X ω) < 1) :
    False := by
  have hsum_eq : ∑ T ∈ parts, ∑ ω ∈ T, p_X ω = 1 :=
    MIP.T18_10_conservation p_X h_norm parts h_disjoint h_cover
  have h1 : (∑ S ∈ parts, (parts.card : NNReal) * (∑ ω ∈ S, p_X ω))
          < (∑ S ∈ parts, (1 : NNReal)) := by
    apply Finset.sum_lt_sum_of_nonempty h_nonempty
    intro S hS; exact h_below S hS
  have hLHS : (∑ S ∈ parts, (parts.card : NNReal) * (∑ ω ∈ S, p_X ω))
            = (parts.card : NNReal) := by
    rw [← Finset.mul_sum, hsum_eq, mul_one]
  have hRHS : (∑ _S ∈ parts, (1 : NNReal)) = (parts.card : NNReal) := by
    rw [Finset.sum_const]
    simp
  rw [hLHS, hRHS] at h1
  exact absurd h1 (lt_irrefl _)

/-! ## (iv) Trivial corollary: empty partition impossible if Ω inhabited. -/

omit [Fintype Ω] [DecidableEq Ω] in
/-- **Empty partition is impossible when Ω is inhabited and parts cover Ω.**

If `parts = ∅` then no `ω` has a covering part. -/
theorem impossible_empty_partition_when_inhabited
    [Nonempty Ω]
    (parts : Finset (Finset Ω))
    (h_empty : parts = ∅)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S) :
    False := by
  obtain ⟨ω⟩ := ‹Nonempty Ω›
  obtain ⟨S, hS, _⟩ := h_cover ω
  rw [h_empty] at hS
  exact (Finset.notMem_empty S hS)

end Agent9_Partition_NoGo

end MIP
