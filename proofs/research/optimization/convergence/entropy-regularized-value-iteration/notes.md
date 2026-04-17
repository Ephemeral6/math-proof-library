# Notes: Entropy-Regularized Value Iteration

## Proof technique
Route 1 (Operator Theory via Log-Sum-Exp Properties) won. The proof factors $T_\tau = \tau \cdot \mathrm{LSE} \circ L$ where $L$ is a $\gamma/\tau$-Lipschitz affine map, and uses the 1-Lipschitz property of LSE in $\ell^\infty$ to establish the $\gamma$-contraction. The variational characterization of LSE as a max over the simplex (entropy-regularized optimization) cleanly delivers the Gibbs policy. The approximation bound uses a super-fixed-point argument.

## Key steps
1. **LSE 1-Lipschitz lemma**: $|\mathrm{LSE}(x) - \mathrm{LSE}(y)| \leq \|x-y\|_\infty$ via exponential-sum bounding
2. **Factorization**: $T_\tau V(s) = \tau \cdot \mathrm{LSE}(q_s^V)$ with $q_s^V(a) = (r(s,a) + \gamma(PV)(s,a))/\tau$
3. **Variational LSE**: $\mathrm{LSE}(z) = \max_{\pi \in \Delta} \{\langle \pi, z \rangle + H(\pi)\}$, proved via Lagrange multipliers with strict concavity of Shannon entropy (Hessian negative definite on tangent space)
4. **Per-step sandwich**: $TV \leq T_\tau V \leq TV + \tau \log A$ from single-term lower bound and $A$-term upper bound
5. **Super-fixed-point**: $W = V^* + \tau\log(A)/(1-\gamma)$ satisfies $T_\tau W \leq W$, and monotone iteration from above converges to $V^*_\tau \leq W$

## Audit result
PASS WITH MINOR FIXES. Three one-line additions were needed:
- Explicit Hessian verification for strict concavity of entropy
- Inline proof of standard Bellman operator contraction (replacing "well-known")
- Explicit monotonicity justification via positive softmax gradients

All fixes applied in final version. No structural issues found.

## Related results
- Standard Bellman operator contraction (unregularized case, $\tau = 0$ limit)
- NPG softmax tabular convergence (already in library) — uses the same entropy-regularized MDP framework
- Mirror descent online regret bound (already in library) — LSE as regularizer connects to entropic mirror descent
- Soft Actor-Critic (SAC) algorithm builds directly on this soft value iteration foundation
- Policy mirror descent for regularized MDPs uses the Gibbs policy structure from Part (iii)
