# Jones polynomial of the figure-eight knot

## Statement

Let $4_1$ be the figure-eight knot, viewed as the closure of
$\sigma_1 \sigma_2^{-1} \sigma_1 \sigma_2^{-1} \in B_3$. Under the Lickorish
convention (see `conventions.md` §1.1):

$$V_{4_1}(q) = q^{-2} - q^{-1} + 1 - q + q^2.$$

Note: $4_1$ is **amphichiral** ($4_1 \cong 4_1^m$), which is reflected in the
symmetry $V_{4_1}(q) = V_{4_1}(q^{-1})$.

**Difficulty**: C-class (textbook standard).
**Class**: B/C (library).

## Proof sketch

1. **Standard alternating diagram.** Use the 4-crossing alternating diagram
   (two positive and two negative crossings, writhe $w = 0$).

2. **Kauffman bracket.** State-sum on 16 states; direct computation gives
   $$\langle 4_1 \rangle = A^{-8} - A^{-4} + 1 - A^4 + A^8.$$
   (Lickorish, *Introduction to Knot Theory*, §3, Example 3.2.)

3. **Writhe normalization.** $(-A)^{-3w} = (-A)^0 = 1$ since $w = 0$.

4. **Substitute** $A = q^{-1/4}$: $A^{8} \to q^{-2}$, $A^4 \to q^{-1}$,
   $A^{-4} \to q$, $A^{-8} \to q^2$. So
   $$V_{4_1}(q) = q^2 - q + 1 - q^{-1} + q^{-2}.$$
   Rewriting in ascending-power form: $V_{4_1}(q) = q^{-2} - q^{-1} + 1 - q + q^2$.

5. **Amphichirality cross-check.** $V_{4_1}(q^{-1}) = q^2 - q + 1 - q^{-1} + q^{-2}
   = V_{4_1}(q)$. ✓

## Cross-check

`[CALL:tsv-knot]` `jones_polynomial("figure-eight")` returns
$q^{-2} - q^{-1} + 1 - q + q^2$, confidence=high. **VERIFIED.**

## Used by

- `workspace/active/ldt_round0_trefoil_vs_figure8/explorer_1_jones.md`
- Round 0 of LDT extension

## References

- Lickorish, *An Introduction to Knot Theory* (Springer GTM 175, 1997), §3.
- KnotInfo database entry for `4_1`.

## See also

- `conventions.md` §1.1 (Lickorish convention)
- `jones-trefoil-right.md` (companion lemma, non-amphichiral case)
- `kauffman-bracket-axioms.md` (foundation)
