# Chambolle-Pock PDHG O(1/N) Saddle-Point Convergence

## Source
- Paper: A. Chambolle, T. Pock, "A first-order primal-dual algorithm for convex problems with applications to imaging", JMIV 2011; "On the ergodic convergence rates of a first-order primal-dual algorithm", Math. Programming, 2016.
- Context: PDHG is one of the most widely used first-order methods for structured convex optimization. This theorem establishes the O(1/N) ergodic convergence rate for the restricted primal-dual gap.

## Statement

Let $\mathcal{X}, \mathcal{Y}$ be finite-dimensional real Hilbert spaces. Consider:

$$\min_{x \in \mathcal{X}} \max_{y \in \mathcal{Y}} \; \langle Kx, y \rangle + g(x) - f^*(y)$$

where $K: \mathcal{X} \to \mathcal{Y}$ bounded linear with $\|K\| = L$, $g$ and $f^*$ proper convex lsc.

**PDHG** with $\tau\sigma L^2 < 1$, $\bar{x}^0 = x^0$:
$$y^{n+1} = \mathrm{prox}_{\sigma f^*}(y^n + \sigma K\bar{x}^n), \quad x^{n+1} = \mathrm{prox}_{\tau g}(x^n - \tau K^* y^{n+1}), \quad \bar{x}^{n+1} = 2x^{n+1} - x^n$$

**Theorem.** The ergodic averages $X^N = \frac{1}{N}\sum_{n=1}^N x^n$, $Y^N = \frac{1}{N}\sum_{n=1}^N y^n$ satisfy:

$$\mathcal{G}_{\mathcal{B}}(X^N, Y^N) \leq \frac{1}{N}\left(\frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma}\right) \quad \forall (x,y) \in \mathcal{B}$$

## Difficulty
research
