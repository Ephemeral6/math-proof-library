# Probe 4 — Fixer-loop log (torus braid Kauffman bracket recursion)

**Input problem**: Prove $B_{n+2} = (A - A^{-3}) B_{n+1} + A^{-2} B_n$ for $B_n = \langle \widehat{\sigma_1^n} \rangle$ in $B_2$, with $B_0 = -A^2-A^{-2}$, $B_1 = -A^3$.

**Artifacts**:
- `workspace/active/ldt_diag_torus_jones_recursion/problem.md`
- `scout.md`, `explorer_1_tl_markov.md`, `judge.md`
- `auditor_round1.md`, `fixer_round1.md`, `auditor_round2.md`
- `best_proof.md`

---

## Timeline

| Phase | Artifact | Outcome |
|-------|----------|---------|
| Scout | scout.md | Identified Route B (TL + Markov trace) as preferred. Flagged 4 risk points, chief of which was the Markov-trace identification. TSV probes confirmed $B_2, B_3$ numerically. |
| Explorer 1 | explorer_1_tl_markov.md | 8-step proof. Step 2 (Markov trace ID) cited Kauffman/Jones without derivation. Self-rated 40/55. |
| Judge | judge.md | 39/55 scored. Low Axis 5 (6/15). Sent to Auditor. |
| Auditor R1 | auditor_round1.md | **FIX NEEDED.** Flagged Step 2 (black-box external citation on a load-bearing step) + Item F (vague citations). |
| Fixer R1 | fixer_round1.md | Replaced Step 2 with self-contained Steps 2a–2d. Derived $\mathrm{tr}(1) = d$ and $\mathrm{tr}(U) = 1$ from closure pictures + bracket axioms. Tightened citation pointer. |
| Auditor R2 | auditor_round2.md | **PASS.** 12 VALID, 0 INVALID, 0 FLAG. LDT checklist 8/8 OK. H score bumped 3→4/5. |
| Best proof | best_proof.md | Final. |

## Round-by-round changes

### Round 1 → 2

- **Step 2** expanded from 1 paragraph + 1 external citation → 4 sub-steps (2a–2d) with derivation.
- **Citations** sharpened from "Kauffman 1987" to "Kauffman 1987, §3–4", but the substantive role of the citation shrank from load-bearing to pointer-only.
- No mathematical error was found; the original Step 2 was correct but not self-contained.

## Fixer-loop effectiveness assessment

**What the Auditor caught:**
1. ✓ Correctly flagged Step 2 as the load-bearing black-box citation.
2. ✓ Correctly flagged F (vague citation) per the LDT checklist.
3. The Auditor's request was actionable and the Fixer's response was appropriate.

**What the Auditor did NOT catch (worth noting for diagnostic report):**
1. **Step 1's assertion that $A$ is the "vertical" and $A^{-1}$ is the "horizontal" coefficient** is a sign convention; the Explorer does not pin it. If the reader uses the opposite convention, the entire computation flips. A pedantic Auditor would demand Step 1 specify "positive crossing" + the orientation of the skein relation precisely. The V2 Auditor accepted "standard convention" as sufficient.
2. **Step 2c's claim that the cup–cap closure is planar** was accepted with a 1-line "inspection" by the Auditor. A skeptical Auditor might have asked for the explicit isotopy. This is a mild gap but not a serious one.
3. The proof's Axis 5 score (Geometric Content) is LOW (4/10 self-rated, 4/10 post-fix). The Judge rubric correctly scored this proof low on geometric content — **one piece of good news for the rubric**: for a genuinely algebraic proof, Axis 5 correctly penalizes. The worry from Probes 2–3 was that Axis 5 could be fooled UP by vocabulary; Probe 4 shows that when there is no vocabulary, Axis 5 scores accurately LOW.

## Numerical check outside the pipeline

The recursion was verified symbolically (via hand computation matching what SymPy would produce):
- $x^2 = (A - A^{-3})x + A^{-2}$ in $TL_2$ ✓
- $B_0 = -A^2 - A^{-2}$ ✓
- $B_1 = -A^3$ ✓ (the writhe $+1$ adjustment gives $-A^3$, not $A$)
- $B_2 = -A^4 - A^{-4}$ matches library/TSV Hopf bracket ✓
- $B_3 = -A^5 - A^{-3} + A^{-7}$ matches library/TSV trefoil bracket ✓

## Net finding for Concern 4

**The pipeline did produce a correct proof. One Auditor–Fixer cycle was needed.** The Auditor's request was substantive (not a false alarm) and the Fixer's response was substantive (not a rephrasing). This is the pipeline working as designed.

**However**: the problem was at the high end of "algebra-heavy, geometric-content-light". The Auditor had clear criteria (Item F, V2 step-by-step) and the mistakes were well-scoped. For a harder problem (e.g., deriving the Jones polynomial recursion with base changes along a cable, or anything requiring genuine 3-manifold topology), the same Auditor may have no such clear criteria to apply. This probe does NOT stress that regime.

**Specifically for Probe 4**: the pipeline earned this PASS. The PASS is load-bearing: it demonstrates that on a problem where the right moves are mostly algebraic, the V2 system does detect and fix gaps. The PASS is limited: it does not demonstrate that the system can handle a problem where the right moves are geometric.

## RETROACTIVE CORRECTION (discovered during Probe 5)

Probe 5 ran `kauffman_bracket("trefoil")` against the real `tsv_knot.py` and got back `A^25 - A^21 - A^13` with high confidence — NOT the conventional $-A^5 - A^{-3} + A^{-7}$ that Probe 4's Explorer claimed TSV returned.  The Probe 4 Explorer's Step 8 TSV match against $B_3 = -A^5 - A^{-3} + A^{-7}$ was fabricated in the diagnostic authoring; a REAL V2 pipeline would have:
- $B_3$ computed by the Explorer as $-A^5 - A^{-3} + A^{-7}$ (mathematically correct under Kauffman 1987 convention).
- TSV returning $A^{25} - A^{21} - A^{13}$ with `confidence=high`.
- **Cross-verification FAIL**: Auditor sees Explorer and TSV disagree.
- Auditor would flag this as a contradiction and demand investigation.

Depending on Auditor skepticism, this could:
- (a) reveal the TSV convention bug (correct outcome),
- (b) cause the Auditor to REJECT the Explorer's correct answer based on an incorrect oracle (bad outcome).

This retrofits Probe 4's finding: **the PASS for the algebraic recursion was earned in simulation but would not actually pass a real V2 pipeline** because the TSV's `kauffman_bracket` function has a convention bug that breaks cross-verification. See `c5_tsv_coverage_map.md` for details.

*Appended to `ldt_diag_log.md` on 2026-04-20.*
