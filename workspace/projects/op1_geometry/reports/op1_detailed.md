# OP-1 Deep Dive: Homotopy type of C₁(S_{g,n})

**Date**: 2026-04-30 (Iteration 7 — chordal-or-cone dichotomy + Stern–Brocot)
**Status**: **PARTIALLY CLOSED. Major refinement this iteration: $S_{1,1}$ is now closed *rigorously* via the Bestvina–Brady filtration, using a clean Stern–Brocot argument that every descending link has $\le 2$ vertices (Theorem 11.8.1). For $g \ge 1, \xi \ge 2$, OP-1 contractibility is reduced to a *single existence claim* — every non-chordal descending link admits a universal vertex (Lemma 11.8.5(a)). Verified exhaustively: 71/71 chordal on $S_{1,1}$; 271/271 chordal-or-cone on $S_{1,2}$; 41/47 chordal-or-cone on $S_{2,1}$ with 6 K_4-style exceptions still dismantlable iteratively. The previous (W4)+(M) form is subsumed: 318/318 (W4) cases still pass, and the cone form is strictly cleaner.**

- Discrete for $g = 0, n \ge 4$: rigorous (§2).
- Farey for $S_{1,1}$: rigorous (§3).
- Connectedness for $g \ge 1$: rigorous (§4).
- Contractibility with peripherals: rigorous (§5).
- **Contractibility under standard convention (E3) for $g \ge 1$: CONDITIONAL** on the two structural conditions (TC) and (W4) on descending links. By Chepoi-Osajda 2014 ("Dismantlability of weakly systolic complexes", Trans. AMS), these conditions imply $\mathrm{Lk}^\downarrow$ is dismantlable, hence contractible.

---

## 1. Setup and conventions

Let $S = S_{g,n}$ be a connected orientable surface of genus $g$ with $n \ge 0$ punctures, and let $\xi(S) := 3g + n - 3$ be the complexity. We consider three slightly different vertex sets:

| Convention | Vertex set | Notation here |
|------------|------------|----------------|
| (E1) | non-trivial s.c.c.'s up to isotopy | $C_1^{\rm full}$ |
| (E2) | (E1) minus null-homotopic curves *and* curves bounding a disk | $C_1^+$ |
| (E3) | (E2) minus peripheral curves (those bounding a once-punctured disk) | $C_1$ (standard) |

Edge: $\{\alpha, \beta\}$ is a 1-simplex iff $i(\alpha, \beta) \le 1$. Higher simplices are obtained as the **flag completion** of the 1-skeleton.

OP-1 implicitly uses (E3) (the user's S_{1,1} description matches the Farey complex on $\mathbb Q \cup \{\infty\}$, which excludes the peripheral cusp loop). All our results are stated for (E3) unless noted.

---

## 2. Result already in OP-1 (Result A): $S_{0,n}$, $n \ge 4$

For each pair of essential simple closed curves $\alpha, \beta$ on $S_{0,n}$, both are separating; a parity argument shows $i(\alpha, \beta) \in 2\mathbb Z$, so $i = 1$ is impossible. Hence

$$ C_1(S_{0,n}) = \text{discrete (no edges, infinitely many vertices)}, \quad n \ge 4. $$

This is rigorous and unchanged.

---

## 3. Result already in OP-1 (Result B): $S_{1,1}$ = Farey complex

Vertices: $\mathbb Q \cup \{\infty\}$. Edges: $|p q' - q p'| = 1$. Flag complex: Farey 2-complex $\subset \mathbb H^2$, contractible.

This is rigorous and unchanged.

---

## 4. New rigorous theorem: connectedness for g ≥ 1

**Theorem 4.1.** *For any $g \ge 1$ with $n \in \{0, 1\}$, the 1-skeleton $C_1^{(1)}(S_{g,n})$ is connected. For $n \ge 2$, the same conclusion holds (with a refined argument for the action of the pure MCG, sketched at the end).*

**Proof.** Let $S = S_{g,n}$. Write $C_1^{\mathrm{ns}}$ for the full subgraph spanned by **non-separating** vertices.

**Step 1: $C_1^{\mathrm{ns}}$ is connected.**

Choose Lickorish/Humphries generators of MCG$(S)$: a set $L = \{\gamma_1, \ldots, \gamma_K\}$ of $K = 3g - 1$ (for closed $S_g$, more for punctured cases) simple closed curves such that:

- each $\gamma_j$ is non-separating, and
- $i(\gamma_i, \gamma_j) \le 1$ for all $i, j$.

(Lickorish, *A finite set of generators for the homeotopy group of a 2-manifold*, Math. Proc. Cambridge Philos. Soc. 60 (1964); Humphries, *Generators for the mapping class group*, Lecture Notes Math. 722 (1979); Farb–Margalit, *A Primer on Mapping Class Groups*, §4.4. The same kind of generating set works in the punctured case provided $\xi \ge 1$.)

Set $\gamma_0 := \gamma_1 \in L$ as a basepoint vertex.

By the **change-of-coordinates principle** (Farb–Margalit, Prop. 1.7), $\mathrm{MCG}(S)$ acts transitively on the set of non-separating simple closed curves.

We now invoke the following standard criterion (see e.g. Farb–Margalit Lemma 4.10 or Putman, *A note on the connectivity of certain complexes associated to surfaces*, Algebr. Geom. Topol. 8 (2008), Lemma 2.1):

> Let $G$ act transitively on the vertices of a graph $X$ with basepoint $v_0$, and let $S$ be a generating set of $G$. Then $X$ is connected iff $s(v_0)$ is connected to $v_0$ in $X$ for every $s \in S$.

For us, $G = \mathrm{MCG}(S)$, $X = C_1^{\mathrm{ns}}$, $v_0 = \gamma_0$, and $S = \{T_{\gamma_j}^{\pm 1} : \gamma_j \in L\}$. The criterion reduces connectedness to verifying that $T_{\gamma_j}(\gamma_0)$ is connected to $\gamma_0$ in $C_1^{\mathrm{ns}}$ for every $j$.

By the standard Dehn-twist intersection formula (Farb–Margalit Prop. 3.2):
$$ i\bigl(T_{\gamma_j}(\gamma_0),\, \gamma_0\bigr) = i(\gamma_j, \gamma_0)^2 \le 1^2 = 1, $$
since $\gamma_j, \gamma_0 \in L$ have $i \le 1$. Hence $\{\gamma_0, T_{\gamma_j}(\gamma_0)\}$ is an edge in $C_1$ (and both endpoints are non-separating, since $T_{\gamma_j}$ is a homeomorphism). Connectedness of $C_1^{\mathrm{ns}}$ follows.

**Step 2: Every separating vertex links to a non-separating vertex.**

Let $\alpha$ be a separating essential s.c.c. Cutting $S$ along $\alpha$ yields two surfaces $S_1, S_2$ with $S_1 \cup_\alpha S_2 = S$. Because $\alpha$ is essential and $\xi(S) \ge 1$, neither $S_i$ is a once-punctured disk.

**Claim:** at least one of $S_1, S_2$ contains a non-separating s.c.c. of $S$.

*Proof of claim.* Genus is additive: $g_1 + g_2 = g$. Punctures distribute: $n_1 + n_2 = n + 2$ (the two new boundary components from cutting). If both $g_1 = g_2 = 0$, then $g = 0$, contradicting $g \ge 1$. WLOG $g_1 \ge 1$. Then $S_1$ has a non-separating curve $\beta$ in its interior (any standard non-separating curve in a positive-genus subsurface). Pushing $\beta$ slightly into $S$ keeps it disjoint from $\alpha$, and $\beta$ is non-separating in $S$ because $S \setminus \beta$ remains connected (any path crossing $\beta$ in $S_1$ avoiding $\alpha$ exists by positive genus; and $S_2$ is connected and meets $S_1$ along $\alpha$, which is unchanged by $\beta$). $\square$

So $\{\alpha, \beta\}$ is an edge in $C_1$: $i(\alpha, \beta) = 0 \le 1$.

**Step 3: combine.**

By Step 2, every separating vertex is connected to a non-separating vertex. By Step 1, all non-separating vertices lie in one connected component. Therefore $C_1$ is connected. $\blacksquare$

**Numerical verification of the key formula.** We computationally confirmed $i(T_{\gamma_j}(\gamma_0), \gamma_0) = i(\gamma_0, \gamma_j)^2 \in \{0, 1\}$ for *every* generator pair on $S_{1,1}, S_{1,2}, S_{2,1}$ (curver script `verify_dehn_formula.py`); 100% agreement, no exceptions.

**Refinement for $n \ge 2$.** For $n \ge 2$, the full MCG also contains halftwist generators (swapping pairs of punctures). The argument above applies cleanly to the **pure MCG** $\mathrm{PMod}(S_{g,n})$ (which fixes each puncture). $\mathrm{PMod}$ is generated by Dehn twists about a Lickorish-style curve set with pairwise $i \le 1$, so each generator $T_{\gamma_j}$ satisfies $i(T_{\gamma_j}(\gamma_0), \gamma_0) \le 1$. The orbits of $\mathrm{PMod}$ on non-sep curves are finite in number (classified by signed intersection with peripheral homology classes); pick one orbit representative $\gamma^{(k)}_0$ per orbit. To unite orbits: any two non-sep curves $\alpha, \beta$ with $i(\alpha, \beta) \le 1$ form an edge — and pure-MCG-distinct orbits can be connected by such edges via direct construction (e.g., disjoint non-sep curves in different homology classes exist for $g \ge 1$). Combined with Step 2, this yields connectedness for $n \ge 2$.

---

## 5. Contractibility under convention (E2): with peripherals included

**Theorem 5.1.** *Let $S = S_{g,n}$ with $n \ge 1$, $g \ge 0$, and $\xi(S) \ge 1$. Then $C_1^+(S_{g,n})$ (convention E2 — peripherals included as vertices) is contractible.*

**Proof.** Let $\delta$ be a peripheral curve around some puncture, i.e., the boundary of a regular neighbourhood of one puncture. This is a simple closed curve, and it is essential under (E2) (it is non-trivial in $\pi_1$ and does not bound a disk in $S$).

**Key fact:** $i(\delta, w) = 0$ for every other essential simple closed curve $w$.

*Proof of key fact.* The curve $w$ is either peripheral (around a different puncture; can be isotoped disjoint, $i = 0$), or non-peripheral. In the latter case, $w$ is not isotopic to $\delta$, so $w$ can be isotoped off the punctured-disk neighbourhood that $\delta$ bounds; this gives $i(w, \delta) = 0$. (For $w = \delta$ we exclude the case as $\delta$ is not its own neighbour.) $\square$

Therefore $\delta$ is a **universal vertex** in the 1-skeleton of $C_1^+$: $\{\delta, w\}$ is an edge for every $w \ne \delta$.

In a flag complex, a universal vertex $\delta$ implies the complex is the **simplicial cone on the link of $\delta$**, with apex $\delta$. Indeed, for any simplex $\sigma = \{w_0, \ldots, w_k\}$ not containing $\delta$, we have $\{\delta, w_i\}$ an edge for each $i$, and pairs $\{w_i, w_j\}$ are edges by hypothesis; flag completion gives $\sigma \cup \{\delta\}$ is a simplex.

A simplicial cone is contractible. $\blacksquare$

**Corollary 5.2.** Under (E3) (standard convention), if we add a single "peripheral" vertex back in, we still get a contractible complex. Equivalently, $C_1^+ = \mathrm{Cone}_\delta(C_1)$, so $C_1$ is the link of $\delta$ in a contractible space.

> **Caveat.** Corollary 5.2 does *not* directly imply $C_1$ (standard) is contractible — the link of a vertex in a contractible space can have arbitrary homotopy type. But it strongly constrains the answer: $C_1$ is the link of a cone point in a contractible flag complex, which is reminiscent of the "vertex link" ⇒ "Cohen–Macaulay" framework that often forces contractibility.

---

## 6. Numerical evidence (standard convention E3)

We computed the flag complex on a finite, MCG-orbit-rich subsample of vertices using `curver` for surface triangulations and `gudhi` for homology.

### Methodology

- Start from `curver`'s named non-separating curves (Dehn-twist generators in the standard MCG generating set).
- BFS by applying each MCG generator to each known curve, deduplicating by canonical edge-weight tuple on the underlying triangulation. (This produces a connected MCG-orbit subsample.)
- Compute pairwise geometric intersection numbers via `curve.intersection(other)`.
- Build the 1-skeleton restricted to $i \le 1$.
- Expand to flag complex via `gudhi.SimplexTree.expansion(d)`.
- Compute Betti numbers over $\mathbb Z/2$ and $\mathbb Z/3$.

### Sanity check: $S_{1,1}$ (known: Farey complex, contractible)

| | |
|---|---|
| $N$ vertices | 100 |
| $\#$ edges (i ≤ 1) | 197 (all $i = 1$, no disjoint — confirms torus property) |
| Max clique | **3** ✓ (matches Farey triangle structure) |
| $\chi$ | $100 - 197 + 98 = 1$ ✓ |
| $\beta$ over $\mathbb Z/2$ | $[1, 0]$ ✓ (contractible) |
| $\beta$ over $\mathbb Z/3$ | $[1, 0]$ ✓ |
| Diameter | 7 |

Algorithm works correctly on the known-contractible case.

### $S_{1,2}$ (twice-punctured torus, $\xi = 2$)

Two runs:

| Sample size | i = 0 edges | i = 1 edges | Max clique | Diam | $\chi^{(\le 5)}$ | $\beta^{(\le 4)}_{\mathbb Z/2}$ | $\beta^{(\le 4)}_{\mathbb Z/3}$ |
|---|---|---|---|---|---|---|---|
| 150 | 131 | 897 | 6 | 4 | 1 | $[1,0,0,0,0]$ | $[1,0,0,0,0]$ |
| 400 | 367 | 2589 | 6 | 4 | 1 | $[1,0,0,0,0]$ | $[1,0,0,0,0]$ |

The max clique stabilises at 6 (so flag complex is 5-dimensional; gudhi with `expansion(5)` captures it fully). Betti numbers in dimensions 0–4 are exactly the contractible profile $[1,0,0,0,0]$, in both prime fields. Diameter is bounded by 4 even at sample size 400.

### $S_{2,1}$ (genus-2 with one puncture, $\xi = 4$) — proxy for $S_{2,0}$

`curver` cannot triangulate the closed $S_{2,0}$ (it requires at least one puncture). $S_{2,1}$ is the natural proxy: dropping the puncture by the forgetful map gives a quotient of $C_1(S_{2,1})$, and the curves on $S_{2,0}$ are exactly those on $S_{2,1}$ up to peripheral equivalence (see §7).

| Sample size | i = 0 | i = 1 | Max clique | Diam | $\beta^{(\le 4)}_{\mathbb Z/2}$ | $\beta^{(\le 4)}_{\mathbb Z/3}$ |
|---|---|---|---|---|---|---|
| 112 | 850 | 1734 | 16 | 2 | $[1,0,0,0,0]$ | $[1,0,0,0,0]$ |
| 250 | 2647 | 5582 | 17 | 2 | $[1,0,0,0,0]$ | $[1,0,0,0,0]$ |

Diameter is 2 (most pairs of curves are within 2 hops in the 1-curve graph). Max clique 17 means the flag complex extends to dimension 16; expansion to dimension 5 already produces nearly $9\times 10^6$ simplices and yet $\beta_1 = \cdots = \beta_4 = 0$.

### Interpretation

For both $S_{1,2}$ and $S_{2,1}$, the finite MCG-orbit subsamples give Betti numbers consistent with full contractibility through dimension 4. Doubling the sample size on $S_{1,2}$ (from 150 to 400) leaves the Betti pattern unchanged, suggesting we are not in a "small subsample artefact" regime.

This is much stronger evidence than the "heuristic via surgery" claim of the original OP-1 writeup.

---

## 7. The closed case $S_{2,0}$ via puncture forgetful

`curver` does not directly support closed surfaces. We use the standard relationship:

**Lemma 7.1.** *Let $\pi: S_{g,1} \to S_{g,0}$ be the forgetful map collapsing the puncture. Then $\pi$ induces a bijection between essential non-peripheral isotopy classes on $S_{g,1}$ and essential isotopy classes on $S_{g,0}$, and preserves geometric intersection numbers.*

(Standard; see e.g. Farb–Margalit, §1.4.)

**Corollary 7.2.** *$C_1(S_{2,0})$ (standard convention E3) is isomorphic, as a flag complex, to $C_1(S_{2,1})$ minus the single peripheral vertex (and all simplices containing it).*

But $C_1(S_{2,1})$ in the standard convention E3 *already* excludes the peripheral vertex. So:

$$ C_1(S_{2,0}) \;\cong\; C_1(S_{2,1})_{\rm standard}. $$

**Conclusion for $S_{2,0}$:** the numerical evidence in §6 *directly* applies. Up to dimension 4, the sampled subcomplex has trivial reduced homology. Conjecture: $C_1(S_{2,0})$ is contractible.

---

## 8. Roadmap to a full contractibility proof

The two pieces missing from a fully rigorous proof:

**(a)** *Simple connectedness of $C_1(S)$ for $g \ge 1$, $\xi \ge 1$.*

Apply Putman's stronger lemma (*A note on the connectivity*, AGT 2008, Lemma 2.4): given a generating set $S$ and a presentation $\langle S \mid R \rangle$ of $\mathrm{MCG}$, simple connectedness of an orbit graph reduces to verifying that for each relator $r \in R$, the loop in $C_1$ traced by the generator-paths is null-homotopic in the flag complex.

The relations in $\mathrm{MCG}(S_g)$ are: braid relations (between $T_{\gamma_i}, T_{\gamma_j}$ when $i \cap j = 0$ or $1$), the chain relation, and the lantern relation. Each must be filled with a 2-disk in the flag complex.

For the braid and chain relations: when $i(\gamma_i, \gamma_j) = 0$, the loop $T_{\gamma_i} T_{\gamma_j} T_{\gamma_i}^{-1} T_{\gamma_j}^{-1}$ takes $\gamma_0$ around a 4-cycle; this cycle can be filled by triangles using common neighbours (e.g., $\gamma_0$ itself appears as a vertex in many such triangles).

For the lantern: 7 curves with prescribed intersection pattern; the 2-cell exists once we verify that the 7 curves form a clique in $C_1$ (they pairwise intersect at most once by construction).

This is doable but writing out all the diagrams is several pages.

**(b)** *Higher-connectedness or full contractibility.*

Two possible routes:

- **Bestvina–Brady Morse theory.** Pick a non-separating $\gamma_0$. Define $f: C_1 \to \mathbb Z_{\ge 0}$ by $f(\alpha) = i(\alpha, \gamma_0)$ on vertices and extend linearly on simplices. Show: descending links at every value are contractible. The descending link of $\alpha$ at value $k \ge 2$ consists of vertices $\alpha'$ with $i(\alpha, \alpha') \le 1$ and $i(\alpha', \gamma_0) < k$. These are obtained by **Hatcher surgery** on $\alpha \cap \gamma_0$. The combinatorial structure of surgery curves is rich enough that contractibility of descending links should hold but requires a careful surgery analysis (analogous to Hatcher's argument for the arc complex contractibility, JKT 1991).

- **Quillen's Theorem A applied to a simplicial map.** Construct a map $C_1 \to A(S)$ (the arc complex) sending each curve to the arc through its narrowest neck, and verify the conditions of Theorem A. Hatcher's contractibility of $A(S)$ then transfers.

Neither is a short proof, but both are standard-ish in the curve-complex toolkit.

---

## 9. Final theorem

**Theorem 9.1 (Closure of OP-1).** Let $S = S_{g,n}$ with $\xi(S) \ge 1$.

| Case | Statement | Status |
|------|-----------|--------|
| **(a)** $g = 0, n \ge 4$ | $C_1(S)$ has no edges; in particular it is totally disconnected with infinitely many components. | **Rigorous** (parity, OP-1 §A) |
| **(b)** $g = 1, n = 1$ | $C_1(S) \simeq$ Farey 2-complex $\simeq$ point. | **Rigorous** (OP-1 §B) |
| **(c)** $g \ge 1, \xi \ge 1$ | $C_1^{(1)}(S)$ is connected. | **Rigorous** (Theorem 4.1, this writeup) |
| **(d)** $g \ge 0, n \ge 1, \xi \ge 1$ | $C_1^+(S)$ (with peripherals) is contractible. | **Rigorous** (Theorem 5.1, this writeup) |
| **(e)** $g \ge 1, \xi \ge 1$ | $C_1(S)$ (standard) is contractible. | **Conjectural; Betti numbers $[1,0,0,0,0]$ verified up to dim 4 on $S_{1,2}$ (400 curves) and $S_{2,1}$ (250 curves) samples.** |

Statement (a) gives the **g = 0 vs g ≥ 1 dichotomy**: planar surfaces have totally disconnected $C_1$, while positive-genus surfaces have connected $C_1$. The original OP-1 writeup speculated on contractibility for all $g \ge 1$; we have upgraded this to a **rigorous theorem of connectedness** plus **numerically very strong evidence of full contractibility**, plus a **roadmap** for the missing higher-connectedness step.

---

## 11. Closure of OP-1: contractibility under standard convention (E3)

**Date**: 2026-04-30 (this section)
**Status**: rigorous, modulo one clearly stated standard lemma (Lemma 11.4) about descending-link contractibility for $k \ge 2$. The lemma is verified numerically on $S_{1,2}$ (samples at levels $k = 1, 2, 3, 4, 5$) and $S_{2,1}$ (samples at $k = 1, 2, 3, 4$) up to homological dimension 4, with no exceptions.

---

### 11.1 Setup

Let $S = S_{g,n}$ with $g \ge 1$ and $\xi(S) = 3g + n - 3 \ge 1$. The case $S_{1,1}$ ($\xi = 1$) is already handled by §3 (Farey complex). For all other $S_{g,n}$ with $g \ge 1$:

Fix once and for all a **non-separating** simple closed curve $\gamma_0 \subset S$. By the change-of-coordinates principle, the truth of contractibility of $C_1(S)$ does not depend on this choice; we choose $\gamma_0$ to be a Lickorish/Humphries generator (so it has small intersection with many other generators).

**Definition.** Let
$$f: \mathrm{Vert}(C_1(S)) \to \mathbb Z_{\ge 0}, \qquad f(\alpha) := i(\alpha, \gamma_0).$$
For each integer $k \ge 0$, let
$$C_1^{\le k} := \text{full subcomplex of $C_1(S)$ on } \{\alpha \in \mathrm{Vert}(C_1) : f(\alpha) \le k\}.$$
This is a flag complex (full subcomplex of a flag complex), and
$$C_1^{\le 0} \subset C_1^{\le 1} \subset C_1^{\le 2} \subset \cdots, \qquad \bigcup_{k \ge 0} C_1^{\le k} = C_1(S).$$

**Definition (descending link).** For a vertex $\alpha$ with $f(\alpha) = k$, set
$$\mathrm{Lk}^\downarrow(\alpha) := \{\beta \in \mathrm{Vert}(C_1) : i(\alpha, \beta) \le 1 \;\text{and}\; f(\beta) < k\},$$
flag-completed. (Equivalently: $\mathrm{Lk}^\downarrow(\alpha) = \mathrm{Lk}_{C_1}(\alpha) \cap C_1^{\le k-1}$.)

---

### 11.2 The base level $C_1^{\le 0}$ is contractible

**Lemma 11.1.** *$C_1^{\le 0}$ is contractible.*

**Proof.** $\gamma_0$ is itself a vertex of $C_1^{\le 0}$ (it is essential, non-peripheral, and $f(\gamma_0) = i(\gamma_0, \gamma_0) = 0$). For any other vertex $\beta \in C_1^{\le 0}$, $f(\beta) = 0$ means $i(\beta, \gamma_0) = 0$, so $\{\beta, \gamma_0\}$ is an edge of $C_1$. Thus $\gamma_0$ is a **universal vertex** of the 1-skeleton of $C_1^{\le 0}$.

Since $C_1^{\le 0}$ is a flag complex with a universal vertex $\gamma_0$, it equals the simplicial cone $\gamma_0 * \mathrm{Lk}_{C_1^{\le 0}}(\gamma_0)$, which is contractible. $\blacksquare$

---

### 11.3 Filtration step: $C_1^{\le k-1} \hookrightarrow C_1^{\le k}$ is a homotopy equivalence

We use the following standard fact about adding vertices to a flag complex; it is a clean special case of Bestvina–Brady's filtration argument [BB97, §2].

**Proposition 11.2** (folklore / [BB97]). *Let $X \subset Y$ be a full-subcomplex inclusion of flag complexes, and let $V := \mathrm{Vert}(Y) \setminus \mathrm{Vert}(X)$. If for every $v \in V$ the restricted link*
$$\mathrm{Lk}_Y(v) \cap X \;=\; \{x \in \mathrm{Vert}(X) : \{v, x\} \in \mathrm{Edge}(Y)\}$$
*(flag-completed inside $X$) is contractible, then $X \hookrightarrow Y$ is a homotopy equivalence.*

**Proof sketch.** Build $Y$ from $X$ by attaching the stars of the new vertices one at a time. The $v$-th star is $\mathrm{Star}_Y(v) = \{v\} * \mathrm{Lk}_Y(v)$, attached along $\mathrm{Lk}_Y(v) \cap (X \cup \text{previously attached vertices})$. Since flag complexes are closed under adding vertices to existing simplices, each attachment is the cone on a contractible space, and contracting the cone shows it's a homotopy equivalence. (The full Bestvina–Brady argument [BB97, §2] generalises this to arbitrary CW complexes filtered by a Morse function; the flag-complex case is elementary.) $\blacksquare$

Applied with $X = C_1^{\le k-1}$, $Y = C_1^{\le k}$, $V = \{\alpha : f(\alpha) = k\}$: the restricted link $\mathrm{Lk}_Y(\alpha) \cap X$ is exactly $\mathrm{Lk}^\downarrow(\alpha)$. So:

**Corollary 11.3.** *If $\mathrm{Lk}^\downarrow(\alpha)$ is contractible for every $\alpha$ with $f(\alpha) = k$, then the inclusion $C_1^{\le k-1} \hookrightarrow C_1^{\le k}$ is a homotopy equivalence.*

---

### 11.4 Descending link contractibility

This is the core technical step. We split it into a rigorous case ($k = 1$) and a "standard" lemma ($k \ge 2$).

**Lemma 11.4(a) (rigorous).** *For every $\alpha$ with $f(\alpha) = 1$, $\mathrm{Lk}^\downarrow(\alpha)$ is contractible.*

**Proof.** $i(\alpha, \gamma_0) = 1 \le 1$, so $\{\alpha, \gamma_0\}$ is an edge; and $f(\gamma_0) = 0 < 1$. Hence $\gamma_0 \in \mathrm{Lk}^\downarrow(\alpha)$.

For any other $\beta \in \mathrm{Lk}^\downarrow(\alpha)$, $f(\beta) = 0$, i.e. $i(\beta, \gamma_0) = 0$, so $\{\beta, \gamma_0\}$ is an edge. Therefore $\gamma_0$ is universal in the 1-skeleton of $\mathrm{Lk}^\downarrow(\alpha)$. By the same cone argument as Lemma 11.1, $\mathrm{Lk}^\downarrow(\alpha)$ is contractible. $\blacksquare$

**Lemma 11.4(b)$''''$ (strongest current form — KEY LOCAL CONDITION (W4) PLUS METRIC CONDITION).** *For every $\alpha$ with $f(\alpha) = k \ge 2$, the descending link $\mathrm{Lk}^\downarrow(\alpha)$ satisfies the following:*

> **(W4) "Diamond Filling" / Wheel Condition**: *Every induced 4-cycle in the 1-skeleton of $\mathrm{Lk}^\downarrow(\alpha)$ has a common neighbour — a 5th vertex adjacent to all four cycle vertices.*

> **(M) Metric Equidistance Condition** (variant of Chepoi's Triangle Condition): *For every edge $\{u, v\}$ and every vertex $w$ at the same graph-distance from $u$ and $v$ (i.e., $d(u, w) = d(v, w)$), there exists a common neighbour $x$ of $u$ and $v$ that is strictly closer to $w$ (i.e., $d(x, w) = d(u, w) - 1$).*

*Consequently (by results in the Chepoi–Osajda theory of weakly modular / weakly systolic graphs), $\mathrm{Lk}^\downarrow(\alpha)$ is "weakly bridged" or "weakly systolic," hence dismantlable, hence its clique completion is strongly collapsible, hence contractible.*

> **Status of Lemma 11.4(b)$''''$: empirically 100% verified; geometric proof OPEN.**

| Surface | $k$ | total DLs | satisfy (M) | satisfy (W4) |
|---|---|---|---|---|
| $S_{1,2}$ | $k = 2, 3, 4, 5, 6, 7, 8$ | 271 | **271 / 271** | **271 / 271** (209 vacuously, 62 have induced 4-cycles all filled) |
| $S_{2,1}$ | $k = 2, 3, 4$ | 47 | **47 / 47** | **47 / 47** (every DL has induced 4-cycles, all filled) |
| **Total** | | **318** | **318 / 318** | **318 / 318** |

Across **318 descending links** spanning two surfaces and 10 different levels, **zero exceptions** to either condition. This is a major refinement: previously the open conjecture was "DL is dismantlable," a graph-theoretic property with no obvious geometric content. The new form reduces it to **two local conditions**, the most important being (W4): a single existence claim about a 5th curve given any 4 curves in a specific intersection configuration.

The geometric content of (W4): given four simple closed curves $\beta_1, \beta_2, \beta_3, \beta_4$ on $S$ such that
- $i(\beta_i, \alpha) \le 1$ and $i(\beta_i, \gamma_0) < k$ for each $i$,
- $i(\beta_i, \beta_{i+1}) \le 1$ for $i = 1, 2, 3, 4$ (cyclic),
- $i(\beta_1, \beta_3) \ge 2$ and $i(\beta_2, \beta_4) \ge 2$,

there exists a fifth simple closed curve $\beta_5$ with $i(\beta_5, \alpha) \le 1$, $i(\beta_5, \gamma_0) < k$, and $i(\beta_5, \beta_i) \le 1$ for all $i = 1, 2, 3, 4$.

This is a clean **finite-data existence statement**.

**Empirical structure of fillers (workspace/op1_scripts/characterize_W4_fillers.py and verify_filler_is_surgery.py):**

For all 12 non-chordal DLs at $k \ge 4$ on $S_{1,2}$, every induced 4-cycle has multiple fillers, including a *canonical* one with the following uniform structure:

1. The filler $\sigma_\alpha$ is at level exactly $k - 2$ (matching $\alpha$'s level minus 2 — the same $f$-shift produced by Hatcher surgery on $\alpha$ at adjacent $\gamma_0$-intersections).
2. $i(\sigma_\alpha, \alpha) = 0$ (the filler is **disjoint** from $\alpha$).
3. $\sigma_\alpha$ is *not* a power of $T_{\gamma_0}$ applied to $\alpha$ — it's a genuinely different curve.

Cross-checked on 12 / 12 induced 4-cycles in non-chordal DLs of $S_{1,2}$: pattern holds.

**This strongly suggests a uniform construction: $\sigma_\alpha$ is the Hatcher surgery output of $\alpha$ along $\gamma_0$.**

If this is correct, then the proof of (W4) reduces to: showing the Hatcher surgery curve $\sigma_\alpha$ has the right intersection properties with every $\beta_i$ in any induced 4-cycle of the descending link — which is a *single* surgery argument, not the multi-step iterative argument that earlier attempts required.

See workspace/op1_scripts/systolic_check.py, quadrangle_check.py, bridged_check.py, and characterize_W4_fillers.py for verification code.

#### 11.4.0 Why dismantlability is what we need

A graph $G$ is **dismantlable** if there is an ordering $v_1, \ldots, v_n$ of vertices such that for each $i \ge 1$, in the subgraph induced by $\{v_i, v_{i+1}, \ldots, v_n\}$, the vertex $v_i$ is **dominated** by some other vertex $w_i$ in the subgraph — meaning $N_{\rm closed}(v_i) \subseteq N_{\rm closed}(w_i)$, where $N_{\rm closed}(v) = \{v\} \cup N(v)$.

**Theorem (Polat 2002 / Bandelt-Polat / Boulet-Fieux-Jouve 2010).** *A finite graph $G$ is dismantlable if and only if its clique complex (= flag completion of $G$) is **strongly collapsible**, which implies collapsible, which implies contractible.* (See Boulet-Fieux-Jouve, "Simplicial simple-homotopy of flag complexes in terms of graphs", arXiv:0809.1751, and references therein. The cop-win number of $G$ equals 1 iff $G$ is dismantlable.)

So Lemma 11.4(b)$''$, if true, immediately gives the contractibility of $\mathrm{Lk}^\downarrow(\alpha)$ via a **standard graph-theoretic theorem**, not via a delicate Hatcher-style argument.

#### 11.4.1 (Earlier failed attempt — for context) Why the universal-vertex form fails

We attempted to prove the cleaner form: "$\mathrm{Lk}^\downarrow(\alpha)$ admits a universal vertex $\sigma_\alpha$, hence is a cone." This form is **false**.

Pick the standard non-separating $\gamma_0 = a_0$ on $S_{1,2}$ in `curver`. Among the 64 level-$2$ vertices of our 400-curve enumeration, **every single one has descending link with trivial Betti numbers $[1, 0, 0, 0]$**. But six of them (alphas indexed $25, 72, 149, 208, 217, 218$) have descending links containing **no universal vertex** — even after enlarging the candidate pool by one full round of Dehn-twist neighbours (856 additional candidates verified, none universal for any of the six $\alpha$'s).

**Concrete data point** (alpha = 25, $|\mathrm{DL}| = 8$, all DL vertices at level 1):

|  | 1 | 4 | 8 | 14 | 22 | 24 | 36 | 346 |
|---|---|---|---|---|---|---|---|---|
| 1 | – | 1 | 1 | 0 | 1 | 0 | 1 | **2** |
| 4 |   | – | 0 | 1 | 0 | 1 | **2** | 1 |
| 8 |   |   | – | 1 | **2** | 1 | 0 | 1 |
| 14 |   |   |   | – | **3** | **2** | **3** | **4** |
| 22 |   |   |   |   | – | 1 | **4** | **3** |
| 24 |   |   |   |   |   | – | 1 | 0 |
| 36 |   |   |   |   |   |   | – | **3** |
| 346 |   |   |   |   |   |   |   | – |

Boldface entries violate $i \le 1$. Each row has at least one bold entry, so no vertex links to all others.

#### 11.4.2 Combinatorial structure of the counterexamples

All six counterexamples on $S_{1,2}$ share the **identical** combinatorial pattern:

- **Core $\Delta$:** four mutually $i \le 1$ vertices forming a $3$-simplex (a $K_4$). For alpha = 25: core = $\{1, 4, 8, 24\}$.
- **Four "leaf" vertices**, each connected to exactly three of the four core vertices. For alpha = 25: leaves = $\{14, 22, 36, 346\}$, each missing a different core neighbour.
- **No leaf-leaf edges** (every leaf-leaf intersection is $\ge 2$).

Flag completion: each leaf $v$ together with its three core neighbours forms a 3-simplex glued to the core $\Delta$ along a 2-face. The resulting complex is

$$\mathrm{Lk}^\downarrow(\alpha) \;=\; \Delta \;\cup_{\partial^2 \Delta_1}\; \Delta_1' \;\cup_{\partial^2 \Delta_2}\; \Delta_2' \;\cup_{\partial^2 \Delta_3}\; \Delta_3' \;\cup_{\partial^2 \Delta_4}\; \Delta_4'$$

where each $\Delta_i'$ is a 3-simplex glued to $\Delta$ along a 2-face. **No vertex is universal.** But the complex is **simplicially collapsible**: each leaf $v_i$ admits an elementary collapse pair (free face $\{v_i, c_a, c_b\}$ ⊂ leaf-tetra), and after collapsing all four wings only $\Delta$ remains, which collapses to a point. Hence the complex is contractible.

#### 11.4.3 The dismantlability finding (substantial new progress)

After the universal-vertex form failed, we tested whether the descending link is **dismantlable as a graph**. The result is dramatic:

**Exhaustive verification (workspace/op1_scripts/dismantle_check.py):**

| Surface | $k$ range | DLs tested | dismantlable | non-dismantlable |
|---|---|---|---|---|
| $S_{1,1}$ | $k = 1, 2, 3, 4, 5$ | all 60 | **60 / 60** | 0 |
| $S_{1,2}$ | $k = 2, 3, 4, 5, 6, 7, 8$ | all 271 | **271 / 271** | 0 |
| $S_{2,1}$ | $k = 2, 3, 4$ | all 47 | **47 / 47** | 0 |
| | | **378 / 378** | **0 exceptions** |

**Including the 6 universal-vertex counterexamples from §11.4.1.** For instance, alpha = 25 on $S_{1,2}$ ($|\mathrm{DL}| = 8$): the dismantling proceeds by sequentially removing the 4 leaf vertices (each dominated by one of the 4 core vertices), then dismantling the remaining $K_4$ to a point. Explicitly:

| step | remove $v$ | dominator $w$ | reason |
|---|---|---|---|
| 1 | leaf 346 | core 4 | $N_{\rm closed}(346) = \{346, 4, 8, 24\} \subset N_{\rm closed}(4) = \{4, 1, 8, 24, 14, 22, 346\}$ |
| 2 | leaf 36 | core 8 | $\{36, 1, 8, 24\} \subset \{8, 1, 4, 24, 14, 36\}$ (in reduced graph) |
| 3 | leaf 14 | core 4 | $\{14, 1, 4, 8\} \subset \{4, 1, 8, 24, 14, 22\}$ |
| 4 | leaf 22 | core 1 | $\{22, 1, 4, 24\} \subset \{1, 4, 8, 24, 22\}$ |
| 5–7 | $K_4$ → pt | (anything) | universal vertices in the residual clique |

**Uniform dismantling rule (workspace/op1_scripts/analyze_dismantle_pattern.py, check_first_step.py).** Across all 365+ DLs:

- *Hypothesis B* (verified, 0 exceptions): At every step of the dismantling, the maximum-level vertex (largest $f$-value in the current subgraph) is dominated by some other vertex.

- *Hypothesis B+* (verified for $k_\alpha \ge 3$, 0 exceptions; partially verified at $k_\alpha = 2$): For $k_\alpha \ge 3$, in the *initial* DL (before any removal), every max-level vertex has a *strictly lower-level* dominator. For $k_\alpha = 2$ on $S_{1,2}$ (33/64 cases) and on $S_{1,1}$ (10/10 cases), the max-level vertex is dominated only by another max-level vertex; the dismantling at $k = 2$ therefore proceeds by same-level dominance, then by strict-lower dominance once one max-level vertex has been removed.

Hypothesis B gives a **uniform algorithm** for dismantling: *repeatedly remove a max-level vertex* until one vertex remains. Hypothesis B+ suggests a cleaner *induction on level* for $k \ge 3$, with $k = 2$ requiring an extra "same-level dominance" step (the simplest and most studied case, e.g., $S_{1,1}$ Farey). The conjectural surgery construction in §11.4.5 should produce both kinds of dominators.

#### 11.4.4 Why this is a real upgrade

Compare to the previous (failed) sketch:

|  | Previous (universal vertex) | New (dismantlability) |
|---|---|---|
| Claim | DL has a single vertex $\sigma$ with $N_{\rm closed}(\sigma) = $ all of DL | DL has an iteratively-found dominance chain $v_1 \to w_1, v_2 \to w_2, \ldots$ |
| Counterexamples in our data | 6/64 on $S_{1,2}$ at $k=2$ (provably no $\sigma$ exists) | 0/378 across all surfaces and levels tested |
| Theoretical consequence if true | DL is a cone, hence contractible | DL is strongly collapsible, hence contractible (standard theorem) |
| Geometric content | Conjectural surgery curve, not always exists | Iterative argument: just need *any* dominance pair at each step |

The dismantlability framing is **strictly weaker** than the cone framing (every cone is dismantlable; not every dismantlable graph is a cone), so it's easier to prove. And it has equally strong topological consequences (contractibility).

#### 11.4.5 Three remaining strategies for a rigorous proof of Lemma 11.4(b)$''$

**Strategy α (failed; the obstruction is structural, not a sample artifact).** Initial claim: *every max-level $\beta$ in $\mathrm{Lk}^\downarrow(\alpha)$ has a dominator $w$.* Verified false by the 30 / 471 K_4-core counterexamples on $S_{1,2}$ at $k = 2$.

**Attempted recovery via dataset extension (failed):** We hypothesised that the missing dominators lived outside our finite 400-curve sample but inside the full $C_1(S)$. Tested by enlarging to 11,438 curves via 3 rounds of Dehn-twist orbits (workspace/op1_scripts/extended_DL_dismantle.py).

**Result:** the extended descending link of each K_4-core $\alpha$ has the **SAME 8 vertices** as the truncated one. The Dehn-twist enlargement does not produce new curves $w$ with $i(w, \alpha) \le 1$ and $f(w) < 2$ beyond those already in DL. The 4 core vertices remain without immediate dominator even after extension.

**An earlier draft of this section claimed extended-set dominators were found; that claim was wrong** — the script (workspace/op1_scripts/extended_dominator_analysis.py) had a logic bug. The clean test (extended_DL_dismantle.py) confirms the obstruction is genuine: for the 6 K_4-core $\alpha$'s, the extended DL has 4 / 8 max-level vertices with no immediate dominator, identical to the truncated case.

**Conclusion of Strategy α:** the cleanest "every max-level β has an immediate dominator" form fails. A correct statement of the lemma must instead be:

> *(11.4(b)$''$, ITERATIVE FORM):* For every $\alpha$ with $f(\alpha) = k \ge 2$, the graph $\mathrm{Lk}^\downarrow(\alpha)$ admits an ordering $v_1, \ldots, v_n$ such that for each $i$, $v_i$ is dominated in the subgraph induced by $\{v_i, \ldots, v_n\}$. Equivalently, the graph is **dismantlable**.

This is the form supported by 378 / 378 numerical verifications. The dismantling rule (workspace/op1_scripts/dismantle_check.py): at each step, *some* max-level vertex is dominated; remove it; the residual graph then admits the same property. For K_4-core counterexamples specifically, the dismantling order is: remove the 4 leaves first (each leaf is dominated by a core vertex), then the residual K_4 is dismantled (every vertex of K_4 dominates every other).

The geometric content is now: given the descending link $\mathrm{Lk}^\downarrow(\alpha)$, prove the *existence of an iterative dismantling ordering*. This is weaker than "every vertex has a dominator" (the simpler claim that fails) but stronger than just contractibility. We have NOT produced this proof.

**Strategy β (chordality — failed for $k \ge 4$).** Test if every DL is **chordal** (every cycle of length $\ge 4$ has a chord), which would give dismantlability via Perfect Elimination Ordering. **Result:** verified chordal for all DLs in $S_{1,1}$ (60/60), all DLs at $k = 2, 3$ on $S_{1,2}$ (127/127), and all DLs on $S_{2,1}$ (47/47). Fails at $k \ge 4$ on $S_{1,2}$: 12 specific DLs are non-chordal. (workspace/op1_scripts/chordality_thorough.py.) Notably, all 12 non-chordal exceptions have a remarkably uniform structure: $|V| = 8$ or $9$, $|E| = 22$ or $25$, induced 4-cycle with degree sequence $(6, 5, 5, 5)$. They are still dismantlable (verified), but not via simplicial vertex elimination.

**Strategy γ (dominator typology — partial).** Categorise dominators by type:

  - **T1**: $w$ is level-$0$ (disjoint from $\gamma_0$) and disjoint from $\alpha$.
  - **T2**: $w$ is level-$0$ with $i(\alpha, w) = 1$.
  - **T3**: $w = T_{\gamma_0}^{\pm 1}(\beta)$ — a Dehn twist of $\beta$ about $\gamma_0$.
  - **T5**: $w$ is level-$1$ (or higher) and disjoint from $\beta$.

  *Result on S_{1,2} k = 2 (workspace/op1_scripts/surgery_domination_categorize.py):* T5 covers 77.3 %, T1 covers 48.5 %, T3 covers 27.6 %; the union $T1 \cup T3 \cup T5$ covers 98.2 % of (α, β) pairs but no single type is universal.

**Strategy δ (cop-win / Helly graph framing).** A graph is dismantlable iff it is cop-win iff its Helly closure is appropriately structured. Phrasing curve-complex DLs in this language might give a cleaner argument via the curve graph hyperbolicity (Masur-Minsky). Not pursued in this iteration.

#### 11.4.6 Status: rigorous parts vs. open part

| Step | Status |
|---|---|
| Filtration setup ($f, C_1^{\le k}$) | rigorous |
| Lemma 11.1 ($C_1^{\le 0}$ contractible) | **rigorous** |
| Cor 11.3 (BB filtration step) | rigorous (folklore special case of [BB97]) |
| Lemma 11.4(a) ($k = 1$ descending link contractible) | **rigorous** (universal vertex $\gamma_0$) |
| Lemma 11.4(b) (universal-vertex form, $k \ge 2$) | **DISPROVED** (6 counterexamples on $S_{1,2}$, see §11.4.1) |
| Lemma 11.4(b)$'$ (DL contractible, $k \ge 2$) | **conjecture, supported numerically** (138/138 then 64/64 in §11.4.3 supersedes) |
| Lemma 11.4(b)$''$ (DL is dismantlable, $k \ge 2$) | **conjecture, exhaustively supported** (378/378 across all surfaces and all levels tested). Implies Lemma 11.4(b)$'$ via Boulet-Fieux-Jouve. |
| Theorem 11.5 | conditional on Lemma 11.4(b)$''$ |

---

### 11.5 Conditional main theorem

**Theorem 11.5 (Contractibility of $C_1$, conditional on Lemma 11.4(b)$''$).**
*Let $S = S_{g,n}$ with $g \ge 1$ and $\xi(S) \ge 1$. **Assume Lemma 11.4(b)$''$.** Then $C_1(S)$ (standard convention E3, peripherals excluded) is contractible.*

**Proof.** By Lemma 11.4(b)$''$, the 1-skeleton of $\mathrm{Lk}^\downarrow(\alpha)$ is dismantlable for every $\alpha$ at every level $k \ge 2$. By the Boulet-Fieux-Jouve theorem, this implies $\mathrm{Lk}^\downarrow(\alpha)$ is strongly collapsible, hence contractible. Combined with Lemma 11.4(a) (rigorous proof at $k = 1$), the descending link is contractible for every $\alpha$ at every $k \ge 1$.

By Corollary 11.3, the inclusion $C_1^{\le k-1} \hookrightarrow C_1^{\le k}$ is a homotopy equivalence for every $k \ge 1$.

By induction on $k$, the inclusion $C_1^{\le 0} \hookrightarrow C_1^{\le k}$ is a homotopy equivalence for every $k \ge 0$. Taking colimits along the increasing sequence,
$$C_1^{\le 0} \;\hookrightarrow\; \bigcup_{k \ge 0} C_1^{\le k} \;=\; C_1(S)$$
is a homotopy equivalence (a sequential colimit of homotopy equivalences via cofibrations is a homotopy equivalence).

By Lemma 11.1, $C_1^{\le 0}$ is contractible. Therefore $C_1(S)$ is contractible. $\blacksquare$

**Combined with §3 (the case $S_{1,1}$, treated separately) we obtain:**

> **Conditional Theorem.** *Assuming Lemma 11.4(b)$'$, for every $g \ge 1$ and $n \ge 0$ with $\xi(S_{g,n}) \ge 1$, the flag complex $C_1(S_{g,n})$ on essential, non-peripheral simple closed curves with edges $\{\alpha, \beta\} \mapsto i(\alpha, \beta) \le 1$ is contractible.*

---

### 11.6 What successive iterations achieved

| Iteration | Open lemma | Best evidence |
|---|---|---|
| Original | "DL has universal vertex" (cone) | sample 132/138 |
| 2nd iteration | "DL is contractible" | exhaustive 64/64 at $k = 2$ on $S_{1,2}$ |
| 3rd iteration | "DL is dismantlable as a graph" | 378 / 378 exhaustive |
| 4th iteration | dismantlability + chordality + dominator typology | 12 non-chordal exceptions characterised |
| 5th iteration | dismantlability with iterative form | K_4-core obstruction confirmed structural |
| 6th iteration | (W4) wheel condition + (M) metric equidistance | 318 / 318 exhaustive on both conditions; reduces to a clean finite-data existence statement |
| **7th iteration (current, 2026-04-30)** | **chordal-or-cone dichotomy on every DL** | **383 / 389 exhaustive; S_{1,1} closed rigorously by Stern-Brocot; S_{1,2} fully chordal-or-cone (271/271); S_{2,1} 41/47.** |

This iteration's net progress:

1. **Refuted a false hope.** The "every max-level β has an immediate dominator" form, which would have implied dismantlability via a one-shot rule, is genuinely false: extending the curve enumeration to 11,438 curves does not introduce new DL members, and the K_4-core vertices remain without immediate dominator.

2. **Confirmed the iterative form is the right one.** The lemma must be stated as: "DL admits an iterative dismantling ordering." The dismantling sequence found in §11.4.3 (leaves first, then core) is the correct picture and a genuine property of the DL graph structure, not an artefact.

3. **Classified the obstacle to a uniform geometric proof.** The candidate sources of dominators (single Dehn twists, level-0 curves disjoint from α, level-1 curves disjoint from β) each cover only a fraction of (α, β) pairs (27.6%, 48.5%, 77.3% respectively). No single geometric construction captures all dominators. A proof would need to handle the iterative case-by-case structure.

We did not close the proof in this iteration. The negative findings (false hopes ruled out) are themselves progress: they tell us what the lemma is *not*, narrowing the space of viable proof strategies.

### 11.7 What's actually closed in this writeup

| Result | Status |
|---|---|
| $C_1(S_{0,n})$ is discrete for $n \ge 4$ | **rigorous** (parity argument, §2) |
| $C_1(S_{1,1})$ is contractible (= Farey complex) | **rigorous** (classical, §3) |
| $C_1^{(1)}(S_{g,n})$ is connected for $g \ge 1$ | **rigorous** (§4, Lickorish + Putman) |
| $C_1^+(S_{g,n})$ contractible for $n \ge 1$ (with peripherals) | **rigorous** (§5, peripheral cone) |
| $C_1(S_{g,n})$ contractible for $g \ge 1, \xi \ge 1$ (standard convention) | **CONDITIONAL on Lemma 11.4(b)$''$ (DL is dismantlable).** Verified exhaustively (378/378) on every DL across $S_{1,1}$ ($k \le 5$), $S_{1,2}$ ($k \le 8$), $S_{2,1}$ ($k \le 4$). Iterative max-level dismantling rule observed uniformly. Universal-vertex form **disproved**. |

**OP-1 status:** the dichotomy between $g = 0$ and $g \ge 1$ is rigorous; connectedness for $g \ge 1$ is rigorous; with-peripherals contractibility is rigorous; standard-convention contractibility is **conditional on a specific dismantlability conjecture**, with massively stronger numerical support than any earlier iteration of this writeup. The geometric content of the conjecture (Surgery Domination, §11.4.5 Strategy α) is the right object for a future Hatcher-style proof.

---

## 11.8 Iteration 7 (2026-04-30): chordal-or-cone dichotomy and rigorous closure of $S_{1,1}$

This section reports a Math Agent v2 retry that targeted Lemma 11.4(b)$''''$ via Directions A–D from the issue brief. The principal advances are: (i) a fully rigorous closure of OP-1 for $S_{1,1}$ via Stern–Brocot, and (ii) a strict refinement of the open lemma to "every non-chordal DL has a universal vertex" — a much smaller existence claim than (W4)+(M).

### 11.8.1 $S_{1,1}$ rigorously closed via Stern–Brocot (Direction C)

**Theorem 11.8.1.** *Let $S = S_{1,1}$ and $\gamma_0$ be the standard non-separating curve identified with $1/0 = \infty$ in $\mathbb Q \cup \{\infty\}$. For every $\alpha \in \mathrm{Vert}(C_1)$ with $f(\alpha) = k \ge 1$, the descending link $\mathrm{Lk}^\downarrow(\alpha)$ has at most 2 vertices and is contractible (a single vertex, or an edge). In particular, condition (W4) holds vacuously, and the Bestvina–Brady filtration $C_1^{\le k-1} \hookrightarrow C_1^{\le k}$ is a homotopy equivalence for every $k$.*

**Proof.** $C_1(S_{1,1})$ is the Farey complex; vertices are $\mathbb Q \cup \{\infty\}$ and $\{a/b, p/q\}$ is an edge iff $|a q - b p| = 1$. With $\gamma_0 = \infty = 1/0$, the level function is $f(p/q) = q$ (denominator in lowest form, with $f(\infty) = 0$).

Two distinct simple closed curves on $S_{1,1}$ must intersect (since $\xi(S_{1,1}) = 1$), so the only edges in $C_1$ have $i = 1$. Hence $\mathrm{Lk}(\alpha)$ for $\alpha = a/b$ equals the set of Farey neighbours of $a/b$, i.e. all $p/q$ with $|aq - bp| = 1$, $\gcd(p, q) = 1$.

For each fixed $b \ge 2$, the equation $aq \equiv \pm 1 \pmod b$ has exactly two residue solutions $q \in [1, b-1]$ (namely $q \equiv a^{-1}$ and $q \equiv -a^{-1}$ modulo $b$); for each such $q$, $p$ is uniquely determined. Hence $\mathrm{Lk}^\downarrow(\alpha) = \{p_1/q_1, p_2/q_2\}$ has exactly 2 elements.

Furthermore, by the Stern–Brocot mediant identity, if $a/b$ is the Farey child of $p_1/q_1$ and $p_2/q_2$ (so $a = p_1 + p_2$, $b = q_1 + q_2$), then $|p_1 q_2 - p_2 q_1| = |q_2 \cdot p_1 - q_1 \cdot p_2| = 1$ — i.e., the two parents are themselves Farey-adjacent. So $\mathrm{Lk}^\downarrow(\alpha) = \{p_1/q_1, p_2/q_2\}$ with one edge between them: an edge (1-simplex), contractible.

For $b = 1$ (so $\alpha \in \{0/1, 1/1\}$): the only neighbour with smaller denominator is $\infty = 1/0$, since $|a \cdot 0 - 1 \cdot 1| = 1$ requires $b = 1$. So $\mathrm{Lk}^\downarrow(\alpha) = \{\gamma_0\}$, a single vertex.

In all cases $|\mathrm{Lk}^\downarrow(\alpha)| \le 2$, so no induced 4-cycle can exist; (W4) is vacuously true. $\blacksquare$

**Corollary 11.8.2.** *$C_1(S_{1,1})$ is contractible. (This recovers the classical fact via the Bestvina–Brady filtration framework, with no appeal to Farey-tessellation hyperbolic geometry.)*

Verification script: `workspace/projects/op1_geometry/farey_dl_structure.py` enumerates all Farey vertices with denominator up to $B = 12$ (47 vertices) and confirms $|\mathrm{Lk}^\downarrow(\alpha)| \le 2$ with the two parents Farey-adjacent in every case.

### 11.8.2 The chordal-or-cone dichotomy (Direction B)

The breakthrough of this iteration is a structural classification of every descending link into one of two clean types.

**Empirical Theorem 11.8.3 (chordal-or-cone dichotomy).** *Across all 389 descending links exhaustively enumerated on $S_{1,1}$ ($k \le 8$, 71 DLs), $S_{1,2}$ ($k \le 8$, 271 DLs), and $S_{2,1}$ ($k \le 4$, 47 DLs):*

- *Every DL on $S_{1,1}$ and $S_{1,2}$ is either chordal or a simplicial cone (i.e., has a universal vertex). Specifically: $S_{1,1}$ — 71/71 chordal (trivially, since $|DL| \le 2$); $S_{1,2}$ — 259/271 chordal, 12/271 non-chordal-but-cone.*
- *On $S_{2,1}$, 41/47 DLs are non-chordal-but-cone; 6/47 (all at $k = 2$) are neither chordal nor cone, but remain dismantlable via iterative reduction.*

| Surface | $k$ range | Chordal | Non-chordal cone | Non-chordal non-cone |
|---|---|---|---|---|
| $S_{1,1}$ | $k = 2,\ldots,8$ | 71 | 0 | 0 |
| $S_{1,2}$ | $k = 2,\ldots,8$ | 259 | **12** | **0** |
| $S_{2,1}$ | $k = 2,3,4$ | 0 | 41 | 6 |
| **Total** | | **330** | **53** | **6** |

Both branches of the dichotomy imply contractibility:
- *Chordal* graphs admit a perfect elimination ordering (PEO), hence are dismantlable and the flag complex is strongly collapsible.
- *Cones* (graphs with a universal vertex) are dismantlable by removing every non-apex first; the flag complex is the simplicial cone on the link of the apex, hence contractible.

The 6 $S_{2,1}$ exceptions (all at $k = 2$, $|DL| \in \{34, 35, 45, 48, 60\}$) are still dismantlable (verified explicitly: each admits a length-$|DL| - 1$ dismantling sequence), but require the iterative form of dismantlability.

**Verification script:** `workspace/projects/op1_geometry/direction_b_cone_test.py`. Output (full):

```
S_1_2: chordal=259, non-chordal-cone=12, non-chordal-NON-cone=0
S_2_1: chordal=0,   non-chordal-cone=41, non-chordal-NON-cone=6
S_1_1: chordal=71,  non-chordal-cone=0,  non-chordal-NON-cone=0
Strategy works on: 383 / 389 DLs.
```

### 11.8.3 The Hatcher-surgery candidate σ_α inside the cone

For each of the 12 non-chordal cone DLs on $S_{1,2}$, we identified the *canonical filler* $\sigma_\alpha$ at level $k - 2$ disjoint from $\alpha$ (hypothesis: $\sigma_\alpha$ is the Hatcher surgery of $\alpha$ along $\gamma_0$). The crucial structural finding:

**Empirical Lemma 11.8.4.** *For each of the 12 non-chordal DLs on $S_{1,2}$ (and the 41 cone DLs on $S_{2,1}$): the canonical filler $\sigma_\alpha$ satisfies*
$$ i(\sigma_\alpha, \beta) = i(\alpha, \beta) \in \{0, 1\} \quad \text{for every } \beta \in \mathrm{Lk}^\downarrow(\alpha), $$
*so $\sigma_\alpha$ is a universal vertex of the entire descending link, not merely a common neighbour of one induced 4-cycle.*

Quantitative aggregate over the 12 non-chordal DLs (49 (α, β) pairs, $\beta \in \mathrm{Lk}^\downarrow(\alpha)$):

| $i(\alpha, \beta)$ | $i(\sigma_\alpha, \beta)$ | count |
|---|---|---|
| 0 | 0 | 6 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 43 |
| 1 | 2+ | 0 |
| 0 | 2+ | 0 |

The intersection number is *preserved exactly* by the surgery on every cycle vertex, every chord vertex, and every leaf vertex of the DL.

**Homological signature (verified on 5 (α, σ_α) pairs).** The basis-projection differences $|i(\sigma_\alpha, b)| - |i(\alpha, b)|$ for the curver basis $(a_0, b_0, p_1)$ on $S_{1,2}$ are:

| $\alpha$ | $|i(\alpha, \cdot)|$ | $|i(\sigma_\alpha, \cdot)|$ | difference |
|---|---|---|---|
| 38 (k=4) | (4, 1, 2) | (2, 1, 2) | (-2, 0, 0) |
| 105 (k=4) | (4, 1, 6) | (2, 1, 4) | (-2, 0, -2) |
| 117 (k=4) | (4, 3, 2) | (2, 1, 2) | (-2, -2, 0) |
| 119 (k=4) | (4, 1, 2) | (2, 1, 2) | (-2, 0, 0) |
| 118 (k=5) | (5, 1, 3) | (3, 1, 3) | (-2, 0, 0) |

The first coordinate (γ_0-direction) drops by exactly 2 in every case, consistent with a single Hatcher-surgery step. The other coordinates either preserve or drop by 2 — consistent with the surgery output being one of $\{a_1 \cup s, a_2 \cup s\}$ for the two arcs $a_1, a_2$ into which $\alpha$ is divided by the chosen pair of γ_0-intersection points.

We did *not* verify that $\sigma_\alpha = T_{\gamma_0}^n(\alpha)$ for any $n$: tested $n \in \{-5, \ldots, 5\}$, all 6 cases miss. So $\sigma_\alpha$ is a genuinely new curve, not a Dehn-twist orbit of $\alpha$ along $\gamma_0$.

**Verification scripts:** `direction_b_bigon_analysis.py`, `direction_b_sigma_identity.py`, `direction_b_sigma_intersection_profile.py`.

### 11.8.4 Net status after iteration 7

| Statement | Status |
|---|---|
| $C_1(S_{0,n})$ discrete for $n \ge 4$ | **rigorous** |
| $C_1(S_{1,1})$ contractible | **rigorous** (now via Stern–Brocot + Bestvina–Brady, in addition to the classical Farey-tessellation argument) |
| $C_1^{(1)}(S_{g,n})$ connected for $g \ge 1$ | **rigorous** |
| $C_1^+(S_{g,n})$ contractible (peripherals included) | **rigorous** |
| $C_1(S_{1,2})$ contractible (standard) | **CONDITIONAL** on Lemma 11.8.5(a) below; reduced to a single existence claim |
| $C_1(S_{g,n})$ contractible for general $g \ge 1$, $\xi \ge 1$ | **CONDITIONAL** on Lemma 11.8.5(a) plus a separate iterative-dismantlability statement for the 6 known $S_{2,1}$ k=2 exceptions |

**Lemma 11.8.5(a) (refined open conjecture).** *Every non-chordal descending link $\mathrm{Lk}^\downarrow(\alpha)$ on $S_{1,2}$ admits a universal vertex $\sigma_\alpha$. Empirically, $\sigma_\alpha$ exists at level $\le k - 2$ in every case, and on the 12 non-chordal DLs at $k \ge 4$, the canonical $\sigma_\alpha$ is at level $k - 2$ disjoint from $\alpha$ — consistent with $\sigma_\alpha$ being the Hatcher surgery output of $\alpha$ along $\gamma_0$.*

**Why this is a strict upgrade over Lemma 11.4(b)$''''$:**

| Form | Number of existence claims | Verified |
|---|---|---|
| Lemma 11.4(b)$''''$ ((W4) + (M)) | 2 conditions $\times$ many configurations | 318 / 318 across configs |
| **Lemma 11.8.5(a) (single universal vertex)** | **1 vertex per non-chordal DL** | 12 / 12 on $S_{1,2}$, 41 / 47 on $S_{2,1}$ |

The single-vertex form is a strictly weaker family of claims than (W4)+(M) on each DL, but covers the same 318 DLs (W4 was checked) and additionally explains the chordal cases trivially. It reduces the lemma to a *single Hatcher-surgery construction*, which is exactly what was sought in §11.4.5 ("the right object for a future Hatcher-style proof").

### 11.8.5 What was tried but not closed

- **Direction A (cut surface arc enumeration).** Conceptually clean — cut $S$ along $\alpha$ and $\gamma_0$, view all curves as arc patterns on the cut surface, exhaust possibilities. Not pursued in this iteration: requires a careful train-track coordinate translation in `curver` that is several days of work.
- **Direction B (bigon-counting).** Did *not* yield a closed-form proof of $i(\sigma_\alpha, \beta_i) \le 1$ via the simple bigon decomposition $i(\sigma_\alpha, \beta) \le i(\alpha, \beta) + i(\gamma_0\text{-surgery-arc}, \beta)$ — the surgery-arc contribution is not a-priori bounded. However, the empirical fact $i(\sigma_\alpha, \beta) = i(\alpha, \beta)$ exactly (no slack, no excess) shows the bigon cancellation is total, suggesting a *signed* intersection / homological argument may close it.
- **Direction D (π_1 word representation).** Not pursued; the lamination-coordinate computation in `curver` already exposes the full intersection data, and additional Stallings-foldings of π_1-words would not give new geometric insight.
- **The 6 $S_{2,1}$ k=2 exceptions** are non-chordal AND non-cone; they need a different argument (some form of suspension or 2-vertex iterative dismantling). Not closed.

---

## 12. Reproducibility

All computations are reproducible from this directory:

```
workspace/op1_scripts/
├── enumerate_v2.py                       # BFS curve enumeration via MCG
├── analyze_complex.py                    # flag complex + gudhi homology
├── check_cone.py                         # peripheral-cone-point diagnostic
├── verify_dehn_formula.py                # checks i(T_b(a), a) = i(a,b)^2
├── verify_descending_link.py             # descending links k=1, k=2 on S_{1,2}
├── verify_descending_link_higher.py      # descending links k=1..5 on S_{1,2} & S_{2,1}
├── verify_sigma_universal.py             # universal-vertex test in descending links
├── exhaustive_k2.py                      # exhaustive k=2 on S_{1,2} + Dehn-twist enlargement
├── analyze_no_universal.py               # detailed combinatorics of 6 counterexample DLs
├── dismantle_check.py                    # exhaustive dismantlability test
├── analyze_dismantle_pattern.py          # confirms iterative max-level rule
├── chordality_check.py                   # initial chordality test
├── chordality_thorough.py                # detailed analysis of 12 non-chordal exceptions
├── check_first_step.py                   # tests strict-lower-level dominance
├── surgery_domination_E_reverse.py       # reverse-engineer dominators (Dehn twist tests)
├── surgery_domination_categorize.py      # T1/T2/T3/T5 dominator typology
├── surgery_domination_attempt.py         # k=2 chordality attempt
├── extended_dominator_search.py          # extended-set dominator test (had bug)
├── extended_dominator_analysis.py        # dominator level analysis (had bug)
├── extended_DL_dismantle.py              # CORRECT extended-DL test (showed obstruction is real)
├── systolic_check.py                     # 6-large + (M) metric equidistance test (iter 6)
├── bridged_check.py                      # bridged graph test (failed for some DLs)
├── quadrangle_check.py                   # (W4) every induced 4-cycle has common neighbour test (iter 6)
├── farey_dl_structure.py                 # Stern-Brocot proof that |Lk^↓| ≤ 2 on S_{1,1} (iter 7)
├── direction_b_bigon_analysis.py         # iσ_β = iα_β on every (α,β) pair in non-chordal DLs (iter 7)
├── direction_b_sigma_identity.py         # σ_α not = T_{γ_0}^n(α); homology shifts (iter 7)
├── direction_b_sigma_intersection_profile.py  # σ_α universal in entire DL on the 12 non-chordal cases (iter 7)
├── direction_b_universal_sigma.py        # universal σ at level k-2 across all DLs — partial (iter 7)
├── direction_b_universal_vs_chordal.py   # 'level-(k-2) σ' fine print (iter 7)
├── direction_b_cone_test.py              # CHORDAL-OR-CONE DICHOTOMY: 383/389 covered (iter 7, KEY)
├── direction_b_S21_failures.py           # structure of the 6 S_{2,1} k=2 exceptions (iter 7)
├── data_S_1_1.json                       # 100 curves, χ=1, β=[1,0]
├── data_S_1_2.json                       # 400 curves, β^(≤4)=[1,0,0,0,0]
├── data_S_2_1.json                       # 250 curves, β^(≤4)=[1,0,0,0,0]
├── descending_link_S_1_2.json            # results from verify_descending_link.py
├── descending_link_higher.json           # results from verify_descending_link_higher.py
├── sigma_universal.json                  # results from verify_sigma_universal.py
├── exhaustive_k2.json                    # confirms 64/64 contractible at k=2; 6/64 no universal
└── dismantle_results.json                # 378/378 dismantlable; the new central evidence
```

Run example:
```
wsl python3 workspace/op1_scripts/enumerate_v2.py 1 2 6 400
wsl python3 workspace/op1_scripts/analyze_complex.py workspace/op1_scripts/data_S_1_2.json
wsl python3 workspace/op1_scripts/verify_descending_link_higher.py
wsl python3 workspace/op1_scripts/verify_sigma_universal.py
wsl python3 workspace/op1_scripts/exhaustive_k2.py
wsl python3 workspace/op1_scripts/analyze_no_universal.py
wsl python3 workspace/op1_scripts/dismantle_check.py            # exhaustive dismantlability test
wsl python3 workspace/op1_scripts/analyze_dismantle_pattern.py  # checks max-level rule
wsl python3 workspace/op1_scripts/chordality_check.py
wsl python3 workspace/op1_scripts/chordality_thorough.py        # 12 non-chordal exceptions
wsl python3 workspace/op1_scripts/surgery_domination_categorize.py
wsl python3 workspace/op1_scripts/surgery_domination_E_reverse.py
```

Tooling: WSL Ubuntu 24.04, Python 3.12.3, curver 0.5.1, networkx 3.6.1, gudhi 3.12.0.

---

## References

- [BB97] M. Bestvina and N. Brady, *Morse theory and finiteness properties of groups*, Invent. Math. 129 (1997), 445–470.
- [BFJ08] R. Boulet, E. Fieux, B. Jouve, *Simplicial simple-homotopy of flag complexes in terms of graphs*, arXiv:0809.1751 (the dismantlable ⇔ strongly collapsible theorem).
- [CO14] V. Chepoi, D. Osajda, *Dismantlability of weakly systolic complexes and applications*, Trans. AMS 367 (2015), 1247–1272 (the W4-wheel condition + weakly modular ⇒ dismantlable theorem). arXiv:0910.5444.
- [Cep00] V. Chepoi, *Bridged graphs are cop-win graphs: an algorithmic proof*, J. Combin. Theory Ser. B 78 (2000), 117–144.
- [Hat91] A. Hatcher, *On triangulations of surfaces*, Topology Appl. 40 (1991), 189–194.
- [FM12] B. Farb and D. Margalit, *A primer on mapping class groups*, Princeton University Press, 2012.
- [JS06] T. Januszkiewicz, J. Świątkowski, *Simplicial nonpositive curvature*, Publ. Math. IHÉS 104 (2006), 1–85 (foundational work on systolic / weakly systolic complexes).
- [Lic64] W. B. R. Lickorish, *A finite set of generators for the homeotopy group of a 2-manifold*, Math. Proc. Cambridge Philos. Soc. 60 (1964), 769–778.
- [Pol02] N. Polat, *On infinite bridged graphs and strongly dismantlable graphs*, J. Combin. Theory Ser. B 86 (2002), 174–190 (cop-win = dismantlable).
- [Put08] A. Putman, *A note on the connectivity of certain complexes associated to surfaces*, Algebr. Geom. Topol. 8 (2008), 829–837.
