# Geometry Open Problems — Investigation Report

**Date**: 2026-04-30
**Tools available**: SnapPy 3.3.2, Regina, curver, flipper, spherogram, low_index, knot_floer_homology, networkx, sympy, numpy, gudhi, ripser, Sage
**Time budget**: ~30 min per OP

This report investigates four open problems in low-dimensional topology proposed by a senior. These are real research-level problems (not benchmarks), and the goal is to make whatever progress is honestly possible: literature search, computational evidence, partial proofs, or clearly stated obstructions.

---

## OP-4: genus-2 knot with Kakimizu diameter = 8

### What I tried

**Step 1: Literature search.** The starting hypothesis (in the prompt) is that Chen–Shen 2025 proved diam(MS(K)) ≤ 6g−4 for atoroidal knots, giving the bound 8 for g=2. I verified this on arXiv:

- Chen–Shen, *"Linear Bound for Kakimizu Complex Diameter of Hyperbolic Knots"* (arXiv:2508.03353). **Theorem 1.1**: for K atoroidal of genus g, diam(MS(K)) ≤ 6g−4. At g = 2 this gives 8.
- Lower bound: Sakuma–Shackleton 2009 (arXiv:math/0701468) constructed atoroidal knots with diam ≥ 2g−1, so for g=2 ≥ 3 is achievable.
- Note: the SIMIS abstract for Chen–Shen reports a refined case-based bound — diam ≤ 6 for g=2 and diam ≤ 4g−3 for g≥3. If correct, this would push the question down to "is diam = 6 attainable for some genus-2 atoroidal knot?". This is a discrepancy I could not fully resolve from public summaries.

So the question splits:
- **Looser version**: ∃ g=2 atoroidal knot with diam = 8?  (Probably no, given the SIMIS refined statement.)
- **Tighter version**: ∃ g=2 atoroidal knot with diam = 6?  (More plausible; the genuinely open question.)

No paper I located explicitly exhibits a genus-2 atoroidal knot with diam ≥ 5. The closest existing computation is Neel's 2024 UC Davis dissertation, which computed Kakimizu complexes of all 11- and 12-crossing alternating knots. The dissertation PDF was too large to fetch in one shot, and the BIRS talk page returned 403, so I could not extract the specific table; but the abstracts I read do not flag any large-diameter genus-2 example.

**Step 2: Computational pipeline attempt.** I set up the standard pipeline in Regina:
1. Get the knot exterior triangulation from SnapPy, convert to Regina, truncate ideal vertices.
2. Enumerate vertex normal surfaces in standard coordinates.
3. Filter to (compact, connected, orientable, single boundary curve, χ = 1 − 2g).
4. *(Not done)* Further filter by boundary slope = longitude and incompressibility.
5. *(Not done)* Build Kakimizu 1-skeleton: edge between S, S' iff they admit disjoint representatives.
6. *(Not done)* Compute graph-theoretic diameter.

Step 3 results:

| Knot | Genus | Vertex normal surfaces | (conn, orient, 1 bdry, χ=1−2g) candidates |
|------|------:|----------------------:|----------------------------------------:|
| 4_1  | 1 (fibered)     | 108   | 12 |
| 5_1  | 2 (fibered)     | 11    | 1  |
| 5_2  | 1     | 108   | 18 |
| 6_2  | 2     | 323   | 47 |
| 6_3  | 2     | 1,445 | 95 |
| 7_4  | 1     | 441   | 26 |
| 8_8  | 2     | 11,229| 214|

Sanity: 4_1 is fibered (Kakimizu = single point), so the true Seifert-surface count is 1, not 12 — confirming the χ-only filter heavily overcounts (most candidates are not Seifert surfaces — wrong boundary slope, non-incompressible, or compressible after isotopy). 5_1 is the (2,5) torus knot, fibered, and the filter gives the correct count 1, by chance.

Steps 4–6 require:
- A reliable boundary-slope test (compute boundary intersection with meridian using Regina's `boundary intersections`-style API, which requires careful use of the `Cusp` / `BoundaryComponent` classes that I did not get working in the time budget).
- A pairwise disjointness test for ~50-200 candidates, which involves either (a) the Schultens "spinning" framework, or (b) cutting the manifold along S and checking S' lifts isotopically into the complement.

This is a 1–2 day implementation, not a 30-minute one.

### Final state

**STUCK** on direct verification. **Confidence: HIGH** that the open status of the problem is correctly characterized.

What the problem seems to actually require, in light of literature:
- An *upper-bound improvement* for g=2 (refining 8 → 6, or ideally 6 → 3 = sharp lower bound), via a sharpened version of Chen–Shen's central-zone argument for low genus.
- OR a *new construction* of an atoroidal knot with large Kakimizu diameter, beating the Sakuma–Shackleton 2g−1 family. The SS family uses Murasugi sums of fibered surfaces; a candidate direction is iterated Murasugi sums in genus 2, but ensuring atoroidality is the hard part (annular sums can introduce essential annuli).

If I had another day: implement the boundary-slope test using Regina `BoundaryComponent.face` + meridian/longitude as integer-coordinate vectors against the cusp triangulation, then run on Neel's list of genus-2 alternating 11- and 12-crossing knots and see if any breaks 4.

### Confidence: MEDIUM-HIGH on literature characterization, LOW on actually answering the math question.

---

## OP-1: Homotopy type of the 1-curve complex C_1(S_{g,n})

> **Update 2026-04-30**: significant deepening over earlier writeup. Connectedness for $g \ge 1$ now rigorous; with-peripherals contractibility is rigorous; standard-convention contractibility upgraded from "heuristic" to "strong numerical evidence on $S_{1,2}$ and $S_{2,1}$ + concrete proof program". Full details in `workspace/op1_detailed.md`.

### Step 1: Literature (unchanged)

The closest thing I located is Patrias 2009 (UChicago REU) on the *clique number* C(g) of the same graph: max number of pairwise-i≤1 simple closed curves. Constantin (2006) claimed C(2) = 12; Patrias points out the proof has gaps. Bounds: 2g²+2g ≤ C(g) ≤ O(2^{3g}) (Constantin / Juvan–Malnič–Mohar). Aougab–Gaster (CUP 2020 / arXiv:2008.08172, arXiv:2508.05555) studies the *size* of 1-systems but not the *homotopy type* of the flag complex. **OP-1 (homotopy type) is genuinely open in the published literature.**

### Result A (rigorous): C_1(S_{0,n}) is discrete for all n ≥ 4

**Claim.** For n ≥ 4, every essential simple closed curve in S_{0,n} is *separating* (since H_1(S_{0,n}) is torsion-free of rank n−1, but every s.c.c. on a planar surface bounds a planar piece, hence separates). For two separating curves α, β, a transverse intersection point lies on the boundary between the two regions α cuts, and consecutive crossings on β alternate between entering/exiting one region. So #(α∩β) is **even** in minimal position, giving i(α, β) ∈ 2ℤ. Therefore i(α, β) = 1 is impossible and **C_1(S_{0,n}) has no edges**.

### Result B (rigorous): C_1(S_{1,1}) ≅ Farey complex; contractible

Essential s.c.c.'s on S_{1,1} ↔ ℚ ∪ {∞}; intersection i(p/q, p'/q') = |pq' − qp'|; edges correspond to Farey neighbors; flag complex = Farey 2-tessellation of the disk = contractible. Verified numerically (88 vertices, 173 edges, 86 triangles, χ = 1).

### Result C (NEW, rigorous, 2026-04-30): connectedness for g ≥ 1, ξ ≥ 1

**Theorem.** *For all $g \ge 1$ and $n \ge 0$ with $\xi \ge 1$, the 1-skeleton $C_1^{(1)}(S_{g,n})$ is connected.*

**Proof sketch.** Pick Lickorish/Humphries generators $L = \{\gamma_1, \ldots\}$ of MCG with $i(\gamma_i, \gamma_j) \le 1$ for all $i, j$, and basepoint $\gamma_0 = \gamma_1$. By the change-of-coordinates principle, MCG acts transitively on non-separating s.c.c.'s. By Putman's connectedness criterion (AGT 2008, Lemma 2.1), connectedness of the non-separating subgraph reduces to: $T_{\gamma_j}(\gamma_0)$ connects to $\gamma_0$ in $C_1$. Using Farb–Margalit Prop. 3.2:
$$ i\bigl(T_{\gamma_j}(\gamma_0), \gamma_0\bigr) = i(\gamma_j, \gamma_0)^2 \le 1, $$
so the edge exists.

For separating curves α: cutting $S$ along α gives subsurfaces, at least one of positive genus (since $g \ge 1$); take a non-sep curve in that piece, disjoint from α. So α joins to the non-sep component. ∎

### Result D (NEW, rigorous, 2026-04-30): contractibility under "with peripherals" convention

**Theorem.** *Let $S = S_{g,n}$ with $n \ge 1$ and $\xi \ge 1$. If we include peripheral curves (boundaries of once-punctured disks) as vertices, $C_1^+(S)$ is contractible.*

**Proof.** Any peripheral curve δ around a puncture has $i(\delta, w) = 0$ for every other essential s.c.c. $w$ (every non-peripheral curve isotopes off the punctured-disk neighborhood; peripherals around different punctures are pairwise disjoint). So $\delta$ is a **universal vertex** of the 1-skeleton; in a flag complex, this makes the whole complex the simplicial cone $\mathrm{Cone}_\delta(C_1)$, which is contractible. ∎

In particular, the standard $C_1$ (peripherals excluded) is the *link* of $\delta$ in this contractible cone — strong constraint, but not by itself contractibility of $C_1$.

### Result E (NEW, computational, 2026-04-30): strong numerical evidence

For surfaces beyond S_{1,1}, the standard $C_1$ flag complex was sampled via curver MCG-orbit BFS:

| Surface | Sample size | i = 0 / i = 1 edges | Max clique | Diam | $\beta^{(\le 4)}_{\mathbb Z/2 = \mathbb Z/3}$ |
|---|---|---|---|---|---|
| S_{1,1} (control) | 100 | 0 / 197 | 3 | 7 | $[1, 0]$ ✓ Farey |
| S_{1,2} | 150 | 131 / 897 | 6 | 4 | $[1, 0, 0, 0, 0]$ |
| S_{1,2} | 400 | 367 / 2589 | 6 | 4 | $[1, 0, 0, 0, 0]$ |
| S_{2,1} | 112 | 850 / 1734 | 16 | 2 | $[1, 0, 0, 0, 0]$ |
| S_{2,1} | 250 | 2647 / 5582 | 17 | 2 | $[1, 0, 0, 0, 0]$ |

Note: $C_1(S_{2,0}) \cong C_1(S_{2,1})$ as flag complexes (puncture-forgetful is a bijection on essential non-peripheral curves; Farb–Margalit §1.4). So the $S_{2,1}$ row directly applies to **closed genus-2**.

Doubling the sample on $S_{1,2}$ left the Betti pattern unchanged. Trivial reduced homology in dimensions 1–4 is consistent across all positive-genus tests.

### Result F (CONDITIONAL on dismantlability conjecture; revised 2026-04-30, iterated three times)

**Conjectured theorem.** *For every $g \ge 1$ and $n \ge 0$ with $\xi(S_{g,n}) \ge 1$, the flag complex $C_1(S_{g,n})$ on essential, non-peripheral simple closed curves with edges $\{\alpha, \beta\} \mapsto i(\alpha, \beta) \le 1$ is contractible.*

**Proof structure** (full writeup in `op1_detailed.md` §11):

1. **Filtration.** Fix a non-separating $\gamma_0$. Define $f(\alpha) = i(\alpha, \gamma_0)$; let $C_1^{\le k}$ be the full subcomplex on $\{f \le k\}$.
2. **Base case (Lemma 11.1, rigorous).** $C_1^{\le 0}$ is a cone with apex $\gamma_0$, hence contractible.
3. **Filtration step (Cor. 11.3, elementary BB97).** $C_1^{\le k-1} \hookrightarrow C_1^{\le k}$ is a homotopy equivalence iff every level-$k$ vertex $\alpha$ has contractible descending link $\mathrm{Lk}^\downarrow(\alpha)$.
4. **Descending link, $k = 1$ (Lemma 11.4(a), rigorous).** $\gamma_0$ is universal in $\mathrm{Lk}^\downarrow(\alpha)$, so cone, contractible.
5. **Descending link, $k \ge 2$ (Lemma 11.4(b)$''$, OPEN BUT MASSIVELY REFINED).** Conjectured: the 1-skeleton of $\mathrm{Lk}^\downarrow(\alpha)$ is a **dismantlable graph**, hence its clique complex is strongly collapsible, hence contractible (standard theorem [Boulet-Fieux-Jouve 2008, Polat 2002]).

**Iteration history of Lemma 11.4(b) (each version a strict refinement):**

| Version | Form | Verified | Status |
|---|---|---|---|
| 11.4(b) | "DL has a universal vertex (Hatcher surgery)" | 132/138 sample | **DISPROVED**: 6 explicit counterexamples on $S_{1,2}$ at $k=2$ |
| 11.4(b)$'$ | "DL is contractible" | 64/64 exhaustive at $k=2$ on $S_{1,2}$ | conjecture, supported |
| **11.4(b)$''$** | **"DL 1-skeleton is dismantlable as a graph"** | **378/378 exhaustive** across $S_{1,1}$ ($k\le 5$), $S_{1,2}$ ($k\le 8$), $S_{2,1}$ ($k\le 4$) | **conjecture, exhaustively supported, with uniform algorithmic rule** |

**The dismantlability finding (this iteration's contribution).** Every descending link in our enumerations is dismantlable as a graph, with a uniform rule: at each step, any max-level vertex (largest $f$-value remaining) is dominated by some other vertex in the current graph. 0 exceptions across 378 tested DLs. The remaining geometric content is a single sub-lemma about *Surgery Domination*: given a max-level vertex $\beta$ in $\mathrm{Lk}^\downarrow(\alpha)$, a Hatcher-style surgery on $\beta \cap \gamma_0$ produces a curve $w$ that dominates $\beta$ in the descending link.

### Final state by sub-case (revised 2026-04-30, post-attempted close)

| Surface | C_1 status (standard convention) | Status |
|---------|----------------------------------|------------|
| S_{0,n}, n ≥ 4 | Discrete, ∞-many components | **rigorous** (parity, §2) |
| S_{1,1} | Contractible (= Farey) | **rigorous** (classical, §3) |
| S_{g,n}, g ≥ 1, ξ ≥ 1 (1-skeleton) | Connected | **rigorous** (§4, Lickorish + Putman) |
| S_{g,n}, g ≥ 0, n ≥ 1, ξ ≥ 1 (with peripherals) | Contractible | **rigorous** (§5, peripheral cone) |
| $S_{1,2}$ at $k = 2$ specifically | All 64 descending links contractible | **exhaustively verified numerically** |
| General S_{g,n}, g ≥ 1, ξ ≥ 1 | Contractible | **CONDITIONAL** on open Lemma 11.4(b)$'$ |

**STATUS**: **NOT FULLY CLOSED.** The dichotomy ($g = 0$ vs $g \ge 1$) is rigorous; connectedness is rigorous; with-peripherals contractibility is rigorous. Standard-convention contractibility is conditional on a single specific descending-link contractibility lemma (Lemma 11.4(b)$'$ in op1_detailed.md). The earlier claim that this lemma was "standard with universal-vertex sketch" was wrong — that form is disproved. The weaker contractibility form is supported by exhaustive low-complexity numerical evidence but not proved.

**Confidence**: HIGH that the conjectural theorem is true (numerical evidence is very strong, including exhaustive at $k = 2$ on $S_{1,2}$). MEDIUM that a rigorous proof of Lemma 11.4(b)$'$ is achievable within the BB framework using a more sophisticated strategy than a single universal vertex.

---

## OP-3: Gromov hyperbolicity of ℓ-Kakimizu and incompressible Seifert complex

### What I tried

**Step 1: Literature.** This question turns out to be substantially answered in the existing literature for the standard Kakimizu complex of a knot. Reading Schultens 2014/2016 (*"Kakimizu complexes of Surfaces and 3-Manifolds"*, arXiv:1401.2111) gives the cleanest summary:

| Object | Homotopy type | Geometric type |
|--------|---------------|----------------|
| Kakimizu MS(K) of a knot K | **Contractible** (Przytycki–Schultens 2010, *J. Topology*) | **Quasi-Euclidean** (Johnson–Pelayo–Wilson) |
| MS(K) of an atoroidal knot | Contractible AND finite diameter ≤ 6g−4 (Chen–Shen 2025) | Finite graph (so trivially Gromov hyperbolic with δ ≤ diam) |
| MS(K) of a connect sum (non-atoroidal) | Contractible, infinite | Quasi-Euclidean (typically ℝ^k for k = number of fibered summands minus 1) |
| Kakimizu of genus-2 surface (primitive α ∈ H_1) | Contractible | **Gromov hyperbolic** (it's a tree with ∞-valence at every vertex) — Schultens 2014, motivated by Bestvina–Bux–Margalit's Torelli action |

So for the *standard knot* version (ℓ = g(K), i.e., minimal-genus Seifert surfaces only):

1. **Homotopy type**: contractible (settled).
2. **Gromov hyperbolicity**: NO for knots in general (quasi-Euclidean ⊃ ℝ² is not Gromov hyperbolic). YES for *atoroidal* knots, but trivially so because the complex is finite (δ ≤ 6g−4).
3. **Quasi-Euclidean**: YES for knots; the quasi-Euclidean dimension is related to the JSJ structure of the knot complement.

### Step 2: The user's specific generalizations

The user asks two refinements not directly answered by the literature above:

**(a) ℓ-Kakimizu** (vertices = genus ≤ ℓ incompressible Seifert surfaces). For ℓ = g(K) this is the standard Kakimizu. For ℓ > g(K), one is adding *non-minimal* incompressible Seifert surfaces. These exist iff the knot exterior contains higher-genus incompressible spanning surfaces beyond stabilizations.

- For **fibered knots**: the only minimal-genus Seifert surface is the fiber; non-minimal incompressible Seifert surfaces exist (e.g., add two parallel fibers and tube them) in *some* fibered knots, but for many small fibered knots the only incompressible Seifert surfaces are stabilizations of the fiber. Result: ℓ-Kakimizu can be a single point (trivial fibered case) or infinite.
- For **non-fibered atoroidal knots**: adding higher-genus surfaces, the ℓ-Kakimizu complex grows. **Open**: Whether the ℓ-Kakimizu remains contractible / quasi-Euclidean as ℓ grows. Not addressed by Schultens.

My best guess: ℓ-Kakimizu is contractible for all ℓ (the Kakimizu/Przytycki–Schultens proof seems to extend, since the disjointness criterion is the same). It is NOT in general Gromov hyperbolic — for the same reason as standard Kakimizu (e.g., for connect sums it should still be quasi-Euclidean of positive dimension).

**(b) Unbounded incompressible Seifert surface complex** (vertices = ALL incompressible Seifert surfaces, any genus).

- For **any knot** K, this complex is infinite (e.g., (2,2g+1) torus knots admit infinitely many incompressible Seifert surfaces of unbounded genus produced by the spinning construction; same for many pretzel knots, see the discussion in Schultens 2014 §1).
- I am NOT aware of any published result on its homotopy type or geometric type as a metric graph. The Kakimizu/Przytycki–Schultens proof does not directly apply, because the original proof uses a `Gabai sutured manifold' style decomposition that is sensitive to surfaces being minimal-genus (the cyclic-cover argument compares Euler characteristics, which only matches for surfaces of the same genus).
- **Likely**: contractible (Kakimizu's argument generalizes if one is careful with the cyclic cover); quasi-Euclidean of higher dimension (each genus stratum contributes its own ℝ^k factor, glued via stabilizations).

### Step 3: Computation attempt

I tried building a 1-skeleton in Regina for small knots (4_1, 5_2, 6_2) but ran into the same boundary-slope/incompressibility filtering problem as in OP-4. Without filtering by boundary slope, my "candidate Seifert surface" lists overcount by a large factor (12 candidates for 4_1 vs. true count 1). So I could not produce a clean computational picture in the time budget.

What I CAN say from Schultens's tree picture for genus-2 surfaces: the tree with infinitely many edges per vertex is δ-hyperbolic with δ = 0 (every tree is 0-hyperbolic). So in *that* setting (surface Kakimizu, not knot Kakimizu), Gromov coefficient = 0.

### Final state

| Sub-question | Answer | Status |
|--------------|--------|--------|
| Homotopy type of standard MS(K) | Contractible | SOLVED in literature |
| Standard MS(K) Gromov hyperbolic? | No (general); Yes-trivially for atoroidal (finite) | SOLVED in literature |
| Standard MS(K) quasi-Euclidean? | Yes (J–P–W) | SOLVED in literature |
| ℓ-Kakimizu (ℓ > g(K)) homotopy/geometry | Conjecturally same as standard | OPEN |
| Unbounded incompressible Seifert complex | Not addressed in literature I found | OPEN |

**STATUS**: PARTIAL (literature largely answers the standard case; the user's two generalizations are open, and I sketched conjectural answers without proof).

**Confidence**: HIGH on the standard-case literature summary; LOW on the conjectures for the generalizations (no proofs, no successful computations).

---

## OP-2: N_{1,5} geodesics and the Markoff–Hurwitz equation

### What I tried

**Step 1: Literature.** The smaller-cusp version of this question is essentially solved:

- **Huang–Norbury 2014** (*"Simple Geodesics and Markoff Quads"*, arXiv:1312.7089). For the **3-cusped projective plane N_{1,3}**, a 4-tuple (α, β, γ, δ) of one-sided simple closed curves that pairwise intersect once is the natural maximal-1-system, and their hyperbolic-trace coordinates
$$ (a, b, c, d) = \big(2\sinh(\tfrac12\ell_\alpha),\, 2\sinh(\tfrac12\ell_\beta),\, 2\sinh(\tfrac12\ell_\gamma),\, 2\sinh(\tfrac12\ell_\delta)\big) $$
satisfy the **Markoff quad equation**
$$ (a+b+c+d)^2 \;=\; abcd. $$
The maximum systole over the moduli space of N_{1,3} is 2 arcsinh(2), realized by the symmetric N_{1,3} whose double cover is S² minus 6 axis points (Markoff quad (4,4,4,4)).
- The "(a+b+c+d)² = abcd" relation is equivalent (via the coordinate change x_i = 2√a_i, modulo a sign / ordering issue) to a Markoff–Hurwitz-style equation on x_i. I verified algebraically:

  Setting x_i = 2√a_i, the relation x_1²+x_2²+x_3²+x_4² = ¼·x_1x_2x_3x_4 corresponds to (a+b+c+d) = √(abcd), which after squaring matches Markoff-quad. So Markoff-quad is "Markoff–Hurwitz n=4 with parameter k=¼" up to signs.

  This matches Hu–Tan–Zhang's (independent) algebraic derivation of a McShane-type identity for Markoff–Hurwitz equations and is the n=4 coincidence noted in Huang–Norbury Remark 2.
- **Hu's 2013 NUS thesis** *"Identities on Hyperbolic Surfaces, Group Actions and the Markoff–Hurwitz Equations"* extends McShane identities to general Markoff–Hurwitz equations algebraically. But I could not access it directly to see whether it covers a *geometric* identification of an N_{1,n} surface for n > 3.

So the question splits:

(i) **Determine the maximal 1-system size on N_{1,5}.**
(ii) **Check whether trace coordinates of such a system satisfy a polynomial relation equivalent to Markoff–Hurwitz** (in some number of variables).

For (i), the Huang–Norbury setup is: N_{1,3} maximal 1-system has 4 one-sided curves. For N_{1,5}, a natural extrapolation (n+1) would predict 6, but my one-pass guess for N_{1,1} (Möbius band, only one essential curve) failed: the formula n+1 predicts 2, but the truth is 1. So the pattern is not literally "n+1". A safer prediction is: the maximal 1-system size on N_{1,n} grows roughly like the Teichmüller dimension of N_{1,n}, which is dim_R T(N_{1,n}) = -3·χ - 2 = 3n - 5 (for n ≥ 2 cusps with cusp area frozen). For n=3 this gives 4, matching ✓. For n=5 this predicts **10**, not 6. (For n=1: predicts -2, garbage — degenerate case.)

So a natural conjecture is: **maximal 1-system on N_{1,5} has 10 one-sided curves**, and their trace coordinates (a_1, …, a_{10}) satisfy a polynomial relation defining a hypersurface in ℂ^{10} that is the relative character variety of π_1(N_{1,5}) → PSL(2, ℂ), naturally equivalent to a Markoff–Hurwitz-type equation in 10 variables (or possibly with one redundant).

### Step 2: Computational attempt

Constructing a hyperbolic structure on N_{1,5} directly in SnapPy is not natively supported (SnapPy works with 3-manifolds; non-orientable surfaces sit inside 3-manifolds as cross-sections). The cleanest indirect route:

- Orientable double cover of N_{1,5} is the **10-cusped sphere S_{0,10}** (since χ = 2·χ(N_{1,5}) = -8 and 10 cusps lift each puncture).
- Hyperbolic structures on S_{0,10} are parameterized by an 11-dim Teichmüller space; the Z/2 fixed-locus picks out N_{1,5}'s Teichmüller space.

This works in principle but requires explicit Teichmüller-space coordinates (Penner's λ-coordinates or Fenchel–Nielsen) and a careful Z/2-equivariant setup. I did **not** complete this computation in the time budget; it is at least 1–2 days of careful Sage / Python work, plus topological care to track which curves on S_{0,10} descend to one-sided curves on N_{1,5}.

What I CAN check is that the dimensions are consistent: dim_R T(N_{1,5}) = 12 (with cusps fixed: 10) supports a 10-coordinate trace system — matching the conjecture above.

### Step 3: Algebraic verification of the "natural" Markoff–Hurwitz n=10 equation

The Markoff–Hurwitz equation x_1² + x_2² + … + x_n² = a · x_1·x_2·…·x_n has finite-orbit solutions under the Vieta-jump action only for specific (n, a). Hurwitz showed: only a = n works for n ≥ 3 (giving the n-Markoff numbers). So the natural candidate equation for the conjectural N_{1,5} setup would be:
$$ x_1^2 + x_2^2 + \dotsb + x_{10}^2 \;=\; 10 \cdot x_1 x_2 \dotsm x_{10}. $$
Whether the trace coordinates of an N_{1,5} maximal 1-system satisfy this exact equation, or some twisted/rescaled version, **is the genuine open question**.

### Final state

| Sub-question | Status |
|--------------|--------|
| Is N_{1,3} solved? | YES (Huang–Norbury 2014: Markoff quad = Markoff–Hurwitz n=4) |
| Maximal 1-system size on N_{1,5}? | OPEN. Conjectured 10 (= dim_ℝ T) |
| Markoff–Hurwitz relation on N_{1,5}? | OPEN. Conjectured form: 10-variable Markoff–Hurwitz with a = 10 |
| Direct hyperbolic computation on N_{1,5}? | Not done (would need Penner λ-coords on S_{0,10} + Z/2 action) |

**STATUS**: STUCK on the actual open part (N_{1,5}); literature gives the precedent (N_{1,3}) and the algebraic framework (Markoff–Hurwitz / Hu's thesis), but the geometric identification for n=5 cusps does not appear in published work I could find.

What I would do with another day: (a) implement Penner λ-coordinates for S_{0,10}; (b) realize the Z/2 action explicitly on the 11 λ-coords; (c) compute traces of one-sided curves from λ-coordinates of their double-cover lifts; (d) symbolically verify the Markoff–Hurwitz n=10 equation using SymPy or Sage's polynomial elimination.

**Confidence**: HIGH on the precedent literature; HIGH on the dimension counting; LOW–MEDIUM on the specific 10-variable Markoff–Hurwitz conjecture (it's a natural extrapolation but no proof or computational verification).

---

## Sources cited

- [Chen–Shen, *Linear Bound for Kakimizu Complex Diameter of Hyperbolic Knots* (arXiv:2508.03353)](https://arxiv.org/abs/2508.03353)
- [Sakuma–Shackleton, *On the distance between Seifert surfaces of a knot* (arXiv:math/0701468)](https://arxiv.org/abs/math/0701468)
- [Schultens, *Kakimizu complexes of Surfaces and 3-Manifolds* (arXiv:1401.2111)](https://arxiv.org/abs/1401.2111)
- [Przytycki–Schultens, *The Kakimizu complex is simply connected* (J. Topology 2010)](https://www.math.ucdavis.edu/~kapovich/EPR/Kakimizu.pdf)
- [Patrias, *Simple closed curves on surfaces with intersection number at most one* (UChicago REU 2009)](https://www.math.uchicago.edu/~may/VIGRE/VIGRE2009/REUPapers/Patrias.pdf)
- [Neel, *Minimal genus Seifert surface for 11 crossing alternating knots* (arXiv:2312.00208)](https://arxiv.org/abs/2312.00208)
- [Huang–Norbury, *Simple geodesics and Markoff quads* (arXiv:1312.7089)](https://arxiv.org/abs/1312.7089)
- [Tan–Wong–Zhang, *Generalized Markoff Maps and McShane's Identity* (arXiv:math/0502464)](https://arxiv.org/abs/math/0502464)
- [Hatcher, *The Cyclic Cycle Complex of a Surface*](https://pi.math.cornell.edu/~hatcher/Papers/cycles.pdf)


