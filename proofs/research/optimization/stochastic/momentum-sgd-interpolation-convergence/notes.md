# Notes: Momentum SGD under Interpolation Linear Convergence

## Proof technique
Route 3 (Variance Reduction Viewpoint) won. Core technique: **split co-coercivity** -- decompose $\langle \nabla f, e\rangle$ via convex combination of strong convexity and averaged co-coercivity bounds. With $\alpha=1/2$ and $\gamma=1/L$, the co-coercivity portion exactly absorbs the stochastic gradient variance $\gamma^2\mathbb{E}[\|g_t\|^2]$.

## Key steps
1. **Split co-coercivity (Step 6)**: The identity $-2\gamma\langle \nabla f, e\rangle + \gamma^2\mathbb{E}[\|g\|^2] \leq -(\mu/L)\|e\|^2$ when $\alpha=1/2$, $\gamma=1/L$. This is the "variance reduction without SVRG" -- interpolation alone provides exact variance cancellation.
2. **Joint Lyapunov $\Phi_t = \|e_t\|^2 + a\|m_t\|^2$** with $a = \mu/(4L)$ tracks both position error and momentum energy.
3. **Budget allocation**: The $\mu/L$ contraction is split into $\mu/(2L)$ for the final rate and $\mu/(2L)$ for absorbing three perturbation terms: residual variance $a\|e\|^2 = \mu/(4L)$, and two Young's bounds at $\mu/(8L)$ each.
4. **Small $\beta = \mu^2/(16L^2)$** ensures momentum cross-terms fit within the budget. The $R_m \leq a\rho$ condition reduces to $\kappa^2 \geq 4/5$.

## Audit result
PASS on round 1. All 10 steps valid. Numerically verified at $\kappa \in \{2,5,10,50,100\}$. All constants traceable, no hidden dimension dependence.

Two LOW observations: (1) rate $1-1/(2\kappa)$ loses factor 2 vs optimal SGD; (2) $\beta = O(1/\kappa^2)$ is conservative, no acceleration benefit captured.

## Related results
- **SPS-SGD convergence** (proofs/optimization/stochastic/): Also uses interpolation for variance control, but with adaptive step size instead of momentum
- **SVRG linear convergence** (proofs/optimization/stochastic/): Achieves variance reduction through explicit control variates; here interpolation provides "free" variance reduction
- **SGD under PL + interpolation** (proofs/optimization/stochastic/): Same interpolation variance bound, different algorithm (iterate averaging)
- **SGD stability** (proofs/learning-theory/stability/): Uses co-coercivity similarly for non-expansiveness of gradient step
- The split co-coercivity technique is a variation of the standard "interpolation between strong convexity and smoothness" used in deterministic gradient descent analysis
