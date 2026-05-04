# Notes: Thompson Sampling $O(\sqrt{KT \log T})$ Regret for Bernoulli Bandits

## Proof technique

**Winning route**: Route 1 — Agrawal-Goyal 2017 good-event decomposition + posterior-dominance (inflation) lemma.

The key structural insight is the **posterior-dominance inflation lemma** (Lemma 3.1): conditional on the filtration $\mathcal{F}_{t-1}$, the probability that suboptimal arm $k$ is played with a "pessimistic" sample $\theta_k(t) < y_k$ is upper-bounded by $\frac{1-p_t}{p_t}$ times the probability that the optimal arm $1$ is played with the same condition on $\theta_k$:
$$\Pr(I_t = k, \theta_k < y_k | \mathcal{F}_{t-1}) \le \frac{1-p_t}{p_t} \Pr(I_t = 1, \theta_k < y_k | \mathcal{F}_{t-1})$$
where $p_t := \Pr(\theta_1(t) > y_k | \mathcal{F}_{t-1})$.

The derivation (Steps A–D) exploits conditional independence of $\theta_1(t)$ from $\theta_{-1}(t) = (\theta_j)_{j \ne 1}$ given $\mathcal{F}_{t-1}$. Both probabilities share a common factor $Q = \Pr(\theta_k < y_k, \theta_k \ge M_{-k})$ where $M_{-k} = \max_{j \ne 1, k} \theta_j$; the LHS/RHS ratio cleanly collapses to $(1-p_t)/p_t$.

## Key steps

1. **Beta-Binomial duality** (Lemma 1.1): $\Pr(\mathrm{Beta}(s+1, f+1) \le y) = \Pr(\mathrm{Binom}(s+f+1, y) \ge s+1)$. Proof by matching derivatives of the incomplete Beta function and boundary values.

2. **Beta sub-Gaussian concentration** (Lemma 2.1): via duality + Hoeffding on Binomial, gives $\Pr(|\theta - s/n| \ge \varepsilon) \le 2\exp(-n\varepsilon^2)$. The classical tight constant is $\exp(-2n\varepsilon^2)$; we weaken to $\exp(-n\varepsilon^2)$ since downstream $n\varepsilon^2 = L = 4\log T$ is plenty.

3. **Good-event decomposition**: $E_k^\mu(t) = \{|\hat\mu_k - \mu_k| \le \sqrt{L/(2n)}\}$, $E_k^\theta(t) = \{|\theta_k - \hat\mu_k| \le \sqrt{L/n}\}$, $G_k(t) = E_k^\mu \cap E_k^\theta$. On $G_k$, $|\theta_k - \mu_k| \le 2\sqrt{L/n}$.

4. **Three-part play decomposition**: $N_k(T) = N_k^{(a1)} + N_k^{(a2)} + N_k^{\mathrm{bad}}$:
   - (a1) plays with $\theta_k \ge y_k$ on good event: $\le 16L/\Delta_k^2$ by pigeonhole.
   - (a2) plays with $\theta_k < y_k$ on good event: controlled via inflation lemma, giving $O(\log T/\Delta_k^2)$.
   - bad event plays: $\le 4T^{-3}$ via Hoeffding and Beta concentration.

5. **Lemma 3.2** (sum bound): $\sum_t \mathbb{E}[(1-p_t)/p_t \cdot \mathbb{1}[I_t = 1] | \mathcal{F}_{t-1}] \le O(\log T/\Delta_k^2)$. The reduction is: $p_t$ depends on $t$ only through $n_1(t)$, and at most one round per block of constant $n_1$ satisfies $I_t = 1$. The per-$n$ moment bound $\mathbb{E}[1/p_{(n)}] - 1$ is imported from AG 2013 Lemma 4.

6. **Gap-balancing**: Threshold $\Delta^* = \sqrt{K\log T/T}$:
   - Small-gap arms ($\Delta_k \le \Delta^*$): contribute $\le \Delta^* \cdot T = \sqrt{KT \log T}$ total.
   - Large-gap arms ($\Delta_k > \Delta^*$): contribute $\le K \cdot C\log T / \Delta^* = C\sqrt{KT \log T}$.
   - Total: $\le C'\sqrt{KT \log T}$.

## Audit result

**Round 1**: MEDIUM issue on Lemma 3.1 (sketch).
**Round 2: PASS**.
- Lemma 3.1 Steps A–D: rigorous, measure-theoretically sound.
- Lemma 3.2 reduction: VALID with AG 2013 Lemma 4 import.
- Gap-balancing: numerically verified.

Only LOW-severity items remain (constants, sharper-form exposition).

## Related results

- **UCB1 regret bound** (Auer, Cesa-Bianchi, Fischer 2002): matches TS's $O(\sqrt{KT \log T})$ via a very different analysis (Chernoff concentration on empirical means, confidence interval optimism).
- **Minimax lower bound** $\Omega(\sqrt{KT})$ (Auer-Cesa-Bianchi-Freund-Schapire 2002): TS is near-optimal but off by $\sqrt{\log T}$.
- **Information ratio / Bayesian regret** (Russo-Van Roy 2016): proves Bayesian regret $O(\sqrt{KT \log K})$ — tighter in $K$ but in a Bayesian sense. Route 2 of this proof produces this result; the frequentist conversion is non-trivial.
- **EXP3 adversarial bandit** ([REF: proofs/research/learning-theory/generalization/exp3-adversarial-bandit-regret/]): $O(\sqrt{KT \log K})$ in the adversarial setting; different techniques (exponential weights + potential).
- **OFUL linear bandit** ([REF: proofs/research/learning-theory/generalization/oful-linear-bandit-regret/]): $O(d\sqrt{T})$ for linear structure; uses self-normalized martingale.

## Lessons learned (for future bandit proofs)

1. **Posterior-dominance is the central technique for TS**: The inflation lemma $(1-p_t)/p_t$ factor is what converts Beta posterior samples into UCB-style bounds. It replaces the explicit confidence interval of UCB with a "latent" optimism via the posterior distribution.

2. **Conditional independence is critical**: The independence of $\theta_1(t)$ from $\theta_{-1}(t)$ given $\mathcal{F}_{t-1}$ is what makes the inflation lemma derivable. Any attempt to couple samples across arms (Route 4's two-phase counting) runs into the under-exploration problem.

3. **Bayesian-to-frequentist conversion is not automatic**: Route 2's information-ratio bound gives cleaner Bayesian regret $O(\sqrt{KT \log K})$, but converting to frequentist for a fixed Beta(1,1) TS re-introduces the full Agrawal-Goyal machinery — there's no shortcut.

4. **Gap-balancing is mechanical once per-arm bound is established**: The $O(\log T / \Delta_k^2)$ → $O(\sqrt{KT \log T})$ transformation via threshold $\Delta^* = \sqrt{K\log T/T}$ is a universal trick applicable to any problem-dependent bandit bound.

5. **Beta concentration via Beta-Binomial duality**: Instead of working with Beta tails directly (which require non-trivial integration), always convert to Binomial tails and use Hoeffding. This reduces the Beta posterior analysis to elementary Bernoulli concentration.
