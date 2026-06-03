/-
  STATUS: DISCOVERY
  AGENT: 8
  DIRECTION: Three-agent union coverage — if any one of three agents has
             a covered demand, the union K A ∪ K B ∪ K C covers a demand.
  SUMMARY:
    `Results/R813_JointCoverage.cover_union_of_left/right` is the two-agent
    fact: `R' ⊆ K X → R' ⊆ K X ∪ K Y`. The natural three-agent extension
    (and its A.2-finite form) does not appear in the corpus. We prove:

    (i)   `R' ⊆ K A → R' ⊆ K A ∪ K B ∪ K C` (set-theoretic, three positions);
    (ii)  `N p A ≠ ⊤ ∨ N p B ≠ ⊤ ∨ N p C ≠ ⊤
            → ∃ R' ∈ ℛ(p), R' ⊆ K A ∪ K B ∪ K C` (three-agent union
            finiteness witness);
    (iii) the "triple intersection covers ⟹ all three finite" three-agent
          analogue of R.816's flywheel solvability:
          `(∃ R' ∈ ℛ(p), R' ⊆ K A ∩ K B ∩ K C) → N p A ≠ ⊤ ∧ N p B ≠ ⊤ ∧ N p C ≠ ⊤`.

    These are clean A.2-level multi-agent statements that extend the
    two-agent corpus uniformly to three agents — the kind of formalization
    a 3-agent collaborative-coverage analysis would need.
-/
import MIP.Axioms
import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Lattice

namespace MIP

namespace Agent8_ThreeAgent_UnionCoverage

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## (1) Set-theoretic union lifting. -/

/-- Three-agent union from a left witness. -/
theorem cover_union3_of_left
    (R' : Set Ω) (A B C : Agent α)
    (h : R' ⊆ (K A : Set Ω)) :
    R' ⊆ (K A : Set Ω) ∪ (K B : Set Ω) ∪ (K C : Set Ω) :=
  h.trans (Set.subset_union_left.trans Set.subset_union_left)

/-- Three-agent union from a middle witness. -/
theorem cover_union3_of_mid
    (R' : Set Ω) (A B C : Agent α)
    (h : R' ⊆ (K B : Set Ω)) :
    R' ⊆ (K A : Set Ω) ∪ (K B : Set Ω) ∪ (K C : Set Ω) :=
  h.trans (Set.subset_union_right.trans Set.subset_union_left)

/-- Three-agent union from a right witness. -/
theorem cover_union3_of_right
    (R' : Set Ω) (A B C : Agent α)
    (h : R' ⊆ (K C : Set Ω)) :
    R' ⊆ (K A : Set Ω) ∪ (K B : Set Ω) ∪ (K C : Set Ω) :=
  h.trans Set.subset_union_right

/-! ## (2) Three-agent disjunction-of-finiteness witness.

If any one of `A, B, C` has `N p · ≠ ⊤`, then A.2 produces a covered
demand, and the same witness covers the union `K A ∪ K B ∪ K C`. -/

/-- **Three-agent disjunction → joint union coverage.** If any single
agent among `A, B, C` has finite `N(p, ·)`, there is a single A.2
demand-witness covered by the triple union. -/
theorem demand_in_union3_of_any_finite
    (p : Problem α) (A B C : Agent α)
    (h : N p A ≠ ⊤ ∨ N p B ≠ ⊤ ∨ N p C ≠ ⊤) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)),
      R' ⊆ (K A : Set Ω) ∪ (K B : Set Ω) ∪ (K C : Set Ω) := by
  rcases h with hA | hB | hC
  · obtain ⟨R', hMem, hSub⟩ := (Axioms.A2 (Ω := Ω) p A).mp hA
    exact ⟨R', hMem, cover_union3_of_left R' A B C hSub⟩
  · obtain ⟨R', hMem, hSub⟩ := (Axioms.A2 (Ω := Ω) p B).mp hB
    exact ⟨R', hMem, cover_union3_of_mid R' A B C hSub⟩
  · obtain ⟨R', hMem, hSub⟩ := (Axioms.A2 (Ω := Ω) p C).mp hC
    exact ⟨R', hMem, cover_union3_of_right R' A B C hSub⟩

/-! ## (3) Triple intersection — three-agent flywheel. -/

/-- **Triple intersection coverage → all three finite.** Three-agent
extension of R.816's `flywheel_solvable`: if some demand `R' ∈ ℛ(p)`
fits inside the *triple* intersection `K A ∩ K B ∩ K C`, then each of
`A, B, C` has finite `N(p, ·)`. -/
theorem all_finite_of_triple_intersection_covers
    (p : Problem α) (A B C : Agent α)
    (h : ∃ R' ∈ (demandFamily p : Set (Set Ω)),
            R' ⊆ (K A : Set Ω) ∩ (K B : Set Ω) ∩ (K C : Set Ω)) :
    N p A ≠ ⊤ ∧ N p B ≠ ⊤ ∧ N p C ≠ ⊤ := by
  obtain ⟨R', hMem, hSub⟩ := h
  refine ⟨?_, ?_, ?_⟩
  · refine (Axioms.A2 (Ω := Ω) p A).mpr ⟨R', hMem, ?_⟩
    exact hSub.trans (Set.inter_subset_left.trans Set.inter_subset_left)
  · refine (Axioms.A2 (Ω := Ω) p B).mpr ⟨R', hMem, ?_⟩
    exact hSub.trans (Set.inter_subset_left.trans Set.inter_subset_right)
  · refine (Axioms.A2 (Ω := Ω) p C).mpr ⟨R', hMem, ?_⟩
    exact hSub.trans Set.inter_subset_right

/-! ## (4) Phase quantity — three-agent flywheel order parameter.

Analogue of R.816's `phase_quantity_flywheel`: the three-agent flywheel
zone is captured by the order parameter
`{ R' ∈ ℛ(p) | R' ⊆ K A ∩ K B ∩ K C }.Nonempty`. -/

/-- Three-agent flywheel predicate (Definition-like). -/
def TripleFlywheel (p : Problem α) (A B C : Agent α) : Prop :=
  ∃ R' ∈ (demandFamily p : Set (Set Ω)),
    R' ⊆ (K A : Set Ω) ∩ (K B : Set Ω) ∩ (K C : Set Ω)

/-- **Three-agent flywheel ⟺ phase quantity nonempty.** Bookkeeping. -/
theorem tripleFlywheel_iff_phase_quantity
    (p : Problem α) (A B C : Agent α) :
    TripleFlywheel (Ω := Ω) p A B C
      ↔ { R' | R' ∈ (demandFamily p : Set (Set Ω))
                ∧ R' ⊆ (K A : Set Ω) ∩ (K B : Set Ω) ∩ (K C : Set Ω) }.Nonempty := by
  constructor
  · rintro ⟨R', hMem, hSub⟩; exact ⟨R', hMem, hSub⟩
  · rintro ⟨R', hMem, hSub⟩; exact ⟨R', hMem, hSub⟩

/-- **Three-agent flywheel ⟹ all three solve.** Cf. R.816
`flywheel_solvable`. -/
theorem tripleFlywheel_all_finite
    (p : Problem α) (A B C : Agent α)
    (h : TripleFlywheel (Ω := Ω) p A B C) :
    N p A ≠ ⊤ ∧ N p B ≠ ⊤ ∧ N p C ≠ ⊤ :=
  all_finite_of_triple_intersection_covers (Ω := Ω) p A B C h

end Agent8_ThreeAgent_UnionCoverage

end MIP
