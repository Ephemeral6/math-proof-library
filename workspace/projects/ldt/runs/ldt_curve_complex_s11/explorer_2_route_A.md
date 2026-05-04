# Explorer 2 — Route A: Farey-graph / combinatorial-model identification

**Route.** Identify $\mathcal{C}(S_{1,1})$ with an explicit combinatorial
graph on $\mathbb{Q} \cup \{\infty\}$, then prove connectedness of that
graph by elementary arithmetic.

## Step 1 — Setup

$S_{1,1} = (T^2 \setminus \{*\})/$ (isotopy). Let $\widetilde{T^2} =
\mathbb{R}^2$ be the universal cover of $T^2$, with the puncture $*$
lifting to the lattice $\mathbb{Z}^2$.

**Claim 1.** Isotopy classes of essential simple closed curves on $T^2$
biject with $\{(p, q) \in \mathbb{Z}^2 : \gcd(p, q) = 1\} / \pm$, via
$(p, q) \mapsto$ the image in $T^2$ of a straight line of slope $q/p$
through the origin (with $q/p = \infty$ when $p = 0$).

**Claim 2.** Under this bijection, deletion of one puncture $*$ from $T^2$
does not change the set of essential simple closed curve isotopy classes.
Rationale: any essential simple closed curve in $T^2$ has a representative
avoiding any given point (just push it off), and on $T^2 \setminus \{*\}$
the only additional "curve" is a small loop around $*$, which is
non-essential by problem.md §3. Conversely, an essential simple closed
curve on $S_{1,1}$ extends to an essential simple closed curve on $T^2$
by filling in the puncture.

**Claim 3.** For two essential simple closed curves with slopes
$\alpha_i = q_i/p_i$ ($i = 1, 2$, coprime representatives),
$$ i(\alpha_1, \alpha_2) = |p_1 q_2 - p_2 q_1|. $$

**Claim 4.** The "curve complex graph" then becomes the **Farey graph**
$\mathcal{F}$ with vertex set $\widehat{\mathbb{Q}} = \mathbb{Q} \cup \{\infty\}$
and edges $\{p/q, r/s\}$ whenever $|ps - qr| = 1$ (and $p/q \ne r/s$).

**Claim 5 (the theorem, translated).** $\mathcal{F}$ is connected.

We now prove Claims 1–5. Claims 1, 2, and 5 are clean. Claim 3 is the
heavy lift. Claim 4 follows from 3 and problem.md §7.

## Step 2 — Claim 1 (parametrization)

A **primitive** lattice vector is $(p, q) \in \mathbb{Z}^2$ with
$\gcd(p, q) = 1$, considered up to $\pm 1$ (i.e. $(p,q) \sim (-p,-q)$).
Equivalently, an element of the "projective" primitive lattice
$(\mathbb{Z}^2_{\text{prim}})/\pm$, which is naturally bijective with
$\widehat{\mathbb{Q}} = \mathbb{Q} \cup \{\infty\}$ via
$(p, q) \mapsto q/p$ (with $q/p = \infty$ iff $p = 0$, forcing
$(p, q) = (0, \pm 1)$).

**Proof that primitive lattice vectors index essential SCC on $T^2$.**
A simple closed curve $\gamma$ on $T^2$ lifts to a straight line segment
or a disconnected union of parallel segments in $\widetilde{T^2} =
\mathbb{R}^2$ (possibly after isotopy). If $\gamma$ is essential
(nontrivial in $\pi_1$), its $\pi_1$-class is a nonzero element of
$\mathbb{Z}^2$, and simplicity forces it to be primitive: a non-primitive
class $(p, q) = d (p_0, q_0)$ with $d > 1$ lifts to $d$ parallel lines
per fundamental domain, which cannot be the lift of a *simple* curve.

Conversely, given $(p, q)$ primitive, the image of the line
$y = (q/p) x$ in $T^2$ is a simple closed curve of slope $q/p$,
essential because it represents the nonzero homology class $(p, q)$.

The $\pm$-quotient is because $\gamma$ and $\gamma^{-1}$ (reversed
orientation) are isotopic as unoriented curves.

**Tag:** L1 (classical fact about lattices and $T^2$). *[Reference:
Farb–Margalit §1.2.3, but this is genuinely textbook; problem.md's
allowed-background §3 implicitly grants $\pi_1(T^2) = \mathbb{Z}^2$.]*

## Step 3 — Claim 2 (puncture is invisible)

$S_{1,1} = T^2 \setminus \{*\}$.

**Direction 1:** an essential SCC $\gamma$ on $S_{1,1}$ extends to an
essential SCC on $T^2$: include $\gamma \hookrightarrow T^2$.
Essentiality on $S_{1,1}$ means $\gamma$ does not bound a disk in $S_{1,1}$
and is not puncture-parallel. In $T^2$, the puncture is filled in:
$\gamma$ either (a) is already essential in $T^2$, OR (b) bounds a disk
containing $*$. In case (b), $\gamma$ would be puncture-parallel in
$S_{1,1}$, contradiction.

**Direction 2:** an essential SCC $\gamma$ on $T^2$, after isotopy, avoids
any given point. So $\gamma \subset S_{1,1}$. Essentiality is preserved
because $\gamma$ still does not bound a disk in $S_{1,1}$ (it does not in
$T^2$, and the inclusion $S_{1,1} \hookrightarrow T^2$ is $\pi_1$-
injective). Not puncture-parallel because the puncture is on the other
side of $\gamma$ in $T^2$.

**Tag:** I (this is a careful unpacking that is project-original at this
level of explicitness, though the underlying ideas are L1).

## Step 4 — Claim 3 (intersection number = $|ps - qr|$)

**Statement.** For primitive pairs $(p_1, q_1), (p_2, q_2)$ defining
essential SCCs $\alpha_1, \alpha_2$ on $T^2$,
$$ i(\alpha_1, \alpha_2) \;=\; |p_1 q_2 - p_2 q_1|. $$

**Proof.** The straight-line representatives $\alpha_1, \alpha_2$ of
slopes $q_1/p_1, q_2/p_2$ meet transversely in $T^2$ when
$(p_1, q_1) \ne \pm (p_2, q_2)$ (different slopes, or different signs
which we have quotiented out). The number of intersection points of
two straight lines on $T^2$ equals $|\det \binom{p_1\ q_1}{p_2\ q_2}| =
|p_1 q_2 - p_2 q_1|$: this is the absolute value of the determinant of
the $2 \times 2$ matrix formed by the homology classes.

Indeed, for any pair of primitive classes $v_1, v_2 \in \mathbb{Z}^2$,
the image of $v_1$ in $T^2$ is a torus $T_1 \cong S^1$, likewise $T_2$,
and $|T_1 \cap T_2| = |\det(v_1, v_2)|$ counted with multiplicity — but
since the $v_i$ are primitive, all intersections are transverse
single-points (no multiplicities).

**Minimality of $|\det|$.** Could there be isotopic representatives
with fewer intersections? No: the algebraic intersection number
$\hat{i}(\alpha_1, \alpha_2) := \langle [\alpha_1], [\alpha_2] \rangle_{T^2}$
is a homology invariant and equals $\pm \det = \pm(p_1 q_2 - p_2 q_1)$.
The geometric intersection number $i$ satisfies $i \ge |\hat{i}|$, and
the straight-line representatives realize $|\hat{i}|$, hence $i =
|\det|$.

(On $T^2$ specifically, $|\hat{i}|$ coincides with $i$ for essential SCCs
because of the linear geodesic representatives. This is a special
feature of the torus.)

**Tag:** L1 (homology intersection = algebraic determinant, classical);
I (the upgrade from $\hat{i} = \det$ to $i = |\det|$ via straight-line
minimality).

## Step 5 — Claim 4 (adjacency in $\mathcal{C}(S_{1,1})$ $\Leftrightarrow$ Farey-edge)

Two distinct classes $\alpha_1, \alpha_2$ span an edge in
$\mathcal{C}(S_{1,1})$ iff $i(\alpha_1, \alpha_2) = 0$ and $\alpha_1 \ne
\alpha_2$ — **but** by problem.md §7, $i = 0$ forces $\alpha_1 = \alpha_2$
or disjoint, and for *distinct* classes "disjoint" is the only option.

Wait — by Claim 3, if $\alpha_1 \ne \alpha_2$ (distinct primitive
classes), then $|p_1 q_2 - p_2 q_1| \ne 0$, so $i(\alpha_1, \alpha_2) \ne 0$.

**So $\mathcal{C}(S_{1,1})$ has NO edges by this reading?!**

[STUCK SP-A1] — Something is wrong. Re-examine: the problem.md
definition of "edge" is "$a, b$ can be realized disjointly" $\Leftrightarrow i(a,b) = 0$
AND $a \ne b$. But on $T^2$, two straight lines of *different* slopes
always meet (on the torus, two primitive-class curves always have
$i > 0$). So either (a) there are no edges in $\mathcal{C}(T^2)$, or (b)
the curve complex of $T^2$ is a different object (perhaps with the
disjointness relaxed).

**Diagnosis.** On $T^2$, the definition of the curve complex is usually
modified: the disjointness condition $i(a, b) = 0$ (for $a \ne b$) is
replaced by $i(a, b) = 1$, because the "usual" condition has no edges.
**But problem.md explicitly defines edges as $i(a, b) = 0$**. The
problem.md definition gives a DISCONNECTED graph on $T^2$ (all vertices
are isolated).

**Wait.** Let me recheck — problem.md is about $S_{1,1}$, not $T^2$. The
puncture changes things. In $S_{1,1}$, a pair of curves that would meet
transversely in one point on $T^2$ might be isotoped to meet at the
puncture (which isn't there), leaving them disjoint in $S_{1,1}$ $\setminus \{*\}$.

**Refined claim.** On $S_{1,1}$, $i(\alpha_1, \alpha_2) = |p_1 q_2 - p_2 q_1|
- \delta$, where $\delta$ accounts for intersection points that can be
"pushed through the puncture".

But simple closed curves on $S_{1,1}$ cannot cross the puncture (it is
missing). So the intersection number on $S_{1,1}$ cannot decrease by
$1$ via the puncture — it stays $|p_1 q_2 - p_2 q_1|$.

**[DEEPER STUCK POINT SP-A2].** Under the problem.md definition of
$\mathcal{C}(S_{1,1})$, the graph appears disconnected with all vertices
isolated — because by Claim 3 the intersection number is always
$|p_1 q_2 - p_2 q_1| \ne 0$ for distinct classes.

**But** the problem statement asserts $\mathcal{C}(S_{1,1})$ is
**connected**. So either Claim 3 is wrong, or the definition of
"essential" or "disjoint" I am using is wrong.

**Re-check.** Look at the meridian $\mu = (1, 0)$ and longitude
$\lambda = (0, 1)$. $|p_1 q_2 - p_2 q_1| = |1 \cdot 1 - 0 \cdot 0| = 1$,
not $0$. So $\mu$ and $\lambda$ are **not** disjoint under problem.md's
definition — they intersect in one point.

**But on $S_{1,1}$** specifically, the meridian and longitude can be
isotoped so that their one intersection point on $T^2$ is *exactly the
puncture*, which is not in $S_{1,1}$. Hence in $S_{1,1}$, the
representatives miss each other — i.e. they are "disjoint" in the
$S_{1,1}$ sense.

**This is the key insight I was missing.** On $S_{1,1}$, the
intersection number differs from the $T^2$ intersection number: it can
decrease by 1 if the intersection points can be moved to the puncture.

**Refined Claim 3'.** For $S_{1,1}$:
$$ i(\alpha_1, \alpha_2)_{S_{1,1}} = \begin{cases} |p_1 q_2 - p_2 q_1| & \text{if } |p_1 q_2 - p_2 q_1| \ge 2, \\ 0 & \text{if } |p_1 q_2 - p_2 q_1| = 1. \end{cases} $$

**Is this right?** Intuition: with one puncture, one intersection point
can be pushed off through the puncture (no — the puncture is just
removed from the surface, it doesn't absorb anything). The actual
mechanism: if two curves on $T^2$ meet at a single point $p$, we can
isotope them on $S_{1,1} = T^2 \setminus \{*\}$ so that their
intersection point coincides with the puncture... but the puncture is
NOT on the surface, so "coincides with the puncture" means "passes
arbitrarily close to the puncture". After this isotopy, the two curves
still intersect: isotoping them so both go "through" the same hole
doesn't separate them. I'm confusing myself.

[REALLY STUCK SP-A3] — **I cannot derive the precise intersection-
number formula on $S_{1,1}$ without external L2 input.** The standard
claim ($\mathcal{C}(S_{1,1}) = $ Farey graph $\Leftrightarrow i = 1$) is
what the pre-existing seed dictionary §3.3 asserts but does not derive.
I need to know which intersection-number condition produces the edges
of $\mathcal{C}(S_{1,1})$ under the problem.md definition.

**Hypothesis.** Maybe problem.md is implicitly using a curve-complex
convention that differs from the standard one on $S_{1,1}$. Re-read
problem.md §8: "Two distinct vertices $a, b$ are connected by an edge
iff $a \cap b = \emptyset$ (equivalently, iff $i(a, b) = 0$ and
$a \ne b$)." So under problem.md's definition, an edge requires $i = 0$.

**If my Claim 3 ($i(\alpha, \beta)_{S_{1,1}} = |\det|$) is correct, the
theorem is FALSE** (the graph has no edges).

So either Claim 3 is wrong for $S_{1,1}$, or the problem statement is
non-standard.

**Recovery attempt.** On $S_{1,1}$, can two distinct-slope straight-line
curves be isotoped to be disjoint? On $T^2$, no (they must intersect in
$|\det|$ points). On $S_{1,1}$, the only move available not on $T^2$
is "push an arc through a region containing the puncture". But the
puncture is a single point with a small open neighborhood, and that
neighborhood is contractible, so you cannot eliminate a topological
intersection by pushing past it — you can only move the intersection
point around.

**This is the right reasoning:** topological intersection points on
$S_{1,1}$ between two simple closed curves lift exactly to topological
intersection points on $T^2$. Removing a single point doesn't eliminate
intersections. So $i(\alpha, \beta)_{S_{1,1}} = i(\alpha, \beta)_{T^2} =
|\det|$, confirming Claim 3.

**If so, $\mathcal{C}(S_{1,1})$ under problem.md's definition has no
edges** — and the theorem fails. But that contradicts the stated
theorem.

**ABORT ROUTE A.** Either:
(i) The problem definition uses a different edge relation than stated,
(ii) my Claim 3 is wrong (but I've given a clean argument for it that
matches the $T^2$ case),
(iii) the puncture really does decrease $i$ somehow (but I can't see
how).

### Self-diagnosis

I believe Claim 3 is correct on the topological level: $i$ on $S_{1,1}$
between distinct-slope primitive-class curves equals $|\det|$, same as on
$T^2$. This contradicts the target theorem under problem.md's strict
$i = 0$ edge definition.

**Possibility I missed.** The problem statement's edge definition might
be *loose* — in much of the literature, $\mathcal{C}(S_{1,1})$ is
defined with edges for $i = 1$ (Farey graph), because $i = 0$ gives no
edges. Problem.md may be implicitly using the Farey-graph convention
despite what §8 says: perhaps the $i(a,b) = 0$ is a typo for
"$a, b$ realizable disjointly" which on $T^2$-like surfaces is a vacuous
condition, and the authors meant $i(a, b) = 1$.

But Explorer 2 cannot rewrite the problem. **Taking problem.md
literally, I conclude my Route A cannot resolve the apparent
contradiction, and I must stop with a STUCK-POINT tag.**

## Step 6 — Stuck-points

- **SP-A1:** on $T^2$, the "disjointness" relation $i = 0$ is only
  satisfied by equal classes. (The Farey graph uses $i = 1$ edges,
  but problem.md defines edges by $i = 0$.)
- **SP-A2:** on $S_{1,1}$, my derivation gives $i = |\det|$ same as
  on $T^2$, hence $\mathcal{C}(S_{1,1})$ under problem.md's definition
  has no edges and is not connected.
- **SP-A3 (deepest):** resolving the tension requires either
  (i) a proof that $i$ on $S_{1,1}$ differs from $T^2$ by 1 in a specific
  case (which I cannot prove without L2 input), or
  (ii) problem.md using a different edge convention than stated.

## Step 7 — Verdict on Route A

**PARTIAL / STUCK.** Route A as naively implemented (Farey-graph
identification) produces a definitional contradiction with problem.md
§8's strict $i = 0$ edge rule. Explorer 2 cannot resolve this from
first principles.

Recommendation: Explorer 2 output forwarded to Judge with
`[STEP-STUCK SP-A3]` explicitly flagged. Judge should decide whether
Route A's identification of curves with rationals has value even if
the naive edge-rule is wrong, or whether Route A should be rejected.

**If the problem.md definition is correct and $i(\mu, \lambda)_{S_{1,1}}
= 1 \ne 0$**, then the theorem as stated requires one of two resolutions:

1. $i(\mu, \lambda)_{S_{1,1}} = 0$ actually (I am wrong, they can be
   disjoint), OR
2. problem.md's theorem is nonstandard.

## Step 8 — Citation profile (partial)

- **I:** Claims 1–3 partial arguments.
- **L1:** $T^2$ lattice / homology facts; $i \ge |\hat{i}|$.
- **L2:** None explicitly; but implicit call on Farb–Margalit §1.2.3
  would happen at Claim 3 if the proof were completed.
- **L3:** None.

## Post-hoc reflection

Explorer 2 has found a definitional issue in the problem that Explorer
1 did not notice. If Explorer 1 is right that "surgery at a crossing
produces a simple closed curve with smaller $i$", then Explorer 1's
argument still works if we interpret "connected in $\mathcal{C}(S_{1,1})$"
via the literature's *actual* $i = 1$ edge convention, not problem.md's
stated $i = 0$. But Explorer 1 did not test this — neither explorer
checked that $\mu, \lambda$ are actually disjoint under the literal
problem.md definition.

Forwarding to Judge with strong recommendation to examine this.
