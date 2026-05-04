# Fragment: martingale-cancellation-iterate-noise

## Statement
Let $\{x_t\}$ be SGD-like iterates with $x_{t+1}$ defined using stochastic gradient $g_t = s_t + \xi_t$ where $s_t \in \partial f(x_t)$ and $\mathbb{E}[\xi_t | \mathcal{F}_t] = 0$ (martingale-difference noise). Define $\delta_t := x_t - x^*$ and the projection-step inequality
$$2\eta\, g_t \delta_t \;\le\; \delta_t^2 - \delta_{t+1}^2 + \eta^2 g_t^2.$$
Substituting $g_t = s_t + \xi_t$ and writing $Z_t := -2\eta\,\xi_t \delta_t$:
$$2\eta\, s_t \delta_t + Z_t \;\le\; \delta_t^2 - \delta_{t+1}^2 + \eta^2 g_t^2.$$
Then $M_T := \sum_{t=1}^T Z_t$ is a **martingale** with $\mathbb{E}[M_T] = 0$, since $\delta_t \in \mathcal{F}_t$ and $\mathbb{E}[\xi_t | \mathcal{F}_t] = 0$:
$$\mathbb{E}[Z_t | \mathcal{F}_t] = -2\eta\,\delta_t\, \mathbb{E}[\xi_t | \mathcal{F}_t] = 0.$$
Taking unconditional expectation telescopes the noise away — yielding the standard SGD averaged-iterate bound
$$\mathbb{E}\!\sum_{t=1}^T \langle s_t, \delta_t\rangle \;\le\; \tfrac{D^2}{2\eta} + \tfrac{\eta T G^2}{2}.$$

## Proof
Direct: $\mathbb{E}[Z_t | \mathcal{F}_t] = -2\eta\delta_t \mathbb{E}[\xi_t | \mathcal{F}_t] = 0$ (using $\mathcal{F}_t$-measurability of $\delta_t$). Sum and apply iterated expectations to get $\mathbb{E}[M_T] = 0$. The remaining inequality after taking expectations and using $\mathbb{E}[g_t^2] \le G^2$:
$$2\eta \sum_t \mathbb{E}[\langle s_t, \delta_t\rangle] \le D^2 + \eta^2 T G^2,$$
which gives the averaged-iterate bound after dividing by $2\eta T$ and applying convexity (Jensen). $\square$

## Source
- `proofs/research/optimization/convergence/sgd-last-iterate-averaged-baseline/proof.md` — Steps 4-5.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (this is the canonical SGD averaged-iterate proof)
- **Potential applications**:
  - SGD convergence proofs (averaged or last-iterate)
  - Online convex optimization regret bounds
  - Stochastic mirror descent / FTRL analyses
  - Any scheme where noise can be moved into a martingale-difference sequence
  - Generic template for "kill the noise via $\mathbb{E}[M_T] = 0$"

## Tags
martingale, SGD, averaged-iterate, noise-cancellation, telescoping
