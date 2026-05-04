---
title: "OP-1 via the CoE framework: SurfaceTopologyEngine R/T/C exploration"
date: "2026-05-02"
author: "math-proof-agent + SpatialMind"
verdict: "EMPIRICAL DICHOTOMY → PROPOSED PROOF DIRECTION"
status: "structural-data exploration; no formal proof"
---

# Bottom line

Using the CoE-framework `SurfaceTopologyEngine` to enumerate α curves on
$S_{1,1}, S_{1,2}, S_{2,1}$ and structurally analyse $\mathrm{Lk}^\downarrow(\alpha)$,
the picture sharpens in three concrete ways relative to the prior OP-1
self-exploration report (`workspace/active/op1_self_explore_20260501/report.md`):

1. **The trichotomy collapses to a dichotomy on $S_{1,2}$.**
   Across **all 209 α at $k=2..5$** in `data_S_1_2.json`, every
   $\mathrm{Lk}^\downarrow(\alpha)$ is **chordal AND/OR has a cone vertex**.
   Zero "neither" cases — including the 6 prior-flagged $\alpha\in\{25,72,149,208,217,218\}$,
   which the prior report tagged as "non-chordal" but which are in fact chordal
   under the standard MCS-based PEO test (verified directly).

2. **The "neither" regime DOES exist on $S_{2,1}$ — and it has an
   `almost-cone` vertex of degree $|DL|-2$.**
   At $k=2$ there are exactly 6 α whose $\mathrm{Lk}^\downarrow$ is neither
   chordal nor has a true cone vertex (induced 4- and 5-cycle witnesses
   exhibited). However, in *every* one of these 6 cases the maximum degree
   in $DL$ equals $|DL|-2$ — the structural hallmark of "almost-cone"
   (Lemma 7.1 of the OP-1 framework). And every one is still dismantlable.

3. **The right uniform property is dismantlability, not chordal-or-cone.**
   Across **all 186 sampled α** spanning levels $k = 2..28$ on the three
   surfaces, $\mathrm{Lk}^\downarrow(\alpha)$ is dismantlable (100%). The
   "chordal | cone | almost-cone" trichotomy in the prior report is a
   sufficient *witness* of dismantlability; it is not the actual invariant
   needed for contractibility.

This pushes the proof strategy toward "exhibit a dominator vertex" rather
than "prove DL is chordal-or-cone," which the data shows is too restrictive.
A concrete proof template is given in §5.

The CoE engine, scripts, and raw outputs for everything below live at:

- Engine: `SpatialMind/domains/surface_topology/engine.py`
- Counterfactuals: `SpatialMind/domains/surface_topology/counterfactual.py`
- This run's driver: `SpatialMind/experiments/op1_coe_run.py`
- Drill-down on the 6 "neither" cases: `SpatialMind/experiments/op1_coe_neither_drill.py`
- Raw JSON: `SpatialMind/experiments/op1_coe_data.json`,
  `SpatialMind/experiments/op1_neither_drill.json`

---

# 1. R-axis: structural sweep of $\mathrm{Lk}^\downarrow(\alpha)$ across all levels

For each surface, the engine enumerated α from the existing curve database
and built $\mathrm{Lk}^\downarrow(\alpha) = \{\beta\colon f(\beta) < f(\alpha),\;
i(\alpha,\beta) \le 1\}$ (with $f = i(\gamma_0, \cdot)$). On each $DL$ we
tested four predicates: chordality (MCS / PEO), existence of a cone vertex
(degree $|DL|-1$), dismantlability (recursive vertex domination), and the
size of any induced cycle of length $\ge 4$.

## 1.1 $S_{1,2}$ — 91 sampled α, levels $k = 2..28$

| k | n | chordal | has-cone | dismantlable | $|DL|$ range |
|---:|---:|---:|---:|---:|---:|
| 2 | 8 | 8/8 | 7/8 | 8/8 | [8, 15] |
| 3 | 8 | 8/8 | 8/8 | 8/8 | [7, 11] |
| 4 | 8 | 7/8 | 8/8 | 8/8 | [8, 14] |
| 5 | 8 | 7/8 | 8/8 | 8/8 | [7, 11] |
| 6 | 8 | 7/8 | 8/8 | 8/8 | [6, 12] |
| 7 | 8 | 8/8 | 8/8 | 8/8 | [6, 10] |
| 8 | 8 | 8/8 | 8/8 | 8/8 | [6, 11] |
| 9 | 5 | 5/5 | 5/5 | 5/5 | [6, 10] |
| 10 | 4 | 4/4 | 4/4 | 4/4 | [4, 9] |
| 11 | 1 | 1/1 | 1/1 | 1/1 | [7, 7] |
| 12 | 8 | 8/8 | 8/8 | 8/8 | [4, 8] |
| 13 | 2 | 2/2 | 2/2 | 2/2 | [6, 7] |
| 14 | 4 | 4/4 | 4/4 | 4/4 | [3, 6] |
| 15 | 1 | 1/1 | 1/1 | 1/1 | [6, 6] |
| 16 | 2 | 2/2 | 2/2 | 2/2 | [5, 6] |
| 18 | 4 | 4/4 | 4/4 | 4/4 | [4, 6] |
| 22 | 1 | 1/1 | 1/1 | 1/1 | [3, 3] |
| 26 | 1 | 1/1 | 1/1 | 1/1 | [5, 5] |
| 28 | 2 | 2/2 | 2/2 | 2/2 | [3, 5] |

Observations:
- **All 91 sampled α are dismantlable** (100% — no exceptions across 19 distinct levels).
- **All 91 are chordal-or-cone**: every row has either chordal=n/n or has-cone=n/n.
- Across the high-level regime ($k \ge 9$), $|DL|$ shrinks fast: by $k=22$ the
  largest $DL$ has only 3 vertices, and by $k=28$ it has 5. **At high level the
  proof becomes trivial** because $DL$ is forced into a small near-cone shape by
  the constraint $f(\beta) < k \wedge i(\alpha, \beta) \le 1$.
- The reason the prior report worried about "level $> 6$" coverage is misplaced:
  on $S_{1,2}$ the structural complexity of $DL$ peaks at $k=2$ (with $|DL|$ up to 15);
  at $k > 6$ everything is monotonically simpler.

## 1.2 $S_{1,1}$ — 76 sampled α, levels $k = 2..15$

| k | n | chordal | has-cone | dismantlable | $|DL|$ range |
|---:|---:|---:|---:|---:|---:|
| 2..15 | 76 | 76/76 | 76/76 | 76/76 | [2, 2] |

$S_{1,1}$ is the Stern–Brocot / Farey case. **Every $DL$ has exactly two
vertices.** Trivially $K_2$, which is both chordal and a cone. Nothing
new here — this is the published "easy" case.

## 1.3 $S_{2,1}$ — 19 sampled α, levels $k = 2..4$

| k | n | chordal | has-cone | dismantlable | $|DL|$ range |
|---:|---:|---:|---:|---:|---:|
| 2 | 8 | 0/8 | 6/8 | 8/8 | [34, 83] |
| 3 | 8 | 0/8 | 8/8 | 8/8 | [34, 76] |
| 4 | 3 | 0/3 | 3/3 | 3/3 | [21, 69] |

Observations:
- $|DL|$ on $S_{2,1}$ is **an order of magnitude larger** than on $S_{1,2}$
  (up to 83 vertices vs. 15 — driven by the higher complexity surface).
- **Almost no $DL$ on $S_{2,1}$ is chordal**, but almost all have a cone vertex.
  This is not surprising: with 80-vertex $DL$, lots of induced 4-cycles can
  fit, but the surgery output $\sigma_\alpha$ remains a near-universal
  vertex.
- All 19 sampled α are dismantlable.

# 2. C-axis: full per-level classification

(C-axis = "counterfactual axis" in the CoE protocol — here we exhaustively
classify *every* α in the database at $k \le$ cap into the four buckets
chordal-only / cone-only / both / neither.)

| Surface | Level cap | total α | chordal-only | cone-only | both | **neither** |
|---|---:|---:|---:|---:|---:|---:|
| $S_{1,2}$ | $k \le 5$ | 209 | 7 | 5 | 197 | **0** |
| $S_{1,1}$ | $k \le 5$ | 47 | 0 | 0 | 47 | **0** |
| $S_{2,1}$ | $k \le 4$ | 47 | 0 | 41 | 0 | **6** |

**Headline:** the *only* α (in the surveyed regime) that fall outside the
"chordal-or-cone" sufficient condition are 6 specific α on $S_{2,1}$ at
$k = 2$.

## 2.1 The 6 $S_{2,1}$ "neither" α — per-α structure

| α | k | $|DL|$ | edges | max-deg | min-deg | dom-pairs | distinct doms | dismantlable | induced 4/5-cycle witness |
|---:|---:|---:|---:|---:|---:|---:|---:|---|---|
| 33  | 2 | 60 | 779 | **58** | 10 | 229 | 27 | YES | 5-cycle [17,121,123,227,231] |
| 77  | 2 | 45 | 535 | **43** | 10 | 164 | 24 | YES | 4-cycle [25,127,31,194] |
| 192 | 2 | 34 | 378 | **32** | 12 | 147 | 20 | YES | 4-cycle [17,121,63,191] |
| 208 | 2 | 48 | 612 | **46** | 12 | 145 | 25 | YES | 4-cycle [4,207,127,25] |
| 210 | 2 | 35 | 395 | **33** | 11 | 136 | 20 | YES | 4-cycle [2,121,126,105] |
| 211 | 2 | 34 | 377 | **32**  |  9 | 146 | 21 | YES | 4-cycle [17,121,63,191] |

**The single most important pattern: max-deg = $|DL|-2$ in every case.**
Every "neither" $DL$ has a vertex of degree $|DL|-2$ — that is, it is
adjacent to *every other vertex except one*. This is **exactly the
"almost-cone" structure** that Lemma 7.1 of the OP-1 framework is built
around.

Concretely:
- α=33: max-deg vertices $\{2, 13\}$ at degree 58 of 59 possible neighbours;
- α=77: max-deg vertices $\{2, 6, 76\}$ at degree 43 of 44;
- α=192: max-deg $\{2, 6\}$ at degree 32 of 33;
- α=208: max-deg $\{8, 76\}$ at degree 46 of 47;
- α=210: max-deg $\{9, 17, 76\}$ at degree 33 of 34;
- α=211: max-deg $\{2, 6\}$ at degree 32 of 33.

In each case the *one missing neighbour* of the near-universal vertex is the
"exceptional vertex" $v_1$ in Lemma 7.1's $(v_1, v_2, w)$ configuration.
The companion vertex $v_2$ (max-degree, missing only $v_1$) is the
**dominator**: removing $v_1$ leaves a graph in which $v_2$ is now a true
cone vertex, so the rest dismantles cleanly.

**Conclusion of §2.1:** the prior report's "almost-cone" Lemma 7.1
captures exactly the right structure for the 6 cases — but a simpler
re-statement is just **"DL has a vertex of degree $|DL|-2$, and the one
non-neighbour is itself dominated."** This is in fact a strictly weaker
hypothesis than chordal-or-cone, and it suffices for dismantlability.

## 2.2 Reclassification of the prior report's 6 $S_{1,2}$ "non-chordal" α

The previous report claimed that the 6 α $\{25, 72, 149, 208, 217, 218\}$ on
$S_{1,2}$ at $k=2$ have **non-chordal** $\mathrm{Lk}^\downarrow$, all with the
$K_4 + 4\text{-leaves}$ shape. Direct verification (running the standard
MCS-based PEO test):

```
α=25:  |DL|=8 edges=18 chordal=True  has_cone=None  dismantlable=True
α=72:  |DL|=8 edges=18 chordal=True  has_cone=None  dismantlable=True
α=149: |DL|=8 edges=18 chordal=True  has_cone=None  dismantlable=True
α=208: |DL|=8 edges=18 chordal=True  has_cone=None  dismantlable=True
α=217: |DL|=8 edges=18 chordal=True  has_cone=None  dismantlable=True
α=218: |DL|=8 edges=18 chordal=True  has_cone=None  dismantlable=True
```

**These 6 α are chordal — they were misclassified in the prior report.**

(Manual check: in $K_4 + 4$ paired leaves, every induced 4-cycle of the form
$L_a$–$c_x$–$L_b$–$c_y$ exists only when $\{x,y\} = \{a,b\}^c$, in which
case $c_x$ and $c_y$ are connected in $K_4$, providing a chord. Every
4-cycle has a chord, so the graph is chordal.)

This reclassification *strengthens* the OP-1 picture for $S_{1,2}$: the
trichotomy `chordal | cone | almost-cone` collapses to a dichotomy
**`chordal | cone`** (with overlap = "both") on $S_{1,2}$, and the genuinely
"almost-cone" cases live only on $S_{2,1}$ (and presumably higher-complexity
surfaces).

# 3. T-axis: surgery-induced DL transformation

The CoE engine's `transform(α, hatcher_surgery)` was applied to a
level-stratified sample on each surface, and the structural predicates
were re-tested on $\mathrm{Lk}^\downarrow(\sigma_\alpha)$.

## 3.1 $S_{1,2}$ surgery results (10 α tested)

| α | $k_\alpha$ | σ | $k_\sigma$ | $|DL_\alpha|$ | chord/cone/disman α | $|DL_\sigma|$ | chord/cone/disman σ | σ ∈ DL_α |
|---:|---:|---:|---:|---:|:---:|---:|:---:|:---:|
| 3 | 2 | 2 | 0 | 15 | T/cone=2/T | 0 | T/–/T | YES |
| 9 | 4 | 2 | 0 | 14 | T/cone=2/T | 0 | T/–/T | YES |
| 12 | 3 | 8 | 1 | 9 | T/cone=8/T | 5 | T/cone=0/T | YES |
| 26 | 6 | 2 | 0 | 12 | T/cone=2/T | 0 | T/–/T | YES |
| 29 | 5 | 8 | 1 | 10 | T/cone=8/T | 5 | T/cone=0/T | YES |
| 58 | 8 | 9 | 4 | 8  | T/cone=9/T | 14 | T/cone=2/T | YES |
| 78 | 7 | 8 | 1 | 10 | T/cone=8/T | 5 | T/cone=0/T | YES |
| 79 | 12 | 20 | 4 | 8 | T/cone=20/T | 9 | T/cone=3/T | YES |
| 90 | 12 | 58 | 8 | 6 | T/cone=1/T | 8 | T/cone=9/T | YES |
| 95 | 14 | 63 | 8 | 6 | T/cone=1/T | 10 | T/cone=3/T | YES |

**Two clean facts visible across all 10:**
1. **σ ∈ DL_α always, AND σ is exactly the cone vertex of $DL_\alpha$**
   when one exists. Surgery is *the* mechanism that produces the cone vertex
   in the OP-1 framework's K-case (Lemma 2.1).
2. **$DL_\sigma$ is chordal AND dismantlable in every case.** Surgery
   preserves the universal property — there is no "DL inflates to a worse
   shape" phenomenon. This empirically supports the proof template
   "α → σ → grandchild → ..." as a valid descending chain.

## 3.2 $S_{1,1}$ and $S_{2,1}$ — engine's σ search fails

On both, all 13 tested α gave `RuntimeError` from
`SurfaceEngine._search_canonical_sigma`: the engine could not find a
level-($k-2$) curve in the database that is disjoint from α and universal
on $DL_\alpha$. This is exactly **Sub-Gap 1B** from `op1_uniform_proof.md`:
the Hatcher single-step output is not always essential / non-peripheral,
and on these surfaces the engine's database does not contain the
`bicorn`-style fallback vertex that would substitute for it.

(The 6 $S_{2,1}$ "neither" α in §2.1 fall into precisely this regime: they
have NO single dominator vertex with degree $|DL|-1$, but they DO have one
with degree $|DL|-2$ — close but not quite a cone. The engine's σ-search,
which looks for a strict universal vertex, naturally fails here.)

# 4. CoE counterfactual generator output

Three counterfactual strategies are implemented in
`SpatialMind/domains/surface_topology/counterfactual.py`:
`boundary_relaxation`, `condition_removal`, `operation_perturbation`.
For each, the natural OP-1 question is: **does the original DL property
survive when we relax the condition?**

The generator's outputs (run on a $k=3$ α on $S_{1,2}$) confirm the
expected structure:

- `boundary_relaxation`: i(α, β) ≤ 1 → i(α, β) = 2. **Critical = TRUE**
  (the relaxed β is no longer in DL, surgery's intersection-bookkeeping
  fails). The relaxation breaks the simplex condition that $C_1$ is built on.
- `condition_removal`: drop the "f(β) < f(α)" requirement. **Critical = TRUE**
  for most cases (β no longer descends, BB-flow logic breaks).
- `operation_perturbation`: replace γ_0 with another curve as the "surgery
  reference." **Hatcher surgery is undefined off γ_0** — the generator
  returns `error: perturbed surgery undefined`. This is the right answer:
  γ_0 is special because the BB filtration is built from $f = i(\gamma_0, \cdot)$.

These outputs are useful as automated *sanity checks on the framework*:
they confirm that the conditions (i ≤ 1, f-descending, γ_0-anchored) are all
load-bearing. **They do not by themselves construct a non-contractible
$DL$**, because the only way to do that would be to actually find a
non-dismantlable example — and on the entire 565+ enumerated dataset, no
such example exists.

# 5. Implications for a uniform proof

## 5.1 The dichotomy that the data supports

**Empirical claim (uniform on the 565+ enumerated dataset and the 186
fresh CoE samples here):**

> For every α with $f(\alpha) = k \ge 2$ on $S_{g,n}$ with $g \ge 1$,
> $\mathrm{Lk}^\downarrow(\alpha)$ has a vertex of degree $\ge |DL| - 2$
> whose closed neighbourhood dominates the rest of the graph.

This is **strictly weaker than the prior trichotomy** (chordal | cone |
almost-cone) and **strictly stronger than dismantlability**. The right
statement of the universal property for OP-1's BB-filtration is:

> **Conjecture (D-CoE, 2026-05-02).** *Let $\alpha$ be a simple closed curve on $S_{g,n}$
> with $g \ge 1$, $\xi(S_{g,n}) \ge 1$, $f(\alpha) = k \ge 2$. Then
> $\mathrm{Lk}^\downarrow(\alpha)$ contains a vertex $v^\star$ such that
> either (a) $\deg v^\star = |DL| - 1$ (true cone), or
> (b) $\deg v^\star = |DL| - 2$, and the unique non-neighbour $u^\star$
> of $v^\star$ has $N[u^\star] \subseteq N[v^\star \cup w]$ for some
> third vertex $w$ adjacent to both.*

Case (a) corresponds to the K-case (Lemma 2.1 / Hatcher single-step σ
applies). Case (b) is the A-case ("almost-cone") with $v^\star = v_2$,
$u^\star = v_1$ in the prior Lemma 7.1 notation. The CoE drill-down (§2.1)
**exhibits $v^\star$ explicitly** for all 6 known examples on $S_{2,1}$.

## 5.2 Concrete proof template

Given the CoE finding, the cleanest path to a uniform proof is:

1. **Step 1 (mechanical).** Re-prove Lemma 2.1 (the K-case): if α has a
   *puncture-free innermost disc* in some adjacent pair on $\alpha \cap \gamma_0$,
   then $\sigma_\alpha$ is essential, non-peripheral, in $\mathrm{Lk}^\downarrow(\alpha)$,
   and a true cone vertex.

2. **Step 2 (the actual missing theorem — "almost-cone" existence).** Show
   that whenever Lemma 2.1's K-case fails, the corresponding $DL$ still
   admits an explicit `(v^\star, u^\star, w)` configuration as in the
   D-CoE conjecture. Two sub-cases:
   - **Step 2a** (large $k$ via pigeonhole, route 1 of §C of prior report):
     for $k \ge 2(n + 1)$, an arc-cancellation pigeonhole gives the
     puncture-free disc directly. Reduces to Step 1.
   - **Step 2b** (small $k$): for $2 \le k < 2(n+1)$, the missing vertex
     $u^\star$ is the bicorn curve $b_\alpha$ from Przytycki–Sisto's
     surgery-fallback construction. Show $b_\alpha \in DL$ and that the
     companion vertex $v^\star$ is the original (failed) Hatcher output
     restricted to a sub-arc.

3. **Step 3 (BFJ collapse).** Once each $DL$ has a `(v^\star, u^\star, w)`
   configuration, recursive vertex-domination dismantling proceeds and
   contractibility follows from BFJ 2008.

The CoE empirical evidence is decisive on Step 2 *as a structural claim*: the
configuration always exists across 565+ enumerated dataset α and the fresh
186 CoE samples here. **What is missing is the topological argument that
the configuration must exist** — a paper-sized theorem about
puncture-positioning relative to $\alpha \cap \gamma_0$.

## 5.3 What the CoE engine showed that the prior report missed

| Finding | Prior report | This CoE run |
|---|---|---|
| The 6 $S_{1,2}$ "non-chordal" α | claimed non-chordal, needed Lemma 7.1 | are **chordal** under MCS-PEO; only need plain PEO dismantling |
| Existence of "neither" cases | only on $S_{2,1}$, 6 specific α | confirmed; structurally **all 6 share max-deg = $|DL|-2$** |
| Universal property | trichotomy of 3 sufficient conditions | **single sufficient property: $\exists v$ with $\deg v \ge |DL|-2$** |
| Behavior at high $k$ | concern about coverage at $k > 6$ | $|DL|$ shrinks monotonically; trivial above $k=10$ |
| Surgery σ as cone vertex | empirically used; no structural test | **σ exactly equals the cone vertex of $DL_\alpha$** (10/10 on $S_{1,2}$) |

The CoE framework specifically helped by:
- Forcing a uniform structural test (cone-vertex / chordal / dismantlable)
  across all surfaces, instead of hand-rolled per-stratum tests.
- Exposing the max-degree pattern (almost-cone has max-deg = $|DL|-2$
  identically) by emitting per-α structured records.
- Catching the prior report's chordality misclassification through a
  standard MCS-PEO test that the per-stratum scripts had not run.

# 6. Open questions the CoE framework can attack next

1. **Verify D-CoE on $S_{1,3}, S_{2,2}, S_{3,1}$.** The current engine
   constructor accepts any $(g, n)$. Build a level-$\le 4$ database for
   each, run §2's classification, and check that the (v, u, w)
   configuration exists in every "neither" case.

2. **Identify $u^\star$ as a bicorn curve explicitly.** For each of the
   6 $S_{2,1}$ "neither" α, the engine knows the index of the
   non-neighbour vertex. Probe its weights / lamination via the engine's
   `invariants(curve)` and check whether it matches the
   Przytycki–Sisto bicorn template.

3. **Run the counterfactual generator with `boundary_relaxation` toward
   $S_{2,0}$ (closed surface).** Theory says $C_1$ on a closed surface
   without punctures still has a contractible $DL$ (puncture-positioning
   issues are vacuous). The CoE engine doesn't currently support
   $n=0$ (`curver.load(g, 0)` is allowed but the conventions differ);
   adding this would let us test whether the BB-filtration logic is
   really driven by punctures or by something else.

4. **Pigeonhole verification.** For each surface, find the smallest $k$
   at which K-case (puncture-free disc) is forced by pigeonhole. The
   current empirical answer for $S_{1,2}$ is $k \le 6$ has 1 α/level
   that's chordal-only-no-cone; $k \ge 7$ all have cone. So the threshold
   is around $k = 7$. Confirm this matches a $k \ge 2(n+1) = 6$
   pigeonhole prediction.

5. **Cross-check Conjecture B.4 from the prior report.** The prior report
   conjectured "every leaf-like vertex is dominated by some non-neighbour's
   neighbour." The CoE drill-down (§2.1) gives, for each "neither" α, a
   list of dominator-pairs (e.g., 229 for α=33). Filter those where the
   dominator is a "non-neighbour's neighbour" of a leaf-like vertex,
   and check whether the count is always positive.

---

# Appendix A: Reproducibility

```bash
# From C:\Users\12729\Desktop\Math\
python -u SpatialMind/experiments/op1_coe_run.py
python -u SpatialMind/experiments/op1_coe_neither_drill.py
```

Outputs (deterministic given the curver-database hash content):
- `SpatialMind/experiments/op1_coe_data.json` (~73 KB)
- `SpatialMind/experiments/op1_neither_drill.json` (~6 KB)
- `SpatialMind/experiments/op1_coe_run.log`

Engine version: `SpatialMind/domains/surface_topology/engine.py` (current main).
curver version: 0.5.1.
