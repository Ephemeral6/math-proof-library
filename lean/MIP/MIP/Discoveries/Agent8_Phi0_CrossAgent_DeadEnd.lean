/-
  STATUS: DEAD END
  AGENT: 8
  DIRECTION: Can `K A = K B` (with A.4) force `Phi0 A p = Phi0 B p`?
             — NO. A.4 only swaps tokens within ONE agent.
  SUMMARY:
    A natural multi-agent question: if `K A = K B`, do the two agents
    have the same emergence potential `Phi0` on every problem?

    The intuition: A.4 says ω ∉ K X → X h = X (τ_ω h). With K A = K B,
    the "inert tokens" coincide; so any history `h` can be reduced
    (via successive A.4 token-replacements) to a "K-essential" core
    that both A and B handle identically?

    **This argument fails.** A.4 is a per-agent statement. It says
    `X h = X (τ_ω h)` for a *single* agent X — it does NOT say
    `A h = B h` or `A h = B (τ_ω h)`. Two agents with the same `K` can
    have arbitrarily different response distributions on K-essential
    histories. The token-reduction reduces each agent's behavior to its
    own "K-essential core", but the cores can still differ.

    Consequently:
    (a) A.4 + (K A = K B) does NOT imply `Phi0 A p = Phi0 B p`.
    (b) Even the weaker `Phi0 A p = 0 ↔ Phi0 B p = 0` is not derivable
        from K-equality alone; it needs a *behavioral* bridge (which
        `Agent1_A1A4_Phi0Invariance.phi0_zero_iff_N_zero_across_A4_orbit`
        carries explicitly as `hPhiBridge`).

    What IS derivable: `K A = K B → (N p A ≠ ⊤ ↔ N p B ≠ ⊤)` (the
    *finiteness verdict* equivalence). This is
    `Agent1_A1A2A4_TrivialProblemCoverage.N_ne_top_invariant_under_K_eq`.
    The asymmetry — coverage transfers but Phi0 does not — is the key
    obstruction.

    This file documents the negative finding; no theorems are produced
    because the statement we wanted is precisely NOT derivable.
-/
import MIP.Axioms

namespace MIP

namespace Agent8_Phi0_CrossAgent_DeadEnd

/-! ## (1) The desired statement that is NOT a theorem.

We do NOT claim:

  `(K A = K B) → ∀ p, Phi0 A p = Phi0 B p`

This is false in general — A.4 does not constrain cross-agent
response distributions.

We also do NOT claim:

  `(K A = K B) → ∀ p, Phi0 A p = 0 ↔ Phi0 B p = 0`

This is also not derivable — the iff requires a behavioral bridge
beyond K-equality. -/

/-- Recording the dead end as a `True` placeholder; the analytical
content is in the doc comment above. -/
example : True := trivial

/-! ## (2) What CAN be salvaged from this exploration.

The relationship `Phi0 A p = Phi0 B p` is the precise bridge that
`Agent1_A1A4_Phi0Invariance` requires as a hypothesis to conclude
`Phi0 A p = 0 ↔ N p B = 0`. So this dead end is, in retrospect, the
*motivation* for why that file carries a `hPhiBridge` hypothesis — the
bridge cannot be derived from A.4 + K-equality.

The cleanest companion DISCOVERY at this same boundary is:
`Agent8_WeakPhi0Symmetry.N_zero_both_of_phi0_zero_both` — which derives
N = 0 for both agents from Phi0 = 0 for both agents, requiring no
bridge but also no cross-agent equality of Phi0. -/

end Agent8_Phi0_CrossAgent_DeadEnd

end MIP
