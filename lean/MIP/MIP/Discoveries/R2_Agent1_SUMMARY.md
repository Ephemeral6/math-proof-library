# R2 Agent 1 — Summary: Trichotomy regime corollaries

**Direction:** Round 1 (Agent 2) proved the unconditional N-trichotomy
(R0 / RP / R∞) and Round 1 (Agent 9) showed exactly 3 of 12 (N, Φ₀, cov)
configurations are realisable.  R2 Agent 1 drilled in: starting from each
regime, what *joint* constraints does it force on B_data / Z / T.8 Ohm
prediction / Phi_state / Phi_decrement?  And does the regime constrain
the activation distribution `d` at all? (Answer to the last: no.)

---

## Files produced (6)

| File | STATUS | Headline |
|---|---|---|
| `R2_Agent1_BSynthStep.lean` | DISCOVERY | `(b_synth X p 0).s_pre.step = 0` unconditionally — three regime packagings collapse to the same identity (briefing question answered: regime doesn't sharpen) |
| `R2_Agent1_R0_JointFacts.lean` | DISCOVERY | **R0 bundle:** `N=0 → Phi0=0 ∧ B_data=∅ ∧ Phi0·Z=0 ∧ T.8 Ohm holds ∧ Phi_state⟨X,p,k⟩=0 ∧ coverage` |
| `R2_Agent1_RP_JointFacts.lean` | DISCOVERY | **RP bundle:** `0<N<⊤ → Phi0≠0 ∧ |B_data|=N.toNat≥1 ∧ b_synth X p 0 ∈ B_data ∧ ⌈Phi0·Z⌉<N ∧ coverage` (strict T.8 undershoot, RP-only fact) |
| `R2_Agent1_Rinf_JointFacts.lean` | DISCOVERY | **R∞ bundle:** `N=⊤ → Phi0≠0 ∧ B_data=∅ ∧ ⌈Phi0·Z⌉<⊤=N ∧ ¬coverage`, plus headline **`B_data_empty_split`**: `B_data=∅ → (R0 or R∞), split by Phi0` |
| `R2_Agent1_T8_RegimeSplit.lean` | DISCOVERY | **HEADLINE T.8 verdict by regime:** Ohm-law strict-eq holds iff R0; in RP and R∞ the ceiling strictly undershoots N; **`T8_R0_double_sharp`** = both T.8 bounds collapse to 0 in R0 |
| `R2_Agent1_RegimeFromBData.lean` | DISCOVERY | **Reverse classifier:** read regime off `(B_data, Phi0)` flags. Three biconditionals: R0 ↔ (B_data=∅ ∧ Phi0=0), RP ↔ B_data≠∅, R∞ ↔ (B_data=∅ ∧ Phi0≠0). |
| `R2_Agent1_PhiState_Regime.lean` | DISCOVERY | **Phi_state regime collapse:** R0 → Phi_state ≡ 0; R∞ → Phi_state ≡ Phi0; only RP has non-constant Phi_state in k. Plus Phi_decrement = 0 in both extreme regimes. |
| `R2_Agent1_ActivationDist_Free.lean` | OBSERVATION | **Negative result:** regime does NOT constrain activation distributions. From `N p X = 0/⊤` alone you cannot derive anything about `H_K(d)` or `KL_to_uniform(d)`. Briefing's predicted answer confirmed. |

**Total:** 7 DISCOVERY files + 1 OBSERVATION file = 8 files.  All
zero-sorry, zero-new-axiom, all compile.

---

## Headline results (selected)

### 1. **B_data_empty_split** (R2_Agent1_Rinf_JointFacts.lean)

```lean
theorem B_data_empty_split (p : Problem α) (X : Agent α) (h_emp : B_data p X = ∅) :
    (Phi0 X p = 0 ∧ N p X = 0) ∨ (Phi0 X p ≠ 0 ∧ N p X = ⊤)
```

The model-artefact observation from Agent 2 that "B_data = ∅ in both R0
and R∞" gets *separated*: which side you're on is determined by Phi0.

### 2. **T8_verdict_by_regime** (R2_Agent1_T8_RegimeSplit.lean)

```lean
theorem T8_verdict_by_regime (p : Problem α) (X : Agent α) :
    (N p X = 0 ∧ N p X = ceilENat (Phi0 X p * Z X p))
      ∨ (0 < N p X ∧ ceilENat (Phi0 X p * Z X p) < N p X)
```

T.8 Ohm-law strict-equality form holds *exactly* in R0; in RP and R∞ it
strictly undershoots.  This is the regime-keyed sharpening of Agent 5's
`T8_Ohm_holds_iff_Phi0_zero`.

### 3. **R0_iff_observable** / **Rinf_iff_observable** / **RP_iff_observable** (RegimeFromBData)

The trichotomy regime can be *read off* from the observable
`(B_data status, Phi0 status)`:

```lean
N p X = 0   ↔ B_data p X = ∅ ∧ Phi0 X p = 0
0<N p X<⊤  ↔ (B_data p X).Nonempty
N p X = ⊤   ↔ B_data p X = ∅ ∧ Phi0 X p ≠ 0
```

This is a *decidable-style* classifier even though `N` itself is opaque
ℕ∞.

### 4. **PhiState_constant_in_extreme_regimes** (PhiState_Regime)

R0 collapses `Phi_state ⟨X, p, k⟩` to constant `0`.
R∞ collapses it to constant `Phi0 X p`.
Only RP has non-trivial step-dependent behaviour.

### 5. **regime_is_d_blind** (ActivationDist_Free) — OBSERVATION

A.1–A.4 do not couple Φ₀/N to `d`, so the regime imposes nothing on
the activation distribution.  Formalised as: the regime hypothesis
appears in the implication but not in the conclusion (which uses only
`d.normalized`).

---

## Cross-cutting observations

1. **The "regime conditioning" of `b_synth X p 0`'s s_pre.step is vacuous.**
   The briefing asked whether each regime forces a unique value;
   answer: yes, the value is `0`, but *unconditionally* — the three
   regime-conditional theorems collapse to the same `rfl`.  Recorded as
   a deliberate non-finding.

2. **B_data ↔ regime in three observable biconditionals.**  This is the
   cleanest reverse direction we got: each trichotomy cell is uniquely
   determined by the `(B_data emptiness, Phi0 zeroness)` Boolean
   2-tuple.

3. **RP is the only regime with non-trivial state-sequence dynamics.**
   In R0 and R∞, `Phi_state` is constant in `k`.  Only RP has the
   piecewise-constant drop at `k = (N p X).toNat`.

4. **R0 is the only regime where T.8 holds.**  The lower bound, the
   strict-equality Ohm form, AND the upper bound all collapse to the
   joint equality `0 = N = ⌈Phi0 · Z_min⌉ = ⌈Phi0 · Z⌉ = ⌈Phi0 · Z_max⌉
   = 0` in R0.  In RP and R∞ the lower side strictly under-shoots.

5. **Activation distributions are decoupled from trichotomy regime.**
   This is a useful *negative* fact for downstream agents: do not
   attempt "in regime R0, `H_K = ...`"-style theorems without
   strengthening A.1–A.4.

---

## Non-findings / dead ends avoided

* Did NOT redo Agent 9's `Agent9_BData_Phi0_Impossibilities` chains —
  cross-referenced and re-packaged in joint-positive form (bundles)
  rather than as `False`-conclusions.
* Did NOT introduce a new `Z` model — Agent 5's `Z = Z_min = 0`,
  `Z_max = ⊤` choice was used as-is.
* Did NOT re-prove the trichotomy itself — used it as imported lemma.
* Did NOT touch `KL_to_uniform` or `knowledgeEntropy`'s value side —
  only the *independence* direction.  The positive-value computations
  are Agent 3/6/10's territory.

---

## Theorem count

- **R0 bundle:** 6 sharp theorems + 1 bundle = 7
- **RP bundle:** 8 sharp theorems + 1 bundle = 9
- **R∞ bundle:** 7 sharp theorems + 1 bundle + 1 cross-regime split = 9
- **T.8 regime split:** 5 sharp theorems + 1 master verdict = 6
- **Regime from B_data:** 3 forward + 3 biconditional + 1 master = 7
- **b_synth step:** 3 unconditional + 3 regime-tagged + 2 last-index = 8
- **Phi_state regime:** 5 case theorems + 1 headline + 2 Phi_decrement = 8
- **ActivationDist free (OBSERVATION):** 6 negative-result theorems

**Total: 60 new theorems** across 8 files.
