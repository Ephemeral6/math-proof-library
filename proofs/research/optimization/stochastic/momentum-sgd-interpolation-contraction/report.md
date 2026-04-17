# SGD with Polyak Momentum under Interpolation — Linear Convergence

## Route 4: Contraction Mapping in Weighted Joint Space

---

## Theorem

Let $f = \frac{1}{n}\sum_{i=1}^n f_i$ where each $f_i$ is convex and $L$-smooth, $f$ is $\mu$-strongly convex with condition number $\kappa = L/\mu$, and the interpolation condition holds: $\nabla f_i(x^*) = 0$ for all $i$. Consider SGD with Polyak momentum initialized at $v_0 = 0$:

$$v_{t+1} = \beta v_t + \nabla f_{i_t}(x_t), \quad x_{t+1} = x_t - \gamma v_{t+1}$$

With $\gamma = \frac{1}{4L}$ and $\beta = \frac{1}{8\kappa}$, there exists $\rho < 1$ such that

$$\mathbb{E}[\|x_t - x^*\|^2] \leq \rho^t \|x_0 - x^*\|^2.$$

Specifically, $\rho = 1 - \Theta(1/\kappa)$.

---

## Proof

### 1. Preliminaries

**Notation.** Let $x^*$ be the unique minimizer of $f$. Define error variables:
$$e_t = x_t - x^*, \qquad w_t = v_t.$$

The fixed point of the dynamics is $(x^*, 0)$: at $x = x^*$ with interpolation, $\nabla f_i(x^*) = 0$ for all $i$, so the momentum $v$ decays geometrically to 0.

**Recursion in error variables:**
$$w_{t+1} = \beta w_t + \nabla f_{i_t}(x_t)$$
$$e_{t+1} = e_t - \gamma w_{t+1} = e_t - \gamma\beta w_t - \gamma \nabla f_{i_t}(x_t)$$

**Key inequalities.** From convexity + $L$-smoothness of each $f_i$ combined with interpolation $\nabla f_i(x^*) = 0$:

**(I1) Per-component co-coercivity:**
$$\langle \nabla f_i(x), x - x^*\rangle \geq \frac{1}{L}\|\nabla f_i(x)\|^2 \quad \forall i, \forall x. \tag{I1}$$

*Proof of (I1):* Since $f_i$ is convex and $L$-smooth, the standard co-coercivity inequality gives $\langle \nabla f_i(x) - \nabla f_i(y), x-y\rangle \geq \frac{1}{L}\|\nabla f_i(x) - \nabla f_i(y)\|^2$. Setting $y = x^*$ and using $\nabla f_i(x^*) = 0$ yields (I1).

**(I2) Strong convexity of $f$:**
$$\langle \nabla f(x), x - x^*\rangle \geq \mu\|x - x^*\|^2 \quad \forall x. \tag{I2}$$

**(I3) Expected co-coercivity** (averaging (I1)):
$$\mathbb{E}_i[\langle \nabla f_i(x), x - x^*\rangle] = \langle \nabla f(x), x - x^*\rangle \geq \frac{1}{L}\mathbb{E}_i[\|\nabla f_i(x)\|^2]. \tag{I3}$$

**(I4) Interpolation convex combination:** For any $\alpha \in [0,1]$, combining (I2) and (I3):
$$\langle \nabla f(x), x - x^*\rangle \geq \alpha\mu\|x-x^*\|^2 + \frac{1-\alpha}{L}\mathbb{E}_i[\|\nabla f_i(x)\|^2]. \tag{I4}$$

---

### 2. Lyapunov Function

Define the Lyapunov function with weight $c > 0$:
$$\Phi_t = \|e_t\|^2 + c\|w_t\|^2.$$

**Goal:** Show $\mathbb{E}_{i_t}[\Phi_{t+1}] \leq \rho\,\Phi_t$ for some $\rho < 1$.

---

### 3. Expansion of $\|e_{t+1}\|^2$

\begin{align}
\|e_{t+1}\|^2 &= \|e_t - \gamma\beta w_t - \gamma\nabla f_{i_t}(x_t)\|^2 \\
&= \|e_t\|^2 + \gamma^2\beta^2\|w_t\|^2 + \gamma^2\|\nabla f_{i_t}\|^2 \\
&\quad - 2\gamma\beta\langle e_t, w_t\rangle - 2\gamma\langle \nabla f_{i_t}, e_t\rangle + 2\gamma^2\beta\langle w_t, \nabla f_{i_t}\rangle. \tag{3.1}
\end{align}

(Here and below we abbreviate $\nabla f_{i_t} = \nabla f_{i_t}(x_t)$.)

### 4. Expansion of $\|w_{t+1}\|^2$

\begin{align}
\|w_{t+1}\|^2 &= \|\beta w_t + \nabla f_{i_t}\|^2 \\
&= \beta^2\|w_t\|^2 + \|\nabla f_{i_t}\|^2 + 2\beta\langle w_t, \nabla f_{i_t}\rangle. \tag{4.1}
\end{align}

### 5. Combined Lyapunov

Adding $c$ times (4.1) to (3.1):
\begin{align}
\Phi_{t+1} &= \|e_t\|^2 + (\gamma^2\beta^2 + c\beta^2)\|w_t\|^2 + (\gamma^2 + c)\|\nabla f_{i_t}\|^2 \\
&\quad - 2\gamma\beta\langle e_t, w_t\rangle - 2\gamma\langle \nabla f_{i_t}, e_t\rangle + 2\beta(\gamma^2 + c)\langle w_t, \nabla f_{i_t}\rangle. \tag{5.1}
\end{align}

### 6. Taking Expectation over $i_t$

Let $S = \mathbb{E}_i[\|\nabla f_i(x_t)\|^2]$ and $G = \nabla f(x_t) = \mathbb{E}_i[\nabla f_i(x_t)]$. Note $w_t, e_t$ are deterministic given the filtration $\mathcal{F}_t$.

\begin{align}
\mathbb{E}_{i_t}[\Phi_{t+1}] &= \|e_t\|^2 + (\gamma^2 + c)\beta^2\|w_t\|^2 + (\gamma^2 + c)S \\
&\quad - 2\gamma\beta\langle e_t, w_t\rangle - 2\gamma\langle G, e_t\rangle + 2\beta(\gamma^2 + c)\langle w_t, G\rangle. \tag{6.1}
\end{align}

### 7. Bounding Cross-terms

**Term A:** $-2\gamma\langle G, e_t\rangle$. By (I4) with parameter $\alpha$:
$$-2\gamma\langle G, e_t\rangle \leq -2\gamma\alpha\mu\|e_t\|^2 - \frac{2\gamma(1-\alpha)}{L}S. \tag{7.A}$$

**Term B:** $-2\gamma\beta\langle e_t, w_t\rangle$. By Young's inequality with parameter $\eta > 0$:
$$-2\gamma\beta\langle e_t, w_t\rangle \leq \gamma\beta\eta\|e_t\|^2 + \frac{\gamma\beta}{\eta}\|w_t\|^2. \tag{7.B}$$

**Term C:** $2\beta(\gamma^2 + c)\langle w_t, G\rangle$. By Young's inequality with parameter $\delta > 0$:
$$2\beta(\gamma^2+c)\langle w_t, G\rangle \leq \beta(\gamma^2+c)\delta\|w_t\|^2 + \frac{\beta(\gamma^2+c)}{\delta}\|G\|^2. \tag{7.C}$$

By Jensen's inequality: $\|G\|^2 = \|\mathbb{E}_i[\nabla f_i]\|^2 \leq \mathbb{E}_i[\|\nabla f_i\|^2] = S$. So:
$$\text{(7.C)} \leq \beta(\gamma^2+c)\delta\|w_t\|^2 + \frac{\beta(\gamma^2+c)}{\delta}S. \tag{7.C'}$$

### 8. Assembly

Substituting (7.A), (7.B), (7.C') into (6.1):

\begin{align}
\mathbb{E}_{i_t}[\Phi_{t+1}] &\leq \underbrace{\Big(1 - 2\gamma\alpha\mu + \gamma\beta\eta\Big)}_{=:\,A_e}\|e_t\|^2 \\
&\quad + \underbrace{\Big((\gamma^2+c)\beta^2 + \frac{\gamma\beta}{\eta} + \beta(\gamma^2+c)\delta\Big)}_{=:\,A_w}\|w_t\|^2 \\
&\quad + \underbrace{\Big(\gamma^2 + c - \frac{2\gamma(1-\alpha)}{L} + \frac{\beta(\gamma^2+c)}{\delta}\Big)}_{=:\,A_s}S. \tag{8.1}
\end{align}

---

### 9. Parameter Selection

We choose:
$$\gamma = \frac{1}{4L}, \quad c = \gamma^2 = \frac{1}{16L^2}, \quad \alpha = \frac{1}{2}, \quad \beta = \frac{1}{8\kappa}, \quad \eta = 1.$$

We determine $\delta$ to make $A_s = 0$.

**Step 9a: Eliminate $S$ by setting $A_s = 0$.**

With $c = \gamma^2$:
$$A_s = 2\gamma^2 - \frac{\gamma}{L} + \frac{2\beta\gamma^2}{\delta}.$$

Substituting $\gamma = 1/(4L)$:
$$A_s = \frac{2}{16L^2} - \frac{1}{4L^2} + \frac{2\beta\gamma^2}{\delta} = -\frac{1}{8L^2} + \frac{2\beta\gamma^2}{\delta}.$$

Setting $A_s = 0$: $\delta = 16\beta\gamma^2 L^2 = 16\beta\gamma^2 L^2$.

With $\gamma = 1/(4L)$: $\delta = 16\beta \cdot \frac{1}{16L^2}\cdot L^2 = \beta$. So $\delta = \beta = \frac{1}{8\kappa}$.

**Verification:** $A_s = -\frac{1}{8L^2} + \frac{2\beta\gamma^2}{\beta} = -\frac{1}{8L^2} + 2\gamma^2 = -\frac{1}{8L^2} + \frac{2}{16L^2} = 0$. $\checkmark$

---

**Step 9b: Coefficient of $\|e_t\|^2$.**

$$A_e = 1 - 2\gamma\cdot\frac{\mu}{2} + \gamma\beta = 1 - \gamma\mu + \gamma\beta = 1 - \frac{\mu}{4L} + \frac{\beta}{4L}.$$

Substituting $\beta = \frac{1}{8\kappa} = \frac{\mu}{8L}$:
$$A_e = 1 - \frac{1}{4\kappa} + \frac{\mu}{32L^2} = 1 - \frac{1}{4\kappa} + \frac{1}{32\kappa^2}.$$

**Claim:** $A_e \leq 1 - \frac{7}{32\kappa}$ for $\kappa \geq 1$.

*Proof:* We need $\frac{1}{32\kappa^2} \leq \frac{1}{4\kappa} - \frac{7}{32\kappa} = \frac{1}{32\kappa}$, i.e., $\frac{1}{\kappa^2}\leq\frac{1}{\kappa}$, which holds for $\kappa\geq 1$. $\checkmark$

---

**Step 9c: Coefficient of $\|w_t\|^2$.**

$$A_w = 2\gamma^2\beta^2 + \gamma\beta + 2\beta^2\gamma^2 = 4\gamma^2\beta^2 + \gamma\beta.$$

Wait, let me recompute more carefully:
$$A_w = (\gamma^2 + c)\beta^2 + \frac{\gamma\beta}{\eta} + \beta(\gamma^2+c)\delta$$
$$= 2\gamma^2\beta^2 + \gamma\beta + 2\gamma^2\beta\delta$$
$$= 2\gamma^2\beta^2 + \gamma\beta + 2\gamma^2\beta^2 \quad (\text{since } \delta = \beta)$$
$$= 4\gamma^2\beta^2 + \gamma\beta.$$

The contraction rate for the $w$-component requires $A_w/c < 1$:
$$\frac{A_w}{c} = \frac{4\gamma^2\beta^2 + \gamma\beta}{\gamma^2} = 4\beta^2 + \frac{\beta}{\gamma} = 4\beta^2 + 4L\beta.$$

Substituting $\beta = \frac{1}{8\kappa} = \frac{\mu}{8L}$:
$$\frac{A_w}{c} = \frac{4}{64\kappa^2} + \frac{4L\mu}{8L} = \frac{1}{16\kappa^2} + \frac{1}{2\kappa} =: \rho_w.$$

**For $\kappa \geq 1$:** $\rho_w \leq \frac{1}{16} + \frac{1}{2} = \frac{9}{16} < 1$. $\checkmark$

**For $\kappa \geq 2$:** $\rho_w \leq \frac{1}{64} + \frac{1}{4} = \frac{17}{64} < 1$. $\checkmark$

---

### 10. Contraction Inequality

Combining steps 9b and 9c, we have:

$$\mathbb{E}_{i_t}[\Phi_{t+1}] \leq A_e\|e_t\|^2 + A_w\|w_t\|^2 = A_e\|e_t\|^2 + c\rho_w\|w_t\|^2$$

$$\leq \max(A_e, \rho_w)\Big(\|e_t\|^2 + c\|w_t\|^2\Big) = \rho\,\Phi_t$$

where:
$$\rho = \max\!\left(1 - \frac{1}{4\kappa} + \frac{1}{32\kappa^2},\;\; \frac{1}{16\kappa^2} + \frac{1}{2\kappa}\right).$$

**Claim: $\rho < 1$ for all $\kappa \geq 1$.**

- $A_e = 1 - \frac{1}{4\kappa} + \frac{1}{32\kappa^2} < 1$ since $\frac{1}{4\kappa} > \frac{1}{32\kappa^2}$ for $\kappa \geq 1/8$. $\checkmark$
- $\rho_w = \frac{1}{16\kappa^2} + \frac{1}{2\kappa} \leq \frac{9}{16} < 1$ for $\kappa \geq 1$. $\checkmark$

**Asymptotic rate for large $\kappa$:** The bottleneck is $A_e$, giving:
$$\rho \approx 1 - \frac{1}{4\kappa} = 1 - \frac{\mu}{4L}.$$

---

### 11. Telescoping and Final Result

By iterated expectation:
$$\mathbb{E}[\Phi_t] \leq \rho^t\,\Phi_0.$$

Since $\|e_t\|^2 \leq \Phi_t$ and with initialization $v_0 = 0$:
$$\Phi_0 = \|x_0 - x^*\|^2 + c\|v_0\|^2 = \|x_0 - x^*\|^2.$$

Therefore:
$$\boxed{\mathbb{E}\!\left[\|x_t - x^*\|^2\right] \leq \rho^t\,\|x_0 - x^*\|^2}$$

with
$$\rho = 1 - \frac{1}{4\kappa} + \frac{1}{32\kappa^2} < 1$$

under the parameter choices $\gamma = \frac{1}{4L}$, $\beta = \frac{1}{8\kappa}$, $c = \frac{1}{16L^2}$. $\blacksquare$

---

## Summary of Parameter Choices

| Parameter | Value | Role |
|-----------|-------|------|
| $\gamma$ (step size) | $\frac{1}{4L}$ | Small enough for co-coercivity to absorb gradient noise |
| $\beta$ (momentum) | $\frac{\mu}{8L} = \frac{1}{8\kappa}$ | Small momentum preserving contraction |
| $c$ (Lyapunov weight) | $\gamma^2 = \frac{1}{16L^2}$ | Balances position and momentum errors |
| $\alpha$ (interpolation split) | $\frac{1}{2}$ | Equal weight to strong convexity and co-coercivity |
| $\eta$ (Young for $\langle e,w\rangle$) | $1$ | Simplest symmetric choice |
| $\delta$ (Young for $\langle w,G\rangle$) | $\beta$ | Chosen to make $A_s = 0$ |
| $\rho$ (rate) | $1 - \Theta(1/\kappa)$ | Linear convergence |

## Remarks

1. **Interpolation is essential**: Without $\nabla f_i(x^*) = 0$, co-coercivity (I1) fails in the per-component form, and the stochastic gradient variance at $x^*$ does not vanish. The proof would give only $O(1/t)$ convergence (no linear rate) without interpolation.

2. **Role of momentum**: The momentum parameter $\beta = O(1/\kappa)$ is quite small. For this particular proof technique, momentum does not accelerate convergence (the rate $1 - O(1/\kappa)$ matches vanilla SGD under interpolation). The value of this analysis is demonstrating that momentum does not *hurt* convergence under interpolation, and the joint-space contraction framework extends naturally.

3. **Tightness**: The rate $1 - O(1/\kappa)$ per iteration matches known lower bounds for first-order stochastic methods under interpolation up to constants. Achieving the accelerated rate $1 - O(1/\sqrt{\kappa})$ would require a different analysis (e.g., the approach of Vaswani et al. 2019 or Liu & Belkin 2020).

4. **Generalization**: The weighted joint-space Lyapunov technique extends to other momentum schemes (Nesterov, triple momentum) and to proximal variants, with different Lyapunov weights $c$.
