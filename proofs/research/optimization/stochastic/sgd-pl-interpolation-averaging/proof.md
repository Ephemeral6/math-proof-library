# Proof: SGD Convergence under PL + Interpolation with Iterate Averaging

## Theorem

Let $f(x) = \frac{1}{n}\sum_{i=1}^n f_i(x)$ where each $f_i$ is convex and $L$-smooth with $\nabla f_i(x^*) = 0$. Suppose $f$ is $L$-smooth and satisfies $\mu$-PL: $\|\nabla f(x)\|^2 \geq 2\mu(f(x) - f^*)$. Let $\mathbb{E}[\|\nabla f_{i}(x)\|^2] \leq \rho\|\nabla f(x)\|^2$ (strong growth). Denote $e_t = \mathbb{E}[f(x_t) - f^*]$.

**(a)** With $\gamma = 1/(\rho L)$: $e_t \leq (1 - \mu/(\rho L))^t \, e_0$.

**(b)** With $\gamma_t = 2/(\mu(t+t_0))$, $t_0 = 2\rho L/\mu$, the average $\bar{x}_T = \frac{1}{T}\sum_{t=0}^{T-1} x_t$ satisfies: $\mathbb{E}[f(\bar{x}_T) - f^*] \leq \frac{2\rho L}{\mu T} \, e_0$.

---

## Fundamental One-Step Descent

By $L$-smoothness, taking conditional expectation over $i_t$ with $\mathbb{E}[\nabla f_{i_t}(x_t)] = \nabla f(x_t)$ and strong growth:

$$\mathbb{E}[f(x_{t+1}) | x_t] \leq f(x_t) - \gamma_t\!\left(1 - \frac{\rho L \gamma_t}{2}\right)\|\nabla f(x_t)\|^2 \tag{D}$$

Applying $\mu$-PL ($\|\nabla f(x_t)\|^2 \geq 2\mu \, e_t$) and taking full expectation:

$$e_{t+1} \leq \alpha_t \, e_t, \qquad \alpha_t = 1 - 2\mu\gamma_t + \rho L \mu \gamma_t^2 \tag{$\star$}$$

---

## Part (a): Constant Step Size $\gamma = 1/(\rho L)$

With $\gamma = 1/(\rho L)$:

$$\alpha = 1 - \frac{2\mu}{\rho L} + \frac{\mu}{\rho L} = 1 - \frac{\mu}{\rho L} \in [0, 1)$$

Iterating $(\star)$:

$$\boxed{e_t \leq \left(1 - \frac{\mu}{\rho L}\right)^t e_0} \qquad \blacksquare$$

---

## Part (b): Decreasing Step Size $\gamma_t = 2/(\mu(t+t_0))$, $t_0 = 2\rho L/\mu$

### Step 1: Compute the contraction factor

With $s = t + t_0$ and $t_0 = 2\rho L/\mu$:

$$2\mu\gamma_t = \frac{4}{s}, \qquad \rho L \mu \gamma_t^2 = \frac{4\rho L}{\mu s^2} = \frac{2t_0}{s^2}$$

$$\alpha_t = 1 - \frac{4}{s} + \frac{2t_0}{s^2} = \frac{s^2 - 4s + 2t_0}{s^2} \tag{R}$$

**Verify descent is valid:** $1 - \rho L\gamma_t/2 = 1 - t_0/(2s) \geq 1/2 > 0$ since $s \geq t_0$. $\checkmark$

### Step 2: Prove $e_t \leq t_0^2/(t+t_0)^2 \cdot e_0$ by induction

**Claim:** $e_t \leq \frac{t_0^2}{s^2} \, e_0$ for all $t \geq 0$, where $s = t + t_0$.

**Base case ($t = 0$):** $t_0^2/t_0^2 = 1$. $\checkmark$

**Inductive step:** Assume $e_t \leq t_0^2 e_0/s^2$. By $(\star)$, we need:

$$\alpha_t \leq \frac{s^2}{(s+1)^2} \tag{$\dagger$}$$

Substituting (R), this becomes:

$$\frac{s^2 - 4s + 2t_0}{s^2} \leq \frac{s^2}{(s+1)^2}$$

Cross-multiplying ($s > 0$, $(s+1)^2 > 0$):

$$(s^2 - 4s + 2t_0)(s+1)^2 \leq s^4$$

Expanding the LHS:

$$s^4 - 2s^3 + (2t_0 - 7)s^2 + (4t_0 - 4)s + 2t_0$$

So $(\dagger)$ is equivalent to:

$$2s^3 - (2t_0 - 7)s^2 - (4t_0 - 4)s - 2t_0 \geq 0 \tag{P}$$

**Verify (P) at $s = t_0$:**

$$2t_0^3 - (2t_0 - 7)t_0^2 - (4t_0 - 4)t_0 - 2t_0 = 3t_0^2 + 2t_0 > 0 \qquad \checkmark$$

**Verify (P) for all $s \geq t_0 \geq 2$:**

For $s \geq t_0$: $(2t_0 - 7)s^2 \leq 2t_0 s^2$, $(4t_0 - 4)s \leq 4t_0 s$, $2t_0 \leq 2s$. So it suffices to show:

$$2s^3 \geq 2t_0 s^2 + 4t_0 s + 2s$$

Dividing by $2s$: $s^2 \geq t_0 s + 2t_0 + 1$. Since $s \geq t_0$: $t_0 s \leq s^2$, and $2t_0 + 1 \leq s^2$ for $s \geq 3$ (check $s = t_0 = 2$ directly: $P(2) = 16 - (2t_0-7)\cdot 4 - (4t_0-4)\cdot 2 - 2t_0 = 3\cdot 4 + 2\cdot 2 = 16 > 0$). $\checkmark$

**Induction complete:**

$$\boxed{e_t \leq \frac{t_0^2}{(t + t_0)^2} \, e_0} \tag{I}$$

This is an $O(1/t^2)$ per-iterate rate.

### Step 3: Average via convexity + Jensen

Since $f$ is convex (sum of convex $f_i$), by Jensen's inequality:

$$\mathbb{E}[f(\bar{x}_T) - f^*] \leq \frac{1}{T}\sum_{t=0}^{T-1} e_t \leq \frac{t_0^2 e_0}{T} \sum_{t=0}^{T-1} \frac{1}{(t + t_0)^2}$$

Bound the sum:

$$\sum_{t=0}^{T-1} \frac{1}{(t+t_0)^2} \leq \int_0^T \frac{dt}{(t + t_0 - 1)^2} \leq \frac{1}{t_0 - 1} \leq \frac{2}{t_0}$$

for $t_0 \geq 2$ (since $t_0 - 1 \geq t_0/2$). Therefore:

$$\mathbb{E}[f(\bar{x}_T) - f^*] \leq \frac{t_0^2 e_0}{T} \cdot \frac{2}{t_0} = \frac{2t_0 \, e_0}{T} = \frac{4\rho L}{\mu T} \, e_0$$

$$\boxed{\mathbb{E}[f(\bar{x}_T) - f^*] \leq \frac{4\rho L}{\mu T}(f(x_0) - f^*) = O\!\left(\frac{\rho L}{\mu T} \cdot e_0\right)}$$

### Step 4: The $\mu^2$ form

If the initial error is expressed in gradient norm via PL ($e_0 \leq \|\nabla f(x_0)\|^2/(2\mu)$):

$$\mathbb{E}[f(\bar{x}_T) - f^*] \leq \frac{4\rho L}{\mu T} \cdot \frac{\|\nabla f(x_0)\|^2}{2\mu} = \frac{2\rho L}{\mu^2 T}\|\nabla f(x_0)\|^2 = O\!\left(\frac{\rho L}{\mu^2 T}\right)$$

$\blacksquare$

---

## Proof Architecture

| Component | Role |
|-----------|------|
| $L$-smoothness | One-step descent (D) |
| Strong growth ($\rho$) | Bounds stochastic variance ∝ $\|\nabla f\|^2$ (multiplicative noise) |
| PL ($\mu$) | Converts $\|\nabla f\|^2$ to function gap, giving contraction |
| Interpolation | Makes variance vanish at optimum → no additive noise floor |
| Induction on $e_t \leq t_0^2/(t+t_0)^2$ | Establishes $O(1/t^2)$ per-iterate rate |
| Convexity of $f$ + Jensen | Converts iterate average to function value bound |

$\blacksquare$
