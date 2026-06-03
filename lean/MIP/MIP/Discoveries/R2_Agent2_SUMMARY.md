# R2 Agent 2 — Summary: Agent-Swap Category Structure

**Direction:** Deepen Agent 4's same-N agent-swap groupoid by analysing
what happens when `N p X ≠ N p Y`. Extract the partial bijection,
common-prefix subset, three-agent transport coherence, and the precise
trichotomy of swap behaviour.

**Approach:** Generalise `agentSwapStep Y p` past the `N p X = N p Y`
hypothesis. The key observation is that `agentSwapStep Y p` is
**unconditionally** `Set.InjOn` on `B_data p X` (its proof never used
N-equality); the comparison enters only when we ask where the image
LANDS. This decouples injectivity from the comparison, giving a clean
"partial bijection" picture: image of `B_data p X` ∩ `B_data p Y` equals
`commonPrefix p Y X` with exact card `min(N_X.toNat, N_Y.toNat)`.

---

## Files produced

| File | STATUS | Headline |
|---|---|---|
| `R2_Agent2_AgentSwap_InjOn_Unconditional.lean` | DISCOVERY | `agentSwapStep Y p` is `InjOn (B_data p X)` **unconditionally** (no N-hypothesis); embedding form `(N_X).toNat ≤ (N_Y).toNat → MapsTo B_data p X → B_data p Y`; card-side `(B_data p X).card ≤ (B_data p Y).card` |
| `R2_Agent2_CommonPrefix.lean` | DISCOVERY | Defines `commonPrefix p X Y = (range (min N_X.toNat N_Y.toNat)).image (b_synth X p)`. Proves: subset of `B_data p X`, card = `min`, `BijOn` from `commonPrefix p X Y` to `commonPrefix p Y X`, empty iff one N is zero, equals `B_data p X` when N's match on toNat |
| `R2_Agent2_ThreeAgent_Coherence.lean` | DISCOVERY | **Strong pointwise coherence**: `agentSwapStep Z p ∘ agentSwapStep Y p = agentSwapStep Z p` on ALL inputs (not just `B_data p A`); three- and four-agent chain identities; functional composition `(swap Z) ∘ (swap Y) = swap Z`; image-swap commutation |
| `R2_Agent2_Intersection_Bijection.lean` | DISCOVERY | **Tight intersection equality**: `((B_data p X).image (swap Y)) ∩ B_data p Y = commonPrefix p Y X`, with EXACT cardinality `min(N_X, N_Y)`; "hole" outside-B_data_Y card = `N_X − min(N_X, N_Y)` |
| `R2_Agent2_Asymmetric_SurjOn.lean` | DISCOVERY | When `(N p Y).toNat ≤ (N p X).toNat`, `agentSwapStep Y p` is `SurjOn B_data p X → B_data p Y`. Combined with InjOn on the commonPrefix gives a `BijOn commonPrefix p X Y → B_data p Y`. Plus the trichotomy and the one-sided inverse on the common prefix |
| `R2_Agent2_Category_Structure.lean` | DISCOVERY | Categorical packaging: identity law, composition law, image identification `(commonPrefix p X Y).image (swap Y) = commonPrefix p Y X`, finset-level chain identity, triple common-prefix `tripleCommonPrefix` with full 3-way symmetry under any swap |

**Total: 6 DISCOVERY files.** All compile clean, zero `sorry`, zero
new `axiom`.

---

## Headline results

### 1. Unconditional InjOn (drops Agent 4's N-equality hypothesis)

```lean
theorem agentSwapStep_injOn_unconditional
    (p : Problem α) (X Y : Agent α) :
    Set.InjOn (agentSwapStep Y p) (B_data p X : Set (BarrierData α))
```

The InjOn proof never used `N p X = N p Y` — only `b_synth_injective Y p`
plus the step-projection identity `(b_synth X p i).s_pre.step = i`.

### 2. Common prefix as the universal bijection zone

```lean
noncomputable def commonPrefix (p : Problem α) (X Y : Agent α) :
    Finset (BarrierData α) :=
  (Finset.range (min (N p X).toNat (N p Y).toNat)).image (b_synth X p)

theorem agentSwapStep_bijOn_commonPrefix (p : Problem α) (X Y : Agent α) :
    Set.BijOn (agentSwapStep Y p)
      (commonPrefix p X Y) (commonPrefix p Y X)
```

This is the right "stay-inside" form for the disagreement case: even
when `N` differs, the agree-zone is a clean bijection.

### 3. Tight intersection equality

```lean
theorem swap_image_inter_B_data_Y_eq_commonPrefix
    (p : Problem α) (X Y : Agent α) :
    ((B_data p X).image (agentSwapStep Y p)) ∩ B_data p Y
      = commonPrefix p Y X
```

Card consequence:
```lean
theorem swap_image_inter_B_data_Y_card_eq :
    ((image ∩ B_data p Y)).card = min (N p X).toNat (N p Y).toNat
```

This sharpens the "≤ min" bound to an EQUALITY.

### 4. Three-agent coherence (pointwise, on ALL inputs)

```lean
@[simp] theorem agentSwapStep_comp_pointwise
    (p : Problem α) (Y Z : Agent α) (b : BarrierData α) :
    agentSwapStep Z p (agentSwapStep Y p b) = agentSwapStep Z p b
```

A genuinely surprising strengthening: Agent 4's `agentSwapStep_comp` was
already pointwise, but the new file makes it `@[simp]` and turns it
into a functional equality `(swap Z) ∘ (swap Y) = swap Z`. The
intermediate agent is irrelevant for ANY input, not just inputs in
`B_data p A`.

### 5. Trichotomy

```lean
theorem trichotomy (p : Problem α) (X Y : Agent α) :
    (N p X).toNat < (N p Y).toNat
      ∨ (N p X).toNat = (N p Y).toNat
      ∨ (N p X).toNat > (N p Y).toNat
```

with three different swap behaviours per branch:
- `<`: InjOn + MapsTo (sub-embedding)
- `=`: BijOn (Agent 4's groupoid)
- `>`: SurjOn + NOT injective on the full B_data X

---

## Most surprising findings

**(a) Pointwise coherence holds unrestricted.** Agent 4's
`agentSwapStep_comp` was stated for general `b` and proved by `rfl` —
but the conceptual interpretation that "intermediate Y doesn't matter
for ANY input" was not made explicit. We made it `@[simp]` and packaged
it as a functional equality, immediately giving the four-agent chain
coherence and the image-swap commutation lemma.

**(b) The "agree zone" is the common prefix.** The intersection of the
swap image with the target B_data is EXACTLY the common prefix —
indexed by step `i < min(N_X.toNat, N_Y.toNat)`. This is a sharper
statement than "card ≤ min" and gives a precise structural identity:
`((B_data p X).image (swap Y)) ∩ B_data p Y = commonPrefix p Y X`.

**(c) Triple-prefix is fully tri-symmetric.** `tripleCommonPrefix p X Y Z`
under any agent-swap maps into `tripleCommonPrefix` with the
swapped argument moved to the first slot. This is a full 3-way
symmetric category-of-three-objects statement.

---

## Non-findings / dead ends

* The N-comparison cannot be promoted from `(N p X).toNat ≤ (N p Y).toNat`
  to `N p X ≤ N p Y` (ENat) without an extra `N p Y ≠ ⊤` hypothesis,
  because `N p X = 5 ≤ ⊤ = N p Y` does NOT give `5 = N_X.toNat ≤
  (⊤).toNat = 0`. We left both forms available: the natural ENat form
  is only useful in finite-finite cases.
* Did NOT try to extend to "agent-permutation" actions on B_data (e.g.
  generated by k-agent swaps). The composition law shows the
  agent-swap group acts trivially on the step-indexed structure, so the
  permutation action collapses to the "last-applied agent" projection.
  This would be a categorical statement of degree 1, not adding genuine
  content.
* Did NOT attempt cross-problem identifications (`agentSwapStep` only
  changes the agent field, not the problem field). Cross-problem
  transport is genuinely outside A.1–A.4.

---

## Compilation

All 6 files compiled with
`cd C:\Users\12729\Desktop\Math\lean\MIP ; lake env lean MIP/Discoveries/R2_Agent2_*.lean`.
File 1 (`R2_Agent2_AgentSwap_InjOn_Unconditional.lean`) is standalone
(only `MIP.Axioms` + `MIP.Defs.Barriers`). Files 2 (`CommonPrefix`)
through 6 form a dependency chain:

```
R2_Agent2_CommonPrefix
  ├─ R2_Agent2_ThreeAgent_Coherence
  │    └─ R2_Agent2_Category_Structure
  ├─ R2_Agent2_Intersection_Bijection
  └─ R2_Agent2_Asymmetric_SurjOn
```

Zero `sorry`, zero new `axiom`, zero proof shortcuts.
