# SARAH/SPIDER Variance Reduction: Non-convex Complexity

## Source
- Paper: Fang et al. 2018 (SPIDER) / Nguyen et al. 2017 (SARAH)
- Context: Variance-reduced stochastic gradient method for non-convex optimization

## Statement
Consider the finite-sum problem $f(x) = \frac{1}{n}\sum_{i=1}^n f_i(x)$ where each $f_i$ is $L$-smooth, and $f^* = \inf_x f(x) > -\infty$. The SPIDER/SARAH estimator uses recursive variance reduction:

$$v_t = \nabla f_{i_t}(x_t) - \nabla f_{i_t}(x_{t-1}) + v_{t-1}$$

with periodic full-gradient resets $v_0 = \nabla f(x_0)$ every $q$ steps, and gradient descent updates $x_{t+1} = x_t - \eta v_t$.

**Theorem**: To find an $\epsilon$-stationary point ($\mathbb{E}[\|\nabla f(\hat{x})\|^2] \leq \epsilon^2$), SPIDER requires
$$O\left(n + \frac{\sqrt{n}}{\epsilon^2}\right)$$
stochastic gradient evaluations (treating $L, \Delta_f = f(x_0) - f^*$ as constants), improving over SGD's $O(1/\epsilon^4)$.

## Difficulty
research
