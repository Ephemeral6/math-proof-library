# C6 — Chambolle-Pock PDHG O(1/N) ergodic

**Path**: `proofs/research/convex-analysis/subgradient/chambolle-pock-pdhg-ergodic-convergence/`
**Verdict**: **MATCH (canonical Chambolle-Pock 2011 result)**

## Our statement
For the PDHG iteration with step sizes $\tau, \sigma > 0$ satisfying $\tau\sigma L^2 < 1$ (where $L = \|K\|$):
$$
y^{n+1} = \text{prox}_{\sigma f^*}(y^n + \sigma K\bar x^n),\quad x^{n+1} = \text{prox}_{\tau g}(x^n - \tau K^* y^{n+1}),\quad \bar x^{n+1} = 2x^{n+1} - x^n,
$$
the ergodic averages $X^N = \frac{1}{N}\sum_n x^n$, $Y^N = \frac{1}{N}\sum_n y^n$ satisfy, for any bounded set $\mathcal{B} = \mathcal{B}_x \times \mathcal{B}_y$ and $(x,y) \in \mathcal{B}$:
$$
\mathcal{G}_{\mathcal{B}}(X^N, Y^N) \le \frac{1}{N}\left(\frac{\|x-x^0\|^2}{2\tau} + \frac{\|y-y^0\|^2}{2\sigma}\right).
$$

## Literature

### Chambolle-Pock 2011 (JMIV) — "A First-Order Primal-Dual Algorithm for Convex Problems with Applications to Imaging"
- Canonical reference. Theorem 1 of CP 2011 gives exactly the bound above with the same step-size condition $\tau\sigma L^2 < 1$ (often written $\tau\sigma L^2 \le 1$).
- The restricted-gap formulation with $\mathcal{B}$ is standard for primal-dual (allows handling unbounded domains).

### He-Yuan 2012, Esser-Zhang-Chan 2010
- Variants of PDHG with similar O(1/N) ergodic rates.

## Comparison

The bound $\mathcal{G}_{\mathcal{B}}(X^N, Y^N) \le \frac{1}{N}(\|x-x^0\|^2/(2\tau) + \|y-y^0\|^2/(2\sigma))$ is **exactly Chambolle-Pock 2011 Theorem 1**. The condition $\tau\sigma L^2 < 1$ is exactly their step-size condition.

| Aspect | CP 2011 | OUR C6 |
|---|---|---|
| Step size | $\tau\sigma L^2 < 1$ | $\tau\sigma L^2 < 1$ |
| Iterate | $\bar x = 2x - x^-$ extrapolation | identical |
| Rate | $O(1/N)$ ergodic gap | identical |
| Constant | $\|x-x^0\|^2/(2\tau) + \|y-y^0\|^2/(2\sigma)$ | identical |

## Verdict

**MATCH.** Faithful reproduction of Chambolle-Pock 2011 Theorem 1. The proof uses the monotone-inclusion / VI route (route 2 in the file), which is one of the standard derivations. No novelty claimed; this is a B-class library result.

The proof is complete (Schur-complement absorption of cross terms via $\tau\sigma L^2 < 1$) and the constants match the canonical bound.
