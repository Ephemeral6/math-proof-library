/-
  STATUS: DISCOVERY
  AGENT: R2-10
  DIRECTION: Pairwise independence — concrete model violating BOTH A.1
             and A.3 while satisfying A.2 and A.4.
  SUMMARY:
    Build `M_noA1A3 : MIPModel Unit Unit`:
      * `N p X := 0`              (always)
      * `Phi0 X p := 1`            (always)        →  violates A.1
      * `K X := ∅`, `demandFamily p := {∅}`  →  A.2 holds (both sides True).
      * `tokenReplace ω h := h`   (identity)        →  A.4 holds (X h = X h).
      * `MetaSet := ∅`             (no meta-cognitive interventions)
      * `Cₑ e := 0`                (zero density)
      * `expertKnowledge e := ∅`   (no knowledge content)
      * `tvDist := fun _ _ => 1`    (always distance 1)

    A.3 violation: pick ε := 1/2, any X, e, h. Hypotheses
      e ∉ ∅ (True), expertKnowledge e ⊆ K X (∅ ⊆ ∅ True).
    Bound `(ms.length : ℝ) ≤ Cₑ(e) · log(1/ε) = 0 · log 2 = 0` forces
    `ms = []`. Then `tvDist ... = 1 > 1/2 = ε`, so the tvDist clause
    fails. Hence A.3's existential has no witness — A.3 violated.

    Conclusion: {A.1, A.3} is pairwise independent of {A.2, A.4}.
-/
import MIP.Discoveries.R2_Agent10_ModelFramework

namespace MIP

namespace R2_Agent10_Model_NoA1A3

open R2_Agent10_ModelFramework
open R2_Agent10_ModelFramework.MIPModel

/-- The model. -/
noncomputable def M_noA1A3 : MIPModel Unit Unit where
  N        := fun _ _ => 0
  Phi0     := fun _ _ => 1
  K        := fun _ => (∅ : Set Unit)
  demandFamily := fun _ => ({∅} : Set (Set Unit))
  expertKnowledge := fun _ => (∅ : Set Unit)
  Cₑ       := fun _ => 0
  MetaSet  := (∅ : Set (Str Unit))
  tokenReplace := fun _ h => h
  tvDist   := fun _ _ => 1

/-! ## A.2 holds: N=0 ≠ ⊤, ∃ R'=∅ ∈ {∅}, R' ⊆ ∅. -/

theorem A2_holds : satisfiesA2 M_noA1A3 := by
  intro p X
  refine ⟨fun _ => ⟨∅, rfl, Set.empty_subset _⟩, fun _ => ?_⟩
  show (0 : ℕ∞) ≠ ⊤
  decide

/-! ## A.4 holds: tokenReplace is the identity. -/

theorem A4_holds : satisfiesA4 M_noA1A3 := by
  intro X ω h _; rfl

/-! ## A.1 fails: N=0 but Phi0=1≠0. -/

theorem A1_fails : violatesA1 M_noA1A3 := by
  intro hA1
  have h := (hA1 (fun _ => true) (fun _ => PMF.pure [])).mp rfl
  exact one_ne_zero h

/-! ## A.3 fails: ε = 1/2 gives no ms with length ≤ 0 and tvDist ≤ 1/2. -/

theorem A3_fails : violatesA3 M_noA1A3 := by
  intro hA3
  -- Choose any agent / problem-history.
  let X : Agent Unit := fun _ => PMF.pure []
  let e : Str Unit := []
  let h : Str Unit := []
  -- ε = 1/2 : NNReal
  have hε : (0 : NNReal) < 1/2 := by norm_num
  have hMem : e ∉ M_noA1A3.MetaSet := by
    intro h; exact h.elim
  have hCover : M_noA1A3.expertKnowledge e ⊆ M_noA1A3.K X := by
    intro x hx; exact hx.elim
  obtain ⟨ms, hAllMeta, hLen, htv⟩ := hA3 X e h (1/2) hε hMem hCover
  -- Cₑ e = 0, so the bound is 0.
  -- Cₑ e = 0, so the bound is 0 ⟹ ms = [].
  have hnil : ms = [] := by
    have hCzero : ((M_noA1A3.Cₑ e : ℝ)) = 0 := by
      show ((0 : NNReal) : ℝ) = 0
      simp
    rw [hCzero, zero_mul] at hLen
    have hzero : ms.length = 0 := by
      have hnn : (0 : ℝ) ≤ (ms.length : ℝ) := by exact_mod_cast Nat.zero_le _
      have heq : (ms.length : ℝ) = 0 := le_antisymm hLen hnn
      exact_mod_cast heq
    exact List.length_eq_zero_iff.mp hzero
  -- tvDist of the two PMFs is constant 1, which is not ≤ 1/2.
  -- The model's tvDist returns 1 for everything.
  have htv' : (1 : NNReal) ≤ 1/2 := by
    -- M_noA1A3.tvDist _ _ = 1 by definition, ms = [] so the equation reduces.
    have hreduced : M_noA1A3.tvDist
        (X (extendHist h e))
        (X (extendHist h (ms.foldl List.append []))) = 1 := rfl
    rw [hreduced] at htv
    exact htv
  -- 1 ≤ 1/2 contradicts 1/2 < 1.
  have hreal : ((1 : NNReal) : ℝ) ≤ ((1/2 : NNReal) : ℝ) := by exact_mod_cast htv'
  simp at hreal
  linarith

/-! ## Headline. -/

theorem pair_A1_A3_independent :
    satisfiesA2 M_noA1A3 ∧ satisfiesA4 M_noA1A3
      ∧ violatesA1 M_noA1A3 ∧ violatesA3 M_noA1A3 :=
  ⟨A2_holds, A4_holds, A1_fails, A3_fails⟩

end R2_Agent10_Model_NoA1A3

end MIP
