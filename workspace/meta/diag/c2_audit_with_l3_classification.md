# Probe 2 re-audit — L1/L2/L3 citation classification applied

**Input**: `workspace/diag/c2_synthetic_citation_proof.md` (the maximally
citation-heavy synthetic proof of $3_1 \not\sim 4_1$, 10 steps, 8 distinct
`[REF:external]` citations).

**Rubric applied**: `~/.claude/skills/math-auditor/ldt_checklist.md` (post-Fix-2
version with item **F2 — Citation-depth classification**).

**Goal**: confirm that the new F2 classifier correctly identifies this
proof as high-L3 / low-Independent-steps and emits the
STRUCTURAL-CITATION-WARNING without vetoing the underlying PASS that the
V2 Auditor would issue for a logically correct argument.

---

## V2 Auditor verdict (pre-F2, recomputed for baseline)

Every step is a citation to a real, correctly applied theorem; the chain
of implications is valid; the conclusion holds. The V2 Auditor marks every
step `VALID`, and under the old `ldt_checklist.md` (items A–H without F2)
the proof receives **PASS** with the caveats already recorded in Probe 2
(Item F flags the vague-phrase-within-citations issue only weakly).

**Verdict (baseline): PASS.** Numerical verification vacuously satisfied
(no polynomial computations). Judge score (under pre-fix `judge_ldt.md`):
~46/55.

---

## Citation-depth classification (F2)

Going through every `[REF:external]` in order:

| Step | Citation | Depth | Justification |
|------|----------|-------|---------------|
| 1 | Waldhausen 1968, *On irreducible 3-manifolds...* | **L3** | Canonical rigidity theorem whose proof is a research-level monograph; the hierarchical sutured-manifold / Haken ladder machinery is itself a deep program. Appears in the canonical list under its derivatives (Thurston's hyperbolization uses Waldhausen). |
| 2 | Perelman 2002–2003 + Kleiner–Lott 2008 | **L3** | Perelman's proof of geometrization; the entirety of 3-manifold classification downstream rests on it. Explicitly on the canonical L3 list as "Thurston's 8-geometry classification (Perelman)". |
| 3 | Agol, *Virtual Haken conjecture*, 2013 | **L3** | Explicitly on the canonical L3 list. |
| 4 | Wise, *Structure of groups with quasi-convex hierarchy*, 2012 | **L3** | Explicitly on the canonical L3 list. |
| 5 | Gordon–Luecke 1989 | **L3** | Explicitly on the canonical L3 list. |
| 6 | Thurston hyperbolization, 1979–1982 | **L3** | Explicitly on the canonical L3 list. |
| 7 | Mostow rigidity, 1968 | **L3** | Explicitly on the canonical L3 list. |
| 8 | Seifert 1933, Seifert fibrations classification | **L2** | Single-theorem classification of Seifert-fibered spaces from one 1933 paper; verifiable from Seifert–Threlfall textbook. On the borderline but graded L2 because the underlying invariants (base orbifold, Euler number) are single-textbook objects. |

**Independent steps**: tallying steps that are `[IND]` or have no external
citation. Steps 9 and 10 are combinatorial assembly of the cited claims;
they are `[REF:internal]` (pointing back at Steps 1–8). The Explorer
contributes zero independent argument beyond "combine cited facts". So
$N_{\text{Ind}} = 0$.

**L3 count**: $N_{L3} = 7$ (Steps 1–7).

---

## STRUCTURAL-CITATION-WARNING trigger check

Trigger rule from F2: **≥3 L3 citations AND <3 Independent steps**.

- L3 count: $7 \geq 3$ ✓
- Independent step count: $0 < 3$ ✓

**Warning fires.**

---

## Post-F2 audit output

```
## Audit Report (V2)

Verdict: PASS (logic chain is valid; every cited theorem is correctly applied)

Step 1: VALID (cites Waldhausen appropriately)
Step 2: VALID (Perelman applicable to both complements)
Step 3: VALID (Agol applicable to hyperbolic cover of M_{4_1}) [NOTE: not used downstream]
Step 4: VALID (Wise applies to cusped hyperbolic 3-mflds) [NOTE: not used downstream]
Step 5: VALID (Gordon–Luecke is the key reduction to complement-homeomorphism)
Step 6: VALID (Thurston hyperbolization)
Step 7: VALID (Mostow rigidity, correctly applied)
Step 8: VALID (Seifert fibration classification)
Step 9: VALID (3_1 torus => Seifert; 4_1 hyperbolic => not Seifert)
Step 10: VALID (conclusion follows from Perelman + Gordon–Luecke)

## LDT-Specific Audit

| Item | Verdict | Note |
|------|---------|------|
| A. Isotopy vs. equivalence   | OK      | "$\sim$" consistently means ambient isotopy throughout |
| B. Orientation               | OK      | orientation fixed at setup; not used in any invariant argument |
| C. Dimension                 | OK      | 3-dim throughout; no slice/ribbon confusion |
| D. Compactness / infinitude  | N/A     | no compactness argument invoked |
| E. Group presentation        | N/A     | no MCG presentations used |
| F. Literature cross-check    | OK      | constants not invoked; citations point to specific papers |
| F2. Citation-depth (L1/L2/L3)| WARN    | L3=7, L2=1, L1=0, Independent=0 — see warning below |
| G. Picture-proof handling    | OK      | no picture arguments; 0 `[PICTURE-ARGUMENT]` tags |

### Geometric Intuition Assessment
Score: 2/5
Rationale: The proof uses geometric vocabulary (hyperbolic, Seifert, orbifold,
Haken) but does not construct or engage any specific geometric object. The
proof would read identically to a reader who knew no hyperbolic geometry
beyond "there is such a thing as a hyperbolic 3-manifold". No volume
computed, no fundamental group generators examined, no cusp cross-section
described.

### L3 citations used

- Waldhausen 1968 (rigidity of Haken 3-manifolds) — invoked in Step 1 but
  NOT load-bearing for the final conclusion; the Gordon–Luecke + Thurston +
  Seifert chain suffices without it.
- Perelman 2002 geometrization — invoked Step 2; partially redundant with
  Thurston hyperbolization (Step 6) for the specific knots in question,
  but formally load-bearing as the "uniqueness of geometric decomposition"
  cited in Step 10.
- Agol 2012 virtual Haken conjecture — invoked Step 3 as decoration; NOT
  used downstream. Removing it does not break the proof.
- Wise 2012 quasi-convex hierarchy — invoked Step 4 as decoration; NOT
  used downstream. Removing it does not break the proof.
- Gordon–Luecke 1989 — load-bearing: the entire reduction "different
  complements => different knots" depends on this.
- Thurston hyperbolization 1979 — load-bearing: gives $M_{4_1}$ its
  hyperbolic structure.
- Mostow rigidity 1968 — load-bearing in Step 7 for "hyperbolic structure
  is unique up to isometry"; note that for the logical conclusion
  "$M_{3_1} \not\cong M_{4_1}$", Mostow is not strictly required —
  Perelman's uniqueness of the geometric decomposition already distinguishes
  Seifert-fibered from hyperbolic. Mostow is recorded as load-bearing
  because the Explorer's Step 10 cites it explicitly.

### LDT-specific issues found

- [WARN: STRUCTURAL-CITATION-WARNING]
    L3 citations: 7 (>= 3) — three of them (Agol, Wise, Waldhausen) are
      decorative or redundant. The four load-bearing L3s are Perelman,
      Gordon–Luecke, Thurston hyperbolization, Mostow.
    Independent steps: 0 (< 3) — the Explorer contributes zero independent
      argument; Steps 9–10 are bookkeeping on cited claims.
    Finding: the proof's logical skeleton rests entirely on deep external
      machinery; the Explorer's contribution is routing between cited
      theorems rather than reconstructing their content. The verdict is
      PASS because every citation is correctly applied and the conclusion
      follows, but the proof should be archived with this caveat so the
      collaborator knows the rubric's Completeness score (high) is NOT
      equivalent to mathematical originality (zero).

- [MEDIUM] Steps 3 and 4 (Agol, Wise) are cited but not used downstream;
  they are decorative L3 citations. A Fixer could trim these without
  affecting the conclusion. Flagged but not blocking.

- [MEDIUM] Step 1 (Waldhausen) is invoked but the downstream argument
  does NOT use Haken rigidity; Gordon–Luecke (Step 5) subsumes it for
  this specific conclusion. Flagged but not blocking.

### Final Verdict: PASS with STRUCTURAL-CITATION-WARNING
```

---

## Expected-vs-observed check

The task brief specified that Probe 2's proof under the post-fix rubric
should receive **PASS + STRUCTURAL-CITATION-WARNING**.

- PASS: ✓ (logic is correct; warnings do not veto).
- STRUCTURAL-CITATION-WARNING: ✓ (7 L3s vs 0 Independent; trigger rule met).

Outcome matches the expected post-fix behavior. The L3-classification
mechanism correctly distinguishes a proof that "routes between deep
theorems" from a proof that "contributes independent argument", without
changing the verdict on logically correct work.

---

## Limitations (of the fix, visible from this probe)

1. The warning mechanism catches over-reliance on external machinery but
   says nothing about *which* external machinery is appropriate. A proof
   that cites Heegaard Floer to distinguish $3_1$ from $4_1$ would receive
   the same warning as the current proof; the F2 rubric does not try to
   assess proportionality of machinery to problem.

2. "Independent step" counting is coarse. Steps 9–10 are non-trivial
   bookkeeping, and a proof that merely re-states cited facts in the
   Explorer's own words is also counted as 0 Independent. The heuristic
   is useful but not surgical.

3. L3 classification is boundary-sensitive: Seifert's classification
   (Step 8) is graded L2 here, but an Auditor could reasonably grade it
   L3 if they interpret "Seifert's full machinery" as encompassing the
   orbifold Euler number theory. The canonical list clarifies common
   cases but does not eliminate Auditor judgment.

4. The warning is retrospective — it fires after the proof exists. It
   does not nudge the Explorer toward derivations over citations during
   the Explorer phase. For that, the Scout phase would need a mirror
   rule ("prefer routes with derivations of comparable complexity to the
   citations").

These limitations are recorded here and will go into the post-fix summary.

*Saved 2026-04-20. Artifact for Fix 2 of the V2.1 LDT diagnostic repair.*
