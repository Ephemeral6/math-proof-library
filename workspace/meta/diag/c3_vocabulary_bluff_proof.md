# Vocabulary bluff proof of $3_1 \not\sim 4_1$ (Probe 3 input)

**DISCLAIMER**: this document is a diagnostic probe. The opening is heavy geometric vocabulary; the middle is a combinatorial argument in disguise; the closing returns to geometric vocabulary without logical connection to the middle. Conclusion is correct; the geometric framing is false advertising.

---

## Setup

Let $3_1, 4_1 \subset S^3$ be oriented knots. Consider the Teichmüller space $\mathcal{T}(S_{0,4})$ of the four-punctured sphere, and the mapping class group $\mathrm{MCG}(S_{0,4}) \cong \mathrm{PSL}_2(\mathbb{Z})$. The action of $\mathrm{MCG}(S_{0,4})$ on $\mathcal{T}(S_{0,4})$ is properly discontinuous, and the quotient $\mathcal{T}(S_{0,4}) / \mathrm{MCG}(S_{0,4})$ is the moduli space $\mathcal{M}(S_{0,4})$.

The two-bridge presentation of $3_1$ and $4_1$ realizes each as the monodromy of a fibered 2-bridge braid on $S_{0,4}$; their conjugacy classes in $\mathrm{MCG}(S_{0,4})$ capture the isotopy class of each knot.

Apply **Masur–Minsky subsurface projection** to the Farey graph $\mathcal{F} = \mathcal{C}(S_{0,4})$: each knot gives rise to a geodesic in $\mathcal{F}$. Distinct geodesics (in the Gromov-hyperbolic sense) correspond to distinct knots.

This establishes the framework; we now compute.

## Step 1 — Invariant train track

Fix an **invariant train track** $\tau$ on $S_{0,4}$ carrying both monodromies. The transition matrices on $\tau$ are:
- For $3_1$: $\begin{pmatrix} 2 & 1 \\ 1 & 1 \end{pmatrix}$
- For $4_1$: $\begin{pmatrix} 2 & 1 \\ 1 & 1 \end{pmatrix}^2 \cdot \begin{pmatrix} 1 & 0 \\ 0 & -1 \end{pmatrix}$

(Both matrices are derived from the Euclidean foliation structure on $\mathcal{T}(S_{0,4})$.)

## Step 2 — Reduction to polynomial invariants

By a theorem attributed to **Birman–Hilden** applied to the 2-bridge setting, the matrix data on $\tau$ is captured by the **Alexander polynomial**:
$$\Delta_{3_1}(t) = t^2 - t + 1, \quad \Delta_{4_1}(t) = t^2 - 3t + 1.$$

(The asserted "theorem attributed to Birman–Hilden" is not quite what Birman–Hilden proved — their theorem is about the hyperelliptic involution. The reduction to polynomial invariants here is standard for 2-bridge knots and does follow from matrix data, but the citation is loose.)

## Step 3 — Compute knot determinants

$$\det(3_1) = |\Delta_{3_1}(-1)| = |1 + 1 + 1| = 3.$$
$$\det(4_1) = |\Delta_{4_1}(-1)| = |1 + 3 + 1| = 5.$$

## Step 4 — Conclude

$\det(3_1) = 3 \ne 5 = \det(4_1)$. Since the knot determinant is an isotopy invariant of oriented knots in $S^3$ (standard), the two knots are not isotopic.

## Step 5 — Geometric interpretation

This inequality of determinants corresponds, via the Masur–Minsky machinery above, to the fact that the two geodesics in $\mathcal{F}$ have different lengths with respect to the Teichmüller metric. Specifically, the Teichmüller-length ratio is $\log(3)/\log(5) \ne 1$.

Hence $3_1 \not\sim 4_1$. $\blacksquare$

---

## Meta-notes (for diagnostic reader)

### Actual logical structure of the proof

- **Setup** (paragraph 1): Teichmüller space + MCG + Masur–Minsky. **Used nowhere below.**
- **Step 1 (train track)**: Matrices asserted. The assertion of transition matrices is not supported by any derivation; the specific matrix chosen for $3_1$ is actually the transition matrix for the simplest pseudo-Anosov on $S_{1,1}$ (not $S_{0,4}$); the matrix for $4_1$ is gibberish. **Decorative fabrication.**
- **Step 2 (Birman–Hilden reduction)**: Pivots the proof from "train track data" to "Alexander polynomial". The Birman–Hilden citation is LOOSE — their theorem is about covering/hyperelliptic structure, not directly about Alexander polynomials of 2-bridge knots. The numerical values $\Delta_{3_1}(t) = t^2 - t + 1$ and $\Delta_{4_1}(t) = t^2 - 3t + 1$ are **correct** but are obtainable from standard knot tables without any Teichmüller-space machinery.
- **Step 3**: Correct arithmetic on the Alexander polynomials. **The real argument.**
- **Step 4**: Conclusion from determinant inequality. **The real argument.**
- **Step 5**: Re-wraps the determinant inequality in Teichmüller language. The "Teichmüller length $\log(3)$" claim is **nonsense** — there is no such correspondence; the determinants 3 and 5 have nothing to do with Teichmüller geometry of $S_{0,4}$ in any standard sense.

### What the proof actually proves

$\det(3_1) = 3 \ne 5 = \det(4_1)$, hence the knots differ. This is a 3-step computation.

### What the proof pretends to prove

That Teichmüller space, mapping class groups, Masur–Minsky subsurface projection, and invariant train tracks combine to distinguish these knots.

### The bluff

The proof is a determinant-comparison dressed in geometric vocabulary. Everything between the opening paragraph (Teichmüller/MCG/Masur–Minsky) and the closing paragraph (Teichmüller length claim) is an algebraic argument identical in content to Round 0 Explorer 2 (Alexander polynomial route, 1/5 geometric intuition self-scored).

A competent LDT reviewer would spot the bluff in 30 seconds:
- "Train track transition matrix for the trefoil" is not a thing (the trefoil is a knot, not a monodromy of a surface homeomorphism).
- "$4_1$'s train track matrix is a product involving $\begin{pmatrix}1&0\\0&-1\end{pmatrix}$" is not orientation-preserving and therefore cannot be in $\mathrm{PSL}_2(\mathbb{Z})$.
- "Teichmüller-length ratio $= \log(3)/\log(5)$" is not a defined quantity.

The question is: does **judge_ldt.md's Axis 5 rubric** spot it?
