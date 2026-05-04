# Fragment: spider-variance-recursion

## Statement
For the SPIDER/SARAH variance-reduced update inside an epoch (with full-gradient anchor at the start, i.e., $e_0 = 0$): $v_{t+1} = \nabla f(x_{t+1}; \xi_{t+1}) - \nabla f(x_t; \xi_{t+1}) + v_t$, with mini-batch size $b$. The estimator error $e_t := v_t - \nabla f(x_t)$ satisfies:
$$\mathbb{E}[\|e_{t+1}\|^2 | \mathcal{F}_t] \;=\; \|e_t\|^2 + \frac{L^2 \eta^2}{b}\|v_t\|^2,$$
which telescopes to
$$\mathbb{E}[\|e_t\|^2] \;\le\; \frac{L^2 \eta^2}{b}\sum_{s=0}^{t-1}\mathbb{E}[\|v_s\|^2].$$

Summed across the epoch of length $q$:
$$\sum_{t=0}^{q-1}\mathbb{E}[\|e_t\|^2] \;\le\; \frac{L^2 \eta^2 q}{b}\sum_{t=0}^{q-1}\mathbb{E}[\|v_t\|^2].$$

## Proof
Write $e_{t+1} = v_{t+1} - \nabla f(x_{t+1}) = e_t + \delta_{t+1}$ where $\delta_{t+1} = [\nabla f(x_{t+1}; \xi) - \nabla f(x_t; \xi)] - [\nabla f(x_{t+1}) - \nabla f(x_t)]$ (a centered single-sample/mini-batch difference). Since $\delta_{t+1}$ is conditionally mean-zero given $\mathcal{F}_t$ and $e_t \in \mathcal{F}_t$:
$$\mathbb{E}[\|e_{t+1}\|^2 | \mathcal{F}_t] = \|e_t\|^2 + \mathbb{E}[\|\delta_{t+1}\|^2 | \mathcal{F}_t].$$
By "variance $\le$ second moment" applied to the mini-batch and individual $L$-smoothness:
$$\mathbb{E}[\|\delta_{t+1}\|^2] \le \frac{L^2}{b}\|x_{t+1} - x_t\|^2 = \frac{L^2 \eta^2}{b}\|v_t\|^2.$$
Telescope from $e_0 = 0$. $\square$

## Source
- `proofs/research/optimization/stochastic/spider-nonconvex-gradient-complexity/proof.md` — Lemma 1.
- `proofs/research/optimization/stochastic/spider-variance-reduction-nonconvex/proof.md` — Lemma 1.
- `proofs/research/optimization/stochastic/page-optimal-gradient-complexity/proof.md` — Lemma 2 (Bernoulli-reset variant).

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (cornerstone of SPIDER, SARAH, PAGE complexity proofs)
- **Potential applications**:
  - SPIDER, SARAH, PAGE, ProxSARAH non-convex analysis
  - Showing $O(\sqrt{n}/\varepsilon^2)$ complexity (vs SVRG's $n^{2/3}$)
  - Variance-reduced methods for finite-sum problems
  - Adaptive batch size selection (ratio $L^2\eta^2/b$ controls drift)
  - Generalization to bilevel / minimax variance-reduced estimators

## Tags
spider, sarah, variance-reduction, sfo-complexity, anchor, telescope
