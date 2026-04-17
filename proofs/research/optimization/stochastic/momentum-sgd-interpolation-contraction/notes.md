# Notes: SGD with Polyak Momentum Linear Convergence under Interpolation

## Proof technique
Route 4: Contraction Mapping in Weighted Joint Space. Define the Lyapunov function $\Phi_t = \|x_t - x^*\|^2 + c\|v_t\|^2$ with $c = \gamma^2$ and show $\mathbb{E}[\Phi_{t+1}] \leq \rho\Phi_t$ using co-coercivity per $f_i$ (from smoothness + convexity + interpolation) combined with strong convexity of $f$.

## Key steps
1. Expand $\Phi_{t+1}$ into terms involving $\|e_t\|^2$, $\|w_t\|^2$, $\|\nabla f_{i_t}\|^2$, and three cross-terms
2. Take expectation over $i_t$ to convert stochastic gradients to full gradients and expected squared norms
3. Apply co-coercivity (I1) and strong convexity (I2) via a convex combination with parameter $\alpha = 1/2$
4. Use Young's inequality on two cross-terms with parameters $\eta$ and $\delta$
5. Choose $\delta = \beta$ to make the coefficient of $S = \mathbb{E}[\|\nabla f_i\|^2]$ exactly zero
6. Verify both the $\|e_t\|^2$ and $\|w_t\|^2$ coefficients are strictly contracting

## Audit result
- Algebraic verification: All coefficient computations verified by hand and cross-checked
- Numerical verification: Ran 10,000 Monte Carlo trials on a quadratic instance with $\kappa = 10$. Theoretical bound holds at all time steps. Empirical rate (~0.74) is significantly better than the conservative bound (0.975), confirming the bound is valid but loose.
- The $A_s = 0$ cancellation is exact (verified symbolically)
- Young's inequality applications are all standard and correct

## Related results
- **Vanilla SGD under interpolation**: Achieves $\rho = 1 - O(\mu/L)$ without momentum (Vaswani et al. 2019). Our rate matches this, showing momentum does not hurt but also does not help with this analysis.
- **SPS-SGD convergence**: Our SPS-SGD proof (in this library) uses interpolation similarly but with stochastic Polyak step size.
- **Heavy-ball instability**: Our proof of heavy-ball instability (Lessard et al. 2016) shows that without interpolation, heavy-ball can diverge. Interpolation resolves this.
- **SVRG linear convergence**: Our SVRG proof achieves better rates via variance reduction; interpolation gives "free" variance reduction at the optimum.
- **Accelerated rates**: Liu & Belkin 2020 achieve $1 - O(1/\sqrt{\kappa})$ for momentum SGD under interpolation using a different (more complex) analysis.
