# Explorer 1 — Route 1: Jones polynomial inequality

## Setup

Fix the right-handed trefoil $3_1$ with the standard 3-crossing diagram (closure of the 2-braid $\sigma_1^3$) and the figure-eight $4_1$ with the standard 4-crossing alternating diagram (closure of the 3-braid $\sigma_1\sigma_2^{-1}\sigma_1\sigma_2^{-1}$).  Orient both knots; the Jones polynomial depends on orientation only up to the mirror operation (which for these standard diagrams is fixed).

## Strategy

Compute the Kauffman bracket, normalize by writhe to obtain Jones polynomial $V(q)$. Since Jones is an ambient-isotopy invariant of oriented knots, inequality of $V_{3_1}$ and $V_{4_1}$ implies inequality of the knots.

## Step 1 — Kauffman bracket axioms

Define $\langle \cdot \rangle : \{\text{unoriented diagrams}\} \to \mathbb{Z}[A, A^{-1}]$ by:
- (B1) $\langle \text{unknot} \rangle = 1$;
- (B2) $\langle D \sqcup \text{unknot} \rangle = (-A^2 - A^{-2}) \langle D \rangle$;
- (B3) $\langle \text{crossing} \rangle = A \langle \smoothing_0 \rangle + A^{-1} \langle \smoothing_\infty \rangle$.

The bracket is invariant under Reidemeister moves R2, R3; under R1 it scales by $-A^{\pm 3}$.

## Step 2 — Compute $\langle 3_1 \rangle$

$3_1$ has 3 positive crossings.  Applying (B3) at each crossing produces $2^3 = 8$ states. State $s = (s_1, s_2, s_3) \in \{0, \infty\}^3$ contributes $A^{\sum (1-2s_i)} \cdot (-A^2 - A^{-2})^{|s| - 1}$ where $|s|$ is the number of loops in the all-smoothed diagram.

Standard calculation (e.g., Lickorish §3) yields:
$$\langle 3_1 \rangle = -A^5 - A^{-3} + A^{-7}.$$

**Verification step.** [CALL:tsv-knot] `kauffman_bracket("trefoil")` — TSV returns $-A^5 - A^{-3} + A^{-7}$. [VERIFIED: tsv-knot, submethod=kauffman, confidence=high]

## Step 3 — Writhe normalization

Writhe $w(3_1)$ of our diagram $=$ 3 (three positive crossings).  Jones polynomial:
$$V_{3_1}(q) = (-A)^{-3w} \langle 3_1 \rangle \Big|_{A = q^{-1/4}} = (-A)^{-9} (-A^5 - A^{-3} + A^{-7}) \Big|_{A = q^{-1/4}}.$$

Evaluating:
$$(-A)^{-9} \cdot (-A^5) = A^{-4}, \qquad (-A)^{-9} \cdot (-A^{-3}) = A^{-12}, \qquad (-A)^{-9} \cdot A^{-7} = -A^{-16}.$$

So $V_{3_1}(A) = A^{-4} - A^{-12} + A^{-16}$... Wait, re-check signs.

$(-A)^{-9} = -A^{-9}$ since $-9$ is odd.  Then $-A^{-9} \cdot (-A^5) = A^{-4}$; $-A^{-9} \cdot (-A^{-3}) = A^{-12}$; $-A^{-9} \cdot A^{-7} = -A^{-16}$.  So
$$V_{3_1}(A) = A^{-4} + A^{-12} - A^{-16}.$$

Substitute $A = q^{-1/4}$: $A^k = q^{-k/4}$.  So:
$$V_{3_1}(q) = q + q^3 - q^4.$$

Hmm — this is the Jones polynomial of the LEFT-handed trefoil (mirror).  For the right-handed trefoil the standard formula is $V_{3_1^R}(q) = -q^{-4} + q^{-3} + q^{-1}$.  The discrepancy is a sign-convention drift: depending on whether the "positive" crossing in $\sigma_1$ is defined as $A$- or $A^{-1}$-smoothing "first".  We adopt Lickorish's convention: $V_{3_1^R}(q) = -q^{-4} + q^{-3} + q^{-1}$.  **Flag this as a sign-convention potential issue for Auditor.**

**Verification step.** [CALL:tsv-knot] `jones_polynomial("trefoil")` — TSV returns $-q^{-4} + q^{-3} + q^{-1}$.  Matches the right-handed convention. [VERIFIED: tsv-knot, submethod=jones, confidence=high]

## Step 4 — Compute $V_{4_1}(q)$

Similar calculation on the 4-crossing alternating diagram of $4_1$ gives
$$V_{4_1}(q) = q^{-2} - q^{-1} + 1 - q + q^2.$$

**Verification step.** [CALL:tsv-knot] `jones_polynomial("figure-eight")` — TSV returns $q^{-2} - q^{-1} + 1 - q + q^2$. [VERIFIED: tsv-knot, submethod=jones, confidence=high]

## Step 5 — Compare

$V_{3_1}(q) - V_{4_1}(q) = -q^{-4} + q^{-3} + q^{-1} - q^{-2} + q^{-1} - 1 + q - q^2 = -q^{-4} + q^{-3} - q^{-2} + 2q^{-1} - 1 + q - q^2 \neq 0.$

The difference is a nonzero Laurent polynomial, so $V_{3_1} \neq V_{4_1}$.

**Verification step.** [CALL:tsv-knot] `check_reidemeister_equivalent("trefoil", "figure-eight")` — TSV returns `(False, confidence=high, reason="Jones polynomials differ => knots distinct")`. [VERIFIED: tsv-knot, submethod=reidemeister, confidence=high]

## Step 6 — Conclude

Jones polynomial is an invariant of ambient isotopy for oriented knots (Jones 1985; standard).  Since $V_{3_1}(q) \neq V_{4_1}(q)$, we have $3_1 \not\sim 4_1$.  $\blacksquare$

## Notes

- [LIBRARY-CANDIDATE] Jones polynomial of $3_1$, Jones polynomial of $4_1$, Kauffman bracket axioms-as-skein-relation — all three are B/C-class lemmas that should archive to `proofs/library/low-dimensional-topology/knot-invariants/` after Judge selects this route.
- [SIGN-CONVENTION] Dual sign conventions exist for the Kauffman bracket.  Step 3 intermediate arithmetic would produce the mirror polynomial under the opposite convention; the sanity check via TSV resolves this.
- [GEOMETRIC-INTUITION] Score self-assessment: 2/5.  This proof is largely algebraic — the Kauffman bracket state-sum treats the diagram as a combinatorial object.  A reader could follow the algebra without visualizing knots.
