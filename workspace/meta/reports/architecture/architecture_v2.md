# Math Agent Architecture v2 — Integrated Discovery Loop

**Date**: 2026-04-30
**Relation to v1**: extends `workspace/reports/architecture/architecture_report.md` (henceforth "v1")
without modifying it. v1 is the snapshot of the working system as of
2026-04-30 (7-stage Lean pipeline + 5-module discovery loop). v2 adds
the **Representation System** (6th registry channel) and the
**Capability 2 layer** (Instance Sorter + Explain-Why + Hypothesis
Tracker) and re-threads the discovery loop to consume both.

This document is design only; no source code is modified. Implementation
roadmap is Part V.

---

## Part I — Current Architecture (v1 summary)

Full detail in `workspace/reports/architecture/architecture_report.md`. Highlights:

### Lean Formalization Pipeline
A 7-stage skill (`lean-formalization-agent`) running:
```
Architect → Decomposer → Aligner → Skeleton → Filler → Verifier → Linter
```
plus a Tightness Pre-Audit between Explorer and Judge (proof mode).
13/13 CERTIFIED on the optlib benchmark as of 2026-04-30. Capabilities
validated: single-file proofs ≤ 304 LOC, multi-route exploration,
Tier-3 recursive synthesis, multi-file decomposition, registry reuse,
auxiliary-sequence synthesis, vector-identity normalisation. Known
gaps: tactic-shape preflight linter, Stage-6 polish, no PR submission.

### Discovery Pipeline (research mode)
v1 frames 5 modules:
```
Proposer → Verifier → Prover → Diagnoser → Bridge → repeat
```
Reconstructed from OP-1 (6 rounds, `op1_detailed.md`) and Theorem-3
(4 rounds, `theorem3_final.md`) traces. State is reconstructed from
prose; failure schema is English commentary; no proposer module that
encodes failure as anti-hint.

### Registry (4 channels)
- `lemmas/` — one JSON per certified Lean theorem (8 entries).
- `pairs/` — NL ↔ Lean parallel corpus (18 entries).
- `playbook/` — proof patterns; 6 tactic + 4 named patterns (10 entries).
- `failures/` — STUCK records (5 entries).

### What v2 adds (one sentence)
A 6th channel `representations/` for *route choice*; an Instance
Sorter as a Proposer-output field; an Explain-Why prompt invoked after
each Verifier step; a Hypothesis Tracker that drives the next round's
predictions; and the wiring between them so that capability-2
falsification triggers capability-1 representation switching.

---

## Part II — New Discovery Loop Architecture

### A. The updated flow

```
Goal(intent ∈ {deep_dive, scout})
 │                                          (scout-mode spec:
 │                                           workspace/agents_spec/scout_mode.md)
 ▼
PROPOSER  ─── emits ──► (conjecture + test_plan + initial WH)
 │                               (instance_sorter.md §A)
 │                               • intent=scout → max_steps=1
 │                               • intent=deep_dive → full plan
 ▼
[Rep Selector — Architect probe]
 │  • lightweight: file-read + filter on registry/representations
 │  • input  : (object, domain) from Proposer
 │  • output : preferred_rep + transport_seq
 │  • cost   : ~ 1 ms; runs every round
 │  (lean/LeanAgent/registry/representations/SCHEMA.md §C)
 │
 ▼
[INTENT FORK]
 │
 ├── intent == scout ──► VERIFIER(1 step) → Explain-Why SEED only →
 │                       Tracker(WH-1, ACTIVE only) →
 │                       tractability_report [SCOUT EXIT]
 │                       (skip: Diagnoser, Prover, Tightness Pre-Audit,
 │                        Judge, Auditor, Fixer, retrospectives, Archive)
 │
 └── intent == deep_dive ──► continue normal flow below
 │
 ▼
VERIFIER  ─── executes test_plan step by step ──► per-step (actual_outcome, evidence)
 │
 ▼
[Explain-Why prompt — fires after each step]
 │  • seed prompt on step 1; stress-test on subsequent steps
 │  • output : verdict ∈ {CONFIRMED, REFUTED_AT_EXPLANATION,
 │            FALSIFIED, MIXED} + successor WH
 │  (workspace/agents_spec/explain_why_prompt.md)
 │
 ▼
HYPOTHESIS TRACKER
 │  • registers WH from seed prompt
 │  • updates predictions.status from each stress-test verdict
 │  • on REFUTED_AT_EXPLANATION: WH → failed_attempts; create successor
 │  (workspace/agents_spec/hypothesis_tracker.md)
 │
 ▼
PROVER ─── attempts formal proof on verified conjecture ──► verdict
 │
 ├── success ──► [completion_status check]
 │                 │
 │                 ├── status ∈ {empirically_verified, formally_certified}
 │                 │     ──► Archive emits CLOSING SUMMARY + post-Auditor
 │                 │         RETROSPECTIVE (representation_retrospective +
 │                 │         discovery_retrospective in parallel; writes new
 │                 │         entries to registry/representations/ via
 │                 │         T-LEMMA, T-AUX-SEQ, T-CONJ-REFINE, T-WH-FALSIFY
 │                 │         triggers — SCHEMA.md §E)
 │                 │
 │                 └── status ∈ {pending, inconclusive_open, error, falsified}
 │                       ──► Archive emits PROGRESS REPORT with OPEN markers,
 │                           NOT a closing summary. Retrospective still runs
 │                           (records partial-route-choice data even on
 │                           inconclusive runs).
 │                 (gate spec: workspace/agents_spec/hypothesis_tracker.md §G)
 │
 └── failure ──► DIAGNOSER  (axis-uniformity probes; v1 Q2)
                  │
                  ├── tactic-shape failure ──► preflight linter
                  │   (does NOT trigger representation switch — design decision 7)
                  │
                  └── non-tactic-shape failure
                      │
                      ├── Tracker ternary judge (hypothesis_tracker.md §C.2)
                      │   driven by Explain-Why's obstacle field
                      │   ├── conjecture_refuted     → §B.4 (no Discoverer)
                      │   ├── rep_too_restrictive    → REP DISCOVERER (existing path)
                      │   ├── technique_insufficient → TOOL DISCOVERER (Part IX, NEW)
                      │   └── (combined cases may fire both Discoverers in parallel)
                      │
                      ├── [Rep Discoverer — heavyweight Diagnoser query]
                      │   • input  : (failure_mode, current_rep_id, WH)
                      │   • output : ranked candidate reps (top K=3) — READ-ONLY
                      │   • on empty top-K (no existing rep matches the
                      │     failure mode), the T-WH-FALSIFY trigger of
                      │     representation_retrospective fires the synthesis
                      │     of a new rep entry with status=conjectural.
                      │     Discoverer never writes; retrospective owns the
                      │     write path (representation_retrospective.md §K).
                      │   (SCHEMA.md §D)
                      │
                      ├── [Tool Discoverer — heavyweight obstruction-keyed query, NEW]
                      │   • input  : (obstruction_class, current_rep_id,
                      │              current_technique, propagation_path)
                      │   • output : ranked candidate discoveries (top K=3) — READ-ONLY
                      │   • on empty Mode-3 match, the catalog fallback
                      │     (obstruction_catalog.md) emits a suggested_query
                      │     for Phase-2 Bridge synthesis. T-DISC-SYNTH is
                      │     the Phase-2 prospective-write trigger.
                      │   (workspace/agents_spec/tool_discoverer.md §C/§D)
                      │
                      └── BRIDGE (literature search in new rep's domain;
                          Phase-2: also called by Tool Discoverer with
                          suggested_query)
                          │
                          ▼
                       back to PROPOSER with updated State
```

### B. Capability 1 integration — Representation Switching

Two embedding points for `registry/representations/`:

1. **Rep Selector after Proposer** (light-touch, every run). The Architect
   probe queries `(object, domain)` and returns a ranked list of
   available representations. The Proposer chooses one and the Verifier
   runs in that rep. This converts the Architect's existing `[REGISTRY]`
   semantic-search lookup into a structured registry query.
2. **Rep Discoverer after Diagnoser** (heavyweight, only on structural
   failure). When the Tracker's "rep too restrictive" judge fires (§D),
   the Discoverer queries the registry for alternatives. Tactic-shape
   compile failures NEVER reach this layer (per design decision 7);
   they go to the preflight linter.

Both layers share the registry schema (`SCHEMA.md` §A) and query
interface (`SCHEMA.md` §C and §D). Writes happen at the post-Auditor
retrospective (`SCHEMA.md` §E).

### C. Capability 2 integration — Generalize vs Specialize

Three new modules implementing the capability-2 design conclusions:

| Module | Position | Spec | Role |
|---|---|---|---|
| Instance Sorter | Proposer output field | `workspace/agents_spec/instance_sorter.md` | Encodes the `test_plan` array on `current_conjecture`; defines complexity ordering per domain |
| Explain-Why prompt | After each Verifier step | `workspace/agents_spec/explain_why_prompt.md` | Seed prompt on step 1; stress-test prompt on subsequent steps; produces JSON verdict + successor WH |
| Hypothesis Tracker | Owns the State's `why_hypotheses` array | `workspace/agents_spec/hypothesis_tracker.md` | WH lifecycle state machine; triggers Rep Discoverer on REFUTED_AT_EXPLANATION |

Per design decision 1, **Instance Sorter is not an independent module** —
it is a field on the Proposer's output schema that the Verifier reads
and writes back into. Per design decision 2, **the Explain-Why prompt
uses the hybrid structure** (collect candidate properties, then ask for
predictions per property). Per design decision 4, **`why_hypotheses`
and `failed_attempts` do not merge** — the former drives predictions,
the latter is anti-hint memory; the Tracker writes both. Per design
decision 5, **the prediction schema is loose**: one sentence + status
∈ {pending, verified, falsified, cancelled}.

### D. Interaction: Capability 2 triggers Capability 1

The capability-2 analysis (this conversation) concluded that capability
2 is *the trigger* for capability 1. The mechanism:

```
WH-N predicts: on next instance, candidate_property P holds → conjecture C holds
Verifier runs next instance: actual outcome = C holds; but P does not
   ↓
Explain-Why prompt: verdict = REFUTED_AT_EXPLANATION
   ↓
Tracker: marks prediction.status = falsified; creates successor WH-(N+1)
   ↓
Tracker judge (hypothesis_tracker.md §C.1):
   IF actual_outcome == "pass" AND P fails AND failure has uniform axis
   THEN representation is too restrictive
   ↓
Tracker fires Rep Discoverer with input (current_rep_id, failure_mode)
   ↓
Discoverer returns ranked alternative reps
   ↓
Bridge searches literature in new rep's domain (if needed)
   ↓
Proposer re-emits with new rep_id and a fresh test_plan
```

**Two empirical instances** of this trigger in the existing OP-1 trace
(see `op1_detailed.md` §11.6):

1. **Instance 1** (Round 1 → Round 3 in real trace; folded in v2):
   universal-vertex form (rep_019) verified on S_{1,1} k≤3, then
   refuted on S_{1,2} k=2 (6 K_4-core CEs, conjecture C = "DL is
   dismantlable" still survived) → Tracker would have fired Rep
   Discoverer → returned rep_021 (dismantlable graph).

2. **Instance 2** (Round 4 → Round 6 in real trace; folded in v2):
   chordal-PEO form (rep_022) verified on S_{1,2} k≤3, then refuted on
   S_{1,2} k=4 (12 non-chordal CEs, conjecture C still survived) →
   Tracker would have fired Rep Discoverer → returned rep_024
   (Chepoi-Osajda W4+M).

In both instances the failure mode was "candidate_property fails but
conjecture survives," exactly the pattern the §C.1 judge keys on. This
is what the Part III counterfactual quantifies.

---

## Part III — OP-1 Counterfactual

What would OP-1 have looked like with v2 architecture in place from
Round 1?

### Real trace (v1, 6 rounds, ~ 6 hours)

| Round | Conjecture form | Outcome |
|---|---|---|
| 1 | universal vertex (rep_019) | DISPROVED — 6 K_4-core CEs |
| 2 | DL is contractible (rep_020 Betti) | numerically supported, no proof technique |
| 3 | DL is dismantlable (rep_021) | 378/378, geometric proof OPEN |
| 4 | DL is chordal (rep_022 PEO) | DISPROVED at k ≥ 4 (12 CEs) |
| 5 | iterative max-level dismantling (rep_023) | structural; Hypothesis B+ partial |
| 6 | (W4) + (M) Chepoi-Osajda (rep_024) | 318/318, geometric proof OPEN |

### Counterfactual trace (v2)

The v2 plan is a single sweep with 9 plan steps, driven by the Sorter's
lex-ordering on `(3g+n-3, k, expected_DL_size, max_clique)`:

| Step | Instance | Active WH | Verifier outcome | Tracker action |
|---|---|---|---|---|
| 1 | S_{1,1} k=1 | (seed) | pass | WH-1 created from seed prompt: "DL has universal vertex" |
| 2 | S_{1,1} k=2 | WH-1 | pass | WH-1 prediction CONFIRMED |
| 3 | S_{1,1} k=3 | WH-1 | pass | WH-1 CONFIRMED |
| 4 | S_{1,2} k=2 | WH-1 | mixed (58/64 pass, 6 K_4-core CEs without universal vertex) | WH-1 REFUTED_AT_EXPLANATION → successor WH-2 (chordality) |
| 5 | S_{1,2} k=3 | WH-2 | pass (63/63 chordal) | WH-2 CONFIRMED |
| 6 | S_{1,2} k=4 | WH-2 | mixed (54/54 dismantlable, 42/54 chordal, 12 CEs) | WH-2 REFUTED_AT_EXPLANATION → successor WH-3 ((W4)) |
| 7 | S_{1,2} k=5..8 | WH-3 | pass (271/271 cumulative on (W4)) | WH-3 CONFIRMED |
| 8 | S_{2,1} k=2..4 | WH-3 | pass (47/47) | WH-3 CONFIRMED → VERIFIED (terminal-good) |

### Round-by-round compression

| Real round | Counterfactual outcome | Notes |
|---|---|---|
| Round 1 (universal vertex) | absorbed into step 4's WH-1 refutation | Sorter does S_{1,1} first (where universal vertex actually holds) before reaching the refutation case at S_{1,2} k=2 |
| Round 2 (Betti) | **skipped** | Betti is verification, not explanation; absorbed as the verifier qualifier on rep_020 |
| Round 3 (dismantlable iterative) | folded into WH-2's lifecycle (chordality is the natural strengthening) | Same registry entry rep_021 is auto-loaded from seed |
| Round 4 (chordality DISPROVED) | **compressed to step 6's WH-2 refutation** | The strict-stronger anti-hint filter (architecture_report Q1) catches that chordality is strictly stronger than rep_021; refutation happens at k=4 inside the same plan |
| Round 5 (typology) | **absorbed into Diagnoser axis-uniformity at step 4 + step 6** | T1/T3/T5 typology becomes a `notes` patch on the falsified WHs, not a separate round |
| Round 6 ((W4) + (M)) | step 6's successor WH-3 + Bridge keyword match on "weakly modular" → Chepoi-Osajda | Bridge fires because Tracker judge identified rep_022 as "too restrictive" — the keyword query for an alternative finds the published 2014 result |

**Round count**: 6 conceptual rounds → 1 sweep with 8 plan steps and 3
active WHs. The geometric proof of (W4) remains OPEN as in the real
trace; v2 doesn't *prove* anything the human didn't, but it
*structures* the search so the (W4) hypothesis emerges 4 rounds earlier
in elapsed time (estimated step 6 vs round 6 = ~ 2 hours saved).

### Compression mechanisms

The 6 → 1 compression breaks down as:

1. **Strictly-stronger anti-hint** (skips a redundant round): chordality
   is filtered before being a Round, then is re-discovered at step 6
   only as a side-property to test, not as a separate hypothesis.
2. **WH lifecycle folding** (compresses 4 rounds into 3 WHs): each WH's
   lifecycle natively handles its own refutation + successor without
   needing a fresh round.
3. **Bridge auto-trigger** (eliminates the Round-5 → Round-6 latency):
   the Tracker fires Bridge on "rep too restrictive" verdicts, so
   Chepoi-Osajda is found in the same iteration as the chordality
   refutation, not 1+ rounds later.
4. **Sorter discipline** (eliminates premature large-case work): doing
   S_{1,1} first means rep_019 is *verified* on S_{1,1} before being
   *refuted* on S_{1,2}, which is what makes the WH-based analysis work.

This is **suggestive, not conclusive**: Round 1 still had to discover
Bestvina-Brady from scratch (Bridge has to start somewhere; the
registry is empty in counterfactual Round 1). The *refinement work*
between Rounds 1 and 6 — which is where the human trace spent most of
its time — is roughly halved.

---

## Part IV — Seed Data Statistics

`lean/LeanAgent/registry/representations/entries.jsonl` as of 2026-04-30:
**31 entries** drawn from:

| Source | Entries | IDs |
|---|---|---|
| Lean benchmark (#01–#13 across multiple reps) | 18 | rep_001 … rep_018 |
| OP-1 Rounds 1–6 + outer scaffold | 7 | rep_019 … rep_025 |
| Theorem 3 (4 reps + PEP + 2 disproved) | 6 | rep_026 … rep_031 |

### Status breakdown

| Status | Count |
|---|---|
| `validated` | 19 |
| `conjectural` | 7 (OP-1 Rounds 2/3/5/6 forms; Theorem 3 PEP-leftover; rep_009) |
| `disproved` | 5 (universal vertex, chordal, polynomial schedule, Cesàro+monotone, inline pnat match) |

### Verification qualifier breakdown (validated entries only)

| Qualifier | Count |
|---|---|
| `EXACT` (Lean axiom-clean OR exact-rational QQ) | 14 |
| `EXHAUSTIVE_ON_SAMPLE` | 3 |
| `NUMERICAL` | 2 |

### Transport graph

- **Total transport edges**: 47 across 31 entries.
- **Bidirectional edges**: 12.
- **Most-incoming-degree representation**: `rep_021_dismantlable_graph`
  (incoming from rep_020, rep_022, rep_023, rep_024 — central hub of
  the OP-1 transport graph).
- **Second hub**: `rep_002_descent_gradient` (incoming from rep_001,
  rep_003, rep_010 — central hub of the optimisation-rate transport
  graph).

### Domain distribution

| Domain | Count |
|---|---|
| `optimization` | 11 |
| `combinatorial_topology` | 7 |
| `meta` | 8 |
| `convex_analysis` | 3 |
| `geometric_topology` | 0 (deferred — no rep yet that's purely surface-level) |
| `learning_theory` / `statistics` / others | 0 (no problems yet) |

The thinness of `geometric_topology` is expected: most OP-1 entries
classify as `combinatorial_topology` because the verifier-level work is
graph-theoretic. A future entry for *Hatcher surgery* would belong in
`geometric_topology` proper.

---

## Part V — Implementation Roadmap

### Phase 1 — Schema + seed data + prompt templates (THIS PR)

| Item | Status | File |
|---|---|---|
| Registry schema | DONE | `lean/LeanAgent/registry/representations/SCHEMA.md` |
| Seed data (31 entries) | DONE | `lean/LeanAgent/registry/representations/entries.jsonl` |
| Architecture v2 doc | DONE (this file) | `workspace/reports/architecture/architecture_v2.md` |
| Instance Sorter spec | DONE | `workspace/agents_spec/instance_sorter.md` |
| Explain-Why prompt template | DONE | `workspace/agents_spec/explain_why_prompt.md` |
| Hypothesis Tracker spec | DONE | `workspace/agents_spec/hypothesis_tracker.md` |
| representation_retrospective spec | DONE | `workspace/agents_spec/representation_retrospective.md` |
| representation_retrospective prompt | DONE | `workspace/agents_spec/representation_retrospective_prompt.md` |

Phase-1 deliverable is purely declarative (schemas + prompts +
specifications); no executable code. Validates that the *design* is
internally consistent.

### Phase 2 — OP-1 replay validation

Goal: verify the counterfactual in Part III by *replaying* OP-1 with
the v2 modules, scoring each round against the actual trace.

Tasks:

1. Implement Instance Sorter (the `test_plan` field generator) — ~50
   LOC Python.
2. Implement the Hypothesis Tracker state machine — ~200 LOC Python.
3. Implement the Explain-Why prompt invocation glue — ~30 LOC.
4. Hand-write the input State for OP-1 Round 1 (matches `op1_detailed.md`
   prologue).
5. Run the v2 loop; check that:
   - WH-1, WH-2, WH-3 emerge in the order predicted in Part III.
   - The Sorter's plan produces the 8-step sequence in §III.
   - The Tracker fires Rep Discoverer at steps 4 and 6.
   - Bridge retrieves Chepoi-Osajda 2014 when called at step 6.
6. Score: number of rounds compressed; agreement between WH lifecycle
   and the real trace's failed_attempts.

Estimated effort: 2–3 days. Output: a workshop-paper-grade replay
artifact.

### Phase 3 — Live test on a new OP

Goal: drive a never-attempted OP through the full v2 loop,
end-to-end, with no human intervention beyond the initial problem
statement.

Candidate problems:

- **OP-3** (3-manifold topology): some open question in the
  spherogram / SnapPy reachable space.
- **OP-2 v6** (a deeper SHB question, e.g. closed-form C(β)).
- A fresh benchmark item beyond #13 (Layer-4 territory).

Tasks:

1. Operator chooses an OP and writes the input State.
2. v2 loop runs; logs every Sorter / WH / Tracker / Discoverer event.
3. Operator reviews the log; identifies any place where the loop's
   automation broke down vs. would have benefited from human input.
4. Iterate prompts / heuristics based on findings.

Estimated effort: 1–2 weeks per OP, depending on problem difficulty.

### Phase 4 — Capability 1 tool library (cut surface enumeration etc.)

Goal: expand the registry's `tools_required` coverage so that
representations gated on missing tools (`tools_status: partial / missing`)
become available.

Specific tools needed (from `architecture_v2.md` §4 in the prior
version + the seed registry):

1. **Cut-surface arc enumeration** (curver-based; ~200 LOC) — closes
   the (W4) verification on arbitrary Σ_{g,n} and turns rep_024 from
   "318/318 sample" into "positive existence via arc enumeration."
2. **π_1 word representation** (sympy + sage wrap; ~150 LOC) — adds a
   dual perspective for surface-curve manipulations.
3. **Composition primitives** (cut / project / quotient / lift /
   restrict / complement) as a small registry-side type library — long
   horizon; pay this cost when launching a new OP family.
4. **Exact rational SDP solver wrapper** — extends rep_028 to all of
   Theorem 3's β range; closes the Lean ingestion gap.

Estimated effort: each tool is 1–2 weeks; the composition-primitives
project is ~ 1 month.

### Phase ordering

Phase 1 is complete with this PR. Phase 2 is the next concrete step
(low cost, high signal). Phase 3 and Phase 4 run in parallel: Phase 3
validates the architecture on real problems while Phase 4 expands the
tool surface so that more representations become *available* rather
than just *recorded*.

---

## Part VI — Geometric Reasoning Engine (added 2026-04-30)

The v2 design through Part V handles *route choice* (registry tells the agent
which representation to be in) and *hypothesis lifecycle* (Tracker drives
predictions). What it does **not** handle is *spatial inference within a
representation* — taking a coarse rep (intersection-number table, edge-weight
tuple) and lifting it to a fine rep (arc pattern on a cut surface) where the
next operation is naturally expressible.

OP-1 §11.8 is the canonical example. The agent has 49/49 verified
`i(σ_α, β) = i(α, β)` from `direction_b_bigon_analysis.py`, but cannot
construct σ_α as an arc on the cut surface to *prove* the equality. The
Tracker correctly fires "rep too restrictive"; the Discoverer correctly
returns "use cut-surface arc enumeration"; but no executable engine
implements that.

### 6.1 The Reasoner Protocol

A `GeometricReasoner` is a domain-pluggable layer with five atomic
operations: **lift / project / locate / trace / cut_glue / recognize /
count_incidence** (with `lift / project` being the inverse pair binding the
remaining five). Full Protocol in
`workspace/agents_spec/geometric_reasoner.md` §A; per-domain implementation
sketches in §C.

The five ops correspond to the cross-domain decomposition of "spatial
imagination" identified in the analytical writeup that produced this
section. Every spatial-reasoning bottleneck the system has hit decomposes
into a sequence of these five.

### 6.2 First implementation — SurfaceGeo

`workspace/projects/op1_geometry/surface_geo.py` implements the Protocol for
the geometric_topology domain over `curver 0.5.1`. Atomic ops covered:

| Op | Implementation | Validation against |
|---|---|---|
| `lift` | Bonahon train-track decomposition: per-triangle passage counts | Reconstructs curver edge-weight tuple under `project` |
| `project` | sum-arc-contributions back to edge weights | round-trip with `lift` |
| `locate` | named-curve intersection profile + γ_0 level | `direction_b_*.py` constants |
| `trace` | per-arc cut-edge annotation on triangulation | (visual; consumed by explain-why prompt) |
| `cut_glue` | Hatcher surgery: train-track edit + database-search fallback | 12/12 non-chordal S_{1,2} canonical fillers |
| `recognize` | chordal / cone / k4_core / neither_chordal_nor_cone templates | `direction_b_cone_test.py` 383/389 split |
| `count_incidence` | enriched: integer + per-triangle locations | curver `c.intersection` ground truth |

**Status as of 2026-04-30**: **TESTED** — self-test passes 200/200 +
12/12 + 6/6 on all three validation buckets:
  - `count_incidence` : 200/200 sampled (α, β) pairs from
    `data_S_1_2.json` agree with curver exact intersection.
  - `cut_glue`        : 12/12 non-chordal S_{1,2} DLs (k = 4..8) reproduce
    the canonical universal σ_α (7/12 at level k − 2 — single-step
    Hatcher; 5/12 at strictly lower levels — multi-step, per §11.8.5(a)).
  - `recognize`       : 6/6 S_{2,1} k = 2 non-chordal-non-cone DLs are
    classified correctly.
Three new rep entries are now registered in
`lean/LeanAgent/registry/representations/entries.jsonl`: `rep_033_arc_pattern_cut_surface`
(validated), `rep_034_hatcher_surgery_output` (conjectural — pending the
proof_obligation), `rep_035_enriched_intersection_data` (validated).
Downstream Discoverer / explain-why dispatch through the engine is
unblocked.

### 6.3 Integration with the registry

Three minimal edits to existing specs (the engine itself is a new, additive
layer):

1. **`SCHEMA.md` §A** gains an optional `primitive` sub-object on each
   `transport_to` edge: `{engine, op, args_template}`. The Discoverer
   (SCHEMA §D) uses this to convert a returned rep candidate into an
   actual `(engine, op, kwargs)` call.
2. **`instance_sorter.md` §A** allows `verifier_command` to be a
   structured `{kind: "engine_call", engine, op, kwargs}` dict in addition
   to the existing CLI string. Backward-compatible.
3. **`explain_why_prompt.md` §A.0** allows `actual_evidence` to be a JSON
   object (e.g. an arc list, a `MatchResult` list) rather than a free-text
   string. The prompt template renders it as ASCII before showing to the
   LLM.

`hypothesis_tracker.md` requires no changes — it already treats
`actual_evidence` as opaque payload (§B.2 line 199).

### 6.4 Routing

Two strategies considered; **Strategy 2 (registry-driven)** chosen
(`geometric_reasoner.md` §E). The rep entry's `tools_required` field names
primitives like `["surface_geo.cut_glue", "surface_geo.trace"]`; an
`engine_inventory.json` maps these to `(engine, op)` tuples; the Discoverer
filters reps with unsatisfiable tools_required and ranks the rest. This
makes the engine layer a *pluggable extension* to the registry rather than
a parallel routing system.

### 6.5 OP-1 §11.8 unblocking — expected flow once SurfaceGeo is validated

```
Tracker flags "WH-N falsified at S_{1,2} k=4 chordal-or-cone rep"
   ↓
Discoverer ranks alternatives; top candidate is rep_NEW_arc_pattern
   with primitive = (SurfaceGeo, cut_glue,
                     args_template={obj: "$alpha", cut_spec:..., glue_spec:...})
   ↓
Orchestrator: SurfaceGeo.cut_glue(alpha, cut_spec={...}, glue_spec={...})
   → TransformedObject(result=σ_α, diff={homology_shift: (-2,0,0), ...},
                        proof_obligation="bigon cancellation total when i(α,β)≤1")
   ↓
Verifier writes structured actual_evidence into State.test_plan[step]
   ↓
Explain-why prompt receives:
   - the σ_α curve (curver lamination, for c.intersection ground truth)
   - the homology shift (auxiliary structural data)
   - the proof obligation (the LLM's task)
   - 49/49 i(σ_α, β) = i(α, β) from per-instance count_incidence
   ↓
LLM emits 1-page proof; if it back-translates to a Lean signature via
   the existing Aligner (architecture_report.md Q5 option 2), it goes
   through Stages 3–5 and lands as a CERTIFIED entry in registry/lemmas/
```

This is the v2 architecture's first end-to-end use of the Reasoner: the
Tracker's "rep too restrictive" fires the Discoverer; the Discoverer
returns a primitive call; the engine constructs the new geometric object;
the explain-why prompt produces a proof attempt; Lean verifies (or
identifies a finite-data sub-claim, per architecture_report Q5).

### 6.6 Phase 2 / Phase 3 roadmap

Phase 2 (3–6 weeks): validate SurfaceGeo against the OP-1 buckets;
register the three rep entries (`rep_NEW1_arc_pattern_S_{g,n}_cut_along_alpha_gamma0`,
`rep_NEW2_hatcher_surgery_output`, `rep_NEW3_enriched_intersection_data`)
in the registry; close OP-1 §11.8 stuck point.

Phase 3 (8–12 weeks): generalise to the other four domains.
`ThreeManifoldGeo` (SnapPy + Regina), `AlgebraicSurfaceGeo` (Sage),
`PolytopeGeo` (cdd / lrs), `OptimizationGeo` (cvxpy + scipy). Each is a
1–2 week wrapping job; the Protocol is the same.

Total cost to close OP-1: ~750 LOC (SurfaceGeo + dispatcher).
Total cost for the Phase-3 cross-domain story: ~3000 LOC over five engines.
The Protocol itself is small (~150 LOC). The cost is in the per-domain
wrappers, each of which is a 1–2 week project for someone familiar with
the underlying library.

### 6.7 What this section does NOT promise

- **Cross-engine planning** (a single proof needing SurfaceGeo *and*
  AlgebraicSurfaceGeo) is out of scope; would require a planner above the
  Reasoner.
- **Symbolic-numeric handoff certification**: when an engine returns
  approximate values (SnapPy's hyperbolic structure to 12 decimal places),
  the verifier still needs an exact check before any conclusion records as
  `EXACT` (SCHEMA §A.3). The Reasoner's outputs carry their own
  `verification_qualifier` for this.
- **Engine-internal optimization** (MCG-word search depth, normal-surface
  enumeration cutoffs): each engine owns its own performance profile;
  the Protocol exposes operations as opaque calls.

---

## Part VII — Tool Discovery Registry (added 2026-04-30)

The 6 channels through Part VI handle: truth (`lemmas/`, `pairs/`), tactic
recipes (`playbook/`), anti-recipes (`failures/`), route choice
(`representations/`), and spatial inference (Reasoner). What they do **not**
record is the *transferable mid-level moves* that an Explorer reapplies
across problems because "this looks like the time I did X" — a parity
argument, an aux-sequence synthesis pattern, an inline-API bypass, a
frontier-extrapolation move. Each is bigger than a tactic but smaller
than a representation, and reusable across domains.

`lean/LeanAgent/registry/discoveries/` is the 7th channel and the home for
these moves. Schema spec at `lean/LeanAgent/registry/discoveries/SCHEMA.md`;
seed data in `entries.jsonl` (9 entries as of 2026-04-30, harvested from
OP-1 r7, OP-2 r1-r4, OptLib2, and the master_discovery_report).

### 7.1 Channel role and difference from siblings

| Question | Channel |
|---|---|
| Has this exact statement been proved? | `lemmas/` |
| Does this NL match this Lean signature? | `pairs/` |
| Given this goal shape, what tactic closes it? | `playbook/` |
| Has this approach already STUCK? | `failures/` |
| Which form of the object should I be in? | `representations/` |
| Which spatial inference engine and op should I call? | (Reasoner Protocol, Part VI) |
| **Which transferable move should I try?** | **`discoveries/`** |

A discovery is a *verb*: "do an aux-sequence synthesis", "do a frontier
extrapolation", "do a Hatcher-surgery upgrade." A representation is a *noun*:
"the trajectory + auxiliary sequence form", "the Hatcher-surgery output."
Many discoveries have a sibling rep entry; this is correct — the rep
records the form, the discovery records the move that produces it.

### 7.2 Retrospective — sibling of `representation_retrospective`

`workspace/agents_spec/discovery_retrospective.md` specifies a new module
that runs in parallel with `representation_retrospective` after the
Auditor verdict. They share the input contract (run trace + State JSON
+ verifier evidence) and run in disjoint contexts. They emit to disjoint
registries. Outputs are concatenated, validated, and committed in a
single transaction.

The 10 triggers in `discoveries/SCHEMA.md` §E (D-NEW-MOVE, D-AUX-DEF,
D-API-BYPASS, D-EXTRAPOLATE, D-DICHOTOMY, D-AUGMENT, D-RIGOR-LIFT,
D-CROSS-DOM, D-ANTI-PROVE, D-PROMOTE) are sibling to the 7 triggers in
`representations/SCHEMA.md` §E.2 — they detect orthogonal patterns and
do not double-count.

### 7.3 Two-mode query interface

Symmetric with `representations/SCHEMA.md`:

- **Mode 1 — Architect proactive probe** (cheap, every problem). File-read
  + filter on `when_to_query` keywords + maturity gate. Returns 0-3
  discoveries to inject as pre-hints before the Explorer starts.
- **Mode 2 — Diagnoser stuck-query** (heavyweight, only on structural
  failure). LLM-driven match against `failure_modes` and `anti_patterns`.
  May return `anti_pattern_match: true` results that *push the Explorer
  off* a path rather than onto one.

The two-mode design mirrors the Architect / Diagnoser split (decision 7
in Part II): cheap pre-flight on every run, heavyweight rescue only on
non-tactic-shape failure.

### 7.4 Maturity lifecycle and promotion to playbook

```
seed ─► conjectural ─► validated_once ─► validated_multi ─► promoted_to_playbook
```

Promotion to `playbook` happens at the 3rd distinct-source instantiation;
the discoveries entry is NOT deleted on promotion (cross-domain transfer
is the discoveries channel's role even after a playbook entry exists).
The lifecycle is enforced by `lean/LeanAgent/scripts/validate_discoveries.py`.

### 7.5 Files in this addendum

| Path | Purpose |
|---|---|
| `lean/LeanAgent/registry/discoveries/SCHEMA.md` | 7th-channel schema, query interfaces, 10 triggers, lifecycle |
| `lean/LeanAgent/registry/discoveries/entries.jsonl` | 9 seed entries (4 geometric_topology, 4 optimization, 1 lean-formalization-flavored) |
| `workspace/agents_spec/discovery_retrospective.md` | Module spec; sibling of representation_retrospective |
| `workspace/agents_spec/discovery_retrospective_prompt.md` | LLM prompt template for the retrospective |
| `lean/LeanAgent/scripts/validate_discoveries.py` | Schema + referential-integrity + acyclicity + uniqueness validator |
| (modified) `lean/LeanAgent/registry/representations/SCHEMA.md` §E.2 | Cross-link to sibling discovery channel |
| (modified) `lean/LeanAgent/registry/representations/entries.jsonl` | rep_034's `notes` adds `back_references_to_discoveries: ["disc_001"]` |

---

## Part IX — Obstacle-Driven Tool Discovery (added 2026-05-01)

The system through Part VIII handles two recovery dispatchers under the Diagnoser: Rep Discoverer (route choice — "switch the noun") and the legacy Bridge (literature lookup gated on a rep switch already having been decided). Neither covers the case where the conjecture is correct, the representation is correct, but the *proof technique itself* is too weak — the bound is loose, the certificate search blows up, the inequality is in the wrong direction, the independence assumption breaks under adaptivity. This is the "method wall" rather than the "noun wall."

Part IX introduces **Tool Discoverer** as a third dispatcher under the Diagnoser, parallel to Rep Discoverer and keyed on a structured `obstruction_class` field rather than on a free-text failure_mode string.

### 9.1 Three-way symmetry

```
representations/  ←── Rep Discoverer (read)  ←── Diagnoser ternary judge ──── Tool Discoverer (read) ──→ discoveries/
                  ←── representation_retrospective §K (write)                  ←── (Phase-2) discovery_retrospective T-DISC-SYNTH (write)
                  
nouns: forms of the object                                                     verbs: transferable mid-level moves
keyed on: failure_mode (NL string)                                             keyed on: obstruction_class (controlled vocab, 8 values)
```

The dispatch is fed by an `obstacle` field on the Explain-Why prompt's output (`workspace/agents_spec/explain_why_prompt.md §A.4`); the Tracker validates and forwards it through the §C.2 ternary judge to whichever Discoverer (or both) applies.

### 9.2 Trigger conditions (full table at `workspace/agents_spec/tool_discoverer.md §B`)

| Trigger | Condition | Frequency |
|---|---|---|
| `ternary_judge` | Diagnoser concludes `technique_insufficient`: actual_outcome ≠ fail, candidate_property holds (or is irrelevant), failure is in executing the proof step | Primary |
| `wh_chain_stagnation` | WH chain length ≥ 4 AND last 2 WHs share `rep_id_at_creation` (thrashing within a rep) | Secondary |
| `operator_override` | `completion_status == inconclusive_open` and operator wants a deeper rescue than Bridge | Tertiary |

### 9.3 The obstruction taxonomy (full catalog at `workspace/agents_spec/obstruction_catalog.md §A`)

Eight controlled-vocab classes:

| Class | Rescue keywords |
|---|---|
| `combinatorial_blowup` | probabilistic method, expectation bound, LP relaxation, generating function |
| `loose_inequality` | polarisation, AM-GM tightening, Schur complement, interpolation |
| `wrong_direction` | duality, conjugate, complementary slackness, minimax |
| `missing_lower_bound` | Le Cam two-point, Fano, Yao's principle |
| `non_constructive_witness` | algorithmic constructivisation, derandomisation, explicit construction |
| `coupling_breaks` | KL chain rule, sequential conditioning, Doob martingale |
| `regularity_loss` | mollification, Yosida-Moreau, smoothed dual |
| `intractable_certificate` | SDP/LMI, Positivstellensatz, sum-of-squares, PEP |

`discoveries/SCHEMA.md §A.defuses_obstruction[]` indexes each discovery by the classes it defuses; the Mode-3 query (§C of the same file) returns matches by file-read filter.

### 9.4 Erdős-Selfridge retroactive trace

This is what the v2-with-Part-IX flow produces on the canonical "tool wall" example: the iterative inclusion-exclusion attack on Erdős-Selfridge's covering-system theorem.

| Stage | Output |
|---|---|
| Verifier | step k=4 times out: max_union enumeration over `∏ p_i / lcm` residue tuples ≥ 10⁴ |
| Explain-Why | verdict=`FALSIFIED` (verifier could not run); `obstacle.obstruction_class = combinatorial_blowup`; `mathematical_property_needed = "bound max-union of arithmetic progressions without enumerating all residue tuples"` |
| Tracker §C.2 | ternary judge → `technique_insufficient`; fires Tool Discoverer |
| Tool Discoverer Mode-3 | `defuses_obstruction contains combinatorial_blowup` → only disc_003 matches (cross-domain weak hit); fit_score 0.6, prerequisites_met=false |
| Catalog fallback | `suggested_query = "<NL property> -- keywords: probabilistic method, expectation bound, LP relaxation, generating function"` |
| Phase-1 outcome | closing summary `open_items` carries the obstruction_summary forward; agent honestly reports "technique gap, query staged for Phase-2 Bridge" |
| Phase-2 outcome (planned) | Bridge fetches paper(s) on probabilistic method for covering systems; T-DISC-SYNTH writes a seed-maturity discovery; next round attempts the technique |

The honest framing: Phase-1 makes the obstacle visible, named, and queryable, but does not auto-resolve. That is the precondition for Phase-2 to close the loop.

### 9.5 Phase-2 / Phase-3 roadmap

Detailed in `workspace/agents_spec/tool_discoverer.md §K`. Summary:

- **Phase-2** (~2–4 weeks of code): Bridge sub-call (~150 LOC) + T-DISC-SYNTH trigger in `discovery_retrospective` (~80 LOC) + applicability probe (~120 LOC). Closes the synthesis loop end-to-end.
- **Phase-3** (~1–2 months): promote `obstruction_catalog.md` from a hand-curated markdown table to an 8th registry channel with auto-extension under operator approval; cross-channel transitive ranking between Rep and Tool Discoverers.

### 9.6 What Part IX does NOT promise

- Does not invent new mathematics. Tool Discoverer surfaces patterns that have been seen before (this codebase or the literature).
- Does not auto-translate cross-domain hits. Low-fit cross-domain candidates are reported but the Proposer / human decides whether to attempt translation.
- Does not write to `discoveries/` in Phase-1. T-DISC-SYNTH is schema-declared but not implemented; Tool Discoverer is read-only.
- Does not change the existing Bridge. Bridge stays at 1-line spec until Phase-2.

---

## Files in this PR

| Path | Purpose |
|---|---|
| `lean/LeanAgent/registry/representations/SCHEMA.md` | 6th-channel schema, query interfaces, write triggers |
| `lean/LeanAgent/registry/representations/entries.jsonl` | 31 seed entries from Lean / OP-1 / OP-2 / OptLib2 |
| `workspace/reports/architecture/architecture_v2.md` | this file |
| `workspace/agents_spec/instance_sorter.md` | `test_plan` field on Proposer output; complexity ordering rules per domain |
| `workspace/agents_spec/explain_why_prompt.md` | seed prompt + stress-test prompt template; OP-1 + Theorem 3 worked examples |
| `workspace/agents_spec/hypothesis_tracker.md` | State schema extension; WH lifecycle state machine; OP-1 complete WH trace |
| `workspace/agents_spec/geometric_reasoner.md` | (added 2026-04-30) GeometricReasoner Protocol spec; per-domain sketches; integration with SCHEMA |
| `workspace/projects/op1_geometry/surface_geo.py` | (added 2026-04-30) SurfaceGeo first implementation; UNTESTED until WSL self-test passes |
| `workspace/agents_spec/tool_discoverer.md` | (added 2026-05-01, Phase-1) Tool Discoverer module spec; sibling of Rep Discoverer; obstruction-keyed Mode-3 query; Erdős-Selfridge worked example |
| `workspace/agents_spec/obstruction_catalog.md` | (added 2026-05-01, Phase-1) controlled-vocab catalog of 8 obstruction classes + search keywords + historical examples |
| (modified) `workspace/agents_spec/explain_why_prompt.md` §A.4 | obstacle field added to JSON output schema |
| (modified) `workspace/agents_spec/hypothesis_tracker.md` §A / §B.3 / §C.2 | obstacle field on WH and failed_attempts; Diagnoser ternary judge |
| (modified) `lean/LeanAgent/registry/discoveries/SCHEMA.md` §A / §C / §E | defuses_obstruction[] field; Mode-3 query; T-DISC-SYNTH trigger (Phase-2 schema-only) |
| (modified) `lean/LeanAgent/registry/discoveries/entries.jsonl` | defuses_obstruction[] backfilled on disc_001..disc_009 |

No existing files were broken. The architecture_report.md (v1) and the
4 existing registry channels remain authoritative for the system as run today.

---

## Part X — Strategy Search + Scope Judgment (added Gap-1/2/3)

Three closing-the-loop modules sit between Diagnoser and the next-round Proposer:

```
                 Verifier reports failure
                          │
                          ▼
       ┌────────────  has_prior_passes(state) ?  ────────────┐
       │ yes                                              no │
       ▼                                                     ▼
  SCOPE JUDGE  (Gap 3)                                 Diagnoser
       │                                                     │
       ├── verdict=scope_limitation + workaround → continue with caveat
       ├── verdict=scope_limitation, no workaround → completion=inconclusive_open
       ├── verdict=falsification                  ──┐
       └── verdict=uncertain                       │
                ↓ (HUMAN_REVIEW_NEEDED)            │
                                                   ▼
                                            Diagnoser → ternary judge
                                                   │
                ┌──────────────────────────────────┼──────────────────────────────┐
                ▼                                  ▼                              ▼
          STRATEGY PROPOSER                 BRIDGE TRIGGERS                    Discoverers
            (Gap 1)                           (Gap 2)                  (Rep / Tool, existing)
                │                                │
                ├─ generate_candidates (LLM)     ├─ priority 1: Strategy Proposer queries
                ├─ probe_candidates (N×scout)    ├─ priority 2: Diagnoser direct (when pattern present)
                ├─ rank_candidates               └─ priority 3: Tool Discoverer fallback
                ▼                                       │
        recommended top-1                                ▼
                                          run_bridge_with_triggers (one call)
                                                         │
                                                         ▼
                                                 BridgeResult feeds candidate rationales
```

### 10.1 Gap 1 — Strategy Proposer

`workspace/agents_spec/strategy_proposer.md` + `lean/LeanAgent/LeanAgent/Agent/Scout/strategy_proposer.py`. Five candidate types: `weaken_property`, `split_cases`, `change_representation`, `generalize_from_evidence`, `bridge_to_literature`. Each candidate is probed via `scout_one()`, ranked by (probe pass, difficulty rank, tractability), demoted if duplicate of `failed_attempts`. Top-1 is `recommended_id`.

### 10.2 Gap 2 — Bridge trigger expansion

`workspace/agents_spec/tool_discoverer.md §H.2` + `workspace/agents_spec/hypothesis_tracker.md §C.2.1`. Bridge now has three trigger paths in priority order: Strategy Proposer (1), Diagnoser direct via `extract_bridge_trigger()` (2), Tool Discoverer fallback (3). New module surface: `Scout/diagnoser.py:BridgeTrigger`, `extract_bridge_trigger`, `select_highest_priority_trigger`; `Bridge/literature_search.py:run_bridge_with_triggers`.

### 10.3 Gap 3 — Scope Judge

`workspace/agents_spec/scope_judge.md` + `lean/LeanAgent/LeanAgent/Agent/Scout/scope_judge.py`. Triggers when Verifier returns `fail` AND the same conjecture has prior passes. Four signals (parameter boundary, structural consistency, failure severity, proof-dependency workaround) feed a `scope_score`; the score routes through three bands: high (≥0.7) → `scope_limitation`, low (≤0.3) → `falsification`, middle → LLM tiebreak. Verdict updates `completion_status` per §F mapping; `uncertain` or low-confidence routes to `[HUMAN_REVIEW_NEEDED]`.

### 10.4 Integration locus

`lean/LeanAgent/LeanAgent/Agent/DeepDive/strategy_integration.py` is the single composition function `deep_dive_with_strategy()` that wires the three modules into the Deep Dive flow. The existing `Scout/orchestrator.py:scout_one` is unchanged — Scout Mode is shallow-only and these modules belong to deep-dive.

### 10.5 What Part X does NOT promise

- The Strategy Proposer's candidates may include directions the operator finds objectionable; the operator is the final arbiter on `recommended_id`.
- Scope Judge is heuristic; the four-signal weights are tuned against OP-1 retroactive replay only. Other domains may need re-tuning.
- Bridge sub-call from Diagnoser direct trigger uses synthesised queries — papers found may be only weakly related; the priority-2 path is a fast triage, not a substitute for Strategy Proposer's vetted queries.
