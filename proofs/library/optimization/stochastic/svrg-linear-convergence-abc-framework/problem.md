# SVRG Linear Convergence (ABC Framework / Semi-Stochastic Route)

## Source
- Paper: Johnson & Zhang 2013 (NeurIPS), "Accelerating Stochastic Gradient Descent using Predictive Variance Reduction"
- Context: SVRG variance-reduced SGD for finite-sum optimization, proved via the semi-stochastic / ABC framework tracking joint (function gap, distance) recursion

## Statement
Consider $\min_x F(x) = \frac{1}{n}\sum_{i=1}^n f_i(x)$, where each $f_i$ is convex and $L$-smooth, $F$ is $\mu$-strongly convex, $\kappa = L/\mu$.

**SVRG algorithm:** At epoch $s$, set $x_0 = \tilde{x}_s$, compute $\tilde{g} = \nabla F(\tilde{x}_s)$. For $t = 0, \ldots, m-1$: pick $i_t$ uniformly, set $v_t = \nabla f_{i_t}(x_t) - \nabla f_{i_t}(\tilde{x}_s) + \tilde{g}$, update $x_{t+1} = x_t - \eta v_t$. Output $\tilde{x}_{s+1}$ chosen uniformly from $\{x_0, \ldots, x_{m-1}\}$.

**Claim:** With $\eta = \frac{1}{10L}$ and $m = 20\kappa$:

$$\mathbb{E}[F(\tilde{x}_{s+1})] - F(x^*) \leq \frac{1}{2}\left[\mathbb{E}[F(\tilde{x}_s)] - F(x^*)\right].$$

## Difficulty
advanced
