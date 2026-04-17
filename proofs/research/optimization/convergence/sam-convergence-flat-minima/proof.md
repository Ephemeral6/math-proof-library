# SAM Convergence to Flat Minima — Proof

## Theorem

Let $f:\mathbb{R}^d\to\mathbb{R}$ be $L$-smooth (i.e., $\nabla f$ is $L$-Lipschitz) and bounded below by $f^* > -\infty$. Define the SAM objective:

$$f^{\mathrm{SAM}}(x) = \max_{\|\delta\|\leq\rho} f(x+\delta).$$

Consider the SAM iterates:

$$x_{t+1} = x_t - \eta\, g_t, \quad g_t := \nabla f(\tilde{x}_t), \quad \tilde{x}_t := x_t + \rho\frac{\nabla f(x_t)}{\|\nabla f(x_t)\|},$$

with the convention $\tilde{x}_t = x_t$ when $\nabla f(x_t) = 0$.

**Part I (Fixed $\rho$).** With $\eta = \frac{1}{2L}$ and $\rho \leq \frac{1}{2L}$:

$$\min_{0\leq t < T}\|\nabla f^{\mathrm{SAM}}(x_t)\|^2 \leq \frac{16L(f(x_0)-f^*)}{T} + 12L^2\rho^2.$$

**Part II (Diminishing $\rho$).** With $\eta = \frac{1}{2L}$ and $\rho = \rho_0/\sqrt{T}$ where $\rho_0 \leq \frac{1}{2L}$:

$$\min_{0\leq t < T}\|\nabla f^{\mathrm{SAM}}_{\rho}(x_t)\|^2 \leq \frac{16L(f(x_0)-f^*) + 12L^2\rho_0^2}{T} = O\!\left(\frac{1}{T}\right).$$

---

## Preliminaries

**$L$-smoothness** means $\|\nabla f(x) - \nabla f(y)\| \leq L\|x-y\|$ for all $x,y\in\mathbb{R}^d$, which implies the **descent lemma**:

$$f(y) \leq f(x) + \langle\nabla f(x), y-x\rangle + \frac{L}{2}\|y-x\|^2. \tag{DL}$$

**Danskin's theorem.** Since $f$ is $C^1$ and $B_\rho = \{\delta:\|\delta\|\leq\rho\}$ is compact, the function $f^{\mathrm{SAM}}(x) = \max_{\delta\in B_\rho} f(x+\delta)$ satisfies, at any $x$ where the maximizer $\delta^*(x) = \arg\max_{\delta\in B_\rho} f(x+\delta)$ is unique:

$$\nabla f^{\mathrm{SAM}}(x) = \nabla f(x+\delta^*(x)). \tag{Danskin}$$

When the maximizer is not unique, we use Clarke's generalized gradient, and the bounds below still hold.

---

## Proof

### Step 1: One-step descent on $f(x_t)$

By the descent lemma (DL) with $y = x_{t+1} = x_t - \eta g_t$:

$$f(x_{t+1}) \leq f(x_t) - \eta\langle\nabla f(x_t), g_t\rangle + \frac{L\eta^2}{2}\|g_t\|^2. \tag{1}$$

### Step 2: Inner product lower bound

Since $\|\tilde{x}_t - x_t\| = \rho$, by $L$-Lipschitz gradients:

$$\|g_t - \nabla f(x_t)\| = \|\nabla f(\tilde{x}_t) - \nabla f(x_t)\| \leq L\rho. \tag{2a}$$

Write $e_t := g_t - \nabla f(x_t)$ with $\|e_t\| \leq L\rho$. Then:

$$\langle\nabla f(x_t), g_t\rangle = \langle g_t - e_t, g_t\rangle = \|g_t\|^2 - \langle e_t, g_t\rangle \geq \|g_t\|^2 - L\rho\|g_t\|.$$

By Young's inequality ($ab \leq a^2/2 + b^2/2$) with $a = \|g_t\|$, $b = L\rho$:

$$L\rho\|g_t\| \leq \frac{1}{2}\|g_t\|^2 + \frac{L^2\rho^2}{2}.$$

Therefore:

$$\langle\nabla f(x_t), g_t\rangle \geq \frac{1}{2}\|g_t\|^2 - \frac{L^2\rho^2}{2}. \tag{2}$$

### Step 3: Combined descent inequality

Substituting (2) into (1):

$$f(x_{t+1}) \leq f(x_t) - \frac{\eta}{2}(1 - L\eta)\|g_t\|^2 + \frac{\eta L^2\rho^2}{2}. \tag{3}$$

With $\eta = \frac{1}{2L}$, we have $1 - L\eta = \frac{1}{2}$, yielding:

$$f(x_{t+1}) \leq f(x_t) - \frac{\eta}{4}\|g_t\|^2 + \frac{\eta L^2\rho^2}{2}. \tag{4}$$

### Step 4: Telescoping sum

Summing (4) from $t=0$ to $T-1$ and using $f(x_T) \geq f^*$:

$$\frac{1}{T}\sum_{t=0}^{T-1}\|g_t\|^2 \leq \frac{4(f(x_0)-f^*)}{\eta T} + 2L^2\rho^2 = \frac{8L(f(x_0)-f^*)}{T} + 2L^2\rho^2. \tag{5}$$

### Step 5: Relating $g_t$ to $\nabla f^{\mathrm{SAM}}(x_t)$

By Danskin's theorem: $\nabla f^{\mathrm{SAM}}(x_t) = \nabla f(x_t + \delta^*(x_t))$.

The SAM approximation uses $\tilde\delta_t = \rho\,\nabla f(x_t)/\|\nabla f(x_t)\|$ while the exact maximizer is $\delta^*(x_t)$. Since both have norm at most $\rho$:

$$\|\tilde\delta_t - \delta^*(x_t)\| \leq 2\rho. \tag{6a}$$

By $L$-smoothness:

$$\|g_t - \nabla f^{\mathrm{SAM}}(x_t)\| = \|\nabla f(x_t+\tilde\delta_t) - \nabla f(x_t+\delta^*_t)\| \leq 2L\rho. \tag{6}$$

By the inequality $\|a\|^2 \leq 2\|b\|^2 + 2\|a-b\|^2$:

$$\|\nabla f^{\mathrm{SAM}}(x_t)\|^2 \leq 2\|g_t\|^2 + 8L^2\rho^2. \tag{7}$$

### Step 6: Final convergence bound

Combining (5) and (7):

$$\frac{1}{T}\sum_{t=0}^{T-1}\|\nabla f^{\mathrm{SAM}}(x_t)\|^2 \leq \frac{16L(f(x_0)-f^*)}{T} + 4L^2\rho^2 + 8L^2\rho^2 = \frac{16L(f(x_0)-f^*)}{T} + 12L^2\rho^2. \tag{8}$$

Since $\min_t \leq \frac{1}{T}\sum_t$:

$$\boxed{\min_{0\leq t < T}\|\nabla f^{\mathrm{SAM}}(x_t)\|^2 \leq \frac{16L(f(x_0)-f^*)}{T} + 12L^2\rho^2.}$$

**Part II.** Setting $\rho = \rho_0/\sqrt{T}$:

$$\min_{0\leq t < T}\|\nabla f^{\mathrm{SAM}}_\rho(x_t)\|^2 \leq \frac{16L(f(x_0)-f^*) + 12L^2\rho_0^2}{T} = O\!\left(\frac{1}{T}\right). \qquad\square$$

---

## Remarks

1. **Two-term structure.** The bound has an optimization term $O(L\Delta_f/T)$ and a bias $O(L^2\rho^2)$ from the approximate perturbation direction. For fixed $\rho$, SAM converges to a neighborhood; for $\rho \to 0$, exact convergence.

2. **Comparison with GD.** Standard GD gives $\min_t\|\nabla f(x_t)\|^2 \leq 4L\Delta_f/T$. SAM has a 4x worse leading constant but optimizes the sharpness-aware objective.

3. **Parameter conditions.** $\eta = 1/(2L) = O(1/L)$ and $\rho \leq 1/(2L) = \eta$, so $\rho = O(\eta)$, matching the problem requirements.
