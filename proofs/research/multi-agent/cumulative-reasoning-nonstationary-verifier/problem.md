# Cumulative Reasoning under Non-Stationary Verifier

## Source
- Paper: AI/ML theory hypothetical extension of cumulative-reasoning frameworks
- Context: previously the Verifier error rate $\varepsilon$ was constant; here we model context-length-dependent degradation $\varepsilon_t = \varepsilon_0(1+t/T_0)^\alpha$.

## Statement

Let $\varepsilon_t = \varepsilon_0(1+t/T_0)^\alpha$ for $\alpha > 0$, and let
$$P_T = \prod_{t=1}^{T}(1-\varepsilon_t)$$
denote the success probability after $T$ steps under independent verification events.

**(a)** For $\alpha < 1$ and $T \ge T_0$ (with $\varepsilon_T \le 1/2$):
$$P_T \;\ge\; \exp\!\left(-\frac{3\cdot 2^\alpha\, \varepsilon_0\, T^{\alpha+1}}{(\alpha+1)\, T_0^\alpha}\cdot(1+o(1))\right).$$

**(b)** For $\alpha = 1$: $P_T$ is strictly decreasing on $T \in [1, T_0(\varepsilon_0^{-1}-1))$. The marginal log-decrement reaches magnitude $1$ at $T^{**} = T_0(1-1/e)/\varepsilon_0$, beyond which each step costs at least 1 in $\log P$. With Proposer benefit $\beta\log T$, the optimum is
$$T^*_\beta = \tfrac{T_0}{2}\!\left(\sqrt{1+4\beta/(\varepsilon_0 T_0)}-1\right) \asymp \sqrt{\beta T_0/\varepsilon_0}.$$

**(c)** For $\alpha > 1$: there exists $T_{\text{div}} \asymp ((\alpha+1)T_0^\alpha/\varepsilon_0)^{1/(\alpha+1)}$ such that for $T \ge T_{\text{div}}$:
$$\log P_T \;\le\; -\frac{\varepsilon_0\, T^{\alpha+1}}{(\alpha+1)\, T_0^\alpha} + O(1),$$
i.e. $\log P_T \to -\infty$ at super-polynomial rate $T^{\alpha+1}$.

**(d) Optimal stopping**: with $\Phi(T) = \beta\log T + \log P_T$, there is a unique maximizer
$$T^*(\alpha) \;=\; (\beta T_0^\alpha/\varepsilon_0)^{1/(\alpha+1)}\cdot(1+o(1)) \quad (\beta \gg \varepsilon_0 T_0).$$

## Difficulty
research
