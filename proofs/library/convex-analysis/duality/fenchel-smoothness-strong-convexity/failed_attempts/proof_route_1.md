# Route 1: Via Cocoercivity (Baillon-Haddad style)

## Setup and Definitions

Let $f : \mathbb{R}^n \to \mathbb{R}$ be a closed convex function that is differentiable with $L$-Lipschitz continuous gradient, i.e.,
$$\|\nabla f(x) - \nabla f(y)\| \leq L\|x - y\| \quad \forall x, y \in \mathbb{R}^n.$$

The Fenchel conjugate is $f^*(y) = \sup_{x \in \mathbb{R}^n} [\langle y, x \rangle - f(x)]$.

---

## Part 1: $\nabla f^* = (\nabla f)^{-1}$

**Claim**: $f^*$ is differentiable and $\nabla f^*(y) = (\nabla f)^{-1}(y)$ for all $y \in \mathbb{R}^n$.

**Proof**:

**Step 1 (Surjectivity of $\nabla f$)**. Since $f$ is $L$-smooth and convex on $\mathbb{R}^n$, we have the quadratic lower bound
$$f(x) \geq f(0) + \langle \nabla f(0), x\rangle + \frac{1}{2L}\|\nabla f(x) - \nabla f(0)\|^2$$
(this follows from the standard cocoercivity estimate for smooth convex functions, proved below in Step 3). In particular, $f(x) \to +\infty$ as $\|x\| \to \infty$ (since $\|\nabla f(x)\| \to \infty$ by the growth of a smooth convex function).

More directly: for any $y \in \mathbb{R}^n$, the function $x \mapsto \langle y, x \rangle - f(x)$ satisfies
$$\langle y, x \rangle - f(x) \leq \langle y, x \rangle - f(0) - \langle \nabla f(0), x\rangle - \frac{1}{2L}\|x\|^2$$
Wait, we need a more careful argument. Actually, since $f$ is $L$-smooth and convex, we have the standard quadratic lower bound:
$$f(x) \geq f(x_0) + \langle \nabla f(x_0), x - x_0 \rangle + \frac{1}{2L}\|\nabla f(x) - \nabla f(x_0)\|^2.$$

For the surjectivity: given any $y$, the function $h(x) = \langle y, x\rangle - f(x)$ is concave and, because $f$ is superlinear (as a consequence of $f$ being convex with Lipschitz gradient on all of $\mathbb{R}^n$... actually this requires $f$ to be supercoercive).

**Let us use a cleaner approach.** Since $f$ is convex and differentiable, $y \in \partial f(x)$ iff $y = \nabla f(x)$. By Fenchel-Young, $f(x) + f^*(y) = \langle x, y\rangle$ iff $y \in \partial f(x)$.

So for each $y$, the supremum in $f^*(y) = \sup_x [\langle y, x\rangle - f(x)]$ is attained at $x$ iff $\nabla f(x) = y$.

**We need $\nabla f$ to be surjective.** Since $f$ is $L$-smooth and convex on $\mathbb{R}^n$, $f$ has the lower bound $f(x) \geq f(0) + \langle \nabla f(0), x\rangle + \frac{1}{2L}\|x\|^2$ (NO - this is not correct in general).

Actually, for $L$-smooth convex $f$ on $\mathbb{R}^n$, we have:
$$f(x) \leq f(x_0) + \langle \nabla f(x_0), x - x_0\rangle + \frac{L}{2}\|x - x_0\|^2.$$

This gives an upper bound. For the lower bound, we only have convexity:
$$f(x) \geq f(x_0) + \langle \nabla f(x_0), x - x_0\rangle.$$

To show surjectivity of $\nabla f$: consider the function $g_y(x) = f(x) - \langle y, x\rangle$. This is convex and differentiable with $\nabla g_y(x) = \nabla f(x) - y$. We need to show $g_y$ attains its minimum, i.e., $g_y(x) \to +\infty$ as $\|x\| \to \infty$.

From the descent lemma applied at any fixed $x_0$:
$$f(x) \geq f(x_0) + \langle \nabla f(x_0), x - x_0\rangle + \frac{1}{2L}\|\nabla f(x) - \nabla f(x_0)\|^2.$$

Hmm, this is the cocoercivity lower bound. Let me just use a simpler fact.

Since $\nabla f$ is $L$-Lipschitz: $\|\nabla f(x)\| \leq \|\nabla f(0)\| + L\|x\|$. By convexity:
$$f(x) \geq f(0) + \langle \nabla f(0), x\rangle.$$

This only gives a linear lower bound. For coercivity of $g_y$:
$$g_y(x) = f(x) - \langle y, x\rangle \geq f(0) + \langle \nabla f(0) - y, x\rangle.$$

This doesn't give coercivity directly. We need more.

**Better approach**: By the fundamental theorem of monotone operators, a continuous monotone map $T: \mathbb{R}^n \to \mathbb{R}^n$ that is coercive (i.e., $\langle T(x), x\rangle / \|x\| \to \infty$) is surjective. 

$\nabla f$ is monotone (since $f$ is convex) and continuous. For coercivity:
$$\langle \nabla f(x), x\rangle = \langle \nabla f(x) - \nabla f(0), x\rangle + \langle \nabla f(0), x\rangle.$$

By cocoercivity (which we prove in Step 3):
$$\langle \nabla f(x) - \nabla f(0), x - 0\rangle \geq \frac{1}{L}\|\nabla f(x) - \nabla f(0)\|^2 \geq 0.$$

So $\langle \nabla f(x), x\rangle \geq \langle \nabla f(0), x\rangle$, which doesn't directly give coercivity in the needed sense.

**Simplest correct argument**: For convex differentiable $f$ on $\mathbb{R}^n$ with $L$-Lipschitz gradient, define $\hat{f}(x) = f(x) + \epsilon\|x\|^2/2$ for small $\epsilon > 0$. Then $\hat{f}$ is $(\epsilon)$-strongly convex and $(L+\epsilon)$-smooth, so $\nabla \hat{f}$ is surjective. Take $\epsilon \to 0$... This is getting complicated.

**Most direct approach**: Let us simply observe that for $f$ convex and $L$-smooth on $\mathbb{R}^n$, the function $x \mapsto f(x) - \langle y, x\rangle$ is still convex and $L$-smooth. Its infimum is either $-\infty$ or attained. But:

$$f(x) - \langle y, x\rangle \geq f(x^*) + \langle \nabla f(x^*) - y, x - x^*\rangle$$

for any $x^*$. If $f(x) - \langle y, x \rangle$ is unbounded below, there exists a sequence $x_k$ with $f(x_k) - \langle y, x_k\rangle \to -\infty$, but then by the quadratic upper bound:

$$f(x_k) \leq f(0) + \langle \nabla f(0), x_k\rangle + \frac{L}{2}\|x_k\|^2,$$

so $f(x_k) - \langle y, x_k\rangle \leq f(0) + \langle \nabla f(0) - y, x_k\rangle + \frac{L}{2}\|x_k\|^2$. For this to go to $-\infty$, we'd need $\|x_k\| \to \infty$, but the $\frac{L}{2}\|x_k\|^2$ term dominates, so $f(x_k) - \langle y, x_k\rangle \to +\infty$. Contradiction.

Wait — this argument shows the opposite: $f(x) - \langle y,x\rangle$ IS coercive! Because:
$$f(x) - \langle y, x\rangle \leq f(0) + \langle \nabla f(0) - y, x\rangle + \frac{L}{2}\|x\|^2.$$

No, this is an upper bound on $f(x) - \langle y, x\rangle$, not a lower bound. We need a lower bound to show coercivity.

**Key insight**: For smooth convex $f$, we have the following lower bound (from the conjugate of the upper bound):

$$f(x) \geq -f^*(y) + \langle y, x\rangle \quad \forall y,$$

which is trivial (just the definition of $f^*$). This doesn't help.

Let me use a completely different approach. We know:
$$f(x) \geq f(x_0) + \langle \nabla f(x_0), x - x_0\rangle + \frac{1}{2L}\|\nabla f(x) - \nabla f(x_0)\|^2$$

(proved below). Using $\|\nabla f(x) - \nabla f(x_0)\| \geq \|\nabla f(x)\| - \|\nabla f(x_0)\|$:

$$f(x) \geq f(x_0) - \|\nabla f(x_0)\| \cdot \|x - x_0\| + \frac{1}{2L}(\|\nabla f(x)\| - \|\nabla f(x_0)\|)^2.$$

Also $\|\nabla f(x)\| \leq \|\nabla f(x_0)\| + L\|x - x_0\|$, so $\|x - x_0\| \geq (\|\nabla f(x)\| - \|\nabla f(x_0)\|)/L$. 

As $\|x\| \to \infty$, since $\nabla f$ is $L$-Lipschitz, we don't necessarily have $\|\nabla f(x)\| \to \infty$ (actually we do for supercoercivity, but let me check).

Hmm, actually for convex $f$ on $\mathbb{R}^n$ with $\text{dom}(f) = \mathbb{R}^n$, if $f$ is not identically an affine function, then $f(x)/\|x\| \to +\infty$ is NOT guaranteed. Consider $f(x) = x^2/(1+|x|)$ — but this doesn't have Lipschitz gradient.

OK, let me try a very clean argument. Forget about showing surjectivity directly. Let us instead:

**RESTART: Clean proof of Part 1**

Since $f$ is convex and differentiable, by Fenchel-Young: for any $x, y$,
$$f(x) + f^*(y) \geq \langle x, y\rangle,$$
with equality iff $y = \nabla f(x)$.

Given $y \in \mathbb{R}^n$, consider $\phi(x) = f(x) - \langle y, x\rangle$. This is convex and differentiable. We claim $\phi$ attains its minimum.

The $L$-smoothness gives: $f(x) \leq f(0) + \langle \nabla f(0), x\rangle + \frac{L}{2}\|x\|^2$.

Now we use a subtler bound. By convexity and $L$-smoothness, we have the key inequality:
$$f(x) \geq f(0) + \langle \nabla f(0), x\rangle + \frac{1}{2L}\|\nabla f(x) - \nabla f(0)\|^2.$$

Since $\nabla f$ is $L$-Lipschitz, $\|\nabla f(x)\| \leq L\|x\| + \|\nabla f(0)\|$, so $\|\nabla f(x) - \nabla f(0)\| \leq L\|x\|$.

This doesn't directly help. Let me use the quadratic upper bound differently.

$$\phi(x) = f(x) - \langle y, x\rangle.$$

Pick $x_0 = 0$. By the upper bound on $f$:
$$f(x) \leq f(0) + \langle \nabla f(0), x\rangle + \frac{L}{2}\|x\|^2.$$

Take the minimum of the right side over $x$: RHS is minimized at $x = -\nabla f(0)/L$, giving $f(0) - \|\nabla f(0)\|^2/(2L)$. So the minimum of $f$ exists and is finite.

But we need $\phi(x) \to +\infty$ as $\|x\| \to \infty$. Consider: for any $x$, by the lower bound from convexity at the minimizer of $f$ (call it $x^*$ with $\nabla f(x^*) = 0$):
$$f(x) \geq f(x^*).$$

So $\phi(x) = f(x) - \langle y, x\rangle \geq f(x^*) - \|y\| \cdot \|x\|$. This is linear in $\|x\|$, goes to $-\infty$. So this doesn't help.

But wait — does $f$ necessarily have a minimizer? Not if $f(x) = cx$ for constant $c$. But then $\nabla f(x) = c$ is $0$-Lipschitz, and $f^*$ is only defined on $\{c\}$ (it's $+\infty$ elsewhere).

So the issue is: for general convex $L$-smooth $f$, $\nabla f$ may not be surjective.

**Resolution**: We should assume $f$ is $L$-smooth and *supercoercive* (which follows if $f$ is $\mu$-strongly convex with $\mu > 0$, but not from $L$-smoothness alone).

Actually, the standard theorem in the literature states: if $f$ is closed convex and $L$-smooth, then $\text{dom}(f^*) = \text{range}(\nabla f)$, and $f^*$ is differentiable on $\text{int}(\text{dom}(f^*))$ with $\nabla f^* = (\nabla f)^{-1}$ there. And $f^*$ is $(1/L)$-strongly convex on its effective domain.

For the result as stated (on all of $\mathbb{R}^n$), we need $\nabla f$ to be surjective. This is guaranteed when $f$ is *strictly convex* and *supercoercive*.

However, there is a cleaner standard approach: **We don't need surjectivity for the core result.** The strong convexity inequality for $f^*$ holds on $\text{dom}(\partial f^*) = \text{range}(\partial f)$. And if we are just showing the duality between smoothness and strong convexity as properties (rather than on all of $\mathbb{R}^n$), the result holds on the effective domain.

For clarity, let us add the mild assumption that $f$ is supercoercive (i.e., $f(x)/\|x\| \to +\infty$ as $\|x\| \to \infty$), which ensures $\text{dom}(f^*) = \mathbb{R}^n$ and $\nabla f$ is surjective.

**Under supercoercivity**: For any $y$, $\phi(x) = f(x) - \langle y, x\rangle \to +\infty$ as $\|x\| \to \infty$ (since $f(x)/\|x\| \to \infty$ dominates $\|y\|$). So $\phi$ attains its minimum at some $x_y$ with $\nabla f(x_y) = y$. This $x_y$ is unique since... actually $f$ need not be strictly convex.

**[This route is getting bogged down in domain issues. Abandoning in favor of a cleaner approach.]**

---

*Note: This route has unresolved issues with the domain of $\nabla f^*$ and surjectivity of $\nabla f$. The proof is incomplete.*
