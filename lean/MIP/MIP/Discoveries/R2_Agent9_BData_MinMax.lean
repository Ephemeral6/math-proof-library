/-
  STATUS: DISCOVERY
  AGENT: R2-9
  DIRECTION: Minimum / maximum element of `B_data p X` under the
    `s_pre.step` ordering.
  SUMMARY:
    When `(B_data p X).Nonempty` (equivalently `0 < N p X ∧ N p X ≠ ⊤`),
    we identify the unique minimum and maximum elements explicitly:
      * `min` element = `b_synth X p 0` (step value 0)
      * `max` element = `b_synth X p ((N p X).toNat - 1)`
        (step value `(N p X).toNat - 1`)
    These give min and max of `B_data.image stepProj` as 0 and
    `(N p X).toNat - 1` respectively. Stated using `Finset.min'` and
    `Finset.max'` on the step image (a `Finset ℕ`).
-/
import MIP.Axioms
import MIP.Defs.Barriers
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Lattice.Basic
import Mathlib.Data.Finset.Lattice.Fold

namespace MIP

namespace R2_Agent9_BData_MinMax

variable {α : Type}

/-! ## (1) Step image is `Finset.range (N p X).toNat` (re-cite). -/

/-- Local re-statement of Agent 4's step-image identity, used internally. -/
private lemma B_data_step_image (p : Problem α) (X : Agent α) :
    ((B_data p X).image (fun b => b.s_pre.step))
      = Finset.range (N p X).toNat := by
  apply Finset.ext
  intro k
  rw [Finset.mem_image, Finset.mem_range]
  refine ⟨?_, ?_⟩
  · rintro ⟨b, hb, hStep⟩
    unfold B_data at hb
    rw [Finset.mem_image] at hb
    obtain ⟨i, hi, heq⟩ := hb
    rw [Finset.mem_range] at hi
    rw [← heq] at hStep
    have hi_step : (b_synth X p i).s_pre.step = i := rfl
    rw [hi_step] at hStep
    rw [← hStep]; exact hi
  · intro hk
    refine ⟨b_synth X p k, ?_, rfl⟩
    unfold B_data
    rw [Finset.mem_image]
    exact ⟨k, Finset.mem_range.mpr hk, rfl⟩

/-! ## (2) `b_synth X p 0` is the min — step value 0. -/

/-- **`b_synth X p 0 ∈ B_data p X` when nonempty.** -/
theorem b_synth_zero_mem (p : Problem α) (X : Agent α)
    (hNE : (B_data p X).Nonempty) :
    b_synth X p 0 ∈ B_data p X := by
  -- (B_data p X).card = (N p X).toNat ≥ 1
  have hCardEq : (B_data p X).card = (N p X).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
    exact Finset.card_range _
  have hCardPos : 0 < (B_data p X).card := Finset.card_pos.mpr hNE
  rw [hCardEq] at hCardPos
  unfold B_data
  rw [Finset.mem_image]
  exact ⟨0, Finset.mem_range.mpr hCardPos, rfl⟩

/-- **Min of step image is 0.** When `B_data p X` is nonempty, the
minimum value of `s_pre.step` over `B_data p X` is 0. -/
theorem step_min_eq_zero (p : Problem α) (X : Agent α)
    (hNE : (B_data p X).Nonempty) :
    ((B_data p X).image (fun b => b.s_pre.step)).min'
      (hNE.image _) = 0 := by
  -- The image equals Finset.range (N p X).toNat, whose min' is 0.
  have himg : (B_data p X).image (fun b => b.s_pre.step)
      = Finset.range (N p X).toNat := B_data_step_image p X
  -- Need to coordinate the nonempty hypothesis.
  have hRangeNE : (Finset.range (N p X).toNat).Nonempty := by
    rw [← himg]
    exact hNE.image _
  -- Use Finset.min'_eq via equality of finsets.
  -- Strategy: show 0 ∈ image and 0 ≤ everything in the image.
  apply le_antisymm
  · -- min' ≤ 0
    apply Finset.min'_le
    rw [himg, Finset.mem_range]
    -- need 0 < (N p X).toNat
    have hCardEq : (B_data p X).card = (N p X).toNat := by
      unfold B_data
      rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
      exact Finset.card_range _
    have hCardPos : 0 < (B_data p X).card := Finset.card_pos.mpr hNE
    rw [hCardEq] at hCardPos
    exact hCardPos
  · -- 0 ≤ min'
    exact Nat.zero_le _

/-! ## (3) `b_synth X p ((N p X).toNat - 1)` is the max — step value
`(N p X).toNat - 1`. -/

/-- **`b_synth X p ((N p X).toNat - 1) ∈ B_data p X` when nonempty.** -/
theorem b_synth_pred_mem (p : Problem α) (X : Agent α)
    (hNE : (B_data p X).Nonempty) :
    b_synth X p ((N p X).toNat - 1) ∈ B_data p X := by
  have hCardEq : (B_data p X).card = (N p X).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
    exact Finset.card_range _
  have hCardPos : 0 < (B_data p X).card := Finset.card_pos.mpr hNE
  rw [hCardEq] at hCardPos
  unfold B_data
  rw [Finset.mem_image]
  refine ⟨(N p X).toNat - 1, ?_, rfl⟩
  rw [Finset.mem_range]
  omega

/-- **Max of step image is `(N p X).toNat - 1`.** -/
theorem step_max_eq_pred (p : Problem α) (X : Agent α)
    (hNE : (B_data p X).Nonempty) :
    ((B_data p X).image (fun b => b.s_pre.step)).max'
      (hNE.image _) = (N p X).toNat - 1 := by
  have himg : (B_data p X).image (fun b => b.s_pre.step)
      = Finset.range (N p X).toNat := B_data_step_image p X
  have hCardEq : (B_data p X).card = (N p X).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
    exact Finset.card_range _
  have hCardPos : 0 < (B_data p X).card := Finset.card_pos.mpr hNE
  rw [hCardEq] at hCardPos
  apply le_antisymm
  · -- max' ≤ (N p X).toNat - 1
    apply Finset.max'_le
    intro y hy
    rw [himg, Finset.mem_range] at hy
    omega
  · -- (N p X).toNat - 1 ≤ max'
    apply Finset.le_max'
    rw [himg, Finset.mem_range]
    omega

/-! ## (4) The actual min/max barriers in `B_data` as Finset elements. -/

/-! `Finset.min'` / `Finset.max'` operate on a finite ordered type, but
`BarrierData α` has no canonical order. We instead state min/max for
the *step image* (a `Finset ℕ`), and identify the unique barrier whose
step value is min/max as `b_synth X p 0` or `b_synth X p (N.toNat - 1)`. -/

/-- **The barrier with step value 0 is `b_synth X p 0`.** Any barrier
in `B_data p X` whose `s_pre.step` is 0 equals `b_synth X p 0`. -/
theorem step_zero_eq_b_synth_zero
    (p : Problem α) (X : Agent α) {b : BarrierData α}
    (hb : b ∈ B_data p X) (hStep : b.s_pre.step = 0) :
    b = b_synth X p 0 := by
  unfold B_data at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, _, heq⟩ := hb
  rw [← heq] at hStep
  have : (b_synth X p i).s_pre.step = i := rfl
  rw [this] at hStep
  rw [← heq, hStep]

/-- **The barrier with step value `(N p X).toNat - 1` is
`b_synth X p ((N p X).toNat - 1)`.** -/
theorem step_pred_eq_b_synth_pred
    (p : Problem α) (X : Agent α) {b : BarrierData α}
    (hb : b ∈ B_data p X) (hStep : b.s_pre.step = (N p X).toNat - 1) :
    b = b_synth X p ((N p X).toNat - 1) := by
  unfold B_data at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, _, heq⟩ := hb
  rw [← heq] at hStep
  have : (b_synth X p i).s_pre.step = i := rfl
  rw [this] at hStep
  rw [← heq, hStep]

end R2_Agent9_BData_MinMax

end MIP
