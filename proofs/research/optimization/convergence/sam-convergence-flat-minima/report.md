# Final Report: SAM Convergence to Flat Minima

## Status: PASS

## Problem
Prove that Sharpness-Aware Minimization (SAM) with $\eta = O(1/L)$ and $\rho = O(\eta)$ converges to an $\epsilon$-stationary point of the SAM objective $f^{\mathrm{SAM}}(x) = \max_{\|\delta\|\leq\rho} f(x+\delta)$ at rate $O(1/T)$ for $L$-smooth non-convex $f$.

## Result

**Theorem.** Under $L$-smoothness and $f \geq f^*$, SAM with $\eta = 1/(2L)$ satisfies:

$$\min_{0\leq t < T}\|\nabla f^{\mathrm{SAM}}(x_t)\|^2 \leq \frac{16L(f(x_0)-f^*)}{T} + 12L^2\rho^2.$$

With $\rho = \rho_0/\sqrt{T}$: exact $O(1/T)$ convergence. With fixed $\rho$: $O(1/T)$ convergence to an $O(L^2\rho^2)$-neighborhood.

## Proof Strategy (Route 1 — Winner)

1. **Descent on $f(x_t)$:** Standard descent lemma gives $f(x_{t+1}) \leq f(x_t) - \eta\langle\nabla f(x_t), g_t\rangle + \frac{L\eta^2}{2}\|g_t\|^2$.
2. **Inner product bound:** Since $\|g_t - \nabla f(x_t)\| \leq L\rho$, Young's inequality gives $\langle\nabla f(x_t), g_t\rangle \geq \frac{1}{2}\|g_t\|^2 - \frac{L^2\rho^2}{2}$.
3. **Combine and telescope:** $\frac{1}{T}\sum\|g_t\|^2 \leq \frac{8L\Delta_f}{T} + 2L^2\rho^2$.
4. **Danskin + approximation:** $\|\nabla f^{\mathrm{SAM}}(x_t)\|^2 \leq 2\|g_t\|^2 + 8L^2\rho^2$ since $\|g_t - \nabla f^{\mathrm{SAM}}(x_t)\| \leq 2L\rho$.

## Routes Explored

| Route | Approach | Outcome |
|-------|----------|---------|
| 1 | Direct descent + Young's + Danskin | **PASS** (best constants) |
| 2 | Lyapunov $f(\tilde{x}_t)$ tracking | Correct but 10x worse constants |
| 3 | Two-step: descent on $f$ + case analysis | Correct but 9/4 factor penalty |

## Audit Summary

- All algebraic steps verified correct
- Danskin regularity: minor point, resolved via Clarke generalized gradient
- Parameter conditions $\eta = O(1/L)$, $\rho = O(\eta)$ verified
- $O(1/T)$ rate confirmed under both fixed-$\rho$ and diminishing-$\rho$ interpretations

## Key Techniques

- $L$-smoothness descent lemma
- Young's inequality to decouple perturbation error from gradient norm
- Danskin's theorem for envelope gradient
- Triangle inequality for approximate vs exact perturbation

## Difficulty Assessment
Research level — requires combining standard non-convex optimization analysis with envelope theorem arguments and careful control of the approximation error from the SAM perturbation.
