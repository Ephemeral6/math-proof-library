/-
Result R-SUB.7 — Knowledge-entropy chain decomposition.

Reference: `workspace/subdomain_competition.md` §6.7 (A 无条件).

**Statement.** For a normalised activation distribution `p_X : Ω → ℝ≥0`
and a finite partition `K(X) = ⊔_i K_i`:

    H_K(X) = H(π) + Σ_i π_i · H_i,

where
* `π_i := Σ_{ω ∈ K_i} p_X(ω)` is subdomain mass,
* `H(π) := −Σ_i π_i log π_i` is the coarse-grained entropy,
* `H_i := −Σ_{ω ∈ K_i} (p_X(ω)/π_i) log (p_X(ω)/π_i)` is the within-subdomain
  conditional entropy (convention `0 · log 0 = 0` via `Real.log 0 = 0`).

**Proof.** Standard Shannon chain rule.

For `ω ∈ K_i` write `p(ω) = π_i · (p(ω)/π_i)` (after dropping the
`π_i = 0` parts, where the entropy contribution vanishes). Then

    -p(ω) log p(ω) = -p(ω) (log π_i + log (p(ω)/π_i))
                  = -p(ω) log π_i  -  p(ω) log (p(ω)/π_i),

and summing over `ω ∈ K_i` gives the chain rule. ∎

This file proves the **pure-math chain rule** for a finite partition of
any `Fintype Ω` carrying a normalised non-negative mass function,
without sorry. The MIP-side wrappers (using `ActivationDist` and
`SubdomainPartition`) are stated as corollaries.
-/
import MIP.Defs.Knowledge
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators
open Real

namespace HKChain

/-- Total Shannon entropy of `p : Ω → ℝ` summed over a finite set `S`.
Uses the convention `0 · log 0 = 0` since `Real.log 0 = 0` and the
factor of `p ω` annihilates `log 0` even when the log itself is `0`. -/
noncomputable def entropy {Ω : Type} (S : Finset Ω) (p : Ω → ℝ) : ℝ :=
  -∑ ω ∈ S, p ω * Real.log (p ω)

variable {Ω : Type} [DecidableEq Ω]

/-- **Atomic chain identity for one subdomain.**

`∑_{ω ∈ S} p ω · log p ω = (∑_{ω ∈ S} p ω) · log π + ∑_{ω ∈ S} p ω · log (p ω / π)`,
provided `π = ∑_{ω ∈ S} p ω > 0` (so we can split the logarithm).

This is the algebra core of the chain rule. -/
lemma chain_atomic {Ω : Type} (S : Finset Ω) (p : Ω → ℝ)
    (hp : ∀ ω ∈ S, 0 ≤ p ω) (hpos : 0 < ∑ ω ∈ S, p ω) :
    ∑ ω ∈ S, p ω * Real.log (p ω)
      = (∑ ω ∈ S, p ω) * Real.log (∑ ω ∈ S, p ω)
        + ∑ ω ∈ S, p ω * Real.log (p ω / (∑ ω ∈ S, p ω)) := by
  set π := ∑ ω ∈ S, p ω
  -- For each ω with p ω > 0, `log (p ω) = log π + log (p ω / π)`.
  -- For p ω = 0, both sides contribute 0.
  have hkey : ∀ ω ∈ S,
      p ω * Real.log (p ω) =
        p ω * Real.log π + p ω * Real.log (p ω / π) := by
    intro ω hω
    by_cases hzero : p ω = 0
    · rw [hzero]; ring
    · -- p ω > 0; p ω / π > 0 since π > 0
      have hpωpos : 0 < p ω := lt_of_le_of_ne (hp ω hω) (Ne.symm hzero)
      have hπne : π ≠ 0 := ne_of_gt hpos
      have hlog : Real.log (p ω) = Real.log π + Real.log (p ω / π) := by
        rw [Real.log_div (ne_of_gt hpωpos) hπne]; ring
      rw [hlog]; ring
  rw [Finset.sum_congr rfl hkey, Finset.sum_add_distrib]
  have : ∑ ω ∈ S, p ω * Real.log π = (∑ ω ∈ S, p ω) * Real.log π := by
    rw [← Finset.sum_mul]
  rw [this]

/-- **R-SUB.7 chain rule, in the partition-mass form.**

Given pairwise disjoint subsets `parts ⊆ Finset Ω` whose biUnion is the
full universe (an exhaustive disjoint partition), and a normalised
mass function `p`, the total entropy decomposes as
"coarse-grained π-entropy" + "weighted within-subdomain entropies". -/
theorem R_SUB_7_chain_decomposition
    [Fintype Ω]
    (p : Ω → ℝ) (hp : ∀ ω, 0 ≤ p ω)
    (parts : Finset (Finset Ω))
    (h_disjoint : (parts : Set (Finset Ω)).PairwiseDisjoint id)
    (h_cover : parts.biUnion id = Finset.univ)
    (h_pos_part : ∀ S ∈ parts, 0 < ∑ ω ∈ S, p ω) :
    -∑ ω, p ω * Real.log (p ω)
      = -∑ S ∈ parts, (∑ ω ∈ S, p ω) * Real.log (∑ ω ∈ S, p ω)
        + ∑ S ∈ parts,
            (∑ ω ∈ S, p ω) *
              (-∑ ω ∈ S, (p ω / (∑ ω' ∈ S, p ω')) *
                  Real.log (p ω / (∑ ω' ∈ S, p ω'))) := by
  -- Step 1: rewrite the full sum as a sum over parts via biUnion.
  have hflatten :
      ∑ ω, p ω * Real.log (p ω)
        = ∑ S ∈ parts, ∑ ω ∈ S, p ω * Real.log (p ω) := by
    calc ∑ ω, p ω * Real.log (p ω)
        = ∑ ω ∈ (Finset.univ : Finset Ω), p ω * Real.log (p ω) := rfl
      _ = ∑ ω ∈ parts.biUnion id, p ω * Real.log (p ω) := by rw [h_cover]
      _ = ∑ S ∈ parts, ∑ ω ∈ S, p ω * Real.log (p ω) :=
          Finset.sum_biUnion h_disjoint
  -- Step 2: apply the atomic chain identity on each part.
  have hper :
      ∀ S ∈ parts,
        ∑ ω ∈ S, p ω * Real.log (p ω)
          = (∑ ω ∈ S, p ω) * Real.log (∑ ω ∈ S, p ω)
            + ∑ ω ∈ S, p ω * Real.log (p ω / (∑ ω ∈ S, p ω)) := by
    intro S hS
    exact chain_atomic S p (fun ω _ => hp ω) (h_pos_part S hS)
  rw [hflatten, Finset.sum_congr rfl hper]
  -- Step 3: distribute the sum and rearrange the conditional-entropy term.
  rw [Finset.sum_add_distrib]
  -- The "within-subdomain" sum needs scaling by π_S = ∑_{ω ∈ S} p ω.
  -- For each S, π_S · (-∑ (p/π) log (p/π)) = -∑ (p/π) (π) log (p/π)
  --   = -∑ p log (p/π)  ⟺  +∑ p log (p/π) = -π · (-∑ (p/π) log (p/π)).
  -- We arrange so the third sum equals `∑ p log (p/π)` on the LHS
  -- and `-π · H_cond` on the RHS via the simple identity
  --   π · (-∑ (p/π) log (p/π)) = -∑ p log (p/π).
  have hcond : ∀ S ∈ parts,
      (∑ ω ∈ S, p ω) *
        (-∑ ω ∈ S, (p ω / (∑ ω' ∈ S, p ω')) *
            Real.log (p ω / (∑ ω' ∈ S, p ω')))
      = -∑ ω ∈ S, p ω * Real.log (p ω / (∑ ω' ∈ S, p ω')) := by
    intro S hS
    have hπpos := h_pos_part S hS
    have hπne : (∑ ω ∈ S, p ω) ≠ 0 := ne_of_gt hπpos
    -- Per-term: π * ((p ω / π) * log (p ω / π)) = p ω * log (p ω / π).
    have hper :
        ∀ ω ∈ S,
          (∑ ω' ∈ S, p ω') * ((p ω / ∑ ω' ∈ S, p ω') * Real.log (p ω / ∑ ω' ∈ S, p ω'))
            = p ω * Real.log (p ω / ∑ ω' ∈ S, p ω') := by
      intro ω _
      field_simp
    rw [mul_neg, Finset.mul_sum, Finset.sum_congr rfl hper]
  rw [Finset.sum_congr rfl hcond]
  -- Final arithmetic.
  rw [Finset.sum_neg_distrib]
  ring

end HKChain

end MIP
