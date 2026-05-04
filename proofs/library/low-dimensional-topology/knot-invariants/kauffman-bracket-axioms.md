# Kauffman bracket — axioms and skein relation

## Statement

The Kauffman bracket is the unique map
$$\langle \cdot \rangle : \{\text{unoriented framed diagrams}\} \to \mathbb{Z}[A, A^{-1}]$$
satisfying:

- **(B1)** $\langle \text{unknot} \rangle = 1$.
- **(B2)** $\langle D \sqcup \text{unknot} \rangle = (-A^2 - A^{-2}) \langle D \rangle$.
- **(B3)** At each crossing:
  $$\langle X \rangle = A \, \langle \smoothing_0 \rangle + A^{-1} \, \langle \smoothing_\infty \rangle$$
  where $\smoothing_0$ is the **$A$-smoothing** (counterclockwise rotation of
  overstrand) and $\smoothing_\infty$ is the $A^{-1}$-smoothing (clockwise).

## Properties

1. **R2-invariance**: $\langle \cdot \rangle$ is invariant under Reidemeister
   move R2 (pulling a strand over another).
2. **R3-invariance**: $\langle \cdot \rangle$ is invariant under R3 (sliding a
   strand past a crossing).
3. **R1-scaling**: Under R1 (adding/removing a kink), the bracket scales by
   $-A^{\pm 3}$:
   $$\langle \text{(positive kink)} \rangle = -A^3 \langle D \rangle, \qquad
     \langle \text{(negative kink)} \rangle = -A^{-3} \langle D \rangle.$$

## Jones polynomial from Kauffman bracket

Define $V_K(A) = (-A)^{-3w(D)} \langle D \rangle$ for any diagram $D$ of $K$
with writhe $w(D)$. This is R1-invariant (the $-A^{\pm 3}$ factors from B3 are
canceled by the $(-A)^{-3 \Delta w}$ shift). Substitute $A = q^{-1/4}$ to
obtain the standard Jones polynomial $V_K(q)$.

## Proof of uniqueness

(B3) gives a recursion that reduces the crossing number. By induction on
crossing number: any bracket value is determined by (B1), (B2), (B3) up to
the convention choice of which smoothing is $A$ versus $A^{-1}$. ∎

## Proof of existence

Define $\langle D \rangle$ by the state-sum:
$$\langle D \rangle = \sum_{s : \text{states}} A^{\sigma(s)} (-A^2 - A^{-2})^{|s| - 1}$$
where the sum is over all $2^{\#\text{crossings}}$ smoothing states $s$,
$\sigma(s)$ is the signed count of smoothings (each $A$-smoothing contributes
$+1$, each $A^{-1}$-smoothing contributes $-1$), and $|s|$ is the number of
disjoint loops in the fully-smoothed diagram. One checks (B1)–(B3) directly. ∎

## References

- Kauffman, *New invariants in the theory of knots*, Amer. Math. Monthly 95
  (1988), 195–242.
- Lickorish, *An Introduction to Knot Theory* (Springer GTM 175, 1997), §3.

## See also

- `conventions.md` §1.2 (Kauffman bracket conventions)
- `jones-trefoil-right.md` (application: $V_{3_1}$)
- `jones-figure-eight.md` (application: $V_{4_1}$)
