/-
  STATUS: DISCOVERY
  AGENT: R2-2
  DIRECTION: Precise intersection identification: the image of
    `agentSwapStep Y p` over `B_data p X` intersected with `B_data p Y`
    equals exactly `commonPrefix p Y X`, and its cardinality is exactly
    `min(N_X.toNat, N_Y.toNat)`.
  SUMMARY:
    Refines the rough "card ≤ min" bound from
    `R2_Agent2_AgentSwap_InjOn_Unconditional` to an EQUALITY. The image
    of B_data p X under the swap, intersected with B_data p Y, is
    exactly the common-prefix-Y-X set. Headline:
      `((B_data p X).image (agentSwapStep Y p)) ∩ B_data p Y = commonPrefix p Y X`
    and its cardinality is `min N_X.toNat N_Y.toNat` (exact equality).
    This is the tight version of the embedding-card bound.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import MIP.Discoveries.R2_Agent2_CommonPrefix
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Image

namespace MIP

namespace R2_Agent2_Intersection_Bijection

open R2_Agent2_CommonPrefix

variable {α : Type}

/-! ## (1) Image lies in `B_data p Y`-or-outside characterisation. -/

/-- **Image characterisation**: an element of
`(B_data p X).image (agentSwapStep Y p)` has the form `b_synth Y p i`
for some `i < (N p X).toNat`. -/
theorem mem_image_iff
    (p : Problem α) (X Y : Agent α) (b : BarrierData α) :
    b ∈ (B_data p X).image (agentSwapStep Y p)
      ↔ ∃ i < (N p X).toNat, b = b_synth Y p i := by
  rw [Finset.mem_image]
  constructor
  · rintro ⟨b₀, hb₀, hEq⟩
    unfold B_data at hb₀
    rw [Finset.mem_image] at hb₀
    obtain ⟨i, hi, hb₀Eq⟩ := hb₀
    rw [Finset.mem_range] at hi
    refine ⟨i, hi, ?_⟩
    unfold agentSwapStep at hEq
    rw [← hb₀Eq] at hEq
    have hStep : (b_synth X p i).s_pre.step = i := rfl
    rw [hStep] at hEq
    exact hEq.symm
  · rintro ⟨i, hi, hEq⟩
    refine ⟨b_synth X p i, ?_, ?_⟩
    · unfold B_data
      rw [Finset.mem_image]
      exact ⟨i, Finset.mem_range.mpr hi, rfl⟩
    · unfold agentSwapStep
      have hStep : (b_synth X p i).s_pre.step = i := rfl
      rw [hStep]
      exact hEq.symm

/-! ## (2) Headline equality: intersection equals commonPrefix p Y X. -/

/-- **HEADLINE**: `((B_data p X).image (agentSwapStep Y p)) ∩ B_data p Y
= commonPrefix p Y X`. -/
theorem swap_image_inter_B_data_Y_eq_commonPrefix
    (p : Problem α) (X Y : Agent α) :
    ((B_data p X).image (agentSwapStep Y p)) ∩ B_data p Y
      = commonPrefix p Y X := by
  ext b
  rw [Finset.mem_inter, mem_image_iff]
  constructor
  · rintro ⟨⟨i, hiX, hEq⟩, hbY⟩
    -- b = b_synth Y p i, and b ∈ B_data p Y ⟹ i < N_Y.toNat.
    rw [hEq] at hbY
    unfold B_data at hbY
    rw [Finset.mem_image] at hbY
    obtain ⟨j, hj, hjEq⟩ := hbY
    rw [Finset.mem_range] at hj
    have hji : j = i := b_synth_injective Y p hjEq
    -- Now i (=j) < N_Y.toNat and i < N_X.toNat.
    unfold commonPrefix
    rw [Finset.mem_image]
    refine ⟨i, ?_, hEq.symm⟩
    rw [Finset.mem_range, lt_min_iff]
    refine ⟨?_, hiX⟩
    rw [← hji]; exact hj
  · intro hb
    unfold commonPrefix at hb
    rw [Finset.mem_image] at hb
    obtain ⟨i, hi, hEq⟩ := hb
    rw [Finset.mem_range, lt_min_iff] at hi
    obtain ⟨hiY, hiX⟩ := hi
    refine ⟨⟨i, hiX, hEq.symm⟩, ?_⟩
    rw [← hEq]
    unfold B_data
    rw [Finset.mem_image]
    exact ⟨i, Finset.mem_range.mpr hiY, rfl⟩

/-! ## (3) Cardinality consequence: exact equality. -/

/-- **Exact card**: the intersection has cardinality EXACTLY
`min(N_X.toNat, N_Y.toNat)`. -/
theorem swap_image_inter_B_data_Y_card_eq
    (p : Problem α) (X Y : Agent α) :
    (((B_data p X).image (agentSwapStep Y p)) ∩ (B_data p Y)).card
      = min (N p X).toNat (N p Y).toNat := by
  rw [swap_image_inter_B_data_Y_eq_commonPrefix, commonPrefix_card]
  exact Nat.min_comm _ _

/-! ## (4) The full image of B_data p X under swap has card = N_X.toNat. -/

/-- **Image total card**: `((B_data p X).image (agentSwapStep Y p)).card
= (N p X).toNat`. -/
theorem swap_image_card
    (p : Problem α) (X Y : Agent α) :
    ((B_data p X).image (agentSwapStep Y p)).card = (N p X).toNat := by
  rw [Finset.card_image_of_injOn]
  · unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
    exact Finset.card_range _
  · intro b₁ hb₁ b₂ hb₂ hEq
    -- Direct InjOn proof using the same machinery.
    unfold B_data at hb₁ hb₂
    rw [Finset.coe_image, Set.mem_image] at hb₁ hb₂
    obtain ⟨i, _, hi⟩ := hb₁
    obtain ⟨j, _, hj⟩ := hb₂
    unfold agentSwapStep at hEq
    rw [← hi, ← hj] at hEq
    have hi_step : (b_synth X p i).s_pre.step = i := rfl
    have hj_step : (b_synth X p j).s_pre.step = j := rfl
    rw [hi_step, hj_step] at hEq
    have hij : i = j := b_synth_injective Y p hEq
    rw [← hi, ← hj, hij]

/-! ## (5) "Hole" characterisation: how much of the image is outside
B_data p Y. -/

/-- **Outside-card**: when `N p X > N p Y` (on `.toNat`), the swap image
has `(N p X).toNat - (N p Y).toNat` elements outside `B_data p Y`. -/
theorem swap_image_outside_card
    (p : Problem α) (X Y : Agent α) :
    ((B_data p X).image (agentSwapStep Y p) \ B_data p Y).card
      = (N p X).toNat - min (N p X).toNat (N p Y).toNat := by
  have h := Finset.card_sdiff_add_card_inter
              ((B_data p X).image (agentSwapStep Y p)) (B_data p Y)
  rw [swap_image_inter_B_data_Y_card_eq, swap_image_card] at h
  omega

/-! ## (6) Special case: when N_X = N_Y, intersection = both. -/

/-- **Equal-`toNat` case**: when `(N p X).toNat = (N p Y).toNat`, the
intersection is the FULL `B_data p Y`. -/
theorem swap_image_inter_eq_B_data_Y_of_toNat_eq
    (p : Problem α) (X Y : Agent α)
    (hN : (N p X).toNat = (N p Y).toNat) :
    ((B_data p X).image (agentSwapStep Y p)) ∩ B_data p Y
      = B_data p Y := by
  rw [swap_image_inter_B_data_Y_eq_commonPrefix]
  rw [commonPrefix_eq_B_data_of_toNat_eq p Y X hN.symm]

end R2_Agent2_Intersection_Bijection

end MIP
