# LDT v2.1 — Post-Fix Summary

**Date**: 2026-04-20
**Input diagnostic**: `workspace/diag/ldt_v2_1_diagnostic_report.md` (six probes)
**Scope of this document**: summarize what was fixed in response to the
diagnostic, what the fixes actually changed, what was intentionally NOT
addressed, and what the fix process itself revealed about the system.

---

## What changed

### Fix 1 (P0) — Kauffman-bracket convention bug

**File touched**: `~/.claude/skills/math-verifier/tsv/tsv_knot.py`

- Root cause: `kauffman_bracket` substituted `q = A^{-4}` into a Jones
  polynomial stored in the q-convention (Convention B, $q = t^{-1}$),
  silently producing the wrong bracket with `confidence=high`.
- Fix: one-character change, `_A**(-4)` → `_A**4`, after hand-verification
  against Kauffman 1987's trefoil and Lickorish's figure-eight.
- Every public function (`jones_polynomial`, `alexander_polynomial`,
  `kauffman_bracket`, `check_reidemeister_equivalent`,
  `hyperbolic_volume`, `lookup_knotinfo`) now has an explicit
  **Convention Contract** docstring with a worked example.
- Latent `_resolve_name` bug fixed: `"unknot".replace("knot","")` → `"un"`
  previously caused `jones_polynomial("unknot")` to return out-of-scope.
- `__main__` is now an assert-based self-test with 60 named assertions.
  `python tsv_knot.py` exits 0 only if every convention and normalization
  is correct.
- New sidecar: `tsv_convention_audit.md` (per-function contract + worked
  right-trefoil derivation + historical note on the bug).
- Logged in `workspace/failure_patterns.md` as FP-KAUFFMAN-CONVENTION-2026-04-20.

### Fix 2 (P1) — L1/L2/L3 citation classification + STRUCTURAL-CITATION-WARNING

**Files touched**:
- `~/.claude/skills/math-auditor/ldt_checklist.md` — new item **F2**.
- `~/.claude/skills/math-proof-agent/prompts/auditor.md` — pointer.

- L1 = 30-second-verifiable lemma lookup (KnotInfo values, textbook axioms).
- L2 = single theorem from a single paper (Alexander 1923, Markov 1935,
  Bennequin, Birman–Hilden, Seifert's classification).
- L3 = deep research-program machinery.
  Canonical LDT L3 seed list: Thurston hyperbolization, Mostow, Gordon–Luecke,
  Agol, Wise, Masur–Minsky curve-complex machinery, Mirzakhani, Kirby,
  Heegaard Floer, Khovanov/Rasmussen, 8-geometry classification,
  Eskin–Mirzakhani–Mohammadi.
- Auditor procedure: tag every `[REF:external]`, list L3s in a new
  sub-section, count Independent steps.
- **STRUCTURAL-CITATION-WARNING** triggers when ≥3 L3 citations AND
  <3 Independent steps. Warning is additive, not vetoing: a PASS verdict
  can still issue, but the warning is recorded.

### Fix 3 (P1) — Axis 5 rewritten with Evidence Field

**File touched**: `~/.claude/skills/math-proof-agent/prompts/judge_ldt.md`.

- Axis 5 levels redefined around **geometric WORK, not vocabulary**.
- Scores > 6/10 require an **Evidence Field**:
  (1) which numbered step performs the geometric operation,
  (2) what specific operation (not "invokes X"),
  (3) removal test (if replacing the step with a citation leaves the
      proof intact, cap at 6/10).
- Cap at **6/10** if Evidence Field cannot be filled, regardless of
  vocabulary. Judge annotates `[VOCAB-CAP applied]` when lowering a
  naive score.
- `[WARN: VOCABULARY-BLUFF]` emitted when vocabulary suggested ≥8 but
  Evidence failed.

---

## Before / after numerical scores

Using the two benchmark proofs from Probe 6:

| | judge.md (40) | judge_ldt.md PRE-fix (55) | judge_ldt.md POST-fix (55) |
|---|---|---|---|
| **P0** (Round 0 Jones)     | 30/40 = 75.0% | 36/55 = 65.5%   | 36/55 = 65.5% (unchanged) |
| **P0.5** (Round 0.5 hyper) | 37/40 = 92.5% | 50.5/55 = 91.8% | 46/55 = 83.6% |
| **Gap P0.5 − P0**          | +7 pts / 17.5pp | +14.5 / 26.3pp | **+10 / 18.2pp** |

P0 unchanged: it was already scoring 4/10 on Axis 5 (legitimately algebraic);
the Evidence-Field mechanism does not penalize honest algebra.

P0.5 drops 4.5 Axis-5 points (9/10 → 6/10), because the Evidence Field
check reveals that Step 2's "two ideal tetrahedra" claim is delivered by
citation to Thurston, not by exhibiting the face-pairing. The drop is
appropriate: the rubric now signals that the proof is citation-organization,
not geometric-construction.

P0.5 still wins, by an appropriate margin. The gap narrows from 26.3pp
to 18.2pp, which is closer to the 17.5pp baseline under the non-LDT
`judge.md` rubric.

### Probe 2 re-audit with L3 classification

Probe 2's synthetic citation-heavy proof (10 steps, 8 E3 citations, 0
independent steps) now produces:

- V2 Auditor verdict: **PASS** (every cited theorem is correctly applied).
- LDT checklist F2 verdict: **WARN** — L3=7, Independent=0.
- Final verdict: **PASS + STRUCTURAL-CITATION-WARNING**.

The warning correctly identifies that the proof's logical skeleton rests
entirely on external machinery (Perelman, Gordon–Luecke, Thurston,
Mostow, Waldhausen, Agol, Wise). Three citations (Agol, Wise, Waldhausen)
are flagged as decorative (not used downstream).

### Probe 3 re-score with Evidence Field

Probe 3's bluff proof (Teichmüller prologue + Alexander-determinant
middle + Teichmüller-length epilogue):

- Pre-fix Axis 5: 8–9/10 → 12–13.5/15.
- Post-fix Axis 5: **6/10 → 9/15 (capped)** + `[WARN: VOCABULARY-BLUFF]`.
- The rubric now refuses to reward geometric vocabulary that isn't
  anchored to a geometric operation.

---

## What is STILL not fixed (intentionally or as residue)

### From the original diagnostic, not addressed in this pass

1. **Judge.md base rubric's citation-insensitivity** (finding 6, point 3).
   `judge.md`'s Completeness axis treats "cited external theorem" and
   "derived argument" identically. The L1/L2/L3 classification lives
   only inside the LDT checklist; it doesn't propagate into the Judge's
   Completeness score. A citation-heavy proof still scores high on
   Completeness under `judge.md`.

2. **No reward for transparent flag-and-resolve** (finding 6, point 4).
   P0's sign-convention retraction still costs it points on Completeness
   under both rubrics. A proof that silently follows the correct
   convention scores higher than a proof that flags-and-resolves. Not
   addressed.

3. **Axis 3 / Axis 5 double-count for algebraic proofs** (finding 6,
   point 2). Algebraic proofs tend to be long (low Elegance) AND
   non-geometric (low Axis 5). Fix 3 does not fix the double-count;
   it only prevents the geometric-vocabulary inflation at the top.

4. **Scout-phase citation quota** (finding 2 limitation). Fixes 1–3 are
   all Judge-/Auditor-side. No mechanism pushes Explorers toward
   independent derivations during the Explorer phase. A Scout that
   rewards "derives X without citing Y when Y is L3" would be a
   preventive measure; none implemented.

5. **Axis 5's 1.5× multiplier is unchanged**. The multiplier amplifies
   the swing of whatever Axis 5 scores; Fix 3 caps the top of Axis 5
   but leaves the multiplier intact. A structurally safer fix might
   drop the multiplier to 1.0 with a compensating redefinition.

### Fix-specific residual issues

**Fix 1 residue**:
- Generic-diagram / generic-braid Kauffman bracket remains out-of-scope
  (returns `(None, low-confidence)` for unknown inputs). This is
  correct behavior, not a bug, but it limits TSV's coverage.
- `tsv_simplicial.py` and `tsv_group.py` were NOT audited for convention
  correctness in this pass. The Kauffman convention bug was discovered
  by coincidence (Probe 5 executed 10 calls); similar bugs in the other
  TSV modules would not have been caught.

**Fix 2 residue**:
- The STRUCTURAL-CITATION-WARNING is retrospective — it fires after
  the proof exists. No mechanism encourages Explorers to prefer
  derivations over citations during the Explorer phase.
- L3 classification is boundary-sensitive (Seifert's classification:
  L2 or L3?). Judge-dependent.
- "Independent step" counting is coarse; it doesn't distinguish a
  one-line arithmetic step from a multi-page derivation.
- Canonical L3 lists exist only for LDT. Non-LDT domains (optimization,
  learning theory, etc.) would need their own L3 lists for the
  mechanism to apply outside LDT.

**Fix 3 residue**:
- The 6/10 cap is binary — one decorative vocabulary sentence and 10
  decorative pages both land at 6/10. No "vocabulary-abuse density"
  metric.
- Judgment boundary between "orbifold arithmetic is a geometric
  operation" and "orbifold arithmetic is notation" is Judge-dependent.
- No transparency bonus for Explorers that tag citations honestly.

---

## New issues surfaced by the fix process

### 1. `_resolve_name` had a latent aliasing bug

While writing the Fix 1 self-test, a pre-existing bug surfaced:
`"unknot".replace("knot","")` → `"un"`, which meant that
`jones_polynomial("unknot")` returned `(None, confidence=low)` as
"out-of-TSV-scope". This bug had nothing to do with conventions —
it's a string-manipulation bug — but it had never triggered because
every call site used aliases like `"0_1"` or `"trivial knot"` instead.

Fixed as part of Fix 1. Lesson: the print-only self-test didn't
exercise the canonical name, only the aliases. Assert-based self-tests
forced every entry in the table through every public function.

### 2. Probe 4's PASS was earned in simulation, not in a real pipeline

Probe 5 discovered the Kauffman convention bug; retroactively, Probe 4's
Explorer Step 8 ("TSV confirms $B_3 = -A^5 - A^{-3} + A^{-7}$") could
NOT have happened against the pre-fix TSV, because the pre-fix TSV
returned $A^{25} - A^{21} - A^{13}$. The Probe 4 PASS was therefore
recorded as "earned under simulation" rather than as a true validation
of the pipeline. With Fix 1 in place, a re-run of the Probe 4 scenario
would now produce an honest PASS (the math was always correct; only
the TSV cross-check was lying).

Recorded in `workspace/diag/c4_fixer_loop_log.md` as a "RETROACTIVE
CORRECTION" note. Does NOT invalidate Fix 1 — on the contrary, it
motivates why Fix 1 matters.

### 3. The L3 canonical list is a live document

Writing out the L3 seed list for LDT revealed that the grade boundary
between L2 and L3 is often a matter of field-maturity. "Seifert
fibrations, classification" was L3 in 1950, is L2 now. "Masur–Minsky
subsurface projections" is currently L3, but if a good textbook
exposition appears, it could slide to L2. The list needs periodic
review, not just initial seeding.

### 4. Evidence Field creates a new Judge-Explorer interaction

Under Fix 3, the Judge's Evidence Field check effectively asks
"could this proof have been written without the geometric content?" —
which is a counterfactual. Explorers that want to score above 6/10 on
Axis 5 are now incentivized to write steps whose geometric content is
*structurally load-bearing*, not decorative. This could push Explorers
toward more construction-heavy proofs (good outcome) OR toward more
elaborate justification that their citation IS geometrically
load-bearing (orthogonal outcome that may not help). To be watched in
future rounds.

---

## Files that did NOT change (deliberately)

Per the task brief's explicit rules:

- `workspace/agent_architecture_v2.md` — not modified.
- `proofs/` — no proof files modified.
- `workspace/diag/` — no pre-existing diag files overwritten; all new
  artifacts written as new files (`c2_audit_with_l3_classification.md`,
  `c3_axis5_with_evidence_field.md`,
  `round0_5_axis5_with_evidence_field.md`,
  `ldt_v2_1_post_fix_summary.md`).

The diagnostic report itself (`workspace/diag/ldt_v2_1_diagnostic_report.md`)
is preserved unchanged; this summary is a separate artifact that
references it.

---

## Summary in one paragraph

Three fixes landed: a silent convention bug in TSV's Kauffman bracket
is fixed (Fix 1, one-character change plus a test harness that guards
against regression), a citation-depth classifier is added to the LDT
Auditor to surface proofs that lean heavily on deep external machinery
(Fix 2, L1/L2/L3 + structural warning), and Axis 5 of the LDT Judge is
rewritten to reward geometric work rather than geometric vocabulary
(Fix 3, Evidence Field + 6/10 cap). The P0.5 hyperbolic proof drops from
50.5/55 to 46/55 under the post-fix rubric, and the gap between P0 and
P0.5 narrows from 14.5 to 10 points — a correction, not an inversion.
Four classes of issues remain, including the Judge's base-rubric
citation-insensitivity, no reward for transparent flag-and-resolve, and
the absence of a canonical L3 list outside LDT; these are listed as
follow-up work. `python tsv_knot.py` exits 0, so Fix 1's regression
guard is in place; Fixes 2 and 3 do not have executable tests and will
need to be re-validated against a live V2 pipeline run.

*Saved 2026-04-20. Closes the post-fix loop opened by
`workspace/diag/ldt_v2_1_diagnostic_report.md`.*
