# Tool Discoverer — Specification

**Status**: design spec, no implementation yet (Phase-1).
**Position**: read-only ranking / synthesis-suggestion module on the failure path. Sibling of the Rep Discoverer (`lean/LeanAgent/registry/representations/SCHEMA.md` §D). Where Rep Discoverer answers "which form of the object should I be in?", Tool Discoverer answers "which transferable mid-level move should I try?" — keyed on the *obstruction* that blocked the previous attempt rather than on the goal pattern.
**Related docs**:
- `workspace/agents_spec/obstruction_catalog.md` — controlled vocabulary + obstruction → search-keyword catalog (the hand-curated dispatch table this module reads).
- `workspace/agents_spec/explain_why_prompt.md` §A.4 — emits the `obstacle` field that drives this module's input.
- `workspace/agents_spec/hypothesis_tracker.md` §A / §C.2 — owns the obstacle records and the Diagnoser ternary judge.
- `lean/LeanAgent/registry/discoveries/SCHEMA.md` §A `defuses_obstruction[]`, §C Mode 3, §E `T-DISC-SYNTH` — the registry-side coupling.
- `lean/LeanAgent/registry/representations/SCHEMA.md` §D — the symmetric Rep Discoverer interface.
- `workspace/reports/architecture/architecture_v2.md` Part IX — embeds this spec into the v2 flow.

---

## A. Position in the loop

Tool Discoverer is the **third** of the three failure-recovery dispatchers under the Diagnoser. Rep Discoverer answers "switch the noun"; Tool Discoverer answers "switch the verb." Both are read-only over their respective registries; both fall through to a retrospective-driven synthesis path when the registry has no match.

```
                 Verifier step
                       │
                       ▼
                 Explain-Why prompt
                       │  (verdict, obstacle on REFUTED_AT_EXPLANATION)
                       ▼
                  Hypothesis Tracker
                       │
                       ▼
                ┌──── failure ────┐
                ▼                 ▼
   tactic-shape failure       non-tactic-shape failure
        │                              │
        ▼                              ▼
   preflight linter           Diagnoser  ── ternary judge ──┐
                                                            │
            ┌───────────────────────────┬───────────────────┴───────────────────┐
            ▼                           ▼                                       ▼
   conjecture_refuted             rep_too_restrictive                  technique_insufficient
   (Tracker §B.4)                 (Tracker §C.1)                       (this module — §B trigger)
                                        │                                       │
                                        ▼                                       ▼
                              Rep Discoverer                            Tool Discoverer
                              (representations §D, READ)                (discoveries §C Mode 3, READ)
                                        │                                       │
                              empty top-K?                            empty match?
                                        │                                       │
                                        ▼                                       ▼
                              T-WH-FALSIFY                            T-DISC-SYNTH (Phase-2)
                              representation_retrospective §K          discovery_retrospective §… (Phase-2)
```

Both Discoverers may fire on the same failure; their outputs are merged by the Proposer into the next round's `tools_in_scope` and `current_conjecture.rep_id`.

---

## B. Trigger conditions

The Tool Discoverer fires when **at least one** of the following is true. The orchestrator passes the trigger code as part of the input payload (`§C.trigger_reason`).

### B.1 Primary — Diagnoser ternary judge

`Diagnoser.judge == "technique_insufficient"` per `hypothesis_tracker.md §C.2`. Concretely, all three must hold:

1. `actual_outcome != "fail"` on the failing step (the conjecture itself survives).
2. The `candidate_property` of the active WH either holds or is irrelevant — i.e. swapping property would not unblock the proof.
3. The failure mode is in *executing the proof step*: exhaustive enumeration blew up, certificate could not be found, the bound is loose, the inequality is in the wrong direction. The Diagnoser ternary judge attaches the `obstruction_class` from the explain-why output.

### B.2 Secondary — WH chain stagnation

`WH chain length ≥ 4` AND **the most recent two WHs share `rep_id_at_creation`**. Interpretation: the agent has tried two distinct candidate properties inside the same representation and both failed. The bottleneck is not the rep — switching property within the rep is exhausting variants, so the technique itself is the gap.

This is a heuristic refinement of the existing chain-length cap (`hypothesis_tracker.md §B.6` cap of 6); it fires earlier when the failure pattern is "thrashing within a rep" rather than "drifting across reps."

### B.3 Tertiary — operator override on inconclusive_open

When `current_conjecture.completion_status == "inconclusive_open"` and the operator wants a deeper rescue than Bridge's keyword search, the operator may invoke this module manually. The trigger payload sets `trigger_reason = "operator_override"` and the `obstruction_class` is supplied by the operator (validated against the controlled vocab).

### B.4 What is NOT a trigger

- Tactic-shape compile failures (no-goals, simp over-rewrite, …) — handled by the preflight linter, never reach this module.
- Tracker `verdict: FALSIFIED` (the conjecture itself failed) — handled by §B.4 of the tracker, no successor.
- Tracker `verdict: CONFIRMED` — there is no failure to recover from.
- Pure rep mismatches with a clean `rep_too_restrictive` judge — handled by Rep Discoverer alone.

---

## C. Input contract

```jsonc
{
  "query_kind"    : "tool_discoverer",                     // ★ required
  "trigger_reason": "ternary_judge"                         // ★ required
                  | "wh_chain_stagnation"
                  | "operator_override",
  "object"        : "<from state.current_conjecture>",      // ★ required
  "domain"        : "<from state.current_conjecture>",      // ★ required (one of representations/SCHEMA.md §A.1)
  "current_rep_id": "rep_NNN_...",                          // ★ required
  "current_technique": "<NL: 'iterative inclusion-exclusion with max-union enumeration'>", // ★ required
  "obstruction_class": "<one of obstruction_catalog.md §A>",// ★ required
  "mathematical_property_needed": "<NL one-liner>",         // ★ required
  "propagation_path": "<which step / WH / inequality blew up>", // ★ required
  "tried_discoveries": ["disc_NNN_...", ...],               // optional, default []
  "wh_at_trigger"   : "WH-N",                                // optional
  "evidence_pointer": "test_plan[step].actual_evidence"      // optional
}
```

The `obstruction_class` field must be one of the eight values in `obstruction_catalog.md §A`. If Explain-Why emits an unrecognised value, the Tracker validates and rejects the obstacle record before this module is invoked; the operator can then re-classify or extend the catalog.

---

## D. Query strategy

### D.1 Mode-3 query against `discoveries/`

```
1. Read lean/LeanAgent/registry/discoveries/entries.jsonl.
2. Filter:
     candidates = [d for d in entries
                    if obstruction_class in (d.defuses_obstruction or [])
                    and d.maturity in {"validated_once", "validated_multi", "promoted_to_playbook"}
                    and d.id not in tried_discoveries]
3. Rank by:
     primary   : maturity                   (validated_multi > validated_once > promoted_to_playbook)
     secondary : domain match               (== current domain > "meta" > other)
     tertiary  : category preference        (per obstruction_catalog.md §A "typical category")
     quaternary: fewer failure_modes        (well-charted preferred)
4. Cap at top K = 3.
```

`promoted_to_playbook` ranks below `validated_multi` for the same reason as `discoveries/SCHEMA.md §C` Mode-1: the playbook has the canonical implementation; the discovery entry survives for cross-domain transfer.

### D.2 Catalog fallback (synthesis suggestion)

When Mode-3 returns empty:

```
1. Read workspace/agents_spec/obstruction_catalog.md.
2. Look up the row matching obstruction_class.
3. Construct suggested_query:
     suggested_query = f"{mathematical_property_needed} -- "
                       f"keywords: {row.search_keywords}"
4. Mark every output candidate is_synthesis = true (no real discovery_id).
5. Set candidates = [] in the output (the synthesis path doesn't emit real candidates;
   it emits a search query for Phase-2 Bridge to execute).
```

### D.3 Prerequisites probe

For every Mode-3 candidate, the module performs a **lightweight** prerequisites probe (no LLM call, no Lean compile):

```
prerequisites_met = "true"  if every prerequisite with checkable=true is satisfied
                            against (current_rep_id, tools_required of current rep,
                            engine_inventory.json)
                  = "false" if any checkable prereq is NOT satisfied
                  = "unknown" if all prereqs have checkable=false (NL-only)
```

A heavier shape-fit / dimensional-analysis probe is **out of scope for Phase-1** and listed in §K.

---

## E. Output contract

```jsonc
{
  "candidates": [
    {
      "discovery_id"    : "disc_NNN_..." | null,
      "category"        : "proof_technique" | "definition_synthesis"
                        | "strategic_pattern" | "api_workaround"
                        | "extrapolation_method" | "rigor_pattern",
      "rationale"       : "<why this discovery defuses the obstruction_class>",
      "fit_score"       : 0.0 .. 1.0,
      "prerequisites_met": true | false | "unknown",
      "suggested_query" : "<lit-search keywords; populated when is_synthesis=true>",
      "is_synthesis"    : false | true,
      "back_references" : { "representations": [...], "discoveries": [...] }
    }
  ],
  "obstruction_summary": {
    "obstruction_class"           : "...",
    "mathematical_property_needed": "...",
    "catalog_keywords"            : ["...", "..."],
    "catalog_typical_category"    : "proof_technique"
  },
  "trigger_reason"   : "<echoed from input>",
  "registry_snapshot": "<sha or row count of discoveries/entries.jsonl at query time>",
  "ts"               : "<ISO-8601>"
}
```

`fit_score` is computed as `0.5 * obstruction_match + 0.3 * domain_match + 0.2 * maturity_match`, where each summand is 1.0 / 0.5 / 0.0. The 0.5 weight on obstruction_match makes it the dominant signal — this module exists *because* of obstruction-keyed dispatch.

---

## F. Feedback path

Three branches on the orchestrator side, indexed by `output.candidates` shape:

### F.1 Non-empty + `is_synthesis: false` (the success case)

```
Orchestrator → Proposer:
  next_round.tools_in_scope += [c.discovery_id for c in candidates]
  next_round.notes += "tool_discoverer: trying " + ",".join(...)
Proposer re-emits a test_plan that exercises one of the candidates.
Verifier runs; on outcome=succeeded, discovery_retrospective patches the
discovery's known_instantiations (existing D-CROSS-DOM if domain differs,
or pure instantiation patch otherwise — see discoveries/SCHEMA.md §E).
```

### F.2 Non-empty + `is_synthesis: true`

Phase-1 behaviour: mark the candidate as a **suggestion** in the closing summary's `open_items` list; do not re-launch the proof. The Bridge sub-call (`§H`) and the prospective seed-discovery write (`T-DISC-SYNTH`) are Phase-2 work.

```
Archive payload includes:
  open_items += [{
    "kind"           : "tool_discoverer_synthesis_pending",
    "obstruction"    : output.obstruction_summary,
    "suggested_query": candidates[0].suggested_query,
    "phase"          : "Phase-2"
  }]
```

### F.3 Empty candidates (no Mode-3 match, no catalog row)

This means `obstruction_class` is unrecognised — should be impossible after Tracker validation, but defensively the orchestrator emits a closing-summary `open_items` row of kind `"technique_gap_unresolved"` with the raw input echoed. The operator extends `obstruction_catalog.md` and re-runs.

```
open_items += [{
  "kind"  : "technique_gap_unresolved",
  "input" : <verbatim §C input>,
  "reason": "no Mode-3 match; obstruction_class not in catalog"
}]
```

---

## G. Relationship with Rep Discoverer

The two Discoverers are **strictly parallel**, not nested:

| Axis | Rep Discoverer | Tool Discoverer |
|---|---|---|
| Channel | `representations/` | `discoveries/` |
| Question | "switch the noun?" | "switch the verb?" |
| Read mode | filter by `(object, domain, failure_mode)` | filter by `obstruction_class` (M3) |
| Failure-record key | `failure_mode` (NL string) | `obstruction_class` (controlled vocab) |
| Synthesis path | `T-WH-FALSIFY` (`representation_retrospective.md §K`, Phase-1) | `T-DISC-SYNTH` (Phase-2) |
| Trigger predicate | "rep too restrictive" judge | "technique insufficient" judge |

Both may fire on a single failure when the failure has both a structural and a methodological cause. Example: a chordal-form proof of dismantlability that *also* relies on PEO enumeration that scales badly; the Diagnoser would trigger Rep Discoverer (chordal → W4) and Tool Discoverer (PEO enumeration → probabilistic upper bound on cycle count) in parallel. Their outputs are merged by the Proposer into a single next-round payload:

```
proposer_input = {
  "rep_candidates"     : <Rep Discoverer output>,
  "technique_candidates": <Tool Discoverer output>,
  ...
}
```

Conflict resolution is left to the Proposer — typically rep candidates dominate when both have high `fit_score`, since a rep switch usually moots the prior technique anyway.

---

## H. Relationship with Bridge

The `Bridge` module (`architecture_v2.md` L149) currently has a 1-line spec — "literature search in new rep's domain." Tool Discoverer's catalog-fallback path (§D.2) constructs a `suggested_query` that Bridge would consume in Phase-2:

```
Tool Discoverer (catalog miss)
   ↓
output.candidates = []
output.obstruction_summary.catalog_keywords = ["probabilistic method", ...]
   ↓
Phase-2: Bridge invoked with suggested_query
Bridge returns 0..N papers
   ↓
discovery_retrospective T-DISC-SYNTH writes a seed-maturity discovery with
back_references to the papers
```

Phase-1 stops at the first arrow; the rest is Phase-2 scaffolding declared here for symmetry only. The Bridge spec does not need to change in this PR.

---

## I. Worked example — Erdős-Selfridge (combinatorial blowup)

Erdős-Selfridge: prove that a covering system of arithmetic progressions on ℤ with distinct moduli must have a modulus with a small prime factor (or some equivalent obstruction). Iterative inclusion-exclusion needs `max_union_size(A_1, ..., A_k)` for unions of APs, which requires enumerating up to ∏ p_i / lcm(...) residue tuples; for k ≥ 4 distinct primes this is intractable.

### I.1 Trigger inputs

```jsonc
{
  "query_kind"    : "tool_discoverer",
  "trigger_reason": "ternary_judge",
  "object"        : "covering_system_of_AP",
  "domain"        : "combinatorial_topology",   // closest in current vocab; will likely add "combinatorics"
  "current_rep_id": "<rep tracking iterative I-E formulation>",
  "current_technique": "iterative inclusion-exclusion with max-union enumeration over residue tuples",
  "obstruction_class": "combinatorial_blowup",
  "mathematical_property_needed": "bound max-union of arithmetic progressions without enumerating all residue tuples",
  "propagation_path": "computing max_union(A_1,...,A_4) requires enumerating ∏p_i / lcm ≥ 10^4 tuples for the smallest 4-prime instance; Verifier times out at k=4",
  "tried_discoveries": []
}
```

### I.2 Mode-3 query

```
Filter: defuses_obstruction contains "combinatorial_blowup"
  → backfilled disc_003_universal_vertex_upgrade matches by classification
    BUT domain == geometric_topology, fit_score domain_match = 0.0
  → fit_score ≈ 0.5 (obstruction match) + 0.0 + 0.5 (validated_once) = 0.6
```

The cross-domain hit is suggestive but weak. In practice the Mode-3 ranker may surface it with `prerequisites_met: false` (the geometric prereqs do not apply). The catalog fallback fires.

### I.3 Catalog fallback

```
catalog_keywords = ["probabilistic method", "expectation bound", "LP relaxation", "generating function"]
suggested_query  = "bound max-union of arithmetic progressions without enumerating all residue tuples
                    -- keywords: probabilistic method, expectation bound, LP relaxation, generating function"
```

### I.4 Output

```jsonc
{
  "candidates": [
    {
      "discovery_id": "disc_003_universal_vertex_upgrade",
      "category"   : "strategic_pattern",
      "rationale"  : "matches combinatorial_blowup obstruction class but domain mismatch",
      "fit_score"  : 0.6,
      "prerequisites_met": false,
      "is_synthesis": false
    }
  ],
  "obstruction_summary": {
    "obstruction_class"           : "combinatorial_blowup",
    "mathematical_property_needed": "bound max-union of arithmetic progressions without enumerating all residue tuples",
    "catalog_keywords"            : ["probabilistic method", "expectation bound", "LP relaxation", "generating function"],
    "catalog_typical_category"    : "proof_technique"
  },
  "trigger_reason": "ternary_judge"
}
```

### I.5 Resolution under Phase-1

Per §F.2, the Phase-1 orchestrator does NOT auto-resolve. The closing summary's `open_items` carries the obstruction_summary forward:

```
open_items: [{
  kind: "tool_discoverer_synthesis_pending",
  obstruction: {obstruction_class: "combinatorial_blowup", ...},
  suggested_query: "...",
  phase: "Phase-2"
}]
```

This is the *honest* output: the obstacle is now structured, named, and queryable; the search is staged for Phase-2; the agent is unstuck only in the sense that it has a concrete hand-off rather than a vague "I am stuck." Phase-2 work (§K) closes the remaining gap.

---

## J. Worked example — OP-1 R4→R5/R6 (illustrating the rep/technique boundary)

OP-1 round 4: chordality fails on 12 specific S_{1,2} k=4 DLs (12/54 are non-chordal but still dismantlable). The narrative is: "chordal is too strong; need a weaker property that allows induced 4-cycles but still forces dismantlability."

### J.1 Why this is **rep_too_restrictive**, not **technique_insufficient**

- `actual_outcome` = pass (54/54 dismantlable).
- `candidate_property` = chordal — fails on 12/54.
- The proof method (Perfect Elimination Ordering) **would work fine** if chordal held. The blocker is that chordal does not hold; the right substitute is a weaker structural property that admits a different elimination scheme. That is a **noun substitution** (W4 condition replaces chordal-property), not a **verb substitution** (the elimination-style proof technique survives).

Diagnoser routes this to **Rep Discoverer** (returns rep_024_w4_metric_chepoi). Tool Discoverer is **not** invoked.

### J.2 Where Tool Discoverer would fire on a sibling failure

Hypothetical: imagine Round 4 had instead failed at S_{1,2} k=4 with this pattern: chordal *holds* on every DL, but PEO enumeration takes 2^|V| time per DL and 54 DLs at k=4 already exhausts the 24-hour Verifier budget. Then:

- `actual_outcome` = pass on every step that completes.
- `candidate_property` (chordal) **holds**.
- Failure is in *executing* PEO enumeration → `obstruction_class = combinatorial_blowup`.
- Diagnoser ternary judge: `technique_insufficient`.
- Tool Discoverer queries discoveries/ for `defuses_obstruction contains combinatorial_blowup` → in current registry, only disc_003 backfills this; cross-domain weak match. Catalog fallback returns `["probabilistic method", "LP relaxation", ...]` — analogous resolution to Erdős-Selfridge.

The boundary between Rep Discoverer's domain and Tool Discoverer's domain is therefore: **does swapping the candidate property unblock the proof?** If yes → rep switch. If no → technique switch.

---

## K. Phase-2 / Phase-3 roadmap

### K.1 Phase-2 — close the synthesis loop

| Item | Estimated effort | New code |
|---|---|---|
| Bridge sub-call: take `suggested_query` to a literature search (gh-pages of Math arXiv mirrors / OpenReview / Google Scholar API), return 0..N candidate papers | 1–2 weeks | ~150 LOC |
| `T-DISC-SYNTH` trigger in `discovery_retrospective`: when Tool Discoverer Mode-3 was empty AND Bridge returned ≥1 paper, emit a seed-maturity discovery whose `back_references.notes` cite the paper | 0.5–1 week | ~80 LOC |
| Applicability probe: a heavier prereq check that runs an LLM-side shape-fit (does the candidate technique's input shape match the current goal's shape?) | 1 week | ~120 LOC + prompt |

After Phase-2, the loop closes for Erdős-Selfridge: catalog → Bridge fetches a paper on the probabilistic method's bound for covering systems → seed discovery is written → next round attempts the technique under the seed-maturity gate.

### K.2 Phase-3 — agent-extensible obstruction taxonomy

The hand-curated `obstruction_catalog.md` is a hard limit on the agent's ability to discover *new categories of obstruction*. Phase-3 promotes the catalog to a registry channel:

| Item | Estimated effort |
|---|---|
| `lean/LeanAgent/registry/obstructions/` 8th channel; entries keyed by `obstruction_class` | 1 week schema + seed |
| Auto-extension: when Explain-Why emits an `obstruction_class` not in the catalog, a meta-Discoverer suggests a new class + draft search keywords; operator approves | 2–3 weeks |
| Cross-channel transitive ranking: an obstruction at the WH level may correspond to a known transport edge in `representations/` — both Discoverers contribute to a single fit score | 1–2 weeks |

Phase-3 is the point at which "the agent invents new tools" stops being a phrase and becomes operational: a fully closed loop where each new obstruction it encounters either matches an existing class (handled), extends the taxonomy under operator approval (catalog grows), or is rejected as too vague (the proof is escalated to the operator with an honest "I do not know how to classify this failure" record).

---

## L. Out of scope for this module

- **Inventing entirely new mathematics**. Tool Discoverer surfaces *transferable patterns* that have been seen before (in this codebase or in the literature). It does not generate proofs.
- **Cross-domain proof translation**. If a discovery's known instantiations are all in `optimization` and the current problem is in `combinatorial_topology`, the module reports the cross-domain hit with low `fit_score` but does not auto-translate. The Proposer / human decides.
- **Modifying existing discoveries**. Writes happen via `discovery_retrospective` only. Tool Discoverer is read-only against the channel (Mode-3 query) plus catalog-read-only against `obstruction_catalog.md`.
- **Prerequisite discharge via Lean**. The Phase-1 prereqs probe is structural only (does the rep / engine_inventory have the named tool?). Lean-side discharge of mathematical preconditions is Phase-2's applicability probe.

---

## H.2 Extended Bridge Triggers (added Gap-2)

Bridge has three trigger paths now, in priority order:

1. **Strategy Proposer `bridge_to_literature` (priority 1)**: when Strategy Proposer (`workspace/agents_spec/strategy_proposer.md` §E) emits a candidate with `type = "bridge_to_literature"`, that candidate's `search_queries` are passed verbatim to Bridge. This is the cleanest trigger path — the strategy step has already vetted the queries through the LLM's structured output.

2. **Diagnoser direct trigger (priority 2)**: when Diagnoser's binary judge emits `rep_too_restrictive` AND `falsification_evidence.structural_pattern` is non-empty, Bridge is invoked with a synthesised query of the form `"weaker than {current_property} but implies {target_property}"`. This is the OP-1 R5 → R6 path (chordal → (W4)+(M)) — Bridge fires *before* Strategy Proposer has run, so Strategy Proposer can include the Bridge result as a candidate.

3. **Tool Discoverer fallback (priority 3, original path)**: Mode-3 query empty → catalog_fallback → Bridge with `obstruction_summary`. Unchanged from original.

The orchestrator picks the highest-priority trigger present and routes a single Bridge call. If multiple triggers fire in the same Diagnoser-cycle, only one Bridge invocation runs.

`BridgeTrigger` shape:
```jsonc
{
  "source"  : "tool_discoverer" | "strategy_proposer" | "diagnoser",
  "query"   : "<NL search query OR null when source=tool_discoverer (uses obstruction_summary instead)>",
  "queries" : ["<list>"] | null,                  // populated when source=strategy_proposer
  "obstruction_summary": { ... } | null,           // populated when source=tool_discoverer
  "pattern" : "<verbatim structural pattern from falsification evidence>" | null,
  "priority": 1 | 2 | 3
}
```

Implementation: `lean/LeanAgent/LeanAgent/Agent/Scout/diagnoser.py` adds `extract_bridge_trigger()`. The Bridge module gains a new entry point `run_bridge_with_triggers()` that takes any subset of (`obstruction_summary`, `strategy_queries`, `diagnoser_trigger`) and routes to the existing `run_bridge()` after picking by priority.
