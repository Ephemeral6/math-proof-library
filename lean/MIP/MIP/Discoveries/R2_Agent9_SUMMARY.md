# R2 Agent 9 — Summary: lattice / poset structure on `B_data`

**Direction:** Build on Round-1 Agent 4's combinatorial discoveries
(`s_pre.step` is an injective indexing of `B_data p X` into
`Finset.range (N p X).toNat`) to extract the full order-theoretic
structure on `B_data p X`: order isomorphism into a finite linear
range, min/max elements, successor/predecessor maps, orthogonality of
`B_data` sets across distinct agents or problems, the filtered subset
"below step `k`", and the global step-class decomposition.

**Approach:** Every element of `B_data p X` has the unique form
`b_synth X p i` (Agent 4), so `B_data` is canonically identified with
`Finset.range (N p X).toNat` via the step projection. All order facts
on `B_data` reduce to order facts on `ℕ`. Orthogonality across agents
or problems follows from the joint `(X, p, i)`-injectivity of `b_synth`
combined with the projection of `s_pre.agent` and `s_pre.problem`.

---

## Files produced

| File | STATUS | Headline |
|---|---|---|
| `R2_Agent9_BData_OrderIso_Range.lean` | DISCOVERY | `Set.BijOn stepProj (B_data p X) (Finset.range (N p X).toNat)`; step projection respects ≤ |
| `R2_Agent9_BData_MinMax.lean` | DISCOVERY | Min step = 0, max step = `(N p X).toNat - 1`; the unique barriers with those step values are `b_synth X p 0` / `b_synth X p ((N p X).toNat - 1)` |
| `R2_Agent9_BData_Successor.lean` | DISCOVERY | `next` / `prev` maps; `prev (next b) = b` on `B_data`; `next (prev b) = b` on `B_data` restricted to step ≥ 1; injectivity of both; chain identity `(next b).s_pre = b.s_post` |
| `R2_Agent9_BData_OrthogonalAcrossAgents.lean` | DISCOVERY | `X ≠ Y → Disjoint (B_data p X) (B_data p Y)`; symmetric statement for problems; `|B_data p X ∪ B_data p Y| = (N p X).toNat + (N p Y).toNat`; three-way card identity |
| `R2_Agent9_BData_BelowK_Filter.lean` | DISCOVERY | `B_data_below_k p X k = image of Finset.range (min k (N p X).toNat)`; card formula; monotonicity in `k`; boundary cases (`k = 0` empty, `k ≥ (N p X).toNat` whole `B_data`) |
| `R2_Agent9_BData_StepClass.lean` | DISCOVERY | Global step-class partition: each step-`k` slice is empty (if `k ≥ (N p X).toNat`) or a singleton (if `k < ...`); disjoint across step values; covers `B_data` |

**Total:** 6 DISCOVERY files. Zero `sorry`, zero new `axiom`, all
compile clean.

---

## Headline results

### 1. Order isomorphism into a finite range

```lean
theorem stepProj_bijOn (p : Problem α) (X : Agent α) :
    Set.BijOn stepProj
      (B_data p X : Set (BarrierData α))
      (↑(Finset.range (N p X).toNat) : Set ℕ)
```

`B_data p X` is canonically a linearly-ordered timeline of length
`(N p X).toNat` via the step projection. This makes precise the "time
chain" interpretation initiated in Agent 4's `Agent4_BData_Chain.lean`.

### 2. Orthogonality across distinct agents

```lean
theorem B_data_disjoint_of_agent_ne (p : Problem α) (X Y : Agent α)
    (hXY : X ≠ Y) :
    Disjoint (B_data p X) (B_data p Y)
```

Barrier sets of distinct agents share no element — every barrier carries
its source agent in `s_pre.agent`. This is the dual of Agent 4's
`agentSwap` bijection: the bijection exists *between* sets, and the
sets themselves don't overlap. Together they give the "agent-fibre"
structure: `B_data p (·)` is a family of pairwise disjoint Finsets of
known cardinality, indexed by `Agent α`.

### 3. Global step-class decomposition

```lean
theorem B_data_eq_biUnion_step_class (p : Problem α) (X : Agent α) :
    B_data p X
      = (Finset.range (N p X).toNat).biUnion (fun k => step_class p X k)
```

`B_data` is the disjoint union of its step-classes, each of which is
a singleton `{b_synth X p k}`. This is the categorical "indexing"
form of Agent 4's image presentation of `B_data`.

---

## Non-findings / explicit non-attempts

* Did NOT build a `LinearOrder` *instance* on `BarrierData α`. As the
  briefing noted, `BarrierData α` has no canonical order (it's a
  general structure with subterms of opaque types), so the order is
  recorded *extrinsically* via the step projection, not as a typeclass.
* Did NOT build a `Lattice` instance on `BarrierData α` — same reason.
* Did NOT explore the `ω`-side (B_data × Ω) — the briefing explicitly
  flagged this as out of scope, since `b.s_pre` is an `InternalState`,
  not an `Ω`-valued thing.
* The successor/predecessor maps are *not* mutual inverses on all of
  `BarrierData α` (only on `B_data p X` with the appropriate step
  restriction). On general `BarrierData α`, `prev (next b)` may not
  equal `b` because `b.s_pre.step` might be any natural, but
  `prev`-then-`next` would round-trip through `b_synth`.

---

## Cross-references

* `Agent4_BData_Chain.lean` — original step-injectivity proof; we
  extend with order compatibility and step image identification.
* `Agent4_BData_Card_Unconditional.lean` — used directly in the
  union-card proofs.
* `Agent4_BSynth_Projections.lean` — `b_synth` joint injectivity used
  in orthogonality proofs.
* `Agent4_AgentSwap_Bijection.lean` — agent-swap is a *map between*
  disjoint sets across distinct agents (our orthogonality is the
  complementary fact).
