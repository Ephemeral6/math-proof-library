# Fragment: bernoulli-reset-variance-recursion

## Statement
Consider the PAGE variance-reduced estimator: at each step, with probability $p$ reset $g_{t+1} = \nabla f(x_{t+1})$ (full gradient); with probability $1-p$ apply the SPIDER-style correction $g_{t+1} = g_t + \tfrac{1}{b'}\sum_{i \in \mathcal{B}'}[\nabla f_i(x_{t+1}) - \nabla f_i(x_t)]$. The error $e_t := g_t - \nabla f(x_t)$ satisfies
$$V_{t+1} := \mathbb{E}[\|e_{t+1}\|^2] \;\le\; (1 - p) V_t + \frac{L^2 \eta^2}{b'}\,\mathbb{E}[\|g_t\|^2].$$
Equivalently, summed over $T$ steps:
$$\sum_t V_t \;\le\; \frac{L^2 \eta^2}{p\,b'}\sum_t \mathbb{E}[\|g_t\|^2].$$

The Bernoulli reset prevents unbounded variance accumulation: each past gradient norm contributes with **exponentially decaying** weight (factor $1/p$ rather than the linear $q$ growth of fixed-epoch SPIDER).

## Proof
Conditional on $\mathcal{F}_t$:
$$\mathbb{E}[\|e_{t+1}\|^2 | \mathcal{F}_t] = p \cdot 0 + (1-p)\Bigl(\|e_t\|^2 + \mathbb{E}[\|\delta_t\|^2]\Bigr),$$
where $\delta_t$ is the SPIDER correction noise satisfying $\mathbb{E}[\|\delta_t\|^2] \le L^2 \eta^2 \|g_t\|^2 / b'$ (variance $\le$ second moment, individual $L$-smoothness). Use $(1-p) \le 1$ on the noise term, take total expectation, and telescope:
$$V_t \le \frac{L^2 \eta^2}{b'}\sum_{s=0}^{t-1}(1-p)^{t-1-s}\mathbb{E}[\|g_s\|^2].$$
Sum over $t$, swap order, bound the geometric series by $1/p$. $\square$

## Source
- `proofs/research/optimization/stochastic/page-optimal-gradient-complexity/proof.md` — Lemma 2 + Step 2.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (delivers PAGE optimal $O(\sqrt{n}/\varepsilon^2)$ complexity)
- **Potential applications**:
  - PAGE, ProbAbilistic Gradient Estimator analyses
  - Random-restart variance-reduced methods
  - Stochastic methods with adaptive checkpoint/reset frequency
  - Continuous-time analogue: jump-diffusion in optimization
  - Memoryless variance-reduction (no fixed epoch boundaries)

## Tags
PAGE, bernoulli-reset, variance-reduction, geometric-decay, sfo-optimal
