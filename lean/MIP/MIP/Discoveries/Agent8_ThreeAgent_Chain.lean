/-
  STATUS: DISCOVERY
  AGENT: 8
  DIRECTION: Three-agent finiteness chain — K A ⊆ K B ⊆ K C transports
             A.2 finiteness along the inclusion chain.
  SUMMARY:
    `Corollaries/C6_PosetMonotone.finiteness_transfer` proves a two-agent
    version: `K A ⊆ K B → N p A ≠ ⊤ → N p B ≠ ⊤`.  The natural three-agent
    extension chain `K A ⊆ K B ⊆ K C → N p A ≠ ⊤ → N p B ≠ ⊤ ∧ N p C ≠ ⊤`
    follows by composing two C.6 steps, and likewise `K A = K B = K C →
    N p A ≠ ⊤ ↔ N p B ≠ ⊤ ↔ N p C ≠ ⊤`.  We also state the contrapositive
    "infection" form (top-status propagates backwards along the chain).
    These are the cleanest novel three-agent statements: no analogue exists
    in `Results/R813_JointCoverage.lean` or `Results/R816_FlywheelTrap.lean`,
    both of which stop at two agents.
-/
import MIP.Axioms

namespace MIP

namespace Agent8_ThreeAgent_Chain

variable {α : Type} {Ω : Type}

/-! ## (1) Two-agent finiteness transfer (re-derivation).

We re-prove the C.6 kernel inline so this file is self-contained
(`Corollaries/C6` is in a different namespace and we want a stable
import-light entry point). The proof is one-line A.2.mp + .mpr with the
inclusion lifting the witness. -/

/-- **Two-agent finiteness transfer.** If `K A ⊆ K B` and `N p A ≠ ⊤`,
then `N p B ≠ ⊤`. (Re-derivation of `Corollary_C6.finiteness_transfer`
for namespace-local use.) -/
theorem ne_top_of_subset
    (p : Problem α) (A B : Agent α)
    (hK : (K A : Set Ω) ⊆ (K B : Set Ω))
    (hA : N p A ≠ ⊤) :
    N p B ≠ ⊤ := by
  obtain ⟨R', hMem, hSub⟩ := (Axioms.A2 (Ω := Ω) p A).mp hA
  exact (Axioms.A2 (Ω := Ω) p B).mpr ⟨R', hMem, hSub.trans hK⟩

/-! ## (2) Three-agent chain.

If `K A ⊆ K B ⊆ K C`, then finiteness of `N p A` cascades to both
`N p B` and `N p C`. -/

/-- **Three-agent finiteness chain.** If `K A ⊆ K B ⊆ K C` and
`N p A ≠ ⊤`, then both `N p B ≠ ⊤` and `N p C ≠ ⊤`. -/
theorem ne_top_chain
    (p : Problem α) (A B C : Agent α)
    (hAB : (K A : Set Ω) ⊆ (K B : Set Ω))
    (hBC : (K B : Set Ω) ⊆ (K C : Set Ω))
    (hA : N p A ≠ ⊤) :
    N p B ≠ ⊤ ∧ N p C ≠ ⊤ := by
  have hB : N p B ≠ ⊤ := ne_top_of_subset (Ω := Ω) p A B hAB hA
  have hC : N p C ≠ ⊤ := ne_top_of_subset (Ω := Ω) p B C hBC hB
  exact ⟨hB, hC⟩

/-- **Three-agent finiteness chain — direct from A to C.** Transitivity
of the inclusion plus a single A.2 step. -/
theorem ne_top_chain_direct
    (p : Problem α) (A C : Agent α)
    (hAC : (K A : Set Ω) ⊆ (K C : Set Ω))
    (hA : N p A ≠ ⊤) :
    N p C ≠ ⊤ :=
  ne_top_of_subset (Ω := Ω) p A C hAC hA

/-! ## (3) Contrapositive: top status propagates backwards. -/

/-- **Top-status backward propagation.** If `K A ⊆ K B` and `N p B = ⊤`,
then `N p A = ⊤`. (Contrapositive of `ne_top_of_subset`.) -/
theorem top_of_subset_top_target
    (p : Problem α) (A B : Agent α)
    (hK : (K A : Set Ω) ⊆ (K B : Set Ω))
    (hB : N p B = ⊤) :
    N p A = ⊤ := by
  by_contra hA
  exact (ne_top_of_subset (Ω := Ω) p A B hK hA) hB

/-- **Three-agent top-status backward chain.** If `K A ⊆ K B ⊆ K C` and
`N p C = ⊤`, then both `N p A = ⊤` and `N p B = ⊤`. -/
theorem top_chain
    (p : Problem α) (A B C : Agent α)
    (hAB : (K A : Set Ω) ⊆ (K B : Set Ω))
    (hBC : (K B : Set Ω) ⊆ (K C : Set Ω))
    (hC : N p C = ⊤) :
    N p A = ⊤ ∧ N p B = ⊤ := by
  have hB : N p B = ⊤ := top_of_subset_top_target (Ω := Ω) p B C hBC hC
  have hA : N p A = ⊤ := top_of_subset_top_target (Ω := Ω) p A B hAB hB
  exact ⟨hA, hB⟩

/-! ## (4) Three-way K-equality.

When all three agents have equal knowledge sets, finiteness verdicts
agree across all three. -/

/-- **Three-way knowledge equality → finiteness equivalence.** If
`K A = K B = K C`, then `N p A ≠ ⊤ ↔ N p B ≠ ⊤ ↔ N p C ≠ ⊤`. -/
theorem ne_top_iff_three
    (p : Problem α) (A B C : Agent α)
    (hAB : (K A : Set Ω) = (K B : Set Ω))
    (hBC : (K B : Set Ω) = (K C : Set Ω)) :
    (N p A ≠ ⊤ ↔ N p B ≠ ⊤) ∧ (N p B ≠ ⊤ ↔ N p C ≠ ⊤) := by
  refine ⟨?_, ?_⟩
  · rw [Axioms.A2 (Ω := Ω) p A, Axioms.A2 (Ω := Ω) p B, hAB]
  · rw [Axioms.A2 (Ω := Ω) p B, Axioms.A2 (Ω := Ω) p C, hBC]

/-- **Three-way knowledge equality → joint finiteness.** All three
agents share the same `N ≠ ⊤` status. -/
theorem ne_top_three_way
    (p : Problem α) (A B C : Agent α)
    (hAB : (K A : Set Ω) = (K B : Set Ω))
    (hBC : (K B : Set Ω) = (K C : Set Ω)) :
    N p A ≠ ⊤ ↔ (N p B ≠ ⊤ ∧ N p C ≠ ⊤) := by
  constructor
  · intro hA
    have hAB' : (K A : Set Ω) ⊆ (K B : Set Ω) := hAB.subset
    have hBC' : (K B : Set Ω) ⊆ (K C : Set Ω) := hBC.subset
    exact ne_top_chain (Ω := Ω) p A B C hAB' hBC' hA
  · rintro ⟨hB, _⟩
    have hBA : (K B : Set Ω) ⊆ (K A : Set Ω) := hAB.symm.subset
    exact ne_top_of_subset (Ω := Ω) p B A hBA hB

end Agent8_ThreeAgent_Chain

end MIP
