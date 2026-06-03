/-
  STATUS: DISCOVERY
  AGENT: R2-10
  DIRECTION: Pairwise independence — concrete model violating BOTH A.1
             and A.4 while satisfying A.2 and A.3.
  SUMMARY:
    Build `M_noA1A4 : MIPModel Unit Unit` with the choices:
      * `N p X := 0`             (always)
      * `Phi0 X p := 1`           (always)        →  violates A.1
      * `K X := ∅`                (no knowledge)
      * `demandFamily p := {∅}`   →  A.2's RHS holds vacuously (∅ ⊆ ∅).
        Since `N := 0 ≠ ⊤`, both sides of A.2 are True; A.2 holds.
      * `MetaSet := Set.univ`     →  A.3 vacuous (e ∉ univ False).
      * `tokenReplace ω h := () :: h`  (prepend)
        For the identity-on-histories agent `X₀ h := PMF.pure h`,
        we have `X₀ [] = pure []` and `X₀ (() :: []) = pure [()]`,
        which are distinct PMFs. Since `K X₀ = ∅`, ω ∉ K X₀ for every ω,
        so A.4's hypothesis triggers but the conclusion fails. →  violates A.4.

    Result: A.2 ∧ A.3 holds, A.1 ∧ A.4 fails. Hence {A.1, A.4} is
    pairwise independent of {A.2, A.3}.
-/
import MIP.Discoveries.R2_Agent10_ModelFramework

namespace MIP

namespace R2_Agent10_Model_NoA1A4

open R2_Agent10_ModelFramework
open R2_Agent10_ModelFramework.MIPModel

/-- The model. -/
noncomputable def M_noA1A4 : MIPModel Unit Unit where
  N        := fun _ _ => 0
  Phi0     := fun _ _ => 1
  K        := fun _ => (∅ : Set Unit)
  demandFamily := fun _ => ({∅} : Set (Set Unit))
  expertKnowledge := fun _ => (∅ : Set Unit)
  Cₑ       := fun _ => 0
  MetaSet  := (Set.univ : Set (Str Unit))
  tokenReplace := fun _ h => () :: h
  tvDist   := fun _ _ => 0

/-! ## A.2 holds: N = 0 ≠ ⊤, and ∅ ∈ {∅}, ∅ ⊆ ∅. -/

theorem A2_holds : satisfiesA2 M_noA1A4 := by
  intro p X
  constructor
  · intro _
    refine ⟨∅, ?_, Set.empty_subset _⟩
    -- ∅ ∈ {∅}
    exact rfl
  · intro _
    -- N = 0 ≠ ⊤
    show (0 : ℕ∞) ≠ ⊤
    decide

/-! ## A.3 holds (vacuous via MetaSet = univ). -/

theorem A3_holds : satisfiesA3 M_noA1A4 := by
  intro X e h ε hε hMem _
  exact (hMem (Set.mem_univ e)).elim

/-! ## A.1 fails: N = 0, Phi0 = 1 ≠ 0. -/

theorem A1_fails : violatesA1 M_noA1A4 := by
  intro hA1
  have h := (hA1 (fun _ => true) (fun _ => PMF.pure [])).mp rfl
  exact one_ne_zero h

/-! ## A.4 fails: the identity agent on `Unit`-strings distinguishes
the empty history from `[()]`. -/

theorem A4_fails : violatesA4 M_noA1A4 := by
  intro hA4
  -- the identity-on-history agent
  let X₀ : Agent Unit := fun h => PMF.pure h
  -- ω = ()
  -- ω ∉ K X₀ = ∅
  have hOut : ((() : Unit)) ∉ M_noA1A4.K X₀ := by
    show ((() : Unit)) ∉ (∅ : Set Unit)
    exact id
  -- The model says X₀ [] = X₀ (() :: [])  but pure [] ≠ pure [()].
  have heq : X₀ [] = X₀ (M_noA1A4.tokenReplace () []) := hA4 X₀ () [] hOut
  -- show this is a contradiction
  -- Evaluate both PMFs at `[] : List Unit`.
  have h1 : (X₀ []) ([] : List Unit) = 1 := PMF.pure_apply_self _
  have h2 : (X₀ (M_noA1A4.tokenReplace () [])) ([] : List Unit) = 0 := by
    -- M_noA1A4.tokenReplace () [] = [()]
    -- X₀ [()] = PMF.pure [()]
    -- pure [()] [] = 0 since [] ≠ [()]
    show (PMF.pure ([()] : List Unit)) ([] : List Unit) = 0
    apply PMF.pure_apply_of_ne
    intro h
    exact List.cons_ne_nil () [] h.symm
  have hcon : (X₀ []) ([] : List Unit)
                = (X₀ (M_noA1A4.tokenReplace () [])) ([] : List Unit) := by
    rw [heq]
  rw [h1, h2] at hcon
  exact one_ne_zero hcon

/-! ## Headline: {A.1, A.4} is independent of {A.2, A.3}. -/

theorem pair_A1_A4_independent :
    satisfiesA2 M_noA1A4 ∧ satisfiesA3 M_noA1A4
      ∧ violatesA1 M_noA1A4 ∧ violatesA4 M_noA1A4 :=
  ⟨A2_holds, A3_holds, A1_fails, A4_fails⟩

end R2_Agent10_Model_NoA1A4

end MIP
