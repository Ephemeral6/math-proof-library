# Scout — Trefoil vs Figure-Eight Inequivalence (Round 0.5)

## Step 0: Library / technique / failure-pattern search (with Stage 3 fixes)

### 0a. Technique library
Read `workspace/proof_techniques_ldt.md` — unchanged since Round 0 (10 entries).
Relevant: §1.1 skein, §1.2 state sum, §1.3 Burau, §1.5 hyperbolic obstruction.

### 0b. Library lemma search — **NEW HITS**
`proofs/library/low-dimensional-topology/knot-invariants/`:
- `jones-trefoil-right.md` ✓ — gives $V_{3_1}(q) = -q^{-4} + q^{-3} + q^{-1}$ directly.
- `jones-figure-eight.md` ✓ — gives $V_{4_1}(q) = q^{-2} - q^{-1} + 1 - q + q^2$ directly.
- `kauffman-bracket-axioms.md` ✓ — foundation lemma available for reference.

Also: `proofs/library/low-dimensional-topology/conventions.md` ✓ — fixes the
Lickorish / reduced-Burau conventions. This closes the sign-convention
ambiguity that bit Round 0 Explorer 1.

**Hit count: 4** (vs 0 in Round 0). Scout notes this is a domain-specific fix
that only covers the Jones route; Alexander (Burau for $B_3$) and hyperbolic
routes still have no library coverage.

### 0c. Failure patterns
`workspace/failure_patterns.md` now contains 4 new LDT entries (FP-LDT-01 to
FP-LDT-04) from Round 0's gap report. Relevant for route design:
- FP-LDT-01 (Burau $B_3$ normalization) → Route 2 is still risky without
  explicit convention fix; but with `conventions.md` §1.3 now fixing reduced
  Burau dim $n-1$ with normalizer $1 + t + \cdots + t^{n-1}$, Route 2 is
  somewhat de-risked.
- FP-LDT-02 (Kauffman writhe substitution → mirror) → **mitigated by library**
  lemmas that give the correct right-handed polynomial directly.
- FP-LDT-03 (non-hyperbolic → no volume) → warning for Route 3 to state
  "undefined" rather than "vol = 0".
- FP-LDT-04 (Judge undervalues geometry) → mitigated by `judge_ldt.md`.

## Route prioritization (Round 0.5, anticipating Judge's new rubric)

### Route 1: Jones polynomial inequality (via library)
- **Key idea**: Cite `jones-trefoil-right.md` and `jones-figure-eight.md`;
  polynomials differ, done.
- **Difficulty**: trivially easy now (library-citation proof).
- **Geometric Content (Judge Axis 5)**: predicted **4/10** — uses an algebraic
  invariant without engaging geometric structure. Same as Round 0.
- **Prediction**: Route 1 wins on Completeness/Correctness/Verifiability but
  Geometric Content stays low.

### Route 2: Alexander polynomial
- **Key idea**: Burau for $B_2$ and $B_3$ with convention registry fixed.
- **Difficulty**: easy-medium. Fix to convention should unstick the $B_3$ case,
  but library has no Alexander-specific lemmas yet.
- **Geometric Content**: predicted **2/10** — pure algebra. No improvement.
- **Verdict**: still tertiary. Skip or run as redundancy check.

### Route 3: Hyperbolic-volume obstruction
- **Key idea**: $3_1$ is Seifert-fibered, $4_1$ is hyperbolic. Mostow + Gordon–Luecke.
- **Difficulty**: medium (same black-box references as Round 0).
- **Geometric Content (Judge Axis 5)**: predicted **9/10** — directly engages
  hyperbolic structure, ideal-tetrahedron triangulation, Seifert fibration.
- **Prediction**: with `judge_ldt.md`'s ×1.5 multiplier, Route 3's Geometric
  Content contributes $9 \times 1.5 = 13.5$ points. Route 1 contributes
  $4 \times 1.5 = 6$ points from Axis 5. The 7.5-point Axis-5 gap may be
  enough to flip the winner if Axes 1–4 are close.

### Route 4: Reidemeister direct
Still excluded (not viable as in Round 0).

## Predicted Judge outcome

- Route 1 Axes 1–4: ~19/30 (as Round 0), Axis 5: 6/15 → **25/55**.
- Route 3 Axes 1–4: ~17/30 (as Round 0), Axis 5: 13.5/15 → **30.5/55**.

**Prediction: Route 3 wins this time by about 5 points.** The collaborator
criterion is now driving the outcome.

## Recommendation

Run Routes 1 and 3 in parallel. Skip Route 2 unless redundancy needed (the
Burau-$B_3$ stuck-point from Round 0 was not fully closed, and Alexander
doesn't add much beyond what Jones proves). Use library lemmas in Route 1 to
keep it short; emphasize geometric structure in Route 3.
