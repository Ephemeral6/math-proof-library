/-
  STATUS: DISCOVERY
  AGENT: R2-6
  DIRECTION: Three-agent positive case: `K A ⊆ K B ∩ K C → N p A ≠ ⊤
    → N p B ≠ ⊤ ∧ N p C ≠ ⊤` (intersection finiteness transfer).
  SUMMARY:
    The Agent 8 chain handles linear chains `K A ⊆ K B ⊆ K C`. The
    *intersection* form `K A ⊆ K B ∩ K C` is logically stronger on the
    hypothesis side (it gives BOTH `K A ⊆ K B` and `K A ⊆ K C` directly)
    and is the natural three-agent generalization of `R.813`-style
    statements where a single agent's knowledge is jointly dominated.

    We prove:

      (i)   `inter_finiteness_transfer`: `K A ⊆ K B ∩ K C →
                  N p A ≠ ⊤ → N p B ≠ ⊤ ∧ N p C ≠ ⊤`
      (ii)  `K A = K B ∩ K C` analogue: same conclusion as (i), with the
            equality. Adds nothing extra over the inclusion form.
      (iii) Four-agent intersection: `K A ⊆ K B ∩ K C ∩ K D →
                  N p A ≠ ⊤ → all three finite`.
      (iv)  Generalised: `K A ⊆ ⋂_{X ∈ S} K X → N p A ≠ ⊤ →
                  ∀ X ∈ S, N p X ≠ ⊤`, indexed by a finset.
-/
import MIP.Axioms
import Mathlib.Data.Set.Basic
import Mathlib.Data.Finset.Basic

namespace MIP

namespace R2_Agent6_InterFiniteness

variable {α : Type} {Ω : Type}

/-! ## (1) Two-agent kernel. -/

/-- **Two-agent finiteness transfer (local re-derivation).** -/
theorem ne_top_of_subset
    (p : Problem α) (A B : Agent α)
    (hK : (K A : Set Ω) ⊆ (K B : Set Ω))
    (hA : N p A ≠ ⊤) :
    N p B ≠ ⊤ := by
  obtain ⟨R', hMem, hSub⟩ := (Axioms.A2 (Ω := Ω) p A).mp hA
  exact (Axioms.A2 (Ω := Ω) p B).mpr ⟨R', hMem, hSub.trans hK⟩

/-! ## (2) Three-agent intersection-form finiteness transfer. -/

/-- **Intersection finiteness transfer (three agents).** If `K A` sits
inside `K B ∩ K C` and `N p A ≠ ⊤`, then both `N p B ≠ ⊤` and `N p C ≠ ⊤`. -/
theorem inter_finiteness_transfer
    (p : Problem α) (A B C : Agent α)
    (hSub : (K A : Set Ω) ⊆ (K B : Set Ω) ∩ (K C : Set Ω))
    (hA : N p A ≠ ⊤) :
    N p B ≠ ⊤ ∧ N p C ≠ ⊤ := by
  have hAB : (K A : Set Ω) ⊆ (K B : Set Ω) := hSub.trans Set.inter_subset_left
  have hAC : (K A : Set Ω) ⊆ (K C : Set Ω) := hSub.trans Set.inter_subset_right
  exact ⟨ne_top_of_subset (Ω := Ω) p A B hAB hA,
         ne_top_of_subset (Ω := Ω) p A C hAC hA⟩

/-- **Intersection coverage witness.** The single A.2 witness for `A`
covers both `K B` and `K C`. -/
theorem inter_coverage_witness
    (p : Problem α) (A B C : Agent α)
    (hSub : (K A : Set Ω) ⊆ (K B : Set Ω) ∩ (K C : Set Ω))
    (hA : N p A ≠ ⊤) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)),
      R' ⊆ (K B : Set Ω) ∧ R' ⊆ (K C : Set Ω) := by
  obtain ⟨R', hMem, hRA⟩ := (Axioms.A2 (Ω := Ω) p A).mp hA
  refine ⟨R', hMem, ?_, ?_⟩
  · exact hRA.trans (hSub.trans Set.inter_subset_left)
  · exact hRA.trans (hSub.trans Set.inter_subset_right)

/-! ## (3) K-equality form. -/

/-- **`K A = K B ∩ K C` ⟹ same intersection finiteness transfer.**
The equality gives nothing extra over the inclusion (the conclusion is
the same; the converse direction `K B ∩ K C ⊆ K A` doesn't help us
derive anything new about `N p B` or `N p C` since A.2 already produces
witnesses *per agent*). -/
theorem inter_finiteness_transfer_K_eq
    (p : Problem α) (A B C : Agent α)
    (hEq : (K A : Set Ω) = (K B : Set Ω) ∩ (K C : Set Ω))
    (hA : N p A ≠ ⊤) :
    N p B ≠ ⊤ ∧ N p C ≠ ⊤ :=
  inter_finiteness_transfer (Ω := Ω) p A B C hEq.subset hA

/-! ## (4) Four-agent intersection transfer. -/

/-- **Four-agent intersection finiteness transfer.** If `K A ⊆ K B ∩ K C
∩ K D` and `N p A ≠ ⊤`, then all three downstream agents are A.2-finite. -/
theorem inter_finiteness_transfer_four
    (p : Problem α) (A B C D : Agent α)
    (hSub : (K A : Set Ω) ⊆ (K B : Set Ω) ∩ (K C : Set Ω) ∩ (K D : Set Ω))
    (hA : N p A ≠ ⊤) :
    N p B ≠ ⊤ ∧ N p C ≠ ⊤ ∧ N p D ≠ ⊤ := by
  have hAB : (K A : Set Ω) ⊆ (K B : Set Ω) :=
    hSub.trans (Set.inter_subset_left.trans Set.inter_subset_left)
  have hAC : (K A : Set Ω) ⊆ (K C : Set Ω) :=
    hSub.trans (Set.inter_subset_left.trans Set.inter_subset_right)
  have hAD : (K A : Set Ω) ⊆ (K D : Set Ω) :=
    hSub.trans Set.inter_subset_right
  exact ⟨ne_top_of_subset (Ω := Ω) p A B hAB hA,
         ne_top_of_subset (Ω := Ω) p A C hAC hA,
         ne_top_of_subset (Ω := Ω) p A D hAD hA⟩

/-! ## (5) Finset-indexed: K A ⊆ ⋂_{X ∈ S} K X. -/

/-- **Finset-indexed intersection finiteness transfer.** If `A` has
`K A ⊆ K X` for every `X` in a finite set of agents `S`, and `N p A ≠ ⊤`,
then `N p X ≠ ⊤` for every `X ∈ S`. -/
theorem inter_finiteness_transfer_finset
    (p : Problem α) (A : Agent α) (S : Finset (Agent α))
    (hSub : ∀ X ∈ S, (K A : Set Ω) ⊆ (K X : Set Ω))
    (hA : N p A ≠ ⊤) :
    ∀ X ∈ S, N p X ≠ ⊤ := by
  intro X hX
  exact ne_top_of_subset (Ω := Ω) p A X (hSub X hX) hA

/-- **Finset-indexed intersection coverage witness.** A single A.2
witness for `A` covers every `K X` for `X ∈ S`. -/
theorem inter_coverage_witness_finset
    (p : Problem α) (A : Agent α) (S : Finset (Agent α))
    (hSub : ∀ X ∈ S, (K A : Set Ω) ⊆ (K X : Set Ω))
    (hA : N p A ≠ ⊤) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)),
      ∀ X ∈ S, R' ⊆ (K X : Set Ω) := by
  obtain ⟨R', hMem, hRA⟩ := (Axioms.A2 (Ω := Ω) p A).mp hA
  refine ⟨R', hMem, ?_⟩
  intro X hX
  exact hRA.trans (hSub X hX)

/-! ## (6) Contrapositive: top status propagates back from any covered
    agent to `A`. -/

/-- **Contrapositive: if any of B, C is `⊤`, then A is `⊤`.** Provided
the inclusion `K A ⊆ K B ∩ K C` holds. -/
theorem A_top_of_any_inter_top
    (p : Problem α) (A B C : Agent α)
    (hSub : (K A : Set Ω) ⊆ (K B : Set Ω) ∩ (K C : Set Ω))
    (h : N p B = ⊤ ∨ N p C = ⊤) :
    N p A = ⊤ := by
  by_contra hA
  have ⟨hB, hC⟩ := inter_finiteness_transfer (Ω := Ω) p A B C hSub hA
  rcases h with hB' | hC'
  · exact hB hB'
  · exact hC hC'

end R2_Agent6_InterFiniteness

end MIP
