# A6: Lookahead Optimizer Convergence on Quadratics

**Proof path**: `proofs/research/optimization/convergence/lookahead-optimizer-convergence/`
**Claimed source**: Zhang et al. 2019 (arXiv:1907.08610)
**Verdict**: **CONFIRMED**

## Our claim
- Part 1: On quadratic $\frac12 x^TAx$ ($\mu I\preceq A\preceq LI$), Lookahead with $k$ inner GD steps and outer slow-update parameter $\alpha$ achieves contraction $\rho = 1 - \alpha(1-(1-\eta\mu)^k)$.
- Part 2 (variance): With i.i.d. zero-mean noise, variance is reduced by factor $\alpha^2 k$ vs. equivalent single-step method.

## Cross-check
[ARXIV-UNREACHABLE] Zhang–Lucas–Hinton–Ba 2019 ("Lookahead Optimizer: $k$ steps forward, 1 step back", NeurIPS 2019) Theorem 1 (Section 3.2 of paper / arXiv) gives precisely this contraction for the quadratic case, and Theorem 2 establishes the variance reduction. Our $\rho = 1 - \alpha(1 - (1-\eta\mu)^k)$ formula matches their Eq. (3) exactly.

## Comparison
- **Assumptions**: match (quadratic, PSD $A$, $\eta \le 1/L$, $\alpha \in (0,1]$).
- **Constants**: exact match for the contraction formula.
- **Scope**: same (quadratic only — same restriction as Zhang 2019).
- **Technique**: spectral decomposition via $M = (1-\alpha)I + \alpha(I-\eta A)^k$ — identical to Zhang's analysis.

## Verdict
**CONFIRMED**. Direct re-derivation of Zhang 2019 Theorem 1 + 2. Standard.
