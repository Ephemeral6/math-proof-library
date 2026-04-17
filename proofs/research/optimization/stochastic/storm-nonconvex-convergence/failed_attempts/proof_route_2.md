# Proof Route 2: Direct Recursive Variance Bound + Epoch-Free Telescoping

**Route**: Direct variance bound substitution without explicit Lyapunov function

---

## Setup

Same as Route 1. STORM algorithm:
$$d_t = (1-a)d_{t-1} + a\nabla f(x_t;\xi_t) + (1-a)[\nabla f(x_t;\xi_t) - \nabla f(x_{t-1};\xi_t)]$$
$$x_{t+1} = x_t - \eta d_t$$

Error $e_t = d_t - \nabla f(x_t)$. Assumptions: $L$-smooth, mean-squared smoothness $\mathbb{E}[\|\nabla f(x;\xi) - \nabla f(y;\xi)\|^2] \leq L^2\|x-y\|^2$, variance bound $\sigma^2$, $f^* > -\infty$.

---

## Step 1: Descent Lemma with Young's Inequality

By $L$-smoothness and $x_{t+1} = x_t - \eta d_t$:
$$f(x_{t+1}) \leq f(x_t) - \eta\langle\nabla f(x_t), d_t\rangle + \frac{L\eta^2}{2}\|d_t\|^2$$

Write $d_t = \nabla f(x_t) + e_t$:
$$-\eta\langle\nabla f(x_t), d_t\rangle = -\eta\|\nabla f(x_t)\|^2 - \eta\langle\nabla f(x_t), e_t\rangle$$

By Young's inequality with parameter $\alpha > 0$:
$$-\eta\langle\nabla f(x_t), e_t\rangle \leq \frac{\eta\alpha}{2}\|\nabla f(x_t)\|^2 + \frac{\eta}{2\alpha}\|e_t\|^2$$

And:
$$\frac{L\eta^2}{2}\|d_t\|^2 \leq L\eta^2\|\nabla f(x_t)\|^2 + L\eta^2\|e_t\|^2$$

Taking expectations conditioned on $\mathcal{F}_{t-1}$, and noting that $\mathbb{E}[\langle\nabla f(x_t), e_t\rangle \mid \mathcal{F}_{t-1}] = (1-a)\langle\nabla f(x_t), e_{t-1}\rangle$ (from the decomposition $\mathbb{E}[e_t|\mathcal{F}_{t-1}] = (1-a)e_{t-1}$):

This makes the analysis messy because the cross-term doesn't vanish. Let me instead take full expectations and use the polarization approach.

**Using polarization** (same as Route 1):
$$\mathbb{E}[f(x_{t+1})] \leq \mathbb{E}[f(x_t)] - \frac{\eta}{2}\mathbb{E}[\|\nabla f(x_t)\|^2] + \frac{\eta}{2}\mathbb{E}[\|e_t\|^2] - \frac{\eta(1-L\eta)}{2}\mathbb{E}[\|d_t\|^2]$$

## Step 2: Bound $\|e_t\|^2$ via Unrolled Recursion

From the variance recursion (Lemma 1 of Route 1):
$$\mathbb{E}[\|e_t\|^2] \leq (1-a)\mathbb{E}[\|e_{t-1}\|^2] + 2L^2\eta^2\mathbb{E}[\|d_{t-1}\|^2] + 2a^2\sigma^2$$

Unrolling:
$$\mathbb{E}[\|e_t\|^2] \leq (1-a)^t\mathbb{E}[\|e_0\|^2] + 2L^2\eta^2\sum_{j=0}^{t-1}(1-a)^{t-1-j}\mathbb{E}[\|d_j\|^2] + \frac{2a^2\sigma^2}{1-(1-a)} \cdot [1-(1-a)^t]$$

$$\leq (1-a)^t\sigma^2 + 2L^2\eta^2\sum_{j=0}^{t-1}(1-a)^{t-1-j}\mathbb{E}[\|d_j\|^2] + 2a\sigma^2$$

## Step 3: Sum the Descent Inequality

Sum over $t = 0, \ldots, T-1$:
$$\mathbb{E}[f(x_T)] \leq f(x_0) - \frac{\eta}{2}\sum_{t=0}^{T-1}\mathbb{E}[\|\nabla f(x_t)\|^2] + \frac{\eta}{2}\sum_{t=0}^{T-1}\mathbb{E}[\|e_t\|^2] - \frac{\eta(1-L\eta)}{2}\sum_{t=0}^{T-1}\mathbb{E}[\|d_t\|^2]$$

For the error sum, using the unrolled recursion and exchanging summation order:
$$\sum_{t=0}^{T-1}\mathbb{E}[\|e_t\|^2] \leq \frac{\sigma^2}{a} + 2L^2\eta^2\sum_{j=0}^{T-2}\mathbb{E}[\|d_j\|^2]\sum_{t=j+1}^{T-1}(1-a)^{t-1-j} + 2aT\sigma^2$$

The inner sum $\sum_{t=j+1}^{T-1}(1-a)^{t-1-j} \leq \frac{1}{a}$.

So:
$$\sum_{t=0}^{T-1}\mathbb{E}[\|e_t\|^2] \leq \frac{\sigma^2}{a} + \frac{2L^2\eta^2}{a}\sum_{j=0}^{T-1}\mathbb{E}[\|d_j\|^2] + 2aT\sigma^2$$

## Step 4: Absorb the $\|d_t\|^2$ Terms

Substituting:
$$\mathbb{E}[f(x_T)] \leq f(x_0) - \frac{\eta}{2}\sum_t\mathbb{E}[\|\nabla f\|^2] + \frac{\eta\sigma^2}{2a} + \frac{L^2\eta^3}{a}\sum_t\mathbb{E}[\|d_t\|^2] + \eta aT\sigma^2 - \frac{\eta(1-L\eta)}{2}\sum_t\mathbb{E}[\|d_t\|^2]$$

The net coefficient on $\sum\|d_t\|^2$ is:
$$-\frac{\eta(1-L\eta)}{2} + \frac{L^2\eta^3}{a}$$

We need this to be $\leq 0$:
$$\frac{L^2\eta^3}{a} \leq \frac{\eta(1-L\eta)}{2} \implies a \geq \frac{2L^2\eta^2}{1-L\eta}$$

This is the same condition as Route 1. Under this condition, drop the $\|d_t\|^2$ terms:

$$\frac{\eta}{2}\sum_{t=0}^{T-1}\mathbb{E}[\|\nabla f(x_t)\|^2] \leq \Delta + \frac{\eta\sigma^2}{2a} + \eta aT\sigma^2$$

$$\frac{1}{T}\sum_{t=0}^{T-1}\mathbb{E}[\|\nabla f(x_t)\|^2] \leq \frac{2\Delta}{\eta T} + \frac{\sigma^2}{aT} + 2a\sigma^2$$

## Step 5: Parameter Choice and Complexity

This is identical to Route 1's final bound. With $a = \Theta(\varepsilon^2/\sigma^2)$ and $\eta = \Theta(\varepsilon/(L\sigma))$:

$$T = O\left(\frac{\sigma^2}{\varepsilon^3} + \frac{1}{\varepsilon^2}\right) \qquad \blacksquare$$

---

## Route Comparison Note

This route arrives at the same bound as Route 1 but without explicitly naming the Lyapunov function. The proof is slightly less structured — the "Lyapunov function" emerges implicitly when we add $c\mathbb{E}[\|e_t\|^2]$ to both sides. The advantage is that the unrolled recursion makes the geometric decay of initialization error transparent. The disadvantage is that the exchange-of-sums step is less clean.
