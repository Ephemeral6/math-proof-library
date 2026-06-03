# Agent 2 — Summary: Extreme values of N

**Direction:** Investigate what other physical quantities are forced when
`N p X` takes a boundary value: `N = 0`, `N = 1`, `N = ⊤`.

**Approach:** Combine A.1 (`N = 0 ↔ Phi0 = 0`) and A.2 (`N ≠ ⊤ ↔ ∃ R' ∈ ℛ(p), R' ⊆ K X`)
to characterise each boundary regime by forced values of `Phi0`, demand
coverage, and (for the concrete model) the barrier set `B_data`.

---

## Files produced

| File | STATUS | Headline |
|---|---|---|
| `Agent2_NZero_Chain.lean` | DISCOVERY | `N = 0 → Phi0 = 0 ∧ coverage`, full chain restating A.1 + A.2 around the trivially-solvable regime |
| `Agent2_AlwaysTrue_NZero.lean` | DISCOVERY | `N (fun _ => true) X = 0` for every agent X (combining `Phi0_always_true` and A.1) |
| `Agent2_NTop_Chain.lean` | DISCOVERY | `N p X = ⊤ ↔ ∀ R' ∈ ℛ(p), ¬ R' ⊆ K X` (full A.2-contrapositive biconditional) |
| `Agent2_NTrichotomy_Full.lean` | DISCOVERY | **HEADLINE**: unconditional N trichotomy (R0 / RP / R∞) — proven from A.1 + A.2 alone |
| `Agent2_BData_Boundary.lean` | DISCOVERY | `B_data = ∅ ↔ N = 0 ∨ N = ⊤`; `N = 1 ↔ \|B_data\| = 1` |
| `Agent2_NOne_Regime.lean` | DISCOVERY | `N = 1 → Phi0 ≠ 0 ∧ coverage ∧ 0 < N < ⊤` (and the generalisation to any positive finite n) |

**Total:** 6 DISCOVERY files. Zero OBSERVATION, zero DEAD END. All zero-sorry, zero-new-axiom.

---

## Headline result

```lean
theorem N_trichotomy (p : Problem α) (X : Agent α) :
    (N p X = 0 ∧ Phi0 X p = 0
        ∧ (∃ R' ∈ ℛ(p), R' ⊆ K X))                          -- (R0) trivially solvable
      ∨ (0 < N p X ∧ N p X < ⊤ ∧ Phi0 X p ≠ 0
        ∧ (∃ R' ∈ ℛ(p), R' ⊆ K X))                          -- (RP) positively emergent
      ∨ (N p X = ⊤ ∧ Phi0 X p ≠ 0
        ∧ ∀ R' ∈ ℛ(p), ¬ R' ⊆ K X)                          -- (R∞) knowledge-deficient
```

Provable from A.1 + A.2 alone. Agent 1 proved a **coverage-conditional dichotomy**;
this is the **unconditional trichotomy** spanning all three regimes.

---

## Cross-cutting observations

1. **`B_data` collapses at both boundaries.** In the concrete model,
   `(N p X).toNat = 0` for BOTH `N = 0` and `N = ⊤`, so `B_data = ∅`
   characterises *the union* of the trivially-solvable and
   knowledge-deficient regimes. Cardinality alone cannot distinguish them
   — Phi0 (via A.1) does. This is a model-artefact observation worth
   recording.

2. **N = 1 is non-trivially "interior":** it forces simultaneously
   `Phi0 ≠ 0`, coverage, `0 < N`, `N < ⊤`, and `|B_data| = 1`. Of all the
   `ℕ∞` values, `N = 1` is the "smallest positive emergence" regime —
   one-shot solvable.

3. **`Phi0 ≠ 0`, not `> 0`.** The trichotomy uses `≠ 0` rather than `> 0`
   because the latter requires `Phi0 ≠ ⊤` in ENNReal, which is NOT forced
   by A.1 + A.2 alone (Phi0 = ⊤ is consistent with `N = ⊤` since A.1 is
   only the `= 0` boundary). This was a careful pitfall flagged in the
   briefing.

4. **Always-true universal.** The Lean codebase already used
   `N (fun _ => true) X = 0` inline in T18.2's NP-hard proof but never
   stated it as a clean lemma. We make it a one-line standalone discovery
   plus a universal-`X` form.

---

## Non-findings / dead ends avoided

* Did NOT try to prove `Phi0 X p > 0 ↔ N p X > 0` — would need
  `Phi0 ≠ ⊤` as a hypothesis, not derivable.
* Did NOT redo Agent 1's `coverage_of_phi0_zero`, `N_top_of_no_coverage`,
  `N_positive_finite_of_coverage_and_nonzero`, `N_trichotomy_under_coverage`
  — explicitly cross-referenced in `Agent2_NZero_Chain.lean` and
  `Agent2_NTrichotomy_Full.lean` docstrings.
