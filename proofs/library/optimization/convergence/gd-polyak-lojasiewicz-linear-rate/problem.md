# GD with Polyak-Lojasiewicz: Exact Linear Convergence Rate

## Source
- Paper: Polyak 1963; Karimi et al. 2016 "Linear Convergence of Gradient and Proximal-Gradient Methods Under the Polyak-Lojasiewicz Condition"
- Context: PL condition is strictly weaker than strong convexity — does not require convexity. Fundamental result for non-convex optimization with favorable landscape.

## Statement

Let $f: \mathbb{R}^d \to \mathbb{R}$ be $L$-smooth and satisfy the $\mu$-PL condition:

$$\frac{1}{2}\|\nabla f(x)\|^2 \geq \mu(f(x) - f^*)$$

where $f^* = \inf_x f(x)$. Note: $f$ need NOT be convex.

Prove that gradient descent with step size $\eta = 1/L$:

$$x_{k+1} = x_k - \frac{1}{L}\nabla f(x_k)$$

satisfies:

$$f(x_{k+1}) - f^* \leq \left(1 - \frac{\mu}{L}\right)(f(x_k) - f^*)$$

and consequently:

$$f(x_k) - f^* \leq \left(1 - \frac{\mu}{L}\right)^k (f(x_0) - f^*)$$

## Difficulty
research
