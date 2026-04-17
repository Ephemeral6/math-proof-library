## Proof

**Route**: Route 3 -- Variance Reduction Viewpoint (Split Co-coercivity + Lyapunov)

---

### Theorem Statement

Let $f = \frac{1}{n}\sum_{i=1}^n f_i$ where each $f_i$ is convex and $L$-smooth, $f$ is $\mu$-strongly convex ($\kappa = L/\mu$), and the interpolation condition holds: $\nabla f_i(x^*) = 0$ for all $i$. Consider SGD with Polyak momentum:

$$v_{t+1} = \beta v_t + \nabla f_{i_t}(x_t), \quad x_{t+1} = x_t - \gamma v_{t+1}$$

with $v_0 = 0$ and $i_t$ sampled uniformly from $\{1,\ldots,n\}$.

**Claim**: With $\gamma = \frac{1}{L}$ and $\beta = \frac{\mu^2}{16L^2}$, we have

$$\mathbb{E}[\|x_t - x^*\|^2] \leq \left(1 - \frac{\mu}{2L}\right)^t \|x_0 - x^*\|^2.$$

---

### Preliminary Lemmas

**Lemma 1 (Split inner product bound).** Let $f$ be $\mu$-strongly convex and $L$-smooth with minimizer $x^*$, and let the interpolation condition $\nabla f_i(x^*)=0$ hold. Then for any $\alpha \in [0,1]$:

$$\langle \nabla f(x), x - x^*\rangle \geq \alpha\mu\|x - x^*\|^2 + \frac{1-\alpha}{L}\cdot\frac{1}{n}\sum_{i=1}^n \|\nabla f_i(x)\|^2.$$

*Proof.* We combine two inequalities:

(a) **Strong convexity**: $\langle \nabla f(x), x-x^*\rangle \geq f(x) - f^* + \frac{\mu}{2}\|x-x^*\|^2 \geq \mu\|x-x^*\|^2$ (the last step uses $f(x)-f^* \geq \frac{\mu}{2}\|x-x^*\|^2$).

(b) **Averaged co-coercivity**: Since each $f_i$ is convex and $L$-smooth with $\nabla f_i(x^*) = 0$, co-coercivity gives $\langle \nabla f_i(x), x-x^*\rangle \geq \frac{1}{L}\|\nabla f_i(x)\|^2$. Averaging over $i$: $\langle \nabla f(x), x-x^*\rangle \geq \frac{1}{nL}\sum_i\|\nabla f_i(x)\|^2$.

Taking the convex combination $\alpha \cdot (a) + (1-\alpha) \cdot (b)$ yields the result. $\square$

**Lemma 2 (Interpolation variance bound).** Under the stated conditions:
$$\frac{1}{n}\sum_{i=1}^n\|\nabla f_i(x)\|^2 \leq L^2\|x - x^*\|^2.$$

*Proof.* By $L$-smoothness of each $f_i$ and interpolation ($\nabla f_i(x^*)=0$): $\|\nabla f_i(x)\|^2 = \|\nabla f_i(x) - \nabla f_i(x^*)\|^2 \leq L^2\|x-x^*\|^2$. Averaging preserves this bound. $\square$

**Lemma 3 (Gradient Lipschitz bound).** $\|\nabla f(x)\|^2 \leq L^2\|x-x^*\|^2$.

*Proof.* By $L$-smoothness of $f$: $\|\nabla f(x) - \nabla f(x^*)\| \leq L\|x-x^*\|$. Since $\nabla f(x^*) = 0$, the result follows. $\square$

---

### Main Proof

#### Step 1: Error coordinates

Let $e_t = x_t - x^*$ and $m_t = \gamma v_t$ (the scaled momentum). Since $v_0=0$, we have $m_0=0$. The iteration becomes:

$$m_{t+1} = \beta m_t + \gamma g_t, \quad e_{t+1} = e_t - m_{t+1} = e_t - \beta m_t - \gamma g_t \tag{1}$$

where $g_t = \nabla f_{i_t}(x_t)$ and $\mathbb{E}_t[\cdot] = \mathbb{E}[\cdot|\mathcal{F}_t]$ denotes conditional expectation given the filtration up to time $t$. We have $\mathbb{E}_t[g_t] = \nabla f(x_t)$ and $\mathbb{E}_t[\|g_t\|^2] = \frac{1}{n}\sum_i\|\nabla f_i(x_t)\|^2$.

#### Step 2: Lyapunov function

Define:
$$\Phi_t = \|e_t\|^2 + a\|m_t\|^2$$

where $a = \frac{\mu}{4L} = \frac{1}{4\kappa}$. We will show $\mathbb{E}_t[\Phi_{t+1}] \leq \rho\Phi_t$ with $\rho = 1 - \frac{\mu}{2L}$.

#### Step 3: Expand $\|e_{t+1}\|^2$

From (1):
$$\|e_{t+1}\|^2 = \|e_t - \beta m_t - \gamma g_t\|^2$$
$$= \|e_t\|^2 + \beta^2\|m_t\|^2 + \gamma^2\|g_t\|^2 - 2\beta\langle e_t, m_t\rangle - 2\gamma\langle e_t, g_t\rangle + 2\gamma\beta\langle m_t, g_t\rangle \tag{2}$$

#### Step 4: Expand $\|m_{t+1}\|^2$

$$\|m_{t+1}\|^2 = \|\beta m_t + \gamma g_t\|^2 = \beta^2\|m_t\|^2 + 2\gamma\beta\langle m_t, g_t\rangle + \gamma^2\|g_t\|^2 \tag{3}$$

#### Step 5: Conditional expectation of $\Phi_{t+1}$

Taking (2) + $a \times$ (3) and applying $\mathbb{E}_t$:

$$\mathbb{E}_t[\Phi_{t+1}] = \|e_t\|^2 + (1+a)\beta^2\|m_t\|^2 + (1+a)\gamma^2\mathbb{E}_t[\|g_t\|^2]$$
$$\quad - 2\beta\langle e_t, m_t\rangle - 2\gamma\langle e_t, \nabla f(x_t)\rangle + 2(1+a)\gamma\beta\langle m_t, \nabla f(x_t)\rangle \tag{4}$$

#### Step 6: Variance absorption via split co-coercivity (KEY STEP)

Apply Lemma 1 with $\alpha = \frac{1}{2}$:

$$\langle \nabla f(x_t), e_t\rangle \geq \frac{\mu}{2}\|e_t\|^2 + \frac{1}{2L}\mathbb{E}_t[\|g_t\|^2]$$

Therefore:

$$-2\gamma\langle e_t, \nabla f(x_t)\rangle \leq -\gamma\mu\|e_t\|^2 - \frac{\gamma}{L}\mathbb{E}_t[\|g_t\|^2]$$

With $\gamma = \frac{1}{L}$:

$$-2\gamma\langle e_t, \nabla f(x_t)\rangle \leq -\frac{\mu}{L}\|e_t\|^2 - \frac{1}{L^2}\mathbb{E}_t[\|g_t\|^2] \tag{5}$$

The gradient step also contributes $\gamma^2\mathbb{E}_t[\|g_t\|^2] = \frac{1}{L^2}\mathbb{E}_t[\|g_t\|^2]$ to the $\|e_{t+1}\|^2$ expansion (from (2)).

**Combining these two contributions, the stochastic gradient variance from the $\|e_{t+1}\|^2$ expansion is exactly cancelled:**

$$-2\gamma\langle e_t,\nabla f(x_t)\rangle + \gamma^2\mathbb{E}_t[\|g_t\|^2] \leq -\frac{\mu}{L}\|e_t\|^2 \tag{6}$$

This is the **variance reduction effect** of interpolation: the co-coercivity portion of the inner product (using $\alpha=1/2$) provides exactly $\frac{1}{L^2}\mathbb{E}_t[\|g_t\|^2]$ of negative contribution, which cancels the $\frac{1}{L^2}\mathbb{E}_t[\|g_t\|^2]$ variance term. The strong convexity portion provides the $\frac{\mu}{L}$ contraction.

#### Step 7: Bound the momentum contributions

Substituting (6) into (4), the remaining terms beyond the baseline contraction are:

$$\mathbb{E}_t[\Phi_{t+1}] \leq \left(1 - \frac{\mu}{L}\right)\|e_t\|^2 + (1+a)\beta^2\|m_t\|^2 + a\gamma^2\mathbb{E}_t[\|g_t\|^2]$$
$$\quad -2\beta\langle e_t, m_t\rangle + 2(1+a)\gamma\beta\langle m_t, \nabla f(x_t)\rangle \tag{7}$$

Note: the $(1+a)\gamma^2\mathbb{E}_t[\|g_t\|^2]$ from (4) splits as $1 \cdot \gamma^2\mathbb{E}_t[\|g_t\|^2]$ (absorbed by (6)) plus $a\gamma^2\mathbb{E}_t[\|g_t\|^2]$ (remains).

We now bound each perturbation term, allocating a budget of $\frac{\mu}{8L}\|e_t\|^2$ per term:

**(i) Residual variance** ($a\gamma^2\mathbb{E}_t[\|g_t\|^2]$ from the momentum Lyapunov):

By Lemma 2 and $\gamma = 1/L$:

$$a\gamma^2\mathbb{E}_t[\|g_t\|^2] \leq a\gamma^2 L^2\|e_t\|^2 = a\|e_t\|^2 = \frac{\mu}{4L}\|e_t\|^2 \tag{i}$$

**(ii) Cross term** $-2\beta\langle e_t, m_t\rangle$:

By Young's inequality with parameter $\delta = \frac{8L\beta}{\mu}$:

$$-2\beta\langle e_t, m_t\rangle \leq \frac{\beta}{\delta}\|e_t\|^2 + \beta\delta\|m_t\|^2 = \frac{\mu}{8L}\|e_t\|^2 + \frac{8L\beta^2}{\mu}\|m_t\|^2 \tag{ii}$$

**(iii) Cross term** $2(1+a)\gamma\beta\langle m_t, \nabla f(x_t)\rangle$:

By Young's inequality with parameter $\sigma = \frac{8(1+a)\beta L^2}{\mu}$:

$$2(1+a)\gamma\beta\langle m_t, \nabla f(x_t)\rangle \leq \frac{(1+a)\gamma\beta}{\sigma}\|\nabla f(x_t)\|^2 + (1+a)\gamma\beta\sigma\|m_t\|^2$$

For the first term, using Lemma 3 and $\gamma L = 1$:

$$\frac{(1+a)\gamma\beta}{\sigma}\|\nabla f(x_t)\|^2 \leq \frac{(1+a)\gamma\beta L^2}{\sigma}\|e_t\|^2 = \frac{\mu}{8L}\|e_t\|^2 \tag{iii-a}$$

(since $\frac{(1+a)\gamma\beta L^2}{\sigma} = \frac{(1+a)\beta L}{\sigma} = \frac{(1+a)\beta L \cdot \mu}{8(1+a)\beta L^2} = \frac{\mu}{8L}$).

For the second term:

$$(1+a)\gamma\beta\sigma\|m_t\|^2 = \frac{8(1+a)^2\beta^2 L}{\mu}\|m_t\|^2 \tag{iii-b}$$

#### Step 8: Assemble the $\|e_t\|^2$ coefficient

From (7), (i), (ii), (iii-a):

$$R_e = 1 - \frac{\mu}{L} + \frac{\mu}{4L} + \frac{\mu}{8L} + \frac{\mu}{8L} = 1 - \frac{\mu}{L} + \frac{\mu}{2L} = 1 - \frac{\mu}{2L} = \rho \tag{8}$$

#### Step 9: Verify the $\|m_t\|^2$ coefficient

From (7), (ii), (iii-b):

$$R_m = (1+a)\beta^2 + \frac{8L\beta^2}{\mu} + \frac{8(1+a)^2\beta^2 L}{\mu} \tag{9}$$

With $\beta = \frac{\mu^2}{16L^2}$ and $a = \frac{\mu}{4L} \leq \frac{1}{4}$:

- $(1+a)\beta^2 \leq \frac{5}{4} \cdot \frac{\mu^4}{256L^4} = \frac{5\mu^4}{1024L^4}$

- $\frac{8L\beta^2}{\mu} = \frac{8L\mu^4}{256L^4\mu} = \frac{\mu^3}{32L^3}$

- $\frac{8(1+a)^2\beta^2 L}{\mu} \leq \frac{8 \cdot \frac{25}{16} \cdot \frac{\mu^4}{256L^4} \cdot L}{\mu} = \frac{25\mu^3}{512L^3}$

Therefore:

$$R_m \leq \frac{5\mu^4}{1024L^4} + \frac{\mu^3}{32L^3} + \frac{25\mu^3}{512L^3} = \frac{5\mu^4}{1024L^4} + \frac{16\mu^3 + 25\mu^3}{512L^3} = \frac{5\mu^4}{1024L^4} + \frac{41\mu^3}{512L^3}$$

For $\kappa \geq 1$, the first term is negligible, and:

$$R_m \leq \frac{41\mu^3}{512L^3} + \frac{5\mu^3}{1024L^3} \leq \frac{\mu^3}{10L^3}$$

We need $R_m \leq a\rho$:

$$a\rho = \frac{\mu}{4L}\left(1 - \frac{\mu}{2L}\right) = \frac{\mu}{4L} - \frac{\mu^2}{8L^2} \geq \frac{\mu}{8L} \quad \text{for } \kappa \geq 2.$$

The condition $R_m \leq a\rho$ requires:

$$\frac{\mu^3}{10L^3} \leq \frac{\mu}{8L} \iff \frac{\mu^2}{10L^2} \leq \frac{1}{8} \iff \kappa^2 \geq \frac{8}{10}$$

which holds for all $\kappa \geq 1$. $\checkmark$

#### Step 10: Conclusion

From Steps 8 and 9, we have $R_e = \rho$ and $R_m \leq a\rho$, giving:

$$\mathbb{E}_t[\Phi_{t+1}] \leq R_e\|e_t\|^2 + R_m\|m_t\|^2 \leq \rho\|e_t\|^2 + a\rho\|m_t\|^2 = \rho\,\Phi_t$$

Taking full expectations and iterating from $t=0$:

$$\mathbb{E}[\Phi_t] \leq \rho^t\,\Phi_0$$

Since $\|e_t\|^2 \leq \Phi_t$ and $\Phi_0 = \|e_0\|^2 + a\|m_0\|^2 = \|e_0\|^2$ (using $m_0 = 0$):

$$\boxed{\mathbb{E}[\|x_t - x^*\|^2] \leq \left(1 - \frac{\mu}{2L}\right)^t \|x_0 - x^*\|^2}$$

This proves the claimed linear convergence with $C = 1$ and $\rho = 1 - \frac{1}{2\kappa} < 1$.

$\blacksquare$

---

### Summary of the Variance Reduction Viewpoint

The proof rests on two key mechanisms:

1. **Variance absorption via split co-coercivity (Step 6)**: Under interpolation, each component gradient vanishes at $x^*$, so co-coercivity gives $\langle \nabla f_i(x), x-x^*\rangle \geq \frac{1}{L}\|\nabla f_i(x)\|^2$. By "splitting" the inner product $\langle \nabla f, e\rangle$ into half for strong convexity and half for co-coercivity, the co-coercivity portion exactly absorbs the $\gamma^2\mathbb{E}[\|g_t\|^2]$ variance when $\gamma = 1/L$. This is the "variance reduction" inherent in interpolation -- no explicit variance reduction technique (like SVRG) is needed.

2. **Momentum as small perturbation (Steps 7-9)**: With $\beta = O(1/\kappa^2)$, the momentum displacement $m_t = \gamma v_t$ contributes terms of order $O(\beta) = O(1/\kappa^2)$ to the per-step error, well within the $O(1/\kappa)$ contraction budget. The Lyapunov weight $a = \frac{1}{4\kappa}$ ensures the momentum energy $\|m_t\|^2$ also contracts.

### Remark on the Rate

The achieved rate $\rho = 1 - \frac{1}{2\kappa}$ is of the same order as vanilla SGD under interpolation. The momentum parameter $\beta = \Theta(1/\kappa^2)$ is conservative; larger $\beta$ (closer to the classical heavy-ball choice $\beta \approx ((\sqrt{\kappa}-1)/(\sqrt{\kappa}+1))^2$) could potentially yield an accelerated rate $1 - O(1/\sqrt{\kappa})$ but would require a more delicate analysis (e.g., integral quadratic constraints or a non-standard Lyapunov function).
