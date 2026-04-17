# Nesterov's First-Order Lower Bound for Smooth Convex Optimization

## Source
- Paper: Nesterov 2004 "Introductory Lectures on Convex Optimization" (Theorem 2.1.7)
- Context: Fundamental complexity lower bound showing that gradient descent's O(1/k^2) rate (with acceleration) is optimal among first-order methods

## Statement

**Theorem (Nesterov's Lower Bound).** For any $k \le (d-1)/2$ and any first-order method that generates iterates $x_t \in x_0 + \operatorname{span}\{\nabla f(x_0), \nabla f(x_1), \ldots, \nabla f(x_{t-1})\}$, there exists an $L$-smooth convex function $f: \mathbb{R}^d \to \mathbb{R}$ such that:

$$f(x_k) - f(x^*) \ge \frac{3L \|x_0 - x^*\|^2}{32(k+1)^2}.$$

This shows that no first-order method can achieve a rate better than $\Omega(1/k^2)$ on $L$-smooth convex functions, matching the upper bound of Nesterov's accelerated gradient descent up to constants.

## Difficulty
research
