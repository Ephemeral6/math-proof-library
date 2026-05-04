# Classical invariants of spiral knots

## Source

REU-level research problem. Difficulty: **research**. No external references supplied;
the pipeline must proceed from the statements and allowed background below.

## Allowed background

1. A **knot** is an embedding $S^1 \hookrightarrow S^3$, considered up to ambient
   isotopy.

2. The **braid group** $B_p$ on $p$ strands has standard generators
   $\sigma_1, \ldots, \sigma_{p-1}$ subject to the Artin relations
   $\sigma_i \sigma_{i+1} \sigma_i = \sigma_{i+1} \sigma_i \sigma_{i+1}$ and
   $\sigma_i \sigma_j = \sigma_j \sigma_i$ for $|i-j| \ge 2$.

3. The **closure** $\widehat{\beta}$ of a braid $\beta \in B_p$ is the oriented
   link obtained by joining the $i$-th top endpoint to the $i$-th bottom
   endpoint of the braid, for $1 \le i \le p$.

4. Given $p \ge 2$, $q \ge 1$, and $\epsilon = (\epsilon_1, \ldots, \epsilon_{p-1})
   \in \{\pm 1\}^{p-1}$, the **spiral knot** $S(p, q, \epsilon)$ is the closure
   of the braid
   $$\beta_{p,q,\epsilon} \;=\; \left(\sigma_1^{\epsilon_1} \sigma_2^{\epsilon_2}
   \cdots \sigma_{p-1}^{\epsilon_{p-1}}\right)^q \;\in\; B_p.$$
   (The assumption that the closure is a *knot* — one component — is an
   implicit hypothesis on $(p, q, \epsilon)$; you may assume it throughout.)

5. The **genus** $g(K)$ of a knot $K$ is the minimum genus of a compact
   oriented surface $F \subset S^3$ with $\partial F = K$ (a Seifert surface).

6. The **Alexander polynomial** of $K$ is defined via a Seifert surface $F$
   with Seifert matrix $M$ (representing the Seifert form $V: H_1(F) \times
   H_1(F) \to \mathbb{Z}$) as
   $$\Delta_K(t) \;=\; \det(M - t M^T) \in \mathbb{Z}[t, t^{-1}],$$
   defined up to multiplication by $\pm t^k$. The normalization convention used
   below is $\Delta_K(1) = \pm 1$ and the leading coefficient sign fixed by
   context.

7. The **determinant** of a knot is $\det(K) = |\Delta_K(-1)|$.

8. **Seifert's algorithm** (may be invoked): given an oriented diagram of $K$,
   Seifert circles + twisted bands produce a Seifert surface for $K$.
   (Scout/Explorer must tag this as a black-box reference when invoked; the
   algorithm itself is standard and is considered low-depth.)

## Definitions used in the statements

Define $\mu : \{1, \ldots, p-1\} \to \{1, 0, t\}$ from $\epsilon$ by
$$\mu(i) \;=\; \begin{cases} 1 & \epsilon_i = +1, \\ t & \epsilon_i = -1, \\
0 & \text{(unused in this problem — reserved for later generalizations).}
\end{cases}$$

Define polynomials $C_k(x, t) \in \mathbb{Z}[x, t, t^{-1}]$ by the recursion
$$C_k(x, t) \;=\; \left(\frac{\mu(k)^2}{t} + x\right) C_{k-1}(x, t)
\;-\; \frac{\mu(k-1)\, \mu(k)\, x}{t}\, C_{k-2}(x, t),$$
with $C_0 = 1$ and $C_1(x, t) = \mu(1)^2/t + x$.

## Statements to prove

### Theorem 3.5 (Alexander polynomial of a spiral knot)

For every spiral knot $S(p, q, \epsilon)$ (with $p \ge 2, q \ge 1$, and
$\epsilon \in \{\pm 1\}^{p-1}$ such that $\widehat{\beta}_{p,q,\epsilon}$ is a
knot),
$$\Delta_{S(p, q, \epsilon)}(t) \;=\; \prod_{\ell=1}^{q-1}
C_{p-1}\!\left(e^{2\pi i \ell / q}, t\right),$$
up to the standard $\pm t^k$ ambiguity of the Alexander polynomial.

### Theorem 4.2 (Genus of a spiral knot)

For every spiral knot $S(p, q, \epsilon)$ with $p \ge 2$ and $q \ge 1$,
$$g\!\left(S(p, q, \epsilon)\right) \;=\; \frac{(p-1)(q-1)}{2}.$$

## Base cases (TSV-verifiable)

The following small-parameter identifications may be used as TSV ground-truth
cross-checks on any intermediate formula:

- $S(2, 3, (+1)) \;=\; T(2,3) \;=\; 3_1$ (right-handed trefoil); expected
  $\Delta = t^2 - t + 1$, $g = 1$.
- $S(3, 2, (+1, +1)) \;=\; T(3,2) \;=\; 3_1$; expected $\Delta = t^2 - t + 1$,
  $g = 1$.
- $S(3, 2, (+1, -1)) \;=\; 4_1$ (figure-eight); expected $\Delta = -t^2 + 3t - 1$
  (equivalently $t^2 - 3t + 1$ up to sign), $g = 1$.
- $S(3, 5, (+1, -1)) \;=\; 10_{123}$; $g = 4$. (TSV has `alexander_polynomial`
  for $10_{123}$ if in scope; otherwise Explorer may tag
  `method=none, reason=out-of-TSV-scope`.)

In the formulas above, $(p-1)(q-1)/2$ correctly gives $g = 1, 1, 1, 4$ for
these cases, and the product formula for $\Delta$ reduces to the classical
answers. These provide base-case checks, **not a proof of the general formula**.

## Difficulty

Research. Theorem 3.5 is the main claim; Theorem 4.2 is expected to follow from
(a) a concrete Seifert surface exhibiting the upper bound, and (b) a degree
count on $\Delta_{S(p,q,\epsilon)}$ extracted from Theorem 3.5.

## What the pipeline must deliver

A proof, a partial proof with explicit stuck points, or an honest REJECT_ALL
with diagnosis of what is missing. All citations must be tagged at the depth
level (L1/L2/L3) used by the LDT auditor checklist.
