# 8.2 — Momentum Cooling/Warmup Schedules

**Date:** 2026-04-26
**Status:** UNCERTAIN — algebraic obstruction clear, but $f_0$ alone is μ-SC so test case isn't a true non-SC separation.

## Verdict

OP-2's lower bound *as stated* (with cycling-attaining initialization and **fixed** $\beta$) does NOT transfer to time-varying momentum schedules. But this does NOT cleanly establish that scheduled momentum *accelerates*: the test instance $f_0$ alone is $\mu$-SC ($\mu = \kappa L > 0$), and Nesterov's $T^{-3}$ behavior on $f_0$ is consistent with classical SC theory.

## Algebraic finding (a) — cycling exactly breaks

For OP-2's cycling identity, the polytope is built around the **construction** $\beta_c$. With time-varying $\beta_t$:
$$x_{t+1} = \lambda\,e_{t+1} + (\beta_t - \beta_c)\,\lambda\,(e_t - e_{t-1}).$$

Per-step deviation from cycle: exactly $|\beta_t - \beta_c|\,\lambda\sqrt{2(1-c_K)} = |\beta_t - \beta_c|\,\lambda\sqrt 3$ at $K=3$. **Cycle persists ↔ $\beta_t \equiv \beta_c$.**

## Numerical experiment (b)

Setup: $f_0$ with $(\beta_c, \eta L, \kappa) = (0.5, 3, 0.25)$, cycling-init, $T = 10000$.

| Schedule | cycles? | $f_0(x_T)$ | LB target $6.25\!\times\!10^{-6}$ |
|---|---|---|---|
| Constant $\beta = 0.5$ | **YES** | 0.222 | satisfied |
| Cool to 0 (any $\rho$) | NO | 0.125 | satisfied (drift attractor at $\|x\|\approx 0.556$) |
| Cool to 0.3 (any $\rho$) | NO | 0.264 | satisfied (drift to $\|x\|\approx 0.821$) |
| Warmup 0→0.5 (any $\rho$) | NO | 0.014–0.040 | satisfied |
| **Nesterov $(t-1)/(t+2)$** | NO | $3 \times 10^{-13}$ | **VIOLATED** |

Nesterov $\beta_t = (t-1)/(t+2)$ achieves $T^{-3}$ decay on $f_0$, defeating the LB target by 7 orders of magnitude.

## Transient analysis (c)

Warmup time to enter $\mathcal{F}_{K=3}$: $T_w = \log(1 - 2\beta^\star)/\log\rho$, where $\beta^\star = (\sqrt{13}-3)/2 \approx 0.303$.
- $\rho = 0.99 \to T_w \approx 92.6$
- $\rho = 0.9 \to T_w \approx 8.8$
- $\rho = 0.5 \to T_w \approx 1.3$

After $T_w$, even as $\beta_t \to \beta_c$, the iterate **does not re-lock** onto the cycle (the cycle is unstable to displacement; orbit is captured by a different attractor).

## Subtlety: $f_0$ is $\mu$-SC

The OP-2 LB is for the *compound* $f^{(s)}(x,y) = f_0(x) + \alpha_s y + w(y)$, globally 0-SC because of the $y$-direction. But $f_0$ alone is $\mu$-SC with $\mu = \kappa L > 0$. The bias term in OP-2 lives in the $x$-coord, where $f_0$ is SC. So:

**Nesterov's $T^{-3}$ on $f_0$ is consistent with classical SC theory** — *not* a separation result for non-SC functions.

To make 8.2 a clean test, one needs a non-SC hard instance where fixed momentum cycles *and* every reasonable schedule fails to accelerate. We do not have a candidate.

## Verdict

**(c) UNCERTAIN.**
- (a) is **false**: scheduled momentum strictly breaks the cycle.
- (b) is **partially true**: Nesterov accelerates on this $f_0$, but only because $f_0$ is SC.
- A clean non-acceleration result for *all* schedules on smooth-convex non-SC functions remains open.
