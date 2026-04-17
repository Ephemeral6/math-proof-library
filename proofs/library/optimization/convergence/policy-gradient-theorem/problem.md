# Policy Gradient Theorem

## Source
- Paper: "Policy Gradient Methods for Reinforcement Learning with Function Approximation" (Sutton, McAllester, Singh, Mansour, NeurIPS 1999)
- Context: Foundational result expressing the gradient of the expected return with respect to policy parameters, enabling gradient-based policy optimization in reinforcement learning.

## Statement

Consider a discounted MDP with discount factor $\gamma \in [0,1)$, state space $\mathcal{S}$, action space $\mathcal{A}$, transition kernel $P(s'|s,a)$, reward function $r(s,a)$, and a parameterized stochastic policy $\pi_\theta(a|s)$.

Define:
- Value function: $V^{\pi_\theta}(s) = \mathbb{E}_{\pi_\theta}\left[\sum_{t=0}^\infty \gamma^t r(s_t, a_t) \mid s_0 = s\right]$
- Action-value function: $Q^{\pi_\theta}(s,a) = r(s,a) + \gamma \mathbb{E}_{s' \sim P(\cdot|s,a)}[V^{\pi_\theta}(s')]$
- Performance measure: $V^{\pi_\theta}(\rho) = \mathbb{E}_{s \sim \rho}[V^{\pi_\theta}(s)]$
- Discounted state visitation distribution: $d^\pi_\rho(s) = (1-\gamma)\sum_{t=0}^\infty \gamma^t P(s_t = s \mid \pi, \rho)$

**Theorem (Policy Gradient).** Under regularity conditions (differentiability of $\pi_\theta$, boundedness of rewards, positivity of $\pi_\theta$):

$$\nabla_\theta V^{\pi_\theta}(\rho) = \frac{1}{1-\gamma}\mathbb{E}_{s \sim d^\pi_\rho, a \sim \pi_\theta}[Q^{\pi_\theta}(s,a) \nabla_\theta \log \pi_\theta(a|s)]$$

## Difficulty
research
