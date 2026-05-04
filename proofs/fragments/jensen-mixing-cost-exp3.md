# Fragment: jensen-mixing-cost-exp3

## Statement
Let $\tilde{p}_t \in \Delta_K$ be the multiplicative-weight distribution and define the $\gamma$-mixed sampling distribution
$$p_t(i) = (1 - \gamma)\tilde{p}_t(i) + \gamma/K, \quad \gamma \in (0, 1].$$
Then for every loss vector $\ell_t \in [0, 1]^K$ and every arm $i \in [K]$:
$$\langle p_t, \ell_t\rangle - \ell_t(i) \;\le\; \langle \tilde{p}_t, \ell_t\rangle - \ell_t(i) + \gamma.$$

In particular, replacing the sampling distribution $p_t$ by the unmixed distribution $\tilde{p}_t$ in the regret accounting costs at most $\gamma$ per round (the **mixing cost**).

The dual property — bounded importance weight ratio:
$$\frac{\tilde p_t(i)}{p_t(i)} \;\le\; \frac{1}{1 - \gamma},$$
controls the variance of importance-weighted estimators.

## Proof
Decompose $\langle p_t, \ell_t\rangle = (1-\gamma)\langle\tilde{p}_t, \ell_t\rangle + \gamma\langle\mathbf{u}, \ell_t\rangle$ where $\mathbf{u} = (1/K, \ldots, 1/K)$. Subtract $\ell_t(i)$ from both sides:
$$\langle p_t, \ell_t\rangle - \ell_t(i) = (1-\gamma)(\langle\tilde p_t, \ell_t\rangle - \ell_t(i)) + \gamma(\langle\mathbf{u}, \ell_t\rangle - \ell_t(i)).$$
The desired inequality becomes
$$-\gamma(\langle\tilde p_t, \ell_t\rangle - \ell_t(i)) + \gamma(\langle\mathbf{u}, \ell_t\rangle - \ell_t(i)) \le \gamma,$$
i.e., $\langle\mathbf u, \ell_t\rangle - \langle\tilde p_t, \ell_t\rangle \le 1$, which holds since both terms are in $[0, 1]$.

Importance ratio: $p_t(i) = (1-\gamma)\tilde p_t(i) + \gamma/K \ge (1-\gamma)\tilde p_t(i)$, so $\tilde p_t(i)/p_t(i) \le 1/(1-\gamma)$. $\square$

## Source
- `proofs/research/learning-theory/generalization/exp3-adversarial-bandit-regret/proof.md` — Step 4 (mixing cost) + Step 3 (variance control).

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (key step in EXP3 regret bound)
- **Potential applications**:
  - EXP3 / EXP3.P / EXP4 adversarial-bandit regret analysis
  - $\gamma$-uniform-mixing arguments for importance sampling stability
  - Off-policy RL with behavior-policy clipping
  - Regret-vs-variance trade-offs in randomized algorithms
  - Doubly-robust estimator variance control

## Tags
exp3, bandit, mixing, importance-weighted, variance-control, exploration
