# Notes: SAM Convergence to Flat Minima

## Proof technique
Route 1 (Direct descent + Young's inequality + Danskin) won because it provides the tightest constants and most direct argument. The key insight is treating the SAM gradient $g_t = \nabla f(\tilde{x}_t)$ as a perturbed version of $\nabla f(x_t)$ with error bounded by $L\rho$, then using Young's inequality to avoid any dependence on $\|\nabla f(x_t)\|$ in the denominator.

## Key steps
1. **Descent lemma on $f$:** The SAM update still decreases $f(x_t)$ because the SAM gradient $g_t$ is correlated with $\nabla f(x_t)$ (they differ by at most $L\rho$).
2. **Young's inequality decoupling:** The cross-term $L\rho\|g_t\|$ is bounded by $\frac{1}{2}\|g_t\|^2 + \frac{L^2\rho^2}{2}$, which cleanly separates into a term absorbable into the descent and a constant bias.
3. **Danskin's theorem:** Connects $\nabla f^{\mathrm{SAM}}(x) = \nabla f(x+\delta^*(x))$ to the SAM gradient $g_t = \nabla f(x_t + \tilde\delta_t)$, with error $\leq 2L\rho$ from the triangle inequality.

## Audit result
PASS. All steps verified. Only minor issue: Danskin's theorem technically requires uniqueness of the maximizer, which holds generically for $L$-smooth functions. At non-differentiable points, Clarke's generalized gradient gives the same bound.

## Related results
- **GD non-convex convergence** (`proofs/optimization/convergence/gd-nonconvex-stationary-point/`): The base technique; SAM extends this with perturbation error analysis.
- **Moreau envelope smoothness** (`proofs/convex-analysis/subgradient/moreau-envelope-smoothness/`): $f^{\mathrm{SAM}}$ is the "adversarial" analogue of the Moreau envelope (max instead of min).
- **Proximal gradient convergence** (`proofs/convex-analysis/subgradient/proximal-gradient-convergence-rate/`): Similar $O(1/T)$ non-convex rate with approximate proximal steps.
- Andriushchenko & Flammarion (2022) "Towards Understanding Sharpness-Aware Minimization" provides the framework this proof follows.
- The stochastic SAM analysis (mini-batch setting) adds variance terms and achieves $O(1/\sqrt{T})$, analogous to SGD vs GD.
