/-
  STATUS: DISCOVERY
  AGENT: R2-2
  DIRECTION: Three-agent transport coherence for `agentSwapStep`.
  SUMMARY:
    The two-step composition `agentSwapStep Z p ∘ agentSwapStep Y p` is
    point-wise equal to `agentSwapStep Z p` for ANY input, because the
    step index is preserved by `agentSwapStep Y p`. As a consequence,
    the three-agent "transport via B" — `A → B → C` — agrees with the
    direct A → C transport on EVERY input, not just the common-prefix.
    This coherence makes the agent-swap maps cohere as morphisms in a
    category with objects = agents and morphisms = step-preserving
    barrier maps, exactly the categorical structure Agent 4 hinted at.
-/
import MIP.Axioms
import MIP.Defs.Barriers
import MIP.Discoveries.R2_Agent2_CommonPrefix
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Image
import Mathlib.Data.Set.Function

namespace MIP

namespace R2_Agent2_ThreeAgent_Coherence

open R2_Agent2_CommonPrefix

variable {α : Type}

/-! ## (1) Strong coherence: composition equals direct map at every point. -/

/-- **Strong coherence (pointwise).** For any barrier `b` (NOT just one
in `B_data p X`), the two-step swap A → B → C equals the direct A → C
swap. The proof is by `rfl` once we observe that `agentSwapStep Y p b`
has `s_pre.step = b.s_pre.step`. -/
@[simp] theorem agentSwapStep_comp_pointwise
    (p : Problem α) (Y Z : Agent α) (b : BarrierData α) :
    agentSwapStep Z p (agentSwapStep Y p b) = agentSwapStep Z p b := by
  unfold agentSwapStep
  have h : (b_synth Y p b.s_pre.step).s_pre.step = b.s_pre.step := rfl
  rw [h]

/-- **Idempotent composition**: `(agentSwapStep Y p) ∘ (agentSwapStep Y p) = agentSwapStep Y p`. -/
@[simp] theorem agentSwapStep_idempotent
    (p : Problem α) (Y : Agent α) (b : BarrierData α) :
    agentSwapStep Y p (agentSwapStep Y p b) = agentSwapStep Y p b :=
  agentSwapStep_comp_pointwise p Y Y b

/-! ## (2) Three-agent identities on `B_data p A`. -/

/-- **A → B → A coherence.** For `b ∈ B_data p A`, swap to `B` then back
to `A` returns `b`. -/
theorem swap_BA_eq_self_on_B_data
    (p : Problem α) (A B : Agent α) :
    ∀ b ∈ B_data p A, agentSwapStep A p (agentSwapStep B p b) = b := by
  intro b hb
  rw [agentSwapStep_comp_pointwise]
  -- Now need: agentSwapStep A p b = b, but this only holds for b ∈ B_data p A.
  unfold B_data at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, _, hEq⟩ := hb
  unfold agentSwapStep
  rw [← hEq]
  show b_synth A p (b_synth A p i).s_pre.step = b_synth A p i
  rfl

/-- **A → B → C agrees with A → C on `B_data p A`.** Specialization of
the pointwise coherence to the relevant subset. -/
theorem swap_ABC_eq_swap_AC_on_B_data
    (p : Problem α) (A B C : Agent α) :
    ∀ b ∈ B_data p A,
      agentSwapStep C p (agentSwapStep B p b) = agentSwapStep C p b := by
  intro b _
  exact agentSwapStep_comp_pointwise p B C b

/-! ## (3) Three-agent prefix coherence: the bijection diagram commutes. -/

/-- **Prefix coherence**: when restricted to the common prefix of A, B, C
(i.e. `Finset.range (min N_A.toNat N_B.toNat N_C.toNat)`), the maps
A → B → C and A → C agree pointwise. -/
theorem prefix_swap_ABC_eq_swap_AC
    (p : Problem α) (A B C : Agent α) (i : ℕ) :
    agentSwapStep C p (agentSwapStep B p (b_synth A p i))
      = agentSwapStep C p (b_synth A p i) :=
  agentSwapStep_comp_pointwise p B C (b_synth A p i)

/-! ## (4) Multi-step coherence: any chain through intermediate agents. -/

/-- **List coherence (3 agents)**: A → B → C agrees with A → C on B_data p A. -/
theorem three_agent_chain_eq
    (p : Problem α) (A B C : Agent α) :
    ∀ b ∈ B_data p A,
      agentSwapStep C p (agentSwapStep B p b) = agentSwapStep C p b :=
  swap_ABC_eq_swap_AC_on_B_data p A B C

/-- **Four-agent chain coherence**: A → B → C → D agrees with A → D on
ANY input — the intermediate agents are irrelevant. -/
theorem four_agent_chain_eq
    (p : Problem α) (B C D : Agent α) (b : BarrierData α) :
    agentSwapStep D p (agentSwapStep C p (agentSwapStep B p b))
      = agentSwapStep D p b := by
  rw [agentSwapStep_comp_pointwise, agentSwapStep_comp_pointwise]

/-! ## (5) Categorical morphism: agent-swap as natural transformation. -/

/-- **Naturality**: `agentSwapStep Z p ∘ agentSwapStep Y p = agentSwapStep Z p`
as functions. -/
theorem agentSwapStep_comp_fn
    (p : Problem α) (Y Z : Agent α) :
    (agentSwapStep Z p) ∘ (agentSwapStep Y p) = agentSwapStep Z p := by
  funext b
  exact agentSwapStep_comp_pointwise p Y Z b

/-! ## (6) Image transport: applying the swap to images commutes. -/

/-- **Image-swap commutation**: applying `agentSwapStep C p` to an image
under `agentSwapStep B p` is the same as applying `agentSwapStep C p`
directly. -/
theorem image_swap_comp
    (p : Problem α) (B C : Agent α) (S : Finset (BarrierData α)) :
    (S.image (agentSwapStep B p)).image (agentSwapStep C p)
      = S.image (agentSwapStep C p) := by
  ext b
  rw [Finset.mem_image, Finset.mem_image]
  constructor
  · rintro ⟨b', hb', hEq⟩
    rw [Finset.mem_image] at hb'
    obtain ⟨b'', hb'', hEq''⟩ := hb'
    refine ⟨b'', hb'', ?_⟩
    rw [← hEq, ← hEq'']
    exact agentSwapStep_comp_pointwise p B C b''
  · rintro ⟨b', hb', hEq⟩
    refine ⟨agentSwapStep B p b', ?_, ?_⟩
    · rw [Finset.mem_image]
      exact ⟨b', hb', rfl⟩
    · rw [agentSwapStep_comp_pointwise]
      exact hEq

/-! ## (7) Image of B_data p A under swap to B, then to C, equals image
under direct swap A → C. -/

/-- **Direct image collapse**: `(B_data p A).image (agentSwapStep B p)`,
then transported by `agentSwapStep C p`, equals `(B_data p A).image (agentSwapStep C p)`. -/
theorem B_data_image_swap_chain
    (p : Problem α) (A B C : Agent α) :
    ((B_data p A).image (agentSwapStep B p)).image (agentSwapStep C p)
      = (B_data p A).image (agentSwapStep C p) :=
  image_swap_comp p B C (B_data p A)

end R2_Agent2_ThreeAgent_Coherence

end MIP
