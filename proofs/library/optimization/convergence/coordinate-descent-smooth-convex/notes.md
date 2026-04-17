# Notes: Randomized Coordinate Descent Convergence Rate

## Proof technique
Lyapunov function + telescoping (Pattern A/B from proof library). The winning route combines the coordinate descent lemma with a carefully chosen Lyapunov function $\Phi_t = (t+n)\delta_t + \frac{n}{2}\|x_t-x^*\|_L^2$ in the $L$-weighted norm. The key is that the weighted norm naturally cancels the $1/L_i$ factors from the step size, yielding a clean monotone decrease.

## Key steps
1. **Coordinate descent lemma**: Per-coordinate smoothness gives decrease $\geq (\nabla_i f)^2/(2L_i)$ per update
2. **Weighted distance evolution**: The $L$-weighted norm $\|x_t-x^*\|_L^2$ has a clean update formula because $L_i$ weights cancel with the $1/L_i$ step size
3. **Lyapunov monotonicity**: The function $(t+n)\delta_t + \frac{n}{2}\|x_t-x^*\|_L^2$ is non-increasing in expectation, with the critical coefficient of $S_t$ being $-(t+1)/(2n) \leq 0$
4. **Initial bound**: Separable smoothness at $x^*$ (with $\nabla f(x^*)=0$) gives $\delta_0 \leq \frac{1}{2}\|x_0-x^*\|_L^2$

## Audit result
PASS in 1 round. All 9 steps VALID. 6 numerical verifications passed. Key finding: the tight bound is $n\|x_0-x^*\|_L^2/(T+n)$ in the weighted norm; converting to Euclidean norm costs a factor of $n$.

## Related results
- **GD strongly convex linear convergence** (proofs/optimization/convergence/gd-strongly-convex-linear-convergence/): Uses the same Lyapunov + descent lemma pattern but with full gradient
- **Nesterov AGD O(1/k^2)** (proofs/optimization/convergence/nesterov-accelerated-gradient-convergence/): Accelerated version uses estimate sequences; coordinate descent can also be accelerated
- **Proximal gradient convergence** (proofs/convex-analysis/subgradient/proximal-gradient-convergence-rate/): Same O(1/T) rate structure, Lyapunov + telescoping pattern
- **SVRG linear convergence** (proofs/optimization/stochastic/svrg-linear-convergence-abc-framework/): Variance-reduced coordinate descent achieves linear convergence for strongly convex
- Importance sampling version ($p_i \propto L_i$) gives the sharper $2n\bar{L}\|x_0-x^*\|^2/(T+4)$ bound (Nesterov 2012, Theorem 2)
