# Scout Mode — Specification

**Status**: design spec, no implementation yet.
**Position**: divergent dispatcher path activated by an `intent` flag on Proposer input. Forks the v2 discovery loop *after* Proposer emission and *before* full Verifier execution. Scout Mode is for **low-cost batch tractability scanning** of open problems; the existing 7-round deep dive is the other branch.

**Related docs**:
- `workspace/reports/architecture/architecture_v2.md §II.A` — fork-point in the dispatcher flow.
- `workspace/agents_spec/instance_sorter.md` — `test_plan` is capped at 1 step in scout mode; deep-dive escalation extends (does not re-order) the plan.
- `workspace/agents_spec/explain_why_prompt.md §A.1` — seed prompt only fires; stress-test does not run.
- `workspace/agents_spec/hypothesis_tracker.md §B.2 / §G` — scout-WH guard (cannot transition to VERIFIED) and `completion_status` interaction.
- `lean/LeanAgent/registry/representations/SCHEMA.md §C` — Rep Selector probe is invoked normally.

---

## A. Position in the dispatcher

Scout Mode is *not* an independent module; it is a divergent execution path of the existing v2 discovery loop. The fork happens at the dispatcher level after the Proposer emits and the Rep Selector picks a representation. Both branches share the same Proposer, Rep Selector, Verifier executor, Explain-Why prompt invocation glue, and Tracker. They differ in:

- how many `test_plan` steps execute,
- which prompt variants fire,
- whether the Tracker registers a successor WH,
- whether the Prover stage and retrospectives run.

The math-proof-agent skill's intra-problem **Scout phase** (5-phase pipeline `Scout → Explorer → Judge → Auditor → Fixer`, per `CLAUDE.md`) is unrelated: that scout searches for *routes within one theorem*. This document specifies a *cross-problem portfolio scan* mode.

## B. `intent` flag

The Proposer's input gains a top-level `intent` field:

```jsonc
{
  "intent": "deep_dive" | "scout",     // default: "deep_dive"
  "goal": "...",
  "literature_in_scope": [...],
  ...
}
```

When `intent == "scout"`, the orchestrator caps the test_plan, restricts the prompt sequence, and emits a `tractability_report` instead of a closing summary.

## C. Scout flow

```
Goal(intent=scout)
   │
   ▼
PROPOSER  ─── emits ──► (conjecture + test_plan with max_steps=1 + initial WH-1 seed)
   │
   ▼
[Rep Selector — Architect probe]
   │   normal SCHEMA.md §C query, no change
   │
   ▼
VERIFIER  ─── executes test_plan[1] ──► per-step (actual_outcome, evidence)
   │
   ▼
[Explain-Why SEED prompt — workspace/agents_spec/explain_why_prompt.md §A.1]
   │   seed prompt fires; stress-test does NOT run (no step 2)
   │
   ▼
HYPOTHESIS TRACKER
   │   creates WH-1 from seed; verdict stays ACTIVE (cannot reach VERIFIED;
   │   cf. hypothesis_tracker.md §B.2 scout guard, §G.5)
   │
   ▼
[tractability_report] EXIT — see §D
```

The flow above replaces the deep-dive flow's branching at the Verifier-output stage. Scout never reaches Diagnoser, Prover, Tightness Pre-Audit, Judge, Auditor, Fixer, retrospectives, or Archive.

## D. Tractability verdict schema

Scout Mode's exit artefact:

```jsonc
{
  "problem_id"      : "<workspace/active/<run_id>>",
  "scout_outcome"   : "pass" | "fail" | "inconclusive" | "error",
  "scout_evidence"  : "<test_plan[1].actual_evidence verbatim>",
  "scout_wh": {
    "id"                : "WH-1",
    "claim"             : "<from seed prompt>",
    "candidate_property": "<from seed prompt>"
  },
  "scout_rep_id"    : "rep_NNN_<selected by Rep Selector>",
  "estimated_difficulty": "shallow" | "medium" | "deep" | "intractable",
  "difficulty_signals": {
    "verifier_runtime_s": 0.0,           // float
    "rep_tools_status"  : "available" | "partial" | "missing",
    "wh_anchor_size"    : 0,             // int — size of the anchor instance
    "registry_hits"     : 0              // # of existing matching reps + discoveries
  },
  "recommended_action": "deep_dive" | "defer" | "discard" | "needs_tool_first",
  "ts": "<ISO-8601>"
}
```

### D.1 `scout_outcome` semantics

- `pass` — Verifier returned `pass` on the single anchor instance; the seed-prompt LLM produced ≥ 1 candidate property; the conjecture survived the smallest case. Most informative; the natural input to a deep dive.
- `fail` — Verifier returned `fail` on the anchor; the conjecture is empirically false even at the smallest complexity. The deep dive is unlikely to recover this; mark `recommended_action: discard` unless the seed-prompt LLM identified a specific structural axis to refine.
- `inconclusive` — Verifier returned `mixed` or `error` (with successful retry); the seed prompt produced WH-1 but the LLM flagged uncertainty about predicates of `pass / fail`. Deep dive may help.
- `error` — Verifier crashed and could not be recovered; `recommended_action` is typically `needs_tool_first` (e.g. SurfaceGeo registers as `partial` in the inventory).

### D.2 `estimated_difficulty` heuristic

```
shallow      : pass + rep_tools_status == "available" + wh_anchor_size ≤ 5 +
               registry_hits ≥ 2
medium       : pass + rep_tools_status == "available" + (5 < wh_anchor_size ≤ 50)
deep         : pass + (rep_tools_status == "partial" OR wh_anchor_size > 50)
intractable  : (rep_tools_status == "missing")
              OR (verifier_runtime_s > T_BUDGET on the smallest case)
              OR (scout_outcome == "fail" AND no structural axis identified)
```

The thresholds are heuristic and tunable per domain.

### D.3 `recommended_action` mapping

| `scout_outcome` × `estimated_difficulty` | `recommended_action` |
|---|---|
| pass × shallow | `deep_dive` (high yield, low cost) |
| pass × medium | `deep_dive` (default) |
| pass × deep | `deep_dive` if registry_hits ≥ 1, else `defer` |
| pass × intractable | `needs_tool_first` |
| inconclusive × * | `defer` (operator decides whether to deep-dive after addressing the inconclusivity) |
| fail × * | `discard` unless seed prompt identified a refinement axis |
| error × * | `needs_tool_first` |

## E. Deep-dive escalation

When a scouted problem is escalated to deep dive, the deep-dive orchestrator inherits the scout's artefacts:

- `test_plan[1].actual_outcome` and `test_plan[1].actual_evidence` are **inherited verbatim** — the deep dive does NOT re-run step 1.
- `scout_wh` is inherited as the deep dive's `WH-1`. The deep dive's first stress-test prompt fires at step 2 (the next-smallest unvisited instance) against this inherited WH-1.
- The scout's `scout_rep_id` is inherited as `current_conjecture.rep_id`; the Rep Selector is NOT re-invoked unless the operator explicitly requests a re-probe.
- Per `instance_sorter.md §A` (plan immutability), inheritance is **append-only extension**, not re-ordering. The deep dive's step 1 == scout's step 1 (same row); steps 2..N are appended.

Net savings per escalated problem: one Verifier call + one seed-prompt LLM call.

If the operator requests a deep dive WITHOUT a prior scout, the flow is the existing v2 deep-dive flow with no inheritance.

## F. Skip list (what scout does NOT run)

Scout deliberately bypasses these stages:

| Stage | Why skip |
|---|---|
| **Stress-test prompt** (`explain_why_prompt.md §A.2`) | requires step 2; scout has only 1 step |
| **Tracker successor creation** (`hypothesis_tracker.md §B.3`) | no stress-test → no REFUTED_AT_EXPLANATION verdicts → no successors |
| **Rep Discoverer** (`SCHEMA.md §D`) | the Tracker never fires the "rep too restrictive" judge in scout mode |
| **Prover stage** (Lean pipeline: Architect/Decomposer/Aligner/Skeleton/Filler/Verifier/Linter) | the conjecture has not been empirically verified beyond a single case |
| **Tightness Pre-Audit** | requires Explorer frames; scout produces none |
| **Judge / Auditor / Fixer** | requires Prover output |
| **Retrospectives** (`representation_retrospective.md`, `discovery_retrospective.md`) | scout has no successful proof to mine |
| **Archive (closing summary path)** | `completion_status == pending` per §H below — `can_emit_summary` returns False |

The orchestrator's stage scheduler reads the `intent` flag and short-circuits these stages without dispatching.

## G. Batch mode

Scout Mode is designed to scale to *portfolios* of open problems. The orchestrator accepts a batch payload:

```jsonc
{
  "intent": "scout",
  "batch": [
    { "problem_id": "OP-3-spherogram", "goal": "...", "literature_in_scope": [...] },
    { "problem_id": "OP-2-v6-Cbeta",   "goal": "...", "literature_in_scope": [...] },
    { "problem_id": "OP-4-Layer4-#14", "goal": "...", "literature_in_scope": [...] }
  ],
  "max_parallel": 4,                    // worker concurrency
  "global_time_budget_s": 600           // total wall-clock cap for the batch
}
```

### G.1 Concurrency model

- **Per-problem isolation**: each scout runs in its own subprocess / worktree (no shared state with sibling scouts). The Verifier scripts often write to disk; the orchestrator uses a per-problem temp directory.
- **Shared registry reads**: the Rep Selector probe and seed-prompt LLM call read the *same* registry snapshot (`representations/entries.jsonl`, `discoveries/entries.jsonl`, `playbook/entries.jsonl`). No writes during a scout batch.
- **No write conflicts**: scout never writes to the registry; tractability_report files are written to disjoint paths under `workspace/active/scout_<batch_id>/`.

### G.2 Output

A batch emits one tractability_report per problem plus a ranking:

```jsonc
{
  "batch_id": "scout_<ts>",
  "reports": [ <tractability_report>, <tractability_report>, ... ],
  "ranking": [
    { "problem_id": "OP-3-spherogram", "rank": 1,
      "rationale": "shallow + 3 registry_hits + scout_outcome=pass" },
    ...
  ],
  "top_K_for_deep_dive": [ "OP-3-spherogram", "OP-2-v6-Cbeta" ],
  "ts": "<ISO-8601>"
}
```

Ranking key: `(scout_outcome == "pass", -estimated_difficulty rank, registry_hits desc, verifier_runtime_s asc)`.

### G.3 Top-K escalation

The operator (or an upstream agent) selects the top-K problems from the ranking and re-launches them with `intent=deep_dive`, inheriting the scout artefacts (§E).

## H. Completion-status interaction

Scout-mode runs MUST keep `current_conjecture.completion_status = "pending"` for their entire lifetime. Per `hypothesis_tracker.md §G.2`, the gate function explicitly short-circuits when `state.config.intent == "scout"`:

```python
if state.config.intent == "scout":
    c.completion_rationale = "scout mode — completion gated to deep_dive"
    return "pending"
```

Consequences:
- `can_emit_summary` returns False → Archive cannot emit a closing summary.
- The scout's exit artefact is the `tractability_report` (this spec §D), NOT a closing summary.
- The seed WH-1 stays `verdict: ACTIVE` (never `VERIFIED`); WH-level verdict transition at `hypothesis_tracker.md §B.2` has the matching scout guard.

This prevents a 1-step scout from masquerading as a finished proof.

## I. Validation rules

Before the orchestrator accepts a scout payload:

1. `intent == "scout"` is set explicitly (no implicit scout dispatch).
2. `max_parallel ≥ 1`; `global_time_budget_s > 0`.
3. Each batch entry has a unique `problem_id`.
4. The Proposer's emitted `test_plan` MUST have `len(test_plan) == 1` when `intent == "scout"`. A plan longer than 1 step is bounced back to the Proposer with the error string `"scout: test_plan length N > 1 (scout caps at 1 step)"`.
5. The Tracker's WH must have `id = "WH-1"` and no successors. A successor on WH-1 in scout mode is rejected with the error string `"scout: WH successor creation forbidden in scout mode"`.

These error strings are free-form by design — the orchestrator does not maintain an error-code registry, since scout has only two failure modes and they surface at distinct callsites. If a future module needs structured error codes (e.g. for batch-mode reporting in `§G.2`), introduce the registry then; do not preempt.

## J. Out of scope (future work)

- **Scout-mode adaptive deepening**: a scout that produces `inconclusive` could optionally extend its plan to 2 steps within the same scout invocation. Currently rejected by §I rule 4; would require a `scout_max_steps` parameter and an exit-budget check.
- **Cross-domain scout batches**: scouting a mix of `geometric_topology` and `optimization` problems in one batch. Already supported by §G.1 (per-problem isolation), but the ranking key in §G.2 mixes scalars across domains; a per-domain ranking option is open.
- **Scout-driven registry probing**: a scout could be used purely to *exercise* a candidate rep without committing to a problem (e.g. "scout this rep against 5 toy problems, see if it's worth promoting from `conjectural` to `validated_once`"). Currently scouts are problem-anchored; rep-probing scouts would reuse the same machinery with a different exit artefact.
