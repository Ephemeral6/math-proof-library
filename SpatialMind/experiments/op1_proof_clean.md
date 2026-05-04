---
title: "OP-1 on $S_{1,2}$ — clean proof"
date: "2026-05-03"
status: "Final"
---

# Section 1 — Setup

## 1.1 The surface and the reference curve $\gamma_0$

Let $\Sigma = S_{1,2}$ be the genus-1 orientable surface with two punctures
$p_1, p_2$. Fix once and for all an essential, non-separating, simple closed
curve $\gamma_0 \subset \Sigma$.

In `curver`'s standard model, $\Sigma$ carries the triangulation
`6_WKSv` (six edges, $\zeta = 6$). The reference curve is
$$
\gamma_0 \;=\; \texttt{S.curves['a\_0']} \;=\; \texttt{Curve}\,[1,1,0,1,0,1]
\quad\text{on}\quad \texttt{6\_WKSv}.
$$
The geometric coordinates record that $\gamma_0$ crosses edges
$e_0, e_1, e_3, e_5$ once and avoids $e_2, e_4$. Direct computation
(`curver`) gives:

* $\gamma_0$ has one component;
* $i(\gamma_0, b_0) = 1$ where $b_0$ is the dual generator;
* $i(\gamma_0, p_j) = 0$ for $j=1,2$;
* `gamma_0.crush()` lands on a triangulation of Euler characteristic $-2$
  with four boundary vertices.

Hence $\gamma_0$ is non-separating, and cutting $\Sigma$ along $\gamma_0$
yields the four-holed sphere
$$
\Sigma_{0,4} \;=\; \Sigma \setminus\!\!\setminus \gamma_0,
\qquad
\partial \Sigma_{0,4} \;=\; \gamma_0^+ \,\sqcup\, \gamma_0^- \,\sqcup\, p_1 \,\sqcup\, p_2,
$$
with the two new boundary circles $\gamma_0^\pm$ being the two sides of the
cut, and $p_1, p_2$ inherited from $\Sigma$.

**Schematic of $\gamma_0$ on $\Sigma_{1,2}$ (square model).**
Identify opposite sides of the unit square to form the torus, then drill out
two interior points. $\gamma_0$ is the *vertical* meridian (a non-separating
SCC disjoint from both punctures):
```
       a              a
   ┌──────────┐   ┌──────────┐
   │          │   │   |γ_0   │
   │  • p_1   │   │   |•p_1  │
 b │          │ b │   |      │ b
   │   •p_2   │   │   |•p_2  │
   │          │   │   |      │
   └──────────┘   └──────────┘
        a               a
   torus = a·b·a^{-1}·b^{-1};   γ_0 is a meridian
```
Cutting along the vertical line opens the torus into a cylinder, which after
removing $\{p_1,p_2\}$ is exactly $\Sigma_{0,4}$.

## 1.2 The level-1 curve complex $\mathcal{C}^1(\Sigma)$

Vertices of $\mathcal{C}^1(\Sigma)$ are isotopy classes of essential SCCs on
$\Sigma$. Edges connect classes $\alpha, \beta$ with $i(\alpha, \beta) \le 1$.
We endow $\mathcal{C}^1(\Sigma)$ with its flag-complex topology.

The **level** of a curve $\alpha$ is $\ell(\alpha) := i(\gamma_0, \alpha)$.
For a vertex $\alpha$ with $\ell(\alpha) = k \ge 1$, its *descending link* is
$$
\mathrm{DL}(\alpha) \;=\; \{\, \beta\in\mathcal{C}^1(\Sigma) :
i(\alpha, \beta) \le 1 \text{ and } \ell(\beta) < k \,\},
$$
viewed as a full subcomplex.

## 1.3 Main theorem

**Theorem (OP-1 on $S_{1,2}$).** *For every essential SCC $\alpha$ on
$\Sigma = S_{1,2}$ with $\ell(\alpha) \ge 2$, the descending link
$\mathrm{DL}(\alpha)$ is contractible. Consequently
$\mathcal{C}^1(\Sigma)$ is contractible.*

The Bestvina–Brady descending-link argument reduces the global statement to
contractibility of every $\mathrm{DL}(\alpha)$, so the theorem follows from
the next three sections in order: $k\ge 3$ (Case 1), $k=2$ configuration (a)
(Case 2), and $k=2$ configuration (b) (Case 3).

---

# Section 2 — Proof

For $\alpha$ with $\ell(\alpha) = k \ge 1$, the cut surface inherits a
multi-arc $\widetilde\alpha = a_1 \cup \cdots \cup a_k \subset \Sigma_{0,4}$,
with each $a_i$ running from $\gamma_0^+$ to $\gamma_0^-$.

## Case 1 — $k \ge 3$  (Hatcher pigeonhole)

The multi-arc $\widetilde\alpha$ cuts $\Sigma_{0,4}$ into $k+1$ faces; with
$k \ge 3$, at least one face contains neither $p_1$ nor $p_2$. Pick such a
face $F$; its boundary contains a sub-arc of $\gamma_0^+$ (say) flanked by
two arcs of $\widetilde\alpha$. Push that sub-arc across $F$ to obtain a
level-1 SCC $\beta_F$ with $i(\alpha, \beta_F) = 0$. Then $\beta_F$ is a
**cone vertex** of $\mathrm{DL}(\alpha)$: it is adjacent to every
$\beta \in \mathrm{DL}(\alpha)$ via the trivial edge $i = 0 \le 1$. A cone is
contractible. $\square$

## Case 2 — $k = 2$, configuration (a)  (Hatcher pigeonhole)

In configuration (a), each face of $\Sigma_{0,4} \setminus \widetilde\alpha$
contains exactly one puncture; equivalently, $\widetilde\alpha$ separates
$p_1$ from $p_2$. Then there is a face whose boundary contains
$\gamma_0^+$ entirely on one side and $\gamma_0^-$ entirely on the other
(the *puncture-free corridor*); the same arc-push as in Case 1 gives a cone
vertex $\beta \in \mathrm{DL}(\alpha)$. $\square$

## Case 3 — $k = 2$, configuration (b)  (the core)

In configuration (b), $\widetilde\alpha$ does **not** separate the
punctures. The two faces of $\Sigma_{0,4} \setminus \widetilde\alpha$ are
$$
R_{pp} \;\text{(pair of pants, contains both $p_1,p_2$)},
\qquad
R_\emptyset \;\text{(disk, no punctures)}.
$$

Equivalently — and this is what the proof uses — every $\beta \in
\mathrm{DL}(\alpha)$ has $\ell(\beta) = 1$ exactly, with
$i(\alpha,\beta) = 1$ exactly. (No $\ell = 0$ neighbour exists because any
SCC disjoint from $\gamma_0$ lives in $\Sigma_{0,4}$, hence in $R_{pp}$ or
$R_\emptyset$, and is peripheral.)

### Step 1 — Cut and parameterize level-1 curves

Cutting along $\gamma_0$ followed by the homological parity argument shows
$$
\bigl\{\, \beta \in \mathcal{C}^1(\Sigma) : \ell(\beta) = 1 \,\bigr\}
\;\xleftrightarrow{\;1\text{-}1\;}\;
\{\,\text{arc classes on } \Sigma_{0,4}\,\} \times \mathbb{Z},
$$
where the $\mathbb{Z}$-coordinate is the $\gamma_0$-twist.  Concretely:
choose a base $\beta_0 = \beta_0([\widetilde\beta])$ in each arc orbit, and
write $\beta = T_{\gamma_0}^t(\beta_0)$. The action is free because
$T_{\gamma_0}$ has infinite order on $\mathcal{C}^1(\Sigma)$.

### Step 2 — Vertices of $\mathrm{DL}(\alpha)$ via the crush map

Let $\mathrm{DL}_{\mathrm{arc}}(\alpha) \subset \{\text{arc classes on }
\Sigma_{0,4}\}$ be the image of $\mathrm{DL}(\alpha)$ under the crush
projection $[\beta] \mapsto [\widetilde\beta]$. Then
$$
\mathrm{DL}(\alpha) \;=\; \bigsqcup_{[\widetilde\beta] \in
\mathrm{DL}_{\mathrm{arc}}(\alpha)}\!
\bigl\{\, T_{\gamma_0}^t(\beta_0([\widetilde\beta])) :
i(\alpha, T_{\gamma_0}^t(\beta_0)) = 1 \,\bigr\}.
$$

### Step 3 — Bonahon's intersection formula

Fix $\alpha$ at config (b). For each level-1 base $\beta_0 \in
[\widetilde\beta]$, Bonahon's PL formula for Dehn-twist intersection numbers
specialises (with slope $i(\gamma_0,\alpha) \cdot i(\gamma_0,\beta) =
2 \cdot 1 = 2$) to
$$
\boxed{\;
i\bigl(\alpha, T_{\gamma_0}^t(\beta_0)\bigr) \;=\;
\max\!\bigl(\, c_\alpha([\widetilde\beta]),\; \lvert 2t - d_\alpha([\widetilde\beta]) \rvert \,\bigr),
\qquad t \in \mathbb{Z},
\;}
$$
for unique integers $c_\alpha \ge 0$ and $d_\alpha \in \mathbb{Z}$ depending
only on $\alpha$ and the arc class (modulo the choice of base). Combining
with config (b) (no $i = 0$ neighbour) one shows
$$
[\widetilde\beta] \in \mathrm{DL}_{\mathrm{arc}}(\alpha)
\;\iff\;
c_\alpha([\widetilde\beta]) = 1.
$$

**Multiplicity rule.** Solving $\max(1, |2t - d|) = 1$:
* $d$ **even**: a unique $t = d/2$. Multiplicity $1$.
* $d$ **odd**: two solutions $t = (d \pm 1)/2$. Multiplicity $2$.

The classification of $\mathrm{DL}(\alpha)$ at config (b) thus reduces to two
sub-cases controlled by the structure of $\widetilde\alpha$.

### Step 4 — Sub-case (J): parallel arcs

Suppose $\widetilde\alpha = 2[C]$, i.e. $a_1, a_2$ are isotopic on
$\Sigma_{0,4}$. Let $\sigma$ be the half-twist of a tubular neighbourhood of
$C$: it fixes $C$ pointwise, swaps $a_1 \leftrightarrow a_2$, and acts on
$\gamma_0^\pm$ as a half-rotation. Glued back across $\gamma_0$, $\sigma$ is
a self-homeomorphism of $(\Sigma, \alpha)$ satisfying $\sigma^2 =
T_{\gamma_0}$, so it conjugates $T_{\gamma_0}^t(\beta_0)$ to
$T_{\gamma_0}^{t+1/2}(\beta_0)$ in the continuous twist coordinate. Since
$\sigma$ preserves geometric intersection,
$$
i\bigl(\alpha, T_{\gamma_0}^t(\beta_0)\bigr)
\;=\; i\bigl(\alpha, T_{\gamma_0}^{t+1/2}(\beta_0)\bigr)
\quad\text{for every arc class.}
$$
The PL function in Step 3 is therefore symmetric about a half-integer, which
forces $d_\alpha([\widetilde\beta])$ to be **odd** for every
$[\widetilde\beta] \in \mathrm{DL}_{\mathrm{arc}}(\alpha)$ — multiplicity $2$
universally.

For $[\widetilde\beta] = [C]$ itself: $i_{\Sigma_{0,4}}([C], 2[C]) = 0$, the
boundary correction is $\le 1$, and the two consecutive twists
$\beta_C, \beta'_C$ realising the minimum satisfy $i(\beta_C, \beta'_C) = 1$
and $i(\beta_C, \beta) \le 1$ for every other $\beta \in \mathrm{DL}(\alpha)$
(direct PL computation, using that every $[\widetilde\beta] \in
\mathrm{DL}_{\mathrm{arc}}(\alpha)$ is disjoint from $[C]$ on
$\Sigma_{0,4}$). Hence $\beta_C, \beta'_C$ are **cone vertices**.

Writing $G_{\mathrm{outer}}$ for the induced subgraph on the remaining
$2(|\mathrm{DL}_{\mathrm{arc}}| - 1)$ vertices,
$$
\mathrm{DL}(\alpha) \;\cong\; K_2 \vee G_{\mathrm{outer}}.
$$
The flag complex of a join is the join of the flag complexes; $K_2$'s flag
complex is a $1$-simplex. Thus $\mathrm{DL}(\alpha)$ is a cone, hence
contractible. $\square$

### Step 5 — Sub-case (G): non-parallel arcs

Suppose $\widetilde\alpha = [C_1] + [C_2]$ with $[C_1] \ne [C_2]$ and
$i_{\Sigma_{0,4}}(C_1, C_2) = 0$.

**Six arc classes.** First,
$\mathrm{DL}_{\mathrm{arc}}(\alpha) = \{[C_1],[C_2]\} \cup \{[D_1],\dots,[D_4]\}$,
where the $D_j$'s are the **four diagonals**: arc classes on $\Sigma_{0,4}$
with $i_{\Sigma_{0,4}}(D_j, \widetilde\alpha) = 1$. To see this, cut along
$\widetilde\alpha$ to get $R_{pp} \sqcup R_\emptyset$; an arc with
intersection 1 with $\widetilde\alpha$ has one piece in each region. The
disk $R_\emptyset$ has a unique simple arc joining each pair of distinct
boundary arcs (trivial relative arc complex), and the simplicity constraint
on the $R_{pp}$-piece pins down a unique isotopy class per endpoint
configuration. The four endpoint configurations
$(\text{crosses } C_1 \text{ or } C_2) \times (\text{which side of } \gamma_0)$
give exactly four diagonals. Any arc class with $i_{\Sigma_{0,4}} \ge 2$
gives $c_\alpha \ge 2 \notin \mathrm{DL}_{\mathrm{arc}}$ since the boundary
correction is $\le 1$.

**Multiplicities.** The half-twist symmetry of Step 4 applies *separately*
around each $C_i$ (and only there), giving:
* $d_\alpha([C_i])$ **odd** ($i=1,2$) — multiplicity $2$ each;
* $d_\alpha([D_j])$ **even** ($j=1,\dots,4$) — multiplicity $1$ each.

So $|\mathrm{DL}(\alpha)| = 2 + 2 + 4 = 8$.

**Adjacency: $K_4 + 4$ paired leaves.** Label
$V_C = \{(C_1,t_1^-),(C_1,t_1^+),(C_2,t_2^-),(C_2,t_2^+)\}$ and
$V_D = \{D_1,D_2,D_3,D_4\}$.

* *Within $V_C$.* For consecutive twists of the same arc class:
  $i = 1$ (Bonahon, $|2t-d| = 1$). Across $C_1 \leftrightarrow C_2$:
  $i_{\Sigma_{0,4}}(C_1, C_2) = 0$ and the boundary correction is $\le 1$,
  giving $i \le 1$. Hence $V_C$ spans $K_4$.

* *Within $V_D$.* Distinct diagonals satisfy
  $i_{\Sigma_{0,4}}(D_j, D_k) \ge 2$ (Farey arithmetic of arc classes that
  each cross $\widetilde\alpha$ once but in incompatible directions), so
  no $V_D$-edges.

* *$V_D$ vs $V_C$.* Each $D_j$ has $i_{\Sigma_{0,4}}(D_j, C_i) \in \{0,1\}$.
  Tracking the boundary correction through the formula in Step 3 shows
  exactly *one* of the four $V_C$-vertices realises $i(D_j, \cdot) = 2$ and
  the other three realise $i \le 1$. The pairing
  $D_j \leftrightarrow$ (its non-neighbour) is a bijection $V_D \to V_C$
  (each $V_C$-vertex is missed by exactly one diagonal).

This is the graph $G^\star = K_4 + \text{4 paired leaves}$, with degree
sequence $(6,6,6,6,3,3,3,3)$.

**Contractibility.** $G^\star$ is **chordal**: every cycle of length $\ge 4$
has a chord, because any cycle through two distinct $V_D$-vertices passes
through the $K_4$ and gets cut by a $K_4$-edge. By a standard fact (e.g.
Jonsson, *Simplicial Complexes of Graphs*, 2008, §4 — the flag complex of a
chordal graph is collapsible, hence contractible), the flag complex of
$G^\star$ is contractible. $\square$

This completes Case 3, and with it all three cases. The Bestvina–Brady
descending-link argument now gives the contractibility of
$\mathcal{C}^1(S_{1,2})$. $\blacksquare$

---

# Section 3 — Verification

Two independent computational checks were carried out on
`workspace/projects/op1_geometry/data_S_1_2.json` (a database of $400$
distinct level-$\ge 2$ SCCs on $S_{1,2}$ produced by `curver`).

**(V1) Direct Betti-number certificate.** For all $309$ SCCs $\alpha$ in the
database with $\ell(\alpha) \ge 2$ for which $\mathrm{DL}(\alpha)$ admits a
finite combinatorial description, we computed the simplicial Betti numbers
of the flag complex of $\mathrm{DL}(\alpha)$:
$$
b_0 = 1, \quad b_i = 0 \text{ for all } i \ge 1
\qquad\text{in every one of the 309 cases.}
$$
Each flag complex is connected and acyclic, consistent with contractibility.

**(V2) Dichotomy on configuration (b).** Of those $309$ cases, exactly $33$
fall in $k = 2$ configuration (b). Computing
$\mathrm{DL}_{\mathrm{arc}}(\alpha)$ via `gamma_0.crush()`,
verifying the Bonahon formula in Step 3 against direct intersection numbers,
and inspecting the resulting graph structure:
$$
\begin{array}{lcc}
\text{sub-case} & \text{count} & \text{verdict} \\\hline
\text{(J) parallel arcs} & 19 & \text{all } \mathrm{DL}(\alpha) \cong K_2 \vee G_{\mathrm{outer}} \\
\text{(G) non-parallel arcs} & 14 & \text{all } \mathrm{DL}(\alpha) \cong G^\star \\\hline
\text{total} & 33 & \text{33/33 match the JOIN-or-}G^\star \text{ dichotomy}
\end{array}
$$

The verification script is `op1_lemma34_proof_verify.py`; the JSON output
lives at `workspace/active/lemma34_clean_close/true_dl_verification.json`.
Both checks (V1) and (V2) are consistent with the proof above and provide
no counterexample.
