# Spiral-Knots Stress-Test — Evidence Extraction for External Review

**Purpose.** Archaeological extraction of what the pipeline produced on Theorems 3.5 and 4.2 of Blackwell–Das–Mayer–Moyar–Quraishi–Stees (arXiv:2506.17889). No re-evaluation. No re-scoring. The reviewer decides Category A/B/C/D.

Working directory referenced throughout: `workspace/active/ldt_spiral_knots_stress_test/`.

---

## Section 1 — Problem.md contents verbatim

```markdown
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
```

### Structural terms NOT appearing in problem.md

- "cake surface" / "cake homology" / "cake basis": **NOT PRESENT**
- "block tri-diagonal" / "tri-diagonal" / "block diagonal": **NOT PRESENT**
- "Molinari": **NOT PRESENT**
- "roots of unity": **NOT PRESENT** as a phrase. "cyclotomic": **NOT PRESENT**.
  "$e^{2\pi i \ell / q}$" specifically: **PRESENT — inside the Theorem 3.5 statement**: `$$\Delta_{S(p, q, \epsilon)}(t) \;=\; \prod_{\ell=1}^{q-1} C_{p-1}\!\left(e^{2\pi i \ell / q}, t\right),$$` (line 67-68 of problem.md).
- "characteristic polynomial of $A$" (or equivalent): **NOT PRESENT**
- "Jordan normal form": **NOT PRESENT**
- "Burau": **NOT PRESENT**
- References to arXiv:2506.17889 or "Blackwell"/"Das"/"Mayer"/"Moyar"/"Quraishi"/"Stees": **NOT PRESENT**
- Phrase resembling "$C_k(x, t) = (\mu(k)^2 / t + x) C_{k-1} - ...$" (the target recursion): **PRESENT — lines 55-58 of problem.md**:
  ```
  Define polynomials $C_k(x, t) \in \mathbb{Z}[x, t, t^{-1}]$ by the recursion
  $$C_k(x, t) \;=\; \left(\frac{\mu(k)^2}{t} + x\right) C_{k-1}(x, t)
  \;-\; \frac{\mu(k-1)\, \mu(k)\, x}{t}\, C_{k-2}(x, t),$$
  with $C_0 = 1$ and $C_1(x, t) = \mu(1)^2/t + x$.
  ```
- Phrase resembling "$\Delta = \prod_{\ell=1}^{q-1} C_{p-1}(e^{2\pi\ell i/q}, t)$" (the target formula): **PRESENT — lines 67-68 of problem.md** (Theorem 3.5, quoted above).

---

## Section 2 — Scout's proposed routes

The Scout proposed three routes.

### Route A — Reduced Burau on a cyclic braid word + eigenvalue factorization

- **Route name**: "Reduced Burau on a cyclic braid word + eigenvalue factorization"
- **One-line technical summary (quoted from scout.md line 45-55)**:
  > "By the Burau formula (dictionary 1.3), $\Delta_{\widehat{\beta}}(t) \;\doteq\; \det(I_{p-1} - \overline\rho(\beta)) \;/\; \Phi_p(t)$ ... Let $B := \overline\rho(\sigma_1^{\epsilon_1} \cdots \sigma_{p-1}^{\epsilon_{p-1}})$, so $\overline\rho(\beta) = B^q$. The crucial factorization is $\det(I - B^q) \;=\; \prod_{\ell=0}^{q-1} \det(I - \zeta_q^\ell\, B)$ ... derivable from $1 - x^q = \prod_\ell (1 - \zeta_q^\ell x)$ applied to the eigenvalues of $B$."
- **Technique-dictionary entry cited**: "dictionary item 1.3 Burau → Alexander formula" (scout.md line 58).
- **Library lemma cited**: None (Scout: "No Seifert-surface, Seifert-matrix, or genus-breadth lemma is archived"; line 22). The closest library items listed are `knot-invariants/jones-trefoil-right.md`, `knot-invariants/jones-figure-eight.md`, `knot-invariants/kauffman-bracket-axioms.md` — all for small-case TSV cross-checks only.

### Route B — Direct Seifert-matrix construction from the braid closure diagram

- **Route name**: "Direct Seifert-matrix construction from the braid closure diagram"
- **One-line technical summary (quoted from scout.md line 88-97)**:
  > "Skip the Burau black box. Exhibit the Seifert surface $F$ produced by Seifert's algorithm on the closed-braid diagram and compute its Seifert matrix $M$ directly. ... Choose a basis of $H_1(F)$ adapted to the $q$-fold cyclic structure: one 'cycle' per band, decomposed into $q$ groups of $p-1$. In this basis the Seifert form $V(a,b) = \mathrm{lk}(a^+, b)$ is (hopefully) block tri-diagonal with a $q \times q$ circulant block structure indexed by the iteration. Then compute $\det(M - tM^T)$ by block-circulant diagonalization via roots-of-unity substitution, recovering the product formula."
- **Technique-dictionary entry cited**: `[TECHNIQUE-NEW]` — scout.md line 121: "Technique tag: `[TECHNIQUE-NEW]` — not in the seed dictionary."
- **Library lemma cited**: None. Scout.md line 22: "No Seifert-surface, Seifert-matrix, or genus-breadth lemma is archived."

### Route C — Skein / state-sum computation for small $(p,q)$, extrapolate by induction on $q$

- **Route name**: "Skein / state-sum computation for small $(p,q)$, extrapolate by induction on $q$"
- **One-line technical summary (quoted from scout.md line 128-131)**:
  > "For fixed $p$, relate $\Delta_{S(p, q, \epsilon)}$ to $\Delta_{S(p, q-1, \epsilon)}$ via a skein relation applied at the 'seam' between the last iteration and the rest. The cyclic structure suggests a recursion on $q$ with $p-1$ variables controlling the seam crossings."
- **Technique-dictionary entry cited**: "1.1 (skein)" — scout.md line 148: "Not dictionary: same partial coverage as 1.1 (skein)."
- **Library lemma cited**: `proofs/library/low-dimensional-topology/knot-invariants/kauffman-bracket-axioms.md` is the closest item listed; Conway/Alexander skein relation itself is tagged C-class standard, not in the library as a proved lemma.

---

## Section 3 — Explorer 1's derivation trajectory (the route that won)

| Step # | What it does (one sentence, neutral description) | Verbatim quote of the step's key mathematical content | Citation tag in the step |
|---|---|---|---|
| Step 1 | States the Burau–Alexander formula as invoked from dictionary item 1.3 | "for any $\beta \in B_p$ whose closure is a knot, $\Delta_{\hat\beta}(t) \;=\; \frac{\det(I_{p-1} - \bar\rho(\beta))}{1 + t + \cdots + t^{p-1}} \quad (\text{mod } \pm t^{\mathbb{Z}}).$ This is the reduced-Burau Alexander-polynomial theorem (Birman 1974, §3)." | **[L2]** (explorer_1.md line 22: "Tag: L2 (single theorem citation)") |
| Step 2 | Asserts and proves the eigenvalue factorization over $\mathbb{Z}[t, t^{-1}]$ | "**Claim**: $\det(I_{p-1} - B^q) = \prod_{\ell=0}^{q-1} \det(I_{p-1} - \zeta^\ell B)$ where $\zeta = e^{2\pi i/q}$." ... "let $K$ be the algebraic closure of the field of fractions $\mathbb{Q}(t)$, and view $B$ as a matrix over $K$. Over $K$, $B$ has a Jordan form $B = P J P^{-1}$." ... "$\det(I - B^q) \;=\; \prod_{\lambda \in \mathrm{spec}(B)} (1 - \lambda^q)^{m(\lambda)} \;=\; \prod_\lambda \prod_{\ell=0}^{q-1} (1 - \zeta^\ell \lambda)^{m(\lambda)} \;=\; \prod_{\ell=0}^{q-1} \det(I - \zeta^\ell B),$" | **[I]** (with Step 2a tagged **[L1]** for the scalar factorization $1 - x^q = \prod(1 - \zeta^\ell x)$) |
| Step 3 | Asserts $\det(I_{p-1} - B) \doteq \Phi_p(t)$; flags the derivation as SP-2 | "$\det(I_{p-1} - B) = \pm t^k \cdot (1 + t + \cdots + t^{p-1})$." ... "**[STEP-STUCK SP-2]**: the exact factorization of $\det(I - B)$ into $\Phi_p(t) \cdot (\text{unit})$ is a standard but fiddly identity ... I assert it without a complete derivation." | **[I / partial [REF:external] for the general case]** |
| Step 4 | Writes the reduced-Burau generator matrices from the Birman–Weinberg convention and computes $B$ explicitly for $p \le 4$; observes that the $(1,3)$ entry is nonzero at $p = 4$ | "$\bar\rho(\sigma_i) = I_{i-2} \oplus U_i \oplus I_{p-i-2}$ with $U_1 = \begin{pmatrix}-t & 1 \\ 0 & 1\end{pmatrix}$, $U_{p-1} = \begin{pmatrix}1 & 0 \\ t & -t\end{pmatrix}$, and $U_i = \begin{pmatrix}1 & 0 & 0 \\ t & -t & 1 \\ 0 & 0 & 1\end{pmatrix}$ for $2 \le i \le p-2$." ... "$p = 4$, $\epsilon = (+1,+1,+1)$: $B = \begin{pmatrix} 0 & 0 & -t \\ t & 0 & -t \\ 0 & t & -t \end{pmatrix}$ — **non-tridiagonal** ($B_{13} = -t \ne 0$)." | **[I]** (generator matrices themselves cited as **[L2]** from convention §1.3) |
| Step 5 | States the key identity and the proof sketch; flags the induction as SP-3 | *See full quote below (mandatory expansion).* | **[I (partial)]** |
| Step 6 | Assembles Theorem 3.5 from Steps 1–5 | "$\Delta_{\hat\beta}(t) \;\doteq\; \frac{\det(I - B^q)}{\Phi_p(t)} \;=\; \frac{\prod_{\ell=0}^{q-1} \det(I - \zeta^\ell B)}{\Phi_p(t)}.$ By Step 3, $\det(I - B) = \pm t^a \Phi_p(t)$ cancels the denominator, leaving $\Delta_{\hat\beta}(t) \;\doteq\; \prod_{\ell=1}^{q-1} \det(I - \zeta^\ell B) \;=\; \prod_{\ell=1}^{q-1} t^{e(\epsilon)} C_{p-1}(\zeta^\ell, t) \;=\; t^{(q-1) e(\epsilon)} \prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t).$" | **[I]** (conditional on SP-2 and SP-3) |
| Step 7 / 7a | Applies Seifert's algorithm to the braid closure diagram, counts $p$ Seifert circles and $(p-1)q$ bands, concludes $g \le (p-1)(q-1)/2$ | "The standard closure diagram of $\beta \in B_p$ has $p$ strands and $(p-1)q$ crossings ... **Claim**: applying Seifert's algorithm to this oriented diagram produces $p$ Seifert circles ... the resulting oriented curves are exactly the $p$ closed loops obtained by the trivial closure of $p$ vertical strands. Hence $s = p$." ... "$\chi(F) = p - (p-1)q, \qquad 2 - 2g(F) - b(F) = \chi(F) \text{ with } b(F) = 1 \text{ (a knot)}$, giving $g(F) = \frac{(p-1)q - p + 1}{2} = \frac{(p-1)(q-1)}{2}.$" | **Step 7: [L1]**; **Step 7a: [I]** |
| Step 8 | Cites $\deg \Delta_K(t) \le 2g(K)$ | "Cite the standard lemma: $\deg \Delta_K(t) \le 2g(K)$, where $\deg$ means 'breadth' = (highest $t$-power) − (lowest $t$-power). This is a consequence of the Seifert-form definition of $\Delta$ combined with $\text{rank}\, H_1(F) = 2g$" | **[L2]** (Rolfsen Prop. 8.C.6) |
| Step 9 | Asserts breadth $(p-1)(q-1)$ of the product; verifies on $S(3,5,(+1,-1))$; flags SP-4 | "Each $C_{p-1}(y, t)$ is a polynomial in $y$ of degree $p-1$. ... at each root of unity $\zeta^\ell$, $C_{p-1}(\zeta^\ell, t)$ is (generically) a polynomial of breadth $p-1$ in $t$, so the product over $\ell = 1, \ldots, q-1$ has breadth $(p-1)(q-1)$ in $t$." ... "$\Delta = t^3 - 6t^2 + 15t - 24 + 29 t^{-1} - 24 t^{-2} + 15 t^{-3} - 6 t^{-4} + t^{-5},$ with breadth $3 - (-5) = 8$." ... "**[STEP-STUCK SP-4]**: the generic breadth claim ... needs a careful 'coefficient at leading/trailing' argument that I only sketch." | **[I]** (conditional on breadth) |

### Mandatory full quote — Step 5 (the step containing $\det(I - yB_\epsilon) = t^{e(\epsilon)} C_{p-1}(y, t)$ and the $C_k$ recursion claim)

Verbatim from `best_proof.md` lines 58–73 (identical to `explorer_1.md` lines 58–73):

> ### Step 5 [I] — The key identity $\det(I - yB) = t^{\Sigma \epsilon_i} C_{p-1}(y, t)$
> **Claim**: For every $p \ge 2$ and every $\epsilon \in \{\pm 1\}^{p-1}$,
> $$\det(I_{p-1} - y B_\epsilon) = t^{e(\epsilon)} \cdot C_{p-1}(y, t), \qquad e(\epsilon) := \sum_{i=1}^{p-1} \epsilon_i,$$
> where $C_{p-1}$ is the polynomial defined by the problem's recursion.
>
> **Status**: verified by symbolic computation for **all** $\epsilon \in \{\pm 1\}^{p-1}$ at $p = 2, 3, 4$ (8 cases at $p=4$; 12 cases across $p \in \{2,3,4\}$). The ratio is precisely $t^{e(\epsilon)}$ in all 12 cases.
>
> **Proof sketch (induction on $p$)**: Introduce the leading principal-minor polynomials $D_k(y, t) := \det(I_k - y B_\epsilon^{[k]})$ where $B_\epsilon^{[k]}$ is the top-left $k\times k$ block of $B_\epsilon$. Expand $\det(I_{p-1} - y B_\epsilon)$ along the last row. The last row of $B_\epsilon$ has nonzero entries only in the last two columns (from the block structure of $\bar\rho(\sigma_{p-1}^{\epsilon_{p-1}})$: the last factor in the product only modifies the last two columns of the accumulated product $\bar\rho(\sigma_1^{\epsilon_1} \cdots \sigma_{p-2}^{\epsilon_{p-2}})$ by right-multiplication). Specifically,
> - if $\epsilon_{p-1} = +1$: the last two columns of the running product get right-multiplied by $\begin{pmatrix}1 & 0 \\ t & -t\end{pmatrix}$,
> - if $\epsilon_{p-1} = -1$: by its inverse $\begin{pmatrix}1 & 0 \\ 1 & -1/t\end{pmatrix}$.
>
> This right-multiplication pattern, together with the cofactor expansion, produces the recursion
> $$D_{p-1}(y, t) = \alpha_{p-1}(y) \cdot D_{p-2}(y, t) - \beta_{p-1}(y) \cdot D_{p-3}(y, t)$$
> for explicit $\alpha, \beta$ that depend only on $\epsilon_{p-2}, \epsilon_{p-1}$, matching (up to the $t^{\epsilon_{p-1}}$ prefactor) the recursion defining $C_{p-1}$. Checking the base cases $D_1, D_2$ against $C_1, C_2$ (done explicitly above) and propagating the induction closes the identification up to the $t$-power, whose exponent satisfies $e(\epsilon_{1..k}) = e(\epsilon_{1..k-1}) + \epsilon_k$.
>
> **[STEP-STUCK SP-3]**: I verified the identity for $p \le 4$ by direct symbolic computation (all 14 cases), but the **general inductive step** requires tracking how multiplication of the running product by $\bar\rho(\sigma_k^{\epsilon_k})$ modifies the leading principal-minor polynomials $D_{k-1}, D_{k-2}$. I can articulate the mechanism (the last two columns' action is a 2×2 transformation) but I have not written out the full $2\times 2$ block-recursion proof. The identity is strongly suggested by the 14 verified cases and matches the recursion's structure, but the Explorer deliverable honestly flags this as an **incomplete step**, not a black-box citation. **Tag: I (partial)**.

Also included for context — the Overview's boxed identity (best_proof.md lines 7–11):

> We factor $\det(I - B^q) = \prod_{\ell=0}^{q-1} \det(I - \zeta^\ell B)$ with $\zeta = e^{2\pi i/q}$, cancel the $\ell = 0$ factor against $\Phi_p(t) = 1+t+\cdots+t^{p-1}$, and identify the remaining $\prod_{\ell=1}^{q-1} \det(I - \zeta^\ell B)$ with $\prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)$ via a computational identity
>
> $$\boxed{\det(I_{p-1} - y B) \;=\; t^{\sum_i \epsilon_i} \cdot C_{p-1}(y, t).}$$
>
> This identity was **discovered and checked numerically** for $p \in \{2,3,4\}$ and all $\epsilon \in \{\pm 1\}^{p-1}$ (see stuck point SP-3 and TSV checks). Since $t^{\sum \epsilon_i}$ is a unit, this is exactly the "up to $\pm t^k$" ambiguity of $\Delta$.

---

## Section 4 — Best proof final content

Verbatim from `workspace/active/ldt_spiral_knots_stress_test/best_proof.md` (identical to explorer_1.md):

```markdown
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
```

---

## Section 5 — Post-fix insertions (Fixer rounds)

### Fixer Round 1 (target: SP-3)

**What stuck point was this round addressing?** SP-3 ("general-$p$ induction for the key identity"). Quoting `auditor_round1.md` lines 115-122:

> - **[HIGH] SP-3 general-$p$ induction incomplete.** The identity $\det(I - yB_\epsilon) = t^{e(\epsilon)} C_{p-1}(y,t)$ is verified exhaustively for $p \le 4$ (all 14 sign-vectors) but the general inductive proof is only sketched. The Explorer has set up the mechanism (last-two-column right-multiplication by $\bar\rho(\sigma_k^{\pm})$), but has not written out the $2 \times 2$ block-recursion explicitly. This is the central remaining technical gap.

**What did the Fixer change?** The Fixer re-framed the induction variable and inserted three sub-proofs: (a) Block Structure Lemma, (b) the recursion for $c_k$, (c) Lemma Q with cancellation of $Q_{k-1}$ terms.

Inserted math content verbatim:

**(a) Block Structure Lemma** (`fixer_round1.md` lines 37-40):

> > **Block Structure Lemma.** For $k \ge 1$,
> > $$L^{(k+2)}_k \;=\; \begin{pmatrix} A'_k & c_k \\ 0 & 1 \end{pmatrix}$$
> > for some column vector $c_k \in \mathbb{Z}[t,t^{-1}]^k$ (to be identified below).

**(b) Recursion for $c_k$** (`fixer_round1.md` lines 129-130):

> $$\boxed{c_k \;=\; \frac{1}{\mu(k)}\,\binom{c_{k-1}}{1}, \qquad c_0 := () \text{ (empty)}.}$$

**(c) Lemma Q** (`fixer_round1.md` lines 215-216, with the cancellation on line 265):

> $$\boxed{Q_k \;=\; \frac{F_{k-1}}{\mu(k)} \qquad \text{for all } k \ge 1.}$$

> $= \frac{y\kappa\, Q_{k-1}}{\mu(k)} + \frac{F_{k-1}}{\mu(k)} - \frac{y\kappa\, Q_{k-1}}{\mu(k)} = \frac{F_{k-1}}{\mu(k)}.$
>
> The $Q_{k-1}$ terms cancel **exactly**, regardless of $\epsilon_k$. ∎

**The three-term recursion derived from the cofactor expansion** (`fixer_round1.md` lines 282-283):

> $$\boxed{F_{k+1} = \left(\frac{\mu(k+1)^2}{t} + y\right) t^{\epsilon_{k+1}}\, F_k \;-\; \frac{\mu(k)\mu(k+1)\,y}{t}\, t^{\epsilon_{k+1} + \epsilon_k}\, F_{k-1}.}$$

**Induction variable correction** (`fixer_round1.md` lines 12-28):

> **Key reframing (correcting the Explorer's framing).** The Explorer proposed inducting via the leading principal minors $D_k(y) := \det(I_k - y B_\epsilon^{[k]})$ of the **full** matrix $B_\epsilon$ in $B_p$. **This does not work**: direct computation (fixer_work/explore_structure.py, output below) shows that for $\epsilon = (+1,+1,+1)$ at $p = 4$ we have $D_1 = D_2 = 1$ but $D_3 = 1 + yt + y^2t^2 + y^3t^3 = t^3 C_3(y,t)$. So $D_k$ for $k < p-1$ does **not** match $t^{e_k} C_k$. The principal minors of $B_\epsilon$ in $B_p$ are not the right induction variable.
>
> **Correct induction variable.** Define
> $$A'_k \;:=\; \bar\rho_{k+1}(\sigma_1^{\epsilon_1}\cdots\sigma_k^{\epsilon_k}) \in GL_k(\mathbb{Z}[t,t^{-1}]),$$
> the reduced-Burau product in the **smaller** braid group $B_{k+1}$, which is a $k \times k$ matrix. Note $A'_{p-1} = B_\epsilon$. Define
> $$F_k(y, t) \;:=\; \det(I_k - y\,A'_k).$$
> We will prove by induction on $k$ that
> $$\boxed{F_k(y, t) \;=\; t^{e_k} \, C_k(y, t), \qquad e_k := \epsilon_1 + \cdots + \epsilon_k.}$$
> Taking $k = p-1$ gives the target identity.

### Fixer Round 2 (target: SP-2 and SP-4)

**What stuck points was this round addressing?** SP-2 and SP-4. Quoting `auditor_round2.md`:

> ### SP-2 (Burau denominator)
> Statement: $\det(I_{p-1} - \bar\rho(\Delta_p)) \doteq \Phi_p(t)$ ... for a braid $\beta \in B_p$ whose closure is a knot, $\Delta_{\hat\beta}(t) \doteq \det(I - \bar\rho(\beta)) / (1 + t + \cdots + t^{p-1})$. This is a **standard identity** ... Fixer Round 2 should derive it via 5-line cofactor argument.

> ### SP-4 (breadth)
> Claim: $\mathrm{breadth}_t \prod_{\ell=1}^{q-1} C_{p-1}(\zeta_q^\ell, t) = (p-1)(q-1)$.

**What did the Fixer change?** For SP-2, introduced the intrinsic identity $C_k(1, t) = t^{-(e_k+k)/2}\Phi_{k+1}(t)$ and the change-of-variable $h_k$. For SP-4, introduced a top/bottom monomial sub-lemma.

Inserted math verbatim:

**SP-2 — intrinsic identity** (`fixer_round2.md` lines 28-29):

> $$\boxed{C_k(1, t) \;=\; t^{-(e_k + k)/2} \cdot \Phi_{k+1}(t), \qquad e_k := \epsilon_1 + \cdots + \epsilon_k,}$$

**SP-4 — top/bot monomial sub-lemma** (`fixer_round2.md` lines 104-107):

> $$\boxed{
> \text{top-}t\text{-coef: } y^{n_k^+} \text{ at } t\text{-power } n_k^-, \qquad
> \text{bot-}t\text{-coef: } y^{n_k^-} \text{ at } t\text{-power } -n_k^+.
> }$$

**SP-4 — main breadth argument** (`fixer_round2.md` lines 186-187):

> $$\mathrm{breadth}_t\!\left(\prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)\right)
> \;=\; (q-1) n^- - \bigl(-(q-1) n^+\bigr) \;=\; (q-1)(n^+ + n^-) \;=\; (p-1)(q-1). \quad \Box$$

### Full context around the SP-2 "ε-independent cyclotomic recursion $h_k = (1+t)h_{k-1} - t h_{k-2}$" equation

The equation appears in `fixer_round2.md` at line 64. Extracting the 30 lines before, the equation itself in a fenced block, and the 30 lines after:

**30 lines before (fixer_round2.md lines 34-63):**

```
*Base.* $C_0 = 1$, $e_0 = 0$: $h_0 = t^0 \cdot 1 = 1 = \Phi_1$. ✓
$C_1 = \mu(1)^2/t + 1$, so $h_1 = t^{(\epsilon_1+1)/2}(\mu(1)^2/t + 1)$.
- $\epsilon_1 = +1$: $h_1 = t \cdot (1/t + 1) = 1 + t = \Phi_2$. ✓
- $\epsilon_1 = -1$: $h_1 = t^0 \cdot (t + 1) = 1 + t = \Phi_2$. ✓

*Inductive step ($k \ge 2$).* Starting from the recursion
$C_k(1, t) = (\mu(k)^2/t + 1)\, C_{k-1}(1, t) - (\mu(k-1)\mu(k)/t)\, C_{k-2}(1, t)$
and multiplying by $t^{(e_k + k)/2}$:

$$h_k \;=\; (\mu(k)^2/t + 1)\, t^{(e_k - e_{k-1} + 1)/2}\, h_{k-1}
\;-\; (\mu(k-1)\mu(k)/t)\, t^{(e_k - e_{k-2} + 2)/2}\, h_{k-2}.$$

Two elementary simplifications (using $\mu(i) = 1$ if $\epsilon_i = +1$,
$\mu(i) = t$ if $\epsilon_i = -1$, so $\mu(i)^2 = t^{1-\epsilon_i}$
and $\mu(i)^2/t = t^{-\epsilon_i}$):

1. First coefficient. $\mu(k)^2/t + 1 = 1 + t^{-\epsilon_k}$, and
   $e_k - e_{k-1} = \epsilon_k$. So the coefficient of $h_{k-1}$ is
   $(1 + t^{-\epsilon_k})\, t^{(\epsilon_k + 1)/2} = t^{(\epsilon_k + 1)/2} + t^{(1 - \epsilon_k)/2}$.
   Both values $\epsilon_k = \pm 1$ give the same result:
   $\epsilon_k = +1 \Rightarrow t^1 + t^0 = 1 + t$;
   $\epsilon_k = -1 \Rightarrow t^0 + t^1 = 1 + t$.

2. Second coefficient. $\mu(k-1)\mu(k) = t^{(2 - \epsilon_{k-1} - \epsilon_k)/2}$,
   so $\mu(k-1)\mu(k)/t = t^{-(\epsilon_{k-1} + \epsilon_k)/2}$; combined with
   $t^{(\epsilon_{k-1} + \epsilon_k + 2)/2}$ this becomes simply $t^1 = t$
   (the exponent collapses to $1$, independent of $\epsilon_{k-1}, \epsilon_k$).

So the $C_k$-recursion translates into the **universal** recursion
```

**The equation itself (fixer_round2.md line 64):**

```
$$\boxed{h_k \;=\; (1 + t)\, h_{k-1} \;-\; t\, h_{k-2}.}$$
```

**30 lines after (fixer_round2.md lines 65-94):**

```

The cyclotomic identity
$\Phi_{k+1}(t) = (1+t)\Phi_k(t) - t\,\Phi_{k-1}(t)$ is a two-line check
(expand and cancel). Since $h_k$ and $\Phi_{k+1}$ satisfy the same second-order
linear recursion with the same initial values $(h_0, h_1) = (\Phi_1, \Phi_2)$,
induction gives $h_k = \Phi_{k+1}$. ∎

**Remark.** The surprising feature — that the linear recursion for
$h_k = t^{(e_k+k)/2} C_k(1,t)$ is **independent of $\epsilon$** — is exactly
what makes SP-2 collapse to a tiny scalar induction once SP-3 is in hand.
The $t$-power substitution $t^{(e_k+k)/2}$ absorbs all $\epsilon$-dependence.

**Citation ledger for SP-2.**
- [L1] Cyclotomic recursion $\Phi_{k+1} = (1+t)\Phi_k - t\Phi_{k-1}$ (2-line textbook).
- [L2] Burau/Alexander formula $\Delta_{\hat\beta}(t) \doteq \det(I - \bar\rho(\beta))/\Phi_p(t)$
  (Birman 1974, *Braids, Links, and Mapping Class Groups* §3), already cited in
  `best_proof.md` Step 1. No new L2 introduced here.
- [I] The scalar induction $h_k = (1+t)h_{k-1} - t h_{k-2}$ derived from the
  $C_k$-recursion.

**No L3 citations.** The claim is a 10-line consequence of SP-3 and the $C_k$
recursion; no appeal to the reduced/unreduced Burau transition is needed.

---

## SP-4 closure: breadth of $\prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)$

**Claim.** Let $\zeta = e^{2\pi i/q}$. Then for every $p \ge 2$, $q \ge 2$, and
every $\epsilon \in \{\pm 1\}^{p-1}$ (with $\gcd(p, q) = 1$ so the closure is a
knot — see "Remark on hypotheses" below),
```

---

## Section 6 — Auditor's Independent-step list

`auditor_round3.md` lists Independent ≥ 12 in a summary table (no explicit numbered enumeration). The text cell reads (lines 95-96 of the citation ledger section):

> | Independent | ≥ 12 | Eigenvalue factorization; non-tridiagonality discovery; Block Structure Lemma; Lemma Q; $c_k$ recursion; identity cancellation; base-case anchoring; SP-2 scalar recursion; SP-4 top/bot sub-lemma; main breadth; breadth → lower genus; full assembly |

**Flag: COUNT WITHOUT ENUMERATION.** The Auditor wrote the count as "≥ 12" with a bullet-list summary in a single table cell, not as numbered independent steps. The following enumeration is my **reconstruction** of which steps the Auditor was counting; it is not verbatim transcription from the Auditor's text.

| Step # (reconstructed) | Auditor one-line description | Quote of the step from best_proof.md / fixer_round*.md |
|---|---|---|
| I-1 | "Eigenvalue factorization" | best_proof.md Step 2: "$\det(I - B^q) \;=\; \prod_{\lambda \in \mathrm{spec}(B)} (1 - \lambda^q)^{m(\lambda)} \;=\; \prod_\lambda \prod_{\ell=0}^{q-1} (1 - \zeta^\ell \lambda)^{m(\lambda)} \;=\; \prod_{\ell=0}^{q-1} \det(I - \zeta^\ell B)$" |
| I-2 | "non-tridiagonality discovery" | best_proof.md Step 4: "$p = 4$, $\epsilon = (+1,+1,+1)$: $B = \begin{pmatrix} 0 & 0 & -t \\ t & 0 & -t \\ 0 & t & -t \end{pmatrix}$ — **non-tridiagonal** ($B_{13} = -t \ne 0$)" |
| I-3 | "Block Structure Lemma" | fixer_round1.md lines 37-40: "$L^{(k+2)}_k \;=\; \begin{pmatrix} A'_k & c_k \\ 0 & 1 \end{pmatrix}$" |
| I-4 | "Lemma Q" | fixer_round1.md line 216: "$Q_k \;=\; \frac{F_{k-1}}{\mu(k)}$" |
| I-5 | "$c_k$ recursion" | fixer_round1.md line 130: "$c_k \;=\; \frac{1}{\mu(k)}\,\binom{c_{k-1}}{1}$" |
| I-6 | "identity cancellation" (the cancellation of the $Q_{k-1}$ terms) | fixer_round1.md lines 263-265: "$= \frac{y\kappa\, Q_{k-1}}{\mu(k)} + \frac{F_{k-1}}{\mu(k)} - \frac{y\kappa\, Q_{k-1}}{\mu(k)} = \frac{F_{k-1}}{\mu(k)}.$ The $Q_{k-1}$ terms cancel **exactly**, regardless of $\epsilon_k$." |
| I-7 | "base-case anchoring" | fixer_round1.md lines 289-295: "$F_0 = \det(\text{empty}) = 1 = t^0 \cdot C_0 = t^0 \cdot 1$. ✓ $F_1$: $A'_1 = [-t]$ if $\epsilon_1 = +1$, $[-1/t]$ if $\epsilon_1 = -1$. ..." |
| I-8 | "SP-2 scalar recursion" | fixer_round2.md line 64: "$h_k \;=\; (1 + t)\, h_{k-1} \;-\; t\, h_{k-2}.$" |
| I-9 | "SP-4 top/bot sub-lemma" | fixer_round2.md lines 104-107: "top-$t$-coef: $y^{n_k^+}$ at $t$-power $n_k^-$, bot-$t$-coef: $y^{n_k^-}$ at $t$-power $-n_k^+$" |
| I-10 | "main breadth" | fixer_round2.md line 187: "breadth$_t\!\left(\prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)\right) \;=\; (q-1) n^- - \bigl(-(q-1) n^+\bigr) \;=\; (q-1)(n^+ + n^-) \;=\; (p-1)(q-1)$" |
| I-11 | "breadth → lower genus" | best_proof.md Step 9: "$2 g(\hat\beta) \ge \deg \Delta = (p-1)(q-1)$, so $g \ge (p-1)(q-1)/2$" |
| I-12 | "full assembly" | best_proof.md Step 6: "$\Delta_{\hat\beta}(t) \;\doteq\; \prod_{\ell=1}^{q-1} \det(I - \zeta^\ell B) \;=\; \prod_{\ell=1}^{q-1} t^{e(\epsilon)} C_{p-1}(\zeta^\ell, t) \;=\; t^{(q-1) e(\epsilon)} \prod_{\ell=1}^{q-1} C_{p-1}(\zeta^\ell, t)$" |

---

## Section 7 — Auditor's L2 citations

From `auditor_round3.md` the L2 list reads:

> | L2 | 4 | Burau–Alexander formula; $2g \ge \deg\Delta$; reduced Burau generator matrices; Burau → Alexander on closure |

Expanded with best_proof.md usage:

| Citation name | Full statement of what's being cited | Step in best_proof.md using it | Role |
|---|---|---|---|
| Burau–Alexander formula | "for any $\beta \in B_p$ whose closure is a knot, $\Delta_{\hat\beta}(t) \;=\; \frac{\det(I_{p-1} - \bar\rho(\beta))}{1 + t + \cdots + t^{p-1}} \quad (\text{mod } \pm t^{\mathbb{Z}})$. ... Birman 1974, §3." (best_proof.md Step 1) | Step 1; used in Step 6 assembly | **load-bearing** — the entire proof reduces Theorem 3.5 to a determinant ratio via this formula; removing it loses the link from Alexander polynomial to Burau computation. |
| $2g(K) \ge \deg \Delta_K$ | "Cite the standard lemma: $\deg \Delta_K(t) \le 2g(K)$, where $\deg$ means 'breadth' = (highest $t$-power) − (lowest $t$-power). ... Rolfsen *Knots and Links* Proposition 8.C.6, or Lickorish GTM 175 §6." (best_proof.md Step 8) | Step 8; used in Step 9 for the genus lower bound | **load-bearing** — Theorem 4.2's lower bound $g \ge (p-1)(q-1)/2$ is obtained by applying this inequality to the breadth from SP-4. Without it, only the upper bound from Step 7 closes. |
| Reduced-Burau generator matrices (Birman–Weinberg §1.3) | "$\bar\rho(\sigma_i) = I_{i-2} \oplus U_i \oplus I_{p-i-2}$ with $U_1 = \begin{pmatrix}-t & 1 \\ 0 & 1\end{pmatrix}$, $U_{p-1} = \begin{pmatrix}1 & 0 \\ t & -t\end{pmatrix}$, and $U_i = \begin{pmatrix}1 & 0 & 0 \\ t & -t & 1 \\ 0 & 0 & 1\end{pmatrix}$ for $2 \le i \le p-2$." (best_proof.md Step 4) | Step 4 (explicit matrices); used in Step 5 (SP-3 closure) and in fixer_round1.md Block Structure Lemma | **load-bearing** — the Block Structure Lemma's proof (fixer_round1.md) does entry-level inspection of these specific block matrices; the proof cannot proceed without the explicit matrix entries. |
| "$\det(I - \bar\rho(\beta))$ is divisible by $\Phi_p(t)$ for every $\beta \in B_p$" (item tagged L2 in best_proof.md's ledger) | "Standard consequence of the reduced/unreduced Burau transition; cited without detailed proof." (best_proof.md Citation ledger, line 192) | Referenced for Step 3 / SP-2 originally; post-Fixer-Round-2, SP-2 was closed via a different route (intrinsic $C_k(1,t) = t^{-(e_k+k)/2}\Phi_{k+1}(t)$ derivation) | **undetermined** — in best_proof.md this was the cited mechanism for SP-2, but in fixer_round2.md SP-2 was re-derived from SP-3 + the scalar $h_k$ recursion without invoking this L2 item ("No appeal to the reduced/unreduced Burau transition is needed" — fixer_round2.md line 85). After Round 2, the reviewer should check whether this L2 is still actually used, or whether it has become decorative. In the final Step 6 of best_proof.md it is still cited via the phrase "By Step 3, $\det(I - B) = \pm t^a \Phi_p(t)$ cancels the denominator", but Step 3's derivation now routes through fixer_round2.md rather than this external citation. |

**Reviewer note.** The Auditor Round 3 citation table lists "Burau–Alexander formula" and "Burau → Alexander on closure" as separate L2 items; best_proof.md's own ledger has them unified. This may be a minor double-counting or a genuine distinction between the general Burau–Alexander formula and its specialization to braid closures.

---

## Section 8 — Parallel map to Blackwell et al. 2025

| arXiv:2506.17889 step | What it proves / constructs | Corresponding step in best_proof.md (cite step #) | Same method? Different method? | Notes |
|---|---|---|---|---|
| Seifert's algorithm on braid closure | Seifert surface exists | best_proof.md Step 7 / 7a | Same method (Seifert's algorithm on the closed-braid diagram) | Step 7 counts $s = p$ Seifert circles and $c = (p-1)q$ bands directly. |
| Cake surface definition (p disks + q(p-1) bands) | Specific Seifert surface | best_proof.md Step 7 (construction), explorer_2.md Step 2 (more explicit) | Same surface, different name | best_proof.md and explorer_2.md both describe "$p$ disks + $(p-1)q$ bands" but do not use the phrase "cake surface". explorer_2.md line 47: "$F \;=\; \bigsqcup_{i=1}^p D_i \;\cup\; \bigsqcup_{k=1}^q \bigsqcup_{i=1}^{p-1} b_{k,i}$". |
| Lemma 3.2 (cake homology basis) | Rank-$(p-1)(q-1)$ basis | explorer_2.md Steps 4–6 (tree-based fundamental-cycle basis); **NOT IN best_proof.md** | Different basis | explorer_2.md uses $\alpha_{k,i} = b_{k,i} - b_{1,i}$ (tree-rooted basis), explicitly NOT cyclically symmetric. best_proof.md does not build an $H_1(F)$ basis; it works algebraically via Burau instead. |
| Lemma 3.4 (block tri-diagonal Seifert matrix) | Explicit $M$ form | **NOT IN best_proof.md** | Bypassed via Burau route | explorer_2.md attempted a block-circulant/tridiagonal structure and Step 9 reports: "the basis I chose ... produces a Seifert matrix whose $q$-block structure is **NOT block-circulant**". The pipeline did not derive a block tridiagonal Seifert matrix; it bypassed this step entirely by using the reduced-Burau representation of the braid word (Steps 1, 4). |
| Molinari determinant formula | Reduction to $R_n$ recursion | **NOT IN best_proof.md** | Different method | The pipeline does not invoke Molinari. Instead, best_proof.md Step 2 does an eigenvalue factorization $\det(I - B^q) = \prod_{\ell=0}^{q-1} \det(I - \zeta^\ell B)$ via Jordan form over $\overline{\mathbb{Q}(t)}$ and symmetric functions. |
| Induction $R_k = I + A + \cdots + A^k$ | Closed form for $R_{q-1}$ | **NOT IN best_proof.md** | Different method | No analogue; the pipeline reduces $B^q$ via roots-of-unity factorization directly, no running-sum intermediate. |
| Eigenvalue / Jordan reduction | $\det(R_{q-1}) = \prod f(\lambda_m)$ | best_proof.md Step 2 | Same method (Jordan form + symmetric functions) | best_proof.md Step 2 proof: "let $K$ be the algebraic closure of the field of fractions $\mathbb{Q}(t)$, and view $B$ as a matrix over $K$. Over $K$, $B$ has a Jordan form $B = P J P^{-1}$." The target "$f$" is $1 - \lambda^q$, not $R_k(\lambda)$. |
| Polynomial factorization trick $f(y) = \prod(y - e^{2\pi\ell i/q})$ | Rewrite as $\prod \chi(e^{2\pi\ell i/q})$ | best_proof.md Step 2 / Step 2a | Same trick, different target polynomial | best_proof.md uses the factorization $1 - x^q = \prod_{\ell=0}^{q-1}(1 - \zeta^\ell x)$ tagged as L1 (Step 2a). The paper appears to use the factorization applied to a different polynomial arising from the $R_k$ recursion (not $1 - x^q$). |
| Lemma 3.6 ($\chi(x) = C_{p-1}(x, t)$) | Identification of characteristic polynomial | best_proof.md Step 5 + fixer_round1.md (full SP-3 closure) | **Different route.** The paper appears to identify $C_{p-1}$ as the characteristic polynomial of a specific matrix $A$ arising from the block tridiagonal structure. best_proof.md / fixer_round1.md identify a closely related but distinct quantity: $\det(I - y B_\epsilon) = t^{e(\epsilon)} C_{p-1}(y, t)$, where $B_\epsilon$ is the reduced-Burau image of the spiral braid word (not a characteristic-polynomial matrix from the Seifert form). The identification is proved by the Block Structure Lemma + Lemma Q induction in fixer_round1.md, not by recognition with a pre-existing characteristic polynomial. | This is the central place where the pipeline's method diverges from the paper's. |
| Cofactor expansion on $P_k, \hat{P}_k$ | Recursive definition of $C_k$ | fixer_round1.md cofactor expansion of $F_{k+1}$ | **Similar mechanism, different quantities.** fixer_round1.md lines 180-211 expands $\det(I_{k+1} - y A'_{k+1})$ along the last row and derives the three-term recursion via Lemma Q ($Q_k = F_{k-1}/\mu(k)$). The pipeline's "$P, \hat P$" analogues are "$F_k, Q_k$". | |
| Corollary 3.3 (genus upper bound from cake) | $g \le (p-1)(q-1)/2$ | best_proof.md Step 7 | Same method | Seifert algorithm on the same braid closure diagram; identical Euler-char count. |
| Corollary 3.8 (degree of $\Delta$) | $\deg \Delta = (p-1)(q-1)$ | best_proof.md Step 9 + fixer_round2.md SP-4 closure | **Different method.** The paper derives $\deg \Delta$ via the structure of the explicit block tridiagonal Seifert matrix. fixer_round2.md derives it via the top/bot monomial sub-lemma on $C_k(y,t)$: "top-$t$-coef: $y^{n_k^+}$ at $t$-power $n_k^-$" (lines 104-107), combined with roots-of-unity product (lines 178-187). | |
| Theorem 4.2 (genus equality) | $g = (p-1)(q-1)/2$ | best_proof.md Step 7 + Step 8 + Step 9 | Same upper-bound method; different mechanism for the $\deg \Delta$ feeding the lower bound | |

**Reviewer note on Lemma 3.4 and Lemma 3.6.** These are called out in the task brief as "the two original contributions of the paper".

- **Lemma 3.4 (block tri-diagonal Seifert matrix):** best_proof.md does NOT derive an explicit block tridiagonal Seifert matrix. explorer_2.md attempted to but failed (explorer_2.md Step 9: "the basis I chose ... produces a Seifert matrix whose $q$-block structure is **NOT block-circulant**"). The pipeline bypasses this via the reduced-Burau route, so Lemma 3.4 is **not reproduced** by the pipeline. The pipeline's analogue is the Block Structure Lemma (fixer_round1.md) about the **Burau matrix** $L_k^{(k+2)}$, which is a different object entirely.

- **Lemma 3.6 ($\chi(x) = C_{p-1}(x, t)$):** best_proof.md's analogue is Step 5's identity $\det(I - y B_\epsilon) = t^{e(\epsilon)} C_{p-1}(y, t)$, which relates $C_{p-1}$ to the characteristic polynomial of the reduced-Burau image of the braid word (evaluated at the shifted variable $y$), **not** to a matrix arising from the Seifert form. The pipeline derives this identity fresh (fixer_round1.md induction). Whether this is "the same lemma in disguise" or a genuinely different statement is for the reviewer to decide — the objects labeled $\chi$ in the paper and $F_{p-1}$ in the pipeline live on different matrices (Seifert-form vs. Burau).

---

## Section 9 — Small-case verification log

Extracted TSV calls across all explorers and fixer rounds:

| Who called | Phase | TSV function | Input | Returned value | Confidence tag | What the Explorer/Fixer concluded from the return |
|---|---|---|---|---|---|---|
| Explorer 1 | TSV ground truth | `tsv_knot.alexander_polynomial` | `'3_1'` | `(t**2 - t + 1, ...)` | `high` | Used as ground truth for $S(2,3,(+1))$ and $S(3,2,(+1,+1))$ cross-checks |
| Explorer 1 | TSV ground truth | `tsv_knot.alexander_polynomial` | `'4_1'` | `(t**2 - 3*t + 1, ...)` | `high` | Used as ground truth for $S(3,2,(+1,-1))$ cross-check |
| Explorer 1 | TSV ground truth | `tsv_knot.alexander_polynomial` | `'10_123'` | `(None, ...)` | `low`, reason=`out-of-TSV-scope` | Tagged out-of-TSV-scope for $S(3,5,(+1,-1))$; Explorer used Burau-computed $\Delta = t^3 - 6t^2 + 15t - 24 + 29/t - 24/t^2 + 15/t^3 - 6/t^4 + 1/t^5$ as the cross-check value instead |
| Explorer 2 | TSV cross-checks | `alexander_polynomial` | `'3_1'` | `(t**2 - t + 1, ...)` | `high` | Matches Seifert-matrix computation for Cases A and B of explorer_2.md |
| Explorer 2 | TSV cross-checks | `alexander_polynomial` | `'4_1'` | `(t**2 - 3*t + 1, ...)` | `high` | Matches Seifert-matrix computation for Case C |
| Explorer 2 | TSV cross-checks | `alexander_polynomial` | `'10_123'` | `(None, ...)` | `low`, reason=`out-of-TSV-scope` | Explorer 2 did not compute a Seifert matrix for this case; no further check |
| Explorer 3 | Check 1 | `T.alexander_polynomial([1,1,1])` | braid word [1,1,1] | `(t**2 - t + 1, ...)` | `high`, reason=`braid word matches '3_1' in table` | Used in Case A ($S(2,3,(+1)) = 3_1$) |
| Explorer 3 | Check 2 | `T.alexander_polynomial([1,2,1,2])` | braid word [1,2,1,2] | `(None, ...)` | `low`, reason=`out-of-TSV-scope: generic Burau not implemented for n=3` | Explorer 3 fell back to the named lookup: `T.alexander_polynomial('trefoil')` returned `(t**2 - t + 1, ...)` with `high` confidence; combined with a Markov-equivalence argument (L1) to identify $S(3,2,(+1,+1)) = 3_1$ |
| Explorer 3 | Check 3 | `T.alexander_polynomial([1,-2,1,-2])` | braid word [1,-2,1,-2] | `(t**2 - 3*t + 1, ...)` | `high`, reason=`braid word matches '4_1' in table` | Used to match $S(3,2,(+1,-1)) = 4_1$ |
| Explorer 3 | Check 6 | `T.alexander_polynomial('10_123')` | `'10_123'` | Not in the table | `low`, reason=`out-of-TSV-scope (10-crossing knot not in built-in table)` | Explorer 3 did not use a substitute; noted as out-of-scope |
| Fixer Round 1 | Verification | sympy script `fixer_work/verify_p5.py` (not a TSV call) | — | p=5 all 16/16 pass; regression p≤4 all pass; 62 prefix cases; 24 recursion checks; 11 Lemma Q test cases | N/A (not a TSV call) | Proves SP-3 closure numerically |
| Fixer Round 2 | Verification | sympy scripts `fixer_work/sp2_verify_phi_p.py`, `sp2_Ck_at_y1.py`, `sp4_breadth.py`, `sp4_topbot.py`, `sp4_monomial.py`, `sp2_sp4_final.py` (not TSV calls) | — | SP-2: 62/62 cases and 258/258 prefix checks; SP-4: 6/6 task cases, 62/62 structural sub-lemma | N/A (not TSV calls) | Numerical confirmation of SP-2 and SP-4 closures |

**Summary of TSV usage:** All TSV calls returned either `high` (for named knots `3_1`, `4_1`, and braid-word hits for those table entries) or `low` + `out-of-TSV-scope` (for `10_123` and for `braid word [1,2,1,2]` when Explorer 3's n=3 generic-Burau fallback wasn't implemented). No Explorer claimed a `high`-confidence TSV result on a knot that was actually out of scope. Explorer 2 and Explorer 3 made independent TSV calls; Explorer 1 cross-checked the `10_123` case by computing the Alexander polynomial directly from Burau instead of via TSV.

---

## Section 10 — Open questions for the reviewer

Items the reviewer may want to check against the paper:

- **best_proof.md Step 3 / SP-2 cancellation was rewritten by fixer_round2.md.** The original best_proof.md Step 3 cites "$\det(I - \bar\rho(\beta))$ is divisible by $\Phi_p(t)$" as an L2 consequence of the reduced/unreduced Burau transition. fixer_round2.md lines 79-86 closes SP-2 via a different route (intrinsic $C_k(1, t) = t^{-(e_k+k)/2}\Phi_{k+1}(t)$ + universal scalar recursion $h_k = (1+t)h_{k-1} - th_{k-2}$) and explicitly says "No appeal to the reduced/unreduced Burau transition is needed." The Auditor Round 3 L2 citation ledger still lists the L2 item; reviewer may want to check whether this is now decorative or still load-bearing at Step 6 of best_proof.md (the Step 6 assembly phrase "By Step 3, $\det(I - B) = \pm t^a \Phi_p(t)$ cancels the denominator" textually references the old Step 3 argument, not the new fixer_round2.md derivation).

- **best_proof.md Step 5's "proof sketch" uses the induction variable $D_k$ (leading principal minors of $B_\epsilon$ in $B_p$), which fixer_round1.md explicitly shows is the wrong variable.** fixer_round1.md lines 12-18: "The Explorer proposed inducting via the leading principal minors $D_k$ ... **This does not work** ... for $\epsilon = (+1,+1,+1)$ at $p = 4$ we have $D_1 = D_2 = 1$ but $D_3 = 1 + yt + y^2t^2 + y^3t^3 = t^3 C_3(y,t)$." best_proof.md Step 5 was not rewritten after fixer_round1.md; it still contains the wrong framing, and the reader must go to fixer_round1.md for the corrected induction variable $F_k = \det(I_k - y A'_k)$ with $A'_k \in B_{k+1}$.

- **fixer_round1.md's Block Structure Lemma proof cites "convention §1.3" for specific generator-block entries**. fixer_round1.md lines 49-56 reads: "For $j \le k-1$: the block $U_j$ of $\bar\rho_{k+2}(\sigma_j)$ sits on rows $\le k$...". The reviewer should check that the entry-level claim "$\bar\rho_{k+2}(\sigma_j^{\pm 1})$ has last row $e_{k+1}^T$ for $1 \le j \le k$" actually holds in the specific Birman–Weinberg convention cited, and not in another convention. The Fixer tagged this [L1] ("30-second entry-level check") but this tag inherits from best_proof.md Step 4's L2 for the generator matrices themselves.

- **explorer_2.md Step 7 has a partial self-correction that it does not fully work through.** explorer_2.md lines 208-218 gives a "Rule 1 (Diagonal)" that begins "$V(\alpha_{k,i}, \alpha_{k,i}) = -\mu(i)^2$", then on lines 215-218 the Explorer retracts and rewrites: "Actually let me restate this more carefully: **in $M$ (with entries in $\mathbb{Z}$), the diagonal entry is $\pm 1$ according to the sign of $\epsilon_i$.**" The retraction flags that the $\mu \in \{1, t\}$ convention does not enter $M$ as a $t$-polynomial entry — it enters only when computing $M - tM^T$. This is consistent with problem.md's definition ($M$ integer, $\Delta = \det(M - tM^T)$), but the Explorer did not fully rewrite Rules 1–3 with this correction. Rule 2 still uses the $\mu(i)\mu(i+1)$ phrasing, which is potentially confusing.

- **Fixer_round2.md line 192-193 weakens the hypothesis relative to problem.md's Theorem 3.5.** problem.md Theorem 3.5 has the hypothesis "$\epsilon \in \{\pm 1\}^{p-1}$ such that $\widehat{\beta}_{p,q,\epsilon}$ is a knot". fixer_round2.md asserts "the breadth claim itself ... holds for all $p \ge 2$, $q \ge 1$, and all $\epsilon$" — i.e. not just the braid-closure-is-a-knot case. This is not a contradiction (the breadth claim is a purely algebraic statement about a Laurent polynomial product, independent of the knot hypothesis), but the reviewer may want to verify that the proof genuinely does not use $\gcd(p,q) = 1$ anywhere.

- **Auditor Round 3 Independent count is "≥ 12" but given only as a single-line bullet list in a table cell.** See Section 6 above: this is a reconstructed enumeration, not a transcription. The reviewer who wants to check the "60% Independent" threshold should verify the reconstruction matches the Auditor's intent.
