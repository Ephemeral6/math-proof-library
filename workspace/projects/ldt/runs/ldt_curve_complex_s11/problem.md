# Connectedness of the curve complex of the once-punctured torus

## Source

Low-dimensional-topology workspace problem. Difficulty: **moderate (B-to-A class)**.
Attempt a direct proof.

## Allowed background

1. $S_{1,1}$ denotes the once-punctured torus: the topological space obtained from the
   torus $T^2 = \mathbb{R}^2/\mathbb{Z}^2$ by removing one point (equivalently, marking
   one point and working up to homeomorphism fixing that marked point).

2. A **simple closed curve** on $S_{1,1}$ is the image of a continuous injective map
   $S^1 \to S_{1,1}$.

3. A simple closed curve $\gamma$ is **essential** if it is not isotopic (in $S_{1,1}$)
   to any of the following "trivial" possibilities:
   - a point (i.e. $\gamma$ does not bound a disk in $S_{1,1}$);
   - a loop encircling only the puncture.

   Equivalently: $\gamma$ is essential iff it is nontrivial in $\pi_1(S_{1,1})$ and is
   not freely homotopic into an arbitrarily small neighborhood of the puncture.

4. **Isotopy.** Two simple closed curves $\gamma_0, \gamma_1$ on $S_{1,1}$ are
   *isotopic* if there is a continuous family $\gamma_t$ ($t \in [0,1]$) of simple
   closed curves interpolating between them. We always work with isotopy classes of
   essential simple closed curves; the letters $a, b, c$ denote such classes.

5. **Disjointness of isotopy classes.** Two isotopy classes $a, b$ are *disjoint*,
   written $a \cap b = \emptyset$, iff there exist representatives $a', b'$ of $a, b$
   respectively with $a' \cap b' = \emptyset$ as subsets of $S_{1,1}$.

6. **Geometric intersection number.** For two isotopy classes $a, b$ of essential
   simple closed curves, define
   $$ i(a, b) := \min\{|a' \cap b'| : a' \in a,\; b' \in b,\; a' \pitchfork b'\}, $$
   i.e. the minimum number of transverse intersection points over all transverse
   representatives. This is a non-negative integer depending only on the isotopy
   classes.

7. **Fundamental fact about $i(a, b)$** (you may use without proof):
   $$ i(a, b) = 0 \iff a = b \text{ as isotopy classes, or } a \text{ and } b \text{ are disjoint}. $$
   (In other words, the only way to get zero transverse intersections is to either
   be the same isotopy class or to be realizable disjointly.)

8. **The curve complex $\mathcal{C}(S_{1,1})$.** Vertices are isotopy classes of
   essential simple closed curves on $S_{1,1}$. Two distinct vertices $a, b$ are
   connected by an edge iff $a \cap b = \emptyset$ (equivalently, iff $i(a, b) = 0$
   and $a \ne b$). Higher simplices are not needed for this problem — only the
   1-skeleton matters.

## Theorem (to be proved)

$\mathcal{C}(S_{1,1})$ is connected.

**Equivalent restatement.** For any two essential simple closed curves $a, b$ on
$S_{1,1}$ (considered up to isotopy), there exist a positive integer $n$ and a
sequence of isotopy classes $a = c_0, c_1, c_2, \ldots, c_n = b$ such that, for
each $0 \le i < n$, $c_i \cap c_{i+1} = \emptyset$.

(If $a = b$, take $n = 0$; if $a \ne b$ and $a \cap b = \emptyset$, take $n = 1$
with $c_0 = a, c_1 = b$. The substance of the theorem is the case $i(a, b) > 0$.)

## Difficulty

moderate (B-to-A class). This is a curve-complex-subdomain problem; attempt a
direct proof. The proof should be symbolic / rigorous in the combinatorial-
topology sense; diagrammatic reasoning is permissible but must be backed up by
an explicit construction (e.g. exhibiting a specific curve disjoint from a given
pair, or showing a quantity strictly decreases under a move).

## Sympy guidance

Problem-specific sympy verification is **encouraged where applicable**. For
example, if the proof parametrizes curves by some discrete invariant (a pair of
integers, a representative in $\pi_1$, etc.), a finite-case sympy script can
double-check that the proof's combinatorial/arithmetic claims hold across a
range of small parameters. The final proof must nonetheless be symbolic and
cover all cases — sympy may only certify a finite parameter range.

Any sympy script must follow the VERIFIED-SYMPY protocol at
`~/.claude/skills/math-verifier/VERIFIED_SYMPY_PROTOCOL.md`.

## Small-case hints (sanity checks the pipeline may use)

Explicit named curves on $S_{1,1}$ the pipeline may wish to test the claim
against, as a sanity check:

- The "meridian" $\mu$: the image of the $x$-axis on $T^2 = \mathbb{R}^2/\mathbb{Z}^2$
  (after removing a puncture away from this line).
- The "longitude" $\lambda$: the image of the $y$-axis.
- A "diagonal" $\delta$: the image of the line $y = x$.

The pipeline may verify the theorem for small pairs $(a, b)$ chosen from such
named curves and count intersection numbers to check that any construction
proposed agrees with direct computation.

## Scope note

- The theorem is about $S_{1,1}$ only. No claim about other surfaces.
- Only connectedness of the 1-skeleton is required. Diameter, hyperbolicity,
  higher-dimensional-simplex structure, or global curvature are **not** in
  scope for this problem.
