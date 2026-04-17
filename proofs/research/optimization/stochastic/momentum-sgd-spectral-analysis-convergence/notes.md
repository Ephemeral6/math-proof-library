# Notes: Momentum SGD Linear Convergence via Spectral Analysis

## Proof technique
Route 2 (Linear System / Spectral Analysis) was assigned and executed. The proof uses:
1. Integral Hessian linearization to reduce to a state-dependent linear system
2. Kronecker product second-moment operator for the quadratic case
3. Lyapunov function $\Phi_t = \|e_t\|^2 + \alpha\|p_t\|^2$ for the general case
4. Young's inequality to handle momentum cross terms

The diagonal Lyapunov approach "won" over more complex alternatives (Nesterov-style $\tilde{e}_t$ variable, non-diagonal P matrices) because it yields a clean, verifiable proof despite not achieving the optimal rate.

## Key steps
1. **Integral Hessian:** $\nabla f_i(x) = H_i(x)(x-x^*)$ with $0 \preceq H_i \preceq LI$, $\bar{H} \succeq \mu I$
2. **Key bound:** $H_i^2 \preceq LH_i$ (smoothness), giving $\mathbb{E}_i[\|H_ie\|^2] \leq L\langle e,\bar{H}e\rangle$
3. **Cross term control:** Young's inequality with parameter $\delta = \frac{\gamma\mu}{4\beta(1+\gamma L)}$
4. **Parameter choice:** $\gamma = 1/(2L)$, $\beta = 1/\kappa$, $\alpha = \frac{5\mu}{8L(\gamma L+\beta)}$

## Audit result
Proof is correct. All inequalities verified. The rate $1-5/(16\kappa)$ is a GD-rate (not accelerated). Numerical spectral analysis confirms that better rates exist for larger $\beta$ (up to ~0.94 at $\kappa=100$) but a closed-form Lyapunov proof for those parameters remains open.

This proof improves over the previous entry (momentum-sgd-interpolation-linear-convergence) which achieved rate $1-1/(16\kappa^2)$; we improve to $1-5/(16\kappa)$.

## Related results
- **momentum-sgd-interpolation-linear-convergence:** Previous proof of same theorem with weaker rate $1-O(1/\kappa^2)$
- **momentum-sgd-interpolation-contraction:** Related contraction analysis
- **momentum-sgd-interpolation-convergence:** Split co-coercivity approach
- **gd-strongly-convex-linear-convergence:** The $\beta=0$ special case gives standard GD rate
- **heavy-ball-instability:** Shows heavy ball can diverge WITHOUT interpolation (Lessard et al. 2016)
- **svrg-linear-convergence-abc-framework:** Variance reduction achieves accelerated rates
