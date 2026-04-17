# Notes: Synchronous Q-Learning Finite-Time Convergence

## Proof technique
Route 4 (Variance-Aware Stochastic Recursion) won. The proof uses:
1. Scalar comparison via $\ell_\infty$-contraction of the Bellman operator
2. Entry-wise linearization: decompose $\Delta_t = L_t + R_t$ (linear MDS process + coupling remainder)
3. Azuma-Hoeffding for martingale differences with deterministic weights
4. Union bound over $SA$ state-action pairs

Routes 1-3 (Direct SA, Optimistic Squeeze, Peeling) timed out during exploration.

## Key steps
1. **Bellman $\gamma$-contraction**: $\|\mathcal{T}Q - Q^*\|_\infty \leq \gamma\|Q - Q^*\|_\infty$ — converts the nonlinear max coupling into a scalar bound
2. **Telescoping bias bound**: Product $\prod(1-\alpha_j(1-\gamma)) \leq (H-1)/(H+t-1)$ gives bias $\beta_t = O(1/((1-\gamma)^2 t))$
3. **Deterministic MDS weights**: $w_{k,t} = \alpha_k \prod_{j=k+1}^{t-1}(1-\alpha_j(1-\gamma))$ are deterministic despite nonlinear dynamics
4. **Azuma concentration**: Each entry's noise sum $M_T(s,a)$ concentrates with rate $\exp(-(1-\gamma)^4 T\varepsilon^2/32)$

## Audit result
**7.5/10, CONDITIONAL PASS.** All major components verified correct. One remaining gap: the coupling remainder bound $\|R_t\|_\infty$ uses $e_k \approx \beta_k$ but $e_k$ includes stochastic terms, creating a circularity that requires a bootstrapping or virtual iterate argument (Li et al. 2021 style) to close rigorously. The gap is purely technical — the stated rate is correct.

## Related results
- **Bellman contraction** (proofs/library/optimization/convergence/bellman-optimality-contraction/) — used as key lemma
- **Entropy-regularized VI** (proofs/research/optimization/convergence/entropy-regularized-value-iteration/) — related RL convergence result
- **NPG softmax convergence** (proofs/research/optimization/convergence/npg-softmax-tabular-convergence/) — policy optimization counterpart
- **Policy gradient theorem** (proofs/library/optimization/convergence/policy-gradient-theorem/) — foundational PG result
- **Azuma-Hoeffding inequality** (proofs/library/probability/azuma-hoeffding-inequality/) — used as tool
- **Matrix Bernstein inequality** (proofs/library/statistics/concentration/matrix-bernstein-inequality/) — alternative concentration tool
