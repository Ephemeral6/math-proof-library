/-
  STATUS: DISCOVERY
  AGENT: R2-2
  DIRECTION: The "common prefix" `commonPrefix p X Y` — the subset of
    `B_data p X` indexed by step `i < min N_X N_Y` — and its
    interaction with `agentSwapStep`.
  SUMMARY:
    Define `commonPrefix p X Y = image (b_synth X p) (range (min N_X.toNat N_Y.toNat))`.
    This is the "agree zone" of two agents: the prefix of synthetic
    barriers that both `B_data p X` and `B_data p Y` carry. Headline
    results:
      * `commonPrefix p X Y ⊆ B_data p X` and its card is `min N_X N_Y`.
      * `agentSwapStep Y p` is a `Set.BijOn` from `commonPrefix p X Y`
        onto `commonPrefix p Y X` — a genuine bijection on the agree zone.
      * `commonPrefix p X X = B_data p X` (self-prefix is the full set).
      * `commonPrefix p X Y = commonPrefix p Y X = ∅` iff one of the
        `N` values is zero.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Image
import Mathlib.Data.Set.Function

namespace MIP

namespace R2_Agent2_CommonPrefix

variable {α : Type}

/-- Local copy of `agentSwapStep`. -/
noncomputable def agentSwapStep (Y : Agent α) (p : Problem α)
    (b : BarrierData α) : BarrierData α :=
  b_synth Y p b.s_pre.step

/-! ## (1) Definition of the common prefix. -/

/-- **Common prefix** between agents `X` and `Y` at problem `p`. The
synthetic barriers of `X` whose index is below `min (N_X.toNat) (N_Y.toNat)`. -/
noncomputable def commonPrefix (p : Problem α) (X Y : Agent α) :
    Finset (BarrierData α) :=
  (Finset.range (min (N p X).toNat (N p Y).toNat)).image (b_synth X p)

/-! ## (2) Basic structural facts. -/

/-- **Common prefix is a subset of `B_data p X`.** -/
theorem commonPrefix_subset_B_data
    (p : Problem α) (X Y : Agent α) :
    commonPrefix p X Y ⊆ B_data p X := by
  intro b hb
  unfold commonPrefix at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, hi, hEq⟩ := hb
  rw [Finset.mem_range] at hi
  unfold B_data
  rw [Finset.mem_image]
  refine ⟨i, ?_, hEq⟩
  rw [Finset.mem_range]
  exact lt_of_lt_of_le hi (min_le_left _ _)

/-- **Cardinality**: `|commonPrefix p X Y| = min (N_X.toNat) (N_Y.toNat)`. -/
theorem commonPrefix_card (p : Problem α) (X Y : Agent α) :
    (commonPrefix p X Y).card = min (N p X).toNat (N p Y).toNat := by
  unfold commonPrefix
  rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
  exact Finset.card_range _

/-- **Self-prefix is the full B_data set.** -/
theorem commonPrefix_self (p : Problem α) (X : Agent α) :
    commonPrefix p X X = B_data p X := by
  unfold commonPrefix B_data
  rw [min_self]

/-! ## (3) The action of `agentSwapStep` on the common prefix. -/

/-- **`agentSwapStep Y p` maps `commonPrefix p X Y` into `B_data p Y`.** -/
theorem agentSwapStep_mapsTo_B_data_Y
    (p : Problem α) (X Y : Agent α) :
    ∀ b ∈ commonPrefix p X Y, agentSwapStep Y p b ∈ B_data p Y := by
  intro b hb
  unfold commonPrefix at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, hi, hEq⟩ := hb
  rw [Finset.mem_range] at hi
  -- i < min ⟹ i < (N p Y).toNat
  have hiY : i < (N p Y).toNat := lt_of_lt_of_le hi (min_le_right _ _)
  unfold agentSwapStep
  rw [← hEq]
  show b_synth Y p (b_synth X p i).s_pre.step ∈ B_data p Y
  have hStep : (b_synth X p i).s_pre.step = i := rfl
  rw [hStep]
  unfold B_data
  rw [Finset.mem_image]
  exact ⟨i, Finset.mem_range.mpr hiY, rfl⟩

/-- **Sharper: image lands in `commonPrefix p Y X`.** -/
theorem agentSwapStep_mapsTo_commonPrefix_swap
    (p : Problem α) (X Y : Agent α) :
    ∀ b ∈ commonPrefix p X Y, agentSwapStep Y p b ∈ commonPrefix p Y X := by
  intro b hb
  unfold commonPrefix at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, hi, hEq⟩ := hb
  rw [Finset.mem_range] at hi
  unfold agentSwapStep
  rw [← hEq]
  show b_synth Y p (b_synth X p i).s_pre.step ∈ commonPrefix p Y X
  have hStep : (b_synth X p i).s_pre.step = i := rfl
  rw [hStep]
  unfold commonPrefix
  rw [Finset.mem_image]
  refine ⟨i, ?_, rfl⟩
  rw [Finset.mem_range, Nat.min_comm]
  exact hi

/-! ## (4) Bijection on the common prefix. -/

/-- **Injectivity on the common prefix.** Inherited from the
unconditional version. -/
theorem agentSwapStep_injOn_commonPrefix
    (p : Problem α) (X Y : Agent α) :
    Set.InjOn (agentSwapStep Y p) (commonPrefix p X Y : Set (BarrierData α)) := by
  intro b₁ hb₁ b₂ hb₂ hEq
  unfold commonPrefix at hb₁ hb₂
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

/-- **Surjectivity** of `agentSwapStep Y p` onto `commonPrefix p Y X`
from `commonPrefix p X Y`. -/
theorem agentSwapStep_surjOn_commonPrefix
    (p : Problem α) (X Y : Agent α) :
    Set.SurjOn (agentSwapStep Y p)
      (commonPrefix p X Y : Set (BarrierData α))
      (commonPrefix p Y X : Set (BarrierData α)) := by
  intro b' hb'
  unfold commonPrefix at hb'
  rw [Finset.coe_image, Set.mem_image] at hb'
  obtain ⟨i, hi, hEq⟩ := hb'
  rw [Finset.coe_range, Set.mem_Iio] at hi
  -- i < min (N p Y).toNat (N p X).toNat ⟹ i < min (N p X).toNat (N p Y).toNat
  have hiSwap : i < min (N p X).toNat (N p Y).toNat := by
    rw [Nat.min_comm]; exact hi
  refine ⟨b_synth X p i, ?_, ?_⟩
  · show b_synth X p i ∈ (commonPrefix p X Y : Set (BarrierData α))
    unfold commonPrefix
    rw [Finset.coe_image, Set.mem_image]
    refine ⟨i, ?_, rfl⟩
    rw [Finset.coe_range, Set.mem_Iio]
    exact hiSwap
  · unfold agentSwapStep
    have hStep : (b_synth X p i).s_pre.step = i := rfl
    rw [hStep]
    exact hEq

/-- **HEADLINE: bijection on the common prefix.** Even when `N p X ≠
N p Y`, the `agentSwapStep Y p` restricted to `commonPrefix p X Y` is
a `Set.BijOn` onto `commonPrefix p Y X`. -/
theorem agentSwapStep_bijOn_commonPrefix
    (p : Problem α) (X Y : Agent α) :
    Set.BijOn (agentSwapStep Y p)
      (commonPrefix p X Y : Set (BarrierData α))
      (commonPrefix p Y X : Set (BarrierData α)) := by
  refine ⟨?_, agentSwapStep_injOn_commonPrefix p X Y, agentSwapStep_surjOn_commonPrefix p X Y⟩
  intro b hb
  exact agentSwapStep_mapsTo_commonPrefix_swap p X Y b hb

/-! ## (5) Cardinality symmetry. -/

/-- **Cardinality symmetry**: `|commonPrefix p X Y| = |commonPrefix p Y X|`. -/
theorem commonPrefix_card_symm (p : Problem α) (X Y : Agent α) :
    (commonPrefix p X Y).card = (commonPrefix p Y X).card := by
  rw [commonPrefix_card, commonPrefix_card, Nat.min_comm]

/-! ## (6) Common prefix is empty iff one N value is zero. -/

/-- **Empty iff one N is zero.** `commonPrefix p X Y = ∅ ↔
(N p X).toNat = 0 ∨ (N p Y).toNat = 0`. -/
theorem commonPrefix_empty_iff (p : Problem α) (X Y : Agent α) :
    commonPrefix p X Y = ∅ ↔ (N p X).toNat = 0 ∨ (N p Y).toNat = 0 := by
  rw [← Finset.card_eq_zero, commonPrefix_card]
  omega

/-! ## (7) Common prefix when N values are equal: equals the full B_data. -/

/-- **Equal N case**: when `(N p X).toNat = (N p Y).toNat`, the common
prefix is the full `B_data p X`. -/
theorem commonPrefix_eq_B_data_of_toNat_eq
    (p : Problem α) (X Y : Agent α)
    (hN : (N p X).toNat = (N p Y).toNat) :
    commonPrefix p X Y = B_data p X := by
  unfold commonPrefix B_data
  rw [hN, min_self]

/-! ## (8) Cardinality upper bound on the swap image. -/

/-- **Image card bound**: the image of `agentSwapStep Y p` over
`B_data p X` has cardinality `(B_data p X).card = (N p X).toNat`, but
its intersection with `B_data p Y` has cardinality at most
`min (N_X.toNat) (N_Y.toNat)`. -/
theorem swap_image_inter_B_data_Y_card_le
    (p : Problem α) (X Y : Agent α) :
    (((B_data p X).image (agentSwapStep Y p)) ∩ (B_data p Y)).card
      ≤ min (N p X).toNat (N p Y).toNat := by
  -- The intersection is a subset of B_data p Y, but also of the image
  -- of B_data p X under a step-preserving map ⟶ subset of range
  -- (min ...) under b_synth Y p.
  have hSub : ((B_data p X).image (agentSwapStep Y p)) ∩ (B_data p Y)
                ⊆ commonPrefix p Y X := by
    intro b hb
    rw [Finset.mem_inter] at hb
    obtain ⟨hImg, hY⟩ := hb
    rw [Finset.mem_image] at hImg
    obtain ⟨b₀, hb₀X, hEqImg⟩ := hImg
    -- b₀ ∈ B_data p X ⟹ b₀ = b_synth X p i for i < N_X.toNat
    unfold B_data at hb₀X
    rw [Finset.mem_image] at hb₀X
    obtain ⟨i, hiX, hb₀Eq⟩ := hb₀X
    rw [Finset.mem_range] at hiX
    -- agentSwapStep Y p b₀ = b_synth Y p i (since b₀.s_pre.step = i)
    have hStep : agentSwapStep Y p b₀ = b_synth Y p i := by
      unfold agentSwapStep
      rw [← hb₀Eq]
      rfl
    rw [hStep] at hEqImg
    -- b = b_synth Y p i. Also b ∈ B_data p Y ⟹ i < N_Y.toNat.
    have hiY : i < (N p Y).toNat := by
      rw [← hEqImg] at hY
      unfold B_data at hY
      rw [Finset.mem_image] at hY
      obtain ⟨j, hj, hjEq⟩ := hY
      rw [Finset.mem_range] at hj
      -- b_synth Y p j = b_synth Y p i ⟹ j = i
      have : j = i := b_synth_injective Y p hjEq
      rw [← this]; exact hj
    unfold commonPrefix
    rw [Finset.mem_image]
    refine ⟨i, ?_, hEqImg⟩
    rw [Finset.mem_range]
    exact lt_min hiY hiX
  have hCardSub : (((B_data p X).image (agentSwapStep Y p)) ∩ (B_data p Y)).card
                    ≤ (commonPrefix p Y X).card :=
    Finset.card_le_card hSub
  rw [commonPrefix_card] at hCardSub
  rw [Nat.min_comm] at hCardSub
  exact hCardSub

end R2_Agent2_CommonPrefix

end MIP
