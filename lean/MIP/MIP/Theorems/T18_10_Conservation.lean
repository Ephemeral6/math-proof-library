/-
Theorem T.18.10 — Subdomain mass conservation law (R-SUB.1).

Reference: `theorems/index.md` T.18.10, premise D.1.3.c-4 (strict
disjoint–exhaustive partition).

**Statement.** If `p_X : Ω → ℝ≥0` is a normalised activation distribution
and `K_1, …, K_m` is a disjoint exhaustive partition of `Ω`, then
`Σ_i π_i(X) = 1` where `π_i(X) := Σ_{ω ∈ K_i} p_X(ω)`.

**Proof strategy.** Pairwise disjoint + exhaustive ⟹ `⊔_i K_i = Ω`.
Then `Finset.sum_biUnion` flattens the double sum into a single sum
over `Ω`, which equals 1 by normalisation.

This is the first theorem in the MIP Lean formalisation that is **fully
proved** with no `sorry`.
-/
import MIP.Defs.Knowledge
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators

/-- **T.18.10 (R-SUB.1) Subdomain mass conservation.**

For any normalised mass function `p_X : Ω → ℝ≥0` (summing to 1) and any
disjoint exhaustive partition of `Ω`, the partition masses sum to 1.

This formulation states the law in its most elementary `(Ω, p_X, parts)`
form, matching the user-supplied signature.  The packaged version using
`ActivationDist` and `SubdomainPartition` follows as
`T18_10_conservation_packaged`. -/
theorem T18_10_conservation
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (p_X : Ω → NNReal)
    (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint :
      ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S) :
    ∑ S ∈ parts, ∑ ω ∈ S, p_X ω = 1 := by
  -- (1) Pairwise-disjoint family in the form `Finset.sum_biUnion` wants.
  have hpd : (parts : Set (Finset Ω)).PairwiseDisjoint (id : Finset Ω → Finset Ω) := by
    intro S hS T hT hne
    exact h_disjoint S hS T hT hne
  -- (2) Exhaustiveness gives `parts.biUnion id = univ`.
  have huniv : parts.biUnion id = Finset.univ := by
    apply Finset.eq_univ_iff_forall.mpr
    intro ω
    obtain ⟨S, hS, hω⟩ := h_cover ω
    exact Finset.mem_biUnion.mpr ⟨S, hS, hω⟩
  -- (3) Flatten the double sum and apply normalisation.
  calc ∑ S ∈ parts, ∑ ω ∈ S, p_X ω
      = ∑ ω ∈ parts.biUnion id, p_X ω := (Finset.sum_biUnion hpd).symm
    _ = ∑ ω ∈ (Finset.univ : Finset Ω), p_X ω := by rw [huniv]
    _ = ∑ ω, p_X ω := rfl
    _ = 1 := h_norm

/-- Packaged version of T.18.10 using the `ActivationDist` and
`SubdomainPartition` structures from `MIP.Defs.Knowledge`. -/
theorem T18_10_conservation_packaged
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (d : ActivationDist Ω) (P : SubdomainPartition Ω) :
    ∑ S ∈ P.parts, P.subdomainMass d S = 1 := by
  -- Unfold `subdomainMass` and reduce to the elementary form.
  show ∑ S ∈ P.parts, (∑ ω ∈ S, d.p ω) = 1
  exact T18_10_conservation d.p d.normalized P.parts
    P.pairwise_disjoint P.cover

end MIP
