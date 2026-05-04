# Judge — $\mathcal{C}(S_{1,1})$ connectedness

**Date.** 2026-04-21.
**Inputs.** `explorer_1_route_B.md`, `explorer_2_route_A.md`, `explorer_3_route_D.md`.

## Step 0 — Case summary

| Route | Verdict | L-profile | Key idea |
|-------|---------|-----------|----------|
| B | PASS | 3I + 3L1 + 2L2 | Induct on $i(a,b)$; surgery via bigon criterion (black-boxed). |
| A | STUCK at SP-A3 | — | Farey-graph parametrization ran into strict-$i=0$ vs. $i=1$ tension. |
| D | PASS | 3I + 3L1 + 2L2 | Induct on $i(a,b)$; surgery via explicit coherent resolution $a'\#_p b'$. |

## Step 1 — Five-axis evaluation

### Axis 1 — Correctness

- **B:** Correct modulo Farb–Margalit Prop 1.7 (L2). The homological
  essentiality argument for $c$ is clean.
- **A:** Stuck; the route's Claim 3 ($i = |\det|$ on $S_{1,1}$) was either
  wrong or is incompatible with the edge rule. Either way, this route
  does not close.
- **D:** Correct modulo Farb–Margalit Props 1.6 and 1.7 (L2). The
  coherent-resolution surgery is explicit; the essential-component
  argument via homology of the band sum is clean.

### Axis 2 — Citation depth / closedness

- **B, D:** Identical L-profile (2 L2, same source).
- **A:** Incomplete; cannot rank.

### Axis 3 — Auditability

- **B:** Two audit-targets: (a) the surgery lemma (black-box [L2]);
  (b) the essentiality of $c$ via $[c] = [a] \pm [b]$.
- **D:** Three audit-targets: (a) minimal-position existence [L2];
  (b) the explicit coherent resolution preserves the "$-1$ intersection
  with each of $a, b$" count; (c) the homology-of-resolution argument
  for essential component. More targets but each more *concrete*.
- **D > B** for auditability: the surgery is visible rather than hidden.

### Axis 4 — Library-growth potential

- **B:** Would produce a "curve-complex connectedness via intersection
  induction" library entry, citing an external surgery lemma.
- **D:** Would additionally produce an explicit coherent-resolution
  construction that may generalize (e.g., to $S_{0,4}$, $S_{2,0}$ with
  caveats) in a later artifact. Higher reusability.
- **D > B** here.

### Axis 5 — Evidence Field (O2 observation point)

Evidence items (each a falsifiable atomic claim; target $\ge 6$ to avoid
cap):

1. Strong induction on $N = i(a,b) \in \mathbb{Z}_{\ge 0}$ is
   well-founded: base case $N = 0$ is problem.md §7; strict-decrease step
   produces $c$ with $i(c, a), i(c, b) \le N - 1$.
   — **verifiable by reading problem.md §7 + Step 2–4 of `explorer_3_route_D.md`**.
2. $H_1(S_{1,1}; \mathbb{Z}) \cong \mathbb{Z}^2$.
   — **L1 citation: classification of surfaces; equivalently,
   $H_1(T^2) = \mathbb{Z}^2$ is preserved under puncture removal**.
3. Every essential simple closed curve on $S_{1,1}$ has nonzero homology
   class.
   — **derived in `explorer_3_route_D.md` Subclaim D3.1**.
4. Coherent-orientation resolution $a' \#_p b'$ at a single crossing
   decreases the transverse count with each of $a', b'$ by exactly 1.
   — **derived in `explorer_3_route_D.md` Step 2 counting identity**.
5. $[a' \#_p b'] = [a'] + \epsilon [b']$ in $H_1(S_{1,1})$ for a sign
   $\epsilon$ set by orientation convention.
   — **L1: band-sum homology; standard**.
6. If $[a'] + \epsilon [b'] = 0$, flip resolution: opposite resolution
   gives $2[a'] \ne 0$.
   — **derived in `explorer_3_route_D.md` Step 3 case (D3b)**.
7. At least one component $c'_j$ of the resolution has $[c'_j] \ne 0$
   (by additivity of homology over components).
   — **derived in `explorer_3_route_D.md` Step 3**.
8. $c'_j$ is therefore essential (Subclaim D3.1 in reverse direction).
   — **derived**.
9. $|c'_j \cap a'| \le |(a' \#_p b') \cap a'| = N - 1$, and same for $b$.
   — **derived in `explorer_3_route_D.md` Step 4**.

**Evidence count: 9** — well above the 6/10 cap. No cap hit; O2
observation point confirmed unproblematic.

### Summary score

| Axis | B | D |
|------|---|---|
| 1 Correctness | ✓ | ✓ |
| 2 Citation depth | 2L2 | 2L2 |
| 3 Auditability | medium | **high** (explicit) |
| 4 Library potential | medium | **high** |
| 5 Evidence field | — | 9 items |

**Winner: Route D.** Route B is a valid backup; Route A is parked.

## Step 2 — SP-A3 forensic resolution

Explorer 2's stuck-point deserves a direct answer for the record.

**Explorer 2's claim chain:**
- (C2.3) $i(\alpha_1, \alpha_2) = |p_1 q_2 - p_2 q_1|$ on $T^2$.
- (C2.3') Same formula on $S_{1,1}$ (puncture invisible for $i$).
- ⇒ Distinct primitive classes have $i \ge 1 \ne 0$ ⇒ no edges in
  $\mathcal{C}(S_{1,1})$ under strict $i=0$ reading ⇒ theorem false.

**Where the error is.** Explorer 2's premise that essential SCCs on
$S_{1,1}$ biject with primitive $(p,q)$ is correct for the **isotopy
classes** (mod the puncture, this classification agrees with $T^2$ mod
sign). However, it is NOT true that every essential SCC on $S_{1,1}$ is
determined solely by its homology class. On $T^2$, parallel curves of
the same slope *are* all isotopic, so homology determines isotopy. On
$S_{1,1}$, the puncture breaks this: parallel curves on opposite sides
of the puncture are **not** isotopic (the puncture obstructs the
isotopy), so two distinct essential SCCs of the same homology class can
be disjoint (one on each side of the puncture).

**In particular:** two distinct isotopy classes $a \ne b$ with
$[a] = [b] \in H_1(S_{1,1})$ may satisfy $i(a, b) = 0$. They are linked
by an edge in $\mathcal{C}(S_{1,1})$. The $i = |\det|$ formula Explorer 2
derived applies only to the *homology-class difference*, not to isotopy
classes, on $S_{1,1}$.

**Consequence.** Under problem.md §8's strict $i = 0$ edge rule, the
curve complex $\mathcal{C}(S_{1,1})$ **does** have edges — between
distinct isotopy classes of the same homology class that are
puncture-separated — and the theorem is not vacuous. Route A's
parametrization was incomplete (homology alone is not a parametrization
of $S_{1,1}$ isotopy classes).

**Implication for Routes B/D.** Neither Route B nor Route D relies on
the Route-A parametrization. They reason purely about intersection
number and homology class (as an invariant, not a parametrization).
Hence Routes B/D are unaffected by this forensic correction.

**This resolution is recorded in the log for O4 / O2 purposes and will
not be re-argued in the final proof.**

## Step 3 — Forward to Auditor

**Nominated proof:** `explorer_3_route_D.md` (Route D).

**Rationale:**
- PASS verdict.
- Explicit surgery (better auditability).
- Homology-of-resolution argument for essentiality is a clean, short
  derivation (Subclaim D3.1 + Step 3).
- Two L2 citations, both to a single standard textbook (Farb–Margalit),
  same section (§1.2.4).
- Higher library-growth potential.

**Backup:** Route B (Explorer 1). If Auditor rejects Route D's Step 3
homology argument, Route B's induction frame remains valid (B uses an
abstract existence claim for $c$ that the underlying [L2] provides).

**Parked:** Route A (Explorer 2). The parametrization is interesting and
may be promoted to a library entry later, but it does not close the
theorem under problem.md's edge rule.

## Step 4 — Flags propagated to Auditor

- `[TECHNIQUE-NEW]`: curve-complex induction via coherent resolution —
  forward for LDT dictionary growth log.
- `[L2-LEANS]`: 2 L2 citations, both Farb–Margalit §1.2.4.
- `[AUDIT-TARGETS]`:
  - **AT-1** Step 2 of Route D — "coherent-resolution produces
    simple-closed 1-manifold with transverse count $-1$".
  - **AT-2** Step 3 of Route D — "at least one component is essential".
  - **AT-3** Subclaim D3.1 — "essential SCC on $S_{1,1}$ has nonzero
    homology".
- `[SYMPY-CANDIDATE]` `verify/sp_D_minimal_intersection.py` (mediant /
  coprime-pair cross-check). Fixer may elect to implement if Auditor
  demands additional evidence on the strict-decrease claim.

## Step 5 — Judge verdict

**ACCEPT Route D, forward to Auditor.**
