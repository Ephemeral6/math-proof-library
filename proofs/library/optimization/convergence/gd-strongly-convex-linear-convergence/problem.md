# Gradient Descent Linear Convergence for Strongly Convex Functions

## Source
- Paper: Nesterov 2004 "Introductory Lectures on Convex Optimization" Theorem 2.1.15; Bubeck 2015 survey
- Context: The fundamental convergence rate for gradient descent on smooth strongly convex functions

## Statement

**Theorem.** Let $f: \mathbb{R}^d \to \mathbb{R}$ be $\mu$-strongly convex and $L$-smooth (i.e., $\mu I \preceq \nabla^2 f(x) \preceq LI$ for all $x$). Consider gradient descent with step size $\eta = \frac{1}{L}$:

$$x_{k+1} = x_k - \frac{1}{L}\nabla f(x_k).$$

Then:

(a) **Function value convergence:**
$$f(x_k) - f(x^*) \leq \left(1 - \frac{\mu}{L}\right)^k (f(x_0) - f(x^*)).$$

(b) **Iterate convergence:**
$$\|x_k - x^*\|^2 \leq \left(1 - \frac{\mu}{L}\right)^k \|x_0 - x^*\|^2.$$

The condition number $\kappa = L/\mu$ determines the convergence rate. The number of iterations to reach $\varepsilon$-accuracy is $O(\kappa \log(1/\varepsilon))$.

## Difficulty
advanced
