# Hypothesis Tracker — Specification

**Status**: design spec, no implementation yet.
**Position**: state-management module within the discovery loop. Reads the
output of the explain-why prompt; writes back into the State JSON's
`why_hypotheses`, `failed_attempts`, `complexity_frontier`, and
`tracker_log` fields. Triggers the Rep Discoverer when a falsification
diagnosis indicates "representation too restrictive" rather than
"conjecture wrong."
**Related docs**:
- `workspace/agents_spec/instance_sorter.md` — `test_plan` whose steps drive WH lifecycle.
- `workspace/agents_spec/explain_why_prompt.md` — emits the JSON the Tracker consumes.
- `workspace/reports/architecture/architecture_v2.md` §1.3, §5.2–§5.4 — Rep Selector / Discoverer integration.
- `workspace/reports/architecture/architecture_report.md` Q3 — original State schema (before Tracker).
- `lean/LeanAgent/registry/representations/SCHEMA.md` — registry the Tracker writes to via the Discoverer.

---

## 0. Why a separate Tracker module

The architecture_report.md v1 State has `failed_attempts` and `diagnoses`,
both *post-hoc* records of what already failed. There is no representation
of *active* hypotheses that drive the next round's predictions. Without
that, every round re-derives "what should I expect to see?" from scratch.

The Tracker fills that gap. It owns three things:

1. The list of *active* why-hypotheses (`why_hypotheses` array) — these
   are propositions about *why* the conjecture holds, each with one or
   more pending predictions on future plan steps.
2. The *complexity frontier* — the maximum-complexity instance verified
   so far, used by the Sorter to compute the next plan step.
3. The *lifecycle log* — every WH creation / verification / falsification
   event is appended chronologically to `tracker_log` for replay and
   debugging.

The graveyard of dismissed hypotheses (`failed_attempts`) is *separate*
and distinct in role: it is anti-hint material for the Proposer
(architecture_report.md Q1), not an active driver. The Tracker writes
to both, but never confuses them.

---

## A. State schema extension

The v1 State (architecture_report.md Q3) was:

```jsonc
{
  "goal": "...",
  "current_conjecture": "...",
  "evidence": [...],
  "failed_attempts": [...],
  "diagnoses": [...],
  "literature_in_scope": [...],
  "iteration_count": N
}
```

The Tracker extends it with three new top-level fields:

```jsonc
{
  /* unchanged v1 fields: */
  "goal": "...",
  "current_conjecture": {                       // upgraded to a sub-object
    "id": "...",
    "form": "...",
    "rep_id": "rep_NNN_...",                    // points into registry/representations/
    "verification_status": "...",
    "test_plan": [...],                         // see instance_sorter.md
    "completion_status": "pending"              // see §G — six-state gate
                       | "empirically_verified"
                       | "formally_certified"
                       | "falsified"
                       | "inconclusive_open"
                       | "error",
    "completion_rationale": "<one line: which gate triggered the transition>"
  },
  "evidence": [...],
  "failed_attempts": [...],
  "diagnoses": [...],
  "literature_in_scope": [...],
  "iteration_count": N,

  /* new fields owned by Tracker: */
  "complexity_frontier": {
    "axis": "surface_then_k",                   // see instance_sorter.md §B
    "tested": [
      { "instance": "S_{1,1} k=2", "complexity": 0.10, "outcome": "pass" },
      { "instance": "S_{1,2} k=2", "complexity": 0.42, "outcome": "pass" }
    ],
    "next": {
      "instance": "S_{1,2} k=3",
      "complexity": 0.48,
      "ordering_rationale": "next-smallest unvisited under (3g+n-3, k, ...) lex"
    },
    "ordering_rationale": "lex on (3g+n-3, k, expected_DL_size, max_clique)"
  },

  "why_hypotheses": [
    {
      "id": "WH-N",
      "anchor_case": "S_{1,1} k=2",
      "claim": "DL is dismantlable because it is chordal",
      "candidate_property": "DL is chordal (every induced cycle ≥ 4 has a chord)",
      "rep_id_at_creation": "rep_021_dismantlable_graph",
      "predictions": [
        {
          "next_complexity": "S_{1,2} k=2",
          "predicted_outcome": "pass",
          "predicted_property_holds": true,
          "status": "pending",                  // pending | verified | falsified
          "evidence": null,                     // filled when status changes
          "diagnosis_id": null
        }
      ],
      "verdict": "ACTIVE",                      // ACTIVE | VERIFIED | FALSIFIED_AT_NEXT_LEVEL | TERMINAL
      "successor_id": null,                     // set when verdict = FALSIFIED_AT_NEXT_LEVEL
      "obstacle": null,                         // optional; populated on §B.3 REFUTED_AT_EXPLANATION
                                                // shape: {obstruction_class, mathematical_property_needed, propagation_path}
                                                // controlled vocab in workspace/agents_spec/obstruction_catalog.md §A
      "created_at_iter": N,
      "ts": "<ISO-8601>"
    }
  ],

  "tracker_log": [
    { "iter": N, "step": K, "event": "WH-3 created from S_{1,1} k=2 explain-why" },
    { "iter": N, "step": K+1, "event": "WH-3 prediction on S_{1,2} k=2 verified" },
    { "iter": N+1, "step": K+2, "event": "WH-3 prediction on S_{1,2} k=4 falsified; successor WH-4 created" }
  ]
}
```

### Field semantics

- `complexity_frontier.tested` — append-only list of completed plan steps;
  each entry is `{instance, complexity, outcome}`. Used by the Sorter to
  compute the next step's complexity.
- `complexity_frontier.next` — the proposed next step. The Tracker
  recomputes this whenever a step finishes; the Sorter validates it.
- `why_hypotheses` — array of WH records, each tracking one explanatory
  hypothesis. Order of insertion = lifecycle order. Active WHs have
  `verdict ∈ {ACTIVE, VERIFIED}`; once `verdict ∈ {FALSIFIED_AT_NEXT_LEVEL,
  TERMINAL}` the WH is moved to `failed_attempts` (see §B.4) but remains in
  `why_hypotheses` with the final verdict for one full round to support
  successor cross-references.
- `predictions` — sub-array per WH; one element per future plan step
  this WH speaks to. Predictions are emitted by the explain-why prompt
  and added to the WH at WH-creation time; subsequent rounds may extend
  the array by adding new predictions targeting newly-added plan steps.
- `tracker_log` — append-only chronological event log.

### Distinction between `failed_attempts` (v1) and falsified WHs

`failed_attempts` (v1) is a list of *conjecture forms* that have been
disproved (e.g. "universal vertex form is wrong because of K_4-core CEs").
It feeds the Proposer's anti-hint rule.

A falsified WH is a *failed explanation* — the conjecture survived but the
proposed reason did not. Falsified WHs become entries in `failed_attempts`
with a marker `"as_explanation": true` to distinguish them from
disproved-conjecture entries:

```jsonc
{
  "id": "FA-N",
  "form": "DL is dismantlable because it is chordal",
  "as_explanation": true,                       // marker
  "disproved_by": "12 non-chordal DLs at S_{1,2} k=4 still dismantlable",
  "structural_pattern": "induced 4-cycle with degree sequence (6,5,5,5)",
  "successor_id": "WH-4",                        // points back to the live WH
  "rep_id_at_falsification": "rep_021_dismantlable_graph",
  "obstacle": null | {                           // optional; copied from the WH at the moment of falsification
    "obstruction_class": "<one of obstruction_catalog.md §A>",
    "mathematical_property_needed": "...",
    "propagation_path": "..."
  },
  "ts": "<ISO-8601>"
}
```

The `obstacle` field on `failed_attempts` is the durable record consumed by §C.2's Diagnoser ternary judge and by `tool_discoverer.md §C` when a future round needs to query whether the same obstruction has been seen before. Keeping it on both the live WH (above) and the FA entry is intentional: the WH carries it during the active lifecycle; the FA carries it after the WH is retired.

The Proposer's anti-hint rule (architecture_report.md Q1) treats
`as_explanation: true` entries as *vocabulary anti-hints* (the property
itself can be reused as a sub-feature; the *causal claim* cannot be
repeated).

---

## B. Lifecycle rules

A WH passes through a small state machine. The transitions are driven
by the explain-why prompt's verdict (`workspace/agents_spec/explain_why_prompt.md` §A.3).

### B.1 Creation: ACTIVE

Trigger: explain-why prompt emits `wh_seed` (seed prompt, step 1 of a plan)
OR `successor` (stress-test prompt, REFUTED_AT_EXPLANATION verdict).

Tracker action:

1. Allocate next ID: `WH-{max(existing) + 1}`.
2. Copy `claim`, `candidate_property` from prompt output.
3. Initialise `predictions[]` from the prompt's `next_predictions` (if
   provided) OR from the next K plan steps (default K = 3).
4. Set `verdict: ACTIVE`, `successor_id: null`.
5. Append `tracker_log` event: `"WH-{N} created from {anchor_case}"`.

### B.2 Per-step verification

Trigger: explain-why prompt emits `verdict: CONFIRMED` after step k.

Tracker action:

1. Find the WH's prediction whose `next_complexity == test_plan[k].instance`.
2. Set `prediction.status = "verified"`, `prediction.evidence = <pointer>`.
3. Push the just-tested instance into `complexity_frontier.tested`.
4. Recompute `complexity_frontier.next`.
5. Append `tracker_log` event.

The WH stays ACTIVE; a long-active WH whose every prediction has
`status == "verified"` and which has no remaining pending predictions
gets `verdict: VERIFIED` (terminal-but-good) — this is the success case.

**WH verdict is the WH-level gate, not the conjecture-level gate.** WH:VERIFIED
means *this particular hypothesis* is empirically supported by every prediction
made so far on the current `test_plan`. It does NOT mean the conjecture is
proved or even empirically verified. The conjecture-level `completion_status`
(see §G) is computed by a separate gate function `update_completion_status`
that consults: WH verdicts, the verifier's `pass_rate` and `verification_qualifier`,
and the absence of pending plan steps. Treat WH:VERIFIED as a *necessary but
not sufficient* signal for the conjecture-level gate.

```
def wh_verdict_transition(wh, prediction_just_settled):
    if all(p.status == "verified" for p in wh.predictions) and \
       no_pending_predictions(wh):
        wh.verdict = "VERIFIED"
    # NB: this does NOT touch state.current_conjecture.completion_status.
    # The orchestrator calls update_completion_status() (§G) after this.
```

For Scout Mode runs (`workspace/agents_spec/scout_mode.md`), the scout-WH cannot
transition to VERIFIED — it stays ACTIVE pending deep-dive escalation. See §G's
guard table for the exhaustive rule.

### B.3 Per-step refutation at the explanation level

Trigger: explain-why prompt emits `verdict: REFUTED_AT_EXPLANATION`
(conjecture passes, candidate_property fails).

Tracker action:

1. Find the affected prediction; set `status = "falsified"`, copy the
   prompt's evidence pointer.
2. Set the WH's `verdict = FALSIFIED_AT_NEXT_LEVEL`.
3. **Validate and copy the `obstacle` field** from the explain-why output. The
   `obstruction_class` must match one of the eight values in
   `workspace/agents_spec/obstruction_catalog.md §A`; if not, the entry is
   logged as `"obstacle: invalid_class"` in `tracker_log` and the obstacle is
   set to `null` (the §C.2 dispatch falls back to the binary judge).
4. Create a successor WH-{N+1} from the prompt's `successor` block (§B.1
   creation logic). The successor inherits a *fresh* obstacle slot (initialised
   to `null`); the predecessor's obstacle is not copied forward, since it
   describes *why the predecessor failed*, not what the successor faces.
5. Set the falsified WH's `successor_id = WH-{N+1}`.
6. Add a `failed_attempts` entry with `as_explanation: true` (cf. §A); copy
   the WH's `obstacle` field onto the FA entry.
7. Append `tracker_log` events for both falsification and successor creation.
8. Trigger §C: representation-restrictiveness check (binary judge, legacy);
   then §C.2: ternary judge for technique-insufficient dispatch.

### B.4 Per-step refutation of the conjecture itself

Trigger: explain-why prompt emits `verdict: FALSIFIED`.

Tracker action:

1. Mark prediction `status = "falsified"`.
2. Set the WH's `verdict = TERMINAL` (the WH cannot have a successor
   because the conjecture itself failed; explain-why would generate
   nonsense).
3. Add `failed_attempts` entry with `as_explanation: false` (this
   refutes the conjecture, not just the explanation).
4. Append `tracker_log` event.
5. Hand control to the Diagnoser (`architecture_report.md` Q2). The
   Tracker does NOT generate a successor here.

The Diagnoser may eventually emit a *new* current_conjecture, at which
point the next round's seed prompt creates a fresh WH-{N+2}.

### B.5 Mixed outcome

Trigger: explain-why prompt emits `verdict: MIXED`.

Tracker action: split the step's effects into the pass-subset (treated
as §B.3 REFUTED_AT_EXPLANATION) and the fail-subset (treated as a
*partial* §B.4 FALSIFIED on the failing instances). The successor WH's
predictions are populated only from the pass-subset; the fail-subset
feeds a parallel Diagnoser invocation.

### B.6 Successor-WH chain length cap

The Tracker rejects successor creation if the chain length
`WH-1 → WH-2 → ... → WH-N` exceeds **6** within a single conjecture's
lifecycle (matching OP-1's actual round count). This is a heuristic
"are we drifting?" guard. On exceeding 6, the Tracker emits a
`tracker_log` event `"WH chain exceeded 6; escalating to Bridge"` and
the next round's Proposer is required to consult the Bridge module
before emitting a fresh WH.

---

## C. Interaction with the representation registry

The Tracker is the source of REP-DISCOVERER triggers. Specifically:

### C.1 The "representation too restrictive" judge

When a WH is falsified at the explanation level (§B.3), the Tracker
inspects the falsified prediction's evidence:

```
IF actual_outcome == "pass" AND candidate_property fails AND
   the failure mode has a "uniform structural axis"
   (Diagnoser-confirmed; cf. architecture_report.md Q2)
THEN
   the explanation was "too restrictive in the current rep" — switch rep
ELSE
   the explanation was "wrong about which feature matters" — successor WH
   only, no rep switch
```

Concretely on OP-1 step 5 (S_{1,2} k=4 chordality refutation):

- `actual_outcome` = pass (54/54 dismantlable)
- `candidate_property` = chordality, fails on 12/54 with uniform pattern
  (degree sequence 6,5,5,5)
- Diagnoser confirms uniformity ⇒ representation-too-restrictive verdict
- Tracker fires Rep Discoverer with input
  `{current_rep: rep_022_chordal_peo, failure_mode: "induced 4-cycle with
   degree (6,5,5,5)"}`
- Rep Discoverer queries registry → returns `rep_021_dismantlable_graph`
  (the strict-weakening parent) plus suggests a sibling
  `rep_024_w4_metric_chepoi` (the (W4) form)

### C.2 Discoverer query payload

The Tracker's invocation of the Rep Discoverer is a structured query
matching `lean/LeanAgent/registry/representations/SCHEMA.md` §3.2:

```jsonc
{
  "query_kind": "diagnoser",
  "object": "DL_contractibility_OP1",
  "domain": "combinatorial_topology",
  "current_rep_id": "rep_022_chordal_peo",
  "failure_mode": "12 non-chordal DLs at S_{1,2} k=4; degree sequence (6,5,5,5)",
  "wh_at_falsification": "WH-1",
  "evidence_pointer": "test_plan[5].actual_evidence"
}
```

The Discoverer returns a ranked list of candidate reps; the Tracker
attaches the top candidate's `rep_id` to the next round's
`current_conjecture.rep_id` and lets the Proposer re-emit a `test_plan`
in the new representation.

### C.2 Diagnoser ternary judge — technique-insufficient dispatch

The §C.1 binary judge (rep too restrictive vs explanation wrong) is preserved as the legacy first pass. Once the binary judge has classified the failure, a *second* dispatch fires when the WH has a non-null `obstacle` (set by §B.3 step 3): the **ternary judge** routes between Rep Discoverer and Tool Discoverer.

```
binary_judge_output ∈ {rep_too_restrictive, conjecture_wrong, explanation_wrong}
                                   │
                                   ▼
                       ternary_judge(WH, obstacle, diagnoser_axis):

   IF binary == "conjecture_wrong"                          → §B.4 path (no Discoverer)
   ELIF binary == "rep_too_restrictive"
        AND obstacle.obstruction_class ∈
            {loose_inequality, wrong_direction, regularity_loss}
        AND diagnoser_axis_uniformity confirmed              → BOTH dispatchers fire in parallel:
                                                                Rep Discoverer (existing §C.1)
                                                                Tool Discoverer (tool_discoverer.md §B.1)
   ELIF binary == "rep_too_restrictive"                     → Rep Discoverer ONLY (existing §C.1)
   ELIF binary == "explanation_wrong"
        AND obstacle.obstruction_class ∈
            {combinatorial_blowup, missing_lower_bound,
             non_constructive_witness, coupling_breaks,
             intractable_certificate}                        → Tool Discoverer ONLY
   ELIF binary == "explanation_wrong" AND obstacle is null   → successor WH only (no Discoverer)
   ELSE (chain length > 4 + same rep on last 2 WHs)         → Tool Discoverer §B.2 secondary trigger
```

The judge code emitted as `"technique_insufficient"` corresponds to the two `Tool Discoverer` paths above (the parallel-with-Rep path and the Tool-only path); the orchestrator uses this code to compose the input payload to `tool_discoverer.md §C`. When *both* Discoverers fire, the Proposer merges their outputs per `tool_discoverer.md §G`.

The mapping from `obstruction_class` to the binary-judge branch is a **routing heuristic**, not a logical theorem; the operator may override the dispatch in the input payload. The catalog of which obstructions go with which branches is grounded in the historical examples in `workspace/agents_spec/obstruction_catalog.md §B` and is expected to be revisited each time a new `obstruction_class` is added (Phase-3).

### C.3 What the Tracker does NOT do

- The Tracker does *not* create new representation entries. That is the
  Rep Discoverer's job (`workspace/reports/architecture/architecture_v2.md` §1.3 / §2.2).
- The Tracker does not write to `registry/playbook/` or `registry/lemmas/`.
- The Tracker does not invoke literature search; that is the Bridge
  module's job. The Tracker may *trigger* a Bridge call (§B.6) but does
  not formulate the query itself.

---

## D. OP-1 complete WH trace (counterfactual)

This is what the Tracker would have produced if invoked on OP-1's actual
verifier outputs from Round 1 onward. The trace mirrors and compresses
the human trace (`workspace/op1_detailed.md` §11.6, 6 rounds) into a
single sweep with 6 WHs and 9 plan steps.

Plan steps (matches `instance_sorter.md` §D):

```
step 1: S_{1,1} k=1   → seed prompt   → WH-1
step 2: S_{1,1} k=2   → stress WH-1   → WH-1 CONFIRMED
step 3: S_{1,1} k=3   → stress WH-1   → WH-1 CONFIRMED
step 4: S_{1,2} k=2   → stress WH-1   → WH-1 PARTIALLY refuted; WH-2 created
step 5: S_{1,2} k=4   → stress WH-2   → WH-2 falsified-as-chordality; WH-3 created
step 6: S_{1,2} k=5..8                → stress WH-3 → WH-3 CONFIRMED
step 7: S_{2,1} k=2..4                → stress WH-3 → WH-3 CONFIRMED
```

WH lifecycle records:

```jsonc
"why_hypotheses": [
  {
    "id": "WH-1",
    "anchor_case": "S_{1,1} k=1",
    "claim": "DL is dismantlable because it has a universal vertex (cone)",
    "candidate_property": "DL has a vertex adjacent to every other vertex",
    "rep_id_at_creation": "rep_019_universal_vertex",
    "predictions": [
      { "next_complexity": "S_{1,1} k=2",  "status": "verified",
        "evidence": "3/3 DLs have universal vertex" },
      { "next_complexity": "S_{1,1} k=3",  "status": "verified",
        "evidence": "5/5 DLs have universal vertex" },
      { "next_complexity": "S_{1,2} k=2",  "status": "falsified",
        "evidence": "58/64 have universal vertex; 6 K_4-core CEs do not" }
    ],
    "verdict": "FALSIFIED_AT_NEXT_LEVEL",
    "successor_id": "WH-2"
  },
  {
    "id": "WH-2",
    "anchor_case": "S_{1,2} k=2 (full set)",
    "claim": "DL is dismantlable; failed cone-form is fixed by allowing
              iterative dominance (chordality is the natural strengthening)",
    "candidate_property": "DL is chordal",
    "rep_id_at_creation": "rep_022_chordal_peo",
    "predictions": [
      { "next_complexity": "S_{1,2} k=3",  "status": "verified",
        "evidence": "63/63 chordal" },
      { "next_complexity": "S_{1,2} k=4",  "status": "falsified",
        "evidence": "42/54 chordal; 12 non-chordal CEs all still
                     dismantlable; degree sequence (6,5,5,5)" }
    ],
    "verdict": "FALSIFIED_AT_NEXT_LEVEL",
    "successor_id": "WH-3"
  },
  {
    "id": "WH-3",
    "anchor_case": "S_{1,2} k=4 (12 non-chordal CEs)",
    "claim": "DL is dismantlable because every induced 4-cycle has a
              common neighbour (Chepoi-Osajda W4 condition)",
    "candidate_property": "DL satisfies (W4): every induced 4-cycle has a
                            5th vertex adjacent to all four",
    "rep_id_at_creation": "rep_024_w4_metric_chepoi",
    "predictions": [
      { "next_complexity": "S_{1,2} k=5",  "status": "verified",
        "evidence": "all DLs at this level have all 4-cycles filled" },
      { "next_complexity": "S_{1,2} k=6..8", "status": "verified",
        "evidence": "271/271 cumulative, 209 vacuous, 62 with filled 4-cycles" },
      { "next_complexity": "S_{2,1} k=2..4", "status": "verified",
        "evidence": "47/47 cumulative" }
    ],
    "verdict": "VERIFIED",
    "successor_id": null
  }
],

"failed_attempts": [
  {
    "id": "FA-1", "as_explanation": true,
    "form": "DL has a universal vertex",
    "disproved_by": "6 K_4-core CEs on S_{1,2} k=2",
    "structural_pattern": "K_4 ∪ 4 leaves with no leaf-leaf edges",
    "successor_id": "WH-2",
    "rep_id_at_falsification": "rep_019_universal_vertex"
  },
  {
    "id": "FA-2", "as_explanation": true,
    "form": "DL is chordal (no induced 4-cycle)",
    "disproved_by": "12 non-chordal DLs at S_{1,2} k=4",
    "structural_pattern": "induced 4-cycle, degree sequence (6,5,5,5)",
    "successor_id": "WH-3",
    "rep_id_at_falsification": "rep_022_chordal_peo"
  }
]
```

Compression vs the actual trace:

| Real round | Tracker WH | Note |
|---|---|---|
| Round 1: universal vertex DISPROVED | WH-1 falsifies at step 4 | Compressed by 2 rounds (steps 1–3 are now sanity confirmations) |
| Round 2: Betti homology | (not represented as a WH; absorbed into the verifier qualifier) | Skipped — Betti is verification, not explanation |
| Round 3: dismantlable iterative | WH-2 (intermediate, chordality form) | Note the *order* differs: Tracker tries chordality first because it is the "obvious next strengthening"; the strict-stronger filter (architecture_report.md Q1) catches it only after step 5 |
| Round 4: chordality DISPROVED | step 5 falsification of WH-2 | Folded into WH-2's lifecycle, not a separate round |
| Round 5: typology | absorbed into Diagnoser axis-uniformity at step 4 and step 5 | No fresh WH |
| Round 6: (W4) + (M) Chepoi-Osajda | WH-3 from step 5 successor | The Bridge module retrieves Chepoi-Osajda 2014 as the "weakly modular" → "(W4)" keyword expansion |

Result: 6 conceptual rounds → 3 active WHs → 1 sweep, with the
geometric proof of (W4) still OPEN as in the real trace.

---

## E. Failure modes and edge cases

- **Stale `complexity_frontier.next`**: when the Sorter rejects the
  Tracker's proposed next instance (validation failure, see
  `instance_sorter.md` §E), the Tracker recomputes from
  `complexity_frontier.tested` and the next plan step's index.
- **WH ID collision**: should never happen if the Tracker is the only
  writer. Detected by a uniqueness check at write time; on collision
  the second writer is rejected (the Proposer's emission is bounced).
- **Cyclic `successor_id` chain**: rejected at write time. The Tracker
  walks the chain on every successor creation.
- **Predictions targeting a step that no longer exists**: the plan
  was truncated or cancelled. Such predictions get `status:
  "cancelled"` (a fourth status value in addition to pending/verified/
  falsified) and are not used to gate WH verdict transitions.
- **Multiple WHs active simultaneously**: legal (can have parallel
  explanations of the same conjecture). The stress-test prompt
  (`workspace/agents_spec/explain_why_prompt.md` §A.2) is invoked once *per
  active WH* per step. The Tracker runs all updates atomically per
  step; conflicts (one WH says CONFIRMED, another says
  REFUTED_AT_EXPLANATION) are recorded independently and do not
  cancel each other.

---

## F. Implementation footprint estimate

Following the capability-2 cost analysis in this conversation
(F. 最小实现成本):

| Piece | Type | Est. LOC |
|---|---|---|
| State schema extension (this file's §A) | JSON schema doc | ~60 |
| WH lifecycle state machine | Python, async-safe writes | ~200 |
| Discoverer-trigger heuristic (§C.1) | Python | ~50 |
| Counterexample-axis interface to Diagnoser | Python (light glue) | ~30 |
| `tracker_log` + replay tooling | Python | ~40 |
| **Total** | | **~380** |

Plus prompt template files (this doc + `explain_why_prompt.md` +
`instance_sorter.md`): ~350 lines of markdown, no Python.

The Tracker is the largest of the three new modules but still small
compared to the existing Lean pipeline. **The Tracker can be implemented
and validated against the OP-1 counterfactual in §D before any new OP
is launched**, providing an immediate sanity check on the design.

---

## G. Completion criterion

The conjecture-level done condition. Decoupled from WH verdict (§B.2). Owned
by the Tracker but read by the orchestrator's Archive stage as a gate on
summary emission.

### G.1 Four-level gate table

| Level | Gate predicate | Source of truth |
|---|---|---|
| **step** | `step.actual_outcome ∈ {pass, fail, mixed, error}` is set | already enforced by Verifier (`instance_sorter.md §C.1`) |
| **WH** | every `prediction.status = verified` AND no pending predictions remain | `§B.2` (this file) — sets `wh.verdict = VERIFIED` |
| **conjecture** | `pass_rate = 1.0` AND `verification_qualifier ≥ EXHAUSTIVE_ON_SAMPLE` AND every active WH has `verdict ∈ {VERIFIED, TERMINAL}` AND no pending plan steps | NEW: this section, drives `current_conjecture.completion_status` |
| **problem** | every conjecture in the problem has `completion_status ∈ {empirically_verified, formally_certified}` AND retrospectives have run | NEW: orchestrator's Archive stage |

### G.2 `update_completion_status` — pseudocode

The Tracker calls this after every step's WH lifecycle update.

```python
def update_completion_status(state) -> str:
    c = state.current_conjecture

    # Step-level signals
    if any(s.actual_outcome == "fail" for s in c.test_plan):
        c.completion_rationale = "step-level fail observed"
        return "falsified"

    if any(s.actual_outcome == "error" for s in c.test_plan
           and not retried_successfully(s)):
        c.completion_rationale = "step-level error not recovered"
        return "error"

    if any(s.actual_outcome is None for s in c.test_plan):
        c.completion_rationale = "plan steps still pending"
        return "pending"

    # Conjecture-level signals
    qualifier = c.verification_qualifier
    pass_rate = sum(s.actual_outcome == "pass" for s in c.test_plan) / len(c.test_plan)
    all_wh_settled = all(wh.verdict in {"VERIFIED", "TERMINAL"}
                         for wh in state.why_hypotheses)

    # Scout-mode guard: scout WH stays ACTIVE; never reach completion.
    if state.config.intent == "scout":
        c.completion_rationale = "scout mode — completion gated to deep_dive"
        return "pending"

    if pass_rate == 1.0 and qualifier == "EXACT" and all_wh_settled:
        c.completion_rationale = "EXACT qualifier + all WHs settled"
        return "formally_certified"

    if pass_rate == 1.0 and qualifier == "EXHAUSTIVE_ON_SAMPLE" and all_wh_settled:
        c.completion_rationale = "EXHAUSTIVE_ON_SAMPLE + all WHs settled"
        return "empirically_verified"

    # Inconclusive divergence guards
    if state.tracker_chain_length() > 6:
        c.completion_rationale = "WH chain exceeded 6; per §B.6 escalate to Bridge"
        return "inconclusive_open"

    if pass_rate == 1.0 and qualifier in {"NUMERICAL", "INCOMPLETE"}:
        c.completion_rationale = (
            f"empirical evidence at qualifier={qualifier}; needs lift to "
            f"EXHAUSTIVE_ON_SAMPLE or EXACT before completion"
        )
        return "inconclusive_open"

    return "pending"
```

### G.3 `can_emit_summary` — Archive stage gate

```python
def can_emit_summary(state) -> bool:
    """The orchestrator's Archive stage refuses to emit a closing summary
    unless completion_status is one of the two positive terminal states."""
    return state.current_conjecture.completion_status in {
        "empirically_verified",
        "formally_certified",
    }


def archive_payload(state):
    """When can_emit_summary is False, the Archive stage emits a *progress
    report* with explicit OPEN markers — never a 'done' summary.
    For inconclusive_open, the OPEN section MUST list:
      - the qualifier achieved (NUMERICAL / INCOMPLETE / EXHAUSTIVE_ON_SAMPLE)
      - the gap to formal certification (e.g. 'geometric proof OPEN')
      - the WH chain length (signal of divergence)
    """
    if can_emit_summary(state):
        return {"kind": "closing_summary", "completion_status": ...,
                "completion_rationale": ..., ...}
    return {"kind": "progress_report",
            "completion_status": state.current_conjecture.completion_status,
            "completion_rationale": state.current_conjecture.completion_rationale,
            "open_items": derive_open_items(state)}
```

### G.4 OP-1 retrospective check

What the gate would have said for OP-1's 7 historical rounds:

| Real round | Real verdict | `completion_status` | Notes |
|---|---|---|---|
| R1 universal vertex | DISPROVED at S_{1,2} k=2 (6 K_4-core CEs) | `falsified` | agent moves on; no closing summary |
| R2 Betti homology | numerically supported, no proof | `inconclusive_open` | qualifier = NUMERICAL only — gate prevents "proved" claim |
| R3 dismantlable iterative | 378/378 verified | `empirically_verified` | qualifier = EXHAUSTIVE_ON_SAMPLE; closing summary MUST include "geometric proof OPEN" marker |
| R4 chordality | DISPROVED at k≥4 (12 CEs) | `falsified` | agent moves on |
| R5 typology / iterative dismantling | structural, partial coverage | `inconclusive_open` | no exhaustive enumeration |
| R6 (W4)+(M) Chepoi-Osajda | 318/318 verified | `empirically_verified` | same OPEN marker as R3 |
| R7 §11.8 reasoner unblock | 49/49 (i(σ_α, β) = i(α, β)) | `empirically_verified` | proof_obligation = "bigon cancellation total" still OPEN |

The four rounds (R2 / R3 / R6 / R7) where the human trace produced text reading like "done" would, under this gate, be forced to emit a progress report with an explicit `OPEN` section. The two falsified rounds (R1 / R4) correctly cause the agent to move on without claiming completion.

### G.5 Interaction with Scout Mode

Scout-mode runs (`workspace/agents_spec/scout_mode.md`) cap `test_plan` at 1
step and skip the Prover stage entirely. Per the guard in §G.2:

- A scout-WH stays ACTIVE; never reaches `verdict: VERIFIED`.
- `completion_status` stays `pending` for the scout's lifetime.
- The escalation to deep-dive inherits step 1's `actual_outcome / actual_evidence`
  and the scout-WH; only after deep-dive's stress-test rounds settle every WH
  can `completion_status` transition to `empirically_verified` or higher.

This prevents a 1-step scout from ever pretending to be a finished proof.

### G.6 What this gate does NOT do

- Does not invoke the Prover. Reaching `formally_certified` requires the
  Prover stage to have run and the Auditor to have signed off on an
  axiom-clean Lean term. The gate just *observes* the qualifier.
- Does not recover `error` states. Transient errors are the Diagnoser's
  problem; structural errors stay in `error` until a future round
  re-emits the test_plan.
- Does not affect WH lifecycle. WH transitions remain governed by §B.

---

## H. Out of scope

- **Cross-conjecture WHs** — a WH that explains *both* `conjecture_A`
  and `conjecture_B`. Currently each WH is scoped to one conjecture.
- **Probabilistic predictions** — `predicted_outcome` is `pass / fail /
  mixed / unknown`, not a probability. Bayesian extensions are
  conceivable but not included in v1.
- **Machine-learned WH ranking** — the explain-why prompt's
  `informativeness_rank` is computed by the prompt LLM. No learned
  reranker.
- **Rep Discoverer details** — the Tracker triggers but does not
  implement Discoverer logic. See `workspace/reports/architecture/architecture_v2.md`
  §1.3 / §2.2.

---

## §C.2.1 Bridge Trigger from Diagnoser (added Gap-2)

When the §C.2 ternary judge dispatches into `REP_ONLY` or `BOTH`, an additional check fires for the **Bridge direct trigger** (priority 2 of `tool_discoverer.md §H.2`):

```
IF binary_judge ∈ {rep_too_restrictive}
   AND falsification_evidence.structural_pattern is non-empty
THEN
   bridge_query = f"weaker than {current_property} implies {target_property}"
   emit BridgeTrigger(source="diagnoser", query=bridge_query, pattern=structural_pattern, priority=2)
ELSE
   emit no Bridge trigger from this dispatch
```

The `current_property` is the candidate property from the falsified WH (`why_hypotheses[k].candidate_property`); the `target_property` is the conjecture form (`current_conjecture.form`) — the *underlying* claim the candidate property was supposed to imply. The structural pattern is copied verbatim into the trigger so downstream Bridge consumers can decide if the literature search should anchor on the pattern (e.g. "induced 4-cycle with degree (6,5,5,5)").

The Tracker does **not** invoke Bridge directly; it merely emits the trigger record. The orchestrator collects triggers from Diagnoser, Strategy Proposer, and Tool Discoverer, picks the highest-priority one, and routes the single Bridge call.

When Strategy Proposer is also active in the same cycle and emits a `bridge_to_literature` candidate (priority 1), the Strategy Proposer trigger wins. This is the expected behaviour — Strategy Proposer has done more analysis and its `search_queries` are vetted; Diagnoser-direct is the fast path used when Strategy Proposer is bypassed (e.g. operator override that calls Diagnoser without Strategy).
