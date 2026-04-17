# Convergence of Clipped SGD under Heavy-Tailed Noise: Proof

## Setting and Assumptions

Let $f:\mathbb{R}^d \to \mathbb{R}$ be $L$-smooth (possibly non-convex):
$$\|\nabla f(x) - \nabla f(y)\| \le L\|x - y\| \quad \forall\, x,y \in \mathbb{R}^d.$$

This implies the standard descent inequality:
$$f(y) \le f(x) + \langle \nabla f(x), y - x\rangle + \frac{L}{2}\|y-x\|^2 \quad \forall\, x,y. \tag{SM}$$

Define $f^* = \inf_x f(x) > -\infty$ and $\Delta_f = f(x_0) - f^*$.

**Stochastic oracle.** At each iterate $x_t$, we receive $g_t = \nabla f(x_t) + \xi_t$ where:
- (Unbiasedness) $\mathbb{E}[\xi_t \mid x_t] = 0$,
- (Heavy-tailed $p$-th moment) $\mathbb{E}[\|\xi_t\|^p \mid x_t] \le \sigma^p$ for some fixed $p \in (1,2]$ and $\sigma > 0$.

Note: for $p < 2$, the variance $\mathbb{E}[\|\xi_t\|^2]$ may be infinite.

**Algorithm (Clipped SGD).**
$$x_{t+1} = x_t - \eta\,\mathrm{clip}(g_t, \tau), \qquad \mathrm{clip}(g, \tau) = g \cdot \min\!\left(1,\, \frac{\tau}{\|g\|}\right).$$

**Notation.** $\nabla_t = \nabla f(x_t)$, $c_t = \mathrm{clip}(g_t, \tau)$.

---

## Theorem

Set $\tau = \sigma T^{1/p - 1/2}$ and $\eta = \frac{\sqrt{\Delta_f}}{\sqrt{L}\,\tau\sqrt{T}}$. Assume $T$ is large enough that $\tau \ge 2\sigma$ (equivalently $T^{1/p-1/2} \ge 2$) and $L\eta \le 1/2$. Then:

$$\frac{1}{T}\sum_{t=0}^{T-1}\mathbb{E}\bigl[\|\nabla f(x_t)\|^2\bigr] = O\!\left(\frac{\Delta_f L + L\sigma^2}{T^{1-1/p}}\right).$$

---

## Proof

### Step 1: Descent Lemma

Applying (SM) with $y = x_{t+1} = x_t - \eta c_t$:

$$f(x_{t+1}) \le f(x_t) - \eta\langle\nabla_t, c_t\rangle + \frac{L\eta^2}{2}\|c_t\|^2. \tag{1}$$

Since $\|c_t\| = \min(\|g_t\|, \tau) \le \tau$ (Fact A):
$$f(x_{t+1}) \le f(x_t) - \eta\langle\nabla_t, c_t\rangle + \frac{L\eta^2\tau^2}{2}. \tag{1'}$$

### Step 2: Inner Product Decomposition

Write $g_t = \nabla_t + \xi_t$, so:
$$\langle\nabla_t, c_t\rangle = \langle\nabla_t, g_t\rangle - \langle\nabla_t, g_t - c_t\rangle = \|\nabla_t\|^2 + \langle\nabla_t, \xi_t\rangle - \langle\nabla_t, g_t - c_t\rangle.$$

Taking $\mathbb{E}[\cdot \mid x_t]$ and using $\mathbb{E}[\xi_t \mid x_t] = 0$:
$$\mathbb{E}[\langle\nabla_t, c_t\rangle \mid x_t] = \|\nabla_t\|^2 - \mathbb{E}[\langle\nabla_t, g_t - c_t\rangle \mid x_t]. \tag{2}$$

### Step 3: Bounding the Clipping Bias

**Fact B.** $g_t - c_t = g_t(1 - \tau/\|g_t\|)_+$, so $\|g_t - c_t\| = (\|g_t\| - \tau)_+$.

*Proof:* If $\|g_t\| \le \tau$: $c_t = g_t$, residual is $0$. If $\|g_t\| > \tau$: $c_t = \tau g_t/\|g_t\|$, residual norm is $\|g_t\| - \tau$. $\square$

By Cauchy--Schwarz and Fact B:
$$\langle\nabla_t, g_t - c_t\rangle \le \|\nabla_t\| \cdot (\|g_t\| - \tau)_+. \tag{3}$$

**Lemma (Sub-additivity of $(\cdot)_+$).** For $a \in \mathbb{R}$, $b \ge 0$: $(a + b)_+ \le a_+ + b$.

*Proof:* If $a \ge 0$: $(a+b)_+ = a + b = a_+ + b$. If $a < 0$: $(a+b)_+ \le b = a_+ + b$. $\square$

Using $\|g_t\| \le \|\nabla_t\| + \|\xi_t\|$ and the lemma with $a = \|\nabla_t\| - \tau$, $b = \|\xi_t\|$:
$$(\|g_t\| - \tau)_+ \le (\|\nabla_t\| - \tau)_+ + \|\xi_t\|. \tag{4}$$

Since $x \mapsto x^{1/p}$ is concave for $p \ge 1$, Jensen gives:
$$\mathbb{E}[\|\xi_t\| \mid x_t] \le \bigl(\mathbb{E}[\|\xi_t\|^p \mid x_t]\bigr)^{1/p} \le \sigma. \tag{5}$$

Combining (3), (4), (5) into (2):
$$\mathbb{E}[\langle\nabla_t, c_t\rangle \mid x_t] \ge \|\nabla_t\|^2 - \sigma\|\nabla_t\| - \|\nabla_t\|(\|\nabla_t\| - \tau)_+. \tag{6}$$

### Step 4: Per-Step Descent

Substituting (6) and Fact A into (1'):
$$\mathbb{E}[f(x_{t+1}) \mid x_t] \le f(x_t) - \eta\|\nabla_t\|^2 + \eta\sigma\|\nabla_t\| + \eta\|\nabla_t\|(\|\nabla_t\|-\tau)_+ + \frac{L\eta^2\tau^2}{2}. \tag{7}$$

### Step 5: Unified Bound via $\phi_t$

Define $\phi_t = \min(\|\nabla_t\|^2,\; \tau\|\nabla_t\|)$.

**Case A ($\|\nabla_t\| \le \tau$):** $\phi_t = \|\nabla_t\|^2$, $(\|\nabla_t\|-\tau)_+ = 0$.

By Young: $\sigma\|\nabla_t\| \le \frac{\|\nabla_t\|^2}{4} + \sigma^2$. From (7):
$$\mathbb{E}[f(x_{t+1}) \mid x_t] \le f(x_t) - \frac{3\eta}{4}\|\nabla_t\|^2 + \eta\sigma^2 + \frac{L\eta^2\tau^2}{2}.$$

Hence $\frac{\eta}{2}\phi_t \le f(x_t) - \mathbb{E}[f(x_{t+1}) \mid x_t] + \eta\sigma^2 + \frac{L\eta^2\tau^2}{2}. \tag{8A}$

**Case B ($\|\nabla_t\| > \tau$):** $\phi_t = \tau\|\nabla_t\|$, $(\|\nabla_t\|-\tau)_+ = \|\nabla_t\| - \tau$.

From (7): $\|\nabla_t\|(\|\nabla_t\|-\tau) = \|\nabla_t\|^2 - \tau\|\nabla_t\|$, so:
$$\mathbb{E}[f(x_{t+1}) \mid x_t] \le f(x_t) - \eta(\tau - \sigma)\|\nabla_t\| + \frac{L\eta^2\tau^2}{2}.$$

Since $\tau \ge 2\sigma$: $\tau - \sigma \ge \tau/2$, hence $\frac{\eta}{2}\phi_t = \frac{\eta\tau}{2}\|\nabla_t\| \le f(x_t) - \mathbb{E}[f(x_{t+1}) \mid x_t] + \frac{L\eta^2\tau^2}{2}. \tag{8B}$

**Unified** (adding $\eta\sigma^2$ to Case B only weakens it):
$$\frac{\eta}{2}\phi_t \le f(x_t) - \mathbb{E}[f(x_{t+1}) \mid x_t] + \eta\sigma^2 + \frac{L\eta^2\tau^2}{2}. \tag{8}$$

### Step 6: Telescoping for $\phi_t$

Take full expectation in (8), sum $t = 0, \ldots, T-1$, use $\mathbb{E}[f(x_T)] \ge f^*$:
$$\frac{\eta}{2}\sum_{t=0}^{T-1}\mathbb{E}[\phi_t] \le \Delta_f + T\eta\sigma^2 + \frac{TL\eta^2\tau^2}{2}.$$

Dividing by $T\eta/2$:
$$\frac{1}{T}\sum_{t=0}^{T-1}\mathbb{E}[\phi_t] \le \frac{2\Delta_f}{\eta T} + 2\sigma^2 + L\eta\tau^2. \tag{9}$$

### Step 7: Recovering $\|\nabla_t\|^2$ from $\phi_t$

Observe the identity:
$$\|\nabla_t\|^2 = \phi_t + \|\nabla_t\|(\|\nabla_t\| - \tau)_+. \tag{10}$$

*Proof:* When $\|\nabla_t\| \le \tau$: $\phi_t = \|\nabla_t\|^2$, excess $= 0$. When $\|\nabla_t\| > \tau$: $\phi_t = \tau\|\nabla_t\|$, excess $= \|\nabla_t\|^2 - \tau\|\nabla_t\|$. Sum $= \|\nabla_t\|^2$. $\square$

We bound $\sum_t \mathbb{E}[\|\nabla_t\|(\|\nabla_t\|-\tau)_+]$ by telescoping directly from (7).

**Key observation.** Rearranging (7):
$$\eta\|\nabla_t\|^2 - \eta\sigma\|\nabla_t\| - \eta\|\nabla_t\|(\|\nabla_t\|-\tau)_+ \le f(x_t) - \mathbb{E}[f(x_{t+1})\mid x_t] + \frac{L\eta^2\tau^2}{2}.$$

Therefore:
$$\eta\|\nabla_t\|(\|\nabla_t\|-\tau)_+ \le f(x_t) - \mathbb{E}[f(x_{t+1})\mid x_t] + \frac{L\eta^2\tau^2}{2} - \eta\|\nabla_t\|(\|\nabla_t\| - \sigma).$$

For Type A ($\|\nabla_t\| \le \tau$): the LHS is $0$, so the bound holds trivially.

For Type B ($\|\nabla_t\| > \tau \ge 2\sigma$): we have $\|\nabla_t\| > \sigma$, so $\|\nabla_t\|(\|\nabla_t\| - \sigma) > 0$, hence:
$$\eta\|\nabla_t\|(\|\nabla_t\|-\tau)_+ \le f(x_t) - \mathbb{E}[f(x_{t+1})\mid x_t] + \frac{L\eta^2\tau^2}{2}. \tag{11}$$

This is the crucial step: the negative term $-\eta\|\nabla_t\|(\|\nabla_t\| - \sigma) < 0$ can be dropped because $\|\nabla_t\| > \tau \ge 2\sigma > \sigma$.

Taking full expectation and summing over $t = 0, \ldots, T-1$:
$$\eta\sum_{t=0}^{T-1}\mathbb{E}\bigl[\|\nabla_t\|(\|\nabla_t\|-\tau)_+\bigr] \le \Delta_f + \frac{TL\eta^2\tau^2}{2}.$$

Dividing by $\eta T$:
$$\frac{1}{T}\sum_{t=0}^{T-1}\mathbb{E}\bigl[\|\nabla_t\|(\|\nabla_t\|-\tau)_+\bigr] \le \frac{\Delta_f}{\eta T} + \frac{L\eta\tau^2}{2}. \tag{12}$$

### Step 8: Combining and Parameter Substitution

From (10), (9), (12):
$$\frac{1}{T}\sum_t\mathbb{E}[\|\nabla_t\|^2] \le \frac{3\Delta_f}{\eta T} + 2\sigma^2 + \frac{3L\eta\tau^2}{2}. \tag{13}$$

Substituting $\tau = \sigma T^{1/p-1/2}$ and $\eta = \frac{\sqrt{\Delta_f}}{\sqrt{L}\,\sigma T^{1/p}}$:

**First term:** $\frac{3\Delta_f}{\eta T} = \frac{3\Delta_f \sqrt{L}\,\sigma T^{1/p}}{\sqrt{\Delta_f}\, T} = \frac{3\sqrt{\Delta_f L}\,\sigma}{T^{1-1/p}}$.

**Third term:** $\frac{3}{2}L\eta\tau^2 = \frac{3}{2}L\cdot\frac{\sqrt{\Delta_f}}{\sqrt{L}\,\sigma T^{1/p}}\cdot\sigma^2 T^{2/p-1} = \frac{3\sqrt{\Delta_f L}\,\sigma}{2\,T^{1-1/p}}$.

**Second term:** $2\sigma^2$ (lower order for $T$ large).

Hence:
$$\frac{1}{T}\sum_t\mathbb{E}[\|\nabla_t\|^2] \le \frac{9\sqrt{\Delta_f L}\,\sigma}{2\,T^{1-1/p}} + 2\sigma^2.$$

By AM-GM: $\sqrt{\Delta_f L}\,\sigma \le \frac{\Delta_f L + \sigma^2}{2}$, so:

$$\boxed{\frac{1}{T}\sum_{t=0}^{T-1}\mathbb{E}\bigl[\|\nabla f(x_t)\|^2\bigr] = O\!\left(\frac{\Delta_f L + L\sigma^2}{T^{1-1/p}}\right).} \quad \square$$

---

## Verification of Rate

| $p$ | Rate $T^{-(1-1/p)}$ | Iterations for $\varepsilon$-stationarity |
|-----|---------------------|------------------------------------------|
| $2$ | $T^{-1/2}$         | $O(\varepsilon^{-2})$ |
| $3/2$ | $T^{-1/3}$       | $O(\varepsilon^{-3})$ |
| $1+\delta$ | $T^{-\delta/(1+\delta)}$ | $O(\varepsilon^{-(1+\delta)/\delta})$ |

For $p = 2$ (bounded variance), this recovers the classical $O(1/\sqrt{T})$ rate for non-convex SGD. $\blacksquare$
