# Explorer 3 — Route D: minimal-position / bigon-criterion surgery

**Date.** 2026-04-21.
**Route.** D (geometric specialization of B).
**Goal.** Produce an explicit surgery construction (not an abstract
strict-decrease argument) proving $\mathcal{C}(S_{1,1})$ is connected.

## Step 0 — Relationship to Route B

Route B (Explorer 1) inducts on $N = i(a,b)$ by invoking a surgery lemma
[L2: Farb–Margalit §1.2.4] to produce $c$ with $i(c,a), i(c,b) < N$. Route
D differs in that the surgery is specified *explicitly* on minimal-position
representatives, not imported as a citation. If successful, Route D
reduces (or eliminates) Route B's reliance on the external lemma.

## Step 1 — Minimal-position setup

**Definition (used throughout).** A transverse pair $(a', b')$ with $a' \in a$,
$b' \in b$ is in **minimal position** if $|a' \cap b'| = i(a,b)$.

**Minimal-position existence [L2: Farb–Margalit Proposition 1.6].** Every
pair of isotopy classes admits minimal-position representatives. (This is
the classical "geodesic representatives exist" statement in surface
topology.)

**Bigon criterion [L2: Farb–Margalit Proposition 1.7].** Transverse
representatives $(a', b')$ are in minimal position iff no connected
component of $S_{1,1} \setminus (a' \cup b')$ is an embedded **bigon** —
a disk whose boundary is the union of one arc of $a'$ and one arc of $b'$
meeting at two points.

Route D will use the bigon criterion only *negatively*: after surgery
produces a new curve $c'$, we need that $c'$ can be isotoped to minimal
position with both $a$ and $b$ and that the resulting intersection numbers
are strictly smaller. Farb–Margalit's framing does this surgically — and
I will attempt it below.

## Step 2 — Explicit surgery at a single crossing

Fix minimal-position representatives $(a', b')$ with $|a' \cap b'| = N = i(a,b) \ge 1$.
Pick a point $p \in a' \cap b'$. In a small disk neighborhood $D_p$ around
$p$, $a'$ and $b'$ appear as two transverse arcs crossing once.

**Resolution choice.** Among the two possible orientation-compatible
resolutions at $p$ (replacing the crossing $\times$ by either $)($ or the
other smoothing), a single choice — the one compatible with a coherent
orientation of $a' \cup b'$ — produces a 1-manifold
$$a' \#_p b' := (a' \cup b' \setminus \times_p) \cup )(_p$$
which is a disjoint union of simple closed curves.

**Key counting identity.** $|(a' \#_p b') \cap a'| = |a' \cap b'| - 1 = N - 1$
and similarly $|(a' \#_p b') \cap b'| = N - 1$. (The crossing at $p$ was
consumed; no new crossings are created, because the resolution is local.)

**Isotopy-class picture.** The resolution $a' \#_p b'$ is in general a
disjoint union $c'_1 \sqcup c'_2 \sqcup \cdots \sqcup c'_k$ of simple closed
curves on $S_{1,1}$; each $c'_j$ may or may not be essential.

## Step 3 — At least one component is essential

**Claim D3.** At least one component $c'_j$ of $a' \#_p b'$ is essential
on $S_{1,1}$.

**Proof.** Consider the homology class $[a' \#_p b'] \in H_1(S_{1,1}; \mathbb{Z})$.
Under the coherent-orientation resolution, $[a' \#_p b'] = [a'] + \epsilon[b']$
for some $\epsilon \in \{+1, -1\}$ depending on orientation convention
(this is standard; it is the homology of the "band sum"). Since $a$ and
$b$ are essential classes, $[a'], [b']$ are both nonzero primitive in
$H_1(S_{1,1}) \cong \mathbb{Z}^2$ (the essentiality-vs-homology is a
separate claim, see D3.1 below). We split on two subcases:

**(D3a) $[a'] + \epsilon[b'] \ne 0$.** Then $a' \#_p b'$ has nonzero total
homology class, and since homology is additive over components, at least
one component $c'_j$ has $[c'_j] \ne 0$. A simple closed curve with
nontrivial homology class cannot bound a disk (disks are null-homologous)
and cannot be puncture-parallel (the puncture-loop is null-homologous in
$S_{1,1}$: it bounds a punctured disk, hence represents $0 \in H_1(S_{1,1})$
since we've deleted the puncture). Hence $c'_j$ is essential.

**(D3b) $[a'] + \epsilon[b'] = 0$.** Then $[a'] = -\epsilon[b']$, i.e.
$a$ and $b$ are homologous (or anti-homologous) in $H_1(S_{1,1})$. This
case needs separate handling. Flip the resolution choice: the opposite
resolution $a' \#'_p b'$ gives homology class $[a'] - \epsilon[b'] = 2[a']$,
which is nonzero (since $[a'] \ne 0$). Apply the D3a argument to the
flipped resolution.

**Either way, at least one component is essential.** $\square$

**Subclaim D3.1 (essential $\Rightarrow$ nonzero primitive in $H_1$).**
Let $\gamma$ be an essential simple closed curve on $S_{1,1}$. Then
$[\gamma] \ne 0$ in $H_1(S_{1,1}; \mathbb{Z}) \cong \mathbb{Z}^2$.

**Proof sketch.** If $[\gamma] = 0$, then $\gamma$ bounds a 2-chain in
$S_{1,1}$. A simple closed curve on a surface bounds iff it separates
(classification of surfaces + surgery). Since $S_{1,1}$ is a
once-punctured torus, a separating simple closed curve cuts it into two
pieces whose Euler-characteristic sum must equal $\chi(S_{1,1}) = -1$.
The only options are $\chi \in \{-1, 0\} \cup \{0, -1\}$, and a piece of
$\chi = 0$ with boundary is either an annulus or a once-punctured disk.
The once-punctured-disk case puts $\gamma$ puncture-parallel (excluded).
The annulus case makes $\gamma$ isotopic to its other boundary; but then
$\gamma$ is isotopic to a boundary of a disk-with-handle (i.e. to a disk
boundary) — null-homotopic — excluded. Hence essential $\gamma$ has
$[\gamma] \ne 0$. $\square$

(This is essentially the same homology argument Explorer 1 used in Route B,
repackaged for Claim D3b. No new L2 citation needed.)

## Step 4 — Intersection counts after surgery

Let $c'_j$ be the essential component from Step 3. I want to show
$i(c'_j, a) < N$ and $i(c'_j, b) < N$.

**Transverse count.** Since $c'_j \subset a' \#_p b'$ as a subset, and
$|(a' \#_p b') \cap a'| = N - 1$, we have $|c'_j \cap a'| \le N - 1$.
Similarly $|c'_j \cap b'| \le N - 1$. So the *transverse* count with the
specific representatives $a', b'$ is $\le N - 1$.

**Minimal (isotopy-class) count.** $i(c'_j, a) \le |c'_j \cap a'| \le N - 1 < N$,
and same for $b$. This inequality is a direct consequence of the
definition of $i$ as a minimum over transverse representatives.

Hence $i(c'_j, a), i(c'_j, b) \le N - 1 < N$, as required.

## Step 5 — Inductive assembly

We have now:

- **Base case $N = 0$:** problem.md §7. Either $a = b$ (distance 0) or
  $a \cap b = \emptyset$ (distance 1).

- **Inductive step $N \ge 1$.** Given $a, b$ with $i(a, b) = N$, Steps 2–4
  produce an essential isotopy class $c = [c'_j]$ with $i(c, a), i(c, b) \le N-1$.
  By strong induction, $c$ is connected to $a$ in $\mathcal{C}(S_{1,1})$
  and $c$ is connected to $b$ in $\mathcal{C}(S_{1,1})$. Concatenating
  the two paths gives an $a$-to-$b$ path.

This proves $\mathcal{C}(S_{1,1})$ is connected. $\square$

## Step 6 — L-depth accounting

| Statement used | L-tier | Source |
|----------------|--------|--------|
| Problem definitions $S_{1,1}$, essential, $i(a,b)$, edge rule | Given (problem.md §§1–8) | problem.md |
| Fundamental fact $i = 0 \iff a = b \vee a \cap b = \emptyset$ | Given (problem.md §7) | problem.md |
| $H_1(S_{1,1}) \cong \mathbb{Z}^2$ | L1 | classification of surfaces; standard undergrad |
| Essential ⇒ nonzero primitive in $H_1$ (D3.1) | L1 derived in-line | Step 3 |
| Minimal-position representatives exist | **L2** | Farb–Margalit, *A Primer on Mapping Class Groups*, Proposition 1.6 |
| Bigon criterion | **L2** | Farb–Margalit, Proposition 1.7 |
| Homology of resolution $[a' \#_p b'] = [a'] \pm [b']$ | L1 | standard (band-sum homology) |
| Resolution is locally defined; preserves transversality elsewhere | I (in-line) | Step 2 |

L2 citations: **2** (both Farb–Margalit standard references, same source).

Route B cited the same L2s. **Route D does not reduce citation count**, but
it makes the surgery *explicit* (the resolution is specified as
$a' \#_p b'$, not abstracted behind a black-box lemma). For Auditor
purposes this may be preferable.

## Step 7 — Sympy sanity hooks

Same as Route B: the Route D argument's combinatorial content is
entirely captured by "after single-crossing resolution, intersection
drops by 1". A sympy check on the parametrization $(p,q) \mapsto p\mu + q\lambda$
can confirm that for minimal-position representatives on the universal
cover $\tilde S_{1,1} \simeq \mathbb{R}^2 \setminus \mathbb{Z}^2$, the
number of mod-$\mathbb{Z}^2$ intersections of lines of slope $p_1/q_1$ and
$p_2/q_2$ equals $|p_1 q_2 - p_2 q_1|$, so the "drop by 1 per resolution"
claim is consistent.

I propose (but do not execute here — that is Fixer's job if needed):

- `verify/sp_D_minimal_intersection.py`: enumerate coprime pairs with
  $|p_1 q_2 - p_2 q_1| \le 6$; for each pair, compute a coprime $(r,s)$ with
  $|p_1 s - r q_1| \le |p_1 q_2 - p_2 q_1| - 1$ AND $|p_2 s - r q_2| \le |p_1 q_2 - p_2 q_1| - 1$;
  confirm such $(r,s)$ always exists (this is the mediant construction).
  Template ID: **identity-over-parameter-family** (4 cases × 4 cases,
  bounded by $|det| \le 6$ gives $O(100)$ check rows).

This is a *cross-check*, not a *proof*. The symbolic argument in
Steps 2–5 does not depend on this sympy block.

## Step 8 — Comparison with Route B and stuck-point commentary

Against Route B (Explorer 1):
- Same L2 citations; same proof skeleton (strong induction on $i(a,b)$).
- Route D makes the key "surgery lemma" explicit ($a' \#_p b'$ = coherent
  resolution), so Fixer/Auditor has fewer places to audit.
- Route D adds a **homology-of-resolution** step (Step 3) which makes the
  essentiality argument more transparent than Route B's direct appeal to
  $[c] = [a] \pm [b]$.

Against Route A (Explorer 2, STUCK):
- Route D does **not** attempt to parametrize curves. It uses the
  homology class $[a] \in H_1(S_{1,1}; \mathbb{Z})$ but only as a
  non-vanishing invariant, not as a combinatorial model.
- Route D is therefore *immune* to Explorer 2's definitional tension
  around whether the Farey $i=1$ convention vs. problem.md $i=0$
  convention applies. The base case (problem.md §7) literally gives
  $i = 0 \iff$ adjacent-or-equal, which is exactly what the induction
  needs. There is no Farey-graph identification.
- Explorer 2's SP-A3 is therefore **orthogonal** to Route D's argument.
  Route D does not resolve SP-A3 either — it bypasses it.

## Step 9 — Verdict

**PASS (tentatively).** Route D produces a complete proof that
$\mathcal{C}(S_{1,1})$ is connected, with two L2 citations to standard
surface-topology textbook results (Farb–Margalit, Propositions 1.6 and
1.7). The surgery is explicit (coherent-resolution band sum), the
essentiality check is homological, and the induction is straightforward.

**Flags forwarded:**
- `[TECHNIQUE-NEW]` curve-complex induction via explicit coherent
  resolution.
- `[L2-LEANS]` two L2 citations to Farb–Margalit §1.2.4 (same source, both
  propositions).
- `[AUDIT-TARGETS]` Step 3 (essential-component existence) and Step 4
  (transverse-count preservation under resolution) are the two places an
  auditor should scrutinize most carefully; Step 5 is a routine
  strong-induction assembly.

**Fixer handoff notes:** If Fixer wants to drop an L2 to 0, the
minimal-position-existence and bigon-criterion would have to be redone
from first principles (PL approximation / geodesic length argument), which
is a *significant* expansion of the proof. Recommendation: keep the
L2s; they are both single-source and well-known.

## Step 10 — Route D summary row (for Judge)

| Field | Value |
|-------|-------|
| Route | D — minimal-position / coherent-resolution surgery |
| Verdict | PASS (tentatively) |
| L-tier depth | 2 L2 + 3 L1 + 3 I |
| Symbolic / complete? | Symbolic; complete modulo the 2 L2 citations |
| Sympy block used? | Not in this Explorer pass; proposed for Fixer if needed |
| Stuck points | None |
| Cite sources | Farb–Margalit, *A Primer on Mapping Class Groups*, Props 1.6, 1.7 |
| Key step | Homology of coherent resolution: $[a' \#_p b'] = [a'] + \epsilon[b']$ has an essential component, which has strictly smaller intersection with both $a$ and $b$ |
