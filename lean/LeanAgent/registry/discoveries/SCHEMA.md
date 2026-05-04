# Tool Discovery Registry — Schema Specification

**Channel**: `LeanAgent/registry/discoveries/`
**Created**: 2026-04-30
**Schema version**: `SCHEMA_VERSION = 1`
**Position**: 7th registry channel, peer to `lemmas/`, `pairs/`, `playbook/`, `failures/`, `representations/`.
**Storage**: append-only JSONL (`entries.jsonl`); each line is one entry.

A **discovery** is a transferable *trick* that the Explorer (or a sister agent) reused after first invention — small enough to be a single move, but bigger than a tactic recipe and bigger than a single representation. Examples: a parity argument that bounds homology shift, a `noncomputable def aux_seq` synthesis pattern, an "inline polarisation bypass" that side-steps a missing Mathlib API, a frontier-extrapolation move that promotes a finite numerical sweep to a parametric bound.

The other 6 channels record either *truth* (`lemmas/`, `pairs/`), *recipes at the tactic layer* (`playbook/`), *anti-recipes* (`failures/`), or *route choice* (`representations/`). None of them records **transferable mid-level moves**: the patterns that an Explorer reapplies because "this looks like the time I did X." That is what `discoveries/` is for.

> Discoveries differ from `playbook/` in scope: a playbook entry closes a goal of a specific shape with a specific tactic. A discovery describes an *idea* that can be slot-filled across goals, domains, or representations. Discoveries differ from `representations/` in role: a rep is a noun (the form of an object), a discovery is a verb (the move you make).

---

## A. Entry JSON schema

Each line of `entries.jsonl` is one JSON object. **Bold** fields are required.

```jsonc
{
  // ── identity ────────────────────────────────────────────────────────────
  "id"           : "disc_<NNN>_<short_slug>",            // ★ required
  "category"     : "<see §B>",                            // ★ required
  "domain"       : "<see representations/SCHEMA.md §A.1>",// ★ required

  // ── what the trick is ────────────────────────────────────────────────────
  "name"         : "<short human-readable name>",         // ★ required
  "abstract_shape": "<one paragraph: the trick stated in domain-agnostic
                      terms — the slot-fillable skeleton>",  // ★ required
  "signature"    : {                                      // ★ required
    "lean"  : "<Lean 4 type/lemma signature OR null>",
    "nl"    : "<NL skeleton with $-prefixed slots>"
  },

  // ── when to use it ───────────────────────────────────────────────────────
  "when_to_query": ["<keyword_1>", "<keyword_2>", ...],   // ★ required
  "prerequisites": [                                       // ★ required (may be [])
    {
      "kind"   : "object_property" | "rep_present" | "tool_available"
               | "lemma_in_registry" | "domain_match",
      "spec"   : "<the requirement, in terms of registry IDs or NL>",
      "checkable": true | false
    }
  ],

  // ── failure modes & anti-patterns ────────────────────────────────────────
  "anti_patterns": [                                       // ★ required (may be [])
    "<short description of a misuse the Auditor must reject>"
  ],
  "failure_modes": [                                       // ★ required (may be [])
    {
      "trigger" : "<what looks like a fit but isn't>",
      "symptom" : "<how the Auditor / Verifier sees it fail>",
      "fallback": "<what to do instead — e.g. a sibling discovery id>"
    }
  ],

  // ── instantiations & evidence ────────────────────────────────────────────
  "known_instantiations": [                                // ★ required (≥ 1 if maturity > seed)
    {
      "source_problem"  : "OP-1 r7" | "OP-2 r3" | "Theorem 3" | "OptLib2 #11" | ...,
      "back_reference"  : "rep_NNN_..." | "lemma:...." | "playbook:....",
      "outcome"         : "succeeded" | "succeeded_with_caveat" | "failed",
      "notes"           : "<free text>"
    }
  ],
  "back_references": {                                     // ★ required
    "representations": ["rep_NNN_...", ...],
    "lemmas"         : ["...", ...],
    "playbook"       : ["...", ...],
    "failures"       : ["...", ...]
  },

  // ── obstruction routing (Phase-1, added 2026-05-01) ─────────────────────
  "defuses_obstruction": ["<obstruction_class>", ...],   // optional, default []
                                                          // values from
                                                          // workspace/agents_spec/obstruction_catalog.md §A
                                                          // drives Mode-3 query (§C below)

  // ── lifecycle ────────────────────────────────────────────────────────────
  "maturity"     : "seed" | "conjectural" | "validated_once"             // ★ required
                 | "validated_multi" | "promoted_to_playbook",
  "patches"      : [],                                                    // append-only patch log
  "supersedes"   : ["<disc_id>", ...],
  "superseded_by": null | "<disc_id>",
  "promoted_to_playbook_id": null | "<playbook entry name>",

  // ── housekeeping ─────────────────────────────────────────────────────────
  "discovered_via": "retrospective_auto" | "retrospective_curated"
                  | "human" | "import_from_master_discovery_report",
  "notes"        : "<free text>",                          // ★ required (may be "")
  "ts"           : "<ISO-8601>"                             // ★ required
}
```

---

## B. `category` controlled vocabulary

Every entry has exactly one category. The list is intentionally small; new categories are added only when an entry doesn't fit.

| Value | Meaning | Typical instantiation |
|---|---|---|
| `proof_technique` | A reusable mid-level mathematical move (parity bound, bigon classification, alpha-split, polarisation-over-Young) | `disc_001_homology_parity_bound` |
| `definition_synthesis` | A pattern for *introducing* a new definition mid-proof (auxiliary sequence, gauge-invariant norm) | `disc_006_aux_sequence_synthesis` |
| `strategic_pattern` | A meta-strategy that organises route choice (chordal-or-cone dichotomy, lookahead augmentation) | `disc_004_chordal_or_cone_dichotomy` |
| `api_workaround` | A pattern for working around a missing Mathlib / library API without proving the missing piece (inline polarisation, abel normalisation) | `disc_007_inline_polarisation_bypass` |
| `extrapolation_method` | A pattern for promoting finite/numerical evidence to a parametric statement (frontier extrapolation, conjugate-rationalization) | `disc_005_frontier_extrapolation` |
| `rigor_pattern` | A pattern that improves verification rigor without changing the result (SDP rationalize-then-verify) | `disc_008_sdp_rationalize_verify` |

A discovery may *secondarily* fit other categories; this is captured in `notes`, not in additional `category` slots.

---

## C. Query interfaces

Two distinct callers, two distinct cost regimes.

### Mode 1 — Architect proactive probe (cheap)

**Caller**: Architect (Stage 0 of every problem). Runs once per problem.
**Cost**: file-read + filter + keyword match. ~1 ms.
**Purpose**: surface the 0–3 most relevant discoveries before the Explorer starts so they show up as anti-hints / pre-hints in the prompt.

#### Input

```jsonc
{
  "query_kind"  : "architect_proactive",
  "object"      : "<keywords from problem statement>",
  "domain"      : "<domain from problem>",
  "rep_seed"    : "rep_NNN_..." | null,
  "goal_pattern": "<optional: convergence rate / counterexample / construction / ...>"
}
```

#### Filtering / ranking

```
matches = [d for d in entries
            if any(kw in (object ∪ goal_pattern) for kw in d.when_to_query)
            and (d.domain == domain or d.domain == "meta")
            and d.maturity in {"validated_once", "validated_multi", "promoted_to_playbook"}]

rank_key = (
  d.maturity priority,                  # validated_multi > validated_once > promoted_to_playbook
  prerequisites_satisfied(d, rep_seed), # all checkable prereqs True
  -len(d.failure_modes)                 # prefer well-charted ones
)
top_K = 3
```

`promoted_to_playbook` discoveries rank *below* `validated_multi` when both fire, because the playbook copy is the canonical implementation; the discoveries entry remains for cross-domain transfer.

#### Output

A ranked list of full entries (not summaries — they're already small).

### Mode 2 — Diagnoser stuck-query (heavyweight)

**Caller**: Diagnoser, after a non-tactic-shape failure. Fires only when the Tracker also flags "rep too restrictive" or "explanation REFUTED".
**Cost**: LLM-driven match. Batched.
**Purpose**: rescue a stuck attempt by surfacing trickier discoveries (anti-pattern matches, failure-mode sibling pointers).

#### Input

```jsonc
{
  "query_kind"      : "diagnoser_stuck",
  "object"          : "...",
  "domain"          : "...",
  "current_rep_id"  : "rep_NNN_...",
  "failure_mode"    : "<verbatim from Diagnoser>",
  "wh_at_falsification": "<optional WH-N>",
  "tried_discoveries": ["disc_NNN_...", ...]
}
```

#### Output

```jsonc
{
  "candidates": [
    {
      "discovery_id": "disc_NNN_...",
      "rationale"   : "<why this discovery defuses the failure_mode>",
      "fit_score"   : 0.0..1.0,
      "anti_pattern_match": true | false   // if true, this discovery WARNS against the path the Explorer was on
    }
  ]
}
```

The Mode-2 query may return `anti_pattern_match: true` results: discoveries whose `anti_patterns` field matches the current attempt. Those are returned not to suggest a path but to push the Explorer off one.

### Mode 3 — Tool Discoverer obstruction-keyed query (Phase-1)

**Caller**: Tool Discoverer (`workspace/agents_spec/tool_discoverer.md` §D.1), invoked after the Diagnoser ternary judge classifies the failure as `technique_insufficient`.
**Cost**: file-read + filter on `defuses_obstruction[]`. ~1 ms.
**Purpose**: surface discoveries whose registered `defuses_obstruction[]` contains the obstruction class identified by the Explain-Why prompt's `obstacle.obstruction_class` field. This is keyed on the *failure* class rather than the *goal* shape, which is the structural difference between Mode 1 (goal-keyed) and Mode 3 (obstruction-keyed).

#### Input

```jsonc
{
  "query_kind"        : "tool_discoverer",
  "object"            : "...",
  "domain"            : "...",
  "current_rep_id"    : "rep_NNN_...",
  "current_technique" : "<NL describing the proof method that hit the wall>",
  "obstruction_class" : "<one of obstruction_catalog.md §A>",
  "tried_discoveries" : ["disc_NNN_...", ...]
}
```

#### Filtering / ranking

```
matches = [d for d in entries
            if obstruction_class in (d.defuses_obstruction or [])
            and d.maturity in {"validated_once", "validated_multi", "promoted_to_playbook"}
            and d.id not in tried_discoveries]

rank_key = (
  d.maturity priority,                   # validated_multi > validated_once > promoted_to_playbook
  domain_match(d, current_domain),       # same > "meta" > other
  category_match(d, catalog_typical_category),  # bonus when category matches obstruction_catalog.md row
  -len(d.failure_modes)                  # prefer well-charted ones
)
top_K = 3
```

The Mode-3 ranker differs from Mode-1 in two ways: (i) the filter is on `defuses_obstruction[]` not `when_to_query[]`; (ii) the secondary tiebreaker uses `obstruction_catalog.md`'s recommended `typical category` for the input class, not the goal_pattern.

#### Output

```jsonc
{
  "candidates": [
    {
      "discovery_id"     : "disc_NNN_...",
      "category"         : "...",
      "rationale"        : "<why this discovery defuses the obstruction_class>",
      "fit_score"        : 0.0 .. 1.0,
      "prerequisites_met": true | false | "unknown"
    }
  ]
}
```

The full Tool Discoverer output (which includes `obstruction_summary`, `suggested_query`, and the Phase-2 synthesis flag) is documented in `workspace/agents_spec/tool_discoverer.md §E`. Mode 3 here only returns the `candidates` slice.

#### Mode 3 vs Mode 2

Both Mode 2 and Mode 3 fire on failure. The difference: Mode 2 is keyed on the legacy free-text `failure_mode` string and runs an LLM-side match; Mode 3 is keyed on the controlled-vocab `obstruction_class` and is a pure file-read + filter (no LLM). They are complementary — Mode 2 catches anti-pattern matches and idiosyncratic failure shapes; Mode 3 catches the well-classified cases. The Diagnoser invokes Mode 3 first; if Mode 3 returns empty, Mode 2 may follow as a fallback.

---

## D. Write interface — `discovery_retrospective`

**Caller**: post-Auditor retrospective (sibling of `representation_retrospective`), runs after the Auditor verdict and before Archive. Spec at `workspace/agents_spec/discovery_retrospective.md`.

Writes are append-only and rate-limited.

### D.1 Input contract

The retrospective receives the run's full trace, **identical to** `representation_retrospective` — they are siblings, not replacements:

- Architect blueprint and chosen route.
- Decomposer atom list.
- Compile-fix log, with transport-lemma invocations.
- Tightness Pre-Audit report.
- Auditor verdict.
- Discovery-mode runs: `current_conjecture`, `failed_attempts`, `diagnoses`, `why_hypotheses`, `tracker_log`.
- **In addition**: any verifier evidence (Lean lemma name closed, numerical certificate hash, `actual_evidence` JSON).

### D.2 Output contract

Zero or more `<entry>\n` lines. Patches use the same convention as `representations/SCHEMA.md` §E.3:

```jsonc
{ "_patch": true,
  "target_id": "disc_001_homology_parity_bound",
  "set": { "maturity": "validated_multi",
           "patches": [..., {"action": "+instantiation",
                              "instantiation": {...},
                              "ts": "..."}] },
  "ts": "..." }
```

Identity fields (`id`, `category`, `domain`, `name`, `abstract_shape`) are immutable. Patches may modify: `maturity`, `signature` (only on `seed → conjectural`), `prerequisites`, `anti_patterns`, `failure_modes`, `known_instantiations`, `back_references`, `superseded_by`, `notes`.

---

## E. Trigger taxonomy (10 triggers)

The retrospective LLM scans the run trace against 10 patterns. Each detected pattern emits one *candidate* discovery; the LLM's gate questions (D.4 in the prompt spec) decide whether to write a new entry, patch an existing one, or skip.

| Code | Pattern | Generated entry kind |
|---|---|---|
| **D-NEW-MOVE** | A *novel mid-level move* appears in the proof that is not in any existing playbook / representation entry, and the Explorer's notes flag it as the load-bearing step. | New `proof_technique` entry. |
| **D-AUX-DEF** | A `noncomputable def` for an auxiliary sequence / gauge / lift is introduced and used in ≥ 2 lemmas. | New `definition_synthesis` entry, OR patch existing one with new instantiation. |
| **D-API-BYPASS** | The compile-fix log shows the same Mathlib gap navigated by inlining a 1–5-line lemma, *and* this is the second time we've seen it. | New `api_workaround` entry. |
| **D-EXTRAPOLATE** | A finite numerical sweep is promoted to a parametric statement via a stated extrapolation move (frontier, conjugate, adversarial-existential). | New `extrapolation_method` entry. |
| **D-DICHOTOMY** | The proof splits the problem into A-or-B and the split is reusable: A and B each enable a distinct discovery downstream. | New `strategic_pattern` entry. |
| **D-AUGMENT** | The proof *adds structure* (extra coordinate, lookahead step, mirrored variable) that simplifies the analysis without changing the algorithm semantics. | New `strategic_pattern` entry. |
| **D-RIGOR-LIFT** | A numerical certificate is upgraded to an exact rational / Lean-checkable certificate by a stated transformation pipeline. | New `rigor_pattern` entry. |
| **D-CROSS-DOM** | A discovery from one domain is reused in another, structurally identical configuration. | Patch existing entry with new domain in `known_instantiations`; promote `maturity` if rule allows. |
| **D-ANTI-PROVE** | The proof's failed attempt directory shows a path the Explorer should NOT take that is *not* in `failures/` because it didn't STUCK — it produced a strictly weaker bound. | Patch existing entry's `anti_patterns`, OR new `proof_technique` with `failure_modes` populated. |
| **D-PROMOTE** | A discovery has now been instantiated ≥ 3 times across distinct source problems with `outcome = succeeded`. | Patch `maturity → promoted_to_playbook`; create matching playbook entry. |
| **T-DISC-SYNTH** *(Phase-2 — schema-only in Phase-1)* | The Tool Discoverer Mode-3 query returned empty AND the Diagnoser confirmed `technique_insufficient` AND a Bridge sub-call returned ≥ 1 candidate paper / external reference matching the obstruction's `catalog_keywords`. | New `seed`-maturity entry with `defuses_obstruction = [obstruction_class]`, `signature.nl` populated from the Bridge result, `back_references` citing the paper(s), and `discovered_via = "retrospective_curated"`. |

> **T-DISC-SYNTH activation status**: schema declared in Phase-1, write path **not yet implemented**. The `discovery_retrospective` module's pattern detector (`workspace/agents_spec/discovery_retrospective.md §C.1`) does not yet emit this trigger; activation requires the Phase-2 Bridge sub-call. Until then, Tool Discoverer empty-match cases are recorded in the closing-summary `open_items` (per `tool_discoverer.md §F.2`) rather than in `discoveries/entries.jsonl`. The schema is reserved here so that Phase-2 implementation does not need to touch this file.

Priority order when more than 5 fire: `D-NEW-MOVE > D-EXTRAPOLATE > D-AUX-DEF > D-AUGMENT > D-DICHOTOMY > D-API-BYPASS > D-RIGOR-LIFT > D-ANTI-PROVE > D-CROSS-DOM > D-PROMOTE > T-DISC-SYNTH` (T-DISC-SYNTH last because Phase-1 does not implement it; Phase-2 may re-rank).

---

## F. Maturity lifecycle

```
seed ─► conjectural ─► validated_once ─► validated_multi ─► promoted_to_playbook
              │              │                   │
              ▼              ▼                   ▼
        (disproved /    (caveat-marked      (parent of a playbook
         retracted —    in instantiation)    entry; both stay live —
         status patch                         the discovery describes
         to "disproved")                      the abstract shape, the
                                              playbook describes the
                                              concrete tactic)
```

Transitions:
- `seed → conjectural`: a non-trivial NL signature is written down (does not require a successful instantiation; this is the "I noticed a pattern but haven't reused it yet" state). Hand-written seed entries START at `conjectural` (or higher if the seed includes evidence).
- `conjectural → validated_once`: one `known_instantiation` with `outcome = succeeded` and a corresponding `back_reference` that exists in the named registry.
- `validated_once → validated_multi`: a second `known_instantiation` from a *distinct* source problem (different OP / Theorem / OptLib problem ID) with `outcome = succeeded`.
- `validated_multi → promoted_to_playbook`: third `known_instantiation`. Playbook entry is created and `promoted_to_playbook_id` is set; the discoveries entry is NOT deleted, because cross-domain transfer is the discoveries channel's job.
- Any state → `disproved`: a counterexample is found showing the abstract shape is wrong (not just an instantiation that failed). Patches `maturity → disproved` and adds a `superseded_by` if a fix is known.

A discovery in `seed` state is INVISIBLE to Mode-1 queries (filter line in §C.1). Mode-2 may surface seeds when `failure_mode` is exotic enough that nothing more mature matches.

---

## G. Dedup and rate limit

- **At most 5 new entries per run** — same convention as `representations/`.
- If more triggers fire, top-5 by §E priority are written.
- **Dedup against existing entries**: if a candidate's `(category, name)` matches an existing entry within edit-distance ≤ 3, the candidate becomes a *patch* (new instantiation, refined anti-pattern, refined signature) rather than an INSERT. The retrospective LLM is told this rule explicitly in the prompt so it does not generate near-duplicates.
- **Anti-spam guard**: if a single run would emit ≥ 3 new entries with `category = api_workaround`, only the top 1 is written; the rest are folded into a single `notes` summary on that one. (API workarounds proliferate; we want them, but rate-limited.)

---

## H. Validation rules

Before appending, the orchestrator checks:

1. **Schema**: required fields present; controlled-vocab fields use allowed values.
2. **Referential integrity**: every entry in `back_references.representations` exists in `LeanAgent/registry/representations/entries.jsonl`; same for `lemmas`, `playbook`, `failures`.
3. **Acyclic supersede**: `supersedes` and `superseded_by` cannot form a cycle.
4. **ID uniqueness**: `disc_NNN_...` IDs are unique.
5. **Maturity gate**: state transitions match §F (e.g. cannot jump `seed → validated_multi` without two intermediate instantiations).
6. **Prerequisite checkability**: every `prerequisites[*].checkable: true` row must have a `spec` that names a registry ID or a `tool_available` value present in the engine inventory.

`LeanAgent/scripts/validate_discoveries.py` enforces these.

---

## Versioning

`SCHEMA_VERSION = 1` as of 2026-04-30. Schema-breaking changes (renaming a controlled-vocab value, adding a required field) bump this constant and ship a one-shot migration script.
