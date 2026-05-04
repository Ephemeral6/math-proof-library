# Instance Sorter — Specification

**Status**: design spec, no implementation yet.
**Position**: not an independent module. Instance Sorter is a *field on the Proposer's output schema* (`test_plan`). The orchestrator and the Verifier read this field; the Verifier executes the plan step by step and writes back per-step outcomes.
**Related docs**:
- `workspace/reports/architecture/architecture_v2.md` §5.1 — instance-complexity ordering rationale.
- `workspace/agents_spec/explain_why_prompt.md` — explain-why fires after each step.
- `workspace/agents_spec/hypothesis_tracker.md` — `why_hypothesis_id` cross-reference.
- `workspace/reports/architecture/architecture_report.md` Q1 / Q2 — Proposer / Verifier in v1.

---

## 0. Why a sorter, why not a module

The discovery-loop v1 (architecture_report.md Part II) has Proposer and
Verifier as separate modules; the implicit convention is "the Proposer
emits a conjecture, the Verifier checks it on a dataset chosen by the
Verifier." That coupling hides the *order in which the dataset is
visited*, but the order is exactly what enables Capability 2 (generalize
vs specialize): a smallest-first sweep produces a hypothesis after step 1
that gets *tested* at step 2.

Three options were considered (cf. the capability-2 analysis):

1. Sorter inside the Verifier — early termination on smallest failure.
2. Sorter between Proposer and Verifier — Proposer emits a `test_plan`.
3. Sorter inside the Diagnoser — counterexample classified by complexity.

Option 2 won because it lets the explain-why prompt and the Hypothesis
Tracker hook into the *transitions* between plan steps, which is where
the falsifiable predictions live. Options 1 and 3 are still useful but
are implementation details — short-circuit (1) belongs in the Verifier
executor; counterexample axis-uniformity (3) is what the Diagnoser
already does (architecture_report Q2).

So the sorter is **just a field** on what the Proposer already emits.

---

## A. `test_plan` — field schema

The Proposer's output JSON gains a top-level `test_plan` array. Each
element is one instance to verify, in execution order:

```jsonc
{
  "conjecture": "every descending link satisfies (W4) + (M)",
  "rep_id": "rep_024_w4_metric_chepoi",        // from registry/representations
  "test_plan": [
    {
      "step": 1,
      "instance": "S_{1,1} k=2",
      "complexity": 0.10,
      "complexity_rationale": "genus 1, 1 puncture, k=2; expected DL size ~3 (Farey)",
      "predicted_outcome": "pass",
      "why_hypothesis_id": null,                // step 1 sets the first WH
      "verifier_command": "python workspace/op1_scripts/quadrangle_check.py --surface 1 1 --k-max 2",
      "actual_outcome": null,
      "actual_evidence": null
    },
    {
      "step": 2,
      "instance": "S_{1,1} k=3",
      "complexity": 0.18,
      "complexity_rationale": "same surface, larger level — generalisation in k only",
      "predicted_outcome": "pass",
      "why_hypothesis_id": "WH-1",              // tests WH-1 (set after step 1)
      "verifier_command": "python workspace/op1_scripts/quadrangle_check.py --surface 1 1 --k-max 3",
      "actual_outcome": null,
      "actual_evidence": null
    },
    {
      "step": 3,
      "instance": "S_{1,2} k=2",
      "complexity": 0.42,
      "complexity_rationale": "puncture +1 — first surface change; smallest non-Farey k=2",
      "predicted_outcome": "pass",
      "why_hypothesis_id": "WH-1",
      "verifier_command": "python workspace/op1_scripts/quadrangle_check.py --surface 1 2 --k-max 2",
      "actual_outcome": null,
      "actual_evidence": null
    },
    /* ... further steps ... */
    {
      "step": 8,
      "instance": "S_{2,1} k=4",
      "complexity": 0.95,
      "complexity_rationale": "highest tested complexity in OP-1 trace",
      "predicted_outcome": "pass",
      "why_hypothesis_id": "WH-3",
      "verifier_command": "python workspace/op1_scripts/quadrangle_check.py --surface 2 1 --k-max 4",
      "actual_outcome": null,
      "actual_evidence": null
    }
  ]
}
```

### Field semantics

- `step` — 1-indexed sequence number; the Verifier executes in this order.
- `instance` — domain-specific human-readable identifier.
- `complexity` — float in `[0, 1]`; computed by the domain-specific rule
  in §B. Used for tie-breaking and for the `complexity_rationale` audit
  trail. The orchestrator does NOT enforce monotonicity (some plans
  legitimately re-visit a smaller case as a sanity check); but the
  default emitter produces a non-decreasing sequence.
- `complexity_rationale` — one sentence explaining *why* this is the
  next-smallest unvisited case. This is what the explain-why prompt
  inherits as context.
- `predicted_outcome ∈ {pass, fail, mixed, unknown}` — the Proposer's
  prediction at plan-emission time. Compared against `actual_outcome`
  to update the WH's `predictions[].status`.
- `why_hypothesis_id` — pointer into the State's `why_hypotheses` array.
  `null` only on step 1 (no hypothesis yet); subsequent steps must
  reference an active hypothesis. The Verifier writes back into the
  same WH after the step finishes.
- `verifier_command` — concrete CLI invocation (or, for Lean, the
  theorem name to compile). The orchestrator executes this verbatim;
  no further interpretation.
- `actual_outcome ∈ {pass, fail, mixed, error}` — written back by the
  Verifier after execution.
- `actual_evidence` — short structured summary of what the Verifier
  actually saw (e.g. "271/271 satisfy (W4); 209 vacuously, 62 with
  induced 4-cycles all filled" or "CLARABEL infeasible at β = 0.957").

### Plan immutability

Once the Proposer emits a `test_plan` and the orchestrator starts
executing it, the plan is **append-only**: subsequent rounds may add
new steps (extending the sweep), but never re-order or delete existing
ones. Each completed step's `actual_outcome` and `actual_evidence` are
permanent record. If the conjecture is falsified mid-plan, the
remaining steps are *cancelled* (not deleted) — they retain
`actual_outcome: null` with a `cancelled_at_step: N` annotation at the
plan level.

#### Scout-to-deep-dive inheritance

When a deep dive inherits from a prior scout (`workspace/agents_spec/scout_mode.md §E`),
the deep-dive's `test_plan[1]` IS the scout's `test_plan[1]` — same row,
same `actual_outcome`, same `actual_evidence`. Steps 2..N are *appended*
to the existing plan, not inserted. This is **extension, not re-ordering**;
the immutability invariant still holds because the scout's row is
preserved verbatim.

The first stress-test prompt in the deep dive fires at step 2 (against
the inherited WH-1 from the scout's seed prompt), saving one Verifier
call + one LLM call relative to a deep dive launched without scout.

---

## B. Complexity ordering rules — domain-specific

The complexity scalar is *not* universal; it is computed by a small
per-domain function. New domains add a new rule. Cross-domain
comparisons are not meaningful.

### B.1 `geometric_topology` (OP-1, OP-3, OP-4)

Lex order on `(3g + n − 3, k, expected_DL_size, max_clique)`:

```python
def complexity_geo(instance):
    g, n = instance.surface          # e.g. (1, 1) for S_{1,1}
    k    = instance.level            # descending-link level
    sz   = instance.expected_DL_size # from prior rounds; ∞ if unknown
    mc   = instance.expected_max_clique
    return (3*g + n - 3, k, sz, mc)
```

Concrete OP-1 ordering (from architecture_v2.md §5.1):

| Surface | k | DL_size | max_clique | tuple             | scalar (normalised) |
|---------|---|---------|------------|-------------------|---------------------|
| S_{1,1} | 1 | 1       | 2          | (1, 1, 1, 2)      | 0.05                |
| S_{1,1} | 2 | 3       | 3          | (1, 1, 2, 3, 3)   | 0.10                |
| S_{1,1} | 3 | 5       | 3          | (1, 1, 3, 5, 3)   | 0.18                |
| S_{1,2} | 2 | 3-8     | ≤ 6        | (2, 2, 8, 6)      | 0.42                |
| S_{1,2} | 4 | -       | ≤ 6        | (2, 4, -, 6)      | 0.55                |
| S_{1,2} | 8 | -       | ≤ 6        | (2, 8, -, 6)      | 0.78                |
| S_{2,1} | 2 | -       | ≤ 17       | (4, 2, -, 17)     | 0.85                |
| S_{2,1} | 4 | -       | ≤ 17       | (4, 4, -, 17)     | 0.95                |

The normalised scalar in `[0, 1]` is `complexity = rank(tuple) / N_total`
where `N_total` is the size of the planned sweep. It exists for
display and tie-breaking only; the lex tuple is canonical.

### B.2 `optimization` (Theorem 3, OP-2 family)

For first-order method analysis, primary axis is the *momentum
parameter* (β for SHB, t for Nesterov), secondary is *step-size grid*,
tertiary is *lookahead depth*:

```python
def complexity_opt(instance):
    return (instance.beta,                   # primary: momentum / strong-convexity offset
            -instance.eta_grid_log_step,     # secondary: step-size resolution
            instance.lookahead_k,            # tertiary: anchor count
            instance.dimension_d)            # quaternary: state dim
```

Rationale: smaller β is "the textbook GD case"; certificates simpler.
Each lookahead step `k` introduces a new anchor; expensive but extends
the certified frontier. Theorem 3 rounds executed `k = 0, 1, 2, 3` in
that order.

Concrete Theorem 3 plan (matches `theorem3_final.md`):

| step | instance              | β     | k | scalar |
|------|-----------------------|-------|---|--------|
| 1    | β = 0,    k = 0       | 0.000 | 0 | 0.00   |
| 2    | β = 0.30, k = 0       | 0.30  | 0 | 0.10   |
| 3    | β = 0.50, k = 0       | 0.50  | 0 | 0.18   |
| ...  | (50 baseline points)  | ...   | 0 | ...    |
| 51   | β = 0.957, k = 0      | 0.957 | 0 | 0.55   |
| 52   | β = 0.957, k = 1      | 0.957 | 1 | 0.62   |
| 53   | β = 0.978, k = 1      | 0.978 | 1 | 0.70   |
| 54   | β = 0.99,  k = 2      | 0.99  | 2 | 0.85   |
| 55   | β = 0.992, k = 2      | 0.992 | 2 | 0.93   |
| 56   | β = 0.99,  k = 3      | 0.99  | 3 | 0.99   |

Step-by-step the plan tracks the actual Round-1..4 trajectory.

### B.3 `lean_formalization` (benchmark items)

For Lean theorems, complexity is `(layer, LOC, helper_count, novelty)`:

```python
def complexity_lean(instance):
    return (instance.layer,                  # 1 / 2 / 3 from FINAL_SUMMARY §4.2
            instance.optlib_LOC,             # ground-truth size
            instance.expected_helper_count,  # from Architect's blueprint
            instance.requires_novel_pattern) # bool — playbook lookup miss
```

The benchmark trace ran items #01 → #13 in this exact order; that is
the natural sweep. Layer 1 (#01–#06) → Layer 2 (#07–#10) → Layer 3
(#11–#13) is what FINAL_SUMMARY §4.2 already records.

### B.4 New domains

When a new domain enters the registry, the operator adds:

1. A `complexity_<domain>` function (Python, ~15–30 LOC).
2. A reference table of expected scalar values for known instances.
3. (Optional) a `tools_required` annotation showing which Verifier
   stack is invoked for each step.

The function is the source of truth; the table is for human review.

---

## C. Verifier interface

The Verifier consumes a `test_plan` and writes back outcomes. Contract:

### C.1 Read contract

The Verifier reads the State JSON and finds
`State.current_conjecture.test_plan` (an array). It iterates from
`step = 1`:

```
for step_record in test_plan:
    if step_record.actual_outcome is not None:
        continue                              # already executed
    result = run(step_record.verifier_command)
    step_record.actual_outcome  = parse_pass_fail(result)
    step_record.actual_evidence = summarise(result)
    state.write()                             # persist after every step
    fire_explain_why(step_record)             # workspace/agents_spec/explain_why_prompt.md
    fire_tracker_update(step_record)          # workspace/agents_spec/hypothesis_tracker.md
    if step_record.actual_outcome == "fail":
        if state.config.early_terminate_on_fail:
            cancel_remaining(test_plan, step_record.step)
            return
```

### C.2 Write contract

After each step, the Verifier writes (atomically) to:

- `step_record.actual_outcome ∈ {pass, fail, mixed, error}`
- `step_record.actual_evidence` — short string, ≤ 500 chars
- `state.evidence` — append a new `{"kind": "...", "scope": "...", "result": "..."}` entry referencing the verifier output file
- `state.tracker_log` — append an event `{"iter": N, "step": K, "event": "..."}`

The Verifier does NOT touch:

- `step_record.predicted_outcome` (set by Proposer at plan time; immutable)
- `step_record.why_hypothesis_id` (set by Proposer; the Tracker may patch
  this in a separate write, but not the Verifier)
- earlier steps' fields

### C.3 Failure-mode handling

If `verifier_command` returns a non-zero exit code or otherwise crashes:

- `actual_outcome = "error"`
- `actual_evidence = "<exception class>: <first 300 chars of stderr>"`
- the orchestrator pauses the plan; downstream steps are NOT auto-cancelled
  (a transient `clarabel.SolverError` should not kill a 50-step sweep).
- the Diagnoser is invoked to classify whether this is transient
  (re-run the step) or structural (cancel and refine the plan).

### C.4 Mixed outcome

`mixed` means *partial pass*: the verifier ran successfully but the
result is "some pass, some fail" (e.g. "62/64 DLs satisfy P; 2 K_4-core
CEs"). This is the most informative case and should never be reduced
to `fail` — the Diagnoser slices the failed subset by candidate axes
(architecture_report Q2). The `actual_evidence` field must record the
pass/fail split:

```
actual_evidence: "62/64 pass; 2 fail; failing instances: alpha=25, alpha=72;
                  shared structure: K_4 + 4 leaves with no leaf-leaf edges"
```

---

## D. Worked example: OP-1 with sorter (counterfactual)

The actual OP-1 trace ran *all* surfaces and *all* levels in batch mode.
With the sorter, the plan would have been:

```
step 1: S_{1,1} k=1     predicted: pass, WH: null      actual: pass (1/1)
step 2: S_{1,1} k=2     predicted: pass, WH: WH-1      actual: pass (3/3)
        [explain-why fires: "DL too small for 4-cycle"]
        [tracker registers WH-1 with prediction for step 3]
step 3: S_{1,1} k=3     predicted: pass (WH-1), WH: WH-1   actual: pass (5/5)
step 4: S_{1,2} k=2     predicted: pass (WH-1), WH: WH-1   actual: pass (64/64)
        [WH-1 PARTIALLY refuted: 31/64 have 4-cycles, all filled
         → tracker creates WH-2: "4-cycles exist but always filled"]
step 5: S_{1,2} k=4     predicted: pass (WH-2), WH: WH-2   actual: pass (54/54)
        [chordality ALSO checked as a side-property; 12/54 fail chordality
         → tracker logs as fact, but does NOT spawn a chordality WH
         (chordality is strictly stronger than WH-2; rejected by the
          anti-strictly-stronger filter — concretely:
            from LeanAgent.scripts.strict_stronger import (
                reject_against_failed, Predicate, load_registry_ctx)
            ctx = load_registry_ctx()
            if reject_against_failed(
                Predicate(rep_id="rep_022_chordal_peo"),
                [Predicate(rep_id=wh.rep_id_at_creation) for wh in active_whs],
                ctx) is not None:
                # filter rejects — chordality not a candidate WH
                ...
          )]
step 6-8: S_{1,2} k=5..8                                      actual: pass
step 9: S_{2,1} k=2..4                                        actual: pass
done. WH-2 promoted to "DL satisfies (W4) + (M)" (rep_024 confirmed)
```

The compression: 6 conceptual rounds → 1 sweep with 9 plan steps. The
Hypothesis Tracker accumulates WH-1 → WH-2; the chordality detour
(real Round 4) is filtered out before being a Round.

---

## E. Validation rules

Before the orchestrator accepts a `test_plan`:

1. **Step indices** are 1, 2, 3, ... contiguous.
2. **First step** has `why_hypothesis_id == null`.
3. **Subsequent steps** have non-null `why_hypothesis_id` matching an
   ID the Tracker is allowed to register (i.e. either a fresh ID or
   an active WH).
4. **Verifier commands** are syntactically valid for the registered
   verifier stack (cheap precondition: the orchestrator parses the
   first token and checks it against an allow-list).
5. **Complexity sequence** is non-decreasing by default; explicit
   re-visits to smaller complexity require an annotation
   `revisit_reason: "..."`.
6. **No duplicate `(instance, verifier_command)` pairs** in one plan
   (de-dup is the orchestrator's job, not the Verifier's).

A plan that fails validation is bounced back to the Proposer with a
specific error code; the Proposer re-emits.

---

## F. Out of scope (future work)

- **Adaptive plan extension**: when WH-1 is refuted at step 4, should
  the Proposer be allowed to *insert* steps 4.1, 4.2 to localise the
  refutation? Currently no — the plan is append-only and the next plan
  is the next round's responsibility. A future "in-flight refinement"
  feature could relax this.
- **Cross-domain plans**: a plan that mixes geometric and analytic
  instances (e.g. "verify W4 on S_{1,2} AND verify the analogous LMI
  property") would need a unified complexity scalar. Not yet supported.
- **Distributed execution**: each step runs sequentially on one
  worker. Trivial parallelism (independent steps) is left to the
  Verifier's executor.
