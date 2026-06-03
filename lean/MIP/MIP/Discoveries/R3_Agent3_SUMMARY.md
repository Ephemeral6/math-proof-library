# R3 Agent 3 — Phase-Transition Family

**Group focus:** Phase-transition family.
**Source results:** T.30 (PhaseTransition), R.79 (Grokking), R.80
(GrokkingCrossing), R.97 (TwoPhaseTransitions), R.98 (GompertzKappa),
R.102 (UnimodalTransition), R.193 (DecayLearnTransition), R.81ab
(DoubleDescentSplit), R.518 (DecayGrokkingSuppression).

All theorems below are zero-sorry, zero-new-axiom Lean 4 lemmas in the
`MIP` namespace. Each file imports ≥ 2 R-results.

---

## File 1 — `R3_Agent3_PhaseTimeOrdering.lean`

**Chain: T.30 + R.97 (case A).**  Cross-derivation of the two
phase-transition times.

| Theorem | Statement | Depends on |
| --- | --- | --- |
| `phase_ordering_t_cov_lt_t_aut` | T.30 prereq ⇒ `t_cov < t_aut` | T.30 |
| `phase_ordering_quantitative` | T.30 + R.97 κ-decay threshold ⇒ ordering AND gap = log(r/δ)/α_κ | T.30, R.97 |
| `phase_ordering_double_witness` | Two independent proofs of `t_cov < t_aut` agree | T.30, R.97 |
| `middle_phase_positive_duration` | Both sub-gaps of T.30 are positive, sum = R.97 gap | T.30, R.97 |

---

## File 2 — `R3_Agent3_CrossingSuppression.lean`

**Chain: R.79 + R.80 + R.518 (case B).**  Decay-suppression of the
grokking crossing.

| Theorem | Statement | Depends on |
| --- | --- | --- |
| `crossing_point_suppressed_by_decay` | `τ̄ < τ̄_c` + κ-bound ⇒ `κ_t < κc² ∀ t` | R.518, R.80 |
| `R80_crossing_premise_fails` | Under suppression, no `t` with `κc² ≤ κ_t t` | R.80, R.518 |
| `covered_set_empty_under_decay` | R.80's `covered` predicate universally false | R.80, R.518 |
| `R79_threshold_no_input_under_decay` | R.79's `eventually-covered` hypothesis fails on discrete times | R.79, R.518 |
| **HEADLINE: `grokking_suppressed_three_chain`** | All three suppression facts together (R.80 crossing premise fails, covered set empty, R.79 discrete input fails) | R.79, R.80, R.518 |

---

## File 3 — `R3_Agent3_GompertzAtDecayTransition.lean`

**Chain: R.98 + R.193 (case C).**  Gompertz κ value at the R.193
characteristic time.

| Theorem | Statement | Depends on |
| --- | --- | --- |
| `kappa_at_one_efold_decay` | `κ(τ̄ + t_c) = exp(log κ₀ · exp(-α·τ̄))` | R.98, R.193 |
| `gompertz_ode_at_one_efold` | R.98's ODE holds at the R.193 e-folding time | R.98, R.193 |
| `nEff_value_at_one_efold` | R.193's nEff explicit form at `t = τ̄ + t_c` | R.193 (uses R.98 context) |
| `joint_values_at_one_efold` | Bundled R.98 + R.193 values at common time | R.98, R.193 |
| `log_kappa_at_one_efold_decay` | `log κ` form: `log κ₀ · exp(-α·τ̄)` | R.98, R.193 |
| `asymptote_at_critical_rate` | R.193 critical rate makes asymptote = demand; R.98 value unchanged | R.98, R.193 |

---

## File 4 — `R3_Agent3_FourEventTimeline.lean`

**Chain: R.97 + R.193 (case D).**  Three-event timeline (clean R.97
two transitions + R.193 decay-learn).

| Theorem | Statement | Depends on |
| --- | --- | --- |
| `three_event_timeline` | R.97 + R.193 net-growth ⇒ ordering + asymptote surplus | R.97, R.193 |
| `joint_positivity` | Both gap quantities strictly positive | R.97, R.193 |
| `sub_critical_no_third_event` | R.97 ordering holds but R.193 third event missing | R.97, R.193 |
| `signature_inequality` | Two independent positive signatures | R.97, R.193 |
| `R97_invariant_across_R193_regimes` | R.97 ordering robust across all R.193 regimes | R.97, R.193 |

---

## File 5 — `R3_Agent3_GrokkingPhaseClassifier.lean` ★ HEADLINE 3-CHAIN

**Chain: T.30 + R.80 + R.518 (case F).**  Grokking-phase classifier.

| Theorem | Statement | Depends on |
| --- | --- | --- |
| `R80_crossing_in_phase_II` | R.80 crossing on Phase-II window lies in `[t_cov, t_aut]` | T.30, R.80 |
| `phase_II_suppression` | Under R.518 + T.30, `κ_t < κc²` throughout Phase II | T.30, R.518 |
| **HEADLINE: `grokking_classification_by_decay`** | T.30 ordering + R.518-decay-branch ⇒ classifier of R.80 crossing existence | T.30, R.80, R.518 |
| `grokking_implies_decay_above_threshold` | Contrapositive: R.80 crossing exists ⇒ decay above threshold | R.80, R.518 |
| `headline_three_chain_witness` | Bundled three-chain witness: ordering + ceiling + crossing-in-Phase-II | T.30, R.80, R.518 |

---

## File 6 — `R3_Agent3_UnimodalVsDoubleDescent.lean`

**Chain: R.102 + R.81ab (case E).**  Compatibility / conflict
analysis.

| Theorem | Statement | Depends on |
| --- | --- | --- |
| `R102_consecutive_difference_nonneg` | R.102 ⇒ time-series non-decreasing step-by-step | R.102 |
| `R102_no_descent_step` | No negative time-series step under R.102 | R.102 |
| `R81ab_middle_positive` | DD requires positive middle `dN₂` | R.81ab |
| **`R102_excludes_DD_ascent`** | R.102 monotonicity excludes a downward jump (DD ascent under sign-flip) | R.102, R.81ab |
| `coexistence_on_disjoint_variables` | R.102 + R.81ab coexist on disjoint variables | R.102, R.81ab |
| `direct_conflict_under_identification` | Same-variable identification produces a contradiction | R.102, R.81ab |

---

## File 7 — `R3_Agent3_GompertzWithDecay.lean`

**Chain: R.98 + R.518 (case G).**  Gompertz with decay-modified
ceiling.

| Theorem | Statement | Depends on |
| --- | --- | --- |
| `kappaInf_lt_one` | R.518 ceiling strictly below 1 | R.518 |
| `kappaInf_pos` | R.518 ceiling strictly positive | R.518 |
| `saturation_gap_positive` | R.98 limit (1) − R.518 ceiling > 0 | R.98, R.518 |
| `gompertz_ode_invariant_under_decay` | R.98 ODE holds independently of decay | R.98 (R.518 context) |
| `decay_ceiling_brackets_surface` | `0 < κ_eff^∞ < κc² < 1` under sub-critical decay | R.98, R.518 |
| **HEADLINE: `gompertz_with_decay_ceiling_below_one`** | R.98 + R.518: ceiling strictly below R.98 unimpeded saturation | R.98, R.518 |
| `trajectory_universally_bounded` | Universal pointwise bound `κ_t < 1` | R.98, R.518 |

---

## Headline 3-chain

**`grokking_classification_by_decay`** in
`R3_Agent3_GrokkingPhaseClassifier.lean` chains **three** R-results
(T.30 + R.80 + R.518):

- T.30 supplies the phase ordering `t_cov < t* < t_aut` (Phase II is
  the middle interval).
- R.80 supplies the IVT-based crossing existence inside any continuous
  window of the closure trajectory.
- R.518 supplies the decay-suppression criterion: when `τ̄ < τ̄_c`,
  the closure ceiling sits strictly below the grokking surface so the
  R.80 crossing point cannot exist.

The headline classifies the grokking event: it lives in T.30's Phase
II *exactly* when decay is at or above R.518's threshold, and is
suppressed (no crossing exists) when decay is below threshold.

**`grokking_suppressed_three_chain`** in
`R3_Agent3_CrossingSuppression.lean` also chains **three** R-results
(R.79 + R.80 + R.518), giving the joint "no grokking" statement
across both geometric (R.80) and combinatorial (R.79) views.

---

## Stats

- **7 files**, all compile clean (zero `sorry`, zero new `axiom`).
- **~35 theorems total**.
- **Two 3-result headline chains:**
  - `grokking_classification_by_decay` (T.30 + R.80 + R.518),
  - `grokking_suppressed_three_chain` (R.79 + R.80 + R.518).
- Each file imports ≥ 2 R-results (most import 2; the two 3-chain
  files import 3).

## Files

```
MIP/Discoveries/R3_Agent3_PhaseTimeOrdering.lean
MIP/Discoveries/R3_Agent3_CrossingSuppression.lean         ★ 3-chain
MIP/Discoveries/R3_Agent3_GompertzAtDecayTransition.lean
MIP/Discoveries/R3_Agent3_FourEventTimeline.lean
MIP/Discoveries/R3_Agent3_GrokkingPhaseClassifier.lean      ★ headline 3-chain
MIP/Discoveries/R3_Agent3_UnimodalVsDoubleDescent.lean
MIP/Discoveries/R3_Agent3_GompertzWithDecay.lean
```
