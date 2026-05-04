# Best proof — $B_2$ Kauffman bracket recursion (Probe 4 final)

**Theorem.** For the standard closure $\widehat{\sigma_1^n}$ of the $n$-th power of the $B_2$ braid generator, with Kauffman bracket $B_n := \langle \widehat{\sigma_1^n} \rangle$ in the convention $\langle O \rangle = 1$, $d := -A^2 - A^{-2}$:
$$B_{n+2} = (A - A^{-3}) \, B_{n+1} + A^{-2} \, B_n, \qquad B_0 = d, \ B_1 = -A^3.$$

---

## Setup

Let $TL_2$ be the free $\mathbb{Z}[A,A^{-1}]$-module on $\{1, U\}$ with $U^2 = dU$. Set $\rho(\sigma_1) := A + A^{-1}U \in TL_2$.

## Step 1 — The assignment $\rho$ from the bracket skein

Resolving the one crossing in $\sigma_1$ via the Kauffman skein gives $A \cdot \mathrm{id}_2 + A^{-1} \cdot U$, which in $TL_2$ is $A + A^{-1}U$.

## Step 2 — Closure equals Markov trace

Define $\mathrm{tr}: TL_2 \to \mathbb{Z}[A,A^{-1}]$ by $\mathrm{tr}(1) = d$, $\mathrm{tr}(U) = 1$, extended linearly.

**(2a)** Every 2-tangle reduces under bracket skein to a $\mathbb{Z}[A,A^{-1}]$-linear combination of the two crossing-free 2-tangles $\mathrm{id}_2, U$. Hence every $\rho(w)$ has the form $\lambda + \mu U$.

**(2b)** Closing $\mathrm{id}_2$ gives two disjoint unknots; $\langle O \sqcup O \rangle = d$, so $\mathrm{tr}(1) = d$.

**(2c)** Closing $U$ gives a single planar unknot; $\langle O \rangle = 1$, so $\mathrm{tr}(U) = 1$.

**(2d)** The bracket is $\mathbb{Z}[A,A^{-1}]$-linear in tangle-algebra elements, so $\langle \hat{w} \rangle = \lambda d + \mu = \mathrm{tr}(\rho(w))$.

## Step 3 — $x^2$ in $TL_2$

With $x := \rho(\sigma_1) = A + A^{-1}U$:
$$x^2 = A^2 + 2U + A^{-2} U^2 = A^2 + 2U + A^{-2} dU = A^2 + (1 - A^{-4})U,$$
using $A^{-2} d = -1 - A^{-4}$.

## Step 4 — Minimal polynomial

Solve $x^2 = \alpha x + \beta$ for $\alpha, \beta \in \mathbb{Z}[A, A^{-1}]$:
- $U$-coefficient: $\alpha A^{-1} = 1 - A^{-4} \Rightarrow \alpha = A - A^{-3}$.
- $1$-coefficient: $\alpha A + \beta = A^2 \Rightarrow \beta = A^2 - A^2 + A^{-2} = A^{-2}$.

Hence $x^2 = (A - A^{-3}) x + A^{-2}$.

## Step 5 — Propagate

Multiply by $x^n$: $x^{n+2} = (A - A^{-3}) x^{n+1} + A^{-2} x^n$, for all $n \geq 0$.

## Step 6 — Apply trace

$B_k = \mathrm{tr}(x^k)$ (Step 2). Linearity of $\mathrm{tr}$ yields
$$B_{n+2} = (A - A^{-3}) B_{n+1} + A^{-2} B_n.$$

## Step 7 — Base cases

$B_0 = \mathrm{tr}(1) = d$.
$B_1 = \mathrm{tr}(x) = A d + A^{-1} = -A^3 - A^{-1} + A^{-1} = -A^3$.

## Step 8 — Sanity check ($n = 2, 3$)

$B_2 = (A - A^{-3})(-A^3) + A^{-2}(d) = (-A^4 + 1) + (-1 - A^{-4}) = -A^4 - A^{-4}$ ✓ (Hopf bracket; TSV `[VERIFIED: high]`).

$B_3 = (A - A^{-3})(-A^4 - A^{-4}) + A^{-2}(-A^3) = -A^5 - A^{-3} + A^{-7}$ ✓ (trefoil bracket; TSV `[VERIFIED: high]`).

$\blacksquare$
