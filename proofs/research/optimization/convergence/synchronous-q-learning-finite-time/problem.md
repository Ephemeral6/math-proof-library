# Finite-Time Convergence of Synchronous Q-Learning with Generative Model

## Source
- Paper: Li, Cai, Chen et al. (2021); Wainwright (2019); Even-Dar & Mansour (2003)
- Context: Sharp sample complexity for model-free Q-learning in tabular MDPs with generative model access

## Statement

Consider a finite MDP $(\mathcal{S}, \mathcal{A}, P, r, \gamma)$ with $|\mathcal{S}| = S$ states, $|\mathcal{A}| = A$ actions, discount factor $\gamma \in (0,1)$, and bounded rewards $r(s,a) \in [0,1]$. A **generative model** allows independent sampling of $s' \sim P(\cdot|s,a)$ for any state-action pair.

**Synchronous Q-learning** updates all entries simultaneously:
$$Q_{t+1}(s,a) = (1-\alpha_t)\,Q_t(s,a) + \alpha_t\Big[r(s,a) + \gamma \max_{a'} Q_t(s',a')\Big], \quad \forall (s,a)$$

with learning rate $\alpha_t = \frac{H+1}{H+t}$, $H = \frac{1}{1-\gamma}$, and optimistic initialization $Q_0(s,a) = \frac{1}{1-\gamma}$.

**Theorem.** There exists a universal constant $C > 0$ such that for any $\varepsilon \in (0, \frac{1}{1-\gamma})$ and $\delta \in (0,1)$, after
$$T = \frac{C}{(1-\gamma)^4 \varepsilon^2} \log\!\Big(\frac{SA}{(1-\gamma)\delta}\Big)$$
iterations, $\mathbb{P}\!\big[\|Q_T - Q^*\|_\infty \leq \varepsilon\big] \geq 1-\delta$.

Total sample complexity: $T \cdot SA = \widetilde{O}\!\Big(\frac{SA}{(1-\gamma)^4 \varepsilon^2}\Big)$.

## Difficulty
research
