# GD on Non-Convex L-Smooth Functions: Convergence to Approximate Stationary Point

## Source
- Paper: Standard result in non-convex optimization (Nesterov 2004, Chapter 1)
- Context: Fundamental convergence guarantee for gradient descent on non-convex smooth functions — GD finds approximate stationary points at rate O(1/sqrt(T))

## Statement

Let $f: \mathbb{R}^d \to \mathbb{R}$ be $L$-smooth (possibly non-convex) with $f^* = \inf_x f(x) > -\infty$.

Prove that gradient descent with step size $\eta = 1/L$:

$$x_{k+1} = x_k - \frac{1}{L}\nabla f(x_k)$$

satisfies:

$$\min_{0 \leq k \leq T-1} \|\nabla f(x_k)\|^2 \leq \frac{2L(f(x_0) - f^*)}{T}$$

## Difficulty
research
