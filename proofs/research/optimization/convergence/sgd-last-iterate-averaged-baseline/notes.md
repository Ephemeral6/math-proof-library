# Notes: SGD Last-Iterate Averaged Baseline

## Proof technique
Martingale decomposition + Lyapunov telescoping with constant step size. The stochastic gradient is split into true subgradient + zero-mean noise; the noise cross-terms form a martingale that vanishes in expectation, enabling clean telescoping. Constant step size η = D/(G√T) eliminates the harmonic sum that causes the log(T) factor with decreasing step sizes.

## Key steps
1. Non-expansiveness of projection gives the descent recursion on (x_t - x*)²
2. Martingale structure of the noise terms: E[M_T] = 0 eliminates all cross-correlations
3. Telescoping sum + subgradient inequality converts squared-distance bound into function-value bound
4. Jensen's inequality passes from individual iterates to the averaged iterate
5. Step size optimization: η = D/(G√T) balances the D²/(2ηT) and ηG²/2 terms equally

## Audit result
PASS. All 7 steps VALID. 6 numerical checks passed. All constants traceable. The proof is the standard optimal result for convex Lipschitz SGD with averaged iterates.

## Related results
- Nemirovski-Yudin lower bound: Ω(DG/√T) is information-theoretically optimal for this setting
- Shamir & Zhang 2013: O(log(T)/√T) upper bound for the last iterate with decreasing step sizes
- Koren & Segal, COLT 2020: Open problem — is the last-iterate rate Θ(1/√T)?
- Harvey, Liaw, Plan, Randhawa 2019: Tight analyses of SGD for last-iterate convergence
- Zamani & Glineur 2023: Progress on last-iterate bounds in special cases

## Status of the open problem
The last-iterate O(1/√T) conjecture for general convex Lipschitz functions remains OPEN. Five independent exploration routes all identified the same three fundamental barriers (no contraction without strong convexity, no concentration around average, slow Markov chain mixing). Any resolution would require techniques beyond the standard Lyapunov/telescoping/martingale framework.
