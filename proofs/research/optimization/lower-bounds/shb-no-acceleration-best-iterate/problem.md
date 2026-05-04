# Best-iterate lower bound for stochastic SHB on F (OP-2 / I3 extension)

## Source
- Extension of OP-2 (Goujaud-Taylor-Dieuleveut 2023 polytope-Moreau cycling).
- Direction: Iterate-type extension. Replace last iterate $x_T$ with best iterate $\min_{t \le T} f(x_t)$.
- Companion result to `proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/`.

## Setup (inherited from OP-2)

- $L, \sigma, D > 0$ fixed.
- $\mathcal{F} \subset \mathcal{S}$ = Goujaud cycling sub-region of SHB stability.
- For $(\beta, \eta) \in \mathcal{F}$, the polytope-Moreau function $f_{\beta, \eta}$ is $L$-smooth and $\mu = \kappa(\beta, \eta) L$-strongly convex.
- Stochastic oracle: $g_t = \nabla f(x_t) + \xi_t$, $\mathbb{E}[\xi_t] = 0$, $\mathbb{E}\|\xi_t\|^2 \le \sigma^2$.
- SHB: $x_{t+1} = x_t - \eta g_t + \beta(x_t - x_{t-1})$.

## Statement (target)

For every $(\beta, \eta) \in \mathcal{F}$, exists $f$ + stochastic oracle such that
$$
\mathbb{E}\Big[\min_{0 \le t \le T} f(x_t) - f^\star\Big] \ge c(\beta, \eta) \cdot LD^2/T \;+\; c' \cdot \sigma D/\sqrt T \quad \forall T \ge 1.
$$

## Difficulty
research

## Outcome (PARTIAL PASS)

**Bias term**: $\Omega(\kappa LD^2/T)$ for best iterate is PROVED on $\mathcal{F}$ — same construction and constant as OP-2, transfers verbatim because the deterministic orbit cycles on the $D/\sqrt 2$-circle from $t = 0$ (no transient).

**Variance term**: $\Omega(\sigma D/\sqrt T)$ for best iterate is DISPROVED on the OP-2 construction. The SHB random walk visits the optimum's neighborhood, giving $\min_t g_y - \min g_y = O(1/T)$ asymptotically — faster decay than $1/\sqrt T$. Le Cam two-point argument (which works for last iterate) breaks because the natural test $\hat s = -\mathrm{sign}(y_{t^*})$ is near-perfect, so cannot be Le Cam-lower-bounded.

**Verdict**: The combined statement (bias + variance jointly) is FALSE on this construction. The bias-only sub-statement is the correct, rigorous theorem.
