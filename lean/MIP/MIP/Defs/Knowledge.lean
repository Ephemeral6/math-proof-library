/-
Mathematical Principles of Intelligence (MIP) — Emergence Mechanics
Knowledge-layer definitions: activation distribution, subdomain partition,
knowledge entropy.

References (in `~/Desktop/MIP/definitions/`):
* D.1.3.b v2 — Activation Probability Measure `p_X(ω; 𝒟)`
* D.1.3.c   — Demand-Induced Subdomain Decomposition
* D.3.3     — Knowledge entropy `H_K(X) = -Σ p_X(ω) log p_X(ω)`
-/
import MIP.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Data.NNReal.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Basic

namespace MIP

open scoped BigOperators

/-! ## D.1.3.b — Normalized knowledge activation distribution `p_X`

The raw activation marginal `α_X(ω; 𝒟) = Pr_{h ~ 𝒟}[ω ⊑ X(h)]` is
generally not a probability distribution (it sums to
`E_{h~𝒟}[|extract(X(h))|]`, which can exceed 1).  After normalising by
`Z_norm(X; 𝒟) := Σ_ω α_X(ω; 𝒟)` we obtain a genuine probability
distribution `p_X` on `Ω`, supported on `K(X)`.

We bundle the `Ω → NNReal` function and its normalisation into a
structure. -/

/-- Normalised knowledge activation distribution (Definition D.1.3.b v2).

`p ω` is the probability mass `p_X(ω; 𝒟)` for some implicit reference
dialogue distribution `𝒟`; downstream theorems quantify over all such
distributions.  The structure carries the normalisation constraint
`∑_ω p ω = 1`.

Note: the support condition `p ω = 0 ⟹ ω ∉ K X` is enforced separately
in the axiom layer when needed; this structure does not bake it in. -/
structure ActivationDist (Ω : Type) [Fintype Ω] where
  /-- The mass function `p_X : Ω → ℝ≥0`. -/
  p : Ω → NNReal
  /-- Normalisation: `Σ_ω p ω = 1`. -/
  normalized : ∑ ω, p ω = 1

namespace ActivationDist

variable {Ω : Type} [Fintype Ω]

/-- Mass of a subset `S ⊆ Ω` under `d.p`. -/
def mass (d : ActivationDist Ω) (S : Finset Ω) : NNReal := ∑ ω ∈ S, d.p ω

@[simp] lemma mass_univ (d : ActivationDist Ω) : d.mass Finset.univ = 1 := by
  unfold mass
  exact d.normalized

end ActivationDist

/-! ## D.1.3.c — Subdomain partition

A *subdomain partition* of `Ω` (relative to a problem-distribution
partition `P = ⊔ P_i`) is a finite family of finite subsets of `Ω` that
is pairwise disjoint and covers `Ω`.

We do not require the parts to come from a specific demand-family
construction `K_i := K(X) ∩ ⋃ ℛ(P_i)` — the structure here records the
end product (the partition itself), which suffices for the conservation
law T.18.10. -/

/-- A finite disjoint-and-exhaustive partition of `Ω`. (D.1.3.c-4
"strict disjoint exhaustive" form, which is the premise of T.18.10.) -/
structure SubdomainPartition (Ω : Type) [Fintype Ω] [DecidableEq Ω] where
  /-- The parts `K_1, …, K_m`. -/
  parts : Finset (Finset Ω)
  /-- Pairwise disjoint: distinct parts have empty intersection. -/
  pairwise_disjoint :
    ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T
  /-- Exhaustive: every knowledge element lies in some part. -/
  cover : ∀ ω : Ω, ∃ S ∈ parts, ω ∈ S

namespace SubdomainPartition

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- `Set.PairwiseDisjoint` rephrasing of `pairwise_disjoint`, which is
the form expected by `Finset.sum_biUnion`. -/
lemma pairwiseDisjoint_id (P : SubdomainPartition Ω) :
    (P.parts : Set (Finset Ω)).PairwiseDisjoint id := by
  intro S hS T hT hne
  exact P.pairwise_disjoint S hS T hT hne

/-- The biUnion of the parts of an exhaustive partition is the whole
finite type. -/
lemma biUnion_eq_univ (P : SubdomainPartition Ω) :
    P.parts.biUnion id = Finset.univ := by
  apply Finset.eq_univ_iff_forall.mpr
  intro ω
  obtain ⟨S, hS, hω⟩ := P.cover ω
  exact Finset.mem_biUnion.mpr ⟨S, hS, hω⟩

/-- Subdomain mass `π_i(X; 𝒟) := ∑_{ω ∈ K_i} p_X(ω)` (Definition D.3.19). -/
def subdomainMass (_P : SubdomainPartition Ω) (d : ActivationDist Ω)
    (K_i : Finset Ω) : NNReal :=
  ∑ ω ∈ K_i, d.p ω

end SubdomainPartition

/-! ## D.3.3 — Knowledge entropy

`H_K(X) := -Σ_{ω ∈ K(X)} p_X(ω) · log p_X(ω)`.

We define it on the whole of `Ω`; for `ω ∉ supp(p_X)` the term vanishes
because `Real.log 0 = 0` by convention and the factor `p_X ω = 0`. -/

/-- Shannon entropy of the activation distribution
`d.p` (Definition D.3.3). -/
noncomputable def knowledgeEntropy {Ω : Type} [Fintype Ω]
    (d : ActivationDist Ω) : ℝ :=
  -∑ ω, (d.p ω : ℝ) * Real.log ((d.p ω : ℝ))

end MIP
