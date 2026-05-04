# Orchestrator — Decision on Theorem 4.4 (v2.3 Stage 2)

## Inputs

- Scout: 3 routes identified; primary=Route 1, backup=Route 2,
  reserve=Route 3.
- Explorer 1 (Route 1): PARTIAL (Case A closed, Case B strategic-stuck).
- Explorer 2 (Route 2): PARTIAL (asymmetric case killed, uniform
  case closed, mixed-mixed strategic-stuck).
- Judge: Winner=Route 2 (31.5/55); Second=Route 1 (29.5/55); both
  PARTIAL per Pre-Selection Gate. 3 reusable fragments extracted.
- Auditor Round 1: PARTIAL verdict. 2 HIGH/STRATEGIC SPs, 1 LOW/
  ROUTINE. STRUCTURAL-CITATION-WARNING not triggered.
- Fixer Round 1: FIXER-REFUSED-CONFIRMED. Recommended option (c).

## Decision point (v2.3)

Three options per F4 gate + orchestrator protocol:
- (a) Route-switch to alternative_route.md (Route 1).
- (b) Re-Scout under new constraint.
- (c) Accept PARTIAL.

## Analysis

### Option (a): route-switch to Route 1
Route 1 has the SAME strategic SP (Case B needs missing paper §4
lemma). Switching buys nothing. **REJECTED.**

### Option (b): re-Scout with constraint
The constraint "cannot rely on missing level1 classification
lemma" would restrict Scout to (i) direct braid-word methods
(Route 3, exploratory, no level1 support), (ii) cobordism/surgery
arguments with no level1 support, or (iii) ad-hoc invariants.
None of these has a plausible closure path in a single pipeline
run. **Expected value is low; budget-cost high.** REJECTED for
this run; may be attempted after level1 is expanded.

### Option (c): accept PARTIAL
Record the SP in `workspace/failure_patterns.md`. Preserve the 3
cross-pollination fragments for downstream reuse. Record the
prerequisite: populate level1 with Blackwell §4 Lemma 4.1 / 4.2
before re-attempt. **SELECTED.**

## Decision

**OPTION (c): accept PARTIAL.**

Next actions:
1. Record failure pattern in `workspace/failure_patterns.md`
   (entry: "Spiral-knot parameter-swap mixed-case requires paper
   §4 scaffolding; routes stall without it").
2. Do NOT invoke Integrator (PARTIAL verdicts skip Integrator per
   `orchestrator_update.md` trigger conditions).
3. Do NOT auto-archive (per Phase 2 absolute rules from user
   spec, Stage 2 is diagnostic-only; no auto-archive).
4. Emit Stage 2 observation log at
   `workspace/diag/theorem_4_4_v23_test_log.md`.
5. Emit Stage 1+2 summary at
   `workspace/diag/v23_upgrade_and_test_summary.md`.

## PARTIAL artifact preservation

What is preserved for future re-entry:
- `best_proof.md`: Route 2 + 3 fragments appended.
- `alternative_route.md`: Route 1 (Case A uniform-arm proof is
  clean; worth preserving even though overall route is PARTIAL).
- `level1_lemmas/` with README and 3 lemmas as-registered.
- Judge's cross-pollination block.

What a future re-attempt would need:
- New level1 lemmas: Blackwell §4 Lemma 4.1 (refined Alexander-
  polynomial classification for mixed spiral knots) and/or
  Lemma 4.2 (spiral-signature or spiral-determinant closed form).
- With those registered, either Route 1 or Route 2 could close
  Case B in a single additional round.

## Verdict tags

- PIPELINE-VERDICT: PARTIAL
- CAUSE: STRATEGIC-SP-BLOCKED-BY-LEVEL1-GAP
- INTEGRATOR-INVOKED: NO (PARTIAL skip)
- AUTO-ARCHIVE: NO (Stage 2 diagnostic, per user spec)
- FAILURE-PATTERN-RECORDED: YES
