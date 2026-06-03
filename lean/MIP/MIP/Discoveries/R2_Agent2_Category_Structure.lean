/-
  STATUS: DISCOVERY
  AGENT: R2-2
  DIRECTION: The B_data sets across agents form a *category* under
    `agentSwapStep` — extending the groupoid Agent 4 found.
  SUMMARY:
    Agent 4 showed that when N matches across agents, the agent-swap
    maps form a groupoid. Here we show the structure extends to a
    CATEGORY when N can differ:
      * objects = agents,
      * morphism X → Y = restriction of `agentSwapStep Y p` to
        `commonPrefix p X Y`,
      * composition X → Y → Z agrees with X → Z via three-agent
        coherence,
      * identity X → X is the inclusion `commonPrefix p X X ↪ B_data p X`,
        which is the identity by `commonPrefix_self`.
    Headline categorical laws:
      * Identity law: `commonPrefix p X X = B_data p X` (Agent 2's prefix
        is the full set on the diagonal).
      * Image identification: the image of `commonPrefix p X Y` under
        `agentSwapStep Y p` is exactly `commonPrefix p Y X`.
      * Composition law: image of `commonPrefix p X Y` under
        `agentSwapStep Y p`, then under `agentSwapStep Z p`, equals
        image under `agentSwapStep Z p` directly.
      * Triple-prefix containment: image of the triple common-prefix
        `tripleCommonPrefix p X Y Z` under any swap lands inside the
        appropriate target prefix.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import MIP.Discoveries.R2_Agent2_CommonPrefix
import MIP.Discoveries.R2_Agent2_ThreeAgent_Coherence
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Image
import Mathlib.Data.Set.Function

namespace MIP

namespace R2_Agent2_Category_Structure

open R2_Agent2_CommonPrefix
open R2_Agent2_ThreeAgent_Coherence

variable {α : Type}

/-! ## (1) Identity morphism: `agentSwapStep X p` on `commonPrefix p X X`
= identity. -/

/-- **Identity law (categorical).** On the self common-prefix
(which equals `B_data p X`), `agentSwapStep X p` is the identity. -/
theorem identity_law (p : Problem α) (X : Agent α) :
    ∀ b ∈ commonPrefix p X X, agentSwapStep X p b = b := by
  intro b hb
  rw [commonPrefix_self] at hb
  unfold B_data at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, _, hEq⟩ := hb
  unfold agentSwapStep
  rw [← hEq]
  show b_synth X p (b_synth X p i).s_pre.step = b_synth X p i
  rfl

/-! ## (2) Composition law (pointwise). -/

/-- **Composition law (pointwise)**: applying Y→Z swap to Y-output of
X→Y swap gives the same as X→Z swap. -/
theorem composition_law
    (p : Problem α) (_X Y Z : Agent α) (b : BarrierData α) :
    agentSwapStep Z p (agentSwapStep Y p b) = agentSwapStep Z p b :=
  agentSwapStep_comp_pointwise p Y Z b

/-! ## (3) Image of the X→Y morphism is exactly `commonPrefix p Y X`. -/

/-- **Image identification (HEADLINE)**:
`(commonPrefix p X Y).image (agentSwapStep Y p) = commonPrefix p Y X`.

This is the precise statement of "the X→Y morphism lands exactly on
the common prefix of Y→X". -/
theorem commonPrefix_image_eq
    (p : Problem α) (X Y : Agent α) :
    (commonPrefix p X Y).image (agentSwapStep Y p) = commonPrefix p Y X := by
  ext b
  rw [Finset.mem_image]
  constructor
  · rintro ⟨b₀, hb₀, hEq⟩
    rw [← hEq]
    exact agentSwapStep_mapsTo_commonPrefix_swap p X Y b₀ hb₀
  · intro hb
    have h := agentSwapStep_surjOn_commonPrefix p X Y
    have hb' : b ∈ (commonPrefix p Y X : Set (BarrierData α)) := hb
    obtain ⟨b₀, hb₀, hEq⟩ := h hb'
    exact ⟨b₀, hb₀, hEq⟩

/-! ## (4) Image-then-image identity (Finset-level composition). -/

/-- **Finset-level composition**:
`((commonPrefix p X Y).image (agentSwapStep Y p)).image (agentSwapStep Z p)
= (commonPrefix p X Y).image (agentSwapStep Z p)`. -/
theorem commonPrefix_image_chain
    (p : Problem α) (X Y Z : Agent α) :
    ((commonPrefix p X Y).image (agentSwapStep Y p)).image (agentSwapStep Z p)
      = (commonPrefix p X Y).image (agentSwapStep Z p) :=
  image_swap_comp p Y Z (commonPrefix p X Y)

/-! ## (5) Triple common prefix. -/

/-- **Triple common prefix**: the set of synthetic barriers indexed by
step `i < min(N_X, N_Y, N_Z)`, viewed inside `B_data p X`. -/
noncomputable def tripleCommonPrefix (p : Problem α) (X Y Z : Agent α) :
    Finset (BarrierData α) :=
  (Finset.range (min (N p X).toNat (min (N p Y).toNat (N p Z).toNat))).image (b_synth X p)

/-- **Triple prefix is a subset of `B_data p X`.** -/
theorem tripleCommonPrefix_subset_B_data
    (p : Problem α) (X Y Z : Agent α) :
    tripleCommonPrefix p X Y Z ⊆ B_data p X := by
  intro b hb
  unfold tripleCommonPrefix at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, hi, hEq⟩ := hb
  rw [Finset.mem_range] at hi
  unfold B_data
  rw [Finset.mem_image]
  refine ⟨i, ?_, hEq⟩
  rw [Finset.mem_range]
  exact lt_of_lt_of_le hi (min_le_left _ _)

/-- **Triple prefix is a subset of `commonPrefix p X Y`.** -/
theorem tripleCommonPrefix_subset_pairPrefix_XY
    (p : Problem α) (X Y Z : Agent α) :
    tripleCommonPrefix p X Y Z ⊆ commonPrefix p X Y := by
  intro b hb
  unfold tripleCommonPrefix at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, hi, hEq⟩ := hb
  rw [Finset.mem_range] at hi
  unfold commonPrefix
  rw [Finset.mem_image]
  refine ⟨i, ?_, hEq⟩
  rw [Finset.mem_range, lt_min_iff]
  refine ⟨lt_of_lt_of_le hi (min_le_left _ _), ?_⟩
  have h2 : i < min (N p Y).toNat (N p Z).toNat := lt_of_lt_of_le hi (min_le_right _ _)
  exact lt_of_lt_of_le h2 (min_le_left _ _)

/-- **Triple prefix subset of `commonPrefix p X Z`.** -/
theorem tripleCommonPrefix_subset_pairPrefix_XZ
    (p : Problem α) (X Y Z : Agent α) :
    tripleCommonPrefix p X Y Z ⊆ commonPrefix p X Z := by
  intro b hb
  unfold tripleCommonPrefix at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, hi, hEq⟩ := hb
  rw [Finset.mem_range] at hi
  unfold commonPrefix
  rw [Finset.mem_image]
  refine ⟨i, ?_, hEq⟩
  rw [Finset.mem_range, lt_min_iff]
  refine ⟨lt_of_lt_of_le hi (min_le_left _ _), ?_⟩
  have h2 : i < min (N p Y).toNat (N p Z).toNat := lt_of_lt_of_le hi (min_le_right _ _)
  exact lt_of_lt_of_le h2 (min_le_right _ _)

/-! ## (6) Triple prefix cardinality. -/

/-- **Triple prefix card**: equals `min(N_X.toNat, N_Y.toNat, N_Z.toNat)`. -/
theorem tripleCommonPrefix_card (p : Problem α) (X Y Z : Agent α) :
    (tripleCommonPrefix p X Y Z).card
      = min (N p X).toNat (min (N p Y).toNat (N p Z).toNat) := by
  unfold tripleCommonPrefix
  rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
  exact Finset.card_range _

/-! ## (7) Triple prefix is symmetric in its (X, Y, Z) under swap. -/

/-- **Image of triple prefix under `agentSwapStep Y p`** lies inside
`tripleCommonPrefix p Y X Z`. -/
theorem tripleCommonPrefix_image_swap
    (p : Problem α) (X Y Z : Agent α) :
    ∀ b ∈ tripleCommonPrefix p X Y Z,
      agentSwapStep Y p b ∈ tripleCommonPrefix p Y X Z := by
  intro b hb
  unfold tripleCommonPrefix at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, hi, hEq⟩ := hb
  rw [Finset.mem_range] at hi
  unfold agentSwapStep
  rw [← hEq]
  show b_synth Y p (b_synth X p i).s_pre.step ∈ tripleCommonPrefix p Y X Z
  have hStep : (b_synth X p i).s_pre.step = i := rfl
  rw [hStep]
  unfold tripleCommonPrefix
  rw [Finset.mem_image]
  refine ⟨i, ?_, rfl⟩
  rw [Finset.mem_range, lt_min_iff]
  -- i < min N_X (min N_Y N_Z), need i < min N_Y (min N_X N_Z).
  have hiX : i < (N p X).toNat := lt_of_lt_of_le hi (min_le_left _ _)
  have hiYZ : i < min (N p Y).toNat (N p Z).toNat := lt_of_lt_of_le hi (min_le_right _ _)
  have hiY : i < (N p Y).toNat := lt_of_lt_of_le hiYZ (min_le_left _ _)
  have hiZ : i < (N p Z).toNat := lt_of_lt_of_le hiYZ (min_le_right _ _)
  refine ⟨hiY, ?_⟩
  rw [lt_min_iff]
  exact ⟨hiX, hiZ⟩

/-! ## (8) Three-agent transport coherence on the triple prefix. -/

/-- **Triple-prefix transport coherence**: on `tripleCommonPrefix p X Y Z`,
the route X → Y → Z agrees with X → Z. (This is just the pointwise
coherence on a subset.) -/
theorem tripleCommonPrefix_chain_coherence
    (p : Problem α) (X Y Z : Agent α) :
    ∀ b ∈ tripleCommonPrefix p X Y Z,
      agentSwapStep Z p (agentSwapStep Y p b) = agentSwapStep Z p b := by
  intro b _
  exact agentSwapStep_comp_pointwise p Y Z b

/-! ## (9) Sharp categorical statement: on the triple prefix, the image
under X→Y→Z swap lands inside `tripleCommonPrefix p Z X Y` (full
three-way symmetry). -/

/-- **Triple-prefix tri-symmetry of image**: on the triple prefix,
applying X→Z swap (directly or via Y) lands in `tripleCommonPrefix p Z X Y`. -/
theorem tripleCommonPrefix_image_swap_to_Z
    (p : Problem α) (X Y Z : Agent α) :
    ∀ b ∈ tripleCommonPrefix p X Y Z,
      agentSwapStep Z p b ∈ tripleCommonPrefix p Z X Y := by
  intro b hb
  unfold tripleCommonPrefix at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, hi, hEq⟩ := hb
  rw [Finset.mem_range] at hi
  unfold agentSwapStep
  rw [← hEq]
  show b_synth Z p (b_synth X p i).s_pre.step ∈ tripleCommonPrefix p Z X Y
  have hStep : (b_synth X p i).s_pre.step = i := rfl
  rw [hStep]
  unfold tripleCommonPrefix
  rw [Finset.mem_image]
  refine ⟨i, ?_, rfl⟩
  rw [Finset.mem_range, lt_min_iff]
  have hiX : i < (N p X).toNat := lt_of_lt_of_le hi (min_le_left _ _)
  have hiYZ : i < min (N p Y).toNat (N p Z).toNat := lt_of_lt_of_le hi (min_le_right _ _)
  have hiY : i < (N p Y).toNat := lt_of_lt_of_le hiYZ (min_le_left _ _)
  have hiZ : i < (N p Z).toNat := lt_of_lt_of_le hiYZ (min_le_right _ _)
  refine ⟨hiZ, ?_⟩
  rw [lt_min_iff]
  exact ⟨hiX, hiY⟩

end R2_Agent2_Category_Structure

end MIP
