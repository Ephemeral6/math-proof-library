# Final Report: STORM Convergence for Non-Convex Optimization

## Problem Statement

Prove that the STORM (STOchastic Recursive Momentum) algorithm achieves $O(\sigma^2/\varepsilon^3 + 1/\varepsilon^2)$ stochastic gradient complexity for finding $\varepsilon$-stationary points of smooth non-convex functions, matching the information-theoretic lower bound.

**Source**: Cutkosky & Orabona, "Momentum-Based Variance Reduction in Non-Convex SGD", NeurIPS 2019.

---

## Phase Summary

| Phase | Model | Status | Key Output |
|-------|-------|--------|------------|
| 1. Scout | sonnet | Complete | 4 routes proposed (Lyapunov, Direct Recursion, SPIDER Analogy, Martingale) |
| 2. Explore | opus (×4) | Complete | 4 proof attempts, all reaching the same bound |
| 3. Judge | sonnet | Complete | Route 1 (Lyapunov) selected, 35/40 |
| 4. Audit R1 | opus | FAIL | [HIGH] Initialization term creates $O(\sigma^4/\varepsilon^4)$ bottleneck |
| 5. Fix R1 | opus | Complete | Mini-batch initialization $B = O(\sigma/\varepsilon)$ fixes the gap |
| 4. Audit R2 | opus | **PASS** | All 6 steps VALID, 6 numerical checks passed |

---

## Routes Explored

1. **Route 1 (Winner): Lyapunov + Descent Lemma** — Standard framework with $\Phi_t = f(x_t) + c\|e_t\|^2$. Score: 35/40.
2. **Route 2: Direct Recursive Variance** — Unrolled recursion without explicit Lyapunov. Same result, less structured. Score: 25/40.
3. **Route 3: SPIDER Analogy** — Conceptual mapping STORM↔SPIDER. Good intuition but incomplete as self-contained proof. Score: 26/40.
4. **Route 4: Martingale Decomposition** — Orthogonality of increments gives clean variance bound. Score: 31/40.

---

## Final Proof

### Theorem (STORM Convergence)

Under assumptions (A1)-(A4) — L-smoothness, bounded variance $\sigma^2$, lower-bounded $f$, and mean-squared smoothness — with parameters $a = \Theta(\varepsilon^2/\sigma^2)$, $\eta = \Theta(\varepsilon/(L\sigma))$, and mini-batch initialization of size $B = O(\sigma/\varepsilon)$, STORM finds $x_\tau$ with $\mathbb{E}[\|\nabla f(x_\tau)\|^2] \leq \varepsilon^2$ within

$$T = O\left(\frac{\sigma^2}{\varepsilon^3} + \frac{1}{\varepsilon^2}\right)$$

stochastic gradient evaluations.

### Proof Structure

1. **Lemma 1 (Variance Recursion):** $\mathbb{E}[\|e_t\|^2 | \mathcal{F}_{t-1}] \leq (1-a)\|e_{t-1}\|^2 + 2L^2\eta^2\|d_{t-1}\|^2 + 2a^2\sigma^2$
   - Key tool: decomposition $e_t = (1-a)e_{t-1} + (1-a)\delta_t + a\epsilon_t$, mean-squared smoothness

2. **Lemma 2 (Descent via Polarization):** $f(x_{t+1}) \leq f(x_t) - \frac{\eta}{2}\|\nabla f\|^2 + \frac{\eta}{2}\|e_t\|^2 - \frac{\eta(1-L\eta)}{2}\|d_t\|^2$
   - Key tool: polarization identity from SPIDER proof [REF: proofs/research/optimization/stochastic/spider-nonconvex-gradient-complexity/proof.md]

3. **Lyapunov function** $\bar{\Phi}_t = \mathbb{E}[f(x_t)] + \frac{\eta}{2a}\mathbb{E}[\|e_t\|^2]$ with descent $\bar{\Phi}_{t+1} \leq \bar{\Phi}_t - \frac{\eta}{2}\mathbb{E}[\|\nabla f\|^2] + \eta a\sigma^2$

4. **Telescoping + parameter optimization** yields the stated complexity.

### Key Techniques
- Descent Lemma (L-smoothness) [REF: proofs/library/optimization/convergence/gd-nonconvex-stationary-point/proof.md]
- Polarization identity [REF: proofs/research/optimization/stochastic/spider-nonconvex-gradient-complexity/proof.md]
- Lyapunov function construction [REF: proofs/library/optimization/stochastic/svrg-linear-convergence-abc-framework/proof.md]
- Mini-batch initialization warm-start

---

## Audit Result

### Round 1: FAIL
- [HIGH] Single-sample initialization gives $O(\sigma^4/\varepsilon^4)$ bottleneck
- [MEDIUM] Mean-squared smoothness assumption not explicitly stated
- [LOW] Exposition had false starts

### Round 2 (after fix): PASS
- All 6 proof steps VALID
- 6/6 numerical verification checks passed
- All constants traced to source inequalities
- Cross-verified against SPIDER, SGD, and GD results — all consistent

### Fix History
- Round 1 → Round 2: Added mini-batch initialization ($B = O(\sigma/\varepsilon)$), explicit (A4) assumption, cleaned exposition

---

## Constant Table

| Constant | Value | Origin |
|----------|-------|--------|
| 2 (Lemma 1) | 2 | $\|u+v\|^2 \leq 2\|u\|^2 + 2\|v\|^2$ |
| 1/2 (Lemma 2) | 1/2 | Polarization identity |
| 6 (in $a$) | 6 | $2 \times 3$ from splitting bound into thirds |
| $12\sqrt{6}$ (in $T$) | 29.4 | Product of parameter constants |
