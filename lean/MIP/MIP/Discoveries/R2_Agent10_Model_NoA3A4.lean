/-
  STATUS: DISCOVERY
  AGENT: R2-10
  DIRECTION: Pairwise independence — concrete model violating BOTH A.3
             and A.4 while satisfying A.1 and A.2.
  SUMMARY:
    Build `M_noA3A4 : MIPModel Unit Unit`:
      * `N p X := 0`, `Phi0 X p := 0`
        N=0 ↔ Phi0=0 is True ↔ True (TRUE).  →  A.1 holds.
      * `K X := ∅`, `demandFamily p := {∅}`
        N=0 ≠ ⊤ True; ∃ R'=∅ ⊆ ∅ True.  ↔ True.  →  A.2 holds.
      * `MetaSet := ∅`, `Cₑ e := 0`, `expertKnowledge e := ∅`,
        `tvDist := fun _ _ => 1`, `tokenReplace ω h := () :: h`.
        Same Cₑ=0 + constant-tvDist=1 trick: A.3 fails at ε = 1/2.
        Identity-on-history agent X₀ violates A.4.

    Conclusion: {A.3, A.4} is pairwise independent of {A.1, A.2}.
-/
import MIP.Discoveries.R2_Agent10_ModelFramework

namespace MIP

namespace R2_Agent10_Model_NoA3A4

open R2_Agent10_ModelFramework
open R2_Agent10_ModelFramework.MIPModel

noncomputable def M_noA3A4 : MIPModel Unit Unit where
  N        := fun _ _ => 0
  Phi0     := fun _ _ => 0
  K        := fun _ => (∅ : Set Unit)
  demandFamily := fun _ => ({∅} : Set (Set Unit))
  expertKnowledge := fun _ => (∅ : Set Unit)
  Cₑ       := fun _ => 0
  MetaSet  := (∅ : Set (Str Unit))
  tokenReplace := fun _ h => () :: h
  tvDist   := fun _ _ => 1

/-! ## A.1 holds. -/

theorem A1_holds : satisfiesA1 M_noA3A4 := by
  intro p X
  exact ⟨fun _ => rfl, fun _ => rfl⟩

/-! ## A.2 holds. -/

theorem A2_holds : satisfiesA2 M_noA3A4 := by
  intro p X
  refine ⟨fun _ => ⟨∅, rfl, Set.empty_subset _⟩, fun _ => ?_⟩
  show (0 : ℕ∞) ≠ ⊤
  decide

/-! ## A.3 fails. -/

theorem A3_fails : violatesA3 M_noA3A4 := by
  intro hA3
  let X : Agent Unit := fun _ => PMF.pure []
  let e : Str Unit := []
  let h : Str Unit := []
  have hε : (0 : NNReal) < 1/2 := by norm_num
  have hMem : e ∉ M_noA3A4.MetaSet := fun h => h.elim
  have hCover : M_noA3A4.expertKnowledge e ⊆ M_noA3A4.K X :=
    fun _ hx => hx.elim
  obtain ⟨ms, _, hLen, htv⟩ := hA3 X e h (1/2) hε hMem hCover
  have hnil : ms = [] := by
    have hCzero : ((M_noA3A4.Cₑ e : ℝ)) = 0 := by
      show ((0 : NNReal) : ℝ) = 0
      simp
    rw [hCzero, zero_mul] at hLen
    have hzero : ms.length = 0 := by
      have hnn : (0 : ℝ) ≤ (ms.length : ℝ) := by exact_mod_cast Nat.zero_le _
      have heq : (ms.length : ℝ) = 0 := le_antisymm hLen hnn
      exact_mod_cast heq
    exact List.length_eq_zero_iff.mp hzero
  have htv' : (1 : NNReal) ≤ 1/2 := by
    have hreduced : M_noA3A4.tvDist
        (X (extendHist h e))
        (X (extendHist h (ms.foldl List.append []))) = 1 := rfl
    rw [hreduced] at htv
    exact htv
  have hreal : ((1 : NNReal) : ℝ) ≤ ((1/2 : NNReal) : ℝ) := by exact_mod_cast htv'
  simp at hreal
  linarith

/-! ## A.4 fails: identity-on-history agent. -/

theorem A4_fails : violatesA4 M_noA3A4 := by
  intro hA4
  let X₀ : Agent Unit := fun h => PMF.pure h
  have hOut : ((() : Unit)) ∉ M_noA3A4.K X₀ := id
  have heq : X₀ [] = X₀ (M_noA3A4.tokenReplace () []) := hA4 X₀ () [] hOut
  have h1 : (X₀ []) ([] : List Unit) = 1 := PMF.pure_apply_self _
  have h2 : (X₀ (M_noA3A4.tokenReplace () [])) ([] : List Unit) = 0 := by
    show (PMF.pure ([()] : List Unit)) ([] : List Unit) = 0
    apply PMF.pure_apply_of_ne
    intro h
    exact List.cons_ne_nil () [] h.symm
  have hcon : (X₀ []) ([] : List Unit)
                = (X₀ (M_noA3A4.tokenReplace () [])) ([] : List Unit) := by
    rw [heq]
  rw [h1, h2] at hcon
  exact one_ne_zero hcon

theorem pair_A3_A4_independent :
    satisfiesA1 M_noA3A4 ∧ satisfiesA2 M_noA3A4
      ∧ violatesA3 M_noA3A4 ∧ violatesA4 M_noA3A4 :=
  ⟨A1_holds, A2_holds, A3_fails, A4_fails⟩

end R2_Agent10_Model_NoA3A4

end MIP
