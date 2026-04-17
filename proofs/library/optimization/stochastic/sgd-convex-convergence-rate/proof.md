# SGD O(1/√T) Convergence for Convex Functions

**Theorem.** Let $f:\mathbb{R}^d \to \mathbb{R}$ be convex with minimizer $x^*$. Consider SGD: $x_{t+1} = x_t - \eta g_t$, where $\mathbb{E}[g_t|x_t] = \nabla f(x_t)$ (unbiasedness) and $\mathbb{E}[\|g_t\|^2|x_t] \leq \sigma^2$ (bounded second moment). With constant step size $\eta = c/\sqrt{T}$, the averaged iterate $\bar{x}_T = \frac{1}{T}\sum_{t=0}^{T-1} x_t$ satisfies:

$$\mathbb{E}[f(\bar{x}_T)] - f^* \leq \frac{\|x_0 - x^*\|^2}{2c\sqrt{T}} + \frac{c\sigma^2}{2\sqrt{T}}.$$

> **Remark on the $\sigma^2$ convention.** The problem states $\mathbb{E}[\|g_t - \nabla f(x_t)\|^2|x_t] \leq \sigma^2$ (variance bound), yet the target bound contains only $\sigma^2$ with no gradient-norm term. This is consistent only if $\sigma^2$ is interpreted as a second-moment bound $\mathbb{E}[\|g_t\|^2|x_t] \leq \sigma^2$, which is the standard convention in the textbook formulations of this result (Bubeck 2015; Shalev-Shwartz & Ben-David 2014). We adopt this interpretation throughout.

---

## Proof

**Step 1: Define Lyapunov function.**

Let $V_t = \|x_t - x^*\|^2$.

**Step 2: One-step expansion.**

$$V_{t+1} = \|x_{t+1} - x^*\|^2 = \|x_t - \eta g_t - x^*\|^2$$
$$= \|x_t - x^*\|^2 - 2\eta \langle g_t, x_t - x^* \rangle + \eta^2 \|g_t\|^2$$
$$= V_t - 2\eta \langle g_t, x_t - x^* \rangle + \eta^2 \|g_t\|^2.$$

**Step 3: Take conditional expectation.**

Taking $\mathbb{E}[\cdot | x_t]$ on both sides and using unbiasedness $\mathbb{E}[g_t|x_t] = \nabla f(x_t)$ and the second-moment bound $\mathbb{E}[\|g_t\|^2|x_t] \leq \sigma^2$:

$$\mathbb{E}[V_{t+1}|x_t] \leq V_t - 2\eta \langle \nabla f(x_t), x_t - x^* \rangle + \eta^2 \sigma^2. \quad (\star)$$

**Step 4: Apply convexity.**

Since $f$ is convex, the first-order condition gives:

$$f(x_t) - f(x^*) \leq \langle \nabla f(x_t), x_t - x^* \rangle.$$

Substituting into $(\star)$:

$$\mathbb{E}[V_{t+1}|x_t] \leq V_t - 2\eta(f(x_t) - f^*) + \eta^2 \sigma^2. \quad (\star\star)$$

**Step 5: Take full expectation and telescope.**

Taking full expectation of $(\star\star)$ and rearranging:

$$2\eta(\mathbb{E}[f(x_t)] - f^*) \leq \mathbb{E}[V_t] - \mathbb{E}[V_{t+1}] + \eta^2 \sigma^2.$$

Summing from $t = 0$ to $T-1$ (left side telescopes):

$$2\eta \sum_{t=0}^{T-1}(\mathbb{E}[f(x_t)] - f^*) \leq \mathbb{E}[V_0] - \mathbb{E}[V_T] + T\eta^2 \sigma^2.$$

Since $\mathbb{E}[V_T] = \mathbb{E}[\|x_T - x^*\|^2] \geq 0$, dropping $-\mathbb{E}[V_T]$ (a non-positive term) from the RHS is a valid relaxation:

$$2\eta \sum_{t=0}^{T-1}(\mathbb{E}[f(x_t)] - f^*) \leq \|x_0 - x^*\|^2 + T\eta^2 \sigma^2,$$

where $V_0 = \|x_0 - x^*\|^2$ is deterministic.

**Step 6: Apply Jensen's inequality.**

By convexity and Jensen's inequality:

$$f(\bar{x}_T) = f\!\left(\frac{1}{T}\sum_{t=0}^{T-1}x_t\right) \leq \frac{1}{T}\sum_{t=0}^{T-1}f(x_t).$$

Taking expectation and combining with Step 5 (dividing both sides by $2\eta T$):

$$\mathbb{E}[f(\bar{x}_T)] - f^* \leq \frac{1}{T}\sum_{t=0}^{T-1}(\mathbb{E}[f(x_t)] - f^*) \leq \frac{\|x_0 - x^*\|^2}{2\eta T} + \frac{\eta \sigma^2}{2}.$$

**Step 7: Substitute step size.**

Setting $\eta = c/\sqrt{T}$:

$$\mathbb{E}[f(\bar{x}_T)] - f^* \leq \frac{\|x_0 - x^*\|^2}{2c\sqrt{T}} + \frac{c\sigma^2}{2\sqrt{T}}. \quad \blacksquare$$

---

**Step 8: Optimal choice of $c$.**

The bound is $B(c) = \frac{D^2}{2c\sqrt{T}} + \frac{c\sigma^2}{2\sqrt{T}}$ where $D = \|x_0 - x^*\|$. Minimizing over $c > 0$:

$$B'(c) = -\frac{D^2}{2c^2\sqrt{T}} + \frac{\sigma^2}{2\sqrt{T}} = 0 \implies c^* = \frac{D}{\sigma}.$$

Second derivative: $B''(c) = \frac{D^2}{c^3\sqrt{T}} > 0$, confirming a minimum.

Substituting $c^* = D/\sigma$:

$$B(c^*) = \frac{D^2\sigma}{2D\sqrt{T}} + \frac{D\sigma^2}{2\sigma\sqrt{T}} = \frac{D\sigma}{2\sqrt{T}} + \frac{D\sigma}{2\sqrt{T}} = \frac{D\sigma}{\sqrt{T}}.$$

**Optimal step size:** $\eta^* = \frac{\|x_0 - x^*\|}{\sigma\sqrt{T}}$, yielding:

$$\boxed{\mathbb{E}[f(\bar{x}_T)] - f^* \leq \frac{\|x_0 - x^*\|\,\sigma}{\sqrt{T}}}$$

This is the classical $O(1/\sqrt{T})$ rate for convex SGD, matching the minimax lower bound (Nemirovski & Yudin).

**Q.E.D.**
