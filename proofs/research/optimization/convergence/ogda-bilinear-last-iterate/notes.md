# Notes: OGDA Bilinear Last-Iterate Convergence

## Proof technique
Spectral decomposition (Route 2) won. The Lyapunov approach (Route 1) was attempted first but the cross-term bounds were too loose; the spectral approach leverages the linear structure of bilinear games directly.

Key idea: OGDA on a bilinear game is a LINEAR recurrence $u_{t+1} = M u_t$. Decompose $M$ via the SVD of $A$ into independent 2×2 blocks, analyze each block's eigenvalues, and aggregate.

## Key steps
1. **Identity (E)**: $\|z_{t+1}\|^2 = \|z_t\|^2 + \|\delta_{t+1}-\delta_t\|^2 - \|\delta_t\|^2$ — derived from skew-symmetry of $F$
2. **Block diagonalization**: Each singular value $\sigma_j$ of $A$ gives a 4D block (or 2D in complex form)
3. **Eigenvalues**: $\lambda_\pm = (1\pm\rho)/2 - i\eta\sigma$ with $|\lambda_\pm|^2 = (1\pm\rho)/2$ where $\rho = \sqrt{1-4\eta^2\sigma^2}$
4. **Decay**: $(1+\rho)/2 \leq 1-\eta^2\sigma^2$, so $|\lambda_+|^T \leq O(1/(\eta\sigma\sqrt{T}))$
5. **Aggregation**: Worst block is $\sigma_{\min}$, giving $\kappa(A)^2/T$ rate

## Audit result
7/10, PASS. Identity (E), eigenvalue computation, decay bound all correct. The eigenvector condition number bound $\kappa(P)^2 \leq 8$ claimed but not fully verified — qualitatively correct, constants need more work.

## Related results
- **Extragradient convex-concave minimax** (proofs/library/convex-analysis/subgradient/extragradient-convex-concave-minimax/) — related algorithm for minimax problems
- **NPG softmax convergence** (proofs/research/optimization/convergence/npg-softmax-tabular-convergence/) — another game-theoretic optimization result
