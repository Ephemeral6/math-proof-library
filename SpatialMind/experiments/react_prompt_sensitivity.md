# ReAct Prompt Sensitivity Analysis (knot_theory)

**Status:** supplementary experiment for rebuttal use.
**Date:** 2026-05-03.
**Responder model:** claude-sonnet-4-6 (sub-agents).
**Rater model:** claude-opus-4-7 (this conversation), 0-4 rubric identical to `react_comparison_results.json`.

## Motivation

In the headline ReAct+Engine experiment (`react_comparison_results.json`),
**knot_theory was the worst domain** for ReAct: 0 engine queries across all 3
cases (0/17 of total queries went to this domain), yielding mean 3.0 vs
CoE-R/RTC's 4.0. The agent argued from "R2 is ambient isotopy → invariants
preserved" without verifying. C-primitive was queried 0 times across all 24
trials.

A reviewer could reasonably ask: **how much of the gap is an artifact of the
specific ReAct system prompt** vs an architectural property of pull-based
designs? This experiment tests three prompt variants on the worst domain to
isolate prompt-engineering effects.

## Variants

| Tag | Modification |
|-----|---|
| **Baseline ReAct** | (from `react_comparison_results.json`) standard ReAct: 5 actions THINK / QUERY_R / QUERY_T / QUERY_C / ANSWER, ≤5 queries, no further guidance about when to use which primitive. |
| **V1: ReAct+Few-shot** | + 2 worked examples (graph_connectivity-style + boundary_interior-style) showing the agent issuing QUERY_C to verify load-bearing conditions. No explicit instruction added. |
| **V2: ReAct+Explicit-C** | + a paragraph in the system prompt explicitly describing what QUERY_C returns (boundary_relaxation / operation_perturbation / condition_removal scenarios) and 3 situations where the agent should use it (claims of the form "X holds because of Y"; arguments from a general theorem; upgrading from "argument" to "proof"). No examples. |
| **V3: ReAct+Full-hint** | both V1 examples + V2 explicit paragraph. |

Engine, case set, and rubric are identical to the headline experiment.
3 variants × 3 knot_theory cases (`3_1-r2-3`, `4_1-r2-4`, `5_2-r2-5`) = 9 trials.
Each trial dispatched as one Sonnet sub-agent calling
`python react_agent.py …` via Bash.

## Trial-level results

| # | Variant | Case | Queries | C? | Score | Notes |
|---|---------|------|---------|----|------:|-------|
| 1 | V1 Few-shot | 3_1-r2-3 | R, T, C | YES | 4 | Verified σ=−2, det=3, Alex [1,−1,1] preserved; C confirmed (+1,−1) sign-pair is critical (pseudo-R2 with (−1,−1) breaks det 3→7). PROOF. |
| 2 | V1 Few-shot | 4_1-r2-4 | R, T |  no | 4 | Verified σ=0, det=5, Alex [1,−3,1] preserved; explicitly handled t³ unit factor in raw Alexander; explicit verification of all four invariants from R+T data. PROOF. |
| 3 | V1 Few-shot | 5_2-r2-5 | R, T |  no | 4 | Verified σ=2, det=7, Alex [2,−3,2] preserved; explicit invariant identification + diagram-vs-topology distinction. PROOF. |
| 4 | V2 Explicit-C | 3_1-r2-3 | R, T, C | YES | 4 | Same R+T verification + 3 counterfactuals all `condition_is_critical:true` (sign-pair, crossing-flip, planarity). PROOF. |
| 5 | V2 Explicit-C | 4_1-r2-4 | R, T, C | YES | 4 | Same as #2 + counterfactual confirms canceling-sign condition is load-bearing. PROOF. |
| 6 | V2 Explicit-C | 5_2-r2-5 | R, C | YES | 4 | Same as #3 + counterfactual; agent skipped T but C compensated. PROOF. |
| 7 | V3 Full-hint | 3_1-r2-3 | R, C | YES | 4 | R verifies invariants, C confirms criticality of all 3 conditions. Agent skipped T (concluded C was higher value than T). PROOF. |
| 8 | V3 Full-hint | 4_1-r2-4 | R, C | YES | 4 | Same as #7 pattern. Explicitly named the protocol it was following ("per the protocol I did NOT skip QUERY_C"). PROOF. |
| 9 | V3 Full-hint | 5_2-r2-5 | R, C | YES | 4 | Same as #7. PROOF. |

## Aggregate results

### Score on knot_theory (mean over 3 cases)

| Condition | Mean | Δ vs Baseline ReAct |
|-----------|-----:|--------------------:|
| Baseline ReAct (headline experiment) | 3.000 | — |
| **V1: ReAct+Few-shot** | **4.000** | **+1.000** |
| **V2: ReAct+Explicit-C** | **4.000** | **+1.000** |
| **V3: ReAct+Full-hint** | **4.000** | **+1.000** |
| CoE-R / CoE-RTC (headline) | 4.000 | +1.000 |

**All three improved variants close the entire gap to CoE on this domain.**

### C-primitive query rate (3 cases per variant)

| Condition | C-queries | C-rate |
|-----------|----------:|-------:|
| Baseline ReAct (headline) | 0 / 3 | 0% |
| **V1: Few-shot only** | **1 / 3** | **33%** |
| **V2: Explicit-C only** | **3 / 3** | **100%** |
| **V3: Full-hint** | **3 / 3** | **100%** |

### Total queries per variant

| Condition | R | T | C | Total |
|-----------|--:|--:|--:|------:|
| Baseline (headline) | 0 | 0 | 0 | 0 |
| V1 Few-shot | 3 | 3 | 1 | 7 |
| V2 Explicit-C | 3 | 2 | 3 | 8 |
| V3 Full-hint | 3 | 0 | 3 | 6 |

## Findings

1. **Score gap is fully closable by prompt engineering.** All three variants
   reach 4.0/4.0 on knot_theory, matching CoE-R/RTC. The 1.0-point baseline
   ReAct deficit is entirely a prompt-engineering artifact, not an
   architectural one.

2. **Explicit instruction is necessary; few-shot alone is insufficient.**
   Few-shot examples (V1) triggered QUERY_C in only 1 of 3 trials. Explicit
   instruction (V2) triggered it in all 3. Combining them (V3) does not
   exceed V2. Conclusion: the LLM does NOT generalize "use C in graph or
   polygon problems" → "use C in knot problems" from in-domain examples.
   It needs to be *told* that C is for verifying load-bearing conditions.

3. **R+T alone hits PROOF on knot_theory.** Trials 2 and 3 (V1 Few-shot
   without C) still scored 4. The structural_comparison fields
   (signature_pre/post, determinant_pre/post, alexander_pre/post_normalized,
   writhe_pre/post) supplied by R are sufficient to convert "argument" into
   "proof"; C is not strictly required for this domain. The headline
   experiment's 3.0 score came from issuing **zero** queries, not from
   skipping C specifically.

4. **The C-primitive provides genuine semantic content beyond R.** When
   queried, the counterfactual returns three distinct critical conditions
   (sign-pair, crossing-flip, planarity), each with quantified invariant
   shifts. Trials that issued C produce noticeably stronger justifications
   ("R2 preserves invariants *because* it inserts a canceling pair, and the
   counterfactual shows breaking that condition does break the invariants")
   vs trials with only R+T ("R2 is ambient isotopy → invariants preserved").
   Both score 4 under the rubric, but the C-augmented answers are
   qualitatively closer to PROOF; a finer-grained rubric or human eval
   might separate them.

5. **Sub-agents allocate attention away from T when C is salient.** V3
   trials skipped T entirely (0/3) while every V3 trial issued C. V2
   skipped T once. The agent appears to treat T and C as substitutable
   sources of "extra confirmation," and once C is made salient it
   displaces T. This suggests the prompt-engineering nudge has a budget
   trade-off rather than purely additive effect.

## Implications for the headline result

The headline ReAct+Engine 3.63 vs CoE-R 3.75 gap (-0.13 overall) was
attributed primarily to knot_theory's 3.0 vs 4.0 deficit (which contributes
−0.125 to the overall mean). This experiment shows:

- **If we replace baseline ReAct with V2 (Explicit-C) just on knot_theory**,
  knot_theory becomes 4.0, ReAct's overall mean rises to 3.75, and the
  ReAct vs CoE gap closes to 0.00. So the headline gap is essentially a
  "default ReAct underuses C" effect on a single domain.

- **However**, the architectural argument for CoE is unchanged: CoE
  guarantees C-coverage by construction, while ReAct requires the prompt
  designer to anticipate which domains need a C-nudge. On knot_theory the
  nudge is obvious in hindsight (the proof requires verifying a
  condition); on a new domain, prompt designers may not know in advance.
  The headline finding "pull architectures systematically under-use the
  least-intuitive primitive" survives.

- **What the headline experiment does NOT support** (and reviewers may
  point out): the claim that ReAct *cannot* match CoE on this domain.
  It can, with prompt engineering. The right framing is "default ReAct
  prompts under-utilize counterfactual primitives, and this is fixable
  with explicit instruction" — not "ReAct architecturally underperforms."

## Caveats

- n=3 cases per variant; all-integer rubric. The 4.0 ceiling is hit by
  all 3 cases for all 3 variants, so this experiment cannot detect
  variant-vs-variant differences in raw score (a higher-resolution
  rubric or a harder case set would be needed).
- Same single-rater (Opus self-rater) caveat as the headline.
- Baseline-ReAct numbers (3.0 mean, 0/3 C queries) are inherited from
  `react_comparison_results.json`, not re-run here. The improvement is
  measured against the original; not an independent baseline.
- The 33% C-rate for V1 (Few-shot) is a single trial out of 3 issuing C;
  with n=3 this is a noisy estimate of the few-shot effect. The V2 and
  V3 100% rates are more robust.
- All sub-agents are Sonnet-4-6 (matching headline responder); the
  prompt-sensitivity effect may differ for other model classes.

## One-line summary for rebuttal

> **A 1-paragraph addition to the ReAct system prompt — explicitly
> describing when to use QUERY_C — closes the entire 1.0-point ReAct vs
> CoE deficit on knot_theory (3.0 → 4.0) and lifts C-primitive utilization
> from 0% to 100%; few-shot examples without explicit instruction are
> insufficient (33%). The headline architectural gap reflects a default
> prompt's failure to surface the C-primitive, not an inherent ReAct
> weakness — but CoE's guarantee of C-coverage remains a useful property
> when prompt-time anticipation is unreliable.**

## Raw data

Trajectories from all 9 sub-agent runs are appended below for audit.

### Trial 1 — V1 Few-shot, 3_1-r2-3
QUERIES_ISSUED: R, T, C  (3 queries; QUERIED_C: YES)
Final: R2 valid; +1/-1 pair confirmed; σ=-2, det=3, Alexander [1,-1,1] preserved; counterfactual confirms opposite-sign requirement is critical (pseudo-R2 with (-1,-1) gives det=7, breaks Alexander).

### Trial 2 — V1 Few-shot, 4_1-r2-4
QUERIES_ISSUED: R, T  (2 queries; QUERIED_C: NO)
Final: R2 valid on figure-eight; σ=0, det=5, Alexander normalized [1,-3,1] preserved; raw form gains t^3 unit factor explicitly handled.

### Trial 3 — V1 Few-shot, 5_2-r2-5
QUERIES_ISSUED: R, T  (2 queries; QUERIED_C: NO)
Final: R2 valid on 5_2; σ=2, det=7, Alexander [2,-3,2] preserved; raw form shifts by t^4 unit factor; diagram count 5→7 noted as non-topological.

### Trial 4 — V2 Explicit-C, 3_1-r2-3
QUERIES_ISSUED: R, T, C  (3 queries; QUERIED_C: YES)
Final: same R+T verification as Trial 1 + 3 counterfactuals all condition_is_critical:true (sign-pair → det 3→7; crossing-flip → unknot; planarity drop → inconsistent diagram).

### Trial 5 — V2 Explicit-C, 4_1-r2-4
QUERIES_ISSUED: R, T, C  (3 queries; QUERIED_C: YES)
Final: σ=0, det=5, Alex [1,-3,1] preserved + counterfactual sign-pair shift confirms condition is load-bearing (det 5→7 under same-sign perturbation).

### Trial 6 — V2 Explicit-C, 5_2-r2-5
QUERIES_ISSUED: R, C  (2 queries; QUERIED_C: YES)
Final: σ=2, det=7, Alex [2,-3,2] preserved; T skipped because R already gave full structural comparison; C confirms canceling-pair condition.

### Trial 7 — V3 Full-hint, 3_1-r2-3
QUERIES_ISSUED: R, C  (2 queries; QUERIED_C: YES)
Final: σ=-2, det=3, Alex [1,-1,1] preserved; T skipped; counterfactual: same-sign pair → det 7, crossing-flip → unknot, planarity drop → inconsistent.

### Trial 8 — V3 Full-hint, 4_1-r2-4
QUERIES_ISSUED: R, C  (2 queries; QUERIED_C: YES)
Final: σ=0, det=5, Alex [1,-3,1] preserved + counterfactual confirms criticality. Agent self-narrated "per the protocol I did NOT skip QUERY_C" — direct evidence the explicit instruction reached the decision boundary.

### Trial 9 — V3 Full-hint, 5_2-r2-5
QUERIES_ISSUED: R, C  (2 queries; QUERIED_C: YES)
Final: σ=2, det=7, Alex [2,-3,2] preserved + counterfactual confirms.
