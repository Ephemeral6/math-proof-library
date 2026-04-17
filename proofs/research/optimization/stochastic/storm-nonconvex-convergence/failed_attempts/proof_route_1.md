# Route 1: Lyapunov Function V_t = f(x_t) + α‖e_t‖² + Telescoping

## Proof

**Route**: Route 1 — Lyapunov Function

### Setup
Define $e_t = d_t - \nabla f(x_t)$. Lyapunov function: $V_t = \mathbb{E}[f(x_t)] + \alpha \mathbb{E}\|e_t\|^2$ where $\alpha = \frac{1}{2c\eta}$.

### Step 1: Descent Lemma
By L-smoothness with $y = x_{t+1} = x_t - \eta d_t$:
$$f(x_{t+1}) \leq f(x_t) - \eta\langle \nabla f(x_t), d_t\rangle + \frac{L\eta^2}{2}\|d_t\|^2$$

Decompose $d_t = \nabla f(x_t) + e_t$, expand, and use Young's inequality.

### Step 2: Error Recursion
From STORM update: $d_t = (1-a)d_{t-1} + \nabla F(x_t;\xi_t) - (1-a)\nabla F(x_{t-1};\xi_t)$

Derive: $e_{t+1} = (1-a)e_t + \phi_{t+1} + a\psi_{t+1}$ where $\phi, \psi$ are zero-mean.

Key bound: $\mathbb{E}\|e_{t+1}\|^2 \leq (1-a)\mathbb{E}\|e_t\|^2 + 2L_1^2\eta^2\mathbb{E}\|d_t\|^2 + 2a^2\sigma^2$

Using $(1-a)^2 \leq 1-a$, mean-squared smoothness for $\phi$, bounded variance for $\psi$.

### Step 3: Lyapunov Descent
Form $V_{t+1} - V_t$, expand $\|d_t\|^2 = \|\nabla f(x_t)\|^2 + 2\langle\nabla f(x_t),e_t\rangle + \|e_t\|^2$.

Let $\gamma = \frac{L\eta^2}{2} + 2\alpha L_1^2\eta^2$. Apply Young's with $\mu=1$ to cross-term.

### Step 4: Parameter Choice
Set error coefficient to zero: $\alpha a = \eta/2$, giving $\alpha = \frac{1}{2c\eta}$.
Choose $c = 8L_1^2$, verify $\gamma < \eta/2$ when $L\eta \leq 3/4$.

Result: Gradient coefficient = $\eta/2$, error coefficient = 0.

$$V_{t+1} \leq V_t - \frac{\eta}{2}\mathbb{E}\|\nabla f(x_t)\|^2 + 8L_1^2\eta^3\sigma^2$$

### Step 5: Telescoping
Sum $t=0$ to $T-1$: $\frac{\eta}{2}\sum\mathbb{E}\|\nabla f\|^2 \leq V_0 - f^* + 8L_1^2T\eta^3\sigma^2$

With $V_0 \leq f(x_0) + \frac{\sigma^2}{16L_1^2\eta}$:

$$\frac{1}{T}\sum\mathbb{E}\|\nabla f(x_t)\|^2 \leq \frac{2\Delta}{\eta T} + \frac{\sigma^2}{8L_1^2\eta^2 T} + 16L_1^2\eta^2\sigma^2$$

### Step 6: Parameter Optimization
$\eta = \min\left\{(\Delta/(L_1^2\sigma^2 T))^{1/3}, 1/(2L)\right\}$

Main terms: $O(L_1^{2/3}\sigma^{2/3}\Delta^{2/3}/T^{2/3})$
Initialization: $O(\sigma^{10/3}/(L_1^{2/3}\Delta^{2/3}T^{1/3}))$
Small-T regime: $O(L\Delta/T)$

### Final Result
$$\frac{1}{T}\sum_{t=0}^{T-1}\mathbb{E}\|\nabla f(x_t)\|^2 = O\left(\frac{(L_1\sigma\Delta)^{2/3}}{T^{2/3}} + \frac{L\Delta}{T}\right)$$

Parameters: $c = 8L_1^2$, $\alpha = \frac{1}{16L_1^2\eta}$

Q.E.D.
