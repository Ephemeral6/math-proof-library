# Proximal Point Method: Convergence for Monotone Operators

## Source
- Paper: Rockafellar 1976; Bauschke & Combettes 2017
- Problem Bank: A6
- Context: Fundamental iteration for monotone inclusions, basis of many splitting algorithms

## Statement

For a maximal monotone operator $T: \mathbb{R}^d \rightrightarrows \mathbb{R}^d$, the proximal point iteration is:
$$x_{k+1} = J_{\eta T}(x_k) = (I + \eta T)^{-1}(x_k)$$
where $\eta > 0$ and $T^{-1}(0) \neq \emptyset$. Let $x^* \in T^{-1}(0)$.

**Original claim** (false): $\|x_k - x^*\| \leq \|x_0 - x^*\|/\sqrt{k+1}$

**Corrected results**:
- (a) Fejér monotonicity: $\|x_{k+1} - x^*\| \leq \|x_k - x^*\|$
- (b) Residual rate: $\min_{j \leq k} \|x_j - x_{j+1}\| \leq \|x_0 - x^*\|/\sqrt{k+1}$
- (c) Function value rate (when $T = \partial f$): $f(x_k) - f(x^*) \leq \|x_0 - x^*\|^2/(2\eta k)$

## Difficulty
research
