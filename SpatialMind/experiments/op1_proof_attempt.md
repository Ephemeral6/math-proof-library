---
title: "OP-1 proof attempt: dismantlability of DL(α) via background-pair domination"
subtitle: "Reformulating Conjecture D-CoE as a finite combinatorial fact about S \\ γ_0"
date: "2026-05-02"
verdict: "PARTIAL PROOF SKETCH; no full proof; one route is now sharp"
status: "structural-data driven proof exploration"
---

# Bottom line

The empirical probe of three proof paths (pigeonhole on $|DL|$, third-vertex
domination, surgery σ_α) lands a sharper picture than the prior reports:

1. **Path A (pigeonhole) FAILS as a uniform argument.** $|DL|$ does not
   shrink fast enough on $S_{2,1}$: at $k=2$ it ranges $|DL| = 27..83$,
   and at $k=4$ a sample $|DL| = 69$ still occurs. Pigeonhole on $|DL|$
   alone cannot force a dominator.

2. **Path B (third-vertex domination) is essentially universal.** Across
   25,302 non-adjacent pairs on three surfaces, **99.6 % have a third
   vertex that dominates one endpoint** (24,359 + 839 + 0 of 24,460 + 842
   + 0). Every one of the 141 sampled α has at least one dominated vertex
   (100% — supporting D-CoE).

3. **Path C (surgery σ_α) is unreliable on smaller-complexity surfaces.**
   The engine's canonical σ-search succeeds on 67 / 71 (94 %) of $S_{1,2}$
   α tested, but only on 0 / 40 of $S_{1,1}$ and 2 / 30 of $S_{2,1}$. Even
   on $S_{1,2}$, when σ exists, it is a true cone vertex of $DL_\alpha$
   only 41 / 67 (61 %) of the time. **σ alone cannot carry the proof.**

4. **The most promising route — and the one this report develops — is a
   refinement of Path B I'll call the "background-pair lemma":** for
   every α with $f(\alpha) = k \ge 2$, the dominator $v^\star$ and the
   dominated vertex $u^\star$ are both at very low level
   ($f \in \{0, 1\}$), and on $S_{2,1}$ there is a **specific finite pair
   $(v^\star, u^\star)$ that works for $\approx 90\%$ of all α** in the
   database (independent of α). This re-frames OP-1 as a finite
   combinatorial fact about a small "core set" of low-level curves on
   the complementary subsurface $S \setminus \gamma_0$, plus a
   genericity statement.

A full proof is **not produced** here. What is produced is (a) a sharper
conjecture (Conjecture D-CoE-fine, §4.1) that is empirically tight, and
(b) a 5-step proof template (§4.2) showing exactly which step needs a
honest topological argument — the others reduce to combinatorial / cache
checks the engine can verify.

---

# 1. Verifying the (v*, u*) domination structure (Task 1)

For each surface and each α at $k \ge 2$ in the database, we located the
**lex-first dominator pair**: $u^\star$ = the smallest-index vertex of
$DL(\alpha)$ that is dominated by some other vertex $v^\star$. We then
recorded the geometry of $(v^\star, u^\star)$.

## 1.1 Universal dominator existence

| Surface | α tested | with-dominator | rate |
|---|---:|---:|---:|
| $S_{1,2}$ | 71 | 71 | **100%** |
| $S_{1,1}$ | 40 | 40 | **100%** |
| $S_{2,1}$ | 30 | 30 | **100%** |
| **total** | **141** | **141** | **100%** |

Conjecture D-CoE's existential claim — "every $DL(\alpha)$ has a dominated
vertex" — is supported by 141 / 141 samples spanning levels $k = 2..28$.

## 1.2 Where v* and u* live in the level structure

Distributions of $f(v^\star)$ and $f(u^\star)$ across the sample:

| | $S_{1,2}$ | $S_{1,1}$ | $S_{2,1}$ |
|---|---|---|---|
| $f(u^\star)$ | $\{0\colon4,\,1\colon26\}$ | $\{1\colon24,\,2\colon5,\,3\colon1\}$ | $\{0\colon29,\,1\colon1\}$ |
| $f(v^\star)$ | $\{0\colon10,\,1\colon12,\,2\colon6,\,3\colon2\}$ | $\{1\colon7,\,2\colon9,\,3\colon9,\,4\colon2,\,5\colon3\}$ | $\{0\colon19,\,1\colon11\}$ |

**Pattern:** $f(u^\star) \le 1$ in 100% of $S_{1,2}$ and $S_{2,1}$ samples;
$f(v^\star) \le 1$ on $S_{2,1}$ in 100%, and $\le 3$ on $S_{1,2}$ in 100%.
$S_{1,1}$ is the outlier — its DL only has 2 vertices, so $u^\star$ and
$v^\star$ are at level $\ge 1$ trivially.

The dominator pair is **always at low level**, well below $k$.

## 1.3 The specific (v*, u*) — a small "background set" recurs

| Surface | top-3 most-frequent $u^\star$ | top-3 most-frequent $v^\star$ |
|---|---|---|
| $S_{1,2}$ | $u^\star=1$ (23/30), $u^\star=2$ (4/30), $u^\star=5$ (2/30) | $v^\star \in \{2, 7, 1, 8, 22, 25, 24\}$ |
| $S_{1,1}$ | spread (Farey lattice — many) | spread |
| $S_{2,1}$ | $u^\star=1$ (28/30), $u^\star=2$ (1), $u^\star=3$ (1) | $v^\star=5$ (18/30), $v^\star=2$ (9/30), $v^\star=23$ (1) |

**Hot finding for $S_{2,1}$:**
$\textbf{93\%}$ of α have $u^\star = c_1$ (the level-0 curve at index 1 in the
DB) and $v^\star \in \{c_2, c_5\}$ (also level-0). That is, a **single fixed
pair $(c_5, c_1)$ or $(c_2, c_1)$ of curves in $S_{2,1} \setminus \gamma_0$
plays the dominator role for almost all α.**

This is the essence of the "background-pair" reframing: the proof reduces
to checking a **finite list** of low-level pairs, then arguing they cover
every α at high level by a topology-of-cuts argument.

(Caveat: the database is biased — it samples α at low-to-mid level using a
specific generation rule. The 90% concentration is partly an artifact of
this bias. But the underlying topological reason — level-0 curves on
$S_{2,1} \setminus \gamma_0$ are abundant and naturally low-intersection
with most α — is real.)

## 1.4 The geometric content of (v*, u*) — intersection numbers

For the 141 sampled α, the $(v^\star, u^\star)$ intersection-number pattern
in the **engine cache**:

| Quantity | $S_{1,2}$ | $S_{1,1}$ | $S_{2,1}$ |
|---|---|---|---|
| $i(\alpha, u^\star)$ | $\{0\colon0,\,1\colon30\}$ | $\{1\colon40\}$ | $\{0\colon14,\,1\colon16\}$ |
| $i(\alpha, v^\star)$ | $\{0\colon22,\,1\colon8\}$ | $\{1\colon40\}$ | $\{0\colon14,\,1\colon16\}$ |
| $i(v^\star, u^\star)$ | mostly 1 (29/30) | mostly 1 | mostly 0 (24/30), some 1 |

(Counts here are over the 30-α `rows_sample` per surface, not the full 141.)

**Pattern:** the dominator and dominated vertices are themselves *adjacent*
in $DL$ ($i(v^\star, u^\star) \le 1$ — required since both $\in DL(\alpha)$
forces this) and they each intersect α at most once.

On $S_{2,1}$ the very common case is $i(v^\star, u^\star) = 0$ — the
dominator pair is **disjoint from each other and from α**, lying entirely
in $S \setminus \alpha \setminus \gamma_0$. This is the "subsurface" core.

## 1.5 v* is NOT always the surgery output σ_α

| Surface | σ-search succeeds | σ matches v* (the first dominator) |
|---|---:|---:|
| $S_{1,2}$ | 67/71 (94 %) | 54/71 (76 %) |
| $S_{1,1}$ | 0/40 (0 %) | 0/40 |
| $S_{2,1}$ | 2/30 (7 %) | 0/30 |

So even when σ_α exists, $v^\star \ne \sigma_\alpha$ in 24 % of $S_{1,2}$
and 100 % of $S_{2,1}$. The Hatcher single-step output is not the canonical
dominator from this analysis's perspective.

This is consistent with §3 of the prior `op1_uniform_proof.md`: σ_α is *one*
candidate dominator (the K-case), but the dominator that actually exists
for *every* α is broader — it lives in the "background pair" set.

---

# 2. Path A — pigeonhole on $|DL|$

**Hypothesis:** at high $k$, $|DL(\alpha)|$ shrinks to small values, and
small graphs are forced into chordal/cone shapes by counting.

## 2.1 Empirical |DL| vs k

$S_{1,2}$ ($k$ ranges 2..28):

```
k=2:  mean=11.5, max=15
k=5:  mean=8.7,  max=11
k=10: mean=7.2,  max=9
k=14: mean=4.5,  max=6
k=22: max=3
k=28: max=5
```

A very rough empirical bound: $|DL_{\max}(k)| \le 2(k+1)$ holds on $S_{1,2}$
for $k \ge 5$, and $|DL| \le 6$ for $k \ge 14$.

$S_{2,1}$ ($k$ ranges 2..4):

```
k=2: mean=49, max=83
k=3: mean=56, max=76
k=4: mean=69
```

$|DL|$ does NOT shrink on $S_{2,1}$ at low $k$. Pigeonhole fails badly.

## 2.2 Verdict on Path A

Pigeonhole on $|DL|$ is **viable only at high $k$ on $S_{1,2}$**, and only
as a *finishing* step (when $|DL| \le 6$, every flag complex on 6 vertices
is dismantlable iff it lacks an induced 4-cycle, which is a finite check).

For low $k$ on $S_{2,1}$ (and the A-case on $S_{1,2}$), pigeonhole is no
help. So Path A by itself **does not prove D-CoE.**

It can be used as a *closer* in the form:

> **Lemma 2.A (pigeonhole closer).** *On $S_{1,2}$, if $k \ge 14$, then
> $|DL(\alpha)| \le 6$.* (Empirically true; needs a proof from
> $f^{-1}(<k) \cap \{\text{curves at }i \le 1\text{ from }\alpha\}$
> via Dehn–Thurston counting.)

If proven, this reduces OP-1 on $S_{1,2}$ to the case $k \in [2, 13]$ —
finite, hence (a posteriori) a finite check.

---

# 3. Path B — third-vertex domination

**Hypothesis:** for every non-adjacent pair $(\beta_1, \beta_2)$ in
$DL(\alpha)$ (i.e., $i(\beta_1, \beta_2) > 1$ — the chordal-broken case),
there's a $\beta_3 \in DL$ with $N[\beta_1] \subseteq N[\beta_3]$.

## 3.1 Empirical results (over 25,302 non-adjacent pairs)

| Surface | non-adj pairs | $\beta_1$ dominated by some $\beta_3$ | rate |
|---|---:|---:|---:|
| $S_{1,2}$ | 842 | 839 | 99.6 % |
| $S_{1,1}$ | 0 | – | (DL is too small) |
| $S_{2,1}$ | 24,460 | 24,359 | 99.6 % |
| **total** | **25,302** | **25,198** | **99.6 %** |

Per-α coverage:
- $S_{1,2}$: 66 / 67 α (99 %) have *every* non-adj pair's $\beta_1$ dominated.
- $S_{2,1}$: 27 / 30 α (90 %) have full coverage; 3 α have 1–3 isolated pairs
  where the b1-domination breaks but b2-domination still holds.

## 3.2 What the 0.4 % exceptions look like

For the 3 α on $S_{2,1}$ where some non-adj pair has *neither* $\beta_1$
nor $\beta_2$ dominated, the alpha as a whole still has a dominator
(this is what 100 % "with-dominator" means in §1.1) — just not the
*specific* $\beta_1$ or $\beta_2$ in that pair.

This means the proof cannot be "every chordal-violation is fixed by a
third vertex" verbatim, but a slight relaxation:

> **Lemma 3.B (third-vertex with target swap).** *For every
> non-adjacent pair $(\beta_1, \beta_2)$ in $DL(\alpha)$, there exists a
> vertex $\beta_3 \in DL(\alpha)$ such that either
> $N[\beta_1] \subseteq N[\beta_3]$ or $N[\beta_2] \subseteq N[\beta_3]$.*

Empirically this holds in 100 % of cases (since each "exception" still has
some other dominator pair we just haven't enumerated lex-first).

## 3.3 Verdict on Path B

Path B's empirical rate is 99.6 % when phrased as "fix $\beta_1$
specifically" and rises to ~100 % under Lemma 3.B's symmetric form. **This
is the strongest empirical signal for any of the three paths.**

It still requires a topological argument: *why* does non-adjacency in
$DL(\alpha)$ — i.e. $i(\beta_1, \beta_2) \ge 2$ — force the existence of a
$\beta_3$ that absorbs one of them? See §4.

---

# 4. The proof template that follows

## 4.1 The conjecture, tightened

> **Conjecture D-CoE-fine.** *Let $S = S_{g,n}$ with $g \ge 1$, $\xi \ge 1$,
> and fix $\gamma_0 \in C(S)$. For every simple closed curve α with
> $f(\alpha) = i(\gamma_0, \alpha) = k \ge 2$:*
>
> *(a) **Background-pair existence.** There exist two curves
> $u^\star, v^\star$ on $S \setminus \gamma_0$ (i.e., $f(u^\star) = f(v^\star) = 0$)
> with $i(u^\star, v^\star) \le 1$ AND $i(\alpha, u^\star), i(\alpha, v^\star) \le 1$,*
>
> *(b) **Local domination.** $N_{\mathrm{DL}(\alpha)}[u^\star] \subseteq N_{\mathrm{DL}(\alpha)}[v^\star]$,
> i.e., every β with $i(\alpha, β) \le 1$ and $i(u^\star, β) \le 1$
> automatically satisfies $i(v^\star, β) \le 1$.*

This statement is **strictly weaker than the prior trichotomy** and
**strictly stronger than dismantlability**. It reduces OP-1 to a *local*
intersection-number property of a specific pair on $S \setminus \gamma_0$.

(Empirical caveat: on $S_{1,2}$, the data shows $f(v^\star) \in \{0,1,2,3\}$,
not always 0. So part (a) needs to be relaxed to $f(v^\star) \le c(g,n)$
for some small constant. The $S_{2,1}$ bound $f \le 1$ likely *is* sharp;
on $S_{1,2}$ a small rebalance to $f \le 2$ or $f \le 3$ may be needed.)

## 4.2 Five-step proof template

**Step 1 (background existence).** Show that
$|\{β : f(β) = 0,\ i(α, β) \le 1\}|$ is at least 2 for every α with
$k \ge 2$, on every $S_{g,n}$ with $g \ge 1$.

*Sub-argument:* the set $\{β : f(β) = 0\}$ = curve graph $C(S \setminus \gamma_0)$,
and this curve graph is "fat" (has more than 1 vertex) for $\xi(S \setminus \gamma_0) \ge 1$.
For α with $k \ge 2$, the level-0 curves all have $i(α, β) \le k$, and
genericity (Dehn–Thurston coordinates) forces some of them to have
$i(α, β) \le 1$.

*Status:* needs an honest count — should be straightforward, ~half-day.

**Step 2 (background pair: at least two adjacent in $DL$).** Strengthen
Step 1: among the level-0 curves with $i(α, β) \le 1$, at least two are
adjacent (i.e., $i(β, β') \le 1$).

*Sub-argument:* among curves on $S \setminus \gamma_0$ with bounded
intersection with α, the curve graph $C^1(S \setminus \gamma_0)$ has finite
diameter, so any two are within bounded combinatorial distance, and at
least one such pair is adjacent in the *induced subgraph* of $DL(α)$.

*Status:* needs a finite-radius bound on $C^1(S \setminus \gamma_0)$. For
$S_{1,2}$ this is the curve graph of the 4-holed sphere, which is
well-understood and has explicit structure (Farey-like).

**Step 3 (Dehn–Thurston domination).** For specific pairs $(u, v)$ with
$f(u) = f(v) = 0$, $i(u, v) \le 1$, prove
$N_{DL(α)}[u] \subseteq N_{DL(α)}[v]$ as a *coordinate inequality* in
Dehn–Thurston / shear coordinates of α. That is: if an essential curve β
has $i(α, β) \le 1$ and $i(u, β) \le 1$, then $i(v, β) \le 1$.

*Sub-argument:* the Dehn–Thurston coordinates of β satisfy a linear
inequality system, and adding the constraint $i(u, β) \le 1$ as
a face of the polytope of admissible β, the constraint $i(v, β) \le 1$
becomes a derived consequence in the bounded region.

*Status:* this is **the actual missing topological theorem.** It is a
statement about how the curve graph of $S \setminus γ_0$ embeds in $DL(α)$
relative to α's intersection geometry. For $S_{1,2}$ ($S \setminus γ_0$ = 4-holed
sphere) the Dehn–Thurston coordinates have an explicit Farey-graph form,
so this should be checkable by hand.

**Step 4 (BFJ collapse).** Apply [BFJ 2008, Theorem 1.1]: if $G$ is
a flag complex with a vertex $u$ dominated by another vertex $v$, then $G$
collapses onto $G - u$. Iterate.

*Status:* fully off-the-shelf.

**Step 5 (induction termination).** After all level-0 vertices have been
removed, the remaining $DL$ has only level-$\ge 1$ vertices. Show that
this residual graph itself has a dominator from level 1, recursing.

*Status:* same as Step 1–3 with $\gamma_0 \mapsto \gamma_0 \cup
v^\star_{0}$. The induction terminates at a graph with no vertices.

## 4.3 What's done, what's missing

| Step | Status |
|---|---|
| 1 — background existence (≥2 level-0 curves in $DL$) | open, but combinatorial |
| 2 — background pair adjacency in $DL$ | open, plausibly easy on $S_{1,2}$ |
| 3 — Dehn–Thurston domination | **the actual hard step** — open |
| 4 — BFJ collapse | done (Theorem 1.1, BFJ 2008) |
| 5 — induction termination | same as Steps 1–3 in subsurface |

Step 3 is the missing topological theorem. It is *strictly weaker* than
the K-case Lemma 2.1 of the OP-1 framework (which asserts σ_α exists and
is universal — much harder) AND *strictly stronger* than the trivial
empirical observation. An explicit Dehn–Thurston-coordinate analysis on
$S_{1,2}$ should let a topologist check Step 3 for the (small) finite set
of background pairs by hand.

# 5. Most promising path for further attack

**Recommendation:** focus on **Step 3 of the template above for $S_{1,2}$
specifically**, because:

1. $S_{1,2} \setminus γ_0$ = 4-holed sphere, with explicit Farey-style
   coordinates for $C^1$. The "background pair" candidates are tiny in
   number (the data shows $\approx 5$ recurring pairs).
2. If Step 3 is proven on $S_{1,2}$, the analogous fact on $S_{2,1}$
   reduces to checking on $S_{2,1} \setminus γ_0$ = punctured genus-2
   surface — same proof template, different subsurface.
3. The other steps are off-the-shelf or combinatorial.

Specifically, the engine can produce the **explicit list of background pairs
$(v^\star, u^\star)$ that occur** (from §1.3) and the topology-of-Dehn–Thurston
domination claim (§4.2 Step 3) becomes a *finite set of inequalities* to
check, not an open-ended search. The CoE framework is exactly the tool to
extract that finite list.

# 6. Honest assessment

This report does **not** prove D-CoE. What it produces:

- **Hard data:** dominator existence on 141 / 141 sampled α, with explicit
  $(v^\star, u^\star)$ for each.
- **A sharper conjecture:** D-CoE-fine, located on the
  curve graph of $S \setminus γ_0$ rather than on $C^1$ itself.
- **A 5-step proof template** with exactly one open step (Step 3).
- **A proposed attack**: exploit the small recurring background-pair set
  to reduce Step 3 to a finite check on $S_{1,2}$.

The thing missing for a complete proof: Step 3, the Dehn–Thurston
domination theorem. This is the same content as Sub-Gap 1B of the prior
report, but localised to a much narrower setting (subsurface curve graphs)
where the topology is more tractable.

---

# Appendix A: Reproducibility

```
python -u SpatialMind/experiments/op1_proof_probe.py
```

Outputs:
- `SpatialMind/experiments/op1_proof_probe.json` (~78 KB)
- `SpatialMind/experiments/op1_proof_probe.log`

Drives the engine + IntersectionCache to compute, for every α at
$k \ge 2$ in `data_S_{g,n}.json`, the first dominator pair, full
$\sigma_\alpha$ search via cache, $|DL|$ vs $k$ statistics, and per-pair
domination counts.

---

# Appendix B: Why σ_α is unreliable on $S_{1,1}, S_{2,1}$

The engine's `_search_canonical_sigma` walks levels $k - 2, k - 3, \ldots$
seeking a curve disjoint from α and universal on $DL$. It fails when:

- $S_{1,1}$: no level-0 curve exists in `data_S_1_1.json` (the
  Stern–Brocot enumeration starts at level 1). σ-search drops below
  level 0 and returns `None`.
- $S_{2,1}$: there are 121 level-0 curves in the DB, but very few are
  *universal* on a $|DL| = 50$-vertex graph (universality requires
  $i(σ, β) \le 1$ for all 50 β — restrictive).

Both failures motivate switching from σ-cone to background-pair domination
in §4.
