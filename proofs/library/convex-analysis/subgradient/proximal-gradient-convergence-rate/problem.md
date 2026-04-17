# Proximal Gradient Method Convergence (Composite Optimization)

## Source
- Context: Fundamental convergence result for proximal gradient methods in composite optimization
- Standard reference in convex optimization theory

## Statement

Consider the composite optimization problem:

$$\min_{x \in \mathbb{R}^d} \; F(x) = f(x) + g(x)$$

where:
- $f$ is convex and $L$-smooth (i.e., $\nabla f$ is $L$-Lipschitz continuous)
- $g$ is convex, proper, lower semi-continuous (possibly non-smooth, e.g., $g(x) = \lambda \|x\|_1$)

The proximal gradient method updates:

$$x_{t+1} = \mathrm{prox}_{\eta g}(x_t - \eta \nabla f(x_t))$$

where $\eta = 1/L$ and $\mathrm{prox}_{\eta g}(y) = \arg\min_{x} \left\{ g(x) + \frac{1}{2\eta}\|x - y\|^2 \right\}$.

**Theorem.** Prove that:

$$F(x_T) - F(x^*) \leq \frac{L \|x_0 - x^*\|^2}{2T}$$

where $x^*$ is a minimizer of $F$.

## Difficulty
research
