# Proof Report: SGD Convergence under PL + Interpolation with Iterate Averaging

## 1. Problem Statement

SGD on $f = \frac{1}{n}\sum f_i$ with $L$-smooth $f$, $\mu$-PL, interpolation ($\nabla f_i(x^*)=0$), strong growth ($\rho$).

**(a)** $\gamma = 1/(\rho L)$: $\mathbb{E}[f(x_t)-f^*] \leq (1-\mu/(\rho L))^t(f(x_0)-f^*)$

**(b)** $\gamma_t = 2/(\mu(t+t_0))$, $t_0 = 2\rho L/\mu$: $\mathbb{E}[f(\bar{x}_T)-f^*] \leq O(\rho L/(\mu T) \cdot \epsilon_0)$

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 5 routes proposed |
| Explorer | Opus | 5 proofs attempted, all succeeded |
| Judge | Sonnet | Route 5 selected (score: 37/40) |
| Audit | Opus | PASS (1 round, all steps valid) |
| Fix | — | Not needed |

## 3. Proof Routes Explored

1. **Direct Lyapunov / Abel summation** (35/40): Elegant Abel summation avoids induction
2. **Potential Function** (29/40): Gets weaker 1/t rate (not 1/t²) per iterate
3. **Bias-Variance** (33/40): Clean induction, long presentation
4. **Weighted Recursion** (32/40): Same induction, summing-factor interpretation
5. **Direct Recursion** (37/40, WINNER): Most rigorous induction verification, clean μ² reconciliation

## 4. Final Proof

**Part (a):** Standard. L-smoothness descent + strong growth with $\gamma = 1/(\rho L)$ gives effective coefficient $1/2$. PL converts to $(1-\mu/(\rho L))$ contraction.

**Part (b):** The key is proving by induction that $e_t \leq t_0^2/(t+t_0)^2 \cdot e_0$ — an $O(1/t^2)$ per-iterate rate. The inductive step requires showing $\alpha_t \leq s^2/(s+1)^2$, verified by cross-multiplication: $(s^2-4s+2t_0)(s+1)^2 \leq s^4$ reduces to $P(s) = 2s^3 - (2t_0-7)s^2 - (4t_0-4)s - 2t_0 \geq 0$, which holds since $P(t_0) = 3t_0^2+2t_0 > 0$ and $P'(s) > 0$ for $s \geq t_0$.

Averaging via Jensen (f convex): $\sum 1/(t+t_0)^2 \leq 2/t_0$ gives $\mathbb{E}[f(\bar{x}_T)-f^*] \leq 4\rho L \cdot e_0/(\mu T)$.

**Rate reconciliation:** The bound is $O(\rho L/(\mu T) \cdot e_0)$ with $e_0 = f(x_0)-f^*$. Equivalently, $O(\rho L/(\mu^2 T) \cdot \|\nabla f(x_0)\|^2)$ via PL.

## 5. Audit Result

PASS on first round. All 12 audit points verified. Minor presentation note only.

## 6. Fix History

No fixes needed.
