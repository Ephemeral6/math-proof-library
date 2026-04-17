# Momentum SGD Linear Convergence via Spectral Analysis

## Source
- Paper: Relates to Loizou et al. 2021 (SPS), Vaswani et al. 2019, Liu & Belkin 2020
- Context: Spectral analysis route for heavy ball SGD under interpolation; integral Hessian linearization + Kronecker product second-moment operator

## Statement

Let $f = \frac{1}{n}\sum_{i=1}^n f_i$ where each $f_i$ is convex and $L$-smooth, $f$ is $\mu$-strongly convex ($\kappa = L/\mu$), and interpolation holds: $\nabla f_i(x^*) = 0$ for all $i$.

SGD with Polyak momentum:
$$v_{t+1} = \beta v_t + \nabla f_{i_t}(x_t), \quad x_{t+1} = x_t - \gamma v_{t+1}$$

**Theorem.** With $\gamma = \frac{1}{2L}$ and $\beta = \frac{1}{\kappa}$:
$$\mathbb{E}[\|x_t - x^*\|^2] \leq C\left(1 - \frac{5}{16\kappa}\right)^t \|x_0 - x^*\|^2$$

where $C$ depends on initial conditions. More generally, for any $\gamma \leq \frac{1}{2L}$ and $\beta$ satisfying $\beta^2(1 + \frac{4(1+\gamma L)^2}{\gamma\mu}) < 1$, linear convergence holds.

## Difficulty
advanced
