# Discovery Retrospective — Module Specification

**Module name**: `discovery_retrospective`
**Position in pipeline**: post-Auditor, pre-Archive. Sibling of `representation_retrospective`.
**Schema this module writes to**: `lean/LeanAgent/registry/discoveries/SCHEMA.md`.
**Prompt template**: `workspace/agents_spec/discovery_retrospective_prompt.md`.

This module extracts *transferable mid-level moves* from a successful proof run and writes them as entries in `registry/discoveries/`. It is the channel-write end of the discovery loop; the channel-read end (Mode 1 / Mode 2 queries) lives in `discoveries/SCHEMA.md` §C.

## A. Position in the loop

```
... → Verifier → Diagnoser → Fixer → Auditor (verdict CERTIFIED) →
   ┌──────────────────────────────────────────────────────┐
   │  retrospective fan-out (parallel, isolated contexts) │
   │                                                      │
   │  representation_retrospective                        │
   │     writes to registry/representations/              │
   │                                                      │
   │  discovery_retrospective    ← THIS MODULE             │
   │     writes to registry/discoveries/                  │
   └──────────────────────────────────────────────────────┘
                         │
                         ▼
                      Archive
```

The two retrospectives run in parallel because they read the same input contract and emit to disjoint registries. They are not allowed to modify each other's outputs; cross-references are recorded by ID only.

## B. Input contract

The orchestrator hands the retrospective a single JSON payload:

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

  // Verifier evidence (NEW vs representation_retrospective)
  "verifier_evidence": {
    "lemmas_closed"      : [ "<full Lean lemma name>", ... ],
    "numerical_certs"    : [ { "kind": "QQ_PSD", "hash": "...", "rep_id": ... }, ... ],
    "actual_evidence"    : [ <opaque JSON from explain_why_prompt §A.0> ]
  },

  // Existing registry snapshot (for dedup)
  "existing_discoveries": [ <entries.jsonl content> ],
  "existing_playbook"   : [ ... ],
  "existing_representations": [ ... ]
}
```

The `existing_*` fields are passed by reference (filesystem path) when over a few KB; the module reads them as needed.

## C. Trigger detection

The module scans the input against the 10 triggers from `discoveries/SCHEMA.md` §E. Each trigger has a *pattern detector* (deterministic, runs first) and a *gate* (LLM-driven, runs second).

### C.1 Pattern detector rules

| Trigger | Detector predicate (deterministic) |
|---|---|
| **D-NEW-MOVE** | Auditor's `annotations` contain `[LOAD_BEARING]` on an atom whose `lemma_name` is NOT in `existing_playbook` AND not derivable from `existing_representations[*].formal_form` keyword match. |
| **D-AUX-DEF** | `compile_fix_log` shows ≥ 1 `noncomputable def` declared at `top_level` AND that def is referenced by ≥ 2 distinct `lemma_name`s in `atom_list`. |
| **D-API-BYPASS** | `compile_fix_log[*].tactic` contains an inlined sequence ≤ 5 lines that closes a goal where the obvious named lemma was tried-and-failed (Tier-1 in `failures/`). The same pattern (by goal-shape hash) appears in `failures/` ≥ 1 prior run. |
| **D-EXTRAPOLATE** | `state.failed_attempts` includes one with `reason ∋ "literal claim refuted by sweep"` AND the final `current_conjecture` has a *quantifier restriction* (`∀ x ∈ F, …` instead of `∀ x, …`) where `F` was not in the original problem statement. |
| **D-DICHOTOMY** | The proof's atom list contains a top-level `Or`-introduction OR a `match` on a classifier function (`recognize` from a GeometricReasoner) AND each branch closes with a *different* registered route. |
| **D-AUGMENT** | The `blueprint.rep_chosen` exposes a state variable not present in the original problem statement (e.g. lookahead `v_{t+k}`, lifted gauge variable, mirrored copy) AND that variable appears in the Lyapunov / objective. |
| **D-RIGOR-LIFT** | `verifier_evidence.numerical_certs` contains a `QQ_PSD` cert AND the upstream solver was floating-point (CLARABEL / SCS / scipy). |
| **D-CROSS-DOM** | An existing entry `disc_NNN_...` has `domain != problem.domain` AND its `when_to_query` keywords overlap with the current problem's NL by ≥ 3 tokens. |
| **D-ANTI-PROVE** | `state.failed_attempts` includes one with `outcome = "succeeded but strictly weaker bound"` (NOT a STUCK) — i.e. a route worked but produced a worse result than the chosen route. |
| **D-PROMOTE** | An existing entry has `len(known_instantiations) >= 2` AND the current run would add a 3rd-from-distinct-source instantiation. |

### C.2 Gate questions (LLM-driven)

For each detected pattern, the LLM is asked the three gate questions from `discovery_retrospective_prompt.md` §D:

(a) Is this in the cited literature? (If yes, it's a *known* trick, not a discovery — reject.)
(b) Is this in `registry/representations/` or `registry/playbook/` already? (If yes — patch, do not insert.)
(c) Can the prerequisites be stated as a checkable list? (If no — the pattern is too vague to register; reject.)

A pattern that passes all three becomes a *candidate entry*.

## D. Output contract

```jsonc
{
  "run_id"     : "...",
  "module"     : "discovery_retrospective",
  "candidates" : [ <entry>, <entry>, ... ],   // 0..5 entries
  "patches"    : [ <patch>, <patch>, ... ],   // 0..N patch lines
  "skipped"    : [
    { "trigger": "D-NEW-MOVE", "reason": "literature-known: HRS 2016" }
  ],
  "summary"    : "<one paragraph: which triggers fired, what was kept>"
}
```

The orchestrator validates the output against `discoveries/SCHEMA.md` §H rules, then appends to `entries.jsonl`. If validation fails on a specific candidate, that candidate is dropped and a `validation_error` is recorded; the rest proceed.

## E. Selection rules

After the gate questions, multiple candidates may remain. Selection is governed by `discoveries/SCHEMA.md` §G:

1. **Hard cap**: at most 5 new entries per run. If more, top-5 by §E priority.
2. **Dedup**: `(category, name)` near-match (edit-distance ≤ 3) → patch, not insert.
3. **Anti-spam**: ≥ 3 `api_workaround` candidates → fold all into top-1's `notes`.
4. **Maturity gate**: a new entry with `maturity = "validated_multi"` requires ≥ 2 `known_instantiations` from distinct source problems already populated; if not, downgrade to `validated_once` or `conjectural`.

Patches (D.5) are not subject to the 5-entry cap; they are bookkeeping.

## F. Relationship to representation_retrospective

`representation_retrospective` (`workspace/agents_spec/representation_retrospective.md`,
prompt at `workspace/agents_spec/representation_retrospective_prompt.md`) and
`discovery_retrospective` are siblings:

| | representation_retrospective | discovery_retrospective |
|---|---|---|
| **Question answered** | What ROUTE choices did this run validate or invent? | What MID-LEVEL MOVES did this run expose for reuse? |
| **Channel** | `registry/representations/` | `registry/discoveries/` |
| **Granularity** | one (object, form) pair | one transferable move/idea |
| **Triggers** | T-LEMMA, T-AUX-SEQ, T-CONJ-REFINE, T-LIT-JUMP, T-TOOL-SWITCH, T-WH-FALSIFY, T-MULTI-FILE | D-NEW-MOVE, D-AUX-DEF, D-API-BYPASS, D-EXTRAPOLATE, D-DICHOTOMY, D-AUGMENT, D-RIGOR-LIFT, D-CROSS-DOM, D-ANTI-PROVE, D-PROMOTE |
| **Cap per run** | 5 | 5 |

They share the input contract (same JSON payload). They MUST NOT modify each other's output. The orchestrator concatenates results, runs validators in parallel, and applies all writes in a single transaction.

### F.1 Cross-references between channels

When a `discovery_retrospective` candidate references a representation that the `representation_retrospective` is about to write in the same run:

- The `back_references.representations` field uses the future ID (`rep_NNN_...`).
- Validation checks both the existing registry AND the in-flight write batch from the sibling retrospective. (Same convention as `representations/SCHEMA.md` §E.6 rule 2.)

If both retrospectives independently want to record the *same* move (e.g. an aux-sequence: representation_retrospective records the rep `rep_010_zseq_lyapunov`-style entry; discovery_retrospective records `disc_006_aux_sequence_synthesis`-style entry), this is correct and not double-counted: the rep is the *form* of the object, the discovery is the *move* that introduces it. Both stay live.

## G. Error handling

- **LLM produces malformed JSON**: re-run once with explicit JSON repair instruction; if still malformed, drop all candidates from this run and log to `workspace/active/.../discovery_retrospective_errors.log`.
- **Candidate violates §H schema**: drop that candidate; keep others; record in `skipped`.
- **Candidate would create supersede cycle**: drop; record in `skipped`.
- **Module exceeds time budget** (default 60s): emit any candidates produced so far; mark module as `partial`.

## H. Logging

Every run emits a structured log to `workspace/active/<run_id>/discovery_retrospective.log`:

```jsonc
{ "ts": "...", "run_id": "...",
  "triggers_fired": ["D-NEW-MOVE", "D-AUX-DEF", "D-PROMOTE"],
  "gates_failed":  [{"trigger": "D-NEW-MOVE", "reason": "lit-known"}],
  "entries_written": 2,
  "patches_applied": 1,
  "duration_ms": 1850 }
```

Aggregated logs feed the framework's own self-evaluation: which triggers actually find new content vs. produce noise. The `D-CROSS-DOM` trigger in particular is a candidate for retirement if its hit rate stays below 5% over the first 50 runs.

## I. Bootstrapping

The seed entries in `entries.jsonl` (9 entries as of 2026-04-30) were hand-curated from the OP-1, OP-2, OptLib2, and master_discovery_report.md sources, with `discovered_via = "retrospective_curated"`. The retrospective module did NOT generate them; it inherits them as the initial state of the channel.

Subsequent runs of `discovery_retrospective` will use `discovered_via = "retrospective_auto"` for entries it generates without operator review, and `"retrospective_curated"` for entries an operator hand-edits before commit.

## J. Failure-mode of the module itself

The retrospective is allowed to *miss* discoveries (false negatives are cheap: the human or the next run will catch them). It is NOT allowed to *invent* discoveries that were not in the trace (false positives pollute the registry). The gate questions in §C.2 are the primary guard against false positives; the validation in §G is the secondary guard.

A self-evaluation criterion: if the validator rejects > 30% of candidates over a sliding window of 20 runs, the prompt template in `discovery_retrospective_prompt.md` is re-tuned. (This is operator-driven, not self-modifying.)

## K. Future work

1. **D-PROMOTE auto-emit playbook entry**: currently when a discovery hits 3 instantiations the module sets `maturity = promoted_to_playbook` but does NOT write the matching playbook entry. Operator does that step. Future: emit a candidate playbook line for operator approval.
2. **Cross-domain bridge module**: when D-CROSS-DOM fires repeatedly between two domains, surface the pair as a *new* registry entity (`bridges/`?). Out of scope for SCHEMA v1.
3. **De-duplication via abstract_shape similarity**: currently dedup is by `(category, name)` edit-distance. A more principled approach: embed `abstract_shape` and dedupe by cosine similarity ≥ 0.9. Punt to v2.
