/-
  STATUS: DISCOVERY
  AGENT: R2-10
  DIRECTION: Pairwise independence — concrete model violating BOTH A.1
             and A.2 while satisfying A.3 and A.4.
  SUMMARY:
    Build `M_noA1A2 : MIPModel Unit Unit` explicitly:
      * `N p X := 0`         (always zero)
      * `Phi0 X p := 1`       (always nonzero)   →  violates A.1
      * `K X := ∅`            (no knowledge)
      * `demandFamily p := ∅` (no admissible explanation) →  violates A.2
        because N p X = 0 ≠ ⊤ but no demand witness exists.
      * `MetaSet := Set.univ`  →  e ∉ MetaSet is False, A.3 vacuous.
      * `K X := ∅` means `ω ∉ K X` is True for all ω, but the conclusion
        of A.4 is the agent equation; we satisfy it by choosing `tokenReplace
        ω h := h` (identity), so `X h = X h` trivially.

    Therefore `M_noA1A2` satisfies A.3 and A.4 and violates A.1 and A.2.
    Hence the conjunction (A.3 ∧ A.4) does NOT imply (A.1 ∨ A.2):
    A.1 and A.2 are jointly independent of {A.3, A.4}.
-/
import MIP.Discoveries.R2_Agent10_ModelFramework

namespace MIP

namespace R2_Agent10_Model_NoA1A2

open R2_Agent10_ModelFramework
open R2_Agent10_ModelFramework.MIPModel

/-- The concrete model: `α = Unit`, `Ω = Unit`. -/
noncomputable def M_noA1A2 : MIPModel Unit Unit where
  N        := fun _ _ => 0
  Phi0     := fun _ _ => 1
  K        := fun _ => (∅ : Set Unit)
  demandFamily := fun _ => (∅ : Set (Set Unit))
  expertKnowledge := fun _ => (∅ : Set Unit)
  Cₑ       := fun _ => 0
  MetaSet  := (Set.univ : Set (Str Unit))
  tokenReplace := fun _ h => h
  tvDist   := fun _ _ => 0

/-! ## A.3 holds (vacuously: MetaSet = univ means no `e ∉ MetaSet`). -/

theorem A3_holds : satisfiesA3 M_noA1A2 := by
  intro X e h ε hε hMem _
  -- `hMem : e ∉ Set.univ` is impossible.
  exact (hMem (Set.mem_univ e)).elim

/-! ## A.4 holds (tokenReplace is identity, so X h = X h). -/

theorem A4_holds : satisfiesA4 M_noA1A2 := by
  intro X ω h _
  -- `tokenReplace ω h := h` in this model.
  rfl

/-! ## A.1 fails: N=0 but Phi0=1≠0. -/

theorem A1_fails : violatesA1 M_noA1A2 := by
  intro hA1
  -- specialise at the always-true problem and a default agent
  have h := (hA1 (fun _ => true) (fun _ => PMF.pure [])).mp rfl
  -- `h : (1 : ENNReal) = 0`
  exact one_ne_zero h

/-! ## A.2 fails: N = 0 ≠ ⊤ but demandFamily is empty, no R'. -/

theorem A2_fails : violatesA2 M_noA1A2 := by
  intro hA2
  -- specialise; N _ _ = 0 ≠ ⊤
  have hne : M_noA1A2.N (fun _ => true) (fun _ => PMF.pure []) ≠ ⊤ := by
    show (0 : ℕ∞) ≠ ⊤
    decide
  obtain ⟨R', hR'mem, _⟩ := (hA2 (fun _ => true) (fun _ => PMF.pure [])).mp hne
  -- hR'mem : R' ∈ (∅ : Set (Set Unit))
  exact hR'mem.elim

/-! ## Headline: the pair {A.1, A.2} is independent of {A.3, A.4}. -/

theorem pair_A1_A2_independent :
    satisfiesA3 M_noA1A2 ∧ satisfiesA4 M_noA1A2
      ∧ violatesA1 M_noA1A2 ∧ violatesA2 M_noA1A2 :=
  ⟨A3_holds, A4_holds, A1_fails, A2_fails⟩

end R2_Agent10_Model_NoA1A2

end MIP
