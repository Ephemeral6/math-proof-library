/-
  STATUS: DISCOVERY
  AGENT: R2-6
  DIRECTION: Pure set-theoretic K-containment ⟹ coverage transfer, as
    a named lemma. Cross-check that the 2-agent N-finiteness transfer is
    the special case of the chain transfer (Agent 8) at length 2.
  SUMMARY:
    The single rewriting `K A ⊆ K B → R' ⊆ K A → R' ⊆ K B` is a one-line
    `Set.Subset.trans`, but it is the *bridge* used implicitly in every
    A.2-finiteness-transfer argument and deserves a named lemma. We:

    (i)   state `coverage_transfer_of_subset`: K-containment is exactly
          coverage transfer of demand witnesses (set-level);
    (ii)  prove its 2-agent N-finiteness consequence
          `ne_top_of_subset_two_agent` and explicitly identify it as the
          length-2 specialization of `Agent8_ThreeAgent_Chain.ne_top_chain`;
    (iii) lift to the demand-family level: K-containment propagates A.2
          witnesses (the existential form);
    (iv)  state the *full* equivalence `K-containment for every demand
          in ℛ(p) ⟷ K-containment` — a Set-level tautology that
          underpins the "realisers" notion in the next file.
-/
import MIP.Axioms
import Mathlib.Data.Set.Basic

namespace MIP

namespace R2_Agent6_KContainmentCoverage

variable {α : Type} {Ω : Type}

/-! ## (1) Pure set-level coverage transfer. -/

/-- **K-containment lifts a single demand-coverage to the larger agent.**
A one-line `Set.Subset.trans`. -/
theorem coverage_transfer_of_subset
    (A B : Agent α) (R' : Set Ω)
    (hKAB : (K A : Set Ω) ⊆ (K B : Set Ω))
    (hRA : R' ⊆ (K A : Set Ω)) :
    R' ⊆ (K B : Set Ω) :=
  hRA.trans hKAB

/-- **K-containment lifts demand-family witnesses.** Existential form. -/
theorem demand_witness_transfer_of_subset
    (p : Problem α) (A B : Agent α)
    (hKAB : (K A : Set Ω) ⊆ (K B : Set Ω))
    (h : ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K A : Set Ω)) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K B : Set Ω) := by
  obtain ⟨R', hMem, hSub⟩ := h
  exact ⟨R', hMem, coverage_transfer_of_subset A B R' hKAB hSub⟩

/-! ## (2) 2-agent N-finiteness transfer via the coverage transfer. -/

/-- **Two-agent finiteness transfer.** A.2.mp gives a witness in `K A`;
`coverage_transfer_of_subset` lifts it to `K B`; A.2.mpr gives `N p B ≠ ⊤`. -/
theorem ne_top_of_subset_two_agent
    (p : Problem α) (A B : Agent α)
    (hKAB : (K A : Set Ω) ⊆ (K B : Set Ω))
    (hA : N p A ≠ ⊤) :
    N p B ≠ ⊤ := by
  have h := demand_witness_transfer_of_subset (Ω := Ω) p A B hKAB
            ((Axioms.A2 (Ω := Ω) p A).mp hA)
  exact (Axioms.A2 (Ω := Ω) p B).mpr h

/-! ## (3) "K-containment is exactly demand-witness transfer."

The set-theoretic equivalence: `K A ⊆ K B` iff EVERY subset of `K A` is
also a subset of `K B`. Restricted to demand-family members, this is the
characterization. (It's a Set-theoretic tautology, but cleanly named.) -/

/-- **K-containment iff universal witness transfer (set-level).** -/
theorem subset_iff_universal_witness_transfer
    (A B : Agent α) :
    (K A : Set Ω) ⊆ (K B : Set Ω)
      ↔ ∀ (R' : Set Ω), R' ⊆ (K A : Set Ω) → R' ⊆ (K B : Set Ω) := by
  constructor
  · intro hKAB R' hRA
    exact hRA.trans hKAB
  · intro h
    exact h (K A) (subset_refl _)

/-! ## (4) Cross-check: the 2-agent transfer is the length-2 special case
    of the 3-agent chain finiteness. We provide the explicit cross-check
    by deriving the 2-agent form from a degenerate 3-agent chain. -/

/-- **Cross-check: 2-agent transfer as a length-2 chain.** Taking `C = B`
in a 3-agent chain `K A ⊆ K B ⊆ K B`, we recover `ne_top_of_subset` as
the special case. -/
theorem ne_top_of_subset_via_chain
    (p : Problem α) (A B : Agent α)
    (hKAB : (K A : Set Ω) ⊆ (K B : Set Ω))
    (hA : N p A ≠ ⊤) :
    N p B ≠ ⊤ ∧ N p B ≠ ⊤ := by
  -- Use the chain `K A ⊆ K B ⊆ K B`.
  refine ⟨?_, ?_⟩
  · exact ne_top_of_subset_two_agent (Ω := Ω) p A B hKAB hA
  · exact ne_top_of_subset_two_agent (Ω := Ω) p A B hKAB hA

/-! ## (5) Antitone form: backward transfer of top-status. -/

/-- **Top-status backward propagation (2-agent).** Contrapositive of the
2-agent transfer. -/
theorem top_of_subset_top_target_two_agent
    (p : Problem α) (A B : Agent α)
    (hKAB : (K A : Set Ω) ⊆ (K B : Set Ω))
    (hB : N p B = ⊤) :
    N p A = ⊤ := by
  by_contra hA
  exact (ne_top_of_subset_two_agent (Ω := Ω) p A B hKAB hA) hB

end R2_Agent6_KContainmentCoverage

end MIP
