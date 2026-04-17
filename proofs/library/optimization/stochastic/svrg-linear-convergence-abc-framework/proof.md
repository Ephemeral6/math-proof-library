# SVRG Linear Convergence — ABC Framework Proof

## Assumptions
- Each $f_i$ is convex and $L$-smooth: $\|\nabla f_i(x) - \nabla f_i(y)\| \leq L\|x - y\|$
- $F = \frac{1}{n}\sum f_i$ is $\mu$-strongly convex, $\kappa = L/\mu$
- Parameters: $\eta = \frac{1}{10L}$, $m = 20\kappa$

## Notation
- $\delta_t = \mathbb{E}[F(x_t) - F(x^*)]$ (function gap at inner iterate $t$)
- $\Phi_t = \mathbb{E}\|x_t - x^*\|^2$ (squared distance to optimum)
- $\delta_0 = F(\tilde{x}_s) - F(x^*)$ (epoch-start gap, since $x_0 = \tilde{x}_s$)
- $D_f(x, y) = f(x) - f(y) - \langle \nabla f(y), x - y\rangle$ (Bregman divergence)

---

## Lemma 1 (Unbiasedness)

$$\mathbb{E}_{i_t}[v_t \mid x_t] = \nabla F(x_t).$$

**Proof.** $\mathbb{E}_{i_t}[v_t] = \mathbb{E}_{i_t}[\nabla f_{i_t}(x_t) - \nabla f_{i_t}(\tilde{x}_s)] + \nabla F(\tilde{x}_s) = \nabla F(x_t) - \nabla F(\tilde{x}_s) + \nabla F(\tilde{x}_s) = \nabla F(x_t)$. $\blacksquare$

## Lemma 2 (Nesterov's Smoothness-Convexity Bound)

For convex $L$-smooth $f_i$:

$$\|\nabla f_i(x) - \nabla f_i(y)\|^2 \leq 2L \cdot D_{f_i}(x, y).$$

**Proof.** This is Nesterov (2004), Theorem 2.1.5. Define $g(z) = f_i(z) - f_i(y) - \langle \nabla f_i(y), z - y\rangle$. Then $g$ is convex, $L$-smooth, $g(y) = 0$, $\nabla g(y) = 0$. The minimizer of the quadratic upper bound $g(y) + \langle \nabla g(x), z - x\rangle + \frac{L}{2}\|z - x\|^2$ is at $z^* = x - \frac{1}{L}\nabla g(x)$, giving $g(z^*) \leq g(x) - \frac{1}{2L}\|\nabla g(x)\|^2$. Since $g \geq 0$ everywhere (by convexity and $g(y) = 0, \nabla g(y) = 0$), taking $z^*$ at the global min: $0 \leq g(x) - \frac{1}{2L}\|\nabla g(x)\|^2$, i.e., $\|\nabla f_i(x) - \nabla f_i(y)\|^2 = \|\nabla g(x)\|^2 \leq 2L \cdot g(x) = 2L \cdot D_{f_i}(x, y)$. $\blacksquare$

## Lemma 3 (Gradient Bound at Optimum)

For $L$-smooth (and convex) $F$ with minimizer $x^*$:

$$\|\nabla F(x)\|^2 \leq 2L(F(x) - F(x^*)).$$

**Proof.** Special case of Lemma 2 applied to $F$ with $y = x^*$ and $\nabla F(x^*) = 0$. $\blacksquare$

## Lemma 4 (Strong Convexity Distance Bound)

$$\|x - x^*\|^2 \leq \frac{2}{\mu}(F(x) - F(x^*)).$$

**Proof.** From $\mu$-strong convexity at $x^*$: $F(x) \geq F(x^*) + \frac{\mu}{2}\|x - x^*\|^2$. $\blacksquare$

## Lemma 5 (SVRG Second Moment Bound)

$$\mathbb{E}_{i_t}\|v_t\|^2 \leq 4L\left[(F(x_t) - F(x^*)) + (F(\tilde{x}_s) - F(x^*))\right].$$

**Proof.** Write $v_t = [\nabla f_{i_t}(x_t) - \nabla f_{i_t}(x^*)] - [(\nabla f_{i_t}(\tilde{x}_s) - \nabla f_{i_t}(x^*)) - \nabla F(\tilde{x}_s)]$ using $\nabla F(x^*) = 0$.

Let $A_i = \nabla f_i(x_t) - \nabla f_i(x^*)$ and $B_i = \nabla f_i(\tilde{x}_s) - \nabla f_i(x^*)$. Then $v_t = A_{i_t} - (B_{i_t} - \mathbb{E}[B_{i_t}])$, since $\mathbb{E}_i[B_i] = \nabla F(\tilde{x}_s)$.

By $\|a + b\|^2 \leq 2\|a\|^2 + 2\|b\|^2$:

$$\mathbb{E}\|v_t\|^2 \leq 2\mathbb{E}\|A_{i_t}\|^2 + 2\mathbb{E}\|B_{i_t} - \mathbb{E}B_{i_t}\|^2 \leq 2\mathbb{E}\|A_{i_t}\|^2 + 2\mathbb{E}\|B_{i_t}\|^2.$$

By Lemma 2: $\frac{1}{n}\sum_i \|\nabla f_i(x) - \nabla f_i(x^*)\|^2 \leq \frac{2L}{n}\sum_i D_{f_i}(x, x^*) = 2L \cdot D_F(x, x^*) = 2L(F(x) - F(x^*))$,

where the last equality uses $\nabla F(x^*) = 0$.

Therefore: $\mathbb{E}\|v_t\|^2 \leq 4L(F(x_t) - F(x^*)) + 4L(F(\tilde{x}_s) - F(x^*))$. $\blacksquare$

---

## Main Proof

### Step 1: One-step distance recursion

Expand $\|x_{t+1} - x^*\|^2 = \|x_t - \eta v_t - x^*\|^2$:

$$\|x_{t+1} - x^*\|^2 = \|x_t - x^*\|^2 - 2\eta\langle v_t, x_t - x^*\rangle + \eta^2\|v_t\|^2.$$

Take $\mathbb{E}_{i_t}[\cdot \mid x_t]$. By Lemma 1, $\mathbb{E}[v_t] = \nabla F(x_t)$:

$$\mathbb{E}_{i_t}\|x_{t+1} - x^*\|^2 = \|x_t - x^*\|^2 - 2\eta\langle \nabla F(x_t), x_t - x^*\rangle + \eta^2\mathbb{E}\|v_t\|^2.$$

### Step 2: Apply strong convexity and Lemma 5

By $\mu$-strong convexity of $F$:

$$\langle \nabla F(x_t), x_t - x^*\rangle \geq (F(x_t) - F(x^*)) + \frac{\mu}{2}\|x_t - x^*\|^2.$$

By Lemma 5:

$$\eta^2\mathbb{E}\|v_t\|^2 \leq 4\eta^2 L(F(x_t) - F(x^*)) + 4\eta^2 L(F(\tilde{x}_s) - F(x^*)).$$

### Step 3: Combine

$$\mathbb{E}_{i_t}\|x_{t+1} - x^*\|^2 \leq (1 - \eta\mu)\|x_t - x^*\|^2 - \eta(2 - 4\eta L)(F(x_t) - F(x^*)) + 4\eta^2 L(F(\tilde{x}_s) - F(x^*)).$$

With $\eta = \frac{1}{10L}$:

- $\eta\mu = \frac{1}{10\kappa}$
- $2 - 4\eta L = 2 - \frac{4}{10} = \frac{8}{5}$
- $\eta(2 - 4\eta L) = \frac{8}{50L} = \frac{4}{25L}$
- $4\eta^2 L = \frac{4}{100L} = \frac{1}{25L}$

Taking full expectations:

$$\Phi_{t+1} \leq \left(1 - \frac{1}{10\kappa}\right)\Phi_t - \frac{4}{25L}\delta_t + \frac{1}{25L}\delta_0. \quad (\star)$$

### Step 4: Sum over inner loop

Sum $(\star)$ for $t = 0, 1, \ldots, m-1$:

$$\sum_{t=1}^m \Phi_t \leq \left(1 - \frac{1}{10\kappa}\right)\sum_{t=0}^{m-1}\Phi_t - \frac{4}{25L}\sum_{t=0}^{m-1}\delta_t + \frac{m}{25L}\delta_0.$$

Rewrite the left side: $\sum_{t=1}^m \Phi_t = \sum_{t=0}^{m-1}\Phi_t - \Phi_0 + \Phi_m$. Rearranging:

$$\frac{4}{25L}\sum_{t=0}^{m-1}\delta_t + \frac{1}{10\kappa}\sum_{t=0}^{m-1}\Phi_t + \Phi_m \leq \Phi_0 + \frac{m}{25L}\delta_0. \quad (\star\star)$$

### Step 5: Convert $\Phi_t$ to $\delta_t$ via strong convexity

By Lemma 4: $\Phi_t \leq \frac{2}{\mu}\delta_t$, so:

$$\frac{1}{10\kappa}\Phi_t \leq \frac{2}{10\kappa\mu}\delta_t = \frac{2}{10L}\delta_t = \frac{1}{5L}\delta_t.$$

Substituting into $(\star\star)$ and dropping $\Phi_m \geq 0$:

$$\left(\frac{4}{25L} + \frac{1}{5L}\right)\sum_{t=0}^{m-1}\delta_t \leq \Phi_0 + \frac{m}{25L}\delta_0.$$

$$\frac{9}{25L}\sum_{t=0}^{m-1}\delta_t \leq \Phi_0 + \frac{m}{25L}\delta_0.$$

### Step 6: Apply output averaging

Since $\tilde{x}_{s+1}$ is uniform over $\{x_0, \ldots, x_{m-1}\}$, by convexity of $F$:

$$\mathbb{E}[F(\tilde{x}_{s+1})] - F(x^*) \leq \frac{1}{m}\sum_{t=0}^{m-1}\delta_t.$$

From the bound above:

$$\frac{1}{m}\sum_{t=0}^{m-1}\delta_t \leq \frac{25L}{9m}\Phi_0 + \frac{1}{9}\delta_0.$$

Using $\Phi_0 = \|\tilde{x}_s - x^*\|^2 \leq \frac{2}{\mu}\delta_0$ (Lemma 4):

$$\frac{1}{m}\sum_{t=0}^{m-1}\delta_t \leq \left(\frac{50L}{9m\mu} + \frac{1}{9}\right)\delta_0 = \left(\frac{50\kappa}{9m} + \frac{1}{9}\right)\delta_0.$$

### Step 7: Plug in $m = 20\kappa$

$$\frac{50\kappa}{9 \cdot 20\kappa} + \frac{1}{9} = \frac{50}{180} + \frac{1}{9} = \frac{5}{18} + \frac{2}{18} = \frac{7}{18}.$$

### Conclusion

$$\boxed{\mathbb{E}[F(\tilde{x}_{s+1})] - F(x^*) \leq \frac{7}{18}\left(F(\tilde{x}_s) - F(x^*)\right) < \frac{1}{2}\left(F(\tilde{x}_s) - F(x^*)\right).}$$

Since $\frac{7}{18} \approx 0.389 < \frac{1}{2}$, SVRG achieves linear convergence with contraction factor at most $\frac{1}{2}$ per epoch. $\blacksquare$
