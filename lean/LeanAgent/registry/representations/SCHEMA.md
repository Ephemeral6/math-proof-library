# Representation Registry — Schema Specification

**Channel**: `LeanAgent/registry/representations/`
**Created**: 2026-04-30
**Schema version**: `SCHEMA_VERSION = 2`
**Position**: 6th registry channel, peer to `lemmas/`, `pairs/`, `playbook/`, `failures/`.
**Storage**: append-only JSONL (`entries.jsonl`); each line is one entry.

A **representation** is a way of looking at a mathematical object that makes
some inferences cheap and others expensive. Two representations of the same
object are equivalent in truth-value but very different in proof-search.
The registry records, for each (object, representation) pair the system
has seen succeed or fail: what the representation is, what tools are
needed, how to transport between it and other representations, on which
problem it was first encountered, and its current status.

This is what was concluded in the capability-2 analysis: the discovery
loop needs a *first-class* place to record route choice — the
"which representation should we be in right now?" question that comes
*before* "which tactic should we apply?" The other 4 channels record
either *truth* (`lemmas/`, `pairs/`) or *recipes* (`playbook/`,
`failures/`); none of them records *route choice*.

---

## A. Entry JSON schema

Each line of `entries.jsonl` is one JSON object with the fields below.
The user-spec required fields are **bold**; supplementary fields used
by the seed data are kept and described.

```jsonc
{
  // ── identity ────────────────────────────────────────────────────────────
  "id"           : "rep_<NNN>_<short_slug>",          // ★ required
  "object"       : "<the mathematical object>",        // ★ required
  "domain"       : "<top-level branch — see A.1>",     // ★ required

  // ── the representation ──────────────────────────────────────────────────
  "representation"   : "<short name + 1-line description>",                  // ★ required
  "formal_form"      : "<Lean 4 type/signature OR NL if not yet formalised>",// ★ required
  "tools_required"   : ["<tool_1>", "<tool_2>", ...],                        // ★ required
  "tools_status"     : "available" | "partial" | "missing",                   // ★ required
  "tools_missing_what": "<if tools_status != available, what is missing>",   // optional

  // ── transport graph ─────────────────────────────────────────────────────
  "transport_to"     : [                                                      // ★ required (may be [])
    {
      "target_rep_id"  : "rep_<NNN>_<...>",
      "transport_method": "<short description of how to convert>",
      "transport_lemma": "<Lean lemma name in registry/lemmas/, OR null>",
      "cost"           : "cheap" | "moderate" | "expensive",
      "bidirectional"  : true | false,
      "loss"           : "lossless" | "lossy_<what is lost>"
    }
  ],

  // ── verification provenance ─────────────────────────────────────────────
  "verification_qualifier": "EXACT" | "EXHAUSTIVE_ON_SAMPLE"                  // ★ required
                          | "NUMERICAL" | "INCOMPLETE",
  "verification_evidence" : "<which script / which benchmark item / which
                              Lean theorem witnesses the qualifier>",         // optional but strongly recommended

  // ── source & status ─────────────────────────────────────────────────────
  "source_problem"   : "<benchmark #N | OP-1 round k | OP-2 round k | OptLib2>",  // ★ required
  "source_iteration" : "<round number, or null>",                                  // optional
  "discovered_via"   : "literature" | "counterexample_analysis"                    // optional
                     | "tool_routing" | "registry_reuse" | "human",
  "status"           : "validated" | "conjectural" | "disproved",                  // ★ required
  "failure_mode"     : "<if disproved: counterexample type + scope, else null>",  // ★ required-when-disproved

  // ── implication graph (SCHEMA_VERSION 2) ────────────────────────────────
  "implies_reps" : ["<rep_id>", ...],           // optional; default []. logical
                                                // implication edges: A.implies_reps
                                                // contains B iff A ⇒ B over the
                                                // shared object class. Drives
                                                // Tier-1 of strict_stronger.py.

  // ── housekeeping ────────────────────────────────────────────────────────
  "supersedes"   : ["<rep_id, rep_id, ...>"],   // representations this strictly improves on
  "superseded_by": null | "<rep_id>",
  "notes"        : "<free text>",               // ★ required (may be "")
  "ts"           : "<ISO-8601>"                  // optional but recorded by the orchestrator
}
```

### A.1 `domain` controlled vocabulary

Keep this list short; new domains added only when an entry doesn't fit:

- `optimization` — first-order methods, Lyapunov, convergence rates.
- `convex_analysis` — duality, KKT, subdifferential, prox.
- `geometric_topology` — surfaces, curve complexes, mapping class groups.
- `combinatorial_topology` — flag complexes, dismantlability, collapsibility.
- `learning_theory` — generalization, PAC, Rademacher.
- `statistics` — concentration, high-dim estimation.
- `linear_algebra` — matrix analysis, spectra, LMIs.
- `probability` — martingales, couplings.
- `meta` — domain-agnostic patterns (e.g. `rep_017_recursive_synthesis`).

### A.2 Cost vocabulary

| Cost | Meaning |
|---|---|
| `cheap`     | one-line rewrite, `simp`-class transformation, unfold a `def`, project a record field |
| `moderate`  | uses a named lemma or 5–10 lines of tactic (e.g. Riesz `toDual`, `match_scalars <;> field_simp`) |
| `expensive` | requires a separate proof or non-trivial computation (polarisation, MCG-orbit BFS, conic SDP solve, recursive synthesis) |

### A.3 `verification_qualifier` semantics

- `EXACT` — Lean theorem closes axiom-clean OR exact-rational certificate
  verified by `sympy.is_positive_semidefinite` in QQ.
- `EXHAUSTIVE_ON_SAMPLE` — every element of an explicit finite set checked
  (e.g. 378/378 descending links).
- `NUMERICAL` — floating-point computation reports OK (CLARABEL `optimal`);
  may have error bars.
- `INCOMPLETE` — heuristic / partial verification only.

#### A.3.1 Completion-criterion contribution

The qualifier feeds the conjecture-level `completion_status` gate defined in
`workspace/agents_spec/hypothesis_tracker.md §G`. The mapping (with `pass_rate = 1.0`
and every active WH settled):

| Qualifier | Completion-status contribution |
|---|---|
| `EXACT` | `formally_certified` |
| `EXHAUSTIVE_ON_SAMPLE` | `empirically_verified` |
| `NUMERICAL` | `inconclusive_open` (gate prevents "proved" claim) |
| `INCOMPLETE` | `inconclusive_open` |

The orchestrator's Archive stage reads the resulting `completion_status` via
`can_emit_summary` (`hypothesis_tracker.md §G.3`): `formally_certified` and
`empirically_verified` permit a closing summary; the other states force a
progress report with explicit `OPEN` markers. This replaces the prior loose
formulation "termination rule (architecture_report.md Q4)."

### A.4 `discovered_via` taxonomy

How the agent first arrived at this representation — used by the
post-Auditor retrospective to credit the right module:

- `literature` — paper / textbook gave the form.
- `counterexample_analysis` — diagnosing why a previous representation
  failed produced this one.
- `tool_routing` — Architect picked it from registry given (object, domain).
- `registry_reuse` — a prior problem already had this entry; new problem
  imported it.
- `human` — operator wrote it in by hand.

---

## B. Interface to the existing 4 channels

`representations/` is a **sibling**, not a parent, of the existing 4
channels. Each channel answers a different question:

| Channel | Question it answers | Granularity |
|---|---|---|
| `lemmas/` | "Has this exact statement been proved?" | one Lean theorem |
| `pairs/` | "Does this NL match this Lean signature?" | NL ↔ Lean alignment |
| `playbook/` | "Given this goal shape, what tactic closes it?" | tactic-recipe |
| `failures/` | "Has this approach already STUCK?" | failed atom |
| **`representations/`** | **"Which form of the object should I be in?"** | (object, form) pair + transport |

The capability-2 analysis concluded: capability 2 (generalize-vs-specialize)
*triggers* capability 1 (representation switching). When an explain-why
hypothesis is falsified, the diagnosis "the candidate property failed but
the conjecture survived" *means* "the current representation is too
restrictive" — at which point the Diagnoser queries `representations/`
for an alternative. So this channel is the bridge between the capability
2 (Hypothesis Tracker) and capability 1 (Rep Selector / Discoverer) layers
of the v2 architecture.

### B.1 Cross-references

- `representations/` → `lemmas/`: a transport edge's `transport_lemma`
  field names a row in `lemmas/`. Example: `rep_002_descent_gradient`'s
  transport to `rep_001_descent_fderiv` cites
  `transport_lemma = "descent_lemma_gradient_form"`, which is a row in
  `LeanAgent/OptLib2/...`.
- `pairs/` is **language transport** (NL → Lean); `representations/` is
  **semantic transport** (one Lean form ↔ another Lean form, both correct).
  Every entry whose endpoints both have Lean proofs references two rows
  in `pairs/`.
- `playbook/` is "given a stuck goal, here is the close." `representations/`
  is "given a stuck goal, here is a *different goal* of the same content
  that may be easier to close." Playbook = micro-tactic; representation =
  macro-route. They compose: switch representation, then run a playbook
  pattern in the new representation.
- `failures/` records what didn't work in the *current* representation.
  When a `failures/` diagnosis is "obstruction is structural in this
  representation," the Rep Discoverer emits a new `representations/`
  entry with `discovered_via = "counterexample_analysis"` and
  `transport_to` pointing back at the failed representation, annotated
  with the structural barrier as the loss.

### B.2 Worked example — descent lemma

For the descent lemma `f y ≤ f x + ⟨∇f x, y-x⟩ + (L/2)‖y-x‖²` the system has:

- 2 `pairs/` rows (FDeriv form, gradient form),
- 2 `lemmas/` rows (one per form),
- 0 `playbook/` rows for the lemma itself; 2 for inner sub-tactics,
- **2** `representations/` rows: `rep_001_descent_fderiv` and
  `rep_002_descent_gradient`, with a transport edge between them
  annotated `transport_lemma: descent_lemma_gradient_form`,
  `cost: moderate`, `bidirectional: true`, `loss: lossless`.

---

## C. Architect query interface

**Caller**: Architect (Stage 0 of the Lean pipeline, OR Rep Selector in
the discovery loop). Invoked **on every problem** as a cheap file-read.

**Two-layer triggering** (per design decision 7): the Architect probe
is the **lightweight** layer — file-read + filter, no LLM creativity
required. The heavyweight Diagnoser query (§D) only fires on
non-tactic-shape failures.

### C.1 Input

```jsonc
{
  "object"        : "<keyword(s) describing the mathematical object>",
  "domain"        : "<one of A.1>",
  "goal_pattern"  : "<optional: e.g. 'convergence rate of a first-order method'>"
}
```

### C.2 Output

```jsonc
{
  "representations": [<entry, entry, ...>],   // matches with status != "disproved"
  "transport_graph": [
    { "src": "rep_id_A", "dst": "rep_id_B",
      "cost": "moderate", "transport_lemma": "...", "bidirectional": true }
  ],
  "preferred_starting_rep": "<rep_id with lowest tools cost AND validated status>",
  "warnings": [
    "rep_id_X is conjectural (verification: EXHAUSTIVE_ON_SAMPLE only)",
    "rep_id_Y depends on tool 'curver' which is currently 'partial'"
  ]
}
```

### C.3 Filtering / ranking

```
matches = [ e for e in entries
            if (e.object matches object_keywords)
            and (e.domain == domain or e.domain == "meta")
            and (e.status != "disproved") ]

rank_key = (
  e.tools_status == "available",                                      # primary
  transport_in_degree(e.id),                                          # secondary
  {EXACT: 3, EXHAUSTIVE_ON_SAMPLE: 2, NUMERICAL: 1, INCOMPLETE: 0}[e.verification_qualifier],
  -e.transport_to[*].cost.cheapest                                     # quaternary
)
```

Tie-break by `tools_status: available` first, then by transport-graph
in-degree (representations many others transport *to* are usually the
most central), then by qualifier, then by cheapest outgoing edge.

### C.4 Disproved entries are still loaded

`status: "disproved"` entries are NOT returned in the result, but they
*are* read so that the Architect's downstream **anti-strictly-stronger
filter** can reject any candidate that is strictly stronger than a
known-disproved form. The seed data therefore contains disproved entries
(e.g. `rep_019_universal_vertex`, `rep_022_chordal_peo`) precisely as
anti-hint material.

The filter is implemented in `LeanAgent/scripts/strict_stronger.py` as
the function `reject_against_failed(candidate, failed_attempts, ctx)`,
which returns the failed entry that the candidate is strictly stronger
than (or `None` to pass). The function delegates to
`compare(p_a, p_b, ctx) → Verdict ∈ {STRICTLY_STRONGER, STRICTLY_WEAKER,
EQUIVALENT, INCOMPARABLE}` via three tiers:

  1. **Registry** — `implies_reps` graph (cheap, exact).
  2. **Lean probe** — when both predicates have `formal_form`, attempt
     `∀ x, P_a x → P_b x` and the converse (currently stubbed; falls through).
  3. **LLM** — 4-way classification fallback, used only when neither
     structured tier resolves; conservatively returns `INCOMPARABLE`
     when uncertain so the filter does not silently reject candidates.

This replaces the prior inline reference to "architecture_report.md Q1"
narrative; the four-way verdict surface is the source of truth.

---

## D. Diagnoser query interface

**Caller**: Diagnoser (after a non-tactic-shape failure, per design
decision 7) OR Hypothesis Tracker (when a WH falsification meets the
"representation too restrictive" judge — see
`workspace/agents_spec/hypothesis_tracker.md` §C).

**Heavyweight trigger**: this query is *not* fired for tactic-shape
compile failures (no-goals, explicit-arg count, simp over-rewrite); the
preflight linter handles those. It fires only when the Diagnoser has
identified a *structural* failure axis.

### D.1 Input

```jsonc
{
  "query_kind"     : "diagnoser",
  "object"         : "<as in C.1>",
  "domain"         : "<as in C.1>",
  "current_rep_id" : "rep_NNN_...",
  "failure_mode"   : "<verbatim from Diagnoser's axis-uniformity report>",
  "wh_at_falsification": "<optional: WH-N from Tracker>",
  "evidence_pointer": "<optional: test_plan[step].actual_evidence>"
}
```

### D.2 Output

```jsonc
{
  "candidates": [
    {
      "rep_id": "rep_id_Z",
      "transport_from_current": {
        "transport_method": "...",
        "cost": "moderate",
        "transport_lemma": "..."
      },
      "rationale": "<why this rep avoids the current failure mode>"
    }
  ]
}
```

### D.3 Filtering / ranking

```
1. Drop the current rep itself.
2. Drop reps with status == "disproved" UNLESS their failure_mode is
   strictly distinct from the current failure_mode.
3. Drop reps whose tools_status == "missing".
4. Sort by:
     primary   : transport cost from current_rep_id  (cheap < moderate < expensive)
     secondary : status                              (validated > conjectural)
     tertiary  : verification_qualifier              (EXACT > EXHAUSTIVE_ON_SAMPLE > NUMERICAL > INCOMPLETE)
5. Return top K (default K = 3).
```

### D.4 Rationale generation

The `rationale` field is generated at query time by comparing the
candidate's `failure_mode` (if any) and `discovered_via` to the current
`failure_mode`. Example: if current failure is "K_4 + 4-leaf core, no
universal vertex" and the candidate's `discovered_via ==
"counterexample_analysis"` with `source_iteration` matching exactly that
K_4-core CE, the rationale is: "this representation was specifically
discovered by analysing the K_4-core counterexample that blocked the
current rep."

### D.5 Cross-domain query (Bridge module)

A separate `query_kind = "bridge"` path: input
`(domain_old, object_old, transport_axis)` where `transport_axis` is e.g.
"discrete-to-continuous" or "graph-theoretic-to-metric." Returns
representations in *other* domains that share the structural axis.
Implemented by heuristic match on `transport_method` keywords across
domains.

---

## E. Feedback / write interface

**Caller**: post-Auditor retrospective, run **after** the Auditor verdict
and **before** Archive.

Writes are append-only and rate-limited; the spec for the retrospective
itself lives in `workspace/agents_spec/representation_retrospective.md`
(prompt template at `workspace/agents_spec/representation_retrospective_prompt.md`).
This section defines what input the retrospective takes and what entries
it emits. The Discoverer write path (T-WH-FALSIFY synthesis of new reps
when no existing entry matches the failure mode) is owned by the same
module — see `representation_retrospective.md §K`.

### E.1 Input contract

The retrospective receives the run's full trace:

- The Architect's blueprint and chosen route.
- The Decomposer's atom list (for keyword-driven discoveries).
- The compile-fix log from Stage 4 (which `transport_lemma`s were invoked).
- The Tightness Pre-Audit report.
- The Auditor's verdict.
- For discovery-mode runs: the State JSON
  (`current_conjecture` + `failed_attempts` + `diagnoses` +
   `why_hypotheses` + `tracker_log` from
   `workspace/agents_spec/hypothesis_tracker.md`).

### E.2 Auto-detection rules (extraction triggers)

Each trigger generates one *candidate* entry; the retrospective LLM
decides whether to write a new entry, update an existing one, or skip.

| Trigger | Pattern detected | Generated entry kind |
|---|---|---|
| **T-LEMMA** | Compile-fix log invokes a "transport-shaped" lemma: any of `toDual`, `polarisation`, `Riesz`, `match_scalars`, an explicit `noncomputable def aux_seq`, a `rfl`-bridge between two `def`s. | New transport edge between existing reps, OR new (rep, rep) pair if endpoints don't yet exist. |
| **T-AUX-SEQ** | Decomposer produced a `noncomputable def` (G-NEW pattern) at top level. | New rep for "trajectory + auxiliary sequence." |
| **T-MULTI-FILE** | Architect chose multi-file decomposition over inline (G5). | New transport: "in-file inlining ↔ multi-file `import`." |
| **T-CONJ-REFINE** | State.failed_attempts grew by ≥ 1 row this run AND the new current_conjecture has a different formal predicate name. | Candidate rep for the new form, `discovered_via = "counterexample_analysis"`. |
| **T-LIT-JUMP** | A literature citation appeared in the proof / report that was NOT in the previous round's `State.literature_in_scope`. | Candidate rep with `discovered_via = "literature"`. |
| **T-TOOL-SWITCH** | Numerical pipeline switched stacks mid-run (CLARABEL → SymPy QQ; curver → networkx). | New transport edge between two reps, possibly across domains. |
| **T-WH-FALSIFY** (NEW, capability 2) | A WH lifecycle event `verdict: REFUTED_AT_EXPLANATION` plus Tracker judge fires "representation too restrictive." | New rep with `discovered_via = "counterexample_analysis"`, transport edge from `current_rep_id` annotated as the structural barrier. |

> **Sibling channel — discoveries**: the `representation_retrospective` runs
> in parallel with `discovery_retrospective` (`workspace/agents_spec/discovery_retrospective.md`),
> which writes to `LeanAgent/registry/discoveries/` (see `discoveries/SCHEMA.md`).
> The two share the input contract (§E.1) and run in disjoint contexts; the
> 7 triggers above record *route choice*, the 10 triggers in `discoveries/SCHEMA.md` §E
> record *transferable mid-level moves*. A move that is also a route choice gets
> two entries (one per channel) — this is correct; the channels answer different questions.

### E.3 Output contract

The retrospective emits zero or more `<entry>\n` lines that the
orchestrator appends to `entries.jsonl`. It must NOT modify earlier
lines. Updates to an earlier entry are done via a "patch line":

```jsonc
{ "_patch": true,
  "target_id": "rep_007_old_thing",
  "set": { "superseded_by": "rep_018_better_thing" },
  "ts": "..." }
```

Readers fold patch lines as a final pass. (Same pattern as how
`failures/` handles `resolution: FIXED` annotations.)

### E.4 Rate limits and dedup

- **At most 5 new entries per run** to prevent inflation.
- If more triggers fire, only the 5 highest-priority are written:
  `T-CONJ-REFINE > T-WH-FALSIFY > T-AUX-SEQ > T-LIT-JUMP > T-LEMMA > T-MULTI-FILE > T-TOOL-SWITCH`.
- **Dedup against existing entries**: if a candidate's `(object, representation)`
  pair already exists, the candidate becomes an UPDATE (patch line) rather
  than a new INSERT. Only patches that change `transport_to`,
  `verification_qualifier`, `verification_evidence`, `status`, or `notes`
  are allowed; identity fields (`id`, `object`, `domain`, `representation`)
  are immutable.

### E.5 Hand-written entries

Operators may hand-write entries (one-time seed; corrections; cross-domain
analogies the agent missed). Hand-written entries set
`discovered_via: "human"` and the `notes` field should explain rationale.
The seed data delivered with this schema is hand-written.

### E.6 Validation rules

Before appending a new entry, the orchestrator checks:

1. **Schema**: all required fields present; controlled-vocab fields use
   allowed values (unknown `domain`/`cost`/`status` is a hard error).
2. **Referential integrity**: every `target_rep_id` in `transport_to`
   either exists already in the file OR is being added in the same write
   batch.
3. **Acyclic supersede chain**: `supersedes` and `superseded_by` cannot
   form a cycle.
4. **Lemma reference**: every non-null `transport_lemma` must name a row
   in `registry/lemmas/` OR `registry/pairs/`. A dangling reference is
   allowed only for `status: conjectural` entries with a `notes`
   explanation.
5. **No identity-tuple duplicates**: `(object, representation)` is unique
   across non-disproved entries.

A future `scripts/validate_registry.sh` will enforce these; for now the
operator runs them by inspection.

---

## Versioning

`SCHEMA_VERSION = 1` as of 2026-04-30. Schema-breaking changes (renaming
a controlled-vocab value, adding a required field) bump this constant
and ship a one-shot migration script.
