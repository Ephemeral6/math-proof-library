# Explain-Why Prompt — Specification

**Status**: design spec, no implementation yet.
**Position**: fires after every Verifier step where `actual_outcome != error`. The
output is the input to `workspace/agents_spec/hypothesis_tracker.md`. The first step
of a plan triggers a "seed" version (no prior hypothesis to test); subsequent
steps trigger the "stress-test" version that takes the previous WH as input.
**Related docs**:
- `workspace/agents_spec/instance_sorter.md` — defines `test_plan` and per-step lifecycle.
- `workspace/agents_spec/hypothesis_tracker.md` — consumes prompt output.
- `workspace/reports/architecture/architecture_v2.md` §5.2 / §5.3 — the explain-why / stress-test pattern in v2.
- The capability-2 analysis (this conversation): the hybrid (2)+(3) prompt design.

---

## 0. Why hybrid (structural + predictive)

The capability-2 analysis evaluated three prompt designs:

1. **Open-ended** ("why does P hold here?") — produces vague gestures, no
   falsifiable claim, hard to register in the Tracker.
2. **Structural** ("is it because of (a) or (b)?") — forces commitment but
   a false binary often hides a third reason; the K_4-core obstruction in
   OP-1 is neither "vertex count" nor "topology" alone.
3. **Comparative / predictive** ("predict whether P holds in case Y") —
   directly produces the Tracker input; agent may answer "yes because Y is
   also small," dodging the structural question.

The hybrid design runs (2) first to enumerate candidate properties P_i,
then (3) per-candidate to extract per-property predictions. Each P_i becomes
its own sub-hypothesis with its own falsification test. Failure of one P_i
that *doesn't* coincide with failure of the conjecture is the most
informative outcome — it tells us the conjecture survives without P_i,
i.e. P_i was a non-essential part of the explanation.

---

## A. Hybrid prompt template

The template has four parameter holes and three sections.

### A.0 Parameters

| Param | Filled from | Example (OP-1 step 2 → step 3) |
|---|---|---|
| `{anchor_case}` | `test_plan[step].instance` | `S_{1,1} k=2` |
| `{conjecture}` | `State.current_conjecture.form` | `descending link is dismantlable` |
| `{actual_evidence}` | `test_plan[step].actual_evidence` | `3/3 DLs dismantlable; all have ≤ 5 vertices` |
| `{next_case}` | `test_plan[step+1].instance` | `S_{1,1} k=3` |
| `{prior_WH}` | most recent active WH (or null on seed) | null on step 1; WH-1 thereafter |
| `{rep_id}` | `State.current_conjecture.rep_id` | `rep_021_dismantlable_graph` |
| `{failed_attempts}` | `State.failed_attempts` summary | none yet at step 2 |

### A.1 Seed prompt (first step of a plan, no prior WH)

```
You are analysing a single verified instance.

[anchor result]
On {anchor_case}, the conjecture "{conjecture}" holds.
Verifier evidence: {actual_evidence}
Current representation: {rep_id}.
Known failed forms in this representation's history:
  {failed_attempts}

[step 1 — enumerate candidate properties]
List ≥ 3 candidate properties P_i, each of the shape "{anchor_case} has
specific feature F_i which is sufficient to imply {conjecture}". Be
concrete: name the feature in the verifier-readable language (vertex count,
edge density, intersection-number bound, eigenvalue magnitude, etc.), not
a generic descriptor.

For each P_i, also record:
  - is_strictly_stronger_than_conjecture: bool
  - depends_on_anchor_size: bool         # would fail if instance grew
  - rooted_in_representation_choice: bool # would change under rep switch

[step 2 — predict on the next instance]
The next instance to be verified is {next_case}. For each P_i, predict:
  (a) does P_i still hold on {next_case}? (yes / no / partial / unknown)
  (b) if P_i holds, does {conjecture} still hold? (yes / no / unclear)
  (c) if you predicted P_i fails: give a plausible structural counterexample
      — name the specific feature of {next_case} that destroys P_i.

[step 3 — rank by informativeness]
Rank P_1, ..., P_n by: "if P_i fails on {next_case} but {conjecture} still
holds, how much do we learn about why {conjecture} actually holds?"

The top-ranked P_i becomes the candidate WH. Output JSON:

{
  "candidate_properties": [
    { "id": "P1", "feature": "...", "is_strictly_stronger": false,
      "depends_on_anchor_size": true, "rooted_in_rep_choice": false,
      "prediction_on_next": "no",
      "prediction_rationale": "...",
      "informativeness_rank": 1 }
  ],
  "top_ranked_id": "P1",
  "wh_seed": {
    "claim": "<one-line statement combining the top P_i with the conjecture>",
    "candidate_property": "<P_i.feature verbatim>"
  }
}
```

### A.2 Stress-test prompt (subsequent step, prior WH active)

```
You are stress-testing an existing hypothesis against a new instance.

[prior hypothesis]
WH-{N}: {prior_WH.claim}
Anchor case: {prior_WH.anchor_case}
Candidate property: {prior_WH.candidate_property}
Predictions made: {prior_WH.predictions[].next_complexity}

[new instance]
On {next_case}, the conjecture "{conjecture}" was just verified:
  outcome    : {actual_outcome}
  evidence   : {actual_evidence}
  predicted  : {test_plan[step].predicted_outcome}

[step 1 — reconcile prediction vs reality]
Compare {test_plan[step].predicted_outcome} against {actual_outcome}.
  - if they match and the candidate property {prior_WH.candidate_property}
    still holds → emit verdict: "WH-{N} CONFIRMED on {next_case}"; the WH
    survives unchanged.
  - if {actual_outcome} is pass but the candidate property {prior_WH.
    candidate_property} fails → emit verdict: "WH-{N} REFUTED at the
    explanation level — conjecture survives without the property."
    This is the most informative outcome; you must produce a successor
    WH-{N+1} whose candidate property is *strictly weaker* than
    {prior_WH.candidate_property} but still implies {conjecture} on the
    cases verified so far.
  - if {actual_outcome} is fail → emit verdict: "WH-{N} FALSIFIED — the
    conjecture itself fails on {next_case}". The Diagnoser takes over;
    no successor WH from this prompt.
  - if {actual_outcome} is mixed → both above apply: pass-cases give the
    REFUTED-at-explanation pattern; fail-cases feed the Diagnoser.

[step 2 — successor WH (only on REFUTED-at-explanation)]
If WH-{N} is refuted but the conjecture survives, propose:
  successor.candidate_property: "<weaker but still sufficient property>"
  successor.justification: "<why the new property explains the cases that
                             fail {prior_WH.candidate_property}>"
  successor.next_predictions: [
    { "next_complexity": "<plan step k+1 instance>", "predicted_outcome": "...",
      "rationale": "..." }
  ]

[step 3 — anti-strictly-stronger filter]
Reject any successor whose candidate_property is strictly stronger than
{prior_WH.candidate_property} OR than any element of {failed_attempts}.
Also reject any successor whose candidate_property is logically equivalent
to a dismissed form.

The LLM-side filter at this step is the **Tier-3 fallback**: structured
checks live in `lean/LeanAgent/scripts/strict_stronger.py`. The orchestrator
runs `reject_against_failed(candidate, failed_attempts, ctx)` as a
preflight; if Tier 1 (registry implies_reps) or Tier 2 (Lean probe)
already discharged the candidate as STRICTLY_STRONGER, the candidate
never reaches this prompt. The LLM only sees candidates that survived
the cheap structured checks.

If your only candidate fails this filter, emit successor: null and let
the Tracker decide whether to escalate to Bridge or to mark WH-{N} TERMINAL.

Output JSON:
{
  "verdict": "CONFIRMED | REFUTED_AT_EXPLANATION | FALSIFIED | MIXED",
  "evidence_pointer": "test_plan[{step}].actual_evidence",
  "successor": null | {
    "claim": "...",
    "candidate_property": "...",
    "justification": "...",
    "next_predictions": [...]
  },
  "obstacle": null | {                      // ★ required when verdict ∈ {REFUTED_AT_EXPLANATION, MIXED, FALSIFIED}
    "obstruction_class": "<one of obstruction_catalog.md §A>",
    "mathematical_property_needed": "<one-sentence NL description of the property the proof step needs but does not have>",
    "propagation_path": "<which step / WH / inequality is blocked by this obstruction>"
  }
}
```

### A.4 The `obstacle` field — controlled vocabulary and emission rule

When the verdict is `REFUTED_AT_EXPLANATION`, `MIXED`, or `FALSIFIED`, the prompt MUST emit an `obstacle` object. The `obstruction_class` is one of the eight controlled-vocab values from `workspace/agents_spec/obstruction_catalog.md §A`:

| Value | One-line meaning |
|---|---|
| `combinatorial_blowup` | search space exponential; exhaustive enumeration infeasible |
| `loose_inequality` | inequality has slack; bound not tight |
| `wrong_direction` | needed bound is the opposite direction |
| `missing_lower_bound` | only upper bounds available, lower bound needed |
| `non_constructive_witness` | existence proven but explicit construction needed |
| `coupling_breaks` | dependency / adaptivity destroys independence assumption |
| `regularity_loss` | smoothness / convexity hypothesis fails |
| `intractable_certificate` | certificate search space too large |

Selection rule:
1. Read `workspace/agents_spec/obstruction_catalog.md §A` for the full row including search keywords.
2. Pick the **primary** class — the one whose removal would most directly unblock the proof.
3. If multiple apply, list secondary classes in the `notes` field of the parent verdict object.
4. If no class applies at all, emit `obstacle: null` and document the unrecognised pattern in `notes`. The Tracker will validate against the catalog and forward the unrecognised case to the operator (per `tool_discoverer.md §F.3`).

This obstacle field is what the Tracker reads (`hypothesis_tracker.md §A` / §C.2) and what the Diagnoser ternary judge consumes to dispatch between Rep Discoverer (`rep_too_restrictive`) and Tool Discoverer (`technique_insufficient`).

### A.3 Where the prompt sits in the Verifier loop

```
Verifier executes step k → step.actual_outcome written
   ↓
if k == 1: seed prompt fires
else:      stress-test prompt fires (using WH active at step k-1's exit)
   ↓
Tracker consumes prompt JSON output
   ↓
Tracker updates State.why_hypotheses + State.tracker_log
   ↓
Verifier proceeds to step k+1
```

The prompt invocation is **synchronous within the per-step loop** but is a
separate LLM call — the Verifier itself is non-LLM (it just runs Python /
Lean commands).

---

## B. OP-1 concrete instantiation

This is what the prompt would have produced if invoked on OP-1's actual
verifier outputs. Format: `[seed]` for step 1, `[stress]` for later steps.

### B.1 Step 1 — S_{1,1} k=2 → seed

`{anchor_case}` = `S_{1,1} k=2`
`{conjecture}` = `every descending link is dismantlable`
`{actual_evidence}` = `3/3 DLs dismantlable; ≤ 5 vertices each; all chordal`

Expected output:

```json
{
  "candidate_properties": [
    { "id": "P1", "feature": "DL has ≤ 5 vertices",
      "is_strictly_stronger": false, "depends_on_anchor_size": true,
      "rooted_in_rep_choice": false,
      "prediction_on_next": "yes (S_{1,1} k=3 has ≤ 5 vertices too)",
      "informativeness_rank": 3 },
    { "id": "P2", "feature": "DL is chordal (every cycle ≥ 4 has a chord)",
      "is_strictly_stronger": true, "depends_on_anchor_size": false,
      "rooted_in_rep_choice": false,
      "prediction_on_next": "yes (S_{1,1} k≤3 verified chordal in prior runs)",
      "informativeness_rank": 1,
      "rationale": "if chordality fails on a later case, dismantlability
                    surviving would be highly informative" },
    { "id": "P3", "feature": "every DL is the local link of a Farey 2-cell",
      "is_strictly_stronger": false, "depends_on_anchor_size": false,
      "rooted_in_rep_choice": true,
      "prediction_on_next": "yes for S_{1,1}, unclear for S_{1,2}+",
      "informativeness_rank": 2,
      "rationale": "Farey structure is specific to S_{1,1}; testing on
                    S_{1,2} probes whether Farey-locality is essential" }
  ],
  "top_ranked_id": "P2",
  "wh_seed": {
    "claim": "DL is dismantlable because it is chordal",
    "candidate_property": "DL is chordal"
  }
}
```

This becomes WH-1 in the Tracker.

### B.2 Step 4 — S_{1,2} k=2 → stress-test of WH-1

`{prior_WH}` = WH-1 (chordality)
`{next_case}` = S_{1,2} k=2
`{actual_outcome}` = pass
`{actual_evidence}` = `64/64 dismantlable; 64/64 chordal at this level`

Expected output:

```json
{
  "verdict": "CONFIRMED",
  "evidence_pointer": "test_plan[4].actual_evidence",
  "successor": null
}
```

WH-1 survives this step.

### B.3 Step 5 — S_{1,2} k=4 → REFUTATION

`{prior_WH}` = WH-1 (chordality)
`{next_case}` = S_{1,2} k=4
`{actual_outcome}` = pass on dismantlability; mixed on chordality
`{actual_evidence}` = `54/54 dismantlable; 42/54 chordal; 12 specific
                       DLs are non-chordal with degree sequence (6,5,5,5)`

Expected output:

```json
{
  "verdict": "REFUTED_AT_EXPLANATION",
  "evidence_pointer": "test_plan[5].actual_evidence",
  "successor": {
    "claim": "DL is dismantlable because every induced 4-cycle has a
              common neighbour (a 5th vertex adjacent to all four)",
    "candidate_property": "DL satisfies the (W4) wheel condition",
    "justification": "the 12 non-chordal CEs all have an induced 4-cycle
                      that gets filled by a 5-th vertex; chordality (no
                      induced 4-cycle at all) is strictly stronger than
                      (W4) (4-cycles allowed if filled). The CEs to
                      chordality CONFIRM (W4) survives.",
    "next_predictions": [
      { "next_complexity": "S_{1,2} k=5", "predicted_outcome": "pass",
        "rationale": "(W4) is a local condition; should generalise" }
    ]
  }
}
```

This is the moment OP-1 Round 6 (the Chepoi-Osajda jump) emerges *as a
hypothesis*, two rounds earlier than the actual trace. The Bridge module
(`workspace/reports/architecture/architecture_report.md` Q5) takes "(W4)" as a literature
keyword and surfaces Chepoi-Osajda 2014.

### B.4 Step 6 — S_{1,2} k=5 → CONFIRM WH-2

`{prior_WH}` = WH-2 ((W4))
`{next_case}` = S_{1,2} k=5
`{actual_outcome}` = pass

```json
{ "verdict": "CONFIRMED", "evidence_pointer": "...", "successor": null }
```

WH-2 survives. By step 9 (S_{2,1} k=4), WH-2 is empirically confirmed on
all 318/318 instances and is promoted to a registry entry
(`rep_024_w4_metric_chepoi`, status: conjectural; geometric proof OPEN).

---

## C. Theorem 3 concrete instantiation

### C.1 Step 1 — β = 0 → seed

`{anchor_case}` = `β = 0, η = η_opt(0) = 1/L`
`{conjecture}` = `the 2-step Lyapunov LMI is feasible with C(β) finite`
`{actual_evidence}` = `feasible; C = 0.333; W = 1; (a_0, a_1, a_2, c_01,
                       c_02, c_12) trivially zero except for w_t F_t term`

Expected output:

```json
{
  "candidate_properties": [
    { "id": "P1", "feature": "η can be 1/L (textbook GD step)",
      "is_strictly_stronger": false, "depends_on_anchor_size": false,
      "rooted_in_rep_choice": false,
      "prediction_on_next": "no — η decreases as β increases",
      "informativeness_rank": 3 },
    { "id": "P2", "feature": "Lyapunov reduces to single-anchor: only
                              w_t F_t carries weight",
      "is_strictly_stronger": true, "depends_on_anchor_size": false,
      "rooted_in_rep_choice": true,
      "prediction_on_next": "no — momentum cross-term c_01 will activate
                             at β > 0",
      "informativeness_rank": 1,
      "rationale": "if Lyapunov stays single-anchor as β grows, the LMI
                    is solving an artificially-low-rank problem" },
    { "id": "P3", "feature": "(1-β) appears as the only β-dependent factor
                              in the certificate's leading constant",
      "is_strictly_stronger": false, "depends_on_anchor_size": false,
      "rooted_in_rep_choice": false,
      "prediction_on_next": "yes — empirical fit shows C(β) ~ (1-β)^{-q}",
      "informativeness_rank": 2 }
  ],
  "top_ranked_id": "P3",
  "wh_seed": {
    "claim": "C(β) blows up only as (1-β)^{-q} for some q ≈ 1, with no
              additional β* singularity",
    "candidate_property": "log-log fit slope on (1-β) is finite and isolated"
  }
}
```

### C.2 Step 51 — β = 0.957, k = 0 → REFUTATION-at-feasibility

`{prior_WH}` = WH-3 (smooth (1-β)^{-q})
`{next_case}` = β = 0.957, k = 0
`{actual_outcome}` = fail (LMI infeasible)
`{actual_evidence}` = `CLARABEL infeasible; coefficient norms ‖a_i, c_ij‖
                       diverge as (1-β)^{-2} approaching β = 0.957`

Expected output:

```json
{
  "verdict": "MIXED",
  "evidence_pointer": "test_plan[51].actual_evidence",
  "successor": {
    "claim": "The frontier β*_LMI = 0.957 is a structural cap of the
              quadratic-Q linear-w_t Lyapunov family, not a physical
              rate transition — so a richer rep extends it",
    "candidate_property": "the LMI's failure mode is *coefficient norm
                            divergence*, not *primal-rate degradation*",
    "justification": "C(β) fits (1-β)^{-q} smoothly through the entire
                       certified region with no extra (β*-β)^{-1} term;
                       the failure is in the certificate-extraction
                       machinery, not the iteration dynamics",
    "next_predictions": [
      { "next_complexity": "β = 0.957, k = 1", "predicted_outcome": "pass",
        "rationale": "1-step lookahead adds anchors past the current
                      window, providing slack the baseline can't access" }
    ]
  }
}
```

This is the moment Round 3's lookahead jump emerges as a hypothesis. The
"next_predictions" entry directly drives plan step 52.

### C.3 Step 52 — β = 0.957, k = 1 → CONFIRM the WH

`{actual_outcome}` = pass; C(0.957) = 27.0; bulk values (β = 0.5, 0.8)
also tighten 17–66%.

```json
{
  "verdict": "CONFIRMED",
  "evidence_pointer": "test_plan[52].actual_evidence",
  "successor": null
}
```

WH-4 promoted; rep_027 created with status: validated.

---

## D. Output schema reference

The Tracker (`workspace/agents_spec/hypothesis_tracker.md`) consumes the
JSON output of the prompt. Mapping:

| Prompt field | Tracker action |
|---|---|
| `wh_seed` (seed only) | create new WH with `verdict: ACTIVE`; assign next ID |
| `verdict: CONFIRMED` | mark prediction.status = "verified"; WH stays ACTIVE |
| `verdict: REFUTED_AT_EXPLANATION` | mark prediction.status = "falsified"; move WH to failed_attempts; create successor from prompt.successor |
| `verdict: FALSIFIED` | mark prediction.status = "falsified"; move WH to failed_attempts; do not create successor; emit signal to Diagnoser |
| `verdict: MIXED` | both: WH gets a partial-falsification record; successor is created from the falsifying subset |
| `evidence_pointer` | copied verbatim into the prediction's `evidence` field |

If the prompt LLM emits malformed JSON, the orchestrator retries once
with a stricter schema reminder; second failure is logged as a
`tracker_log` event and the round proceeds with the WH unchanged
(conservative default).

---

## E. Constraints on the prompt LLM

The prompt is invoked with explicit instructions to:

1. **Stay inside the verifier output**: do not invent properties not
   visible in `actual_evidence`. The Tracker will check that every
   `feature` mentioned in `candidate_properties` appears as a substring
   or trivial paraphrase of `actual_evidence` (or of a registered
   probe in the playbook).
2. **One sentence per field**: predictions are short. Long rationale
   goes in `notes`, not the schema fields the Tracker keys on.
3. **Anti-strictly-stronger** is enforced via two layers:
   - **Tier-1/Tier-2 (structured)**: the orchestrator calls
     `lean/LeanAgent/scripts/strict_stronger.py:reject_against_failed`
     before invoking the prompt. Tier 1 consults the registry's
     `implies_reps` graph; Tier 2 (when available) runs a Lean
     implication probe over the two `formal_form`s. Candidates flagged
     STRICTLY_STRONGER never reach the LLM.
   - **Tier-3 (LLM, fallback)**: the prompt instruction at §A.2 step 3
     handles cases the structured tiers cannot resolve. The LLM should
     conservatively reject when uncertain.
4. **No new representations**: the prompt may *suggest* a representation
   switch in `notes`, but the actual creation of a new
   `representations/` entry happens in the Rep Discoverer, not here.
   This separation keeps the explain-why loop fast and cheap.

---

## F. Open questions

- **Seed-prompt creativity vs faithfulness tradeoff**: a strong Proposer
  produces ≥ 5 candidate properties but quality decays past 3. The cap
  at 3 is a guess; should be tuned on a real run.
- **Stress-test recursion**: when WH-1 is refuted and successor WH-2 is
  emitted, the next step's stress-test runs against WH-2 — but the WH-1
  refutation evidence is also informative for WH-2's predictions.
  Currently the prompt ignores it; a richer version would carry forward
  a "lineage" of past refutations.
- **Prompt cost amortisation**: invoking the prompt after every step
  costs an LLM call per step. For long plans (e.g. Theorem 3's 50+ β
  values), this is heavy. A coarsening — invoke only on outcome change
  — is on the table but breaks the per-step Tracker invariant.
