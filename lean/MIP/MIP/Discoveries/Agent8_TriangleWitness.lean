/-
  STATUS: DISCOVERY
  AGENT: 8
  DIRECTION: A.2 gives ∃ R' per agent — the witnesses for different
             agents need not match. A *single shared* witness for K A
             and K B suffices for K A ∩ K B coverage; bare A.2 does not
             give this for free.
  SUMMARY:
    A.2 has the form `N p X ≠ ⊤ ↔ ∃ R' ∈ ℛ(p), R' ⊆ K X`. The
    existential is per-agent: nothing in A.2 says the witness for A
    equals the witness for B. So `N p A ≠ ⊤ ∧ N p B ≠ ⊤` does NOT
    immediately give `∃ R' ∈ ℛ(p), R' ⊆ K A ∩ K B`.

    What IS derivable from A.2 — *given* a shared witness:

    (a) If `R' ∈ ℛ(p)`, `R' ⊆ K A`, `R' ⊆ K B`, then `R' ⊆ K A ∩ K B`,
        hence `N p A ≠ ⊤ ∧ N p B ≠ ⊤` (via A.2.mpr on the intersection
        through `inter_subset_left/right`).
    (b) The three-agent shared-witness form: `R' ∈ ℛ(p)`, `R' ⊆ K A`,
        `R' ⊆ K B`, `R' ⊆ K C` ⟹ `R' ⊆ K A ∩ K B ∩ K C`.

    These statements isolate the *meaningful* triangle-style coverage:
    the witness must be shared. This is precisely the "Flywheel" zone of
    R.816 (∃ R' ∈ ℛ(p), R' ⊆ K X ∩ K Y), now lifted to three agents
    with an explicit shared-witness hypothesis.

    Bare "all pairwise N ≠ ⊤" does NOT imply existence of a shared
    witness — the witnesses may differ. This is documented as a non-
    trivial GAP between two-agent A.2 conjunction and joint intersection
    coverage.
-/
import MIP.Axioms
import Mathlib.Data.Set.Basic

namespace MIP

namespace Agent8_TriangleWitness

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## (1) Two-agent shared-witness intersection. -/

/-- **Shared witness for two agents.** If a single demand-witness `R'`
is contained in both `K A` and `K B`, then it is contained in their
intersection — giving A.2-finiteness for both. -/
theorem shared_witness_gives_intersection
    (R' : Set Ω) (A B : Agent α)
    (hA : R' ⊆ (K A : Set Ω))
    (hB : R' ⊆ (K B : Set Ω)) :
    R' ⊆ (K A : Set Ω) ∩ (K B : Set Ω) :=
  Set.subset_inter hA hB

/-- **Shared witness ⟹ both A.2-finite.** -/
theorem both_finite_of_shared_witness
    (p : Problem α) (A B : Agent α)
    (R' : Set Ω) (hMem : R' ∈ (demandFamily p : Set (Set Ω)))
    (hA : R' ⊆ (K A : Set Ω))
    (hB : R' ⊆ (K B : Set Ω)) :
    N p A ≠ ⊤ ∧ N p B ≠ ⊤ :=
  ⟨(Axioms.A2 (Ω := Ω) p A).mpr ⟨R', hMem, hA⟩,
   (Axioms.A2 (Ω := Ω) p B).mpr ⟨R', hMem, hB⟩⟩

/-- **Shared witness ⟹ intersection coverage witness.** Repackaged. -/
theorem demand_in_inter_of_shared
    (p : Problem α) (A B : Agent α)
    (R' : Set Ω) (hMem : R' ∈ (demandFamily p : Set (Set Ω)))
    (hA : R' ⊆ (K A : Set Ω))
    (hB : R' ⊆ (K B : Set Ω)) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)),
      R' ⊆ (K A : Set Ω) ∩ (K B : Set Ω) :=
  ⟨R', hMem, shared_witness_gives_intersection R' A B hA hB⟩

/-! ## (2) Three-agent shared-witness intersection. -/

/-- **Triple shared witness ⟹ triple intersection.** -/
theorem triple_shared_witness_gives_intersection
    (R' : Set Ω) (A B C : Agent α)
    (hA : R' ⊆ (K A : Set Ω))
    (hB : R' ⊆ (K B : Set Ω))
    (hC : R' ⊆ (K C : Set Ω)) :
    R' ⊆ (K A : Set Ω) ∩ (K B : Set Ω) ∩ (K C : Set Ω) :=
  Set.subset_inter (Set.subset_inter hA hB) hC

/-- **Triple shared witness ⟹ all three A.2-finite.** -/
theorem all_three_finite_of_shared_witness
    (p : Problem α) (A B C : Agent α)
    (R' : Set Ω) (hMem : R' ∈ (demandFamily p : Set (Set Ω)))
    (hA : R' ⊆ (K A : Set Ω))
    (hB : R' ⊆ (K B : Set Ω))
    (hC : R' ⊆ (K C : Set Ω)) :
    N p A ≠ ⊤ ∧ N p B ≠ ⊤ ∧ N p C ≠ ⊤ :=
  ⟨(Axioms.A2 (Ω := Ω) p A).mpr ⟨R', hMem, hA⟩,
   (Axioms.A2 (Ω := Ω) p B).mpr ⟨R', hMem, hB⟩,
   (Axioms.A2 (Ω := Ω) p C).mpr ⟨R', hMem, hC⟩⟩

/-- **Triple shared witness ⟹ triple intersection demand witness.** -/
theorem demand_in_triple_inter_of_shared
    (p : Problem α) (A B C : Agent α)
    (R' : Set Ω) (hMem : R' ∈ (demandFamily p : Set (Set Ω)))
    (hA : R' ⊆ (K A : Set Ω))
    (hB : R' ⊆ (K B : Set Ω))
    (hC : R' ⊆ (K C : Set Ω)) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)),
      R' ⊆ (K A : Set Ω) ∩ (K B : Set Ω) ∩ (K C : Set Ω) :=
  ⟨R', hMem, triple_shared_witness_gives_intersection R' A B C hA hB hC⟩

/-! ## (3) The GAP — pairwise A.2 does NOT imply shared witness.

This is recorded as a structural observation:
`N p A ≠ ⊤ ∧ N p B ≠ ⊤` only gives `∃ R_A ⊆ K A` and `∃ R_B ⊆ K B`,
but A.2 does not say `R_A = R_B`. So pairwise finiteness ⟹ joint
intersection coverage is NOT a theorem of A.1–A.4. The hypothesis
"shared witness" is genuinely needed.

We state this *positively* below: if the auditor / model supplies a
"single witness chooser" `F : (· ≠ ⊤ → ∃ R') → R'`, then a stronger
statement is derivable. Without it, the implication is blocked.
-/

/-- **A.2 produces a witness per agent, but witnesses may differ.**

The two-agent statement that IS derivable: each agent independently
gets a (possibly distinct) demand-witness. This is just `A.2.mp`
applied separately to both. -/
theorem distinct_witnesses_per_agent
    (p : Problem α) (A B : Agent α)
    (hA : N p A ≠ ⊤) (hB : N p B ≠ ⊤) :
    (∃ R_A ∈ (demandFamily p : Set (Set Ω)), R_A ⊆ (K A : Set Ω))
      ∧ (∃ R_B ∈ (demandFamily p : Set (Set Ω)), R_B ⊆ (K B : Set Ω)) :=
  ⟨(Axioms.A2 (Ω := Ω) p A).mp hA, (Axioms.A2 (Ω := Ω) p B).mp hB⟩

/-- **Bridge-conditional intersection coverage.** Given a hypothesis
that *some* common demand-witness exists in both `K A` and `K B` (the
witness selection function delivers a shared element), we can derive
intersection coverage. The hypothesis itself is the GAP — A.2 alone
does not produce it. -/
theorem intersection_coverage_of_shared_witness_exists
    (p : Problem α) (A B : Agent α)
    (h : ∃ R' ∈ (demandFamily p : Set (Set Ω)),
            R' ⊆ (K A : Set Ω) ∧ R' ⊆ (K B : Set Ω)) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)),
      R' ⊆ (K A : Set Ω) ∩ (K B : Set Ω) := by
  obtain ⟨R', hMem, hA, hB⟩ := h
  exact ⟨R', hMem, Set.subset_inter hA hB⟩

end Agent8_TriangleWitness

end MIP
