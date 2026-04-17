# Randomized Coordinate Descent O(nL̄/ε) Rate

## Source
- Paper: Nesterov 2012 (Efficiency of coordinate descent methods); Wright 2015 survey
- Context: Randomized coordinate descent with coordinate-wise Lipschitz constants for smooth convex optimization

## Statement

Let $f:\mathbb{R}^n \to \mathbb{R}$ be convex with coordinate-wise separable smoothness:
$$f(x + h) \leq f(x) + \langle \nabla f(x), h \rangle + \frac{1}{2}\sum_{i=1}^n L_i h_i^2, \quad \forall x, h \in \mathbb{R}^n$$

Consider randomized coordinate descent: at each step, pick $i_t \sim \text{Uniform}\{1,\ldots,n\}$ and update:
$$x_{t+1} = x_t - \frac{1}{L_{i_t}}\nabla_{i_t} f(x_t) \cdot e_{i_t}$$

Let $\bar{L} = \frac{1}{n}\sum_{i=1}^n L_i$. Then after $T$ iterations:

**Tight bound (weighted norm)**:
$$\mathbb{E}[f(x_T) - f^*] \leq \frac{n\|x_0 - x^*\|_L^2}{T + n}$$

where $\|x\|_L^2 = \sum_{i=1}^n L_i x_i^2$.

**Euclidean norm form**:
$$\mathbb{E}[f(x_T) - f^*] \leq \frac{n^2\bar{L}\|x_0 - x^*\|^2}{T + n}$$

This gives an iteration complexity of $O(n\|x_0-x^*\|_L^2/\varepsilon)$ for $\varepsilon$-accuracy.

## Difficulty
research
