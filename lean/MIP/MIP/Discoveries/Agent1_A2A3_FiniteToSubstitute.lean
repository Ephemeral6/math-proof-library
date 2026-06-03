/-
  STATUS: DISCOVERY
  AGENT: 1
  DIRECTION: A.2 ∧ A.3 — A.2-finiteness ⇒ existence of an "implicit" expert
             whose A.3-substitute realises the demand.
  SUMMARY:
    A.2 gives "∃ R' ∈ ℛ(p), R' ⊆ K X" whenever `N(p, X) < ∞`.  A.3 gives
    a meta-substitute for any expert whose knowledge ⊆ K X.  The genuine
    A.2+A.3 corollary that bridges them: if `N(p, X) < ∞`, then there is
    a demand `R'` that is *exactly* the knowledge of some hypothetical
    expert (one who "embodies the demand"), and that expert is
    automatically A.3-eligible.  In Lean we model this as a
    user-supplied bridge `expertOfDemand` mapping `R' ∈ ℛ(p), R' ⊆ K X`
    to an expert `e` with `expertKnowledge e = R'`.  The combined
    statement: under this bridge, A.2-finiteness implies the existence
    of an A.3-substitute meta-sequence for *some* concrete expert
    realising the demand.

    This is the "operational interpretation of A.2 via A.3":
    A.2-finiteness is *itself* equivalent (under the demand-realisability
    bridge) to the existence of a meta-cognitive sequence that produces
    the right output law.  Neither A.2 nor A.3 alone yields this.
-/
import MIP.Axioms

namespace MIP

namespace Agent1_A2A3_FiniteToSubstitute

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## A.2 → "demand-realising expert" exists (under realisability bridge). -/

/-- **A.2+A.3 — Finiteness yields a concrete A.3-eligible expert.**

Under the realisability bridge (`expertOfDemand`: every K-covered admissible
demand is the expert knowledge of some `e ∈ Σ* \ M`), A.2 finiteness
`N p X ≠ ⊤` produces a concrete expert `e` with `expertKnowledge e ⊆ K X`
(automatic A.3 eligibility) realising a covered demand `R' ∈ ℛ(p)`. -/
theorem expert_realising_demand_of_finite
    (p : Problem α) (X : Agent α)
    (hFin : N p X ≠ ⊤)
    (expertOfDemand :
      ∀ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) →
        {e : Str α // (expertKnowledge e : Set Ω) = R' ∧
                       e ∉ (MetaSet : Set (Str α))}) :
    ∃ (e : Str α) (R' : Set Ω),
      R' ∈ (demandFamily p : Set (Set Ω))
        ∧ (expertKnowledge e : Set Ω) = R'
        ∧ (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω)
        ∧ e ∉ (MetaSet : Set (Str α)) := by
  obtain ⟨R', hMem, hSub⟩ := (Axioms.A2 (Ω := Ω) p X).mp hFin
  obtain ⟨e, hExp, hMem'⟩ := expertOfDemand R' hMem hSub
  refine ⟨e, R', hMem, hExp, ?_, hMem'⟩
  rw [hExp]
  exact hSub

/-! ## A.2 → A.3 substitute exists for that expert. -/

/-- **A.2+A.3 — Finiteness gives an explicit A.3 meta-substitute.**

Combine `expert_realising_demand_of_finite` with A.3: the concrete
expert produced from A.2-finiteness has an A.3 meta-substitute, for any
ε > 0 and any history h. -/
theorem A3_substitute_of_finite
    (p : Problem α) (X : Agent α)
    (hFin : N p X ≠ ⊤)
    (expertOfDemand :
      ∀ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) →
        {e : Str α // (expertKnowledge e : Set Ω) = R' ∧
                       e ∉ (MetaSet : Set (Str α))})
    (h : Str α) (ε : NNReal) (hε : 0 < ε) :
    ∃ (e : Str α) (R' : Set Ω),
      R' ∈ (demandFamily p : Set (Set Ω))
        ∧ (expertKnowledge e : Set Ω) = R'
        ∧ e ∉ (MetaSet : Set (Str α))
        ∧ ∃ (ms : List (Str α)),
            (∀ m ∈ ms, m ∈ (MetaSet : Set (Str α)))
              ∧ (ms.length : ℝ) ≤ (Cₑ e : ℝ) * Real.log (1 / (ε : ℝ))
              ∧ tvDist (X (extendHist h e))
                       (X (extendHist h (ms.foldl List.append []))) ≤ ε := by
  obtain ⟨e, R', hMem, hExp, hElig, hMem'⟩ :=
    expert_realising_demand_of_finite (Ω := Ω) p X hFin expertOfDemand
  refine ⟨e, R', hMem, hExp, hMem', ?_⟩
  exact Axioms.A3 (Ω := Ω) X e h ε hε hMem' hElig

/-! ## Reverse direction: A.3 substitute → A.2 finiteness. -/

/-- **A.2+A.3 — Reverse: an A.3-eligible expert with realised demand
implies A.2 finiteness.**

If we have an expert `e` with `expertKnowledge e = R'` for some
`R' ∈ ℛ(p)` AND `expertKnowledge e ⊆ K X`, then `R' ⊆ K X`, so by A.2
`N p X ≠ ⊤`.  This is the converse to `expert_realising_demand_of_finite`. -/
theorem finite_of_expert_realising_demand
    (p : Problem α) (X : Agent α) (e : Str α) (R' : Set Ω)
    (hMem : R' ∈ (demandFamily p : Set (Set Ω)))
    (hExp : (expertKnowledge e : Set Ω) = R')
    (hElig : (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω)) :
    N p X ≠ ⊤ := by
  refine (Axioms.A2 (Ω := Ω) p X).mpr ⟨R', hMem, ?_⟩
  rw [← hExp]
  exact hElig

/-- **A.2+A.3 — Biconditional under realisability bridge.**

Combine: under the realisability bridge,
`N p X ≠ ⊤  ↔  ∃ e ∈ Σ* \ M, ∃ R' ∈ ℛ(p), R' = expertKnowledge e
                              ∧ expertKnowledge e ⊆ K X`. -/
theorem A2_iff_expert_realising_demand
    (p : Problem α) (X : Agent α)
    (expertOfDemand :
      ∀ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) →
        {e : Str α // (expertKnowledge e : Set Ω) = R' ∧
                       e ∉ (MetaSet : Set (Str α))}) :
    N p X ≠ ⊤ ↔
      ∃ (e : Str α) (R' : Set Ω),
        R' ∈ (demandFamily p : Set (Set Ω))
          ∧ (expertKnowledge e : Set Ω) = R'
          ∧ (expertKnowledge e : Set Ω) ⊆ (K X : Set Ω) := by
  constructor
  · intro hFin
    obtain ⟨e, R', hMem, hExp, hElig, _⟩ :=
      expert_realising_demand_of_finite (Ω := Ω) p X hFin expertOfDemand
    exact ⟨e, R', hMem, hExp, hElig⟩
  · rintro ⟨e, R', hMem, hExp, hElig⟩
    exact finite_of_expert_realising_demand (Ω := Ω) p X e R' hMem hExp hElig

end Agent1_A2A3_FiniteToSubstitute

end MIP
