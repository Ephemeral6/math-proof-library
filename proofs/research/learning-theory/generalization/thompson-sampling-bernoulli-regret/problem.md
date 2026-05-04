# Thompson Sampling for Bernoulli Bandits: Problem-Independent $O(\sqrt{KT \log T})$ Regret

## Source
- **Paper**: S. Agrawal, N. Goyal, *"Further Optimal Regret Bounds for Thompson Sampling"*, AISTATS 2013 / *"Near-Optimal Regret Bounds for Thompson Sampling"*, JACM 2017.
- **Context**: Thompson Sampling (TS) is a Bayesian heuristic for multi-armed bandits: maintain a Beta posterior over each arm's reward probability and at each round sample from the posteriors, playing the arm with the highest sample. Despite its simplicity and heuristic origin (Thompson 1933), TS was only rigorously analyzed starting in 2012 (Agrawal-Goyal 2012, Kaufmann-Korda-Munos 2012). The distribution-independent rate $O(\sqrt{KT \log T})$ matches the UCB rate and is near-optimal (lower bound $\Omega(\sqrt{KT})$).

## Statement

**Setting**. Consider a $K$-armed Bernoulli bandit: at each round $t = 1, \ldots, T$, the learner plays arm $I_t \in [K]$ and receives reward $r_t \sim \mathrm{Bernoulli}(\mu_{I_t})$, where $\mu_1, \ldots, \mu_K \in [0,1]$ are unknown means. Let $\mu^* := \max_k \mu_k$ and $\Delta_k := \mu^* - \mu_k$ the suboptimality gap of arm $k$.

**Thompson Sampling Algorithm** (with Beta prior $\mathrm{Beta}(1,1)$):
- Initialize $S_k(0) = F_k(0) = 0$ for all $k \in [K]$ (success and failure counts).
- At round $t$:
  1. For each $k$, sample $\theta_k(t) \sim \mathrm{Beta}(S_k(t-1) + 1, F_k(t-1) + 1)$.
  2. Play $I_t = \arg\max_k \theta_k(t)$ (break ties arbitrarily).
  3. Observe $r_t \sim \mathrm{Bernoulli}(\mu_{I_t})$.
  4. Update: if $r_t = 1$, $S_{I_t}(t) = S_{I_t}(t-1) + 1$; else $F_{I_t}(t) = F_{I_t}(t-1) + 1$.

**Cumulative regret**:
$$\mathcal{R}(T) := \mathbb{E}\left[\sum_{t=1}^T (\mu^* - \mu_{I_t})\right] = \sum_{k: \Delta_k > 0} \Delta_k \cdot \mathbb{E}[N_k(T)],$$
where $N_k(T) := \sum_{t=1}^T \mathbb{1}[I_t = k]$ is the number of times arm $k$ was played.

**Target theorem** (Agrawal-Goyal 2017 JACM, problem-independent bound).

For Thompson Sampling with $\mathrm{Beta}(1,1)$ prior applied to a Bernoulli bandit with arbitrary means $\mu_1, \ldots, \mu_K \in [0,1]$:
$$\boxed{\;\mathcal{R}(T) \le C \sqrt{KT \log T}\;}$$
for an absolute constant $C > 0$, uniformly over all means and all $T \ge K$.

**Interpretation**:
- The bound is **distribution-independent** (does not depend on the gaps $\Delta_k$).
- Matches UCB1's $O(\sqrt{KT \log T})$ rate.
- Near-optimal: the minimax lower bound for stochastic bandits is $\Omega(\sqrt{KT})$ (Auer-Cesa-Bianchi-Freund-Schapire 2002).
- TS is empirically often superior to UCB despite matching theoretical rate.

## Difficulty
**research**

## Key intermediate results to prove

1. **Concentration of Beta posterior around empirical mean**: For $S \sim \mathrm{Beta}(s+1, f+1)$ with $s + f = n$, the sample concentrates around $\hat\mu := s/n$ with sub-Gaussian-like tails. Specifically, for $t \ge 1$:
$$\Pr(|S - \hat\mu| \ge \sqrt{t/n}) \le 2e^{-2t}.$$

2. **Beta-Binomial duality** (useful for analysis): $\Pr(\mathrm{Beta}(s+1, f+1) > y) = \Pr(\mathrm{Binom}(s+f+1, y) \le s)$.

3. **Decomposition of regret via good event**:
Define $\tau_k(t) := \sqrt{(2\log T)/N_k(t)}$ the UCB-width analogue, and the "good event" that $\theta_k(t)$ is close to $\hat\mu_k(t)$ and $\hat\mu_k(t)$ is close to $\mu_k$. On this event, arm $k$ is played only when $\theta_k(t) \ge \mu^* - \tau_k(t)$.

4. **Upper bound on $\mathbb{E}[N_k(T)]$ for suboptimal arms**:
Combining steps 1-3, show that for each arm $k$ with $\Delta_k > 0$:
$$\mathbb{E}[N_k(T)] \le \frac{C \log T}{\Delta_k^2} + O(1).$$
(This is the problem-dependent bound.)

5. **Translation to problem-independent bound via gap-balancing**:
Sum the per-arm regret contribution $\Delta_k \cdot \mathbb{E}[N_k(T)]$ over arms. Partition arms by whether $\Delta_k \le \sqrt{K \log T / T}$ (pay at most $\Delta_k T \le \sqrt{KT \log T}$ per such arm) or $\Delta_k > \sqrt{K \log T / T}$ (pay at most $C\log T / \Delta_k \le \sqrt{T K \log T}$ cumulated). This yields the $O(\sqrt{KT\log T})$ bound.
