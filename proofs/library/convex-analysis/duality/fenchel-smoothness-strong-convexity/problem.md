# Fenchel Smoothness-Strong Convexity Duality

## Source
- Paper: Rockafellar 1970; Hiriart-Urruty & Lemaréchal 2001
- Context: Fundamental duality in convex analysis relating smoothness of a convex function to strong convexity of its Fenchel conjugate

## Statement

Let $f: \mathbb{R}^n \to \mathbb{R}$ be a closed convex function, differentiable on $\mathbb{R}^n$, with $L$-Lipschitz continuous gradient:
$$\|\nabla f(x) - \nabla f(y)\| \leq L\|x - y\| \quad \forall\, x, y \in \mathbb{R}^n.$$

Then its Fenchel conjugate $f^*(y) = \sup_x [\langle y, x\rangle - f(x)]$ satisfies:

1. $\partial f^* = (\nabla f)^{-1}$ (set-valued inverse): the subdifferential of $f^*$ at $y$ equals the set of $x$ with $\nabla f(x) = y$.
2. $f^*$ is $(1/L)$-strongly convex on $\text{dom}(f^*)$:
$$f^*(y) \geq f^*(y') + \langle \xi, y - y'\rangle + \frac{1}{2L}\|y - y'\|^2 \quad \forall\, \xi \in \partial f^*(y').$$

Conversely, $(1/L)$-strong convexity of $f^*$ implies $L$-smoothness of $f$.

## Difficulty
research
