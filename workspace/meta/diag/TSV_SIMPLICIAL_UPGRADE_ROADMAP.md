# TSV-Simplicial Upgrade Roadmap

**Scope.** Plan an upgrade path for `tsv_simplicial.py` (and, where
coupled, `tsv_knot.py` and `tsv_group.py`) so that the math-verifier's
ground-truth layer can support the five LDT subdomains represented in
`proofs/research/low-dimensional-topology/` and
`proofs/library/low-dimensional-topology/`.

**What this document is.** A roadmap. Requirement analysis, DAG of
capability dependencies, feasibility per capability, and a MVI
proposal. **No code.**

**Author.** P2 of the three-tier v2.2 upgrade (P0 Integrator → P1
Verified Sympy protocol → P2 TSV-Simplicial roadmap).

**Date.** 2026-04-21.

---

## Section 1 — Capability demands per LDT subdomain

For each of the five subdomains, the demands are itemized as
capabilities the math-verifier would need in order to *mechanically
check* (not merely accept on citation) a proof step that sits inside
that subdomain. A capability is scoped as finite or infinite, and — where
applicable — is tagged with the authoritative upstream construction
that would need to be implemented.

### 1.1 knot-theory

Current coverage: `tsv_knot.py` (7-knot lookup table, Burau fallback for
$B_2$, hyperbolic-volume hardcoded table, heuristic Reidemeister
equivalence). Known-incorrect Kauffman bracket for the right-trefoil
(see `diag/c5_tsv_coverage_map.md` §Critical-finding).

| # | Demand | Scope | Authoritative upstream |
|---|--------|-------|------------------------|
| K1 | Named-knot table expansion: $8_*$, $9_*$, $10_*$ crossing numbers | finite | KnotInfo / KnotAtlas |
| K2 | Generic-braid Alexander polynomial for $B_n$, $n \le 6$ via reduced Burau | finite (per $n$) | Birman, *Braids, Links, and MCGs* §3 |
| K3 | Generic-braid Jones polynomial via Temperley–Lieb / HOMFLY specialization | finite (per word length) | Jones 1985, Kauffman 1987 |
| K4 | Kauffman bracket bug fix: normalize convention so $\langle 3_1 \rangle = -A^5 - A^{-3} + A^{-7}$ | regression | Kauffman 1987 |
| K5 | Signature $\sigma(K)$ from Seifert matrix, for knots with $M$ in table | finite | Rolfsen §10.E, Litherland 1979 |
| K6 | Slice genus / 4-genus lower bounds (from signature, Tristram–Levine) | finite-per-knot | Tristram 1969 |
| K7 | Concordance invariants (e.g. $\tau$, $s$): HARD; out of MVI scope | infinite / oracle | Heegaard-Floer / Khovanov |
| K8 | Alexander / Conway polynomial via *skein-tree* for small link diagrams | finite | Conway 1970 |

### 1.2 mapping-class-groups

Current coverage: `tsv_group.py` (Artin relations for $B_n$, $n \le 10$;
lantern / chain / braid / disjoint-commute; symbolic Dehn-twist action).

| # | Demand | Scope | Authoritative upstream |
|---|--------|-------|------------------------|
| M1 | Intersection-number arithmetic on $S_{g,n}$ curves given coordinates | finite | Farb–Margalit §1.2, Penner–Harer train tracks |
| M2 | Actual Dehn-twist update to intersection numbers (not just symbolic) | finite | Farb–Margalit §3.3 |
| M3 | Finite-presentation check: verify a putative relation in $\mathrm{Mod}(S_g)$ is a consequence of Wajnryb's presentation | finite | Wajnryb 1983 |
| M4 | Torelli subgroup membership check via Johnson homomorphism | finite | Johnson 1980 |
| M5 | Birman exact sequence manipulation (symbolic) | finite | Farb–Margalit §4.2 |
| M6 | Nielsen–Thurston classification oracle (periodic / reducible / pseudo-Anosov) | infinite per-element | Thurston 1988, Bestvina–Handel 1992 |
| M7 | Train-track computations: $\lambda$-transition matrices, PF eigenvalue | finite-once-given-a-track | Bestvina–Handel 1992 |
| M8 | Compute commutator length of $w \in \mathrm{Mod}(S)$ | infinite / oracle | Endo–Kotschick 2001 (genus lower bounds only) |

### 1.3 curve-complex

Current coverage: `tsv_simplicial.py` (finite simplicial complex; flag
condition; path-distance upper bound when witness provided; star / link).
Every global C(S) question is currently stuck.

| # | Demand | Scope | Authoritative upstream |
|---|--------|-------|------------------------|
| C1 | Fill in finite local neighborhoods of C(S) for small $S$: $S_{0,4}$ (Farey graph), $S_{1,1}$ (Farey graph) | finite | Minsky 1992 (these C(S) are explicitly the Farey graph) |
| C2 | Distance *lower* bounds in C(S) via subsurface projection witnesses (finite side) | finite-per-witness | Masur–Minsky 2000 |
| C3 | Hyperbolicity constant $\delta$ as a *registered L2 fact*, not a verification (Masur–Minsky 1999) | citation-only | Masur–Minsky 1999 |
| C4 | Bounded geodesic image theorem as L2 | citation-only | Masur–Minsky 2000 |
| C5 | Tight geodesic existence (Bowditch 2008) as L2 | citation-only | Bowditch 2008 |
| C6 | Arc complex $\mathcal{A}(S)$ local model: finite arcs, disjointness, flag | finite | Harer 1985 |
| C7 | Pants graph $\mathcal{P}(S)$ local model: pants decompositions as vertices, elementary moves as edges | finite | Hatcher–Thurston 1980 |
| C8 | Disk complex $\mathcal{D}(V)$ local model (for a handlebody $V$) | finite | Masur–Schleimer 2013 |

**Note on C3–C5.** These are infinite / global properties of C(S). The
roadmap's philosophy is: *TSV never pretends to verify global
hyperbolicity*. These remain L2 citations; the Auditor permits them
with a `[VERIFIED: method=citation, source=..., confidence=high]` tag
but not `method=tsv-simplicial`.

### 1.4 teichmuller-theory

Current coverage: none. Teichmüller space $\mathcal{T}(S)$ is infinite-dimensional-per-
noded-surface-type and pseudo-metric; there is no finite oracle.

| # | Demand | Scope | Authoritative upstream |
|---|--------|-------|------------------------|
| T1 | Fenchel–Nielsen coordinates: explicit twist / length tuple | finite-per-pants-decomp | Wolpert 1982 |
| T2 | Teichmüller distance lower bound from ratios of extremal lengths (finite side) | finite-per-curve-pair | Kerckhoff 1980 |
| T3 | Weil–Petersson geodesic existence / length ops (symbolic) | infinite / oracle | Wolpert 1987 |
| T4 | Thurston's compactification: projective measured laminations on a train track | finite-per-track | Thurston 1988 |
| T5 | Masur–Smillie: generic foliation non-uniquely-ergodic | citation-only | Masur–Smillie 1991 |
| T6 | Mumford compactness: sequence of hyperbolic metrics with systole bounded below converges | citation-only | Mumford 1971 |

### 1.5 3-manifolds

Current coverage: none.

| # | Demand | Scope | Authoritative upstream |
|---|--------|-------|------------------------|
| 3M1 | Heegaard-splitting genus bookkeeping (symbolic) | finite | Scharlemann 2002 survey |
| 3M2 | Dehn-surgery coefficient arithmetic on knots (generic) | finite | Rolfsen §9 |
| 3M3 | SnapPy link to compute hyperbolic volume / cusp structure when available | optional external | SnapPy |
| 3M4 | Cyclic-surgery theorem as L2 | citation-only | Culler–Gordon–Luecke–Shalen 1987 |
| 3M5 | Geometrization statement as L2 | citation-only | Perelman / Morgan–Tian |
| 3M6 | JSJ-decomposition finite data structure | finite | Jaco–Shalen / Johannson |
| 3M7 | Bounded-geometry check via systole computation for hyperbolic mfds | numeric-per-mfd | SnapPy (if available) |
| 3M8 | Character-variety computation for small knots | finite | Culler–Shalen |

---

## Section 2 — Capability DAG with priority tiers

Dependencies flow top-to-bottom within a tier, and later tiers depend
on earlier tiers via the arrows below. "Priority" reflects both pain
(how often the current pipeline's stuck-points trace back to this
capability) and payoff (how many downstream capabilities / proof
subdomains light up).

### Tier 0 — infrastructure / regression

- **K4** Kauffman-bracket convention fix. [Blocks nothing, but is a
  known wrong value currently shipped with `high` confidence, so it is
  higher-severity than everything else in Tier 1.]

### Tier 1 — table expansion & fallback (pure data / existing formulas)

```
K1 ──► K5 ──► K6
K1 ──► C1 (small-surface Farey graphs)
K1 ──► M3 (presentations that cite low-crossing examples)
K2 ──► K3   (Burau-based Jones via determinant-of-matrix)
K2 ──► K8   (skein tree needs a base table)
3M2 ──► 3M1 (surgery notation underpins Heegaard bookkeeping)
```

### Tier 2 — symbolic intersection-number / simplicial upgrades

```
M1 ──► M2 ──► M3 (Wajnryb-relation verification needs intersection updates)
M1 ──► C2 (subsurface projection uses intersection numbers as the lower bound)
C1 ──► C6 (arc complex shares the finite-complex plumbing)
C1 ──► C7 (pants graph shares the finite-complex plumbing)
C6 ──► C8 (disk complex reuses arc-complex conventions)
```

### Tier 3 — external solvers behind an optional shim

```
3M3 (SnapPy) ──► 3M7 (systole) ──► 3M8 (character variety sanity)
M7 (train-tracks) ──► M6 (Nielsen–Thurston classification)
```

### Tier 4 — L2 citations (no TSV implementation needed; only a registered citation lookup)

```
C3, C4, C5, T3, T5, T6, 3M4, 3M5, K7, M8 ...
```

*These do not live in TSV code*. They live in a registered citation
database the Auditor consults. The roadmap explicitly quarantines them
from the implementation stack — this is how we avoid the trap that
doomed previous attempts at "universal topology verifiers".

### Summary of the DAG

```
   Tier 0  [K4 regression]
      │
      ▼
   Tier 1  [K1, K2, K3, K5, K6, K8, C1, M3-shallow, 3M1, 3M2]
      │
      ▼
   Tier 2  [M1, M2, C2 (lower-bound side), C6, C7, C8, M3-deep]
      │
      ▼
   Tier 3  [3M3, 3M7, 3M8, M6, M7]
      │
      ▼
   Tier 4  [citation-only: C3-C5, T3, T5-T6, 3M4-3M5, K7, M8]
```

---

## Section 3 — Feasibility assessment

Rubric per capability:

- **Implementation cost** — engineer-days to reach a working,
  protocol-compliant version (one-person, assuming Python + sympy +
  networkx + optional external SnapPy).
- **Risk** — likelihood a naive implementation ships wrong answers with
  high confidence (cf. the K4 regression as evidence this is a real
  risk, not hypothetical).
- **Expected hit rate** — fraction of recent LDT proof steps that get
  unblocked if this capability is available. Estimates drawn from the
  stuck-points inventory in `workspace/active/ldt_spiral_knots_stress_test/`
  and the stress-test report `workspace/diag/spiral_knots_stress_test_report.md`.

### Tier 0

| Cap | Cost | Risk | Hit rate | Note |
|-----|------|------|----------|------|
| K4  | 0.25 d | low | 0% direct (it mostly affects Probes, not proofs) | Must-fix regardless — ships a wrong value with `high` confidence. |

### Tier 1

| Cap | Cost | Risk | Hit rate | Note |
|-----|------|------|----------|------|
| K1 (30-knot table)  | 1 d | low | ~30% | Paste from KnotInfo CSV + consistency tests. |
| K2 ($n \le 6$ Burau Alexander) | 2 d | medium | ~40% | Sympy already does determinants; conventions must match K1. |
| K3 (braid Jones via HOMFLY)  | 4 d | high | ~15% | HOMFLY normalization is famously easy to get wrong (cf. K4). Needs cross-check against K1. |
| K5 (signature from Seifert)  | 1 d | low | ~5% | Small but cheap. |
| K6 (4-genus lower bounds)    | 2 d | low | ~5% | Depends on K5. |
| K8 (skein tree, small diagrams) | 3 d | medium | ~10% | Needs a diagram data structure. |
| C1 (Farey graph for $S_{0,4}$, $S_{1,1}$) | 2 d | low | ~20% | Exact description available (Minsky); pure finite data. |
| 3M1, 3M2 | 2 d | low | ~10% | Bookkeeping layer; no deep content. |

### Tier 2

| Cap | Cost | Risk | Hit rate | Note |
|-----|------|------|----------|------|
| M1 (intersection numbers) | 5 d | medium | ~25% | Many conventions; need to commit to one (e.g. Penner–Harer) and document in `tsv_convention_audit.md`. |
| M2 (Dehn twist updates)  | 3 d | high | ~15% | Requires M1 stable first. |
| M3 (Wajnryb-relation check) | 4 d | medium | ~10% | Wajnryb's presentation is finite but large; implementation must verify each relator. |
| C2 (subsurface-projection lower bounds, witness-driven) | 4 d | high | ~15% | The infinite side stays out of scope; only the witness-provided side is implementable. |
| C6, C7, C8 (arc / pants / disk complex, local) | 6 d | medium | ~10% | Share infrastructure with C1; many local questions open up. |

### Tier 3

| Cap | Cost | Risk | Hit rate | Note |
|-----|------|------|----------|------|
| 3M3 (SnapPy shim)   | 2 d (optional) | low | ~5% | Only works when SnapPy is installed; fallback must degrade gracefully. |
| 3M7, 3M8           | 3 d each | medium | ~5% each | Depend on 3M3. |
| M6, M7 (Nielsen–Thurston, train tracks) | 8 d | high | ~5% | Requires Bestvina–Handel; conventions are painful. |

### Tier 4

Citation-only (no TSV implementation). Cost is the cost of populating
a citation DB with (theorem-name, citation, confidence). Estimated
**1 d per 50 theorems** for the database; registration of the 10 items
listed costs ~0.2 d.

### Overall feasibility verdict

- Tier 0 + Tier 1 is **fully feasible in ~15 engineer-days** with low
  aggregate risk, and covers an estimated **~55% of currently
  stuck-point LDT steps** (hit-rates do not sum linearly, but dominant
  capabilities are K1–K3 and C1).
- Tier 2 is **feasible in another ~20 days** but risk grows sharply at
  M1 (conventions) and C2 (easy to overstate what was verified).
- Tier 3 requires SnapPy and/or Bestvina–Handel machinery; the ROI is
  lower per day than Tier 1–2, so it belongs *after* Tier 1–2 ship.
- Tier 4 is cheap and should be done in parallel with Tier 0.

---

## Section 4 — MVI proposal

The Minimum Viable Increment (MVI) is the smallest slice of this
roadmap that **simultaneously** (a) fixes the known regression,
(b) lifts the hit-rate on recent LDT stuck-points by at least 30pp,
and (c) does not introduce any high-risk capability that might ship
wrong-answer-with-high-confidence regressions.

### MVI scope: **Tier 0 + the low-risk core of Tier 1 + the Tier 4 registration work**.

Concretely, the MVI consists of 5 deliverables:

1. **K4: Kauffman-bracket convention fix.** Patch `tsv_knot.py` so
   $\langle 3_1 \rangle = -A^5 - A^{-3} + A^{-7}$. Add a regression
   test loaded from the existing probe log
   (`workspace/diag/c5_tsv_coverage_map.md`). **Cost ~0.25 d; risk low.**

2. **K1: Named-knot table expansion.** Extend the lookup from 7 knots
   to 30 (all prime knots through 8 crossings plus selected 9- and 10-
   crossing torus / two-bridge examples relevant to spiral-knots). Data
   pulled from KnotInfo; conventions audit appended to
   `tsv/tsv_convention_audit.md`. **Cost ~1 d; risk low.**

3. **K2: Braid-Alexander for $B_n$, $n \le 6$.** Extend the Burau
   fallback from $B_2$ to $B_6$. Cross-check every table entry in K1
   that has a known braid word. **Cost ~2 d; risk medium but capped by
   the K1 cross-check.**

4. **C1: Farey-graph oracles for $S_{0,4}$ and $S_{1,1}$.** Populate a
   finite-state Farey-graph representation; expose `are_neighbors`,
   `distance_upper_bound`, `explicit_path` for curves encoded as
   slope fractions. **Cost ~2 d; risk low.**

5. **Tier-4 citation DB seed.** Register the 10 explicitly-named L2
   facts from §1 (C3, C4, C5, T3, T5, T6, 3M4, 3M5, K7, M8) in a new
   `tsv/citation_db.json`. Auditor §F3 extended to recognize
   `method=citation` as a valid verification method only if the cited
   item is in the registered list. **Cost ~0.2 d; risk low.**

### MVI non-goals (explicitly **out**)

- Anything Tier 2+: no intersection-number arithmetic, no Dehn-twist
  updates, no subsurface projection, no pants graph.
- Tier 3 externals: no SnapPy link, no Bestvina–Handel.
- K3 (Jones via HOMFLY): held for a *second* increment because the
  normalization risk is comparable to K4 and we want K4's regression
  net in place first before shipping a new polynomial with similar
  convention pitfalls.
- Deep M3 (full Wajnryb relator verification): the shallow variant
  stays as "citation-only" until M1 is available in Tier 2.

### MVI exit criteria

The MVI is **done** when all of the following hold:

- The `tsv/` module suite passes its existing regression tests plus
  new tests for K1, K2, K4, C1. (The P1 Verified Sympy Block protocol
  is already in force, so each test is protocol-compliant:
  `ALL PASSED: N cases` on stdout, exit 0, ≤ 60s.)
- `tsv_convention_audit.md` is updated with the three conventions
  touched by this MVI: Kauffman bracket, reduced Burau sign, Farey
  slope-to-curve encoding.
- `tsv/README.md` is updated with the new capability matrix.
- The Auditor checklist (`ldt_checklist.md`) is updated to recognize
  `method=citation` as a valid verification when the cited item is
  in `tsv/citation_db.json`.
- A fresh run of the spiral-knots stress-test (or a similarly-shaped
  LDT round) demonstrates at least a **30-percentage-point reduction
  in step-level stuck-points** that trace to TSV coverage gaps.

### MVI cost roll-up

| Item | Cost (d) | Risk |
|------|----------|------|
| K4 regression | 0.25 | low |
| K1 table    | 1.0  | low |
| K2 Burau    | 2.0  | medium (mitigated by K1 cross-check) |
| C1 Farey    | 2.0  | low |
| Tier-4 DB   | 0.2  | low |
| Testing & docs | 0.5  | low |
| **Total**   | **~6 engineer-days** | **medium aggregate** (driven by K2) |

### What the MVI explicitly does *not* promise

- It does **not** verify any infinite / global property of C(S),
  $\mathrm{Mod}(S)$, or $\mathcal{T}(S)$. Those stay as Tier-4
  citations.
- It does **not** compute Jones / HOMFLY for generic braids (only
  Alexander, and only via Burau up to $B_6$).
- It does **not** implement Dehn-twist updates or subsurface
  projection. A proof step that needs these stays `[STEP-STUCK]` until
  a later increment.

---

## Appendix A — Parking lot

Capabilities considered and deliberately deferred past the MVI:

- **K3 (Jones via HOMFLY).** Ship after K4 regression is in place for
  at least 2 proof cycles.
- **M1–M3 (intersection arithmetic / Dehn updates / Wajnryb).**
  Highest-payoff Tier-2 cluster; ~12 d; needs its own convention audit.
- **C6/C7/C8 (arc, pants, disk complexes).** Shared plumbing with C1;
  tackle together once C1 is stable.
- **3M3 (SnapPy).** Optional; depends on the oncall machine having
  SnapPy available — the fallback path (hardcoded table) is the norm.

## Appendix B — Interfaces to existing modules

- `tsv_knot.py` owns K1, K2, K3, K4, K5, K6, K7 (citation), K8.
- `tsv_group.py` owns M1–M8.
- `tsv_simplicial.py` owns C1, C2, C6, C7, C8.
- **New (proposed)** `tsv/citation_db.json` + a thin
  `tsv_citation.py` wrapper owns Tier-4 citations.
- No existing file is deleted by the MVI; all edits are additive
  plus the K4 patch.

## Appendix C — Why this roadmap prefers table expansion over
"symbolic-first"

The current TSV regression (K4, Kauffman bracket) came from a
symbolic-first implementation: the code tried to derive the bracket
from the Jones polynomial via an identity, and shipped the wrong
convention. The safer pattern for low-dimensional topology — given how
many conventions disagree at the sign / variable-inversion level — is
to **ship a table + cross-check**, and to reserve symbolic derivation
for steps that are *already* cross-checked against the table. The MVI
is consistent with this: K2's Burau implementation is validated
against the expanded K1 table before it ships.
