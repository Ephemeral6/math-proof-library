# RIP Sparse Recovery Guarantee

## Source
- Paper: Candès & Tao 2005 (IEEE IT); Candès, Romberg & Tao 2006; Candès 2008
- Context: Foundational result in compressed sensing showing that restricted isometry property guarantees exact recovery of sparse signals via ℓ1 minimization

## Statement

**Theorem.** Let $A \in \mathbb{R}^{m \times n}$ with $m \ll n$ satisfy the Restricted Isometry Property (RIP) of order $2s$ with constant $\delta_{2s} < \sqrt{2} - 1$:

$$(1 - \delta_{2s})\|x\|_2^2 \leq \|Ax\|_2^2 \leq (1 + \delta_{2s})\|x\|_2^2, \quad \forall \|x\|_0 \leq 2s.$$

If $x^* \in \mathbb{R}^n$ is $s$-sparse ($\|x^*\|_0 \leq s$) and we observe $b = Ax^*$, then the solution to:

$$\hat{x} = \arg\min_{x} \|x\|_1 \quad \text{s.t.} \quad Ax = b$$

satisfies $\hat{x} = x^*$ (exact recovery).

## Difficulty
research
