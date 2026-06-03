/-
  STATUS: DISCOVERY
  AGENT: R2-10
  DIRECTION: Pairwise independence — concrete model violating BOTH A.2
             and A.4 while satisfying A.1 and A.3.
  SUMMARY:
    Build `M_noA2A4 : MIPModel Unit Unit`:
      * `N p X := ⊤`               (always infinite)
      * `Phi0 X p := 1`             (always nonzero)
        Then `N p X = 0 ↔ Phi0 X p = 0` is `False ↔ False` — TRUE.
        →  A.1 holds.
      * `K X := ∅`                  (no knowledge)
      * `demandFamily p := {∅}`    →  ∃ R' ∈ {∅}, R' ⊆ ∅ is TRUE,
        but `N p X = ⊤` so `N p X ≠ ⊤` is FALSE.
        A.2 becomes False ↔ True. →  violates A.2.
      * `MetaSet := Set.univ`      →  A.3 vacuous.
      * `tokenReplace ω h := () :: h`   The identity-on-history agent
        distinguishes histories of different length, violating A.4.

    Result: A.1 ∧ A.3 holds; A.2 ∧ A.4 fails. Hence {A.2, A.4} is
    pairwise independent of {A.1, A.3}.
-/
import MIP.Discoveries.R2_Agent10_ModelFramework

namespace MIP

namespace R2_Agent10_Model_NoA2A4

open R2_Agent10_ModelFramework
open R2_Agent10_ModelFramework.MIPModel

/-- The model. -/
noncomputable def M_noA2A4 : MIPModel Unit Unit where
  N        := fun _ _ => ⊤
  Phi0     := fun _ _ => 1
  K        := fun _ => (∅ : Set Unit)
  demandFamily := fun _ => ({∅} : Set (Set Unit))
  expertKnowledge := fun _ => (∅ : Set Unit)
  Cₑ       := fun _ => 0
  MetaSet  := (Set.univ : Set (Str Unit))
  tokenReplace := fun _ h => () :: h
  tvDist   := fun _ _ => 0

/-! ## A.1 holds: both sides are False. -/

theorem A1_holds : satisfiesA1 M_noA2A4 := by
  intro p X
  constructor
  · intro h
    -- N = ⊤ = 0 contradiction
    exfalso
    exact ENat.top_ne_zero (h : (⊤ : ℕ∞) = 0)
  · intro h
    -- Phi0 = 1 = 0 contradiction
    exfalso
    exact one_ne_zero (h : (1 : ENNReal) = 0)

/-! ## A.3 holds (vacuous via MetaSet = univ). -/

theorem A3_holds : satisfiesA3 M_noA2A4 := by
  intro X e h ε hε hMem _
  exact (hMem (Set.mem_univ e)).elim

/-! ## A.2 fails: N = ⊤ but ∃R' ⊆ K. -/

theorem A2_fails : violatesA2 M_noA2A4 := by
  intro hA2
  -- Pick any problem and agent.
  let p : Problem Unit := fun _ => true
  let X : Agent Unit := fun _ => PMF.pure []
  -- Direction: rhs (witness exists) → lhs (N ≠ ⊤).
  have hRHS : ∃ R' ∈ M_noA2A4.demandFamily p, R' ⊆ M_noA2A4.K X := by
    refine ⟨∅, rfl, ?_⟩
    exact Set.empty_subset _
  have hLHS : M_noA2A4.N p X ≠ ⊤ := (hA2 p X).mpr hRHS
  -- But the model says N = ⊤.
  exact hLHS rfl

/-! ## A.4 fails: identity-on-history agent. -/

theorem A4_fails : violatesA4 M_noA2A4 := by
  intro hA4
  let X₀ : Agent Unit := fun h => PMF.pure h
  have hOut : ((() : Unit)) ∉ M_noA2A4.K X₀ := id
  have heq : X₀ [] = X₀ (M_noA2A4.tokenReplace () []) := hA4 X₀ () [] hOut
  have h1 : (X₀ []) ([] : List Unit) = 1 := PMF.pure_apply_self _
  have h2 : (X₀ (M_noA2A4.tokenReplace () [])) ([] : List Unit) = 0 := by
    show (PMF.pure ([()] : List Unit)) ([] : List Unit) = 0
    apply PMF.pure_apply_of_ne
    intro h
    exact List.cons_ne_nil () [] h.symm
  have hcon : (X₀ []) ([] : List Unit)
                = (X₀ (M_noA2A4.tokenReplace () [])) ([] : List Unit) := by
    rw [heq]
  rw [h1, h2] at hcon
  exact one_ne_zero hcon

/-! ## Headline: {A.2, A.4} is independent of {A.1, A.3}. -/

theorem pair_A2_A4_independent :
    satisfiesA1 M_noA2A4 ∧ satisfiesA3 M_noA2A4
      ∧ violatesA2 M_noA2A4 ∧ violatesA4 M_noA2A4 :=
  ⟨A1_holds, A3_holds, A2_fails, A4_fails⟩

end R2_Agent10_Model_NoA2A4

end MIP
