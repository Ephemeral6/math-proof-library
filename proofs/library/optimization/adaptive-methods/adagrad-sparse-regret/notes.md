# Notes: AdaGrad Convergence for Sparse Gradients

## Proof technique
Per-coordinate OGD decomposition with Abel summation (for distance terms with decreasing step sizes) and the key telescoping lemma $\sum a_t/\sqrt{S_t} \leq 2\sqrt{S_T}$ (for gradient terms).

## Key steps
1. Convexity → per-coordinate regret decomposition
2. Projection non-expansiveness → standard OGD per-round bound
3. Abel summation handles varying step sizes: distance term $\leq D^2\sqrt{S_{T,i}}/(2\eta)$
4. Key lemma (concavity of sqrt) handles gradient term: $\leq \eta\sqrt{S_{T,i}}$
5. Optimize $\eta = D/\sqrt{2}$: coefficient $D\sqrt{2}$
6. Cauchy-Schwarz for worst-case; sparsity counting for sparse case

## Audit result
PASS (1 round). All steps valid. Key lemma verified numerically.

## Important note on constants
OGD analysis yields constant $\sqrt{2}$, not 1. The exact constant 1 requires FTRL/dual-averaging formulation (Duchi et al. 2011, Theorem 5). Asymptotic rate is identical.

## Related results
- Adam non-convex convergence (library) — extends to momentum-based adaptive methods
- OGD regret bound (library) — non-adaptive baseline that AdaGrad improves upon for sparse problems
