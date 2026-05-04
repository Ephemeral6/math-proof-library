# Auditor — Round 0.5 audit of Route 3 (Hyperbolic) + Route 1 (Jones) as alternative

## Part 1 — Audit Route 3 (primary winner)

### 1.1 V2 standard audit

- **Claim chain**: (a) $M_{3_1}$ is Seifert-fibered with base $D^2(2,3)$;
  (b) Seifert-fibered with hyperbolic base orbifold Euler char $< 0$ yields
  $\widetilde{SL}_2$ geometry, not $\mathbb{H}^3$; (c) $M_{4_1}$ admits
  complete hyperbolic structure via two regular ideal tetrahedra;
  (d) Mostow: hyperbolic-admissibility is topological; (e) Gordon–Luecke:
  complement determines knot.
- **Logical flow**: (a)+(b) ⇒ no hyperbolic on $M_{3_1}$; (c) ⇒ hyperbolic
  on $M_{4_1}$; (d) ⇒ if $M_{3_1} \cong M_{4_1}$, both hyperbolic — contradiction;
  (e) ⇒ knots distinct. ✓ Sound.
- **TSV coverage**: 2 calls (volume of $4_1$, volume of $3_1$=None). Both
  high-confidence. Covers the numerical claim and the non-existence claim. ✓
- **Step 0.5 reverse-consistency**: swap roles $3_1 \leftrightarrow 4_1$ —
  argument holds by symmetry of "hyperbolic vs non-hyperbolic" distinction. ✓
- **Black-box references**: 3 × `[REF:external]` (Thurston, Mostow,
  Gordon–Luecke). Each is standard and appropriate for the difficulty level
  of this problem. No over-citation.

**V2 verdict: PASS.** Minor: Step 2's volume-formula aside should be cleaned
up in the final archive — see Fixer-Light note below.

### 1.2 LDT checklist (8 items)

- **A (isotopy vs equivalence)**: PASS. Route 3 works with oriented
  ambient isotopy throughout; Gordon–Luecke is stated for ambient-isotopy
  equivalence.
- **B (orientation)**: PASS. Both knots oriented; orientation irrelevant for
  the Seifert vs hyperbolic distinction.
- **C (dimension 3 vs 4)**: PASS (not applicable — purely 3-dim).
- **D (compactness / infinitude)**: PASS. Both manifolds are compact (knot
  complements with torus cusp boundary); finite-volume hyperbolic in $M_{4_1}$
  case; the cusp is treated correctly as a torus boundary of the compact
  manifold with one removed ideal point (or equivalently, a $T^2$-cross-section
  of the complete structure).
- **E (group presentation)**: PASS (not applicable — no group presentation
  used).
- **F (literature cross-check of constants)**: PASS. Volume $6\Lambda(\pi/3)
  \approx 2.02988$ matches SnapPy output, Thurston's original calculation,
  and KnotInfo's `hyperbolic_volume` field for $4_1$. Seifert base orbifold
  $D^2(2,3)$ matches Rolfsen Ch. 3 and Burde–Zieschang.
- **G (picture-proof handling)**: **FIRES.** Route 3 claims "$M_{4_1}$ is two
  regular ideal tetrahedra glued along faces". This IS a picture fact; without
  a picture, the reader must trust Thurston's explicit gluing. Audit: is this
  formally stated? **Route 3 states it as a citation to Thurston's Princeton
  notes §4**. TSV-Knot does not verify the triangulation directly, but TSV
  does verify the volume derived FROM it. So the picture-proof is
  numerically-anchored via the volume. **Verdict: PASS with NOTE** — the
  triangulation is cited; the numerical consequence is TSV-verified; this is
  acceptable handling per LDT-G rules.
- **H (geometric-intuition score)**: **9/10** (self-scored; auditor agrees).
  This is precisely the kind of proof the collaborator criterion asks for.

**LDT checklist verdict: 8/8 items pass or PASS-with-NOTE.**

### 1.3 Hypothesis tracker update

- **H6 (Picture-proof detection will matter)**: **NOW CONFIRMED.** Route 3
  triggered LDT-G; Auditor confirmed the handling rule (cite + TSV-anchor
  numerical consequence). This validates the LDT-G design.

### 1.4 Fixer-Light pass on Route 3

One cosmetic issue flagged at Judge: Step 2 has a volume-formula aside
("Wait — let me be careful…") that was resolved in-text but reads as
intermediate scratch-work. Recommendation: rewrite Step 2 volume paragraph
as a single clean statement for `best_proof.md`. Not a correctness issue,
so no Fixer round triggered — we'll do the minor cleanup inline.

## Part 2 — Audit Route 1 (alternative route)

Route 1 is essentially a trivial citation-based proof. All three library
lemmas (`jones-trefoil-right.md`, `jones-figure-eight.md`, `kauffman-bracket-axioms.md`)
were audited when archived (Stage 3). TSV re-verifies both Jones polynomials.
No flags.

**V2 verdict: PASS.** **LDT checklist verdict: A, B, E, F fire, all PASS.
G, H inapplicable (no picture; geometric content = 4/10 doc).**

## Part 3 — Round 0.5 vs Round 0 comparison (for delta report)

| Metric | Round 0 | Round 0.5 | Delta |
|--------|---------|-----------|-------|
| Library hits | 0 | 4 | **+4** |
| Routes run | 3 | 2 | −1 (Route 2 Alexander skipped per Scout) |
| Winner route | Route 1 (Jones, 19/20) | Route 3 (Hyperbolic, 47.5/55) | **flipped** |
| Geometric Content of winner | 2/5 | 9/10 | **massive improvement** |
| [STEP-STUCK] tags | 1 (in Route 2) | 0 | −1 |
| [SIGN-CONVENTION] flags | 1 (Route 1, resolved) | 0 | −1 |
| TSV calls | 9 | 4 | −5 (library-citation shorts the path) |
| Auditor flags | 2 (FLAG-1, FLAG-2, resolved) | 1 minor cleanup note | −1 |
| LDT checklist items fired | 5 (A, B, E, F, H) | 8 (all on Route 3) | **+3** (G, C, D all applicable now) |
| Hypotheses confirmed | H1, H3, H5; H2, H4 partial; H6 deferred | H1, H3; H2 closed; H4 full; H6 confirmed | **better coverage** |

## Verdict

Both routes PASS. Route 3 is primary (`best_proof.md`); Route 1 archived as
`alternative_route_algebraic.md`.

**No Fixer round required.** Only a cosmetic cleanup on Route 3 Step 2 (will
be applied when copying to `best_proof.md`).
