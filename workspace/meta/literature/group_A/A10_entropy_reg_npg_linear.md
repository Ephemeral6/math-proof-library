# A10: Entropy-Regularized NPG Linear Convergence (Variant)

**Proof path**: `proofs/research/optimization/convergence/entropy-regularized-npg-linear-convergence-variant/`
**Claimed source**: Cen-Cheng-Chen-Wei-Chi 2022 (arXiv:2007.06558)
**Verdict**: **CONFIRMED-WEAKER** (honest variant)

## Our claim
For entropy-regularized NPG with $0<\eta\le(1-\gamma)/\tau$, the Lyapunov
$$\Phi^{(k)} = \|Q^{(k)}_\tau - Q^*_\tau\|_\infty + \tau\|\xi^{(k)}\|_c$$
(where $\|\cdot\|_c$ is the state-wise centered seminorm) satisfies
$$\Phi^{(k+1)} \le (1 - \eta\tau(1-\gamma))\Phi^{(k)}.$$

## Cross-check
[ARXIV-UNREACHABLE] Cen-Cheng-Chen-Wei-Chi 2022 (Theorem 1) prove **rate $(1-\eta\tau)$** in the soft-Q gap, with full step size up to $\eta = (1-\gamma)/\tau$. Their analysis uses a different Lyapunov (involving $\|Q-Q^*\|_\infty$ alone, with delicate handling of policy log-ratio). For $\eta = (1-\gamma)/\tau$ both rates coincide ($(1-\eta\tau) = (1-\eta\tau(1-\gamma))$ at $\eta\tau = 1-\gamma$), so at the *largest* allowed step size we match Cen et al. exactly; for smaller $\eta$ our rate $(1-\eta\tau(1-\gamma))$ is **strictly slower** than their $(1-\eta\tau)$.

The proof's own "Status" section explicitly acknowledges this: it states the variant is rate $(1-\eta\tau(1-\gamma))$ rather than the original target $(1-\eta\tau)$. This is HONEST.

## Comparison
- **Assumptions**: match.
- **Constants**: rate is **slower** by factor $(1-\gamma)$ in the contraction speed (small $\eta$).
- **Scope**: correctly matches at $\eta = (1-\gamma)/\tau$, slower elsewhere.
- **Technique**: Lyapunov with centered-seminorm $\|\cdot\|_c$ is a different (cleaner) gauge-invariant approach than Cen et al.'s. The $\|\cdot\|_c$ idea is itself a small contribution.

## Verdict
**CONFIRMED-WEAKER**. The proof is honestly labeled as a variant. Rate is suboptimal vs. published Cen 2022 result for $\eta < (1-\gamma)/\tau$, equivalent at $\eta = (1-\gamma)/\tau$. The gauge-invariant centered-seminorm Lyapunov is a small technical novelty but does not yield a stronger rate.
