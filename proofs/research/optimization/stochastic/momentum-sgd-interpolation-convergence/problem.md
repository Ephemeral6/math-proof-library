# Momentum SGD under Interpolation: Linear Convergence

## Source
- Paper: Related to Vaswani et al. (2019) "Fast and Faster Convergence of SGD for Over-Parameterized Models", Liu & Belkin (2020)
- Context: SGD with Polyak (heavy-ball) momentum under the interpolation condition, proving linear convergence via the variance reduction viewpoint

## Statement

Let $f = \frac{1}{n}\sum_{i=1}^n f_i$ where each $f_i$ is convex and $L$-smooth, $f$ is $\mu$-strongly convex ($\kappa = L/\mu$), and the interpolation condition holds: $\nabla f_i(x^*) = 0$ for all $i$.

Consider SGD with Polyak momentum:
$$v_{t+1} = \beta v_t + \nabla f_{i_t}(x_t), \quad x_{t+1} = x_t - \gamma v_{t+1}$$
with $v_0 = 0$ and $i_t$ uniform on $\{1,\ldots,n\}$.

**Theorem.** With $\gamma = \frac{1}{L}$ and $\beta = \frac{\mu^2}{16L^2}$:

$$\mathbb{E}[\|x_t - x^*\|^2] \leq \left(1 - \frac{\mu}{2L}\right)^t \|x_0 - x^*\|^2.$$

Key properties used:
- $\mathbb{E}_i[\|\nabla f_i(x)\|^2] \leq 2L(f(x)-f^*)$ (interpolation + smoothness)
- $f(x)-f^* \geq \frac{\mu}{2}\|x-x^*\|^2$ (strong convexity)
- $\langle \nabla f_i(x), x-x^*\rangle \geq \frac{1}{L}\|\nabla f_i(x)\|^2$ (co-coercivity from convexity + smoothness + interpolation)

## Difficulty
conjecture
