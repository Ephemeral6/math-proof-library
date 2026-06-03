/-
  STATUS: DISCOVERY
  AGENT: 4
  DIRECTION: Characterisation of `(B_data p X).Nonempty` in terms of N.
  SUMMARY:
    Agent 2 proved `B_data = ∅ ↔ N = 0 ∨ N = ⊤`. The dual nonempty
    characterisation is also clean:
      `(B_data p X).Nonempty ↔ (0 < N p X ∧ N p X ≠ ⊤)`
    i.e. the positively-emergent regime is exactly when `B_data` carries
    at least one element. We also state the explicit-witness form
    `B_data` always contains `b_synth X p 0` when `N p X ≥ 1`.
-/
import MIP.Axioms
import MIP.Defs.Barriers

namespace MIP

namespace Agent4_BData_Nonempty

variable {α : Type}

/-! ## (1) Nonempty ↔ positively emergent. -/

/-- **`(B_data p X).Nonempty ↔ 0 < N p X ∧ N p X ≠ ⊤`.** Headline
characterisation: `B_data` carries an element iff `(N p X).toNat ≥ 1`,
i.e. `N` is in the strict-interior of `ℕ∞`. -/
theorem B_data_nonempty_iff (p : Problem α) (X : Agent α) :
    (B_data p X).Nonempty ↔ (0 < N p X ∧ N p X ≠ ⊤) := by
  refine ⟨?_, ?_⟩
  · intro hNE
    have hCardPos : 0 < (B_data p X).card := Finset.card_pos.mpr hNE
    -- unfold B_data, the card is at least 1, hence (N p X).toNat ≥ 1
    have hCardEq : (B_data p X).card = (N p X).toNat := by
      unfold B_data
      rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
      exact Finset.card_range _
    rw [hCardEq] at hCardPos
    refine ⟨?_, ?_⟩
    · -- 0 < N p X
      by_contra hLe
      push_neg at hLe
      have hZero : N p X = 0 := le_antisymm hLe bot_le
      rw [hZero] at hCardPos
      simp at hCardPos
    · -- N p X ≠ ⊤
      intro hTop
      rw [hTop] at hCardPos
      simp at hCardPos
  · rintro ⟨hPos, hNeTop⟩
    -- N p X ≥ 1 → (N p X).toNat ≥ 1 → range nonempty → image nonempty
    have hToNatPos : 0 < (N p X).toNat := by
      have hCoe : ((N p X).toNat : ℕ∞) = N p X := ENat.coe_toNat hNeTop
      -- if toNat = 0, then N = 0, contradicting hPos
      rcases Nat.eq_zero_or_pos (N p X).toNat with hz | hp
      · exfalso
        rw [hz, Nat.cast_zero] at hCoe
        rw [← hCoe] at hPos
        exact absurd hPos (by decide)
      · exact hp
    unfold B_data
    have hRangeNE : (Finset.range (N p X).toNat).Nonempty := by
      rw [Finset.nonempty_range_iff]
      omega
    exact Finset.Nonempty.image hRangeNE _

/-! ## (2) Explicit witness: `b_synth X p 0 ∈ B_data` when `N ≥ 1`. -/

/-- When `(N p X).toNat ≥ 1`, the first synthetic barrier `b_synth X p 0`
is a member of `B_data p X`. -/
theorem b_synth_zero_mem_of_N_pos (p : Problem α) (X : Agent α)
    (hPos : 0 < N p X) (hNeTop : N p X ≠ ⊤) :
    b_synth X p 0 ∈ B_data p X := by
  unfold B_data
  rw [Finset.mem_image]
  refine ⟨0, ?_, rfl⟩
  rw [Finset.mem_range]
  have hCoe : ((N p X).toNat : ℕ∞) = N p X := ENat.coe_toNat hNeTop
  rcases Nat.eq_zero_or_pos (N p X).toNat with hz | hp
  · exfalso
    rw [hz, Nat.cast_zero] at hCoe
    rw [← hCoe] at hPos
    exact absurd hPos (by decide)
  · exact hp

/-! ## (3) When `N p X = ↑n` for explicit `n`, the membership criterion. -/

/-- **Membership criterion**: `b_synth X p i ∈ B_data p X ↔ i < (N p X).toNat`. -/
theorem b_synth_mem_B_data_iff (p : Problem α) (X : Agent α) (i : ℕ) :
    b_synth X p i ∈ B_data p X ↔ i < (N p X).toNat := by
  unfold B_data
  rw [Finset.mem_image]
  refine ⟨?_, ?_⟩
  · rintro ⟨j, hj, heq⟩
    rw [Finset.mem_range] at hj
    -- b_synth X p j = b_synth X p i → j = i (by injectivity)
    have : j = i := b_synth_injective X p heq
    rw [← this]; exact hj
  · intro hi
    exact ⟨i, Finset.mem_range.mpr hi, rfl⟩

end Agent4_BData_Nonempty

end MIP
