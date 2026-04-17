# Entropy-Regularized Natural Policy Gradient: Linear Convergence

## Source
- **Paper**: S. Cen, C. Cheng, Y. Chen, Y. Wei, Y. Chi, *"Fast Global Convergence of Natural Policy Gradient Methods with Entropy Regularization"*, Operations Research 2022.
- **Context**: Establishes that NPG with entropy regularization achieves linear (geometric) convergence to the regularized optimal policy, in contrast to the sub-linear $O(1/K)$ rate of unregularized NPG (Agarwal et al. 2021). The entropy regularization term provides implicit strong convexity in the policy space.

## Statement

**Setting.** Consider a finite discounted MDP $(\mathcal{S}, \mathcal{A}, P, r, \gamma, \rho)$ with states $\mathcal{S}$, actions $\mathcal{A}$, transition kernel $P(\cdot|s,a)$, reward $r:\mathcal{S}\times\mathcal{A}\to[0,1]$, discount $\gamma\in(0,1)$, and initial state distribution $\rho\in\Delta(\mathcal{S})$.

For a stochastic policy $\pi:\mathcal{S}\to\Delta(\mathcal{A})$, the entropy-regularized value function with temperature $\tau > 0$ is
$$V_\tau^\pi(s) := \mathbb{E}\left[\sum_{t=0}^{\infty}\gamma^t \big(r(s_t,a_t) + \tau\mathcal{H}(\pi(\cdot|s_t))\big)\,\Big|\,s_0 = s,\,a_t\sim\pi(\cdot|s_t)\right]$$
where $\mathcal{H}(\pi(\cdot|s)) = -\sum_a \pi(a|s)\log\pi(a|s)$ is the Shannon entropy. Define $V_\tau^\pi(\rho) := \mathbb{E}_{s\sim\rho}[V_\tau^\pi(s)]$ and correspondingly
$$Q_\tau^\pi(s,a) := r(s,a) + \gamma\mathbb{E}_{s'\sim P(\cdot|s,a)}[V_\tau^\pi(s')].$$

Let $\pi^*_\tau$ denote the unique optimal regularized policy (well-defined since the regularized Bellman operator is a contraction in $\|\cdot\|_\infty$ on the softmax simplex).

**Softmax parameterization.** Let $\theta\in\mathbb{R}^{\mathcal{S}\times\mathcal{A}}$ and define
$$\pi_\theta(a|s) := \frac{\exp(\theta(s,a))}{\sum_{a'}\exp(\theta(s,a'))}.$$

**Exact entropy-regularized NPG iteration.** For step size $\eta > 0$,
$$\theta^{(k+1)}(s,a) = \theta^{(k)}(s,a) + \frac{\eta}{1-\gamma}\,A_\tau^{(k)}(s,a)$$
where $A_\tau^{(k)}(s,a) := Q_\tau^{\pi^{(k)}}(s,a) - \tau\log\pi^{(k)}(a|s) - V_\tau^{\pi^{(k)}}(s)$ is the (soft) advantage.

Equivalently (well-known simplification under softmax), the NPG update in the probability simplex becomes:
$$\pi^{(k+1)}(a|s) \propto \pi^{(k)}(a|s)^{1 - \eta\tau/(1-\gamma)}\cdot\exp\!\left(\frac{\eta}{1-\gamma}Q_\tau^{(k)}(s,a)\right).$$

**Target theorem.** Assume $0 < \eta \le (1-\gamma)/\tau$. Then the entropy-regularized NPG iterates $\{\pi^{(k)}\}$ converge linearly to $\pi^*_\tau$ in the following sense:

$$\boxed{\;\|Q_\tau^{(k+1)} - Q^*_\tau\|_\infty \;\le\; (1 - \eta\tau)\cdot\|Q_\tau^{(k)} - Q^*_\tau\|_\infty + C_0 \|\log\pi^{(k)} - \log\pi^*_\tau\|_\infty\;}$$

with an appropriately chosen $C_0$ vanishing as $k\to\infty$. **Moreover**, the following cleaner linear rate holds on the Lyapunov quantity
$$\Phi^{(k)} := \|Q_\tau^{(k)} - Q_\tau^*\|_\infty + C\|\log\pi^{(k)} - \log\pi_\tau^*\|_\infty$$
for some explicit $C = C(\gamma, \tau, \eta) > 0$:
$$\Phi^{(k+1)} \le (1 - \eta\tau)\cdot\Phi^{(k)}.$$

Hence
$$\|V_\tau^{\pi^{(k)}} - V_\tau^*\|_\infty \le (1-\eta\tau)^k\cdot \Phi^{(0)}.$$

## Difficulty
**research**

## Key intermediate results to prove

1. **Regularized Bellman operator contraction**: The Bellman operator $\mathcal{T}_\tau[Q](s,a) := r(s,a) + \gamma\mathbb{E}_{s'\sim P(\cdot|s,a)}[V_\tau(s')]$ with $V_\tau(s) := \tau\log\sum_{a'}\exp(Q(s,a')/\tau)$ is a $\gamma$-contraction in $\|\cdot\|_\infty$. Hence $Q_\tau^*$ is its unique fixed point.

2. **Simplification of NPG update under softmax**: The NPG update
$$\theta^{(k+1)} = \theta^{(k)} + (\eta/(1-\gamma))A_\tau^{(k)}$$
is equivalent (in the induced policy space, modulo normalization) to
$$\pi^{(k+1)} \propto \pi^{(k)\,1-\eta\tau/(1-\gamma)}\cdot\exp(\eta Q_\tau^{(k)}/(1-\gamma)).$$

3. **Soft Q-function contraction under NPG iterate**: The key recursion
$$Q_\tau^{(k+1)} = (1-\eta\tau)Q_\tau^{(k)} + \eta\tau\mathcal{T}_\tau[Q_\tau^{(k)}] + \text{(error terms)}$$
where the error terms involve $\log\pi^{(k)} - \log\pi_\tau^*$ and vanish at the fixed point.

4. **Lyapunov decrease**: Construct $\Phi^{(k)} = \|Q_\tau^{(k)} - Q_\tau^*\|_\infty + C\|\log\pi^{(k)} - \log\pi_\tau^*\|_\infty$ and show that for appropriate $C > 0$,
$$\Phi^{(k+1)} \le (1-\eta\tau)\Phi^{(k)}.$$

5. **Telescoping / iterated contraction** gives the final linear convergence rate.
