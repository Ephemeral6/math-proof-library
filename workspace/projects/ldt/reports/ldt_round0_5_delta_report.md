# LDT Round 0.5 — Delta Report

**Problem**: Same as Round 0: prove $3_1 \not\sim 4_1$ in $S^3$.
**Purpose**: Measure impact of Stage 3's top-3 fixes by re-running the same
problem and comparing.
**Date**: 2026-04-20.

## Fixes applied (from Stage 3)

1. **Fix 1 — Geometric Content axis in Judge.**
   New file: `~/.claude/skills/math-proof-agent/prompts/judge_ldt.md`.
   Adds 5th scoring axis with 1.5× multiplier. Total = 55 points (was 40).

2. **Fix 2 — Convention registry.**
   New file: `proofs/library/low-dimensional-topology/conventions.md`.
   Fixes Lickorish Jones convention, reduced Burau, non-hyperbolic =
   undefined (not zero), orientation/chirality.

3. **Fix 3 — Three library lemmas.**
   New files in `proofs/library/low-dimensional-topology/knot-invariants/`:
   - `jones-trefoil-right.md`
   - `jones-figure-eight.md`
   - `kauffman-bracket-axioms.md`

## Pipeline delta (Round 0 → Round 0.5)

| Metric | Round 0 | Round 0.5 | Delta |
|--------|---------|-----------|-------|
| Scout library hits | 0 | **4** | +4 |
| Scout failure-pattern hits | 0 | 4 (FP-LDT-01..04) | +4 |
| Routes explored | 3 | 2 (Alexander skipped) | −1 |
| Winning route | Route 1 Jones | **Route 3 Hyperbolic** | **FLIPPED** |
| Winner total | 19/20 (old rubric) | 47.5/55 (new rubric) | new metric |
| Winner Geometric Content | 2/5 | **9/10** | +20 percentage points normalized |
| [STEP-STUCK] tags across all explorers | 1 (Route 2 Burau) | 0 | −1 |
| [SIGN-CONVENTION] flags | 1 (Route 1 Jones) | 0 | −1 |
| TSV calls (total) | 9 | 4 | −5 (library citations shorten chain) |
| Auditor flags raised | 2 | 1 minor cleanup | −1 |
| LDT checklist items fired on winner | 4 (A, B, F, H) | **7** (A, B, D, F, G, H, plus C pass-as-NA) | +3 |
| Hypotheses (of H1–H6) confirmed | H1, H3, H5 full; H2, H4 partial; H6 deferred | H1, H3, H5 full; H2, H4 closed; **H6 confirmed** | **H6 now confirmed; H2/H4 matured** |
| Fixer rounds triggered | 0 | 0 | 0 |
| Audit verdict | PASS w/ reservations | **PASS** (clean) | simpler |

## Qualitative changes

### Change 1: Collaborator criterion now drives route selection

The most important delta. Under Round 0's V2 rubric, "correctness + completeness +
elegance + verifiability" favored the algebraic Jones route (self-contained,
well-anchored). Under Round 0.5's `judge_ldt.md`, the 1.5× Geometric Content
multiplier tipped the scales to Route 3 by 1.5 points (47.5 vs 46). The
pipeline now chooses the proof that matches "希望看到几何直觉".

**This validates Fix 1** as the single most-impactful change.

### Change 2: Sign-convention stumble eliminated

Round 0 Route 1 produced the left-handed (mirror) Jones polynomial on first
pass, then self-corrected via Lickorish + TSV. Round 0.5 Route 1 is 4 lines
long because it cites `jones-trefoil-right.md` directly. No computation, no
convention ambiguity, no stumble.

**This validates Fix 2 + Fix 3 together.** The convention registry tells the
Explorer which convention to use; the library lemma provides the answer in
that convention; TSV re-verifies.

### Change 3: LDT-G (picture-proof) hypothesis finally exercised

Round 0 Route 1 (winner) had no picture content, so LDT-G never fired.
Round 0.5 Route 3 (winner) has a picture fact ("two regular ideal tetrahedra
glued along faces"); LDT-G fired; the handling rule (citation + TSV-anchored
numerical consequence) was tested and worked.

**Hypothesis H6 (picture-proof detection matters) is now CONFIRMED.**

### Change 4: Alexander route safely skipped

Scout at Round 0.5 saw that Route 2 (Alexander/Burau) had no library lemmas
and a known stuck-point from Round 0 (FP-LDT-01). With two routes already
giving complementary proofs (algebraic + geometric), running a third noisy
route added no information. Scout correctly pruned it.

**This reflects the pipeline maturing**: Scout uses prior-round data (failure
patterns) to make better route-selection decisions.

### Change 5: Clean audit, no Fixer

Round 0 audit raised 2 flags ([FLAG-1] sign convention, [FLAG-2] TSV-only
resolution) that were resolved in-audit but left a paper trail. Round 0.5
audit raises 1 cosmetic cleanup note (Route 3 Step 2 volume-formula aside)
which is applied inline when copying to `best_proof.md`.

**Fixer round was not needed either time**, but Round 0.5's flag-count is
genuinely lower, not just not-escalated.

## Unresolved / new findings in Round 0.5

### U1. `best_proof.md` cleanup was manual

Auditor flagged a cosmetic issue in Route 3 Step 2 ("volume formula aside");
this was resolved by hand when writing `best_proof.md`. A mature pipeline
would have the Fixer do this as a minor-cleanup pass. Currently Fixer only
triggers on correctness/completeness issues — a "Fixer-Light" for
cosmetic cleanup would be a Stage 4 improvement.

### U2. Route 3's 3 black-box references are still unverified

`[REF:external]` to Thurston / Mostow / Gordon–Luecke carries no
`[VERIFIED:]` tag because these are outside TSV scope. For this problem's
difficulty (C-class textbook), black-box citation is appropriate. For
harder problems (A-class research), the pipeline should push back harder
and ask whether at least one reference can be promoted to `[REF:library]`.

### U3. Library-only Jones proof is so short it loses elegance signal

Route 1 Round 0.5 is 4 steps and 2 TSV calls. So trivially easy that the
"elegance" axis doesn't distinguish it meaningfully from a proof that
cites a finished paper. Signal saturation at the top of the elegance scale.
This is not a problem now, but once library coverage is broad, Judge may
need to de-weight Elegance or split it into "elegance of the derivation"
vs "elegance of the cited chain".

### U4. Geometric narrative paragraph in Route 3 — should it be required?

Route 3 includes a "Geometric narrative" paragraph that's explicitly for
human readability (not formal proof content). It likely contributed to the
9/10 Axis 5 score. For collaborator-facing proofs, maybe the pipeline should
REQUIRE a narrative paragraph? Open question for Stage 4.

## Hypotheses refresh after Round 0.5

| # | Original | Round 0.5 outcome |
|---|----------|------------------|
| H1 | TSV-Knot closes knot-invariant arguments | Still CONFIRMED |
| H2 | Technique dict too thin to steer Scout | **RESOLVED** (now OK with library additions) |
| H3 | Library-empty = zero hits, minor cost | CONFIRMED then RESOLVED (library now non-empty) |
| H4 | LDT checklist fires on A, B, G, H | **CONFIRMED** (all 4 plus C, D, F fired in Round 0.5) |
| H5 | Sign conventions surface as errors | **CONFIRMED then MITIGATED** (registry stops recurrence) |
| H6 | Picture-proof detection will matter | **NOW CONFIRMED** (LDT-G fired on Route 3 triangulation) |

All 6 hypotheses are now either confirmed or resolved. The Stage 1–3 design
loop closed.

## Net assessment

The three Stage-3 fixes delivered exactly what the Round 0 gap report
predicted:
- Fix 1 flipped the winner to the geometric route (collaborator criterion).
- Fix 2 eliminated the sign-convention stumble.
- Fix 3 shrank Route 1 from 6 steps to 4 and removed the need for Explorer
  to re-derive invariants.

No fixes introduced new problems. Cost of fixes: ~4 files (one prompt, one
registry, two library lemmas — `kauffman-bracket-axioms.md` was zero-work
since it just crystallized material already in the Round 0 Explorer).

## Recommendation to user

Stage 3 is successful. Suggested next steps (NOT self-started per rule #4 of
the original task brief):
1. **Stage 4 (optional, user-triggered)**: Pick a harder LDT problem (e.g.,
   torus-knot classification $T(p,q) \sim T(p',q') \iff \{p,q\} = \{p',q'\}$)
   to stress-test the pipeline further. Current Round 0/0.5 results may be
   misleadingly clean because the problem was textbook-level.
2. **Stage 4 alt**: Tackle a picture-proof-heavy problem (e.g., genus of
   $(2, 2k+1)$-torus knot via Seifert surface) to further exercise LDT-G.
3. **Stage 4 alt 2**: Tackle an MCG / curve-complex problem to exercise
   TSV-Group and TSV-Simplicial (which saw ZERO use in Rounds 0 and 0.5).

## Artifacts produced this round

- `workspace/active/ldt_round0_5_trefoil_vs_figure8/`
  - `problem.md`
  - `scout.md`
  - `explorer_1_jones.md`
  - `explorer_3_hyperbolic.md`
  - `judge.md` (using `judge_ldt.md` rubric)
  - `auditor.md` (V2 + LDT checklist)
  - `best_proof.md` (Route 3 cleaned up)
  - `alternative_route_algebraic.md` (copy of Route 1)
- `workspace/ldt_round0_5_delta_report.md` (this file)
