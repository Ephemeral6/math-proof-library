# Agent 4 — Summary: Barrier combinatorics

**Direction:** Combinatorial structure of `B_data p X` as a Finset — projection
lemmas for `b_synth`, unconditional cardinality, nonempty characterisation,
atomic-decomposition sum, time-chain order, and the agent-swap bijection
between B_data sets of equal-N agents.

**Approach:** Treat `B_data p X = (range (N p X).toNat).image (b_synth X p)`
as an indexed family of synthetic barriers. The injectivity of `b_synth X p`
in its three arguments + the explicit projection identities give a complete
combinatorial calculus on barrier sets that requires no axiom beyond the
existing four (most results need none at all).

---

## Files produced

| File | STATUS | Headline |
|---|---|---|
| `Agent4_BSynth_Projections.lean` | DISCOVERY | Explicit `s_pre` / `s_post` projection simp lemmas + joint `(X,p,i)` injectivity + chain identity `(b_synth X p i).s_post = (b_synth X p (i+1)).s_pre` |
| `Agent4_BData_Card_Unconditional.lean` | DISCOVERY | `(B_data p X).card = (N p X).toNat` UNCONDITIONALLY (drops Barriers.lean's `N ≠ ⊤` hypothesis); also `Phi0 = 0 → B_data = ∅` via A.1, and the always-true B_data empty corollary |
| `Agent4_BData_Nonempty.lean` | DISCOVERY | `(B_data p X).Nonempty ↔ 0 < N p X ∧ N p X ≠ ⊤`; explicit witness `b_synth X p 0`; membership criterion `b_synth X p i ∈ B_data ↔ i < (N p X).toNat` |
| `Agent4_BData_AtomicSum.lean` | DISCOVERY | `∑ b ∈ B_data, b.atomicDecomp.card = (N p X).toNat`; biUnion of atomic decomps equals `B_data` itself |
| `Agent4_BData_Chain.lean` | DISCOVERY | `B_data` carries an order via `s_pre.step` (injective on `B_data`); step-image = `Finset.range (N.toNat)`; every member has step `< (N.toNat)` |
| `Agent4_AgentSwap_Bijection.lean` | DISCOVERY | **HEADLINE**: when `N p X = N p Y`, `agentSwapStep Y p` is a `Set.BijOn` between `B_data p X` and `B_data p Y` — canonical agent-relabelling of barrier sets |
| `Agent4_AgentSwap_Identity.lean` | DISCOVERY | Identity / composition / inverse laws for `agentSwapStep`: self-swap is `id`, swap is its own inverse, two-step swap = direct swap (groupoid structure) |
| `Agent4_pAnd_pOr_DeadEnd.lean` | DEAD END | Records that subadditivity `N (pAnd p q) X ≤ N p X + N q X` and disjunction `N (pOr p q) X ≤ min ...` are NOT derivable from A.1–A.4 alone; provides `pAnd`/`pOr` definitions, commutativity, and the always-true unit/absorption for future agents |

**Total:** 7 DISCOVERY + 1 DEAD END = 8 files. Zero sorry, zero new axiom, all compile clean.

---

## Headline results

### 1. Unconditional cardinality (extends `Barriers.lean`)

```lean
theorem B_data_card_eq_toNat (p : Problem α) (X : Agent α) :
    (B_data p X).card = (N p X).toNat
```

This drops the `N ≠ ⊤` hypothesis from `Barriers.lean`'s `B_data_card_eq_N`,
because `(⊤ : ℕ∞).toNat = 0 = (∅ : Finset _).card`. The unconditional form
is what most downstream uses actually want.

### 2. Agent-swap bijection (new structural identification)

```lean
theorem agentSwapStep_bijOn (p : Problem α) (X Y : Agent α) (hN : N p X = N p Y) :
    Set.BijOn (agentSwapStep Y p)
      (B_data p X : Set (BarrierData α))
      (B_data p Y : Set (BarrierData α))
```

Any two agents with the same emergence value on `p` have CANONICALLY
bijective barrier sets — the bijection is just "replace the agent field
in `s_pre`/`s_post` with `Y`, keep the step index". This is a structural
fact that Barriers.lean never made explicit: B_data sets are not just
equinumerous when N matches, they are canonically identified.

### 3. Time-chain structure

```lean
@[simp] theorem b_synth_chain (X : Agent α) (p : Problem α) (i : ℕ) :
    (b_synth X p i).s_post = (b_synth X p (i + 1)).s_pre
```

Consecutive synthetic barriers share an endpoint, so `B_data` is literally
a "time-stamped progress meter" — walking from step 0 to step `(N p X).toNat`.
The step-projection `s_pre.step` is injective on `B_data`, and its image is
exactly `Finset.range (N.toNat)`.

---

## Most surprising group

**Group B (agent invariance / swap) was the most surprising positive.**
The briefing flagged the agent-swap bijection as a candidate, and it
worked out cleanly — but the *identity / composition / inverse* laws also
fall out for FREE because `agentSwapStep Y p b` only depends on
`b.s_pre.step`, and `b_synth Y p` is injective. This gives B_data sets
indexed by equal-N agents the structure of a connected groupoid with
canonical morphisms — a tidy algebraic-categorical observation that goes
beyond mere equal cardinality. Worth recording for future T.7 uniqueness
work: "any model satisfying A.1-A.4 gives the same N" can now be refined
to "the barrier sets are canonically identified, not just equinumerous".

**Group C (problem composition arithmetic) was the most surprising
negative.** Even the most basic `N (pAnd p q) X ≤ N p X + N q X` is
NOT derivable from A.1-A.4. The four axioms simply don't say anything
about how `Phi0` or `R` (demandFamily) compose under boolean operations
on problems. To get this, the NL theory's R1-R4 conjectures (the ones
that make T.7 uniqueness work) would need to be added as extra
hypotheses — exactly the route `T7_Uniqueness.R3_strong` takes.

---

## Non-findings / dead ends avoided

* Did NOT redo Agent 2's `B_data_empty_iff` or `N_eq_one_iff_B_data_card_eq_one`
  (explicit cross-reference in our docstrings).
* Did NOT try to fix `B_data` at `N = ⊤` (the truncation to ∅ is a
  *concrete-model artefact* documented in Agent2_BData_Boundary;
  changing it would require modifying `Barriers.lean`).
* Did NOT attempt sub-/super-additivity of N under problem composition —
  the obstacle is documented in `Agent4_pAnd_pOr_DeadEnd.lean`.
