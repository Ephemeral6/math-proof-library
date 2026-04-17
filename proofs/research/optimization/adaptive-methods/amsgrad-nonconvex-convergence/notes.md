# Notes: AMSGrad Non-Convex Convergence

## Proof technique
Coordinate-wise descent lemma + $\hat{v}_{t-1}$ noise decomposition trick + telescoping sum. The key innovation is handling the correlation between stochastic gradients $g_t$ and the adaptive denominator $\hat{v}_t$ by decomposing the noise cross-term using the previous step's $\hat{v}_{t-1}$ (which is $\mathcal{F}_{t-1}$-measurable), yielding a zero-mean main part plus a bounded correction exploiting AMSGrad's monotonicity.

## Key steps
1. Descent lemma gives per-step bound with inner product $\langle \nabla f, D_t\rangle$ and quadratic $\|D_t\|^2$
2. $\|D_t\|^2 \leq dG^2/\epsilon^2$ from bounded gradients and $\sqrt{\hat{v}_t}+\epsilon \geq \epsilon$
3. Decompose $m_t = (1-\beta_1)\nabla f + (1-\beta_1)\xi_t + \beta_1 m_{t-1}$ into gradient signal, noise, and momentum
4. **The $\hat{v}_{t-1}$ trick**: Write noise term with $\hat{v}_{t-1}$ denominator (zero mean) plus correction (bounded by $O(\sqrt{1-\beta_2}dG^3/\epsilon^2)$ using $\sqrt{a+c}-\sqrt{a} \leq \sqrt{c}$)
5. Momentum term bounded by $\beta_1 dG^2/\epsilon$ (Cauchy-Schwarz)
6. Telescope with $\alpha_t = \alpha/\sqrt{T}$, rearrange

## Audit result
- **Round 1: FAIL** — Critical error in inner product lower bound. The inequality $a/(\sqrt{\hat{v}_t}+\epsilon) \geq a/(G+\epsilon)$ fails when $a < 0$ (negative noise products). Numerical counterexample provided.
- **Round 2: PASS** — After fix. All 6 steps valid. 6/6 numerical verifications passed. Minor correction to $\delta_B$ bound (derivative near $x=0$). Constants suboptimal but rate and structure correct.

## Related results
- Adam non-convex convergence (same paper, Theorem 4 variant): $O(d\log T/\sqrt{T})$ — AMSGrad avoids the $\log T$ factor due to monotone $\hat{v}_t$
- AdaGrad sparse regret (Duchi et al.): regret framework, coordinate-adaptive step sizes
- GD non-convex stationary point: deterministic $O(1/T)$ baseline
- Clipped SGD heavy-tail: different stochastic non-convex analysis with proxy stationarity
