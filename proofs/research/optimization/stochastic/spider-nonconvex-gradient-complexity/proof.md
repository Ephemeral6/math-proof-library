# SPIDER Nonconvex Gradient Complexity — Proof

## Setup

$f = \frac{1}{n}\sum_{i=1}^n f_i$, each $f_i$ $L$-smooth (not necessarily convex), $f^* = \inf f > -\infty$, $\Delta_0 = f(x_0) - f^*$.

**SPIDER algorithm.** For $k = 1, \ldots, K$:
1. $x_0 = x_0^{(k)}$, compute $v_0 = \nabla f(x_0)$ (cost: $n$).
2. For $t = 0, \ldots, q-1$: $x_{t+1} = x_t - \eta v_t$; sample $\mathcal{B}_{t+1}$ of size $b$; $v_{t+1} = \frac{1}{b}\sum_{i \in \mathcal{B}_{t+1}}[\nabla f_i(x_{t+1}) - \nabla f_i(x_t)] + v_t$.
3. $x_0^{(k+1)} = x_q^{(k)}$.

Output: $\hat{x}$ uniform from all $Kq$ iterates. Parameters: $\eta = \frac{1}{2L}$, $b = q = \lceil\sqrt{n}\rceil$.

**Notation.** $e_t = v_t - \nabla f(x_t)$ (estimator error), $\mathcal{F}_t = \sigma(x_0, \mathcal{B}_1, \ldots, \mathcal{B}_t)$.

---

## Lemma 1 (Variance tracking)

At epoch start, $e_0 = 0$. For $t \geq 0$:
$$\mathbb{E}[\|e_{t+1}\|^2 \mid \mathcal{F}_t] \leq \|e_t\|^2 + \frac{L^2\eta^2}{b}\|v_t\|^2.$$

Telescoping: $\sum_{t=0}^{q-1}\mathbb{E}[\|e_t\|^2] \leq \frac{L^2\eta^2 q}{b}\sum_{t=0}^{q-1}\mathbb{E}[\|v_t\|^2]$.

**Proof.** Write $e_{t+1} = v_{t+1} - \nabla f(x_{t+1}) = v_t + \frac{1}{b}\sum_{i \in \mathcal{B}_{t+1}}[\nabla f_i(x_{t+1}) - \nabla f_i(x_t)] - \nabla f(x_{t+1})$.

Adding and subtracting $\nabla f(x_t)$: $e_{t+1} = e_t + \delta_{t+1}$ where
$$\delta_{t+1} = \frac{1}{b}\sum_{i \in \mathcal{B}_{t+1}}[\nabla f_i(x_{t+1}) - \nabla f_i(x_t)] - [\nabla f(x_{t+1}) - \nabla f(x_t)].$$

Since $\mathcal{B}_{t+1}$ is i.i.d. uniform and $x_{t+1}$ is $\mathcal{F}_t$-measurable: $\mathbb{E}[\delta_{t+1} \mid \mathcal{F}_t] = 0$.

So $\mathbb{E}[\|e_{t+1}\|^2 \mid \mathcal{F}_t] = \|e_t\|^2 + \mathbb{E}[\|\delta_{t+1}\|^2 \mid \mathcal{F}_t]$.

By variance $\leq$ second moment and $L$-smoothness of each $f_i$:
$$\mathbb{E}[\|\delta_{t+1}\|^2 \mid \mathcal{F}_t] \leq \frac{1}{b}\mathbb{E}_i[\|\nabla f_i(x_{t+1}) - \nabla f_i(x_t)\|^2] \leq \frac{L^2}{b}\|x_{t+1} - x_t\|^2 = \frac{L^2\eta^2}{b}\|v_t\|^2.$$

Telescope from $e_0 = 0$: $\mathbb{E}[\|e_t\|^2] \leq \frac{L^2\eta^2}{b}\sum_{s=0}^{t-1}\mathbb{E}[\|v_s\|^2]$.

Sum over $t$: $\sum_{t=0}^{q-1}\mathbb{E}[\|e_t\|^2] \leq \frac{L^2\eta^2}{b}\sum_{t=0}^{q-1}(q - 1 - t + 1)\mathbb{E}[\|v_t\|^2] \leq \frac{L^2\eta^2 q}{b}\sum_t\mathbb{E}[\|v_t\|^2]$. $\square$

---

## Lemma 2 (Per-step descent via polarization)

By $L$-smoothness: $f(x_{t+1}) \leq f(x_t) - \eta\langle\nabla f(x_t), v_t\rangle + \frac{L\eta^2}{2}\|v_t\|^2$.

**Polarization identity.** From $e_t = v_t - \nabla f(x_t)$:
$$\|e_t\|^2 = \|v_t\|^2 - 2\langle v_t, \nabla f(x_t)\rangle + \|\nabla f(x_t)\|^2$$
$$\implies \langle\nabla f(x_t), v_t\rangle = \frac{1}{2}\big(\|v_t\|^2 + \|\nabla f(x_t)\|^2 - \|e_t\|^2\big).$$

Substituting:
$$\boxed{f(x_{t+1}) \leq f(x_t) - \frac{\eta}{2}\|\nabla f(x_t)\|^2 + \frac{\eta}{2}\|e_t\|^2 - \frac{\eta(1 - L\eta)}{2}\|v_t\|^2.}$$

The crucial feature: the $\|v_t\|^2$ term has a **negative** coefficient when $\eta < 1/L$. $\square$

---

## Main Proof

### Step 1: Epoch-level descent

Sum Lemma 2 over $t = 0, \ldots, q-1$ and take expectations:
$$\mathbb{E}[f(x_q)] \leq f(x_0) - \frac{\eta}{2}\sum_t\mathbb{E}[\|\nabla f(x_t)\|^2] + \frac{\eta}{2}\sum_t\mathbb{E}[\|e_t\|^2] - \frac{\eta(1-L\eta)}{2}\sum_t\mathbb{E}[\|v_t\|^2].$$

Apply the cumulative variance bound (Lemma 1):
$$\mathbb{E}[f(x_q)] \leq f(x_0) - \frac{\eta}{2}\sum_t\mathbb{E}[\|\nabla f(x_t)\|^2] - \frac{\eta}{2}\underbrace{\left(1 - L\eta - \frac{L^2\eta^2 q}{b}\right)}_{\gamma}\sum_t\mathbb{E}[\|v_t\|^2].$$

**Parameter verification.** With $\eta = \frac{1}{2L}$, $b = q$:
$$\gamma = 1 - \frac{1}{2} - \frac{1}{4} = \frac{1}{4} > 0.$$

Since $\gamma > 0$, the $\sum\|v_t\|^2$ term is non-positive. Drop it:
$$\mathbb{E}[f(x_q)] \leq f(x_0) - \frac{\eta}{2}\sum_{t=0}^{q-1}\mathbb{E}[\|\nabla f(x_t)\|^2]. \tag{$\star$}$$

### Step 2: Telescoping across $K$ epochs

Let $F_k = \mathbb{E}[f(x_0^{(k)})]$. Since $x_0^{(k+1)} = x_q^{(k)}$, ($\star$) gives:
$$F_{k+1} \leq F_k - \frac{\eta}{2}\sum_{t=0}^{q-1}\mathbb{E}[\|\nabla f(x_t^{(k)})\|^2].$$

Sum over $k = 1, \ldots, K$:
$$\frac{\eta}{2}\sum_{k=1}^K\sum_{t=0}^{q-1}\mathbb{E}[\|\nabla f(x_t^{(k)})\|^2] \leq F_1 - F_{K+1} \leq \Delta_0.$$

### Step 3: Output bound

$\hat{x}$ uniform from all $Kq$ iterates:
$$\mathbb{E}[\|\nabla f(\hat{x})\|^2] \leq \frac{2\Delta_0}{\eta Kq} = \frac{4L\Delta_0}{Kq}.$$

### Step 4: Complexity

Set $\frac{4L\Delta_0}{Kq} \leq \epsilon^2$: need $K \geq \frac{4L\Delta_0}{q\epsilon^2} = \frac{4L\Delta_0}{\sqrt{n}\,\epsilon^2}$.

**Cost per epoch:** $n$ (full gradient) $+ bq = \sqrt{n}\cdot\sqrt{n} = n$ (inner loop) $= 2n$.

**Total cost:**
$$K \cdot 2n \leq 2n\left(\frac{4L\Delta_0}{\sqrt{n}\,\epsilon^2} + 1\right) = 2n + \frac{8L\Delta_0\sqrt{n}}{\epsilon^2}.$$

$$\boxed{\text{Total stochastic gradient evaluations} = O\!\left(n + \frac{L\Delta_0\sqrt{n}}{\epsilon^2}\right).} \qquad \blacksquare$$

---

## Why polarization is essential

Using Young's inequality instead of polarization: $-\langle \nabla f, e\rangle \leq \frac{1}{2}\|\nabla f\|^2 + \frac{1}{2}\|e\|^2$ and $\|v\|^2 \leq 2\|\nabla f\|^2 + 2\|e\|^2$.

This loses the negative $\|v\|^2$ term. The error $\sum\|e_t\|^2$ must then be bounded by $\sum\|\nabla f\|^2$ through a self-bounding argument, which introduces an extra $\sqrt{q}$ factor and yields $O(n^{3/4}/\epsilon^2)$ (the SVRG rate).

The polarization trick preserves the $\|v\|^2$ structure, allowing variance absorption at no cost in the gradient norm term. This is the key technical insight that upgrades SVRG's $n^{3/4}$ rate to SPIDER's $\sqrt{n}$ rate.
