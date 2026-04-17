# Bellman Optimality: Contraction and Uniqueness

## Source
- Paper: Bellman 1957 (Dynamic Programming); Puterman 1994 (Markov Decision Processes)
- Context: Foundational result in reinforcement learning / MDP theory establishing that the Bellman optimality operator is a contraction mapping, guaranteeing convergence of value iteration.

## Statement

Consider a finite MDP $(\mathcal{S}, \mathcal{A}, r, P, \gamma)$ with $\gamma \in [0,1)$. The Bellman optimality operator $\mathcal{T}^*: \mathbb{R}^{|\mathcal{S}||\mathcal{A}|} \to \mathbb{R}^{|\mathcal{S}||\mathcal{A}|}$ is defined by

$$(\mathcal{T}^* Q)(s,a) = r(s,a) + \gamma \sum_{s' \in \mathcal{S}} P(s'|s,a) \max_{a' \in \mathcal{A}} Q(s',a').$$

**Prove:**

1. $\mathcal{T}^*$ is a $\gamma$-contraction in $\|\cdot\|_\infty$: $\|\mathcal{T}^* Q_1 - \mathcal{T}^* Q_2\|_\infty \leq \gamma \|Q_1 - Q_2\|_\infty$.
2. $\mathcal{T}^*$ has a unique fixed point $Q^*$ (the optimal Q-function).
3. Value iteration converges: $\|Q_k - Q^*\|_\infty \leq \gamma^k \|Q_0 - Q^*\|_\infty$.

## Difficulty
research
