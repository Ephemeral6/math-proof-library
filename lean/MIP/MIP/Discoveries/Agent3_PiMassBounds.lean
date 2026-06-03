/-
  STATUS: DISCOVERY
  AGENT: 3
  DIRECTION: Tier A — Pointwise bounds on subdomain mass π_i ∈ [0, 1].
  SUMMARY:
    For any normalised activation distribution `p_X : Ω → NNReal` and any
    `SubdomainPartition Ω`, the subdomain masses π_i = ∑_{ω ∈ K_i} p_X ω
    satisfy 0 ≤ π_i ≤ 1 for every part. The lower bound is automatic (NNReal),
    but the upper bound is a non-trivial corollary of the conservation law
    T18.10 (Σ π_i = 1) together with non-negativity of the other terms.

    This pointwise upper bound is needed by every downstream entropy /
    KL / variance bound on `π`. It is not in any existing R-SUB file.
-/
import MIP.Theorems.T18_10_Conservation

namespace MIP

namespace Agent3_PiMassBounds

open scoped BigOperators

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

omit [Fintype Ω] [DecidableEq Ω] in
/-- **A.1 — Subdomain mass is nonneg.** Trivial since `p_X` is NNReal; we
state it as a named lemma for symmetry with the upper bound. -/
theorem pi_nonneg
    (p_X : Ω → NNReal) (K_i : Finset Ω) :
    (0 : NNReal) ≤ ∑ ω ∈ K_i, p_X ω :=
  zero_le _

/-- **A.2 — Subdomain mass is bounded by 1.**

For a normalised distribution and a disjoint exhaustive partition, every
subdomain mass is at most 1.  Proof: the conservation law T.18.10 gives
`Σ_{S ∈ parts} π_S = 1`; isolating the single term `π_{K_i}` and using
non-negativity of the other `π_S` finishes.

This is the elementary form (taking the elementary T.18.10 hypotheses). -/
theorem pi_le_one_elementary
    (p_X : Ω → NNReal)
    (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint :
      ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    {K_i : Finset Ω} (hK_i : K_i ∈ parts) :
    (∑ ω ∈ K_i, p_X ω) ≤ 1 := by
  -- Conservation: Σ_{S ∈ parts} (Σ_{ω ∈ S} p_X ω) = 1.
  have h_sum :
      ∑ S ∈ parts, ∑ ω ∈ S, p_X ω = 1 :=
    T18_10_conservation p_X h_norm parts h_disjoint h_cover
  -- Isolate the K_i term from the sum.
  have h_split :
      ∑ S ∈ parts, ∑ ω ∈ S, p_X ω
        = (∑ ω ∈ K_i, p_X ω)
          + ∑ S ∈ parts.erase K_i, ∑ ω ∈ S, p_X ω :=
    (Finset.add_sum_erase parts (fun S => ∑ ω ∈ S, p_X ω) hK_i).symm
  -- The "other" sum is non-negative (NNReal).
  have h_rest_nn :
      (0 : NNReal) ≤ ∑ S ∈ parts.erase K_i, ∑ ω ∈ S, p_X ω :=
    zero_le _
  -- Combine.
  have : (∑ ω ∈ K_i, p_X ω) ≤
      (∑ ω ∈ K_i, p_X ω)
        + ∑ S ∈ parts.erase K_i, ∑ ω ∈ S, p_X ω :=
    le_add_of_nonneg_right h_rest_nn
  calc (∑ ω ∈ K_i, p_X ω)
      ≤ (∑ ω ∈ K_i, p_X ω)
          + ∑ S ∈ parts.erase K_i, ∑ ω ∈ S, p_X ω := this
    _ = ∑ S ∈ parts, ∑ ω ∈ S, p_X ω := h_split.symm
    _ = 1 := h_sum

/-- **A.2 (packaged) — Subdomain mass is bounded by 1 (ActivationDist /
SubdomainPartition form).** -/
theorem pi_le_one
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    {K_i : Finset Ω} (hK_i : K_i ∈ P.parts) :
    P.subdomainMass d K_i ≤ 1 := by
  show (∑ ω ∈ K_i, d.p ω) ≤ 1
  exact pi_le_one_elementary d.p d.normalized P.parts
    P.pairwise_disjoint P.cover hK_i

/-- **Coerced form — `π_i` as a real number lies in [0, 1].** This is the
form most useful for downstream entropy / variance bounds, which all
live in `ℝ`. -/
theorem pi_real_mem_unit_interval
    (d : ActivationDist Ω) (P : SubdomainPartition Ω)
    {K_i : Finset Ω} (hK_i : K_i ∈ P.parts) :
    (0 : ℝ) ≤ ((P.subdomainMass d K_i : NNReal) : ℝ)
      ∧ ((P.subdomainMass d K_i : NNReal) : ℝ) ≤ 1 := by
  refine ⟨NNReal.coe_nonneg _, ?_⟩
  have := pi_le_one d P hK_i
  exact_mod_cast this

end Agent3_PiMassBounds

end MIP
