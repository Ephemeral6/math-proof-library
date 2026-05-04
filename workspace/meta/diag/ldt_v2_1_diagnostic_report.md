# LDT v2.1 Diagnostic Report

**Date**: 2026-04-20
**Scope**: stress-test six structural concerns about the Math Agent V2 + LDT extension (Stages 1–3), following the Round 0 and Round 0.5 PASS verdicts on $3_1 \not\sim 4_1$.
**Method**: six targeted probes, each producing a standalone artifact under `workspace/diag/`; this report synthesizes findings.
**Remit**: diagnosis only. No fixes proposed in the main body. Fix-temptations deferred to the final appendix as observations.

---

## Executive summary

The current LDT-extended pipeline PASSed both Round 0 (Jones route) and Round 0.5 (hyperbolic route) proofs of $3_1 \not\sim 4_1$. The probes below show that **both PASS verdicts are structurally fragile**, and that the pipeline would likely also PASS proofs that should NOT pass. Specifically:

1. **Citation weight is invisible to the Auditor.** A synthetic proof with 8 E3 citations (4 decorative) and zero computation PASSes the V2 Auditor and scores within 1 point of Round 0.5 on `judge_ldt.md`.
2. **`judge_ldt.md` Axis 5 rewards geometric vocabulary, not geometric engagement.** A bluff proof with Teichmüller/MCG/Masur–Minsky prologue and epilogue but Alexander-determinant middle would score 12–13.5/15 on Axis 5 — essentially indistinguishable from the real Round 0.5 hyperbolic proof's score.
3. **Round 0 and 0.5 proofs both rest heavily on external citations.** Round 0 has 0 E3 / 4 E2 / 3 E1 / 3 I (Independent); Round 0.5 has 4 E3 / 2 E2 / 2 E1 / 4 I. Neither proof would stand if external citations were struck; the "independent reasoning" portion of each is 3–4 steps.
4. **Pipeline works correctly on an algebra-heavy problem** (Probe 4 Kauffman bracket recursion): one Auditor–Fixer cycle surfaced a real gap (black-box Markov-trace identification) and the Fixer resolved it self-contained.
5. **TSV tag protocol is sound; TSV contents have a convention bug.** The confidence-tag system correctly distinguishes hit / miss / authoritative-null. But `kauffman_bracket("trefoil")` returns an INCORRECT value ($A^{25} - A^{21} - A^{13}$ instead of $-A^5 - A^{-3} + A^{-7}$) with **high** confidence, caused by a Jones-table convention mismatch with the derivation formula.
6. **`judge.md` vs `judge_ldt.md` scoring gap scales asymmetrically.** Both rubrics prefer the hyperbolic proof, but the LDT rubric widens the margin from 17.5 to 26.3 percentage points. Axis 5 and Axis 3 (Elegance) structurally double-count against algebraic proofs. No rubric axis rewards independent reasoning or transparent flag-and-resolve.

The system can produce PASS verdicts on proofs that are "organizationally correct, mathematically thin" (Round 0, Round 0.5) and on proofs that are "geometrically decorated but algebraic underneath" (hypothetical bluff). The V2 Auditor has no mechanism to distinguish these from deeply-engaged proofs. The one concrete derivation bug (TSV `kauffman_bracket`) is masked by high-confidence tagging.

---

## Per-concern findings

### Concern 1 — Both PASS verdicts depend on external citations, not independent reasoning
**Artifact**: `c1_citation_audit.md`

Per-step classification of Round 0 and Round 0.5 `best_proof.md` files. Classification rules:
- I = Independent argument (derivation from first principles)
- L = our library (`proofs/library/`)
- E1 = external citation with ≤30 second mental verification
- E2 = external: one-theorem/paper, widely known
- E3 = external: deep field-spanning (Thurston, Mostow, Gordon–Luecke, Agol, Wise, Perelman, etc.)

**Round 0 load-bearing step inventory (7 steps)**: 3 I / 0 L / 3 E1 / 4 E2 / **0 E3**.
**Round 0.5 load-bearing step inventory (12 steps)**: 4 I / 0 L / 2 E1 / 2 E2 / **4 E3**.

Neither proof stands if E-citations are struck. The "independent reasoning" core of each proof is 3–4 trivial steps (bracket arithmetic for Round 0; contradiction-wiring for Round 0.5). Round 0.5 is **more** E3-heavy in absolute terms but is judged to be "geometrically richer" by the rubric — which highlights that the rubric measures **topic of citation** rather than **independence of argument**.

### Concern 2 — The V2 Auditor cannot distinguish light vs heavy `[REF:external]` citations
**Artifact**: `c2_synthetic_citation_proof.md`, `c2_audit_result.md`

Constructed a 10-step synthetic proof of $3_1 \not\sim 4_1$ citing 8 E3 theorems (Waldhausen, Perelman, Agol, Wise, Gordon–Luecke, Thurston hyperbolization, Mostow, Seifert); by design, 4 citations (Waldhausen, Agol, Wise, full-generality Perelman) are not used downstream — pure decoration.

Applied the V2 Auditor:
- Step 0.5 Reverse Consistency: N/A (no UB/LB).
- Step-by-step validity: 11/11 VALID.
- Constants Tracing: no constants; vacuous.
- Numerical Verification: no inequalities; **the primary validation mechanism is vacuous on citation-only proofs**.
- Cross-Verification: no library lemmas cited; `[NO-BASELINE]` flag not raised.

Applied `ldt_checklist.md`: 8/8 items pass or pass-with-note. Item F (vague citations) does not trigger because the synthetic proof cites specific publications (author, year, journal). Item H (geometric intuition) scores 3/5 — modest, not failing.

Applied `judge_ldt.md`: literal-rubric score = **46/55**, within 1 point of the real Round 0.5 proof (47.5/55) and equal to the real Round 0 Jones proof's scoring ballpark. The synthetic proof passes both the Auditor and the Judge.

**Finding confirmed**: the V2 Auditor has no mechanism to flag citation density or decorative citations. The primary numerical validation is silent on citation-heavy proofs. A proof with 4 decorative E3 citations, zero computation, zero library use, and zero TSV call passes.

### Concern 3 — `judge_ldt.md` Axis 5 rewards vocabulary, not engagement
**Artifact**: `c3_vocabulary_bluff_proof.md`, `c3_axis5_scoring.md`

Constructed a "geometric prologue + algebraic middle + geometric epilogue" proof of $3_1 \not\sim 4_1$: Teichmüller space + MCG + Masur–Minsky framing, invented transition matrices, Birman–Hilden mis-citation, Alexander-determinant comparison (the ONLY load-bearing mathematical content), then a Teichmüller-length epilogue claiming $\log(3)/\log(5)$ is a geodesic length ratio (not a defined quantity).

Applied Axis 5 rubric literally: the proof "uses ... a Teichmüller-space argument" (level 10 wording). A rule-following Judge would score **9/10 or 10/10**. Applying rubric INTENT (depth of engagement) would score 4/10.

The rubric text contains no mechanism that would prompt the Judge to apply intent rather than literal reading. The "multiplier rationale" paragraph is aspirational ("not just unrelated algebra") but **non-operational** — it doesn't tell a Judge how to detect unrelated algebra.

LDT checklist item F (vague citations) is the only potential safety net: Birman–Hilden is cited without a specific theorem. But F requires actively skeptical reading, not rule-following.

**Expected Axis 5 score for the bluff proof: 12–13.5/15**, competitive with the real Round 0.5 hyperbolic proof. The specific failure mode — **geometric prologue + algebraic middle + geometric epilogue** — is not caught by either the Judge or the LDT checklist.

### Concern 4 — Pipeline on an induction-requiring, beyond-TSV problem
**Artifact**: `c4_fixer_loop_log.md`, full artifacts in `workspace/active/ldt_diag_torus_jones_recursion/`

Problem: derive $B_{n+2} = (A - A^{-3}) B_{n+1} + A^{-2} B_n$ for the Kauffman bracket of $\widehat{\sigma_1^n}$ in $B_2$, base cases $B_0 = -A^2-A^{-2}$, $B_1 = -A^3$.

Pipeline trace:
- Scout identified Route B (Temperley–Lieb + Markov trace) as preferred; flagged Step 2 (Markov-trace identification) as risk.
- Explorer 1 produced an 8-step proof. Step 2 was a black-box citation.
- Auditor Round 1: **FIX NEEDED.** Flagged Step 2 (load-bearing external citation) and Item F (vague citation).
- Fixer Round 1: replaced Step 2 with 4 sub-steps deriving the Markov trace from bracket axioms, making the proof self-contained.
- Auditor Round 2: **PASS.** All steps VALID, all checklist items OK.

**The pipeline worked as intended on this problem.** One Audit-Fix cycle surfaced a real gap; the Fixer's response was substantive (derivation, not rephrasing); the final proof is self-contained.

**Caveats**:
1. Axis 5 correctly scored LOW (4/10) for this algebraic proof. The worry from Probes 2–3 was that Axis 5 could be fooled UP by vocabulary; Probe 4 shows that when there is no geometric vocabulary, the rubric correctly penalizes. This is a piece of POSITIVE news for the rubric.
2. The problem was algebra-heavy (the "right moves" are TL algebra). The pipeline's Auditor criteria (Step 0.5, step-by-step validity, constants tracing) are well-matched to algebra. This probe does NOT stress the regime where the right moves are geometric (cf. Concern 3).
3. **Retrofitted finding from Probe 5**: the Explorer's Step 8 claimed a TSV match against $B_3 = -A^5 - A^{-3} + A^{-7}$. Probe 5 showed that the real TSV returns $A^{25} - A^{21} - A^{13}$ (an INCORRECT value, marked high confidence). In a real pipeline, Auditor cross-verification would fail — either revealing the TSV bug, or (worse) causing the Auditor to reject the Explorer's correct answer. The Probe 4 PASS was earned in simulation; a real pipeline would hit this discrepancy.

### Concern 5 — TSV coverage and tag reliability
**Artifact**: `c5_tsv_coverage_map.md`, `c5_tsv_probe_script.py`

Ran 10 diverse calls against `tsv_knot.py` in isolation. Results (full tags logged):

| Call | Outcome | Tag |
|------|---------|-----|
| `jones("trefoil")` | correct value | high confidence |
| `jones("7_1")` | None | low, "unknown knot" |
| `jones([1]*7)` | None | low, "generic-braid not implemented" |
| `jones([1,-2,1,-2])` | matches 4_1 table | high |
| `alexander([1,1,1], n=2)` | matches 3_1 table | high (n ignored — table hit first) |
| `alexander([1,1,1,1,1], n=2)` | matches 5_1 table | high |
| `kauffman("trefoil")` | **INCORRECT VALUE** | **high** |
| `kauffman("T(3,5)")` | None | low, "unknown knot" |
| `volume("trefoil")` | None | **high**, "non-hyperbolic" (authoritative null) |
| `reidemeister("trefoil", "3_1m")` | False | high, Jones differs |

**Tag protocol is informative**: the `{method, submethod, confidence, reason}` tuple lets a careful Explorer distinguish three cases: real hit (high + value), real miss (none + low + "out-of-scope"), authoritative null (tsv-knot + high + "non-hyperbolic"). This works.

**TSV `kauffman_bracket` has a convention bug**. The table stores $V_{3_1}(q) = -q^{-4} + q^{-3} + q^{-1}$ in a convention where the Kauffman-bracket identity $\langle L \rangle = (-A)^{3w} V_L(A^{-4})$ does NOT produce the conventional Kauffman bracket. For the right-trefoil, the formula returns $A^{25} - A^{21} - A^{13}$; the Kauffman convention's right-trefoil bracket is $-A^5 - A^{-3} + A^{-7}$. The function tags the result `confidence=high` because the derivation PATH (table-lookup + formula) is well-defined — but the formula's convention does not match the table's. An Explorer trusting high-confidence tags would ingest a wrong value.

**Finding**: confidence tags correctly distinguish success from miss. They do NOT distinguish a correct derivation from a derivation with a convention bug. That distinction requires end-to-end numerical verification against an independent path — exactly the kind of check that Probes 2–3 showed the V2 Auditor does NOT perform on citation-heavy proofs.

### Concern 6 — Rubric mismatch between `judge.md` and `judge_ldt.md`
**Artifact**: `c6_rubric_mismatch.md`

| | `judge.md` (40) | `judge_ldt.md` (55) |
|---|---|---|
| P0 (Jones route) | 30/40 = 75.0% | 36/55 = 65.5% |
| P0.5 (hyperbolic route) | 37/40 = 92.5% | 50.5/55 = 91.8% |
| **P0.5 margin** | +17.5pp | +26.3pp |

Four concrete mismatches:

1. **Margin scaling**: the LDT rubric widens the scoring gap by a factor of 1.5 via the Axis 5 multiplier. Proofs near the boundary in `judge.md` can flip decisively under `judge_ldt.md`.

2. **Double-counting**: Axis 3 (Elegance) and Axis 5 (Geometric Content) structurally correlate — algebraic proofs tend to be long AND non-geometric. A proof like P0 takes a hit on both.

3. **Completeness is citation-blind**: P0.5 scores 9/10 on Completeness despite resting on 4 E3 citations; P0 scores 7/10 despite doing more independent work. Cited = justified, under both rubrics.

4. **No reward for transparent flag-and-resolve**: P0's sign-convention retraction costs points on Completeness; silent-but-correct scores higher. Perverse incentive toward hiding subtle issues.

Both rubrics pick P0.5 as winner. Neither rewards originality or transparency. The LDT rubric's Axis 5 adds a geometric-vocabulary axis but does NOT correct the base rubric's citation-insensitivity.

---

## Capability picture

What the current system reliably does:
- Produces PASS on proofs that are correct and well-organized, whether by independent derivation (P0) or by external citation (P0.5).
- Surfaces gaps in algebra-heavy proofs where the Auditor's V2 criteria (step validity, constants, numerical verification) apply cleanly (Probe 4).
- Correctly distinguishes real hits from real misses in the TSV via the tag protocol (Probe 5 non-kauffman calls).

What the current system does NOT reliably do:
- Distinguish citation-heavy from independence-heavy proofs (Concern 2).
- Distinguish genuine geometric engagement from geometric-vocabulary decoration (Concern 3).
- Catch latent derivation bugs in external verifiers (Concern 5, `kauffman_bracket`).
- Reward independent reasoning or transparent flag-and-resolve across rubric axes (Concern 6).
- Stress the regime where the "right move" is geometric rather than algebraic (Probe 4 was algebra-heavy; Probes 2–3 show the geometric-content axis is the main weak point).

The PASS verdicts on Round 0 and Round 0.5 are EARNED in the sense that the proofs are mathematically correct and the pipeline's validation criteria are satisfied. They are FRAGILE in the sense that the same pipeline would also PASS synthetic citation-heavy proofs (Probe 2) and vocabulary-bluff proofs (Probe 3), indicating that the validation criteria have significant false-positive rates.

The LDT extension (Axis 5 + LDT checklist) adds signal, but that signal is primarily about geometric vocabulary. On the concern that motivated the extension — "希望看到 LLM 具有几何直觉，而不是只有计算的能力" (wanting LLMs with geometric intuition, not just computation) — the extension rewards the appearance of geometric intuition more than the substance.

---

## Appendix — Observations that may motivate future work

These are diagnostic observations only; they are NOT fix recommendations. The user explicitly scoped this task as diagnosis.

1. **Citation depth metric**: the rubric currently has no measure of "citation weight". An observation: a metric that distinguishes I / L / E1 / E2 / E3 as used in Probe 1 would make citation density visible to the Judge and Auditor. This is descriptive, not prescriptive.

2. **Axis 5 intent vs literal reading**: the current rubric text has wording ("uses X") that admits both literal (vocabulary-rewarding) and intent (engagement-rewarding) readings. An observation: rubrics that include "test whether X actually participates in a load-bearing step" tend to be harder to bluff. The `judge_ldt.md` multiplier paragraph gestures at intent but does not operationalize it.

3. **TSV cross-check**: the `kauffman_bracket` bug (Probe 5, Call 7) would be caught by comparing the formula-derived bracket to an independent computation (e.g., TL recursion). An observation: multi-path cross-verification in TSV itself could catch such bugs before they reach the Explorer.

4. **Auditor's vacuous-validation mode**: on citation-heavy proofs, the V2 Auditor's Numerical Verification is vacuous (no inequalities to check) and Constants Tracing is vacuous (no constants). An observation: an Auditor criterion tailored to "proof is mostly citation" — e.g., requiring explicit derivation in at least one load-bearing step — would change the calculus on Probe 2's synthetic proof.

5. **Transparent-error reward**: an observation that came out of Probe 6 — P0's sign-convention flag-and-resolve currently costs it Completeness points. A rubric that rewards transparency (explicit flag of subtle issues, with resolution) would alter the scoring gap between P0 and P0.5.

6. **Geometric engagement vs geometric vocabulary**: Probe 3's "geometric prologue + algebraic middle + geometric epilogue" pattern is specifically identified as undetectable under the current rubric. An observation: a Judge criterion that traces whether named geometric structures participate in load-bearing steps would directly address this.

These observations are not prescriptive — a decision about which (if any) to act on depends on what the system is trying to do. The diagnostic establishes what the current system does and does not catch, under the probes defined.

---

*Primary artifacts referenced in this report:*
- `c1_citation_audit.md` — per-step citation classification for Round 0 and 0.5 best_proofs
- `c2_synthetic_citation_proof.md`, `c2_audit_result.md` — synthetic 10-step citation-only proof and its Auditor+Judge outputs
- `c3_vocabulary_bluff_proof.md`, `c3_axis5_scoring.md` — bluff proof and Axis 5 analysis
- `c4_fixer_loop_log.md` — full Auditor–Fixer loop on torus braid Kauffman bracket recursion
- `c5_tsv_coverage_map.md`, `c5_tsv_probe_script.py` — 10 TSV calls, tag analysis, bracket-bug diagnosis
- `c6_rubric_mismatch.md` — scoring P0 and P0.5 under both rubrics
- `ldt_diag_log.md` — timestamped probe log
