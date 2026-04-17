# EXP3 Algorithm: Optimal O(√(KT log K)) Regret for Adversarial Multi-Armed Bandits

## Source
- Paper: Auer, Cesa-Bianchi, Freund, Schapire (2002), "The Nonstochastic Multiarmed Bandit Problem", SIAM J. Computing
- Context: Foundational result establishing minimax-optimal regret for adversarial bandits, connecting exponential weights to partial information

## Statement

Consider the adversarial multi-armed bandit problem with $K$ arms over $T$ rounds. At each round $t = 1, \ldots, T$:
1. The learner chooses arm $I_t \in \{1, \ldots, K\}$ according to distribution $p_t \in \Delta_K$
2. The adversary (obliviously) assigns losses $\ell_t \in [0,1]^K$
3. The learner observes only $\ell_t(I_t)$ (bandit feedback)

The **EXP3 algorithm** (Exponential-weight algorithm for Exploration and Exploitation):
- Parameters: learning rate $\eta > 0$, exploration rate $\gamma \in (0,1)$
- Maintain weights $w_t(i)$ for $i = 1, \ldots, K$, initialized $w_1(i) = 1$
- At each round $t$:
  - Set $p_t(i) = (1-\gamma)\frac{w_t(i)}{\sum_j w_t(j)} + \frac{\gamma}{K}$
  - Draw $I_t \sim p_t$
  - Construct importance-weighted loss estimate: $\hat{\ell}_t(i) = \frac{\ell_t(i) \cdot \mathbf{1}[I_t = i]}{p_t(i)}$
  - Update: $w_{t+1}(i) = w_t(i) \cdot \exp(-\eta \hat{\ell}_t(i))$

**Theorem (EXP3 Regret Bound)**: For any oblivious adversary and any $\eta \leq \gamma/K$, the expected regret of EXP3 satisfies:

$$\mathbb{E}\!\left[\sum_{t=1}^T \ell_t(I_t)\right] - \min_{i \in [K]} \sum_{t=1}^T \ell_t(i) \leq \frac{\ln K}{\eta} + \eta K T + \gamma T$$

In particular, with $\eta = \sqrt{\frac{\ln K}{KT}}$ and $\gamma = K\eta = \sqrt{\frac{K \ln K}{T}}$ (assuming $T \geq K\ln K$):

$$\text{Regret} \leq 2\sqrt{KT\ln K} + \sqrt{KT\ln K} = 3\sqrt{KT\ln K}$$

## Difficulty
research

## Key Intermediate Results to Prove

1. **Unbiased loss estimate**: Show $\mathbb{E}[\hat{\ell}_t(i) | \mathcal{F}_{t-1}] = \ell_t(i)$ for all $i$ and $t$.

2. **Exponential weights regret for full-information**: Via the potential $\Phi_t = \ln\!\left(\frac{1}{K}\sum_i w_t(i)\right)$, show that for the exponential weights update with any loss estimates $\hat{\ell}_t$:
$$\sum_t \langle p_t, \hat{\ell}_t \rangle - \sum_t \hat{\ell}_t(i) \leq \frac{\ln K}{\eta} + \eta \sum_t \langle p_t, \hat{\ell}_t^2 \rangle$$

3. **Variance bound**: Show $\mathbb{E}[\hat{\ell}_t(i)^2] \leq \frac{\ell_t(i)}{p_t(i)} \leq \frac{K}{\gamma}$ and $\sum_i p_t(i)\hat{\ell}_t(i)^2 \leq \frac{K}{\gamma}$ in expectation.

4. **Mixing cost**: The $(1-\gamma)$ mixing incurs an additional $\gamma T$ cost in regret.

5. **Parameter optimization**: Optimize $\eta, \gamma$ to get the $O(\sqrt{KT\ln K})$ rate.
