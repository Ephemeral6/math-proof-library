# Representation Retrospective — Module Specification

**Module name**: `representation_retrospective`
**Position in pipeline**: post-Auditor, pre-Archive. Sibling of `discovery_retrospective`.
**Schema this module writes to**: `lean/LeanAgent/registry/representations/SCHEMA.md`.
**Prompt template**: `workspace/agents_spec/representation_retrospective_prompt.md`.

This module extracts *route-choice records* from a successful proof run and writes them as entries in `registry/representations/`. It is the channel-write end of the route-choice loop; the channel-read end (Architect proactive probe / Diagnoser stuck-query) lives in `representations/SCHEMA.md` §C and §D.

## A. Position in the loop

```
... → Verifier → Diagnoser → Fixer → Auditor (verdict CERTIFIED) →
   ┌──────────────────────────────────────────────────────┐
   │  retrospective fan-out (parallel, isolated contexts) │
   │                                                      │
   │  representation_retrospective    ← THIS MODULE        │
   │     writes to registry/representations/              │
   │                                                      │
   │  discovery_retrospective                              │
   │     writes to registry/discoveries/                  │
   └──────────────────────────────────────────────────────┘
                         │
                         ▼
                      Archive
```

The two retrospectives run in parallel because they read the same input contract and emit to disjoint registries. They are not allowed to modify each other's outputs; cross-references are recorded by ID only.

## B. Input contract

The orchestrator hands the retrospective a single JSON payload — **identical** to the payload `discovery_retrospective` receives:

```jsonc
{
  "run_id"      : "<workspace/active/proof_work_YYYYMMDD_HHMMSS>",
  "problem"     : { "name": "...", "source": "OP-1 r7" | ..., "domain": "..." },

  // Architect / Decomposer / Verifier trace
  "blueprint"   : { "rep_chosen": "rep_NNN_...", "atoms": [...], ... },
  "atom_list"   : [ { "id": ..., "nl": ..., "lemma_name": ... }, ... ],
  "compile_fix_log": [ { "atom_id": ..., "tactic": ..., "transport_lemma": ..., "outcome": ... }, ... ],

  // Pre-Audit / Audit
  "tightness_report": { "verdict": "PROCEED" | ..., "warnings": [...] },
  "auditor_verdict" : { "status": "CERTIFIED", "axioms": [...], "annotations": [...] },

  // Discovery-mode runs only
  "state": {
    "current_conjecture" : "...",
    "failed_attempts"    : [ { "rep_id": ..., "rejected_at": ..., "reason": ... } ],
    "diagnoses"          : [...],
    "why_hypotheses"     : [...],
    "tracker_log"        : [...]
  },

  // Verifier evidence
  "verifier_evidence": {
    "lemmas_closed"      : [ "<full Lean lemma name>", ... ],
    "numerical_certs"    : [ { "kind": "QQ_PSD", "hash": "...", "rep_id": ... }, ... ],
    "actual_evidence"    : [ <opaque JSON from explain_why_prompt §A.0> ]
  },

  // Existing registry snapshot (for dedup)
  "existing_representations": [ <entries.jsonl content> ],
  "existing_lemmas"  : [ ... ],
  "existing_pairs"   : [ ... ],
  "existing_playbook": [ ... ]
}
```

The `existing_*` fields are passed by reference (filesystem path) when over a few KB; the module reads them as needed.

## C. Trigger detection

The module scans the input against the 7 triggers from `representations/SCHEMA.md §E.2`. Each trigger has a *pattern detector* (deterministic, runs first) and a *gate* (LLM-driven, runs second).

### C.1 Pattern detector rules

The detectors key off **`transport_to`-graph events** in the trace, not playbook overlap (which is `discovery_retrospective`'s job).

| Trigger | Detector predicate (deterministic) |
|---|---|
| **T-LEMMA** | `compile_fix_log[*].transport_lemma` invokes any of: `toDual`, `polarisation`, `Riesz`, `match_scalars`, `field_simp`-bridge, an explicit `noncomputable def aux_seq`, or any `rfl`-bridge between two `def`s in the atom list. The lemma either exists in `existing_lemmas` (→ candidate is a new transport edge between two existing reps) or does not (→ candidate is a new (rep, rep, transport_lemma) tuple). |
| **T-AUX-SEQ** | `compile_fix_log` shows ≥ 1 `noncomputable def` declared at top level (per the Decomposer's G-NEW pattern), AND that def is referenced by ≥ 2 distinct `lemma_name`s. Generates a new rep entry of the "trajectory + auxiliary sequence" family with `formal_form` capturing the `def` signature. |
| **T-MULTI-FILE** | `blueprint.atoms` are split across ≥ 2 Lean files (Architect chose multi-file decomposition over inline, per G5). Generates a transport edge "in-file inlining ↔ multi-file `import`" with `cost: moderate, loss: lossless`. |
| **T-CONJ-REFINE** | `state.failed_attempts` grew by ≥ 1 row this run AND `state.current_conjecture` has a `formal_form` whose top-level predicate name differs from any prior round's. Generates a candidate rep for the new form, `discovered_via = "counterexample_analysis"`, with a transport edge from the falsified rep annotated as the structural barrier. |
| **T-LIT-JUMP** | `state.literature_in_scope` gained an entry this round that was not in the previous round's State, AND that entry's keywords appear in `auditor_verdict.annotations` or in `compile_fix_log[*].transport_lemma`. Generates a candidate rep with `discovered_via = "literature"`. |
| **T-TOOL-SWITCH** | The numerical pipeline switched stacks mid-run (CLARABEL → SymPy QQ; curver → networkx; cvxpy → custom CG-method) as evidenced by ≥ 2 distinct stack identifiers in `verifier_evidence`. Generates a new transport edge between two existing reps, possibly across domains. |
| **T-WH-FALSIFY** | A `tracker_log` event has `event ∋ "WH-N falsified at explanation level"` AND the Tracker's "rep too restrictive" judge fired (cf. `hypothesis_tracker.md §C.1`) AND no existing rep entry matches the failure mode. **This is the Discoverer write path** — see §K. Generates a new rep with `discovered_via = "counterexample_analysis"`, `status = "conjectural"`, and a transport edge from `current_rep_id` annotated with the structural barrier as `loss`. |

### C.2 Gate questions (LLM-driven)

For each detected pattern, the LLM is asked the three gate questions from `representation_retrospective_prompt.md §D`:

(a) Is this rep already in the cited literature *and* already expressible via an existing rep entry's `formal_form` (modulo trivial paraphrase)? (If yes — skip.)
(b) Is this rep an exact `(object, representation)` duplicate of an existing entry? (If yes — emit a patch, not an insert.)
(c) Are the rep's `tools_required` either available or explicitly recorded as `partial`/`missing`? (If `tools_required` cannot be enumerated — reject as too vague.)

A pattern that passes all three becomes a *candidate entry*.

## D. Output contract

```jsonc
{
  "run_id"     : "...",
  "module"     : "representation_retrospective",
  "candidates" : [ <entry>, <entry>, ... ],   // 0..5 entries
  "patches"    : [ <patch>, <patch>, ... ],   // 0..N patch lines
  "skipped"    : [
    { "trigger": "T-LEMMA", "reason": "literature-known: Riesz representation in Mathlib" }
  ],
  "summary"    : "<one paragraph: which triggers fired, what was kept>"
}
```

Each `candidate` is a representation entry conforming to `representations/SCHEMA.md §A`. The signature output is:

```jsonc
{
  "id"           : "rep_<NNN>_<slug>",
  "object"       : "...",
  "domain"       : "...",
  "representation": "<short name + 1-line description>",
  "formal_form"  : "<Lean 4 type/signature OR NL>",       // primary signature
  "tools_required": [...],
  "tools_status" : "...",
  "transport_to" : [                                       // primary structural output
    {
      "target_rep_id"  : "rep_<NNN>_<...>",
      "transport_method": "...",
      "transport_lemma": "<Lean lemma name OR null>",
      "cost"           : "cheap" | "moderate" | "expensive",
      "bidirectional"  : true | false,
      "loss"           : "lossless" | "lossy_<...>"
    }
  ],
  "verification_qualifier": "EXACT" | "EXHAUSTIVE_ON_SAMPLE" | "NUMERICAL" | "INCOMPLETE",
  "verification_evidence" : "...",
  "source_problem" : "{{problem.source}}",
  "discovered_via" : "...",
  "status"         : "validated" | "conjectural",
  "implies_reps"   : [...],                                // see strict_stronger.py / SCHEMA §A
  "supersedes"     : [],
  "superseded_by"  : null,
  "notes"          : "...",
  "ts"             : "{{now_iso}}"
}
```

The orchestrator validates the output against `representations/SCHEMA.md §E.6` rules, then appends to `entries.jsonl`. Validation failure on a specific candidate drops that candidate; the rest proceed.

### D.1 Qualifier extraction from Auditor verdict

The retrospective infers `verification_qualifier` deterministically from the run trace:

| Auditor / Verifier signal | Qualifier emitted |
|---|---|
| Lean theorem closes axiom-clean (`#print axioms` whitelist passes) | `EXACT` |
| `verifier_evidence.numerical_certs` contains a `QQ_PSD` cert that SymPy validated in QQ | `EXACT` |
| Verifier ran on every element of an explicit finite set with `pass_rate = 1.0` | `EXHAUSTIVE_ON_SAMPLE` |
| Verifier returns `optimal` from CLARABEL / SCS / floating-point solver, no exact lift | `NUMERICAL` |
| Verifier returns partial / sample-based / heuristic verdict | `INCOMPLETE` |

If multiple signals fire, the **strictest qualifier wins** (EXACT > EXHAUSTIVE_ON_SAMPLE > NUMERICAL > INCOMPLETE).

## E. Selection rules

After the gate questions, multiple candidates may remain. Selection is governed by `representations/SCHEMA.md §E.4`:

1. **Hard cap**: at most 5 new entries per run. If more, top-5 by `representations/SCHEMA.md §E.4` priority: `T-CONJ-REFINE > T-WH-FALSIFY > T-AUX-SEQ > T-LIT-JUMP > T-LEMMA > T-MULTI-FILE > T-TOOL-SWITCH`.
2. **Dedup**: `(object, representation)` near-match (edit-distance ≤ 3 on `representation`, exact-match on `object`) → patch, not insert.
3. **Anti-spam (transport edges)**: ≥ 3 candidates targeting the same `target_rep_id` with the same `transport_method` family → fold all but the cheapest into that one's `notes`. (Different from `discovery_retrospective`'s api_workaround anti-spam, which keys on category.)
4. **Maturity gate**: a new entry with `status = "validated"` requires the run's qualifier to be `EXACT` OR `EXHAUSTIVE_ON_SAMPLE`; lower qualifiers downgrade `status` to `conjectural` automatically.

Patches (D.5 / `SCHEMA.md §E.3`) are not subject to the 5-entry cap; they are bookkeeping.

## F. Relationship to discovery_retrospective

`representation_retrospective` and `discovery_retrospective` (`workspace/agents_spec/discovery_retrospective.md`) are siblings:

| | representation_retrospective | discovery_retrospective |
|---|---|---|
| **Question answered** | What ROUTE choices did this run validate or invent? | What MID-LEVEL MOVES did this run expose for reuse? |
| **Channel** | `registry/representations/` | `registry/discoveries/` |
| **Granularity** | one `(object, form)` pair + transport | one transferable move/idea |
| **Triggers** | T-LEMMA, T-AUX-SEQ, T-MULTI-FILE, T-CONJ-REFINE, T-LIT-JUMP, T-TOOL-SWITCH, T-WH-FALSIFY (7) | D-NEW-MOVE, D-AUX-DEF, D-API-BYPASS, D-EXTRAPOLATE, D-DICHOTOMY, D-AUGMENT, D-RIGOR-LIFT, D-CROSS-DOM, D-ANTI-PROVE, D-PROMOTE (10) |
| **Cap per run** | 5 | 5 |

They share the input contract (same JSON payload, §B above and `discovery_retrospective.md §B`). They MUST NOT modify each other's output. The orchestrator concatenates results, runs validators in parallel, and applies all writes in a single transaction.

### F.1 Cross-references between channels

When a `representation_retrospective` candidate references a discovery the sibling is about to write in the same run:

- The candidate's `notes` field may contain `back_references_to_discoveries: ["disc_NNN_..."]` (informational; not a schema-required field).
- Validation checks both the existing registry AND the in-flight write batch from `discovery_retrospective`. (Same convention as `representations/SCHEMA.md §E.6` rule 2 and `discovery_retrospective.md §F.1`.)

If both retrospectives independently want to record the *same* underlying event (e.g. an aux-sequence: `representation_retrospective` records `rep_010_zseq_lyapunov`-style entry; `discovery_retrospective` records `disc_006_aux_sequence_synthesis`-style entry), this is correct and not double-counted: the rep is the *form* of the object, the discovery is the *move* that introduces it. Both stay live.

## G. Error handling

- **LLM produces malformed JSON**: re-run once with explicit JSON repair instruction; if still malformed, drop all candidates from this run and log to `workspace/active/.../representation_retrospective_errors.log`.
- **Candidate violates `SCHEMA.md §E.6` rules**: drop that candidate; keep others; record in `skipped`.
- **Candidate would create supersede cycle**: drop; record in `skipped`.
- **Module exceeds time budget** (default 60s): emit any candidates produced so far; mark module as `partial`.
- **`transport_lemma` references a non-existent lemma in `registry/lemmas/`**: candidate is allowed only if `status = "conjectural"` AND `notes` explains the dangling reference (per `SCHEMA.md §E.6` rule 4).

## H. Logging

Every run emits a structured log to `workspace/active/<run_id>/representation_retrospective.log`:

```jsonc
{ "ts": "...", "run_id": "...",
  "triggers_fired": ["T-CONJ-REFINE", "T-WH-FALSIFY", "T-LEMMA"],
  "gates_failed":  [{"trigger": "T-LIT-JUMP", "reason": "lit-known + already in registry"}],
  "entries_written": 2,
  "patches_applied": 1,
  "qualifier_extracted": "EXACT",
  "duration_ms": 1450 }
```

Aggregated logs feed the framework's own self-evaluation: which triggers actually find new content vs. produce noise. The `T-MULTI-FILE` trigger is a candidate for retirement if its hit rate stays below 5% over the first 50 runs.

## I. Bootstrapping

The seed entries in `entries.jsonl` (35 entries as of 2026-04-30) were hand-curated from the Lean benchmark, OP-1, OP-2, Theorem 3, OptLib2 sources, with `discovered_via = "human"`. The retrospective module did NOT generate them; it inherits them as the initial state of the channel. Subsequent runs of `representation_retrospective` will use `discovered_via` derived from the trigger that fired (`counterexample_analysis` for T-CONJ-REFINE / T-WH-FALSIFY; `literature` for T-LIT-JUMP; `tool_routing` for T-LEMMA / T-AUX-SEQ / T-MULTI-FILE / T-TOOL-SWITCH).

## J. Failure-mode of the module itself

The retrospective is allowed to *miss* rep entries (false negatives are cheap: the human or the next run will catch them). It is NOT allowed to *invent* rep entries that are not warranted by the trace (false positives pollute the registry). The gate questions in §C.2 are the primary guard; the validation in `SCHEMA.md §E.6` is the secondary guard.

A self-evaluation criterion: if the validator rejects > 30% of candidates over a sliding window of 20 runs, the prompt template in `representation_retrospective_prompt.md` is re-tuned. (This is operator-driven, not self-modifying.)

## K. Rep Discoverer write path (T-WH-FALSIFY)

The Discoverer (Diagnoser query interface, `representations/SCHEMA.md §D`) is **read-only**: it ranks existing rep entries against a failure mode and returns the top K. It does not create new entries.

When the top-K is empty (or every candidate is gated out by `tools_status: missing` / disproved-overlap / poor rationale match), the Tracker's "rep too restrictive" verdict cannot be answered by the existing registry. **`representation_retrospective` is the module that closes this gap.** The T-WH-FALSIFY trigger fires precisely in this case; this module synthesises a new rep entry with:

- `id`: next free `rep_<NNN>_<slug>` derived from the failure mode (e.g. `rep_036_w4_inferred_from_op1_round_5`).
- `object`: copied from the falsifying conjecture's object.
- `domain`: copied from the active conjecture's domain.
- `representation`: short label proposed by the LLM, anchored on the failure-mode pattern (e.g. "wheel-W4 metric form, 4-cycles always filled").
- `formal_form`: NL initially (Lean signature is null) — the formalisation lift happens in a later round.
- `tools_required`: enumerated from the failure-mode evidence (e.g. `["networkx.cycle_basis", "SurfaceGeo.cut_glue"]`).
- `tools_status`: `available` if all enumerated tools are in `engine_inventory.json`; `partial` otherwise.
- `transport_to`: at least one edge from `state.current_conjecture.rep_id` (the falsified rep), `transport_method` describing the structural barrier, `loss = "lossy_<barrier>"`, `transport_lemma = null`.
- `verification_qualifier`: `INCOMPLETE` (only candidate evidence at this point; the conjecture has not been re-verified in this rep yet).
- `discovered_via`: `"counterexample_analysis"`.
- `status`: `"conjectural"`.
- `implies_reps`: empty (the new rep's logical relations are unknown until the next round verifies it).
- `notes`: must include the WH-id at falsification, the structural pattern (e.g. "induced 4-cycle, degree (6,5,5,5)"), and a one-line rationale matching `SCHEMA.md §D.4`.

The synthesised entry is emitted as a normal candidate (subject to the same 5-cap and `SCHEMA.md §E.6` validation). On the *next* round, when the new rep is actually exercised by the Verifier, the Tracker's CONFIRMED verdict eventually upgrades `status: conjectural → validated` and `qualifier` from INCOMPLETE upward — done via the patch mechanism in `SCHEMA.md §E.3`, not a new insert.

This is the **single locus** for new-rep creation. The Discoverer never writes; the Tracker never writes; only this module writes. That removes the "who creates the rep" ambiguity flagged by the architecture audit.

### K.1 Race with concurrent `discovery_retrospective`

Both retrospectives run in parallel. If `discovery_retrospective` emits a `disc_NNN_...` whose `back_references.representations` points at the in-flight rep being synthesised here, the orchestrator's transaction layer (`SCHEMA.md §E.6` rule 2) accepts the cross-reference because both writes are in the same batch. Validators run after the merge.

## L. Future work

1. **Multi-step Discoverer chain**: when T-WH-FALSIFY fires repeatedly across rounds (e.g. OP-1's universal-vertex → chordal → (W4) chain), the synthesised reps form a chain of `transport_to` edges. A future enhancement: emit a `chain_id` on each entry so retrospectives can detect "this rep is the 3rd in a structural-barrier walk" and downgrade `maturity` accordingly.
2. **`representation_retrospective` auto-promote**: when a `conjectural` rep is exercised in 3 distinct source problems with `pass_rate = 1.0`, auto-emit a patch promoting `status → validated`. Currently operator-driven.
3. **Cross-channel deduplication**: if the same physical event triggers BOTH a discovery (verb) AND a representation (noun), the two entries should cross-reference each other. The schema already supports this; the prompt should be tightened to emit both reciprocal references in the same run.
