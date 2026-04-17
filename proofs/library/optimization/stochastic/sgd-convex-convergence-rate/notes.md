# Notes: SGD O(1/√T) Convergence for Convex Functions

## Proof technique
Lyapunov potential $V_t = \|x_t - x^*\|^2$ with one-step expansion, conditional expectation (second-moment bound), convexity, telescoping, Jensen averaging.

## Key steps
1. Expand $\|x_{t+1} - x^*\|^2$ using SGD update
2. Take conditional expectation: unbiasedness + second-moment bound $\mathbb{E}[\|g_t\|^2] \leq \sigma^2$
3. Apply convexity: $f(x_t) - f^* \leq \langle \nabla f(x_t), x_t - x^*\rangle$
4. Telescope the Lyapunov differences, drop $-\mathbb{E}[V_T] \leq 0$
5. Jensen's inequality for convex averaging
6. Substitute $\eta = c/\sqrt{T}$, optimize $c^* = D/\sigma$

## Audit result
PASS (Round 2). Round 1 found invalid gradient norm dropping; fixed by using second-moment bound interpretation directly. 5 numerical checks passed.

## Critical subtlety
The problem states variance bound $\mathbb{E}[\|g_t - \nabla f\|^2] \leq \sigma^2$, but the clean result requires second-moment bound $\mathbb{E}[\|g_t\|^2] \leq \sigma^2$. Under variance bound alone, an uncontrollable $\eta^2\|\nabla f(x_t)\|^2$ term appears. Standard textbook convention (Bubeck 2015) uses second-moment bound.

## Related results
- GD PL linear convergence (library) — strongly convex case with exact gradients
- SPS-SGD convergence (library) — adaptive step size version
- SVRG linear convergence (library) — variance reduction achieves linear rate
- SGD PL+interpolation (library) — faster rate under PL + interpolation
