# V2.3 Upgrade & Regression-Test Summary

**Date**: 2026-04-21
**Scope**: Stage 1 (5 prompt-level upgrades) + Stage 2
(Theorem 4.4 regression test).

---

## Stage 1 — Five upgrades

| ID | Upgrade | Prompt files touched | Sanity check |
|----|---------|----------------------|--------------|
| U1 | Dynamic Fixer round limit with progress ledger | `auditor.md`, `auditor_update.md` (F4 gate) | `v23_upgrade_1_sanity.md` PASS |
| U2 | Sub-pipeline recursion via `[SUB-PROBLEM:...]` | `explorer.md`, `orchestrator_update.md`, `auditor.md` (admissibility) | `v23_upgrade_2_sanity.md` PASS |
| U3 | Cross-pollination at Judge via `[REUSABLE-FRAGMENT:...]` | `judge.md`, `judge_ldt.md` | `v23_upgrade_3_sanity.md` PASS |
| U4 | Level-1 library + `[REF:level1:...]` tag | NEW `level1_library_protocol.md`; patches in `scout.md`, `math-auditor/ldt_checklist.md`, `integrator.md` | `v23_upgrade_4_sanity.md` PASS |
| U5 | SP severity × type refactor (ROUTINE/STRUCTURAL/STRATEGIC + FIXER-REFUSED) | `math-auditor/ldt_checklist.md`, `fixer.md` (implicit via Auditor) | `v23_upgrade_5_sanity.md` PASS |

**Backup**: all modified prompt files mirrored to
`workspace/architecture_backups/v2.2/` before edits.

**Sanity-check discipline**: 5/5 PASS, but 2 of the 5 caught real
issues in the drafts before sign-off:
- U1 sanity check surfaced a sign-convention ambiguity in the
  Net-delta formula (positive = regress vs positive = progress);
  the draft had both readings in different paragraphs. Resolved:
  positive = regress.
- U3 sanity check surfaced a missing fragment status type
  (`verified-as-counterexample`) that was not in the initial
  vocabulary; added after the Explorer 1 library-insufficiency
  fragment needed it.

These catches are the evidence that the sanity-check layer is
active review, not rubber-stamping.

---

## Stage 2 — Theorem 4.4 regression test

**Pipeline verdict**: PARTIAL-with-STRATEGIC-SP.

**What closed**:
- Backward direction (torus ⇒ ∃ swap).
- Forward uniform-ε sub-case (via Route 1 Case A, captured as
  fragment-1).
- Forward asymmetric-case elimination (via Route 2 Step 1 genus
  dichotomy, captured as fragment-3).

**What remained open**:
- Forward mixed-mixed sub-case (both routes STRATEGIC-stuck at
  missing Blackwell §4 Lemma 4.1 / 4.2).

**Fragments preserved for future re-attempt**: 3 (2 verified, 1
unverified, 1 verified-as-counterexample — total 4 across the 2
losing-route pools, of which 3 were appended to best_proof.md).

**Failure pattern recorded**:
`FP-SPIRAL-PARAMSWAP-MIXED-CASE-LEVEL1-GAP-2026-04-21` in
`workspace/failure_patterns.md`.

Full per-upgrade + O1–O5 observations:
`workspace/diag/theorem_4_4_v23_test_log.md`.

---

## Delta from V2.2 baseline

| Dimension | V2.2 behavior | V2.3 behavior |
|-----------|---------------|---------------|
| Multiple Fixer rounds | Counted, no ledger | Progress ledger with Net-delta (U1) |
| Ambiguous Fixer failure | "Fixer couldn't close" | Explicit FIXER-REFUSED-CONFIRMED vs FIXER-STALLED vs FIXER-PROGRESS (U1+U5) |
| Sub-problem recursion | None | Explicit [SUB-PROBLEM:...] marker with admissibility self-check (U2) |
| Losing-route outputs | Discarded | Up to 3 [REUSABLE-FRAGMENT:...] per route preserved by Judge (U3) |
| Paper-chained citations | Bare L2 or L3 | Per-workdir `level1_lemmas/` with explicit status + citation tag (U4) |
| SP taxonomy | Severity only | Severity × type with Fixer dispatch rules (U5) |
| Pipeline on missing-machinery theorem | Could hallucinate closure | Surfaces the gap as typed SP (U4 + U5) |
| Honest-failure rails | Step 0.5, REJECT_ALL, STRUCTURAL-CITATION-WARNING (carryover) | All carry forward + new fragment & level1 mechanisms |

---

## Honest assessment: capability increase vs. rearrangement?

**Genuine capability gains (NEW)**:
- **U2** adds a recursion axis that V2.2 had no equivalent of. An
  Explorer that hits a stuck-point can now delegate a strictly-
  smaller sub-problem to a bounded sub-pipeline. Not exercised
  end-to-end in Stage 2 (all candidates were electively not
  emitted), but the admissibility check prevented a
  non-admissible sub-problem from reaching the Auditor — a real
  new guard.
- **U3** adds a mechanism to preserve reusable pieces from
  non-winning routes. V2.2 dropped losing routes entirely. In
  Stage 2 this produced 3 fragments with concrete downstream
  utility (uniform-arm handler, asymmetric-elimination, Seifert-
  matrix dimension hook). `status=verified-as-counterexample` is
  a genuinely new output type — it tells the orchestrator which
  lemma is missing, not just that the route didn't close.
- **U4** adds per-workdir paper-chained lemma infrastructure. V2.2
  had no structured way to distinguish "the paper's Theorem 3.5
  which we're citing as assumed-valid" from a generic L2 textbook
  citation. The level1 library + status tags + STRUCTURAL-
  CITATION-WARNING exemption is real new plumbing. Stage 2
  depends on it: the gap identification ("Blackwell §4 Lemma 4.1
  is missing") is only sharp because we know exactly which 3
  lemmas ARE registered and can name the gap.

**Partially rearrangement (MORE EXPLICIT, not strictly more
capable)**:
- **U1** formalizes what V2.2 Fixer rounds already did implicitly.
  The ledger makes the progress measurable but does not let the
  pipeline prove things it could not prove before. The value is
  in termination clarity: FIXER-REFUSED-CONFIRMED vs
  FIXER-STALLED is a meaningful distinction that V2.2 blurred.
- **U5** formalizes what V2.2 Auditor already did implicitly when
  classifying SP severity. V2.2 Fixers already refused
  strategic-feeling SPs in practice; U5 makes the refusal
  categorical and orchestrator-visible. The rearrangement has
  real downstream value (cleaner orchestrator decision points)
  but is not a new proof capability per se.

**Overall verdict**:
V2.3 = V2.2 + ~3 genuine capability axes (U2, U3, U4) + 2
explicitness upgrades (U1, U5) that produce cleaner orchestrator
state. The pipeline can now:
1. Recurse on smaller sub-problems (U2).
2. Preserve and reuse fragments across the Judge boundary (U3).
3. Name and exempt paper-chained lemmas (U4).

And it communicates more precisely when it can't close a proof
(U1, U5).

The Stage 2 test deliberately stressed a theorem where closure
was structurally impossible with the registered library. The
PARTIAL verdict with typed SPs and preserved fragments is exactly
the behavior the upgrades targeted.

---

## Residual unexercised surfaces

- U1's multi-round Net-delta arithmetic never fired (only 1 round
  happened in Stage 2).
- U2's sub-pipeline execution never fired (all candidates were
  electively not emitted).
- U5's STRUCTURAL-dispatch branch (Fixer attempts patch) never
  fired (all HIGH SPs were STRATEGIC).

A complete exercise of V2.3's dispatch surfaces requires a
theorem with a mix of SP types and at least one structurally-
closable-with-present-library route — i.e., a theorem that lands
between "trivial" (V2.2 would close) and "strategic-impossible"
(V2.3 Stage 2's choice).

---

## Next-action candidates (2–3, ranked)

### (A) Populate additional level1 lemmas from Blackwell §4 and re-attempt Theorem 4.4
- **What**: Read Blackwell et al.'s §4, identify Lemma 4.1 and
  Lemma 4.2 (or whichever §4 results support the mixed-ε
  classification), register each in `level1_lemmas/` as
  UNPROVEN-HERE → L2, re-run the V2.3 pipeline on Theorem 4.4.
- **Expected outcome**: one of Routes 1 or 2 closes Case B in a
  single additional pipeline run.
- **Cost**: moderate (read + register + one pipeline run).
- **Value**: high — completes the Stage 2 test AND exercises U4's
  dynamic population loop (which U4's protocol explicitly
  anticipates as the "iterate level1 then re-attempt" workflow).

### (B) Construct a theorem designed to exercise U1 + U2 + U5 STRUCTURAL simultaneously
- **What**: Pick a theorem with (i) at least one STRUCTURAL SP
  that a well-chosen sub-problem can close, AND (ii) at least
  one ROUTINE SP that the Fixer should patch in 1–2 rounds.
  Candidates: `FP-SHB-Bias` meta-lesson's option (a)
  (weakened ∀β ∃f_β cycling construction) could fit — it has
  provable sub-pieces (per-β Goujaud), a measurable Fixer
  progress axis, and routine constant tracing.
- **Expected outcome**: pipeline runs a full multi-round Fixer
  loop and dispatches at least one genuine sub-pipeline.
- **Cost**: high — requires problem-statement engineering.
- **Value**: medium-high — fills the residual-unexercised gap.

### (C) Stress-test U3 cross-pollination on a 3-way losing-route case
- **What**: Pick a theorem where 3 Explorer routes all produce
  PARTIAL results with disjoint reusable pieces. Verify Judge
  correctly extracts up to 3 × 3 = 9 fragments (subject to cap),
  and that the winner's best_proof.md picks up the right subset.
- **Cost**: low — most LDT-adjacent research theorems produce
  multi-PARTIAL fan-outs naturally.
- **Value**: medium — probes the fragment extraction + cap
  arithmetic, but U3 already ran successfully in Stage 2.

**Recommended**: (A) next. It has the highest ratio of
"completes a known unfinished test" × "exercises U4's dynamic
population loop". (B) as a follow-on.

---

## Files emitted in this upgrade cycle

- Prompt edits: `judge_ldt.md`, `judge.md`,
  `level1_library_protocol.md` (new), `scout.md`,
  `math-auditor/ldt_checklist.md`, `integrator.md`,
  plus U1 auditor.md patches (Stage 1 earlier).
- Backups: `workspace/architecture_backups/v2.2/*`.
- Sanity checks: `workspace/diag/v23_upgrade_{1,2,3,4,5}_sanity.md`.
- Stage 1 checkpoint: `workspace/ldt_extension_log.md` (appended
  entry).
- Stage 2 working dir: `workspace/active/ldt_theorem_4_4/`
  (problem.md, level1_lemmas/, scout.md, explorer_1_route_1.md,
  explorer_2_route_2.md, judge.md, best_proof.md,
  alternative_route.md, auditor_round1.md, fixer_round1.md,
  orchestrator_decision.md).
- Stage 2 log: `workspace/diag/theorem_4_4_v23_test_log.md`.
- Failure pattern: new entry in `workspace/failure_patterns.md`.
- This summary: `workspace/diag/v23_upgrade_and_test_summary.md`.
