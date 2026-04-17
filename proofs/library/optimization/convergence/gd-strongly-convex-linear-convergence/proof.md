# Proof: Gradient Descent Linear Convergence for Strongly Convex Functions

## Setup and Definitions

Let $f: \mathbb{R}^d \to \mathbb{R}$ be $\mu$-strongly convex and $L$-smooth, with $0 < \mu \leq L$. Let $x^* = \arg\min_x f(x)$ (unique by strong convexity). Consider gradient descent with step size $\eta = 1/L$:

$$x_{k+1} = x_k - \frac{1}{L}\nabla f(x_k).$$

**Definitions used**:
- **$L$-smoothness**: $\|\nabla f(x) - \nabla f(y)\| \leq L\|x - y\|$ for all $x, y$. Equivalently: $f(y) \leq f(x) + \langle \nabla f(x), y-x \rangle + \frac{L}{2}\|y-x\|^2$.
- **$\mu$-strong convexity**: $f(y) \geq f(x) + \langle \nabla f(x), y - x \rangle + \frac{\mu}{2}\|y - x\|^2$ for all $x, y$.

---

## Part (a): Function Value Convergence

$$f(x_k) - f(x^*) \leq \left(1 - \frac{\mu}{L}\right)^k (f(x_0) - f(x^*)).$$

### Step 1: Descent Lemma

**Claim**: $f(x_{k+1}) \leq f(x_k) - \frac{1}{2L}\|\nabla f(x_k)\|^2$.

**Proof**: By $L$-smoothness:
$$f(y) \leq f(x) + \langle \nabla f(x), y - x \rangle + \frac{L}{2}\|y - x\|^2.$$

This is derived by integrating the Lipschitz gradient condition:
$$f(y) - f(x) = \int_0^1 \langle \nabla f(x + t(y-x)), y - x \rangle \, dt$$
$$= \langle \nabla f(x), y-x \rangle + \int_0^1 \langle \nabla f(x + t(y-x)) - \nabla f(x), y-x \rangle \, dt$$
$$\leq \langle \nabla f(x), y-x \rangle + \int_0^1 Lt\|y-x\|^2 \, dt = \langle \nabla f(x), y-x \rangle + \frac{L}{2}\|y-x\|^2.$$

Setting $y = x_{k+1} = x_k - \frac{1}{L}\nabla f(x_k)$:
$$f(x_{k+1}) \leq f(x_k) - \frac{1}{L}\|\nabla f(x_k)\|^2 + \frac{1}{2L}\|\nabla f(x_k)\|^2 = f(x_k) - \frac{1}{2L}\|\nabla f(x_k)\|^2. \quad \square$$

### Step 2: PL Inequality from Strong Convexity

**Claim**: $\|\nabla f(x)\|^2 \geq 2\mu(f(x) - f(x^*))$ for all $x$.

**Proof**: By $\mu$-strong convexity:
$$f(y) \geq f(x) + \langle \nabla f(x), y - x \rangle + \frac{\mu}{2}\|y - x\|^2 \quad \forall y.$$

Minimizing the RHS over $y$: the minimum is at $y = x - \frac{1}{\mu}\nabla f(x)$, giving:
$$f(y) \geq f(x) - \frac{1}{2\mu}\|\nabla f(x)\|^2 \quad \forall y.$$

In particular for $y = x^*$: $f(x^*) \geq f(x) - \frac{1}{2\mu}\|\nabla f(x)\|^2$, hence $\|\nabla f(x)\|^2 \geq 2\mu(f(x) - f(x^*))$. $\square$

### Step 3: Per-Step Contraction

From Step 1: $f(x_{k+1}) - f(x^*) \leq f(x_k) - f(x^*) - \frac{1}{2L}\|\nabla f(x_k)\|^2$.

Applying Step 2: $\frac{1}{2L}\|\nabla f(x_k)\|^2 \geq \frac{\mu}{L}(f(x_k) - f(x^*))$.

Therefore:
$$f(x_{k+1}) - f(x^*) \leq \left(1 - \frac{\mu}{L}\right)(f(x_k) - f(x^*)).$$

### Step 4: Telescoping

By induction on $k$:
$$f(x_k) - f(x^*) \leq \left(1 - \frac{\mu}{L}\right)^k (f(x_0) - f(x^*)). \quad \blacksquare$$

---

## Part (b): Iterate Convergence

$$\|x_k - x^*\|^2 \leq \left(1 - \frac{\mu}{L}\right)^k \|x_0 - x^*\|^2.$$

### Step 5: Interpolation Inequality for $\mathcal{F}_{\mu,L}$

**Claim**: For $f$ that is $\mu$-strongly convex and $L$-smooth:
$$\langle \nabla f(x) - \nabla f(y), x - y \rangle \geq \frac{\mu L}{\mu + L}\|x - y\|^2 + \frac{1}{\mu + L}\|\nabla f(x) - \nabla f(y)\|^2.$$

**Proof**: Define $g(x) = f(x) - \frac{\mu}{2}\|x\|^2$. Then $g$ is convex and $(L-\mu)$-smooth. By the Baillon-Haddad theorem (cocoercivity of gradients of convex smooth functions):
$$\langle \nabla g(x) - \nabla g(y), x - y \rangle \geq \frac{1}{L - \mu}\|\nabla g(x) - \nabla g(y)\|^2.$$

Let $u = \nabla f(x) - \nabla f(y)$ and $v = x - y$. Since $\nabla g(x) = \nabla f(x) - \mu x$:
$$\langle u - \mu v, v \rangle \geq \frac{1}{L - \mu}\|u - \mu v\|^2.$$

Expanding both sides:
$$\langle u, v \rangle - \mu\|v\|^2 \geq \frac{1}{L-\mu}(\|u\|^2 - 2\mu\langle u, v\rangle + \mu^2\|v\|^2).$$

Collecting $\langle u, v \rangle$ terms on the left:
$$\langle u, v \rangle\left(1 + \frac{2\mu}{L-\mu}\right) \geq \mu\|v\|^2 + \frac{\mu^2}{L-\mu}\|v\|^2 + \frac{1}{L-\mu}\|u\|^2.$$

Simplifying: $1 + \frac{2\mu}{L-\mu} = \frac{L+\mu}{L-\mu}$ and $\mu + \frac{\mu^2}{L-\mu} = \frac{\mu L}{L-\mu}$. So:
$$\langle u, v \rangle \cdot \frac{L+\mu}{L-\mu} \geq \frac{\mu L}{L-\mu}\|v\|^2 + \frac{1}{L-\mu}\|u\|^2.$$

Multiplying by $\frac{L-\mu}{L+\mu}$:
$$\langle u, v \rangle \geq \frac{\mu L}{L+\mu}\|v\|^2 + \frac{1}{L+\mu}\|u\|^2. \quad \square$$

### Step 6: Iterate Contraction

With $y = x^*$, $\nabla f(x^*) = 0$: the interpolation inequality gives
$$\langle \nabla f(x_k), x_k - x^* \rangle \geq \frac{\mu L}{\mu+L}\|x_k - x^*\|^2 + \frac{1}{\mu+L}\|\nabla f(x_k)\|^2.$$

Now:
$$\|x_{k+1} - x^*\|^2 = \|x_k - x^* - \tfrac{1}{L}\nabla f(x_k)\|^2$$
$$= \|x_k - x^*\|^2 - \frac{2}{L}\langle \nabla f(x_k), x_k - x^* \rangle + \frac{1}{L^2}\|\nabla f(x_k)\|^2.$$

Applying the interpolation bound:
$$\leq \|x_k - x^*\|^2 - \frac{2\mu}{\mu+L}\|x_k - x^*\|^2 - \frac{2}{L(\mu+L)}\|\nabla f(x_k)\|^2 + \frac{1}{L^2}\|\nabla f(x_k)\|^2$$
$$= \frac{L-\mu}{L+\mu}\|x_k - x^*\|^2 + \underbrace{\left(\frac{1}{L^2} - \frac{2}{L(\mu+L)}\right)}_{= -\frac{L-\mu}{L^2(L+\mu)} \leq 0}\|\nabla f(x_k)\|^2$$
$$\leq \frac{L-\mu}{L+\mu}\|x_k - x^*\|^2.$$

### Step 7: From Tight Rate to Claimed Rate

Since $\frac{L-\mu}{L+\mu} = \frac{\kappa - 1}{\kappa + 1}$ and $1 - \frac{1}{\kappa} = \frac{\kappa-1}{\kappa}$, we verify:
$$\frac{\kappa-1}{\kappa+1} \leq \frac{\kappa-1}{\kappa} = 1 - \frac{\mu}{L}.$$

Therefore by induction:
$$\|x_k - x^*\|^2 \leq \left(\frac{L-\mu}{L+\mu}\right)^k\|x_0 - x^*\|^2 \leq \left(1 - \frac{\mu}{L}\right)^k\|x_0 - x^*\|^2. \quad \blacksquare$$

---

## Iteration Complexity

Since $1 - \mu/L \leq e^{-\mu/L}$, achieving $f(x_k) - f(x^*) \leq \varepsilon$ requires:
$$k \geq \frac{L}{\mu}\log\frac{f(x_0) - f(x^*)}{\varepsilon} = O\!\left(\kappa\log\frac{1}{\varepsilon}\right).$$

$\blacksquare$
