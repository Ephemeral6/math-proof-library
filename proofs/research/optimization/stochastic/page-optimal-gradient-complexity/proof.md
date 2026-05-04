# PAGE Convergence Proof — Unrolled Recursion Approach

## Setup

$f = \frac{1}{n}\sum_{i=1}^n f_i$, each $f_i$ $L$-smooth, $f^* = \inf f > -\infty$, $\Delta_0 = f(x_0) - f^*$.

**PAGE:** $g_0 = \nabla f(x_0)$; for $t \geq 0$: $x_{t+1} = x_t - \eta g_t$; with prob $p$ reset $g_{t+1} = \nabla f(x_{t+1})$, with prob $1-p$ correct $g_{t+1} = g_t + \frac{1}{b'}\sum_{i \in \mathcal{B}'_t}[\nabla f_i(x_{t+1}) - \nabla f_i(x_t)]$.

**Parameters:** $p = 1/\sqrt{n}$, $b' = \sqrt{n}$, $\eta = 1/(2L)$.

**Notation:** $e_t = g_t - \nabla f(x_t)$, $V_t = \mathbb{E}[\|e_t\|^2]$, $\mathcal{G} = \sum_t \mathbb{E}[\|\nabla f(x_t)\|^2]$, $\mathcal{H} = \sum_t \mathbb{E}[\|g_t\|^2]$, $\mathcal{V} = \sum_t V_t$.

---

## Lemma 1 (Unbiasedness)

$\mathbb{E}[e_t] = 0$ for all $t$.

**Proof.** $e_0 = 0$. Induction: $\mathbb{E}[e_{t+1}|\mathcal{F}_t] = p \cdot 0 + (1-p) \cdot e_t = (1-p)e_t$. Taking expectations: $\mathbb{E}[e_{t+1}] = (1-p)\mathbb{E}[e_t] = 0$. $\square$

---

## Lemma 2 (Variance Recursion)

$$V_{t+1} \leq (1-p)V_t + \frac{L^2\eta^2}{b'}\mathbb{E}[\|g_t\|^2]$$

**Proof.** Define $\delta_t = \frac{1}{b'}\sum_{i \in \mathcal{B}'_t}[\nabla f_i(x_{t+1}) - \nabla f_i(x_t)] - [\nabla f(x_{t+1}) - \nabla f(x_t)]$.

In the SPIDER case: $e_{t+1} = e_t + \delta_t$. Since $\mathbb{E}[\delta_t|\mathcal{F}_t] = 0$ and $e_t$ is $\mathcal{F}_t$-measurable:

$$\mathbb{E}[\|e_{t+1}\|^2|\mathcal{F}_t, \text{no reset}] = \|e_t\|^2 + \mathbb{E}[\|\delta_t\|^2|\mathcal{F}_t]$$

By variance $\leq$ second moment and individual $L$-smoothness:

$$\mathbb{E}[\|\delta_t\|^2|\mathcal{F}_t] \leq \frac{1}{b'} \cdot \frac{1}{n}\sum_{i=1}^n \|\nabla f_i(x_{t+1}) - \nabla f_i(x_t)\|^2 \leq \frac{L^2}{b'}\|x_{t+1}-x_t\|^2 = \frac{L^2\eta^2}{b'}\|g_t\|^2$$

By total expectation (reset gives $\|e_{t+1}\|^2 = 0$):

$$\mathbb{E}[\|e_{t+1}\|^2|\mathcal{F}_t] = (1-p)\left(\|e_t\|^2 + \frac{L^2\eta^2}{b'}\|g_t\|^2\right)$$

Taking expectations and using $(1-p) \leq 1$ on the second term: $V_{t+1} \leq (1-p)V_t + \frac{L^2\eta^2}{b'}\mathbb{E}[\|g_t\|^2]$. $\square$

---

## Lemma 3 (Descent via Polarization)

$$f(x_{t+1}) \leq f(x_t) - \frac{\eta}{2}\|\nabla f(x_t)\|^2 - \frac{\eta(1-L\eta)}{2}\|g_t\|^2 + \frac{\eta}{2}\|e_t\|^2$$

**Proof.** By $L$-smoothness: $f(x_{t+1}) \leq f(x_t) - \eta\langle\nabla f(x_t), g_t\rangle + \frac{L\eta^2}{2}\|g_t\|^2$.

By polarization: $\langle\nabla f(x_t), g_t\rangle = \frac{1}{2}\|\nabla f(x_t)\|^2 + \frac{1}{2}\|g_t\|^2 - \frac{1}{2}\|e_t\|^2$.

Substituting and collecting the $\|g_t\|^2$ terms: $-\eta/2 + L\eta^2/2 = -\eta(1-L\eta)/2$. $\square$

---

## Main Proof

**Step 1 (Unroll).** From $V_0 = 0$ and Lemma 2:

$$V_t \leq \frac{L^2\eta^2}{b'}\sum_{s=0}^{t-1}(1-p)^{t-1-s}\mathbb{E}[\|g_s\|^2]$$

Each past gradient norm contributes with exponentially decaying weight — the Bernoulli resets prevent unbounded variance accumulation.

**Step 2 (Sum and swap).** Sum over $t$, swap summation order, bound geometric series by $1/p$:

$$\mathcal{V} \leq \frac{L^2\eta^2}{pb'}\mathcal{H}$$

Substituting parameters: $\frac{L^2\eta^2}{pb'} = \frac{L^2 \cdot \frac{1}{4L^2}}{\frac{1}{\sqrt{n}} \cdot \sqrt{n}} = \frac{1}{4}$. So $\mathcal{V} \leq \frac{1}{4}\mathcal{H}$.

**Step 3 (Combine).** Sum Lemma 3 over $t$, take expectations, use $f(x_T) \geq f^*$:

$$\frac{\eta}{2}\mathcal{G} + \frac{\eta}{2}\left(1 - L\eta - \frac{1}{4}\right)\mathcal{H} \leq \Delta_0$$

**Coefficient check:** $1 - \frac{1}{2} - \frac{1}{4} = \frac{1}{4} > 0$ for all $n \geq 1$.

Drop the non-negative $\mathcal{H}$ term:

$$\frac{1}{T}\sum_{t=0}^{T-1}\mathbb{E}[\|\nabla f(x_t)\|^2] \leq \frac{2\Delta_0}{\eta T} = \frac{4L\Delta_0}{T} \qquad \blacksquare$$

---

## Gradient Complexity

Per step cost: $p \cdot n + (1-p) \cdot b' = 2\sqrt{n} - 1 = O(\sqrt{n})$.

Total SFO calls: $n + T \cdot O(\sqrt{n}) = O\!\left(n + \frac{\sqrt{n} \cdot L\Delta_0}{\varepsilon^2}\right)$.

This matches the lower bound $\Omega(n + \sqrt{n}/\varepsilon^2)$ (Fang et al. 2018) up to the $L\Delta_0$ factor absorbed in the big-O.
