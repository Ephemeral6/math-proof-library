# SGD with Polyak Momentum under Interpolation: Linear Convergence

## Source
- Paper: Relates to Loizou et al. 2021 (SPS), Vaswani et al. 2019 (interpolation framework)
- Context: Stochastic heavy ball under interpolation and strong convexity; PL + joint Lyapunov analysis

## Statement

Let $f = \frac{1}{n}\sum_{i=1}^n f_i$ where each $f_i$ is convex and $L$-smooth, $f$ is $\mu$-strongly convex ($\kappa = L/\mu$), and the interpolation condition holds: $\nabla f_i(x^*) = 0$ for all $i$.

SGD with Polyak momentum:
$$v_{t+1} = \beta v_t + \nabla f_{i_t}(x_t), \quad x_{t+1} = x_t - \gamma v_{t+1}$$
where $i_t \sim \text{Uniform}\{1,\ldots,n\}$.

**Theorem.** With step size $\gamma = \frac{\mu}{2L^2}$ and momentum $\beta = \frac{\mu^2}{4L^2}$, for $\kappa \geq 3$:
$$\mathbb{E}[\|x_t - x^*\|^2] \leq C\left(1 - \frac{1}{16\kappa^2}\right)^t \|x_0 - x^*\|^2$$
where $C = 1 + \frac{\gamma^2}{\kappa^2} \cdot \frac{\|v_0\|^2}{\|x_0 - x^*\|^2}$ (with $C = 1$ when $v_0 = 0$).

## Difficulty
advanced
