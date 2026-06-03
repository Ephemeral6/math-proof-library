/-
  STATUS: DISCOVERY
  AGENT: 4
  DIRECTION: When `N p X = N p Y`, `B_data p X` and `B_data p Y` are
    naturally bijective via an "agent swap" map.
  SUMMARY:
    Two agents `X`, `Y` with the same emergence value `N p X = N p Y`
    have B_data sets of equal cardinality (both equal `(N p X).toNat`).
    But more: there is a canonical bijection
      `agentSwap X Y : BarrierData α → BarrierData α`
    that replaces the agent in both `s_pre` and `s_post`, and it
    restricts to a bijection between `B_data p X` and `B_data p Y`.
    Concretely, both sets are images of `Finset.range n` under
    `b_synth · p`, so they line up index-by-index.

    This is a structural identification between barrier sets that
    depends ONLY on the value of N, not on the agents themselves —
    a kind of "agent-relabelling invariance" of the barrier set.
-/
import MIP.Axioms
import MIP.Defs.Barriers

namespace MIP

namespace Agent4_AgentSwap_Bijection

variable {α : Type}

/-! ## (1) Same-N forces equal `B_data` cardinalities. -/

/-- **Equal-N agents have equal `B_data` cardinalities.** Direct
consequence of the unconditional cardinality formula. -/
theorem B_data_card_eq_of_N_eq
    (p : Problem α) (X Y : Agent α) (hN : N p X = N p Y) :
    (B_data p X).card = (B_data p Y).card := by
  have hXcard : (B_data p X).card = (N p X).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective X p)]
    exact Finset.card_range _
  have hYcard : (B_data p Y).card = (N p Y).toNat := by
    unfold B_data
    rw [Finset.card_image_of_injective _ (b_synth_injective Y p)]
    exact Finset.card_range _
  rw [hXcard, hYcard, hN]

/-! ## (2) The agent-swap map. -/

/-- **Index map**: send `b ∈ B_data p X` to `b_synth Y p (b.s_pre.step)`. -/
noncomputable def agentSwapStep (Y : Agent α) (p : Problem α)
    (b : BarrierData α) : BarrierData α :=
  b_synth Y p b.s_pre.step

/-! ## (3) Bijection between `B_data p X` and `B_data p Y` when N
matches. -/

/-- **Same-N bijection (forward)**: `agentSwapStep Y p` sends every
member of `B_data p X` to a member of `B_data p Y`, when N agrees. -/
theorem agentSwapStep_maps_to
    (p : Problem α) (X Y : Agent α) (hN : N p X = N p Y) :
    ∀ b ∈ B_data p X, agentSwapStep Y p b ∈ B_data p Y := by
  intro b hb
  -- b = b_synth X p i for some i < (N p X).toNat
  unfold B_data at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, hi, hEq⟩ := hb
  rw [Finset.mem_range] at hi
  unfold agentSwapStep
  -- b.s_pre.step = i
  rw [← hEq]
  -- now show: b_synth Y p (b_synth X p i).s_pre.step ∈ B_data p Y
  have hStep : (b_synth X p i).s_pre.step = i := rfl
  rw [hStep]
  unfold B_data
  rw [Finset.mem_image]
  refine ⟨i, ?_, rfl⟩
  rw [Finset.mem_range]
  -- need i < (N p Y).toNat. From hi and hN.
  rw [← hN]; exact hi

/-! ## (4) Injectivity on `B_data p X`. -/

/-- **`agentSwapStep` is injective on `B_data p X`.** Because
`s_pre.step` is injective on `B_data p X` (every element is uniquely
determined by its step), and `b_synth Y p` is injective on naturals. -/
theorem agentSwapStep_injOn
    (p : Problem α) (X Y : Agent α) :
    Set.InjOn (agentSwapStep Y p) (B_data p X : Set (BarrierData α)) := by
  intro b₁ hb₁ b₂ hb₂ hEq
  -- Members of B_data p X are b_synth X p i for unique i.
  unfold B_data at hb₁ hb₂
  rw [Finset.coe_image, Set.mem_image] at hb₁ hb₂
  obtain ⟨i, _, hi⟩ := hb₁
  obtain ⟨j, _, hj⟩ := hb₂
  -- hi : b_synth X p i = b₁, hj : b_synth X p j = b₂
  unfold agentSwapStep at hEq
  rw [← hi, ← hj] at hEq
  -- (b_synth X p i).s_pre.step = i
  have hi_step : (b_synth X p i).s_pre.step = i := rfl
  have hj_step : (b_synth X p j).s_pre.step = j := rfl
  rw [hi_step, hj_step] at hEq
  -- hEq : b_synth Y p i = b_synth Y p j → i = j
  have hij : i = j := b_synth_injective Y p hEq
  rw [← hi, ← hj, hij]

/-! ## (5) Surjectivity onto `B_data p Y` when N matches. -/

/-- **Surjectivity** of `agentSwapStep Y p` on `B_data p X` onto
`B_data p Y` when N matches. -/
theorem agentSwapStep_surjOn
    (p : Problem α) (X Y : Agent α) (hN : N p X = N p Y) :
    Set.SurjOn (agentSwapStep Y p)
      (B_data p X : Set (BarrierData α))
      (B_data p Y : Set (BarrierData α)) := by
  intro b' hb'
  -- b' ∈ B_data p Y ⟹ b' = b_synth Y p i for i < (N p Y).toNat
  unfold B_data at hb'
  rw [Finset.coe_image, Set.mem_image] at hb'
  obtain ⟨i, hi, hEq⟩ := hb'
  rw [Finset.coe_range, Set.mem_Iio] at hi
  -- The preimage: b_synth X p i ∈ B_data p X.
  refine ⟨b_synth X p i, ?_, ?_⟩
  · show b_synth X p i ∈ (B_data p X : Set (BarrierData α))
    unfold B_data
    rw [Finset.coe_image, Set.mem_image]
    refine ⟨i, ?_, rfl⟩
    rw [Finset.coe_range, Set.mem_Iio]
    rw [hN]; exact hi
  · unfold agentSwapStep
    have hStep : (b_synth X p i).s_pre.step = i := rfl
    rw [hStep]
    exact hEq

/-! ## (6) Headline: BijOn statement. -/

/-- **Headline: `agentSwapStep Y p` is a bijection from
`(B_data p X : Set _)` onto `(B_data p Y : Set _)` whenever
`N p X = N p Y`.** A canonical identification between barrier sets
across agents with the same emergence value. -/
theorem agentSwapStep_bijOn
    (p : Problem α) (X Y : Agent α) (hN : N p X = N p Y) :
    Set.BijOn (agentSwapStep Y p)
      (B_data p X : Set (BarrierData α))
      (B_data p Y : Set (BarrierData α)) := by
  refine ⟨?_, ?_, ?_⟩
  · -- MapsTo
    intro b hb
    exact agentSwapStep_maps_to p X Y hN b hb
  · -- InjOn
    exact agentSwapStep_injOn p X Y
  · -- SurjOn
    exact agentSwapStep_surjOn p X Y hN

end Agent4_AgentSwap_Bijection

end MIP
