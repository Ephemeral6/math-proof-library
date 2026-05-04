# 8.3 — Stochastic Cycling Stability under x-Noise

**Date:** 2026-04-26
**Status:** PASS — cycling is **geometrically stable** under additive x-noise. OP-2's bias term is robust.

## Headline result

**Theorem 8.3.** The Goujaud cycling orbit is **geometrically attracting** under additive x-noise, with Lyapunov exponent
$$\boxed{\lambda_{\mathrm{Lyap}} = \tfrac{1}{2}\log\beta < 0.}$$
For every $\sigma_x \in (0, \infty)$ the orbit is bounded in expectation and converges to a stationary distribution. **No critical $\sigma_x^\star$** above which cycling is destroyed by divergence.

## Lyapunov analysis (sub-task c) — the key calculation

**Cycle-point regularity.** At cycle vertex $\lambda e_t$, the polytope projection $P_{\widetilde C}(\lambda e_t) = \lambda M e_t$ lands on a **vertex** of $\widetilde C$. In an open neighborhood, $P_{\widetilde C}$ is constant, so $\nabla P_{\widetilde C}(\lambda e_t) = 0$ and
$$\nabla^2 f_0(\lambda e_t) = \mu I_2.$$

(Note: this corrects an earlier claim that the Hessian had structure $\mu I + (L-\mu)u u^\top$; that holds in the *interior* of an edge, not at a vertex projection. At vertex projections the Hessian is exactly $\mu I_2$.)

**Jacobian of state map.** State $X_t = (x_t, x_{t-1}) \in \mathbb{R}^4$. At a cycle vertex:
$$D\Phi = \begin{pmatrix}(1+\beta-\eta\mu) I_2 & -\beta I_2 \\ I_2 & 0_2\end{pmatrix}.$$

**Eigenvalues.** Each Cartesian coordinate decouples into companion form $\delta_{t+1} = a\delta_t - b\delta_{t-1}$ with $a = 1 + \beta - \eta\mu = 0.75$, $b = \beta = 0.5$. Roots: $z = 0.375 \pm 0.5995i$, magnitude $|z| = \sqrt\beta \approx 0.7071 < 1$.

**Spectral radius:** $\rho(D\Phi) = \sqrt\beta < 1$. **Cycle is strictly contracting in every direction.**

This *contradicts the user's intuition* in (d) that the cycle is neutrally stable: the strong-convexity term $\mu I$ in the Hessian provides a non-trivial restoring force on top of the rotational cycle. Neutrality would require $\mu = 0$, which doesn't apply on $f_0$ (where $\mu = \kappa L > 0$ structurally).

## Numerical experiment (sub-task a)

Setup: $(\beta, \eta L, \kappa, K) = (0.5, 3, 0.25, 3)$, $L=D=1$, cycling-init, $N=200$ MC trials.

| $\sigma_x$ | $T=100$: $\mathbb{E}\|x_T\|$ | $T=1000$ | $T=10000$ |
|---|---|---|---|
| 0 | 0.7071 | 0.7071 | 0.7071 |
| 0.001 | 0.7071 ± 0.004 | 0.7071 | 0.7073 |
| 0.01 | 0.7074 ± 0.041 | 0.7121 | 0.7019 |
| 0.1 | 0.6025 ± 0.316 | 0.5954 | 0.5734 |
| 0.5 | 2.382 ± 1.20 | 2.345 | 2.363 |
| 1.0 | 4.701 ± 2.60 | 4.904 | 4.542 |

**All entries are stationary in $T$** — no divergence. Small $\sigma_x$ stays near the cycle; large $\sigma_x$ explores a stationary distribution centered at 0 with size $\sim \sigma_x \cdot \eta/\sqrt{1-\beta}$.

## Variance amplification (sub-task d)

Discrete Lyapunov equation $\Sigma = A\Sigma A^\top + Q$ with $A = \begin{pmatrix}a & -b\\ 1 & 0\end{pmatrix}$, $Q = \eta^2\sigma_x^2\,\mathrm{diag}(1, 0)$ gives
$$\mathrm{Var}_\infty(\delta) = \frac{\eta^2(1+\beta)}{(1-\beta)\big((1+\beta)^2 - (1+\beta-\eta\mu)^2\big)}\sigma_x^2 = 16\,\sigma_x^2.$$
Per Cartesian coord, so $\mathbb{E}\|\delta\|^2 = 32\,\sigma_x^2$.

**Numerical verification ($t \in [100, 200]$):**
- $\sigma_x = 0.001$: theory $3.2 \times 10^{-5}$, measured $3.2 \times 10^{-5}$ ✓
- $\sigma_x = 0.01$: theory $3.2 \times 10^{-3}$, measured $3.3 \times 10^{-3}$ ✓
- $\sigma_x = 0.1$: theory $0.32$, measured $0.96$ — **linear theory breaks** because orbit drifts off the single-vertex projection neighborhood.

**Variance is bounded in $T$**, not $\propto T$. The user's prediction $\mathrm{Var}(x_T) \sim T\sigma_x^2$ in (d) is **rejected** — it would require a neutral eigenvalue (=1), but here the eigenvalues have $|z| = \sqrt\beta < 1$.

## Critical noise threshold (sub-task b)

**There is no critical $\sigma_x^\star$.** Running $T = 5000$ for $\sigma_x \in \{1, 2, 5\}$ shows $\mathbb{E}\|x_T\|$ saturates around $\{4.7, 9.5, 24\}$ respectively, with no growth between $t = 500$ and $t = 5000$. The dynamics has a **bounded stationary law for all $\sigma_x > 0$** because $f_0$ is globally $\mu$-strongly convex on $\mathbb{R}^2$.

## Verdict for OP-2 (sub-task e)

**OP-2's bias term is ROBUST to small x-noise.**

1. For $\sigma_x \ll D$, the LB still holds: $\mathbb{E}\|x_T\| \approx D/\sqrt 2$ to within $O(\sigma_x)$, and $\mathbb{E}[f_0(x_T) - f_0^\star] \ge \mu D^2/4 - O(\sigma_x^2)$.
2. No critical $\sigma_x^\star$ destroys cycling abruptly — the orbit smoothly transitions from "concentrated near deterministic 3-cycle" to "diffuse stationary law."
3. Large x-noise ($\sigma_x \sim D$) actually *strengthens* the bias term (variance-dominated): $\mathbb{E}[f_0(x_T)] = 5.3$ at $\sigma_x = 1$ vs $0.22$ at $\sigma_x = 0$.

**OP-2's choice of zero x-noise is for proof clarity, not technical necessity.** The proof would extend to small x-noise with an $O(\sigma_x^2)$ second-order correction to the bias constant.

## Practical takeaway

This result complements OP-2 nicely: it shows the cycling lower bound is robust to oracle-noise on the cycling coordinate. Future work could extend OP-2 to the unified noise setting $\xi_t \sim \mathcal{N}(0, \sigma^2 I_3)$ on all 3 coordinates, with the bias constant degrading by an $O(\sigma_x^2/L^2)$ factor.
