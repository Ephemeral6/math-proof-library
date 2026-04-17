# Lookahead Optimizer: Convergence Guarantee on Quadratics

## Source
- Paper: Zhang et al. 2019 (Lookahead Optimizer: k steps forward, 1 step back)
- Context: Convergence analysis of Lookahead wrapper on quadratic objectives, establishing both convergence rate and variance reduction properties

## Statement

Consider the Lookahead optimizer applied to a quadratic $f(x) = \frac{1}{2}x^TAx$ where $A \in \mathbb{R}^{d \times d}$ is symmetric positive definite with $\mu I \preceq A \preceq LI$. The inner optimizer runs $k$ steps of (stochastic) gradient descent with step size $\eta$ from slow weights $\phi_t$ to get fast weights $\theta_t$, then:
$$\phi_{t+1} = \phi_t + \alpha(\theta_t - \phi_t)$$

**Part 1 (Convergence Rate):** The convergence rate of the outer iterates $\phi_t$ is
$$\rho = 1 - \alpha(1 - (1 - \eta\mu)^k)$$
per outer step, assuming $0 < \eta \leq 1/L$ and $0 < \alpha \leq 1$.

**Part 2 (Variance Reduction):** In the stochastic setting with i.i.d. zero-mean gradient noise, Lookahead reduces variance by a factor of $\alpha^2 k$ compared to an equivalent single-step method with the same contraction rate.

## Difficulty
Research
