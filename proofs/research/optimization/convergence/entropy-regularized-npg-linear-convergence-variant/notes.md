# Notes: Entropy-Regularized NPG Linear Convergence (Variant)

## Proof technique

**Winning route**: Hybrid of Route B (soft-Bellman factorization) + Route A's ξ-gap identity, assembled in Fix Round 1.

The key insight that unlocked the proof is replacing the **non-gauge-invariant** $\|\log\pi^{(k)}-\log\pi_\tau^*\|_\infty$ (which was used in the original target and caused a factor-of-2 normalizer bloat) with the **state-wise centered seminorm**
$$\|\xi\|_{\mathrm c} := \tfrac12\sup_s(\max_a\xi(s,a)-\min_a\xi(s,a)).$$

This seminorm is gauge-invariant under softmax normalization (adding any $f(s)$ leaves it unchanged), which exactly kills the LSE normalizer contribution that blocked Route A.

The second key step is the **soft-Bellman factorization** from Route B:
$$Q_\tau^{(k+1)} = (1-\alpha)Q_\tau^{(k)} + \alpha\,\mathcal T_\tau[Q_\tau^{(k)}] + E^{(k)},$$
with $\|E^{(k)}\|_\infty \le K\gamma\tau\alpha\|\xi^{(k)}\|_{\mathrm c} + \text{h.o.t.}$

Combining with the $\gamma$-contraction of $\mathcal T_\tau$ gives the Q-recursion
$$\|\Delta^{(k+1)}\|_\infty \le (1-\eta\tau)\|\Delta^{(k)}\|_\infty + K\gamma\tau\alpha\|\xi^{(k)}\|_{\mathrm c} + \text{h.o.t.}$$

## Key steps

1. **Log-policy recursion** (Lemma 2.1): $\xi^{(k+1)}(s,a) = (1-\alpha)\xi^{(k)}(s,a) + \beta\Delta^{(k)}(s,a) + G^{(k)}(s)$ where $G^{(k)}(s)$ is a state-only function.
2. **Gauge-invariant contraction** (Cor 2.2): The centered seminorm $\|\cdot\|_{\mathrm c}$ kills $G^{(k)}(s)$, giving $\|\xi^{(k+1)}\|_{\mathrm c} \le (1-\alpha)\|\xi^{(k)}\|_{\mathrm c} + \beta\|\Delta^{(k)}\|_\infty$.
3. **Q-recursion via Bellman subtraction** (Lemma 3.1): $\Delta^{(k+1)} = \gamma\mathbb E_{s'}\sum_{a'}\pi^{(k+1)}(a'|s')[\Delta^{(k+1)}(s',a') - \tau\xi^{(k+1)}(s',a')]$.
4. **Soft-Bellman factorization** (Lemma 4.2, from Route B): yields the $(1-\eta\tau)$-rate Q-recursion with $\|\xi\|_{\mathrm c}$ cross-coupling.
5. **Lyapunov assembly** (Section 5): $\Phi^{(k)} = \|\Delta^{(k)}\|_\infty + C\|\xi^{(k)}\|_{\mathrm c}$ with $C \in [K\tau/(2-\gamma), \tau\gamma(1-\gamma)]$. The two-constraint system is feasible when $K \le \gamma(1-\gamma)(2-\gamma)$; otherwise the rate drops to $1-c\eta\tau(1-\gamma)$ for $c \in (0,1)$.
6. **Quadratic h.o.t. absorption** (Section 7): Bootstrap argument — starting from small enough $\Phi^{(0)}$, iterates stay in the small-error regime where h.o.t. is dominated by the linear rate.

## Audit result

- **Round 1 (FAIL)**: All three Explorers hit the same obstruction — $\|\log\pi-\log\pi^*\|_\infty$ is not gauge-invariant; the LSE normalizer contributes a factor of 2 per step that makes the linear system for Lyapunov constant $C$ infeasible at the target rate $(1-\eta\tau)$.
- **Fix Round 1**: Hybrid approach — Route B's factorization + centered seminorm $\|\xi\|_{\mathrm c}$. Achieves rate $(1-c\eta\tau(1-\gamma))$.
- **Round 2 (PASS-WITH-MINOR-ISSUES)**: Variant proof is rigorous end-to-end modulo citation of Route B's factorization (Lemma 4.2). Five editorial cleanup items flagged but no mathematical errors.

## Discrepancies (Variant vs Target)

| Aspect | Target (Cen et al. 2022) | Proved Variant |
|---|---|---|
| Rate | $(1-\eta\tau)^k$ | $(1-c\eta\tau(1-\gamma))^k$, $c \in (0,1]$ |
| Lyapunov seminorm on policy | $\|\log\pi-\log\pi^*\|_\infty$ | $\|\xi\|_{\mathrm c}$ (centered) |
| Regime | All $\Phi^{(0)} < \infty$ | Small-error regime (or eventually) |
| Step-size range | $0 < \eta \le (1-\gamma)/\tau$ | Same |

The factor $(1-\gamma)$ gap in the rate is an intrinsic limitation of the soft-Bellman-factorization + centered-seminorm approach. The exact $(1-\eta\tau)$ rate requires the soft sub-optimality gap $\xi_{\mathrm{Cen}}^{(k)}(s,a) := \tau\log\pi^{(k)}(a|s) + V_\tau^{(k)}(s) - Q_\tau^{(k)}(s,a)$ and the soft policy-improvement inequality, which could not be closed rigorously in any explored route without citing the original paper's "monotonic improvement" result.

## Related results

- **Entropy-regularized value iteration** (`proofs/research/optimization/convergence/entropy-regularized-value-iteration/`): Soft VI is the prototype $\gamma$-contraction of $\mathcal T_\tau$; NPG inherits it.
- **NPG softmax tabular O(1/K) convergence** (`proofs/research/optimization/convergence/npg-softmax-tabular-convergence/`): Unregularized NPG has sub-linear rate; entropy regularization provides implicit strong convexity that upgrades to geometric rate.
- **Synchronous Q-learning finite-time convergence** (`proofs/research/optimization/convergence/synchronous-q-learning-finite-time/`): Parallel result for Q-learning; both use the soft/hard Bellman contraction as the core tool.

## Lessons learned (for future policy-gradient proofs)

1. **Gauge-invariance is non-negotiable**: When working with log-policies under softmax, any norm on $\log\pi$ must either be centered (like $\|\cdot\|_{\mathrm c}$) or normalized (like $\pi_\tau^*$-mean-zero) — otherwise the normalizer $\log Z$ produces spurious factors of 2 that break linear-rate Lyapunov constructions.
2. **Factor-of-$(1-\gamma)$ gap is structural**: The soft-Bellman factorization approach is intrinsically limited to rate $1 - O(\eta\tau(1-\gamma))$. The full $(1-\eta\tau)$ requires either (a) Cen et al.'s soft-advantage approach with one-step improvement inequality, or (b) direct analysis in KL-divergence space with gradient flow.
3. **Bootstrap for h.o.t.**: When a quadratic higher-order term appears in a linear-rate Lyapunov inequality, the standard trick is to start in a small-error regime and bootstrap monotone decrease — the linear term dominates once iterates are close enough to the fixed point.
