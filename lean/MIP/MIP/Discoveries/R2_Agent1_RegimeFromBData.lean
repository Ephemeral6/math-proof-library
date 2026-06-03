/-
  STATUS: DISCOVERY
  AGENT: R2-1
  DIRECTION: Inverse classification — recover the trichotomy regime from
             (B_data status, Phi0 status).
  SUMMARY:
    Agent 2's trichotomy maps the hypothesis (`N = 0` / `0 < N < ⊤` / `N = ⊤`)
    to the consequence (forced facts).  The *reverse* map — from observable
    "downstream" data back to the regime — is also clean once we package
    it.  We prove the three reverse classifications:
      • (B_data ≠ ∅) → regime RP
      • (B_data = ∅ ∧ Phi0 = 0) → regime R0
      • (B_data = ∅ ∧ Phi0 ≠ 0) → regime R∞
    plus a "regime classifier" theorem that branches on the two observable
    flags.  This gives downstream consumers a *decidable-style* check
    even though `N` itself is opaque.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import MIP.Defs.StateSequence

namespace MIP

namespace R2_Agent1_RegimeFromBData

variable {α : Type} {Ω : Type}

/-! ## (1) Reverse: B_data nonempty → RP. -/

/-- **B_data nonempty forces RP**: `0 < N p X ∧ N p X < ⊤`. -/
theorem RP_of_bdata_nonempty
    (p : Problem α) (X : Agent α) (h : (B_data p X).Nonempty) :
    0 < N p X ∧ N p X < ⊤ := by
  have hCardPos : 0 < (B_data p X).card := Finset.card_pos.mpr h
  have hCardEq : (B_data p X).card = (N p X).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
    exact Finset.card_range _
  rw [hCardEq] at hCardPos
  refine ⟨?_, ?_⟩
  · -- 0 < N
    by_contra hLe
    push_neg at hLe
    have hZero : N p X = 0 := le_antisymm hLe bot_le
    rw [hZero] at hCardPos
    simp at hCardPos
  · -- N < ⊤
    refine lt_top_iff_ne_top.mpr ?_
    intro hTop
    rw [hTop] at hCardPos
    simp at hCardPos

/-! ## (2) Reverse: B_data empty + Phi0 = 0 → R0. -/

/-- **B_data empty + Phi0 = 0 forces R0**: `N p X = 0`. -/
theorem R0_of_bdata_empty_phi0_zero
    (p : Problem α) (X : Agent α)
    (_h_emp : B_data p X = ∅) (h_phi : Phi0 X p = 0) :
    N p X = 0 :=
  (Axioms.A1 p X).mpr h_phi

/-! ## (3) Reverse: B_data empty + Phi0 ≠ 0 → R∞. -/

/-- **B_data empty + Phi0 ≠ 0 forces R∞**: `N p X = ⊤`. -/
theorem Rinf_of_bdata_empty_phi0_ne
    (p : Problem α) (X : Agent α)
    (h_emp : B_data p X = ∅) (h_phi : Phi0 X p ≠ 0) :
    N p X = ⊤ := by
  -- B_data = ∅ → (N p X).toNat = 0 → N = 0 ∨ N = ⊤.  Phi0 ≠ 0 rules out N = 0.
  have hCard : (B_data p X).card = 0 := by rw [h_emp]; exact Finset.card_empty
  have hCardEq : (B_data p X).card = (N p X).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
    exact Finset.card_range _
  rw [hCardEq] at hCard
  by_cases hTop : N p X = ⊤
  · exact hTop
  · exfalso
    have hCoe : ((N p X).toNat : ℕ∞) = N p X := ENat.coe_toNat hTop
    rw [hCard, Nat.cast_zero] at hCoe
    -- N = 0, so Phi0 = 0 by A.1, contradicting h_phi.
    exact h_phi ((Axioms.A1 p X).mp hCoe.symm)

/-! ## (4) Master regime classifier. -/

/-- **Master regime classifier.**  From the two observable flags
`(B_data ≠ ∅?, Phi0 ≠ 0?)`, we recover the regime: -/
theorem regime_classifier
    (p : Problem α) (X : Agent α) :
    -- R0 reading
    (B_data p X = ∅ → Phi0 X p = 0 → N p X = 0)
      ∧ -- RP reading
        ((B_data p X).Nonempty → 0 < N p X ∧ N p X < ⊤)
      ∧ -- R∞ reading
        (B_data p X = ∅ → Phi0 X p ≠ 0 → N p X = ⊤) :=
  ⟨R0_of_bdata_empty_phi0_zero p X,
   RP_of_bdata_nonempty p X,
   Rinf_of_bdata_empty_phi0_ne p X⟩

/-! ## (5) Biconditional readings. -/

/-- **R0 biconditional in observable form**:
`N p X = 0 ↔ B_data p X = ∅ ∧ Phi0 X p = 0`. -/
theorem R0_iff_observable (p : Problem α) (X : Agent α) :
    N p X = 0 ↔ (B_data p X = ∅ ∧ Phi0 X p = 0) := by
  refine ⟨?_, ?_⟩
  · intro hN
    refine ⟨?_, (Axioms.A1 p X).mp hN⟩
    unfold B_data; rw [hN]; simp
  · rintro ⟨h_emp, h_phi⟩
    exact R0_of_bdata_empty_phi0_zero p X h_emp h_phi

/-- **R∞ biconditional in observable form**:
`N p X = ⊤ ↔ B_data p X = ∅ ∧ Phi0 X p ≠ 0`. -/
theorem Rinf_iff_observable (p : Problem α) (X : Agent α) :
    N p X = ⊤ ↔ (B_data p X = ∅ ∧ Phi0 X p ≠ 0) := by
  refine ⟨?_, ?_⟩
  · intro hN
    refine ⟨?_, ?_⟩
    · unfold B_data; rw [hN]; simp
    · intro hPhi
      have hN0 : N p X = 0 := (Axioms.A1 p X).mpr hPhi
      rw [hN] at hN0
      exact ENat.top_ne_zero hN0
  · rintro ⟨h_emp, h_phi⟩
    exact Rinf_of_bdata_empty_phi0_ne p X h_emp h_phi

/-- **RP biconditional in observable form**: `0 < N p X ∧ N p X < ⊤
↔ (B_data p X).Nonempty`. -/
theorem RP_iff_observable (p : Problem α) (X : Agent α) :
    (0 < N p X ∧ N p X < ⊤) ↔ (B_data p X).Nonempty := by
  refine ⟨?_, RP_of_bdata_nonempty p X⟩
  rintro ⟨h_pos, h_fin⟩
  have hCardPos : 1 ≤ (B_data p X).card := by
    have hCardEq : (B_data p X).card = (N p X).toNat := by
      unfold B_data
      rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
      exact Finset.card_range _
    rw [hCardEq]
    have hNeTop : N p X ≠ ⊤ := lt_top_iff_ne_top.mp h_fin
    have hCoe : ((N p X).toNat : ℕ∞) = N p X := ENat.coe_toNat hNeTop
    rcases Nat.eq_zero_or_pos (N p X).toNat with hz | hp
    · exfalso
      rw [hz, Nat.cast_zero] at hCoe
      rw [← hCoe] at h_pos
      exact absurd h_pos (by decide)
    · exact hp
  exact Finset.card_pos.mp hCardPos

end R2_Agent1_RegimeFromBData

end MIP
