# Linear Convergence of Natural Policy Gradient in Tabular Softmax MDPs

## Source
- Context: Convergence analysis of NPG with softmax parameterization in tabular RL
- Related work: Agarwal, Kakade, Lee, Mahajan (2021); Cen, Cheng, Chen, Wei, Chi (2022)

## Statement

Consider a tabular MDP with finite state space $\mathcal{S}$ ($|\mathcal{S}| = S$), finite action space $\mathcal{A}$ ($|\mathcal{A}| = A$), discount factor $\gamma \in (0,1)$, transition kernel $P$, and reward function $r(s,a) \in [0, 1]$.

The policy is parameterized by softmax: $\pi_\theta(a|s) = \frac{\exp(\theta_{s,a})}{\sum_{a'} \exp(\theta_{s,a'})}$ where $\theta \in \mathbb{R}^{S \times A}$.

The Natural Policy Gradient (NPG) update with step size $\eta$ is:
$$\theta^{(k+1)}_{s,a} = \theta^{(k)}_{s,a} + \eta \cdot Q^{\pi_{\theta^{(k)}}}(s,a)$$

**Theorem.** With step size $\eta = (1-\gamma) \log A / (2\gamma)$ (or more generally $\eta = \Theta(1/(1-\gamma))$), NPG achieves:

$$V^*(\rho) - V^{\pi_{\theta^{(K)}}}(\rho) \leq \frac{\log A}{\eta(1-\gamma)K} + \frac{\eta}{8(1-\gamma)^3}$$

For the specific choice $\eta = (1-\gamma)\log A/(2\gamma)$ and $K \geq 32\gamma^2/\log A$:

$$V^*(\rho) - V^{\pi_{\theta^{(K)}}}(\rho) \leq \frac{4\gamma}{(1-\gamma)^2 K}$$

i.e., an $O(1/K)$ convergence rate to the optimal policy value.

## Required intermediate results

1. Performance difference lemma
2. NPG as mirror descent (softmax ↔ KL mirror descent)
3. Per-state improvement bound via KL divergence three-point decomposition
4. Monotone value improvement + Donsker-Varadhan + Hoeffding bound
5. Telescoping with KL cancellation for O(1/K) rate

## Difficulty
conjecture
