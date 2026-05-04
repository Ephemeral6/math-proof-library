# Explorer 1 — Route 1: Jones polynomial (library-citation form)

## Setup

Fix $3_1$ = right-handed trefoil = $\widehat{\sigma_1^3} \in B_2$, oriented;
$4_1$ = figure-eight = $\widehat{\sigma_1 \sigma_2^{-1} \sigma_1 \sigma_2^{-1}} \in B_3$,
oriented. Conventions: `proofs/library/low-dimensional-topology/conventions.md` §1.1
(Lickorish Jones convention, $A = q^{-1/4}$).

## Strategy

Cite archived library lemmas for both Jones polynomials; compare; done.

## Step 1 — Retrieve $V_{3_1}(q)$ from library

[REF:library] `proofs/library/low-dimensional-topology/knot-invariants/jones-trefoil-right.md`:
$$V_{3_1}(q) = -q^{-4} + q^{-3} + q^{-1}.$$

**Verification step.** [CALL:tsv-knot] `jones_polynomial("trefoil")` — TSV
returns $-q^{-4} + q^{-3} + q^{-1}$. [VERIFIED: tsv-knot, submethod=jones,
confidence=high]

## Step 2 — Retrieve $V_{4_1}(q)$ from library

[REF:library] `proofs/library/low-dimensional-topology/knot-invariants/jones-figure-eight.md`:
$$V_{4_1}(q) = q^{-2} - q^{-1} + 1 - q + q^2.$$

**Verification step.** [CALL:tsv-knot] `jones_polynomial("figure-eight")` — TSV
returns $q^{-2} - q^{-1} + 1 - q + q^2$. [VERIFIED: tsv-knot, submethod=jones,
confidence=high]

## Step 3 — Compare

$V_{3_1}(q) - V_{4_1}(q) = -q^{-4} + q^{-3} - q^{-2} + 2q^{-1} - 1 + q - q^2.$

This is a nonzero Laurent polynomial, so $V_{3_1} \ne V_{4_1}$.

Equivalently, knot determinants: $|\Delta_{3_1}(-1)| = 3$, $|\Delta_{4_1}(-1)| = 5$
(also consistent via $|V_K(-1)| = \det(K)$: $V_{3_1}(-1) = 1 + (-1) + (-1) = -1$
wait let me recompute: $-(-1)^{-4} + (-1)^{-3} + (-1)^{-1} = -1 + (-1) + (-1) = -3$;
$|V_{3_1}(-1)| = 3$. And $V_{4_1}(-1) = (-1)^{-2} - (-1)^{-1} + 1 - (-1) + (-1)^2
= 1 - (-1) + 1 - (-1) + 1 = 5$; $|V_{4_1}(-1)| = 5$. ✓ Distinct.)

## Step 4 — Conclude

Jones polynomial is an ambient-isotopy invariant of oriented knots (Jones
1985). Since $V_{3_1} \ne V_{4_1}$, $3_1 \not\sim 4_1$. $\blacksquare$

## Notes

- **Proof length**: 4 steps vs 6 in Round 0, because library lemmas collapsed
  the state-sum + writhe-substitution work.
- **No sign-convention stumble**: the Lickorish convention is now registered;
  no mirror polynomial surprise.
- **[GEOMETRIC-INTUITION]** Self-score: **4/10** under the new `judge_ldt.md`
  Axis 5 rubric (6 on the old 0–5 scale). Uses an algebraic invariant without
  engaging geometric structure — slightly better than Round 0's 2/5 only
  because the state-sum-on-diagram step is now abstracted away (the diagram
  is barely mentioned). No visualization of knots occurs.
- **TSV calls**: 2 (both library values re-verified for defense-in-depth).
- **No [STEP-STUCK] tags.**
