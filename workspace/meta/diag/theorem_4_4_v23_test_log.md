# V2.3 Stage 2 — Theorem 4.4 pipeline observation log

**Date**: 2026-04-21
**Target**: Blackwell et al. arXiv:2506.17889 Theorem 4.4
**Pipeline verdict**: PARTIAL-with-STRATEGIC-SP (accepted via
orchestrator option (c))

---

## Pipeline trace

| Stage | Artifact | Outcome |
|-------|----------|---------|
| Scout | scout.md | 3 routes identified; 0b-level1 scan populated |
| Explorer 1 (Route 1) | explorer_1_route_1.md | PARTIAL (Case A closed, Case B STRATEGIC) |
| Explorer 2 (Route 2) | explorer_2_route_2.md | PARTIAL (asymmetric killed, uniform closed, mixed STRATEGIC) |
| Judge | judge.md | Route 2 winner 31.5/55 (Axis 5 = 5); Route 1 second 29.5/55; both PARTIAL; 3 fragments extracted |
| Auditor R1 | auditor_round1.md | PARTIAL; 2 HIGH/STRATEGIC + 1 LOW/ROUTINE; L3=0 |
| Fixer R1 | fixer_round1.md | FIXER-REFUSED-CONFIRMED (both HIGH SPs are STRATEGIC) |
| Orchestrator | orchestrator_decision.md | Option (c): accept PARTIAL; record failure pattern |
| Integrator | — | SKIPPED (PARTIAL verdict) |

---

## Per-upgrade observations

### U1 — Dynamic Fixer round limit with progress ledger

**Artifact**: `fixer_round1.md` §Progress ledger.

**Triggered?** Partially. Only Fixer Round 1 was run. The F4 gate
outcome was FIXER-REFUSED-CONFIRMED (categorical-by-type), so the
ledger baseline was computed but the Net-delta iteration rule was
not exercised across rounds.

**What the ledger recorded**:
- Baseline: 2 HIGH/STRATEGIC SPs entering Round 1.
- Round 1: 0 closed, 0 introduced.
- Net delta: 0 (no progress, no regress).
- Outcome: FIXER-REFUSED-CONFIRMED — distinct from FIXER-STALLED.

**Verdict on U1**: PARTIALLY EXERCISED. The ledger format is
correctly populated; the distinction between REFUSED-BY-TYPE and
STALLED-ON-ATTEMPT is honored. The multi-round progress tracking
(where Net-delta actually informs termination) was NOT exercised
in this test — it would need a route with at least one
STRUCTURAL SP (where a Fixer attempt is made and can then be
measured round-over-round).

**Gap for future test**: run a theorem with mixed STRUCTURAL +
STRATEGIC SPs so U1's multi-round ledger arithmetic is actually
triggered.

### U2 — Sub-pipeline recursion via `[SUB-PROBLEM:...]`

**Artifacts**: `explorer_1_route_1.md` §Step 4; `explorer_2_route_2.md`
§Step 4.

**Triggered?** Yes. BOTH explorers considered sub-problems.

**What the admissibility check caught**:
- Explorer 1's first candidate (generic Alexander-Δ equality
  across (p,q)-swap implies uniform ε) was self-rejected because
  the sub-problem has WEAKER hypothesis (Δ-equality ⊂ knot-
  equivalence), hence strictly MORE general, hence not strictly
  smaller. **U2 admissibility rule correctly blocked a
  non-admissible sub-problem.**
- Explorer 1's second candidate (p = 2 base case) was noted as
  vacuously true at p=2 (no mixed 1-element vector) and correctly
  abandoned.
- Explorer 2's candidate (fix p = 3) passed admissibility
  (smaller parameter range) but was electively not emitted because
  the sub-pipeline would face the same missing-scaffolding gap and
  burn breadth budget.

**Verdict on U2**: SUCCESSFUL. The admissibility self-check at
Explorer-time prevented a degenerate sub-problem from reaching
Auditor, AND the judgment about sub-pipeline cost-benefit was made
explicitly (Explorer 2 Step 4 "burning the breadth budget" note).

**Qualification**: U2 was "exercised-by-non-emission" rather than
by actual sub-pipeline execution. A future test should deliberately
use a theorem where a sub-problem genuinely isolates a tractable
piece so the sub-pipeline actually runs.

### U3 — Cross-pollination at Judge via `[REUSABLE-FRAGMENT:...]`

**Artifact**: `judge.md` §Cross-pollination extraction; appended
block in `best_proof.md`.

**Triggered?** Yes — dual-PARTIAL case hit the extraction
procedure.

**Fragments extracted** (3 total, within cap):
- fragment-1 (Explorer 1 uniform-arm handler): status=verified.
- fragment-2 (Explorer 1 library insufficiency counterexample):
  status=verified-as-counterexample.
- fragment-3 (Explorer 2 genus-dichotomy asymmetric elimination):
  status=verified.
- fragment-4 (Explorer 2 Seifert-matrix dimension hook):
  status=unverified.

Wait — Judge wrote 4 tagged fragments in total (2 per losing route,
3 rubric cap per route, so 4 combined is within bounds). Auditor's
cross-pollination audit checked 3 of the 4 in the best_proof.md
appended block (the orchestrator retained fragment-1, fragment-2,
fragment-4 explicitly; fragment-3 is the winning-route's own work
so it's already inside best_proof.md §Step 1 and not re-appended).

**Auditor re-verification** (cross-pollination audit): 3/3
appended fragments verified-as-stated; unverified status on
fragment-4 honestly flagged.

**Verdict on U3**: SUCCESSFUL. All three status types
(verified, verified-as-counterexample, unverified) appeared in
one pipeline run — exercising the full U3 vocabulary. The
counterexample-typed fragment (fragment-2) is a particularly
useful output: it tells a future orchestrator which lemma is
missing rather than just "this didn't work."

**Downstream value check**: if future pipeline populates level1
with Lemma 4.1 / 4.2, fragment-1 + fragment-3 can be re-cited
directly and fragment-4's S-equivalence claim becomes verifiable.
The fragments have concrete re-entry utility — not just
decorative.

### U4 — Level-1 library with `[REF:level1:...]` tag

**Artifacts**: `level1_lemmas/` directory (3 lemma files +
README); citation tags throughout Explorer 1 / 2 / Judge / Auditor.

**Triggered?** Yes — 6 distinct `[REF:level1:...]` tags across the
pipeline.

**Sub-observations**:
- Scout's 0b-level1 scan correctly inventoried the 3 lemmas and
  classified all as UNPROVEN-HERE → L2.
- Auditor F2 check: L3 count = 0 (all level1 citations exempted);
  STRUCTURAL-CITATION-WARNING NOT triggered. This is the correct
  behavior — the level1 lemmas are paper-internal results being
  assumed-valid, not disguised external blackboxes.
- L3-in-disguise exception: the Auditor explicitly checked whether
  any level1 lemma was load-bearing for a RESEARCH claim that could
  not be independently verified from paper Section 3 — none was
  (Theorem 3.5 = Seifert structure; Corollary 3.10 = Δ-invariance
  is classical; Proposition 4.3 = torus polynomial is textbook).
  So exemption stands.

**Verdict on U4**: SUCCESSFUL. The level1 library mechanism
correctly surfaced what's available (3 lemmas) AND what's missing
(Lemma 4.1 / 4.2 from §4). The honesty of the PARTIAL verdict
depends directly on U4 — without the per-workdir level1 inventory,
the pipeline might have hallucinated a "use Lemma X" step without
noticing Lemma X was absent.

### U5 — SP severity × type refactor (ROUTINE/STRUCTURAL/STRATEGIC)

**Artifact**: Auditor round 1 §Issues Found; Fixer round 1
§U5 dispatch rule.

**Triggered?** Yes. All three types appeared:
- SP-1 HIGH/STRATEGIC → Fixer REFUSED.
- SP-2 HIGH/STRATEGIC → Fixer REFUSED.
- SP-3 LOW/ROUTINE → Fixer noted but did not patch (cosmetic on
  top of refused proof).

**Dispatch correctness**:
- STRATEGIC dispatch rule: Fixer MUST refuse; no partial patch
  attempt. Honored.
- FIXER-REFUSED pathway emitted the ORCHESTRATOR hand-off
  recommendations (a)/(b)/(c), as specified in the v2.3 rubric.
- No "Complete Fixed Proof" artifact emitted, as specified.

**Verdict on U5**: SUCCESSFUL. The classification-driven dispatch
replaced what in V2.2 would have been an ambiguous "Fixer tries
and fails" round with an explicit typed refusal. This saved a
round and produced a cleaner orchestrator decision point.

**Qualification**: STRUCTURAL dispatch (where Fixer attempts a
patch citing registered machinery) was NOT exercised in this test
— all HIGH SPs were STRATEGIC. A future test should include a
STRUCTURAL SP to exercise the middle branch of U5.

---

## O1–O5 Cold-Start Metrics (per V2.2 template)

### O1 — Pipeline completeness
- Full pipeline ran Scout → 2 Explorers → Judge → Auditor R1 →
  Fixer R1 → Orchestrator.
- No stage was skipped except Integrator, which is correctly
  skipped on PARTIAL verdict.
- **O1**: PASS (all expected stages fired).

### O2 — Honest failure reporting
- The STRATEGIC gap (missing §4 lemma) was surfaced, not
  hallucinated around.
- Auditor did NOT stamp the proof VALID in aggregate — it stamped
  it PARTIAL.
- Fixer did NOT attempt to invent Lemma 4.1 — it emitted
  FIXER-REFUSED.
- Judge's REJECT_ALL considered but not emitted, with reasoning
  recorded (partial fragments have downstream value).
- **O2**: PASS (honest-failure discipline held).

### O3 — Reverse-consistency check
- Auditor §Step 0.5 explicitly checked the IFF structure.
- Forward direction: PARTIAL (uniform sub-case closed;
  asymmetric sub-case eliminated; mixed-mixed sub-case open).
- Backward direction: clean via classical $T(p,q) \cong T(q,p)$.
- The backward/forward asymmetry is reflected in the final
  verdict.
- **O3**: PASS.

### O4 — Citation discipline
- L1 citations (genus invariance, σ invariance, classical
  $T(p,q) \cong T(q,p)$): all proper.
- L2 citations: $T(p,q) \cong T(q,p)$ (Lickorish §7 / Kauffman
  §3) and the 3 level1 lemmas.
- L3 count: 0 (level1 exempted).
- STRUCTURAL-CITATION-WARNING: not triggered.
- **O4**: PASS.

### O5 — Constants and numerics
- Not applicable in the traditional (convergence-rate) sense.
- Numerical spot-check at $(p,q) = (3,5)$: genus arithmetic OK;
  block-cyclic dimension arithmetic OK after self-correction.
- Self-correction in Explorer 2 Step 2 is captured honestly.
- **O5**: PASS (LDT-adjusted).

---

## Diff from V2.2 baseline (ldt_curve_complex_s11)

| Axis | V2.2 | V2.3 Stage 2 |
|------|------|--------------|
| Full-proof closure | YES (Route D coherent-resolution surgery) | NO (PARTIAL, strategic-stuck) |
| Fixer rounds | 1 | 1 (REFUSED, not STALLED) |
| SP classification | Severity-only | Dual: severity × type |
| Cross-pollination | N/A (single winning route) | 3 fragments extracted |
| Level-1 lemmas | N/A | 3 registered, all UNPROVEN-HERE |
| Sub-problem emission | N/A | Considered 3x, rejected 3x (2 by admissibility, 1 by cost-benefit) |
| Integrator | Invoked | Skipped (PARTIAL) |
| Honest failure surfacing | N/A | Primary output |

The test deliberately chose a theorem where closure would require
unregistered machinery. PARTIAL was the predicted (and correct)
outcome.

---

## Capability vs. rearrangement assessment (preview)

See `v23_upgrade_and_test_summary.md` for full analysis. Short
version:
- U2 + U3 + U4 add genuine NEW capability (sub-problem recursion;
  fragment preservation; paper-chained lemma citation).
- U1 + U5 make existing Auditor/Fixer behavior MORE EXPLICIT —
  partial rearrangement, but the explicitness itself is a
  capability gain (FIXER-REFUSED vs FIXER-FAILED ambiguity is
  eliminated).
