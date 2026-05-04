# Softmax Policy Gradient $O(1/t)$ Convergence for Finite MDPs

## Source
- **Paper**: J. Mei, C. Xiao, C. Szepesvari, D. Schuurmans, *"On the Global Convergence Rates of Softmax Policy Gradient Methods"*, ICML 2020.
- **Context**: Vanilla policy gradient (PG) under softmax tabular parametrization is the canonical RL algorithm, but until 2020 only asymptotic convergence was known. Mei et al. established a non-asymptotic $O(1/t)$ rate via a novel "non-uniform Łojasiewicz inequality". This bridged the gap between NPG (which has $O(1/t)$ under exact gradient) and vanilla PG, resolving a long-standing question.

## Statement

**Setting**. Finite MDP with state space $\mathcal{S}$, action space $\mathcal{A}$, transition kernel $P(s'|s,a)$, reward $r(s,a) \in [0,1]$, discount $\gamma \in [0, 1)$, and initial distribution $\rho \in \Delta(\mathcal{S})$. Define:
- Value function: $V^\pi(s) := \mathbb{E}_\pi\big[\sum_{t=0}^\infty \gamma^t r(s_t, a_t) \mid s_0 = s\big]$
- $V^\pi(\rho) := \mathbb{E}_{s \sim \rho}[V^\pi(s)]$
- Optimal value: $V^*(\rho) := \max_\pi V^\pi(\rho)$
- Discounted state visitation: $d^\pi_\rho(s) := (1-\gamma) \sum_{t=0}^\infty \gamma^t \Pr_\pi(s_t = s \mid s_0 \sim \rho)$

**Softmax tabular parametrization**. For $\theta \in \mathbb{R}^{|\mathcal{S}| \times |\mathcal{A}|}$:
$$\pi_\theta(a|s) := \frac{\exp(\theta_{s,a})}{\sum_{a' \in \mathcal{A}} \exp(\theta_{s,a'})}.$$

**Vanilla policy gradient update**:
$$\theta_{t+1} = \theta_t + \eta \nabla_\theta V^{\pi_{\theta_t}}(\rho), \qquad \eta = \frac{(1-\gamma)^3}{8}.$$

**Assumption (full support of $\rho$)**: $\rho(s) > 0$ for all $s \in \mathcal{S}$.

**Target theorem** (simplified version of Mei-Xiao-Szepesvari-Schuurmans 2020 Theorem 4).

Under the above setting, for any $t \ge 1$,
$$\boxed{\; V^*(\rho) - V^{\pi_{\theta_t}}(\rho) \le \frac{16 |\mathcal{S}|}{(1-\gamma)^6 \, t \, c_{\infty}^2}, \;}$$
where
$$c_\infty := \inf_{t \ge 0} \min_{s \in \mathcal{S}} \pi_{\theta_t}(a^*(s) \mid s) > 0$$
is the worst-case (over iterates) minimum probability of the optimal action $a^*(s) := \arg\max_a Q^*(s,a)$ under the current policy.

**Corollary**: To achieve $V^*(\rho) - V^{\pi_t}(\rho) \le \epsilon$, it suffices to run
$$t = O\left(\frac{|\mathcal{S}|}{(1-\gamma)^6 c_\infty^2 \epsilon}\right)$$
iterations. The polynomial dependence on the horizon $1/(1-\gamma)$ and on $1/c_\infty$ is the "price" of vanilla PG vs. NPG (which has $O(1/t)$ without the $c_\infty$ dependence).

**Key innovation**: The non-uniform Łojasiewicz inequality
$$\|\nabla_\theta V^\pi(\rho)\|_2 \ge \frac{c_\infty}{\sqrt{|\mathcal{S}|}} \cdot \min_s \frac{d^{\pi^*}_\rho(s)}{d^\pi_\rho(s)}^{-1} \cdot (V^* - V^\pi) \ge \frac{c_\infty (1-\gamma)}{\sqrt{|\mathcal{S}|}} \cdot (V^*(\rho) - V^\pi(\rho)),$$
(using $d^{\pi^*}_\rho(s) \ge (1-\gamma)\rho(s)$, then absorbing $\rho$-dependence; the final form has the constant that depends on $c_\infty$).

## Difficulty
**research**

## Key intermediate results to prove

1. **$\beta$-smoothness of $V^\pi$ w.r.t. $\theta$**: For softmax parametrization, the value function $\theta \mapsto V^{\pi_\theta}(\rho)$ is $\beta$-smooth with $\beta = \frac{8}{(1-\gamma)^3}$. This follows from bounding the Hessian via the PG theorem and Fisher information structure.

2. **Policy Gradient Theorem**: $\frac{\partial V^\pi(\rho)}{\partial \theta_{s,a}} = \frac{1}{1-\gamma} d^\pi_\rho(s) \pi(a|s) A^\pi(s, a)$, where $A^\pi(s,a) := Q^\pi(s,a) - V^\pi(s)$.

3. **Performance difference lemma**: $V^\pi(\rho) - V^{\pi'}(\rho) = \frac{1}{1-\gamma} \mathbb{E}_{s \sim d^\pi_\rho}\big[\sum_a (\pi(a|s) - \pi'(a|s)) Q^{\pi'}(s, a)\big]$.

4. **Non-uniform Łojasiewicz inequality** (the key novel lemma):
$$\|\nabla_\theta V^\pi(\rho)\|_2 \ge \frac{\min_s \pi(a^*(s)|s)}{\sqrt{|\mathcal{S}|}} \cdot (V^*(\rho) - V^\pi(\rho)).$$
This is derived via the PG theorem + performance difference + a lower bound on $\pi(a^*|s)$.

5. **Descent lemma + NU-Łojasiewicz → $O(1/t)$**: Combining smoothness (giving $V^{\pi_{t+1}} \ge V^{\pi_t} + \eta \|\nabla V\|^2 / 2$ at $\eta = 1/\beta$) with the non-uniform Łojasiewicz yields
$$V^* - V^{\pi_{t+1}} \le (V^* - V^{\pi_t}) \cdot \left(1 - \frac{(c_\infty)^2 (1-\gamma)^2}{2 \beta |\mathcal{S}|} \cdot (V^* - V^{\pi_t})\right).$$
Standard $a_{t+1} \le a_t (1 - c \cdot a_t)$ recursion gives $a_t \le 1/(c t)$.

6. **$c_\infty > 0$ argument**: Show that along the PG trajectory, $\inf_t \min_s \pi_{\theta_t}(a^*(s)|s) > 0$, i.e., the probability of the optimal action doesn't collapse to zero. This is done via a monotonicity argument: $\pi_{\theta_t}(a^*(s)|s)$ is non-decreasing in $t$ once some threshold is crossed.
