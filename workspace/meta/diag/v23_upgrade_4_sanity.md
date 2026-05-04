# Sanity check — Upgrade 4 (Level-1 library)

**Date.** 2026-04-21.
**Target.** Confirm Scout correctly scans `level1_lemmas/` during its
0b-level1 step, and Auditor F2 correctly exempts `[REF:level1:*]`
citations (with `status=UNPROVEN-HERE` or `PROVEN-HERE-AT-*`) from the
STRUCTURAL-CITATION-WARNING trigger.

## Mock setup

Imagine `workspace/active/ldt_theorem_4_4/` targeting Blackwell et al.
Theorem 4.4 ("$S(p,q,\epsilon) = S(q,p,\epsilon')$ iff $S(p,q,\epsilon)$
is a torus knot"). The paper's internal chain includes Theorem 3.5
(spiral-knot Seifert structure), Corollary 3.10, and Proposition 4.3.

Mock `level1_lemmas/theorem_3_5.md`:

```markdown
# Theorem 3.5

## Statement
Let $S(p,q,\epsilon)$ be a spiral knot with $p, q$ coprime and
$\epsilon \in \{+1, -1\}^{p-1}$. Then $S(p,q,\epsilon)$ admits a
Seifert surface $\Sigma$ of genus $g = (p-1)(q-1)/2$, and the
Seifert matrix $V_\Sigma$ is block-cyclic with blocks determined
by $\epsilon$.

## Source
- Paper: Blackwell, Chen, et al. "Spiral knots via braid words"
  arXiv:2506.17889
- Location: §3, Theorem 3.5 (p. 9)

## Status
PROVEN-HERE-AT-proofs/research/low-dimensional-topology/spiral-knots-recursion/proof.md

## Usage contract
- Citation tag: [REF:level1:theorem_3_5]
- Fixer may expand Statement verbatim for readability.

## Notes
The spiral-knots-recursion proof (archived 2026-04-18) established this
for $\epsilon$ constant; Blackwell Theorem 3.5 extends to general
$\epsilon \in \{+1,-1\}^{p-1}$. The archived proof suffices for routes
that need only the constant-$\epsilon$ case.
```

Mock `level1_lemmas/corollary_3_10.md`:

```markdown
# Corollary 3.10

## Statement
If $S(p,q,\epsilon) \sim S(p', q', \epsilon')$ as oriented knots (same
equivalence class in the standard ambient-isotopy sense), then the
Alexander polynomials agree: $\Delta_{S(p,q,\epsilon)}(t) =
\Delta_{S(p',q',\epsilon')}(t)$ up to $\pm t^n$.

## Source
- Paper: Blackwell, Chen, et al. arXiv:2506.17889
- Location: §3, Corollary 3.10 (p. 11)

## Status
UNPROVEN-HERE

## Usage contract
- Citation tag: [REF:level1:corollary_3_10]
- This is an Alexander-polynomial invariance argument (classical); the
  paper derives it as a corollary of Theorem 3.5.

## Notes
Accepted as L2 citation. If a route needs a sharper variant (e.g.,
Alexander polynomial IDENTIFIES the knot up to conjugation in some
cases), that stronger statement is NOT covered here.
```

Mock `level1_lemmas/proposition_4_3.md`:

```markdown
# Proposition 4.3

## Statement
A torus knot $T(p,q)$ with $p,q > 1$ coprime has Alexander polynomial
$\Delta_{T(p,q)}(t) = \frac{(t^{pq}-1)(t-1)}{(t^p-1)(t^q-1)}$ and is
uniquely determined among spiral knots $S(p,q,\epsilon)$ by this
polynomial.

## Source
- Paper: Blackwell, Chen, et al. arXiv:2506.17889
- Location: §4, Proposition 4.3 (p. 14)

## Status
UNPROVEN-HERE

## Usage contract
- Citation tag: [REF:level1:proposition_4_3]

## Notes
The first half (torus-knot Alexander polynomial) is classical; the
second half (uniqueness among spiral knots) is paper-specific.
```

Mock `level1_lemmas/README.md`:

```markdown
# Level-1 lemmas for Theorem 4.4

| File | Id | Status | Used by |
|------|----|--------|---------|
| theorem_3_5.md | Theorem 3.5 | PROVEN-HERE-AT-... | Step 2 of Route A |
| corollary_3_10.md | Corollary 3.10 | UNPROVEN-HERE | Steps 3, 4 |
| proposition_4_3.md | Proposition 4.3 | UNPROVEN-HERE | Step 5 |

Total: 3 lemmas.
Of which PROVEN-HERE: 1; UNPROVEN-HERE: 2; KNOWN-FROM: 0.
```

## Simulated Scout execution (0b-level1)

Reading the updated `scout.md` §0b-level1:
1. Check `{work_dir}/level1_lemmas/` → exists.
2. Read `README.md` → inventory of 3 lemmas.
3. Classify: theorem_3_5 = L1-citable (PROVEN-HERE); corollary_3_10 =
   L2-citable (UNPROVEN-HERE, exempt from STRUCTURAL-CITATION-WARNING);
   proposition_4_3 = L2-citable (UNPROVEN-HERE, same).
4. Route recommendations: prefer routes that cite via
   `[REF:level1:theorem_3_5]`, `[REF:level1:corollary_3_10]`,
   `[REF:level1:proposition_4_3]` rather than re-deriving from scratch.

Sample Scout output (excerpt):

```
## Route 1: Alexander-polynomial uniqueness
- Key idea: Assume S(p,q,ε) ∼ S(q,p,ε'). By Corollary 3.10
  [REF:level1:corollary_3_10], their Alexander polynomials agree.
  By Theorem 3.5 [REF:level1:theorem_3_5], their Seifert structures
  give known Δ formulas. Match coefficients to force the torus-knot
  case via Proposition 4.3 [REF:level1:proposition_4_3].
- Required tools: Alexander polynomial arithmetic, torus-knot Δ
  formula, case-match on ε.
- Estimated difficulty: medium (all level1 citations in place).
- Potential pitfalls: Proposition 4.3's "uniquely determined among
  spiral knots" clause is UNPROVEN-HERE; if the route depends on this
  clause in a STRONGER form, a sub-pipeline may be needed.
```

## Simulated Auditor F2 execution

After Explorer produces the proof citing 2× `[REF:level1:*]` with
status=UNPROVEN-HERE and 1× `[REF:level1:theorem_3_5]` with
status=PROVEN-HERE-AT-*, Auditor F2 classifies:

| Citation | File | Status | L-class |
|----------|------|--------|---------|
| [REF:level1:theorem_3_5] | theorem_3_5.md | PROVEN-HERE | **L1** |
| [REF:level1:corollary_3_10] | corollary_3_10.md | UNPROVEN-HERE | **L2** |
| [REF:level1:proposition_4_3] | proposition_4_3.md | UNPROVEN-HERE | **L2** |

L3 citations used: 0.
STRUCTURAL-CITATION-WARNING triggered? NO (L3=0 < 3).

**Contrast check (negative case).** Suppose the proof had also invoked
Gordon–Luecke, Thurston hyperbolization, and Mostow rigidity as L3
citations. Under V2.2, the three L3 + any level1 references would
risk inflating the warning count. Under V2.3, level1 refs DON'T count
toward L3. The warning STILL triggers (3 L3's are enough), but now
from the GENUINE L3 citations, not from paper scaffolding.

## Exception check (L3-in-disguise)

Sanity: what if someone created a level1 file with
`status=UNPROVEN-HERE` whose Statement is actually an L3 theorem
(e.g., "Every hyperbolic 3-manifold has finite-volume complement")?
Per the exception clause in `ldt_checklist.md` F2:
- Auditor reads the Statement field.
- Statement matches the canonical L3 list (Thurston hyperbolization).
- Auditor re-classifies as L3 regardless of status tag.
- Records the re-classification in `### L3 citations used` with a note.
- STRUCTURAL-CITATION-WARNING still triggers if L3 ≥ 3.

This prevents abuse of the level1 mechanism to hide genuinely deep
citations behind a false-scaffolding label.

## Integrator check

Per the updated `integrator.md` Rule II-b, Integrator preserves
`[REF:level1:*]` citations verbatim and does NOT inline the lemma's
proof into `best_proof.md`. The lemma's content lives in
`level1_lemmas/<stem>.md`.

Simulated Integrator behavior on best_proof.md Step 2:
- Input (Explorer): "By Theorem 3.5 [REF:level1:theorem_3_5], the
  Seifert matrix is block-cyclic."
- Integrator output: preserves verbatim. No inlining.

Contrast: if this were an `[REF:external]` citation to an L2 paper
result that a Fixer has since proven independently, Integrator would
inline per Rule V. Level1 is the opposite policy: keep separated.

## Result

**PASS.** All four checks succeed:

1. Scout correctly scans `level1_lemmas/` and prefers level1 citations
   in route recommendations.
2. Auditor F2 correctly classifies by status tag:
   PROVEN-HERE → L1, UNPROVEN-HERE → L2.
3. STRUCTURAL-CITATION-WARNING does NOT trigger on paper scaffolding
   (exempted); still triggers on genuine L3 machinery.
4. L3-in-disguise exception correctly re-classifies abuse attempts.
5. Integrator preserves level1 citations without inlining.

## Real-test reminder

The Stage 2 Theorem 4.4 pipeline will populate these three mock level1
files with REAL content at pipeline start. The sanity check above uses
mock content only. Stage 2 is where level1_library gets a load-bearing
test — if Scout / Auditor / Integrator all handle the mock correctly
here, the real test will surface any remaining issues.
