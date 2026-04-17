# Nesterov's Accelerated Gradient Descent O(1/k²) Convergence

## Source
- Paper: Nesterov 1983 (original), Nesterov 2004 "Introductory Lectures" Theorem 2.2.2
- Context: The optimal first-order method for smooth convex optimization, matching the Omega(1/k²) lower bound

## Statement

**Theorem (Nesterov's Accelerated Gradient).** Let $f: \mathbb{R}^d \to \mathbb{R}$ be convex with $L$-Lipschitz continuous gradient. Consider the accelerated gradient method (three-sequence form):

$$z_0 = x_0, \quad y_k = \frac{k}{k+2}x_k + \frac{2}{k+2}z_k$$
$$x_{k+1} = y_k - \frac{1}{L}\nabla f(y_k), \quad z_{k+1} = z_k - \frac{k+1}{2L}\nabla f(y_k)$$

with $x_0$ arbitrary. Then for all $k \geq 1$:

$$f(x_k) - f(x^*) \leq \frac{2L\|x_0 - x^*\|^2}{k(k+1)} = O\!\left(\frac{L\|x_0 - x^*\|^2}{k^2}\right)$$

This matches (up to constants) the $\Omega(1/k^2)$ lower bound for first-order methods on $L$-smooth convex functions.

## Difficulty
research
