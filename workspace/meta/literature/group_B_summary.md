# Group B — Literature Cross-Check Summary (Stochastic + Adaptive)

**Date**: 2026-04-27
**Owner**: Agent 2
**Scope**: 14 PASS proofs in `proofs/research/optimization/{stochastic,adaptive-methods}/`

---

## Verdict tally

| Verdict | Count | Proofs |
|---|---|---|
| CONFIRMED | 6 | B2 (clipped-SGD), B3 (PL+interp), B6 (split-coco momentum), B8 (SPIDER), B10 (STORM), B12 (Adam), B14 (AdaGrad-Norm) — actually 7 |
| CONFIRMED-WEAKER | 5 | B1 (SPS), B4 (linear-conv momentum), B5 (contraction momentum), B9 (SPIDER/SARAH), B13 (AMSGrad) |
| CONFIRMED (existential) | 1 | B7 (spectral analysis momentum) |
| DISCREPANCY | 1 | B11 (PAGE — final SFO complexity off by $\sqrt n$) |
| NOVEL | 0 | — |
| ERROR | 0 | — |

**Recount**: CONFIRMED 7 + CONFIRMED-WEAKER 5 + CONFIRMED-existential 1 + DISCREPANCY 1 = 14 ✓

---

## Top novel results
**None.** All 14 proofs reproduce known published results from 2017-2022. Group B's purpose is library-building of textbook-canonical convergence proofs for SGD variants and adaptive methods. There are no new theorems.

The most "interesting" proof is B7 (momentum-SGD spectral analysis): it lifts the Loizou-Richtárik / Can-Gurbuzbalaban-Zhu spectral framework from quadratics to general convex via an integral-Hessian state-dependent reduction. The reduction is a careful proof variant rather than a new theorem; the underlying spectral machinery is published.

---

## Top discrepancies

**B11 (PAGE) — DISCREPANCY**: The proof's stated total gradient complexity is
$$O(n + nL\Delta_0/\varepsilon^2)$$
but it then claims to match the published PAGE/Fang lower bound
$$\Omega(n + \sqrt n/\varepsilon^2).$$
These differ by a factor $\sqrt n$. Root cause: step size $\eta = 1/(2L\sqrt n)$ is too conservative — published PAGE uses $\eta = 1/(2L)$ (independent of $n$), giving iteration count $T = O(L\Delta_0/\varepsilon^2)$ rather than our $T = O(L\sqrt n\,\Delta_0/\varepsilon^2)$. The intermediate bound is internally consistent with the chosen $\eta$, but the final claim "matches lower bound" is incorrect. **Not an ERROR (no contradiction with published math), but the optimality claim is unjustified.**

**B1, B4, B5, B9, B13 — CONFIRMED-WEAKER**: All five reproduce the correct rate but with looser constants than the original paper (factors of 2× to ~10×). Proofs explicitly acknowledge most of these gaps in their own remarks. No theorems are misstated.

---

## Two-sentence pattern

The Group B proofs are highly faithful reproductions of canonical SGD/adaptive-method theorems from 2017-2022; rates match published results in 13 of 14 cases, and where constants are looser the proofs honestly say so. The single notable issue is B11 (PAGE), where a conservative step-size choice produces a complexity bound that is $\sqrt n$ worse than the optimal published rate yet is incorrectly claimed to match the Fang et al. lower bound — fixable by tightening the step size to the published value $\eta = 1/(2L)$.

---

## Per-proof file pointers

All detailed verdicts in `workspace/literature_crosscheck/group_B/`:
- B01_sps-sgd-convergence-rate.md
- B02_clipped-sgd-heavy-tail.md
- B03_sgd-pl-interpolation-averaging.md
- B04_momentum-sgd-interpolation-linear.md
- B05_momentum-sgd-interpolation-contraction.md
- B06_momentum-sgd-interpolation-convergence.md
- B07_momentum-sgd-spectral-analysis.md
- B08_spider-nonconvex-grad-complexity.md
- B09_spider-variance-reduction-nonconvex.md
- B10_storm-nonconvex.md
- B11_page-optimal-grad-complexity.md
- B12_adam-nonconvex.md
- B13_amsgrad-nonconvex.md
- B14_adagrad-norm-nonconvex.md

---

## Methodology notes

- **arXiv reachability**: WebFetch consistently returned only abstract metadata (no theorem text). The detailed cross-check therefore combined (i) abstract-level confirmation of the rate exponent and big-O complexity for B8, B10, B11, B12, B14 (which had useful abstracts) with (ii) training-data knowledge of the published theorem statements for the others.
- **arXiv ID typo**: B2's listed arXiv 1912.07467 is an astrophysics paper. The correct heavy-tail clipping reference is the NeurIPS 2020 Zhang et al. / arXiv 2005.10785 Gorbunov et al. family. Marked "[ARXIV-UNREACHABLE]" in the per-proof file.
- **Per-proof time**: ~2-3 min average, well within 4-min cap. Total wall time ~45 min.
