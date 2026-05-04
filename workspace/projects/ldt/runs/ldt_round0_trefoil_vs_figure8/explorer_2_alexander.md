# Explorer 2 — Route 2: Alexander polynomial / determinant

## Setup

Represent $3_1$ as the closure of $\sigma_1^3 \in B_2$ and $4_1$ as the closure of $\sigma_1 \sigma_2^{-1} \sigma_1 \sigma_2^{-1} \in B_3$.  Alexander polynomial will be computed via the reduced Burau representation.

## Strategy

For a braid $\beta \in B_n$, the (normalized) Alexander polynomial of its closure is
$$\Delta_{\widehat{\beta}}(t) = \frac{\det(I - \overline{\rho}(\beta))}{1 + t + \cdots + t^{n-1}}$$
up to multiplication by $\pm t^k$, where $\overline{\rho}: B_n \to GL_{n-1}(\mathbb{Z}[t, t^{-1}])$ is the reduced Burau representation.

Unequal Alexander polynomials $\Rightarrow$ unequal knots.

## Step 1 — Reduced Burau matrices

For $B_2$ (i.e., $n = 2$), the reduced Burau rep is 1-dimensional: $\sigma_1 \mapsto -t$, $\sigma_1^{-1} \mapsto -t^{-1}$.

For $B_3$ ($n = 3$), the reduced Burau matrices are $2 \times 2$:
$$\overline{\rho}(\sigma_1) = \begin{pmatrix} -t & 1 \\ 0 & 1 \end{pmatrix}, \qquad \overline{\rho}(\sigma_2) = \begin{pmatrix} 1 & 0 \\ t & -t \end{pmatrix}.$$

Inverses:
$$\overline{\rho}(\sigma_2^{-1}) = \begin{pmatrix} 1 & 0 \\ 1 & -t^{-1} \end{pmatrix}.$$

## Step 2 — Compute $\Delta_{3_1}(t)$ from $\sigma_1^3$ in $B_2$

$$\overline{\rho}(\sigma_1^3) = (-t)^3 = -t^3.$$
$$\det(I - (-t^3)) = \det(1 + t^3) = 1 + t^3.$$
Divide by $1 + t$ (the normalizer for $n = 2$):
$$\Delta_{3_1}(t) = \frac{1 + t^3}{1 + t} = t^2 - t + 1.$$

**Verification step.** [CALL:tsv-knot] `alexander_polynomial("trefoil")` — TSV returns $t^2 - t + 1$. [VERIFIED: tsv-knot, submethod=alexander, confidence=high]

## Step 3 — Compute $\Delta_{4_1}(t)$ from $\sigma_1 \sigma_2^{-1} \sigma_1 \sigma_2^{-1}$ in $B_3$

Let $M = \overline{\rho}(\sigma_1) \overline{\rho}(\sigma_2^{-1}) \overline{\rho}(\sigma_1) \overline{\rho}(\sigma_2^{-1})$.

Compute step by step.  Let $P = \overline{\rho}(\sigma_1) \overline{\rho}(\sigma_2^{-1})$.

$$P = \begin{pmatrix} -t & 1 \\ 0 & 1 \end{pmatrix} \begin{pmatrix} 1 & 0 \\ 1 & -t^{-1} \end{pmatrix} = \begin{pmatrix} -t + 1 & -t^{-1} \\ 1 & -t^{-1} \end{pmatrix}.$$

Then $M = P^2$:
$$P^2 = \begin{pmatrix} (-t+1)^2 + (-t^{-1}) \cdot 1 & (-t+1)(-t^{-1}) + (-t^{-1})(-t^{-1}) \\ (1)(-t+1) + (-t^{-1})(1) & (1)(-t^{-1}) + (-t^{-1})(-t^{-1}) \end{pmatrix}.$$

Entry (1,1): $(-t+1)^2 - t^{-1} = t^2 - 2t + 1 - t^{-1}$.
Entry (1,2): $(-t+1)(-t^{-1}) + t^{-2} = 1 - t^{-1} + t^{-2}$.
Entry (2,1): $-t + 1 - t^{-1}$.
Entry (2,2): $-t^{-1} + t^{-2}$.

So
$$M = \begin{pmatrix} t^2 - 2t + 1 - t^{-1} & 1 - t^{-1} + t^{-2} \\ -t + 1 - t^{-1} & -t^{-1} + t^{-2} \end{pmatrix}.$$

$I - M$:
$$I - M = \begin{pmatrix} 1 - t^2 + 2t - 1 + t^{-1} & -1 + t^{-1} - t^{-2} \\ t - 1 + t^{-1} & 1 + t^{-1} - t^{-2} \end{pmatrix} = \begin{pmatrix} -t^2 + 2t + t^{-1} & -1 + t^{-1} - t^{-2} \\ t - 1 + t^{-1} & 1 + t^{-1} - t^{-2} \end{pmatrix}.$$

$\det(I - M) = (-t^2 + 2t + t^{-1})(1 + t^{-1} - t^{-2}) - (-1 + t^{-1} - t^{-2})(t - 1 + t^{-1})$.

Expand term 1: $(-t^2)(1) + (-t^2)(t^{-1}) + (-t^2)(-t^{-2}) + (2t)(1) + (2t)(t^{-1}) + (2t)(-t^{-2}) + (t^{-1})(1) + (t^{-1})(t^{-1}) + (t^{-1})(-t^{-2})$
$= -t^2 - t + 1 + 2t + 2 - 2t^{-1} + t^{-1} + t^{-2} - t^{-3}$
$= -t^2 + t + 3 - t^{-1} + t^{-2} - t^{-3}$.

Expand term 2: $(-1)(t) + (-1)(-1) + (-1)(t^{-1}) + (t^{-1})(t) + (t^{-1})(-1) + (t^{-1})(t^{-1}) + (-t^{-2})(t) + (-t^{-2})(-1) + (-t^{-2})(t^{-1})$
$= -t + 1 - t^{-1} + 1 - t^{-1} + t^{-2} - t^{-1} + t^{-2} - t^{-3}$
$= -t + 2 - 3 t^{-1} + 2 t^{-2} - t^{-3}$.

$\det(I-M) = $ term1 $-$ term2 $= (-t^2 + t + 3 - t^{-1} + t^{-2} - t^{-3}) - (-t + 2 - 3t^{-1} + 2t^{-2} - t^{-3})$
$= -t^2 + t + 3 - t^{-1} + t^{-2} - t^{-3} + t - 2 + 3t^{-1} - 2t^{-2} + t^{-3}$
$= -t^2 + 2t + 1 + 2t^{-1} - t^{-2}$.

Divide by $1 + t + t^2$ (normalizer for $n = 3$).  This feels off — let me double-check.  Actually, Burau-based Alexander is delicate; the simpler route is the **Alexander matrix** from a Wirtinger presentation, which gives $\Delta_{4_1}(t) = t^2 - 3t + 1$ directly.

[STEP-STUCK: normalization] The arithmetic above produced $\det(I - M) = -t^2 + 2t + 1 + 2t^{-1} - t^{-2}$ which does not cleanly divide by $1 + t + t^2$.  This could be an arithmetic error OR an issue with the Burau normalization conventions (several conventions exist; the correct divisor depends on whether you use reduced vs. unreduced Burau, and on sign choices).

**Verification step.** [CALL:tsv-knot] `alexander_polynomial("figure-eight")` — TSV returns $t^2 - 3t + 1$. [VERIFIED: tsv-knot, submethod=alexander, confidence=high]

Taking TSV's value as ground truth (which is consistent with any standard knot table, Rolfsen etc.), $\Delta_{4_1}(t) = t^2 - 3t + 1$.

## Step 4 — Compare

$\Delta_{3_1}(t) - \Delta_{4_1}(t) = (t^2 - t + 1) - (t^2 - 3t + 1) = 2t \neq 0.$

Alternatively, the knot determinant $|\Delta(-1)|$: $|\Delta_{3_1}(-1)| = |1 + 1 + 1| = 3$; $|\Delta_{4_1}(-1)| = |1 + 3 + 1| = 5$.  These are distinct integers.

## Step 5 — Conclude

Alexander polynomial is an invariant of ambient isotopy for knots in $S^3$; it is well-defined up to $\pm t^k$.  Since our monic integer-coefficient forms disagree (and the knot determinants 3 ≠ 5 are unambiguous invariants), $3_1 \not\sim 4_1$.  $\blacksquare$

## Notes

- [STEP-STUCK] Step 3 Burau calculation did not cleanly close; relied on TSV to provide the correct $\Delta_{4_1}$.  This is a case where the Scout-recommended route had an implementation hiccup but TSV-Knot's ground-truth rescued it.
- [LIBRARY-CANDIDATE] "Alexander polynomial of $3_1$", "Alexander polynomial of $4_1$", "Knot determinant identity $\det(K) = |\Delta_K(-1)|$".
- [GEOMETRIC-INTUITION] Score self-assessment: 1/5.  Pure algebra.  No geometric content was used; matrix calculation and a numerical comparison.
