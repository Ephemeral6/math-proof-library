# Explorer 1 — Route A (Burau + eigenvalue factorization)

## Overview

Strategy: apply the reduced Burau representation $\bar\rho : B_p \to GL_{p-1}(\mathbb{Z}[t, t^{-1}])$ to the spiral braid $\beta = (\sigma_1^{\epsilon_1} \cdots \sigma_{p-1}^{\epsilon_{p-1}})^q$. Writing $B := \bar\rho(\sigma_1^{\epsilon_1} \cdots \sigma_{p-1}^{\epsilon_{p-1}})$, we have $\bar\rho(\beta) = B^q$. The standard Burau–Alexander formula (dictionary 1.3, convention §1.3) gives
$$\Delta_{\hat\beta}(t) \;\doteq\; \frac{\det(I_{p-1} - B^q)}{1 + t + \cdots + t^{p-1}}\quad\text{(up to $\pm t^k$).}$$
We factor $\det(I - B^q) = \prod_{\ell=0}^{q-1} \det(I - \zeta^\ell B)$ with $\zeta = e^{2\pi i/q}$, cancel the $\ell = 0$ factor against $\Phi_p(t) = 1+t+\cdots+t^{p-1}$, and identify the remaining $\prod_{\ell=1}^{q-1} \det(I - \zeta^\ell B)$ with $\prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)$ via a computational identity

$$\boxed{\det(I_{p-1} - y B) \;=\; t^{\sum_i \epsilon_i} \cdot C_{p-1}(y, t).}$$

This identity was **discovered and checked numerically** for $p \in \{2,3,4\}$ and all $\epsilon \in \{\pm 1\}^{p-1}$ (see stuck point SP-3 and TSV checks). Since $t^{\sum \epsilon_i}$ is a unit, this is exactly the "up to $\pm t^k$" ambiguity of $\Delta$.

**Important honest correction**: the Scout hinted that $B$ is *tridiagonal* in the standard basis. Direct computation at $p=4$ shows this is **false** (see SP-1). The $(1,3)$ entry of $B$ is generically nonzero. The proof therefore does *not* proceed via a tridiagonal char-poly recursion. Instead, we prove the boxed identity above by a different route, outlined in Step 5 and marked with a remaining stuck point SP-3.

For Theorem 4.2, upper bound $g \le (p-1)(q-1)/2$ follows from Seifert's algorithm on the braid closure; lower bound $g \ge (p-1)(q-1)/2$ follows from $2g \ge \deg \Delta$ and a degree count on the RHS of Theorem 3.5.

## Step-by-step proof

### Step 1 [L, tag L2] — Burau–Alexander formula
Invoke dictionary 1.3 and convention §1.3: for any $\beta \in B_p$ whose closure is a knot,
$$\Delta_{\hat\beta}(t) \;=\; \frac{\det(I_{p-1} - \bar\rho(\beta))}{1 + t + \cdots + t^{p-1}} \quad (\text{mod } \pm t^{\mathbb{Z}}).$$
This is the reduced-Burau Alexander-polynomial theorem (Birman 1974, §3). **Tag: L2** (single theorem citation).

### Step 2 [I] — Eigenvalue factorization
Let $B = \bar\rho(\sigma_1^{\epsilon_1} \cdots \sigma_{p-1}^{\epsilon_{p-1}})$, an element of $GL_{p-1}(\mathbb{Z}[t, t^{-1}])$. Then $\bar\rho(\beta) = B^q$.

**Claim**: $\det(I_{p-1} - B^q) = \prod_{\ell=0}^{q-1} \det(I_{p-1} - \zeta^\ell B)$ where $\zeta = e^{2\pi i/q}$.

**Proof**: The scalar factorization $1 - x^q = \prod_{\ell=0}^{q-1}(1 - \zeta^\ell x)$ (Step 2a [L, tag L1]) holds in any commutative ring. Apply it to the matrix $B$ as follows: let $K$ be the algebraic closure of the field of fractions $\mathbb{Q}(t)$, and view $B$ as a matrix over $K$. Over $K$, $B$ has a Jordan form $B = P J P^{-1}$. By the Cayley–Hamilton factorization,
$$\det(I - B^q) \;=\; \prod_{\lambda \in \mathrm{spec}(B)} (1 - \lambda^q)^{m(\lambda)} \;=\; \prod_\lambda \prod_{\ell=0}^{q-1} (1 - \zeta^\ell \lambda)^{m(\lambda)} \;=\; \prod_{\ell=0}^{q-1} \det(I - \zeta^\ell B),$$
where $m(\lambda)$ is the algebraic multiplicity. The identity is initially in $K$, but both sides are elements of $\mathbb{Z}[t, t^{-1}]$ (the LHS by definition; the RHS because reordering turns the product into a symmetric polynomial in the $\zeta^\ell$, which lands in $\mathbb{Z}[t,t^{-1}]$ by Newton's identities applied to $\det(xI - B) \in \mathbb{Z}[t,t^{-1}][x]$). Hence the identity holds over $\mathbb{Z}[t, t^{-1}]$. **Tag: I.**

### Step 3 [I] — The $\ell = 0$ factor
$\det(I_{p-1} - \zeta^0 B) = \det(I_{p-1} - B)$. We show this equals $\pm t^k \cdot \Phi_p(t)$:

**Sub-claim**: $\det(I_{p-1} - B) = \pm t^k \cdot (1 + t + \cdots + t^{p-1})$.

**Proof**: By the classical relation between the reduced and unreduced Burau representations, $\det(I_p - \rho(\beta)) = 0$ for any $\beta \in B_p$ (the full vector $(1,1,\ldots,1)$ is a fixed eigenvector of the unreduced Burau with eigenvalue 1). The transition formula is
$$\det(I_p - \rho(\beta)) = (1 - t^{e(\beta)}) \cdot \det(I_{p-1} - \bar\rho(\beta)) \cdot (1 - t)^{-1} \cdot \frac{1}{\Phi_p(t)^{-1}}\ldots$$
**[STEP-STUCK SP-2]**: the exact factorization of $\det(I - B)$ into $\Phi_p(t) \cdot (\text{unit})$ is a standard but fiddly identity (it uses that $B$ represents a positive braid cyclically permuting the strands modulo $t$-weight). I assert it without a complete derivation. For the three TSV base cases ($p=2,q=3$; $p=3,q=2$ both $\epsilon$) I verified numerically that $\det(I - B)/\Phi_p(t)$ is a unit: see the TSV section below.

Concretely, for $p=2$, $B = [-t]$, so $\det(I - B) = 1 - (-t) = 1+t = \Phi_2(t)$, a ratio of $1$. For $p=3$, direct computation from the entries of $B$ (obtained via Step 4) gives $\det(I - B) = \epsilon t^{a} \cdot (1 + t + t^2)$ for some $a$ depending on $\epsilon$, verified for $(+1,+1)$ and $(+1,-1)$.

**Tag: I / partial [REF:external] for the general case.**

### Step 4 [I] — Reduced Burau matrix entries (via convention §1.3)
Using the Birman–Weinberg convention (§1.3),
$$\bar\rho(\sigma_i) = I_{i-2} \oplus U_i \oplus I_{p-i-2}$$
with $U_1 = \begin{pmatrix}-t & 1 \\ 0 & 1\end{pmatrix}$, $U_{p-1} = \begin{pmatrix}1 & 0 \\ t & -t\end{pmatrix}$, and $U_i = \begin{pmatrix}1 & 0 & 0 \\ t & -t & 1 \\ 0 & 0 & 1\end{pmatrix}$ for $2 \le i \le p-2$. For $\sigma_i^{-1}$ invert the block.

**Explicit computation of $B$ for small $p$** (verified by symbolic Python):

- $p = 2$, $\epsilon = (\epsilon_1)$: $B = [-t]$ if $\epsilon_1 = +1$, $[-1/t]$ if $\epsilon_1 = -1$.
- $p = 3$, $\epsilon = (+1,+1)$: $B = \begin{pmatrix} 0 & -t \\ t & -t \end{pmatrix}$.
- $p = 3$, $\epsilon = (+1,-1)$: $B = \begin{pmatrix} 1-t & -1/t \\ 1 & -1/t \end{pmatrix}$.
- $p = 4$, $\epsilon = (+1,+1,+1)$: $B = \begin{pmatrix} 0 & 0 & -t \\ t & 0 & -t \\ 0 & t & -t \end{pmatrix}$ — **non-tridiagonal** ($B_{13} = -t \ne 0$).

### Step 5 [I] — The key identity $\det(I - yB) = t^{\Sigma \epsilon_i} C_{p-1}(y, t)$
**Claim**: For every $p \ge 2$ and every $\epsilon \in \{\pm 1\}^{p-1}$,
$$\det(I_{p-1} - y B_\epsilon) = t^{e(\epsilon)} \cdot C_{p-1}(y, t), \qquad e(\epsilon) := \sum_{i=1}^{p-1} \epsilon_i,$$
where $C_{p-1}$ is the polynomial defined by the problem's recursion.

**Status**: verified by symbolic computation for **all** $\epsilon \in \{\pm 1\}^{p-1}$ at $p = 2, 3, 4$ (8 cases at $p=4$; 12 cases across $p \in \{2,3,4\}$). The ratio is precisely $t^{e(\epsilon)}$ in all 12 cases.

**Proof sketch (induction on $p$)**: Introduce the leading principal-minor polynomials $D_k(y, t) := \det(I_k - y B_\epsilon^{[k]})$ where $B_\epsilon^{[k]}$ is the top-left $k\times k$ block of $B_\epsilon$. Expand $\det(I_{p-1} - y B_\epsilon)$ along the last row. The last row of $B_\epsilon$ has nonzero entries only in the last two columns (from the block structure of $\bar\rho(\sigma_{p-1}^{\epsilon_{p-1}})$: the last factor in the product only modifies the last two columns of the accumulated product $\bar\rho(\sigma_1^{\epsilon_1} \cdots \sigma_{p-2}^{\epsilon_{p-2}})$ by right-multiplication). Specifically,
- if $\epsilon_{p-1} = +1$: the last two columns of the running product get right-multiplied by $\begin{pmatrix}1 & 0 \\ t & -t\end{pmatrix}$,
- if $\epsilon_{p-1} = -1$: by its inverse $\begin{pmatrix}1 & 0 \\ 1 & -1/t\end{pmatrix}$.

This right-multiplication pattern, together with the cofactor expansion, produces the recursion
$$D_{p-1}(y, t) = \alpha_{p-1}(y) \cdot D_{p-2}(y, t) - \beta_{p-1}(y) \cdot D_{p-3}(y, t)$$
for explicit $\alpha, \beta$ that depend only on $\epsilon_{p-2}, \epsilon_{p-1}$, matching (up to the $t^{\epsilon_{p-1}}$ prefactor) the recursion defining $C_{p-1}$. Checking the base cases $D_1, D_2$ against $C_1, C_2$ (done explicitly above) and propagating the induction closes the identification up to the $t$-power, whose exponent satisfies $e(\epsilon_{1..k}) = e(\epsilon_{1..k-1}) + \epsilon_k$.

**[STEP-STUCK SP-3]**: I verified the identity for $p \le 4$ by direct symbolic computation (all 14 cases), but the **general inductive step** requires tracking how multiplication of the running product by $\bar\rho(\sigma_k^{\epsilon_k})$ modifies the leading principal-minor polynomials $D_{k-1}, D_{k-2}$. I can articulate the mechanism (the last two columns' action is a 2×2 transformation) but I have not written out the full $2\times 2$ block-recursion proof. The identity is strongly suggested by the 14 verified cases and matches the recursion's structure, but the Explorer deliverable honestly flags this as an **incomplete step**, not a black-box citation. **Tag: I (partial)**.

### Step 6 [I] — Assembling Theorem 3.5
Combining Steps 1–5:
$$\Delta_{\hat\beta}(t) \;\doteq\; \frac{\det(I - B^q)}{\Phi_p(t)} \;=\; \frac{\prod_{\ell=0}^{q-1} \det(I - \zeta^\ell B)}{\Phi_p(t)}.$$
By Step 3, $\det(I - B) = \pm t^a \Phi_p(t)$ cancels the denominator, leaving
$$\Delta_{\hat\beta}(t) \;\doteq\; \prod_{\ell=1}^{q-1} \det(I - \zeta^\ell B) \;=\; \prod_{\ell=1}^{q-1} t^{e(\epsilon)} C_{p-1}(\zeta^\ell, t) \;=\; t^{(q-1) e(\epsilon)} \prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t).$$
Since $t^{(q-1)e(\epsilon)}$ is a unit, this proves Theorem 3.5 up to the declared $\pm t^k$ ambiguity. **Tag: I** (conditional on SP-2 and SP-3).

### Step 7 [L, tag L1] — Seifert's algorithm upper bound for $g$
The standard closure diagram of $\beta \in B_p$ has $p$ strands and $(p-1)q$ crossings (each of the $q$ cyclic iterations contributes $p-1$ crossings). **Claim**: applying Seifert's algorithm to this oriented diagram produces $p$ Seifert circles (Step 7a [I]).

**Proof of 7a**: In a braid-closure diagram, each of the $p$ strands is oriented downward throughout the braid box and then closed up by arcs running top-to-bottom on the side. At every crossing, the Seifert smoothing respects this vertical orientation. Therefore Seifert's algorithm resolves each crossing into a horizontal "cap+cup", and the resulting oriented curves are exactly the $p$ closed loops obtained by the trivial closure of $p$ vertical strands. Hence $s = p$.

**Euler characteristic and genus**: the Seifert surface $F$ produced consists of $p$ disks (one per Seifert circle) with $(p-1)q$ twisted bands (one per crossing). Hence
$$\chi(F) = p - (p-1)q, \qquad 2 - 2g(F) - b(F) = \chi(F) \text{ with } b(F) = 1 \text{ (a knot)},$$
giving $g(F) = \frac{(p-1)q - p + 1}{2} = \frac{(p-1)(q-1)}{2}$. Thus $g(\hat\beta) \le g(F) = (p-1)(q-1)/2$. **Tag: L1** (Seifert's algorithm + Euler-char count; standard 30-second textbook calculation).

### Step 8 [L, tag L2] — Alexander-polynomial genus lower bound
Cite the standard lemma: $\deg \Delta_K(t) \le 2g(K)$, where $\deg$ means "breadth" = (highest $t$-power) − (lowest $t$-power). This is a consequence of the Seifert-form definition of $\Delta$ combined with $\text{rank}\, H_1(F) = 2g$ for a genus-$g$ Seifert surface of a knot. **Tag: L2** (Rolfsen *Knots and Links* Proposition 8.C.6, or Lickorish GTM 175 §6).

### Step 9 [I] — Degree of the product
From Theorem 3.5, $\Delta_{\hat\beta}(t) \doteq \prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)$. Each $C_{p-1}(y, t)$ is a polynomial in $y$ of degree $p-1$. Writing $C_{p-1}(y, t) = \sum_{j=0}^{p-1} c_j(t) y^j$, we have (from the recursion; verified at small $p$) that the breadth in $t$ of $c_j(t)$ satisfies $\mathrm{br}_t(c_{p-1}) = 0$ (top coefficient is 1) and $\mathrm{br}_t(c_0)$ equals the breadth contributed by the product of $\mu$-terms. More relevantly: at each root of unity $\zeta^\ell$, $C_{p-1}(\zeta^\ell, t)$ is (generically) a polynomial of breadth $p-1$ in $t$, so the product over $\ell = 1, \ldots, q-1$ has breadth $(p-1)(q-1)$ in $t$.

**Verification**: for $S(3,5,(+1,-1))$, the formula predicts breadth $(p-1)(q-1) = 2 \cdot 4 = 8$. Direct Burau computation yields
$$\Delta = t^3 - 6t^2 + 15t - 24 + 29 t^{-1} - 24 t^{-2} + 15 t^{-3} - 6 t^{-4} + t^{-5},$$
with breadth $3 - (-5) = 8$. ✓

Hence $2 g(\hat\beta) \ge \deg \Delta = (p-1)(q-1)$, so $g \ge (p-1)(q-1)/2$. Combined with Step 7, this gives $g = (p-1)(q-1)/2$, proving Theorem 4.2. **Tag: I** (conditional on the breadth computation being $(p-1)(q-1)$, which is verified on base cases but not fully proved for all $\epsilon$).

**[STEP-STUCK SP-4]**: the generic breadth claim "$\prod_\ell C_{p-1}(\zeta^\ell, t)$ has breadth exactly $(p-1)(q-1)$ in $t$" requires that no cancellation reduces the breadth. This is expected (the product of top-degree-in-$y$ coefficients over $\ell = 1, \ldots, q-1$ equals $\prod_\ell 1 = 1$, so the top $t$-power does not cancel; dually the lowest $t$-power), but needs a careful "coefficient at leading/trailing" argument that I only sketch.

## Stuck points

- **[STEP-STUCK SP-1]**: Route A's original premise — that $B = \bar\rho(\sigma_1^{\epsilon_1} \cdots \sigma_{p-1}^{\epsilon_{p-1}})$ is **tridiagonal** in the standard basis — is **false**. Direct computation at $p = 4$, $\epsilon = (+1,+1,+1)$ gives $B_{13} = -t \ne 0$. Therefore the tridiagonal characteristic-polynomial recursion cannot be applied directly to $\det(xI - B)$. This is flagged *honestly* — the scout hypothesis was wrong and I discovered it in Step 4. The proof sidesteps this via the different identity in Step 5.

- **[STEP-STUCK SP-2]**: the cancellation of the $\ell = 0$ factor against $\Phi_p(t)$ is an identity $\det(I - B) \doteq \Phi_p(t)$ that I have not proven in full generality. I cite it as a known consequence of the reduced↔unreduced Burau relation but do not derive it here. Verified on base cases.

- **[STEP-STUCK SP-3]**: the identity $\det(I - yB) = t^{e(\epsilon)} C_{p-1}(y, t)$ is verified exhaustively for $p \le 4$ (14 cases: $2 + 4 + 8 = 14$) but the inductive proof for general $p$ is sketched, not written in full. The mechanism (right-multiplication by $\bar\rho(\sigma_k^{\pm 1})$ modifies only the last two columns of the running product, yielding the three-term recursion matching $C_k$'s recursion) is clear but the algebra is incomplete.

- **[STEP-STUCK SP-4]**: the breadth $(p-1)(q-1)$ of $\prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)$ is asserted on the basis of "top/bottom coefficient doesn't cancel" but not rigorously proved. Required for the lower bound on $g$ in Theorem 4.2.

- **[UNVERIFIABLE: diagonalizability]**: the eigenvalue factorization Step 2 technically requires $B$ to be diagonalizable over $\bar K$, or else a Jordan-block argument. Both extend to the claimed identity, but the matrix-identity-over-$\mathbb{Z}[t,t^{-1}]$ argument I gave (via symmetric functions) is the cleanest.

## TSV cross-checks (commands run + output)

All commands executed from `/c/Users/12729/.claude/skills/math-verifier/tsv`.

### TSV ground truth

```
$ python -c "from tsv_knot import alexander_polynomial; print(alexander_polynomial('3_1'))"
(t**2 - t + 1, {'method': 'tsv-knot', 'submethod': 'alexander', 'confidence': 'high', 'reason': "lookup for named knot '3_1'"})

$ python -c "from tsv_knot import alexander_polynomial; print(alexander_polynomial('4_1'))"
(t**2 - 3*t + 1, {'method': 'tsv-knot', 'submethod': 'alexander', 'confidence': 'high', 'reason': "lookup for named knot '4_1'"})

$ python -c "from tsv_knot import alexander_polynomial; print(alexander_polynomial('10_123'))"
(None, {'method': 'none', 'confidence': 'low', 'reason': "out-of-TSV-scope: unknown knot '10_123'"})
```

### Base-case verification of the general formula via Burau (sympy)

Using the reduced-Burau convention from §1.3 and the matrices from Step 4:

**Case $S(2, 3, (+1)) = T(2,3) = 3_1$**:
- $B = [-t]$, $B^3 = [-t^3]$, $\det(I - B^3) = 1 + t^3$.
- $\Delta = (1 + t^3)/(1 + t) = 1 - t + t^2 = t^2 - t + 1$. ✓ Matches TSV.

**Case $S(3, 2, (+1,+1)) = T(3,2) = 3_1$**:
- $B = \begin{pmatrix}0 & -t \\ t & -t\end{pmatrix}$, $B^2 = \begin{pmatrix}-t^2 & t^2 \\ -t^2 & 0\end{pmatrix}$.
- $\det(I - B^2) = 1 + t^2 + t^4 = (1 + t + t^2)(1 - t + t^2)$.
- $\Delta = (1 + t^2 + t^4)/(1 + t + t^2) = 1 - t + t^2 = t^2 - t + 1$. ✓ Matches TSV.

**Case $S(3, 2, (+1,-1)) = 4_1$**:
- $B = \begin{pmatrix}1-t & -1/t \\ 1 & -1/t\end{pmatrix}$, $B^2$ computed symbolically.
- $\det(I - B^2)/(1+t+t^2) = -1 + 3/t - 1/t^2 = -t^{-2}(t^2 - 3t + 1)$, which equals $t^2 - 3t + 1$ up to unit $-t^{-2}$. ✓ Matches TSV.

### Base-case verification of the product formula $\prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)$

- $S(3, 2, (+1,-1))$: $\prod_{\ell=1}^{1} C_2(-1, t) = C_2(-1, t) = 1 + (-1)(t - 1 + 1/t) + 1 = 3 - t - 1/t$. And $\Delta$ from Burau (above) $= -1 + 3/t - 1/t^2 = -t^{-1}(3 - t - 1/t) \cdot t^{-1}\ldots$ actually $-t^{-1} \cdot (3 - t - 1/t) \cdot (-1) = (3 - t - 1/t)/t$ — so the ratio is $\pm t^{-1}$, a unit. ✓

- $S(3, 5, (+1,-1)) = 10_{123}$ (TSV out of scope for $\Delta$):
  - Burau gives $\Delta = t^3 - 6t^2 + 15t - 24 + 29t^{-1} - 24t^{-2} + 15t^{-3} - 6t^{-4} + t^{-5}$.
  - Breadth $= 3 - (-5) = 8 = 2 \cdot 4 = (p-1)(q-1)$, so $g \ge 4$.
  - Seifert surface gives $g \le (p-1)(q-1)/2 = 4$. Hence $g = 4$ ✓ (matches problem statement).
  - Product formula $\prod_{\ell=1}^{4} C_2(\zeta_5^\ell, t)$ was evaluated numerically at $t \in \{2, 3/7, -5/3\}$ and compared to the Burau $\Delta$; ratio was always a unit ($t^{-1}$ specifically). ✓

### Identity verification $\det(I - yB) = t^{e(\epsilon)} C_{p-1}(y, t)$ across all $\epsilon$, $p \le 4$

Symbolic sympy computation, all 14 cases:

| $p$ | $\epsilon$ | $e(\epsilon) = \sum \epsilon_i$ | ratio $\det(I-yB)/C_{p-1}(y,t)$ |
|---|---|---|---|
| 2 | (+1) | +1 | $t$ |
| 2 | (-1) | -1 | $t^{-1}$ |
| 3 | (+1,+1) | +2 | $t^2$ |
| 3 | (+1,-1) | 0 | 1 |
| 3 | (-1,+1) | 0 | 1 |
| 3 | (-1,-1) | -2 | $t^{-2}$ |
| 4 | (+1,+1,+1) | +3 | $t^3$ |
| 4 | (+1,+1,-1) | +1 | $t$ |
| 4 | (+1,-1,+1) | +1 | $t$ |
| 4 | (-1,+1,+1) | +1 | $t$ |
| 4 | (+1,-1,-1) | -1 | $t^{-1}$ |
| 4 | (-1,+1,-1) | -1 | $t^{-1}$ |
| 4 | (-1,-1,+1) | -1 | $t^{-1}$ |
| 4 | (-1,-1,-1) | -3 | $t^{-3}$ |

**Pattern**: ratio $= t^{e(\epsilon)}$ in every case, confirming the identity of Step 5.

## Citation ledger (L1/L2/L3 tagged)

- **[L1]** Factorization $1 - x^q = \prod_{\ell=0}^{q-1}(1 - \zeta^\ell x)$ in $\mathbb{C}[x]$ (used in Step 2a). 30-second textbook lookup; elementary polynomial factorization.
- **[L1]** Seifert's algorithm for a closed-braid diagram produces $s$ Seifert circles from a strand-count $p$; bands = crossings = $(p-1)q$. Euler-char $\chi = s - c = p - (p-1)q$, $g = (1 - \chi)/2$ (Step 7). Standard undergraduate textbook computation (Rolfsen §5, Lickorish GTM 175 §2). Also explicitly permitted as low-depth per problem.md §Allowed background #8.
- **[L1]** Cyclotomic unit: $t^k$ is a unit in $\mathbb{Z}[t, t^{-1}]$ for all $k \in \mathbb{Z}$ (used for "up to $\pm t^k$" normalization).
- **[L2]** Burau–Alexander formula $\Delta_{\hat\beta}(t) = \det(I - \bar\rho(\beta))/\Phi_p(t)$ up to units (Step 1). Single theorem citation to Birman, *Braids, Links, and Mapping Class Groups* (AMS 1974) §3; matches convention §1.3 of this project's conventions registry.
- **[L2]** Alexander-polynomial genus bound: $2g(K) \ge \deg \Delta_K$ (Step 8). Single theorem citation to Rolfsen *Knots and Links* Prop. 8.C.6, or Lickorish GTM 175 §6.
- **[L2]** Reduced-Burau matrices of $\sigma_i$ (Step 4): generator-level formulas from the Birman–Weinberg convention as recorded in project conventions §1.3.
- **[L2]** $\det(I - \bar\rho(\beta))$ is divisible by $\Phi_p(t)$ for every $\beta \in B_p$ (the factor denominator-cancellation in the Burau formula, Step 3 / SP-2). Standard consequence of the reduced/unreduced Burau transition; cited without detailed proof.
- **No L3 citations.** The proof avoids deep machinery — no Heegaard Floer, no Khovanov homology, no fibered-knot monodromy, no virtual Haken, no Heegaard distance. Everything lives at the level of polynomial determinants and Seifert surfaces, as scout/problem.md expected.

## Honest self-assessment

**What closed**:
- Step 1 (Burau–Alexander formula): closed cleanly via L2 citation.
- Step 2 (eigenvalue factorization $\det(I - B^q) = \prod \det(I - \zeta^\ell B)$): closed independently.
- Step 4 (Burau matrix entries of generators): closed, and I **discovered** that the product is NOT tridiagonal — contradicting the scout's hint (see SP-1).
- Step 5 (the critical identity $\det(I - yB) = t^{e(\epsilon)} C_{p-1}(y, t)$): **verified for all $\epsilon$ at $p \le 4$** (14/14 cases). The pattern $t^{e(\epsilon)}$ is unambiguous. However, the inductive proof for general $p$ is sketched, not completed (SP-3). This is Route A's main incomplete step.
- Step 7 (genus upper bound via Seifert's algorithm): closed.
- Step 9 (breadth giving genus lower bound): closed modulo SP-4 (the "no leading-coefficient cancellation" subclaim).
- TSV base cases: **3/3 passed** ($S(2,3,(+1))$, $S(3,2,(+1,+1))$, $S(3,2,(+1,-1))$). Out-of-TSV case $S(3,5,(+1,-1))$ passes via Burau computation; matches expected $g=4$ and Δ breadth.

**What did not close**:
- SP-1 (scout's tridiagonality claim): **falsified**. Noted honestly.
- SP-2 ($\det(I - B) = \pm t^k \Phi_p(t)$): asserted as standard, not proved.
- SP-3 (general-$p$ induction for the key identity): sketched, not completed. Exhaustively verified for $p \le 4$.
- SP-4 (breadth of $\prod C_{p-1}(\zeta^\ell, t)$ is exactly $(p-1)(q-1)$): asserted via "no top-coefficient cancellation", not rigorously proved.

**Overall verdict**: Route A **reaches Theorem 3.5 and Theorem 4.2 modulo four honest stuck points**, two of which (SP-2, SP-4) are routine completions of standard lemmas and one of which (SP-3) requires a careful but combinatorial inductive argument that I have set up in outline. SP-1 is a correction to the scout's stated structural claim — the route still works, but via a *different* identification than the scout proposed. I do **not** claim a complete proof; I claim a **substantial partial proof** with explicit, well-isolated remaining work. TSV confirms all the in-scope base cases.

**If asked to continue**: the highest-leverage next step is closing SP-3 by writing out the block-cofactor induction for $\det(I - yB_\epsilon)$, followed by SP-2 which is a known Burau-theoretic identity.
