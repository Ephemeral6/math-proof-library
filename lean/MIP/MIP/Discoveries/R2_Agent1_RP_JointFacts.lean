/-
  STATUS: DISCOVERY
  AGENT: R2-1
  DIRECTION: Regime RP (`0 < N < ⊤ ∧ Phi0 ≠ 0 ∧ coverage`) — joint forced facts.
  SUMMARY:
    Starting from RP's two-sided hypothesis `0 < N p X ∧ N p X < ⊤`, we
    package the *sharper* consequences that hold only in this regime:
      (1) Phi0 X p ≠ 0                                 (A.1 contrapositive)
      (2) (B_data p X).card = (N p X).toNat ≥ 1        (Agent 4 + boundary)
      (3) B_data p X ≠ ∅ (positive card)               (Agent 4)
      (4) b_synth X p 0 ∈ B_data p X                   (Agent 4 witness)
      (5) Phi0 X p * Z X p = 0  but  N p X ≠ 0         — T.8 Ohm FAILS strictly
      (6) ⌈Phi0 · Z⌉ < N p X                            (Agent 5 strict undershoot)
      (7) coverage ∃ R' ∈ ℛ(p), R' ⊆ K X                  (A.2)
    The "headline" RP-specific fact is the *strict* T.8 Ohm undershoot
    `ceilENat (Phi0 * Z) < N`, which neither Agent 5 nor Agent 2 stated
    keyed on the RP hypothesis directly.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import MIP.Defs.StateSequence

namespace MIP

namespace R2_Agent1_RP_JointFacts

variable {α : Type} {Ω : Type}

/-! ## (1) `Phi0 ≠ 0` from `0 < N`. -/

/-- **RP forces `Phi0 ≠ 0`** (A.1 contrapositive on `N ≠ 0`). -/
theorem RP_phi0_ne_zero
    (p : Problem α) (X : Agent α) (h_pos : 0 < N p X) :
    Phi0 X p ≠ 0 := by
  intro hPhi
  have hN0 : N p X = 0 := (Axioms.A1 p X).mpr hPhi
  rw [hN0] at h_pos
  exact absurd h_pos (by decide)

/-! ## (2)–(3) `B_data` card and nonemptiness. -/

/-- **RP `B_data` card formula**: `(B_data p X).card = (N p X).toNat`. -/
theorem RP_bdata_card_eq_toNat
    (p : Problem α) (X : Agent α) :
    (B_data p X).card = (N p X).toNat := by
  unfold B_data
  rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
  exact Finset.card_range _

/-- **RP `B_data` card is positive**: `1 ≤ (B_data p X).card`. -/
theorem RP_bdata_card_pos
    (p : Problem α) (X : Agent α)
    (h_pos : 0 < N p X) (h_fin : N p X < ⊤) :
    1 ≤ (B_data p X).card := by
  rw [RP_bdata_card_eq_toNat]
  have hNeTop : N p X ≠ ⊤ := lt_top_iff_ne_top.mp h_fin
  have hCoe : ((N p X).toNat : ℕ∞) = N p X := ENat.coe_toNat hNeTop
  rcases Nat.eq_zero_or_pos (N p X).toNat with hz | hp
  · exfalso
    rw [hz, Nat.cast_zero] at hCoe
    rw [← hCoe] at h_pos
    exact absurd h_pos (by decide)
  · exact hp

/-- **RP `B_data` non-empty.** -/
theorem RP_bdata_nonempty
    (p : Problem α) (X : Agent α)
    (h_pos : 0 < N p X) (h_fin : N p X < ⊤) :
    (B_data p X).Nonempty :=
  Finset.card_pos.mp (RP_bdata_card_pos p X h_pos h_fin)

/-! ## (4) Explicit witness `b_synth X p 0 ∈ B_data`. -/

/-- **RP `b_synth X p 0 ∈ B_data p X`.** -/
theorem RP_b_synth_zero_mem
    (p : Problem α) (X : Agent α)
    (h_pos : 0 < N p X) (h_fin : N p X < ⊤) :
    b_synth X p 0 ∈ B_data p X := by
  unfold B_data
  rw [Finset.mem_image]
  refine ⟨0, ?_, rfl⟩
  rw [Finset.mem_range]
  have hCardPos : 1 ≤ (B_data p X).card :=
    RP_bdata_card_pos p X h_pos h_fin
  rw [RP_bdata_card_eq_toNat] at hCardPos
  exact hCardPos

/-! ## (5)–(6) T.8 Ohm-law strict failure. -/

/-- **RP: `Phi0 * Z = 0` but `N ≠ 0`** — the T.8 Ohm-law product collapses
to 0 even though `N > 0`. -/
theorem RP_PhiZ_eq_zero_but_N_pos
    (p : Problem α) (X : Agent α)
    (h_pos : 0 < N p X) :
    Phi0 X p * Z X p = 0 ∧ N p X ≠ 0 := by
  refine ⟨?_, ?_⟩
  · show Phi0 X p * (0 : ENNReal) = 0
    exact mul_zero _
  · exact ne_of_gt h_pos

/-- **RP: strict T.8 Ohm undershoot.** `⌈Phi0 · Z⌉ < N p X`. -/
theorem RP_T8_Ohm_strict
    (p : Problem α) (X : Agent α)
    (h_pos : 0 < N p X) :
    ceilENat (Phi0 X p * Z X p) < N p X := by
  show ceilENat (Phi0 X p * (0 : ENNReal)) < N p X
  rw [mul_zero, ceilENat_zero]
  exact h_pos

/-- **RP: T.8 Ohm-law equation FAILS** (`≠` form). -/
theorem RP_T8_Ohm_not_eq
    (p : Problem α) (X : Agent α)
    (h_pos : 0 < N p X) :
    N p X ≠ ceilENat (Phi0 X p * Z X p) := by
  intro heq
  have hLt : ceilENat (Phi0 X p * Z X p) < N p X := RP_T8_Ohm_strict p X h_pos
  rw [heq] at hLt
  exact lt_irrefl _ hLt

/-! ## (7) Coverage. -/

/-- **RP forces coverage** (A.2.mp). -/
theorem RP_coverage
    (p : Problem α) (X : Agent α) (h_fin : N p X < ⊤) :
    ∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω) := by
  have hNeTop : N p X ≠ ⊤ := lt_top_iff_ne_top.mp h_fin
  exact (Axioms.A2 (Ω := Ω) p X).mp hNeTop

/-! ## Headline bundle. -/

/-- **RP joint bundle.**  All seven forced facts in one statement. -/
theorem RP_bundle
    (p : Problem α) (X : Agent α)
    (h_pos : 0 < N p X) (h_fin : N p X < ⊤) :
    Phi0 X p ≠ 0
      ∧ (B_data p X).card = (N p X).toNat
      ∧ 1 ≤ (B_data p X).card
      ∧ (B_data p X).Nonempty
      ∧ b_synth X p 0 ∈ B_data p X
      ∧ ceilENat (Phi0 X p * Z X p) < N p X
      ∧ N p X ≠ ceilENat (Phi0 X p * Z X p)
      ∧ (∃ R' ∈ (demandFamily p : Set (Set Ω)), R' ⊆ (K X : Set Ω)) :=
  ⟨RP_phi0_ne_zero p X h_pos,
   RP_bdata_card_eq_toNat p X,
   RP_bdata_card_pos p X h_pos h_fin,
   RP_bdata_nonempty p X h_pos h_fin,
   RP_b_synth_zero_mem p X h_pos h_fin,
   RP_T8_Ohm_strict p X h_pos,
   RP_T8_Ohm_not_eq p X h_pos,
   RP_coverage (Ω := Ω) p X h_fin⟩

end R2_Agent1_RP_JointFacts

end MIP
