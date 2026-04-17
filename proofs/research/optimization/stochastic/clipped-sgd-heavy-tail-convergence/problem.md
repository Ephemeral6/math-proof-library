# Convergence of Clipped SGD under Heavy-Tailed Noise

## Source
- Paper: Zhang, Chen, Lee, Flammarion (ICML 2020); Gorbunov, Horváth, Richtárik, Gidel (2020)
- Context: Heavy-tailed gradient noise in SGD, gradient clipping analysis for non-convex optimization

## Statement

Let $f:\mathbb{R}^d \to \mathbb{R}$ be $L$-smooth (possibly non-convex), $f^* = \inf_x f(x) > -\infty$, $\Delta_f = f(x_0) - f^*$.

Consider clipped SGD:
$$x_{t+1} = x_t - \eta \cdot \mathrm{clip}(g_t, \tau), \qquad \mathrm{clip}(g, \tau) = g \cdot \min\!\left(1,\, \frac{\tau}{\|g\|}\right)$$

where $g_t = \nabla f(x_t) + \xi_t$ satisfies:
- $\mathbb{E}[\xi_t \mid x_t] = 0$ (unbiasedness),
- $\mathbb{E}[\|\xi_t\|^p \mid x_t] \le \sigma^p$ for some $p \in (1, 2]$ (heavy-tailed $p$-th moment bound).

**Theorem.** Set $\tau = \sigma T^{1/p - 1/2}$ and $\eta = \frac{\sqrt{\Delta_f}}{\sqrt{L}\,\tau\sqrt{T}}$. Assume $T$ large enough that $\tau \ge 2\sigma$ and $L\eta \le 1/2$. Then:

$$\frac{1}{T}\sum_{t=0}^{T-1} \mathbb{E}\bigl[\|\nabla f(x_t)\|^2\bigr] \le O\!\left(\frac{\Delta_f L + L\sigma^2}{T^{1-1/p}}\right).$$

## Difficulty
research
