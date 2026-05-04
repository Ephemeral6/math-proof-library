# Scout — route survey for $B_2$ bracket recursion

## Problem restatement
Derive $B_{n+2} = (A - A^{-3}) B_{n+1} + A^{-2} B_n$ for the Kauffman bracket of $\widehat{\sigma_1^n}$ in $B_2$, with $B_0 = -A^2-A^{-2}$, $B_1 = -A^3$.

## TSV probe results

- `[CALL:tsv-knot, knot=closure_sigma1_2]` → `[NOT-IN-TABLE]` (table covers 7 named knots: unknot, trefoil, figure-8, $5_1$, $5_2$, Hopf link, $(2,5)$-torus).
- `[CALL:tsv-knot, knot=trefoil, invariant=kauffman_bracket]` → `-A^5 - A^{-3} + A^{-7}` with `[VERIFIED: high]` — this equals $B_3$.
- `[CALL:tsv-knot, knot=hopf, invariant=kauffman_bracket]` → `-A^4 - A^{-4}` with `[VERIFIED: high]` — equals $B_2$.

TSV confirms $B_2$ and $B_3$ numerically; cannot directly supply the recursion.

## Library probe

Search `proofs/library/low-dimensional-topology/`:
- `knot-invariants/kauffman-bracket-axioms.md` — axioms (A, crossing resolution, $d = -A^2-A^{-2}$).  Directly usable.
- `knot-invariants/jones-trefoil-right.md` — computation of $V_{3_1}$.  Does NOT contain TL machinery.
- `knot-invariants/jones-figure-eight.md` — computation of $V_{4_1}$.  Likewise.
- No proof in library uses Temperley–Lieb algebra or Markov trace. TL is not in our library.

## Routes considered

### Route A — Direct bracket skein expansion on $\sigma_1^{n+2}$

Write $\sigma_1^{n+2}$ as a diagram with $n+2$ crossings. Apply Kauffman skein at one crossing (say the top one):
$$\langle \widehat{\sigma_1^{n+2}} \rangle = A \langle \widehat{\sigma_1^{n+1}} \cdot e \rangle + A^{-1} \langle \widehat{\sigma_1^{n+1}} \cdot U \rangle,$$
where $e$ is the identity tangle and $U$ is the cup-cap tangle.

Problem: $\widehat{\sigma_1^{n+1}} \cdot U$ is not itself of the form $\widehat{\sigma_1^k}$, so the skein does not close to a recursion on $B_n$ alone. Need to track pairs $(B_n, C_n)$ where $C_n$ is some other quantity. Possible but messy — bookkeeping-heavy.

### Route B — Temperley–Lieb algebra + Markov trace (preferred)

Represent $\sigma_1 \mapsto x := A \cdot 1 + A^{-1} U \in TL_2$, where $TL_2 = \langle 1, U \mid U^2 = dU \rangle$, $d = -A^2-A^{-2}$. Bracket of closure = Markov trace: $B_n = \text{tr}(x^n)$ with $\text{tr}(1) = d$, $\text{tr}(U) = 1$.

Compute $x^2$ in $TL_2$ and find scalars $\alpha, \beta$ with $x^2 = \alpha x + \beta \cdot 1$. Then $x^{n+2} = \alpha x^{n+1} + \beta x^n$ and, by linearity of the trace, $B_{n+2} = \alpha B_{n+1} + \beta B_n$.

Expected: $\alpha = A - A^{-3}$, $\beta = A^{-2}$.

Length: ~15 steps, mostly algebra in a 2-dim algebra. Geometric content: LOW (this is algebra + a trace), but unavoidable for this recursion.

### Route C — Generating function / characteristic polynomial of $\begin{pmatrix}A & A^{-1} \\ A^{-1} & A^{-1}d\end{pmatrix}$

Same underlying math as Route B but packaged as linear algebra. No essential difference.

## Selection

**Route B (TL + Markov trace).** Route A is possible but less clean; Route C is equivalent. Route B also has the virtue of explaining the recursion structurally (via Cayley–Hamilton in a 2-dim algebra).

## Risks / expected Auditor hits

1. Markov trace formula $(\text{tr}(1) = d, \text{tr}(U) = 1)$ is not in our library — will need `[REF:external]` to Kauffman 1987 or Jones 1985.
2. The assignment $\sigma_1 \mapsto A + A^{-1}U$ is the standard Kauffman-bracket-at-a-crossing rule applied to the braid generator; Explorer should derive it rather than cite it.
3. Base case $B_1 = -A^3$ requires checking that $\widehat{\sigma_1}$ as a 2-braid closes to an unknot-with-one-twist; specifically the writhe $w = 1$ gives the $-A^3$ multiplier via Kauffman's framing formula.  Potential gap: Explorer may elide this.
4. Convention: "plat closure" vs. "standard braid closure" of $\sigma_1^n$ in $B_2$ give different links for odd $n$. Scout assumes the standard trace/Markov closure. Must be stated.
