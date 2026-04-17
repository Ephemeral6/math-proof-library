# SGD Last-Iterate Convergence Rate (COLT 2020 Open Problem) — Averaged-Iterate Baseline

## Source
- Paper: Koren & Segal, COLT 2020 (Open Problem)
- Context: Closing the log(T) gap between upper and lower bounds for SGD last-iterate convergence. This proof establishes the averaged-iterate O(1/√T) baseline without the log(T) factor.

## Statement

Consider SGD on a convex, $G$-Lipschitz function $f$ over $W = [a,b] \subset \mathbb{R}$ ($d=1$):

$$x_{t+1} = \Pi_W(x_t - \eta_t g_t)$$

where $g_t$ is an unbiased stochastic subgradient with $\mathbb{E}[\|g_t\|^2] \leq G^2$.

**Prove:** With constant step size $\eta = D/(G\sqrt{T})$ (where $D = b-a$), the averaged iterate $\bar{x}_T = (1/T)\sum_{t=1}^T x_t$ satisfies:

$$\mathbb{E}[f(\bar{x}_T) - f^*] \leq \frac{DG}{\sqrt{T}} = O(1/\sqrt{T})$$

**Open problem (not solved here):** Whether the literal last iterate $x_T$ also achieves $O(1/\sqrt{T})$ (the Koren-Segal conjecture).

## Difficulty
conjecture
