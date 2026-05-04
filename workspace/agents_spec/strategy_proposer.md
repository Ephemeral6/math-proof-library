# Strategy Proposer — Specification

**Status**: design spec + Python implementation (Phase-1).
**Position**: between Diagnoser and the next-round Proposer. Fires when the Diagnoser's ternary judge emits any non-`NO_DISCOVERER` decision (REP_ONLY / BOTH / TOOL_ONLY / SUCCESSOR_WH_ONLY). Generates ranked candidate *directions* the next conjecture should take, probes each one cheaply via Scout Mode, and returns the top-1 recommendation.
**Related docs**:
- `workspace/agents_spec/scout_mode.md` — Scout's `scout_one()` is reused as the per-candidate probe.
- `workspace/agents_spec/hypothesis_tracker.md` §C.2 — the upstream ternary judge whose decision triggers this module.
- `workspace/agents_spec/tool_discoverer.md` — sibling: Tool Discoverer answers "which transferable move?"; Strategy Proposer answers "which direction should the next conjecture take?".
- `workspace/reports/architecture/architecture_v2.md` Part X — embeds this spec into the loop.

---

## A. Position in the loop

Strategy Proposer sits **after** Diagnoser fires and **before** the orchestrator hands control to the next round's Proposer. It is the layer that converts a structural failure verdict into one or more *candidate directions* — formed independently of any single Discoverer's output — and ranks them.

```
       ┌── Verifier returns failure
       ▼
   Tracker — explain-why → ternary judge (Diagnoser)
       │
       ▼
   Diagnoser dispatch ∈ {REP_ONLY, BOTH, TOOL_ONLY, SUCCESSOR_WH_ONLY, NO_DISCOVERER}
       │
       ▼
   ┌────────────────────────────────────────────────┐
   │ STRATEGY PROPOSER (this spec)                   │
   │   1. generate_candidates  (1 LLM call)         │
   │   2. probe_candidates     (N × scout_one)      │
   │   3. rank_candidates                            │
   │   4. recommend top-1                            │
   └────────────────────────────────────────────────┘
       │
       ▼
   Next Proposer round (uses recommended strategy)
```

It does **not** replace Rep Discoverer or Tool Discoverer; it composes alongside them. The Proposer for the next round may consult both Discoverer outputs **and** the Strategy Proposer recommendation; conflict-resolution is left to the orchestrator (typically: take the strategy's `recommended_id`, treat Discoverer hits as supporting evidence in the strategy's `rationale`).

---

## B. Trigger conditions

Strategy Proposer fires when:

1. **Primary**: `diagnoser_output.dispatch ∈ {REP_ONLY, BOTH, TOOL_ONLY, SUCCESSOR_WH_ONLY}`. `NO_DISCOVERER` (conjecture is wrong) does not fire Strategy Proposer — there is no surviving conjecture for which to choose a direction.

2. **Secondary**: WH chain stagnation flagged by `hypothesis_tracker.detect_chain_stagnation()` AND chain length ≥ 4. This corresponds to thrashing — multiple WH attempts inside the same rep have failed; Strategy Proposer is asked to break out of the rep.

3. **Tertiary (operator)**: a manual override flag may invoke this module on demand even without a fresh Diagnoser verdict. Used during retroactive validation runs (e.g. the OP-1 §H replay below).

---

## C. Input contract

```jsonc
{
  "current_conjecture"     : { "id": "...", "form": "...", "rep_id": "rep_NNN" },
  "falsification_evidence" : {
    "n_failing"           : 12,
    "n_total"             : 54,
    "structural_pattern"  : "induced 4-cycle, degree (6,5,5,5)",
    "axis_uniformity"     : true,                                 // from Diagnoser
    "anchor_instances"    : [{ "instance": "S_{1,2} k=4", ... }]
  },
  "diagnoser_output"       : {
    "binary"   : "rep_too_restrictive",                            // see diagnoser.py BinaryJudge
    "dispatch" : "REP_ONLY",                                        // diagnoser.py DispatchDecision
    "obstacle" : { "obstruction_class": "...", ... } | null
  },
  "failed_attempts"        : [
    { "form": "DL has universal vertex", ... },
    { "form": "DL is chordal",            ... }
  ],
  "registry_context"       : {
    "representations_path" : "lean/LeanAgent/registry/representations/entries.jsonl",
    "discoveries_path"     : "lean/LeanAgent/registry/discoveries/entries.jsonl"
  },
  "scout_config"           : { "stub_mode": false, "timeout_s": 60.0, ... }
}
```

---

## D. Output contract

```jsonc
{
  "candidates": [
    {
      "id"                       : "S1",
      "description"              : "weaken chordal to (W4)+(M) systolic condition",
      "type"                     : "weaken_property",
      "rationale"                : "12 counterexamples all have short induced cycles with fillers",
      "estimated_tractability"   : 0.70,                            // 0..1, prior estimate
      "requires_literature_search": true,
      "search_queries"           : ["weakly systolic contractible", "W4 condition graph"],
      "probe_result"             : { ... TractabilityReport ... } | null
    }
  ],
  "recommended_id"          : "S1",
  "recommendation_rationale": "(W4)+(M) probe → pass + shallow + 2 registry hits"
}
```

---

## E. Candidate generation strategies — five `type` values

A single LLM call (stage `strategy_proposer`, task `generate`) emits 3–5 candidates spanning these five types. The LLM must emit at least one and at most three of any single type; total cap is 5.

| `type` | Meaning | OP-1 example |
|---|---|---|
| `weaken_property` | Drop or relax one condition of the current property to admit the failing instances. | "drop chordal; require only (W4) on induced 4-cycles" |
| `split_cases` | Partition the instance space into two structurally distinct subsets and propose separate sub-conjectures. | "DL is either chordal or a cone" (the dichotomy) |
| `change_representation` | Move to another rep in `representations/` registry whose `transport_to` reaches the current one. | "switch from rep_022_chordal_peo to rep_023_iterative_max_level" |
| `generalize_from_evidence` | Mine the falsification evidence for a structural pattern; propose a new property anchored on that pattern. | "all 12 CEs have a degree-6 vertex; conjecture: such a vertex is a cone apex" |
| `bridge_to_literature` | The current direction lacks vocabulary; populate `search_queries` so Bridge can fetch related work. | search "weakly modular graph dismantlable Chepoi" |

The five-type taxonomy is not exhaustive but covers the OP-1 trace and Theorem-3 trace; new types may be added by amending this section and updating the LLM prompt.

---

## F. Ranking

After candidates are emitted, each one is **probed** via `scout_one()` (see `scout_mode.md §C`). Probe configuration:

- `intent="scout"` (1-step verifier dispatch only).
- The probe's `goal` is the candidate's `description`.
- The probe's `domain` is inherited from `current_conjecture`.
- The probe's `verifier_command` is auto-generated for `weaken_property` / `split_cases` (engine_call into the existing verifier suite when available); for `bridge_to_literature` the probe is skipped and `probe_result = null` (Bridge runs first).

After probing:

```
rank_key = (
  probe_result is not None and probe_result.scout_outcome == "pass",   # primary
  -difficulty_rank(probe_result.estimated_difficulty),                 # secondary
  estimated_tractability,                                              # tertiary
  -is_dup_of_failed_attempts(candidate, failed_attempts)               # quaternary
)
top_1 = max(candidates, key=rank_key)
```

Ranking key matches Scout Mode's batch ranking semantics (§G.2 in scout_mode.md) and adds a deduplication penalty against `failed_attempts` to avoid recycling defunct directions.

### F.1 Failed-attempt deduplication

A candidate is considered a duplicate when any of:
- Its `description` shares ≥ 80% token overlap with a failed attempt's `form` (case-insensitive Jaccard).
- Its `type == "weaken_property"` and the property name appears verbatim in `failed_attempts`.
- Its `search_queries` are subset of a previously-failed `search_queries` recorded in `discovery_retrospective` outputs (when available).

Duplicates are not removed; they are demoted in the ranking. Rationale: even a duplicate may now succeed under different evidence; we want the operator to see and override.

---

## G. Relationship with Scout Mode

Strategy Proposer **internally invokes** `scout_one()`. The two modules differ in *intent*:

| | Scout Mode | Strategy Proposer |
|---|---|---|
| Question answered | "Is this *problem* worth a deep dive?" | "Which *direction* should the next conjecture take?" |
| Anchor | A whole open problem | A single failing conjecture inside a deep dive |
| Output | `TractabilityReport` per problem | `StrategyProposal` with ranked candidates |
| Number of probes | 1 problem → 1 scout | 1 candidate-set → 3..5 scouts |

A natural composition: a Scout-mode batch over a problem corpus surfaces `recommended_action: deep_dive` candidates; the deep dive that follows uses Strategy Proposer to navigate Diagnoser failures.

---

## H. OP-1 retroactive validation

Replaying the seven OP-1 rounds against this spec:

| OP-1 round | Diagnoser verdict | Strategy Proposer would emit | OP-1 actual move |
|---|---|---|---|
| R1 → R3 | rep_too_restrictive (universal vertex CE: 6 K_4-core) | `weaken_property` (drop universal_vertex), `bridge_to_literature` ("dismantlable graph") | dismantlable rep selected |
| R3 → R4 | (no failure — chordal probe) | n/a — Strategy Proposer not triggered | chordal proposed |
| R4 → R5 | rep_too_restrictive (12 non-chordal CEs) | `weaken_property` (drop chordality, keep dismantlability), `bridge_to_literature` ("(W4) wheel condition"), `split_cases` (chordal-or-cone) | (W4)+(M) tried |
| R5 → R6 | rep_too_restrictive ((W4)+(M) too restrictive on S_{2,1}) | `change_representation` (rep_023_iterative_max_level), `split_cases` (chordal-or-cone dichotomy) | chordal-or-cone dichotomy |
| R6 → R7 | (no failure — dichotomy works) | n/a | iteration ends |

Three of the four direction switches in OP-1 would have been produced by Strategy Proposer in stub mode given the same evidence. The R5 → R6 switch (rep change) is the only one currently outside the stub fixture; it is reachable in non-stub mode if `change_representation` candidates are generated.

---

## I. Python implementation footprint

Pure stub-friendly module; no Lean compilation in the hot path.

| Piece | Type | Est. LOC |
|---|---|---|
| `StrategyCandidate` + `StrategyProposal` dataclasses | Python | 40 |
| `generate_candidates` (1 LLM call + parse) | Python | 60 |
| `probe_candidates` (N × scout_one) | Python | 30 |
| `rank_candidates` (sort + dedup) | Python | 40 |
| `run_strategy_proposer` orchestration | Python | 30 |
| **Total** | | **~200** |

---

## J. Out of scope

- **Cross-conjecture strategy** — a strategy that addresses two failing conjectures jointly (e.g. unify two falsifications under one weaker rep). Currently each StrategyProposer call is scoped to one conjecture.
- **Auto-applied strategy** — the orchestrator may auto-apply the top-1 recommendation, but the operator can always intervene. There is no "decide and bind" mode that locks a strategy without human review.
- **Probe budget allocation** — every candidate gets a single `scout_one` probe. Adaptive budgets (more probes for ambiguous candidates) are Phase-2.
