# Failure Analysis — Summary Statistics

**Date**: 2026-04-27
**Scope**: all problem-level attempts identified in `all_failures.md`. Inner route failures (Tier F) are tracked separately because the problem itself ultimately PASSED.

---

## Top-level distribution

```
Total problem-level attempts considered            : 28 (Tiers A + B + C + D + E)
Of these:
  Hard FAIL (no proof produced)                    :  4 (14.3%)
  INTERRUPTED                                      :  1 (3.6%)
  PARTIAL — archived in research/ with caveats     : 12 (42.9%)
  DISPROVED — archived as honest negative result   :  3 (10.7%)
  Failure-pattern-only (no proofs/ folder)         :  6 (21.4%)
  Problem-statement validation failure             :  3* (one of which double-counts as FAIL — E1)
*adjusted = 2 net new (E2, E3 were caught and resolved without leaving a failure)

Notes:
- Several PARTIALs in Tier C are net positive: literal claim refuted, but a refined
  positive theorem was produced and is in the library.
- Tier F (route-level) is excluded from these problem-level totals: it covers ~16
  theorems where one or more routes died but the problem ultimately PASSED.
```

## Library-wide PASS-rate context

From `workspace/math_agent_full_scan_report.md` (2026-04-26):
- **First-round audit pass rate**: 86% (23 of 27 fully-audited proofs)
- **Total proofs in library**: 93 (51 research + 42 library)
- **Required Fixer repair**: 6
- **Problem-statement self-contradictions detected**: 1 (AdaGrad-Norm UB/LB)

Adding the 28 problem-level non-PASSes documented here against ~ 93 + 28 - already-counted-PARTIALS gross attempts, the net "did not produce a clean PASS" rate is:

```
Clean PASS                                : ~75% (lower bound; many PARTIALs are still useful)
PARTIAL (archived with caveats)           : ~13%
DISPROVED (archived as negative result)   : ~3%
Hard FAIL                                 : ~4%
Other (interrupted, ablation only)        : ~5%
```

## Root-cause distribution (per `root_cause_analysis.md`)

```
RC1 (problem statement was wrong)          : 14 (50.0%)
RC2 (beyond current framework capability)  :  3 (10.7%)
RC3 (wrong proof strategy by Explorer)     :  0
RC4 (right strategy, execution error)      :  2 ( 7.1%)
RC5 (missing prerequisite technique)       :  2 ( 7.1%)
RC6 (numerical / computational limit)      :  0
RC7 (ambiguous problem statement)          :  9 (32.1%)

(some problems map to two RCs; RC7 + RC1 overlap is common.)
```

### Reading the distribution

- **RC1 + RC7 = 23/28 = 82%** of all problem-level non-PASSes are **problem-statement quality issues** (literally false claims, or under-specified statements). This is the single largest finding of the analysis.
- **RC2 = 3 cases** (A3, D-OP2-PEP, D5) are the only genuine "open problems beyond the framework". OP-2 sharp version is the canonical one; the other two are spinoffs.
- **RC4 = 2 cases** (C3 categorical "true retraction" claim was algebraically too strong; E1 Route 3 misapplied suffix averaging). Both are proof-engineering bugs the framework should catch.
- **RC5 = 2 cases**: heavy-tail proxy stationarity (now in library after the second attempt) and Gordon-Slepian (still missing). Adding Gordon to the library would unblock A2.
- **RC3 = 0** at the problem level: the multi-route protocol successfully recovers from individual wrong-strategy choices.
- **RC6 = 0**: no failure has been blocked by raw compute or numerical precision.

## Distribution by source / batch

```
Yuan Yang Batch 1 (1.1, 1.2, 2.1, 3.1, 4.1)  : 5 problems, 1 DISPROVED + matched (3.1), rest PASS
Yuan Yang Batch 2 (6.1-6.10)                 : not catalogued in this repo (problem IDs not present)
Yuan Yang Batch 3 (7.1-7.10)                 : 10 problems
                                                  PASS: 7.2 (with caveat), 7.4 (with corrections), 7.5 (conditional),
                                                        7.6 (with caveat), 7.7 (with correction)
                                                  PARTIAL/REFUTED literal: 7.1, 7.3, 7.8, 7.9, 7.10
OP-2 Original (∃f∀(β,η_t))                   : 1 FAIL (A3)
OP-2 Downgraded (restricted)                 : 1 PASS
OP-2 Iterate-Type (I3, I4, I5, M3, S4)       : I3 PARTIAL, I4 DISPROVED + Tier-A FAIL, I5 DISPROVED + UB,
                                               M3 PASS, S4 PARTIAL
OP-2 Divergent (D1, D4, D5)                  : D1 DISPROVED, D4 DISPROVED, D5 PARTIAL
                                               (D2, D3 not catalogued separately)
OP-2 Upgrade B-series                        : Init B PARTIAL, PEP B2 TIMEOUT
OP-2 New Construction Cesàro                 : DISPROVED
OP-2 Deep Dive (8.1-8.10)                    : not catalogued in this repo (problem IDs not present)
```

The "Yuan Yang Batch 2 (6.1-6.10)" and "OP-2 Deep Dive (8.1-8.10)" batches mentioned in the prompt were searched for but produced no `problem.md` files in the repo. Either these batches were not yet executed, or their IDs differ from the canonical names. Treated as "not in repo" rather than "all FAILED".

## Distribution by branch (`proofs/research/` PARTIALs only)

```
optimization/convergence              : 2 PARTIAL/DISPROVED (3.1 SVRG, I5 PR-defeats-cycling)
optimization/lower-bounds             : 3 PARTIAL/DISPROVED (I3 best-iterate, I4 suffix-avg, S4 interp)
learning-theory/generalization        : 4 PARTIAL (7.1 OT, 7.3 InfoNCE, 7.5 Rényi, 7.8 phase trans)
learning-theory/stability             : 2 PARTIAL (7.6 heavy-tail, 7.10 adv tradeoff)
multi-agent                           : 4 PARTIAL (7.2 categorical, 7.4 nonstat, 7.7 compositional, 7.9 depth)
```

Optimization/lower-bounds and multi-agent are the two PARTIAL-heavy branches — both areas where the literature is thin and original conjectures more frequently turn out to be slightly mis-stated.

## Highest-leverage actions (re-derived from RC distribution)

1. **Pre-Dispatcher problem-statement validation agent** would catch most RC1 + RC7 cases (23 of 28). Already partially deployed via Auditor Step 0.5 reverse-consistency, but the AdaGrad blind test (E1) showed it misses problem-level UB/LB inconsistencies.

2. **Library augmentation** — adding (a) Gordon-Slepian comparison and (b) Assouad's hypercube method would unblock A2 (BLLT bias bound) and sharpen C4 (SSL InfoNCE log-gap) respectively. Both are well-documented techniques; cost is one focused B-class proof entry each.

3. **Acceptance of "PARTIAL" as a legitimate output**: of the 14 PARTIALs in C, all but 2 represent net positive contributions (literal claim refuted, refined version proven). This is a feature, not a bug — but RESEARCH_INDEX.md currently lists them mixed with PASSes. A separate "honest-negative-results" tag would surface their value.

4. **OP-2 sharp ($\exists f\,\forall$)**: a genuine open research problem. Requires a fundamentally new hard-instance idea. Not a framework defect.

5. **Cycling-based LBs as a saturated technique**: Tier D shows the Goujaud framework is now fully exploited (Cesàro, suffix-avg, PR-avg, Adam, high-dim, Nesterov, zero-init all DISPROVED or PARTIAL). New SHB-style LBs need a non-cycling technique.
