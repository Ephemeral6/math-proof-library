# Proof: Moreau Envelope Smoothness and Gradient Formula

Let $f: \mathbb{R}^d \to \mathbb{R} \cup \{+\infty\}$ be a proper, closed (lower semicontinuous), convex function, and fix $\lambda > 0$. Define:

$$M_\lambda f(x) = \inf_{y} \left\{f(y) + \frac{1}{2\lambda}\|y - x\|^2\right\}, \quad p_\lambda(x) = \text{prox}_{\lambda f}(x) = \arg\min_y \left\{f(y) + \frac{1}{2\lambda}\|y-x\|^2\right\}.$$

## Preliminary: Well-definedness and nonexpansiveness of prox

**Step 1: The proximal operator is well-defined.**

For any fixed $x \in \mathbb{R}^d$, the function $\varphi_x(y) = f(y) + \frac{1}{2\lambda}\|y - x\|^2$ is the sum of a proper closed convex function and a $\frac{1}{\lambda}$-strongly convex smooth function. Hence $\varphi_x$ is $\frac{1}{\lambda}$-strongly convex, proper, and closed. Strong convexity implies coercivity ($\varphi_x(y) \to +\infty$ as $\|y\| \to +\infty$), so by the Weierstrass theorem, $\varphi_x$ attains its infimum, and the minimizer is unique by strong convexity. Thus $p_\lambda(x)$ is well-defined.

**Step 2: Optimality condition.**

Since $p = p_\lambda(x)$ minimizes $\varphi_x$, by the Fermat rule for convex functions:

$$0 \in \partial f(p) + \frac{1}{\lambda}(p - x),$$

which gives:

$$\frac{1}{\lambda}(x - p) \in \partial f(p). \tag{OC}$$

(The subdifferential sum rule applies since $\frac{1}{2\lambda}\|y-x\|^2$ is everywhere differentiable.)

**Step 3: Firm nonexpansiveness of prox.**

Let $x_1, x_2 \in \mathbb{R}^d$, $p_i = p_\lambda(x_i)$. By (OC): $\frac{1}{\lambda}(x_i - p_i) \in \partial f(p_i)$. By monotonicity of $\partial f$:

$$\left\langle \frac{1}{\lambda}(x_1 - p_1) - \frac{1}{\lambda}(x_2 - p_2),\; p_1 - p_2 \right\rangle \geq 0.$$

With $\Delta x = x_1 - x_2$ and $\Delta p = p_1 - p_2$:

$$\langle \Delta x - \Delta p,\; \Delta p \rangle \geq 0 \quad \Longrightarrow \quad \langle \Delta x, \Delta p \rangle \geq \|\Delta p\|^2. \tag{FNE}$$

**Consequences of (FNE):**

(i) **Nonexpansiveness**: By Cauchy-Schwarz, $\|\Delta x\| \cdot \|\Delta p\| \geq \|\Delta p\|^2$, giving $\|\Delta p\| \leq \|\Delta x\|$.

(ii) **Complementary nonexpansiveness**: Let $\delta = \Delta x - \Delta p$. Then:

$$\|\delta\|^2 = \|\Delta x\|^2 - 2\langle \Delta x, \Delta p\rangle + \|\Delta p\|^2 \leq \|\Delta x\|^2 - 2\|\Delta p\|^2 + \|\Delta p\|^2 = \|\Delta x\|^2 - \|\Delta p\|^2 \leq \|\Delta x\|^2.$$

So $\|(x_1 - p_1) - (x_2 - p_2)\| \leq \|x_1 - x_2\|$, meaning $x \mapsto x - p_\lambda(x)$ is also nonexpansive. $\tag{CNE}$

---

## Part (a): $M_\lambda f$ is finite-valued and continuous

**Step 4: Finite-valuedness.**

*Upper bound:* For any $x$, pick $y_0 \in \text{dom } f$:
$$M_\lambda f(x) \leq f(y_0) + \frac{1}{2\lambda}\|y_0 - x\|^2 < +\infty.$$

*Lower bound:* Since $f$ is proper closed convex, there exist $a \in \mathbb{R}^d, b \in \mathbb{R}$ with $f(y) \geq \langle a, y\rangle + b$ for all $y$ (existence of a supporting affine minorant). Then:

$$M_\lambda f(x) \geq \inf_y \left\{\langle a, y\rangle + b + \frac{1}{2\lambda}\|y-x\|^2\right\}.$$

This infimum is over a strongly convex quadratic, attained at $y^* = x - \lambda a$:

$$M_\lambda f(x) \geq \langle a, x\rangle + b - \frac{\lambda}{2}\|a\|^2 > -\infty.$$

**Step 5: Continuity.**

We prove continuity using two semicontinuity arguments.

*Upper semicontinuity:* $M_\lambda f(x) = \inf_y g_y(x)$ where $g_y(x) = f(y) + \frac{1}{2\lambda}\|y-x\|^2$ is continuous in $x$. The infimum of continuous functions is upper semicontinuous.

*Lower semicontinuity:* Let $x_n \to x$. Set $p_n = p_\lambda(x_n)$. By nonexpansiveness, $\|p_n - p_\lambda(x)\| \leq \|x_n - x\| \to 0$, so $p_n \to p_\lambda(x)$. Then:

$$\liminf_{n\to\infty} M_\lambda f(x_n) = \liminf_{n\to\infty}\left[f(p_n) + \frac{1}{2\lambda}\|p_n - x_n\|^2\right] \geq f(p_\lambda(x)) + \frac{1}{2\lambda}\|p_\lambda(x) - x\|^2 = M_\lambda f(x),$$

where we used lower semicontinuity of $f$ (since $p_n \to p_\lambda(x)$) and continuity of the norm.

Combining usc and lsc: $M_\lambda f$ is continuous. $\square$

---

## Part (b): Differentiability with $\nabla M_\lambda f(x) = \frac{1}{\lambda}(x - p_\lambda(x))$

**Step 6:** Fix $x \in \mathbb{R}^d$ and let $p = p_\lambda(x)$, $p_h = p_\lambda(x+h)$.

**Upper bound.** Use $p$ (suboptimal) in the definition at $x+h$:

$$M_\lambda f(x+h) \leq f(p) + \frac{1}{2\lambda}\|p - x - h\|^2 = M_\lambda f(x) + \frac{1}{\lambda}\langle x-p, h\rangle + \frac{1}{2\lambda}\|h\|^2. \tag{UB}$$

**Lower bound.** Use $p_h$ (suboptimal) in the definition at $x$:

$$M_\lambda f(x) \leq f(p_h) + \frac{1}{2\lambda}\|p_h - x\|^2.$$

Subtracting from $M_\lambda f(x+h) = f(p_h) + \frac{1}{2\lambda}\|p_h - x - h\|^2$:

$$M_\lambda f(x+h) - M_\lambda f(x) \geq \frac{1}{2\lambda}\left(\|p_h - x - h\|^2 - \|p_h - x\|^2\right) = \frac{1}{\lambda}\langle x - p_h, h\rangle + \frac{1}{2\lambda}\|h\|^2.$$

By nonexpansiveness, $\|p_h - p\| \leq \|h\|$, so $|\langle p - p_h, h\rangle| \leq \|h\|^2$. Thus:

$$\langle x - p_h, h\rangle = \langle x - p, h\rangle + \langle p - p_h, h\rangle \geq \langle x - p, h\rangle - \|h\|^2.$$

Therefore:

$$M_\lambda f(x+h) - M_\lambda f(x) \geq \frac{1}{\lambda}\langle x-p, h\rangle - \frac{1}{2\lambda}\|h\|^2. \tag{LB}$$

**Combining (UB) and (LB):**

$$\left|M_\lambda f(x+h) - M_\lambda f(x) - \frac{1}{\lambda}\langle x-p, h\rangle\right| \leq \frac{1}{2\lambda}\|h\|^2 = o(\|h\|).$$

This proves $M_\lambda f$ is (Fréchet) differentiable at $x$ with $\nabla M_\lambda f(x) = \frac{1}{\lambda}(x - p_\lambda(x))$. $\square$

---

## Part (c): $\nabla M_\lambda f$ is $\frac{1}{\lambda}$-Lipschitz ($M_\lambda f$ is $\frac{1}{\lambda}$-smooth)

**Step 7:** By (CNE) from Step 3:

$$\|\nabla M_\lambda f(x_1) - \nabla M_\lambda f(x_2)\| = \frac{1}{\lambda}\|(x_1 - p_\lambda(x_1)) - (x_2 - p_\lambda(x_2))\| \leq \frac{1}{\lambda}\|x_1 - x_2\|. \quad \square$$

---

## Part (d): $M_\lambda f(x) \leq f(x)$ with equality iff $0 \in \partial f(x)$

**Step 8: The inequality.**

$$M_\lambda f(x) = \inf_y \left\{f(y) + \frac{1}{2\lambda}\|y-x\|^2\right\} \leq f(x) + \frac{1}{2\lambda}\|x - x\|^2 = f(x). \quad \square$$

**Step 9: Equality characterization.**

($\Rightarrow$) If $M_\lambda f(x) = f(x)$, then $y = x$ achieves the infimum (since $M_\lambda f(x) \leq f(x)$ always, equality means the infimand at $y=x$ equals the infimum). By uniqueness of the minimizer: $p_\lambda(x) = x$. By (OC): $\frac{1}{\lambda}(x - x) = 0 \in \partial f(x)$.

($\Leftarrow$) If $0 \in \partial f(x)$, then $f(y) \geq f(x)$ for all $y$ (definition of subdifferential with subgradient 0). So:

$$f(y) + \frac{1}{2\lambda}\|y-x\|^2 \geq f(x) + 0 = f(x) \quad \forall y,$$

with equality at $y = x$. Hence $M_\lambda f(x) = f(x)$. $\square$

---

**Q.E.D.** $\blacksquare$
