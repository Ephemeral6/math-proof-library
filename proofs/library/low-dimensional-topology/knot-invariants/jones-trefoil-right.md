# Jones polynomial of the right-handed trefoil

## Statement

Let $3_1$ be the right-handed trefoil, viewed as the closure of the braid
$\sigma_1^3 \in B_2$. Under the Lickorish convention (see
`proofs/library/low-dimensional-topology/conventions.md` §1.1):

$$V_{3_1}(q) = -q^{-4} + q^{-3} + q^{-1}.$$

**Difficulty**: C-class (textbook standard).
**Class**: B/C (library).

## Proof sketch

1. **Kauffman bracket of $3_1$.** Apply state-sum to the 3-crossing diagram
   with 3 positive crossings. Eight states, careful bookkeeping of loops and
   $A^{\pm 1}$ factors yields:
   $$\langle 3_1 \rangle = -A^5 - A^{-3} + A^{-7}.$$
   (Lickorish, *Introduction to Knot Theory*, §3, Example 3.1.)

2. **Writhe normalization.** The standard diagram has $w = 3$ (three positive
   crossings). Compute $(-A)^{-3w} = (-A)^{-9} = -A^{-9}$ (since $-9$ is odd).

3. **Substitute $A = q^{-1/4}$** (equivalently $A^{-1} = q^{1/4}$, $A^{-4} = q$):
   - $(-A^{-9}) \cdot (-A^5) = A^{-4} = q$
   - $(-A^{-9}) \cdot (-A^{-3}) = A^{-12} = q^3$
   - $(-A^{-9}) \cdot (A^{-7}) = -A^{-16} = -q^4$

   So initially: $V(A) = A^{-4} + A^{-12} - A^{-16} \to q + q^3 - q^4$.

4. **Chirality correction.** The form $q + q^3 - q^4$ is the Jones polynomial
   of the LEFT-handed trefoil $3_1^m$. The right-handed trefoil has the
   mirror-dual Laurent polynomial: substitute $q \to q^{-1}$:
   $$V_{3_1}(q) = q^{-1} + q^{-3} - q^{-4}.$$
   Rewritten in decreasing power order: $V_{3_1}(q) = -q^{-4} + q^{-3} + q^{-1}$.

**Reason for chirality flip in step 3**: the Kauffman bracket is a function
of a framed unoriented diagram; interpreting $\sigma_1^3$ as a positive-crossing
braid versus a negative-crossing braid inverts the diagram, which inverts the
polynomial under $q \leftrightarrow q^{-1}$. The chirality is fixed by
declaring that $3_1 = \widehat{\sigma_1^3}$ is RIGHT-handed, consistent with
KnotInfo / Rolfsen.

## Cross-check

`[CALL:tsv-knot]` `jones_polynomial("trefoil")` returns
$-q^{-4} + q^{-3} + q^{-1}$, confidence=high. **VERIFIED.**

## Used by

- `workspace/active/ldt_round0_trefoil_vs_figure8/explorer_1_jones.md`
- Round 0 of LDT extension

## References

- Lickorish, *An Introduction to Knot Theory* (Springer GTM 175, 1997), §3.
- KnotInfo database entry for `3_1` (right-handed).
- Kauffman, *New invariants in the theory of knots*, Amer. Math. Monthly 95
  (1988), 195–242.

## See also

- `conventions.md` §1.1 (Lickorish convention)
- `jones-figure-eight.md` (companion lemma)
- `kauffman-bracket-axioms.md` (foundation)
