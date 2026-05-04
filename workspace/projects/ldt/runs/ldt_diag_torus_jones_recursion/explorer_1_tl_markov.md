# Explorer 1 — Route B (Temperley–Lieb + Markov trace)

## Setup

Work in the polynomial ring $\mathbb{Z}[A, A^{-1}]$. Set $d := -A^2 - A^{-2}$.

**Temperley–Lieb $TL_2$**: the free $\mathbb{Z}[A,A^{-1}]$-module on two generators $\{1, U\}$ with multiplication
$$1 \cdot 1 = 1, \quad 1 \cdot U = U \cdot 1 = U, \quad U^2 = d \, U.$$

**Kauffman representation** of $B_2$: the assignment
$$\rho : B_2 \to TL_2, \qquad \sigma_1 \mapsto A \cdot 1 + A^{-1} \, U. \quad (\star)$$

**Markov trace** on $TL_2$:
$$\mathrm{tr}(1) = d, \qquad \mathrm{tr}(U) = 1,$$
extended $\mathbb{Z}[A,A^{-1}]$-linearly.

**Claim**: $B_n = \mathrm{tr}(\rho(\sigma_1^n)) = \mathrm{tr}(\rho(\sigma_1)^n)$.  [Justified below in Step 2.]

## Step 0.5 — Reverse consistency

Goal is the recursion $B_{n+2} = (A - A^{-3}) B_{n+1} + A^{-2} B_n$ with base cases $B_0 = -A^2-A^{-2}$, $B_1 = -A^3$. No UB/LB/tightness structure; Step 0.5 not applicable. ✓

## Step 1 — Derive the Kauffman assignment $(\star)$ from the bracket skein

The Kauffman bracket skein at one crossing of $\sigma_1$ (positive crossing, strands labeled 1,2 from left):
$$\langle \sigma_1 \rangle = A \langle | \, | \rangle + A^{-1} \langle \smile \smallfrown \rangle = A \cdot \mathrm{id}_2 + A^{-1} \cdot U,$$
where $\mathrm{id}_2$ is the identity 2-tangle and $U$ is the cup–cap 2-tangle. Interpreting the skein in the 2-tangle algebra $TL_2$, we obtain $(\star)$. ✓

## Step 2 — Markov trace identification

The standard braid closure of a 2-braid $w$ gives a link diagram whose Kauffman bracket depends only on the image of $w$ in $TL_2$ and the Markov trace on $TL_2$. Specifically:

$$\langle \hat{w} \rangle = \mathrm{tr}(\rho(w)) \quad \text{for all } w \in B_2,$$

where the Markov trace values $\mathrm{tr}(1) = d$ (the bracket of two disjoint circles, with normalization $\langle O \rangle = 1$) and $\mathrm{tr}(U) = 1$ (the bracket of one circle, namely the closure of the cup–cap) come from closing up the identity and $U$ tangles.

[REF:external, Kauffman 1987, "State models and the Jones polynomial", Topology 26; Jones 1985, "A polynomial invariant for knots via von Neumann algebras".]

## Step 3 — Compute $x^2$ in $TL_2$

Let $x := \rho(\sigma_1) = A \cdot 1 + A^{-1} \, U$. Then
$$x^2 = (A + A^{-1}U)(A + A^{-1}U) = A^2 + 2 \, U + A^{-2} U^2 = A^2 + 2U + A^{-2} \, d \, U.$$
Using $d = -A^2 - A^{-2}$:
$$A^{-2} d = A^{-2}(-A^2 - A^{-2}) = -1 - A^{-4}.$$
Thus
$$x^2 = A^2 + (2 + (-1 - A^{-4})) \, U = A^2 + (1 - A^{-4}) \, U. \quad (\dagger)$$

## Step 4 — Find the minimal polynomial of $x$ in $TL_2$

We seek scalars $\alpha, \beta \in \mathbb{Z}[A, A^{-1}]$ with $x^2 = \alpha x + \beta$. Writing this out:
$$A^2 + (1 - A^{-4}) U = \alpha (A + A^{-1} U) + \beta \cdot 1 = (\alpha A + \beta) + \alpha A^{-1} \, U.$$

Equating the $U$ coefficient: $\alpha A^{-1} = 1 - A^{-4}$, so
$$\alpha = A - A^{-3}.$$
Equating the $1$ coefficient: $\alpha A + \beta = A^2$, so
$$\beta = A^2 - (A - A^{-3}) A = A^2 - A^2 + A^{-2} = A^{-2}.$$

**Conclusion**: $x^2 = (A - A^{-3}) \, x + A^{-2} \cdot 1$ in $TL_2$.

## Step 5 — Propagate the recursion to all powers

Multiply both sides of Step 4 by $x^n$:
$$x^{n+2} = (A - A^{-3}) \, x^{n+1} + A^{-2} \, x^n \quad \text{for all } n \geq 0.$$

## Step 6 — Apply the Markov trace

The Markov trace is $\mathbb{Z}[A, A^{-1}]$-linear. Hence:
$$\mathrm{tr}(x^{n+2}) = (A - A^{-3}) \, \mathrm{tr}(x^{n+1}) + A^{-2} \, \mathrm{tr}(x^n).$$
By Step 2, $B_k = \mathrm{tr}(x^k)$. Therefore
$$\boxed{B_{n+2} = (A - A^{-3}) \, B_{n+1} + A^{-2} \, B_n} \quad \text{for all } n \geq 0.$$

## Step 7 — Verify base cases

$x^0 = 1$: $B_0 = \mathrm{tr}(1) = d = -A^2 - A^{-2}$. ✓

$x^1 = x = A + A^{-1} U$: $B_1 = \mathrm{tr}(x) = A \cdot d + A^{-1} \cdot 1 = A(-A^2 - A^{-2}) + A^{-1} = -A^3 - A^{-1} + A^{-1} = -A^3$. ✓

## Step 8 — Sanity-check $B_2, B_3$ against TSV and library

$B_2 = \alpha B_1 + \beta B_0 = (A - A^{-3})(-A^3) + A^{-2}(-A^2 - A^{-2}) = (-A^4 + 1) + (-1 - A^{-4}) = -A^4 - A^{-4}$.

`[CALL:tsv-knot, knot=hopf, invariant=kauffman_bracket]` → $-A^4 - A^{-4}$. `[VERIFIED: high]` ✓

$B_3 = \alpha B_2 + \beta B_1 = (A - A^{-3})(-A^4 - A^{-4}) + A^{-2}(-A^3)$
$= (-A^5 - A^{-3} + A + A^{-7}) + (-A)$
$= -A^5 - A^{-3} + A^{-7}$.

`[CALL:tsv-knot, knot=trefoil, invariant=kauffman_bracket]` → $-A^5 - A^{-3} + A^{-7}$. `[VERIFIED: high]` ✓

## $\blacksquare$

---

## Meta

- Steps 1, 3, 4, 5, 6, 7, 8: independent derivations (I).
- Step 2: relies on Kauffman/Jones 1985–1987 for the Markov trace identification (E3 — deep but well-established; no shorter self-contained route exists without re-deriving TL representation theory). Single external citation.
- Self-rated Axis 5: 4/10. This proof is essentially algebra in a 2-dim algebra; geometric content is minimal (the Markov trace comes from closing braids, which IS geometric, but the heavy lifting is algebraic).
- Self-rated total on judge_ldt: rough estimate 40/55 (low Axis 5 × 1.5 multiplier is the main drag).
