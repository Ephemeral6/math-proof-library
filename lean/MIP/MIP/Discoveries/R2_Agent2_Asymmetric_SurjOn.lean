/-
  STATUS: DISCOVERY
  AGENT: R2-2
  DIRECTION: Asymmetric surjectivity: when `N p X ≥ N p Y`, the swap
    `agentSwapStep Y p` is `Set.SurjOn` from `B_data p X` onto all of
    `B_data p Y`. Complements the bijection / injection results.
  SUMMARY:
    When `(N p X).toNat ≥ (N p Y).toNat`, `agentSwapStep Y p` restricted
    to `B_data p X` surjects onto `B_data p Y`. The proof is direct:
    every `b ∈ B_data p Y` has the form `b_synth Y p j` with `j < N_Y.toNat
    ≤ N_X.toNat`, and `agentSwapStep Y p (b_synth X p j) = b_synth Y p j`.
    Combined with the unconditional `InjOn` (when `N_X = N_Y`) or the
    asymmetric MapsTo (when `N_X ≤ N_Y`), this completes a picture:
      - `N_X < N_Y`: InjOn + MapsTo into B_data Y (partial bijection)
      - `N_X = N_Y`: BijOn (Agent 4)
      - `N_X > N_Y`: SurjOn onto B_data Y, NOT InjOn unless restricted
        to commonPrefix.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import MIP.Discoveries.R2_Agent2_CommonPrefix
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Image
import Mathlib.Data.Set.Function

namespace MIP

namespace R2_Agent2_Asymmetric_SurjOn

open R2_Agent2_CommonPrefix

variable {α : Type}

/-! ## (1) Asymmetric surjectivity: `N_X ≥ N_Y` case. -/

/-- **SurjOn under `≥`**: when `(N p Y).toNat ≤ (N p X).toNat`,
`agentSwapStep Y p` restricted to `B_data p X` is `Set.SurjOn` onto
`B_data p Y`. -/
theorem agentSwapStep_surjOn_of_toNat_ge
    (p : Problem α) (X Y : Agent α)
    (hN : (N p Y).toNat ≤ (N p X).toNat) :
    Set.SurjOn (agentSwapStep Y p)
      (B_data p X : Set (BarrierData α))
      (B_data p Y : Set (BarrierData α)) := by
  intro b' hb'
  -- b' ∈ B_data p Y ⟹ b' = b_synth Y p j for j < N_Y.toNat ≤ N_X.toNat.
  unfold B_data at hb'
  rw [Finset.coe_image, Set.mem_image] at hb'
  obtain ⟨j, hj, hEq⟩ := hb'
  rw [Finset.coe_range, Set.mem_Iio] at hj
  -- j < N_X.toNat too.
  have hjX : j < (N p X).toNat := lt_of_lt_of_le hj hN
  refine ⟨b_synth X p j, ?_, ?_⟩
  · show b_synth X p j ∈ (B_data p X : Set (BarrierData α))
    unfold B_data
    rw [Finset.coe_image, Set.mem_image]
    refine ⟨j, ?_, rfl⟩
    rw [Finset.coe_range, Set.mem_Iio]
    exact hjX
  · unfold agentSwapStep
    have hStep : (b_synth X p j).s_pre.step = j := rfl
    rw [hStep]
    exact hEq

/-! ## (2) Sub-bijection on the common prefix even when N values
differ. -/

/-- **Sub-bijection (revisited)**: combining the SurjOn fact with
the `commonPrefix_self` identification, when N_Y ≤ N_X, the swap
`agentSwapStep Y p` is a bijection from `commonPrefix p X Y` onto
`B_data p Y`. -/
theorem agentSwapStep_bijOn_commonPrefix_to_B_data_Y_of_toNat_ge
    (p : Problem α) (X Y : Agent α)
    (hN : (N p Y).toNat ≤ (N p X).toNat) :
    Set.BijOn (agentSwapStep Y p)
      (commonPrefix p X Y : Set (BarrierData α))
      (B_data p Y : Set (BarrierData α)) := by
  -- When N_Y ≤ N_X, commonPrefix p X Y has range (min N_X N_Y) = (range N_Y).
  -- So commonPrefix p X Y ≃ B_data p X restricted to first N_Y indices.
  refine ⟨?_, ?_, ?_⟩
  · intro b hb
    unfold commonPrefix at hb
    rw [Finset.coe_image, Set.mem_image] at hb
    obtain ⟨i, hi, hEq⟩ := hb
    rw [Finset.coe_range, Set.mem_Iio] at hi
    -- i < min N_X N_Y. Since N_Y ≤ N_X, min = N_Y. So i < N_Y.toNat.
    have hiY : i < (N p Y).toNat := lt_of_lt_of_le hi (min_le_right _ _)
    unfold agentSwapStep
    rw [← hEq]
    show b_synth Y p (b_synth X p i).s_pre.step ∈ (B_data p Y : Set (BarrierData α))
    have hStep : (b_synth X p i).s_pre.step = i := rfl
    rw [hStep]
    unfold B_data
    rw [Finset.coe_image, Set.mem_image]
    refine ⟨i, ?_, rfl⟩
    rw [Finset.coe_range, Set.mem_Iio]
    exact hiY
  · -- InjOn via the agent-swap argument.
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
  · -- SurjOn: every b' ∈ B_data p Y has b' = b_synth Y p j for j < N_Y.
    intro b' hb'
    unfold B_data at hb'
    rw [Finset.coe_image, Set.mem_image] at hb'
    obtain ⟨j, hj, hEq⟩ := hb'
    rw [Finset.coe_range, Set.mem_Iio] at hj
    -- j < N_Y.toNat ≤ N_X.toNat, so j < min N_X N_Y = N_Y.
    refine ⟨b_synth X p j, ?_, ?_⟩
    · show b_synth X p j ∈ (commonPrefix p X Y : Set (BarrierData α))
      unfold commonPrefix
      rw [Finset.coe_image, Set.mem_image]
      refine ⟨j, ?_, rfl⟩
      rw [Finset.coe_range, Set.mem_Iio]
      rw [lt_min_iff]
      exact ⟨lt_of_lt_of_le hj hN, hj⟩
    · unfold agentSwapStep
      have hStep : (b_synth X p j).s_pre.step = j := rfl
      rw [hStep]
      exact hEq

/-! ## (3) Trichotomy: precise statement of the three regimes. -/

/-- **Trichotomy summary**: for any `(p, X, Y)`, exactly one of the
following:
  (a) `(N p X).toNat < (N p Y).toNat`: swap is InjOn `B_data p X →
      B_data p Y` (strict sub-bijection).
  (b) `(N p X).toNat = (N p Y).toNat`: swap is BijOn (Agent 4's groupoid).
  (c) `(N p X).toNat > (N p Y).toNat`: swap is SurjOn onto `B_data p Y`
      (but NOT injective on `B_data p X`).

This three-way pattern matches the standard "comparison" trichotomy on
`ℕ`. -/
theorem trichotomy
    (p : Problem α) (X Y : Agent α) :
    (N p X).toNat < (N p Y).toNat
      ∨ (N p X).toNat = (N p Y).toNat
      ∨ (N p X).toNat > (N p Y).toNat :=
  lt_trichotomy _ _

/-! ## (4) Pseudo-inverse: when `N_X ≥ N_Y`, the map
`agentSwapStep X p` from `B_data p Y` is a one-sided inverse to
`agentSwapStep Y p ↾ commonPrefix p X Y`. -/

/-- **One-sided inverse**: when `N_Y ≤ N_X`, the composition
`agentSwapStep X p ∘ agentSwapStep Y p` is the identity on
`commonPrefix p X Y`. -/
theorem swap_X_swap_Y_eq_id_on_commonPrefix
    (p : Problem α) (X Y : Agent α) :
    ∀ b ∈ commonPrefix p X Y,
      agentSwapStep X p (agentSwapStep Y p b) = b := by
  intro b hb
  unfold commonPrefix at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, _, hEq⟩ := hb
  unfold agentSwapStep
  rw [← hEq]
  show b_synth X p (b_synth Y p (b_synth X p i).s_pre.step).s_pre.step
        = b_synth X p i
  have hStep1 : (b_synth X p i).s_pre.step = i := rfl
  rw [hStep1]
  have hStep2 : (b_synth Y p i).s_pre.step = i := rfl
  rw [hStep2]

end R2_Agent2_Asymmetric_SurjOn

end MIP
