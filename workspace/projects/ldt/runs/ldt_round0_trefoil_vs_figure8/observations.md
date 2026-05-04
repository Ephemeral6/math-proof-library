# Observations — Round 0 LDT Pipeline (Trefoil vs Figure-Eight)

**Date**: 2026-04-20
**Problem**: `workspace/active/ldt_round0_trefoil_vs_figure8/problem.md`
**Pipeline**: Scout → Explorer×3 → Judge → Auditor (no Fixer needed)
**Verdict**: PASS with reservations

## Phase-by-phase data points

### Phase 1 — Scout

| Metric | Value |
|--------|-------|
| Library hits (LDT directory) | **0** (empty directory, only README stubs) |
| Technique-dictionary hits | **3/10** entries mapped (§1.1 skein, §1.2 state-sum, §1.3 Burau) |
| Failure-pattern hits | **0** (no LDT entries yet in failure DB) |
| Routes proposed | **4** (Jones, Alexander, hyperbolic volume, Reidemeister-direct) |
| Routes recommended for Explorer | **3** (Reidemeister-direct excluded) |
| Time-to-scout-completion | short (single pass; no iterative searches needed) |

**Observation**: Scout had essentially nothing to reuse. The technique dictionary gave names of approaches but no B/C-class lemmas to plug in. Scout proposed routes *and* flagged Route 3 as "most geometric" — the collaborator criterion was explicit on Scout's radar.

### Phase 2 — Explorer×3 (parallel)

| Route | Output lines | TSV calls | Stuck-points | Geom-int self-score |
|-------|-------------|-----------|--------------|---------------------|
| 1 Jones | 72 | 4 (all high-conf) | 1 sign-convention stumble, auto-recovered | 2/5 |
| 2 Alexander | 92 | 3 (all high-conf) | **1 unresolved: `[STEP-STUCK: normalization]`** | 1/5 |
| 3 Hyperbolic | 50 | 2 (one returns None-by-design) | 0 computational stuck-points; 3 black-box [REF:external] | 5/5 |

**Observation**: Route 2 had a genuine computational stuck-point that TSV rescued. Route 3 was short but leaned heavily on uncited machinery. Route 1 was self-contained but algebraic.

### Phase 3 — Judge

| Axis (1–5) | Route 1 | Route 2 | Route 3 |
|------------|---------|---------|---------|
| Correctness | 5 | 4 | 5 |
| Completeness | 4 | 2 | 3 |
| Elegance | 5 | 3 | 5 |
| Verifiability | 5 | 5 | 4 |
| **Subtotal (V2)** | **19/20** | 14/20 | 17/20 |
| Geometric intuition | 2/5 | 1/5 | **5/5** |

Winner: **Route 1** on V2 rubric. Trade-off flagged: collaborator criterion would flip winner to Route 3.

### Phase 4 — Auditor

| Checklist item | Triggered? | Verdict |
|----------------|------------|---------|
| V2 standard audit | Yes | PASS |
| V2 Step 0.5 reverse-consistency | Yes | PASS (polynomial comparison is symmetric) |
| LDT-A (isotopy vs equivalence) | Yes | PASS |
| LDT-B (orientation) | Yes | PASS |
| LDT-C (3d vs 4d) | No (not applicable) | — |
| LDT-D (compactness/infinitude) | No (not applicable) | — |
| LDT-E (group-presentation) | Yes | PASS |
| LDT-F (literature cross-check of constants) | Yes | PASS (3/3 constants match KnotInfo) |
| LDT-G (picture-proof) | No (Route 1 has no pictures) | — |
| LDT-H (geometric-intuition score) | Yes | 2/5 (documented, not blocker) |
| Flags raised | 2 ([FLAG-1] sign convention, [FLAG-2] TSV-only resolution) | resolved |

**Observation**: Only 5 of 8 LDT checklist items fired on the winning route. Items C, D, G were not applicable to a Jones-polynomial proof of a 3d knot problem. This is expected for this problem but may mean the checklist is somewhat over-specified for purely-algebraic proofs.

### Phase 5 — Fixer

**Not invoked.** Auditor returned PASS with flags-already-resolved. No round-trip to Fixer needed. This is unusually clean for a Round 0 failure experiment — suggests the problem was perhaps *too* textbook to stress-test the pipeline.

## Hypothesis outcomes (from v2.1 extension doc)

| # | Hypothesis | Outcome |
|---|-----------|---------|
| H1 | TSV-Knot closes knot-invariant arguments | **CONFIRMED** (4/4 high-confidence TSV calls) |
| H2 | Technique dict too thin to steer Scout | **PARTIALLY CONFIRMED** (3 entries helped; none scored against collaborator criterion) |
| H3 | Library-empty = zero hits, minor cost | **CONFIRMED** (negligible overhead) |
| H4 | LDT checklist fires on A, B, G, H | **PARTIALLY CONFIRMED** (A, B, H fired; G did not because winner was algebraic) |
| H5 | Sign conventions will surface as errors | **CONFIRMED** ([FLAG-1]) |
| H6 | Picture-proof detection will matter | **DEFERRED** (would have fired on Route 3 but Route 3 lost at Judge) |

## Anomalies / surprises

1. **The pipeline PASSED on a "gap discovery" instrument.** Expected more friction. Two readings: (a) the trefoil/figure-eight problem is just too well-worn to expose gaps; (b) the LDT extension worked better than its designer feared on algebraic routes.

2. **TSV-Knot did heavy lifting at Alexander Step 3.** Without `tsv-knot alexander_polynomial("figure-eight")`, Route 2 would have been unresolvable. The Burau calculation did not close cleanly. This is a *dependency* finding: TSV is not just a verifier, it's a **computational safety-net** for when the Explorer's derivation stalls.

3. **Sign-convention pivot at Jones Step 3 was elegant.** Explorer detected the bug (mirror polynomial), flagged it, applied Lickorish convention, and moved on — without needing Fixer intervention. This suggests Explorer self-correction on convention issues is already working.

4. **Route 3's geometric-intuition score (5/5) is exactly what the collaborator wants, but it didn't win.** The V2 rubric weights correctness/completeness/elegance/verifiability equally, and Route 3 lost on Completeness (black-box citations). This is a **scaffolding question**: should LDT give geometric-intuition more Judge-weight?

5. **Only the WINNING route goes through the checklist.** Items C/D/G/H that would have been interesting on Routes 2 or 3 were not tested. Auditor's checklist is applied after Judge filters, so checklist coverage depends on Judge's picks.

## Data for Gap Report

Key pieces of evidence to surface into `workspace/ldt_round0_gap_report.md`:

- Anomaly #1: pipeline may need a harder problem to stress-test.
- Anomaly #2: TSV doubles as fallback computer (currently undocumented usage).
- Anomaly #4: Judge rubric doesn't weight collaborator criterion.
- Anomaly #5: checklist only sees winners — items may never fire on algebraic winners.
- Stuck-point: Burau normalization for $B_3$ is tricky; library-entry "Alexander polynomial of $4_1$ via Burau" is a good candidate for the library to close this gap.
- Library additions generated: "Jones polynomial of $3_1$", "Jones polynomial of $4_1$", "Kauffman bracket axioms-as-skein-relation" (all [LIBRARY-CANDIDATE] tagged in Explorer 1).
- Failure patterns to seed: "Burau normalization for B_n, n ≥ 3, requires explicit convention choice"; "Kauffman-bracket writhe substitution produces mirror polynomial under default sign convention".
