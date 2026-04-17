# SGD Averaged-Iterate O(1/√T) Convergence via Martingale Decomposition

**Theorem.** For SGD on a convex, $G$-Lipschitz function $f$ over $W = [a, b] \subset \mathbb{R}$ with $D = b - a$, using constant step size $\eta = D/(G\sqrt{T})$, the averaged iterate $\bar{x}_T = (1/T)\sum_{t=1}^{T} x_t$ satisfies:

$$\mathbb{E}[f(\bar{x}_T) - f^*] \leq \frac{DG}{\sqrt{T}}.$$

**Proof.**

**Step 1 (Setup).** Let $W = [a, b]$, $D = b-a$, $x^* \in \arg\min_W f$. Fix constant step size $\eta = D/(G\sqrt{T})$. The SGD iterate is $x_{t+1} = \Pi_W(x_t - \eta g_t)$.

**Step 2 (Decomposition).** Write $g_t = s_t + \xi_t$ where $s_t \in \partial f(x_t)$ is a true subgradient, $\xi_t = g_t - s_t$ is zero-mean noise: $\mathbb{E}[\xi_t \mid \mathcal{F}_t] = 0$. We assume $\mathbb{E}[g_t^2 \mid \mathcal{F}_t] \leq G^2$.

**Step 3 (Projection descent).** Since $\Pi_W$ is non-expansive and $x^* \in W$:

$$(x_{t+1} - x^*)^2 \leq (x_t - \eta g_t - x^*)^2 = (x_t - x^*)^2 - 2\eta g_t(x_t - x^*) + \eta^2 g_t^2$$

Writing $\delta_t = x_t - x^*$:

$$2\eta g_t \delta_t \leq \delta_t^2 - \delta_{t+1}^2 + \eta^2 g_t^2$$

**Step 4 (Martingale).** Define $Z_t = -2\eta \xi_t \delta_t$. Since $\delta_t$ is $\mathcal{F}_t$-measurable and $\mathbb{E}[\xi_t \mid \mathcal{F}_t] = 0$:

$$\mathbb{E}[Z_t \mid \mathcal{F}_t] = -2\eta \delta_t \cdot 0 = 0$$

Thus $M_T = \sum_{t=1}^T Z_t$ is a martingale with $\mathbb{E}[M_T] = 0$.

**Step 5 (Telescope + convexity).** Substituting $g_t = s_t + \xi_t$ in Step 3 and summing $t = 1, \ldots, T$:

$$2\eta \sum_{t=1}^T s_t \delta_t + M_T \leq \delta_1^2 - \delta_{T+1}^2 + \eta^2 \sum_{t=1}^T g_t^2$$

Taking expectations, using $\mathbb{E}[M_T] = 0$, $\delta_{T+1}^2 \geq 0$, $\delta_1^2 \leq D^2$, $\mathbb{E}[g_t^2] \leq G^2$:

$$2\eta \sum_{t=1}^T \mathbb{E}[s_t \delta_t] \leq D^2 + \eta^2 T G^2$$

By the subgradient inequality ($s_t \in \partial f(x_t)$, convexity of $f$):

$$s_t(x_t - x^*) \geq f(x_t) - f(x^*)$$

Therefore:

$$2\eta \sum_{t=1}^T \mathbb{E}[f(x_t) - f^*] \leq D^2 + \eta^2 T G^2$$

**Step 6 (Jensen).** By convexity: $f(\bar{x}_T) \leq (1/T)\sum f(x_t)$. Dividing both sides by $2\eta T$:

$$\mathbb{E}[f(\bar{x}_T) - f^*] \leq \frac{D^2}{2\eta T} + \frac{\eta G^2}{2}$$

**Step 7 (Optimize).** With $\eta = D/(G\sqrt{T})$:

$$\frac{D^2}{2\eta T} = \frac{D^2 \cdot G\sqrt{T}}{2D \cdot T} = \frac{DG}{2\sqrt{T}}, \qquad \frac{\eta G^2}{2} = \frac{DG}{2\sqrt{T}}$$

$$\boxed{\mathbb{E}[f(\bar{x}_T) - f^*] \leq \frac{DG}{\sqrt{T}}} \qquad \blacksquare$$

---

## Why the log(T) Factor is Absent

The standard analysis uses decreasing step sizes $\eta_t = c/\sqrt{t}$, producing $\sum \eta_t^2 = c^2 \sum 1/t = O(c^2 \log T)$. With **constant** step size $\eta = D/(G\sqrt{T})$, we get $\sum \eta_t^2 = T\eta^2 = D^2/G^2 = O(1)$, eliminating the logarithmic factor.

## Three Barriers to the Last-Iterate Bound

1. **No contraction without strong convexity:** $V_{t+1} \leq V_t - 2\eta(f(x_t)-f^*) + \eta^2 G^2$ cannot be turned into $V_{t+1} \leq (1-\alpha)V_t + \beta$ because $f(x_t)-f^*$ is not bounded below by $c \cdot V_t$.

2. **No concentration of $x_T$ around $\bar{x}_T$:** With $\eta = D/(G\sqrt{T})$, the iterates execute a bounded random walk with $O(D)$ spread. $\mathbb{E}[|x_T - \bar{x}_T|] = O(D)$, not $O(1/\sqrt{T})$.

3. **Slow Markov chain mixing:** Mixing time is $\Theta(T)$ with this step size, so at time $T$ the chain has barely mixed.
