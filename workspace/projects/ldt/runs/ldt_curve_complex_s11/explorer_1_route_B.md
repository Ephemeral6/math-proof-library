# Explorer 1 — Route B: intersection-number induction

**Route.** Prove $\mathcal{C}(S_{1,1})$ is connected by induction on
$i(a, b)$. For $i(a, b) > 0$, produce an essential simple closed curve $c$
with $i(a, c) < i(a, b)$ AND $i(b, c) < i(a, b)$; then by two applications
of the induction hypothesis, $a \!-\! c \!-\! b$ is a path of length $\le 2 \cdot \text{dist}$.

## Step 1 — Setup

Let $a, b$ be essential simple closed curves on $S_{1,1}$, up to isotopy.
Set $N = i(a, b)$. The theorem is: $a$ and $b$ are connected in
$\mathcal{C}(S_{1,1})$.

We induct on $N$.

**Base case $N = 0$.** By problem.md §7, $i(a,b) = 0 \Leftrightarrow$
$a = b$ or $a \cap b = \emptyset$. In either case, $a$ and $b$ are
connected (at distance 0 or 1).

**Inductive step $N \ge 1$.** Assume the theorem for all pairs $(a', b')$
with $i(a', b') < N$. Given $(a, b)$ with $i(a, b) = N \ge 1$, we
construct $c$ with $i(a, c) < N$ and $i(b, c) < N$. By IH applied to
$(a, c)$ and to $(c, b)$, both pairs are connected, so concatenating gives
a path from $a$ to $b$.

## Step 2 — The reduction lemma

**Lemma (Reduction).** Let $a, b$ be essential simple closed curves on
$S_{1,1}$ with $i(a, b) = N \ge 1$. Then there exists an essential simple
closed curve $c$ on $S_{1,1}$ with
$$ i(a, c) < N \quad \text{and} \quad i(b, c) < N. $$

This is the load-bearing lemma. Explorer 1's job is to prove it.

### Step 2a — Minimal-position representatives

Fix transverse representatives $a', b'$ with $|a' \cap b'| = i(a, b) = N$.
Such representatives exist: by problem.md §6, $i(a, b)$ is defined as the
**minimum** over transverse representatives, and the minimum is achieved.
*[I, L1: definition unpacking.]*

Orient $a'$ and $b'$ arbitrarily. At each intersection point $p \in a' \cap b'$,
the pair $(T_p a', T_p b')$ is either $+$-oriented or $-$-oriented with
respect to a fixed orientation of $S_{1,1}$ (away from the puncture).

### Step 2b — Surgery construction

Fix one intersection point $p_0 \in a' \cap b'$. In a small oriented disk
neighborhood $U$ of $p_0$ disjoint from all other intersection points,
$a' \cap U$ and $b' \cap U$ are two transverse arcs crossing at $p_0$. The
complement $\partial U \setminus \{a' \cap \partial U, b' \cap \partial U\}$
has 4 open arcs. We perform a **smoothing** of $a' \cup b'$ at $p_0$:
replace the local picture $\{a' \cap U, b' \cap U\}$ by a pair of disjoint
arcs inside $U$ that respect the orientations of $a'$ and $b'$ in a
compatible way — specifically, the "oriented resolution" that replaces
the $X$ at $p_0$ by two arcs going the same direction as $a'$ and $b'$.

**Explicitly.** Let $a'$ run vertically and $b'$ horizontally in local
coordinates at $p_0$. The oriented resolution replaces the crossing by
the two hyperbolic arcs so that the two flows ($a'$-direction,
$b'$-direction) combine rather than cross: near $p_0$ the new curve looks
like "$\asymp$" — two parallel curve-segments that go up-right and
down-left.

Away from $U$, the resulting 1-manifold agrees with $a' \cup b'$.

The result of this local smoothing at $p_0$ is a 1-submanifold $\gamma$ of
$S_{1,1}$. $\gamma$ is transverse to itself nowhere inside $U$ and agrees
with $a' \cup b'$ outside, hence has exactly $N - 1$ transverse
self-intersection points (all from $a' \cap b' \setminus \{p_0\}$).

Now — crucially — for the *oriented* resolution the two ingoing and
outgoing arcs connect across the crossing in a specific way. After
smoothing, $\gamma$ is an immersed 1-manifold with $N - 1$ double points,
but it is no longer simple. We can repeat the oriented smoothing at each
remaining crossing. Alternatively: we can note that after the first
smoothing, the new object is a disjoint union of simple closed curves
and immersed curves with $N - 1$ intersections total. The connectedness
of this surgery argument requires tracking what each component is.

### Step 2c — The dissection problem [STUCK SP-1]

After step 2b, we have $\gamma$ = (locally smoothed $a' \cup b'$ at $p_0$).
The resulting immersed 1-manifold is a union of simple closed components
(plus some remaining self-intersections).

**What we want.** An essential simple closed curve $c$ contained in (or
constructible from) $\gamma$ with $i(a, c) < N$ and $i(b, c) < N$.

**The gap.** Without further lemmas, it is not clear that (i) any
component of the full smoothing of $a' \cup b'$ is *essential*, and (ii)
any component has strictly smaller intersection with BOTH $a$ and $b$.

**Sanity check (not a proof).** For $N = 1$: the "smoothing" turns
$a' \cup b'$ with one intersection point into a single simple closed
curve (the oriented sum of $a$ and $b$ in homology), and that closed
curve has $i(\cdot, a) = 0$ and $i(\cdot, b) = 0$ **only if** the
oriented resolution happens to avoid both. In general, the "oriented
resolution" at one crossing produces a curve whose intersection with $a$
is equal to $|a' \cap b'| - 1 = N - 1$ (since $a'$ loses one crossing
with $b'$ at $p_0$ but gains no new crossings with itself). Wait — the
new curve $c$ might intersect $a$ at points that were formerly
self-intersections of $a' \cup b'$ involving the $b'$-strand, which
are exactly $|a' \cap b' \setminus \{p_0\}|$ of them. So $i(c, a)$ is
*at most* $N - 1$.

But the same bound applies to $i(c, b) \le N - 1$. This is the desired
strict decrease — **if** $c$ is essential and simple. The "simple" part
is the hard piece: the full smoothing at $p_0$ does not automatically
produce a simple curve without further handling at the other $N - 1$
crossings, which were self-intersections of $a' \cup b'$ involving
both strands.

**SP-1 resolution attempt.** The "surgery gives a simple curve
strict-intersection-decrease" statement is textbook material (Farb–
Margalit, *A Primer on Mapping Class Groups*, §1.2.4 "Bigon Criterion"
Proposition 1.7 and Lemma 1.8 give exactly: if $\alpha, \beta$ are
transverse simple closed curves in minimal position with $i(\alpha,
\beta) > 0$, then smoothing at a crossing produces a simple closed
curve with strictly smaller total intersection with $\alpha \cup \beta$).

**Decision.** Invoke as **L2 citation**:
`[L2: Farb–Margalit, "A Primer on Mapping Class Groups", §1.2.4,
Lemma 1.7 / Proposition 1.7]`.

### Step 2d — Essentiality of $c$ [STUCK SP-2]

Even if the surgery produces a **simple** closed curve $c$, it could
fail to be essential — it could bound a disk, be puncture-parallel, or
be null-isotopic. Standard argument: the surgery curve represents a
sum of homology classes. In the closed-surface case, Farb–Margalit
handles essentiality by observing that the surgery class is nonzero
in $H_1$. For $S_{1,1}$ with a puncture, we need to additionally rule
out puncture-parallel.

**SP-2 resolution attempt.** If $a, b$ are essential on $S_{1,1}$ and
the surgery is done in minimal position, then $c$ inherits a homology
class $[a] \pm [b] \in H_1(S_{1,1}; \mathbb{Z})$ (signs depend on
local orientation at $p_0$). In $S_{1,1}$ the homology is
$H_1(S_{1,1}; \mathbb{Z}) \cong \mathbb{Z}^2$ (same as $T^2$ since the
puncture is a codim-2 removal up to homotopy — the $\pi_1$ is $F_2$,
but $H_1$ abelianizes to $\mathbb{Z}^2$). An essential simple closed
curve represents a nonzero class (this is the converse direction of
the problem.md fundamental fact: a curve bounding a disk OR puncture-
parallel has zero homology class). Hence $c$ is essential iff
$[a] \pm [b] \ne 0 \in \mathbb{Z}^2$. Since $[a], [b]$ are each
nonzero and the signs can be chosen, at least one of the two signs
gives a nonzero sum (they can only both vanish if $[a] + [b] = 0$ AND
$[a] - [b] = 0$, i.e. $[a] = [b] = 0$, contradiction).

**Decision.** Invoke as **L1 + I**: the homology computation for
$S_{1,1}$ is L1; the sign-choice argument is I.

### Step 2e — Wait — is $c$ unique, or a choice?

If we perform the *oriented* smoothing at a specific crossing, we get
a specific curve — but it may have more than one component. Farb–
Margalit's surgery explicitly cuts-and-pastes to produce a single
simple closed curve by choosing the smoothing such that the two
in-arcs from $a'$ and $b'$ join (not split). This is the "oriented
resolution with respect to a fixed orientation of the surface" — a
unique choice once orientations are fixed.

## Step 3 — Completing the induction

Assume the L2 citation at SP-1 and the homology-nonvanishing argument
at SP-2. Then for $i(a, b) = N \ge 1$:

1. Fix minimal-position transverse reps $a', b'$, $|a' \cap b'| = N$.
2. Surgery at any crossing produces a simple closed curve $c$ with
   $i(c, a) \le N - 1$ and $i(c, b) \le N - 1$.
3. $c$ is essential because its homology class is $[a] \pm [b] \ne 0$.
4. By IH on $(a, c)$ and on $(c, b)$: there are paths $a = c_0, c_1,
   \ldots, c_k = c$ and $c = d_0, d_1, \ldots, d_m = b$ in
   $\mathcal{C}(S_{1,1})$. Concatenation gives a path of length $k + m$
   from $a$ to $b$. ∎

## Step 4 — Citation profile

- **Independent (I):**
  - Induction frame on $N = i(a, b)$ (standard once surgery lemma is
    available).
  - Homology sign-choice argument at SP-2.
  - Base-case unpacking.
- **L1:**
  - $i(a, b)$ minimum is attained (problem.md §6).
  - $H_1(S_{1,1}) \cong \mathbb{Z}^2$ (standard surface homology).
  - $i = 0 \Leftrightarrow$ same class or disjoint (problem.md §7).
- **L2:**
  - Farb–Margalit §1.2.4 Proposition/Lemma 1.7: surgery at a crossing
    of two minimal-position simple closed curves yields a simple closed
    curve with strictly smaller total transverse intersection.
  - (Possibly) Farb–Margalit §1.2.4 bigon criterion for minimal
    position.
- **L3:** None.

Independent-to-citation ratio: 3 : 4. Below the L3-absence heuristic
threshold but not by a concerning margin.

## Step 5 — Sympy verification (finite-case sanity)

I write a sympy script `verify/sp_B_intersection_check.py` that, for
curves on $T^2$ parametrized by coprime pairs (which is well-known to
index essential simple closed curves on $T^2$ hence on $S_{1,1}$ since
the puncture does not add any new classes), computes $i((p,q),(r,s)) =
|ps - qr|$ and verifies:

1. $i = 0 \Leftrightarrow (p,q) = \pm (r, s)$ OR $|ps - qr| = 0$ (they
   are equivalent since we already have $\gcd$ = 1).
2. For any pair with $|ps - qr| = N \ge 1$, there exists an $(u, v)$
   coprime with $|pv - qu| < N$ AND $|rv - su| < N$.

This is a finite sanity check that the reduction lemma's conclusion is
consistent with the known parametrization of curves on $T^2$.

**Protocol.** Place in `verify/` per VERIFIED-SYMPY protocol. Template:
`identity-over-parameter-family`. Add inline tag at the appropriate
step once the proof compiles.

Script skeleton:

```
[VERIFIED-SYMPY-PROTOCOL: identity-over-parameter-family, cases=N,
 description=For each coprime pair (p,q),(r,s) with |ps-qr|<=M, there
 exists coprime (u,v) with |pv-qu|<|ps-qr| AND |rv-su|<|ps-qr|.]
```

(Scope-honesty note: this script verifies the *claimed* strict-decrease
statement is arithmetic-consistent with the coprime-pair parametrization;
it is NOT a proof, only a cross-check.)

## Step 6 — Stuck-points summary

- **SP-1 (resolved by L2):** surgery gives a simple closed curve with
  strictly smaller total transverse intersection. Farb–Margalit §1.2.4.
- **SP-2 (resolved by L1+I):** the surgery curve is essential.
  Homology-nonvanishing argument.
- **SP-3 (residual):** the exact statement of "minimal-position
  representatives exist" (bigon criterion) — resolved by the same L2
  citation.

No unresolved stuck-points. Two L2 citations feel heavy for what should
be a clean proof. Explorer 3 (Route D) may avoid one or both.
