# Proof: Fenchel Smoothness-Strong Convexity Duality

## Setup

Let $f: \mathbb{R}^n \to \mathbb{R}$ be closed convex, differentiable on $\mathbb{R}^n$, with $L$-Lipschitz continuous gradient ($L > 0$). Denote $f^*(y) = \sup_x [\langle y, x\rangle - f(x)]$.

---

## Lemma 1 (Descent Lemma)

$$f(y) \leq f(x) + \langle \nabla f(x), y-x\rangle + \frac{L}{2}\|y-x\|^2 \quad \forall\, x, y. \tag{QUB}$$

**Proof.** Set $\varphi(t) = f(x + t(y-x))$. Then:
$$f(y) - f(x) - \langle \nabla f(x), y-x\rangle = \int_0^1 \langle \nabla f(x+t(y-x)) - \nabla f(x),\, y-x\rangle\, dt \leq \int_0^1 Lt\|y-x\|^2\,dt = \frac{L}{2}\|y-x\|^2. \quad\blacksquare$$

---

## Lemma 2 (Cocoercivity)

$$\langle \nabla f(x) - \nabla f(y), x-y\rangle \geq \frac{1}{L}\|\nabla f(x) - \nabla f(y)\|^2 \quad \forall\, x, y. \tag{CC}$$

**Proof.** Let $p = \nabla f(x)$, $q = \nabla f(y)$, $d = x-y$, $\delta = p-q$. Define the Bregman residuals:
$$A = f(y) - f(x) - \langle p, y-x\rangle \geq 0, \quad B = f(x) - f(y) - \langle q, x-y\rangle \geq 0$$
(non-negativity from convexity). Note $A + B = \langle \delta, d\rangle$.

**Bound on $B$**: Set $w = x - \frac{1}{L}\delta$.

- QUB at center $x$: $\;f(w) \leq f(x) - \frac{1}{L}\langle p, \delta\rangle + \frac{1}{2L}\|\delta\|^2$.
- Convexity at $y$: $\;f(w) \geq f(y) + \langle q, d - \frac{1}{L}\delta\rangle = f(y) + \langle q, d\rangle - \frac{1}{L}\langle q, \delta\rangle$.

Combining: $\;f(y) + \langle q, d\rangle - \frac{1}{L}\langle q, \delta\rangle \leq f(x) - \frac{1}{L}\langle p, \delta\rangle + \frac{1}{2L}\|\delta\|^2$.

Since $f(y) - f(x) + \langle q, d\rangle = -B$ and $\frac{1}{L}[\langle q - p, \delta\rangle] + \frac{1}{2L}\|\delta\|^2 = -\frac{1}{2L}\|\delta\|^2$:

$$-B \leq -\frac{1}{2L}\|\delta\|^2 \quad\Longrightarrow\quad B \geq \frac{1}{2L}\|\delta\|^2.$$

**Bound on $A$**: Set $w' = y + \frac{1}{L}\delta$.

- QUB at center $y$: $\;f(w') \leq f(y) + \frac{1}{L}\langle q, \delta\rangle + \frac{1}{2L}\|\delta\|^2$.
- Convexity at $x$: $\;f(w') \geq f(x) - \langle p, d\rangle + \frac{1}{L}\langle p, \delta\rangle$.

Combining: $\;f(y) - f(x) + \langle p, d\rangle \geq \frac{1}{L}[\langle p - q, \delta\rangle] - \frac{1}{2L}\|\delta\|^2 = \frac{1}{2L}\|\delta\|^2$.

Since $f(y) - f(x) + \langle p, d\rangle = A$:

$$A \geq \frac{1}{2L}\|\delta\|^2.$$

**Conclusion**: $\langle \delta, d\rangle = A + B \geq \frac{1}{L}\|\delta\|^2$. $\blacksquare$

---

## Corollary (Quadratic Lower Bound)

$$f(y) \geq f(x) + \langle \nabla f(x), y-x\rangle + \frac{1}{2L}\|\nabla f(y) - \nabla f(x)\|^2 \quad \forall\, x, y. \tag{QLB}$$

*This is the statement $A \geq \frac{1}{2L}\|\delta\|^2$ from Lemma 2.* $\blacksquare$

---

## Part A: Subdifferential Identity

For $y \in \text{range}(\nabla f)$, say $y = \nabla f(x_0)$, the concave function $x \mapsto \langle y, x\rangle - f(x)$ has a critical point at $x_0$, hence $x_0$ is a global maximizer. The supremum $f^*(y)$ is attained.

By standard conjugate calculus:
$$\partial f^*(y) = \arg\max_x [\langle y, x\rangle - f(x)] = \{x : \nabla f(x) = y\} = (\nabla f)^{-1}(y).$$

When $(\nabla f)^{-1}(y)$ is a singleton $\{x_y\}$, $f^*$ is differentiable at $y$ with $\nabla f^*(y) = x_y$. $\blacksquare$

---

## Part B: $(1/L)$-Strong Convexity of $f^*$

**Theorem.** For all $y, y' \in \text{range}(\nabla f)$ and $x' \in \partial f^*(y')$:
$$f^*(y) \geq f^*(y') + \langle x', y - y'\rangle + \frac{1}{2L}\|y - y'\|^2.$$

**Proof.** Let $x \in \partial f^*(y)$, $x' \in \partial f^*(y')$, so $\nabla f(x) = y$, $\nabla f(x') = y'$. By Fenchel-Young: $f^*(y) = \langle y, x\rangle - f(x)$ and $f^*(y') = \langle y', x'\rangle - f(x')$.

Compute:
$$f^*(y) - f^*(y') - \langle x', y-y'\rangle = \langle y, x-x'\rangle + f(x') - f(x).$$

Apply the QLB with center $x$ and point $x'$:
$$f(x') \geq f(x) + \langle y, x'-x\rangle + \frac{1}{2L}\|y'-y\|^2.$$

Rearranging: $f(x') - f(x) + \langle y, x-x'\rangle \geq \frac{1}{2L}\|y-y'\|^2$.

Therefore:
$$f^*(y) - f^*(y') - \langle x', y-y'\rangle \geq \frac{1}{2L}\|y-y'\|^2. \qquad \blacksquare$$

The inequality extends to all of $\text{dom}(f^*) = \overline{\text{range}(\nabla f)}$ by lower semicontinuity of $f^*$.

---

## Part C: Converse ($f^*$ strongly convex $\Rightarrow$ $f$ smooth)

Suppose $f^*$ is $(1/L)$-strongly convex. Write $f^*(y) = h(y) + \frac{1}{2L}\|y\|^2$ with $h$ convex. Since $f = f^{**}$:
$$f(x) = \sup_y \left[\langle x, y\rangle - h(y) - \frac{1}{2L}\|y\|^2\right].$$

For any $\eta$, using $h(y) \geq \langle \eta, y\rangle - h^*(\eta)$:
$$f(x) \leq h^*(\eta) + \frac{L}{2}\|x - \eta\|^2. \tag{$\dagger$}$$

For a given $x_1$, the supremum defining $f(x_1)$ is attained at some $y_1$ (by strong concavity of the objective in $y$). The optimality condition gives $\eta_1 := x_1 - \frac{1}{L}y_1 \in \partial h(y_1)$. By Fenchel-Young for $h$: $h^*(\eta_1) = \langle \eta_1, y_1\rangle - h(y_1)$. Direct computation yields $f(x_1) = h^*(\eta_1) + \frac{L}{2}\|x_1 - \eta_1\|^2$.

Setting $\eta = \eta_1$ in $(\dagger)$:
$$f(x_2) \leq f(x_1) + \frac{L}{2}\left[\|x_2 - \eta_1\|^2 - \|x_1 - \eta_1\|^2\right] = f(x_1) + \langle L(x_1 - \eta_1), x_2 - x_1\rangle + \frac{L}{2}\|x_2 - x_1\|^2.$$

Since $L(x_1 - \eta_1) = y_1 = \nabla f(x_1)$ (the gradient exists because $f^*$ is strongly convex, making $f$ differentiable):
$$f(x_2) \leq f(x_1) + \langle \nabla f(x_1), x_2 - x_1\rangle + \frac{L}{2}\|x_2 - x_1\|^2. \qquad \blacksquare$$

---

## Summary

$$\boxed{f \text{ is } L\text{-smooth} \quad\Longleftrightarrow\quad f^* \text{ is } (1/L)\text{-strongly convex}.}$$

The forward direction uses cocoercivity (Lemma 2) to establish the quadratic lower bound, which transfers directly to strong convexity of $f^*$ via Fenchel-Young duality. The converse uses conjugate algebra to reconstruct the quadratic upper bound for $f$ from the strong convexity decomposition of $f^*$. $\blacksquare$
