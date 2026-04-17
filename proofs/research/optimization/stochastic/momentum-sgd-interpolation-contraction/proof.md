# Proof: SGD with Polyak Momentum Converges Linearly under Interpolation

## Setup

Let $f = \frac{1}{n}\sum_{i=1}^n f_i$, each $f_i$ convex and $L$-smooth, $f$ $\mu$-strongly convex, $\kappa = L/\mu$. Interpolation: $\nabla f_i(x^*) = 0$ for all $i$. SGD with momentum ($v_0 = 0$):

$$v_{t+1} = \beta v_t + \nabla f_{i_t}(x_t), \quad x_{t+1} = x_t - \gamma v_{t+1}.$$

Define $e_t = x_t - x^*$, $g_t = \nabla f_{i_t}(x_t)$, $G_t = \nabla f(x_t)$, $S_t = \mathbb{E}_i[\|\nabla f_i(x_t)\|^2]$.

## Key Inequalities

**(I1) Per-component co-coercivity.** Since each $f_i$ is convex, $L$-smooth, and $\nabla f_i(x^*) = 0$:
$$\langle \nabla f_i(x), x - x^*\rangle \geq \frac{1}{L}\|\nabla f_i(x)\|^2.$$

*Proof.* By convexity: $f_i(x^*) \geq f_i(x) + \langle \nabla f_i(x), x^* - x\rangle$. By $L$-smoothness and interpolation: $f_i(x) \geq f_i(x^*) + \frac{1}{2L}\|\nabla f_i(x)\|^2$. Combining gives (I1). $\square$

**(I2) Strong convexity.** $\langle G_t, e_t\rangle \geq \mu\|e_t\|^2$.

**(I3) Averaged co-coercivity.** Averaging (I1): $\langle G_t, e_t\rangle \geq \frac{S_t}{L}$.

**(I4) Interpolated bound.** For any $\alpha \in [0,1]$, taking convex combination of (I2) and (I3):
$$\langle G_t, e_t\rangle \geq \alpha\mu\|e_t\|^2 + \frac{1-\alpha}{L}S_t.$$

## Lyapunov Function

$$\Phi_t = \|e_t\|^2 + \gamma^2\|v_t\|^2.$$

## One-Step Expansion

Since $e_{t+1} = e_t - \gamma v_{t+1}$:

$$\|e_{t+1}\|^2 = \|e_t\|^2 - 2\gamma\langle e_t, v_{t+1}\rangle + \gamma^2\|v_{t+1}\|^2$$

Adding $\gamma^2\|v_{t+1}\|^2$:

$$\Phi_{t+1} = \|e_t\|^2 - 2\gamma\langle e_t, v_{t+1}\rangle + 2\gamma^2\|v_{t+1}\|^2.$$

Expanding $v_{t+1} = \beta v_t + g_t$:

$$\Phi_{t+1} = \|e_t\|^2 - 2\gamma\beta\langle e_t, v_t\rangle - 2\gamma\langle e_t, g_t\rangle + 2\gamma^2\beta^2\|v_t\|^2 + 2\gamma^2\|g_t\|^2 + 4\gamma^2\beta\langle v_t, g_t\rangle.$$

Taking conditional expectation $\mathbb{E}_t$:

$$\mathbb{E}_t[\Phi_{t+1}] = \|e_t\|^2 - 2\gamma\beta\langle e_t, v_t\rangle - 2\gamma\langle e_t, G_t\rangle + 2\gamma^2\beta^2\|v_t\|^2 + 2\gamma^2 S_t + 4\gamma^2\beta\langle v_t, G_t\rangle. \tag{$\star$}$$

## Bounding Cross Terms

**Gradient term.** Apply (I4) with $\alpha = 1/2$:
$$-2\gamma\langle e_t, G_t\rangle \leq -\gamma\mu\|e_t\|^2 - \frac{\gamma}{L}S_t.$$

**Position-velocity cross term.** Young's inequality with $\eta = 1$:
$$-2\gamma\beta\langle e_t, v_t\rangle \leq \gamma\beta\|e_t\|^2 + \gamma\beta\|v_t\|^2.$$

**Velocity-gradient cross term.** Young's inequality with parameter $\delta = \beta$:
$$4\gamma^2\beta\langle v_t, G_t\rangle \leq 2\gamma^2\beta^2\|v_t\|^2 + 2\gamma^2\|G_t\|^2 \leq 2\gamma^2\beta^2\|v_t\|^2 + 2\gamma^2 S_t$$
where $\|G_t\|^2 \leq S_t$ by Jensen's inequality.

## Assembly

Substituting into ($\star$):

$$\mathbb{E}_t[\Phi_{t+1}] \leq \underbrace{(1 - \gamma\mu + \gamma\beta)}_{A_e}\|e_t\|^2 + \underbrace{(4\gamma^2\beta^2 + \gamma\beta)}_{A_v}\|v_t\|^2 + \underbrace{(4\gamma^2 - \gamma/L)}_{A_S}\,S_t.$$

**Coefficient tracking:**
- $\|e_t\|^2$: $1$ (original) $- \gamma\mu$ (from I4) $+ \gamma\beta$ (from Young's).
- $\|v_t\|^2$: $2\gamma^2\beta^2$ (original) $+ \gamma\beta$ (from Young's) $+ 2\gamma^2\beta^2$ (from Young's) $= 4\gamma^2\beta^2 + \gamma\beta$.
- $S_t$: $2\gamma^2$ (original) $- \gamma/L$ (from I4) $+ 2\gamma^2$ (from Young's) $= 4\gamma^2 - \gamma/L$.

## Parameter Choice and Verification

**Step size $\gamma = \frac{1}{4L}$** makes the variance coefficient vanish:
$$A_S = \frac{4}{16L^2} - \frac{1}{4L^2} = 0. \qquad \checkmark$$

**Momentum $\beta = \frac{\mu}{8L} = \frac{1}{8\kappa}$.**

**Checking $A_e < 1$:**
$$A_e = 1 - \frac{\mu}{4L} + \frac{\mu}{4L}\cdot\frac{\mu}{8L} = 1 - \frac{1}{4\kappa} + \frac{1}{32\kappa^2} = 1 - \frac{8\kappa - 1}{32\kappa^2} < 1. \qquad \checkmark$$

**Checking $A_v < c = \gamma^2 = \frac{1}{16L^2}$:**
$$\frac{A_v}{c} = 4\beta^2 + \frac{\beta}{\gamma} = 4\cdot\frac{\mu^2}{64L^2} + 4L\cdot\frac{\mu}{8L} = \frac{1}{16\kappa^2} + \frac{1}{2\kappa} \leq \frac{9}{16} < 1. \qquad \checkmark$$

## Contraction

With $\rho = \max(A_e, A_v/c)$:

Since $A_e = 1 - \frac{1}{4\kappa} + \frac{1}{32\kappa^2} \geq \frac{3}{4}$ and $\frac{A_v}{c} \leq \frac{9}{16} < \frac{3}{4}$ for all $\kappa \geq 1$:

$$\rho = A_e = 1 - \frac{1}{4\kappa} + \frac{1}{32\kappa^2} < 1.$$

The Lyapunov recursion gives $A_e\|e_t\|^2 \leq \rho\|e_t\|^2$ and $A_v\|v_t\|^2 \leq (A_v/c) \cdot c\|v_t\|^2 \leq \rho \cdot c\|v_t\|^2$, so:

$$\mathbb{E}_t[\Phi_{t+1}] \leq \rho\,\Phi_t.$$

## Conclusion

By the tower property and induction: $\mathbb{E}[\Phi_t] \leq \rho^t \Phi_0$.

Since $v_0 = 0$: $\Phi_0 = \|x_0 - x^*\|^2$. Since $\|e_t\|^2 \leq \Phi_t$:

$$\boxed{\mathbb{E}[\|x_t - x^*\|^2] \leq \left(1 - \frac{1}{4\kappa} + \frac{1}{32\kappa^2}\right)^t \|x_0 - x^*\|^2.} \qquad \blacksquare$$
