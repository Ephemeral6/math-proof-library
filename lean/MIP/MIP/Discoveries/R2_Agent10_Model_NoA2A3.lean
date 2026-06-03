/-
  STATUS: DISCOVERY
  AGENT: R2-10
  DIRECTION: Pairwise independence — concrete model violating BOTH A.2
             and A.3 while satisfying A.1 and A.4.
  SUMMARY:
    Build `M_noA2A3 : MIPModel Unit Unit`:
      * `N p X := ⊤`, `Phi0 X p := 1`
        N=0 ↔ Phi0=0 is False ↔ False (TRUE).  →  A.1 holds.
      * `K X := ∅`, `demandFamily p := {∅}`
        N ≠ ⊤ is False, but ∃ R'=∅ ∈ {∅} ⊆ ∅ is True.
        ↔ is False ↔ True.  →  violates A.2.
      * `tokenReplace ω h := h` (identity).  →  A.4 holds (X h = X h).
      * `MetaSet := ∅`, `Cₑ e := 0`, `expertKnowledge e := ∅`,
        `tvDist := fun _ _ => 1`.  Same Cₑ=0+constant-tvDist=1 trick:
        ε := 1/2 forces ms = [] but tvDist = 1 > 1/2 →  violates A.3.

    Conclusion: {A.2, A.3} is pairwise independent of {A.1, A.4}.
-/
import MIP.Discoveries.R2_Agent10_ModelFramework

namespace MIP

namespace R2_Agent10_Model_NoA2A3

open R2_Agent10_ModelFramework
open R2_Agent10_ModelFramework.MIPModel

noncomputable def M_noA2A3 : MIPModel Unit Unit where
  N        := fun _ _ => ⊤
  Phi0     := fun _ _ => 1
  K        := fun _ => (∅ : Set Unit)
  demandFamily := fun _ => ({∅} : Set (Set Unit))
  expertKnowledge := fun _ => (∅ : Set Unit)
  Cₑ       := fun _ => 0
  MetaSet  := (∅ : Set (Str Unit))
  tokenReplace := fun _ h => h
  tvDist   := fun _ _ => 1

/-! ## A.1 holds: both sides False. -/

theorem A1_holds : satisfiesA1 M_noA2A3 := by
  intro p X
  refine ⟨fun h => ?_, fun h => ?_⟩
  · exact (ENat.top_ne_zero (h : (⊤ : ℕ∞) = 0)).elim
  · exact (one_ne_zero (h : (1 : ENNReal) = 0)).elim

/-! ## A.4 holds. -/

theorem A4_holds : satisfiesA4 M_noA2A3 := by
  intro X ω h _; rfl

/-! ## A.2 fails. -/

theorem A2_fails : violatesA2 M_noA2A3 := by
  intro hA2
  let p : Problem Unit := fun _ => true
  let X : Agent Unit := fun _ => PMF.pure []
  have hRHS : ∃ R' ∈ M_noA2A3.demandFamily p, R' ⊆ M_noA2A3.K X :=
    ⟨∅, rfl, Set.empty_subset _⟩
  exact (hA2 p X).mpr hRHS rfl

/-! ## A.3 fails (same Cₑ=0 + constant tvDist trick as M_noA1A3). -/

theorem A3_fails : violatesA3 M_noA2A3 := by
  intro hA3
  let X : Agent Unit := fun _ => PMF.pure []
  let e : Str Unit := []
  let h : Str Unit := []
  have hε : (0 : NNReal) < 1/2 := by norm_num
  have hMem : e ∉ M_noA2A3.MetaSet := fun h => h.elim
  have hCover : M_noA2A3.expertKnowledge e ⊆ M_noA2A3.K X :=
    fun _ hx => hx.elim
  obtain ⟨ms, _, hLen, htv⟩ := hA3 X e h (1/2) hε hMem hCover
  -- Cₑ e = 0 ⟹ ms = [].
  have hnil : ms = [] := by
    have hCzero : ((M_noA2A3.Cₑ e : ℝ)) = 0 := by
      show ((0 : NNReal) : ℝ) = 0
      simp
    rw [hCzero, zero_mul] at hLen
    have hzero : ms.length = 0 := by
      have hnn : (0 : ℝ) ≤ (ms.length : ℝ) := by exact_mod_cast Nat.zero_le _
      have heq : (ms.length : ℝ) = 0 := le_antisymm hLen hnn
      exact_mod_cast heq
    exact List.length_eq_zero_iff.mp hzero
  -- tvDist is constant 1, but ε = 1/2.
  have htv' : (1 : NNReal) ≤ 1/2 := by
    have hreduced : M_noA2A3.tvDist
        (X (extendHist h e))
        (X (extendHist h (ms.foldl List.append []))) = 1 := rfl
    rw [hreduced] at htv
    exact htv
  have hreal : ((1 : NNReal) : ℝ) ≤ ((1/2 : NNReal) : ℝ) := by exact_mod_cast htv'
  simp at hreal
  linarith

theorem pair_A2_A3_independent :
    satisfiesA1 M_noA2A3 ∧ satisfiesA4 M_noA2A3
      ∧ violatesA2 M_noA2A3 ∧ violatesA3 M_noA2A3 :=
  ⟨A1_holds, A4_holds, A2_fails, A3_fails⟩

end R2_Agent10_Model_NoA2A3

end MIP
