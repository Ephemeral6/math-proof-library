# Proof Report: SGD with Polyak Momentum under Interpolation -- Linear Convergence

## 1. Problem Statement

Let $f = \frac{1}{n}\sum_{i=1}^n f_i$ where each $f_i$ is convex and $L$-smooth, $f$ is $\mu$-strongly convex, and the interpolation condition $\nabla f_i(x^*) = 0$ holds for all $i$. Consider SGD with Polyak momentum:

$$v_{t+1} = \beta v_t + \nabla f_{i_t}(x_t), \quad x_{t+1} = x_t - \gamma v_{t+1}$$

Prove $\mathbb{E}[\|x_t - x^*\|^2] \leq C\rho^t\|x_0 - x^*\|^2$ with $\rho < 1$.

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | (pre-assigned) | Route 3 assigned: Variance Reduction Viewpoint |
| Explorer | Opus | 1 proof attempted, 1 succeeded |
| Judge | Sonnet | Route 3 selected (score: 35/40) |
| Audit | Opus | PASS (1 round, 0 issues) |
| Fix | Opus | Not needed |

## 3. Proof Routes Explored

**Route 3 (Variance Reduction Viewpoint)**: Used a split co-coercivity technique to exactly absorb stochastic gradient variance under interpolation, combined with a joint Lyapunov $\Phi_t = \|e_t\|^2 + a\|m_t\|^2$ tracking both position error and momentum energy. Succeeded with rate $\rho = 1 - \frac{1}{2\kappa}$.

## 4. Final Proof

See `best_proof.md` for the complete proof. Key result:

$$\mathbb{E}[\|x_t - x^*\|^2] \leq \left(1 - \frac{\mu}{2L}\right)^t \|x_0 - x^*\|^2$$

with parameters $\gamma = 1/L$, $\beta = \mu^2/(16L^2)$, $C = 1$.

**Core technique**: Split co-coercivity -- decompose $\langle \nabla f(x), x-x^*\rangle$ into:
- Half for strong convexity: $\frac{\mu}{2}\|x-x^*\|^2$ (provides contraction)
- Half for co-coercivity: $\frac{1}{2L}\mathbb{E}_i[\|\nabla f_i(x)\|^2]$ (absorbs variance)

With $\gamma = 1/L$, the co-coercivity portion exactly cancels $\gamma^2\mathbb{E}[\|g_t\|^2]$.

## 5. Audit Result

**PASS** on round 1. All 10 steps verified as VALID. Numerical verification confirmed at $\kappa \in \{2, 5, 10, 50, 100\}$. All constants fully traceable with no hidden dimension dependence.

Two LOW-severity observations:
- Rate $1-1/(2\kappa)$ loses factor 2 vs optimal SGD (proof artifact, not fundamental)
- $\beta = O(1/\kappa^2)$ is conservative (no acceleration captured)

## 6. Fix History

No fixes needed.
