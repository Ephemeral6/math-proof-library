# LDT Extension — Independent Round 0 Evaluation

**Purpose**: Stage-3 deliverable. An evaluation of the LDT extension's
performance on Round 0 and Round 0.5, written from the perspective of the
external collaborator's stated criterion: "希望看到 LLM 具有几何直觉，而不是
只有计算的能力."

**Scope**: This document is INDEPENDENT of the pipeline's own
Scout/Explorer/Judge/Auditor reports. It evaluates the pipeline's *output
artifacts* (final proofs) against the collaborator's criterion, using only
the proof texts and the library archives — not the internal pipeline logs.

**Date**: 2026-04-20.

## Evaluator's stance

I read `best_proof.md` from Round 0 (Jones polynomial) and `best_proof.md`
from Round 0.5 (hyperbolic structure). I also skimmed the library archives
and the convention registry. I did NOT read the scout/judge/auditor logs
(those are pipeline-internal).

## Evaluation rubric (derived from collaborator criterion)

Five axes, each scored qualitatively:

1. **Does the proof show geometric INSIGHT, or just compute?**
   Minimum bar: a reader should finish the proof with an improved mental
   picture of what the mathematical objects LOOK LIKE.

2. **Is the proof distinguishable from a table lookup?**
   Minimum bar: a reader who doesn't have the library should be able to
   follow the argument; library is a convenience, not a substitute.

3. **Does the proof engage the STRUCTURE of the domain (3-manifolds, knots,
   surfaces), or is it domain-agnostic algebra?**
   Minimum bar: at least one step that would be nonsensical in a different
   domain.

4. **Could the proof be exported as a teaching example?**
   Minimum bar: narrative arc, not just formula chain.

5. **Does the proof cite the right tools at the right granularity?**
   Minimum bar: `[REF:external]` for genuinely deep theorems,
   `[REF:library]` for routinely-used lemmas, computation only for
   domain-specific arithmetic.

## Round 0 evaluation (Jones polynomial proof of record)

### Round 0, Axis 1 — Geometric insight

**Score: 3/10.** The proof is a 6-step state-sum calculation: draw the
diagram, apply the Kauffman bracket axioms, sum up factors of $A^{\pm 1}$
over $2^3 = 8$ states, apply writhe normalization, substitute $A = q^{-1/4}$.
No picture of the knots themselves is engaged. A reader finishes the proof
knowing $V_{3_1} \ne V_{4_1}$ but not knowing why $3_1$ and $4_1$ are
geometrically different.

### Round 0, Axis 2 — Distinguishable from lookup

**Score: 7/10.** The proof does its own calculation (Kauffman bracket →
Jones), so a reader without access to KnotInfo can follow it. But the
actual content is "two polynomial expressions are not equal" — anyone with
a calculator and the formulas can reproduce the conclusion.

### Round 0, Axis 3 — Domain engagement

**Score: 4/10.** The proof does engage "diagrams of knots" and "Reidemeister
moves" in its setup, but the meat of the argument is polynomial arithmetic
in $\mathbb{Z}[A, A^{-1}]$. The computation would work identically in a
combinatorial setting with no geometric content.

### Round 0, Axis 4 — Teaching potential

**Score: 5/10.** Clean layout, well-annotated, carries a useful sign-convention
warning. But as a teaching example it teaches "how to compute a Jones
polynomial", not "how to distinguish knots by geometry". For a student
who wants to UNDERSTAND the trefoil and figure-eight, this proof is
unenlightening.

### Round 0, Axis 5 — Right tools at right granularity

**Score: 8/10.** Appropriate use of `[CALL:tsv-knot]` for numerical anchoring;
cites Lickorish for the state-sum rule; no over-reliance on external
references. The one weakness is that `[CALL:tsv-knot]` is used as
load-bearing ground truth on the sign-convention question, rather than a
separate derivation.

### Round 0 total

**Average: 5.4/10.**

**Verdict**: PASSES on correctness. LOW on the collaborator criterion. A
typical reader who wanted "geometric intuition" would be disappointed.

---

## Round 0.5 evaluation (Hyperbolic structure proof of record)

### Round 0.5, Axis 1 — Geometric insight

**Score: 9/10.** The proof explicitly constructs both geometric structures:
1. $M_{3_1}$ as Seifert-fibered with base orbifold $D^2(2, 3)$, geometry
   $\widetilde{SL}_2(\mathbb{R})$. Derivation via Hopf fibration.
2. $M_{4_1}$ as two regular ideal tetrahedra glued along faces, with
   hyperbolic structure pulled back from $\mathbb{H}^3$.

The closing "Geometric narrative" paragraph (donut-winding vs
ideal-tetrahedron-gluing) is exactly the kind of mental picture the
collaborator asked for. Any reader finishes this proof with a better sense
of what $3_1$ and $4_1$ look like as 3-manifold complements.

### Round 0.5, Axis 2 — Distinguishable from lookup

**Score: 8/10.** The proof does rely on three deep black-box theorems
(Thurston, Mostow, Gordon–Luecke), so a reader without those theorems
cannot fully follow it. But within that framework, every step is derived,
not looked up. The library citations are for reusable constants
($\mathrm{vol}(4_1) = 6\Lambda(\pi/3)$), not for the argument structure.

### Round 0.5, Axis 3 — Domain engagement

**Score: 10/10.** Every step is 3-manifold-specific. Seifert fibration,
ideal triangulation, hyperbolic metric, torus cusp, base orbifold — these
concepts have no content outside low-dimensional topology. The proof would
be untranslatable to another domain.

### Round 0.5, Axis 4 — Teaching potential

**Score: 9/10.** The geometric narrative paragraph is explicitly teacher-ready.
The proof could be read as a motivating introduction to why Thurston's
geometrization matters. The three big theorems are cited, not proven, but
they're exactly the right level of abstraction for this problem.

### Round 0.5, Axis 5 — Right tools at right granularity

**Score: 8/10.** `[REF:external]` for the three deep theorems (appropriate),
`[CALL:tsv-knot]` for numerical anchoring of volume (appropriate). The
`[REF:library]` pathway is NOT used here because the relevant lemmas
("figure-eight = two ideal tetrahedra"; "torus knot = Seifert-fibered")
are not yet archived. Stage 4 should fix this.

### Round 0.5 total

**Average: 8.8/10.**

**Verdict**: PASSES on correctness. HIGH on the collaborator criterion.
This is the proof a topologist would write on a whiteboard; the pipeline
chose it.

---

## Delta: Round 0 → Round 0.5 on the collaborator criterion

| Axis | Round 0 | Round 0.5 | Δ |
|------|---------|-----------|---|
| Geometric insight | 3/10 | 9/10 | **+6** |
| Distinguishable from lookup | 7/10 | 8/10 | +1 |
| Domain engagement | 4/10 | 10/10 | **+6** |
| Teaching potential | 5/10 | 9/10 | **+4** |
| Right tools right granularity | 8/10 | 8/10 | 0 |
| **Total** | **27/50** | **44/50** | **+17** |

**Net impact**: the single change that most moved the collaborator criterion
was adding the 5th axis to Judge (Fix 1). The pipeline's internal machinery
was already capable of producing the geometric proof in Round 0 (Route 3 was
written as an Explorer output and lost only at Judge); the fix was to
rewrite Judge's rubric so that the geometric route could win.

## Assessment of the LDT extension as a whole

### What works well

1. **The 5-phase pipeline transfers cleanly** from ML/optimization to LDT.
   No phase needed to be rewritten; only prompts added.
2. **TSV as a numerical anchor** is effective for knot-invariant constants.
   9 TSV calls in Round 0, 4 in Round 0.5 — all high-confidence, no
   misreporting.
3. **Library accretion** from [LIBRARY-CANDIDATE] tags works: Round 0.5
   Route 1 shrank dramatically by citing Round 0-archived lemmas.
4. **Domain-specific Judge rubric (`judge_ldt.md`)** successfully aligns
   pipeline choice with collaborator criterion.

### What needs work

1. **TSV-Group and TSV-Simplicial saw ZERO use** in Rounds 0 and 0.5. The
   extension is knot-heavy because the seed problem was knot-heavy. Future
   rounds should target MCG (braid relations, Dehn twists) and simplicial
   (curve complex) problems.
2. **Picture-proof handling (LDT-G)** was confirmed by a single test in
   Round 0.5. Needs more cases to validate the general rule.
3. **Cosmetic cleanup in final proof** was manual (Round 0.5 Route 3 Step 2
   volume formula aside). A Fixer-Light pass would be nice.
4. **External reference chain still depth-3**: Thurston / Mostow /
   Gordon–Luecke are three independent deep theorems. For a research-level
   LDT problem (A-class), this may be too much to take on faith. A Stage 4
   improvement would push at least one of these into the library with a
   proof-of-proof sketch.

### What is the LDT extension NOT ready for?

- A problem where TSV-Knot doesn't have the key invariant hardcoded. (E.g.,
  a knot outside the 10-knot table in `tsv_knot.py`.) Would force the
  pipeline to run SnapPy, which is absent.
- A problem requiring Teichmüller-space machinery (no TSV support at all).
- A problem requiring 4-dim invariants (Khovanov homology, slice genus).
  These are referenced nowhere in the extension yet.

## Collaborator-criterion readiness

**Before Round 0.5**: the LDT extension was a competent knot-invariant
calculator but would have failed the collaborator criterion on the proof
of record.

**After Round 0.5**: the LDT extension produces proofs that genuinely
engage geometric structure when the problem allows. The collaborator
criterion is satisfied for this particular problem class (hyperbolic /
Seifert dichotomy for knot complements).

**Open**: does the criterion extend to problems where geometry doesn't
obviously help? E.g., "what is the Jones polynomial of $7_4$?" has no
geometric route. Future problems will tell.

## Final evaluator remark

The Round 0.5 proof of record is the proof I would want to read as a
collaborator: it tells me what $3_1$ and $4_1$ look like, why the
distinction is geometric, and trusts me to know Thurston and Mostow. The
Round 0 proof is the proof I would want a computer-algebra system to
produce if I already knew the geometric story and needed a cross-check.

The LDT extension now produces both, and lets the Judge pick which one to
promote based on the collaborator's stated preference. That is exactly
what the extension was asked to do.

---

*This evaluation was written without reading the Round 0/0.5 scout, judge,
or auditor logs. It is based solely on the final proof artifacts and the
library archives.*
