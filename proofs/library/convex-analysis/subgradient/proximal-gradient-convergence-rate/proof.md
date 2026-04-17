# Proof: Proximal Gradient Method O(1/T) Convergence

## Theorem

Let $f: \mathbb{R}^d \to \mathbb{R}$ be convex and $L$-smooth, $g: \mathbb{R}^d \to \mathbb{R} \cup \{+\infty\}$ be convex, proper, and lower semi-continuous. Define $F = f + g$ and let $x^*$ minimize $F$. The proximal gradient iterates

$$x_{t+1} = \mathrm{prox}_{(1/L)g}\!\left(x_t - \tfrac{1}{L}\nabla f(x_t)\right)$$

satisfy:

$$F(x_T) - F(x^*) \leq \frac{L\|x_0 - x^*\|^2}{2T}$$

## Preliminary Lemmas

**Lemma 1 (Descent Lemma).** If $f$ is convex and $L$-smooth, then for all $x, y$:
$$f(y) \leq f(x) + \langle \nabla f(x), y - x \rangle + \frac{L}{2}\|y - x\|^2$$

**Lemma 2 (Convexity of $f$).** For all $x, y$:
$$f(y) \geq f(x) + \langle \nabla f(x), y - x \rangle$$

**Lemma 3 (Proximal Optimality).** $z = \mathrm{prox}_{\eta g}(v)$ iff $\frac{1}{\eta}(v - z) \in \partial g(z)$, i.e., for all $u$:
$$g(u) \geq g(z) + \langle \tfrac{1}{\eta}(v - z), u - z \rangle$$

## Proof

### Setup

Define the **gradient mapping** $G_t = L(x_t - x_{t+1})$ and the **Lyapunov potential**:
$$\Phi_t = \frac{L}{2}\|x_t - x^*\|^2$$

By Lemma 3 with $\eta = 1/L$, $v = x_t - \frac{1}{L}\nabla f(x_t)$, $z = x_{t+1}$:
$$G_t - \nabla f(x_t) \in \partial g(x_{t+1}) \tag{0}$$

### Step 1: Upper bound on $F(x_{t+1})$

**Bound on $f(x_{t+1})$.** Apply Lemma 1 at $x = x_t$, $y = x_{t+1}$. Since $x_{t+1} - x_t = -\frac{1}{L}G_t$:

$$f(x_{t+1}) \leq f(x_t) - \frac{1}{L}\langle \nabla f(x_t), G_t \rangle + \frac{1}{2L}\|G_t\|^2 \tag{1}$$

**Bound on $g(x^*)$.** From (0) and the subgradient inequality at $u = x^*$:

$$g(x^*) \geq g(x_{t+1}) + \langle G_t - \nabla f(x_t), x^* - x_{t+1} \rangle \tag{2}$$

**Bound on $f(x^*)$.** By convexity (Lemma 2):

$$f(x^*) \geq f(x_t) + \langle \nabla f(x_t), x^* - x_t \rangle \tag{3}$$

Add (2) and (3):

$$F(x^*) \geq f(x_t) + g(x_{t+1}) + \langle \nabla f(x_t), x^* - x_t \rangle + \langle G_t - \nabla f(x_t), x^* - x_{t+1} \rangle$$

Expand using $x^* - x_t = (x^* - x_{t+1}) + (x_{t+1} - x_t) = (x^* - x_{t+1}) - \frac{1}{L}G_t$:

$$\langle \nabla f(x_t), x^* - x_t \rangle + \langle G_t - \nabla f(x_t), x^* - x_{t+1} \rangle$$
$$= \langle \nabla f(x_t), (x^* - x_{t+1}) - \tfrac{1}{L}G_t \rangle + \langle G_t - \nabla f(x_t), x^* - x_{t+1} \rangle$$
$$= \langle G_t, x^* - x_{t+1} \rangle - \frac{1}{L}\langle \nabla f(x_t), G_t \rangle$$

Combining with (1), we get:

$$F(x^*) \geq f(x_t) + g(x_{t+1}) + \langle G_t, x^* - x_{t+1} \rangle - \frac{1}{L}\langle \nabla f(x_t), G_t \rangle$$

$$\geq \left(f(x_{t+1}) - \frac{1}{2L}\|G_t\|^2\right) + g(x_{t+1}) + \langle G_t, x^* - x_{t+1} \rangle$$

where we used $f(x_t) - \frac{1}{L}\langle \nabla f(x_t), G_t \rangle \geq f(x_{t+1}) - \frac{1}{2L}\|G_t\|^2$ from rearranging (1).

Therefore:

$$F(x_{t+1}) - F(x^*) \leq \frac{1}{2L}\|G_t\|^2 + \langle G_t, x_{t+1} - x^* \rangle \tag{A}$$

### Step 2: Lyapunov decrease equals the same expression

Compute $\Phi_t - \Phi_{t+1}$ using $x_t = x_{t+1} + \frac{1}{L}G_t$:

$$\|x_t - x^*\|^2 = \|x_{t+1} - x^* + \tfrac{1}{L}G_t\|^2 = \|x_{t+1} - x^*\|^2 + \frac{2}{L}\langle G_t, x_{t+1} - x^* \rangle + \frac{1}{L^2}\|G_t\|^2$$

Therefore:

$$\Phi_t - \Phi_{t+1} = \frac{L}{2}\left(\frac{2}{L}\langle G_t, x_{t+1} - x^* \rangle + \frac{1}{L^2}\|G_t\|^2\right) = \langle G_t, x_{t+1} - x^* \rangle + \frac{1}{2L}\|G_t\|^2 \tag{B}$$

### Step 3: The key observation

Comparing (A) and (B), the right-hand sides are **identical**:

$$\boxed{F(x_{t+1}) - F(x^*) \leq \Phi_t - \Phi_{t+1} = \frac{L}{2}\|x_t - x^*\|^2 - \frac{L}{2}\|x_{t+1} - x^*\|^2} \tag{C}$$

### Step 4: Monotone decrease of $F(x_t)$

Setting $x^* = x_t$ in inequality (A) (which holds for any $y$ in place of $x^*$ by the same argument):

$$F(x_{t+1}) - F(x_t) \leq \frac{1}{2L}\|G_t\|^2 + \langle G_t, x_{t+1} - x_t \rangle = \frac{1}{2L}\|G_t\|^2 - \frac{1}{L}\|G_t\|^2 = -\frac{1}{2L}\|G_t\|^2 \leq 0$$

So $\{F(x_t)\}$ is non-increasing: $F(x_T) \leq F(x_{t+1})$ for all $t \leq T-1$.

### Step 5: Telescope

Sum (C) from $t = 0$ to $T - 1$:

$$\sum_{t=0}^{T-1} \left(F(x_{t+1}) - F(x^*)\right) \leq \Phi_0 - \Phi_T \leq \Phi_0 = \frac{L}{2}\|x_0 - x^*\|^2$$

By monotonicity (Step 4), each summand satisfies $F(x_{t+1}) - F(x^*) \geq F(x_T) - F(x^*)$:

$$T \cdot \left(F(x_T) - F(x^*)\right) \leq \frac{L}{2}\|x_0 - x^*\|^2$$

$$\boxed{F(x_T) - F(x^*) \leq \frac{L\|x_0 - x^*\|^2}{2T}} \qquad \blacksquare$$
