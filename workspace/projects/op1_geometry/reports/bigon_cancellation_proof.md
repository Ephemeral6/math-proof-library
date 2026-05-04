# Bigon Cancellation Lemma for the OP-1 Hatcher Surgery

**Date:** 2026-04-30
**Closes:** OP-1 §11.8.5(a) `proof_obligation` for **all 12/12**
non-chordal S_{1,2} DLs. Single-step cases (6/12) close rigorously
via the bigon disc argument of §3. Multi-step cases (6/12) close via
Lemma 4.1 (universal-vertex + parity), conditional on a finite-data
homology check that the verifier passes 12/12 **on S_{1,2}**. The
homology check does **not** hold uniformly on other surfaces (see §4
caveat); the proof's scope is restricted accordingly. The 6 S_{2,1}
k=2 non-chordal-non-cone DLs close via Lemma 7.1 (two-step almost-cone).
Combined OP-1 contractibility coverage: **389/389 descending links**
closed by either chordal-PEO, cone collapse, or one of the lemmas
2.1 / 4.1 / 7.1.
**Method:** Layer 5 (evidence-guided proof) — classical bigon cancellation
on an embedded innermost disc, with each step empirically verified by
`SurfaceGeo` on the 12 non-chordal cases (99/99 (α, β) pairs).
**Companion verifiers:**
- `workspace/projects/op1_geometry/verify_bigon_proof.py` — Lemma 2.1 (single-step), 12 non-chordal S_{1,2} cases.
- `workspace/projects/op1_geometry/gap1_homology_check.py` — Lemma 4.1 hypothesis (b), $[\sigma_\mathrm{curver}] = [\alpha]$ in $H_1(\mathbb Z/2)$.
- `workspace/projects/op1_geometry/gap1_chain_finder.py` — diagnostic establishing why iteration fails in the BFS-truncated database (motivates the parity reformulation).
- `workspace/projects/op1_geometry/gap2_almost_cone.py` — Lemma 7.1 hypotheses, 6 S_{2,1} k=2 cases.

---

## 1. Setup

Let $S = S_{1,2}$ and $\gamma_0$ the standard non-separating curve at level
0. Fix a simple closed curve $\alpha$ with
$f(\alpha) := i(\alpha, \gamma_0) = k \ge 4$, isotoped into minimal position
with $\gamma_0$. Label the $k$ intersection points of $\alpha$ with
$\gamma_0$ as $p_1, p_2, \ldots, p_k$ in cyclic order along $\alpha$.

Choose an **adjacent pair** $(p_j, p_{j+1})$ — adjacent meaning consecutive
along $\alpha$ — such that the corresponding two arcs

- $a_S$ = the sub-arc of $\alpha$ from $p_j$ to $p_{j+1}$,
- $g_S$ = a sub-arc of $\gamma_0$ connecting $p_j$ to $p_{j+1}$,

co-bound an **embedded innermost disc** $D \subset S$, with
$\partial D = a_S \cup g_S$. The Hatcher 1991 §2 surgery hypothesis is that
such an adjacent pair exists; this is automatic on $S_{1,2}$ for $k \ge 2$
because the four endpoints of $\alpha$ along $\gamma_0$ separate $\gamma_0$
into arcs, and minimal position rules out non-disc bigons.

Write $a_L = \overline{\alpha \setminus a_S}$ for the **long sub-arc**
(complement of $a_S$ in $\alpha$). Define the **Hatcher-surgery output**

$$
\sigma_\alpha \;:=\; (\,a_L \cup g_S\,) \quad \text{after smoothing the
two corners at } p_j, p_{j+1} \text{ and isotoping into minimal position.}
$$

Let $\beta \in \mathrm{Lk}^\downarrow(\alpha)$, i.e. $\beta$ is a simple
closed curve with $i(\alpha, \beta) \le 1$ and $f(\beta) < k$, isotoped
into minimal position with both $\alpha$ and $\gamma_0$.

---

## 2. The lemma

**Lemma 2.1 (Bigon Cancellation, single-step).**
*Under the setup above, $\,i(\sigma_\alpha, \beta) = i(\alpha, \beta).\,$
Equivalently, $i(g_S, \beta) = i(a_S, \beta)$ when both are read in
minimal position inside $D$.*

This is the §11.8.3 Empirical Lemma 11.8.4 promoted from "verified
49/49" to a rigorous statement, conditional on $\sigma_\alpha$ being
the Hatcher single-step output (level shift $-2$). The 6/12 single-step
cases satisfy this; the remaining 6 require Lemma 2.1 applied at each
intermediate surgery step (§4).

---

## 3. Proof

By the Bigon Criterion (Hass–Scott 1985 / Farb–Margalit Theorem 1.7),
two simple closed curves are in minimal position if and only if they
admit no embedded bigon. Apply this to the pair $(\beta, \alpha)$ and
to the pair $(\beta, \gamma_0)$: by hypothesis both pairs are in
minimal position, so neither admits a bigon.

The intersection of $\beta$ with the closed disc $D$ is a finite
disjoint union of properly embedded arcs in $D$ (since $\beta$ is a
simple closed curve and $D$ is a disc). Each such arc has both
endpoints on $\partial D = a_S \cup g_S$, which yields three types:

- **(SS)** both endpoints on $a_S$;
- **(GG)** both endpoints on $g_S$;
- **(SG)** one endpoint on $a_S$, the other on $g_S$.

**Claim 3.1.** *In minimal position, $\beta \cap D$ contains no (SS) arcs
and no (GG) arcs.*

*Proof.* Suppose $\eta \subset \beta \cap D$ is an (SS) arc with both
endpoints on $a_S$. Then $\eta$ together with the sub-arc of $a_S$
between its endpoints bounds a sub-disc $D' \subset D$. Since
$a_S \subset \alpha$ and $\eta \subset \beta$, $D'$ is a bigon between
$\alpha$ and $\beta$ — contradicting minimal position of
$(\alpha, \beta)$. The (GG) case is identical with $\gamma_0$ in place
of $\alpha$. $\square$

Hence every arc of $\beta \cap D$ is of type (SG). Each (SG) arc
contributes exactly one crossing to $\beta \cap a_S$ and exactly one
crossing to $\beta \cap g_S$, so

$$
|\beta \cap a_S| \;=\; \#\{\text{SG arcs}\} \;=\; |\beta \cap g_S|.
$$

(Both equalities hold globally, since $a_S, g_S \subset \partial D$
and $\beta \cap a_S, \beta \cap g_S$ are entirely contained in $D$.)

**Upper bound.** In the constructed position
$\sigma_\alpha = a_L \cup g_S$ (before any further isotopy),

$$
|\beta \cap \sigma_\alpha|_{\text{constructed}}
\;=\; |\beta \cap a_L| + |\beta \cap g_S|
\;=\; |\beta \cap a_L| + |\beta \cap a_S|
\;=\; |\beta \cap \alpha|_{\text{minimal}}
\;=\; i(\alpha, \beta),
$$

so $i(\sigma_\alpha, \beta) \le i(\alpha, \beta)$, since the
geometric intersection number is the minimum over all isotopies.

**Lower bound (parity / homology).** The 1-cycle $\sigma_\alpha - \alpha$
equals $g_S - a_S = \partial D$ in the cellular chain complex of $S$,
so $[\sigma_\alpha] = [\alpha]$ in $H_1(S; \mathbb Z)$. Algebraic
intersection $\hat\imath(\cdot, \beta)$ depends only on the homology
class, so $\hat\imath(\sigma_\alpha, \beta) = \hat\imath(\alpha, \beta)$.
Geometric and algebraic intersection numbers agree modulo 2 (each
transverse crossing contributes $\pm 1$ to $\hat\imath$ and $1$ to $i$),
hence

$$
i(\sigma_\alpha, \beta) \;\equiv\; \hat\imath(\sigma_\alpha, \beta)
\;=\; \hat\imath(\alpha, \beta) \;\equiv\; i(\alpha, \beta) \pmod 2.
$$

Combining: when $i(\alpha, \beta) = 0$ the upper bound gives
$i(\sigma_\alpha, \beta) = 0$; when $i(\alpha, \beta) = 1$ the upper
bound gives $\le 1$ and the parity congruence gives $\equiv 1 \pmod 2$,
so $i(\sigma_\alpha, \beta) = 1$. In both cases
$i(\sigma_\alpha, \beta) = i(\alpha, \beta)$. $\qquad\blacksquare$

### 3.1 Case split aligned with $i(\alpha, \beta) \in \{0, 1\}$

The proof above is uniform; for clarity we restate the conclusion in
the two sub-cases dictated by $\beta \in \mathrm{Lk}^\downarrow(\alpha)$:

**Case $i(\alpha, \beta) = 0.$** $\beta \cap \alpha = \emptyset$, so
$\beta \cap a_S = \emptyset$ and $\beta \cap a_L = \emptyset$. By
Claim 3.1, no (SG) arcs (since both endpoints would touch $a_S$),
no (SS) arcs, and no (GG) arcs (minimal position with $\gamma_0$).
Hence $\beta \cap D = \emptyset$, so $\beta \cap g_S = 0$.
$\;i(\sigma_\alpha, \beta) = 0 + 0 = 0$. $\checkmark$

**Case $i(\alpha, \beta) = 1$, crossing $q \in a_L$.** $\beta$ misses
$a_S$ entirely. Then any arc of $\beta \cap D$ has neither endpoint on
$a_S$, forcing type (GG), which Claim 3.1 forbids. So
$\beta \cap g_S = 0$, and $\;i(\sigma_\alpha, \beta) = 1 + 0 = 1$.
$\checkmark$

**Case $i(\alpha, \beta) = 1$, crossing $q \in a_S$.** Exactly one arc
of $\beta \cap D$ has an endpoint at $q$ on $a_S$. Its other endpoint
must be on $\partial D$. By Claim 3.1, it cannot be on $a_S$ (no (SS)),
so it is on $g_S$ — an (SG) arc. The remaining arcs of $\beta \cap D$
have endpoints in $\partial D \setminus \{q\}$ which lies entirely on
$g_S$ (since $\beta$ meets $a_S$ only at $q$); these are (GG) arcs,
forbidden by Claim 3.1. So there is exactly one (SG) arc, contributing
$|\beta \cap g_S| = 1$. $\;i(\sigma_\alpha, \beta) = 0 + 1 = 1$.
$\checkmark$

In every case $i(\sigma_\alpha, \beta) = i(\alpha, \beta)$.

---

## 4. The multi-step cases close via a parity argument

Of the 12 non-chordal S_{1,2} DLs, only **6 admit a level-$(k-2)$
universal vertex** in the curver-enumerated database. The other 6
present their canonical universal vertex at strictly lower level
(shift $-4$ in 5 cases; shift $-6$ in 1 case at $k = 8$). For these,
the iterated Hatcher single-step interpretation does not embed in the
BFS-truncated database (`gap1_chain_finder.py` exhibits the obstruction:
zero level-$(k-2)$ curves disjoint from these specific $\alpha$'s in any
depth-4 MCG ball, despite the level-$(k-2t)$ canonical filler being
disjoint from $\alpha$).

A simpler argument bypasses iteration entirely. The single-step proof
of §3 used two ingredients: an upper bound (from the disc decomposition
of $\beta \cap D$) and a lower bound (from the homology fact
$[\sigma_\alpha] = [\alpha]$ giving parity). For the multi-step case,
the upper bound is **already supplied by the search criterion**:
$\sigma_\mathrm{curver}$ is selected as a universal vertex of
$\mathrm{Lk}^\downarrow(\alpha)$, so $i(\sigma_\mathrm{curver}, \beta)
\le 1$ for every $\beta \in \mathrm{Lk}^\downarrow(\alpha)$ by
construction. The lower bound is supplied by parity, *if* the
homological condition still holds.

**Lemma 4.1 (Universal-vertex bigon cancellation).**
*Let $\alpha, \gamma_0, \beta$ be as in §1. Suppose $\sigma$ is a
simple closed curve on $S_{1,2}$ satisfying:*

*(a) $\sigma$ is a universal vertex of $\mathrm{Lk}^\downarrow(\alpha)$:
$\,i(\sigma, \beta') \le 1$ for every $\beta' \in
\mathrm{Lk}^\downarrow(\alpha)\,$;*

*(b) $[\sigma] = [\alpha]$ in $H_1(S_{1,2}; \mathbb Z / 2)$.*

*Then $i(\sigma, \beta) = i(\alpha, \beta)$ for every $\beta \in
\mathrm{Lk}^\downarrow(\alpha)$.*

*Proof.* From (a), $i(\sigma, \beta) \le 1$. From (b), the algebraic
intersection $\hat\imath(\sigma, \beta)$ depends only on the mod-2
homology classes, so $\hat\imath(\sigma, \beta) \equiv
\hat\imath(\alpha, \beta) \pmod 2$. Geometric and algebraic
intersection numbers agree mod 2 (each transverse crossing contributes
$1$ to $i$ and $\pm 1$ to $\hat\imath$), giving

$$
i(\sigma, \beta) \;\equiv\; \hat\imath(\sigma, \beta) \;\equiv\;
\hat\imath(\alpha, \beta) \;\equiv\; i(\alpha, \beta) \pmod 2.
$$

When $i(\alpha, \beta) = 0$: $i(\sigma, \beta) \le 1$ and even,
so $= 0$. When $i(\alpha, \beta) = 1$: $i(\sigma, \beta) \le 1$
and odd, so $= 1$. $\qquad\blacksquare$

**Empirical verification of (b).** The script
`gap1_homology_check.py` computes the mod-2 H_1-coordinate
$\bigl(i(\sigma, a_0), i(\sigma, b_0), i(\sigma, p_1)\bigr) \bmod 2$
for $\alpha$ and for $\sigma_\mathrm{curver}$ on each of the 12
non-chordal cases:

```
alpha  k f(s) shift   [alpha]_2   [sigma]_2  match?
   38  4    2    -2   (0, 1, 0)   (0, 1, 0)     YES
  105  4    2    -2   (0, 1, 0)   (0, 1, 0)     YES
  117  4    2    -2   (0, 1, 0)   (0, 1, 0)     YES
  119  4    2    -2   (0, 1, 0)   (0, 1, 0)     YES
  118  5    3    -2   (1, 1, 1)   (1, 1, 1)     YES
   88  6    2    -4   (0, 1, 0)   (0, 1, 0)     YES
  186  6    4    -2   (0, 1, 0)   (0, 1, 0)     YES
  253  6    2    -4   (0, 1, 0)   (0, 1, 0)     YES
  268  6    2    -4   (0, 1, 0)   (0, 1, 0)     YES
  270  6    2    -4   (0, 1, 0)   (0, 1, 0)     YES
  269  7    3    -4   (1, 1, 1)   (1, 1, 1)     YES
  236  8    2    -6   (0, 1, 0)   (0, 1, 0)     YES
```

12/12 PASS **on S_{1,2}**. Hence Lemma 4.1's hypothesis (b) is satisfied
for every $\sigma_\mathrm{curver}$ produced by `SurfaceGeo.cut_glue`
**when the underlying surface is S_{1,2}**, and the lemma closes the
bigon-cancellation property for all 12 non-chordal S_{1,2} cases —
both single-step and multi-step.

**Important scope caveat (added 2026-04-30 after stress testing).** The
hypothesis $[\sigma_\mathrm{curver}] = [\alpha]$ in $H_1(\mathbb Z/2)$
is **not auto-satisfied on other surfaces**. Concretely, on S_{2,1}
the diagnostic `_diagnose_s21_failures.py` exhibits at least 5 alphas
($\{122, 151, 215, 221, 249\}$) for which $[\sigma_\mathrm{curver}] \ne
[\alpha]$ in $H_1(\mathbb Z/2)$, and a corresponding stress test
(`stress_test_theorem3.py`) finds 93 counterexample pairs on S_{2,1}
where $i(\sigma_\mathrm{curver}, \beta) \ne i(\alpha, \beta)$. **The
universal-vertex search criterion of `SurfaceGeo.cut_glue` is strictly
weaker than the true Hatcher single-step construction**: it finds
*some* universal vertex of $\mathrm{Lk}^\downarrow(\alpha)$, which on
S_{1,2} happens to coincide with the Hatcher output up to homology,
but on S_{2,1} can be a different curve entirely.

**Implication for OP-1 closure**: the 389/389 contractibility coverage
in §6 is **not affected** — the contractibility of $\Delta(\mathrm{Lk}
^\downarrow(\alpha))$ for non-chordal-cone DLs follows from
$\sigma_\mathrm{curver}$ being a universal vertex (a cone is
contractible regardless of which vertex is the apex), and does not
depend on $i(\sigma_\mathrm{curver}, \beta) = i(\alpha, \beta)$.
The Hatcher-surgery interpretation of $\sigma_\mathrm{curver}$ is a
*decorative* property that holds on S_{1,2}'s 12 non-chordal cases
but does not generalize uniformly to other surfaces.

**Status.** The single-step S_{1,2} cases (§3) close rigorously
without any empirical input beyond standard curve-complex theory.
The multi-step S_{1,2} cases close *conditional on (b) for S_{1,2}*,
verified 12/12. A future strengthening would be either (i) a uniform
proof that the search-found $\sigma_\mathrm{curver}$ always equals
the true Hatcher output on S_{g,n} (false in general — see the S_{2,1}
counterexamples), or (ii) a constructive single-step Hatcher
implementation in `SurfaceGeo` that produces the geometrically
correct $\sigma_\alpha^\mathrm{Hatcher}$ rather than a universal-vertex
substitute.

---

## 5. SurfaceGeo per-step verification

The companion verifier
`workspace/projects/op1_geometry/verify_bigon_proof.py` discharges
each step (P0–P3) on the 12 non-chordal cases. Re-run with:

```
wsl -e bash -lc "cd /mnt/c/Users/12729/Desktop/Math && \
   python3 workspace/projects/op1_geometry/verify_bigon_proof.py"
```

Output (2026-04-30):

```
alpha  k f(s) shift  step |DL|  P1 i<=1? i=0 cases i=1 cases   P2   P3
----------------------------------------------------------------------
   38  4    2    -2     1    9       YES         1         8 PASS PASS
  105  4    2    -2     1    8       YES         1         7 PASS PASS
  117  4    2    -2     1    8       YES         1         7 PASS PASS
  119  4    2    -2     1    8       YES         1         7 PASS PASS
  118  5    3    -2     1    8       YES         1         7 PASS PASS
   88  6    2    -4   mul    9       YES         1         8 PASS PASS
  186  6    4    -2     1    8       YES         1         7 PASS PASS
  253  6    2    -4   mul    8       YES         1         7 PASS PASS
  268  6    2    -4   mul    8       YES         1         7 PASS PASS
  270  6    2    -4   mul    8       YES         1         7 PASS PASS
  269  7    3    -4   mul    8       YES         1         7 PASS PASS
  236  8    2    -6   mul    9       YES         1         8 PASS PASS
```

| Step | Description | Result |
|---|---|---|
| **P0** | `SurfaceGeo.cut_glue` produces $\sigma_\alpha$ for every case | 12/12 |
| **P1** | Every $\beta \in \mathrm{Lk}^\downarrow(\alpha)$ has $i(\alpha, \beta) \in \{0, 1\}$ — proof's hypothesis | 12/12 (0 violations across 99 pairs) |
| **P2** | $i(\sigma_\alpha, \beta) = i(\alpha, \beta)$ — the lemma's conclusion | **99/99 pairs PASS** |
| **P3** | Each $i = 1$ crossing localises in `SurfaceGeo.count_incidence` triangle data — the granularity §3 reasons over | 87/87 pairs PASS |

**Single-step coverage:** 6/12 cases — α ∈ {38, 105, 117, 119, 118, 186}.
For these, Lemma 2.1 closes the lemma rigorously.

**Multi-step caveat:** 6/12 cases — α ∈ {88, 253, 268, 270, 269, 236}.
For these, P2 confirms the conclusion empirically; rigorous closure
requires Lemma 4.1's intermediate-step minimal-position hypothesis.

---

## 6. Net status

- **Closed (rigorous):** Lemma 2.1 closes the 6 single-step S_{1,2}
  cases unconditionally.

- **Closed (conditional on a finite-data homology check):** Lemma 4.1
  closes the 6 multi-step S_{1,2} cases. The condition
  $[\sigma_\mathrm{curver}] = [\alpha]$ in $H_1(S_{1,2}; \mathbb Z/2)$
  is verified 12/12 by `gap1_homology_check.py`.

- **Combined coverage on S_{1,2}**: chordal 259/271 (PEO) + cone-or-
  arc-disjoint 12/271 (Lemmas 2.1 / 4.1) = **271/271 rigorous mod the
  homology check**.

- **Combined coverage on S_{1,1}**: 71/71 rigorous (Stern–Brocot,
  §11.8.1).

- **Closed (Gap 2, two-step almost-cone):** the 6 $S_{2,1}$ $k=2$
  non-chordal-non-cone cases at $\alpha \in \{33, 77, 192, 208, 210,
  211\}$ via Lemma 7.1 below.

- **Total OP-1 coverage**: $71 + 271 + 47 = \mathbf{389/389}$ DLs
  closed (rigorous mod two finite-data computational checks: the
  H_1(ℤ/2) check on 6 multi-step S_{1,2}'s, and the (v_1, v_2)
  almost-cone structure on 6 S_{2,1} k=2's; both verifiers pass on
  every relevant case).

- **Lean ingestion:** Lemma 2.1 is finite-data over a fixed surface
  (the disc $D$, four arc types, three case branches) and back-
  translates cleanly to a Mathlib statement on simple closed curves
  + bigon criterion. Architecture v1 §A.5 (the Aligner) accepts this
  shape; expected LOC budget 200–300 in the Stage 4 tactic-filler
  loop. Hand-off to the Lean pipeline is the recommended next step.

---

## 7. Gap 2: the 6 S_{2,1} k=2 non-chordal-non-cone DLs

For $\alpha \in \{33, 77, 192, 208, 210, 211\}$ on $S_{2,1}$ at $k=2$,
the descending link $\mathrm{Lk}^\downarrow(\alpha)$ is neither chordal
nor a simplicial cone, so Lemmas 2.1 and 4.1 do not apply. A separate
argument closes contractibility via a two-vertex pre-cone structure.

**Lemma 7.1 (Two-step almost-cone).**
*Let $G$ be a finite simple graph with $\ge 3$ vertices. Suppose:*

*(i) there exists $v_1 \in V(G)$ with $\deg(v_1) = |V(G)| - 2$ —
i.e. $v_1$ is adjacent to every other vertex except a unique $v_2$;*

*(ii) $v_2$ is dominated in $G$: there exists $w \in N(v_2) \setminus
\{v_2\}$ with $N[v_2] \subseteq N[w]$.*

*Then $G$ is dismantlable, and the flag complex $\Delta(G)$ is
contractible.*

*Proof.* By (ii), removing $v_2$ from $G$ is a dismantling step; the
flag-complex inclusion $\Delta(G \setminus v_2) \hookrightarrow
\Delta(G)$ is a homotopy equivalence (Boulet–Fieux–Jouve 2008, the
dismantlable ⇔ strongly collapsible theorem). By (i), $v_1$ is
adjacent to every vertex of $G \setminus v_2$, so $\Delta(G \setminus
v_2)$ is the simplicial cone with apex $v_1$ over the link of $v_1$,
hence contractible. $\qquad\blacksquare$

**Empirical verification.** The script
`workspace/projects/op1_geometry/gap2_almost_cone.py` discovers an
explicit $(v_1, v_2, w)$ triple satisfying (i)+(ii) on each of the
6 cases:

```
alpha |DL|  v1 (deg=|DL|-2)  v2 (non-neighbor)  v2 dominated by  cone(G\v2)
   33   60                2                171         first: 6        YES
   77   45                2                 63         first: 1        YES
  192   34                2                 63         first: 1        YES
  208   48                8                169         first: 4        YES
  210   35                9                 13         first: 1        YES
  211   34                2                 63         first: 1        YES
```

6/6 PASS. Hence Lemma 7.1 closes contractibility for every
$S_{2,1}$ $k=2$ non-chordal-non-cone DL.

The fact that 4 of the 6 share the same $(v_1, v_2)$ values $(2, 63)$
suggests an underlying MCG-equivariance: these alphas may all
reduce to a single "model" DL via the action of MCG$(S_{2,1})$
on the curve database. Confirming this would strengthen Lemma 7.1
into a single uniform argument; it is a separate combinatorial
exercise.

---

## 8. References

- [Hat91] A. Hatcher, *On triangulations of surfaces*, Topology Appl.
  40 (1991), 189–194 — the §2 surgery construction $\sigma_\alpha$.
- [HS85] J. Hass, P. Scott, *Intersections of curves on surfaces*,
  Israel J. Math. 51 (1985), 90–120 — the bigon criterion.
- [FM12] B. Farb, D. Margalit, *A primer on mapping class groups*,
  Princeton, 2012 — Theorem 1.7 (no-bigon ⇔ minimal position).
- `workspace/projects/op1_geometry/reports/op1_detailed.md` §11.8 —
  the empirical setup and 49/49 evidence.
- `workspace/agents_spec/geometric_reasoner.md` — the Reasoner
  Protocol whose `cut_glue` op produces the $\sigma_\alpha$ this
  proof analyses.
- `LeanAgent/registry/representations/entries.jsonl` —
  `rep_034_hatcher_surgery_output` whose `proof_obligation` this
  proof discharges (single-step cases).
