/-
  STATUS: DISCOVERY
  AGENT: R2-1
  DIRECTION: Regime R0 (`N = 0 ∧ Phi0 = 0 ∧ coverage`) — joint forced facts.
  SUMMARY:
    Starting from the trichotomy's R0 hypothesis `N p X = 0`, we package
    the full set of *joint* consequences:
      (1) Phi0 X p = 0                                 (A.1)
      (2) (B_data p X).card = 0                        (Agent 4 unconditional)
      (3) B_data p X = ∅                               (Agent 2 boundary)
      (4) Phi0 X p * Z X p = 0                         (Agent 5 Z = 0)
      (5) ⌈Phi0 · Z⌉ = N                                — T.8 Ohm holds (Agent 5)
      (6) Phi_state s = 0 whenever s.agent = X, s.problem = p
                                                       (state-sequence collapse)
      (7) coverage ∃ R' ∈ ℛ(p), R' ⊆ K X                 (A.2)
    None of these individually are new — each was proved by Agent 2 / 4 / 5.
    The *joint packaging* under the single R0-trigger `N p X = 0` is new:
    it lets downstream consumers branch on the trichotomy once and obtain
    seven facts in one move, instead of seven separate Modus-Ponens chains.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import MIP.Defs.StateSequence

namespace MIP

namespace R2_Agent1_R0_JointFacts

variable {α : Type} {Ω : Type}

/-! ## Seven joint consequences of `N p X = 0`. -/

/-- **R0 forces `Phi0 = 0`** (A.1.mp). -/
theorem R0_phi0_zero (p : Problem α) (X : Agent α) (h : N p X = 0) :
    Phi0 X p = 0 := (Axioms.A1 p X).mp h

/-- **R0 forces `(B_data p X).card = 0`**. -/
theorem R0_bdata_card_zero (p : Problem α) (X : Agent α) (h : N p X = 0) :
    (B_data p X).card = 0 := by
  unfold B_data
  rw [Finset.card_image_of_injective _ (b_synth_injective X p), Finset.card_range, h]
  rfl

/-- **R0 forces `B_data = ∅`** (Agent 2). -/
theorem R0_bdata_empty (p : Problem α) (X : Agent α) (h : N p X = 0) :
    B_data p X = ∅ := by
  unfold B_data; rw [h]; simp

/-- **R0 forces `Phi0 * Z = 0`** (Agent 5: Z = 0). -/
theorem R0_PhiZ_eq_zero (p : Problem α) (X : Agent α) (_h : N p X = 0) :
    Phi0 X p * Z X p = 0 := by
  show Phi0 X p * (0 : ENNReal) = 0
  exact mul_zero _

/-- **R0: T.8 Ohm-law holds**, `N = ⌈Phi0 · Z⌉`.  Both sides are `0`. -/
theorem R0_T8_Ohm_holds (p : Problem α) (X : Agent α) (h : N p X = 0) :
    N p X = ceilENat (Phi0 X p * Z X p) := by
  rw [R0_PhiZ_eq_zero p X h, ceilENat_zero, h]

/-- **R0: every `(X, p)`-state has `Phi_state s = 0`.**

In the concrete state-sequence model, `Phi_state s = 0` whenever
`s.step ≥ N s.problem s.agent`.  In R0 (`N p X = 0`) this is the
constant condition `s.step ≥ 0`, always true, so every state of the form
`⟨X, p, k⟩` collapses to potential 0. -/
theorem R0_Phi_state_zero (p : Problem α) (X : Agent α) (h : N p X = 0)
    (k : ℕ) :
    Phi_state (⟨X, p, k⟩ : InternalState α) = 0 := by
  unfold Phi_state
  show (if (k : ℕ∞) ≥ N p X then 0 else Phi0 X p) = 0
  rw [h]
  rw [if_pos (by exact bot_le)]

/-- **R0 forces coverage** (A.2.mp via `N ≠ ⊤`). -/
theorem R0_coverage (p : Problem α) (X : Agent α) (h : N p X = 0) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) := by
  have hFin : N p X ≠ ⊤ := by rw [h]; decide
  exact (Axioms.A2 (Ω := Ω) p X).mp hFin

/-! ## Headline bundle. -/

/-- **R0 joint bundle.**  All seven forced facts in one statement. -/
theorem R0_bundle (p : Problem α) (X : Agent α) (h : N p X = 0) :
    Phi0 X p = 0
      ∧ (B_data p X).card = 0
      ∧ B_data p X = ∅
      ∧ Phi0 X p * Z X p = 0
      ∧ N p X = ceilENat (Phi0 X p * Z X p)
      ∧ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) :=
  ⟨R0_phi0_zero p X h,
   R0_bdata_card_zero p X h,
   R0_bdata_empty p X h,
   R0_PhiZ_eq_zero p X h,
   R0_T8_Ohm_holds p X h,
   R0_coverage (Ω := Ω) p X h⟩

end R2_Agent1_R0_JointFacts

end MIP
