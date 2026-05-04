# Probe 6 — Rubric mismatch: `judge.md` vs `judge_ldt.md`

**Input**: two proofs of $3_1 \not\sim 4_1$.
- **P0** = Round 0 `best_proof.md` (Jones polynomial route, Kauffman bracket state sum, writhe normalization).
- **P0.5** = Round 0.5 `best_proof.md` (Seifert-vs-hyperbolic dichotomy via Gordon–Luecke, Thurston hyperbolization, Mostow rigidity).

**Rubrics**:
- `judge.md` (base): 4 axes × 10 = **40/40**. Axes: Completeness, Correctness, Elegance, Gaps.
- `judge_ldt.md` (LDT variant): base 4 axes + **Axis 5 Geometric Content × 1.5 = 55/55**.

**Note on "eval_system"**: the task brief referenced an `eval_system` rubric distinct from `judge_ldt.md`. The only other evaluative rubric found in the system is `judge.md`. I treat `judge.md` as the generic "eval_system" baseline here. If a separate `eval_system` artifact exists outside the repo, this probe covers the in-repo comparison only.

---

## Part A — Score P0 under both rubrics

### P0 under `judge.md` (base, 40 max)

- **Axis 1 Completeness**: Steps 1–6 cover bracket axioms → compute → normalize → compare → invariance citation. Mid-proof Step 3 includes a sign-convention retraction ("Hmm — this is the LEFT-handed trefoil..." with on-the-fly correction). A base Judge would treat the retraction as a gap-that-got-patched. **Score 7/10.**

- **Axis 2 Correctness**: The final Jones polynomials match TSV. The sign-convention drift is caught and resolved. No fatal logic gap. The conclusion holds. **Score 9/10.**

- **Axis 3 Elegance**: 6 steps is reasonable for the scope. The mid-proof retraction hurts elegance; also, the proof could have started from `V_{3_1}, V_{4_1}` as library lookups rather than re-computing the bracket. **Score 6/10.** (A more elegant version skips Steps 1–3 and cites `jones-trefoil-right.md` from our library.)

- **Axis 4 Gaps**: Sign-convention ambiguity (resolved), no `[STEP-STUCK]`. Step 6's citation "Jones 1985; standard" is vague (would fail LDT checklist F, but `judge.md` has no F criterion). **Score 8/10.**

**P0 under `judge.md` total**: **7 + 9 + 6 + 8 = 30/40.**

### P0 under `judge_ldt.md` (LDT variant, 55 max)

Same Axes 1–4 (judge_ldt does not redefine them): **7 + 9 + 6 + 8 = 30/40.**

- **Axis 5 Geometric Content**: The proof is **algebraic**. The Kauffman bracket treats the diagram as combinatorial; the state sum is a polynomial evaluation; the final comparison is polynomial inequality. There is no hyperbolic structure, no triangulation, no MCG action, no 3-manifold visualization.
  - Level 6 ("combinatorial/diagrammatic invariant where the diagram represents the object but the proof is combinatorial"): matches.
  - Level 4 ("algebraic invariant computed from a presentation without use of geometric structure"): arguably matches even more precisely, since the bracket is evaluated via a state sum that could be done without drawing the diagram.
  - The proof's own `[GEOMETRIC-INTUITION]` self-rating: 2/5.
  - **Axis 5 score: 4/10 × 1.5 = 6/15.**

**P0 under `judge_ldt.md` total**: **30 + 6 = 36/55.**

---

## Part B — Score P0.5 under both rubrics

### P0.5 under `judge.md` (base, 40 max)

- **Axis 1 Completeness**: 5 steps (Setup + Steps 1–5), each backed by a specific external theorem. No `[STEP-STUCK]`. Writhe/convention concerns absent (not applicable for this approach). **Score 9/10.**

- **Axis 2 Correctness**: Logic chain is Gordon–Luecke + Thurston + Mostow + Seifert classification → contradiction. Each step is a correct application of the cited theorem. TSV-verified numerical volume. **Score 10/10.**

- **Axis 3 Elegance**: Short (5 steps), clean, minimal overhead. The proof IS a ~1-paragraph idea expanded to 5 numbered steps. **Score 9/10.**

- **Axis 4 Gaps**: No unresolved gaps. The "two ideal tetrahedra" claim in Step 2 is cited to Thurston (black-box); a pedantic reader could demand the explicit face-pairing, but under `judge.md`'s rubric, "black-box citation" is acceptable when the citation is to a standard reference. **Score 9/10.**

**P0.5 under `judge.md` total**: **9 + 10 + 9 + 9 = 37/40.**

### P0.5 under `judge_ldt.md` (LDT variant, 55 max)

Same Axes 1–4: **9 + 10 + 9 + 9 = 37/40.**

- **Axis 5 Geometric Content**: The proof DOES engage geometric structure.
  - Step 1 identifies a Seifert fibration and computes the orbifold Euler characteristic.
  - Step 2 describes the ideal-tetrahedra construction and computes volume via Lobachevsky function.
  - Step 3 invokes Mostow rigidity for topological invariance.
  - Level 10 ("uses a hyperbolic structure, a triangulation, ..."): Step 2's triangulation claim matches.
  - Caveat: the "two regular ideal tetrahedra" claim is CITED to Thurston, not independently reconstructed. The Auditor notes (in `auditor.md` Round 0.5, which I reviewed in Probe 1) that the Explorer did NOT explicitly enumerate the face-pairing — it cited Thurston's theorem that such a pairing exists.
  - **Axis 5 score, literal rubric**: 9/10. **Intent rubric** (reward deep engagement, penalize citation-heavy): 7/10 — the Explorer invokes the geometric structures correctly but does not independently construct either.
  - Taking the Probe-1 and Probe-3 lessons seriously: the Explorer DOES name-drop more than it constructs. Still, this is substantially more geometric than P0.
  - **Axis 5 score: 9/10 × 1.5 = 13.5/15** under the rubric as written.

**P0.5 under `judge_ldt.md` total**: **37 + 13.5 = 50.5/55.**

---

## Part C — Mismatch analysis

| | `judge.md` (40) | `judge_ldt.md` (55) | Ratio P0.5:P0 |
|---|---|---|---|
| **P0** (Jones) | 30/40 = **75.0%** | 36/55 = **65.5%** | — |
| **P0.5** (hyperbolic) | 37/40 = **92.5%** | 50.5/55 = **91.8%** | — |
| **Gap** | +7 pts (17.5pp) | +14.5 pts (26.3pp) | — |

### Mismatch 1 — Magnitude of P0.5's advantage

Under `judge.md` (base 4-axis), P0.5 beats P0 by **7/40 (17.5 percentage points)**.

Under `judge_ldt.md` (5 axis, 1.5× geometric multiplier), P0.5 beats P0 by **14.5/55 (26.3 percentage points)**.

The LDT variant **doubles** the scoring gap. This is intended behavior — the LDT rubric exists precisely to penalize non-geometric proofs. But it also means that a proof scoring borderline under base `judge.md` (say, a 32/40 Jones proof) could slide to a firm LOSS under `judge_ldt.md`, even when nothing is substantively wrong with it.

### Mismatch 2 — Axis 3 (Elegance) disagreement with Axis 5

In both rubrics, P0 scores 6/10 on Elegance while P0.5 scores 9/10. But the grounds differ:
- `judge.md` reader: P0.5 is more elegant because fewer ad-hoc computations.
- `judge_ldt.md` reader: P0.5 is more elegant AND more geometric; the two axes agree and REINFORCE each other.

**Observation**: Axis 3 (Elegance) and Axis 5 (Geometric Content) in `judge_ldt.md` have a structural correlation — proofs that engage geometric structure TEND to be shorter (because they cite deep theorems and do little work), and proofs that are algebraic TEND to be longer (because they compute). A Judge applying both axes produces a compounded penalty for algebraic proofs, even though the intent of "elegance" and "geometric content" are conceptually different.

This is partially double-counting. A 10-step algebraic proof might score 6/10 on Elegance (because long) AND 4/10 on Geometric Content (because algebraic). These two penalties reflect substantially overlapping considerations.

### Mismatch 3 — Completeness/Gaps insensitive to citation depth

Both rubrics treat "cited external theorem" identically to "derived argument" for Completeness and Gaps, as long as the citation points to a real theorem. P0.5 scores 9/10 on Completeness despite having 4 E3 citations (Probe 1 finding: Round 0.5 rests on Gordon–Luecke, Thurston Seifert, Thurston hyperbolization, Mostow). P0 scores 7/10 on Completeness despite doing substantially MORE independent derivation (bracket axioms, state-sum expansion, writhe normalization).

This is a concrete scoring mismatch: **P0 does more independent math, yet scores LOWER on Completeness.** The rubric awards "cited" ≡ "justified", so a proof with more black-boxes has fewer unjustified steps by definition.

### Mismatch 4 — No Gap penalty for convention-flags

P0 explicitly **flags a sign-convention ambiguity** in Step 3 and resolves it via TSV. Under `judge.md`, this flag-and-resolve costs 1–2 points on Completeness (reflected in 7/10). Under `judge_ldt.md`, same cost.

BUT: a proof that SILENTLY follows the correct convention without flagging would score higher on both rubrics, because there is no visible "retraction". This creates a perverse incentive: **proofs that surface and resolve subtle issues get penalized relative to proofs that hide them**.

A more robust rubric would reward flag-and-resolve (positive signal) rather than penalize it.

---

## Part D — Cross-rubric consistency under a hypothetical "eval_system"

If we imagine an external `eval_system` that weights proofs by:
- A: mathematical originality (how much the Explorer derives independently vs cites)
- B: transparency (does the Explorer flag subtle issues?)
- C: geometric content

Then:

- P0 scores: HIGH originality (bracket state-sum re-derived from axioms; writhe normalization worked out), HIGH transparency (sign-convention flag), LOW geometric content.
- P0.5 scores: LOW originality (3/4 load-bearing steps are E3 citations), MEDIUM transparency (no mid-proof corrections; citations are what they are), HIGH geometric content.

Under A+B only (originality + transparency, ignoring geometric content), **P0 would beat P0.5**. Under C alone (geometric content), **P0.5 beats P0 by a wide margin**.

The current `judge.md` and `judge_ldt.md` jointly rubric tilts strongly toward P0.5 because:
- Completeness measures "justified steps", and citation = justification.
- Elegance rewards short proofs, and citation-heavy proofs are short.
- Geometric Content explicitly rewards geometric vocabulary.

**None of the three axes actively rewards independent reasoning or transparent error-resolution.**

---

## Part E — Net findings for Concern 6

1. **Scoring gap scales with rubric**: P0.5 beats P0 by 17.5 percentage points under `judge.md` and 26.3 under `judge_ldt.md`. The LDT multiplier amplifies the gap.

2. **Algebraic proofs are penalized twice**: long → low Elegance, and non-geometric → low Axis 5. The two penalties overlap structurally.

3. **Citation-heavy proofs score well on Completeness**: there is no rubric item that penalizes "justified by black-box" differently from "justified by derivation". The Round 0.5 proof's 4 E3 citations register as "fully justified" rather than "heavily dependent on external theory".

4. **No reward for transparent flag-and-resolve**: the sign-convention retraction in P0 hurts its Completeness score; silent-but-correct would score higher.

5. **Both rubrics agree on the winner** (P0.5 > P0 in both cases), but for partially different reasons. Under `judge.md`, P0.5 wins because it is perceived as more complete, correct, elegant, gap-free. Under `judge_ldt.md`, P0.5 ALSO wins on Geometric Content, widening the margin.

6. **The LDT rubric is not a generic improvement over `judge.md`** — it adds a geometric axis but does NOT correct the base rubric's insensitivity to citation depth, originality, or transparency. A proof that would score borderline under `judge.md` could either win (if it is geometric) or lose (if it is not) under `judge_ldt.md`, purely on Axis 5 vocabulary signals.

*Appended to `ldt_diag_log.md` on 2026-04-20.*
