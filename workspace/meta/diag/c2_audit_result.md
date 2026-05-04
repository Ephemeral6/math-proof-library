# Probe 2 — Auditor + Judge outputs on the synthetic citation-heavy proof

**Input**: `c2_synthetic_citation_proof.md` (10-step proof of $3_1 \not\sim 4_1$ with 8 E3-level citations, 4 of them load-bearing, 4 decorative).

**Method**: apply V2 `auditor.md` + LDT `ldt_checklist.md` + `judge_ldt.md` (Stage 3 fix) to this proof. Report what each component would output if executed by a careful but rule-following operator.

---

## Part A — V2 Auditor simulation

### Step 0.5 (Reverse Consistency)

`problem.md` has one qualitative claim: "$3_1 \not\sim 4_1$". No UB/LB/tightness structure. Step 0.5 is **not triggered**. ✓

### Step-by-step validity check

| Step | Validity | Reason |
|------|----------|--------|
| Setup | VALID | Standard notation |
| 1 Waldhausen | VALID | Citation to Waldhausen 1968 is correct |
| 2 Perelman | VALID | Citation to Perelman 2002–2003 is correct |
| 3 Agol | VALID | Citation to Agol 2012 is correct |
| 4 Wise | VALID | Citation to Wise 2012 is correct |
| 5 Gordon–Luecke | VALID | Citation correct; directly relevant |
| 6 Thurston hyperbolization | VALID | Citation correct |
| 7 Mostow rigidity | VALID | Citation correct |
| 8 Seifert (1933) | VALID | Citation correct |
| 9 Application | VALID | Logic flows from cited theorems |
| 10 Conclude | VALID | Conclusion follows |

**Every single step is VALID in V2 Auditor terms.** The Auditor has no mechanism to flag "too many citations" or "citations unused downstream".

### Constants Tracing

No constants in this proof. Table is empty. ✓

### Numerical Verification

**Not applicable** — this proof has no inequalities, no recursions, no numerical bounds. The mandatory numerical-verification rule produces `N/A` for every step. This is the first signal that something is off: V2 Auditor's *main validation mechanism* (forced numerical checks) has nothing to do here.

### Cross-Verification

Auditor searches `proofs/library/low-dimensional-topology/`:
- `conventions.md` — not cited
- `knot-invariants/jones-trefoil-right.md` — not cited
- `knot-invariants/jones-figure-eight.md` — not cited
- `knot-invariants/kauffman-bracket-axioms.md` — not cited

**Cross-verification output**: `[NO-BASELINE]` for the final claim (no prior LDT proof of this form in the library). The *non-use* of available library lemmas is **not** a flag in V2 Auditor — the cross-verification rule only checks whether cited results match existing proofs, not whether existing proofs were skipped.

### V2 Auditor verdict

```
## Summary
- VALID: 11, INVALID: 0
- 数值验证: N/A (no inequalities to verify)
- 常数追踪: N/A (no constants)
- Conclusion: **PASS**
```

**Key observation**: the V2 Auditor has no mechanism to punish over-citation or reward independent reasoning. It checks "is every step valid?" — all 11 are. It checks "does the final conclusion follow?" — yes. It checks numerical/constant consistency — vacuous here. So the verdict is **PASS**.

---

## Part B — LDT Checklist simulation (ldt_checklist.md)

| Item | Verdict | Note |
|------|---------|------|
| A. Isotopy vs. equivalence | **OK** | Gordon–Luecke citation specifies ambient isotopy; consistent throughout |
| B. Orientation | **OK** | Both knots oriented at Setup; no orientation-sensitive claim made |
| C. Dimension | **OK** (N/A) | Purely 3-dim; no slice/ribbon claims |
| D. Compactness | **OK** | Knot complements are compact (torus-boundary manifolds); Haken is compact |
| E. Group presentation | **OK** (N/A) | No presentation used |
| F. Literature cross-check | **OK** | All citations are to correct publications; no constants quoted |
| G. Picture-proof handling | **OK** (N/A) | Zero pictures in this proof |
| H. Geometric Intuition | Score: **3/5** | **This is the critical observation.** See commentary below. |

### H rubric (from ldt_checklist.md)

Scale:
- 0: pure symbol-pushing
- 2: abstract algebraic objects
- 4: geometric vocabulary + tied to meaning
- 5: geometric insight producing simpler argument

The synthetic proof uses geometric *vocabulary* extensively (Haken, hyperbolic, Seifert, orbifold, CAT(0), cube complex, virtual Haken). Under the LDT checklist's H rubric, "uses geometric vocabulary" is part of the level-4 description. But the vocabulary is *decoration*: no geometric object is constructed, no geometric intuition drives the argument. The rubric does not distinguish "uses vocabulary" from "uses structure".

**H would score 3/5 or 4/5** depending on how charitably the word "ties computations back to geometric meaning" is read. No computation exists in this proof, so there is nothing to tie back — which should arguably push the score down to 2/5. But a rule-following auditor who reads "uses geometric vocabulary" literally could justify 3/5 or 4/5.

**The LDT checklist does not catch citation-weight.** Item F is satisfied as long as each citation is to a real publication. There is no "E3 density" metric, no "unused citation" check.

### LDT checklist verdict

```
## LDT-Specific Audit
| Item | Verdict |
|------|---------|
| A | OK |
| B | OK |
| C | OK |
| D | OK |
| E | OK |
| F | OK |
| G | OK |
| H | Score 3/5 |

### Geometric Intuition Assessment
Score: 3/5
Rationale: Proof uses rich geometric vocabulary but does not construct
or engage any specific geometric object; vocabulary is decorative.
```

---

## Part C — judge_ldt.md Axis-by-axis scoring (Probe 2 proof as sole input)

### Axis 1 — Completeness (out of 10)

- All steps justified via citation. No `[STEP-STUCK]` tags.
- But 4 of 8 E3 citations (Agol, Wise, Perelman in full generality, Waldhausen) are NOT load-bearing — they could be struck without affecting the argument.
- A strict rubric would ding for "unused citations = incompleteness of motivation"; the actual rubric doesn't have that criterion.

**Honest reading: 9/10.** All steps cited; citations happen to be padded, but padding is not penalized.

### Axis 2 — Correctness (out of 10)

- The argument, taken at face value, is correct: Steps 5, 6, 7, 8 are genuinely load-bearing and together imply the conclusion.
- The decorative Steps 1, 3, 4 don't corrupt the argument; they are unused.

**Honest reading: 10/10.** The proof is correct.

### Axis 3 — Elegance (out of 10)

- A 10-step proof with 4 unused theorems is NOT elegant.
- But "elegance" in the rubric is "short, clean, minimal black-box citations". Minimality would punish this — but the rubric does not give an explicit metric for "minimality".

**Honest reading: 5/10.** A charitable scorer might go to 7/10 because the actual load-bearing sub-argument (Steps 5–8) is indeed concise.

### Axis 4 — Gaps (out of 10)

- No `[STEP-STUCK]` tags, no flagged issues. Everything is cited.
- But the rubric does not treat "unverified black-box citation" as a gap — only missing steps are gaps.

**Honest reading: 10/10.** No gaps in the rubric's sense.

### Axis 5 — Geometric Content (out of 10, × 1.5 = out of 15)

Axis 5 rubric:
- 10: "uses a hyperbolic structure, a triangulation, …, or an explicit visualization"
- 8: "uses a geometric invariant (volume, genus, Heegaard splitting) but without deep engagement"
- 6: "uses a combinatorial or diagrammatic invariant"
- 4: "uses an algebraic invariant"
- 2: "pure algebra"

**This is where the probe pays off.** The synthetic proof:
- Mentions hyperbolic structure (Step 6) — but does not construct one
- Mentions Seifert fibration (Step 8) — but does not specify one
- Mentions the geometric decomposition (Step 2) — but does not enumerate its pieces
- Mentions virtual Haken / cubulated groups (Steps 3, 4) — but uses them for nothing

Under the rubric's literal wording, the proof *invokes* hyperbolic structures, Seifert fibrations, and geometric decompositions. Under the rubric's *intent* (actual geometric engagement), it does none of these things.

**Literal-rubric reading: 8/10.** The proof "uses geometric invariants" (hyperbolic-vs-Seifert dichotomy, volume implicit via Thurston, orbifold Euler characteristic implicit via Seifert's classification) "without deep engagement".

**Intent-rubric reading: 3/10.** No geometric construction, no specific object, pure name-dropping.

The rubric has no mechanism to distinguish these. **A rule-following Judge would score 8/10, giving 12/15 after ×1.5.**

### Axis 5 × 1.5 multiplier

8 × 1.5 = **12/15** under literal reading.

### judge_ldt total

Under strict-literal reading:
| Axis | Score |
|------|-------|
| 1 Completeness | 9/10 |
| 2 Correctness | 10/10 |
| 3 Elegance | 5/10 |
| 4 Gaps | 10/10 |
| 5 Geometric Content × 1.5 | 12/15 |
| **Total** | **46/55** |

That is within **1 point** of the Round 0.5 hyperbolic proof (47.5/55) and **equal** to the Round 0.5 Jones proof (46/55).

**The synthetic citation-only proof is indistinguishable from the real Round 0 / 0.5 winners under the current rubric.**

---

## Part D — Final diagnostic findings

1. **V2 Auditor**: PASS. No mechanism catches the 4 decorative E3 citations; the mandatory numerical-verification rule is vacuous here and therefore silent.
2. **LDT Checklist**: 8/8 items pass or pass-with-note. Item H (geometric intuition) scores 3/5 — modest, not failing.
3. **judge_ldt total**: 46/55 — essentially indistinguishable from the real Round 0.5 proofs.

**Concern 2 verdict: CONFIRMED.** The Auditor has no mechanism to distinguish light from heavy `[REF:external]` citations. A proof with 8 E3 citations, 4 of them decorative, zero computation, zero library use, and zero TSV verification passes the audit and scores competitively on judge_ldt. The axis 5 "Geometric Content" rubric scores "using geometric vocabulary" almost as highly as "engaging geometric structure", because the literal rubric wording does not distinguish invocation from construction.

Secondary finding: **the judge_ldt Geometric Content axis has a bluff vulnerability.** Any proof that name-drops geometric objects while doing non-geometric work underneath will score close to a genuinely geometric proof. Probe 3 will stress this finding directly.

*Appended to `ldt_diag_log.md` on 2026-04-20.*
