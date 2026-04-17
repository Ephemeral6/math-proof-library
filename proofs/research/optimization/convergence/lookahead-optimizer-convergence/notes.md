# Notes: Lookahead Optimizer Convergence on Quadratics

## Proof technique
**Route 2 (Matrix Recursion / Operator Norm)** won. The key idea is recognizing that on quadratics, Lookahead is a linear iteration $\phi_{t+1} = M\phi_t$ where $M = (1-\alpha)I + \alpha(I-\eta A)^k$. Spectral analysis of $M$ gives the exact convergence rate. For variance reduction, an "equivalent single-step" comparison quantifies the benefit of step-splitting.

## Key steps

### Part 1
1. Express $k$ inner GD steps as $(I-\eta A)^k$ (linear map on quadratic)
2. Derive the outer iteration matrix $M$ and compute its eigenvalues $m(\lambda) = 1-\alpha(1-(1-\eta\lambda)^k)$
3. Show $m(\lambda)$ is non-negative and decreasing in $\lambda$, so worst case is at $\lambda = \mu$
4. Conclude via $\|M\| = \rho(M)$ for symmetric matrices

### Part 2
1. Unroll the stochastic inner loop to identify the noise $\nu_t$ in the outer iterate
2. Compute $\mathbb{E}[\|\nu_t\|^2] \approx \alpha^2 k\eta^2\sigma^2 d$ (small step-size regime)
3. Compare against equivalent single-step method with step size $\tilde{\eta} = \alpha k\eta$
4. Show $1/k$ reduction from step-splitting and $\alpha^2$ from interpolation

## Audit result
**PASS.** Part 1 is exact and fully rigorous. Part 2 uses the small step-size approximation $k\eta L = O(1)$, which is the standard regime for Lookahead analysis. Minor cosmetic improvements suggested for the verbal description of "factor $\alpha^2 k$".

## Related results
- **Plain GD on quadratics:** convergence rate $(1-\eta\mu)$ per step — Lookahead with $\alpha=1$ recovers $(1-\eta\mu)^k$ per $k$-step block
- **Polyak averaging:** reduces variance but does not improve convergence rate — Lookahead provides both
- **SGD variance reduction (SVRG, SAGA):** reduce variance to zero at cost of full gradient computation — Lookahead reduces variance by $\alpha^2/k$ without additional gradient evaluations
- **Exponential moving average (EMA):** Lookahead's outer update is a partial EMA; the distinction is resetting the inner optimizer to the slow weights each outer step
