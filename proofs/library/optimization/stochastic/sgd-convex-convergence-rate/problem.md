# SGD O(1/√T) Convergence for Convex Functions

## Source
- Paper: Classical result; Bubeck 2015; Shalev-Shwartz & Ben-David 2014
- Problem Bank: A7
- Context: Fundamental SGD convergence result for convex optimization with bounded noise

## Statement

Let $f:\mathbb{R}^d \to \mathbb{R}$ be convex with minimizer $x^*$, $f^* = f(x^*)$. Consider SGD: $x_{t+1} = x_t - \eta g_t$ where $\mathbb{E}[g_t|x_t] = \nabla f(x_t)$ and $\mathbb{E}[\|g_t\|^2|x_t] \leq \sigma^2$ (bounded second moment).

With constant step size $\eta = c/\sqrt{T}$, the averaged iterate $\bar{x}_T = \frac{1}{T}\sum_{t=0}^{T-1} x_t$ satisfies:

$$\mathbb{E}[f(\bar{x}_T)] - f^* \leq \frac{\|x_0-x^*\|^2}{2c\sqrt{T}} + \frac{c\sigma^2}{2\sqrt{T}}$$

Optimizing over $c$ gives $c^* = \|x_0-x^*\|/\sigma$ and rate $\|x_0-x^*\|\sigma/\sqrt{T}$.

## Difficulty
research
