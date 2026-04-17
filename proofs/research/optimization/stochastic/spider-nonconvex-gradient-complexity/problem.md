# SPIDER Near-Optimal Nonconvex Gradient Complexity

## Source
- Paper: SPIDER: Near-Optimal Non-Convex Optimization via Stochastic Path Integrated Differential Estimator (Fang et al. 2018, NeurIPS)
- Context: Optimal gradient complexity for finding stationary points of nonconvex finite-sum problems

## Statement
Let $f = \frac{1}{n}\sum_{i=1}^n f_i$ where each $f_i$ is $L$-smooth (not necessarily convex), $f^* = \inf f > -\infty$, $\Delta_0 = f(x_0) - f^*$.

SPIDER algorithm with epoch output $x_0^{(k+1)} = x_q^{(k)}$, parameters $\eta = \frac{1}{2L}$, $b = q = \lceil\sqrt{n}\rceil$, finds $\hat{x}$ satisfying
$$\mathbb{E}[\|\nabla f(\hat{x})\|^2] \leq \epsilon^2$$
using $O\!\left(n + \frac{L\Delta_0\sqrt{n}}{\epsilon^2}\right)$ total stochastic gradient evaluations.

This matches the lower bound $\Omega(\sqrt{n}/\epsilon^2)$ for finite-sum nonconvex optimization.

## Difficulty
Advanced
