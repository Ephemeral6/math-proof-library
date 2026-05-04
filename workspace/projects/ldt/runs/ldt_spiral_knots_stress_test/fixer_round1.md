# Fixer Round 1 — target SP-3 (key Burau-identity induction)

## Setup and induction strategy

**Target identity.** For every $p \ge 2$ and every $\epsilon \in \{\pm 1\}^{p-1}$,
$$\det(I_{p-1} - y\,B_\epsilon) \;=\; t^{e(\epsilon)} \, C_{p-1}(y, t), \qquad
e(\epsilon) := \sum_{i=1}^{p-1} \epsilon_i,$$
where $B_\epsilon = \bar\rho_p(\sigma_1^{\epsilon_1}\cdots\sigma_{p-1}^{\epsilon_{p-1}})$
is the reduced-Burau image of the spiral braid word, using the Birman–Weinberg
convention §1.3 (recorded in best_proof.md Step 4).

**Key reframing (correcting the Explorer's framing).** The Explorer proposed
inducting via the leading principal minors $D_k(y) := \det(I_k - y B_\epsilon^{[k]})$
of the **full** matrix $B_\epsilon$ in $B_p$. **This does not work**: direct
computation (fixer_work/explore_structure.py, output below) shows that for
$\epsilon = (+1,+1,+1)$ at $p = 4$ we have $D_1 = D_2 = 1$ but $D_3 = 1 + yt + y^2t^2 + y^3t^3
= t^3 C_3(y,t)$. So $D_k$ for $k < p-1$ does **not** match $t^{e_k} C_k$. The
principal minors of $B_\epsilon$ in $B_p$ are not the right induction variable.

**Correct induction variable.** Define
$$A'_k \;:=\; \bar\rho_{k+1}(\sigma_1^{\epsilon_1}\cdots\sigma_k^{\epsilon_k})
\in GL_k(\mathbb{Z}[t,t^{-1}]),$$
the reduced-Burau product in the **smaller** braid group $B_{k+1}$, which is a
$k \times k$ matrix. Note $A'_{p-1} = B_\epsilon$. Define
$$F_k(y, t) \;:=\; \det(I_k - y\,A'_k).$$
We will prove by induction on $k$ that
$$\boxed{F_k(y, t) \;=\; t^{e_k} \, C_k(y, t), \qquad e_k := \epsilon_1 + \cdots + \epsilon_k.}$$
Taking $k = p-1$ gives the target identity.

**The bridge between $B_m$ and $B_{m+1}$** (crucial for the induction).
For any $1 \le k$ and any $m \ge k+1$, define the $k$-generator lift to $B_m$:
$$L^{(m)}_k := \bar\rho_m(\sigma_1^{\epsilon_1}\cdots\sigma_k^{\epsilon_k}),$$
a $(m-1)\times(m-1)$ matrix. Note $A'_k = L^{(k+1)}_k$ and the "one-strand lift"
of interest is $L^{(k+2)}_k$, which is $(k+1)\times(k+1)$. The key structural
claim is:

> **Block Structure Lemma.** For $k \ge 1$,
> $$L^{(k+2)}_k \;=\; \begin{pmatrix} A'_k & c_k \\ 0 & 1 \end{pmatrix}$$
> for some column vector $c_k \in \mathbb{Z}[t,t^{-1}]^k$ (to be identified below).

**Proof of the lemma.** It suffices to show that (i) the last row of $L^{(k+2)}_k$ equals
$e_{k+1}^T = (0,\ldots,0,1)$, and (ii) the top-left $k \times k$ block of $L^{(k+2)}_k$
equals $A'_k$.

*For (i).* For $1 \le j \le k$, the reduced-Burau matrix $\bar\rho_{k+2}(\sigma_j^{\pm 1})$
in $B_{k+2}$ has last row equal to $e_{k+1}^T$. This is a direct entry-level check
on the Birman–Weinberg block structure:
  - For $j \le k-1$: the block $U_j$ of $\bar\rho_{k+2}(\sigma_j)$ sits on rows
    $\le k$ (block rows $j$ or $j-1, j, j+1$, all $\le k$), so row $k+1$ of
    $\bar\rho_{k+2}(\sigma_j)$ is the identity row, $(0,\ldots,0,1)$.
  - For $j = k$: the 3×3 block $U_k = \begin{pmatrix}1&0&0\\ t&-t&1\\ 0&0&1\end{pmatrix}$
    sits on rows $(k-1, k, k+1)$. Row 3 of this block is $(0, 0, 1)$, so row $k+1$
    of $\bar\rho_{k+2}(\sigma_k)$ is $(0,\ldots,0,1) = e_{k+1}^T$.
  - The inverse block $U_k^{-1} = \begin{pmatrix}1&0&0\\ 1&-1/t&1/t\\ 0&0&1\end{pmatrix}$
    has the same property (row 3 = $(0,0,1)$), so $\bar\rho_{k+2}(\sigma_k^{-1})$
    also has last row $e_{k+1}^T$.

The product of matrices each with last row $e_{k+1}^T$ has last row $e_{k+1}^T$
(this is elementary: if $M_1, M_2$ each have last row $e_n^T$, then
$(M_1 M_2)_{n,j} = \sum_i (M_1)_{n,i}(M_2)_{i,j} = (M_2)_{n,j}$ which is
$(e_n^T)_j = \delta_{n,j}$). Induction on the number of factors gives the claim.
**Tag: L1** (entry-level matrix-block computation).

*For (ii).* For $1 \le j \le k$, the top-left $k \times k$ block of
$\bar\rho_{k+2}(\sigma_j^{\pm 1})$ equals $\bar\rho_{k+1}(\sigma_j^{\pm 1})$.
Again by direct entry check: the difference between the two Burau matrices
occurs only at positions that involve row or column $k+1$ of the $(k+1)$-dim
space (for $\bar\rho_{k+1}$) vs. row/col $k+1$ in the $(k+2)$-dim space, which
lie beyond the top-left $k \times k$ block when $j \le k - 1$. For $j = k$,
$\bar\rho_{k+1}(\sigma_k)$ uses a 2×2 block $U_{k}^{(\text{last})} = \begin{pmatrix}1&0\\ t&-t\end{pmatrix}$
at rows/cols $(k-1, k)$, while $\bar\rho_{k+2}(\sigma_k)$ uses the 3×3 middle
block at rows/cols $(k-1, k, k+1)$. Inspecting the top-left 2×2 corner of
$U_k^{(\text{mid})} = \begin{pmatrix}1&0&0\\ t&-t&1\\ 0&0&1\end{pmatrix}$ gives
$\begin{pmatrix}1&0\\ t&-t\end{pmatrix} = U_k^{(\text{last})}$. ✓

(And likewise for inverses.) Since each factor has top-left $k \times k$ block
matching the corresponding $B_{k+1}$ generator, and since the top-left block of
a block-triangular product (when last row is $e_{k+1}^T$) is the product of top-left
blocks (direct expansion), the top-left $k \times k$ block of $L^{(k+2)}_k$ equals
$A'_k$. **Tag: L1.** ∎

With the lemma, $L^{(k+2)}_k = \begin{pmatrix} A'_k & c_k \\ 0 & 1\end{pmatrix}$ for some
$c_k$.

**Recursion for $c_k$.** Write
$L^{(k+2)}_k = L^{(k+2)}_{k-1} \cdot \bar\rho_{k+2}(\sigma_k^{\epsilon_k})$,
where $L^{(k+2)}_{k-1}$ is the $(k+1)\times(k+1)$ matrix obtained by the
"two-strand lift" of $A'_{k-1}$ to $B_{k+2}$. Applying the Block Structure Lemma
twice — first to $A'_{k-1}$ (lifted once to $B_{k+1}$ giving
$\begin{pmatrix} A'_{k-1} & c_{k-1} \\ 0 & 1\end{pmatrix}$), then to that lift
(lifted once more to $B_{k+2}$) — together with the "last row = $e^T$" argument
applied at both levels, gives:
$L^{(k+2)}_{k-1} = \begin{pmatrix} A'_{k-1} & c_{k-1} & 0 \\ 0 & 1 & 0 \\ 0 & 0 & 1\end{pmatrix}$.

(More directly: $L^{(k+2)}_{k-1} = \bar\rho_{k+2}(\sigma_1^{\epsilon_1}\cdots\sigma_{k-1}^{\epsilon_{k-1}})$;
by the same entry-level inspection used for the Block Structure Lemma, its last
two rows are both fixed as identity rows $e_k^T$ and $e_{k+1}^T$ respectively,
and its top-left $(k-1)\times(k-1)$ block equals $A'_{k-1}$, and its $k$-th
column's top $k-1$ entries are $c_{k-1}$.)

Right-multiplication by $\bar\rho_{k+2}(\sigma_k^{\epsilon_k})$. For $k \ge 2$
this is the **middle-generator** 3×3 block form in $B_{k+2}$ (since
$2 \le k \le (k+2) - 2 = k$), acting on cols $(k-1, k, k+1)$ of $L^{(k+2)}_{k-1}$.
For $k = 1$, $\sigma_1$ uses the 2×2 **first-boundary** block $U_1^{\epsilon_1}$
at rows/cols $(1, 2)$ of $B_3$'s reduced Burau; we handle this as an explicit
base case afterwards. Focusing on $k \ge 2$:

For $\epsilon_k = +1$ (block $U = \begin{pmatrix}1&0&0\\ t&-t&1\\ 0&0&1\end{pmatrix}$):
  - New col $k-1$ of $L^{(k+2)}_k$: (old col $k-1$) $+ t \cdot$ (old col $k$).
  - New col $k$: $-t \cdot$ (old col $k$).
  - New col $k+1$: (old col $k$) $+$ (old col $k+1$).

For $\epsilon_k = -1$ (block $U^{-1} = \begin{pmatrix}1&0&0\\ 1&-1/t&1/t\\ 0&0&1\end{pmatrix}$):
  - New col $k-1$: (old col $k-1$) $+$ (old col $k$).
  - New col $k$: $-(1/t) \cdot$ (old col $k$).
  - New col $k+1$: $(1/t)\cdot$(old col $k$) $+$ (old col $k+1$).

In either case, the new col $k+1$ = (factor) $\cdot$ (old col $k$ of $L^{(k+2)}_{k-1}$) +
(old col $k+1$ of $L^{(k+2)}_{k-1}$). Old col $k$ of $L^{(k+2)}_{k-1}$ is
$\binom{c_{k-1}}{1}$ with trailing 0 appended, i.e., $(c_{k-1}; 1; 0)$. Old col
$k+1$ is $e_{k+1} = (0; \ldots; 0; 1)$.

Computing the top $k$ entries of new col $k+1$ of $L^{(k+2)}_k$ (which by definition
equals $c_k$):

- $\epsilon_k = +1$: $(1 \cdot c_{k-1} + 0; 1 \cdot 1 + 0) = \binom{c_{k-1}}{1}$.
- $\epsilon_k = -1$: $(1/t)(c_{k-1}; 1) = \binom{c_{k-1}/t}{1/t} = (1/t)\binom{c_{k-1}}{1}$.

Unifying with $\mu(k) \in \{1, t\}$:
$$\boxed{c_k \;=\; \frac{1}{\mu(k)}\,\binom{c_{k-1}}{1}, \qquad c_0 := () \text{ (empty)}.}$$

(Base $k = 1$: $L^{(3)}_0 = I_2$, so $L^{(3)}_1 = \bar\rho_3(\sigma_1^{\epsilon_1})
= U_1^{\epsilon_1}$ with $U_1 = \begin{pmatrix}-t & 1\\ 0 & 1\end{pmatrix}$ and
$U_1^{-1} = \begin{pmatrix}-1/t & 1/t\\ 0 & 1\end{pmatrix}$. The last column's
top-1 entry gives $c_1 = (1)$ for $\epsilon_1 = +1$ and $c_1 = (1/t)$ for $\epsilon_1 = -1$,
which matches the formula $(1/\mu(1))\cdot\binom{c_0}{1} = (1/\mu(1))\cdot(1)$.
So the $c_k$ recursion extends uniformly to $k = 1$.)

## The cofactor expansion

We now compute $F_{k+1} = \det(I_{k+1} - y\,A'_{k+1})$ using the block description
$A'_{k+1} = L_k \cdot \bar\rho_{k+2}(\sigma_{k+1}^{\epsilon_{k+1}})$, where
$\sigma_{k+1}$ is the **last** generator of $B_{k+2}$ and thus uses the **2×2**
boundary block on rows/cols $(k, k+1)$.

Let $a_1, \ldots, a_k$ denote the columns of $A'_k$ (in $\mathbb{Z}[t,t^{-1}]^k$).
The columns of $L^{(k+2)}_k$ are
$\binom{a_1}{0}, \ldots, \binom{a_k}{0}, \binom{c_k}{1}$.

Right-multiplying $L^{(k+2)}_k$ by $\bar\rho_{k+2}(\sigma_{k+1}^{\epsilon_{k+1}})$
(with 2×2 block at rows/cols $(k, k+1)$) affects only the last two columns:

For $\epsilon_{k+1} = +1$ (block $\begin{pmatrix}1&0\\ t&-t\end{pmatrix}$, cols
$(1,t)^T$ and $(0,-t)^T$):
  - New col $k$ of $A'_{k+1} = 1 \cdot \binom{a_k}{0} + t \cdot \binom{c_k}{1}
    = \binom{a_k + t c_k}{t}$.
  - New col $k+1$ of $A'_{k+1} = 0 \cdot \binom{a_k}{0} + (-t)\cdot \binom{c_k}{1}
    = \binom{-tc_k}{-t}$.

For $\epsilon_{k+1} = -1$ (block $\begin{pmatrix}1&0\\ 1&-1/t\end{pmatrix}$, cols
$(1,1)^T$ and $(0,-1/t)^T$):
  - New col $k$: $\binom{a_k + c_k}{1}$.
  - New col $k+1$: $\binom{-c_k/t}{-1/t}$.

The matrix $I_{k+1} - y\,A'_{k+1}$ then has:

Last row entries:
| Case | Cols 1..k-1 | Col $k$ | Col $k+1$ |
|---|---|---|---|
| $\epsilon_{k+1} = +1$ | 0 | $-yt$ | $1 + yt$ |
| $\epsilon_{k+1} = -1$ | 0 | $-y$  | $1 + y/t$ |

Let $\alpha := t, \beta := t$ for $\epsilon_{k+1} = +1$; $\alpha := 1, \beta := 1$
for $\epsilon_{k+1} = -1$. (These are the two scalars giving the shear and scale
in the 2×2 block action on the last two columns.) Note $\alpha \cdot \mu(k+1) = t$
and $\beta \cdot \mu(k+1) = t$ in both cases, and the last-row entries are
$(0, \ldots, 0, -y\beta, 1 + y\beta/\mu(k+1))$... actually let me just keep the
two cases separate; the computation is short either way.

**Expanding $\det(I_{k+1} - y A'_{k+1})$ along the last row.**

Only cols $k$ and $k+1$ contribute. Define:
- $P := \det(I_k - y A'_k) = F_k$ (the "unperturbed" $k \times k$ det).
- $Q_k := \det[\text{cols 1..k-1 of }(I_k - y A'_k),\ c_k]$ (i.e., replace the
  last col of $I_k - y A'_k$ by $c_k$).

Let $M_{k+1,j}$ = minor = determinant of the $k \times k$ matrix obtained by
deleting the last row and column $j$ of $I_{k+1} - y A'_{k+1}$.

$M_{k+1, k+1}$ = top-left $k \times k$ submatrix. Cols 1..k-1 are $e_j^{(k)} - y a_j$
(unchanged from $I_k - y A'_k$). Col $k$ is $(e_k^{(k)} - y a_k) - y\alpha\, c_k$.
By column linearity:
$$M_{k+1, k+1} \;=\; P - y\alpha \cdot Q_k \;=\; F_k - y\alpha\, Q_k.$$

$M_{k+1, k}$ = submatrix with last row and col $k$ deleted. Cols 1..k-1 are
unchanged from $I_k - y A'_k$. Col $k+1$'s top $k$ entries are:
- $\epsilon_{k+1} = +1$: $yt\, c_k$. So $M_{k+1, k} = yt \cdot Q_k$.
- $\epsilon_{k+1} = -1$: $y c_k / t$. So $M_{k+1, k} = (y/t)\, Q_k$.

Cofactor signs: for col $k$, sign $= (-1)^{(k+1)+k} = -1$. For col $k+1$,
sign $= +1$.

**Case $\epsilon_{k+1} = +1$:**
$$F_{k+1} \;=\; (-yt)\cdot(-1)\cdot(yt\, Q_k) + (1+yt)\cdot(F_k - yt\, Q_k)$$
$$= y^2 t^2\, Q_k + (1+yt)\,F_k - yt(1+yt)\,Q_k$$
$$= F_k + yt\, F_k - yt\, Q_k = (1 + yt)\,F_k - yt\, Q_k.$$

**Case $\epsilon_{k+1} = -1$:**
$$F_{k+1} \;=\; (-y)\cdot(-1)\cdot(y/t)\,Q_k + (1 + y/t)(F_k - y\, Q_k)$$
$$= (y^2/t)\,Q_k + (1 + y/t)\,F_k - y(1 + y/t)\,Q_k$$
$$= F_k + (y/t)\,F_k - y\, Q_k = (1 + y/t)\,F_k - y\, Q_k.$$

## Recursion matching (with careful $t$-power bookkeeping)

We now prove the key **Lemma Q**:
$$\boxed{Q_k \;=\; \frac{F_{k-1}}{\mu(k)} \qquad \text{for all } k \ge 1.}$$

**Proof of Lemma Q.** $Q_k$ is the determinant of a $k \times k$ matrix $N_k$
whose cols 1..k-1 are those of $I_k - y A'_k$ and whose last col is $c_k =
(1/\mu(k))\binom{c_{k-1}}{1}$.

Now cols 1..k-1 of $A'_k$ come from the last step of the incremental construction
$A'_k = L^{(k+1)}_{k-1} \cdot \bar\rho_{k+1}(\sigma_k^{\epsilon_k})$, where $\sigma_k$
is the **last** generator of $B_{k+1}$ (2×2 boundary block on rows/cols $(k-1, k)$),
and $L^{(k+1)}_{k-1} = \begin{pmatrix}A'_{k-1} & c_{k-1}\\ 0 & 1\end{pmatrix}$ is
the $k\times k$ lift from the Block Structure Lemma (with parameter $k-1$).
This right-multiplication leaves cols 1..k-2 of $L^{(k+1)}_{k-1}$ unchanged
(they are $\binom{a^{(k-1)}_j}{0}$ for $j \le k-2$) and transforms cols $k-1, k$
of $L^{(k+1)}_{k-1}$ into new cols $k-1, k$ of $A'_k$ via the 2×2 boundary block.

For both $\epsilon_k = \pm 1$, using the appropriate 2×2 block:
- $\epsilon_k = +1$: new col $k-1$ of $A'_k = \binom{a^{(k-1)}_{k-1}}{0} + t\binom{c_{k-1}}{1}
  = \binom{a^{(k-1)}_{k-1} + t\,c_{k-1}}{t}$.
- $\epsilon_k = -1$: new col $k-1$ = $\binom{a^{(k-1)}_{k-1} + c_{k-1}}{1}$.

Unifying with $\kappa := t/\mu(k)$ (so $\kappa = t$ for $\epsilon_k = +1$ and
$\kappa = 1$ for $\epsilon_k = -1$):
$$\text{col } k-1 \text{ of } A'_k \;=\; \binom{a^{(k-1)}_{k-1} + \kappa\, c_{k-1}}{\kappa}.$$

The matrix $N_k$ for the determinant $Q_k$ thus has:
- Cols 1..k-2: $\binom{e^{(k-1)}_j - y\, a^{(k-1)}_j}{0}$.
- Col $k-1$: $e_{k-1}^{(k)} - y\cdot(\text{new col } k-1 \text{ of } A'_k)$
  $= \binom{e^{(k-1)}_{k-1} - y\,a^{(k-1)}_{k-1} - y\kappa\, c_{k-1}}{-y\kappa}$.
- Col $k$: $c_k = (1/\mu(k))\binom{c_{k-1}}{1}$, i.e., top $k-1$ entries
  $c_{k-1}/\mu(k)$, last entry $1/\mu(k)$.

Expand $\det N_k$ along the **last row**, which has entries:
$(0, \ldots, 0, -y\kappa, 1/\mu(k))$.

Contributions:
- From col $k-1$ (entry $-y\kappa$, sign $(-1)^{k + (k-1)} = -1$):
  submatrix obtained by deleting last row and col $k-1$; top-left $(k-1)\times(k-1)$
  has cols 1..k-2 $= e^{(k-1)}_j - y\,a^{(k-1)}_j$ and col $k$'s top $k-1$ entries
  $= c_{k-1}/\mu(k)$. So this minor $= (1/\mu(k)) \cdot Q_{k-1}$.

- From col $k$ (entry $1/\mu(k)$, sign $(-1)^{k+k} = +1$): submatrix is
  top-left $(k-1)\times(k-1)$ of $N_k$: cols 1..k-2 as usual, col $k-1 = (e^{(k-1)}_{k-1} - y\,a^{(k-1)}_{k-1}) - y\kappa\,c_{k-1}$.
  By column linearity:
  $$= \det(I_{k-1} - y A'_{k-1}) - y\kappa \cdot Q_{k-1} = F_{k-1} - y\kappa\, Q_{k-1}.$$

Combining:
$$\det N_k = (-y\kappa)\cdot(-1)\cdot\frac{Q_{k-1}}{\mu(k)} + \frac{1}{\mu(k)}\cdot\left(F_{k-1} - y\kappa\, Q_{k-1}\right)$$
$$= \frac{y\kappa\, Q_{k-1}}{\mu(k)} + \frac{F_{k-1}}{\mu(k)} - \frac{y\kappa\, Q_{k-1}}{\mu(k)} = \frac{F_{k-1}}{\mu(k)}.$$

The $Q_{k-1}$ terms cancel **exactly**, regardless of $\epsilon_k$. ∎

**Assembling the three-term recursion.** From the cofactor expansion and Lemma Q:

Case $\epsilon_{k+1} = +1$ (so $\mu(k+1) = 1$, $t^{\epsilon_{k+1}} = t$):
$$F_{k+1} = (1 + yt)\,F_k - yt \cdot \frac{F_{k-1}}{\mu(k)} = \left(\frac{1}{t} + y\right)\cdot t \cdot F_k - \frac{\mu(k)\cdot 1 \cdot y}{t}\cdot t^{1 + \epsilon_k}\cdot F_{k-1}.$$
(For the second term: $yt/\mu(k) = (y\mu(k)/t)\cdot (t^2/\mu(k)^2)$. Since $\mu(k)^2 \in \{1, t^2\}$,
the identity $yt/\mu(k) = \mu(k)\cdot y \cdot t^{\epsilon_k}$ holds case by case:
for $\epsilon_k = +1$, $\mu(k) = 1$: LHS $= yt$, RHS $= 1\cdot y \cdot t = yt$ ✓;
for $\epsilon_k = -1$, $\mu(k) = t$: LHS $= y$, RHS $= t\cdot y\cdot t^{-1} = y$ ✓.)

Case $\epsilon_{k+1} = -1$ (so $\mu(k+1) = t$, $t^{\epsilon_{k+1}} = 1/t$):
$$F_{k+1} = (1 + y/t)\,F_k - y\cdot\frac{F_{k-1}}{\mu(k)} = \left(\frac{t^2}{t} + y\right)\cdot\frac{1}{t}\cdot F_k - \frac{\mu(k)\cdot t\cdot y}{t}\cdot t^{-1 + \epsilon_k}\cdot F_{k-1}.$$
(Same case-check for the second term: $y/\mu(k) = \mu(k)\cdot y \cdot t^{\epsilon_k - 2}$, which simplifies to $y/t^{?}$... let me verify directly:
for $\epsilon_k = +1$, $\mu(k) = 1$: LHS $= y$, RHS $= 1\cdot y\cdot t^0 = y$ ✓ (with $\mu(k)\mu(k+1)/t = t/t = 1$ and $t^{\epsilon_{k+1}+\epsilon_k} = t^0 = 1$, so the second-term coefficient is $1 \cdot y = y$);
for $\epsilon_k = -1$, $\mu(k) = t$: LHS $= y/t$, RHS requires: $\mu(k)\mu(k+1)/t = t\cdot t/t = t$ times $t^{\epsilon_{k+1}+\epsilon_k} = t^{-2}$, giving $t\cdot t^{-2}\cdot y = y/t$ ✓.)

In both cases we recover the desired recursion:
$$\boxed{F_{k+1} = \left(\frac{\mu(k+1)^2}{t} + y\right) t^{\epsilon_{k+1}}\, F_k \;-\; \frac{\mu(k)\mu(k+1)\,y}{t}\, t^{\epsilon_{k+1} + \epsilon_k}\, F_{k-1}.}$$

Equivalently, writing $\tilde C_k := F_k / t^{e_k}$:
$$\tilde C_{k+1} = \left(\frac{\mu(k+1)^2}{t} + y\right)\tilde C_k - \frac{\mu(k)\mu(k+1)\,y}{t}\,\tilde C_{k-1},$$
which is **exactly** the $C_k$ recursion from problem.md.

## Base case

$F_0 = \det(\text{empty}) = 1 = t^0 \cdot C_0 = t^0 \cdot 1$. ✓

$F_1$: $A'_1 = [-t]$ if $\epsilon_1 = +1$, $[-1/t]$ if $\epsilon_1 = -1$.
- $\epsilon_1 = +1$: $F_1 = 1 - y(-t) = 1 + yt$. And $t^{e_1} C_1 = t^1 \cdot (1/t + y) = 1 + yt$ (with $\mu(1)^2/t = 1/t$). ✓
- $\epsilon_1 = -1$: $F_1 = 1 + y/t$. And $t^{e_1} C_1 = t^{-1} \cdot (t^2/t + y) = t^{-1}(t + y) = 1 + y/t$. ✓

## Inductive step — the explicit computation

Assume $F_{k-1} = t^{e_{k-1}} C_{k-1}$ and $F_k = t^{e_k} C_k$. Substituting into the
recursion:
$$F_{k+1} = \left(\frac{\mu(k+1)^2}{t} + y\right) t^{\epsilon_{k+1}}\cdot t^{e_k} C_k - \frac{\mu(k)\mu(k+1) y}{t}\, t^{\epsilon_{k+1} + \epsilon_k}\cdot t^{e_{k-1}} C_{k-1}.$$

Since $e_{k+1} = e_k + \epsilon_{k+1}$ and $e_{k+1} - e_{k-1} = \epsilon_{k+1} + \epsilon_k$,
pull out $t^{e_{k+1}}$:
$$F_{k+1} = t^{e_{k+1}} \left[\left(\frac{\mu(k+1)^2}{t} + y\right) C_k - \frac{\mu(k)\mu(k+1) y}{t}\, C_{k-1}\right] = t^{e_{k+1}} C_{k+1}$$
by the defining recursion of $C_{k+1}$. ∎

This closes the induction and proves the identity
$F_{p-1} = t^{e(\epsilon)} C_{p-1}(y, t)$, i.e., the target identity
$\det(I_{p-1} - y\,B_\epsilon) = t^{e(\epsilon)} C_{p-1}(y, t)$.

## Numerical verification at $p = 5$

Ran `fixer_work/verify_p5.py` (sympy symbolic):

```
--- p = 5 ---
  eps = (+1,+1,+1,+1)  e(eps) = +4  ratio = t**4       [OK]
  eps = (+1,+1,+1,-1)  e(eps) = +2  ratio = t**2       [OK]
  eps = (+1,+1,-1,+1)  e(eps) = +2  ratio = t**2       [OK]
  eps = (+1,+1,-1,-1)  e(eps) = +0  ratio = 1          [OK]
  eps = (+1,-1,+1,+1)  e(eps) = +2  ratio = t**2       [OK]
  eps = (+1,-1,+1,-1)  e(eps) = +0  ratio = 1          [OK]
  eps = (+1,-1,-1,+1)  e(eps) = +0  ratio = 1          [OK]
  eps = (+1,-1,-1,-1)  e(eps) = -2  ratio = t**(-2)    [OK]
  eps = (-1,+1,+1,+1)  e(eps) = +2  ratio = t**2       [OK]
  eps = (-1,+1,+1,-1)  e(eps) = +0  ratio = 1          [OK]
  eps = (-1,+1,-1,+1)  e(eps) = +0  ratio = 1          [OK]
  eps = (-1,+1,-1,-1)  e(eps) = -2  ratio = t**(-2)    [OK]
  eps = (-1,-1,+1,+1)  e(eps) = +0  ratio = 1          [OK]
  eps = (-1,-1,+1,-1)  e(eps) = -2  ratio = t**(-2)    [OK]
  eps = (-1,-1,-1,+1)  e(eps) = -2  ratio = t**(-2)    [OK]
  eps = (-1,-1,-1,-1)  e(eps) = -4  ratio = t**(-4)    [OK]
  PASS: 16/16
```

All 16 sign-vectors at $p = 5$ pass, i.e., ratio $\det(I_{p-1} - y B_\epsilon)/C_{p-1}(y,t)
= t^{e(\epsilon)}$ exactly (as rational function in $y, t$).

Running the same script on the regression set: $p = 2$ (2/2 OK), $p = 3$ (4/4 OK),
$p = 4$ (8/8 OK).

Additionally, `fixer_work/verify_Ek.py` checks the intrinsic identity
$F_k(y,t) = t^{e_k} C_k(y,t)$ for **every** prefix $\epsilon_{1..k}$ with
$k = 1, 2, 3, 4, 5$: 2 + 4 + 8 + 16 + 32 = **62 cases all pass**.

`fixer_work/check_recursion.py` verifies the three-term recursion
$F_{k+1} = (\mu(k+1)^2/t + y) t^{\epsilon_{k+1}} F_k - \mu(k)\mu(k+1)(y/t) t^{\epsilon_{k+1}+\epsilon_k} F_{k-1}$
for selected 5-prefix chains (6 chains × 4 recursion checks = 24 recursion checks,
all HOLD).

`fixer_work/find_Qk.py` verifies Lemma Q $Q_k = F_{k-1}/\mu(k)$ on 11 test cases
including $k$ up to 5.

## What closed, what remains

**SP-3 is CLOSED.** The induction is written out in full with an explicit
three-term recursion for $F_k$ that exactly matches the $C_k$ recursion after
extracting the $t^{e_k}$ factor. The only non-trivial algebraic step (Lemma Q)
is proven by a two-line cofactor expansion in which the $Q_{k-1}$-terms cancel
**identically** across both sign-values of $\epsilon_k$, giving the simple
scalar identity $Q_k = F_{k-1}/\mu(k)$. The recursion is then combined with base
cases $F_0 = 1$ and the explicit $F_1$ (two cases) to establish $F_k = t^{e_k} C_k$
by induction. Taking $k = p-1$ closes the target identity, since
$A'_{p-1} = B_\epsilon$ by definition.

**Side remarks on the Explorer's original framing.**
1. The Explorer's verbal hypothesis — "right-multiplication by $\bar\rho(\sigma_k^{\pm 1})$
   modifies only the last two columns of the running product" — is **true** only in the
   smaller braid group $B_{k+1}$ (where $\sigma_k$ is the last generator) or in the lift
   $B_{k+2}$ (where $\sigma_{k+1}$ is the last generator); it is **false** in the full
   $B_p$ for intermediate $k$ (where $\sigma_k$ is a middle generator modifying **three**
   columns). The correct setting is the intrinsic $B_{k+1}$ formulation used above.
2. The Explorer's proposed "$D_k$ = leading principal $k \times k$ minor of $B_\epsilon$"
   induction variable is wrong: $D_k \ne t^{e_k} C_k$ for $k < p-1$ (explicitly verified
   at $p=4$, $\epsilon = (+1,+1,+1)$: $D_1 = D_2 = 1 \ne t\cdot C_1, t^2 C_2$). The correct
   induction variable is $F_k := \det(I_k - y A'_k)$ with $A'_k \in B_{k+1}$.

**Other SP items** (SP-2 and SP-4) are unchanged by this round's work. SP-2
(Burau-denominator cancellation $\det(I_{p-1} - \bar\rho(\beta)) \doteq \Phi_p(t)$)
and SP-4 (breadth computation for Theorem 4.2) remain as flagged by Auditor
Round 1; they are independent of SP-3 and not addressed here.

## Citation ledger

- **[L1]** Entry-level matrix identity: the product of matrices each having last
  row $e_n^T$ has last row $e_n^T$. One-line calculation from the definition of
  matrix multiplication. (Used in the Block Structure Lemma, part (i).)
- **[L1]** Direct inspection of 3×3 and 2×2 Birman–Weinberg Burau generator
  blocks from convention §1.3 to verify that (a) $\bar\rho_{k+2}(\sigma_j^{\pm 1})$
  has last row $e_{k+1}^T$ for $1 \le j \le k$, and (b) the top-left 2×2 of
  the middle 3×3 block $U_k^{(\text{mid})}$ matches the boundary 2×2 block
  $U_k^{(\text{last})}$. Both are 30-second entry-level checks. (Used in Block
  Structure Lemma, parts (i) and (ii); inherits from best_proof.md's Step 4 L2
  citation for the generator matrices themselves.)
- **[L1]** Cofactor (Laplace) expansion along a row, with sign $(-1)^{i+j}$.
  Standard undergraduate linear-algebra tool. (Used in both the main recursion
  derivation and the Lemma Q derivation.)
- **[L1]** Column-linearity of the determinant. Standard undergraduate.
- **No new L2 or L3 citations introduced** by this Fixer round. All new content
  is at citation depth L1 (elementary) or marked as **Independent** (the
  Block Structure Lemma's full proof, the $c_k$ recursion, the cofactor
  expansion for $F_{k+1}$, Lemma Q, and the induction close itself).

**Independent-step count for this Fixer round:**
1. Block Structure Lemma: $L_k = \begin{pmatrix}A'_k & c_k \\ 0 & 1\end{pmatrix}$.
2. Recursion for $c_k$: $c_k = (1/\mu(k))\binom{c_{k-1}}{1}$.
3. Cofactor expansion for $F_{k+1}$ (both signs of $\epsilon_{k+1}$).
4. Lemma Q: $Q_k = F_{k-1}/\mu(k)$ (proven by cofactor expansion in which the
   $Q_{k-1}$ terms cancel).
5. Matching to the $C_k$ recursion via case-by-case algebraic identity
   $yt/\mu(k) = \mu(k)\, y\, t^{\epsilon_k}$ and analogous for $\epsilon_{k+1} = -1$.
6. Inductive close at the end.

Six Independent steps, zero L3 citations. Citation-depth profile for this round:
| Tag | Count | Examples |
|---|---|---|
| L1 | 4 | Last-row preservation, entry-level block inspection, Laplace expansion, column-linearity |
| L2 | 0 | (none new; best_proof.md's L2 citations remain in force) |
| L3 | 0 | — |
| Independent | 6 | Listed above |

**No STRUCTURAL-CITATION-WARNING fired**, consistent with best_proof.md and
Auditor Round 1's verdict for the overall proof.
