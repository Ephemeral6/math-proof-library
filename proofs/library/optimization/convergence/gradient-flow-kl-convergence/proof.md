# Gradient Flow Convergence under Kurdyka-Łojasiewicz: Proof

## Theorem

Let $f: \mathbb{R}^n \to \mathbb{R}$ be $C^1$ and let $x(t)$ be a solution of the gradient flow
$$\dot{x}(t) = -\nabla f(x(t)), \quad x(0) = x_0.$$

Suppose $x(t)$ has a limit point $x^*$ with $f(x^*) = f^*$, and that $f$ satisfies the Kurdyka-Łojasiewicz (KL) inequality near $x^*$: there exist $c > 0$, $\theta \in [0,1)$, $\eta > 0$ such that for all $x$ in a neighborhood of $x^*$ with $0 < f(x) - f^* < \eta$:
$$c(1-\theta)(f(x) - f^*)^{-\theta}\|\nabla f(x)\| \geq 1. \tag{KL}$$

Then:
1. If $\theta = 0$: the trajectory has finite length and $x(t)$ converges to $x^*$ in finite time.
2. If $\theta \in (0, 1/2]$: $f(x(t)) - f^* \leq Ce^{-\alpha t}$ for constants $C, \alpha > 0$.
3. If $\theta \in (1/2, 1)$: $f(x(t)) - f^* \leq Ct^{-1/(2\theta-1)}$ for a constant $C > 0$.

---

## Proof

### Preliminary: Energy Dissipation and the Key Differential Inequality

Define the energy $E(t) := f(x(t)) - f^* \geq 0$. Along the gradient flow:
$$\dot{E}(t) = \langle \nabla f(x(t)), \dot{x}(t) \rangle = -\|\nabla f(x(t))\|^2. \tag{1}$$

Thus $E(t)$ is non-increasing. Since $x(t)$ has limit point $x^*$, there exists $t_0 \geq 0$ such that for all $t \geq t_0$, $x(t)$ lies in the KL neighborhood and $0 < E(t) < \eta$ (unless $E(t) = 0$, in which case there is nothing to prove). All subsequent analysis holds for $t \geq t_0$.

From (KL), rearranging:
$$\|\nabla f(x(t))\| \geq \frac{E(t)^\theta}{c(1-\theta)}. \tag{2}$$

Substituting (2) into (1):
$$\dot{E}(t) \leq -\frac{E(t)^{2\theta}}{c^2(1-\theta)^2} =: -\kappa \, E(t)^{2\theta}, \tag{$\star$}$$
where $\kappa := \frac{1}{c^2(1-\theta)^2} > 0$.

### Preliminary: Finite Trajectory Length (All $\theta$)

Define the desingularizing composition $\Phi(t) := \varphi(E(t)) = c \cdot E(t)^{1-\theta}$, where $\varphi(s) = cs^{1-\theta}$.

Differentiating:
$$\dot{\Phi}(t) = c(1-\theta)E(t)^{-\theta} \cdot \dot{E}(t) = -c(1-\theta)E(t)^{-\theta}\|\nabla f(x(t))\|^2.$$

Since $\|\dot{x}(t)\| = \|\nabla f(x(t))\|$, we can write:
$$\dot{\Phi}(t) = -\underbrace{c(1-\theta)E(t)^{-\theta}\|\nabla f(x(t))\|}_{\geq 1 \text{ by (KL)}} \cdot \|\nabla f(x(t))\| \leq -\|\dot{x}(t)\|. \tag{3}$$

Integrating from $t_0$ to $T$:
$$\int_{t_0}^T \|\dot{x}(t)\| \, dt \leq \Phi(t_0) - \Phi(T) \leq \Phi(t_0) = c \cdot E(t_0)^{1-\theta} < \infty.$$

Taking $T \to \infty$:
$$\boxed{\text{Length}(x|_{[t_0,\infty)}) = \int_{t_0}^\infty \|\dot{x}(t)\| \, dt \leq c \cdot E(t_0)^{1-\theta} < \infty.} \tag{4}$$

The trajectory has finite length for every $\theta \in [0,1)$. This implies $x(t)$ converges to $x^*$ (since Cauchy sequences in $\mathbb{R}^n$ converge).

### Comparison Principle

To extract explicit rates, we compare $E(t)$ with the solution of the comparison ODE:
$$\dot{y} = -\kappa \, y^{2\theta}, \quad y(t_0) = E(t_0). \tag{C}$$

Since $g(u) = -\kappa u^{2\theta}$ is continuous and locally Lipschitz on $(0,\infty)$, and $\dot{E}(t) \leq g(E(t))$ while $\dot{y}(t) = g(y(t))$, the standard scalar comparison theorem gives:
$$E(t) \leq y(t) \quad \text{for all } t \geq t_0. \tag{5}$$

We now solve (C) explicitly for each regime.

---

### Part (1): $\theta = 0$ — Finite-Time Convergence

The comparison ODE becomes $\dot{y} = -\kappa$, with solution:
$$y(t) = E(t_0) - \kappa(t - t_0).$$

This reaches zero at $t^* := t_0 + \frac{E(t_0)}{\kappa} = t_0 + c^2 E(t_0)$.

By comparison (5): $E(t) \leq (E(t_0) - \kappa(t-t_0))_+$, so:
$$E(t) = 0 \quad \text{for all } t \geq t^*.$$

Once $E(t) = 0$, we have $f(x(t)) = f^*$. Since $x(t)$ has finite trajectory length (by (4)), it converges to a limit, and this limit must be the critical point $x^*$. For $t \geq t^*$, $\dot{x}(t) = -\nabla f(x(t))$; since $x(t)$ has converged and $f$ achieves its critical value, $\dot{x}(t) = 0$, so $x(t) = x^*$.

Combined with (4), the trajectory has finite length and converges in finite time. $\blacksquare$

---

### Part (2): $\theta \in (0, 1/2]$ — Linear (Exponential) Convergence

**Case $\theta = 1/2$**: The comparison ODE is $\dot{y} = -\kappa y$, with solution:
$$y(t) = E(t_0)\, e^{-\kappa(t-t_0)}.$$

By (5):
$$E(t) \leq E(t_0)\, e^{-\kappa(t-t_0)} = Ce^{-\alpha t}$$

where $\alpha = \kappa = \frac{4}{c^2}$ and $C = E(t_0)\,e^{\kappa t_0}$. $\blacksquare$

**Case $\theta \in (0, 1/2)$**: The exponent $2\theta \in (0,1)$. Separating variables in $\dot{y} = -\kappa y^{2\theta}$:

$$\frac{d}{dt}[y^{1-2\theta}] = (1-2\theta)\,y^{-2\theta}\,\dot{y} = -(1-2\theta)\kappa.$$

Thus $y(t)^{1-2\theta} = E(t_0)^{1-2\theta} - (1-2\theta)\kappa(t-t_0)$, and since $1-2\theta > 0$:

$$y(t) = \left[E(t_0)^{1-2\theta} - (1-2\theta)\kappa(t-t_0)\right]_+^{1/(1-2\theta)}.$$

This reaches zero at finite time $T^* = t_0 + \frac{E(t_0)^{1-2\theta}}{(1-2\theta)\kappa}$. So by (5):
$$E(t) = 0 \quad \text{for all } t \geq T^*.$$

This is **faster than exponential** (finite-time convergence). The exponential bound $E(t) \leq Ce^{-\alpha t}$ holds a fortiori: since $E(t) \leq E(t_0)$ for all $t$ and $E(t) = 0$ for $t \geq T^*$, choosing $C = E(t_0)e^{\alpha T^*}$ and any $\alpha > 0$ gives $E(t) \leq Ce^{-\alpha t}$ for all $t \geq t_0$. $\blacksquare$

---

### Part (3): $\theta \in (1/2, 1)$ — Polynomial Convergence

Let $\gamma := 2\theta - 1 \in (0, 1)$. Separating variables in $\dot{y} = -\kappa y^{1+\gamma}$:

$$\frac{d}{dt}[y^{-\gamma}] = -\gamma \, y^{-\gamma-1}\,\dot{y} = \gamma\kappa\,y^{-\gamma-1}\,y^{1+\gamma} = \gamma\kappa.$$

Thus:
$$y(t)^{-\gamma} = E(t_0)^{-\gamma} + \gamma\kappa(t-t_0).$$

Solving for $y$:
$$y(t) = \left[E(t_0)^{-\gamma} + \gamma\kappa(t-t_0)\right]^{-1/\gamma}. \tag{6}$$

By (5):
$$E(t) \leq \left[E(t_0)^{-\gamma} + \gamma\kappa(t-t_0)\right]^{-1/\gamma}.$$

For $t \geq 2t_0$ (assuming $t_0 > 0$), $t - t_0 \geq t/2$, so:
$$E(t) \leq \left[\gamma\kappa \cdot \frac{t}{2}\right]^{-1/\gamma} = \left(\frac{2}{\gamma\kappa}\right)^{1/\gamma} t^{-1/\gamma}.$$

Recalling $\gamma = 2\theta - 1$ and $\kappa = \frac{1}{c^2(1-\theta)^2}$:

$$f(x(t)) - f^* \leq C\,t^{-1/(2\theta-1)}$$

where $C = \left(\frac{2c^2(1-\theta)^2}{2\theta-1}\right)^{1/(2\theta-1)}$, valid for all sufficiently large $t$. $\blacksquare$

---

## Summary Table

| KL exponent $\theta$ | Comparison ODE solution | Energy decay rate |
|---|---|---|
| $\theta = 0$ | $y = (y_0 - \kappa t)_+$ | **Finite time**: $E(t) = 0$ for $t \geq c^2 E_0$ |
| $\theta \in (0, 1/2)$ | $y = [y_0^{1-2\theta} - (1-2\theta)\kappa t]_+^{1/(1-2\theta)}$ | **Finite time** (faster than exponential) |
| $\theta = 1/2$ | $y = y_0 e^{-\kappa t}$ | **Exponential**: $E(t) \leq Ce^{-4t/c^2}$ |
| $\theta \in (1/2, 1)$ | $y = [y_0^{-(2\theta-1)} + (2\theta-1)\kappa t]^{-1/(2\theta-1)}$ | **Polynomial**: $E(t) \leq Ct^{-1/(2\theta-1)}$ |
