# Fragment: storm-variance-recursion

## Statement
For the STORM update $d_t = (1 - a) d_{t-1} + a \nabla f(x_t; \xi_t) + (1-a)(\nabla f(x_t; \xi_t) - \nabla f(x_{t-1}; \xi_t))$ with mean-squared-smoothness assumption $\mathbb{E}[\|\nabla f(x; \xi) - \nabla f(y; \xi)\|^2] \le L^2 \|x - y\|^2$ and bounded variance $\sigma^2$, the error $e_t := d_t - \nabla f(x_t)$ satisfies the recursion:
$$\mathbb{E}[\|e_t\|^2 | \mathcal{F}_{t-1}] \;\le\; (1 - a)\|e_{t-1}\|^2 + 2L^2 \eta^2 \|d_{t-1}\|^2 + 2a^2 \sigma^2.$$

The geometric decay factor $(1 - a)$ on the previous error, plus the $a^2$ scaling on the noise (rather than $a$), is what allows STORM to achieve $O(\varepsilon^{-3})$ complexity matching SPIDER but **without** requiring large mini-batches at each step.

## Proof
Subtracting $\nabla f(x_t)$ from the STORM update:
$$e_t = (1 - a)e_{t-1} + (1 - a)\delta_t + a\epsilon_t,$$
where $\delta_t := [\nabla f(x_t; \xi_t) - \nabla f(x_{t-1}; \xi_t)] - [\nabla f(x_t) - \nabla f(x_{t-1})]$ and $\epsilon_t := \nabla f(x_t; \xi_t) - \nabla f(x_t)$. Both are conditionally mean-zero given $\mathcal{F}_{t-1}$.

Take conditional second moment, noting $e_{t-1}$ is $\mathcal{F}_{t-1}$-measurable:
$$\mathbb{E}[\|e_t\|^2 | \mathcal{F}_{t-1}] = (1-a)^2\|e_{t-1}\|^2 + \mathbb{E}[\|(1-a)\delta_t + a\epsilon_t\|^2 | \mathcal{F}_{t-1}].$$

Apply $\|u + v\|^2 \le 2\|u\|^2 + 2\|v\|^2$:
$$\mathbb{E}[\|(1-a)\delta_t + a\epsilon_t\|^2] \le 2(1-a)^2 \mathbb{E}[\|\delta_t\|^2] + 2a^2 \mathbb{E}[\|\epsilon_t\|^2].$$

Mean-squared smoothness gives $\mathbb{E}[\|\delta_t\|^2] \le L^2\|x_t - x_{t-1}\|^2 = L^2 \eta^2 \|d_{t-1}\|^2$, and bounded variance gives $\mathbb{E}[\|\epsilon_t\|^2] \le \sigma^2$. Use $(1-a)^2 \le 1-a$ for $a \in (0, 1)$. $\square$

## Source
- `proofs/research/optimization/stochastic/storm-nonconvex-convergence/proof.md` — Lemma 1.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (STORM convergence)
- **Potential applications**:
  - STORM, SARAH+, MARINA, SCSG variance analysis
  - General variance-reduced methods with EMA-style estimators
  - Adaptive momentum analysis (Adam-like with variance correction)
  - Non-convex SGD with momentum (positive feedback control of error)
  - Hybrid gradient methods (combining current and previous batch)

## Tags
storm, variance-reduction, momentum, stochastic, EMA, recursion
