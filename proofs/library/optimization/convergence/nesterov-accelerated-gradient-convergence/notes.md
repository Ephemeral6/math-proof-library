# Notes: Nesterov's Accelerated Gradient Descent O(1/k²) Convergence

## Proof technique
The winning route is the **direct Lyapunov function approach** (Route 3, Bansal-Gupta / modern style). The key is defining the Lyapunov function V_k = k(k+1)(f(x_k) - f*) + 2L||z_k - x*||² with the auxiliary sequence z_k, and showing V_{k+1} ≤ V_k through elegant cancellations.

This was preferred over the estimate sequence framework (Route 2) because:
1. It is more direct and self-contained
2. The Lyapunov approach yields a cleaner constant
3. The cancellation structure is transparent

## Key steps
1. **Descent lemma**: f(x_{k+1}) ≤ f(y_k) - (1/(2L))||∇f(y_k)||² from L-smoothness with step 1/L
2. **Convex combination bound**: Using y_k = (k/(k+2))x_k + (2/(k+2))z_k, bound f(y_k) - f* as a convex combination of f(x_k)-f* and an inner product with z_k - x*
3. **Perfect cancellation**: The inner product terms from the f-bound and the z_k distance expansion cancel exactly; the gradient norm terms leave a negative remainder -(k+1)/(2L)||∇f(y_k)||²
4. **Initial value**: V₀ = 2L||x₀-x*||² because the k(k+1) coefficient vanishes at k=0

The z_k update z_{k+1} = z_k - ((k+1)/(2L))∇f(y_k) is carefully designed so that the coefficient (k+1)/(2L) makes the inner product terms cancel with the coefficient 2(k+1) from the convex combination.

## Audit result
- Round 1: PASS with MEDIUM issues (presentation only, no mathematical errors)
- Round 2 (after cleanup): PASS with 1 LOW issue
- Numerical verification: PASS on 50 iterations with d=50 dimensional problem, all ratios < 0.08
- All 7 proof steps verified VALID across both audit rounds

## Related results
- **Nesterov's first-order lower bound** (Theorem 2.1.7): Proves Omega(1/k²) for any first-order method, which this result matches. Already proved in this library at proofs/optimization/lower-bounds/nesterov-first-order-lower-bound/
- **OGD regret bound**: Gradient descent achieves O(1/k) for smooth convex; acceleration doubles the exponent. In proofs/optimization/convergence/ogd-regret-bound/
- **Proximal gradient convergence**: O(1/T) rate for composite optimization, which can also be accelerated (FISTA). In proofs/convex-analysis/subgradient/proximal-gradient-convergence-rate/
- **SVRG linear convergence**: For strongly convex + finite sum, variance reduction gives linear rate without acceleration. In proofs/optimization/stochastic/svrg-linear-convergence-abc-framework/
- **Su-Boyd-Candes ODE**: The continuous-time limit X'' + (3/t)X' + ∇f(X) = 0 provides intuition for why momentum = (k-1)/(k+2) ≈ 1 - 3/k is the right choice
