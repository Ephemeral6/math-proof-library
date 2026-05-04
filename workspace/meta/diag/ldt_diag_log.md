# LDT v2.1 Diagnostic — Probe log

Date started: 2026-04-20.
Purpose: Stress-test six structural concerns about the Stage 1–3 LDT extension. Read-only on existing infrastructure.

## Probe 1 — Citation audit of Round 0 / Round 0.5 best proofs
- Started: 2026-04-20
- Completed: 2026-04-20
- Finding: Confirmed. Round 0 has 0 E3, 4 E2, 3 E1; Round 0.5 has 4 E3, 2 E2, 2 E1. Neither proof stands if E citations struck. Independent reasoning is thin (3 and 4 trivial steps respectively).
- Artifact: `c1_citation_audit.md`

## Probe 2 — Synthetic citation-heavy proof
- Started: 2026-04-20
- Completed: 2026-04-20
- Finding: CONFIRMED. V2 Auditor PASSes (every step VALID, numerical-verification vacuous). judge_ldt scores 46/55 — within 1 point of real Round 0.5 proof. No mechanism flags 4 decorative E3 citations.
- Artifact: `c2_synthetic_citation_proof.md`, `c2_audit_result.md`

## Probe 3 — Vocabulary bluff proof
- Started: 2026-04-20
- Completed: 2026-04-20
- Finding: CONFIRMED. Axis 5 rubric does not distinguish "invoking X" from "using X". Bluff proof (Teichmüller prologue + Alexander-determinant middle + Teichmüller epilogue) would score 12–13.5/15 on Axis 5 — competitive with real hyperbolic proof. Only LDT checklist item F (vague citations) offers any safety net.
- Artifact: `c3_vocabulary_bluff_proof.md`, `c3_axis5_scoring.md`

## Probe 4 — Torus knot Jones recursion full pipeline
- Started: 2026-04-20
- Completed: 2026-04-20
- Finding: PIPELINE WORKED. Scout→Explorer→Judge→Auditor(R1: FIX)→Fixer→Auditor(R2: PASS). One Audit-Fix cycle; Auditor correctly flagged Step 2 (Markov-trace identification as black-box citation) + Item F (vague citations). Fixer derived Step 2 from bracket axioms, making proof self-contained. Final verdict PASS is earned. Axis 5 correctly scored LOW (4/10) for this algebraic proof — showing the rubric does score accurately when there's no geometric-vocabulary to inflate it. CAVEAT: problem is algebra-heavy; does not stress genuinely geometric regime where Auditor has no clear criteria.
- Artifact: `c4_fixer_loop_log.md`; full pipeline in `workspace/active/ldt_diag_torus_jones_recursion/`
- RETROACTIVE CORRECTION (from Probe 5): TSV `kauffman_bracket("trefoil")` has a convention bug that would break the Explorer's Step 8 cross-check in a real pipeline. Probe 4's PASS was earned under simulation only.

## Probe 5 — TSV coverage (10 live calls)
- Started: 2026-04-20
- Completed: 2026-04-20
- Finding: Tag protocol IS granular enough to distinguish real hit / real miss / authoritative null. BUT `high` confidence reflects the computation PATH, not VALUE correctness. Found a concrete bug: `kauffman_bracket("trefoil")` returns $A^{25}-A^{21}-A^{13}$ with high confidence; conventional bracket is $-A^5 - A^{-3} + A^{-7}$. Convention mismatch between table's Jones polynomial (stored in reciprocal-variable convention) and the derivation formula (assumes the other convention). The bug would be invisible to a naive Explorer that trusts high-confidence tags.
- Artifact: `c5_tsv_coverage_map.md`, `c5_tsv_probe_script.py`

## Probe 6 — Rubric mismatch (judge.md vs judge_ldt.md)
- Started: 2026-04-20
- Completed: 2026-04-20
- Finding: Both rubrics prefer P0.5 over P0, but judge_ldt amplifies the gap (17.5 → 26.3 percentage points) via Axis 5's 1.5× multiplier. Four concrete mismatches: (1) magnitude of scoring gap depends heavily on rubric choice; (2) Axis 3 Elegance and Axis 5 Geometric Content double-count against algebraic proofs (algebraic proofs tend to be long AND non-geometric); (3) citation-heavy steps register as "fully justified" on Completeness, so P0.5 scores 9/10 on Completeness despite resting on 4 E3 citations while P0 scores 7/10 despite doing more independent work; (4) no reward for transparent flag-and-resolve — P0's sign-convention flag hurts its score. The LDT rubric's Axis 5 is not a generic improvement over judge.md; it adds geometric weighting without fixing base rubric insensitivities to citation depth, originality, or transparency.
- Artifact: `c6_rubric_mismatch.md`
