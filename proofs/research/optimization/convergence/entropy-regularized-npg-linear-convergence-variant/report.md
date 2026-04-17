# Proof Report: Entropy-Regularized NPG Linear Convergence (Variant)

## 1. Problem Statement

**Source**: S. Cen, C. Cheng, Y. Chen, Y. Wei, Y. Chi, *"Fast Global Convergence of Natural Policy Gradient Methods with Entropy Regularization"*, Operations Research 2022.

**Target theorem**: For entropy-regularized NPG on a finite discounted MDP with softmax parameterization and step size $0 < \eta \le (1-\gamma)/\tau$, the iterates satisfy
$$\Phi^{(k+1)} \le (1-\eta\tau)\,\Phi^{(k)}, \qquad \|V_\tau^{(k)}-V_\tau^*\|_\infty \le (1-\eta\tau)^k \Phi^{(0)}$$
for Lyapunov $\Phi^{(k)} := \|Q_\tau^{(k)} - Q_\tau^*\|_\infty + C\|\log\pi^{(k)} - \log\pi_\tau^*\|_\infty$.

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 5 routes proposed, top 3 selected |
| Explorer | Opus | 3 proofs attempted, all 3 hit same obstruction |
| Judge | Sonnet | Route B selected as base (score 20/30); Route A's $\xi$-gap insight flagged for hybrid |
| Audit Round 1 | Opus | Factor-of-2 gauge issue identified |
| Fix Round 1 | Opus | Hybrid approach — Route B factorization + centered seminorm $\|\cdot\|_{\mathrm c}$ |
| Audit Round 2 | Opus | PASS-WITH-MINOR-ISSUES as documented variant |

## 3. Proof Routes Explored

- **Route A (Dual Lyapunov with log-policy $\ell^\infty$)**: Derived the log-policy recursion (5) and the elegant "soft Gibbs cancellation" $E_{k+1} \le \gamma\tau/(1-\gamma)\cdot L_{k+1}$. **Obstruction**: factor of 2 in the log-policy coefficient from the normalizer $\log Z^{(k)}$ makes the Lyapunov linear system infeasible. Suggested $\xi$-gap fix not closed rigorously.
- **Route B (Soft-Bellman factorization)**: Established $Q_\tau^{(k+1)} = (1-\alpha)Q_\tau^{(k)} + \alpha \mathcal T_\tau[Q_\tau^{(k)}] + E^{(k)}$ with explicit error bound. Proved a clean weaker rate $(1-\eta\tau(1-\gamma))$. This became the base for the winning hybrid.
- **Route C (KL Lyapunov)**: Collapses to Route A's obstruction after the log-policy substitution; cannot close independently.

## 4. Final Proof (Variant)

Uses the gauge-invariant centered seminorm $\|\xi\|_{\mathrm c} := \tfrac12 \sup_s(\max_a \xi - \min_a \xi)$ in place of $\|\log\pi - \log\pi^*\|_\infty$.

The Lyapunov $\Phi^{(k)} := \|\Delta^{(k)}\|_\infty + C\|\xi^{(k)}\|_{\mathrm c}$ with $C \in [K\tau/(2-\gamma), \tau\gamma(1-\gamma)]$ satisfies
$$\Phi^{(k+1)} \le (1 - c\eta\tau(1-\gamma))\,\Phi^{(k)} + O((\Phi^{(k)})^2)$$
for $c \in (0,1]$. Bootstrapping the higher-order term in the small-error regime gives
$$\|V_\tau^{(k)} - V_\tau^*\|_\infty \le \Phi^{(k)} \le (1-c\eta\tau(1-\gamma))^k \Phi^{(0)}.$$

See `proof.md` for the full proof.

## 5. Audit Result

**Audit Round 2 decision**: PASS-WITH-MINOR-ISSUES as documented variant.

Key findings:
- Gauge-invariance argument (Lemma 2.1/2.2): VALID
- Bellman cancellation (Lemma 3.1): VALID
- Route B factorization citation (Lemma 4.2): adequate (verified against `failed_attempts/proof_route_B.md`)
- Lyapunov algebra (Section 5): correct; feasibility condition $K \le \gamma(1-\gamma)(2-\gamma)$ handled honestly with explicit fallback
- Quadratic h.o.t. absorption (Section 7): rigorous via standard bootstrap
- Final value bound (Corollary 6.2): valid

Minor issues flagged (non-blocking): visible stream-of-consciousness commentary in Section 3, incomplete sentence in Lemma 6.1 proof, self-containment of Lemma 4.2.

## 6. Fix History

- **Fix Round 1** (applied): Replaced $\|\log\pi - \log\pi^*\|_\infty$ with gauge-invariant centered seminorm $\|\xi\|_{\mathrm c}$. Combined Route B's soft-Bellman factorization with Route A's $\xi$-gap insight. Accepted rate downgrade $(1-\eta\tau) \to (1-c\eta\tau(1-\gamma))$ as documented variant.

## 7. Discrepancies (Variant vs Target)

| Aspect | Target (Cen et al. 2022) | Proved Variant |
|---|---|---|
| Rate | $(1-\eta\tau)^k$ | $(1-c\eta\tau(1-\gamma))^k$, $c \in (0,1]$ |
| Lyapunov policy-component | $\|\log\pi - \log\pi^*\|_\infty$ | $\|\xi\|_{\mathrm c}$ (centered seminorm) |
| Regime | All $\Phi^{(0)} < \infty$ | Small-error regime (or eventually) |

The $(1-\gamma)$ factor gap is structural: the soft-Bellman-factorization + centered-seminorm approach cannot reach the exact $(1-\eta\tau)$ rate. Closing it requires the soft sub-optimality gap $\xi_{\mathrm{Cen}}^{(k)}$ with the soft policy-improvement inequality (Cen et al. 2022, Section 4), which was not rigorously reproducible within this workflow's constraints.
