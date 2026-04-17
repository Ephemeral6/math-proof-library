# Proof Route 4: Martingale Difference Decomposition

**Route**: Decompose STORM error as martingale + drift, use second-moment analysis

---

## Setup

STORM: $d_t = (1-a)d_{t-1} + \nabla f(x_t;\xi_t) - (1-a)\nabla f(x_{t-1};\xi_t)$, $x_{t+1} = x_t - \eta d_t$.

Error: $e_t = d_t - \nabla f(x_t)$.

---

## Step 1: Martingale Decomposition of $e_t$

From the recursion $e_t = (1-a)e_{t-1} + (1-a)\delta_t + a\epsilon_t$ where:
- $\delta_t = [\nabla f(x_t;\xi_t) - \nabla f(x_{t-1};\xi_t)] - [\nabla f(x_t) - \nabla f(x_{t-1})]$
- $\epsilon_t = \nabla f(x_t;\xi_t) - \nabla f(x_t)$

Both $\delta_t$ and $\epsilon_t$ have zero conditional expectation given $\mathcal{F}_{t-1}$.

Define the noise $\zeta_t = (1-a)\delta_t + a\epsilon_t$. Then $\mathbb{E}[\zeta_t | \mathcal{F}_{t-1}] = 0$ and:

$$e_t = (1-a)e_{t-1} + \zeta_t$$

Unrolling:
$$e_t = (1-a)^t e_0 + \sum_{j=1}^t (1-a)^{t-j}\zeta_j$$

This is a **stochastic recursion** (AR(1) with martingale innovations). The sum $M_t = \sum_{j=1}^t (1-a)^{t-j}\zeta_j$ is NOT a martingale (the weights depend on $t$), but we can analyze its second moment directly.

## Step 2: Second Moment Bound

$$\mathbb{E}[\|e_t\|^2] = (1-a)^{2t}\mathbb{E}[\|e_0\|^2] + \sum_{j=1}^t (1-a)^{2(t-j)}\mathbb{E}[\|\zeta_j\|^2]$$

(Cross-terms vanish since $\mathbb{E}[\langle \zeta_j, \zeta_k\rangle] = 0$ for $j \neq k$ by the tower property, and $\mathbb{E}[\langle e_0, \zeta_j\rangle] = 0$.)

Wait — the cross-terms are $\mathbb{E}[\langle (1-a)^{t-j}\zeta_j, (1-a)^{t-k}\zeta_k\rangle]$ for $j < k$. By the tower property:
$$\mathbb{E}[\langle \zeta_j, \zeta_k\rangle] = \mathbb{E}[\langle \zeta_j, \mathbb{E}[\zeta_k | \mathcal{F}_{k-1}]\rangle] = 0$$

But $\zeta_j$ depends on $\xi_j$ and $\zeta_k$ depends on $\xi_k$... however, $\zeta_j$ is $\mathcal{F}_j$-measurable and $\mathcal{F}_j \subseteq \mathcal{F}_{k-1}$. So $\mathbb{E}[\langle \zeta_j, \zeta_k\rangle] = \mathbb{E}[\langle \zeta_j, \mathbb{E}[\zeta_k|\mathcal{F}_{k-1}]\rangle] = 0$. ✓

So indeed:
$$\mathbb{E}[\|e_t\|^2] = (1-a)^{2t}\sigma^2 + \sum_{j=1}^t (1-a)^{2(t-j)}\mathbb{E}[\|\zeta_j\|^2]$$

Now bound $\mathbb{E}[\|\zeta_j\|^2]$:
$$\mathbb{E}[\|\zeta_j\|^2] = \mathbb{E}[\|(1-a)\delta_j + a\epsilon_j\|^2] \leq 2(1-a)^2\mathbb{E}[\|\delta_j\|^2] + 2a^2\sigma^2$$

And $\mathbb{E}[\|\delta_j\|^2 | \mathcal{F}_{j-1}] \leq L^2\|x_j - x_{j-1}\|^2 = L^2\eta^2\|d_{j-1}\|^2$ (mean-squared smoothness).

So:
$$\mathbb{E}[\|\zeta_j\|^2] \leq 2L^2\eta^2\mathbb{E}[\|d_{j-1}\|^2] + 2a^2\sigma^2$$

Therefore:
$$\mathbb{E}[\|e_t\|^2] \leq (1-a)^{2t}\sigma^2 + 2L^2\eta^2\sum_{j=1}^t(1-a)^{2(t-j)}\mathbb{E}[\|d_{j-1}\|^2] + \frac{2a^2\sigma^2}{1-(1-a)^2}$$

Since $1-(1-a)^2 = a(2-a) \geq a$:
$$\mathbb{E}[\|e_t\|^2] \leq (1-a)^{2t}\sigma^2 + 2L^2\eta^2\sum_{j=0}^{t-1}(1-a)^{2(t-1-j)}\mathbb{E}[\|d_j\|^2] + 2a\sigma^2$$

## Step 3: Summing the Error

$$\sum_{t=0}^{T-1}\mathbb{E}[\|e_t\|^2] \leq \underbrace{\sigma^2\sum_{t=0}^{T-1}(1-a)^{2t}}_{\leq \sigma^2/(2a)} + 2L^2\eta^2\sum_{t=0}^{T-1}\sum_{j=0}^{t-1}(1-a)^{2(t-1-j)}\mathbb{E}[\|d_j\|^2] + 2aT\sigma^2$$

Exchange summation in the double sum:
$$\sum_{t=0}^{T-1}\sum_{j=0}^{t-1}(1-a)^{2(t-1-j)}\mathbb{E}[\|d_j\|^2] = \sum_{j=0}^{T-2}\mathbb{E}[\|d_j\|^2]\sum_{t=j+1}^{T-1}(1-a)^{2(t-1-j)}$$

The inner sum: $\sum_{s=0}^{T-2-j}(1-a)^{2s} \leq \frac{1}{1-(1-a)^2} \leq \frac{1}{a}$.

So:
$$\sum_{t=0}^{T-1}\mathbb{E}[\|e_t\|^2] \leq \frac{\sigma^2}{2a} + \frac{2L^2\eta^2}{a}\sum_{j=0}^{T-1}\mathbb{E}[\|d_j\|^2] + 2aT\sigma^2$$

## Step 4: Substitute into Descent

From the polarization-based descent:
$$\frac{\eta}{2}\sum_t\mathbb{E}[\|\nabla f(x_t)\|^2] \leq \Delta + \frac{\eta}{2}\sum_t\mathbb{E}[\|e_t\|^2] - \frac{\eta(1-L\eta)}{2}\sum_t\mathbb{E}[\|d_t\|^2]$$

Substituting:
$$\frac{\eta}{2}\sum_t\mathbb{E}[\|\nabla f\|^2] \leq \Delta + \frac{\eta\sigma^2}{4a} + \frac{L^2\eta^3}{a}\sum\|d\|^2 + \eta aT\sigma^2 - \frac{\eta(1-L\eta)}{2}\sum\|d\|^2$$

Net coefficient on $\sum\|d\|^2$: $-\frac{\eta(1-L\eta)}{2} + \frac{L^2\eta^3}{a}$. Need $a \geq \frac{2L^2\eta^2}{1-L\eta}$.

Drop the $\|d\|^2$ terms:
$$\frac{1}{T}\sum_t\mathbb{E}[\|\nabla f\|^2] \leq \frac{2\Delta}{\eta T} + \frac{\sigma^2}{2aT} + 2a\sigma^2$$

## Step 5: Complexity

Same as Routes 1-3 (the constant in the $\sigma^2/(aT)$ term is slightly better: $1/(2a)$ vs $1/a$, giving a tighter bound).

With $a = \Theta(\varepsilon^2/\sigma^2)$, $\eta = \Theta(\varepsilon/(L\sigma))$:

$$\boxed{T = O\left(\frac{\sigma^2}{\varepsilon^3} + \frac{1}{\varepsilon^2}\right)} \qquad \blacksquare$$

---

## Notes on This Route

The martingale decomposition gives a slightly cleaner analysis because:
1. The orthogonality of martingale increments is used explicitly (cross-terms vanish exactly)
2. The geometric decay factor $(1-a)^{2t}$ vs $(1-a)^t$ gives a tighter bound on initialization error
3. The steady-state variance is $2a\sigma^2$ (matching Route 1)

However, the final complexity bound is identical to Route 1. The martingale structure does not provide fundamentally different information — it's essentially the same Lyapunov analysis in different notation.

## References
- [REF: proofs/library/optimization/stochastic/sgd-convex-convergence-rate/proof.md] — SGD noise handling via variance decomposition
- [REF: proofs/research/optimization/stochastic/spider-nonconvex-gradient-complexity/proof.md] — Polarization identity
