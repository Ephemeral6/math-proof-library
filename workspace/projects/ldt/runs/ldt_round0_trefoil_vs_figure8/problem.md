# Problem: Trefoil vs Figure-Eight — Inequivalence

## Source
- Paper: classical (Kauffman, Lickorish — textbook exposition)
- Context: Round 0 of LDT extension of Math Agent V2.  This is NOT a research problem;
  it is a gap-discovery instrument.  Purpose is to run the full 5-phase pipeline on
  a problem where:
    1. The answer is known.
    2. Multiple standard proof paths exist (Jones polynomial, Alexander polynomial,
       knot determinant, hyperbolic volume).
    3. TSV-Knot can ground-truth verify against KnotInfo.

## Statement

Let $K_{\text{trefoil}} = 3_1$ (the right-handed trefoil knot) and $K_{\text{fig8}} = 4_1$
(the figure-eight knot), both viewed as oriented knots in $S^3$.  Prove:

$$K_{\text{trefoil}} \not\sim K_{\text{fig8}}$$

where $\sim$ denotes ambient isotopy in $S^3$.

## Difficulty

standard — undergraduate-level, textbook exercise.

## Context for the Math Agent

- **Library is empty.** Scout will find no LDT entries under `proofs/library/low-dimensional-topology/`.
- **Technique dictionary is thin.** `proof_techniques_ldt.md` has 10 entries; no prior LDT proof exists.
- **TSV-Knot is available**: `jones_polynomial`, `alexander_polynomial`, `hyperbolic_volume`,
  `check_reidemeister_equivalent`, `lookup_knotinfo`.
- **Purpose is GAP DISCOVERY.** A PASS verdict is nice but not required; an honest failure
  with a clear gap list is the target outcome.

## What Round 0 should produce

- A proof attempt (PASS / PARTIAL / FAIL with gap list).
- An observation log (`observations.md` in this dir) documenting each phase's behavior.
- A domain gap report (`workspace/ldt_round0_gap_report.md`).
