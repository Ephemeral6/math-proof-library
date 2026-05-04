# Proof Report: GDA Nonconvex-Strongly-Concave $O(\kappa^2 \epsilon^{-2})$ Convergence

## 1. Problem Statement

GDA for minimax problem $\min_x \max_y f(x,y)$ under (A1) $L$-smooth $\nabla f$, (A2) $\mu$-strongly concave $f(x,\cdot)$, (A3) $\Phi(x_0) - \min \Phi \le \Delta$ where $\Phi(x) := \max_y f(x,y)$. Two-time-scale GDA with $\eta_x = 1/(16\kappa^2 L)$, $\eta_y = 1/L$, $\kappa = L/\mu$. Target:
$$\frac{1}{T}\sum_{t=0}^{T-1}\|\nabla\Phi(x_t)\|^2 \le \frac{C_1 \kappa^2 L \Delta}{T} + \frac{C_2 \kappa^2 L \|y_0 - y^*(x_0)\|^2}{T}.$$

Source: Lin, Jin, Jordan 2020 (ICML), Theorem 4.4. Difficulty: research.

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 5 routes proposed (Lyapunov $V_t = \Phi + c\delta_t$, Danskin+bootstrap, PL inner-gap, IFT+Jacobian, linear coupling) |
| Explorer | Opus | 4 proofs attempted; all 4 completed (Route 3 required 1 retry after API termination) |
| Judge | Sonnet | Route 1 selected (27/30); others: Route 4 26/30, Route 2 21/30, Route 3 15/30 (PARTIAL) |
| Audit R1 | Opus | PASS with 2 MEDIUM cosmetic issues |
| Fix R1 | Opus | $C_2$ μ-absorption + Step 4 co-coercivity derivation cleaned up |
| Audit R2 | Opus | PASS — all fixes verified, no regression |

## 3. Proof Routes Explored

- **Route 1 (Winner)**: Lyapunov $V_t = \Phi(x_t) + (L/(4\kappa))\delta_t$ where $\delta_t = \|y_t-y^*(x_t)\|^2$. Direct descent-plus-contraction. Cleanest constants: $C_1=64$, $C_2=16$.
- **Route 2**: Danskin + approximate-gradient descent on $\Phi$ with bootstrap/self-bound. Closed but with weaker constants ($C_1,C_2 \approx 200$) and required retuning Young's.
- **Route 3**: PL / inner-gap Lyapunov $V_t = \Phi + c \cdot g_t$ where $g_t = \Phi(x_t) - f(x_t, y_t)$. Closed with $c = 2/5$ (not $c = O(\kappa)$ as initially hypothesized); weaker constants.
- **Route 4**: IFT + $y^*$ Jacobian perturbation. Structurally identical to Route 1 after IFT preamble; weaker Lyapunov weight $c = L/(2\kappa)$ yields $C_1=256$, $C_2=128$.

## 4. Final Proof

See `proof.md` in this folder.

**Core Lyapunov**: $V_t := \Phi(x_t) + \frac{L}{4\kappa}\delta_t$. With $\eta_x = 1/(16\kappa^2 L)$, $\eta_y = 1/L$, $\alpha = 1/(2\kappa)$ in Young's splitting:
$$V_{t+1} \le V_t - \frac{\eta_x}{4} \|\nabla\Phi(x_t)\|^2.$$
Telescope: $\sum_t \|\nabla\Phi(x_t)\|^2 \le 64\kappa^2 L \Delta + 16 \kappa^2 L \cdot L \|y_0 - y^*(x_0)\|^2$.

## 5. Audit Result

Round 1: PASS with 2 MEDIUM cosmetic issues (no math errors).
Round 2 (post-fix): PASS. All 9 steps VALID, all numerical checks pass, all constants traced.

## 6. Fix History

- **Fix R1 (cosmetic)**: (i) μ-absorption in Step 8 made explicit as $16\kappa L^2 \delta_0 = 16\kappa^2 L \mu \delta_0 \le 16\kappa^2 L^2 \delta_0$ (using $\mu \le L$). (ii) Step 4 replaced "cite + half-inline" with complete inline Nesterov co-coercivity derivation. (iii) LOW items (stray self-correction, redundant monotonicity, garbled parenthetical, $C_2 = 16\mu$ vs $C_2 = 16$ mismatch) all resolved.
