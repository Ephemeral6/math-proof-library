# Probe 3 re-scoring — Axis 5 with Evidence Field (Fix 3)

**Input**: `workspace/diag/c3_vocabulary_bluff_proof.md` (the vocabulary-bluff
"proof" of $3_1 \not\sim 4_1$: Teichmüller prologue + Alexander-determinant
middle + Teichmüller-length epilogue).

**Rubric applied**: `~/.claude/skills/math-proof-agent/prompts/judge_ldt.md`
(post-Fix-3 version with Evidence Field requirement).

**Pre-fix Probe 3 score on Axis 5**: 12–13.5 / 15 (the proof's heavy
geometric vocabulary inflated it against a rubric that didn't distinguish
vocabulary from operation).

**Expected post-fix score**: ≤ 6/10 → ≤ 9/15, with `[WARN: VOCABULARY-BLUFF]`.

---

## Evidence Field evaluation

Going through the proof's claimed geometric steps:

### Candidate 1: Setup paragraph (Teichmüller / MCG / Masur–Minsky)

- **Load-bearing step?** No — the Setup paragraph is never referenced by
  any downstream step. Removing it leaves the proof intact.
- Not a candidate for Evidence.

### Candidate 2: Step 1 (invariant train track + matrices)

- **Load-bearing step?** No. The matrices asserted in Step 1 are never
  used in Steps 2–4. The diagnostic meta-note even points out that the
  matrix for $4_1$ is gibberish (contains $\mathrm{diag}(1,-1)$ which is
  not in $\mathrm{PSL}_2(\mathbb Z)$). Step 2 pivots to Alexander
  polynomials without referencing the matrices.
- **Operation performed?** None verifiable — the matrices are asserted,
  not derived, and Step 1 performs no check that they carry the claimed
  monodromies. The "operation" exists only in the vocabulary.
- **If removed?** YES, proof still goes through: Steps 2 (Alexander lookup)
  → 3 (determinant arithmetic) → 4 (conclude) are self-contained without
  any train-track content.

### Candidate 3: Step 2 (Birman–Hilden reduction to Alexander)

- **Load-bearing step?** Only as a pivot from fake-geometric to real-algebraic.
  The Birman–Hilden citation is loose and the Alexander polynomials it
  "reduces to" are table-lookup values.
- **Operation performed?** Invokes a theorem name and writes down two
  polynomials. No geometric operation.
- **If removed?** YES — the polynomials can be cited directly.

### Candidate 4: Step 3 (determinant computation)

- Algebraic operation on $\Delta(-1)$. Not geometric.
- Axis-5 grade: this is the COMBINATORIAL/ALGEBRAIC core.

### Candidate 5: Step 5 (Teichmüller-length epilogue)

- **Load-bearing step?** No — Step 5 is after the conclusion is already
  stated. It's post-hoc re-dressing.
- **Operation performed?** None; the "Teichmüller-length ratio $\log 3/\log 5$"
  is not a defined quantity (meta-note confirms).
- **If removed?** YES, proof concludes at Step 4.

### Evidence Field verdict

**No step fills the Evidence Field.** No load-bearing geometric step
exists; every use of geometric vocabulary is either decorative (Setup,
Step 5), unverified (Step 1), or a thin citation-pivot (Step 2).

Per the Fix 3 rubric: **score capped at 6/10**.

---

## Post-fix Axis 5 score

```
Geometric Content: 6/10 × 1.5 = 9/15   [VOCAB-CAP applied]
Evidence:
  - Load-bearing step: none
  - Operation: no geometric operation performed; the setup paragraph,
    Step 1 train-track matrices, and Step 5 Teichmüller-length coda
    are all post-hoc vocabulary. The only operations performed
    (Step 3 arithmetic on Alexander polynomials) are algebraic.
  - If removed (of all geometric vocabulary): YES, proof still works —
    the argument reduces to "Δ(-1) for 3_1 and 4_1 disagree, so the
    knots disagree", a 3-step purely algebraic argument.
```

Axis 5: **6/10 → 9/15**. Total (other axes unchanged from Probe 3's
pre-fix scoring): approximately **42–43/55**, down from the pre-fix
12–13.5/15 Axis-5 contribution yielding ~46/55.

Notes line: `[WARN: VOCABULARY-BLUFF]` — the proof's surface geometric
vocabulary is not matched by load-bearing geometric operations.

---

## Expected-vs-observed check

Task brief's expected behavior for Probe 3 post-fix:
- Axis 5 ≤ 6/10 ✓ (score: 6/10, hit the cap).
- `[WARN: VOCABULARY-BLUFF]` emitted ✓.

Outcome matches. The rubric now correctly refuses to reward geometric
vocabulary that is not anchored to a geometric operation.

---

## Comparison: pre-fix vs post-fix on the same proof

| Component | Pre-fix Axis 5 | Post-fix Axis 5 |
|-----------|----------------|-----------------|
| Vocabulary signal (Teichmüller, MCG, Masur–Minsky) | Pushed score to Level 8–9 | Ignored until Evidence Field check |
| Evidence Field check | (did not exist) | No load-bearing geometric step found |
| Score | 8–9 / 10 = 12–13.5 / 15 | 6 / 10 = 9 / 15 (capped) |
| Diagnostic | none | [VOCAB-CAP applied] + [WARN: VOCABULARY-BLUFF] |

The post-fix rubric lowers the Axis 5 score by 3–4.5 points and flags
the bluff in the Notes. The total proof score drops by the same amount,
which is load-bearing when the proof is close to another route.

---

## Limitation noted

The Evidence Field cap does not penalize **how much** vocabulary is
bluffed — a proof with 1 decorative Teichmüller sentence and a proof
with 10 decorative pages both land at exactly 6/10. This is intentional
(the cap is binary: vocab-without-operation ⇒ ≤6), but it means a
medium-bluff proof is scored identically to a max-bluff proof. If the
collaborator cares about the quantity of vocabulary abuse (not just the
ceiling), a secondary "vocabulary-abuse density" metric could be added
in a future fix. Noted, not addressed here.

*Saved 2026-04-20. Artifact for Fix 3 of the V2.1 LDT diagnostic repair.*
