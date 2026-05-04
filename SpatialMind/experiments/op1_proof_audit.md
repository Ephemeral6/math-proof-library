---
title: "Strict referee audit of op1_proof_clean.md"
date: "2026-05-03"
auditor: "Independent reviewer (skeptical mode)"
verdict: "GAPS FOUND — proof is not complete as written"
---

# Bottom line

The proof has **one critical logical gap** (the main theorem's reduction to $\mathrm{DL}(\alpha)$ for $\ell(\alpha)\ge 2$ does not by itself imply contractibility of $\mathcal C^1(\Sigma)$), **two significant content gaps** in Case 3 (parity of $d$ for diagonals; Farey-arithmetic disjointness claim), and several **expository / definitional inaccuracies** (face count formula in Case 1; informality of the half-twist definition; "cone vertex of $\mathrm{DL}(\alpha)$" boundary-correction estimate). The Bonahon formula, the multiplicity rule, the J/G dichotomy on the 33 verified cases, and the chordality of $G^\star$ all check out empirically against `curver`. The proof is *probably true* and most gaps are repairable, but the document as it stands cannot be accepted as a complete proof.

---

# 1. Theorem statement and `DL` definition (Section 1)

## 1.1 Definition of $\mathrm{DL}(\alpha)$ — **OK with one ambiguity**

§1.2 defines
$$\mathrm{DL}(\alpha) = \{\beta\in\mathcal C^1(\Sigma): i(\alpha,\beta)\le 1 \text{ and } \ell(\beta)<k\}$$
"viewed as a full subcomplex". This is standard and unambiguous on the **vertex** side. "Viewed as a full subcomplex" implicitly means *flag-complex* (edges given by $i\le 1$ on pairs, higher simplices by being a clique). This is consistent with §1.2's earlier "$\mathcal C^1(\Sigma)$ with its flag-complex topology". Good.

"Contractible" therefore refers to the flag complex's geometric realisation — **not** the contractibility of the 1-skeleton as a graph (a graph is contractible iff it is a tree, which $\mathrm{DL}$ rarely is). The proof's conclusion in Step 4 ("$K_2 \vee G_{\mathrm{outer}}$ is a cone, hence contractible") and Step 5 ("flag complex of a chordal graph is contractible") use this convention, so it is consistent throughout.

## 1.2 The condition $\ell(\alpha)\ge 2$ — **CRITICAL GAP**

The Theorem (§1.3) only proves contractibility of $\mathrm{DL}(\alpha)$ for $\ell(\alpha)\ge 2$, then asserts: *"Consequently $\mathcal C^1(\Sigma)$ is contractible."*

This conclusion **does not follow from the stated hypothesis**. The Bestvina–Brady descending-link Morse argument applied to the level filtration $\ell:\mathcal C^1(\Sigma)\to \mathbb Z_{\ge 0}$ gives:
> If $\mathrm{DL}(\alpha)$ is contractible for every $\alpha$ with $\ell(\alpha) \ge L_0$, then $\mathcal C^1(\Sigma)$ deformation-retracts onto its sub-complex on $\{\ell\le L_0-1\}$.

So with $L_0 = 2$, the proof shows $\mathcal C^1(\Sigma)$ retracts onto its **$\ell\le 1$ subcomplex**, NOT that it is contractible.

For the conclusion "$\mathcal C^1(\Sigma)$ is contractible" we additionally need EITHER:

- **(A)** $\mathrm{DL}(\alpha)$ contractible for every $\alpha$ with $\ell(\alpha)=1$ as well (then $\mathcal C^1(\Sigma)$ retracts onto the $\ell=0$ subcomplex, and we still need that subcomplex contractible — but the $\ell=0$ subcomplex is the curve complex of $\Sigma_{0,4}$, which is the Farey graph, **NOT contractible** — it is a tree of triangles, homotopy equivalent to a wedge of circles); OR
- **(B)** A direct argument that the $\{\ell\le 1\}$ subcomplex is contractible.

Neither is given. **This is a fatal gap unless one of the missing pieces is supplied.**

A standard fix: prove that the natural inclusion $\mathcal C^1(\Sigma_{0,4}) \hookrightarrow$ ($\ell=0$ subcomplex of $\mathcal C^1(\Sigma)$) extended by adjoining level-1 vertices kills the loops in the Farey graph — this is what Hatcher's original argument for $\mathcal C^1(S_{1,1})$ etc. relies on, but it requires its own pigeonhole step at $\ell=1$. The proof must address $\ell(\alpha)=1$ explicitly or cite a result that does.

**Severity:** logical / load-bearing.
**Repair:** add Case 0 ($\ell=1$) — for $\alpha$ with $\ell(\alpha)=1$, $\mathrm{DL}(\alpha)\subset\mathcal C^1(\Sigma_{0,4})$ is the link of $\widetilde\alpha$ in the arc complex of $\Sigma_{0,4}$ glued with twist parameters; one can show this is contractible by a direct Hatcher-style argument inside $\Sigma_{0,4}$.

---

# 2. Case 1, $k\ge 3$ (Hatcher pigeonhole)

## 2.1 The "$k+1$ faces" claim — **EXPOSITORY ERROR**

> "The multi-arc $\widetilde\alpha$ cuts $\Sigma_{0,4}$ into $k+1$ faces."

**This formula is wrong in general.** The number of components of $\Sigma_{0,4}\setminus\widetilde\alpha$ depends on the multi-arc's topological type, not only on $k$.

Euler-characteristic check: $\chi(\Sigma_{0,4})=-2$; cutting along an arc with both endpoints on boundary increases $\chi$ by $1$; so the cut surface has $\chi = -2+k$. Concrete counterexamples:

| $k$ | configuration | components | total $\chi$ | "k+1" predicts |
|---|---|---:|---:|---:|
| 2 | config (b) | 2 (pants + disk) | $-1+1=0$ | 3 ✗ |
| 2 | config (a) | 2 (each an annulus around a puncture) | $0+0=0$ | 3 ✗ |
| 3 | both punctures together | 3 (pants + 2 disks) | $-1+1+1=1$ | 4 ✗ |
| 3 | punctures separated | 3 (2 annuli + 1 disk) | $0+0+1=1$ | 4 ✗ |
| 3 | three parallel arcs | 3 (2 thin disks + outer pants) | $1+1+(-1)=1$ | 4 ✗ |

In each row the count is off by one. A correct statement is: *for $k\ge 3$ the multi-arc $\widetilde\alpha$ cuts $\Sigma_{0,4}$ into at least $3$ components, not all of which can host the $2$ punctures*; the pigeonhole conclusion follows from a $\chi$-counting argument, not from "$k+1$".

**Severity:** the conclusion holds (puncture-free face exists for $k\ge 3$), but the stated proof rationale is incorrect.
**Repair:** replace "$k+1$ faces" with the $\chi$ argument:
- if both punctures live in the same component, that component has $\chi\le -1$, so the remaining components have $\chi\ge -2+k+1 \ge 2$ for $k\ge 3$, hence $\ge 2$ disk components, all puncture-free;
- if the punctures live in two different components, each puncture-component has $\chi\le 0$, so the remaining components have $\chi\ge k-2\ge 1$ for $k\ge 3$, hence $\ge 1$ disk component, puncture-free.

## 2.2 "Push that sub-arc across $F$ to obtain a level-1 SCC $\beta_F$" — **NEEDS JUSTIFICATION**

The proof asserts the surgery yields a level-1 curve. The standard Hatcher surgery that pushes a sub-arc of $\gamma_0^+$ across a quadrilateral face $F$ produces a curve isotopic to $\gamma_0$ outside $F$ and rerouted inside $F$. The resulting curve's level (intersection with $\gamma_0$) depends on how it sits relative to $\gamma_0$ in the surgery region, and is **not automatically $1$**.

In particular, the curve obtained by replacing the $\gamma_0^+$-sub-arc with a path through $F$ ending on $\gamma_0^-$ is a single SCC on $\Sigma$ **only after** identifying $\gamma_0^+$ with $\gamma_0^-$ via the gluing — and the "rerouted" portion now crosses $\gamma_0$ where the new path meets $\gamma_0^-$ on the other side. Working this out, the level of $\beta_F$ is $1$ for a generic puncture-free quadrilateral face, but the proof does not explain why.

**Severity:** the claim is plausibly correct, but the proof is missing a sentence.
**Repair:** make the surgery explicit: "$\beta_F$ is the SCC obtained from $\gamma_0$ by replacing the sub-arc $\gamma_0^+\cap F$ with the unique sub-arc of $\partial F$ on the other side; since $F$ is a quadrilateral with two opposite sides on $\widetilde\alpha$, the new curve crosses $\gamma_0$ exactly once (at the unique re-attachment point), so $\ell(\beta_F)=1$."

## 2.3 `curver` verification — **PASSED on small samples**

I sampled $k=3$ and verified the $\widetilde\alpha$-component count via `crush(alpha).components()` for $\alpha\in\{12,33,37,39,41\}$. All have $3$ distinct arcs (or $1$ class with multiplicity $3$ for $\alpha=41$), consistent with #components $=3$ rather than $k+1=4$.

---

# 3. Case 2, $k=2$ config (a)

## 3.1 Definition of config (a) — **OK, but stated only by example**

§2 (Case 2) says: *"each face of $\Sigma_{0,4}\setminus\widetilde\alpha$ contains exactly one puncture; equivalently, $\widetilde\alpha$ separates $p_1$ from $p_2$."* This is a clean operational definition. The equivalence is correct (a 2-arc multi-arc on $\Sigma_{0,4}$ between the same boundary pair $\gamma_0^+,\gamma_0^-$ separates the surface into two pieces; config (a) is the case where one puncture lands in each piece).

## 3.2 "Puncture-free corridor" — **MINOR GAP**

Case 2's argument: *"there is a face whose boundary contains $\gamma_0^+$ entirely on one side and $\gamma_0^-$ entirely on the other."* This is actually false as stated: in config (a) each face is an annulus around a puncture, and $\gamma_0^+$ is split between the two faces (each face's boundary contains a sub-arc of $\gamma_0^+$, not the whole circle).

What the proof presumably means: each face is an annulus whose two boundary components are (i) the puncture circle $p_i$, and (ii) a circle made from one arc of $\widetilde\alpha$ on each side, glued by sub-arcs of $\gamma_0^+$ and $\gamma_0^-$. Inside such an annulus, the two sub-arcs $\gamma_0^+\cap F$ and $\gamma_0^-\cap F$ are connected by the two arc-sides — so the surgery still produces a level-1 cone vertex (the SCC obtained by sliding $\gamma_0^+\cap F$ across $F$ around $p_i$).

**Severity:** terminology, not logic. The argument works, but "puncture-free corridor" is a misnomer here — the corridor *contains* a puncture. The cone vertex is the curve isotopic to a small loop around $p_i$ (in $\Sigma_{0,4}$) twist-shifted into $\Sigma$.

**Repair:** rewrite as: "in config (a), each face contains exactly one puncture. Pick either face $F_i$ around $p_i$; its boundary contains a sub-arc of $\gamma_0^+$ and a sub-arc of $\gamma_0^-$ joined by the two arcs of $\widetilde\alpha$; surgery against $F_i$ yields a level-1 SCC $\beta_i$ disjoint from $\alpha$, hence a cone vertex of $\mathrm{DL}(\alpha)$."

---

# 4. Case 3, Step 3 — Bonahon's formula

## 4.1 Source and statement — **SLIGHT MISCITATION**

The proof writes
$$i(\alpha, T_{\gamma_0}^t(\beta_0)) = \max(c_\alpha,\,|2t - d_\alpha|), \qquad t\in\mathbb Z$$
and credits "Bonahon's PL formula for Dehn-twist intersection numbers".

**Caveat:** Bonahon's 1986 paper *"Bouts des variétés hyperboliques de dimension 3"* proves the asymptotic homogeneity of intersection numbers and the PL structure, but does **not** state the closed-form $\max(c,|2t-d|)$ formula directly. The standard reference for the $\max$-form is Luo or Penner–Harer, *Combinatorics of Train Tracks*, Lemma 1.1.4 (Penner–Harer prove a more general PL identity which specialises to this $\max$-form when the two slopes are equal in absolute value).

In our case, $i(\gamma_0,\alpha)\cdot i(\gamma_0,\beta) = 2\cdot 1 = 2$ but the asymptotic slopes are $\pm 2$ on each side of the minimum, so the formula's specific shape requires that both *subadditive corrections* in Penner–Harer line up to give a single $\max$. This works in Case 3 because $\beta$ has $\ell(\beta)=1$, so $\beta$ has only ONE arc on $\Sigma_{0,4}$ — no internal complexity. But the proof gives no derivation of the $\max(c,|2t-d|)$ form from the cited reference.

**Severity:** medium — the formula is correct in this specialisation but is presented as if it were a direct quote.
**Repair:** explicitly cite Penner–Harer Lemma 1.1.4 (or even derive the formula from first principles using the train-track coordinates of $\beta$ on $\Sigma_{0,4}$) and verify the slope-2 case.

## 4.2 Definitions of $c$ and $d$ — **IMPLICIT**

The proof says *"unique integers $c_\alpha\ge 0$ and $d_\alpha\in\mathbb Z$"* but never defines them concretely. From the formula:
- $c_\alpha([\widetilde\beta])$ is the minimum value of $t\mapsto i(\alpha, T_{\gamma_0}^t(\beta_0))$ — it equals the geometric intersection on $\Sigma_{0,4}$ of $\widetilde\alpha$ with $\widetilde\beta$ minus a boundary correction (Penner–Harer).
- $d_\alpha([\widetilde\beta])$ encodes "where the minimum is": $d/2$ is the optimal real twist.

A reader has to infer this. A clean definition, e.g., via the Bonahon shear coordinates of the geodesic representatives, would close the loop.

## 4.3 `curver` verification — **PASSED**

Direct computation in `curver` confirms the formula on multiple examples:

**Example 1 (Case J: $\alpha=13$, $\beta=1$):**
$t = -7..7\;\mapsto\; (13,11,9,7,5,3,1,1,3,5,7,9,11,13,15)$.
This fits $\max(1, |2t+1|)$ exactly: $c=1$, $d=-1$ (odd), giving multiplicity $2$ at $t=-1, 0$. ✓

**Example 2 (Case G: $\alpha=25$):**
Five level-1 $\beta$ from the DB give:
- $\beta=1$: $\max(1,|2t+1|)$, $d=-1$ odd, mult $2$ (an $\alpha$-arc class).
- $\beta=4$: $\max(1,|2t-1|)$, $d=+1$ odd, mult $2$ (same arc class, base shifted).
- $\beta=5$: $\max(1,|2t+3|)$, $d=-3$ odd, mult $2$ (same arc class, larger twist).
- $\beta=6$: $\max(1,|2t+2|)$, $d=-2$ **even**, mult $1$ (a **diagonal** $D_j$).
- $\beta=8$: $\max(1,|2t-1|)$, $d=+1$ odd, mult $2$ (the second $\alpha$-arc class).

So in Case G ($\alpha=25$) we observe 2 odd-$d$ classes ($\alpha$'s arcs) and at least 1 even-$d$ class (a diagonal), exactly as the proof predicts.

The Bonahon formula and the multiplicity rule are **empirically verified**.

---

# 5. Case 3, Step 4 — Case J (parallel arcs)

## 5.1 Half-twist symmetry — **INFORMAL but defensible**

The argument: $\sigma$ is the half-twist around $C$ in $N(C)\subset\Sigma_{0,4}$, satisfying $\sigma^2=T_{\gamma_0}$ once glued back across $\gamma_0$.

**Issues with the formal statement:**

1. **$\sigma^2 = T_{\gamma_0}$ on $\Sigma$.** A half-twist around an arc $C\subset\Sigma_{0,4}$ acts on $\partial N(C)$ as a half-rotation; the boundary of $N(C)$ shares two arcs with $\gamma_0^\pm$ (where the endpoints of $C$ sit). When glued back, this half-rotation becomes a half-Dehn-twist around $\gamma_0$, and its square is the full Dehn twist. The argument is **correct** but requires identifying the regular neighbourhood very carefully — in particular $\sigma$ is NOT a self-homeomorphism of $\Sigma$ unless $\widetilde\alpha=2[C]$ exactly (the parallelism is essential for $\sigma$ to extend; $\sigma$ swaps $a_1\leftrightarrow a_2$, which only makes sense if $a_1$ and $a_2$ are isotopic).

2. **"Conjugates $T_{\gamma_0}^t(\beta_0)$ to $T_{\gamma_0}^{t+1/2}(\beta_0)$ in the continuous twist coordinate".** The "continuous twist coordinate" is informal — $T_{\gamma_0}^{1/2}$ is not an MCG element of $\Sigma$. What the proof really needs is the **functional symmetry**:
$$f(t):=i(\alpha,T_{\gamma_0}^t(\beta_0)) \quad\text{satisfies}\quad f(t)=f(t+1)\text{-shifted-by-}\frac12\text{ via }\sigma,$$
which forces the integer-valued PL function $f$ to be symmetric about a half-integer, hence $d$ odd. Once stated functionally this is rigorous; as stated it is informal.

**Severity:** medium-low. The conclusion ($d$ odd) is provable; the proof writes it loosely.
**Repair:** state the symmetry purely as a functional equation $f(t) = f(d-t-1)$ (for some appropriate $d$) rather than via "continuous twist".

## 5.2 Multiplicity 2 from $d$ odd — **OK**

Solving $\max(1,|2t-d|)\le 1$ for $d$ odd gives $|2t-d|\le 1\iff t\in\{(d-1)/2, (d+1)/2\}$, two solutions. $d$ even gives $t=d/2$ uniquely. Routine. ✓

## 5.3 Cone vertex argument — **INCOMPLETE**

The proof claims the two twins $\beta_C, \beta_C'$ (twists of an arc representing $[C]=$ $\alpha$'s arc class) are cone vertices, i.e., adjacent to all other $\beta\in\mathrm{DL}(\alpha)$. The justification:
> "$i_{\Sigma_{0,4}}([C], 2[C])=0$, the boundary correction is $\le 1$, and the two consecutive twists $\beta_C, \beta_C'$ realising the minimum satisfy $i(\beta_C, \beta_C')=1$ and $i(\beta_C, \beta)\le 1$ for every other $\beta\in\mathrm{DL}(\alpha)$ (direct PL computation, using that every $[\widetilde\beta]\in\mathrm{DL}_{\mathrm{arc}}(\alpha)$ is disjoint from $[C]$ on $\Sigma_{0,4}$)."

**Issues:**
- The boundary-correction estimate "$\le 1$" is asserted, not derived. In Penner–Harer's framework, the boundary correction at the optimum twist is bounded by the *boundary intersection number*, which for two level-1 curves whose arcs are disjoint on $\Sigma_{0,4}$ is in $\{0,1\}$. This is true but not obvious — a one-sentence justification is missing.
- **Lemma 5.3 (every $[\widetilde\beta]\in\mathrm{DL}_{\mathrm{arc}}$ is disjoint from $[C]$ on $\Sigma_{0,4}$)** is implicitly used and only proved in `op1_lemma34_proof.md` (Lemma 5.3) by the calculation $i_{\Sigma_{0,4}}(\widetilde\beta,2[C])\ge 2 \implies c_\alpha\ge 2 \implies [\widetilde\beta]\notin\mathrm{DL}_{\mathrm{arc}}$. Same boundary-correction $\le 1$ caveat applies. The clean writeup should make this lemma explicit.

**Severity:** medium. The statement is correct; the writeup compresses the argument too much.
**Repair:** insert Lemma 5.3 from `op1_lemma34_proof.md` and a one-sentence boundary-correction lemma.

## 5.4 `curver` verification — **PASSED**

For Case J examples in the JSON output (`alpha ∈ {13, 40, 42, 113, 121, ...}`), the TRUE descending link consistently has the structure $K_2 \vee G_{\mathrm{outer}}$ with degree sequence $(13,13,4^{10},3^2)$ for $|\mathrm{DL}|=14$, two cone vertices of degree $13$. **19/19 J-cases match.**

For multiplicity: $\alpha=13$ with $\beta=1$ has min plateau width $2$ at $t\in\{-1,0\}$ ($d=-1$ odd), confirming multiplicity $2$. ✓

---

# 6. Case 3, Step 5 — Case G (non-parallel arcs)

## 6.1 "Exactly 6 arc classes in $\mathrm{DL}_{\mathrm{arc}}$" — **MOSTLY OK, one weak step**

The argument:
1. $i_{\Sigma_{0,4}}(\widetilde\beta,\widetilde\alpha)\ge 2 \implies c_\alpha\ge 2 \implies \notin\mathrm{DL}_{\mathrm{arc}}$. (Same boundary-correction $\le 1$ caveat as 5.3 above.)
2. $i_{\Sigma_{0,4}}(\widetilde\beta,\widetilde\alpha)=0 \implies [\widetilde\beta]\in\{[C_1],[C_2]\}$. (Disjoint multi-arcs in $\Sigma_{0,4}$ from $\gamma_0^+$ to $\gamma_0^-$ disjoint from $\widetilde\alpha=C_1\cup C_2$ live in $R_{pp}$ or $R_\emptyset$. $R_\emptyset$ is a disk and contains no essential arc from $\gamma_0^+\cap R_\emptyset$ to $\gamma_0^-\cap R_\emptyset$ different from the arcs of $\widetilde\alpha$ — wait, actually this needs more care: $R_\emptyset$ is bounded by $C_1, \gamma_+^\emptyset, C_2, \gamma_-^\emptyset$, so the unique arc from $\gamma_+^\emptyset$ to $\gamma_-^\emptyset$ in $R_\emptyset$ is isotopic to $C_1$ and to $C_2$ — but those are $\alpha$'s arcs, so this gives $[C_1]=[C_2]$? No, $C_1\not\sim C_2$ in $\Sigma_{0,4}$. The proof's claim seems to require that the only arcs from $\gamma_0^+$ to $\gamma_0^-$ disjoint from $\widetilde\alpha$ are $[C_1]$ and $[C_2]$ themselves — this is **non-obvious and not really argued**.)
3. $i_{\Sigma_{0,4}}(\widetilde\beta,\widetilde\alpha)=1$ gives the 4 diagonals via endpoint-configuration counting.

For step (3): the endpoint configurations are
$$(\text{crosses }C_i)\times(\text{which sub-arc of }\gamma_0^+, \text{which sub-arc of }\gamma_0^-),$$
plus simplicity. The proof says "simplicity pins down a unique class per endpoint configuration", citing that the $R_\emptyset$ piece is unique-up-to-isotopy (true: $R_\emptyset$ is a disk) and the $R_{pp}$ piece is unique because of the pants. The pants claim requires: in a pair of pants, simple arcs joining one boundary segment on the outer boundary to another boundary segment (on the same outer boundary, separated by puncture circles) come in finitely many classes per endpoint specification. This is correct (the arc complex of a pair of pants is finite once endpoints are specified), but the proof glosses it.

Empirical: for $\alpha=25$, an "independent verification" claim says exactly 6 arc classes among 88 searched satisfy $i_{\Sigma_{0,4}}\le 1$. **Empirically verified.**

**Severity:** medium. Steps (2) and (3) need 1–2 more sentences each.
**Repair:** state explicitly "the only arc classes in $R_\emptyset$ (a disk) connecting $\gamma_+^\emptyset$ to $\gamma_-^\emptyset$ are isotopic to $C_1$ or to $C_2$ (the two boundary arcs of $R_\emptyset$ on the $\widetilde\alpha$-side)" and "the arc complex of a pair of pants between two specified boundary segments is a single point".

## 6.2 Multiplicity pattern (Lemma 5.5 from op1_lemma34_proof.md): "$d$ odd for $C_i$, even for $D_j$" — **SIGNIFICANT GAP**

The argument as written:
> "The half-twist symmetry of Step 4 applies *separately* around each $C_i$ (and only there)" → $d_\alpha([C_i])$ odd.
> "For each diagonal $D_j$: $D_j$ is disjoint from both $C_1$ and $C_2$ but is NOT $\alpha$'s arc class. The half-twist symmetry argument doesn't apply, so $d_\alpha([D_j])$ can be either parity. The geometric structure (specifically, the orientation of $D_j$ relative to $C_1, C_2$) forces $d$ to be even."

**The "even for $D_j$" claim is the punchline of Case G** — it controls multiplicity, hence $|\mathrm{DL}|=8$, hence the dichotomy. But the proof's justification is a single hand-wave: *"the orientation of $D_j$ relative to $C_1, C_2$ forces $d$ to be even"*, with no actual argument. The fuller version in `op1_lemma34_proof.md` §6.5 says only:

> "The 'even' outcome for diagonals is forced by a complementary argument: the full integer-twist symmetry $T_{\gamma_0}$ acts trivially on the arc class but shifts $t \to t + 1$. Hence the function $f$ is invariant under $t \to t + 1$ ONLY in the trivial sense (it's not a constant function). The minimum is at an integer $t^*$, giving $d = 2t^*$ even."

This is **circular reasoning**: "$d$ is even because the optimum twist is at an integer, because $d$ is even". The full Dehn twist $T_{\gamma_0}$ shifting $t\to t+1$ is a tautology and gives no information about the parity of $d$.

**The actual reason** $d_\alpha(D_j)$ is even must come from: (a) absence of the half-twist symmetry around $D_j$ (correct, but only shows $d$ *can* be even — does not force it), and (b) some POSITIVE argument that a $D_j$-twist family achieves its minimum at an integer twist. Such a positive argument requires looking at how the lift of $D_j$ to $\Sigma$ sits relative to $\alpha$, something the proof never does.

**Severity:** the whole Case G dichotomy hangs on this. As written, the proof has no real argument for "$d$ even on diagonals" — only an empirical claim and a circular sketch.

**Repair:** Either supply a direct geometric proof (e.g., $D_j$'s endpoints on $\gamma_0$ are configured so that the optimal twist for minimising $i(\alpha, T_{\gamma_0}^t(\beta_0))$ falls on an integer, perhaps via an explicit train-track or shear-coordinate calculation), or argue *non-existence* of a half-integer symmetry for $D_j$ in a way that combined with PL-convexity rules out half-integer minima. Empirically the claim holds (4 diagonals × 14 G-cases = 56 instances, all $d$ even per `op1_lemma34_proof_verify.py`), but the topological proof is missing.

## 6.3 "$i_{\Sigma_{0,4}}(D_j, D_k)\ge 2$ by Farey arithmetic" — **GAP**

> "Distinct diagonals satisfy $i_{\Sigma_{0,4}}(D_j,D_k)\ge 2$ (Farey arithmetic of arc classes that each cross $\widetilde\alpha$ once but in incompatible directions), so no $V_D$-edges."

"Farey arithmetic" is a hand-wave. The actual claim is: in the Farey-graph-like arc complex of $\Sigma_{0,4}$, two distinct diagonals (each $i_{\Sigma_{0,4}}=1$ with $\widetilde\alpha$) are at distance $\ge 2$. This needs a real argument — possibly via the Farey graph structure of arcs on $\Sigma_{0,3}$ (the pants $R_{pp}$) or by direct computation.

**Severity:** medium. Plausibly correct (and would follow from a careful enumeration in $R_{pp}$), but unproven.

**Repair:** compute $i_{\Sigma_{0,4}}(D_j, D_k)$ explicitly using the bigon criterion in the cut surface $R_{pp}$ — two simple arcs in a pants between the same boundary-segment configuration are isotopic; for *different* configurations they cross $\ge 2$ times because of how they wind around the punctures.

## 6.4 "$D_j$ vs $V_C$: exactly one $V_C$ vertex has $i=2$" — **GAP**

> "Tracking the boundary correction through the formula in Step 3 shows exactly *one* of the four $V_C$-vertices realises $i(D_j,\cdot)=2$ and the other three realise $i\le 1$."

This is asserted, not derived. "Tracking the boundary correction" is unspecified. The pairing structure (each $D_j$ misses one $V_C$ vertex; each $V_C$ vertex missed by one $D_j$) is then claimed via "(each $V_C$-vertex is missed by exactly one diagonal)" — which is consistent but again only asserted.

**Severity:** load-bearing for the $G^\star$ structure. Empirically verified (deg seq $(6,6,6,6,3,3,3,3)$ on all 14 G-cases), but not proven.

**Repair:** for each $D_j$, compute $d_\alpha(D_j)$ explicitly modulo $4$ (since the Dehn twist acts with period $2$ on the parity, and there are 2 candidate $V_C$-classes each with 2 twins, giving 4 possible alignments). Show the alignment realised is exactly the one yielding $i=2$ on one $V_C$-vertex.

## 6.5 $G^\star$ chordality — **OK, with verifiable proof**

The proof argues:
> "$G^\star$ is chordal: every cycle of length $\ge 4$ has a chord, because any cycle through two distinct $V_D$-vertices passes through the $K_4$ and gets cut by a $K_4$-edge."

I checked computationally (built the graph, enumerated all 4-cycles): **all 23 vertex-set-distinct 4-cycles in $G^\star$ have at least one chord.** And longer cycles (length $\ge 5$) must alternate $V_D, V_C, V_D, V_C, \ldots$ (since $V_D$ is independent), so any cycle of length $\ge 4$ contains two $V_C$-vertices, which are joined by a $K_4$-edge — a chord. The proof's argument is correct.

## 6.6 Reference for "flag complex of chordal graph is contractible"

The clean writeup correctly cites *Jonsson, "Simplicial Complexes of Graphs", 2008, §4*, which is the standard collapsibility proof. The earlier draft `op1_lemma34_proof.md` references this as "BFJ 2008" which is a misnomer (BFJ usually = Bestvina–Fujiwara). The clean writeup's citation is correct.

---

# 7. Overall logic

## 7.1 Case exhaustion

For $k\ge 2$:
- **Case 1 ($k\ge 3$):** OK (modulo §2.1, §2.2 fixes).
- **Case 2 ($k=2$, config (a)):** OK (modulo §3.2 fix).
- **Case 3 ($k=2$, config (b)):** OK in structure, multiple gaps in the details.

Configurations (a) and (b) for $k=2$ exhaust all possibilities (a 2-arc multi-arc on $\Sigma_{0,4}$ between $\gamma_0^+$ and $\gamma_0^-$ either separates the punctures or doesn't). ✓

For $k=2$ configuration (b), Case (J) and Case (G) exhaust all possibilities for $\widetilde\alpha=a_1\cup a_2$ with $i_{\Sigma_{0,4}}(a_1,a_2)=0$: either $[a_1]=[a_2]$ (J) or $[a_1]\ne[a_2]$ (G). ✓

## 7.2 The missing $k=1$ case

As noted in §1.2, the proof does not handle $\ell(\alpha)=1$. **This is the only logical hole that breaks the conclusion** ("$\mathcal C^1(\Sigma)$ contractible") rather than just weakening the proof of the auxiliary statements.

## 7.3 Circularity check

No circular reasoning at the level of the case structure — Case 3 doesn't reuse Case 1/2 conclusions. Within Case 3 §6.2, however, the parity argument is internally circular (see §6.2 above).

---

# 8. Empirical validation against `curver`

| Check | Sample | Result |
|---|---|---|
| $k=2$ alphas in DB | all 64 with $\ell=2$ | 64 found |
| Strict config (b) (script's DB-based check) | all 64 | 33 with non-empty DL_DB & all $i=1$; 31 with empty DL_DB (script skips) |
| Bonahon $\max(c,|2t-d|)$ formula | $\alpha\in\{13,25\}$, $\beta\in\{1,4,5,6,8\}$ | All match exactly |
| Multiplicity rule ($d$ odd → mult 2, $d$ even → mult 1) | same | All match |
| Case J ($\alpha=13$) is parallel-arc case | crush components: 1 with mult 2 | ✓ |
| Case G ($\alpha=25$) is non-parallel case | crush components: 2, mult 1 each | ✓ |
| JOIN structure on Case J | 19 J-cases | 19/19 |
| $G^\star$ structure on Case G | 14 G-cases | 14/14 |
| $G^\star$ chordality | enumerate 4-cycles in $G^\star$ | 23/23 have a chord |

**Discrepancy resolved:** the `true_dl_verification.json` file contains 64 entries (33 ok=true, 31 ok=false), while the proof claims 33. Re-running `op1_lemma34_proof_verify.py` today produces "Found 33 config (b) α", matching the proof. The 31 "ok=false" entries in the saved JSON are stale artifacts from an earlier script run that **did not skip $\alpha$ with empty DL_DB** (those 31 alphas have *no* DB neighbour with $i\le 1$ and were vacuously classified as config (b); when the BFS-extended TRUE descending link is built they don't fit the dichotomy because they likely sit in config (a) or are otherwise pathological with respect to the DB sample).

The proof's empirical claim "33/33 ✓" is therefore **technically correct** but rests on a fragile DB-based detector for "config (b)". A safer detector would compute the puncture-separation property of $\widetilde\alpha$ directly from the cut surface, not by enumerating DB neighbours.

---

# 9. Summary of gaps

| # | Location | Severity | Type | Repairable? |
|---|---|---|---|---|
| G1 | §1.3 main thm conclusion | **CRITICAL** | logical (missing $\ell=1$ case) | yes — add Case 0 for $\ell=1$ |
| G2 | §2 Case 1, "$k+1$ faces" | minor expository | wrong formula | yes — replace with χ-counting |
| G3 | §2 Case 1, "$\beta_F$ is level-1" | minor | unjustified surgery output | yes — add 1 sentence |
| G4 | §3 Case 2, "puncture-free corridor" | minor terminology | misnomer | yes — rephrase |
| G5 | §4.1 Bonahon citation | medium | misattribution / no derivation | yes — cite Penner–Harer |
| G6 | §4.2 $c, d$ definitions | minor | implicit | yes — define explicitly |
| G7 | §5.1 half-twist $\sigma^2=T_{\gamma_0}$ | medium-low | informal | yes — restate as functional symmetry |
| G8 | §5.3 cone-vertex boundary-correction | medium | "$\le 1$" asserted not derived | yes — add lemma |
| G9 | §6.1 6 arc classes — disjoint case | medium | "$\widetilde\beta$ disjoint from $\widetilde\alpha$ in $R_\emptyset$ ⇒ $[\widetilde\beta]\in\{[C_1],[C_2]\}$" not argued | yes — add disk argument |
| G10 | §6.2 "$d$ even for diagonals" | **SIGNIFICANT** | circular reasoning, no actual proof | needs new argument — possibly hard |
| G11 | §6.3 "$i_{\Sigma_{0,4}}(D_j,D_k)\ge 2$ by Farey" | medium | hand-wave | yes — direct computation in $R_{pp}$ |
| G12 | §6.4 "$D_j$ vs $V_C$: exactly one $i=2$" | medium | asserted, not derived | yes — explicit pairing computation |

**Two gaps prevent the proof from being accepted as-is:**
- **G1** breaks the global conclusion.
- **G10** is the linchpin of Case G's dichotomy and is essentially unproven.

The remaining gaps are repairable with modest effort and the empirical evidence (33/33 dichotomy, formula and chordality verified) strongly suggests the result is true. A revised draft addressing G1 and G10 with rigorous (not just empirical) arguments would close the proof.

# 10. Final verdict

**PROOF NOT VERIFIED — gaps found.**

Critical gap: the "$\ell\ge 2$ ⇒ $\mathcal C^1(\Sigma)$ contractible" inference (G1).
Significant gap: "$d_\alpha(D_j)$ even" in Case G (G10).
Plus 10 smaller gaps that are repairable but should be filled before publication.

The empirical (`curver`) checks all pass on the cases sampled, and the dichotomy holds on all 33 strict config (b) cases in the DB — so the *theorem* is almost certainly true; the *proof as written* needs work.
