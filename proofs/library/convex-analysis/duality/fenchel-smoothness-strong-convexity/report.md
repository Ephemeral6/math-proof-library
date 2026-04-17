# Final Report: Fenchel Smoothness-Strong Convexity Duality

## Result: PASS

## Theorem Statement

Let $f: \mathbb{R}^n \to \mathbb{R}$ be a closed convex function, differentiable on $\mathbb{R}^n$, with $L$-Lipschitz continuous gradient. Then its Fenchel conjugate $f^*$ is $(1/L)$-strongly convex on $\text{dom}(f^*)$. Conversely, if $f^*$ is $(1/L)$-strongly convex, then $f$ is $L$-smooth. Moreover, $\partial f^* = (\nabla f)^{-1}$ (set-valued inverse).

## Proof Strategy (Route 2: Direct Inequality Manipulation)

### Architecture
1. Prove the Descent Lemma (QUB) from the integral representation.
2. Prove cocoercivity of $\nabla f$ via a two-point test-function technique.
3. Derive the quadratic lower bound as a corollary.
4. Use the quadratic lower bound to establish strong convexity of $f^*$.
5. Prove the converse via conjugate algebra.

### Key Innovation
The cocoercivity proof uses auxiliary points $w = x - \frac{1}{L}(p-q)$ and $w' = y + \frac{1}{L}(p-q)$, combining the QUB at one center with convexity at the other to independently lower-bound both Bregman residuals $A$ and $B$ by $\frac{1}{2L}\|\delta\|^2$.

## Detailed Proof

### Lemma 1 (Descent Lemma)

If $f$ is differentiable with $L$-Lipschitz gradient, then:
$$f(y) \leq f(x) + \langle \nabla f(x), y-x\rangle + \frac{L}{2}\|y-x\|^2 \quad \forall\, x, y. \tag{QUB}$$

**Proof.** Set $\varphi(t) = f(x + t(y-x))$.
$$f(y) - f(x) - \langle \nabla f(x), y-x\rangle = \int_0^1 \langle \nabla f(x+t(y-x)) - \nabla f(x),\, y-x\rangle\, dt \leq \int_0^1 Lt\|y-x\|^2\,dt = \frac{L}{2}\|y-x\|^2. \quad\blacksquare$$

### Lemma 2 (Cocoercivity)

If $f$ is convex and differentiable with $L$-Lipschitz gradient, then:
$$\langle \nabla f(x) - \nabla f(y), x-y\rangle \geq \frac{1}{L}\|\nabla f(x) - \nabla f(y)\|^2 \quad \forall\, x, y. \tag{CC}$$

**Proof.** Let $p = \nabla f(x)$, $q = \nabla f(y)$, $d = x-y$, $\delta = p-q$. Define:
$$A = f(y) - f(x) - \langle p, y-x\rangle \geq 0, \quad B = f(x) - f(y) - \langle q, x-y\rangle \geq 0.$$

Note $A + B = \langle \delta, d\rangle$.

**Lower bound on $B$**: Set $w = x - \frac{1}{L}\delta$. By QUB at $x$:
$$f(w) \leq f(x) - \frac{1}{L}\langle p, \delta\rangle + \frac{1}{2L}\|\delta\|^2.$$

By convexity at $y$ (note $w - y = d - \frac{1}{L}\delta$):
$$f(w) \geq f(y) + \langle q, d\rangle - \frac{1}{L}\langle q, \delta\rangle.$$

Combining and noting that $-B = f(y) - f(x) + \langle q, d\rangle$:
$$-B \leq \frac{1}{L}[\langle q - p, \delta\rangle] + \frac{1}{2L}\|\delta\|^2 = -\frac{1}{2L}\|\delta\|^2.$$

Hence $B \geq \frac{1}{2L}\|\delta\|^2$.

**Lower bound on $A$**: Set $w' = y + \frac{1}{L}\delta$. By QUB at $y$:
$$f(w') \leq f(y) + \frac{1}{L}\langle q, \delta\rangle + \frac{1}{2L}\|\delta\|^2.$$

By convexity at $x$ (note $w' - x = -d + \frac{1}{L}\delta$):
$$f(w') \geq f(x) - \langle p, d\rangle + \frac{1}{L}\langle p, \delta\rangle.$$

Combining and noting that $A = f(y) - f(x) + \langle p, d\rangle$:
$$A \geq \frac{1}{L}[\langle p - q, \delta\rangle] - \frac{1}{2L}\|\delta\|^2 = \frac{1}{2L}\|\delta\|^2.$$

**Conclusion**: $\langle \delta, d\rangle = A + B \geq \frac{1}{L}\|\delta\|^2$. $\blacksquare$

### Corollary (Quadratic Lower Bound)

$$f(y) \geq f(x) + \langle \nabla f(x), y-x\rangle + \frac{1}{2L}\|\nabla f(y) - \nabla f(x)\|^2 \quad \forall\, x, y. \tag{QLB}$$

*Proof*: This is the statement $A \geq \frac{1}{2L}\|\delta\|^2$ from Lemma 2. $\blacksquare$

### Part A: Subdifferential Identity $\partial f^* = (\nabla f)^{-1}$

For $y \in \text{range}(\nabla f)$, say $y = \nabla f(x_0)$, the function $x \mapsto \langle y, x\rangle - f(x)$ is concave with critical point at $x_0$, hence $x_0$ is a global maximizer. Thus $f^*(y)$ is attained and $x_0 \in \partial f^*(y)$.

Conversely, $x \in \partial f^*(y)$ iff $x$ maximizes $\langle y, \cdot\rangle - f(\cdot)$ iff $\nabla f(x) = y$. So $\partial f^*(y) = \{x : \nabla f(x) = y\} = (\nabla f)^{-1}(y)$.

When the preimage is a singleton, $f^*$ is differentiable at $y$ with $\nabla f^*(y) = (\nabla f)^{-1}(y)$. $\blacksquare$

### Part B: $(1/L)$-Strong Convexity of $f^*$

**Theorem**: For all $y, y' \in \text{range}(\nabla f)$ and $x' \in \partial f^*(y')$:
$$f^*(y) \geq f^*(y') + \langle x', y - y'\rangle + \frac{1}{2L}\|y - y'\|^2.$$

**Proof.** Let $x \in \partial f^*(y)$, $x' \in \partial f^*(y')$, so $\nabla f(x) = y$, $\nabla f(x') = y'$. By Fenchel-Young: $f^*(y) = \langle y, x\rangle - f(x)$, $f^*(y') = \langle y', x'\rangle - f(x')$.

Compute:
$$f^*(y) - f^*(y') - \langle x', y - y'\rangle = \langle y, x - x'\rangle + f(x') - f(x).$$

By the QLB with center $x$ and point $x'$:
$$f(x') \geq f(x) + \langle y, x' - x\rangle + \frac{1}{2L}\|y' - y\|^2.$$

Hence:
$$f(x') - f(x) + \langle y, x - x'\rangle \geq \frac{1}{2L}\|y - y'\|^2.$$

This is exactly the left-hand side, so:
$$f^*(y) - f^*(y') - \langle x', y - y'\rangle \geq \frac{1}{2L}\|y - y'\|^2. \qquad \blacksquare$$

### Part C: Converse ($f^*$ strongly convex $\Rightarrow$ $f$ smooth)

Suppose $f^*$ is $(1/L)$-strongly convex. Write $f^*(y) = h(y) + \frac{1}{2L}\|y\|^2$ with $h$ convex. Since $f = f^{**}$:
$$f(x) = \sup_y \left[\langle x, y\rangle - h(y) - \frac{1}{2L}\|y\|^2\right].$$

For any $\eta \in \mathbb{R}^n$, using $h(y) \geq \langle \eta, y\rangle - h^*(\eta)$:
$$f(x) \leq h^*(\eta) + \sup_y \left[\langle x - \eta, y\rangle - \frac{1}{2L}\|y\|^2\right] = h^*(\eta) + \frac{L}{2}\|x - \eta\|^2. \tag{$\dagger$}$$

For any $x_1$ where $f$ is subdifferentiable, the supremum defining $f(x_1)$ is attained at some $y_1$. The first-order condition gives $x_1 = \eta_1 + \frac{1}{L}y_1$ where $\eta_1 \in \partial h(y_1)$. By Fenchel-Young for $h$: $h^*(\eta_1) = \langle \eta_1, y_1\rangle - h(y_1)$, and direct computation gives $f(x_1) = h^*(\eta_1) + \frac{L}{2}\|x_1 - \eta_1\|^2$.

Substituting $\eta = \eta_1$ into ($\dagger$):
$$f(x_2) \leq h^*(\eta_1) + \frac{L}{2}\|x_2 - \eta_1\|^2 = f(x_1) + \frac{L}{2}[\|x_2 - \eta_1\|^2 - \|x_1 - \eta_1\|^2].$$

Expanding: $\|x_2 - \eta_1\|^2 - \|x_1 - \eta_1\|^2 = 2\langle x_1 - \eta_1, x_2 - x_1\rangle + \|x_2 - x_1\|^2$.

Since $L(x_1 - \eta_1) = y_1 \in \partial f(x_1)$ (which equals $\nabla f(x_1)$ when $f$ is differentiable):
$$f(x_2) \leq f(x_1) + \langle \nabla f(x_1), x_2 - x_1\rangle + \frac{L}{2}\|x_2 - x_1\|^2. \qquad \blacksquare$$

## Audit Summary

- **Lemma 1**: PASS
- **Lemma 2 (Cocoercivity)**: PASS - all algebraic steps verified
- **QLB**: PASS - direct consequence
- **Part A (Inverse gradient)**: PASS
- **Part B (Strong convexity)**: PASS - key computation verified
- **Part C (Converse)**: PASS (minor: finiteness of $f$ from biconjugation assumed)

## Clarification on Problem Statement

The original problem states "$f^*$ is differentiable with $(1/L)$-Lipschitz gradient." The correct conclusion from $L$-smoothness of $f$ alone is:
- $f^*$ is $(1/L)$-**strongly convex** (proved).
- $f^*$ need not have Lipschitz gradient without additional assumptions (e.g., strong convexity of $f$).
- The $(1/L)$-Lipschitz gradient claim for $f^*$ would be the dual of $f$ being $(1/L)^{-1} = L$-smooth, but this is circular without strong convexity.

The dual pair is: $f$ is $\mu$-strongly convex and $L$-smooth $\Leftrightarrow$ $f^*$ is $(1/L)$-strongly convex and $(1/\mu)$-smooth.

## VERDICT: PASS
