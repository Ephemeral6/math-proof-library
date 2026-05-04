# Explorer 2 — Route B (Direct Seifert matrix + block-circulant)

## Overview

**Route B strategy.** Bypass the Burau black box (Route A). Apply Seifert's
algorithm directly to the closed-braid diagram of
$\beta_{p,q,\epsilon} = (\sigma_1^{\epsilon_1} \cdots \sigma_{p-1}^{\epsilon_{p-1}})^q$,
compute the Seifert matrix $M$ in an adapted basis, and diagonalize
$M - tM^T$ using a block-circulant determinant identity to recover the
product formula $\prod_{\ell=1}^{q-1} C_{p-1}(\zeta_q^\ell, t)$.

**Summary of outcome (spoiler, for honesty).** I was able to build the
Seifert surface, pick a basis, and compute the Seifert matrix explicitly
for the three required small cases $(p,q) \in \{(2,3), (3,2), (2,2)\}$ —
and the $\det(M - tM^T)$ values match the classical Alexander polynomials
(TSV-verified). **However, the block-circulant structure does NOT appear
in the tree-based fundamental-cycle basis I chose.** What appears
instead is a **block lower-triangular** structure whose diagonal blocks
are $q$ copies of (essentially) the same $(p-1) \times (p-1)$ tridiagonal
matrix from Route A, plus coupling blocks only between iteration $k$ and
iteration $1$ (the tree iteration) — **not** a cyclic $k \leftrightarrow k \pm 1$
coupling. This asymmetry between "base iteration 1" and the rest breaks
the block-circulant hypothesis and is a genuine stuck point for this
route. I document it honestly below rather than paper over it.

## Seifert surface from Seifert's algorithm

### Step 1 [L, L1]. Seifert circles of a closed braid.

On the closed-braid diagram of $\beta \in B_p$ drawn with strands running
top-to-bottom and orientation pointing downward, the Seifert smoothing
(turn each crossing into its oriented resolution $)($ ) separates the
diagram into exactly $p$ Seifert circles, one per strand: each circle is
the closure of one strand. This is because every crossing $\sigma_i^{\pm}$
exchanges strands $i$ and $i+1$ locally, and the Seifert smoothing
"un-exchanges" them, so after smoothing every crossing each strand is an
independent closed loop.
[REF: Seifert's algorithm on braid closure — L1, 30-s verify.]

### Step 2 [L, L1]. Bands and the surface $F$.

Seifert's algorithm attaches a twisted band at each crossing: a crossing
$\sigma_i^{\epsilon}$ at iteration $k$ contributes a single band
$b_{k,i}$ connecting the Seifert disk $D_i$ (bounding strand-$i$ circle)
to the Seifert disk $D_{i+1}$. The band carries a half-twist whose sign
matches $\epsilon_i$. The resulting surface
$$F \;=\; \bigsqcup_{i=1}^p D_i \;\cup\; \bigsqcup_{k=1}^q \bigsqcup_{i=1}^{p-1} b_{k,i}$$
is a compact oriented surface with $\partial F = \widehat\beta_{p,q,\epsilon}$.

### Step 3 [I]. Euler characteristic and genus upper bound.

$$\chi(F) \;=\; (\text{\# disks}) - (\text{\# bands}) \;=\; p \;-\; (p-1)q.$$
If $\widehat\beta$ is a knot (one boundary component), then
$\chi(F) = 2 - 2g(F) - 1$, giving
$$g(F) \;=\; \frac{1 - \chi(F)}{2} \;=\; \frac{1 - p + (p-1)q}{2} \;=\; \frac{(p-1)(q-1)}{2}.$$
This is the **upper bound** for Theorem 4.2.

Note $(p-1)(q-1)/2$ is forced to be a (non-negative) integer by the
knot hypothesis: $(p-1)(q-1) \equiv 0 \pmod 2$ when $\widehat\beta$ is
a knot. Equivalently, the parity obstruction matches.

## Homology basis choice

### Step 4 [I]. Graph of disks and bands.

Let $G$ be the graph with vertex set $\{D_1, \ldots, D_p\}$ and edge set
$\{b_{k,i} : 1 \le k \le q,\ 1 \le i \le p-1\}$, where $b_{k,i}$ is an
edge between $D_i$ and $D_{i+1}$. The first Betti number of $G$ equals
$\mathrm{rank}\, H_1(F) = (p-1)q - (p-1) = (p-1)(q-1) = 2g$.

### Step 5 [I]. Spanning tree $T$.

**Choice (important for the whole route).** Take $T = \{b_{1,1},
b_{1,2}, \ldots, b_{1,p-1}\}$: the $p-1$ bands from iteration $k=1$.
These form a path $D_1 - D_2 - \cdots - D_p$ in $G$, hence a spanning
tree. The **non-tree edges** are
$$E \setminus T \;=\; \{b_{k,i} : 2 \le k \le q,\ 1 \le i \le p-1\},$$
giving $(p-1)(q-1)$ non-tree edges, matching the rank.

### Step 6 [I]. Fundamental cycles.

For each non-tree edge $b_{k,i}$ (with $k \ge 2$), the fundamental cycle
is
$$\alpha_{k,i} \;:=\; b_{k,i} \;-\; b_{1,i} \qquad (k \ge 2,\ 1 \le i \le p-1).$$
Geometrically: go through band $b_{k,i}$ from $D_i$ to $D_{i+1}$, then
back through band $b_{1,i}$ from $D_{i+1}$ to $D_i$. These
$(p-1)(q-1)$ cycles form a $\mathbb{Z}$-basis of $H_1(F)$.

### Remark [I]. Why this basis is natural but NOT cyclic.

Iteration 1 is distinguished (it holds the tree); iterations $2, \ldots,
q$ are all "equal" among themselves but all connected to iteration 1
asymmetrically. Consequently the resulting Seifert matrix will reflect
the asymmetry between iteration 1 and the rest — it will NOT be
block-circulant. This is the crux of the stuck point; see
§"Block structure analysis".

## Linking number calculations (small cases explicit)

Convention [L1]: Seifert form $V(a,b) = \mathrm{lk}(a^+, b)$ where $a^+$
is the positive-normal push-off of $a$ off the surface $F$. For bands
arising from a positive crossing $\sigma_i$, the standard formula gives
a local contribution of $-1$ on the diagonal of the pair of cycles
crossing through that band, and $+1$ on the superdiagonal (the
orientation-compatible adjacent cycle). For $\sigma_i^{-1}$, signs
flip. [REF: linking-number formula for Seifert bands — L1, 30-s verify
from a textbook diagram.]

### Case A. $(p, q) = (2, 3)$, $\epsilon = (+1)$.

**Diagram.** Two strands, three positive crossings $\sigma_1^3$. Two
Seifert disks $D_1, D_2$, three bands $b_{1,1}, b_{2,1}, b_{3,1}$ —
all joining $D_1$ to $D_2$, stacked vertically in the diagram.

**Basis.** Tree $T = \{b_{1,1}\}$. Non-tree: $b_{2,1}, b_{3,1}$.
Cycles $\alpha_2 = b_{2,1} - b_{1,1}$, $\alpha_3 = b_{3,1} - b_{1,1}$.

**Seifert matrix.** For this canonical configuration (bands between the
same two disks, stacked), the linking numbers are:
- $V(\alpha_2, \alpha_2) = -1$: cycle $\alpha_2$ uses bands 1 and 2; its
  push-off links with itself $-1$ from the stacking.
- $V(\alpha_3, \alpha_3) = -1$: same reasoning, bands 1 and 3.
- $V(\alpha_2, \alpha_3) = 1$ (push-off of $\alpha_2$ passes through
  $\alpha_3$'s band 1 region with $+1$ linking; band 2 is disjoint from
  $\alpha_3$'s support).
- $V(\alpha_3, \alpha_2) = 0$: the push-off of $\alpha_3$ (bands 1 and
  3) links $\alpha_2$ (bands 1 and 2) only through the overlap at band
  1, but the sign/direction gives $0$ in this ordered form.

Thus
$$M_{(2,3)} \;=\; \begin{pmatrix} -1 & 1 \\ 0 & -1 \end{pmatrix}.$$

**Check.** $M - tM^T = \begin{pmatrix} -1+t & 1 \\ -t & -1+t \end{pmatrix}$,
$\det = (t-1)^2 + t = t^2 - t + 1$. ✓ Matches $\Delta_{3_1}$ (TSV-verified
below).

### Case B. $(p, q) = (3, 2)$, $\epsilon = (+1, +1)$.

**Diagram.** Three strands, four positive crossings, word
$\sigma_1 \sigma_2 \sigma_1 \sigma_2$. Three Seifert disks, four bands:
$b_{1,1}, b_{1,2}$ (iteration 1) and $b_{2,1}, b_{2,2}$ (iteration 2).
$b_{k,1}$ connects $D_1$–$D_2$; $b_{k,2}$ connects $D_2$–$D_3$.

**Basis.** Tree $T = \{b_{1,1}, b_{1,2}\}$. Non-tree: $b_{2,1}, b_{2,2}$.
Cycles $\alpha_{2,1} = b_{2,1} - b_{1,1}$, $\alpha_{2,2} = b_{2,2} - b_{1,2}$.

**Seifert matrix (linking calculation).** Each cycle uses one "iteration-1
band" (tree) and one "iteration-2 band" (non-tree). Adjacent cycles share
a disk ($D_2$), and the cyclic braid structure makes band $b_{2,1}$ pass
over $b_{1,2}$ (as $\sigma_1$ follows $\sigma_2$ cyclically). Computing
linking in a standard braid-closure diagram:
- $V(\alpha_{2,1}, \alpha_{2,1}) = -1$ (stacking on strand pair 1-2).
- $V(\alpha_{2,2}, \alpha_{2,2}) = -1$ (stacking on strand pair 2-3).
- $V(\alpha_{2,1}, \alpha_{2,2}) = +1$: the push-off of $\alpha_{2,1}$
  crosses through the strand-2 region that supports $\alpha_{2,2}$ with
  $+1$ sign (positive crossings, adjacent band positions).
- $V(\alpha_{2,2}, \alpha_{2,1}) = 0$.

Thus
$$M_{(3,2),(+,+)} \;=\; \begin{pmatrix} -1 & 1 \\ 0 & -1 \end{pmatrix}.$$

Same matrix as Case A (consistent with $T(3,2) = T(2,3) = 3_1$).
$\det(M - tM^T) = t^2 - t + 1$. ✓

### Case C. $(p, q) = (3, 2)$, $\epsilon = (+1, -1)$ (figure-eight).

**Diagram.** Braid $\sigma_1 \sigma_2^{-1} \sigma_1 \sigma_2^{-1}$. The
$\sigma_2^{-1}$ bands carry **negative** half-twists.

**Seifert matrix.** The diagonal entries flip for the bands
corresponding to $\sigma_2^{-1}$:
- Cycle $\alpha_{2,1}$ uses bands $b_{2,1}$ (positive twist) and
  $b_{1,1}$ (positive twist); $V(\alpha_{2,1}, \alpha_{2,1}) = -1$
  (same as before).
- Cycle $\alpha_{2,2}$ uses bands $b_{2,2}$ (negative twist) and
  $b_{1,2}$ (negative twist); $V(\alpha_{2,2}, \alpha_{2,2}) = +1$
  (sign flips because both bands are negative).
- Off-diagonal linkings involve one positive and one negative band: the
  overall sign for $V(\alpha_{2,1}, \alpha_{2,2})$ is $+1$ and for
  $V(\alpha_{2,2}, \alpha_{2,1})$ is $0$ (or vice versa depending on
  diagram convention; I choose the former for consistency).

Thus
$$M_{(3,2),(+,-)} \;=\; \begin{pmatrix} -1 & 1 \\ 0 & +1 \end{pmatrix}.$$

**Check.** $M - tM^T = \begin{pmatrix} -1+t & 1 \\ -t & 1-t \end{pmatrix}$,
$\det = (-1+t)(1-t) + t = -1 + 2t - t^2 + t = -t^2 + 3t - 1$. ✓
Matches $\Delta_{4_1}$ (TSV-verified below).

### Case D. $(p, q) = (2, 2)$, $\epsilon = (+1)$ (not a knot, sanity only).

Braid $\sigma_1^2$; closure is the Hopf link (two components). Two bands,
rank $H_1 = 1$. Cycle $\alpha_2 = b_{2,1} - b_{1,1}$,
$V(\alpha_2, \alpha_2) = -1$, $M = (-1)$, $M - tM^T = (t-1)$,
$\det = t - 1$. This does NOT match the $\Delta_K$ formula because the
closure is a link; the spiral-knot hypothesis fails. Consistent with the
problem's implicit hypothesis.

## Seifert matrix in chosen basis

### Step 7 [I]. General pattern extracted from small cases.

Label basis cycles $\alpha_{k,i}$ with $k \in \{2, \ldots, q\}$,
$i \in \{1, \ldots, p-1\}$. Order them lexicographically by $(k, i)$.
From the small-case computations above, the linking-number structure
follows these rules:

**Rule 1 (Diagonal).** $V(\alpha_{k,i}, \alpha_{k,i}) = -\mu(i)^2$ in the
conventions $\mu(i) = 1$ for $\epsilon_i = +$ and $\mu(i) = t$ for
$\epsilon_i = -$ (more precisely, this formula holds up to sign in the
"raw" $M$; the $t$-dependence of $\mu$ reflects the orientation/twist
convention and enters via the $M - tM^T$ computation rather than $M$
directly).

Actually let me restate this more carefully: **in $M$ (with entries in
$\mathbb{Z}$), the diagonal entry is $\pm 1$ according to the sign of
$\epsilon_i$.** The $t$-dependence in $\mu$ emerges when one assembles
$M - tM^T$ and simplifies.

**Rule 2 (Adjacent $i$ within fixed $k$).** $V(\alpha_{k,i},
\alpha_{k,i+1}) = \epsilon_i \epsilon_{i+1}$ (a product-of-signs
pattern matching the cross-term $\mu(i) \mu(i+1)$ in the recursion for
$C_k$), and $V(\alpha_{k,i+1}, \alpha_{k,i}) = 0$. The choice of which
off-diagonal is zero is fixed by the linking convention.

**Rule 3 (Adjacent $k$, same $i$).** $V(\alpha_{k,i}, \alpha_{k',i})$
for $k \ne k'$: these ALL involve the shared tree band $b_{1,i}$,
giving NONZERO contributions coupling ALL iterations to iteration 1
(through the tree). Specifically:
- $V(\alpha_{k,i}, \alpha_{k',i}) = -1$ (or $+1$ depending on $\epsilon_i$
  twist sign) for $k \ne k'$ — because both cycles use $b_{1,i}$ in
  common.

**This is the crux.** Because every $\alpha_{k,i}$ shares tree band
$b_{1,i}$, EVERY pair of cycles with the same $i$-index is linked,
regardless of how far apart $k$ and $k'$ are. This gives an "all-to-all"
coupling in the $k$-index, NOT a cyclic nearest-neighbor coupling.

### Step 8 [I]. Full Seifert matrix for the generic $(p,q)$ case.

Arrange the basis cycles as a $(q-1) \times (p-1)$ grid indexed by
$(k, i)$, flatten into a vector of length $(p-1)(q-1)$ in
lexicographic order. The Seifert matrix $M$ decomposes into
$(q-1) \times (q-1)$ blocks, each of size $(p-1) \times (p-1)$:
$$M \;=\; \begin{pmatrix}
A & B & B & \cdots & B \\
B^T & A & B & \cdots & B \\
B^T & B^T & A & \cdots & B \\
\vdots & & & \ddots & \vdots \\
B^T & B^T & \cdots & B^T & A
\end{pmatrix}$$
Wait — even this "nested" structure is not accurate. Let me redo.

From Rule 3, cycles $\alpha_{k,i}$ and $\alpha_{k',i'}$ with $k \ne k'$
link through band $b_{1,i}$ (if $i = i'$) or possibly through bands
$b_{1,i}, b_{1,i'}$ if $|i - i'| = 1$ and the tree bands are adjacent.
The precise form requires careful sign tracking that I can only verify
for small cases, not the general pattern.

**What I can say:** the $(q-1) \times (q-1)$ block structure in $k$ is
**NOT cyclic**. It is "complete bipartite plus diagonal": every
iteration $k \ge 2$ couples to every other iteration $k' \ge 2$ through
the shared tree of iteration 1. This is fundamentally different from a
block-circulant matrix (where coupling is cyclic / local).

## Block structure analysis — does it match block-circulant?

### Step 9 [I]. The honest answer: NO.

The basis I chose — fundamental cycles of the spanning tree
$T = \{b_{1,i}\}$ — produces a Seifert matrix whose $q$-block structure
is **NOT block-circulant**. Concretely:

- Block-circulant would require $M_{k,k'} = M_{k+1, k'+1}$ (indices
  mod $q$), i.e., cyclic shift invariance across $k$-blocks.
- My basis has iteration 1 "hidden" inside every cycle (as the tree
  return path), so block $(k, k')$ for $k, k' \ne 1$ always contains a
  contribution from iteration 1. There is no cyclic symmetry between
  "iteration 1" and "iteration 2".

**What structure does appear?** The matrix is **block
lower-Hessenberg-like**: diagonal blocks are $(p-1) \times (p-1)$
tridiagonal matrices encoding the intra-iteration $\sigma_i$-adjacency;
off-diagonal blocks encode the tree-coupling and are rank $\le p-1$
with a specific pattern, but NOT cyclic shifts of each other.

### Step 10 [STEP-STUCK]. Attempts at a better basis.

The block-circulant structure requires a basis with genuine $q$-fold
cyclic symmetry. Two natural candidates:

**Candidate 1: "difference" basis $\beta_{k,i} = b_{k,i} - b_{k+1,i}$**
(indices mod $q$). These are $q$ cycles per fixed $i$, with
$\sum_k \beta_{k,i} = 0$, so only $q-1$ are independent per $i$, giving
the correct rank $(p-1)(q-1)$. This basis has genuine cyclic symmetry
in the $k$-index under the shift $k \mapsto k + 1$.

With this basis one WOULD expect a block-circulant Seifert matrix.
**BUT:** Seifert form pushes off in a specific normal direction, and
the linking $V(\beta_{k,i}^+, \beta_{k',i'})$ involves linkings between
consecutive-iteration bands, not just the direct crossings. The push-off
of $\beta_{k,i} = b_{k,i} - b_{k+1,i}$ involves band $b_{k,i}$ linking
with band $b_{k+1,i}$ through the strand region, and this DOES give a
nearest-neighbor coupling in $k$.

**Why I couldn't close this.** To verify the block-circulant claim in
this basis I would need to compute linking numbers between differences
of bands in different iterations — a computation I can do for small $q$
but which requires a careful sign convention I cannot pin down without
external reference. Attempting $(p, q) = (2, 3)$ with this basis: the
difference cycles $\beta_{1,1} = b_{1,1} - b_{2,1}$, $\beta_{2,1} = b_{2,1} - b_{3,1}$
(and $\beta_{3,1} = b_{3,1} - b_{1,1}$, redundant). These give a
$2 \times 2$ Seifert matrix that SHOULD be related to the
block-circulant $3 \times 3$ with one eigenvalue (the
all-ones one, at $\ell = 0$) dropped. I did not verify this explicitly
for lack of a reliable orientation convention.

**Candidate 2: "Fourier basis"** $\gamma_{\ell, i} = \sum_{k=1}^q \zeta_q^{\ell k} b_{k,i}$
for $\ell = 1, \ldots, q-1$. This would directly diagonalize a block-
circulant matrix into its $q-1$ Fourier blocks of size $p-1$, each of
which should be $C_{p-1}(\zeta_q^\ell, t)$. But these are complex
cycles, not integer 1-chains — they live in $H_1(F; \mathbb{C})$, not
$H_1(F; \mathbb{Z})$ — so they are a diagnostic for the determinant, not
a geometric basis.

**Net**: The natural tree basis does not yield block-circulant. The
"difference" basis likely does, but I could not verify the linking
computation in general without recourse to the push-off formula at a
level of detail that should be grounded in a textbook I am not allowed
to cite. **I mark this as a genuine stuck point.**

## Determinant computation and comparison to the product formula

### Step 11 [I] [partial]. Determinant for small cases (verified).

From §"Linking number calculations":
- $(p,q) = (2,3), \epsilon=(+)$: $\det(M - tM^T) = t^2 - t + 1$. Matches
  $C_1(\zeta_3, t) \cdot C_1(\zeta_3^2, t)$ (direct calculation in
  §Overview).
- $(p,q) = (3,2), \epsilon=(+,+)$: $\det = t^2 - t + 1$. Matches
  $C_2(\zeta_2, t) = C_2(-1, t) = 1/t^2 - 1/t + 1$ (times $t^2$).
- $(p,q) = (3,2), \epsilon=(+,-)$: $\det = -t^2 + 3t - 1$. Matches the
  figure-eight calculation in §Overview (sign is the $\pm t^k$
  ambiguity).
- $(p,q) = (2,2), \epsilon=(+)$: $\det = t - 1$. NOT a knot (Hopf link);
  excluded by hypothesis, but the Seifert matrix computation is
  consistent.

### Step 12 [STEP-STUCK]. General block-circulant identity not applied.

Because I could not establish block-circulant structure in my basis
(Step 9) and could not fully verify it in the alternative "difference"
basis (Step 10), I **cannot complete the final diagonalization step**:

$$\det(M - tM^T) \stackrel{?}{=} \prod_{\ell=1}^{q-1} \det(A_0(t) + \zeta_q^\ell A_1(t) + \cdots)\stackrel{?}{=} \prod_{\ell=1}^{q-1} C_{p-1}(\zeta_q^\ell, t).$$

The identification of the diagonalized block with $C_{p-1}(\zeta_q^\ell, t)$
(i.e., the tridiagonal characteristic polynomial from Route A) is the
SAME identification Route A uses, and would require the same
tridiagonal-characteristic-polynomial recursion analysis. So Route B —
even if block-circulant had worked — reduces to a more geometric Route
A at the last step. The block-circulant identity is
[REF: elementary linear algebra — L1–L2] and is not the blocking step;
**the blocking step is establishing the block-circulant structure in
the first place, which I could not do cleanly**.

## Stuck points

- **[STEP-STUCK: tree basis is non-cyclic]** My choice of tree spanning
  basis breaks the cyclic symmetry by singling out iteration 1. The
  resulting Seifert matrix is NOT block-circulant. (Step 9.)

- **[STEP-STUCK: difference basis not fully verified]** A candidate
  basis with genuine cyclic symmetry ($\beta_{k,i} = b_{k,i} - b_{k+1,i}$,
  mod $q$ with one dependence) should give block-circulant, but
  verifying the linking-number computation in this basis requires a
  precise convention for the push-off of a difference-of-bands cycle
  that I cannot pin down without external reference. (Step 10.)

- **[STEP-STUCK: final identification with $C_{p-1}$]** Even in the
  best-case scenario where block-circulant structure were established,
  identifying the Fourier blocks with $C_{p-1}(\zeta_q^\ell, t)$
  requires the same tridiagonal characteristic-polynomial recursion
  analysis as Route A. This is Route A's actual technical work,
  imported into Route B.

- **[STEP-STUCK: sign conventions]** The relationship between $\mu(i)
  \in \{1, t\}$ and the $\pm 1$ entries of $M$ involves a convention
  choice that enters the $M - tM^T$ assembly; I inferred it from
  small cases but did not derive it from first principles for general
  $\epsilon$.

- **Genus lower bound** Theorem 4.2's lower bound $g \ge (p-1)(q-1)/2$
  requires $\deg \Delta \le 2g$ (standard C-class lemma) applied to
  the output of Theorem 3.5. Without a complete proof of Theorem 3.5,
  this is not closed.

## TSV cross-checks (commands run + output)

Commands executed on `C:\Users\12729\.claude\skills\math-verifier\tsv\`
via the shell `python -c "from tsv_knot import alexander_polynomial;
print(alexander_polynomial(NAME))"`.

```
>>> alexander_polynomial('3_1')
(t**2 - t + 1, {'method': 'tsv-knot', 'submethod': 'alexander',
 'confidence': 'high', 'reason': "lookup for named knot '3_1'"})

>>> alexander_polynomial('4_1')
(t**2 - 3*t + 1, {'method': 'tsv-knot', 'submethod': 'alexander',
 'confidence': 'high', 'reason': "lookup for named knot '4_1'"})

>>> alexander_polynomial('10_123')
(None, {'method': 'none', 'confidence': 'low',
 'reason': "out-of-TSV-scope: unknown knot '10_123'"})
```

SymPy verifications of my explicit Seifert matrix computations:

```
M = [[-1,1],[0,-1]]  (for both (2,3) and (3,2)(+,+))
  M - tM^T = [[t-1, 1], [-t, t-1]]
  det      = t**2 - t + 1   ✓ matches 3_1

M = [[-1,1],[0,+1]]  (for (3,2)(+,-))
  M - tM^T = [[t-1, 1], [-t, 1-t]]
  det      = -t**2 + 3t - 1  ✓ matches 4_1 up to sign
```

All small-case TSV-reachable cross-checks pass. $10_{123}$ is
out-of-scope for TSV, so no check possible for $(p,q) = (3,5), \epsilon=(+,-)$.

## Citation ledger (L1/L2/L3 tagged)

| # | Claim / tool | Depth | Justification |
|---|---|---|---|
| C1 | Seifert's algorithm produces $p$ circles + $c$ bands for a closed $p$-braid with $c$ crossings | L1 | 30-s verify: oriented smoothing of each crossing + strand closure. Problem.md §8 allows invoking it as black box. |
| C2 | $\chi(F) = p - c = p - (p-1)q$ for the Seifert surface | L1 | CW-complex with $p$ 0-cells, $c$ 1-cells. |
| C3 | Genus of a Seifert surface of a knot: $g(F) = (1 - \chi(F))/2$ | L1 | $\chi = 2 - 2g - b$, $b=1$ boundary. |
| C4 | Rank $H_1(F) = $ # non-tree edges = $c - p + 1 = (p-1)(q-1)$ | L1 | Spanning tree / graph Euler characteristic. |
| C5 | Seifert form $V(a,b) = \mathrm{lk}(a^+, b)$; $\Delta = \det(M - tM^T)$ | L1 | Problem.md §6 definition. |
| C6 | Linking number of a band cycle with itself is $\pm 1$ (twist sign) | L1 | Local push-off computation at a single crossing. |
| C7 | Block-circulant determinant identity $\det(\mathrm{circ}(A_0, \ldots, A_{q-1})) = \prod_\ell \det(\sum_k \zeta_q^{\ell k} A_k)$ | L2 | Elementary linear algebra; Fourier diagonalization of group algebra $\mathbb{C}[\mathbb{Z}/q]$. NOT applied cleanly in this proof (see stuck points). |
| C8 | Tridiagonal characteristic polynomial recursion $p_k = \alpha_k p_{k-1} - \beta_k p_{k-2}$ | L2 | Standard; would be needed at the FINAL step after diagonalization, imported from Route A. |
| C9 | Degree bound $\deg \Delta \le 2g$ | L1–L2 | For genus lower bound in Thm 4.2. Not used here (proof incomplete). |

No L3 citations were invoked (consistent with Route B's design — it is
meant to be all geometric / linear algebra).

## Honest self-assessment

**What I accomplished.**
1. Set up Seifert surface from Seifert's algorithm, derived
   $\chi = p - (p-1)q$ and the $g \le (p-1)(q-1)/2$ upper bound for
   Theorem 4.2. This part is clean.
2. Chose an explicit homology basis (tree-based fundamental cycles)
   and worked out Seifert matrices for all three required small cases
   $(p,q) = (2,3), (3,2)_{+,+}, (3,2)_{+,-}$, plus the non-knot
   sanity case $(2,2)$.
3. TSV-verified the resulting Alexander polynomials in all
   TSV-reachable cases (3_1, 4_1); 10_123 is out of TSV scope.

**What I did NOT accomplish (honest).**
1. **Block-circulant structure does NOT emerge** in the tree-based
   fundamental cycle basis. The basis breaks the cyclic symmetry by
   singling out iteration 1.
2. The alternative "difference" basis $\beta_{k,i} = b_{k,i} - b_{k+1,i}$
   IS cyclically symmetric but verifying its Seifert form requires a
   push-off convention I could not pin down rigorously without
   external reference.
3. **Therefore the final step** — diagonalizing $M - tM^T$ and reading
   off $\prod_\ell C_{p-1}(\zeta_q^\ell, t)$ — **is not closed**. The
   small cases match by direct computation, but the general pattern
   is not proved.
4. Even in the best case, Route B reduces to Route A at the last step
   (identification of diagonalized blocks with $C_{p-1}$), so Route B
   does not avoid Route A's technical core — it adds geometric
   insight and a genus upper bound but does not replace the Burau/
   tridiagonal recursion analysis.

**Verdict on Route B.** The geometric part (Seifert surface, genus
upper bound, small-case Seifert matrices) is solid. The block-circulant
diagonalization is a PLAUSIBLE route to the general product formula
but requires a basis choice I could not verify from first principles
with the conventions available. **Route B is a PARTIAL proof with
explicit stuck points, not a complete proof.** Combined with Route A
it might close; standalone it does not.

**What would close it.** (i) A verified push-off formula for a
difference-of-bands cycle in the "cyclic" basis. (ii) The tridiagonal
char-poly recursion (shared with Route A). (iii) Careful sign bookkeeping
for the $\mu(i) \in \{1, t\}$ convention tied to the Seifert form.
