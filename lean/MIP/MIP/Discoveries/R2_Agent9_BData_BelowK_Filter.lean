/-
  STATUS: DISCOVERY
  AGENT: R2-9
  DIRECTION: Subset of `B_data p X` whose step is below a threshold `k`.
  SUMMARY:
    Define `B_data_below_k p X k = (B_data p X).filter (fun b => b.s_pre.step < k)`.
    Two equivalent representations:
      * As an image of `Finset.range (min k (N p X).toNat)` under `b_synth X p`.
      * As a `Finset` of cardinality `min k (N p X).toNat`.
    Plus monotonicity in `k`, and the boundary cases `k = 0` (empty) and
    `k ≥ (N p X).toNat` (whole `B_data`).
-/
import MIP.Axioms
import MIP.Defs.Barriers
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Image
import Mathlib.Data.Finset.Filter

namespace MIP

namespace R2_Agent9_BData_BelowK_Filter

variable {α : Type}

/-! ## (1) The filtered subset. -/

/-- **`B_data` truncated at step `< k`**: members of `B_data p X` whose
`s_pre.step` is less than `k`. -/
noncomputable def B_data_below_k (p : Problem α) (X : Agent α) (k : ℕ) :
    Finset (BarrierData α) :=
  (B_data p X).filter (fun b => b.s_pre.step < k)

/-! ## (2) Characterisation as image of `Finset.range (min k (N p X).toNat)`. -/

/-- **Image representation.** `B_data_below_k p X k` equals the image of
`Finset.range (min k (N p X).toNat)` under `b_synth X p`. -/
theorem B_data_below_k_eq_image (p : Problem α) (X : Agent α) (k : ℕ) :
    B_data_below_k p X k
      = (Finset.range (min k (N p X).toNat)).image (b_synth X p) := by
  apply Finset.ext
  intro b
  rw [B_data_below_k, Finset.mem_filter, Finset.mem_image]
  constructor
  · rintro ⟨hbMem, hbStep⟩
    -- b ∈ B_data p X ⟹ b = b_synth X p i for i < (N p X).toNat
    unfold B_data at hbMem
    rw [Finset.mem_image] at hbMem
    obtain ⟨i, hi, heq⟩ := hbMem
    rw [Finset.mem_range] at hi
    refine ⟨i, ?_, heq⟩
    rw [Finset.mem_range]
    -- need i < min k (N p X).toNat
    -- We have i < (N p X).toNat and (b_synth X p i).s_pre.step = i < k
    rw [← heq] at hbStep
    have hi_step : (b_synth X p i).s_pre.step = i := rfl
    rw [hi_step] at hbStep
    exact lt_min hbStep hi
  · rintro ⟨i, hi, heq⟩
    rw [Finset.mem_range] at hi
    have hi_lt_k : i < k := lt_of_lt_of_le hi (min_le_left _ _)
    have hi_lt_N : i < (N p X).toNat := lt_of_lt_of_le hi (min_le_right _ _)
    refine ⟨?_, ?_⟩
    · -- b ∈ B_data p X
      unfold B_data
      rw [Finset.mem_image]
      exact ⟨i, Finset.mem_range.mpr hi_lt_N, heq⟩
    · -- b.s_pre.step < k
      rw [← heq]
      have : (b_synth X p i).s_pre.step = i := rfl
      rw [this]
      exact hi_lt_k

/-! ## (3) Cardinality. -/

/-- **Cardinality of the truncation.** `(B_data_below_k p X k).card =
min k (N p X).toNat`. -/
theorem B_data_below_k_card (p : Problem α) (X : Agent α) (k : ℕ) :
    (B_data_below_k p X k).card = min k (N p X).toNat := by
  rw [B_data_below_k_eq_image]
  rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
  exact Finset.card_range _

/-! ## (4) Monotonicity in `k`. -/

/-- **Monotonicity in `k`.** If `k ≤ k'`, then
`B_data_below_k p X k ⊆ B_data_below_k p X k'`. -/
theorem B_data_below_k_mono (p : Problem α) (X : Agent α) {k k' : ℕ}
    (hk : k ≤ k') :
    B_data_below_k p X k ⊆ B_data_below_k p X k' := by
  intro b hb
  rw [B_data_below_k, Finset.mem_filter] at hb ⊢
  exact ⟨hb.1, lt_of_lt_of_le hb.2 hk⟩

/-! ## (5) Boundary cases. -/

/-- **At `k = 0`, the truncation is empty.** -/
theorem B_data_below_k_zero (p : Problem α) (X : Agent α) :
    B_data_below_k p X 0 = ∅ := by
  rw [B_data_below_k_eq_image]
  -- min 0 (N p X).toNat = 0, so range = ∅, image = ∅
  have : min 0 (N p X).toNat = 0 := Nat.zero_min _
  rw [this]
  simp

/-- **At `k ≥ (N p X).toNat`, the truncation is all of `B_data`.** -/
theorem B_data_below_k_full (p : Problem α) (X : Agent α) {k : ℕ}
    (hk : (N p X).toNat ≤ k) :
    B_data_below_k p X k = B_data p X := by
  rw [B_data_below_k_eq_image]
  have : min k (N p X).toNat = (N p X).toNat := min_eq_right hk
  rw [this]
  rfl

/-! ## (6) Decomposition: B_data = below_k ∪ at_least_k. -/

/-- **Complement decomposition.** `B_data p X = B_data_below_k p X k ∪
((B_data p X).filter (fun b => k ≤ b.s_pre.step))`. -/
theorem B_data_below_k_complement (p : Problem α) (X : Agent α) (k : ℕ) :
    B_data p X
      = B_data_below_k p X k
        ∪ (B_data p X).filter (fun b => k ≤ b.s_pre.step) := by
  apply Finset.ext
  intro b
  rw [B_data_below_k, Finset.mem_union, Finset.mem_filter, Finset.mem_filter]
  constructor
  · intro hb
    rcases lt_or_ge b.s_pre.step k with h | h
    · exact Or.inl ⟨hb, h⟩
    · exact Or.inr ⟨hb, h⟩
  · rintro (⟨h, _⟩ | ⟨h, _⟩) <;> exact h

end R2_Agent9_BData_BelowK_Filter

end MIP
