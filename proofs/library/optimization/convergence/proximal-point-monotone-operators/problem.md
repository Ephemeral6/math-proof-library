# Proximal Point Method: Convergence Rate for Maximal Monotone Operators

## Source
- Paper: Rockafellar 1976; Bauschke & Combettes 2017
- Context: Fundamental iteration for monotone inclusions, basis of many splitting algorithms (ADMM, Douglas-Rachford, etc.)

## Statement

For a maximal monotone operator $T: \mathbb{R}^d \rightrightarrows \mathbb{R}^d$, the proximal point iteration is:

$$x_{k+1} = J_{\eta T}(x_k) = (I + \eta T)^{-1}(x_k)$$

where $\eta > 0$ is the step size and $J_{\eta T}$ is the resolvent of $\eta T$.

Assume $T^{-1}(0) \neq \emptyset$ (a zero exists). Let $x^* \in T^{-1}(0)$.

**Prove:**

**(a)** Fejér monotonicity: $\|x_{k+1} - x^*\| \leq \|x_k - x^*\|$ for all $k \geq 0$.

**(b)** Resolvent residual rate:
$$\min_{0 \leq j \leq k} \|x_j - x_{j+1}\| \leq \frac{\|x_0 - x^*\|}{\sqrt{k+1}}$$

**(c)** Function value rate (when $T = \partial f$ for convex $f$):
$$f(x_k) - f(x^*) \leq \frac{\|x_0 - x^*\|^2}{2\eta k}$$

**Note**: The originally posed bound $\|x_k - x^*\| \leq \|x_0 - x^*\|/\sqrt{k+1}$ is false in general; a counterexample is provided.

## Difficulty
research
