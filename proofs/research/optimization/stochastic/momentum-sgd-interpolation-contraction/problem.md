# SGD with Polyak Momentum: Linear Convergence under Interpolation

## Source
- Paper: Related to Vaswani et al. 2019 (AISTATS), Liu & Belkin 2020
- Context: SGD with heavy-ball momentum under interpolation condition; convergence analysis via contraction mapping in weighted joint (position, momentum) space

## Statement

Let $f = \frac{1}{n}\sum_{i=1}^n f_i$ where each $f_i$ is convex and $L$-smooth, $f$ is $\mu$-strongly convex ($\kappa = L/\mu$), and the interpolation condition holds: $\nabla f_i(x^*) = 0$ for all $i$.

Consider SGD with Polyak (heavy-ball) momentum with $v_0 = 0$:
$$v_{t+1} = \beta v_t + \nabla f_{i_t}(x_t), \quad x_{t+1} = x_t - \gamma v_{t+1}$$

**Theorem.** With $\gamma = \frac{1}{4L}$ and $\beta = \frac{\mu}{8L}$, there exists $\rho < 1$ such that
$$\mathbb{E}[\|x_t - x^*\|^2] \leq \rho^t \|x_0 - x^*\|^2$$
where $\rho = 1 - \frac{1}{4\kappa} + \frac{1}{32\kappa^2} < 1$.

## Difficulty
advanced
