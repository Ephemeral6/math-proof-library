# Scope Judge — Specification

**Status**: design spec + Python implementation (Phase-1).
**Position**: between Verifier and Diagnoser. Fires when Verifier reports `actual_outcome == "fail"` AND the same conjecture has previously passed on at least one other instance. Decides whether the failure is a *real falsification* of the conjecture or merely a *scope limitation* (the conjecture is still true on the cases that matter; the failing instance is outside the intended scope).
**Related docs**:
- `workspace/agents_spec/instance_sorter.md` — Verifier writes `actual_outcome`.
- `workspace/agents_spec/hypothesis_tracker.md` §C / §G — Tracker consumes the verdict; `completion_status` reflects it.
- `workspace/agents_spec/strategy_proposer.md` — runs **after** scope judgement on `falsification` verdict.
- `workspace/reports/architecture/architecture_v2.md` Part X — embeds this spec into the loop.

---

## A. Position in the loop

```
   Verifier executes step k → step.actual_outcome ∈ {pass, fail, mixed, error}
       │
       ▼
   IF actual_outcome == "fail" AND has_prior_passes(state):
       │
       ▼
       SCOPE JUDGE (this spec)
           ├── parameter-boundary check
           ├── structural-consistency check
           ├── failure-severity check
           ├── proof-dependency check (1 LLM call)
           ▼
       ScopeVerdict ∈ {falsification, scope_limitation, uncertain}
       │
       ▼
       Branching:
         scope_limitation + workaround.exists → continue with caveat (skip Diagnoser)
         scope_limitation + !workaround       → Diagnoser fires; completion_status=inconclusive_open
         falsification                        → Diagnoser fires; Strategy Proposer fires
         uncertain (confidence < 0.6)         → [HUMAN_REVIEW_NEEDED]
```

The judge is positioned **upstream** of Diagnoser so that scope-limited failures do not unnecessarily fire the strategy / discoverer chain.

---

## B. Trigger conditions

Scope Judge fires iff:

1. `verifier_result.actual_outcome == "fail"`, AND
2. `state.current_conjecture` has at least one prior `actual_outcome == "pass"` on a different instance (i.e. `has_prior_passes(state)` is True).

Otherwise the failure proceeds directly to Diagnoser as before.

---

## C. Input contract

```jsonc
{
  "conjecture"            : { "id": "...", "form": "...", "rep_id": "rep_NNN" },
  "passing_instances"     : [
    { "instance": "S_{1,1} k=2", "params": { "g": 1, "n": 1, "k": 2 },
      "actual_evidence": "..." },
    ...
  ],
  "failing_instance"      : {
    "instance": "S_{2,1} k=5", "params": { "g": 2, "n": 1, "k": 5 },
    "actual_evidence": "93/100 fail; failures cluster at high genus"
  },
  "falsification_evidence": {
    "n_failing"           : 93,
    "n_total"             : 100,
    "structural_pattern"  : "non-chordal-non-cone DLs at high g",
    "passing_evidence"    : ["S_{1,1}: all chordal", "S_{1,2}: chordal-or-cone"]
  },
  "proof_dependency_graph": {                     // optional; null if unknown
    "steps": [
      { "id": "L1", "claim": "DL is chordal-or-cone", "uses": [] },
      { "id": "L2", "claim": "chordal-or-cone implies dismantlable",
                    "uses": ["L1"] }
    ]
  }
}
```

---

## D. Output contract

```jsonc
{
  "verdict"           : "falsification" | "scope_limitation" | "uncertain",
  "confidence"        : 0.0..1.0,
  "rationale"         : "<NL summary of the four signals>",
  "affected_scope"    : "S_{2,1} at k>=5",         // failing-side description
  "unaffected_scope"  : "S_{1,1} all k; S_{1,2} all k",  // passing-side description
  "workaround"        : {
    "exists"     : true | false,
    "description": "Lemma 7.1 provides alternative path for non-chordal-non-cone DLs",
    "cost"       : "low" | "medium" | "high"
  },
  "recommendation"    : "continue_with_scope_caveat" | "abandon" | "human_review",
  "signals"           : {
    "boundary"  : 0.0..1.0,
    "structure" : 0.0..1.0,
    "severity"  : 0.0..1.0,
    "scope_score": 0.0..1.0
  }
}
```

---

## E. Judgement logic — four signals + LLM tiebreaker

### E.1 Parameter boundary (`signals.boundary`)

For each numeric param (e.g. `g`, `n`, `k`), check if `failing_instance.params[p]` lies *outside* the convex hull of the passing instances' values for the same parameter.

```
for p in numeric_params:
    pass_vals = [pi.params[p] for pi in passing_instances if p in pi.params]
    if pass_vals:
        if failing.params[p] > max(pass_vals) or failing.params[p] < min(pass_vals):
            outside_count += 1
boundary_signal = outside_count / len(numeric_params)
```

Higher → more likely to be a scope limitation (the failing case is at the edge of tested space; the conjecture was never claimed there).

### E.2 Structural consistency (`signals.structure`)

If the failing instance's structural pattern is **absent** from all passing instances, the failure is structurally novel — more likely scope_limitation.

```
fail_pattern = falsification_evidence.structural_pattern
pass_blob = " ".join(pi.actual_evidence for pi in passing_instances).lower()
if fail_pattern and (fail_pattern.lower() not in pass_blob):
    structure_signal = 1.0
elif fail_pattern:
    structure_signal = 0.3                       # pattern was seen before — looks like real falsification
else:
    structure_signal = 0.5                       # no pattern info → 50/50
```

### E.3 Failure severity (`signals.severity`)

Inverted: lower failure ratio → higher scope-limitation signal.

```
ratio = n_failing / max(n_total, 1)
severity_signal = 1.0 - min(ratio / 0.5, 1.0)    # 0% fail → 1.0; 50%+ fail → 0.0
```

(Spec heuristic: <10% failure → strong scope_limitation signal; >50% failure → strong falsification signal.)

### E.4 Proof-dependency check + workaround search

When `proof_dependency_graph` is provided, locate which step's hypothesis the failing instance violates. If a sibling step provides an alternative path, return a `Workaround` record. This step makes a single LLM call (`stage = scope_judge`, `task = workaround`) — stub-friendly.

When the dependency graph is null, the workaround field is `Workaround(exists=False, ...)` and the LLM call is skipped.

### E.5 Aggregation

```
scope_score = 0.3 * boundary + 0.3 * structure + 0.4 * severity

IF scope_score >= 0.7 AND workaround.exists:
    verdict       = "scope_limitation"
    confidence    = scope_score
    recommendation= "continue_with_scope_caveat"

ELIF scope_score <= 0.3:
    verdict       = "falsification"
    confidence    = 1.0 - scope_score
    recommendation= "abandon"

ELSE:
    # Tiebreaker — 1 LLM call (`stage = scope_judge`, `task = tiebreak`)
    verdict, confidence = llm_scope_judge(inputs)
    if confidence < 0.6:
        recommendation = "human_review"
    elif verdict == "scope_limitation":
        recommendation = "continue_with_scope_caveat"
    else:
        recommendation = "abandon"
```

---

## F. Interaction with completion criterion

| Verdict | Workaround | `completion_status` change |
|---|---|---|
| `scope_limitation` | exists | unchanged (remains `empirically_verified` if it had been) |
| `scope_limitation` | absent | `inconclusive_open` |
| `falsification` | (any) | `falsified` |
| `uncertain` | (any) | unchanged; `recommendation = human_review` |

The mapping is enforced by the orchestrator (`DeepDive/strategy_integration.py`) — Scope Judge itself only emits the verdict.

---

## G. OP-1 retroactive validation — S_{2,1} 6 K_4-style exceptions

OP-1 §11.7 reports: on `S_{2,1}` at `k=2`, 6 of 47 DLs are non-chordal-non-cone (≈ 13%). The other 41 are non-chordal-but-cone (chordal-or-cone dichotomy holds). On `S_{1,1}` and `S_{1,2}` the dichotomy holds vacuously (or with the cone form). Replaying:

- Passing: `S_{1,1}` 60/60, `S_{1,2}` k≤3 127/127.
- Failing on the dichotomy: `S_{2,1}` k=2: 6/47.
- `boundary_signal`: failing has g=2, max passing g=1 → 1.0 on the genus axis (1/1 axis outside).
- `structure_signal`: "non-chordal-non-cone" pattern not in passing evidence → ~1.0.
- `severity_signal`: 6/47 ≈ 13% → 1 - 0.13/0.5 ≈ 0.74.
- Workaround: Lemma 7.1 (iterative reduction) provides an alternative path — `exists=True`, `cost=low`.
- `scope_score = 0.3·1 + 0.3·1 + 0.4·0.74 = 0.896` → `verdict = scope_limitation`, `recommendation = continue_with_scope_caveat`.

Matches the human's read: "DL on S_{2,1} k=2 has 6 non-chordal-non-cone exceptions but they are still dismantlable iteratively; this is a scope limitation of the chordal-or-cone proof, not a falsification."

---

## H. Human-in-the-loop (`uncertain` verdict)

When `verdict == "uncertain"` OR `confidence < 0.6`, the orchestrator emits a `[HUMAN_REVIEW_NEEDED]` marker with the full payload (signals, evidence, candidate verdicts, workaround search log) and pauses. The operator can:

- Override to `falsification` / `scope_limitation` and the loop continues.
- Reject and close the conjecture.
- Provide additional evidence (e.g. a manually written `proof_dependency_graph`) and re-run.

The marker is the only legitimate "stop and ask" point in the deep-dive flow that this spec introduces.

---

## I. Python implementation footprint

| Piece | Type | Est. LOC |
|---|---|---|
| `ScopeVerdict` + `Workaround` dataclasses | Python | 30 |
| Four signal functions | Python | 60 |
| LLM workaround / tiebreaker (stub-friendly) | Python | 50 |
| `run_scope_judge` aggregation | Python | 40 |
| **Total** | | **~180** |

---

## J. Out of scope

- **Auto-applied workaround** — when a workaround is found, the orchestrator prints the description and asks the operator to integrate it into the proof. There is no auto-rewrite mode.
- **Cross-conjecture scope inheritance** — a scope limitation on conjecture A does not propagate to a sibling conjecture B even if they share a rep. Each conjecture is judged independently.
- **Dynamic re-scoping** — the spec assumes the conjecture's intended scope is implicit in `passing_instances`. Explicit scope declarations (e.g. "this theorem only claims `g ≤ 1`") are not part of the State today; treating them is a Phase-2 extension.
