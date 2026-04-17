# STORM Estimator Non-Convex Convergence Rate

## Source
- Paper: Cutkosky & Orabona, "Momentum-Based Variance Reduction in Non-Convex SGD", NeurIPS 2019
- Context: Optimal single-sample variance reduction for non-convex stochastic optimization

## Statement

Consider $\min_{x \in \mathbb{R}^d} f(x)$ where $f(x) = \mathbb{E}_{\xi}[F(x;\xi)]$. The STORM algorithm:

$$d_t = (1-a_t) d_{t-1} + a_t \nabla F(x_t;\xi_t) + (1-a_t)(\nabla F(x_t;\xi_t) - \nabla F(x_{t-1};\xi_t))$$
$$x_{t+1} = x_t - \eta d_t$$

with $a_t = c\eta^2$ for constant $c > 0$, mini-batch initialization $d_0 = \frac{1}{B}\sum_{i=1}^B \nabla F(x_0;\xi_0^{(i)})$, $B = \lceil 1/a \rceil$.

**Assumptions:**
1. $f$ is $L$-smooth: $\|\nabla f(x) - \nabla f(y)\| \leq L\|x-y\|$
2. Bounded variance: $\mathbb{E}\|\nabla F(x;\xi) - \nabla f(x)\|^2 \leq \sigma^2$
3. Mean-squared smoothness: $\mathbb{E}\|\nabla F(x;\xi) - \nabla F(y;\xi)\|^2 \leq L_1^2\|x-y\|^2$
4. $f^* = \inf_x f(x) > -\infty$

**Claim:** With $c = 4L_1^2$, $\eta = \min\{1/(2\max(L,L_1)), (\Delta/(4L_1^2\sigma^2 T))^{1/3}\}$:

$$\frac{1}{T}\sum_{t=0}^{T-1}\mathbb{E}\|\nabla f(x_t)\|^2 = O\left(\frac{L_1^{2/3}\sigma^{2/3}\Delta^{2/3}}{T^{2/3}} + \frac{\max(L,L_1)\Delta}{T}\right)$$

where $\Delta = f(x_0) - f^*$. Total oracle complexity: $O(T)$.

## Difficulty
research
