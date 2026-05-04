# UCB-Hoeffding Q-Learning Regret $\tilde O(\sqrt{H^4 SAT})$

## Source
- Paper: Jin, Allen-Zhu, Bubeck & Jordan (2018), "Is Q-Learning Provably Efficient?", NeurIPS 2018 (arXiv:1807.03765). Theorem 1 (UCB-Hoeffding variant).
- Context: The first proof that model-free Q-learning achieves sublinear regret in episodic tabular MDPs. It is the tabular analog of OFUL (linear bandits) lifted to sequential decision making. The library has OFUL (linear bandit), synchronous Q-learning (generative model, finite-time sample complexity), and TD(0) linear approximation, but no *regret* bound for online tabular RL. This fills that gap and serves as the gateway to LSVI-UCB / linear-MDP regret analyses.

## Setup

We consider episodic tabular MDPs $\mathcal M = (\mathcal S, \mathcal A, H, \mathbb P, r)$ where
- $\mathcal S$ is a finite state space with $|\mathcal S| = S$;
- $\mathcal A$ is a finite action space with $|\mathcal A| = A$;
- $H \in \mathbb{N}$ is the horizon length;
- $\mathbb P = \{\mathbb P_h\}_{h=1}^H$ are stage-dependent transition kernels, $\mathbb P_h(\cdot \mid s, a) \in \Delta(\mathcal S)$;
- $r = \{r_h\}_{h=1}^H$ are stage-dependent reward functions $r_h : \mathcal S\times\mathcal A \to [0, 1]$ (deterministic rewards for simplicity — the argument extends to stochastic rewards with [0,1] bound).

An episode starts at a fixed initial state $s_1^k$ (arbitrarily chosen by an adversary or a fixed distribution; the regret analysis is *per-initial-state* in the worst case). The agent interacts with $\mathcal M$ for $K$ episodes; in episode $k$, at step $h$, it observes $s_h^k$, plays $a_h^k$, receives $r_h(s_h^k, a_h^k)$, and transitions to $s_{h+1}^k \sim \mathbb P_h(\cdot\mid s_h^k, a_h^k)$. Let $T = KH$ be the total number of timesteps.

Define the optimal value and Q-value functions
$$V_h^*(s) = \max_{a} Q_h^*(s,a), \qquad Q_h^*(s,a) = r_h(s,a) + [\mathbb P_h V_{h+1}^*](s, a), \qquad V_{H+1}^*(s) \equiv 0.$$

## Algorithm — UCB-Hoeffding Q-Learning

Initialize $Q_h(s,a) \leftarrow H$ (an upper bound on $V_h^*$) for all $(s,a,h)$ and $N_h(s,a) \leftarrow 0$.

For episode $k = 1, \dots, K$:
- Receive initial state $s_1^k$.
- For $h = 1, \dots, H$:
  1. Take action $a_h^k = \arg\max_{a'} Q_h(s_h^k, a')$ (ties broken arbitrarily).
  2. Observe $s_{h+1}^k$ and reward $r_h(s_h^k, a_h^k)$.
  3. Set $t \leftarrow N_h(s_h^k, a_h^k) + 1$, $N_h(s_h^k, a_h^k) \leftarrow t$.
  4. Set the learning rate $\alpha_t = \frac{H+1}{H+t}$.
  5. Set the Hoeffding bonus $b_t = c \cdot \sqrt{\frac{H^3\, \iota}{t}} = c\, H^{3/2}\sqrt{\frac{\iota}{t}}$ where $\iota = \log(SAT/\delta)$ for failure probability $\delta \in (0, 1]$ and $c > 0$ is an absolute constant (e.g., $c = 4$). The $H^{3/2}$ scaling (not $H$) is required so that the bonus dominates the *accumulated* martingale noise through the backward induction — each of the $H$ horizon levels contributes a factor $\sqrt H$ to the Azuma deviation via the recursive expansion.
  6. Update
  $$Q_h(s_h^k, a_h^k) \leftarrow (1-\alpha_t)\, Q_h(s_h^k, a_h^k) + \alpha_t\big[r_h(s_h^k, a_h^k) + V_{h+1}(s_{h+1}^k) + b_t\big],$$
  where $V_{h+1}(s) := \min\{H, \max_{a'} Q_{h+1}(s, a')\}$ is the clipped value function induced by the current Q-table.

All other $Q_h(s',a')$ entries are unchanged in this step.

## Claim (Main Theorem)

Let $K$ be the total number of episodes and $T = KH$. For any $\delta \in (0,1]$, with probability at least $1 - \delta$, the total regret satisfies
$$\mathrm{Regret}(K) := \sum_{k=1}^{K} \big[V_1^*(s_1^k) - V_1^{\pi_k}(s_1^k)\big] \;\le\; C \cdot \sqrt{H^4 S A T\, \iota^2},$$
where $\iota = \log(SAT/\delta)$, $C > 0$ is an absolute numerical constant, and $\pi_k$ is the greedy policy induced by $\{Q_h\}$ at the start of episode $k$.

Equivalently, $\mathrm{Regret}(K) = \tilde O(\sqrt{H^4 S A T})$ where $\tilde O$ hides polylogarithmic factors.

## Difficulty

**research**

## Notation & conventions

- $\pi^k = \{\pi_h^k\}_{h=1}^H$ is the greedy policy at the start of episode $k$: $\pi_h^k(s) \in \arg\max_{a'} Q_h^k(s, a')$ where $Q_h^k$ is the Q-table at the start of episode $k$.
- $V_h^{\pi}$, $Q_h^{\pi}$ are the value/Q functions under policy $\pi$ satisfying $V_h^\pi(s) = Q_h^\pi(s, \pi_h(s))$ and $Q_h^\pi(s,a) = r_h(s,a) + [\mathbb P_h V_{h+1}^\pi](s,a)$.
- The *clipped* value function $V_{h}(s) := \min\{H, \max_{a'} Q_h(s, a')\}$ — clipping preserves the upper bound $V_h^*(s) \le V_h(s) \le H$ once optimism is established.
- $n_h^k(s,a)$ denotes the value of the counter $N_h(s,a)$ at the start of episode $k$. At the end of episode $k$, if $(s_h^k, a_h^k) = (s,a)$, the counter increments by 1.
- For a fixed $(s,a,h)$, let $t = n_h^k(s,a)$, and let $k_i = k_i(s,a,h)$ (for $i = 1, \dots, t$) denote the indices of the previous episodes in which $(s_h^{k_i}, a_h^{k_i}) = (s,a)$, so that $t$ equals the number of visits before episode $k$.

## Key learning-rate identities (used repeatedly)

Let $\alpha_t = \frac{H+1}{H+t}$. Define
$$\alpha_t^0 = \prod_{j=1}^{t}(1 - \alpha_j), \qquad \alpha_t^i = \alpha_i \prod_{j=i+1}^{t}(1 - \alpha_j) \quad (1 \le i \le t).$$

Then (to be used without reproof, these are elementary algebraic facts; the proof should still verify them in Step 0):

1. $\sum_{i=1}^t \alpha_t^i = 1$, and $\alpha_t^0 = 0$ for $t \ge 1$ (since $1 - \alpha_1 = 0$). More precisely, $\alpha_t^0 = \mathbb 1[t = 0]$.
2. $\frac{1}{\sqrt t} \le \sum_{i=1}^t \alpha_t^i / \sqrt i \le \frac{2}{\sqrt t}$ for every $t \ge 1$.
3. $\sum_{i=1}^{\infty} \alpha_t^i \le 1 + \frac{1}{H}$.
4. $\sum_{t=i}^{\infty} \alpha_t^i \le 1 + \frac{1}{H}$ for every $i \ge 1$.

## Key intermediate results to establish

1. **Recursive Q-error expansion** (Lemma A). Let $\phi_h^k(s,a) = Q_h^k(s,a) - Q_h^*(s,a)$ where $Q_h^k$ is the Q-table at the *start* of episode $k$. Expanding the update rule step by step and using $\alpha_t^0 = 0$, one obtains for every $(s,a,h)$ and every $k$ with $t = n_h^k(s,a)$:
$$\phi_h^k(s,a) = \sum_{i=1}^t \alpha_t^i \Big[V_{h+1}^{k_i}(s_{h+1}^{k_i}) - V_{h+1}^*(s_{h+1}^{k_i})\Big] + \sum_{i=1}^t \alpha_t^i \Big[[\mathbb P_h V_{h+1}^*](s, a) - V_{h+1}^*(s_{h+1}^{k_i})\Big] + \sum_{i=1}^t \alpha_t^i\, b_i.$$

The three sums are, respectively, the "value propagation error", the "martingale noise", and the "cumulative bonus".

2. **Optimism** (Lemma B). With probability at least $1 - \delta/2$, simultaneously for every $(s,a,h,k)$,
$$0 \;\le\; Q_h^k(s,a) - Q_h^*(s,a) \;\le\; \alpha_t^0 H + \sum_{i=1}^t \alpha_t^i [V_{h+1}^{k_i}(s_{h+1}^{k_i}) - V_{h+1}^*(s_{h+1}^{k_i})] + 2\sum_{i=1}^t \alpha_t^i b_i,$$
where $t = n_h^k(s,a)$. The lower bound is optimism; the upper bound is a finite-time pathwise inequality. The factor of 2 in front of the bonus comes from absorbing the Hoeffding concentration of the martingale noise into the bonus.

3. **Regret decomposition** (Lemma C). Let $\delta_h^k := V_h^k(s_h^k) - V_h^{\pi_k}(s_h^k)$ where $V_h^k(s) = \min\{H, \max_a Q_h^k(s,a)\}$. Then, summing the upper bound of Lemma B along the trajectory and using $\delta_h^k \le \phi_h^k(s_h^k, a_h^k) + \xi_h^k$ with $\xi_h^k$ a mean-zero martingale, one gets
$$\sum_{k=1}^K \delta_1^k \;\le\; O\!\left(\sum_{k=1}^K\sum_{h=1}^H \big[\alpha_{n_h^k}^0 H + \text{bonus}_h^k + \text{noise}_h^k\big]\right),$$
where $\alpha_{n_h^k}^0 H = H\cdot\mathbb 1[n_h^k = 0]$.

4. **Bonus sum bound** (Lemma D). By the Cauchy–Schwarz inequality and the visit-counting identity $\sum_k \sum_h \mathbb 1[(s_h^k,a_h^k)=(s,a)] = $ total visits:
$$\sum_{k=1}^K \sum_{h=1}^H b_{n_h^k(s_h^k,a_h^k)} \;\le\; c\, H \sqrt{\iota}\, \sum_{k,h}\frac{1}{\sqrt{n_h^k}} \;\le\; O\big(H\sqrt{\iota\, SAT}\big).$$

5. **Horizon accumulation** (Lemma E). The "value propagation error" term of Lemma B, when iterated over $h$, contributes an extra factor of $(1+1/H)^H \le e$, a constant. Combined with Lemmas C, D this yields $\mathrm{Regret}(K) \le O(H \sqrt{H^2 SAT \iota^2}) = O(\sqrt{H^4 SAT \iota^2})$.

## What is allowed
- Hoeffding's inequality for bounded martingales / sums of independent bounded random variables (`[REF]`-able from `proofs/library/statistics/concentration/` if present).
- Azuma-Hoeffding for martingales. Union bounds.
- Jensen's inequality, Cauchy-Schwarz, elementary algebra.
- The learning-rate identities listed above (should be verified in Step 0 or noted as elementary).

## What is NOT required
- No Bernstein bonus (that is the UCB-Bernstein variant of the same paper, which shaves a $\sqrt H$ factor and is *not* the claim here).
- No lower-bound matching is required; we only prove the upper bound.
- No generative-model assumption.

## Target constant tracking

The final bound is $C\sqrt{H^4 SAT}\, \iota$ (with $\iota^2$ since both optimism and the martingale noise each contribute one $\iota$). The numerical constant $C$ should be traceable but does not need to be optimized — any absolute constant suffices, so long as it does not depend on $S,A,H,T,\delta$.
