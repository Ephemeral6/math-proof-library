# Notes: Moreau Envelope Smoothness and Gradient Formula

## Proof technique
The winning route was the **Direct Variational / Sandwich Argument** approach (Route 1). This approach works directly from the definition of the Moreau envelope, using the proximal operator's optimality condition and firm nonexpansiveness to establish all properties. The key insight is the symmetric sandwich: testing the prox at $x$ as suboptimal for $x+h$ gives the upper bound, and testing the prox at $x+h$ as suboptimal for $x$ gives the lower bound. Both error terms are $O(\|h\|^2)$, yielding Fréchet differentiability.

This route was preferred over the conjugate calculus approach (Route 3) because it is entirely self-contained and does not invoke the strong convexity-smoothness duality theorem as a black box.

## Key steps
1. **Firm nonexpansiveness of prox** (Step 3): The inequality $\langle \Delta x, \Delta p\rangle \geq \|\Delta p\|^2$ from monotonicity of $\partial f$ is the foundation of the entire proof. It gives both nonexpansiveness of $p_\lambda$ and complementary nonexpansiveness of $\text{Id} - p_\lambda$.
2. **Sandwich argument for differentiability** (Step 6): The upper and lower bounds on $M_\lambda f(x+h) - M_\lambda f(x)$ both have the form $\frac{1}{\lambda}\langle x-p, h\rangle + O(\|h\|^2)$, with the key step being the replacement of $p_h$ by $p$ in the lower bound using nonexpansiveness.
3. **Complementary nonexpansiveness for smoothness** (Step 7): The $\frac{1}{\lambda}$-Lipschitz constant of the gradient follows directly from (CNE), which is a single-line argument once (FNE) is established.

## Audit result
**PASS** on the first round with all 9 steps VALID. Three LOW-severity issues identified, all cosmetic:
- Step 5 could be more explicit about convergence of $\|p_n - x_n\|^2$
- Step 4 could cite a more precise source for affine minorant existence
- Step 9 could note $f(x) < +\infty$ is needed for equality to be non-vacuous

Numerical verification with $f(x) = |x|$, $\lambda = 0.5$, 10000 samples confirmed all properties.

## Related results
- **Proximal gradient method**: The $\frac{1}{\lambda}$-smoothness of $M_\lambda f$ is the theoretical basis for proximal gradient methods with step size $\lambda$.
- **Gradient mapping**: The gradient $\nabla M_\lambda f(x) = \frac{1}{\lambda}(x - \text{prox}_{\lambda f}(x))$ is the "gradient mapping" used as a stationarity measure in nonsmooth optimization.
- **Moreau decomposition**: $x = \text{prox}_{\lambda f}(x) + \lambda \text{prox}_{f^*/\lambda}(x/\lambda)$ (explored in Route 4).
- **Strong convexity-smoothness duality**: $(M_\lambda f)^* = f^* + \frac{\lambda}{2}\|\cdot\|^2$ shows the conjugate is $\lambda$-strongly convex, giving an alternative proof of $\frac{1}{\lambda}$-smoothness (Route 3).
- Related proof in library: `proofs/convex-analysis/subgradient/proximal-gradient-convergence-rate/` uses the Moreau envelope smoothness as a key ingredient.
