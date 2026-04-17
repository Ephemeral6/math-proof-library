# Entropy-Regularized Value Iteration: Contraction, Convergence, and Approximation Error

## Source
- Context: Entropy-regularized MDPs / Soft value iteration (foundations of SAC, soft Q-learning)
- Related: Geist et al. 2019, Cen et al. 2022, Nachum et al. 2017

## Statement

Consider a finite tabular MDP $(\mathcal{S}, \mathcal{A}, P, r, \gamma)$ with $|\mathcal{S}| = S$, $|\mathcal{A}| = A$, discount factor $\gamma \in (0,1)$, bounded rewards $r(s,a) \in [0,1]$.

Define the $\tau$-entropy-regularized Bellman operator $\mathcal{T}_\tau: \mathbb{R}^S \to \mathbb{R}^S$:

$$(\mathcal{T}_\tau V)(s) = \tau \log\Bigl(\sum_{a \in \mathcal{A}} \exp\bigl(\tfrac{1}{\tau}[r(s,a) + \gamma \sum_{s'} P(s'|s,a) V(s')]\bigr)\Bigr)$$

**Prove:**

**(i)** $\mathcal{T}_\tau$ is a $\gamma$-contraction in $\ell^\infty$: $\|\mathcal{T}_\tau V - \mathcal{T}_\tau U\|_\infty \le \gamma \|V - U\|_\infty$

**(ii)** Value iteration converges linearly: $\|V_k - V^*_\tau\|_\infty \le \gamma^k \|V_0 - V^*_\tau\|_\infty$

**(iii)** Optimal policy is Gibbs: $\pi^*_\tau(a|s) = \frac{\exp(Q^*_\tau(s,a)/\tau)}{\sum_{a'} \exp(Q^*_\tau(s,a')/\tau)}$

**(iv)** Approximation error: $\|V^*_\tau - V^*\|_\infty \le \frac{\tau \log A}{1 - \gamma}$

## Difficulty
research
