/-
  STATUS: DISCOVERY
  AGENT: 1
  DIRECTION: A.2 ∧ A.3 — Coverage demands ⊆ K X share their containment
             target with expert-knowledge demands.
  SUMMARY:
    Both A.2 and A.3 have hypotheses of the form `· ⊆ K X`:
      A.2: ∃ R' ∈ ℛ(p), R' ⊆ K X  (coverage witness)
      A.3: expertKnowledge e ⊆ K X  (expert intervention eligibility)
    The shared "containment target" `K X` is the connection point.
    New derivable corollaries:

    (i)  **Expert-supplied coverage**: if a *family* of experts
         `(e_i)_{i ∈ I}` collectively contains the knowledge of some
         R' ∈ ℛ(p) (i.e. R' ⊆ ⋃ᵢ expertKnowledge eᵢ), AND each
         `expertKnowledge eᵢ ⊆ K X` (A.3 eligibility), then
         R' ⊆ K X, so by A.2 N(p, X) < ∞.  This is the
         "expert-knowledge sufficiency" theorem.

    (ii) **A.3 → A.2 lift**: if a single expert e covers R'
         (R' ⊆ expertKnowledge e) and e is A.3-eligible
         (expertKnowledge e ⊆ K X), then R' ⊆ K X, so A.2 gives
         finiteness.

    (iii)**Joint containment**: the conjunction `R' ⊆ K X ∧
         expertKnowledge e ⊆ K X` is exactly `R' ∪ expertKnowledge e ⊆ K X`.
         Useful as an algebraic identity for combining A.2 and A.3
         hypotheses.

    None of these are in Corollaries/* or Results/*.
-/
import MIP.Axioms
import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Lattice

namespace MIP

namespace Agent1_A2A3_CoverageExpertSync

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## (i) Expert-supplied coverage. -/

/-- **A.2+A.3 — Family of experts supplies coverage.**

If a family `(e i)_{i ∈ I}` of expert interventions satisfies:
* each is A.3-eligible: `expertKnowledge (e i) ⊆ K X`;
* their union of expert-knowledge contains some demand R' ∈ ℛ(p):
  `R' ⊆ ⋃ᵢ expertKnowledge (e i)`;

then by transitivity `R' ⊆ K X`, and by A.2 `N p X ≠ ⊤`. -/
theorem N_finite_of_expert_family_covers
    {I : Type} (p : Problem α) (X : Agent α)
    (e : I → Str α)
    (hExpertElig : ∀ i, (expertKnowledge (e i) : Set Ω) ⊆ (K X : Set Ω))
    (R' : Set Ω) (hMem : R' ∈ (demandFamily p : Set (Set Ω)))
    (hCov : R' ⊆ ⋃ i, (expertKnowledge (e i) : Set Ω)) :
    N p X ≠ ⊤ := by
  -- Show R' ⊆ K X by transitivity.
  have hSub : R' ⊆ (K X : Set Ω) := by
    intro ω hω
    obtain ⟨i, hi⟩ := Set.mem_iUnion.mp (hCov hω)
    exact hExpertElig i hi
  exact (Axioms.A2 (Ω := Ω) p X).mpr ⟨R', hMem, hSub⟩

/-! ## (ii) Single-expert A.3 → A.2 lift. -/

/-- **A.2+A.3 — Single expert lifts to coverage.**

If a single A.3-eligible expert `e` (`expertKnowledge e ⊆ K X`) contains
the knowledge of some demand `R' ∈ ℛ(p)` (`R' ⊆ expertKnowledge e`),
then `R' ⊆ K X` and by A.2 `N p X ≠ ⊤`. -/
theorem N_finite_of_single_expert_covers
    (p : Problem α) (X : Agent α) (e : Str α)
    (hExpertElig : (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω))
    (R' : Set Ω) (hMem : R' ∈ (demandFamily p : Set (Set Ω)))
    (hCov : R' ⊆ (expertKnowledge e : Set Ω)) :
    N p X ≠ ⊤ :=
  (Axioms.A2 (Ω := Ω) p X).mpr ⟨R', hMem, hCov.trans hExpertElig⟩

/-! ## (iii) Joint containment algebra. -/

/-- **A.2+A.3 — Joint containment.**

The conjunction "demand R' is K-covered AND expert e is A.3-eligible"
is equivalent to "the union R' ∪ expertKnowledge e is K-covered". -/
theorem joint_subset_K_iff
    (X : Agent α) (R' : Set Ω) (e : Str α) :
    (R' ⊆ (K X : Set Ω)) ∧ ((expertKnowledge e : Set Ω) ⊆ (K X : Set Ω))
      ↔ R' ∪ (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω) := by
  constructor
  · rintro ⟨hR, hE⟩
    exact Set.union_subset hR hE
  · intro hU
    exact ⟨fun ω hω => hU (Or.inl hω), fun ω hω => hU (Or.inr hω)⟩

/-! ## (iv) The "expert-witnessed A.2" — A.3 hypothesis upgrades to A.2 witness. -/

/-- **A.2+A.3 — Expert provides A.2 witness via `R p`.**

If we believe (D.1.4.a hypothesis) that the canonical demand `R p` is an
admissible explanation (`R p ∈ ℛ(p)`), AND a single A.3-eligible expert
`e` carries enough knowledge to cover R p (`R p ⊆ expertKnowledge e`),
then we get a complete A.2 finiteness conclusion. -/
theorem N_finite_canonical_demand_from_expert
    (p : Problem α) (X : Agent α) (e : Str α)
    (hCanon : (R p : Set Ω) ∈ (demandFamily p : Set (Set Ω)))
    (hExpertElig : (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω))
    (hRpExp : (R p : Set Ω) ⊆ (expertKnowledge e : Set Ω)) :
    N p X ≠ ⊤ :=
  N_finite_of_single_expert_covers (Ω := Ω) p X e hExpertElig (R p) hCanon hRpExp

/-! ## (v) Bidirectional: A.2 alone gives a "synthetic expert" demanding only K X. -/

/-- **A.2+A.3 — Synthetic expert exists.**

If `N p X ≠ ⊤` (A.2 finiteness), then there is a demand `R' ∈ ℛ(p)`
with `R' ⊆ K X`.  If additionally we have a "witness expert"
hypothesis — an expert `e_R'` such that `expertKnowledge e_R' = R'`
(synthetic A.3 input) — then this expert is automatically A.3-eligible:
`expertKnowledge e_R' = R' ⊆ K X`. -/
theorem expert_from_coverage
    (p : Problem α) (X : Agent α)
    (hFin : N p X ≠ ⊤)
    (witnessExpert :
      ∀ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) →
        ∃ e : Str α, (expertKnowledge e : Set Ω) = R') :
    ∃ (e : Str α) (R' : Set Ω), R' ∈ (demandFamily p : Set (Set Ω)) ∧
      (expertKnowledge e : Set Ω) = R' ∧
      (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω) := by
  obtain ⟨R', hMem, hSub⟩ := (Axioms.A2 (Ω := Ω) p X).mp hFin
  obtain ⟨e, hExpr⟩ := witnessExpert R' hMem hSub
  refine ⟨e, R', hMem, hExpr, ?_⟩
  rw [hExpr]
  exact hSub

end Agent1_A2A3_CoverageExpertSync

end MIP
