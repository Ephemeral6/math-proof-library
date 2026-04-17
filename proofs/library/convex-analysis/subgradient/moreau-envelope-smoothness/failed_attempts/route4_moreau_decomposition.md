# Proof Route 4: Moreau Decomposition + Conjugate Smoothness

**Route**: Use Moreau decomposition theorem and the strong convexity-smoothness duality

---

## Proof

Let $f: \mathbb{R}^d \to \mathbb{R} \cup \{+\infty\}$ be proper, closed, convex, and $\lambda > 0$.

### Step 1: Moreau decomposition theorem

The Moreau decomposition states that for any $x \in \mathbb{R}^d$:

$$x = \text{prox}_{\lambda f}(x) + \lambda \text{prox}_{f^*/\lambda}(x/\lambda) \tag{MD}$$

where $f^*$ is the Fenchel conjugate of $f$.

**Proof of (MD):** Let $p = \text{prox}_{\lambda f}(x)$. By the optimality condition:
$$\frac{1}{\lambda}(x - p) \in \partial f(p).$$

Let $s = \frac{1}{\lambda}(x-p)$, so $s \in \partial f(p)$. By the conjugate subgradient relation, $s \in \partial f(p) \iff p \in \partial f^*(s)$. Now $x = p + \lambda s$, so $x/\lambda = p/\lambda + s$, giving $p = x - \lambda s$ and thus $p/\lambda = x/\lambda - s$.

We need to show $s = \text{prox}_{f^*/\lambda}(x/\lambda)$, i.e., $s$ minimizes $f^*(t)/\lambda + \frac{1}{2}\|t - x/\lambda\|^2$ over $t$. The optimality condition for this is:

$$\frac{1}{\lambda}\partial f^*(s) + (s - x/\lambda) \ni 0 \implies x/\lambda - s \in \frac{1}{\lambda}\partial f^*(s).$$

We need $p/\lambda \in \frac{1}{\lambda}\partial f^*(s)$, i.e., $p \in \partial f^*(s)$. But we established $s \in \partial f(p) \iff p \in \partial f^*(s)$. So (MD) holds. $\square$

### Step 2: Moreau envelope identity via conjugate

We establish:
$$M_\lambda f(x) = \frac{1}{2\lambda}\|x\|^2 - \frac{1}{\lambda}\left(f^* + \frac{\lambda}{2}\|\cdot\|^2\right)^*\!\!\left(\frac{x}{\lambda}\right) \cdot \lambda$$

Actually, let us use a cleaner identity. Define $g(s) = f^*(s) + \frac{\lambda}{2}\|s\|^2$. We claim:

$$M_\lambda f(x) = \frac{1}{2\lambda}\|x\|^2 - g^*\!\left(\frac{x}{\lambda}\right). \tag{**}$$

**Proof of (***):** 
$$g^*(z) = \sup_s \{\langle z, s\rangle - f^*(s) - \frac{\lambda}{2}\|s\|^2\}$$

$$= \sup_s \left\{-\frac{\lambda}{2}\left\|s - \frac{z}{\lambda}\right\|^2 + \frac{1}{2\lambda}\|z\|^2 - f^*(s)\right\}$$

$$= \frac{1}{2\lambda}\|z\|^2 + \sup_s\left\{-f^*(s) - \frac{\lambda}{2}\left\|s - \frac{z}{\lambda}\right\|^2\right\}$$

$$= \frac{1}{2\lambda}\|z\|^2 - \inf_s\left\{f^*(s) + \frac{\lambda}{2}\left\|s - \frac{z}{\lambda}\right\|^2\right\}$$

$$= \frac{1}{2\lambda}\|z\|^2 - M_{\lambda}^{*} f^*\left(\frac{z}{\lambda}\right) \quad \text{(not quite standard notation)}$$

Let me instead verify (**) directly. With $z = x/\lambda$:

$$g^*(x/\lambda) = \sup_s \left\{\langle x/\lambda, s\rangle - f^*(s) - \frac{\lambda}{2}\|s\|^2\right\}.$$

The supremum is attained at the unique $s^*$ satisfying $x/\lambda \in \partial f^*(s^*) + \lambda s^*$, i.e., $x/\lambda - \lambda s^* \in \partial f^*(s^*)$. This means $\partial f^*(s^*) \ni x/\lambda - \lambda s^*$, so by conjugate relation $s^* \in \partial f(x/\lambda - \lambda s^*)$.

Actually this approach is getting tangled. Let me use the cleaner relationship.

### Step 3: Clean conjugate identity

From Step 5 of Route 3, we know $(M_\lambda f)^* = f^* + \frac{\lambda}{2}\|\cdot\|^2$. Since $M_\lambda f$ is convex (infimal convolution of convex functions) and proper and closed (infimal convolution with a strongly convex function is closed), the biconjugate theorem gives $M_\lambda f = ((M_\lambda f)^*)^* = g^*$ where $g = f^* + \frac{\lambda}{2}\|\cdot\|^2$.

This is the same conclusion as Route 3. Let me instead focus on the decomposition approach.

### Step 4: Using the decomposition for the gradient

From (MD): $x - \text{prox}_{\lambda f}(x) = \lambda \text{prox}_{f^*/\lambda}(x/\lambda)$.

So the proposed gradient $\frac{1}{\lambda}(x - \text{prox}_{\lambda f}(x)) = \text{prox}_{f^*/\lambda}(x/\lambda)$.

The Moreau envelope of $f^*/\lambda$ at $x/\lambda$ is:
$$M_1(f^*/\lambda)(x/\lambda) = (f^*/\lambda)(\text{prox}_{f^*/\lambda}(x/\lambda)) + \frac{1}{2}\|\text{prox}_{f^*/\lambda}(x/\lambda) - x/\lambda\|^2.$$

By (MD), $\text{prox}_{f^*/\lambda}(x/\lambda) = \frac{1}{\lambda}(x - p)$ and $x/\lambda - \text{prox}_{f^*/\lambda}(x/\lambda) = p/\lambda$ where $p = \text{prox}_{\lambda f}(x)$.

This route is becoming more complex than illuminating. The core machinery is the same as Route 3 (conjugate duality). 

### Route Failure Report
- Route: Moreau Decomposition + Conjugate Smoothness
- Failed at: Step 4
- Obstacle: The Moreau decomposition approach, while valid, does not provide a simpler or more self-contained proof than Routes 1-3. The decomposition identity (MD) is itself a consequence of the optimality condition and conjugate subgradient relation, so it adds an extra layer without simplifying the argument. The proof through this route ultimately reduces to the same conjugate calculus as Route 3.
- Recommendation: Route 1 (direct variational) or Route 3 (conjugate) are cleaner.
