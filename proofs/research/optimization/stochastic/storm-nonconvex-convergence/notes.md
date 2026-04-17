# Notes: STORM Non-Convex Convergence

## Proof technique
Route 1: Lyapunov Function + Descent Lemma (Polarization variant) won over 3 alternatives. The core framework is the standard "Descent Lemma + Lyapunov + Telescoping" combo, adapted from the SPIDER proof with the key modification being the momentum parameter $a$ replacing periodic full-gradient resets.

The key insight is using the polarization identity $\langle \nabla f, d\rangle = \frac{1}{2}(\|\nabla f\|^2 + \|d\|^2 - \|e\|^2)$ instead of Young's inequality on the cross-term. This retains a negative $-\eta(1-L\eta)/2\|d_t\|^2$ from the descent lemma, which absorbs the variance growth $2cL^2\eta^2\|d_t\|^2$ when $c = \eta/(2a)$ and $a \geq 2L^2\eta^2/(1-L\eta)$.

## Key steps
1. **Variance recursion** (Lemma 1): $\mathbb{E}[\|e_t\|^2] \leq (1-a)\|e_{t-1}\|^2 + 2L^2\eta^2\|d_{t-1}\|^2 + 2a^2\sigma^2$ — the $(1-a)$ contraction is the key difference from SPIDER
2. **Polarization identity** (Lemma 2): avoids Young's inequality slack entirely, produces negative $\|d_t\|^2$ term
3. **Lyapunov construction**: $\bar{\Phi}_t = \mathbb{E}[f(x_t)] + \frac{\eta}{2a}\mathbb{E}[\|e_t\|^2]$ balances error and descent terms exactly
4. **Mini-batch initialization**: $B = O(\sigma/\varepsilon)$ samples needed to avoid $O(\sigma^4/\varepsilon^4)$ bottleneck

## Audit result
- Round 1: FAIL — single-sample init creates $O(\sigma^4/\varepsilon^4)$ bottleneck; mean-squared smoothness assumption not explicit
- Round 2: PASS — fixed with mini-batch initialization $B = O(\sigma/\varepsilon)$, explicit (A4), cleaned exposition
- All 6 numerical checks passed, all constants traced

## Related results
- SPIDER (Fang et al. 2018): epoch-based variance reduction, $O(\varepsilon^{-3})$ for non-convex [REF: proofs/research/optimization/stochastic/spider-nonconvex-gradient-complexity/]
- SARAH (Nguyen et al. 2017): similar epoch structure [REF: proofs/research/optimization/stochastic/spider-variance-reduction-nonconvex/]
- SVRG: Lyapunov template [REF: proofs/library/optimization/stochastic/svrg-linear-convergence-abc-framework/]
- GD non-convex: deterministic baseline $O(1/\varepsilon^2)$ [REF: proofs/library/optimization/convergence/gd-nonconvex-stationary-point/]
- STORM is the single-loop, epoch-free version achieving same optimal $O(\sigma^2/\varepsilon^3)$ rate

## Comparison with other routes
| Route | Score | Method | Key Feature |
|-------|-------|--------|-------------|
| **1 (Lyapunov+Polarization)** | **35/40** | **Lyapunov $c=\eta/(2a)$** | **Clear structure, exact coefficient balancing** |
| 2 (Direct Recursion) | 25/40 | Unrolled variance | Less structured, same result |
| 3 (SPIDER Analogy) | 26/40 | Conceptual mapping | Good intuition, incomplete as proof |
| 4 (Martingale) | 31/40 | Orthogonal increments | Clean but no new insight |
