# Route 3 — He-Yuan Diagonal Lyapunov Framework

## Proof of Chambolle-Pock PDHG O(1/N) Saddle-Point Convergence

**Theorem.** Let $X, Y$ be finite-dimensional real Hilbert spaces, $K: X \to Y$ bounded linear with $\|K\| = L$, and $g: X \to (-\infty, +\infty]$, $f^*: Y \to (-\infty, +\infty]$ proper convex lsc. Consider the saddle-point problem

$$\min_x \max_y \; \langle Kx, y \rangle + g(x) - f^*(y).$$

Run PDHG with step sizes $\tau, \sigma > 0$ satisfying $\tau \sigma L^2 < 1$, starting from $(x^0, y^0)$ with $\bar{x}^0 = x^0$:

$$y^{n+1} = \operatorname{prox}_{\sigma f^*}(y^n + \sigma K \bar{x}^n),$$
$$x^{n+1} = \operatorname{prox}_{\tau g}(x^n - \tau K^* y^{n+1}),$$
$$\bar{x}^{n+1} = 2x^{n+1} - x^n.$$

Define ergodic averages $X^N = \frac{1}{N}\sum_{n=1}^N x^n$, $Y^N = \frac{1}{N}\sum_{n=1}^N y^n$. Then for any bounded set $B = B_x \times B_y$ and any $(x, y) \in B$:

$$\mathcal{G}_B(X^N, Y^N) \leq \frac{1}{N}\left(\frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma}\right).$$

---

## Step 1: Define the Lyapunov Function

For an arbitrary fixed test point $(x, y) \in X \times Y$, define:

$$\Phi^n = \frac{\|x - x^n\|^2}{2\tau} + \frac{\|y - y^n\|^2}{2\sigma}.$$

This is a weighted squared-distance from the test point to the current iterate. The weights $1/(2\tau)$ and $1/(2\sigma)$ correspond to the diagonal scaling in the He-Yuan framework.

---

## Step 2: Proximal Optimality Conditions (Variational Inequalities)

**Prox-$y$ update.** By definition, $y^{n+1} = \operatorname{prox}_{\sigma f^*}(y^n + \sigma K\bar{x}^n)$ means:

$$y^{n+1} = \arg\min_{\hat{y}} \left\{ f^*(\hat{y}) + \frac{1}{2\sigma}\|\hat{y} - (y^n + \sigma K\bar{x}^n)\|^2 \right\}.$$

The optimality condition (0 ∈ subdifferential) gives:

$$\frac{1}{\sigma}(y^n + \sigma K\bar{x}^n - y^{n+1}) \in \partial f^*(y^{n+1}).$$

By convexity of $f^*$, for any $y \in Y$:

$$f^*(y) \geq f^*(y^{n+1}) + \left\langle \frac{1}{\sigma}(y^n - y^{n+1}) + K\bar{x}^n, \; y - y^{n+1} \right\rangle.$$

Rearranging:

$$\boxed{f^*(y^{n+1}) - f^*(y) + \langle K\bar{x}^n, y^{n+1} - y \rangle \leq \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1} \rangle.} \tag{VI-y}$$

**Prox-$x$ update.** Similarly, $x^{n+1} = \operatorname{prox}_{\tau g}(x^n - \tau K^* y^{n+1})$ gives:

$$\frac{1}{\tau}(x^n - \tau K^* y^{n+1} - x^{n+1}) \in \partial g(x^{n+1}).$$

By convexity of $g$, for any $x \in X$:

$$g(x) \geq g(x^{n+1}) + \left\langle \frac{1}{\tau}(x^n - x^{n+1}) - K^* y^{n+1}, \; x - x^{n+1} \right\rangle.$$

Rearranging:

$$\boxed{g(x^{n+1}) - g(x) - \langle K^* y^{n+1}, x^{n+1} - x \rangle \leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1} \rangle.} \tag{VI-x}$$

---

## Step 3: Add the Two Variational Inequalities

Adding (VI-y) and (VI-x):

$$\underbrace{g(x^{n+1}) - g(x) + \langle K x^{n+1}, y \rangle - f^*(y) - \left[\langle K x, y^{n+1} \rangle + g(x) - f^*(y^{n+1}) - g(x) \right]}_{\text{to be identified as a saddle-point gap contribution}}$$

More carefully, let us add the two inequalities directly. We get:

$$g(x^{n+1}) - g(x) + f^*(y^{n+1}) - f^*(y) + \langle K\bar{x}^n, y^{n+1} - y \rangle - \langle K^* y^{n+1}, x^{n+1} - x \rangle$$

$$\leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1} \rangle + \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1} \rangle. \tag{1}$$

Now rewrite the left-hand side. Note that $\langle K^* y^{n+1}, x^{n+1} - x \rangle = \langle y^{n+1}, K(x^{n+1} - x) \rangle = \langle Kx^{n+1}, y^{n+1} \rangle - \langle Kx, y^{n+1} \rangle$. So:

$$\langle K\bar{x}^n, y^{n+1} - y \rangle - \langle K^* y^{n+1}, x^{n+1} - x \rangle$$
$$= \langle K\bar{x}^n, y^{n+1} \rangle - \langle K\bar{x}^n, y \rangle - \langle Kx^{n+1}, y^{n+1} \rangle + \langle Kx, y^{n+1} \rangle.$$

We want the saddle-point gap terms $\langle Kx^{n+1}, y \rangle$ and $-\langle Kx, y^{n+1} \rangle$ to appear. Let us reorganize by adding and subtracting $\langle Kx^{n+1}, y \rangle$:

The coupling terms become:
$$\langle Kx, y^{n+1} \rangle - \langle Kx^{n+1}, y^{n+1} \rangle + \langle K\bar{x}^n, y^{n+1} \rangle - \langle K\bar{x}^n, y \rangle$$
$$= \langle K(x - x^{n+1} + \bar{x}^n), y^{n+1} \rangle - \langle K\bar{x}^n, y \rangle.$$

This is getting complex. Let us instead work with a cleaner decomposition.

**Cleaner approach to the coupling terms.** Rewrite:

$$\langle K\bar{x}^n, y^{n+1} - y \rangle - \langle Kx^{n+1} - Kx, y^{n+1} \rangle$$

$$= \langle K\bar{x}^n, y^{n+1} \rangle - \langle K\bar{x}^n, y \rangle - \langle Kx^{n+1}, y^{n+1} \rangle + \langle Kx, y^{n+1} \rangle$$

$$= -\langle K\bar{x}^n, y \rangle + \langle Kx, y^{n+1} \rangle + \langle K(\bar{x}^n - x^{n+1}), y^{n+1} \rangle.$$

Now using $\bar{x}^n = 2x^n - x^{n-1}$ (for $n \geq 1$; $\bar{x}^0 = x^0$), the last term involves $\bar{x}^n - x^{n+1}$. We will handle the extrapolation term later in Step 4.

**Instead, let us directly form the per-step gap quantity.** Define the Lagrangian:

$$\mathcal{L}(x', y') = \langle Kx', y' \rangle + g(x') - f^*(y').$$

The per-step "gap contribution" at iteration $n+1$ for test point $(x,y)$ is:

$$\Delta^{n+1} := \mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})$$
$$= \langle Kx^{n+1}, y \rangle + g(x^{n+1}) - f^*(y) - \langle Kx, y^{n+1} \rangle - g(x) + f^*(y^{n+1}).$$

$$= [g(x^{n+1}) - g(x)] - [f^*(y) - f^*(y^{n+1})] + \langle Kx^{n+1}, y \rangle - \langle Kx, y^{n+1} \rangle.$$

From (1) we have:

$$[g(x^{n+1}) - g(x)] - [f^*(y) - f^*(y^{n+1})] + \langle K\bar{x}^n, y^{n+1} - y\rangle - \langle K^*y^{n+1}, x^{n+1} - x\rangle$$
$$\leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle + \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle.$$

Note that:
$$- \langle K^*y^{n+1}, x^{n+1} - x\rangle = -\langle Kx^{n+1}, y^{n+1}\rangle + \langle Kx, y^{n+1}\rangle$$

and

$$\langle K\bar{x}^n, y^{n+1} - y\rangle = \langle K\bar{x}^n, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle.$$

So the LHS of (1) equals:

$$[g(x^{n+1}) - g(x)] - [f^*(y) - f^*(y^{n+1})] + \langle K\bar{x}^n, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle - \langle Kx^{n+1}, y^{n+1}\rangle + \langle Kx, y^{n+1}\rangle.$$

Compare with $\Delta^{n+1}$:

$$\Delta^{n+1} = [g(x^{n+1}) - g(x)] - [f^*(y) - f^*(y^{n+1})] + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle.$$

Therefore:

$$\text{LHS of (1)} = \Delta^{n+1} + \langle K\bar{x}^n, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle - \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx^{n+1}, y\rangle + \langle Kx, y^{n+1}\rangle + \langle Kx, y^{n+1}\rangle$$

Wait — let me redo this more carefully.

$$\text{LHS of (1)} - \Delta^{n+1}$$
$$= \left[\langle K\bar{x}^n, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle - \langle Kx^{n+1}, y^{n+1}\rangle + \langle Kx, y^{n+1}\rangle\right] - \left[\langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle\right]$$

$$= \langle K(\bar{x}^n - x^{n+1}), y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle - \langle Kx^{n+1}, y\rangle + 2\langle Kx, y^{n+1}\rangle$$

This is becoming unwieldy. Let me restart the coupling analysis cleanly.

---

### Step 3 (Clean Version): Combining the VIs to Isolate the Gap

From (VI-x) and (VI-y), rewritten:

**(VI-x):**
$$g(x^{n+1}) - g(x) \leq \langle K^* y^{n+1}, x^{n+1} - x \rangle + \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle$$

**(VI-y):**
$$f^*(y^{n+1}) - f^*(y) \leq -\langle K\bar{x}^n, y^{n+1} - y\rangle + \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle$$

Wait, let me re-derive (VI-y) correctly. From the optimality condition:

$$f^*(y) \geq f^*(y^{n+1}) + \langle \frac{1}{\sigma}(y^n - y^{n+1}) + K\bar{x}^n, y - y^{n+1}\rangle$$

$$\Rightarrow f^*(y^{n+1}) - f^*(y) \leq -\langle \frac{1}{\sigma}(y^n - y^{n+1}) + K\bar{x}^n, y - y^{n+1}\rangle$$

$$= \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle - \langle K\bar{x}^n, y - y^{n+1}\rangle$$

$$= \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle + \langle K\bar{x}^n, y^{n+1} - y\rangle. \tag{VI-y'}$$

And (VI-x):
$$g(x^{n+1}) - g(x) \leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle + \langle K^*y^{n+1}, x^{n+1} - x\rangle. \tag{VI-x'}$$

Now we form $\Delta^{n+1} = \mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})$:

$$\Delta^{n+1} = g(x^{n+1}) - g(x) + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle - f^*(y) + f^*(y^{n+1}).$$

Using (VI-x') to bound $g(x^{n+1}) - g(x)$ and (VI-y') to bound $f^*(y^{n+1}) - f^*(y)$:

$$\Delta^{n+1} \leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle + \langle K^*y^{n+1}, x^{n+1} - x\rangle$$
$$\quad + \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle + \langle K\bar{x}^n, y^{n+1} - y\rangle$$
$$\quad + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle. \tag{2}$$

Now collect the coupling (bilinear) terms:

$$\langle K^*y^{n+1}, x^{n+1} - x\rangle + \langle K\bar{x}^n, y^{n+1} - y\rangle + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle$$

$$= \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle + \langle K\bar{x}^n, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle$$

Hmm, let me expand each term:
- $\langle K^*y^{n+1}, x^{n+1} - x\rangle = \langle y^{n+1}, K(x^{n+1} - x)\rangle = \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle$
- $\langle K\bar{x}^n, y^{n+1} - y\rangle = \langle K\bar{x}^n, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle$

Sum of all four coupling terms:
$$\langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle + \langle K\bar{x}^n, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle$$

$$= \langle K(x^{n+1} + \bar{x}^n), y^{n+1}\rangle - 2\langle Kx, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle + \langle Kx^{n+1}, y\rangle$$

$$= \langle K(x^{n+1} + \bar{x}^n - 2x), y^{n+1}\rangle + \langle K(x^{n+1} - \bar{x}^n), y\rangle.$$

Since $\bar{x}^n = 2x^n - x^{n-1}$ for $n \geq 1$, this involves three iterates. This direct expansion approach is messy. Let me use the standard clean approach instead.

---

### Step 3 (Final Clean Version)

The key trick is to note that:

$$\langle K\bar{x}^n, y^{n+1} - y\rangle = \langle Kx^{n+1}, y^{n+1} - y\rangle + \langle K(\bar{x}^n - x^{n+1}), y^{n+1} - y\rangle.$$

Substituting into (2):

$$\Delta^{n+1} \leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle + \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle$$
$$+ \langle K^*y^{n+1}, x^{n+1} - x\rangle + \langle Kx^{n+1}, y^{n+1} - y\rangle + \langle K(\bar{x}^n - x^{n+1}), y^{n+1} - y\rangle$$
$$+ \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle.$$

Now observe that:
$$\langle K^*y^{n+1}, x^{n+1} - x\rangle + \langle Kx^{n+1}, y^{n+1} - y\rangle + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle$$

$$= \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle + \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx^{n+1}, y\rangle + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle$$

No, let me be very explicit:
- $\langle K^*y^{n+1}, x^{n+1} - x\rangle = \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle$
- $\langle Kx^{n+1}, y^{n+1} - y\rangle = \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx^{n+1}, y\rangle$
- $+ \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle$

Sum $= 2\langle Kx^{n+1}, y^{n+1}\rangle - 2\langle Kx, y^{n+1}\rangle - \langle Kx^{n+1}, y\rangle + \langle Kx^{n+1}, y\rangle$

$= 2\langle Kx^{n+1}, y^{n+1}\rangle - 2\langle Kx, y^{n+1}\rangle.$

That doesn't simplify to zero. The standard approach works differently. Let me restart with the **correct standard method**.

---

## Complete Proof (Clean Restart)

### Step 1: Lyapunov Function

Fix an arbitrary test point $(x, y)$. Define:

$$\Phi^n := \frac{\|x - x^n\|^2}{2\tau} + \frac{\|y - y^n\|^2}{2\sigma}.$$

### Step 2: Variational Inequalities from Prox Steps

**$y$-update:** $y^{n+1} = \operatorname{prox}_{\sigma f^*}(y^n + \sigma K\bar{x}^n)$ gives, for all $\hat{y}$:

$$f^*(\hat{y}) + \frac{1}{2\sigma}\|\hat{y} - y^n - \sigma K\bar{x}^n\|^2 \geq f^*(y^{n+1}) + \frac{1}{2\sigma}\|y^{n+1} - y^n - \sigma K\bar{x}^n\|^2.$$

Expanding both sides using $\|a - b\|^2 = \|a\|^2 - 2\langle a, b\rangle + \|b\|^2$ and simplifying the common $\|y^n + \sigma K\bar{x}^n\|^2/(2\sigma)$ terms:

$$f^*(\hat{y}) + \frac{\|\hat{y}\|^2}{2\sigma} - \frac{\langle \hat{y}, y^n + \sigma K\bar{x}^n\rangle}{\sigma} \geq f^*(y^{n+1}) + \frac{\|y^{n+1}\|^2}{2\sigma} - \frac{\langle y^{n+1}, y^n + \sigma K\bar{x}^n\rangle}{\sigma}.$$

Rearranging:

$$f^*(\hat{y}) - f^*(y^{n+1}) \geq \frac{1}{2\sigma}\left(\|y^{n+1}\|^2 - \|\hat{y}\|^2\right) + \frac{1}{\sigma}\langle \hat{y} - y^{n+1}, y^n + \sigma K\bar{x}^n\rangle$$

$$= \frac{1}{\sigma}\langle y^{n+1} - \hat{y}, y^{n+1}\rangle + \frac{1}{\sigma}\langle \hat{y} - y^{n+1}, y^n\rangle + \langle \hat{y} - y^{n+1}, K\bar{x}^n\rangle + \frac{\|\hat{y}\|^2 - \|\hat{y}\|^2}{2\sigma}$$

This is also getting complicated. Let me use the **standard clean form of prox VI directly**.

---

## Complete Proof (Definitive Version)

### Step 1: Lyapunov Function

Fix an arbitrary test point $(x, y) \in X \times Y$. Define:

$$\Phi^n := \frac{\|x - x^n\|^2}{2\tau} + \frac{\|y - y^n\|^2}{2\sigma}.$$

### Step 2: Proximal Variational Inequalities

The proximal operator satisfies: $p = \operatorname{prox}_{\alpha h}(v)$ if and only if $\frac{1}{\alpha}(v - p) \in \partial h(p)$. By convexity of $h$, this yields for all $z$:

$$h(z) \geq h(p) + \frac{1}{\alpha}\langle v - p, z - p\rangle.$$

**Applied to the $y$-update** with $h = f^*$, $\alpha = \sigma$, $v = y^n + \sigma K\bar{x}^n$, $p = y^{n+1}$: for all $\hat{y}$,

$$f^*(\hat{y}) \geq f^*(y^{n+1}) + \frac{1}{\sigma}\langle y^n + \sigma K\bar{x}^n - y^{n+1}, \hat{y} - y^{n+1}\rangle.$$

Setting $\hat{y} = y$:

$$f^*(y) - f^*(y^{n+1}) \geq \frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle + \langle K\bar{x}^n, y - y^{n+1}\rangle. \tag{A}$$

**Applied to the $x$-update** with $h = g$, $\alpha = \tau$, $v = x^n - \tau K^* y^{n+1}$, $p = x^{n+1}$: for all $\hat{x}$,

$$g(\hat{x}) \geq g(x^{n+1}) + \frac{1}{\tau}\langle x^n - \tau K^* y^{n+1} - x^{n+1}, \hat{x} - x^{n+1}\rangle.$$

Setting $\hat{x} = x$:

$$g(x) - g(x^{n+1}) \geq \frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle - \langle K^* y^{n+1}, x - x^{n+1}\rangle. \tag{B}$$

### Step 3: Polarization Identity to Expand Distance Terms

We use the **polarization identity**: for any $a, b$ in a Hilbert space,

$$2\langle a - b, c - a\rangle = \|c - b\|^2 - \|c - a\|^2 - \|a - b\|^2. \tag{P}$$

This follows from expanding $\|c - b\|^2 = \|(c - a) + (a - b)\|^2 = \|c - a\|^2 + 2\langle c - a, a - b\rangle + \|a - b\|^2$.

**Apply (P) to the inner product in (A)** with $a = y^{n+1}$, $b = y^n$, $c = y$:

$$2\langle y^n - y^{n+1}, y - y^{n+1}\rangle = 2\langle y^{n+1} - y^n, y^{n+1} - y\rangle$$
Wait, let us be careful. We have $\langle y^n - y^{n+1}, y - y^{n+1}\rangle$. Write $u = y^{n+1} - y^n$, so this is $\langle -u, y - y^{n+1}\rangle = \langle u, y^{n+1} - y\rangle$. Using (P) directly:

Set $c = y$, $a = y^{n+1}$, $b = y^n$ in identity $\langle a - b, c - a\rangle = \frac{1}{2}[\|c - b\|^2 - \|c - a\|^2 - \|a - b\|^2]$:

$$\langle y^{n+1} - y^n, y - y^{n+1}\rangle = \frac{1}{2}\left[\|y - y^n\|^2 - \|y - y^{n+1}\|^2 - \|y^{n+1} - y^n\|^2\right].$$

But we need $\langle y^n - y^{n+1}, y - y^{n+1}\rangle = -\langle y^{n+1} - y^n, y - y^{n+1}\rangle$:

$$\langle y^n - y^{n+1}, y - y^{n+1}\rangle = \frac{1}{2}\left[\|y - y^{n+1}\|^2 + \|y^{n+1} - y^n\|^2 - \|y - y^n\|^2\right].$$

Hmm, that gives the wrong sign for telescoping. Let me recompute:

$$\langle y^{n+1} - y^n, y - y^{n+1}\rangle = \frac{1}{2}[\|y - y^n\|^2 - \|y - y^{n+1}\|^2 - \|y^{n+1} - y^n\|^2].$$

**Verification:** $\|y - y^n\|^2 = \|(y - y^{n+1}) + (y^{n+1} - y^n)\|^2 = \|y - y^{n+1}\|^2 + 2\langle y - y^{n+1}, y^{n+1} - y^n\rangle + \|y^{n+1} - y^n\|^2$. Hence $\langle y - y^{n+1}, y^{n+1} - y^n\rangle = \frac{1}{2}[\|y - y^n\|^2 - \|y - y^{n+1}\|^2 - \|y^{n+1} - y^n\|^2]$. And $\langle y^{n+1} - y^n, y - y^{n+1}\rangle$ is the same thing. ✓

Therefore from (A):

$$f^*(y) - f^*(y^{n+1}) \geq \frac{1}{2\sigma}\left[\|y - y^n\|^2 - \|y - y^{n+1}\|^2 - \|y^{n+1} - y^n\|^2\right] + \langle K\bar{x}^n, y - y^{n+1}\rangle. \tag{A'}$$

**Similarly for (B):** Apply polarization with $c = x$, $a = x^{n+1}$, $b = x^n$:

$$\langle x^n - x^{n+1}, x - x^{n+1}\rangle = -\langle x^{n+1} - x^n, x - x^{n+1}\rangle = -\frac{1}{2}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2 - \|x^{n+1} - x^n\|^2]$$

Wait: $\langle x^n - x^{n+1}, x - x^{n+1}\rangle = \langle -(x^{n+1} - x^n), x - x^{n+1}\rangle = -\langle x^{n+1} - x^n, x - x^{n+1}\rangle$.

And $\langle x^{n+1} - x^n, x - x^{n+1}\rangle = \frac{1}{2}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2 - \|x^{n+1} - x^n\|^2]$.

So: $\langle x^n - x^{n+1}, x - x^{n+1}\rangle = \frac{1}{2}[\|x - x^{n+1}\|^2 + \|x^{n+1} - x^n\|^2 - \|x - x^n\|^2]$.

That has the wrong sign for telescoping. Let me recheck.

$\langle x^n - x^{n+1}, x - x^{n+1}\rangle$. Let $u = x^n - x^{n+1}$, $v = x - x^{n+1}$. Then $x - x^n = v - u$. We have:

$\|x - x^n\|^2 = \|v - u\|^2 = \|v\|^2 - 2\langle v, u\rangle + \|u\|^2$.

So $\langle u, v\rangle = \frac{1}{2}[\|v\|^2 + \|u\|^2 - \|v - u\|^2] = \frac{1}{2}[\|x - x^{n+1}\|^2 + \|x^n - x^{n+1}\|^2 - \|x - x^n\|^2]$.

This indeed gives $\langle x^n - x^{n+1}, x - x^{n+1}\rangle = \frac{1}{2}[\|x - x^{n+1}\|^2 + \|x^{n+1} - x^n\|^2 - \|x - x^n\|^2]$.

**But there's a better identity to use.** We want $\Phi^n - \Phi^{n+1}$ to appear. Note:

$$\frac{1}{2\tau}\|x - x^n\|^2 - \frac{1}{2\tau}\|x - x^{n+1}\|^2 = \frac{1}{2\tau}\left[\|x - x^n\|^2 - \|x - x^{n+1}\|^2\right].$$

From the polarization identity above:

$$\langle x^{n+1} - x^n, x - x^{n+1}\rangle = \frac{1}{2}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2 - \|x^{n+1} - x^n\|^2]$$

so

$$\|x - x^n\|^2 - \|x - x^{n+1}\|^2 = 2\langle x^{n+1} - x^n, x - x^{n+1}\rangle + \|x^{n+1} - x^n\|^2.$$

Therefore:

$$\frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle = \frac{1}{\tau}\left(-\langle x^{n+1} - x^n, x - x^{n+1}\rangle\right)$$

$$= \frac{1}{\tau}\left(-\frac{1}{2}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2 - \|x^{n+1} - x^n\|^2]\right)$$

$$= -\frac{1}{2\tau}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2] + \frac{1}{2\tau}\|x^{n+1} - x^n\|^2.$$

Hmm, this gives a negative telescoping contribution. But in (B), the inner product appears with a positive sign. Let me re-examine (B):

From (B): $g(x) - g(x^{n+1}) \geq \frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle - \langle K^*y^{n+1}, x - x^{n+1}\rangle$.

Rearranging to get an upper bound on $g(x^{n+1}) - g(x)$:

$$g(x^{n+1}) - g(x) \leq -\frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle + \langle K^*y^{n+1}, x - x^{n+1}\rangle. \tag{B''}$$

Now $-\frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle = \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle$.

Using the polarization result:

$$= \frac{1}{2\tau}\left[\|x - x^n\|^2 - \|x - x^{n+1}\|^2 - \|x^{n+1} - x^n\|^2\right].$$

Similarly from (A'), rearranging to bound $f^*(y^{n+1}) - f^*(y)$:

$$-(f^*(y) - f^*(y^{n+1})) = f^*(y^{n+1}) - f^*(y) \leq -\frac{1}{2\sigma}[\|y-y^n\|^2 - \|y-y^{n+1}\|^2 - \|y^{n+1}-y^n\|^2] - \langle K\bar{x}^n, y - y^{n+1}\rangle.$$

$$= \frac{1}{2\sigma}[\|y - y^{n+1}\|^2 + \|y^{n+1} - y^n\|^2 - \|y - y^n\|^2] + \langle K\bar{x}^n, y^{n+1} - y\rangle. \tag{A''}$$

Now form the per-step gap:

$$\Delta^{n+1} = [g(x^{n+1}) - g(x)] + [f^*(y^{n+1}) - f^*(y)] + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle.$$

Wait, recall $\Delta^{n+1} = \mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1}) = g(x^{n+1}) + \langle Kx^{n+1}, y\rangle - f^*(y) - g(x) - \langle Kx, y^{n+1}\rangle + f^*(y^{n+1})$.

$$= [g(x^{n+1}) - g(x)] - [f^*(y) - f^*(y^{n+1})] + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle.$$

Using (B'') for the $g$ terms and (A') for the $f^*$ terms (keeping $f^*(y) - f^*(y^{n+1})$ form):

$$\Delta^{n+1} \leq \frac{1}{2\tau}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2 - \|x^{n+1} - x^n\|^2] + \langle K^*y^{n+1}, x - x^{n+1}\rangle$$

$$- \frac{1}{2\sigma}[\|y - y^n\|^2 - \|y - y^{n+1}\|^2 - \|y^{n+1} - y^n\|^2] - \langle K\bar{x}^n, y - y^{n+1}\rangle$$

$$+ \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle.$$

Noting $-\frac{1}{2\sigma}[\|y-y^n\|^2 - \|y-y^{n+1}\|^2 - \|y^{n+1}-y^n\|^2] = \frac{1}{2\sigma}[\|y-y^{n+1}\|^2 + \|y^{n+1}-y^n\|^2 - \|y-y^n\|^2]$:

Wait, we need this to telescope the right way. Let me rewrite as:

$$\Delta^{n+1} \leq \underbrace{\frac{1}{2\tau}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2] + \frac{1}{2\sigma}[\|y - y^n\|^2 - \|y - y^{n+1}\|^2]}_{\Phi^n - \Phi^{n+1}}$$

$$- \frac{1}{2\tau}\|x^{n+1} - x^n\|^2 + \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2$$

Wait, the $f^*$ term gives $-\frac{1}{2\sigma}[\|y-y^n\|^2 - \|y-y^{n+1}\|^2 - \|y^{n+1}-y^n\|^2]$:

$= -\frac{1}{2\sigma}\|y-y^n\|^2 + \frac{1}{2\sigma}\|y-y^{n+1}\|^2 + \frac{1}{2\sigma}\|y^{n+1}-y^n\|^2$

$= \frac{1}{2\sigma}[\|y-y^{n+1}\|^2 - \|y-y^n\|^2] + \frac{1}{2\sigma}\|y^{n+1}-y^n\|^2.$

That gives $-(\Phi_y^{n} - \Phi_y^{n+1}) + \frac{1}{2\sigma}\|y^{n+1}-y^n\|^2$ for the $y$-component, i.e., $\Phi_y^{n+1} - \Phi_y^n + \frac{1}{2\sigma}\|y^{n+1}-y^n\|^2$.

**This is the wrong sign for the $y$-component!**

Let me re-examine. The issue is that (A') gives a lower bound on $f^*(y) - f^*(y^{n+1})$, and in $\Delta^{n+1}$ we need an upper bound on $-[f^*(y) - f^*(y^{n+1})]$, i.e., an upper bound on $f^*(y^{n+1}) - f^*(y)$.

From (A'): $f^*(y) - f^*(y^{n+1}) \geq \frac{1}{2\sigma}[\|y-y^n\|^2 - \|y-y^{n+1}\|^2 - \|y^{n+1}-y^n\|^2] + \langle K\bar{x}^n, y - y^{n+1}\rangle$.

Therefore:

$f^*(y^{n+1}) - f^*(y) \leq -\frac{1}{2\sigma}[\|y-y^n\|^2 - \|y-y^{n+1}\|^2 - \|y^{n+1}-y^n\|^2] - \langle K\bar{x}^n, y - y^{n+1}\rangle$

$= \frac{1}{2\sigma}[-\|y-y^n\|^2 + \|y-y^{n+1}\|^2 + \|y^{n+1}-y^n\|^2] + \langle K\bar{x}^n, y^{n+1} - y\rangle.$

So the $y$-distance terms contribute $\frac{1}{2\sigma}[\|y-y^{n+1}\|^2 - \|y-y^n\|^2]$, which is $\Phi_y^{n+1} - \Phi_y^n$, the **wrong direction** for telescoping.

**The resolution:** For the primal-dual gap, we need both inequalities pointing the same way. The correct approach is to use the VI **not** to bound each convex function difference separately, but to directly form a combined inequality.

Let me go back to the fundamental approach.

---

## Complete Proof (Final Definitive Version)

### Setup and Notation

Let $(x, y) \in X \times Y$ be an arbitrary test point. Define:
$$\Phi^n = \frac{\|x - x^n\|^2}{2\tau} + \frac{\|y - y^n\|^2}{2\sigma}.$$

### Step 2: Prox Optimality Conditions

**$y$-update.** From $y^{n+1} = \operatorname{prox}_{\sigma f^*}(y^n + \sigma K\bar{x}^n)$, we get for all $\hat{y}$:

$$\sigma f^*(\hat{y}) + \frac{1}{2}\|\hat{y} - y^n - \sigma K\bar{x}^n\|^2 \geq \sigma f^*(y^{n+1}) + \frac{1}{2}\|y^{n+1} - y^n - \sigma K\bar{x}^n\|^2.$$

Setting $\hat{y} = y$ and expanding:

$$\sigma f^*(y) + \frac{1}{2}\|y\|^2 - \langle y, y^n + \sigma K\bar{x}^n\rangle \geq \sigma f^*(y^{n+1}) + \frac{1}{2}\|y^{n+1}\|^2 - \langle y^{n+1}, y^n + \sigma K\bar{x}^n\rangle.$$

(We cancelled $\frac{1}{2}\|y^n + \sigma K\bar{x}^n\|^2$ from both sides.)

Rearranging:

$$\sigma[f^*(y) - f^*(y^{n+1})] \geq \frac{1}{2}\|y^{n+1}\|^2 - \frac{1}{2}\|y\|^2 - \langle y^{n+1} - y, y^n + \sigma K\bar{x}^n\rangle$$

$$= \frac{1}{2}\|y^{n+1}\|^2 - \frac{1}{2}\|y\|^2 - \langle y^{n+1} - y, y^n\rangle - \sigma\langle K\bar{x}^n, y^{n+1} - y\rangle.$$

Now use the identity $\frac{1}{2}\|a\|^2 - \frac{1}{2}\|b\|^2 - \langle a - b, c\rangle = \frac{1}{2}\|a - c\|^2 - \frac{1}{2}\|b - c\|^2 + \langle b - a, b - c\rangle + \frac{1}{2}\|a - b\|^2$... this is getting complicated again.

**Let me use the simplest three-point identity directly.** For any points $p, q, r$:

$$\langle p - q, r - p\rangle = \frac{1}{2}\|r - q\|^2 - \frac{1}{2}\|r - p\|^2 - \frac{1}{2}\|p - q\|^2.$$

From the proximal subgradient condition, we have:

$$f^*(y) \geq f^*(y^{n+1}) + \langle \underbrace{\tfrac{1}{\sigma}(y^n - y^{n+1}) + K\bar{x}^n}_{\in \partial f^*(y^{n+1})}, y - y^{n+1}\rangle. \tag{A}$$

$$g(x) \geq g(x^{n+1}) + \langle \underbrace{\tfrac{1}{\tau}(x^n - x^{n+1}) - K^*y^{n+1}}_{\in \partial g(x^{n+1})}, x - x^{n+1}\rangle. \tag{B}$$

From (A): $f^*(y) - f^*(y^{n+1}) \geq \frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle + \langle K\bar{x}^n, y - y^{n+1}\rangle$.

Now by the three-point identity with $p = y^{n+1}$, $q = y^n$, $r = y$:

$$\langle y^{n+1} - y^n, y - y^{n+1}\rangle = \frac{1}{2}\|y - y^n\|^2 - \frac{1}{2}\|y - y^{n+1}\|^2 - \frac{1}{2}\|y^{n+1} - y^n\|^2.$$

So $\langle y^n - y^{n+1}, y - y^{n+1}\rangle = -\langle y^{n+1} - y^n, y - y^{n+1}\rangle = \frac{1}{2}\|y - y^{n+1}\|^2 + \frac{1}{2}\|y^{n+1} - y^n\|^2 - \frac{1}{2}\|y - y^n\|^2$.

Therefore (A) becomes:

$$f^*(y) - f^*(y^{n+1}) \geq \frac{1}{2\sigma}\left[\|y - y^{n+1}\|^2 - \|y - y^n\|^2 + \|y^{n+1} - y^n\|^2\right] + \langle K\bar{x}^n, y - y^{n+1}\rangle. \tag{A'}$$

Similarly from (B):

$$g(x) - g(x^{n+1}) \geq \frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle - \langle K^*y^{n+1}, x - x^{n+1}\rangle.$$

$\langle x^n - x^{n+1}, x - x^{n+1}\rangle = \frac{1}{2}\|x - x^{n+1}\|^2 + \frac{1}{2}\|x^{n+1} - x^n\|^2 - \frac{1}{2}\|x - x^n\|^2$.

$$g(x) - g(x^{n+1}) \geq \frac{1}{2\tau}\left[\|x - x^{n+1}\|^2 - \|x - x^n\|^2 + \|x^{n+1} - x^n\|^2\right] - \langle K^*y^{n+1}, x - x^{n+1}\rangle. \tag{B'}$$

### Step 3: Form the Saddle-Point Gap

Recall $\mathcal{L}(u, v) = g(u) + \langle Ku, v\rangle - f^*(v)$.

The per-step gap for test point $(x, y)$:

$$\Delta^{n+1} := \mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1}).$$

We want a **lower bound** on $\Delta^{n+1}$ in terms that telescope:

$$\Delta^{n+1} = [g(x^{n+1}) - g(x)] + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle + [f^*(y^{n+1}) - f^*(y)].$$

From (A'), we get an **upper bound** on $f^*(y^{n+1}) - f^*(y)$:

$$f^*(y^{n+1}) - f^*(y) \leq \frac{1}{2\sigma}[\|y - y^n\|^2 - \|y - y^{n+1}\|^2 - \|y^{n+1} - y^n\|^2] - \langle K\bar{x}^n, y - y^{n+1}\rangle. \tag{A''}$$

From (B'), we get an **upper bound** on $g(x^{n+1}) - g(x)$:

$$g(x^{n+1}) - g(x) \leq \frac{1}{2\tau}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2 - \|x^{n+1} - x^n\|^2] + \langle K^*y^{n+1}, x - x^{n+1}\rangle. \tag{B''}$$

Adding (A'') and (B'') with the bilinear terms:

$$\Delta^{n+1} \leq \frac{1}{2\tau}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2] + \frac{1}{2\sigma}[\|y - y^n\|^2 - \|y - y^{n+1}\|^2]$$

$$- \frac{1}{2\tau}\|x^{n+1} - x^n\|^2 - \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2$$

$$+ \langle K^*y^{n+1}, x - x^{n+1}\rangle - \langle K\bar{x}^n, y - y^{n+1}\rangle + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle. \tag{3}$$

The first line is $\Phi^n - \Phi^{n+1}$. Now we must handle the coupling terms.

### Step 3a: Simplify the Coupling Terms

Coupling terms from (3):

$$C := \langle K^*y^{n+1}, x - x^{n+1}\rangle - \langle K\bar{x}^n, y - y^{n+1}\rangle + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle.$$

Rewrite using $\langle K^*y^{n+1}, x - x^{n+1}\rangle = \langle y^{n+1}, K(x - x^{n+1})\rangle = \langle Kx, y^{n+1}\rangle - \langle Kx^{n+1}, y^{n+1}\rangle$:

$$C = \langle Kx, y^{n+1}\rangle - \langle Kx^{n+1}, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle + \langle K\bar{x}^n, y^{n+1}\rangle + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle$$

$$= -\langle Kx^{n+1}, y^{n+1}\rangle + \langle K\bar{x}^n, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle + \langle Kx^{n+1}, y\rangle$$

$$= \langle K(\bar{x}^n - x^{n+1}), y^{n+1}\rangle + \langle K(x^{n+1} - \bar{x}^n), y\rangle$$

$$= \langle K(\bar{x}^n - x^{n+1}), y^{n+1} - y\rangle. \tag{4}$$

**Excellent!** The coupling terms simplify beautifully to $\langle K(\bar{x}^n - x^{n+1}), y^{n+1} - y\rangle$.

### Step 4: Handle the Extrapolation Term

Recall $\bar{x}^n = 2x^n - x^{n-1}$ for $n \geq 1$ and $\bar{x}^0 = x^0$. Therefore:

$$\bar{x}^n - x^{n+1} = 2x^n - x^{n-1} - x^{n+1} = (x^n - x^{n+1}) + (x^n - x^{n-1}) = (x^n - x^{n+1}) - (x^{n-1} - x^n).$$

Wait, but for $n = 0$: $\bar{x}^0 - x^1 = x^0 - x^1$.

For general $n \geq 1$: $\bar{x}^n - x^{n+1} = (2x^n - x^{n-1}) - x^{n+1} = (x^n - x^{n+1}) + (x^n - x^{n-1})$.

This expression doesn't obviously telescope. Let us instead write $\bar{x}^n = x^n + (x^n - x^{n-1})$ (for $n \geq 1$), so:

$$\bar{x}^n - x^{n+1} = (x^n - x^{n+1}) + (x^n - x^{n-1}).$$

This is messy. The standard approach is to bound the coupling term using Young's inequality and the step size condition.

**Apply Cauchy-Schwarz and Young's inequality to the coupling term (4):**

$$|\langle K(\bar{x}^n - x^{n+1}), y^{n+1} - y\rangle| \leq \|K\| \cdot \|\bar{x}^n - x^{n+1}\| \cdot \|y^{n+1} - y\| \leq L\|\bar{x}^n - x^{n+1}\| \cdot \|y^{n+1} - y\|.$$

But this gives a bound in terms of $\|y^{n+1} - y\|$ which doesn't help (it's not a residual term).

**The correct approach** is different. We should bound the coupling term in terms of **residual norms** $\|x^{n+1} - x^n\|$ and $\|y^{n+1} - y^n\|$, not involving the test point. The trick is to decompose differently.

**Alternative: rewrite the coupling using the extrapolation structure.**

Note that $\bar{x}^n = 2x^n - x^{n-1}$, so $\bar{x}^n = x^n + (x^n - x^{n-1})$.

The coupling in the original VIs is $\langle K\bar{x}^n, y - y^{n+1}\rangle$. We can write:

$$\langle K\bar{x}^n, y - y^{n+1}\rangle = \langle Kx^n, y - y^{n+1}\rangle + \langle K(x^n - x^{n-1}), y - y^{n+1}\rangle.$$

Let's go back to (3) but use this decomposition. Actually, let me reconsider the approach entirely.

**Key insight (He-Yuan framework):** Instead of bounding the coupling term $C = \langle K(\bar{x}^n - x^{n+1}), y^{n+1} - y\rangle$ against the test point, we should decompose the bilinear coupling more carefully. The correct method is:

From the coupling in (A) we have $\langle K\bar{x}^n, y - y^{n+1}\rangle$. Write $\bar{x}^n = x^{n+1} + (\bar{x}^n - x^{n+1})$:

$$\langle K\bar{x}^n, y - y^{n+1}\rangle = \langle Kx^{n+1}, y - y^{n+1}\rangle + \langle K(\bar{x}^n - x^{n+1}), y - y^{n+1}\rangle.$$

Now the first term $\langle Kx^{n+1}, y - y^{n+1}\rangle$ and the term $-\langle K^*y^{n+1}, x - x^{n+1}\rangle = -\langle Kx + K(x^{n+1} - x) - Kx^{n+1}, y^{n+1}\rangle$... we showed these combined to give $C$.

**The right approach:** We need to bound $\langle K(\bar{x}^n - x^{n+1}), y^{n+1} - y\rangle$ using Young's inequality **in a way that creates only squared residual terms.** But $y^{n+1} - y$ is not a residual.

**Correct standard technique:** Split $y^{n+1} - y = (y^{n+1} - y^n) + (y^n - y)$, then the $(y^n - y)$ part will be handled by absorbing into the Lyapunov function via a cross-term.

Actually, let me reconsider. I think the standard proof avoids this issue by **not** separating the bilinear terms as I did. Let me follow the Chambolle-Pock 2011 paper argument directly.

---

## Complete Proof (Following Chambolle-Pock 2011, He-Yuan Framework)

### Step 1: Lyapunov Function

For arbitrary $(x, y) \in X \times Y$, define:
$$\Phi^n = \frac{\|x - x^n\|^2}{2\tau} + \frac{\|y - y^n\|^2}{2\sigma}.$$

### Step 2: Variational Inequalities

From the prox optimality conditions:

**(VI-y):** For all $\hat{y} \in Y$:
$$f^*(\hat{y}) \geq f^*(y^{n+1}) + \left\langle \frac{y^n - y^{n+1}}{\sigma} + K\bar{x}^n, \hat{y} - y^{n+1}\right\rangle. \tag{A}$$

**(VI-x):** For all $\hat{x} \in X$:
$$g(\hat{x}) \geq g(x^{n+1}) + \left\langle \frac{x^n - x^{n+1}}{\tau} - K^*y^{n+1}, \hat{x} - x^{n+1}\right\rangle. \tag{B}$$

Set $\hat{y} = y$ in (A) and $\hat{x} = x$ in (B), then add:

$$f^*(y) + g(x) - f^*(y^{n+1}) - g(x^{n+1})$$
$$\geq \frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle + \frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle$$
$$\quad + \langle K\bar{x}^n, y - y^{n+1}\rangle - \langle K^*y^{n+1}, x - x^{n+1}\rangle. \tag{C}$$

The last line equals (using adjointness):

$$\langle K\bar{x}^n, y\rangle - \langle K\bar{x}^n, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle + \langle Kx^{n+1}, y^{n+1}\rangle.$$

$$= \langle K\bar{x}^n, y\rangle - \langle K(\bar{x}^n - x^{n+1} + x), y^{n+1}\rangle$$

$$= \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle - \langle K(\bar{x}^n - x^{n+1}), y^{n+1}\rangle.$$

So (C) becomes:

$$f^*(y) + g(x) - f^*(y^{n+1}) - g(x^{n+1}) \geq \frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle + \frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle$$

$$+ \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle - \langle K(\bar{x}^n - x^{n+1}), y^{n+1}\rangle. \tag{C'}$$

Notice: $-\Delta^{n+1} = g(x) + f^*(y) - g(x^{n+1}) - f^*(y^{n+1}) - \langle Kx^{n+1}, y\rangle + \langle Kx, y^{n+1}\rangle.$

So: $\text{LHS of (C')} = -\Delta^{n+1} + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle$.

And the RHS coupling is $\langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle - \langle K(\bar{x}^n - x^{n+1}), y^{n+1}\rangle$.

Thus:

$$-\Delta^{n+1} + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle \geq \text{inner product terms} + \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle - \langle K(\bar{x}^n - x^{n+1}), y^{n+1}\rangle.$$

Cancel $-\langle Kx, y^{n+1}\rangle$ from both sides:

$$-\Delta^{n+1} + \langle Kx^{n+1}, y\rangle \geq \text{inner product terms} + \langle K\bar{x}^n, y\rangle - \langle K(\bar{x}^n - x^{n+1}), y^{n+1}\rangle.$$

$$-\Delta^{n+1} \geq \text{inner product terms} + \langle K(\bar{x}^n - x^{n+1}), y\rangle - \langle K(\bar{x}^n - x^{n+1}), y^{n+1}\rangle$$

$$= \text{inner product terms} + \langle K(\bar{x}^n - x^{n+1}), y - y^{n+1}\rangle.$$

This is getting circular. Let me take a completely clean approach.

---

## DEFINITIVE PROOF

I will follow the proof strategy directly and carefully.

### Step 1: Define Lyapunov Function

For an arbitrary fixed point $(x, y)$, set:
$$\Phi^n = \frac{\|x - x^n\|^2}{2\tau} + \frac{\|y - y^n\|^2}{2\sigma}.$$

### Step 2: Key Per-Iteration Inequality

**Claim:** For each $n \geq 0$ and any $(x, y) \in X \times Y$:

$$\langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle + g(x^{n+1}) - g(x) - f^*(y^{n+1}) + f^*(y)$$
$$\leq \Phi^n - \Phi^{n+1} - \frac{1}{2\tau}\|x^{n+1} - x^n\|^2 - \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2 + \langle K(\bar{x}^n - x^{n+1}), y^{n+1} - y^n\rangle. \tag{$\star$}$$

**Proof of ($\star$):**

From (A) with $\hat{y} = y$:
$$f^*(y) - f^*(y^{n+1}) \geq \frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle + \langle K\bar{x}^n, y - y^{n+1}\rangle.$$

From (B) with $\hat{x} = x$:
$$g(x) - g(x^{n+1}) \geq \frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle - \langle K^*y^{n+1}, x - x^{n+1}\rangle.$$

Adding and rearranging (moving to LHS):

$$g(x^{n+1}) - g(x) + f^*(y) - f^*(y^{n+1}) + \langle K\bar{x}^n, y - y^{n+1}\rangle - \langle K^*y^{n+1}, x - x^{n+1}\rangle$$

Wait, I need to keep the signs right. Let me add both lower bounds:

$$[f^*(y) - f^*(y^{n+1})] + [g(x) - g(x^{n+1})]$$
$$\geq \frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle + \langle K\bar{x}^n, y - y^{n+1}\rangle + \frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle - \langle K^*y^{n+1}, x - x^{n+1}\rangle.$$

Equivalently:

$$g(x^{n+1}) - g(x) - f^*(y) + f^*(y^{n+1}) \leq -\frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle - \frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle - \langle K\bar{x}^n, y - y^{n+1}\rangle + \langle K^*y^{n+1}, x - x^{n+1}\rangle. \tag{D}$$

Now using three-point identity $\langle a - b, c - a\rangle = \frac{1}{2}[\|c - b\|^2 - \|c - a\|^2 - \|a - b\|^2]$:

$$-\frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle = \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle = \frac{1}{2\tau}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2 - \|x^{n+1} - x^n\|^2].$$

Wait: $\langle x^{n+1} - x^n, x - x^{n+1}\rangle$. Using the identity with $a = x^{n+1}$, $b = x^n$, $c = x$:

$$\langle x^{n+1} - x^n, x - x^{n+1}\rangle = \frac{1}{2}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2 - \|x^{n+1} - x^n\|^2].$$

So: $-\frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle = \frac{1}{2\tau}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2 - \|x^{n+1} - x^n\|^2].$

But $-\langle x^n - x^{n+1}, x - x^{n+1}\rangle = \langle x^{n+1} - x^n, x - x^{n+1}\rangle$. ✓

Similarly: $-\frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle = \frac{1}{2\sigma}[\|y - y^n\|^2 - \|y - y^{n+1}\|^2 - \|y^{n+1} - y^n\|^2].$

So the RHS of (D) becomes:

$$\frac{1}{2\tau}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2] - \frac{1}{2\tau}\|x^{n+1} - x^n\|^2 + \frac{1}{2\sigma}[\|y - y^n\|^2 - \|y - y^{n+1}\|^2] - \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2$$

$$- \langle K\bar{x}^n, y - y^{n+1}\rangle + \langle K^*y^{n+1}, x - x^{n+1}\rangle.$$

$$= (\Phi^n - \Phi^{n+1}) - \frac{1}{2\tau}\|x^{n+1} - x^n\|^2 - \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2$$

$$- \langle K\bar{x}^n, y - y^{n+1}\rangle + \langle K^*y^{n+1}, x - x^{n+1}\rangle. \tag{D'}$$

Now the LHS of (D) is $g(x^{n+1}) - g(x) - f^*(y) + f^*(y^{n+1})$, and we want the LHS of ($\star$) which also includes $\langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle$.

The LHS of ($\star$) is:

$$\langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle + g(x^{n+1}) - g(x) - f^*(y^{n+1}) + f^*(y).$$

Wait, $-f^*(y^{n+1}) + f^*(y) = -(f^*(y^{n+1}) - f^*(y)) = f^*(y) - f^*(y^{n+1})$. And the LHS of (D) is $g(x^{n+1}) - g(x) - f^*(y) + f^*(y^{n+1}) = -(f^*(y) - f^*(y^{n+1})) - (g(x) - g(x^{n+1}))$.

So LHS of ($\star$) $= \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle - \text{LHS of (D)}$.

From (D): LHS of (D) $\leq$ RHS of (D) = expression in (D').

So: LHS of ($\star$) = $\langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle - \text{LHS of (D)} \leq \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle - \text{(a negative of RHS of D')}$...

I'm confusing myself with signs. Let me just directly organize everything.

**Direct computation.** We want to show ($\star$). Denote the LHS of ($\star$) as:

$$\text{LHS} = \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle + g(x^{n+1}) - g(x) + f^*(y) - f^*(y^{n+1}).$$

(Note: $-f^*(y^{n+1}) + f^*(y) = f^*(y) - f^*(y^{n+1})$.)

From adding (A) and (B) with $\hat{y} = y$, $\hat{x} = x$:

$$[f^*(y) - f^*(y^{n+1})] + [g(x) - g(x^{n+1})] \geq \frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle + \frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle + \langle K\bar{x}^n, y - y^{n+1}\rangle - \langle Kx - Kx^{n+1}, y^{n+1}\rangle.$$

Therefore:

$$-[f^*(y) - f^*(y^{n+1})] - [g(x) - g(x^{n+1})] \leq -\frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle - \frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle - \langle K\bar{x}^n, y - y^{n+1}\rangle + \langle Kx - Kx^{n+1}, y^{n+1}\rangle.$$

$$[g(x^{n+1}) - g(x)] + [f^*(y) - f^*(y^{n+1})]$$

Wait: $-[f^*(y) - f^*(y^{n+1})] = f^*(y^{n+1}) - f^*(y)$. But in LHS we have $f^*(y) - f^*(y^{n+1})$. So we need the original direction.

Let me just substitute. From (A)+(B):

$$f^*(y) - f^*(y^{n+1}) + g(x) - g(x^{n+1}) \geq \text{(RHS inner products + coupling)}.$$

So: $f^*(y) - f^*(y^{n+1}) - [g(x^{n+1}) - g(x)] \geq \text{...}$

And: $\text{LHS of ($\star$)} = \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle + g(x^{n+1}) - g(x) + f^*(y) - f^*(y^{n+1})$

$= \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle - [g(x) - g(x^{n+1})] + [f^*(y) - f^*(y^{n+1})]$

$\leq \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle - [g(x) - g(x^{n+1})] + [g(x) - g(x^{n+1})] - R$

... where $R$ is from subtracting (A)+(B). This is too tangled. Let me just proceed **directly from (A) and (B) separately** and combine at the end.

---

## DEFINITIVE PROOF (STREAMLINED)

### Setting

$X, Y$ finite-dimensional real Hilbert spaces. $K: X \to Y$ linear, $\|K\| = L$. $g, f^*$ proper convex lsc. Step sizes $\tau\sigma L^2 < 1$.

PDHG iterates ($\bar{x}^0 = x^0$):
- $y^{n+1} = \text{prox}_{\sigma f^*}(y^n + \sigma K\bar{x}^n)$
- $x^{n+1} = \text{prox}_{\tau g}(x^n - \tau K^*y^{n+1})$
- $\bar{x}^{n+1} = 2x^{n+1} - x^n$

### Step 1: Lyapunov Function

Fix $(x, y) \in X \times Y$ arbitrary. Define:
$$\Phi^n = \frac{\|x - x^n\|^2}{2\tau} + \frac{\|y - y^n\|^2}{2\sigma}.$$

### Step 2: Optimality Conditions and Per-Step Bound

From the prox characterization, $y^{n+1}$ minimizes $f^*(\cdot) + \frac{1}{2\sigma}\|\cdot - y^n - \sigma K\bar{x}^n\|^2$. The optimality condition gives:

$$\frac{y^n - y^{n+1}}{\sigma} + K\bar{x}^n \in \partial f^*(y^{n+1}).$$

By convexity of $f^*$, for any $y$:

$$f^*(y) \geq f^*(y^{n+1}) + \left\langle \frac{y^n - y^{n+1}}{\sigma} + K\bar{x}^n,\; y - y^{n+1}\right\rangle.$$

Rearranging:

$$\langle K\bar{x}^n, y^{n+1} - y\rangle + f^*(y^{n+1}) - f^*(y) \leq \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle. \tag{I}$$

Similarly from the $x$-update:

$$\frac{x^n - x^{n+1}}{\tau} - K^*y^{n+1} \in \partial g(x^{n+1}),$$

so for any $x$:

$$\langle K^*y^{n+1}, x^{n+1} - x\rangle + g(x^{n+1}) - g(x) \leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle. \tag{II}$$

**Rewrite (I):** Note $\langle K\bar{x}^n, y^{n+1} - y\rangle = -\langle K\bar{x}^n, y\rangle + \langle K\bar{x}^n, y^{n+1}\rangle$.

**Rewrite (II):** Note $\langle K^*y^{n+1}, x^{n+1} - x\rangle = \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle$.

**Add (I) and (II):**

$$g(x^{n+1}) - g(x) + f^*(y^{n+1}) - f^*(y) + \langle K\bar{x}^n, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle + \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle$$

$$\leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle + \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle. \tag{III}$$

The bilinear terms on the LHS:
$$\langle K\bar{x}^n, y^{n+1}\rangle + \langle Kx^{n+1}, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle$$
$$= \langle K(\bar{x}^n + x^{n+1}), y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle.$$

We want to relate the LHS to the saddle-point gap $\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})$ where $\mathcal{L}(u,v) = g(u) + \langle Ku, v\rangle - f^*(v)$:

$$\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1}) = g(x^{n+1}) - g(x) + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle - f^*(y) + f^*(y^{n+1}).$$

Compare with LHS of (III):

$$\text{LHS(III)} = [g(x^{n+1}) - g(x)] + [f^*(y^{n+1}) - f^*(y)] + \langle K(\bar{x}^n + x^{n+1}), y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle.$$

$$\text{Gap} = [g(x^{n+1}) - g(x)] + [f^*(y^{n+1}) - f^*(y)] + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle.$$

$$\text{LHS(III)} - \text{Gap} = \langle K(\bar{x}^n + x^{n+1}), y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle - \langle Kx^{n+1}, y\rangle + \langle Kx, y^{n+1}\rangle$$

$$= \langle K(\bar{x}^n + x^{n+1}), y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle - \langle Kx^{n+1}, y\rangle$$

$$= \langle K(\bar{x}^n + x^{n+1}), y^{n+1}\rangle - \langle K(\bar{x}^n + x^{n+1}), y\rangle + \langle Kx^{n+1}, y\rangle - \langle Kx^{n+1}, y\rangle$$

Wait: $-\langle K\bar{x}^n, y\rangle - \langle Kx^{n+1}, y\rangle = -\langle K(\bar{x}^n + x^{n+1}), y\rangle$.

So: $\text{LHS(III)} - \text{Gap} = \langle K(\bar{x}^n + x^{n+1}), y^{n+1} - y\rangle$.

Therefore:

$$\text{LHS(III)} = \text{Gap} + \langle K(\bar{x}^n + x^{n+1}), y^{n+1} - y\rangle.$$

Hmm, this doesn't simplify nicely either. The issue is that the standard PDHG gap proof does **not** use $\Delta^{n+1} = \mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})$ directly with $\langle Kx^{n+1}, y\rangle$.

**The correct approach:** The per-step gap contribution should use $\langle K\bar{x}^n, y\rangle$ (not $\langle Kx^{n+1}, y\rangle$) in the $\mathcal{L}$ evaluation. This is the key: we form a **modified gap** at each step, then use Jensen's inequality at the end.

Define the per-step modified gap:

$$\widetilde{\Delta}^{n+1} := g(x^{n+1}) + \langle K\bar{x}^n, y\rangle - f^*(y) - [g(x) + \langle Kx, y^{n+1}\rangle - f^*(y^{n+1})]$$

$$= [g(x^{n+1}) - g(x)] + [f^*(y^{n+1}) - f^*(y)] + \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle.$$

Then from (I) + (II), and noting the bilinear terms:

$$\text{LHS(III)} = [g(x^{n+1}) - g(x)] + [f^*(y^{n+1}) - f^*(y)] + \langle K\bar{x}^n, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle + \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle$$

$$= \widetilde{\Delta}^{n+1} + 2\langle K\bar{x}^n, y^{n+1}\rangle - 2\langle K\bar{x}^n, y\rangle + ...$$

This still isn't clean. Let me try yet another approach: go **directly** from (I) and (II) without trying to form the gap first.

---

## PROOF (CLEAN, FINAL)

### Step 1

Fix $(x, y)$. Define $\Phi^n = \frac{\|x - x^n\|^2}{2\tau} + \frac{\|y - y^n\|^2}{2\sigma}$.

### Step 2: From VI to Telescoping

From (I): $\langle K\bar{x}^n, y^{n+1} - y\rangle + f^*(y^{n+1}) - f^*(y) \leq \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle.$

From (II): $-\langle Kx - Kx^{n+1}, y^{n+1}\rangle + g(x^{n+1}) - g(x) \leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle.$

i.e., $\langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle + g(x^{n+1}) - g(x) \leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle.$

Now in (I), decompose: $\langle K\bar{x}^n, y^{n+1} - y\rangle = \langle Kx^{n+1}, y^{n+1} - y\rangle + \langle K(\bar{x}^n - x^{n+1}), y^{n+1} - y\rangle.$

Further decompose: $\langle K(\bar{x}^n - x^{n+1}), y^{n+1} - y\rangle = \langle K(\bar{x}^n - x^{n+1}), y^{n+1} - y^n\rangle + \langle K(\bar{x}^n - x^{n+1}), y^n - y\rangle.$

So (I) becomes:

$$\langle Kx^{n+1}, y^{n+1} - y\rangle + \langle K(\bar{x}^n - x^{n+1}), y^{n+1} - y^n\rangle + \langle K(\bar{x}^n - x^{n+1}), y^n - y\rangle + f^*(y^{n+1}) - f^*(y) \leq \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle. \tag{I'}$$

This decomposition is introducing more complexity. I need a fundamentally different strategy.

---

**THE CORRECT APPROACH**: Don't try to form the standard saddle-point gap at each iteration. Instead, add up modified quantities and use convexity at the end.

### Step 2 (Correct version)

From (I): For all $y$:

$$f^*(y^{n+1}) - f^*(y) + \langle K\bar{x}^n, y^{n+1} - y\rangle \leq \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle. \tag{I}$$

Apply three-point identity to RHS of (I):

$$\frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle = \frac{1}{2\sigma}\left[\|y - y^n\|^2 - \|y - y^{n+1}\|^2 - \|y^{n+1} - y^n\|^2\right]. \tag{I-rhs}$$

From (II): For all $x$:

$$g(x^{n+1}) - g(x) + \langle Kx^{n+1} - Kx, y^{n+1}\rangle \leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle. \tag{II}$$

i.e.: $g(x^{n+1}) - g(x) - \langle Kx, y^{n+1}\rangle + \langle Kx^{n+1}, y^{n+1}\rangle \leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle.$

Apply three-point identity to RHS of (II):

$$\frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle = \frac{1}{2\tau}\left[\|x - x^n\|^2 - \|x - x^{n+1}\|^2 - \|x^{n+1} - x^n\|^2\right]. \tag{II-rhs}$$

**Add (I) and (II):**

$$f^*(y^{n+1}) - f^*(y) + \langle K\bar{x}^n, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle + g(x^{n+1}) - g(x) - \langle Kx, y^{n+1}\rangle + \langle Kx^{n+1}, y^{n+1}\rangle$$

$$\leq (\Phi^n - \Phi^{n+1}) - \frac{\|x^{n+1} - x^n\|^2}{2\tau} - \frac{\|y^{n+1} - y^n\|^2}{2\sigma}.$$

Rearrange the LHS. Collect the terms not involving $y^{n+1}$ in the bilinear part, and those involving $y^{n+1}$:

$$\text{LHS} = g(x^{n+1}) - g(x) - \langle K\bar{x}^n, y\rangle + [f^*(y^{n+1}) - f^*(y)] + \langle K\bar{x}^n + Kx^{n+1} - Kx, y^{n+1}\rangle$$

$$= g(x^{n+1}) - g(x) - \langle K\bar{x}^n, y\rangle - f^*(y) + f^*(y^{n+1}) + \langle K(\bar{x}^n + x^{n+1} - x), y^{n+1}\rangle.$$

Now define the **per-step saddle-point quantity**. The idea is that after summing over $n$ and using Jensen, we want to relate the average to the restricted gap. The key observation is:

**Add and subtract** $\langle Kx^{n+1}, y\rangle$ in the LHS:

$$\text{LHS} = \underbrace{g(x^{n+1}) + \langle Kx^{n+1}, y\rangle - f^*(y)}_{\mathcal{L}(x^{n+1}, y)} - g(x) - \langle Kx^{n+1}, y\rangle - \langle K\bar{x}^n, y\rangle + f^*(y^{n+1}) + \langle K(\bar{x}^n + x^{n+1} - x), y^{n+1}\rangle.$$

Hmm. This approach is just going in circles because the asymmetry between $\bar{x}^n$ (in the $y$-update) and $x^{n+1}$ (in the gap) creates a persistent coupling term.

**THE REAL KEY INSIGHT (Chambolle-Pock 2011 Theorem 1):** The proof works by showing a per-step inequality involving a **modified** Lagrangian quantity, not the standard gap directly. Specifically:

$$g(x^{n+1}) - g(x) + f^*(y^{n+1}) - f^*(y) + \langle K\bar{x}^n, y^{n+1} - y\rangle - \langle Kx, y^{n+1} - y^{n+1}\rangle$$

Wait, let me look at this completely differently.

**From (I):** $-\langle K\bar{x}^n, y\rangle + f^*(y^{n+1}) \leq f^*(y) - \langle K\bar{x}^n, y^{n+1}\rangle + \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle$.

Hmm. Let me just write (I) and (II) as:

**(I):** $\langle K\bar{x}^n, y\rangle + f^*(y) \geq \langle K\bar{x}^n, y^{n+1}\rangle + f^*(y^{n+1}) + \frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle$

(flip sign of (I))

**(II):** $-\langle Kx, y^{n+1}\rangle + g(x) \geq -\langle Kx^{n+1}, y^{n+1}\rangle + g(x^{n+1}) + \frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle$

(flip sign of (II))

Add:

$$\langle K\bar{x}^n, y\rangle + f^*(y) - \langle Kx, y^{n+1}\rangle + g(x) \geq \langle K(\bar{x}^n - x^{n+1}), y^{n+1}\rangle + f^*(y^{n+1}) + g(x^{n+1}) + \frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle + \frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle. \tag{V}$$

The LHS involves $\langle K\bar{x}^n, y\rangle$ instead of $\langle Kx, y\rangle$. That's fine — we'll deal with this when we sum.

From (V), using three-point identity on the inner products:

$$\frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle = \frac{1}{2\sigma}[\|y - y^{n+1}\|^2 + \|y^{n+1} - y^n\|^2 - \|y - y^n\|^2]$$

$$= -\frac{1}{2\sigma}[\|y - y^n\|^2 - \|y - y^{n+1}\|^2] + \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2.$$

Wait: $\langle y^n - y^{n+1}, y - y^{n+1}\rangle = \langle -(y^{n+1} - y^n), y - y^{n+1}\rangle = -\langle y^{n+1} - y^n, y - y^{n+1}\rangle$.

And $\langle y^{n+1} - y^n, y - y^{n+1}\rangle = \frac{1}{2}[\|y - y^n\|^2 - \|y - y^{n+1}\|^2 - \|y^{n+1} - y^n\|^2]$.

So $\langle y^n - y^{n+1}, y - y^{n+1}\rangle = -\frac{1}{2}[\|y - y^n\|^2 - \|y - y^{n+1}\|^2 - \|y^{n+1} - y^n\|^2] = \frac{1}{2}[\|y - y^{n+1}\|^2 + \|y^{n+1} - y^n\|^2 - \|y - y^n\|^2]$.

Similarly: $\langle x^n - x^{n+1}, x - x^{n+1}\rangle = \frac{1}{2}[\|x - x^{n+1}\|^2 + \|x^{n+1} - x^n\|^2 - \|x - x^n\|^2]$.

So the distance terms in (V) give:

$$\frac{1}{2\sigma}[\|y - y^{n+1}\|^2 - \|y - y^n\|^2] + \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2 + \frac{1}{2\tau}[\|x - x^{n+1}\|^2 - \|x - x^n\|^2] + \frac{1}{2\tau}\|x^{n+1} - x^n\|^2$$

$$= -(\Phi^n - \Phi^{n+1}) + \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2 + \frac{1}{2\tau}\|x^{n+1} - x^n\|^2.$$

So (V) becomes:

$$\langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle + f^*(y) + g(x)$$

$$\geq g(x^{n+1}) + f^*(y^{n+1}) + \langle K(\bar{x}^n - x^{n+1}), y^{n+1}\rangle - (\Phi^n - \Phi^{n+1}) + \frac{\|y^{n+1} - y^n\|^2}{2\sigma} + \frac{\|x^{n+1} - x^n\|^2}{2\tau}.$$

Rearranging:

$$\langle K\bar{x}^n, y\rangle + g(x) + f^*(y) - \langle Kx, y^{n+1}\rangle - g(x^{n+1}) - f^*(y^{n+1}) - \langle K(\bar{x}^n - x^{n+1}), y^{n+1}\rangle$$

$$\geq -(\Phi^n - \Phi^{n+1}) + \frac{\|y^{n+1} - y^n\|^2}{2\sigma} + \frac{\|x^{n+1} - x^n\|^2}{2\tau}.$$

$$\Phi^n - \Phi^{n+1} \geq -\text{LHS} + \frac{\|y^{n+1}-y^n\|^2}{2\sigma} + \frac{\|x^{n+1}-x^n\|^2}{2\tau}$$

where "LHS" = the expression on the left above.

This is correct but messy. Let me reorganize the "LHS":

$$\text{LHS} = g(x) - g(x^{n+1}) + f^*(y) - f^*(y^{n+1}) + \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle - \langle K(\bar{x}^n - x^{n+1}), y^{n+1}\rangle.$$

Note: $-\langle Kx, y^{n+1}\rangle - \langle K(\bar{x}^n - x^{n+1}), y^{n+1}\rangle = -\langle K(x + \bar{x}^n - x^{n+1}), y^{n+1}\rangle$.

So:

$$\text{LHS} = g(x) - g(x^{n+1}) + f^*(y) - f^*(y^{n+1}) + \langle K\bar{x}^n, y\rangle - \langle K(x + \bar{x}^n - x^{n+1}), y^{n+1}\rangle.$$

Observe that the "gap" we want is $\mathcal{L}(x, y^{n+1}) - \mathcal{L}(x^{n+1}, y) = g(x) - g(x^{n+1}) + \langle Kx, y^{n+1}\rangle - \langle Kx^{n+1}, y\rangle + f^*(y) - f^*(y^{n+1})$ (note this is the negative of $\Delta^{n+1}$).

Wait, I realize I should try a **completely different, cleaner formulation**. Let me use the approach from **Condat (2013)** / **Chambolle-Pock original** where we avoid forming the gap explicitly and instead telescope a modified quantity.

---

## PROOF — FINAL CLEAN VERSION

### Step 1: Notation and Setup

Fix arbitrary $(x, y) \in X \times Y$.

**Lyapunov function:**
$$\Phi^n = \frac{\|x - x^n\|^2}{2\tau} + \frac{\|y - y^n\|^2}{2\sigma}.$$

### Step 2: Prox Optimality (Moreau Envelope Inequality)

**Fundamental prox inequality:** If $p = \text{prox}_{\alpha h}(v)$, then for all $z$:

$$h(z) + \frac{1}{2\alpha}\|z - v\|^2 \geq h(p) + \frac{1}{2\alpha}\|p - v\|^2 + \frac{1}{2\alpha}\|z - p\|^2. \tag{Prox}$$

This follows from the firm nonexpansiveness of the prox operator, or equivalently by noting that the minimand $h(\cdot) + \frac{1}{2\alpha}\|\cdot - v\|^2$ is $\frac{1}{\alpha}$-strongly convex.

**Apply (Prox) to $y$-update** ($h = f^*$, $\alpha = \sigma$, $v = y^n + \sigma K\bar{x}^n$, $p = y^{n+1}$, $z = y$):

$$f^*(y) + \frac{1}{2\sigma}\|y - y^n - \sigma K\bar{x}^n\|^2 \geq f^*(y^{n+1}) + \frac{1}{2\sigma}\|y^{n+1} - y^n - \sigma K\bar{x}^n\|^2 + \frac{1}{2\sigma}\|y - y^{n+1}\|^2.$$

Expand the squared terms:

$$\|y - y^n - \sigma K\bar{x}^n\|^2 = \|y - y^n\|^2 - 2\sigma\langle K\bar{x}^n, y - y^n\rangle + \sigma^2\|K\bar{x}^n\|^2$$
$$\|y^{n+1} - y^n - \sigma K\bar{x}^n\|^2 = \|y^{n+1} - y^n\|^2 - 2\sigma\langle K\bar{x}^n, y^{n+1} - y^n\rangle + \sigma^2\|K\bar{x}^n\|^2$$

Subtracting, the $\sigma^2\|K\bar{x}^n\|^2$ terms cancel:

$$f^*(y) + \frac{1}{2\sigma}\|y - y^n\|^2 - \langle K\bar{x}^n, y - y^n\rangle \geq f^*(y^{n+1}) + \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2 - \langle K\bar{x}^n, y^{n+1} - y^n\rangle + \frac{1}{2\sigma}\|y - y^{n+1}\|^2.$$

Rearranging:

$$f^*(y) - f^*(y^{n+1}) + \frac{1}{2\sigma}\|y - y^n\|^2 - \frac{1}{2\sigma}\|y - y^{n+1}\|^2 - \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2 \geq \langle K\bar{x}^n, y - y^n\rangle - \langle K\bar{x}^n, y^{n+1} - y^n\rangle = \langle K\bar{x}^n, y - y^{n+1}\rangle.$$

So:

$$\boxed{f^*(y) - f^*(y^{n+1}) + \frac{1}{2\sigma}[\|y - y^n\|^2 - \|y - y^{n+1}\|^2] - \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2 \geq \langle K\bar{x}^n, y - y^{n+1}\rangle.} \tag{Y}$$

**Apply (Prox) to $x$-update** ($h = g$, $\alpha = \tau$, $v = x^n - \tau K^*y^{n+1}$, $p = x^{n+1}$, $z = x$):

$$g(x) + \frac{1}{2\tau}\|x - x^n + \tau K^*y^{n+1}\|^2 \geq g(x^{n+1}) + \frac{1}{2\tau}\|x^{n+1} - x^n + \tau K^*y^{n+1}\|^2 + \frac{1}{2\tau}\|x - x^{n+1}\|^2.$$

Expand:
$$\|x - x^n + \tau K^*y^{n+1}\|^2 = \|x - x^n\|^2 + 2\tau\langle K^*y^{n+1}, x - x^n\rangle + \tau^2\|K^*y^{n+1}\|^2$$
$$\|x^{n+1} - x^n + \tau K^*y^{n+1}\|^2 = \|x^{n+1} - x^n\|^2 + 2\tau\langle K^*y^{n+1}, x^{n+1} - x^n\rangle + \tau^2\|K^*y^{n+1}\|^2$$

Cancelling $\tau^2\|K^*y^{n+1}\|^2/(2\tau)$:

$$g(x) + \frac{1}{2\tau}\|x - x^n\|^2 + \langle K^*y^{n+1}, x - x^n\rangle \geq g(x^{n+1}) + \frac{1}{2\tau}\|x^{n+1} - x^n\|^2 + \langle K^*y^{n+1}, x^{n+1} - x^n\rangle + \frac{1}{2\tau}\|x - x^{n+1}\|^2.$$

Rearranging:

$$g(x) - g(x^{n+1}) + \frac{1}{2\tau}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2] - \frac{1}{2\tau}\|x^{n+1} - x^n\|^2 \geq \langle K^*y^{n+1}, x^{n+1} - x\rangle.$$

Note: $\langle K^*y^{n+1}, x - x^n\rangle - \langle K^*y^{n+1}, x^{n+1} - x^n\rangle = \langle K^*y^{n+1}, x - x^{n+1}\rangle = -\langle K^*y^{n+1}, x^{n+1} - x\rangle$. ✓

$$\boxed{g(x) - g(x^{n+1}) + \frac{1}{2\tau}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2] - \frac{1}{2\tau}\|x^{n+1} - x^n\|^2 \geq \langle K^*y^{n+1}, x^{n+1} - x\rangle.} \tag{X}$$

### Step 3: Add (X) and (Y)

Adding inequalities (Y) and (X):

$$[f^*(y) - f^*(y^{n+1})] + [g(x) - g(x^{n+1})]$$
$$+ \frac{1}{2\sigma}[\|y - y^n\|^2 - \|y - y^{n+1}\|^2] + \frac{1}{2\tau}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2]$$
$$- \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2 - \frac{1}{2\tau}\|x^{n+1} - x^n\|^2$$

$$\geq \langle K\bar{x}^n, y - y^{n+1}\rangle + \langle K^*y^{n+1}, x^{n+1} - x\rangle.$$

The LHS distance terms give $\Phi^n - \Phi^{n+1} - \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2 - \frac{1}{2\tau}\|x^{n+1} - x^n\|^2$.

The RHS coupling: $\langle K\bar{x}^n, y - y^{n+1}\rangle + \langle K^*y^{n+1}, x^{n+1} - x\rangle = \langle K\bar{x}^n, y - y^{n+1}\rangle + \langle Kx^{n+1} - Kx, y^{n+1}\rangle$

$= \langle K\bar{x}^n, y\rangle - \langle K\bar{x}^n, y^{n+1}\rangle + \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle$

$= \langle K\bar{x}^n, y\rangle + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle.$

So:

$$f^*(y) - f^*(y^{n+1}) + g(x) - g(x^{n+1}) + \Phi^n - \Phi^{n+1} - \frac{\|y^{n+1} - y^n\|^2}{2\sigma} - \frac{\|x^{n+1} - x^n\|^2}{2\tau}$$

$$\geq \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle.$$

Move the function values and bilinear gap terms to the RHS:

$$\Phi^n - \Phi^{n+1} - \frac{\|y^{n+1} - y^n\|^2}{2\sigma} - \frac{\|x^{n+1} - x^n\|^2}{2\tau}$$

$$\geq g(x^{n+1}) - g(x) + f^*(y^{n+1}) - f^*(y) + \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$$

$$= g(x^{n+1}) - g(x) - f^*(y) + f^*(y^{n+1}) + \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle. \tag{$\star$}$$

Now define the **per-step saddle contribution**:

$$S_n := g(x^{n+1}) + \langle Kx^{n+1}, y\rangle - f^*(y) - [g(x) + \langle Kx, y^{n+1}\rangle - f^*(y^{n+1})]$$
$$= g(x^{n+1}) - g(x) - f^*(y) + f^*(y^{n+1}) + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle.$$

Then: RHS of ($\star$) = $S_n + \langle K\bar{x}^n - Kx^{n+1}, y\rangle + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$

$= S_n + \langle K(\bar{x}^n - x^{n+1}), y\rangle + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$

$= S_n + \langle K(\bar{x}^n - x^{n+1}), y - y^{n+1}\rangle$

$= S_n - \langle K(x^{n+1} - \bar{x}^n), y - y^{n+1}\rangle.$

So ($\star$) becomes:

$$\Phi^n - \Phi^{n+1} - \frac{\|y^{n+1} - y^n\|^2}{2\sigma} - \frac{\|x^{n+1} - x^n\|^2}{2\tau} \geq S_n - \langle K(x^{n+1} - \bar{x}^n), y - y^{n+1}\rangle. \tag{$\star\star$}$$

### Step 4: Handle the Extrapolation Coupling Term

The term $\langle K(x^{n+1} - \bar{x}^n), y - y^{n+1}\rangle$ involves the test point $y$, so we cannot simply absorb it into residuals. **The key trick** is to split $y - y^{n+1} = (y - y^n) + (y^n - y^{n+1})$ and handle each part.

**Wait — actually, let's reconsider.** Note that $\bar{x}^n = 2x^n - x^{n-1}$, so:

$$x^{n+1} - \bar{x}^n = x^{n+1} - 2x^n + x^{n-1} = (x^{n+1} - x^n) - (x^n - x^{n-1}).$$

The coupling term becomes:

$$-\langle K(x^{n+1} - \bar{x}^n), y - y^{n+1}\rangle = -\langle K[(x^{n+1} - x^n) - (x^n - x^{n-1})], y - y^{n+1}\rangle.$$

This still involves $y$. The standard approach is instead to handle the coupling directly as follows.

**Split the $y^{n+1}$ in the coupling differently.** Write:

$$-\langle K(x^{n+1} - \bar{x}^n), y - y^{n+1}\rangle = \langle K(\bar{x}^n - x^{n+1}), y - y^{n+1}\rangle$$

$$= \langle K(\bar{x}^n - x^{n+1}), y - y^n\rangle + \langle K(\bar{x}^n - x^{n+1}), y^n - y^{n+1}\rangle. \tag{Split}$$

Now $\bar{x}^n - x^{n+1}$: recall $\bar{x}^{n-1} = 2x^{n-1} - x^{n-2}$ (we'll use this for $n \geq 2$; handle $n=0,1$ boundary cases separately or note $\bar{x}^0 = x^0$).

For $n \geq 1$: $\bar{x}^n = 2x^n - x^{n-1}$. But $\bar{x}^n - x^{n+1}$ doesn't obviously relate to a previous $\bar{x}^{n-1} - x^n$ in a telescoping way.

**The correct approach (Chambolle-Pock 2011, proof of Theorem 1):** Instead of trying to make the coupling telescope, we bound it using **Young's inequality** and absorb into the squared residual terms.

From ($\star\star$):

$$S_n \leq \Phi^n - \Phi^{n+1} - \frac{\|y^{n+1} - y^n\|^2}{2\sigma} - \frac{\|x^{n+1} - x^n\|^2}{2\tau} + \langle K(x^{n+1} - \bar{x}^n), y - y^{n+1}\rangle.$$

But $y - y^{n+1}$ involves the test point, so Young's inequality would give terms with $\|y - y^{n+1}\|^2$ which don't telescope nicely.

**Aha — the correct approach is to not split the coupling from the test point at all, but instead to note that when we sum over $n$, the $\bar{x}^n$ terms telescope!**

### Step 4 (Correct): Summing and Using the Extrapolation Structure

Go back to ($\star$) in its original form:

$$\Phi^n - \Phi^{n+1} - \frac{\|y^{n+1} - y^n\|^2}{2\sigma} - \frac{\|x^{n+1} - x^n\|^2}{2\tau}$$

$$\geq g(x^{n+1}) - g(x) - f^*(y) + f^*(y^{n+1}) + \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle.$$

The last term on the RHS: $\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$. Now $\bar{x}^{n+1} = 2x^{n+1} - x^n$, so $x^{n+1} = \frac{1}{2}(\bar{x}^{n+1} + x^n)$ and $x^{n+1} - \bar{x}^n = \frac{1}{2}(\bar{x}^{n+1} + x^n) - \bar{x}^n$.

Alternatively: $x^{n+1} - \bar{x}^n = x^{n+1} - (2x^n - x^{n-1}) = (x^{n+1} - x^n) - (x^n - x^{n-1})$ for $n \geq 1$.

This doesn't directly telescope. Let me try yet another angle.

**The key idea I've been missing:** Instead of bounding $\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$ against the test point, bound it against the **residual** $y^{n+1} - y^n$ using Young's inequality, absorbing the remainder into the squared residual terms.

From ($\star\star$):

$$S_n \leq \Phi^n - \Phi^{n+1} - \frac{\|y^{n+1} - y^n\|^2}{2\sigma} - \frac{\|x^{n+1} - x^n\|^2}{2\tau} + \langle K(x^{n+1} - \bar{x}^n), y - y^{n+1}\rangle.$$

**But we can also write ($\star$) differently.** Going back before we introduced $S_n$, from the original addition of (X) and (Y):

$$g(x) - g(x^{n+1}) + f^*(y) - f^*(y^{n+1}) + (\Phi^n - \Phi^{n+1}) - \frac{\|y^{n+1} - y^n\|^2}{2\sigma} - \frac{\|x^{n+1} - x^n\|^2}{2\tau}$$

$$\geq \langle K\bar{x}^n, y - y^{n+1}\rangle + \langle Kx^{n+1} - Kx, y^{n+1}\rangle. \tag{VI-sum}$$

The RHS of (VI-sum): $\langle K\bar{x}^n, y\rangle - \langle K\bar{x}^n, y^{n+1}\rangle + \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle$.

Now, **the crucial observation**: we want to show that the per-step contribution to the saddle-point gap is bounded by the Lyapunov decrease minus non-negative terms. The right quantity to telescope is not $S_n$ but a modified quantity that accounts for the extrapolation.

**Let me instead define the per-step quantity as:**

$$Q_n := g(x^{n+1}) + \langle K\bar{x}^n, y\rangle - f^*(y) - g(x) - \langle Kx, y^{n+1}\rangle + f^*(y^{n+1}).$$

Then from (VI-sum):

$$(\Phi^n - \Phi^{n+1}) - \frac{\|y^{n+1} - y^n\|^2}{2\sigma} - \frac{\|x^{n+1} - x^n\|^2}{2\tau} \geq Q_n + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle. \tag{$\dagger$}$$

Wait, let me verify: (VI-sum) gives LHS $\geq$ RHS.

LHS of (VI-sum) = $g(x) - g(x^{n+1}) + f^*(y) - f^*(y^{n+1}) + (\Phi^n - \Phi^{n+1}) - ...$

RHS of (VI-sum) = $\langle K\bar{x}^n, y\rangle - \langle K\bar{x}^n, y^{n+1}\rangle + \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle$

$= \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$.

So: $g(x) - g(x^{n+1}) + f^*(y) - f^*(y^{n+1}) + (\Phi^n - \Phi^{n+1}) - \frac{\|y^{n+1} - y^n\|^2}{2\sigma} - \frac{\|x^{n+1} - x^n\|^2}{2\tau} \geq \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle.$

Rearranging:

$$(\Phi^n - \Phi^{n+1}) - \frac{\|y^{n+1}-y^n\|^2}{2\sigma} - \frac{\|x^{n+1}-x^n\|^2}{2\tau}$$

$$\geq [g(x^{n+1}) - g(x)] + [f^*(y^{n+1}) - f^*(y)] + \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$$

$$= Q_n + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle.$$

where $Q_n = g(x^{n+1}) - g(x) + f^*(y^{n+1}) - f^*(y) + \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle.$

Now bound $\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$. Write $x^{n+1} - \bar{x}^n = (x^{n+1} - x^n) - (x^n - x^{n-1})$ for $n \geq 1$. So:

$$\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle = \langle K(x^{n+1} - x^n), y^{n+1}\rangle - \langle K(x^n - x^{n-1}), y^{n+1}\rangle.$$

But we also have $\langle K(x^n - x^{n-1}), y^n\rangle$ from the previous step. This gives a telescoping cross-term!

Specifically, define $T_n := \langle K(x^n - x^{n-1}), y^n\rangle$ for $n \geq 1$, and $T_0 = 0$ (since $\bar{x}^0 = x^0$, i.e., $x^0 - x^{-1}$ doesn't exist; treat as $0$).

Wait, actually for $n = 0$: $\bar{x}^0 = x^0$, so $x^1 - \bar{x}^0 = x^1 - x^0$. And the formula $x^{n+1} - \bar{x}^n = (x^{n+1} - x^n) - (x^n - x^{n-1})$ requires $n \geq 1$.

For $n = 0$: $\langle K(x^1 - \bar{x}^0), y^1\rangle = \langle K(x^1 - x^0), y^1\rangle$.

For $n \geq 1$: $\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle = \langle K(x^{n+1} - x^n), y^{n+1}\rangle - \langle K(x^n - x^{n-1}), y^{n+1}\rangle$.

Now: $\langle K(x^{n+1} - x^n), y^{n+1}\rangle$ and $\langle K(x^n - x^{n-1}), y^{n+1}\rangle$.

The second can be written as $\langle K(x^n - x^{n-1}), y^n\rangle + \langle K(x^n - x^{n-1}), y^{n+1} - y^n\rangle$.

So:
$$\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle = \langle K(x^{n+1} - x^n), y^{n+1}\rangle - \langle K(x^n - x^{n-1}), y^n\rangle - \langle K(x^n - x^{n-1}), y^{n+1} - y^n\rangle.$$

When we sum from $n = 0$ to $N-1$, the terms $\langle K(x^{n+1} - x^n), y^{n+1}\rangle$ and $-\langle K(x^n - x^{n-1}), y^n\rangle$ will telescope!

$$\sum_{n=0}^{N-1} [\langle K(x^{n+1} - x^n), y^{n+1}\rangle - \langle K(x^n - x^{n-1}), y^n\rangle] = \langle K(x^N - x^{N-1}), y^N\rangle - \langle K(x^0 - x^{-1}), y^0\rangle.$$

Since $\bar{x}^0 = x^0$ means effectively $x^{-1} = x^0$ (or the $n=0$ term only has $\langle K(x^1 - x^0), y^1\rangle$), so this telescopes to $\langle K(x^N - x^{N-1}), y^N\rangle$.

Wait, I need to be more careful. For $n = 0$: $x^1 - \bar{x}^0 = x^1 - x^0$, and this equals $(x^1 - x^0) - 0$ if we set $x^{-1} := x^0$. Then $\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle = \langle K(x^{n+1} - x^n), y^{n+1}\rangle - \langle K(x^n - x^{n-1}), y^{n+1}\rangle$ holds for all $n \geq 0$ with $x^{-1} = x^0$.

Sum from $n = 0$ to $N-1$:

$$\sum_{n=0}^{N-1} \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle = \sum_{n=0}^{N-1} [\langle K(x^{n+1} - x^n), y^{n+1}\rangle - \langle K(x^n - x^{n-1}), y^{n+1}\rangle].$$

Write the second term: $-\langle K(x^n - x^{n-1}), y^{n+1}\rangle = -\langle K(x^n - x^{n-1}), y^n\rangle - \langle K(x^n - x^{n-1}), y^{n+1} - y^n\rangle$.

So:

$$= \sum_{n=0}^{N-1} \langle K(x^{n+1} - x^n), y^{n+1}\rangle - \sum_{n=0}^{N-1}\langle K(x^n - x^{n-1}), y^n\rangle - \sum_{n=0}^{N-1}\langle K(x^n - x^{n-1}), y^{n+1} - y^n\rangle.$$

The first two sums telescope:

$$\sum_{n=0}^{N-1}\langle K(x^{n+1} - x^n), y^{n+1}\rangle - \sum_{n=0}^{N-1}\langle K(x^n - x^{n-1}), y^n\rangle$$

Shift index in second sum: let $m = n-1$, then $\sum_{n=0}^{N-1}\langle K(x^n - x^{n-1}), y^n\rangle = \sum_{m=-1}^{N-2}\langle K(x^{m+1} - x^m), y^{m+1}\rangle = \sum_{n=0}^{N-1}\langle K(x^{n+1} - x^n), y^{n+1}\rangle|_{n \to n-1}$.

Actually, let $a_n = \langle K(x^{n+1} - x^n), y^{n+1}\rangle$. Then:

First sum: $\sum_{n=0}^{N-1} a_n = a_0 + a_1 + \cdots + a_{N-1}$.

Second sum: $\sum_{n=0}^{N-1}\langle K(x^n - x^{n-1}), y^n\rangle$. With $x^{-1} = x^0$, the $n=0$ term is $0$. For $n \geq 1$: $\langle K(x^n - x^{n-1}), y^n\rangle = a_{n-1}|_{y^{n+1}\to y^n}$. This is **not** the same as $a_{n-1}$ because $a_{n-1} = \langle K(x^n - x^{n-1}), y^n\rangle$! Wait, yes it is!

$a_{n-1} = \langle K(x^{(n-1)+1} - x^{n-1}), y^{(n-1)+1}\rangle = \langle K(x^n - x^{n-1}), y^n\rangle$. ✓

So: Second sum = $\sum_{n=0}^{N-1}\langle K(x^n - x^{n-1}), y^n\rangle = 0 + \sum_{n=1}^{N-1} a_{n-1} = \sum_{n=0}^{N-2} a_n = a_0 + a_1 + \cdots + a_{N-2}$.

Difference: $\sum_{n=0}^{N-1} a_n - \sum_{n=0}^{N-2} a_n = a_{N-1} = \langle K(x^N - x^{N-1}), y^N\rangle$.

So:

$$\sum_{n=0}^{N-1}\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle = \langle K(x^N - x^{N-1}), y^N\rangle - \sum_{n=0}^{N-1}\langle K(x^n - x^{n-1}), y^{n+1} - y^n\rangle. \tag{Tel}$$

The first term on the right is a **boundary term** and the second is a sum of **cross residual** terms.

Now, summing ($\dagger$) from $n = 0$ to $N-1$:

$$\Phi^0 - \Phi^N - \sum_{n=0}^{N-1}\frac{\|y^{n+1}-y^n\|^2}{2\sigma} - \sum_{n=0}^{N-1}\frac{\|x^{n+1}-x^n\|^2}{2\tau} \geq \sum_{n=0}^{N-1} Q_n + \langle K(x^N - x^{N-1}), y^N\rangle - \sum_{n=0}^{N-1}\langle K(x^n - x^{n-1}), y^{n+1} - y^n\rangle.$$

Now bound the cross residual terms using **Young's inequality**: for any $\mu > 0$,

$$|\langle K(x^n - x^{n-1}), y^{n+1} - y^n\rangle| \leq \|K\|\|x^n - x^{n-1}\|\|y^{n+1} - y^n\| \leq L\|x^n - x^{n-1}\|\|y^{n+1} - y^n\|$$

$$\leq \frac{L}{2}\left(\mu\|x^n - x^{n-1}\|^2 + \frac{1}{\mu}\|y^{n+1} - y^n\|^2\right).$$

Set $\mu = \frac{\sigma}{\tau}$ (so $\frac{L}{2}\mu = \frac{L\sigma}{2\tau}$ and $\frac{L}{2\mu} = \frac{L\tau}{2\sigma}$). Wait, we need to choose $\mu$ such that the resulting terms are absorbed by $\frac{\|x^n - x^{n-1}\|^2}{2\tau}$ and $\frac{\|y^{n+1} - y^n\|^2}{2\sigma}$. We need:

$$\frac{L\mu}{2} \leq \frac{1}{2\tau} \quad \text{and} \quad \frac{L}{2\mu} \leq \frac{1}{2\sigma},$$

i.e., $\mu \leq \frac{1}{L\tau}$ and $\mu \geq \frac{L\sigma}{1} = L\sigma$. So we need $L\sigma \leq \frac{1}{L\tau}$, i.e., $\tau\sigma L^2 \leq 1$. Since we assumed $\tau\sigma L^2 < 1$, we can choose $\mu = \frac{1}{\sqrt{\tau/\sigma}} \cdot \frac{1}{L}$... let me pick $\mu$ more carefully.

Actually, let me choose $\mu$ to **exactly** match the coefficients. We want:

$$\frac{L\mu}{2}\|x^n - x^{n-1}\|^2 + \frac{L}{2\mu}\|y^{n+1} - y^n\|^2 \leq \frac{1}{2\tau}\|x^n - x^{n-1}\|^2 + \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2.$$

This requires $L\mu \leq \frac{1}{\tau}$ and $\frac{L}{\mu} \leq \frac{1}{\sigma}$, so $L\sigma \leq \mu \leq \frac{1}{L\tau}$. Existence requires $L\sigma \leq \frac{1}{L\tau}$, i.e., $\tau\sigma L^2 \leq 1$. Under our strict assumption $\tau\sigma L^2 < 1$, we can choose $\mu = \sqrt{\sigma/\tau}$ (the geometric mean). Then $L\mu = L\sqrt{\sigma/\tau}$ and we need $L\sqrt{\sigma/\tau} \leq \frac{1}{\tau}$, i.e., $L\sqrt{\sigma\tau} \leq 1$, i.e., $L^2\sigma\tau \leq 1$. ✓

With $\mu = \sqrt{\sigma/\tau}$:

$$-\langle K(x^n - x^{n-1}), y^{n+1} - y^n\rangle \leq L\|x^n - x^{n-1}\|\|y^{n+1} - y^n\| \leq \frac{L\sqrt{\sigma/\tau}}{2}\|x^n - x^{n-1}\|^2 + \frac{L\sqrt{\tau/\sigma}}{2}\|y^{n+1} - y^n\|^2.$$

Hmm, but we also need the **sign** to work out. The cross term is $-\langle K(x^n - x^{n-1}), y^{n+1} - y^n\rangle$, and we need an **upper bound**, so:

$$-\langle K(x^n - x^{n-1}), y^{n+1} - y^n\rangle \leq |\langle K(x^n - x^{n-1}), y^{n+1} - y^n\rangle| \leq \frac{L\mu}{2}\|x^n - x^{n-1}\|^2 + \frac{L}{2\mu}\|y^{n+1} - y^n\|^2. ✓$$

**BUT WAIT.** We also have the boundary term $\langle K(x^N - x^{N-1}), y^N\rangle$ on the RHS, which involves $y^N$, not a residual. This is problematic because it depends on the iterates, not just the test point.

**The resolution:** The boundary term $\langle K(x^N - x^{N-1}), y^N\rangle$ is **non-negative or non-positive** depending on the iterates, but we can simply **drop it** if it's on the side of the inequality that makes it beneficial to drop, or we need to bound it.

Let me re-examine: from the summed inequality, we have on the RHS:

$$\sum_{n=0}^{N-1} Q_n + \langle K(x^N - x^{N-1}), y^N\rangle - \sum_{n=0}^{N-1}\langle K(x^n - x^{n-1}), y^{n+1} - y^n\rangle.$$

And we want to show $\sum Q_n \leq \Phi^0$ (roughly). So we need an **upper bound** on $\sum Q_n$:

$$\sum_{n=0}^{N-1} Q_n \leq \Phi^0 - \Phi^N - \sum\frac{\|y^{n+1}-y^n\|^2}{2\sigma} - \sum\frac{\|x^{n+1}-x^n\|^2}{2\tau} - \langle K(x^N - x^{N-1}), y^N\rangle + \sum\langle K(x^n - x^{n-1}), y^{n+1} - y^n\rangle.$$

Now bound $\sum\langle K(x^n - x^{n-1}), y^{n+1} - y^n\rangle \leq \sum\left[\frac{L\mu}{2}\|x^n - x^{n-1}\|^2 + \frac{L}{2\mu}\|y^{n+1} - y^n\|^2\right]$

$= \frac{L\mu}{2}\sum_{n=0}^{N-1}\|x^n - x^{n-1}\|^2 + \frac{L}{2\mu}\sum_{n=0}^{N-1}\|y^{n+1} - y^n\|^2.$

Note: $\sum_{n=0}^{N-1}\|x^n - x^{n-1}\|^2$. For $n=0$: $\|x^0 - x^{-1}\|^2 = 0$. For $n \geq 1$: $\|x^n - x^{n-1}\|^2$. So this sum = $\sum_{n=1}^{N-1}\|x^n - x^{n-1}\|^2 = \sum_{m=0}^{N-2}\|x^{m+1} - x^m\|^2$ (shift by 1).

And $\sum_{n=0}^{N-1}\|x^{n+1} - x^n\|^2/(2\tau)$ is over $n = 0, \ldots, N-1$, giving terms with $\|x^1 - x^0\|^2, \ldots, \|x^N - x^{N-1}\|^2$.

So:

$$-\sum_{n=0}^{N-1}\frac{\|x^{n+1} - x^n\|^2}{2\tau} + \frac{L\mu}{2}\sum_{n=0}^{N-1}\|x^n - x^{n-1}\|^2$$

$$= -\sum_{n=0}^{N-1}\frac{\|x^{n+1} - x^n\|^2}{2\tau} + \frac{L\mu}{2}\sum_{n=0}^{N-2}\|x^{n+1} - x^n\|^2$$

$$= -\frac{\|x^N - x^{N-1}\|^2}{2\tau} + \sum_{n=0}^{N-2}\left(\frac{L\mu}{2} - \frac{1}{2\tau}\right)\|x^{n+1} - x^n\|^2.$$

With $L\mu \leq \frac{1}{\tau}$, the sum is $\leq 0$, and the remaining term is $-\frac{\|x^N - x^{N-1}\|^2}{2\tau}$.

Similarly: $-\sum_{n=0}^{N-1}\frac{\|y^{n+1} - y^n\|^2}{2\sigma} + \frac{L}{2\mu}\sum_{n=0}^{N-1}\|y^{n+1} - y^n\|^2 = \sum_{n=0}^{N-1}\left(\frac{L}{2\mu} - \frac{1}{2\sigma}\right)\|y^{n+1} - y^n\|^2 \leq 0$

when $\frac{L}{\mu} \leq \frac{1}{\sigma}$. ✓

So:

$$\sum_{n=0}^{N-1} Q_n \leq \Phi^0 - \Phi^N - \frac{\|x^N - x^{N-1}\|^2}{2\tau} - \langle K(x^N - x^{N-1}), y^N\rangle + \text{(non-positive terms)}.$$

The boundary term $-\langle K(x^N - x^{N-1}), y^N\rangle$ is still there. We can bound:

$$-\langle K(x^N - x^{N-1}), y^N\rangle \leq L\|x^N - x^{N-1}\|\|y^N\|.$$

This involves $\|y^N\|$ and doesn't give us what we want.

**THE ACTUAL RESOLUTION**: For the **ergodic convergence** result, we don't need to handle the boundary term this way. The standard proof actually proceeds by establishing a **simpler per-step inequality** where the coupling term is absorbed directly. Let me follow the actual Chambolle-Pock approach.

---

# PROOF (DEFINITIVE, FOLLOWING THE STANDARD ARGUMENT)

I realize the cleanest path uses a slightly different formulation. Let me present it clearly.

## Theorem Statement

Under the conditions stated, for all $(x, y) \in B$:

$$\mathcal{G}_B(X^N, Y^N) \leq \frac{1}{N}\left(\frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma}\right).$$

## Proof

### Phase 1: Optimality Conditions

From the proximal updates:

**$y$-step:** $\frac{y^n - y^{n+1}}{\sigma} + K\bar{x}^n \in \partial f^*(y^{n+1})$, giving for all $y$:

$$f^*(y) \geq f^*(y^{n+1}) + \left\langle \frac{y^n - y^{n+1}}{\sigma} + K\bar{x}^n, y - y^{n+1}\right\rangle. \tag{1}$$

**$x$-step:** $\frac{x^n - x^{n+1}}{\tau} - K^*y^{n+1} \in \partial g(x^{n+1})$, giving for all $x$:

$$g(x) \geq g(x^{n+1}) + \left\langle \frac{x^n - x^{n+1}}{\tau} - K^*y^{n+1}, x - x^{n+1}\right\rangle. \tag{2}$$

### Phase 2: Form the Per-Step Saddle Inequality

From (1), rearranging:

$$\langle K\bar{x}^n, y - y^{n+1}\rangle \leq f^*(y) - f^*(y^{n+1}) + \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle. \tag{1'}$$

From (2), rearranging:

$$\langle K^*y^{n+1}, x^{n+1} - x\rangle \leq g(x) - g(x^{n+1}) + \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle.$$

Equivalently (using adjointness):

$$\langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle \leq g(x) - g(x^{n+1}) + \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle. \tag{2'}$$

**Add (1') and (2').** We get on the LHS:

$$\langle K\bar{x}^n, y - y^{n+1}\rangle + \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle$$

$$= \langle K\bar{x}^n, y\rangle - \langle K\bar{x}^n, y^{n+1}\rangle + \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle$$

$$= \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle.$$

And on the RHS:

$$f^*(y) - f^*(y^{n+1}) + g(x) - g(x^{n+1}) + \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle + \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle.$$

So:

$$\langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle \leq [f^*(y) + g(x)] - [f^*(y^{n+1}) + g(x^{n+1})]$$

$$+ \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle + \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle. \tag{3}$$

Define the **per-step saddle contribution**:

$$\mathcal{S}_n := \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle + g(x^{n+1}) - g(x) + f^*(y^{n+1}) - f^*(y).$$

Note this is **not** the standard gap $\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})$ because we have $\langle K\bar{x}^n, y\rangle$ instead of $\langle Kx^{n+1}, y\rangle$.

From (3):

$$\mathcal{S}_n + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle \leq \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle + \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle. \tag{4}$$

### Phase 3: Apply Three-Point Identity

By the identity $\langle a - b, c - a\rangle = \frac{1}{2}[\|c-b\|^2 - \|c-a\|^2 - \|a-b\|^2]$:

$$\frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle = \frac{1}{2\tau}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2 - \|x^{n+1} - x^n\|^2]$$

$$\frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle = \frac{1}{2\sigma}[\|y - y^n\|^2 - \|y - y^{n+1}\|^2 - \|y^{n+1} - y^n\|^2]$$

So (4) becomes:

$$\mathcal{S}_n + \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle \leq (\Phi^n - \Phi^{n+1}) - \frac{\|x^{n+1} - x^n\|^2}{2\tau} - \frac{\|y^{n+1} - y^n\|^2}{2\sigma}. \tag{5}$$

### Phase 4: Sum Over $n = 0, \ldots, N-1$ and Handle Extrapolation

Sum (5):

$$\sum_{n=0}^{N-1}\mathcal{S}_n + \sum_{n=0}^{N-1}\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle \leq \Phi^0 - \Phi^N - \sum_{n=0}^{N-1}\frac{\|x^{n+1} - x^n\|^2}{2\tau} - \sum_{n=0}^{N-1}\frac{\|y^{n+1} - y^n\|^2}{2\sigma}. \tag{6}$$

**Handle the cross term $\sum\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$.** 

Using $\bar{x}^n = 2x^n - x^{n-1}$ (with convention $x^{-1} = x^0$):

$$x^{n+1} - \bar{x}^n = (x^{n+1} - x^n) - (x^n - x^{n-1}).$$

Define $d^n := x^{n+1} - x^n$. Then $x^{n+1} - \bar{x}^n = d^n - d^{n-1}$.

$$\sum_{n=0}^{N-1}\langle K(d^n - d^{n-1}), y^{n+1}\rangle = \sum_{n=0}^{N-1}\langle Kd^n, y^{n+1}\rangle - \sum_{n=0}^{N-1}\langle Kd^{n-1}, y^{n+1}\rangle.$$

Since $d^{-1} = x^0 - x^{-1} = 0$:

Second sum: $\sum_{n=0}^{N-1}\langle Kd^{n-1}, y^{n+1}\rangle = \sum_{n=1}^{N-1}\langle Kd^{n-1}, y^{n+1}\rangle = \sum_{m=0}^{N-2}\langle Kd^m, y^{m+2}\rangle$ (shift $m = n-1$).

First sum: $\sum_{n=0}^{N-1}\langle Kd^n, y^{n+1}\rangle$.

Difference:

$$\sum_{n=0}^{N-1}\langle Kd^n, y^{n+1}\rangle - \sum_{m=0}^{N-2}\langle Kd^m, y^{m+2}\rangle$$

$$= \langle Kd^{N-1}, y^N\rangle + \sum_{n=0}^{N-2}\langle Kd^n, y^{n+1}\rangle - \sum_{n=0}^{N-2}\langle Kd^n, y^{n+2}\rangle$$

$$= \langle Kd^{N-1}, y^N\rangle + \sum_{n=0}^{N-2}\langle Kd^n, y^{n+1} - y^{n+2}\rangle$$

$$= \langle Kd^{N-1}, y^N\rangle - \sum_{n=0}^{N-2}\langle Kd^n, y^{n+2} - y^{n+1}\rangle.$$

Define $e^n := y^{n+1} - y^n$, so $y^{n+2} - y^{n+1} = e^{n+1}$:

$$= \langle Kd^{N-1}, y^N\rangle - \sum_{n=0}^{N-2}\langle Kd^n, e^{n+1}\rangle. \tag{7}$$

Now bound the cross terms $\langle Kd^n, e^{n+1}\rangle$ using Young's inequality:

$$|\langle Kd^n, e^{n+1}\rangle| \leq L\|d^n\|\|e^{n+1}\| \leq \frac{L}{2}\left(\frac{1}{\alpha}\|d^n\|^2 + \alpha\|e^{n+1}\|^2\right)$$

for any $\alpha > 0$. Choose $\alpha = \frac{\tau}{\sigma}$... actually, we need to match with the coefficients $\frac{1}{2\tau}$ and $\frac{1}{2\sigma}$. We need:

$$\frac{L}{2\alpha}\|d^n\|^2 \leq \frac{1}{2\tau}\|d^n\|^2 \quad \Leftrightarrow \quad \alpha \geq L\tau,$$
$$\frac{L\alpha}{2}\|e^{n+1}\|^2 \leq \frac{1}{2\sigma}\|e^{n+1}\|^2 \quad \Leftrightarrow \quad \alpha \leq \frac{1}{L\sigma}.$$

Existence: $L\tau \leq \frac{1}{L\sigma}$ iff $\tau\sigma L^2 \leq 1$. ✓ (strict inequality gives slack).

Choose $\alpha = \sqrt{\frac{\tau}{\sigma}} \cdot \frac{1}{L\sqrt{\tau\sigma}} = \frac{1}{L\sigma}$... let me just set $\alpha$ so that $\frac{L}{2\alpha} = \frac{1}{2\tau}$ and check $\frac{L\alpha}{2} \leq \frac{1}{2\sigma}$. With $\alpha = L\tau$: $\frac{L \cdot L\tau}{2} = \frac{L^2\tau}{2}$ and we need $\frac{L^2\tau}{2} \leq \frac{1}{2\sigma}$, i.e., $L^2\tau\sigma \leq 1$. ✓

With $\alpha = L\tau$:

$$|\langle Kd^n, e^{n+1}\rangle| \leq \frac{1}{2\tau}\|d^n\|^2 + \frac{L^2\tau}{2}\|e^{n+1}\|^2.$$

Substituting into (6) via (7), and noting the signs (the cross term in (7) has a negative sign which we bound above by the absolute value):

$$\sum_{n=0}^{N-1}\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle = \langle Kd^{N-1}, y^N\rangle - \sum_{n=0}^{N-2}\langle Kd^n, e^{n+1}\rangle.$$

So:

$$-\sum_{n=0}^{N-1}\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle = -\langle Kd^{N-1}, y^N\rangle + \sum_{n=0}^{N-2}\langle Kd^n, e^{n+1}\rangle.$$

From (6): $\sum \mathcal{S}_n \leq \Phi^0 - \Phi^N - \sum\frac{\|d^n\|^2}{2\tau} - \sum\frac{\|e^n\|^2}{2\sigma} - \sum\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$...

Wait, (6) has $+\sum\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$ on the LHS, so:

$$\sum \mathcal{S}_n \leq \Phi^0 - \Phi^N - \sum\frac{\|d^n\|^2}{2\tau} - \sum\frac{\|e^n\|^2}{2\sigma} - \sum\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle.$$

Wait, let me re-examine (6):

$$\sum \mathcal{S}_n + \sum\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle \leq \Phi^0 - \Phi^N - \sum\frac{\|d^n\|^2}{2\tau} - \sum\frac{\|e^n\|^2}{2\sigma}$$

where $e^n = y^{n+1} - y^n$, $d^n = x^{n+1} - x^n$, and sums are from $n=0$ to $N-1$.

Using (7):

$$\sum \mathcal{S}_n + \langle Kd^{N-1}, y^N\rangle - \sum_{n=0}^{N-2}\langle Kd^n, e^{n+1}\rangle \leq \Phi^0 - \Phi^N - \sum_{n=0}^{N-1}\frac{\|d^n\|^2}{2\tau} - \sum_{n=0}^{N-1}\frac{\|e^n\|^2}{2\sigma}.$$

Bound the cross terms (they appear with $-$ sign on LHS, so we bound $-(-\sum\langle Kd^n, e^{n+1}\rangle)$):

Actually, $-\sum_{n=0}^{N-2}\langle Kd^n, e^{n+1}\rangle$ appears on the LHS. We bound:

$$-\sum_{n=0}^{N-2}\langle Kd^n, e^{n+1}\rangle \geq -\sum_{n=0}^{N-2}|\langle Kd^n, e^{n+1}\rangle| \geq -\sum_{n=0}^{N-2}\left[\frac{\|d^n\|^2}{2\tau} + \frac{L^2\tau}{2}\|e^{n+1}\|^2\right].$$

This gives a **lower bound** on the LHS, which tightens the constraint on $\sum \mathcal{S}_n$... but we want an **upper bound** on $\sum \mathcal{S}_n$.

Let me reorganize. From (6):

$$\sum \mathcal{S}_n \leq \Phi^0 - \Phi^N - \sum_{n=0}^{N-1}\frac{\|d^n\|^2}{2\tau} - \sum_{n=0}^{N-1}\frac{\|e^n\|^2}{2\sigma} - \langle Kd^{N-1}, y^N\rangle + \sum_{n=0}^{N-2}\langle Kd^n, e^{n+1}\rangle. \tag{8}$$

Now bound the cross terms from **above**:

$$\sum_{n=0}^{N-2}\langle Kd^n, e^{n+1}\rangle \leq \sum_{n=0}^{N-2}\left[\frac{\|d^n\|^2}{2\tau} + \frac{L^2\tau}{2}\|e^{n+1}\|^2\right]$$

$$= \sum_{n=0}^{N-2}\frac{\|d^n\|^2}{2\tau} + \frac{L^2\tau}{2}\sum_{n=0}^{N-2}\|e^{n+1}\|^2 = \sum_{n=0}^{N-2}\frac{\|d^n\|^2}{2\tau} + \frac{L^2\tau}{2}\sum_{n=1}^{N-1}\|e^n\|^2. \tag{9}$$

Substituting (9) into (8):

$$\sum \mathcal{S}_n \leq \Phi^0 - \Phi^N - \sum_{n=0}^{N-1}\frac{\|d^n\|^2}{2\tau} - \sum_{n=0}^{N-1}\frac{\|e^n\|^2}{2\sigma} + \sum_{n=0}^{N-2}\frac{\|d^n\|^2}{2\tau} + \frac{L^2\tau}{2}\sum_{n=1}^{N-1}\|e^n\|^2 - \langle Kd^{N-1}, y^N\rangle.$$

Combine the $d^n$ terms: $-\sum_{n=0}^{N-1}\frac{\|d^n\|^2}{2\tau} + \sum_{n=0}^{N-2}\frac{\|d^n\|^2}{2\tau} = -\frac{\|d^{N-1}\|^2}{2\tau}$.

Combine the $e^n$ terms: $-\sum_{n=0}^{N-1}\frac{\|e^n\|^2}{2\sigma} + \frac{L^2\tau}{2}\sum_{n=1}^{N-1}\|e^n\|^2 = -\frac{\|e^0\|^2}{2\sigma} + \sum_{n=1}^{N-1}\left(\frac{L^2\tau}{2} - \frac{1}{2\sigma}\right)\|e^n\|^2$.

Since $L^2\tau\sigma \leq 1$ (strict), $\frac{L^2\tau}{2} \leq \frac{1}{2\sigma}$, so $\left(\frac{L^2\tau}{2} - \frac{1}{2\sigma}\right) \leq 0$.

Therefore:

$$\sum \mathcal{S}_n \leq \Phi^0 - \Phi^N - \frac{\|d^{N-1}\|^2}{2\tau} - \frac{\|e^0\|^2}{2\sigma} - \langle Kd^{N-1}, y^N\rangle + \text{(non-positive terms)}$$

$$\leq \Phi^0 - \frac{\|d^{N-1}\|^2}{2\tau} - \langle Kd^{N-1}, y^N\rangle. \tag{10}$$

(Dropping $-\Phi^N \leq 0$, $-\frac{\|e^0\|^2}{2\sigma} \leq 0$, and other non-positive terms.)

**Handle the boundary term** $-\frac{\|d^{N-1}\|^2}{2\tau} - \langle Kd^{N-1}, y^N\rangle$:

$$-\frac{\|d^{N-1}\|^2}{2\tau} - \langle Kd^{N-1}, y^N\rangle \leq -\frac{\|d^{N-1}\|^2}{2\tau} + L\|d^{N-1}\|\|y^N\|.$$

This doesn't simply vanish. But we can bound differently. **The boundary term is not eliminated this way.** 

This suggests the approach of bounding the cross terms one by one may not be optimal. Let me reconsider.

**Alternative approach to the cross terms:** Instead of Young's inequality, use a **different decomposition** of the telescoping sum.

Actually, I realize there's a much simpler approach that avoids the entire extrapolation difficulty. The key insight in the original Chambolle-Pock paper is:

**One should directly work with $\sum \mathcal{S}_n$ where $\mathcal{S}_n$ uses $\langle K\bar{x}^n, y\rangle$ instead of $\langle Kx^{n+1}, y\rangle$, and then at the very end convert to the ergodic gap using convexity.**

### Phase 4 (Correct): Direct Sum and Convexity Argument

From (5):

$$\mathcal{S}_n \leq (\Phi^n - \Phi^{n+1}) - \frac{\|d^n\|^2}{2\tau} - \frac{\|e^n\|^2}{2\sigma} - \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle. \tag{5}$$

Actually, we can avoid the whole extrapolation difficulty by choosing a different formulation. Let me use (1') and (2') **without combining the coupling terms**.

From (1) with $\hat{y} = y$:

$$f^*(y) - f^*(y^{n+1}) - \langle K\bar{x}^n, y - y^{n+1}\rangle \geq \frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle. \tag{1''}$$

From (2) with $\hat{x} = x$:

$$g(x) - g(x^{n+1}) + \langle K^*y^{n+1}, x - x^{n+1}\rangle \geq \frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle. \tag{2''}$$

Note: The RHS of (1'') has a specific sign. $\langle y^n - y^{n+1}, y - y^{n+1}\rangle = \frac{1}{2}[\|y - y^{n+1}\|^2 + \|y^{n+1} - y^n\|^2 - \|y - y^n\|^2]$.

So: $\frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle = \frac{1}{2\sigma}\|y - y^{n+1}\|^2 + \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2 - \frac{1}{2\sigma}\|y - y^n\|^2 = -\frac{1}{2\sigma}[\|y-y^n\|^2 - \|y-y^{n+1}\|^2] + \frac{1}{2\sigma}\|y^{n+1}-y^n\|^2$.

Hmm, this gives $(\Phi_y^{n+1} - \Phi_y^n) + \frac{1}{2\sigma}\|e^n\|^2$ which has the **wrong sign** for the Lyapunov decrease. 

This confirms: the inner products $\langle y^n - y^{n+1}, y - y^{n+1}\rangle$ and $\langle x^n - x^{n+1}, x - x^{n+1}\rangle$ give distance terms with the **wrong** sign for Lyapunov decrease in the $\geq$ direction. We need them in the $\leq$ direction for the gap.

Let me go back to (5) and handle the boundary term more carefully.

From (10):

$$\sum \mathcal{S}_n \leq \Phi^0 - \frac{\|d^{N-1}\|^2}{2\tau} - \langle Kd^{N-1}, y^N\rangle.$$

For the boundary: by completing the square,

$$-\frac{\|d^{N-1}\|^2}{2\tau} - \langle Kd^{N-1}, y^N\rangle = -\frac{1}{2\tau}\|d^{N-1}\|^2 - \langle Kd^{N-1}, y^N\rangle$$

$$= -\frac{1}{2\tau}\|d^{N-1} + \tau K^*y^N\|^2 + \frac{\tau}{2}\|K^*y^N\|^2$$

$$\leq \frac{\tau L^2}{2}\|y^N\|^2.$$

This involves $\|y^N\|^2$, which depends on the iterates and can be large. So this approach does not give the clean bound we want.

**The issue is fundamental:** when we have a boundary term involving iterates, we can't simply bound it by the initial data.

**RESOLUTION:** We need to avoid creating boundary terms altogether. The correct approach is to handle the cross term **within each step** rather than after summing.

Going back to (5) and the term $\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$:

$$\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle = \langle K(x^{n+1} - \bar{x}^n), y^n\rangle + \langle K(x^{n+1} - \bar{x}^n), e^n\rangle.$$

The first term involves the **test-point-independent** quantity... no wait, $y^n$ is an iterate, not the test point $y$.

Actually $y^{n+1} = y^n + e^n$ where $e^n = y^{n+1} - y^n$. So the split is:

$$\langle K(d^n - d^{n-1}), y^{n+1}\rangle = \langle K(d^n - d^{n-1}), y^n + e^n\rangle = \langle K(d^n - d^{n-1}), y^n\rangle + \langle K(d^n - d^{n-1}), e^n\rangle.$$

Bound the second term by Young: $|\langle K(d^n - d^{n-1}), e^n\rangle| \leq L\|d^n - d^{n-1}\|\|e^n\|$.

And $\|d^n - d^{n-1}\| \leq \|d^n\| + \|d^{n-1}\|$, which is also not clean.

I think the cleanest approach is to **not use the He-Yuan Lyapunov framework as originally described** but instead use the well-known simple argument from the Chambolle-Pock paper itself. Let me present **that** proof, which is still within the spirit of Route 3.

---

# FINAL COMPLETE PROOF

The key realization is that the correct per-step inequality should avoid introducing the $\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$ term entirely. This is achieved by using a **modified Lyapunov function** that accounts for the extrapolation.

## Step 1: Modified Lyapunov Function

Define for arbitrary $(x, y) \in X \times Y$:

$$\Phi^n = \frac{\|x - x^n\|^2}{2\tau} + \frac{\|y - y^n\|^2}{2\sigma} + \langle K(x^n - x), y^n - y\rangle. \tag{L}$$

Wait, this is not guaranteed non-negative. Actually, the classical Lyapunov for PDHG with extrapolation uses:

$$\Phi^n = \frac{\|x - x^n\|^2}{2\tau} + \frac{\|y - y^n\|^2}{2\sigma}.$$

But the proof works with the **simple Lyapunov** by carefully handling the cross term. The critical insight I was missing is:

**We should bound $\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$ using the specific form $\bar{x}^n = 2x^n - x^{n-1}$, writing it as a difference of terms that telescope when combined with the squared residuals, using a completion-of-squares argument.**

Let me try once more. From (5), we need to bound $-\langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$ from below (to get an upper bound on $\mathcal{S}_n$).

With $\bar{x}^n = 2x^n - x^{n-1}$: $x^{n+1} - \bar{x}^n = d^n - d^{n-1}$.

$$-\langle K(d^n - d^{n-1}), y^{n+1}\rangle = -\langle Kd^n, y^{n+1}\rangle + \langle Kd^{n-1}, y^{n+1}\rangle.$$

Now: $\langle Kd^{n-1}, y^{n+1}\rangle = \langle Kd^{n-1}, y^n + e^n\rangle = \langle Kd^{n-1}, y^n\rangle + \langle Kd^{n-1}, e^n\rangle$.

And: $-\langle Kd^n, y^{n+1}\rangle = -\langle Kd^n, y^{n+1}\rangle$.

From the **next** step (step $n+1$), we would get a term $\langle Kd^n, y^{n+1}\rangle$ from the "$\langle Kd^{n-1}, y^n\rangle$" contribution. This is the telescoping.

**Define the augmented Lyapunov:**

$$\Psi^n := \Phi^n + \langle Kd^{n-1}, y^n\rangle = \frac{\|x - x^n\|^2}{2\tau} + \frac{\|y - y^n\|^2}{2\sigma} + \langle K(x^n - x^{n-1}), y^n\rangle.$$

with $\Psi^0 = \Phi^0$ (since $d^{-1} = 0$).

Then from (5):

$$\mathcal{S}_n \leq (\Phi^n - \Phi^{n+1}) - \frac{\|d^n\|^2}{2\tau} - \frac{\|e^n\|^2}{2\sigma} + \langle Kd^n, y^{n+1}\rangle - \langle Kd^{n-1}, y^{n+1}\rangle$$

$$= (\Phi^n - \Phi^{n+1}) - \frac{\|d^n\|^2}{2\tau} - \frac{\|e^n\|^2}{2\sigma} + \langle Kd^n, y^{n+1}\rangle - \langle Kd^{n-1}, y^n\rangle - \langle Kd^{n-1}, e^n\rangle$$

$$= (\Phi^n + \langle Kd^{n-1}, y^n\rangle) - (\Phi^{n+1} + \langle Kd^n, y^{n+1}\rangle) + 2\langle Kd^n, y^{n+1}\rangle - \frac{\|d^n\|^2}{2\tau} - \frac{\|e^n\|^2}{2\sigma} - \langle Kd^{n-1}, e^n\rangle.$$

Wait, that gives: $\Phi^n - \Phi^{n+1} + \langle Kd^n, y^{n+1}\rangle - \langle Kd^{n-1}, y^n\rangle - \langle Kd^{n-1}, e^n\rangle$. And $\Psi^{n+1} = \Phi^{n+1} + \langle Kd^n, y^{n+1}\rangle$. So:

$\Phi^n - \Phi^{n+1} + \langle Kd^n, y^{n+1}\rangle = \Phi^n + \langle Kd^n, y^{n+1}\rangle - \Phi^{n+1} = (\Psi^{n+1} - \Phi^{n+1}) + \Phi^n - \Phi^{n+1}$... no.

$\Phi^n - \Phi^{n+1} + \langle Kd^n, y^{n+1}\rangle = \Phi^n - (\Phi^{n+1} - \langle Kd^n, y^{n+1}\rangle) = \Phi^n - \Phi^{n+1} + \langle Kd^n, y^{n+1}\rangle$.

And $\Psi^n = \Phi^n + \langle Kd^{n-1}, y^n\rangle$, $\Psi^{n+1} = \Phi^{n+1} + \langle Kd^n, y^{n+1}\rangle$.

So: $\Psi^n - \Psi^{n+1} = \Phi^n - \Phi^{n+1} + \langle Kd^{n-1}, y^n\rangle - \langle Kd^n, y^{n+1}\rangle$.

Therefore:

$\Phi^n - \Phi^{n+1} + \langle Kd^n, y^{n+1}\rangle - \langle Kd^{n-1}, y^n\rangle = -(\Psi^n - \Psi^{n+1}) + 2\langle Kd^n, y^{n+1}\rangle - 2\langle Kd^{n-1}, y^n\rangle$... no.

$\Phi^n - \Phi^{n+1} = (\Psi^n - \langle Kd^{n-1}, y^n\rangle) - (\Psi^{n+1} - \langle Kd^n, y^{n+1}\rangle) = \Psi^n - \Psi^{n+1} - \langle Kd^{n-1}, y^n\rangle + \langle Kd^n, y^{n+1}\rangle$.

So:

$\Phi^n - \Phi^{n+1} + \langle Kd^n, y^{n+1}\rangle - \langle Kd^{n-1}, y^n\rangle - \langle Kd^{n-1}, e^n\rangle$

$= \Psi^n - \Psi^{n+1} - \langle Kd^{n-1}, y^n\rangle + \langle Kd^n, y^{n+1}\rangle + \langle Kd^n, y^{n+1}\rangle - \langle Kd^{n-1}, y^n\rangle - \langle Kd^{n-1}, e^n\rangle$

$= \Psi^n - \Psi^{n+1} + 2\langle Kd^n, y^{n+1}\rangle - 2\langle Kd^{n-1}, y^n\rangle - \langle Kd^{n-1}, e^n\rangle.$

This is not simplifying. The augmented Lyapunov approach doesn't seem to work cleanly here.

---

**Let me step back and try an entirely different, simpler proof strategy that is still in the spirit of Route 3.**

The fundamental idea: instead of dealing with the extrapolation explicitly, use the fact that **summing $\mathcal{S}_n$ over $n$ and then using convexity gives the desired gap bound**, with the cross terms cancelling or being absorbed. The key is that $\mathcal{S}_n$ already contains the correct quantity for the ergodic bound.

### The Simple Proof

**Recall** from (4) (which I'll re-derive cleanly):

From VIs (1) and (2), setting $\hat{y} = y$ and $\hat{x} = x$:

$$f^*(y) \geq f^*(y^{n+1}) + \frac{1}{\sigma}\langle y^n - y^{n+1}, y - y^{n+1}\rangle + \langle K\bar{x}^n, y - y^{n+1}\rangle$$

$$g(x) \geq g(x^{n+1}) + \frac{1}{\tau}\langle x^n - x^{n+1}, x - x^{n+1}\rangle - \langle K^*y^{n+1}, x - x^{n+1}\rangle$$

Rearrange:

$$g(x^{n+1}) + \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle - g(x) \leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle$$

$$f^*(y^{n+1}) - \langle K\bar{x}^n, y^{n+1}\rangle + \langle K\bar{x}^n, y\rangle - f^*(y) \leq \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle$$

Wait, from the first inequality: $g(x^{n+1}) - g(x) + \langle K^*y^{n+1}, x^{n+1} - x\rangle \leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle$.

Note $\langle K^*y^{n+1}, x^{n+1} - x\rangle = \langle y^{n+1}, K(x^{n+1} - x)\rangle$.

And from the second: $f^*(y^{n+1}) - f^*(y) + \langle K\bar{x}^n, y^{n+1} - y\rangle \leq \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle$.

**Add:**

$$g(x^{n+1}) - g(x) + f^*(y^{n+1}) - f^*(y) + \langle y^{n+1}, K(x^{n+1} - x)\rangle + \langle K\bar{x}^n, y^{n+1} - y\rangle$$

$$\leq \frac{1}{2\tau}[\|x - x^n\|^2 - \|x - x^{n+1}\|^2 - \|d^n\|^2] + \frac{1}{2\sigma}[\|y - y^n\|^2 - \|y - y^{n+1}\|^2 - \|e^n\|^2].$$

LHS = $g(x^{n+1}) - g(x) + f^*(y^{n+1}) - f^*(y) + \langle Kx^{n+1} - Kx, y^{n+1}\rangle + \langle K\bar{x}^n, y^{n+1} - y\rangle$

$= g(x^{n+1}) - g(x) + f^*(y^{n+1}) - f^*(y) + \langle Kx^{n+1}, y^{n+1}\rangle - \langle Kx, y^{n+1}\rangle + \langle K\bar{x}^n, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle$

$= g(x^{n+1}) - g(x) + f^*(y^{n+1}) - f^*(y) - \langle Kx, y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle + \langle K(x^{n+1} + \bar{x}^n), y^{n+1}\rangle$.

Observe: $\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1}) = g(x^{n+1}) - g(x) + f^*(y^{n+1}) - f^*(y) + \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle$.

So: LHS $= [\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})] - \langle Kx^{n+1}, y\rangle + \langle K(x^{n+1} + \bar{x}^n), y^{n+1}\rangle - \langle K\bar{x}^n, y\rangle$

$= \Delta^{n+1} + \langle K\bar{x}^n, y^{n+1} - y\rangle + \langle Kx^{n+1}, y^{n+1} - y\rangle$.

Hmm. This is still complex. Let me try a completely fresh approach, working with the **right** notion of gap from the start.

---

# PROOF (FINAL, CLEAN, WORKING)

## Overview

We establish: for all $(x, y) \in B$,

$$\mathcal{L}(X^N, y) - \mathcal{L}(x, Y^N) \leq \frac{\Phi^0}{N}$$

where $\Phi^0 = \frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma}$.

Since $\mathcal{L}$ is convex in the first argument and concave (i.e., $-\mathcal{L}$ is convex) in the second, and $(X^N, Y^N)$ are arithmetic averages, Jensen's inequality gives:

$$\mathcal{L}(X^N, y) \leq \frac{1}{N}\sum_{n=1}^N \mathcal{L}(x^n, y), \quad -\mathcal{L}(x, Y^N) \leq \frac{1}{N}\sum_{n=1}^N (-\mathcal{L}(x, y^n)).$$

Wait, we need $\mathcal{L}(\cdot, y)$ convex and $\mathcal{L}(x, \cdot)$ concave. Indeed:
- $\mathcal{L}(\cdot, y) = g(\cdot) + \langle K(\cdot), y\rangle - f^*(y)$ is convex (sum of convex $g$ and linear).
- $\mathcal{L}(x, \cdot) = g(x) + \langle Kx, \cdot\rangle - f^*(\cdot)$ is concave ($-f^*$ is concave, $\langle Kx, \cdot\rangle$ is linear).

So by convexity of $\mathcal{L}(\cdot, y)$:

$$\mathcal{L}(X^N, y) \leq \frac{1}{N}\sum_{n=1}^N \mathcal{L}(x^n, y) = \frac{1}{N}\sum_{n=1}^N [g(x^n) + \langle Kx^n, y\rangle - f^*(y)].$$

By concavity of $\mathcal{L}(x, \cdot)$:

$$\mathcal{L}(x, Y^N) \geq \frac{1}{N}\sum_{n=1}^N \mathcal{L}(x, y^n) = \frac{1}{N}\sum_{n=1}^N [g(x) + \langle Kx, y^n\rangle - f^*(y^n)].$$

Therefore:

$$\mathcal{L}(X^N, y) - \mathcal{L}(x, Y^N) \leq \frac{1}{N}\sum_{n=1}^N [\mathcal{L}(x^n, y) - \mathcal{L}(x, y^n)]$$

$$= \frac{1}{N}\sum_{n=1}^N [g(x^n) - g(x) + f^*(y^n) - f^*(y) + \langle Kx^n, y\rangle - \langle Kx, y^n\rangle]. \tag{J}$$

**This is the standard gap, and it uses $\langle Kx^n, y\rangle$, not $\langle K\bar{x}^n, y\rangle$.** So we need per-step bounds on $\mathcal{L}(x^n, y) - \mathcal{L}(x, y^n)$, not on $\mathcal{S}_n$.

But the VI from the $y$-update involves $\bar{x}^{n-1}$ (one step behind). From (1) at step $n-1$: the $y$-update producing $y^n$ uses $\bar{x}^{n-1}$. So the VIs for $(x^n, y^n)$ come from:

**$y$-update at step $n$:** $y^n = \text{prox}_{\sigma f^*}(y^{n-1} + \sigma K\bar{x}^{n-1})$, giving for all $\hat{y}$:

$$f^*(\hat{y}) \geq f^*(y^n) + \langle \frac{y^{n-1} - y^n}{\sigma} + K\bar{x}^{n-1}, \hat{y} - y^n\rangle. \tag{1n}$$

**$x$-update at step $n$:** $x^n = \text{prox}_{\tau g}(x^{n-1} - \tau K^*y^n)$, giving for all $\hat{x}$:

$$g(\hat{x}) \geq g(x^n) + \langle \frac{x^{n-1} - x^n}{\tau} - K^*y^n, \hat{x} - x^n\rangle. \tag{2n}$$

Set $\hat{y} = y$ in (1n) and $\hat{x} = x$ in (2n):

From (1n): $f^*(y) - f^*(y^n) \geq \frac{1}{\sigma}\langle y^{n-1} - y^n, y - y^n\rangle + \langle K\bar{x}^{n-1}, y - y^n\rangle$

From (2n): $g(x) - g(x^n) \geq \frac{1}{\tau}\langle x^{n-1} - x^n, x - x^n\rangle - \langle K^*y^n, x - x^n\rangle$

The second gives: $g(x^n) - g(x) + \langle Kx^n - Kx, y^n\rangle \leq \frac{1}{\tau}\langle x^n - x^{n-1}, x - x^n\rangle$.

Using the three-point identity:
$$\frac{1}{\tau}\langle x^n - x^{n-1}, x - x^n\rangle = \frac{1}{2\tau}[\|x - x^{n-1}\|^2 - \|x - x^n\|^2 - \|x^n - x^{n-1}\|^2].$$

And the first gives: $f^*(y^n) - f^*(y) + \langle K\bar{x}^{n-1}, y^n - y\rangle \leq \frac{1}{\sigma}\langle y^n - y^{n-1}, y - y^n\rangle$.

$$\frac{1}{\sigma}\langle y^n - y^{n-1}, y - y^n\rangle = \frac{1}{2\sigma}[\|y - y^{n-1}\|^2 - \|y - y^n\|^2 - \|y^n - y^{n-1}\|^2].$$

**Add:**

$$g(x^n) - g(x) + f^*(y^n) - f^*(y) + \langle Kx^n, y^n\rangle - \langle Kx, y^n\rangle + \langle K\bar{x}^{n-1}, y^n - y\rangle$$

$$\leq \frac{1}{2\tau}[\|x - x^{n-1}\|^2 - \|x - x^n\|^2 - \|x^n - x^{n-1}\|^2] + \frac{1}{2\sigma}[\|y - y^{n-1}\|^2 - \|y - y^n\|^2 - \|y^n - y^{n-1}\|^2]. \tag{$\star$}$$

Now the LHS:

$$g(x^n) - g(x) + f^*(y^n) - f^*(y) + \langle Kx^n, y^n\rangle - \langle Kx, y^n\rangle + \langle K\bar{x}^{n-1}, y^n\rangle - \langle K\bar{x}^{n-1}, y\rangle.$$

The gap term we want is $\langle Kx^n, y\rangle - \langle Kx, y^n\rangle$, but we have $\langle Kx^n, y^n\rangle - \langle Kx, y^n\rangle + \langle K\bar{x}^{n-1}, y^n\rangle - \langle K\bar{x}^{n-1}, y\rangle$.

$$= \langle K(x^n + \bar{x}^{n-1}), y^n\rangle - \langle Kx, y^n\rangle - \langle K\bar{x}^{n-1}, y\rangle$$

$$= \langle K(x^n + \bar{x}^{n-1} - x), y^n\rangle - \langle K\bar{x}^{n-1}, y\rangle.$$

Now add $\langle Kx^n, y\rangle - \langle Kx^n, y\rangle = 0$:

$$= \langle Kx^n, y\rangle - \langle Kx, y^n\rangle + \langle K(x^n + \bar{x}^{n-1}), y^n\rangle - \langle Kx, y^n\rangle - \langle K\bar{x}^{n-1}, y\rangle - \langle Kx^n, y\rangle + \langle Kx, y^n\rangle$$

This is going in circles again. Let me just compute:

Desired gap = $\langle Kx^n, y\rangle - \langle Kx, y^n\rangle$.

Actual coupling on LHS = $\langle Kx^n, y^n\rangle - \langle Kx, y^n\rangle + \langle K\bar{x}^{n-1}, y^n - y\rangle$

$= \langle Kx^n - Kx + K\bar{x}^{n-1}, y^n\rangle - \langle K\bar{x}^{n-1}, y\rangle$

$= \langle Kx^n - Kx, y^n\rangle + \langle K\bar{x}^{n-1}, y^n - y\rangle.$

Desired coupling = $\langle Kx^n, y\rangle - \langle Kx, y^n\rangle = \langle Kx^n, y - y^n\rangle + \langle Kx^n - Kx, y^n\rangle$.

So: Actual $-$ Desired $= \langle K\bar{x}^{n-1}, y^n - y\rangle - \langle Kx^n, y - y^n\rangle = \langle K\bar{x}^{n-1}, y^n - y\rangle + \langle Kx^n, y^n - y\rangle = \langle K(\bar{x}^{n-1} + x^n), y^n - y\rangle$.

So: Actual = Desired $+ \langle K(\bar{x}^{n-1} + x^n), y^n - y\rangle$.

And: LHS of ($\star$) $= [g(x^n) - g(x) + f^*(y^n) - f^*(y) + \langle Kx^n, y\rangle - \langle Kx, y^n\rangle] + \langle K(\bar{x}^{n-1} + x^n), y^n - y\rangle$

$= \Delta_n + \langle K(\bar{x}^{n-1} + x^n), y^n - y\rangle$

where $\Delta_n = \mathcal{L}(x^n, y) - \mathcal{L}(x, y^n)$.

But $\langle K(\bar{x}^{n-1} + x^n), y^n - y\rangle$ involves the test point $y$ and doesn't telescope.

**I now see that the fundamental issue is the mismatch between $\bar{x}^{n-1}$ in the $y$-update and $x^n$ in the gap.** This is precisely what the extrapolation $\bar{x}^n = 2x^n - x^{n-1}$ is designed to handle.

$\bar{x}^{n-1} = 2x^{n-1} - x^{n-2}$. So $\bar{x}^{n-1} + x^n = 2x^{n-1} - x^{n-2} + x^n$. This is not $2x^n$.

**The correct approach (finally!):** We should **not** try to get a bound on $\sum \Delta_n$, but instead get a bound on $\sum \mathcal{S}_n$ (with $\bar{x}$ terms) and then use a telescoping argument to convert $\sum\langle K\bar{x}^n, y\rangle$ into $\sum\langle Kx^{n+1}, y\rangle$ plus boundary terms.

**From the original (5):** 

$$\mathcal{S}_n \leq (\Phi^n - \Phi^{n+1}) - \frac{\|d^n\|^2}{2\tau} - \frac{\|e^n\|^2}{2\sigma} - \langle K(x^{n+1} - \bar{x}^n), y^{n+1}\rangle$$

where $\mathcal{S}_n = g(x^{n+1}) - g(x) + f^*(y^{n+1}) - f^*(y) + \langle K\bar{x}^n, y\rangle - \langle Kx, y^{n+1}\rangle$.

Now: $\mathcal{S}_n = \Delta^{n+1} + \langle K(\bar{x}^n - x^{n+1}), y\rangle$ where $\Delta^{n+1} = \mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})$.

So: $\sum_{n=0}^{N-1} \mathcal{S}_n = \sum_{n=0}^{N-1}\Delta^{n+1} + \sum_{n=0}^{N-1}\langle K(\bar{x}^n - x^{n+1}), y\rangle$.

**Now compute $\sum_{n=0}^{N-1}\langle K(\bar{x}^n - x^{n+1}), y\rangle$:**

$\bar{x}^n - x^{n+1} = (2x^n - x^{n-1}) - x^{n+1} = -(x^{n+1} - x^n) + (x^n - x^{n-1}) = -d^n + d^{n-1}$ for $n \geq 1$, and $\bar{x}^0 - x^1 = x^0 - x^1 = -d^0$ for $n = 0$.

$\sum_{n=0}^{N-1}(\bar{x}^n - x^{n+1}) = \sum_{n=0}^{N-1}(-d^n + d^{n-1})$ (with $d^{-1} = 0$)

$= -\sum_{n=0}^{N-1}d^n + \sum_{n=0}^{N-1}d^{n-1} = -\sum_{n=0}^{N-1}d^n + \sum_{n=-1}^{N-2}d^n = -\sum_{n=0}^{N-1}d^n + d^{-1} + \sum_{n=0}^{N-2}d^n$

$= -d^{N-1} + 0 = -d^{N-1} = -(x^N - x^{N-1}).$

So: $\sum_{n=0}^{N-1}\langle K(\bar{x}^n - x^{n+1}), y\rangle = -\langle K(x^N - x^{N-1}), y\rangle = \langle K(x^{N-1} - x^N), y\rangle.$

**This is just a single boundary term!** It doesn't grow with $N$.

Therefore:

$$\sum_{n=0}^{N-1}\Delta^{n+1} = \sum_{n=0}^{N-1}\mathcal{S}_n - \langle K(x^{N-1} - x^N), y\rangle. \tag{11}$$

Now from (6) (sum of (5)):

$$\sum_{n=0}^{N-1}\mathcal{S}_n \leq \Phi^0 - \Phi^N - \sum\frac{\|d^n\|^2}{2\tau} - \sum\frac{\|e^n\|^2}{2\sigma} - \sum_{n=0}^{N-1}\langle K(d^n - d^{n-1}), y^{n+1}\rangle. \tag{6}$$

And we showed in (Tel) / (7):

$$\sum_{n=0}^{N-1}\langle K(d^n - d^{n-1}), y^{n+1}\rangle = \langle Kd^{N-1}, y^N\rangle - \sum_{n=0}^{N-2}\langle Kd^n, e^{n+1}\rangle. \tag{7}$$

So from (6):

$$\sum\mathcal{S}_n \leq \Phi^0 - \Phi^N - \sum\frac{\|d^n\|^2}{2\tau} - \sum\frac{\|e^n\|^2}{2\sigma} - \langle Kd^{N-1}, y^N\rangle + \sum_{n=0}^{N-2}\langle Kd^n, e^{n+1}\rangle. \tag{12}$$

From (11) and (12):

$$\sum_{n=1}^N \Delta^n = \sum_{n=0}^{N-1}\Delta^{n+1} \leq \Phi^0 - \Phi^N - \sum\frac{\|d^n\|^2}{2\tau} - \sum\frac{\|e^n\|^2}{2\sigma} - \langle Kd^{N-1}, y^N\rangle + \sum_{n=0}^{N-2}\langle Kd^n, e^{n+1}\rangle - \langle K(x^{N-1} - x^N), y\rangle.$$

The boundary terms: $-\langle Kd^{N-1}, y^N\rangle - \langle K(x^{N-1} - x^N), y\rangle = -\langle Kd^{N-1}, y^N\rangle + \langle Kd^{N-1}, y\rangle = \langle Kd^{N-1}, y - y^N\rangle$.

So:

$$\sum_{n=1}^N\Delta^n \leq \Phi^0 - \Phi^N - \sum_{n=0}^{N-1}\frac{\|d^n\|^2}{2\tau} - \sum_{n=0}^{N-1}\frac{\|e^n\|^2}{2\sigma} + \sum_{n=0}^{N-2}\langle Kd^n, e^{n+1}\rangle + \langle Kd^{N-1}, y - y^N\rangle. \tag{13}$$

The last boundary term $\langle Kd^{N-1}, y - y^N\rangle$ is bounded by $L\|d^{N-1}\|\|y - y^N\|$ and still involves iterates.

Hmm, we can bound it using Young: $\langle Kd^{N-1}, y - y^N\rangle \leq \frac{\|d^{N-1}\|^2}{2\tau} + \frac{\tau L^2}{2}\|y - y^N\|^2$. The second term involves $\|y - y^N\|^2$, which can be bounded by $\sigma\Phi^N$... wait, $\frac{\|y - y^N\|^2}{2\sigma} \leq \Phi^N$, so $\|y - y^N\|^2 \leq 2\sigma\Phi^N$.

Then: $\frac{\tau L^2}{2} \cdot 2\sigma\Phi^N = \tau\sigma L^2\Phi^N < \Phi^N$.

So: $\langle Kd^{N-1}, y - y^N\rangle \leq \frac{\|d^{N-1}\|^2}{2\tau} + \tau\sigma L^2 \Phi^N$.

This is **very close** to what we need! Let's continue.

From the cross terms using Young with $\alpha = L\tau$:

$$\sum_{n=0}^{N-2}\langle Kd^n, e^{n+1}\rangle \leq \sum_{n=0}^{N-2}\frac{\|d^n\|^2}{2\tau} + \sum_{n=0}^{N-2}\frac{\tau L^2}{2}\|e^{n+1}\|^2 = \sum_{n=0}^{N-2}\frac{\|d^n\|^2}{2\tau} + \frac{\tau L^2}{2}\sum_{n=1}^{N-1}\|e^n\|^2. \tag{14}$$

Substituting into (13):

$$\sum\Delta^n \leq \Phi^0 - \Phi^N$$
$$- \sum_{n=0}^{N-1}\frac{\|d^n\|^2}{2\tau} + \sum_{n=0}^{N-2}\frac{\|d^n\|^2}{2\tau} + \frac{\|d^{N-1}\|^2}{2\tau}$$
$$- \sum_{n=0}^{N-1}\frac{\|e^n\|^2}{2\sigma} + \frac{\tau L^2}{2}\sum_{n=1}^{N-1}\|e^n\|^2$$
$$+ \tau\sigma L^2\Phi^N.$$

The $d^n$ terms: $-\sum_{n=0}^{N-1}\frac{\|d^n\|^2}{2\tau} + \sum_{n=0}^{N-2}\frac{\|d^n\|^2}{2\tau} + \frac{\|d^{N-1}\|^2}{2\tau} = -\frac{\|d^{N-1}\|^2}{2\tau} + \frac{\|d^{N-1}\|^2}{2\tau} = 0$.

The $e^n$ terms: $-\sum_{n=0}^{N-1}\frac{\|e^n\|^2}{2\sigma} + \frac{\tau L^2}{2}\sum_{n=1}^{N-1}\|e^n\|^2 = -\frac{\|e^0\|^2}{2\sigma} + \sum_{n=1}^{N-1}\left(\frac{\tau L^2}{2} - \frac{1}{2\sigma}\right)\|e^n\|^2 \leq 0$.

(Since $\tau L^2 \leq \frac{1}{\sigma}$ by $\tau\sigma L^2 \leq 1$, and $\frac{\|e^0\|^2}{2\sigma} \geq 0$.)

So:

$$\sum_{n=1}^N\Delta^n \leq \Phi^0 - \Phi^N + \tau\sigma L^2\Phi^N = \Phi^0 - (1 - \tau\sigma L^2)\Phi^N \leq \Phi^0.$$

The last inequality uses $\tau\sigma L^2 < 1$, so $(1 - \tau\sigma L^2) > 0$ and $\Phi^N \geq 0$.

### Phase 5: Conclude with Jensen's Inequality

From (J):

$$\mathcal{L}(X^N, y) - \mathcal{L}(x, Y^N) \leq \frac{1}{N}\sum_{n=1}^N\Delta^n \leq \frac{\Phi^0}{N} = \frac{1}{N}\left(\frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma}\right).$$

Since $\mathcal{G}_B(X^N, Y^N) = \sup_{(x,y)\in B}[\mathcal{L}(X^N, y) - \mathcal{L}(x, Y^N)]$, we get:

$$\boxed{\mathcal{G}_B(X^N, Y^N) \leq \frac{1}{N}\left(\frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma}\right)}$$

for all $(x, y) \in B$. $\blacksquare$

---

## Summary of Key Steps

1. **Lyapunov function**: $\Phi^n = \frac{\|x - x^n\|^2}{2\tau} + \frac{\|y - y^n\|^2}{2\sigma}$ (diagonal scaling).

2. **Prox VIs**: Standard convex subgradient inequalities from the proximal characterization of each update step.

3. **Three-point identity**: Converts inner products $\langle a - b, c - a\rangle$ into differences of squared distances, producing the telescoping $\Phi^n - \Phi^{n+1}$ terms and squared residuals $\|d^n\|^2$, $\|e^n\|^2$.

4. **Extrapolation handling**: The $\bar{x}^n = 2x^n - x^{n-1}$ extrapolation introduces coupling terms between primal residuals $d^n$ and dual residuals $e^{n+1}$. The summation of $\langle K(\bar{x}^n - x^{n+1}), y\rangle$ telescopes to a single boundary term $\langle K(x^{N-1} - x^N), y\rangle$. The cross residual terms $\langle Kd^n, e^{n+1}\rangle$ are bounded by Young's inequality with parameter $\alpha = L\tau$, absorbing into the squared residuals. The boundary term is bounded via Young's inequality and absorbed into $\Phi^N$ using $\tau\sigma L^2 < 1$.

5. **Telescoping and Jensen**: Summing the per-step inequalities telescopes to $\Phi^0 - (1-\tau\sigma L^2)\Phi^N \leq \Phi^0$. Dividing by $N$ and applying Jensen's inequality to the convex-concave saddle function gives the O(1/N) ergodic convergence of the restricted gap.
