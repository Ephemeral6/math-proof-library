# Proof via Direct Quadratic Bound Recursion

**Route**: Direct Quadratic Upper Bound Recursion

## Setup

Let $f: \mathbb{R}^d \to \mathbb{R}$ be $\mu$-strongly convex and $L$-smooth. Minimizer: $x^* = \arg\min f$. GD: $x_{k+1} = x_k - \frac{1}{L}\nabla f(x_k)$.

## Part (a): Function Value Convergence

### Step 1: Sufficient Decrease from L-smoothness

By L-smoothness (quadratic upper bound), for any $x, y$:
$$f(y) \leq f(x) + \langle \nabla f(x), y - x \rangle + \frac{L}{2}\|y - x\|^2.$$

With $y = x_{k+1} = x_k - \frac{1}{L}\nabla f(x_k)$:
$$f(x_{k+1}) \leq f(x_k) - \frac{1}{L}\|\nabla f(x_k)\|^2 + \frac{L}{2} \cdot \frac{1}{L^2}\|\nabla f(x_k)\|^2 = f(x_k) - \frac{1}{2L}\|\nabla f(x_k)\|^2.$$

### Step 2: Strong Convexity Lower Bound at Optimum

By $\mu$-strong convexity at $x = x_k$ with $y = x^*$:
$$f(x^*) \geq f(x_k) + \langle \nabla f(x_k), x^* - x_k \rangle + \frac{\mu}{2}\|x^* - x_k\|^2.$$

Rearranging:
$$f(x_k) - f(x^*) \leq \langle \nabla f(x_k), x_k - x^* \rangle - \frac{\mu}{2}\|x_k - x^*\|^2.$$

### Step 3: Applying Young's Inequality

For any $\alpha > 0$, by Young's inequality:
$$\langle \nabla f(x_k), x_k - x^* \rangle \leq \frac{1}{2\alpha}\|\nabla f(x_k)\|^2 + \frac{\alpha}{2}\|x_k - x^*\|^2.$$

Substituting into Step 2 with $\alpha = \mu$:
$$f(x_k) - f(x^*) \leq \frac{1}{2\mu}\|\nabla f(x_k)\|^2 + \frac{\mu}{2}\|x_k - x^*\|^2 - \frac{\mu}{2}\|x_k - x^*\|^2 = \frac{1}{2\mu}\|\nabla f(x_k)\|^2.$$

This recovers the PL inequality: $\|\nabla f(x_k)\|^2 \geq 2\mu(f(x_k) - f(x^*))$.

### Step 4: Contraction

From Steps 1 and 3:
$$f(x_{k+1}) \leq f(x_k) - \frac{1}{2L}\|\nabla f(x_k)\|^2 \leq f(x_k) - \frac{\mu}{L}(f(x_k) - f(x^*)).$$

Therefore:
$$f(x_{k+1}) - f(x^*) \leq (f(x_k) - f(x^*)) - \frac{\mu}{L}(f(x_k) - f(x^*)) = \left(1 - \frac{\mu}{L}\right)(f(x_k) - f(x^*)).$$

By induction:
$$f(x_k) - f(x^*) \leq \left(1 - \frac{\mu}{L}\right)^k(f(x_0) - f(x^*)). \quad \blacksquare$$

## Part (b): Iterate Convergence

### Step 5: Direct Recursion on ‖x_k - x*‖²

$$\|x_{k+1} - x^*\|^2 = \|x_k - x^* - \frac{1}{L}\nabla f(x_k)\|^2$$
$$= \|x_k - x^*\|^2 - \frac{2}{L}\langle \nabla f(x_k), x_k - x^* \rangle + \frac{1}{L^2}\|\nabla f(x_k)\|^2.$$

### Step 6: Using Strong Convexity and Smoothness Together

For $\mu$-strongly convex and $L$-smooth $f$, we have the following inequality (from the convex interpolation conditions):
$$\langle \nabla f(x) - \nabla f(y), x - y \rangle \geq \frac{1}{L}\|\nabla f(x) - \nabla f(y)\|^2 + \mu\|x - y\|^2 \cdot \frac{L - \mu}{L + \mu} + \frac{\mu}{L+\mu} \cdot \text{(cross terms)}.$$

Actually, let us use a simpler and more direct approach. We use just the L-smoothness cocoercivity:
$$\langle \nabla f(x) - \nabla f(y), x - y \rangle \geq \frac{1}{L}\|\nabla f(x) - \nabla f(y)\|^2$$

which holds for any convex $L$-smooth function (Baillon-Haddad theorem). With $y = x^*$, $\nabla f(x^*) = 0$:
$$\langle \nabla f(x_k), x_k - x^* \rangle \geq \frac{1}{L}\|\nabla f(x_k)\|^2.$$

Substituting into Step 5:
$$\|x_{k+1} - x^*\|^2 \leq \|x_k - x^*\|^2 - \frac{2}{L} \cdot \frac{1}{L}\|\nabla f(x_k)\|^2 + \frac{1}{L^2}\|\nabla f(x_k)\|^2$$
$$= \|x_k - x^*\|^2 - \frac{1}{L^2}\|\nabla f(x_k)\|^2.$$

Now using PL: $\|\nabla f(x_k)\|^2 \geq 2\mu(f(x_k) - f(x^*)) \geq 2\mu \cdot \frac{\mu}{2}\|x_k - x^*\|^2 = \mu^2\|x_k - x^*\|^2$.

(The second inequality follows from strong convexity: $f(x_k) - f(x^*) \geq \frac{\mu}{2}\|x_k - x^*\|^2$.)

Therefore:
$$\|x_{k+1} - x^*\|^2 \leq \|x_k - x^*\|^2 - \frac{\mu^2}{L^2}\|x_k - x^*\|^2 = \left(1 - \frac{\mu^2}{L^2}\right)\|x_k - x^*\|^2.$$

By induction:
$$\|x_k - x^*\|^2 \leq \left(1 - \frac{\mu^2}{L^2}\right)^k \|x_0 - x^*\|^2.$$

**Note**: This gives contraction rate $(1 - 1/\kappa^2)$ for iterates, which is weaker than the $(1 - 1/\kappa)$ rate claimed in the theorem and weaker than the $(\kappa-1)/(\kappa+1)$ rate from Route 2. The issue is that this route uses weaker intermediate inequalities. The tighter iterate bound requires the stronger interpolation inequality from Route 2.

However, since $1 - \mu^2/L^2 = (1-\mu/L)(1+\mu/L) \leq 2(1 - \mu/L)$ for $\mu \leq L$, this still gives $O(\kappa^2 \log(1/\varepsilon))$ iterate complexity instead of the optimal $O(\kappa \log(1/\varepsilon))$.

## Route Limitation

This route successfully proves part (a) with the sharp rate $(1-\mu/L)^k$, but for part (b) only achieves the weaker rate $(1-\mu^2/L^2)^k$. To get the sharp iterate convergence rate, one needs the stronger interpolation inequality used in Route 2.

$\blacksquare$ (partial — sharp for part (a), suboptimal for part (b))
