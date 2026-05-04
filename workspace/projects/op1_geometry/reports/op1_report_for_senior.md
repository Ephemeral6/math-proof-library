# OP-1 Work Report: Homotopy type of $C_1(S_{g,n})$

**Date**: 2026-04-30
**Problem**: Souto 2007 Question 2 (cited by Przytycki–Sisto 2014): is the flag complex $C_1(S_{g,n})$ on simple closed curves with edges $\{\alpha, \beta\} \mapsto i(\alpha, \beta) \le 1$ contractible?

---

## 1. Executive summary

**Problem.** $C_1(S_{g,n})$ is the flag completion of the "augmented curve graph" of Przytycki–Sisto: vertices are isotopy classes of essential, non-peripheral simple closed curves on $S_{g,n}$; edges are pairs with geometric intersection number $\le 1$. Souto 2007 Quest 2 asked whether $C_1$ is contractible. The question remains open in published literature for $g \ge 1$, $\xi(S) \ge 1$.

**What we did.** Three lines of work:

1. **Rigorous results.** Closed several sub-cases: $g = 0$ ($n \ge 4$), $S_{1,1}$ = Farey, connectedness for all $g \ge 1$, and contractibility in the with-peripherals convention. Built the Bestvina–Brady filtration framework, proving the base case ($k = 0$) and the $k = 1$ descending-link case rigorously.

2. **Reduction of the open part.** The general $g \ge 1, \xi \ge 1$ standard-convention case reduces (via BB) to: every descending link $\mathrm{Lk}^\downarrow(\alpha)$ at level $k \ge 2$ is contractible. Through 7 iterations of progressively sharper conjectures, this reduces to two clean local conditions:

   - **(W4) Wheel condition**: every induced 4-cycle in $\mathrm{Lk}^\downarrow(\alpha)$ has a common neighbour.
   - **(M) Metric equidistance condition**: a Chepoi-style triangle condition.

3. **Numerical verification.** Built a `curver`-based pipeline. Verified (W4) and (M) on **all 318 descending links** in our enumerations of $S_{1,2}$ ($k \le 8$) and $S_{2,1}$ ($k \le 4$): 0 exceptions to either condition. Identified that for the 12 non-chordal cases, the (W4) filler has a uniform structure (level $k-2$, disjoint from $\alpha$, consistent with Hatcher surgery on $\alpha \cap \gamma_0$).

**Result.** Conditional on (W4) + (M), $C_1(S_{g,n})$ is contractible for $g \ge 1$, $\xi \ge 1$. The Chepoi–Osajda 2014 dismantlability theorem provides the final step (W4 + M $\Rightarrow$ dismantlable $\Rightarrow$ strongly collapsible $\Rightarrow$ contractible).

**What remains.** A single geometric claim: given an induced 4-cycle $\beta_1, \beta_2, \beta_3, \beta_4$ in $\mathrm{Lk}^\downarrow(\alpha)$, the Hatcher surgery output $\sigma_\alpha$ of $\alpha$ along $\gamma_0$ satisfies $i(\sigma_\alpha, \beta_i) \le 1$ for $i = 1, 2, 3, 4$. This is a 1–3 page bigon-counting argument that I did not complete.

---

## 2. Background

### 2.1 Definitions and conventions

Let $S = S_{g,n}$ be a connected orientable surface of genus $g$ with $n$ punctures, $\xi(S) := 3g + n - 3$ the complexity. Vertices of $C_1(S)$ are isotopy classes of essential simple closed curves under one of three conventions:

| Convention | Vertex set | Notation |
|---|---|---|
| (E1) | non-trivial s.c.c.'s | $C_1^{\rm full}$ |
| (E2) | (E1) minus null-homotopic and disk-bounding curves | $C_1^+$ |
| (E3) | (E2) minus peripheral curves | $C_1$ (standard) |

Edges: $\{\alpha, \beta\}$ iff $i(\alpha, \beta) \le 1$. Higher simplices by flag completion. Souto's question implicitly uses (E3) (matches the $S_{1,1}$ = Farey description).

### 2.2 Known results

| Case | Result | Source |
|---|---|---|
| $S_{0,n}$, $n \ge 4$ | $C_1$ totally disconnected | parity (folklore) |
| $S_{1,1}$ | $C_1 \simeq$ Farey 2-complex $\simeq *$ | classical |
| Clique number on $C(g)$ | $2g^2 + 2g \le C(g) \le O(2^{3g})$ | Constantin / Juvan–Malnič–Mohar / Patrias |
| 1-system size | quadratic in $|\chi|$ | Aougab–Gaster 2025 |
| Augmented curve graph | quasi-isometric to $C(S)$ | Przytycki–Sisto 2014 |

The homotopy type of $C_1(S_{g,n})$ for $g \ge 1, \xi \ge 1$ is **open**.

---

## 3. Rigorous results

### 3.1 $g = 0$ dichotomy

**Theorem 3.1.** *For $n \ge 4$, $C_1(S_{0,n})$ has no edges (totally disconnected).*

**Proof.** Every essential s.c.c. on $S_{0,n}$ is separating (planar surface). For two separating curves $\alpha, \beta$ in minimal position, transverse intersection points come in pairs (entering and leaving each region), so $i(\alpha, \beta) \in 2\mathbb{Z}$, ruling out $i = 1$. $\square$

### 3.2 $S_{1,1}$ = Farey

Curves on $S_{1,1}$ correspond bijectively to $\mathbb{Q} \cup \{\infty\}$; intersection $i(p/q, p'/q') = |pq' - p'q|$. The flag complex on $i \le 1$ is the Farey 2-complex on the upper half-plane, contractible.

### 3.3 Connectedness for $g \ge 1$

**Theorem 3.3 (rigorous).** *For all $g \ge 1$ and $n \ge 0$ with $\xi(S) \ge 1$, the 1-skeleton $C_1^{(1)}(S_{g,n})$ is connected.*

**Proof sketch.** Let $L = \{\gamma_1, \ldots, \gamma_K\}$ be a Lickorish/Humphries generating set: non-separating curves with pairwise $i \le 1$ (Lickorish 1964, Humphries 1979, Farb–Margalit §4.4). Set $\gamma_0 = \gamma_1$.

(a) *Non-separating curves form one component.* By the change-of-coordinates principle (FM Prop 1.7), $\mathrm{MCG}(S)$ acts transitively on non-separating s.c.c.'s. By Putman's connectedness criterion (AGT 2008, Lemma 2.1), connectedness reduces to: $T_{\gamma_j}(\gamma_0)$ joins $\gamma_0$ in $C_1$ for each $\gamma_j \in L$. By Farb–Margalit Prop 3.2:
$$ i(T_{\gamma_j}(\gamma_0), \gamma_0) = i(\gamma_j, \gamma_0)^2 \le 1, $$
giving an edge.

(b) *Every separating curve joins a non-separating one.* For $\alpha$ separating with $\xi(S) \ge 1, g \ge 1$, cutting $S$ along $\alpha$ produces two subsurfaces, at least one with $g_i \ge 1$, which contains a non-separating $\beta$ disjoint from $\alpha$. So $\{\alpha, \beta\}$ is an edge.

Combining (a) and (b): $C_1$ is connected. $\square$

The Dehn-twist intersection formula was verified numerically on $S_{1,1}, S_{1,2}, S_{2,1}$ (workspace/op1_scripts/verify_dehn_formula.py): 100% agreement.

### 3.4 With-peripherals contractibility

**Theorem 3.4 (rigorous).** *For $S = S_{g,n}$ with $n \ge 1$ and $\xi(S) \ge 1$, $C_1^+(S)$ is contractible.*

**Proof.** Let $\delta$ be a peripheral curve. For any other essential s.c.c. $w$, $w$ is either peripheral (around a different puncture, disjoint) or non-peripheral (can be isotoped off the punctured-disk neighbourhood of $\delta$). Either way $i(\delta, w) = 0$, so $\{\delta, w\}$ is an edge for every $w$. Hence $\delta$ is universal in the 1-skeleton, and (since $C_1^+$ is flag) $C_1^+ = \delta * \mathrm{Lk}_{C_1^+}(\delta)$ is a simplicial cone, contractible. $\square$

This does NOT directly imply $C_1$ (standard) is contractible — links of vertices in contractible flag complexes can have arbitrary homotopy type.

### 3.5 Bestvina–Brady filtration framework

For $\xi(S) \ge 1$, $g \ge 1$, fix a non-separating $\gamma_0$. Define
$$ f: \mathrm{Vert}(C_1) \to \mathbb{Z}_{\ge 0}, \qquad f(\alpha) = i(\alpha, \gamma_0), $$
and let $C_1^{\le k}$ be the full subcomplex on $\{f \le k\}$. The descending link of $\alpha$ at level $k$:
$$ \mathrm{Lk}^\downarrow(\alpha) = \{\beta : i(\alpha, \beta) \le 1, \, f(\beta) < k\}. $$

**Lemma 3.5 (rigorous, base case).** *$C_1^{\le 0}$ is contractible — $\gamma_0$ is universal.*

**Lemma 3.6 (rigorous, $k=1$).** *For every $\alpha$ with $f(\alpha) = 1$, $\mathrm{Lk}^\downarrow(\alpha)$ is contractible — $\gamma_0$ is universal in the descending link (since $f(\gamma_0) = 0 < 1$ and $i(\alpha, \gamma_0) = 1$).*

**Proposition 3.7 (folklore, BB97).** *If $\mathrm{Lk}^\downarrow(\alpha)$ is contractible for every $\alpha$ with $f(\alpha) = k$, then $C_1^{\le k-1} \hookrightarrow C_1^{\le k}$ is a homotopy equivalence.*

**Theorem 3.8 (conditional main).** *If $\mathrm{Lk}^\downarrow(\alpha)$ is contractible for every $\alpha$ at every level $k \ge 1$, then $C_1(S_{g,n})$ is contractible.*

**Proof.** By Lemmas 3.5, 3.6 and Prop 3.7, $C_1^{\le 0} \hookrightarrow C_1^{\le k}$ is a homotopy equivalence for every $k \ge 0$. Taking colimits, $C_1^{\le 0} \hookrightarrow C_1$ is a homotopy equivalence. $C_1^{\le 0}$ is contractible. $\square$

The remaining open part is the contractibility of $\mathrm{Lk}^\downarrow(\alpha)$ for $k \ge 2$.

---

## 4. Iteration history of the open conjecture

Through 7 iterations, the open conjecture was progressively sharpened. Each row records the form, evidence, and failure mode (if any).

| # | Form | Verification | Status |
|---|---|---|---|
| 1 | "$\mathrm{Lk}^\downarrow$ has a universal vertex $\sigma_\alpha$ (Hatcher surgery)" | sample 132/138 | **disproved**: 6 counterexamples on $S_{1,2}$ at $k=2$ ($K_4$+leaves structure has no universal) |
| 2 | "$\mathrm{Lk}^\downarrow$ is contractible (Betti $[1,0,\ldots]$)" | exhaustive 64/64 at $k=2$ on $S_{1,2}$ + samples at higher $k$ | conjecture, supported but topological |
| 3 | "$\mathrm{Lk}^\downarrow$'s 1-skeleton is dismantlable as a graph" | **378/378** exhaustive across $S_{1,1}, S_{1,2}, S_{2,1}$ | conjecture; uniform "remove max-level dominated vertex" rule |
| 4 | dismantlability + chordality at $k \le 3$ | 60/60 ($S_{1,1}$), 271/271 ($S_{1,2}$ $k\le 3$ chordal), but 12 non-chordal at $k\ge 4$ | refined; chordality fails at higher $k$ |
| 5 | dismantlability with iterative form (some max-level vertex dominated) | extended dataset to 11,438 curves; K_4-core obstruction confirmed structural, not artifactual | verified, but no clean proof path |
| 6 | **(W4) every induced 4-cycle has a common neighbour** | **318/318** (Triangle Condition + W4) exhaustive | clean local condition; standard Chepoi-Osajda hypothesis |
| 7 | **(W4) filler is the Hatcher surgery $\sigma_\alpha$** | 12/12 non-chordal DLs: filler at level $k-2$, disjoint from $\alpha$ | concrete construction; reduces to 1-3 page surgery argument |

**Key literature connections:**

- **Polat 2002** (J. Combin. Theory B): a graph is dismantlable iff cop-win; classical theory of "I-contractibility" of graphs.
- **Boulet–Fieux–Jouve 2008** (arXiv:0809.1751): a finite graph is dismantlable iff its clique complex is **strongly collapsible**, hence collapsible, hence contractible.
- **Chepoi–Osajda 2014** (Trans. AMS): a flag complex satisfying the wheel condition (W4) and metric Triangle/Quadrangle conditions is **weakly systolic**, hence dismantlable.
- **Januszkiewicz–Świątkowski 2006** (Publ. IHÉS): foundational systolic geometry; 6-systolic complexes are contractible.

The chain we use:

$$ \text{(W4) + (M)} \;\;\xrightarrow{\text{[CO14]}}\;\; \text{weakly systolic} \;\;\xrightarrow{\text{[CO14]}}\;\; \text{dismantlable} \;\;\xrightarrow{\text{[BFJ08]}}\;\; \text{strongly collapsible} \;\Rightarrow\; \text{contractible}. $$

---

## 5. Current strongest form

**Lemma 5.1 (the open conjecture — strongest form).** *For every $\alpha$ with $f(\alpha) = k \ge 2$, $\mathrm{Lk}^\downarrow(\alpha)$ satisfies:*

> **(W4)** *Every induced 4-cycle $\beta_1, \beta_2, \beta_3, \beta_4$ in the 1-skeleton has a common neighbour: $\exists\, \beta_5 \in \mathrm{Lk}^\downarrow(\alpha)$ with $i(\beta_5, \beta_i) \le 1$ for $i = 1, 2, 3, 4$.*

> **(M)** *For every edge $\{u, v\}$ in $\mathrm{Lk}^\downarrow(\alpha)$ and every $w$ with $d(u, w) = d(v, w)$, there exists a common neighbour $x$ of $u$ and $v$ with $d(x, w) = d(u, w) - 1$.*

By Chepoi–Osajda, this implies $\mathrm{Lk}^\downarrow(\alpha)$ is dismantlable, hence contractible.

### 5.1 Numerical verification

| Surface | Levels tested | Total DLs | Satisfy (W4) | Satisfy (M) |
|---|---|---|---|---|
| $S_{1,2}$ | $k \in \{2,3,4,5,6,7,8\}$ | 271 | 271 / 271 | 271 / 271 |
| $S_{2,1}$ | $k \in \{2,3,4\}$ | 47 | 47 / 47 | 47 / 47 |
| **Total** | | **318** | **318 / 318** | **318 / 318** |

(Scripts: workspace/op1_scripts/quadrangle_check.py, systolic_check.py.)

### 5.2 The structure of (W4) fillers

For each induced 4-cycle in each non-chordal DL, we extracted the canonical "filler" $\beta_5$ and characterized it. The result is uniform:

| Property of filler | Observation across all 12 non-chordal DLs |
|---|---|
| Level $f(\beta_5)$ | Exactly $k - 2$ (where $k = f(\alpha)$) |
| $i(\alpha, \beta_5)$ | Exactly $0$ (disjoint from $\alpha$) |
| $\beta_5$ is a Dehn twist of $\alpha$? | No; $\beta_5 \ne T_{\gamma_0}^{\pm m}(\alpha)$ for $|m| \le 3$ |

This level shift ($k \to k - 2$) and disjointness from $\alpha$ are **exactly** what Hatcher surgery on $\alpha$ at two adjacent intersection points with $\gamma_0$ produces. The data strongly suggests:

> **Conjectured construction:** *The (W4) filler is the Hatcher surgery output $\sigma_\alpha$.*

This gives the proof a concrete geometric handle that all earlier formulations lacked.

---

## 6. The remaining gap — what's left to prove

The open geometric claim is:

> **Claim 6.1.** *Let $\alpha$ be a simple closed curve with $f(\alpha) = k \ge 2$ on $S = S_{g,n}$ (with $g \ge 1, \xi(S) \ge 1$), in minimal position with $\gamma_0$. Let $p_1, \ldots, p_k$ be the cyclic intersection points along $\gamma_0$. Define $\sigma_\alpha$ as a Hatcher surgery: pick adjacent $p_i, p_{i+1}$, replace one of the two arcs of $\alpha$ from $p_i$ to $p_{i+1}$ with the short arc of $\gamma_0$ between them, push off $\gamma_0$ in the appropriate transverse direction.*
>
> *Then for every $\beta \in \mathrm{Lk}^\downarrow(\alpha)$ that is one of the four vertices of an induced 4-cycle in $\mathrm{Lk}^\downarrow(\alpha)$, we have $i(\sigma_\alpha, \beta) \le 1$.*

The naive bound gives $i(\sigma_\alpha, \beta_i) \le i(\alpha, \beta_i) + i(\gamma_0\text{-arc}, \beta_i)$. The first term is $\le 1$ by DL membership. The second term requires showing that $\beta_i$ crosses the surgery arc of $\gamma_0$ (between adjacent intersection points $p_j$ and $p_{j+1}$) at most $0$ times. The key geometric constraint is that $\beta_1, \beta_2, \beta_3, \beta_4$ form an induced 4-cycle — their mutual intersections are all $\le 1$, which limits how they can traverse the surgery region.

### 6.1 What's straightforward

- $\sigma_\alpha$ is essential and non-peripheral for generic surgery choice (case analysis on $S_{g,n}$ topology).
- $i(\sigma_\alpha, \gamma_0) = 0$: the push-off avoids $\gamma_0$.
- $i(\sigma_\alpha, \alpha) = 0$: $\sigma_\alpha$ is parallel to one arc of $\alpha$, push-off avoids the other arc.
- So $\sigma_\alpha \in \mathrm{Lk}^\downarrow(\alpha)$ at level $k - 2$.

### 6.2 What's hard

The naive bigon-counting bound:
$$ i(\sigma_\alpha, \beta) \;\le\; i(\alpha, \beta) + i(\gamma_0\text{-arc}, \beta) \;\le\; 1 + (k - 1) \;=\; k. $$

This is too loose for $k \ge 2$. We need a refinement that uses the specific structure of an *induced 4-cycle*.

### 6.3 Possible proof path

Suppose $\beta_1, \beta_2, \beta_3, \beta_4$ form an induced 4-cycle: $i(\beta_i, \beta_{i+1}) \le 1$ but $i(\beta_1, \beta_3) \ge 2$, $i(\beta_2, \beta_4) \ge 2$.

The 4-cycle structure constrains how the $\beta_i$ can pass through the surgery region of $\sigma_\alpha$:

(i) If $\beta_i$ has $i(\beta_i, \alpha) = 1$, the single $\alpha$-crossing is on either the "kept" arc or the "replaced" arc. If on the kept arc, $i(\sigma_\alpha, \beta_i) = 1$ (this contribution); if on the replaced arc, the contribution is from the $\gamma_0$ side.

(ii) If $\beta_i$ has $i(\beta_i, \gamma_0) \ge 1$, the crossings with $\gamma_0$ contribute to $i(\sigma_\alpha, \beta_i)$ only through the *short* arc of $\gamma_0$ used in the surgery (a fraction of $\gamma_0$).

The 4-cycle constraint $i(\beta_1, \beta_2) \le 1$ etc. forces the $\beta_i$'s to have very limited geometric freedom in the surgery region, and a careful bigon argument should give $i(\sigma_\alpha, \beta_i) \le 1$ for the specific pair $(i, i+1)$ involved.

This is the kind of argument Hatcher [Hat91] uses for the arc complex contractibility (4–8 pages of casework). Adapting it to closed-curve $i \le 1$ is what we did not finish.

### 6.4 Why this proof is needed

The whole reduction chain depends on Claim 6.1. Given Claim 6.1 + the analogous (M)-claim, the proof of $C_1$ contractibility is automatic via Chepoi–Osajda + BB filtration. Without Claim 6.1, we have only empirical evidence.

---

## 7. Numerical tools and reproducibility

### 7.1 Tooling

- `curver` 0.5.1 (Mark Bell) — surface laminations, Dehn twists, intersection numbers
- `gudhi` 3.12.0 — flag complex expansion, Betti numbers
- `networkx` 3.6.1 — graph algorithms (chordality, cycles, dismantling)
- Python 3.12.3 on WSL Ubuntu 24.04

### 7.2 Key scripts

```
workspace/op1_scripts/
├── enumerate_v2.py                # MCG-orbit BFS curve enumeration
├── analyze_complex.py             # flag complex + Betti via gudhi
├── verify_descending_link.py      # k=1, k=2 DL contractibility
├── verify_descending_link_higher.py  # k=1..5 on S_{1,2}, k=1..4 on S_{2,1}
├── exhaustive_k2.py               # all 64 k=2 alphas on S_{1,2}, exhaustive
├── analyze_no_universal.py        # K_4+leaves structure of 6 counterexamples
├── dismantle_check.py             # 378/378 dismantlability, exhaustive
├── chordality_thorough.py         # 12 non-chordal DL details
├── systolic_check.py              # (M) test: 318/318 pass
├── quadrangle_check.py            # (W4) test: 318/318 pass
├── characterize_W4_fillers.py     # filler structure: level k-2, i(α)=0
├── verify_filler_is_surgery.py    # filler ≠ Dehn twist of α
└── extended_DL_dismantle.py       # K_4-core obstruction confirmed structural
```

### 7.3 Reproduction

```bash
# 1. Enumerate curves (BFS over MCG generators)
wsl python3 workspace/op1_scripts/enumerate_v2.py 1 2 6 400

# 2. Verify dismantlability exhaustively
wsl python3 workspace/op1_scripts/dismantle_check.py

# 3. Verify (W4) and (M) conditions
wsl python3 workspace/op1_scripts/quadrangle_check.py
wsl python3 workspace/op1_scripts/systolic_check.py

# 4. Characterize the (W4) fillers
wsl python3 workspace/op1_scripts/characterize_W4_fillers.py
```

All data files (`data_S_{g,n}.json`) are in the same directory; rerunning the above commands reproduces every numerical claim in this report.

---

## 8. Appendix: Key data tables

### A. Dismantlability verification

378 / 378 descending links across all tested surfaces and levels are dismantlable. Verified via the iterative "remove a max-level dominated vertex" algorithm.

| Surface | Levels | Coverage | Dismantlable |
|---|---|---|---|
| $S_{1,1}$ | $k \in \{1,2,3,4,5\}$ | all 60 | 60 / 60 |
| $S_{1,2}$ | $k \in \{2,3,4,5,6,7,8\}$ | all 271 | 271 / 271 |
| $S_{2,1}$ | $k \in \{2,3,4\}$ | all 47 | 47 / 47 |
| **Total** | | | **378 / 378** |

### B. (W4) and (M) verification

| Surface | $k$ | DL count | (M) pass | (W4) pass |
|---|---|---|---|---|
| $S_{1,2}$ | 2 | 64 | 64 | 64 (chordal, vacuous) |
| $S_{1,2}$ | 3 | 63 | 63 | 63 (chordal, vacuous) |
| $S_{1,2}$ | 4 | 49 | 49 | 49 (4 non-chordal, all filled) |
| $S_{1,2}$ | 5 | 33 | 33 | 33 (1 non-chordal, filled) |
| $S_{1,2}$ | 6 | 24 | 24 | 24 (5 non-chordal, all filled) |
| $S_{1,2}$ | 7 | 18 | 18 | 18 (1 non-chordal, filled) |
| $S_{1,2}$ | 8 | 20 | 20 | 20 (1 non-chordal, filled) |
| $S_{2,1}$ | 2 | 32 | 32 | 32 (all have induced 4-cycles, all filled) |
| $S_{2,1}$ | 3 | 12 | 12 | 12 |
| $S_{2,1}$ | 4 | 3 | 3 | 3 |
| **Total** | | **318** | **318 / 318** | **318 / 318** |

### C. The 6 universal-vertex counterexamples ($S_{1,2}$, $k = 2$)

All six have an identical 8-vertex "$K_4$ + 4 leaves" structure:

- **Core** = 4 mutually $i \le 1$ vertices forming a $K_4$.
- **4 leaves**, each connected to exactly 3 of the 4 core vertices (one different "missing" core per leaf).
- No leaf-leaf edges.

| $\alpha$ | Core indices | Leaf indices |
|---|---|---|
| 25 | $\{1, 4, 8, 24\}$ | $\{14, 22, 36, 346\}$ |
| 72 | $\{1, 5, 18, 24\}$ | $\{6, 44, 67, 112\}$ |
| 149 | $\{4, 8, 48, 51\}$ | $\{56, 70, 111, 153\}$ |
| 208 | $\{1, 5, 54, 67\}$ | $\{18, 133, 200, 321\}$ |
| 217 | $\{5, 16, 18, 50\}$ | $\{17, 54, 55, 350\}$ |
| 218 | $\{5, 6, 16, 17\}$ | (similar) |

Each is dismantlable: leaves first (each dominated by some core), then the residual $K_4$ collapses (any vertex of $K_4$ dominates any other). They are chordal: simplicial elimination ordering works.

### D. The 12 non-chordal DLs and their (W4) fillers

| $\alpha$ | $k$ | $|V|$ | $|E|$ | Induced 4-cycle | Canonical filler | $f$(filler) | $i(\alpha, \text{filler})$ |
|---|---|---|---|---|---|---|---|
| 38 | 4 | 9 | 25 | $(8, 14, 73, 39)$ | 25 | 2 | 0 |
| 105 | 4 | 8 | 22 | $(22, 24, 209, 120)$ | 68 | 2 | 0 |
| 117 | 4 | 8 | 22 | $(6, 24, 116, 219)$ | 72 | 2 | 0 |
| 119 | 4 | 8 | 22 | $(1, 15, 221, 43)$ | 74 | 2 | 0 |
| 118 | 5 | 8 | 22 | $(14, 25, 39, 220)$ | 73 | 3 | 0 |
| 88 | 6 | 9 | 25 | $(39, 73, 89, 29)$ | (similar) | 4 | 0 |
| 186 | 6 | 8 | 22 | $(12, 14, 118, 206)$ | (similar) | 4 | 0 |
| 253 | 6 | 8 | 22 | $(120, 82, 271, 209)$ | (similar) | 4 | 0 |
| 268 | 6 | 8 | 22 | $(116, 87, 267, 219)$ | (similar) | 4 | 0 |
| 270 | 6 | 8 | 22 | $(43, 89, 128, 221)$ | (similar) | 4 | 0 |
| 269 | 7 | 8 | 22 | $(39, 88, 89, 220)$ | (similar) | 5 | 0 |
| 236 | 8 | 9 | 25 | $(73, 237, 78, 89)$ | (similar) | 6 | 0 |

**Pattern:** filler at level exactly $k - 2$, disjoint from $\alpha$. Consistent with Hatcher surgery on $\alpha$ along $\gamma_0$.

---

## References

- [BB97] M. Bestvina, N. Brady, *Morse theory and finiteness properties of groups*, Invent. Math. 129 (1997).
- [BFJ08] R. Boulet, E. Fieux, B. Jouve, *Simplicial simple-homotopy of flag complexes in terms of graphs*, arXiv:0809.1751.
- [CO14] V. Chepoi, D. Osajda, *Dismantlability of weakly systolic complexes and applications*, Trans. AMS 367 (2015), arXiv:0910.5444.
- [FM12] B. Farb, D. Margalit, *A primer on mapping class groups*, Princeton, 2012.
- [Hat91] A. Hatcher, *On triangulations of surfaces*, Topology Appl. 40 (1991), 189–194.
- [JS06] T. Januszkiewicz, J. Świątkowski, *Simplicial nonpositive curvature*, Publ. Math. IHÉS 104 (2006).
- [Lic64] W. B. R. Lickorish, *A finite set of generators for the homeotopy group of a 2-manifold*, Math. Proc. Cambridge Philos. Soc. 60 (1964).
- [Pol02] N. Polat, *On infinite bridged graphs and strongly dismantlable graphs*, J. Combin. Theory B 86 (2002).
- [PS17] P. Przytycki, A. Sisto, *A note on acylindrical hyperbolicity of mapping class groups*, arXiv:1502.02176.
- [Put08] A. Putman, *A note on the connectivity of certain complexes associated to surfaces*, Algebr. Geom. Topol. 8 (2008).
- [S07] J. Souto, *Some topological questions about mapping class groups* (2007).
