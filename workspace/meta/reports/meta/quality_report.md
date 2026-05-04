# Proof Library Quality Report

**Generated:** 2026-04-11 (post-fix)
**Total proof folders scanned:** 27 (includes 4 new proofs not yet in INDEX.md)
**INDEX.md recorded count:** 23

---

## Fix Summary (Before → After)

| Category | Before | After | Action |
|----------|--------|-------|--------|
| **Critical: denoising problem.md** | 2 lines, no template | 20 lines, full template | Rewritten with Source/Statement/Difficulty |
| **Critical: denoising report.md** | 2 lines, one-liner | 76 lines, full 5-phase | Rewritten with complete report |
| **Critical: denoising difficulty** | Missing | `research` | Added |
| **QED markers missing** | 5 proofs actually missing (initial report overcounted due to grep bug) | 0 missing | Added `$\blacksquare$` to 5 files |
| **Short proofs (< 35 lines)** | 4 flagged | 4 reviewed, all complete | No fix needed — proofs are compact but rigorous |
| **Missing failed_attempts/ dir** | 1 (langevin) | 0 | Created directory |

**Note on initial QED count:** The original report listed 14 proofs as missing QED markers. This was caused by a grep script bug (double output on zero matches). On manual inspection, 9 of those 14 already had `$\blacksquare$` or `$\square$` markers embedded in the text. Only 5 actually needed the fix:
- extragradient-convex-concave-minimax
- mcallester-pac-bayes-bound
- npg-softmax-tabular-convergence
- clipped-sgd-heavy-tail-convergence
- sgd-pl-interpolation-averaging

---

## Current State

### All 27 proof folders — verification results

| Proof | Branch | Lines | QED? | Files OK? |
|-------|--------|-------|------|-----------|
| admm-ergodic-convergence-full-rank | convex/subgradient | 227 | YES | YES |
| admm-ergodic-convergence-rate | convex/subgradient | 71 | YES | YES |
| extragradient-convex-concave-minimax | convex/subgradient | 246 | YES | YES |
| proximal-gradient-convergence-rate | convex/subgradient | 104 | YES | YES |
| denoising-score-matching-equivalence | LT/generalization | 30 | YES | YES |
| ntk-gram-matrix-positive-definiteness | LT/generalization | 60 | YES | YES |
| ntk-infinite-width-convergence | LT/generalization | 32 | YES | YES |
| relu-universal-approximation-quantitative | LT/generalization | 65 | YES | YES |
| transformer-attention-lipschitz | LT/generalization | 65 | YES | YES |
| mcallester-pac-bayes-bound | LT/pac | 116 | YES | YES |
| sgd-uniform-stability-generalization | LT/stability | 48 | YES | YES |
| johnson-lindenstrauss-lemma | linear-algebra | 51 | YES | YES |
| adam-nonconvex-convergence | opt/adaptive | 49 | YES | YES |
| entropy-regularized-value-iteration | opt/convergence | 99 | YES | YES |
| npg-softmax-tabular-convergence | opt/convergence | 308 | YES | YES |
| ogd-regret-bound | opt/convergence | 66 | YES | YES |
| nesterov-first-order-lower-bound | opt/lower-bounds | 105 | YES | YES |
| mirror-descent-online-regret-bound | opt/mirror-descent | 61 | YES | YES |
| clipped-sgd-heavy-tail-convergence | opt/stochastic | 167 | YES | YES |
| sgd-pl-interpolation-averaging | opt/stochastic | 130 | YES | YES |
| sps-sgd-convergence-rate | opt/stochastic | 71 | YES | YES |
| svrg-linear-convergence-abc-framework | opt/stochastic | 145 | YES | YES |
| langevin-kl-convergence-log-sobolev | probability | 102 | YES | YES |
| matrix-bernstein-inequality | stat/concentration | 27 | YES | YES |
| mcdiarmid-bounded-differences-inequality | stat/concentration | 68 | YES | YES |
| sub-gaussian-covariance-concentration | stat/concentration | 33 | YES | YES |
| double-descent-interpolation-threshold | stat/high-dim | 129 | YES | YES |

### Remaining issues

| # | Issue | Details |
|---|-------|---------|
| 1 | 4 proof folders not in INDEX.md | admm-ergodic-convergence-full-rank, admm-ergodic-convergence-rate, relu-universal-approximation-quantitative, nesterov-first-order-lower-bound |
| 2 | Short report.md files | transformer-attention-lipschitz (16 lines), svrg-linear-convergence-abc-framework (18 lines), sgd-uniform-stability-generalization (25 lines), extragradient-convex-concave-minimax (25 lines) — abbreviated but functional |
| 3 | matrix-bernstein proof.md (27 lines) | Compact single-paragraph style with all 5 lemmas + theorem; full expanded proof exists in report.md (252 lines). No content missing, just dense formatting. |

### Resolved issues: 0 Critical, 5 QED, 1 directory = 6 total fixes applied

---

*Report updated 2026-04-11 after quality fixes.*
