/-
  STATUS: DISCOVERY
  AGENT: R2-2
  DIRECTION: `agentSwapStep Y p` is unconditionally `Set.InjOn` on
    `B_data p X`, no hypothesis on `N p X` vs `N p Y`.
  SUMMARY:
    Agent 4's `agentSwapStep_injOn` already established this for the
    case `N p X = N p Y`. But the proof used NO finiteness or N-equality
    hypothesis — it follows purely from injectivity of `b_synth Y p`
    in its third argument plus the fact that step projection identifies
    `b_synth X p i` by index `i`. We re-state the InjOn unconditionally
    and additionally prove the "joint InjOn" on a subset indexed by an
    arbitrary `Finset ℕ`, which is the technical lemma needed in
    follow-up files for partial-bijection / common-prefix arguments.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Image
import Mathlib.Data.Set.Function

namespace MIP

namespace R2_Agent2_AgentSwap_InjOn_Unconditional

variable {α : Type}

/-! ## (1) Local copy of `agentSwapStep`. -/

/-- Local copy of `agentSwapStep` to keep the file self-contained. -/
noncomputable def agentSwapStep (Y : Agent α) (p : Problem α)
    (b : BarrierData α) : BarrierData α :=
  b_synth Y p b.s_pre.step

/-! ## (2) Unconditional `InjOn` on `B_data p X`. -/

/-- **Unconditional InjOn.** For any pair of agents `X`, `Y` and any
problem `p`, `agentSwapStep Y p` is injective on `B_data p X`. No
hypothesis on `N p X` or `N p Y`. -/
theorem agentSwapStep_injOn_unconditional
    (p : Problem α) (X Y : Agent α) :
    Set.InjOn (agentSwapStep Y p) (B_data p X : Set (BarrierData α)) := by
  intro b₁ hb₁ b₂ hb₂ hEq
  -- Each b ∈ B_data p X has the form b_synth X p i for some i.
  unfold B_data at hb₁ hb₂
  rw [Finset.coe_image, Set.mem_image] at hb₁ hb₂
  obtain ⟨i, _, hi⟩ := hb₁
  obtain ⟨j, _, hj⟩ := hb₂
  unfold agentSwapStep at hEq
  rw [← hi, ← hj] at hEq
  -- (b_synth X p i).s_pre.step = i and similarly for j.
  have hi_step : (b_synth X p i).s_pre.step = i := rfl
  have hj_step : (b_synth X p j).s_pre.step = j := rfl
  rw [hi_step, hj_step] at hEq
  -- hEq : b_synth Y p i = b_synth Y p j
  have hij : i = j := b_synth_injective Y p hEq
  rw [← hi, ← hj, hij]

/-! ## (3) InjOn on the image of an arbitrary index Finset. -/

/-- **Generalised InjOn.** `agentSwapStep Y p` is `Set.InjOn` on the
image of any `Finset ℕ` under `b_synth X p`. This is the key technical
lemma for follow-up partial-bijection arguments: we can restrict to
any subset of step indices, not just `range (N p X).toNat`. -/
theorem agentSwapStep_injOn_image
    (p : Problem α) (X Y : Agent α) (S : Finset ℕ) :
    Set.InjOn (agentSwapStep Y p) (S.image (b_synth X p) : Set (BarrierData α)) := by
  intro b₁ hb₁ b₂ hb₂ hEq
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

/-! ## (4) Embedding when `(N p X).toNat ≤ (N p Y).toNat`: image lies
inside `B_data p Y`. -/

/-- **Forward embedding under `≤` on `toNat`.** If
`(N p X).toNat ≤ (N p Y).toNat`, then `agentSwapStep Y p` carries every
element of `B_data p X` into `B_data p Y`. This is the natural-number
form of the comparison, which avoids the `N = ⊤` complication: when
`N p Y = ⊤` we have `(N p Y).toNat = 0`, so the hypothesis forces
`(N p X).toNat = 0` too, and `B_data p X = ∅`. -/
theorem agentSwapStep_mapsTo_of_toNat_le
    (p : Problem α) (X Y : Agent α)
    (hN : (N p X).toNat ≤ (N p Y).toNat) :
    ∀ b ∈ B_data p X, agentSwapStep Y p b ∈ B_data p Y := by
  intro b hb
  unfold B_data at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, hi, hEq⟩ := hb
  rw [Finset.mem_range] at hi
  -- i < (N p X).toNat ≤ (N p Y).toNat
  have hiY : i < (N p Y).toNat := lt_of_lt_of_le hi hN
  unfold agentSwapStep
  rw [← hEq]
  show b_synth Y p (b_synth X p i).s_pre.step ∈ B_data p Y
  have hStep : (b_synth X p i).s_pre.step = i := rfl
  rw [hStep]
  unfold B_data
  rw [Finset.mem_image]
  exact ⟨i, Finset.mem_range.mpr hiY, rfl⟩

/-! ## (5) Headline: combined `InjOn` + `MapsTo` form on `toNat`. -/

/-- **Embedding under `toNat ≤`.** Together: `agentSwapStep Y p` is an
injective embedding from `B_data p X` into `B_data p Y`. -/
theorem agentSwapStep_injOn_mapsTo_of_toNat_le
    (p : Problem α) (X Y : Agent α)
    (hN : (N p X).toNat ≤ (N p Y).toNat) :
    Set.MapsTo (agentSwapStep Y p)
        (B_data p X : Set (BarrierData α))
        (B_data p Y : Set (BarrierData α))
      ∧ Set.InjOn (agentSwapStep Y p) (B_data p X : Set (BarrierData α)) := by
  refine ⟨?_, agentSwapStep_injOn_unconditional p X Y⟩
  intro b hb
  exact agentSwapStep_mapsTo_of_toNat_le p X Y hN b hb

/-! ## (6) Cardinality consequence of the embedding. -/

/-- **Cardinality embedding.** When `(N p X).toNat ≤ (N p Y).toNat`,
`(B_data p X).card ≤ (B_data p Y).card`. This is a structural
consequence of the injective embedding, independent of Agent 4's
unconditional `card = N.toNat` formula. -/
theorem B_data_card_le_of_toNat_le
    (p : Problem α) (X Y : Agent α)
    (hN : (N p X).toNat ≤ (N p Y).toNat) :
    (B_data p X).card ≤ (B_data p Y).card := by
  have hImage : (B_data p X).image (agentSwapStep Y p) ⊆ B_data p Y := by
    intro b' hb'
    rw [Finset.mem_image] at hb'
    obtain ⟨b, hb, hEq⟩ := hb'
    rw [← hEq]
    exact agentSwapStep_mapsTo_of_toNat_le p X Y hN b hb
  have hCardImage : ((B_data p X).image (agentSwapStep Y p)).card ≤ (B_data p Y).card :=
    Finset.card_le_card hImage
  have hInjFinset : Set.InjOn (agentSwapStep Y p) (B_data p X : Set (BarrierData α)) :=
    agentSwapStep_injOn_unconditional p X Y
  have hCardEq : ((B_data p X).image (agentSwapStep Y p)).card = (B_data p X).card :=
    Finset.card_image_of_injOn hInjFinset
  omega

end R2_Agent2_AgentSwap_InjOn_Unconditional

end MIP
