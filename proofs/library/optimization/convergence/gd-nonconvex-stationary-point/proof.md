# Proof: GD Non-Convex Stationary Point Convergence

**Theorem.** Let $f: \mathbb{R}^d \to \mathbb{R}$ be $L$-smooth (possibly non-convex) with $f^* = \inf_x f(x) > -\infty$. Gradient descent with step size $\eta = 1/L$, i.e., $x_{k+1} = x_k - \frac{1}{L}\nabla f(x_k)$, satisfies:

$$\min_{0 \leq k \leq T-1} \|\nabla f(x_k)\|^2 \leq \frac{2L(f(x_0) - f^*)}{T}$$

---

**Step 1: Descent Lemma.**

Since $f$ is $L$-smooth, we have $\|\nabla f(x) - \nabla f(y)\| \leq L\|x - y\|$ for all $x, y \in \mathbb{R}^d$.

Define $g(t) = f(x + t(y-x))$. By the fundamental theorem of calculus:

$$f(y) - f(x) - \langle \nabla f(x), y-x \rangle = \int_0^1 \langle \nabla f(x + t(y-x)) - \nabla f(x), y-x \rangle\,dt$$

By Cauchy-Schwarz and $L$-smoothness:

$$\leq \int_0^1 \|\nabla f(x + t(y-x)) - \nabla f(x)\| \cdot \|y-x\|\,dt \leq \int_0^1 Lt\|y-x\|^2\,dt = \frac{L}{2}\|y-x\|^2$$

This gives the **descent lemma**: for all $x, y \in \mathbb{R}^d$,

$$f(y) \leq f(x) + \langle \nabla f(x), y-x \rangle + \frac{L}{2}\|y-x\|^2 \tag{1}$$

**Step 2: Per-step descent bound.**

Substituting $x = x_k$, $y = x_{k+1} = x_k - \frac{1}{L}\nabla f(x_k)$ into (1):

$$f(x_{k+1}) \leq f(x_k) + \left\langle \nabla f(x_k), -\frac{1}{L}\nabla f(x_k) \right\rangle + \frac{L}{2}\left\|\frac{1}{L}\nabla f(x_k)\right\|^2$$

$$= f(x_k) - \frac{1}{L}\|\nabla f(x_k)\|^2 + \frac{1}{2L}\|\nabla f(x_k)\|^2 = f(x_k) - \frac{1}{2L}\|\nabla f(x_k)\|^2 \tag{2}$$

Rearranging: $\frac{1}{2L}\|\nabla f(x_k)\|^2 \leq f(x_k) - f(x_{k+1})$.

**Step 3: Telescoping sum.**

Summing over $k = 0, 1, \ldots, T-1$:

$$\frac{1}{2L}\sum_{k=0}^{T-1}\|\nabla f(x_k)\|^2 \leq \sum_{k=0}^{T-1}\left[f(x_k) - f(x_{k+1})\right] = f(x_0) - f(x_T)$$

Since $f(x_T) \geq f^* = \inf_x f(x)$:

$$\sum_{k=0}^{T-1}\|\nabla f(x_k)\|^2 \leq 2L(f(x_0) - f^*) \tag{3}$$

**Step 4: Minimum via averaging.**

The minimum of a finite set of non-negative numbers is at most their average:

$$\min_{0 \leq k \leq T-1}\|\nabla f(x_k)\|^2 \leq \frac{1}{T}\sum_{k=0}^{T-1}\|\nabla f(x_k)\|^2 \leq \frac{2L(f(x_0) - f^*)}{T}$$

$\blacksquare$

---

**Remarks.**

1. **Rate**: This gives $\min_k \|\nabla f(x_k)\| = O(1/\sqrt{T})$, so GD finds an $\epsilon$-stationary point in $T = O(L\Delta_f/\epsilon^2)$ iterations.

2. **No convexity**: The proof uses only $L$-smoothness and $f^* > -\infty$. Convexity is never needed.

3. **Optimal step size**: $\eta = 1/L$ maximizes the per-step descent $\eta(1 - L\eta/2)\|\nabla f\|^2$.

4. **Dimension-free**: The bound has no dependence on the dimension $d$.

5. **Constant tracing**: The factor $2L$ arises as the reciprocal of $1/(2L) = 1/L - 1/(2L)$, the coefficient from combining the linear and quadratic terms in Step 2.
