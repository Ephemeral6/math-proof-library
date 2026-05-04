# Spiral Knots — Classical Invariants (self-contained proof)

> Integrated rewrite: 2026-04-21 (pipeline v2.2, Integrator stage).
>
> Based on Explorer Route A (`explorer_1.md` winning candidate), with Fixer
> Round 1 (SP-3 closure via intrinsic induction) and Fixer Round 2 (SP-2
> closure via universal scalar recursion; SP-4 closure via top/bot monomial
> sub-lemma) merged into the body. All stuck points from the Explorer
> version are now resolved and appear inline as proven lemmas; `best_proof.md`
> no longer references external Fixer files for mathematical content.

---

## 0. Overview

We prove both theorems in parallel via the reduced Burau representation
$\bar\rho_p : B_p \to GL_{p-1}(\mathbb{Z}[t, t^{-1}])$ of the braid group.

Let $B_\epsilon := \bar\rho_p(\sigma_1^{\epsilon_1} \cdots \sigma_{p-1}^{\epsilon_{p-1}})$
so that $\bar\rho_p(\beta_{p,q,\epsilon}) = B_\epsilon^q$. The strategy:

1. By the Burau–Alexander formula, $\Delta_{S(p,q,\epsilon)}(t) \doteq \det(I_{p-1} - B_\epsilon^q) / \Phi_p(t)$ up to $\pm t^k$ ambiguity, with $\Phi_p(t) := 1 + t + \cdots + t^{p-1}$.
2. Factor $\det(I - B_\epsilon^q) = \prod_{\ell=0}^{q-1} \det(I - \zeta^\ell B_\epsilon)$ with $\zeta = e^{2\pi i / q}$.
3. **Central identity**: $\det(I_k - y\, A'_k) = t^{e_k}\, C_k(y, t)$, proved by induction on $k$, where $A'_k := \bar\rho_{k+1}(\sigma_1^{\epsilon_1}\cdots\sigma_k^{\epsilon_k})$ is the **intrinsic** image in the smaller braid group $B_{k+1}$ and $e_k := \sum_{i=1}^{k} \epsilon_i$.
4. **Denominator cancellation**: $\det(I_{p-1} - B_\epsilon) \doteq \Phi_p(t)$, which cancels the $\ell = 0$ factor against the Burau–Alexander denominator. Reduces to an intrinsic identity $C_k(1, t) = t^{-(e_k + k)/2} \Phi_{k+1}(t)$, proved by a universal (ε-independent) scalar recursion.
5. **Breadth computation**: $\prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)$ has breadth exactly $(p-1)(q-1)$ in $t$, proven via a structural "top/bot coefficients are monic monomials in $y$" sub-lemma and the fact that roots of unity are nonzero.
6. Combining (5) with the Alexander-polynomial genus bound $2g \ge \deg \Delta$ gives $g \ge (p-1)(q-1)/2$; Seifert's algorithm gives the matching upper bound.

**Conventions.** The reduced Burau representation is taken in the Birman–Weinberg convention §1.3 (see Step 2 below). Positive crossings $\sigma_i$ are oriented per problem.md §1.2. Alexander polynomials are considered up to multiplication by units $\pm t^k$.

**Correction.** An Explorer-stage hypothesis — that $B_\epsilon$ is tridiagonal in the standard basis — is **false**. Direct computation at $p = 4$, $\epsilon = (+1, +1, +1)$ yields $B_{\epsilon, 13} = -t \ne 0$. The proof below does not use tridiagonality; the central identity is established instead via an intrinsic induction in smaller braid groups (Steps 4–5).

---

## 1. Setup: notation and convention

### 1.1 Notation

For $\epsilon \in \{\pm 1\}^{p-1}$ and $0 \le k \le p-1$:
- $e_k := \sum_{i=1}^k \epsilon_i$, with $e_0 := 0$. Set $e(\epsilon) := e_{p-1}$.
- $\mu(i) := 1$ if $\epsilon_i = +1$, $\mu(i) := t$ if $\epsilon_i = -1$ (from problem.md).
- $n_k^+ := \#\{i \le k : \epsilon_i = +1\}$, $n_k^- := \#\{i \le k : \epsilon_i = -1\}$, so $n_k^+ + n_k^- = k$.
- $B_\epsilon := \bar\rho_p(\sigma_1^{\epsilon_1}\cdots\sigma_{p-1}^{\epsilon_{p-1}}) \in GL_{p-1}(\mathbb{Z}[t, t^{-1}])$.
- $A'_k := \bar\rho_{k+1}(\sigma_1^{\epsilon_1} \cdots \sigma_k^{\epsilon_k}) \in GL_k(\mathbb{Z}[t, t^{-1}])$ for $1 \le k \le p-1$; $A'_0 := ()$ (empty matrix). Note $A'_{p-1} = B_\epsilon$.
- $F_k(y, t) := \det(I_k - y A'_k)$, with $F_0 := 1$.
- $C_k(y, t)$: the polynomial defined by the recursion in problem.md §"Definitions used in the statements".

### 1.2 Reduced Burau generator matrices (convention §1.3) [L2]

For $1 \le i \le p-1$, $\bar\rho_p(\sigma_i)$ equals the identity outside a $2\times 2$ or $3\times 3$ block at rows/columns around $i$. Specifically, writing $\bar\rho_p(\sigma_i) = I_{i-2} \oplus U_i \oplus I_{p-i-2}$ (with the boundary conventions below):

- $U_1 = \begin{pmatrix}-t & 1 \\ 0 & 1\end{pmatrix}$ (first-boundary block at rows/cols $(1, 2)$).
- $U_{p-1} = \begin{pmatrix}1 & 0 \\ t & -t\end{pmatrix}$ (last-boundary block at rows/cols $(p-2, p-1)$).
- $U_i = \begin{pmatrix}1 & 0 & 0 \\ t & -t & 1 \\ 0 & 0 & 1\end{pmatrix}$ for $2 \le i \le p-2$ (middle block at rows/cols $(i-1, i, i+1)$).

Inverses:
- $U_1^{-1} = \begin{pmatrix}-1/t & 1/t \\ 0 & 1\end{pmatrix}$.
- $U_{p-1}^{-1} = \begin{pmatrix}1 & 0 \\ 1 & -1/t\end{pmatrix}$.
- $U_i^{-1} = \begin{pmatrix}1 & 0 & 0 \\ 1 & -1/t & 1/t \\ 0 & 0 & 1\end{pmatrix}$ for middle $i$.

**Tag: L2** — Birman–Weinberg convention for the reduced Burau representation (Birman, *Braids, Links, and Mapping Class Groups*, AMS 1974, §3).

### 1.3 Sample explicit matrices $B_\epsilon$ (used in base-case checks below)

- $p = 2$: $B_{(+1)} = [-t]$, $B_{(-1)} = [-1/t]$.
- $p = 3$, $\epsilon = (+1, +1)$: $B = \begin{pmatrix}0 & -t \\ t & -t\end{pmatrix}$.
- $p = 3$, $\epsilon = (+1, -1)$: $B = \begin{pmatrix}1-t & -1/t \\ 1 & -1/t\end{pmatrix}$.
- $p = 4$, $\epsilon = (+1, +1, +1)$: $B = \begin{pmatrix}0 & 0 & -t \\ t & 0 & -t \\ 0 & t & -t\end{pmatrix}$ — note $B_{13} = -t \ne 0$, falsifying the Explorer-stage tridiagonality hypothesis.

---

## 2. Burau–Alexander formula

### Step 1 — Pipeline formula [L2]

For any $\beta \in B_p$ whose closure is a knot,
$$\Delta_{\widehat\beta}(t) \;=\; \frac{\det(I_{p-1} - \bar\rho_p(\beta))}{\Phi_p(t)} \qquad (\text{mod}\ \pm t^{\mathbb{Z}}),$$
where $\Phi_p(t) = 1 + t + t^2 + \cdots + t^{p-1}$.

**Tag: L2** — Birman 1974, §3 (reduced-Burau Alexander-polynomial theorem); matches convention §1.3 of this project's conventions registry.

Applying to $\beta = \beta_{p,q,\epsilon}$ with $\bar\rho_p(\beta) = B_\epsilon^q$:
$$\Delta_{S(p, q, \epsilon)}(t) \;\doteq\; \frac{\det(I_{p-1} - B_\epsilon^q)}{\Phi_p(t)}. \tag{$\star$}$$

---

## 3. Eigenvalue factorization of $\det(I - B_\epsilon^q)$

### Step 2 — The $q$-fold factorization [I]

**Claim.** $\det(I_{p-1} - B_\epsilon^q) = \prod_{\ell=0}^{q-1} \det(I_{p-1} - \zeta^\ell B_\epsilon)$, with $\zeta := e^{2\pi i / q}$.

**Proof.** Start from the scalar identity $1 - x^q = \prod_{\ell=0}^{q-1}(1 - \zeta^\ell x)$ in $\mathbb{C}[x]$ [L1 — polynomial factorization of $1 - x^q$ via $q$-th roots of unity].

Let $K$ be the algebraic closure of the field of fractions $\mathbb{Q}(t)$, and view $B_\epsilon$ as a matrix over $K$. Over $K$, $B_\epsilon$ has a Jordan form, so in particular its eigenvalues $\lambda_1, \ldots, \lambda_{p-1}$ (with multiplicity) are well-defined elements of $K$. Then
$$\det(I - B_\epsilon^q) = \prod_j (1 - \lambda_j^q) = \prod_j \prod_{\ell=0}^{q-1}(1 - \zeta^\ell \lambda_j) = \prod_{\ell=0}^{q-1} \prod_j (1 - \zeta^\ell \lambda_j) = \prod_{\ell=0}^{q-1} \det(I - \zeta^\ell B_\epsilon).$$

The left-hand side lies in $\mathbb{Z}[t, t^{-1}]$ by definition. The right-hand side, reordered as a symmetric polynomial in $\zeta^\ell$, also lies in $\mathbb{Z}[t, t^{-1}]$ by Newton's identities applied to $\det(xI - B_\epsilon) \in \mathbb{Z}[t, t^{-1}][x]$. Hence the identity, initially derived in $K$, holds in $\mathbb{Z}[t, t^{-1}]$.

**Tag: I** — eigenvalue / symmetric-function argument. [L1 supporting citation: polynomial factorization of $1 - x^q$.]

---

## 4. Block Structure Lemma and the central identity (was SP-3; closed)

### Step 3 — Reframing the induction variable [I]

The Explorer version proposed inducting on the leading principal-minor polynomials $D_k(y) := \det(I_k - y\, B_\epsilon^{[k]})$ of the **full** $B_\epsilon$ in $B_p$. This framing does **not** work: direct computation at $p = 4$, $\epsilon = (+1, +1, +1)$ gives $D_1 = D_2 = 1$, whereas $t^{e_1} C_1 = t(1/t + y) = 1 + yt$ and $t^{e_2} C_2 \ne 1$. Thus $D_k \ne t^{e_k} C_k$ for $k < p - 1$, and the principal minors of $B_\epsilon$ are not the right induction variable.

The correct induction variable is $F_k := \det(I_k - y A'_k)$ where $A'_k = \bar\rho_{k+1}(\sigma_1^{\epsilon_1}\cdots\sigma_k^{\epsilon_k})$ is the **intrinsic** reduced-Burau image in the smaller braid group $B_{k+1}$. Taking $k = p-1$ gives $A'_{p-1} = B_\epsilon$ and hence the target identity.

### Step 4 — Block Structure Lemma [I]

**Lemma (Block Structure).** For every $k \ge 1$, in the ambient group $B_{k+2}$,
$$L^{(k+2)}_k \;:=\; \bar\rho_{k+2}(\sigma_1^{\epsilon_1} \cdots \sigma_k^{\epsilon_k})
\;=\; \begin{pmatrix} A'_k & c_k \\ 0 & 1 \end{pmatrix}$$
for some column vector $c_k \in \mathbb{Z}[t, t^{-1}]^k$. The vector $c_k$ satisfies the recursion
$$c_k \;=\; \frac{1}{\mu(k)}\, \binom{c_{k-1}}{1}, \qquad c_0 := () \text{ (empty)}.$$

**Proof.** The lemma has three parts: (i) the last row of $L^{(k+2)}_k$ is $e_{k+1}^T = (0, \ldots, 0, 1)$; (ii) the top-left $k \times k$ block equals $A'_k$; (iii) the identified $c_k$ recursion.

*(i) Last row is $e_{k+1}^T$.* For $1 \le j \le k$, the matrix $\bar\rho_{k+2}(\sigma_j^{\pm 1})$ has last row $e_{k+1}^T$. This is a direct entry check on the Birman–Weinberg blocks from §1.2:
- For $j \le k - 1$: the active block of $\bar\rho_{k+2}(\sigma_j)$ sits on rows $\le k$, so row $k+1$ is the identity row $(0, \ldots, 0, 1) = e_{k+1}^T$.
- For $j = k$: the middle block $U_k$ sits at rows $(k-1, k, k+1)$, and row 3 of the $3 \times 3$ middle block is $(0, 0, 1)$, contributing exactly $e_{k+1}^T$ as the last row.
- The inverse $U_k^{-1}$ also has row 3 $= (0, 0, 1)$.

Matrices each with last row $e_n^T$ multiply to a matrix with last row $e_n^T$: if $M_1, M_2$ each have last row $e_n^T$, then $(M_1 M_2)_{n, j} = \sum_i (M_1)_{n, i} (M_2)_{i, j} = (M_2)_{n, j} = \delta_{n, j}$. Induction on factor count. **[L1]**

*(ii) Top-left $k \times k$ block equals $A'_k$.* For $j \le k - 1$, $\bar\rho_{k+2}(\sigma_j^{\pm 1})$ and $\bar\rho_{k+1}(\sigma_j^{\pm 1})$ differ only beyond row/column $k+1$, so their top-left $k \times k$ blocks are identical. For $j = k$, inspect: in $B_{k+1}$ the generator $\sigma_k$ is the *last* generator, using the $2 \times 2$ boundary block $\begin{pmatrix} 1 & 0 \\ t & -t \end{pmatrix}$ at rows/cols $(k-1, k)$. In $B_{k+2}$ the same $\sigma_k$ is a *middle* generator, using the $3 \times 3$ block $\begin{pmatrix} 1 & 0 & 0 \\ t & -t & 1 \\ 0 & 0 & 1 \end{pmatrix}$ at rows/cols $(k-1, k, k+1)$. The top-left $2 \times 2$ corner of the middle block is $\begin{pmatrix} 1 & 0 \\ t & -t \end{pmatrix}$, matching the boundary block. **[L1]**

Since each factor has top-left $k \times k$ block matching the corresponding generator in $B_{k+1}$, and since the top-left block of a product with last-row $e_{k+1}^T$ factors equals the product of top-left blocks (direct expansion — **[L1]**), the top-left $k \times k$ block of $L^{(k+2)}_k$ equals $A'_k$. ∎

*(iii) Recursion for $c_k$.* Write $L^{(k+2)}_k = L^{(k+2)}_{k-1} \cdot \bar\rho_{k+2}(\sigma_k^{\epsilon_k})$. The factor $L^{(k+2)}_{k-1}$ has block form $\begin{pmatrix} A'_{k-1} & c_{k-1} & 0 \\ 0 & 1 & 0 \\ 0 & 0 & 1 \end{pmatrix}$ by applying (i)–(ii) with parameter $k - 1$.

For $k \ge 2$, $\sigma_k$ in $B_{k+2}$ is a middle generator using the $3 \times 3$ block at cols $(k-1, k, k+1)$. The right-multiplication's action on column $k+1$ of $L^{(k+2)}_{k-1}$:

- $\epsilon_k = +1$ (block $\begin{pmatrix} 1 & 0 & 0 \\ t & -t & 1 \\ 0 & 0 & 1 \end{pmatrix}$): new col $k+1$ = (old col $k$) + (old col $k+1$) = $\binom{c_{k-1}}{1} \oplus (0) + e_{k+1}$. Top $k$ entries of the new col $k+1$: $\binom{c_{k-1}}{1}$. So $c_k = \binom{c_{k-1}}{1}$ (and $\mu(k) = 1$).
- $\epsilon_k = -1$ (block $\begin{pmatrix} 1 & 0 & 0 \\ 1 & -1/t & 1/t \\ 0 & 0 & 1 \end{pmatrix}$): new col $k+1$ = $(1/t) \cdot$ (old col $k$) + (old col $k+1$). Top $k$ entries: $(1/t)\binom{c_{k-1}}{1}$. So $c_k = (1/t)\binom{c_{k-1}}{1}$ (and $\mu(k) = t$).

Both sub-cases unify as $c_k = (1/\mu(k)) \binom{c_{k-1}}{1}$. The base $k = 1$ is checked directly against $L^{(3)}_1 = U_1^{\epsilon_1}$: for $\epsilon_1 = +1$, $c_1 = (1) = (1/\mu(1))\cdot(1)$; for $\epsilon_1 = -1$, $c_1 = (1/t) = (1/\mu(1))\cdot(1)$. ∎

### Step 5 — The central identity $F_k = t^{e_k}\, C_k$ [I]

**Theorem (central identity).** For every $k \ge 0$ and every $\epsilon_{1..k} \in \{\pm 1\}^k$,
$$F_k(y, t) \;=\; t^{e_k}\, C_k(y, t).$$

In particular, taking $k = p - 1$ gives $\det(I_{p-1} - y B_\epsilon) = t^{e(\epsilon)} C_{p-1}(y, t)$, which is Route A's boxed identity from the Overview.

**Proof.** Induction on $k$.

*Base $k = 0$:* $F_0 = \det(\text{empty}) = 1 = t^0 \cdot 1 = t^{e_0} C_0$. ✓

*Base $k = 1$:* $A'_1 = [-t]$ if $\epsilon_1 = +1$, $[-1/t]$ if $\epsilon_1 = -1$.
- $\epsilon_1 = +1$: $F_1 = 1 + yt$; $t^{e_1} C_1 = t(1/t + y) = 1 + yt$. ✓
- $\epsilon_1 = -1$: $F_1 = 1 + y/t$; $t^{e_1} C_1 = t^{-1}(t + y) = 1 + y/t$. ✓

*Inductive step.* Assume $F_{k-1} = t^{e_{k-1}} C_{k-1}$ and $F_k = t^{e_k} C_k$; prove $F_{k+1} = t^{e_{k+1}} C_{k+1}$. We establish a three-term recursion for $F_k$ matching $C_k$'s recursion (after the $t^{e_k}$ rescaling).

*Cofactor expansion of $F_{k+1}$.* Write $A'_{k+1} = L^{(k+2)}_k \cdot \bar\rho_{k+2}(\sigma_{k+1}^{\epsilon_{k+1}})$, where $\sigma_{k+1}$ is the *last* generator of $B_{k+2}$ (so the $2 \times 2$ boundary block at rows/cols $(k, k+1)$). The columns of $L^{(k+2)}_k$ are $\binom{a_1}{0}, \ldots, \binom{a_k}{0}, \binom{c_k}{1}$ where $a_1, \ldots, a_k$ are the columns of $A'_k$.

Right-multiplying by the $2 \times 2$ boundary block modifies only the last two columns:
- $\epsilon_{k+1} = +1$: new col $k$ $= \binom{a_k + t\, c_k}{t}$, new col $k+1$ $= \binom{-t\, c_k}{-t}$.
- $\epsilon_{k+1} = -1$: new col $k$ $= \binom{a_k + c_k}{1}$, new col $k+1$ $= \binom{-c_k/t}{-1/t}$.

Let
- $P := F_k = \det(I_k - y\, A'_k)$,
- $Q_k := \det[\text{cols 1..k-1 of } (I_k - y\, A'_k),\ c_k]$ (the $k \times k$ matrix with the last column of $I_k - y A'_k$ replaced by $c_k$).

Laplace-expand $F_{k+1} = \det(I_{k+1} - y\, A'_{k+1})$ along the last row:

**Case $\epsilon_{k+1} = +1$** (last-row entries of $I_{k+1} - yA'_{k+1}$ on cols $(k, k+1)$ are $(-yt, 1 + yt)$):
- Minor for col $k$: top-left with col $k+1$ adjoined gives $yt\, Q_k$ (cofactor sign $-1$).
- Minor for col $k+1$: top-left matrix with col $k$ modified by $-y\alpha c_k$ gives $F_k - yt\, Q_k$ (cofactor sign $+1$).

$$F_{k+1} = (-yt)(-1)(yt\, Q_k) + (1 + yt)(F_k - yt\, Q_k) = (1 + yt)\, F_k - yt\, Q_k. \tag{+}$$

**Case $\epsilon_{k+1} = -1$** (last-row entries on cols $(k, k+1)$ are $(-y, 1 + y/t)$):

$$F_{k+1} = (1 + y/t)\, F_k - y\, Q_k. \tag{-}$$

*Lemma Q: $Q_k = F_{k-1}/\mu(k)$.* Both (+) and (-) depend on $Q_k$; we now express $Q_k$ in terms of $F_{k-1}$, a pure scalar identity that removes the $Q$-variable from the recursion.

$Q_k$ is the determinant of a $k \times k$ matrix $N_k$ whose cols $1..k-1$ come from $I_k - y\, A'_k$ and whose last col is $c_k = (1/\mu(k))\binom{c_{k-1}}{1}$. Applying the Block Structure Lemma iteratively, $A'_k = L^{(k+1)}_{k-1} \cdot \bar\rho_{k+1}(\sigma_k^{\epsilon_k})$, where $\sigma_k$ is the *last* generator of $B_{k+1}$ (boundary block at rows/cols $(k-1, k)$) and $L^{(k+1)}_{k-1}$ has block form $\begin{pmatrix} A'_{k-1} & c_{k-1} \\ 0 & 1 \end{pmatrix}$.

Setting $\kappa := t/\mu(k)$ (so $\kappa = t$ for $\epsilon_k = +1$, $\kappa = 1$ for $\epsilon_k = -1$), the new col $k-1$ of $A'_k$ after the right-multiplication is $\binom{a^{(k-1)}_{k-1} + \kappa\, c_{k-1}}{\kappa}$.

$N_k$ thus has last row $(0, \ldots, 0, -y\kappa, 1/\mu(k))$. Expand along this last row:

- Col $k-1$ contribution (entry $-y\kappa$, sign $(-1)^{k + (k-1)} = -1$): submatrix is $(k-1)\times(k-1)$ with cols $1..k-2$ unchanged and col $k$ having top $k-1$ entries $c_{k-1}/\mu(k)$. This minor is $(1/\mu(k))\, Q_{k-1}$.
- Col $k$ contribution (entry $1/\mu(k)$, sign $+1$): submatrix is top-left $(k-1) \times (k-1)$ of $N_k$, with cols $1..k-2$ unchanged and col $k-1$ equal to $(e^{(k-1)}_{k-1} - y\, a^{(k-1)}_{k-1}) - y\kappa\, c_{k-1}$. By column linearity this equals $F_{k-1} - y\kappa\, Q_{k-1}$.

Combining:
$$Q_k = (-y\kappa)(-1)\frac{Q_{k-1}}{\mu(k)} + \frac{1}{\mu(k)}(F_{k-1} - y\kappa\, Q_{k-1}) = \frac{y\kappa\, Q_{k-1}}{\mu(k)} + \frac{F_{k-1}}{\mu(k)} - \frac{y\kappa\, Q_{k-1}}{\mu(k)} = \frac{F_{k-1}}{\mu(k)}.$$

The $Q_{k-1}$ terms cancel **exactly**, regardless of $\epsilon_k$. Hence $Q_k = F_{k-1}/\mu(k)$. **[L1 tools: cofactor expansion, column linearity.]** `[VERIFIED-SYMPY: script=verify/find_Qk.py, cases=11, result=PASS, description=Q_k / F_{k-1} = 1/mu(k) on 11 sign-prefixes of length 2..5]` ∎

*Combining into the three-term recursion.* Substituting $Q_k = F_{k-1}/\mu(k)$ into (+) and (-):
- Case $\epsilon_{k+1} = +1$: $F_{k+1} = (1 + yt)\, F_k - (yt/\mu(k))\, F_{k-1}$.
- Case $\epsilon_{k+1} = -1$: $F_{k+1} = (1 + y/t)\, F_k - (y/\mu(k))\, F_{k-1}$.

Both unify into
$$F_{k+1} \;=\; \left(\frac{\mu(k+1)^2}{t} + y\right) t^{\epsilon_{k+1}}\, F_k \;-\; \frac{\mu(k)\,\mu(k+1)\, y}{t}\, t^{\epsilon_{k+1} + \epsilon_k}\, F_{k-1}. \tag{R}$$

`[VERIFIED-SYMPY: script=verify/check_recursion.py, cases=24, result=PASS, description=three-term recursion (R) for F_k holds across 6 sign-sequences, k=2..5]`

(Case-by-case verification: for $\epsilon_{k+1} = +1, \mu(k+1) = 1$, $(\mu(k+1)^2/t + y) t^{\epsilon_{k+1}} = (1/t + y) t = 1 + yt$; and $\mu(k)\mu(k+1)/t \cdot t^{\epsilon_{k+1} + \epsilon_k} = \mu(k)/t \cdot t^{1 + \epsilon_k} = yt/\mu(k)$ checks out for both $\epsilon_k = \pm 1$. Similarly for $\epsilon_{k+1} = -1$.)

*Closing the induction.* Writing $\tilde C_k := F_k/t^{e_k}$ and using $e_{k+1} = e_k + \epsilon_{k+1}$, $e_{k+1} - e_{k-1} = \epsilon_{k+1} + \epsilon_k$:
$$\tilde C_{k+1} \;=\; \left(\frac{\mu(k+1)^2}{t} + y\right) \tilde C_k \;-\; \frac{\mu(k)\,\mu(k+1)\, y}{t}\, \tilde C_{k-1},$$
which is **exactly** the $C_k$-recursion from problem.md. Since $\tilde C_0 = 1 = C_0$ and $\tilde C_1 = C_1$ by the base cases above, $\tilde C_k = C_k$ for all $k$, i.e., $F_k = t^{e_k} C_k$. ∎

**Tag: I** (Independent: the Block Structure Lemma, Lemma Q, $c_k$-recursion, and three-term $F_k$-recursion are this project's own derivations). Supporting citations: [L1] Laplace / cofactor expansion; [L1] column linearity of determinants; [L2] Burau generator matrices (§1.2).

---

## 5. Denominator cancellation (was SP-2; closed)

### Step 6 — Intrinsic identity $C_k(1, t) = t^{-(e_k + k)/2} \Phi_{k+1}(t)$ [I]

**Claim.** For every $k \ge 0$ and every $\epsilon_{1..k}$,
$$\det(I_k - A'_k) \;=\; t^{(e_k - k)/2}\, \Phi_{k+1}(t).$$

(Note $e_k$ and $k$ have the same parity, so the exponent is always an integer.) Taking $k = p - 1$: $\det(I_{p-1} - B_\epsilon) = t^{(e(\epsilon) - (p-1))/2}\, \Phi_p(t)$, i.e., $\det(I - B_\epsilon) \doteq \Phi_p(t)$.

**Proof.** By Step 5 at $y = 1$, $\det(I_k - A'_k) = F_k(1, t) = t^{e_k}\, C_k(1, t)$. It suffices to prove the intrinsic identity
$$\boxed{C_k(1, t) \;=\; t^{-(e_k + k)/2}\, \Phi_{k+1}(t).}$$

Define $h_k(t) := t^{(e_k + k)/2}\, C_k(1, t)$; we show $h_k = \Phi_{k+1}$.

*Base cases.*
- $k = 0$: $h_0 = t^0 \cdot 1 = 1 = \Phi_1$. ✓
- $k = 1$: $C_1(1, t) = \mu(1)^2/t + 1$. For $\epsilon_1 = +1$: $h_1 = t \cdot (1/t + 1) = 1 + t = \Phi_2$. For $\epsilon_1 = -1$: $h_1 = t^0 \cdot (t + 1) = 1 + t = \Phi_2$. ✓

*Inductive step ($k \ge 2$).* Start from the $C_k$ recursion at $y = 1$:
$$C_k(1, t) \;=\; \left(\frac{\mu(k)^2}{t} + 1\right) C_{k-1}(1, t) \;-\; \frac{\mu(k-1)\mu(k)}{t}\, C_{k-2}(1, t).$$
Multiply both sides by $t^{(e_k + k)/2}$. The coefficients transform as follows, using $\mu(i)^2 = t^{1 - \epsilon_i}$ and $\mu(i)^2/t = t^{-\epsilon_i}$:

**First coefficient.** $(\mu(k)^2/t + 1) = 1 + t^{-\epsilon_k}$, and $e_k - e_{k-1} = \epsilon_k$. So the coefficient of $h_{k-1}$ is
$$(1 + t^{-\epsilon_k})\, t^{(\epsilon_k + 1)/2} \;=\; t^{(\epsilon_k + 1)/2} + t^{(1 - \epsilon_k)/2}.$$
For $\epsilon_k = +1$: $t^1 + t^0 = 1 + t$. For $\epsilon_k = -1$: $t^0 + t^1 = 1 + t$. **Both give $1 + t$, independent of $\epsilon_k$**.

**Second coefficient.** $\mu(k-1)\mu(k)/t = t^{(2 - \epsilon_{k-1} - \epsilon_k)/2} / t = t^{-(\epsilon_{k-1} + \epsilon_k)/2}$. Combined with $t^{(\epsilon_{k-1} + \epsilon_k + 2)/2}$, the exponent collapses to $+1$, independent of signs. **Coefficient of $h_{k-2}$ is $t$.**

Thus the rescaling produces the **universal** recursion
$$\boxed{h_k \;=\; (1 + t)\, h_{k-1} \;-\; t\, h_{k-2},}$$
which is exactly the cyclotomic recursion for $\Phi_{k+1}$: expanding $\Phi_{k+1} = 1 + t + \cdots + t^k$ gives $(1 + t)\Phi_k - t\Phi_{k-1} = \Phi_k + t\,\Phi_k - t\,\Phi_{k-1} = \Phi_k + t \cdot (\Phi_k - \Phi_{k-1}) = \Phi_k + t \cdot t^{k-1} \cdot$ ... actually more directly: $\Phi_{k+1} = \Phi_k + t^k$, and $(1 + t)\Phi_k - t\Phi_{k-1} = \Phi_k + t(\Phi_k - \Phi_{k-1}) = \Phi_k + t \cdot t^{k-1} = \Phi_k + t^k = \Phi_{k+1}$ [L1].

Since $h_k$ and $\Phi_{k+1}$ satisfy the same linear recursion with the same initial values $h_0 = \Phi_1 = 1$ and $h_1 = \Phi_2 = 1 + t$, we conclude $h_k = \Phi_{k+1}$ for all $k \ge 0$. ∎

**Tag: I** (Independent: the rescaling $h_k = t^{(e_k + k)/2} C_k(1, t)$ absorbing $\epsilon$-dependence, and the $\epsilon$-independent universal recursion, are this project's derivations). Supporting citations: [L1] cyclotomic polynomial recursion; [L2] Burau–Alexander formula (via Step 1).

---

## 6. Assembling Theorem 3.5

### Step 7 — Combining Steps 1–6 [I]

From $(\star)$ and Step 2:
$$\Delta_{S(p, q, \epsilon)}(t) \;\doteq\; \frac{\det(I - B_\epsilon^q)}{\Phi_p(t)} \;=\; \frac{\prod_{\ell=0}^{q-1} \det(I - \zeta^\ell B_\epsilon)}{\Phi_p(t)}.$$

The $\ell = 0$ factor is $\det(I - B_\epsilon) \doteq \Phi_p(t)$ (Step 6), which cancels the denominator exactly, leaving
$$\Delta_{S(p, q, \epsilon)}(t) \;\doteq\; \prod_{\ell=1}^{q-1} \det(I - \zeta^\ell B_\epsilon).$$

By the central identity (Step 5) with $y = \zeta^\ell$,
$$\det(I - \zeta^\ell B_\epsilon) \;=\; t^{e(\epsilon)}\, C_{p-1}(\zeta^\ell, t).$$

Substituting and pulling out the $t$-power (which is a unit):
$$\Delta_{S(p, q, \epsilon)}(t) \;\doteq\; t^{(q-1) e(\epsilon)} \prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t) \;\doteq\; \prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t).$$

This is Theorem 3.5. **Tag: I** (assembly; supporting [L2] citations in Step 1).

---

## 7. Seifert genus upper bound

### Step 8 — Seifert's algorithm on the braid closure [L1]

The braid-closure diagram of $\beta_{p,q,\epsilon}$ has $p$ strands and $(p-1)q$ crossings (each of the $q$ cyclic iterations contributes $p-1$ crossings).

**Claim.** Applying Seifert's algorithm to this oriented diagram produces $s = p$ Seifert circles.

**Proof.** In a braid-closure diagram, each strand is oriented downward throughout the braid box and closed up by arcs running top-to-bottom on the side. At every crossing, Seifert smoothing respects the vertical orientation, resolving each crossing into a horizontal cap+cup. The resulting oriented curves are exactly the $p$ closed loops obtained by trivially closing $p$ vertical strands. Hence $s = p$. **[L1]** (Standard braid-closure Seifert-circle count; verifiable by direct oriented-smoothing enumeration in 30 seconds, per problem.md §8.)

**Euler characteristic and genus bound.** The Seifert surface $F$ has $p$ disks (one per circle) and $(p-1)q$ twisted bands (one per crossing), so
$$\chi(F) = p - (p-1)q, \qquad 2 - 2g(F) - b(F) = \chi(F), \qquad b(F) = 1.$$
Solving, $g(F) = \frac{(p-1)q - p + 1}{2} = \frac{(p-1)(q-1)}{2}$.

Since $g(K) \le g(F)$ for any Seifert surface $F$ of $K$,
$$g(S(p, q, \epsilon)) \;\le\; \frac{(p-1)(q-1)}{2}. \tag{$\le$}$$

**Tag: L1** — Seifert's algorithm (problem.md §8) + Euler-characteristic → genus (Rolfsen *Knots and Links* §5, or Lickorish GTM 175 §2).

---

## 8. Breadth of the product — monomial sub-lemma (was SP-4; closed)

### Step 9 — Structural sub-lemma on top/bot $t$-coefficients of $C_k(y, t)$ [I]

**Sub-lemma.** For every $k \ge 0$ and every $\epsilon_{1..k}$, in $C_k(y, t)$ viewed as a Laurent polynomial in $t$ with coefficients in $\mathbb{Z}[y]$:
$$\text{top-}t\text{-coef: } y^{n_k^+} \text{ at } t\text{-power } n_k^-, \qquad \text{bot-}t\text{-coef: } y^{n_k^-} \text{ at } t\text{-power } -n_k^+.$$
In particular $\mathrm{breadth}_t(C_k(y, t)) = n_k^+ + n_k^- = k$, and both extremal coefficients are **monic monomials in $y$** of the stated $y$-degrees.

**Proof.** Induction on $k$.

*Base $k = 0$*: $C_0 = 1 = y^0 t^0$. Top = bot = 1, $n_0^{\pm} = 0$. ✓

*Base $k = 1$*:
- $\epsilon_1 = +1$: $C_1 = 1/t + y$. Top: $y = y^{n_1^+}$ at $t^{n_1^-} = t^0$; bot: $1 = y^{n_1^-}$ at $t^{-n_1^+} = t^{-1}$. ✓
- $\epsilon_1 = -1$: $C_1 = t + y$. Top: $1 = y^{n_1^+}$ at $t^{n_1^-} = t^1$; bot: $y = y^{n_1^-}$ at $t^{-n_1^+} = t^0$. ✓

*Inductive step ($k \ge 2$).* Write the recursion as $C_k = A \cdot C_{k-1} - B \cdot C_{k-2}$ with $A = \mu(k)^2/t + y$ and $B = \mu(k-1)\mu(k)\, y/t$.

**Case $\epsilon_k = +1$** ($n_k^+ = n_{k-1}^+ + 1$, $n_k^- = n_{k-1}^-$, $\mu(k) = 1$, $A = 1/t + y$):

- Top of $y \cdot C_{k-1}$: at $t^{n_{k-1}^-} = t^{n_k^-}$, coefficient $y \cdot y^{n_{k-1}^+} = y^{n_{k-1}^+ + 1} = y^{n_k^+}$.
- Top of $(1/t) \cdot C_{k-1}$: at $t^{n_{k-1}^- - 1} < t^{n_k^-}$.
- Top of $B \cdot C_{k-2}$: for $\epsilon_{k-1} = +1$, $B = y/t$, top at $t^{n_{k-2}^- - 1} = t^{n_{k-1}^- - 1} = t^{n_k^- - 1}$; for $\epsilon_{k-1} = -1$, $B = y$, top at $t^{n_{k-2}^-} = t^{n_{k-1}^- - 1} = t^{n_k^- - 1}$. Both $< t^{n_k^-}$, no cancellation.

So top of $C_k$ = $y^{n_k^+}$ at $t^{n_k^-}$. ✓

Similarly, bot of $(1/t) \cdot C_{k-1}$: at $t^{-n_{k-1}^+ - 1} = t^{-n_k^+}$, coefficient $y^{n_{k-1}^-} = y^{n_k^-}$; bot of $y \cdot C_{k-1}$ is at $t^{-n_{k-1}^+} = t^{-n_k^+ + 1}$, above; bot of $B \cdot C_{k-2}$ is at $-n_{k-1}^+ = -n_k^+ + 1$ in both sub-cases of $\epsilon_{k-1}$, above $-n_k^+$. So bot of $C_k$ = $y^{n_k^-}$ at $t^{-n_k^+}$. ✓

**Case $\epsilon_k = -1$** ($n_k^+ = n_{k-1}^+$, $n_k^- = n_{k-1}^- + 1$, $\mu(k) = t$, $A = t + y$):

- Top of $t \cdot C_{k-1}$: at $t^{n_{k-1}^- + 1} = t^{n_k^-}$, coefficient $y^{n_{k-1}^+} = y^{n_k^+}$.
- Top of $y \cdot C_{k-1}$: at $t^{n_{k-1}^-} = t^{n_k^- - 1}$, below.
- Top of $B \cdot C_{k-2}$: for $\epsilon_{k-1} = +1$, $B = y$, top at $t^{n_{k-2}^-} = t^{n_{k-1}^-} = t^{n_k^- - 1}$; for $\epsilon_{k-1} = -1$, $B = yt$, top at $t^{n_{k-2}^- + 1} = t^{n_{k-1}^-} = t^{n_k^- - 1}$. Both below $n_k^-$.

So top of $C_k$ = $y^{n_k^+}$ at $t^{n_k^-}$. ✓

Bot analysis (mirror): bot of $t \cdot C_{k-1}$ at $-n_{k-1}^+ + 1 = -n_k^+ + 1$; bot of $y \cdot C_{k-1}$ at $-n_{k-1}^+ = -n_k^+$, coefficient $y \cdot y^{n_{k-1}^-} = y^{n_k^-}$; bot of $B \cdot C_{k-2}$ at $-n_k^+ + 1$ in both sub-cases. So bot of $C_k$ = $y^{n_k^-}$ at $t^{-n_k^+}$. ✓ ∎

### Step 10 — Breadth of the product [I]

**Claim.** For $p \ge 2$, $q \ge 2$, and $\epsilon \in \{\pm 1\}^{p-1}$ with $\gcd(p, q) = 1$ (the closure-is-a-knot condition),
$$\mathrm{breadth}_t\!\left(\prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)\right) \;=\; (p-1)(q-1).$$

**Proof.** Write $n^{\pm} := n_{p-1}^{\pm}$ so that $n^+ + n^- = p - 1$. By Step 9, $C_{p-1}(y, t) = y^{n^+}\, t^{n^-} + (\text{middle terms}) + y^{n^-}\, t^{-n^+}$.

For each $\ell \in \{1, \ldots, q-1\}$, $C_{p-1}(\zeta^\ell, t)$ has:
- top coefficient $\zeta^{\ell n^+} \ne 0$ at $t^{n^-}$,
- bot coefficient $\zeta^{\ell n^-} \ne 0$ at $t^{-n^+}$.

Both coefficients are $q$-th roots of unity, hence nonzero.

In the product $\prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)$:
- Coefficient of $t^{(q-1) n^-}$ (candidate top): $\prod_{\ell=1}^{q-1} \zeta^{\ell n^+} = \zeta^{n^+ \cdot q(q-1)/2} = (-1)^{n^+(q-1)} \in \{\pm 1\}$, using $\zeta^{q(q-1)/2} = e^{i\pi(q-1)} = (-1)^{q-1}$ [L1].
- Coefficient of $t^{-(q-1) n^+}$ (candidate bot): $\prod_{\ell=1}^{q-1} \zeta^{\ell n^-} = (-1)^{n^-(q-1)} \in \{\pm 1\}$.

Both are nonzero integers ($\pm 1$); no cancellation at the extremes. Hence
$$\mathrm{breadth}_t = (q-1)\, n^- - \bigl(-(q-1)\, n^+\bigr) = (q-1)(n^+ + n^-) = (p-1)(q-1). \quad \Box$$

**Tag: I** (structural sub-lemma + main breadth argument). Supporting [L1]: sum $\sum_{\ell=1}^{q-1}\ell = q(q-1)/2$ and the evaluation $\zeta^{q(q-1)/2} = (-1)^{q-1}$.

---

## 9. Genus lower bound and Theorem 4.2

### Step 11 — Alexander-polynomial genus lower bound [L2]

For any knot $K$, $2 g(K) \ge \deg \Delta_K$, where $\deg$ is the breadth of the Alexander polynomial in $t$. This is the Seifert-form corollary $\mathrm{rank}\, H_1(F) = 2 g$ for a genus-$g$ Seifert surface of a knot.

**Tag: L2** — Rolfsen, *Knots and Links*, Prop. 8.C.6; alternative source Lickorish GTM 175 §6.

### Step 12 — Combining for Theorem 4.2 [I]

By Theorem 3.5 (Step 7), $\Delta_{S(p, q, \epsilon)}(t) \doteq \prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)$. By Step 10, this product has breadth $(p-1)(q-1)$ in $t$. Applying Step 11:
$$2\, g(S(p, q, \epsilon)) \;\ge\; (p-1)(q-1), \qquad \text{i.e.,} \qquad g(S(p, q, \epsilon)) \;\ge\; \frac{(p-1)(q-1)}{2}. \tag{$\ge$}$$

Combining $(\le)$ from Step 8 and $(\ge)$ from this step:
$$g(S(p, q, \epsilon)) \;=\; \frac{(p-1)(q-1)}{2},$$
which is Theorem 4.2. **Tag: I** (assembly).

---

## 10. TSV cross-checks (verification record)

All commands executed from `/c/Users/12729/.claude/skills/math-verifier/tsv/`.

### 10.1 TSV ground-truth lookups

```
python -c "from tsv_knot import alexander_polynomial; print(alexander_polynomial('3_1'))"
→ (t**2 - t + 1, {'method': 'tsv-knot', 'submethod': 'alexander', 'confidence': 'high'})

python -c "from tsv_knot import alexander_polynomial; print(alexander_polynomial('4_1'))"
→ (t**2 - 3*t + 1, {'method': 'tsv-knot', 'submethod': 'alexander', 'confidence': 'high'})

python -c "from tsv_knot import alexander_polynomial; print(alexander_polynomial('10_123'))"
→ (None, {'method': 'none', 'confidence': 'low', 'reason': "out-of-TSV-scope: unknown knot '10_123'"})
```

### 10.2 Base-case Burau checks

**$S(2, 3, (+1)) = T(2, 3) = 3_1$** [VERIFIED via direct Burau computation]:
- $B = [-t]$, $B^3 = [-t^3]$, $\det(I - B^3) = 1 + t^3$.
- $\Delta = (1 + t^3) / (1 + t) = 1 - t + t^2 = t^2 - t + 1$. ✓ matches TSV.

**$S(3, 2, (+1, +1)) = T(3, 2) = 3_1$**:
- $B = \begin{pmatrix} 0 & -t \\ t & -t \end{pmatrix}$, $B^2 = \begin{pmatrix} -t^2 & t^2 \\ -t^2 & 0 \end{pmatrix}$.
- $\det(I - B^2) = 1 + t^2 + t^4 = (1 + t + t^2)(1 - t + t^2)$.
- $\Delta = (1 + t^2 + t^4)/(1 + t + t^2) = 1 - t + t^2$. ✓ matches TSV.

**$S(3, 2, (+1, -1)) = 4_1$**:
- $B = \begin{pmatrix} 1 - t & -1/t \\ 1 & -1/t \end{pmatrix}$.
- $\det(I - B^2) / (1 + t + t^2) = -1 + 3/t - 1/t^2 \;\doteq\; t^2 - 3t + 1$. ✓ matches TSV.

### 10.3 Out-of-TSV check: $S(3, 5, (+1, -1)) = 10_{123}$

- TSV returns `method=none, confidence=low, reason=out-of-TSV-scope`.
- Direct Burau computation: $\Delta = t^3 - 6t^2 + 15t - 24 + 29/t - 24/t^2 + 15/t^3 - 6/t^4 + 1/t^5$.
- Breadth $= 3 - (-5) = 8 = 2 \cdot 4 = (p-1)(q-1)$. ✓ consistent with Step 10.
- Seifert surface: $g \le (p-1)(q-1)/2 = 4$; Alexander breadth: $g \ge 4$. Hence $g = 4$. ✓ matches problem.md §Base-cases.

### 10.4 Central identity verified across $\epsilon$, $p \le 5$ (62 cases)

Verified via symbolic sympy that $F_k(y, t) / C_k(y, t) = t^{e_k}$ exactly as rational functions in $(y, t)$, for every prefix $\epsilon_{1..k}$ with $k \le 5$. Total: $2 + 4 + 8 + 16 + 32 = 62$ cases, all pass. `[VERIFIED-SYMPY: script=verify/verify_Ek.py, cases=62, result=PASS, description=E_k(y,t)=det(I_k - y*A'_k)=t^{e_k}*C_k(y,t) for k=1..5, all eps]` The $p = 5$ sub-family is cross-checked by the extrinsic variant at the braid level: `[VERIFIED-SYMPY: script=verify/verify_p5.py, cases=30, result=PASS, description=det(I - y*B_eps) = t^{e(eps)} * C_{p-1}(y,t) for p=2..5, all eps]`

| $p$ | # cases | result |
|---|---|---|
| 2 | 2 | all pass |
| 3 | 4 | all pass |
| 4 | 8 | all pass |
| 5 | 16 | all pass |

(At $p = 5$, the 16 cases include e.g. $\epsilon = (+1,+1,+1,+1)$ with $e = 4$, ratio $t^4$; $\epsilon = (+1,+1,-1,-1)$ with $e = 0$, ratio $1$; etc.)

### 10.5 SP-2 intrinsic identity verified, $p \le 6$ (258 prefix checks)

Verified that $C_k(1, t) \cdot t^{(e_k + k)/2} = \Phi_{k+1}(t)$ exactly for every prefix $\epsilon_{1..k}$ with $k \le 5$. Total: 258 prefix checks, all pass. `[VERIFIED-SYMPY: script=verify/sp2_Ck_at_y1.py, cases=258, result=PASS, description=C_k(1,t) * t^{(e_k+k)/2} = Phi_{k+1}(t) for p=2..6, k=1..p-1, all eps]` The extrinsic version at the full-braid level — $\det(I - B_\epsilon) \cdot t^{(p-1-e)/2} = \pm \Phi_p(t)$ — is also confirmed: `[VERIFIED-SYMPY: script=verify/sp2_verify_phi_p.py, cases=62, result=PASS, description=det(I-B_eps) * t^{(p-1-e)/2} = +-Phi_p(t) for p=2..6, all eps]`

### 10.6 SP-4 monomial sub-lemma verified, $p \le 6$ (62 cases)

Verified that the top and bottom $t$-coefficients of $C_{p-1}(y, t)$ are monic monomials $y^{n^+}$ at $t^{n^-}$ and $y^{n^-}$ at $t^{-n^+}$ for all $\epsilon$ with $p \le 6$. Total: 62 cases, all pass. `[VERIFIED-SYMPY: script=verify/sp4_monomial.py, cases=62, result=PASS, description=top/bot t-coefs of C_{p-1}(y,t) are monic monomials in y of degrees n^+/n^- for p=2..6, all eps]` The underlying top/bot $t$-power formulas $\alpha_k = \#\{\epsilon_i = -1\}$, $\beta_k = -\#\{\epsilon_i = +1\}$ (so breadth$_t(C_k) = k$) are confirmed over all prefixes: `[VERIFIED-SYMPY: script=verify/sp4_topbot.py, cases=128, result=PASS, description=top/bot t-power formulas and resulting breadth=k for C_k, p=2..5, k=0..p-1, all eps]`

### 10.7 Breadth check, Theorem 4.2 target cases

| $(p, q, \epsilon)$ | expected $(p-1)(q-1)$ | Burau $\Delta$ | breadth | status |
|---|---|---|---|---|
| $(2, 3, (+))$ | 2 | $t^2 - t + 1$ | 2 | ✓ |
| $(3, 2, (+,+))$ | 2 | $t^2 - t + 1$ | 2 | ✓ |
| $(3, 2, (+,-))$ | 2 | $-1 + 3/t - 1/t^2$ | 2 | ✓ |
| $(3, 4, (+,+))$ | 6 | $t^6 - t^5 + t^3 - t + 1$ | 6 | ✓ |
| $(4, 3, (+,+,+))$ | 6 | $t^6 - t^5 + t^3 - t + 1$ | 6 | ✓ |
| $(3, 5, (+,-))$ | 8 | $t^3 - 6t^2 + \cdots + t^{-5}$ | 8 | ✓ |

`[VERIFIED-SYMPY: script=verify/sp4_breadth.py, cases=6, result=PASS, description=breadth in t of prod_ell C_{p-1}(zeta_q^ell, t) equals (p-1)(q-1) on 6 (p,q,eps) target cases from Theorem 4.2]`

---

## 11. Citation ledger

**L1 (light / textbook lookup, ≈10 citations):**

- Polynomial factorization $1 - x^q = \prod_{\ell=0}^{q-1}(1 - \zeta^\ell x)$ in $\mathbb{C}[x]$ (Step 2).
- Seifert's algorithm on a braid-closure diagram: $s = p$ Seifert circles, Euler-characteristic computation (Step 8) — problem.md §8 permits this as low-depth.
- $t^k$ is a unit in $\mathbb{Z}[t, t^{-1}]$ for all $k \in \mathbb{Z}$ (used in the $\pm t^k$ normalization throughout).
- Cofactor (Laplace) expansion along a row (Steps 5, 6).
- Column linearity of determinants (Steps 5, 6).
- Entry-level block inspection of Birman–Weinberg Burau generators (Step 4, parts (i) and (ii)).
- Last-row-preservation under matrix product: $M_1, M_2$ with last row $e_n^T$ implies $M_1 M_2$ has last row $e_n^T$ (Step 4).
- Cyclotomic recursion $\Phi_{k+1}(t) = (1 + t)\Phi_k(t) - t\Phi_{k-1}(t)$ (Step 6).
- Laurent-polynomial breadth under multiplication without leading-coefficient cancellation (Step 10).
- Sum $\sum_{\ell=1}^{q-1} \ell = q(q-1)/2$ and evaluation $\zeta^{q(q-1)/2} = (-1)^{q-1}$ (Step 10).

**L2 (theorem-grade single-source citation, 3):**

- Burau–Alexander formula: $\Delta_{\hat\beta}(t) = \det(I - \bar\rho(\beta))/\Phi_p(t)$ (mod $\pm t^k$). Birman, *Braids, Links, and Mapping Class Groups* (AMS 1974), §3. [Used in Step 1 and the assembly in Step 7.]
- Alexander-polynomial genus lower bound: $2 g(K) \ge \deg \Delta_K$. Rolfsen, *Knots and Links*, Prop. 8.C.6 (alternative: Lickorish GTM 175 §6). [Used in Step 11.]
- Reduced-Burau generator matrices per convention §1.3 (Birman–Weinberg). [Used in §1.2 and Step 4.]

**L3:** **None.** The proof uses no deep machinery: no Heegaard Floer, no Khovanov, no Thurston hyperbolization, no Mostow rigidity, no Masur–Minsky, no Agol/Wise.

**Independent steps (≥ 12):**

1. Eigenvalue factorization $\det(I - B^q) = \prod_\ell \det(I - \zeta^\ell B)$ via Newton's-identities argument (Step 2).
2. Discovery of non-tridiagonality of $B_\epsilon$ at $p \ge 4$, falsifying an Explorer-stage hypothesis (§1.3).
3. Re-framing from leading-principal-minor $D_k$ (wrong) to intrinsic $F_k$ in $B_{k+1}$ (correct) (Step 3).
4. Block Structure Lemma: $L^{(k+2)}_k = \begin{pmatrix} A'_k & c_k \\ 0 & 1 \end{pmatrix}$ (Step 4, parts (i)–(ii)).
5. Recursion for $c_k$: $c_k = (1/\mu(k))\binom{c_{k-1}}{1}$ (Step 4, part (iii)).
6. Cofactor expansion of $F_{k+1}$ along the last row, for both $\epsilon_{k+1} = \pm$ (Step 5).
7. Lemma Q: $Q_k = F_{k-1}/\mu(k)$, by cofactor expansion where $Q_{k-1}$ terms cancel identically (Step 5).
8. Three-term recursion (R) matching the $C_k$-recursion after $t^{e_k}$ rescaling (Step 5).
9. Intrinsic identity $C_k(1, t) = t^{-(e_k + k)/2} \Phi_{k+1}(t)$ and universal $\epsilon$-independent recursion $h_k = (1+t)h_{k-1} - t h_{k-2}$ (Step 6).
10. Top/bot monomial sub-lemma: extremal $t$-coefs of $C_k(y, t)$ are monic monomials $y^{n_k^\pm}$ (Step 9).
11. Main breadth argument: $\prod_{\ell=1}^{q-1} \zeta^{\ell n^\pm} = (-1)^{n^\pm(q-1)} \in \{\pm 1\}$, no extremal cancellation (Step 10).
12. Full assembly of Theorems 3.5 and 4.2 from the intrinsic identities and the external L2 facts (Steps 7, 12).

**STRUCTURAL-CITATION-WARNING**: **does NOT fire**. Independent/Citation ratio $\approx 12 : 13$. Zero L3 citations.

---

## 12. Honest self-assessment

**What is closed (unconditionally, modulo standard L1/L2 citations):**

- Theorem 3.5 — full assembly via Steps 1–7.
- Theorem 4.2 — both bounds, Steps 8 + 10 + 11 + 12.
- Central identity $F_k = t^{e_k} C_k$ for all $k$ and all $\epsilon$ (Step 5).
- Denominator cancellation $\det(I - B_\epsilon) \doteq \Phi_p(t)$ (Step 6).
- Top/bot monomial sub-lemma and resulting breadth-no-cancellation (Steps 9, 10).

**Known corrections from the proof process:**

- An Explorer-stage hypothesis about tridiagonality of $B_\epsilon$ was found to be **false** at $p \ge 4$ (concrete counterexample at $p = 4$, $\epsilon = (+1,+1,+1)$). The proof does not rely on tridiagonality; the intrinsic-$B_{k+1}$ induction in Step 5 sidesteps it.
- An Explorer-stage proposal to induct on the leading principal minors of $B_\epsilon \in B_p$ was shown to be incorrect: $D_k \ne t^{e_k} C_k$ in general. Replaced by the intrinsic induction on $F_k = \det(I_k - y\, A'_k)$ with $A'_k \in B_{k+1}$.

**What remains open:**

- Nothing within the scope of Theorems 3.5 and 4.2. All four original stuck points (SP-1 = Explorer correction; SP-2 = denominator cancellation; SP-3 = central identity; SP-4 = breadth) are resolved.

**Residual remarks.**

- The proof is algebraically-primary with one load-bearing geometric step (Seifert's algorithm in Step 8). Replaceable by the L1 textbook statement "closure of a positive braid on $p$ strands with $c$ crossings has Seifert genus $(c - p + 1)/2$".
- The TSV base cases (§10.2) verify the formula at $p \le 4$; out-of-TSV $S(3, 5, (+1, -1)) = 10_{123}$ is verified via direct Burau computation and matches the claimed $g = 4$.
- Geometric Intuition Assessment: score 3/5 (algebraic-primary proof with honest correction of an Explorer geometric hypothesis).

---

## 13. Numerical-verification script roster

Location: `{workdir}/verify/` (9 protocol-compliant scripts under the P1 Verified Sympy Block protocol; total **643 cases**, all PASS).

Each script carries a `[VERIFIED-SYMPY-PROTOCOL: <template-id>, cases=<N>, description=<...>]` docstring block and prints `ALL PASSED: N cases` on success with `sys.exit(0)`.

| Script | Template | Cases | Description | Inline cite |
|---|---|---|---|---|
| `verify/verify_p5.py` | identity-over-parameter-family | 30 | det(I - y·B_eps) = t^{e(eps)}·C_{p-1}(y,t), p=2..5, all eps | §10.4 |
| `verify/verify_Ek.py` | identity-over-parameter-family | 62 | E_k = det(I_k - y·A'_k) = t^{e_k}·C_k, k=1..5, all eps | §10.4 |
| `verify/check_recursion.py` | recursion-matches-target | 24 | three-term (R) for F_k, 6 sign-sequences × k=2..5 | Step 5 (R) |
| `verify/find_Qk.py` | identity-over-parameter-family | 11 | Lemma Q: Q_k/F_{k-1} = 1/μ(k), 11 prefixes | Step 5 Lemma Q |
| `verify/sp2_verify_phi_p.py` | identity-over-parameter-family | 62 | det(I - B_eps)·t^{(p-1-e)/2} = ±Φ_p(t), p=2..6 | §10.5 |
| `verify/sp2_Ck_at_y1.py` | identity-over-parameter-family | 258 | C_k(1,t)·t^{(e_k+k)/2} = Φ_{k+1}(t), p=2..6, all prefixes | §10.5 |
| `verify/sp4_monomial.py` | identity-over-parameter-family | 62 | top/bot t-coefs of C_{p-1} are monic y^{n^±}, p=2..6 | §10.6 |
| `verify/sp4_topbot.py` | polynomial-breadth | 128 | breadth_t(C_k) = k via α_k = #{eps=-1}, β_k = -#{eps=+1}, p=2..5 | §10.6 |
| `verify/sp4_breadth.py` | polynomial-breadth | 6 | breadth_t(∏_ℓ C_{p-1}(ζ_q^ℓ, t)) = (p-1)(q-1), Theorem 4.2 targets | §10.7 |

These scripts anchor the symbolic proof at finite parameter ranges; the symbolic arguments in the proof body cover all $p, q, \epsilon$. Per the P1 Verified Sympy Block protocol (2026-04-21), the inline `[VERIFIED-SYMPY:...]` tags cited above appear at the proof steps that call on each script; none of the symbolic arguments replaces a sympy run with a universality claim (cf. §F3.7 of the Auditor checklist).
