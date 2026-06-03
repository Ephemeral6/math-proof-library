/-
  STATUS: DISCOVERY
  AGENT: 4
  DIRECTION: Identities and inverses for the `agentSwapStep` bijection.
  SUMMARY:
    Building on `Agent4_AgentSwap_Bijection`: the agent-swap map
    `agentSwapStep Y p` from `B_data p X` to `B_data p Y` satisfies
    natural identities. Specifically:
      * `agentSwapStep X p` restricted to `B_data p X` is the identity.
      * Two-step swap `X ↦ Y ↦ Z` equals the direct `X ↦ Z` swap.
      * The swap `X ↔ Y` and back (`Y ↔ X`) returns to the original
        barrier — i.e. the bijection composed with its inverse is the
        identity on `B_data p X`.
    These exhibit the "groupoid" structure on barrier sets indexed by
    agents with a fixed N value: B_data sets are isomorphic, with
    canonical isomorphisms that compose coherently.
-/
import MIP.Axioms
import MIP.Defs.Barriers

namespace MIP

namespace Agent4_AgentSwap_Identity

variable {α : Type}

/-- Local copy of `agentSwapStep` to avoid cross-file dependency at the
.olean level. -/
noncomputable def agentSwapStep (Y : Agent α) (p : Problem α)
    (b : BarrierData α) : BarrierData α :=
  b_synth Y p b.s_pre.step

/-! ## (1) Identity: swap-to-self on `B_data p X` is `id`. -/

/-- **Self-swap is identity on `B_data p X`.** Every barrier in
`B_data p X` has the form `b_synth X p i`, so `agentSwapStep X p` sends
it back to `b_synth X p (b_synth X p i).s_pre.step = b_synth X p i`. -/
theorem agentSwapStep_self_eq
    (p : Problem α) (X : Agent α) :
    ∀ b ∈ B_data p X, agentSwapStep X p b = b := by
  intro b hb
  unfold B_data at hb
  rw [Finset.mem_image] at hb
  obtain ⟨i, _, hEq⟩ := hb
  unfold agentSwapStep
  rw [← hEq]
  -- (b_synth X p i).s_pre.step = i
  show b_synth X p (b_synth X p i).s_pre.step = b_synth X p i
  have : (b_synth X p i).s_pre.step = i := rfl
  rw [this]

/-! ## (2) Composition law: agentSwapStep X→Y→Z = agentSwapStep X→Z. -/

/-- **Composition of swaps**: `agentSwapStep Z p ∘ agentSwapStep Y p` is
the same as the direct swap to `Z`. The intermediate agent `Y` doesn't
matter — what matters is the step preservation. -/
theorem agentSwapStep_comp
    (p : Problem α) (Y Z : Agent α) (b : BarrierData α) :
    agentSwapStep Z p (agentSwapStep Y p b) = agentSwapStep Z p b := by
  unfold agentSwapStep
  -- (b_synth Y p b.s_pre.step).s_pre.step = b.s_pre.step
  have : (b_synth Y p b.s_pre.step).s_pre.step = b.s_pre.step := rfl
  rw [this]

/-! ## (3) Inverse law: swap to `Y` then back to `X` is identity on
`B_data p X`. -/

/-- **Inverse law**: swap to `Y` then back to `X` returns each barrier in
`B_data p X` to itself. -/
theorem agentSwapStep_inverse
    (p : Problem α) (X Y : Agent α) :
    ∀ b ∈ B_data p X, agentSwapStep X p (agentSwapStep Y p b) = b := by
  intro b hb
  rw [agentSwapStep_comp]
  exact agentSwapStep_self_eq p X b hb

/-! ## (4) Step preservation: agentSwap preserves `s_pre.step`. -/

/-- **Step preservation**: `agentSwapStep Y p` does not change the step
index. -/
@[simp] theorem agentSwapStep_pre_step
    (Y : Agent α) (p : Problem α) (b : BarrierData α) :
    (agentSwapStep Y p b).s_pre.step = b.s_pre.step := rfl

/-! ## (5) Agent-change visible on `s_pre`. -/

/-- **Agent after swap**: the swap changes the `s_pre.agent` field to `Y`. -/
@[simp] theorem agentSwapStep_pre_agent
    (Y : Agent α) (p : Problem α) (b : BarrierData α) :
    (agentSwapStep Y p b).s_pre.agent = Y := rfl

/-- **Problem after swap**: the problem is `p` (the input). -/
@[simp] theorem agentSwapStep_pre_problem
    (Y : Agent α) (p : Problem α) (b : BarrierData α) :
    (agentSwapStep Y p b).s_pre.problem = p := rfl

end Agent4_AgentSwap_Identity

end MIP
