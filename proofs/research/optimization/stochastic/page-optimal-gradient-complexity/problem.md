# PAGE Optimal Gradient Complexity for Non-Convex Finite-Sum

## Source
- Paper: "PAGE: A Simple and Optimal Probabilistic Gradient Estimator for Nonconvex Optimization" (Li, Huo, Chen, 2021, ICML Best Paper)
- Context: PAGE unifies SPIDER and STORM by introducing a probabilistic gradient estimator. It achieves the information-theoretically optimal gradient complexity for non-convex finite-sum optimization.

## Statement

Consider $\min_{x \in \mathbb{R}^d} f(x) = \frac{1}{n}\sum_{i=1}^n f_i(x)$ where each $f_i$ is $L$-smooth and $f^* = \inf_x f(x) > -\infty$.

**PAGE Algorithm:**
- Initialize $x_0$, compute $g_0 = \nabla f(x_0)$
- For $t = 0, \ldots, T-1$:
  - $x_{t+1} = x_t - \eta g_t$
  - With probability $p$: $g_{t+1} = \nabla f(x_{t+1})$ (full gradient reset)
  - With probability $1-p$: $g_{t+1} = g_t + \frac{1}{b'}\sum_{i \in \mathcal{B}'_t}[\nabla f_i(x_{t+1}) - \nabla f_i(x_t)]$

**Theorem.** With $b' = \sqrt{n}$, $p = 1/\sqrt{n}$, $\eta = 1/(2L\sqrt{n})$:
$$\frac{1}{T}\sum_{t=0}^{T-1} \mathbb{E}[\|\nabla f(x_t)\|^2] \leq \frac{4L\sqrt{n} \cdot \Delta_0}{T}$$

Total SFO complexity: $O(n + \sqrt{n}/\varepsilon^2)$ — matching the lower bound $\Omega(n + \sqrt{n}/\varepsilon^2)$.

## Difficulty
research
