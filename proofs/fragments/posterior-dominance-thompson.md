# Fragment: posterior-dominance-inflation-thompson

## Statement
Consider Thompson Sampling on a $K$-armed bandit. At each round $t$, samples $\theta_1(t), \ldots, \theta_K(t)$ are drawn from the per-arm posteriors (independent given $\mathcal{F}_{t-1}$), and arm $I_t = \arg\max_k \theta_k(t)$ is pulled. Fix any suboptimal arm $k$ and threshold $y_k \in \mathbb{R}$, and define
$$p_t \;:=\; \Pr(\theta_1(t) > y_k \,|\, \mathcal{F}_{t-1}).$$

Then for every $t$:
$$\Pr(I_t = k,\; \theta_k(t) < y_k \,|\, \mathcal{F}_{t-1}) \;\le\; \frac{1 - p_t}{p_t}\,\Pr(I_t = 1 \,|\, \mathcal{F}_{t-1}).$$

(Convention: $0/0 = 0$, $x/0 = +\infty$ for $x > 0$.)

## Proof (sketch)
Work conditionally on $\mathcal{F}_{t-1}$. Let $M_{-k} := \max_{j \notin\{1, k\}}\theta_j(t)$. Condition on the realization of $\theta_{-1}(t)$ (all coordinates except $\theta_1$); $\theta_1(t)$ is independent of these.

For the LHS: on $\{\theta_k(t) = \vartheta_k < y_k\}$ and $\{\vartheta_k \ge M_{-k}\}$, the event $\{I_t = k\}$ requires $\theta_1(t) \le \vartheta_k$. Since $\vartheta_k < y_k$:
$$\Pr(\theta_1(t) \le \vartheta_k) \le \Pr(\theta_1(t) \le y_k) = 1 - p_t.$$

For the RHS: on the same event, $\{I_t = 1\}$ holds when $\theta_1(t) \ge \max(\vartheta_k, M_{-k}) = \vartheta_k < y_k$, which is implied by $\theta_1(t) > y_k$ (so probability $\ge p_t$).

Integrating both bounds against the distribution of $\theta_{-1}(t)$ over the common event $\{\vartheta_k \ge M_{-k}, \vartheta_k < y_k\}$ gives the same auxiliary integral $Q$ multiplied respectively by $1 - p_t$ and $p_t$. Dividing yields the claim. $\square$

## Source
- `proofs/research/learning-theory/generalization/thompson-sampling-bernoulli-regret/proof.md` — Lemma 3.1 ("Posterior-dominance / inflation lemma").

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (this is **the** combinatorial heart of Agrawal-Goyal's Thompson Sampling regret bound)
- **Potential applications**:
  - Thompson Sampling regret bounds (Bernoulli, Gaussian, exponential family)
  - Bayesian regret analyses generally
  - Reducing regret of suboptimal-arm pulls to regret of optimal-arm pulls
  - Confidence-bound vs. randomization comparisons
  - Best-arm identification arguments

## Tags
thompson-sampling, bandit, posterior-dominance, inflation, regret, agrawal-goyal
