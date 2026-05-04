# Problem: Trefoil vs Figure-Eight — Inequivalence (Round 0.5)

## Source
- Paper: classical (Kauffman, Lickorish — textbook exposition)
- Context: **Round 0.5** of LDT extension of Math Agent V2. Re-run of Round 0
  with Stage 3 fixes applied. Same problem, compare pipeline behavior.

## Statement

Let $K_{\text{trefoil}} = 3_1$ (the right-handed trefoil knot) and
$K_{\text{fig8}} = 4_1$ (the figure-eight knot), both viewed as oriented
knots in $S^3$. Prove:

$$K_{\text{trefoil}} \not\sim K_{\text{fig8}}$$

where $\sim$ denotes ambient isotopy in $S^3$.

## Difficulty
standard — undergraduate-level, textbook exercise.

## Fixes applied since Round 0

1. **Fix 1 (Judge rubric)**: `~/.claude/skills/math-proof-agent/prompts/judge_ldt.md`
   adds a 5th axis "Geometric Content" (×1.5 multiplier) — total now 55 points.
2. **Fix 2 (Convention registry)**:
   `proofs/library/low-dimensional-topology/conventions.md` fixes Jones
   (Lickorish), Alexander (reduced Burau dim $n-1$ with normalizer
   $1+t+\cdots+t^{n-1}$), knot chirality.
3. **Fix 3 (Library lemmas)**: 3 lemmas archived in
   `proofs/library/low-dimensional-topology/knot-invariants/`:
   - `jones-trefoil-right.md`
   - `jones-figure-eight.md`
   - `kauffman-bracket-axioms.md`

## What Round 0.5 should produce

- Delta report: how did the fixes change pipeline behavior?
- Evaluation: did Route 3 (hyperbolic volume) win this time?
- Proof of record: `best_proof.md`.
