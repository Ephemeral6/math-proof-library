# Notes: ADMM Ergodic O(1/K) Convergence Rate

## Proof technique
The winning route is the **Lyapunov function + telescoping** approach (variational inequality framework). This follows the He-Yuan (2012) framework:
1. Derive per-step variational inequality from subproblem optimality conditions and convexity
2. Use three-point identity and polarization identity to create perfectly telescoping terms
3. A crucial cancellation combines residual and cross terms into $-\frac{\rho}{2}\|s^{k+1}\|^2 \leq 0$
4. Telescope, apply Jensen's inequality for ergodic averaging
5. Optimize the free dual variable $\lambda$ to extract both feasibility and objective bounds

This route won because it produces the cleanest KEY inequality with perfect telescoping and a non-positive remainder, avoiding the need for AM-GM or other lossy bounds in the main argument.

## Key steps
1. **Subproblem optimality**: The $z$-subproblem gives the remarkably clean condition $0 \in \partial g(z^{k+1}) + B^\top \lambda^{k+1}$, matching the saddle-point condition exactly.
2. **The KEY inequality**: The per-step bound $\mathcal{L}(x^{k+1}, z^{k+1}, \lambda) - \mathcal{L}(x, z, \lambda^{k+1}) \leq \frac{1}{2}(\text{telescoping terms}) - \frac{\rho}{2}\|s^{k+1}\|^2$ is the heart of the proof. The cancellation $\|r^{k+1}\|^2 + 2\langle B(z^k - z^{k+1}), r^{k+1}\rangle + \|B(z^k - z^{k+1})\|^2 = \|s^{k+1}\|^2$ is the critical algebraic step.
3. **Feasibility bound via $\lambda$-optimization**: Choosing $\lambda = \lambda^0 + \rho K\bar{r}^K$ in the general bound (GEN) and solving the resulting quadratic gives the $O(1/K)$ feasibility rate.
4. **Non-negativity from saddle-point**: The inequality $f(\bar{x}^K) + g(\bar{z}^K) - f(x^\star) - g(z^\star) + \langle \lambda^\star, \bar{r}^K\rangle \geq 0$ provides the crucial lower bound needed for the feasibility argument.

## Audit result
PASS on first round. All 10 steps verified VALID. Three LOW-severity observations:
- Full column rank of $B$ could be more explicitly invoked in the proof steps
- Constants depend on unknown saddle-point values (standard in literature)
- Minor algebraic simplification $\sqrt{a^2+b^2} \leq a+b$ could be justified

## Alternative proof route (general case, no full-rank assumption)
Route 5 (Direct Summation via Optimality Conditions) provides a shorter proof under weaker assumptions (saddle point + solvable subproblems, no full-rank B). The Lyapunov function uses ||B(z-z*)||² as a semi-norm. The general proof is included as an appendix in proof.md.

## Related results
- **Proximal gradient O(1/T) convergence** (in this library): shares the Lyapunov + telescoping technique
- **Extragradient O(1/K) for convex-concave minimax** (in this library): similar variational inequality approach for saddle-point problems
- **Douglas-Rachford splitting convergence**: ADMM is equivalent to Douglas-Rachford applied to the dual; the ergodic rate can also be derived from this viewpoint
- **Linearized ADMM**: relaxing the full column rank assumption leads to linearized ADMM variants with similar O(1/K) rates
- **ADMM O(1/K^2) with acceleration**: Goldstein et al. 2014 show accelerated ADMM can achieve O(1/K^2) rates
- **Non-ergodic ADMM convergence**: under stronger assumptions (e.g., strong convexity), non-ergodic (last-iterate) linear convergence rates are achievable
