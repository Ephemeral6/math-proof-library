# Route 3: Via Conjugate of Quadratic Perturbation

## Setup

Let $f : \mathbb{R}^n \to \mathbb{R}$ be a closed convex function, differentiable on $\mathbb{R}^n$, with $L$-Lipschitz continuous gradient:
$$\|\nabla f(x) - \nabla f(y)\| \leq L\|x - y\| \quad \forall x, y \in \mathbb{R}^n.$$

The Fenchel conjugate: $f^*(y) = \sup_{x}[\langle y, x\rangle - f(x)]$.

---

## Step 1: $L$-smoothness $\Leftrightarrow$ $\frac{L}{2}\|\cdot\|^2 - f$ is convex

**Lemma**: $f$ is convex with $L$-Lipschitz gradient $\Leftrightarrow$ both $f$ and $g := \frac{L}{2}\|\cdot\|^2 - f$ are convex.

**Proof ($\Rightarrow$)**: $f$ is convex by assumption. For $g$: we need $g(y) \geq g(x) + \langle \nabla g(x), y-x\rangle$ for all $x, y$.

$$g(y) - g(x) - \langle \nabla g(x), y-x\rangle = \frac{L}{2}\|y\|^2 - f(y) - \frac{L}{2}\|x\|^2 + f(x) - \langle Lx - \nabla f(x), y-x\rangle.$$

$$= \frac{L}{2}(\|y\|^2 - \|x\|^2 - 2\langle x, y-x\rangle) - (f(y) - f(x) - \langle \nabla f(x), y-x\rangle)$$

$$= \frac{L}{2}\|y-x\|^2 - (f(y) - f(x) - \langle \nabla f(x), y-x\rangle).$$

By the descent lemma (QUB): $f(y) - f(x) - \langle \nabla f(x), y-x\rangle \leq \frac{L}{2}\|y-x\|^2$.

So the expression is $\geq 0$. Thus $g$ is convex.

**Proof ($\Leftarrow$)**: If $g$ is convex, then $g(y) \geq g(x) + \langle \nabla g(x), y-x\rangle$ gives $f(y) \leq f(x) + \langle \nabla f(x), y-x\rangle + \frac{L}{2}\|y-x\|^2$ (QUB). The QUB implies $L$-Lipschitz gradient (standard: evaluate QUB at $x$ towards $y$ and at $y$ towards $x$, add). $\blacksquare$

## Step 2: Conjugate Decomposition

Since $f$ is convex and $L$-smooth, write:
$$f(x) = \frac{L}{2}\|x\|^2 - g(x),$$
where $g(x) = \frac{L}{2}\|x\|^2 - f(x)$ is convex (Step 1).

Then:
$$f^*(y) = \sup_x \left[\langle y, x\rangle - \frac{L}{2}\|x\|^2 + g(x)\right].$$

**Key identity**: We use the infimal convolution. For two functions $\alpha, \beta$:
$$(\alpha \Box \beta)(y) = \inf_z [\alpha(z) + \beta(y-z)],$$
and $(\alpha \Box \beta)^* = \alpha^* + \beta^*$ (when proper closed convex).

We have $f = h - g$ where $h(x) = \frac{L}{2}\|x\|^2$. Note $h^*(y) = \frac{1}{2L}\|y\|^2$.

**Claim**: $f^* = g^* \Box h^*$, i.e., $f^*(y) = \inf_z [g^*(z) + h^*(y-z)] = \inf_z [g^*(z) + \frac{1}{2L}\|y-z\|^2]$.

**Proof of Claim**:
$$f^*(y) = \sup_x [\langle y, x\rangle - h(x) + g(x)].$$

For any $x$ and any $z$, by the definition of $g^*$: $g(x) \leq g^*(z) + \langle z, x\rangle - \langle z, x\rangle + g(x) \leq g^*(z)$ ... no, $g(x) = g^*(z) + \langle z, x \rangle$ only if $z \in \partial g(x)$.

Let me use a cleaner approach. Actually:
$$f^*(y) = \sup_x [\langle y, x\rangle - h(x) + g(x)] = \sup_x \left[\sup_z [\langle z, x\rangle - g^*(z)] - h(x) + \langle y-z, x\rangle + \langle z, x\rangle \right]$$

This is getting circular. Let me use the direct identity.

**Direct computation**: 
$$f(x) = h(x) - g(x) \quad \text{where } h(x) = \frac{L}{2}\|x\|^2.$$

By the conjugation rule for the difference of convex functions... this doesn't have a clean general rule. Let me try differently.

$f^*(y) = \sup_x [\langle y, x\rangle - \frac{L}{2}\|x\|^2 + g(x)]$.

Write $\langle y, x\rangle - \frac{L}{2}\|x\|^2 = -\frac{L}{2}\|x - y/L\|^2 + \frac{1}{2L}\|y\|^2$.

So:
$$f^*(y) = \frac{1}{2L}\|y\|^2 + \sup_x \left[g(x) - \frac{L}{2}\|x - y/L\|^2\right]$$
$$= \frac{1}{2L}\|y\|^2 - \inf_x \left[\frac{L}{2}\|x - y/L\|^2 - g(x)\right]$$
$$= \frac{1}{2L}\|y\|^2 - (h(\cdot - y/L) - g)^{\text{inf}}$$

where $(h(\cdot - y/L) - g)^{\text{inf}}$ denotes $\inf_x [h(x - y/L) - g(x)]$.

Alternatively, introduce $u = Lx$ so $x = u/L$:
$$f^*(y) = \sup_u \left[\frac{1}{L}\langle y, u\rangle - \frac{1}{2L}\|u\|^2 + g(u/L)\right].$$

This substitution complicates things. Let me try yet another approach.

**Direct approach to prove $f^*(y) - \frac{1}{2L}\|y\|^2$ is convex**:

We want to show $\psi(y) := f^*(y) - \frac{1}{2L}\|y\|^2$ is convex.

$$\psi(y) = \sup_x [\langle y, x\rangle - f(x)] - \frac{1}{2L}\|y\|^2 = \sup_x \left[\langle y, x\rangle - f(x) - \frac{1}{2L}\|y\|^2\right].$$

Complete the square in $y$:
$$\langle y, x\rangle - \frac{1}{2L}\|y\|^2 = -\frac{1}{2L}\|y - Lx\|^2 + \frac{L}{2}\|x\|^2.$$

So:
$$\psi(y) = \sup_x \left[-\frac{1}{2L}\|y - Lx\|^2 + \frac{L}{2}\|x\|^2 - f(x)\right] = \sup_x \left[g(x) - \frac{1}{2L}\|y - Lx\|^2\right].$$

Since $g$ is convex (Step 1), we can write $g(x) = \inf \{$ affine functions $\leq g\}$... no, $g$ is convex so $g = \sup\{$ affine minorants $\}$.

Hmm, a supremum of concave functions (in $y$) is not necessarily convex. We need a different approach.

**Use the Moreau envelope perspective**: 
$$\psi(y) = \sup_x \left[g(x) - \frac{1}{2L}\|y - Lx\|^2\right].$$

Substitute $w = Lx$, so $x = w/L$:
$$\psi(y) = \sup_w \left[g(w/L) - \frac{1}{2L}\|y - w\|^2\right].$$

Let $\tilde{g}(w) = g(w/L)$. Then:
$$\psi(y) = \sup_w \left[\tilde{g}(w) - \frac{1}{2L}\|y - w\|^2\right] = -\inf_w \left[\frac{1}{2L}\|y-w\|^2 - \tilde{g}(w)\right].$$

This is the negative of the Moreau envelope of $-\tilde{g}$ with parameter $1/L$... but $-\tilde{g}$ is concave, so this is a bit unusual.

This route is getting algebraically messy. Let me try the most direct approach instead.

---

## RESTART: Clean Direct Proof via Route 3

We prove $f^*$ is $(1/L)$-strongly convex by showing the strong convexity inequality directly.

### Part 1: Inverse Gradient Identity

For closed convex differentiable $f$, the Fenchel-Young equality states:
$$f(x) + f^*(y) = \langle x, y\rangle \iff y = \nabla f(x).$$

**Claim**: $\nabla f$ is injective (and hence invertible on its range).

**Proof**: Suppose $\nabla f(x_1) = \nabla f(x_2) = y$. By cocoercivity (proved in Route 2, Lemma C):
$$0 = \frac{1}{L}\|\nabla f(x_1) - \nabla f(x_2)\|^2 \leq \langle \nabla f(x_1) - \nabla f(x_2), x_1 - x_2\rangle = 0.$$

So $\langle 0, x_1 - x_2\rangle = 0$, which is trivially true. This doesn't give $x_1 = x_2$.

Actually, from cocoercivity $\langle p-q, x-y\rangle \geq \frac{1}{L}\|p-q\|^2$, if $p = q$ we get $0 \geq 0$, which is fine but doesn't help.

For injectivity, we need *strict* monotonicity or something stronger. Actually, $\nabla f$ may NOT be injective for general convex $L$-smooth $f$ (consider $f(x,y) = \frac{L}{2}x^2$, then $\nabla f(x,y) = (Lx, 0)$ which is not injective).

However, when $\nabla f(x_1) = \nabla f(x_2) = y$, both $x_1$ and $x_2$ maximize $\langle y, \cdot\rangle - f(\cdot)$, and the set of maximizers is convex (since $f$ is convex). So $f^*(y)$ is well-defined regardless.

For differentiability of $f^*$: If the maximizer in $f^*(y) = \sup_x [\langle y, x\rangle - f(x)]$ is unique, then $f^*$ is differentiable at $y$ with $\nabla f^*(y) = x$ (where $x$ is the unique maximizer, i.e., $\nabla f(x) = y$).

*Actually*, for $L$-smooth $f$, the maximizer IS unique even without strict convexity of $f$, because:

$x$ maximizes $\langle y, \cdot\rangle - f(\cdot)$ iff $\nabla f(x) = y$, and:

If $\nabla f(x_1) = \nabla f(x_2) = y$, then by QUB at $x_1$ towards $x_2$:
$$f(x_2) \leq f(x_1) + \langle y, x_2 - x_1\rangle + \frac{L}{2}\|x_2 - x_1\|^2.$$
By convexity at $x_2$ towards $x_1$:
$$f(x_1) \geq f(x_2) + \langle y, x_1 - x_2\rangle.$$
Adding: $0 \leq \frac{L}{2}\|x_2 - x_1\|^2 + 0$. 

From convexity at $x_1$ towards $x_2$: $f(x_2) \geq f(x_1) + \langle y, x_2 - x_1\rangle$.
From QUB at $x_1$ towards $x_2$: $f(x_2) \leq f(x_1) + \langle y, x_2 - x_1\rangle + \frac{L}{2}\|x_2 - x_1\|^2$.

So: $f(x_1) + \langle y, x_2-x_1\rangle \leq f(x_2) \leq f(x_1) + \langle y, x_2-x_1\rangle + \frac{L}{2}\|x_2-x_1\|^2$.

This gives $0 \leq \frac{L}{2}\|x_2 - x_1\|^2$, which is trivially true.

Hmm, so we can't prove uniqueness this way! The issue is that if $f$ is only convex (not strictly convex), the maximizer may not be unique.

However, there's a subtlety: even if the set of maximizers $S_y = \{x : \nabla f(x) = y\}$ is not a singleton, we still have:

All $x \in S_y$ give the same value $\langle y, x\rangle - f(x) = f^*(y)$. And on $S_y$, $f$ is affine (since $f(x) = \langle y, x\rangle - f^*(y)$ for all $x \in S_y$).

For differentiability of $f^*$ at $y$: We need $\partial f^*(y)$ to be a singleton. We know $\partial f^*(y) = \arg\max_x [\langle y, x\rangle - f(x)] = S_y$, so we need $S_y$ to be a singleton.

**Key insight**: $S_y$ IS a singleton. Here's why: Suppose $x_1, x_2 \in S_y$ with $x_1 \neq x_2$. Then $\nabla f(x_1) = \nabla f(x_2) = y$ and $f$ is affine on $[x_1, x_2]$: $f((1-t)x_1 + tx_2) = (1-t)f(x_1) + tf(x_2)$ for $t \in [0,1]$. 

For $z_t = (1-t)x_1 + tx_2$, by differentiability:
$$\nabla f(z_t) \cdot (x_2 - x_1) = \frac{d}{dt}f(z_t) = f(x_2) - f(x_1) = \langle y, x_2 - x_1\rangle.$$

Wait, the derivative with respect to $t$:
$$\frac{d}{dt}f(z_t) = \langle \nabla f(z_t), x_2 - x_1\rangle.$$

If $f$ is affine on $[x_1, x_2]$, then $\frac{d}{dt}f(z_t) = f(x_2) - f(x_1) = \text{const}$.

So $\langle \nabla f(z_t), x_2 - x_1\rangle$ is constant for $t \in [0,1]$, equal to $\langle y, x_2 - x_1\rangle$.

This means $\langle \nabla f(z_t) - y, x_2 - x_1\rangle = 0$ for all $t$, but it does NOT mean $\nabla f(z_t) = y$.

In the direction perpendicular to $x_2 - x_1$, $\nabla f(z_t)$ could vary. However, by convexity of $f$, for any $v$:
$$f(z_t + sv) \geq f(z_t) + s\langle \nabla f(z_t), v\rangle.$$

Since $z_t$ varies linearly and $f$ is affine on the segment, $\nabla f(z_t)$ might vary. But by the Lipschitz condition: $\|\nabla f(z_t) - \nabla f(z_0)\| \leq Lt\|x_2 - x_1\|$. And $\nabla f(z_0) = \nabla f(x_1) = y$.

So we need $\nabla f(z_t) = y$ for all $t$, but we can only say $\|\nabla f(z_t) - y\| \leq Lt\|x_2 - x_1\|$. Not helpful for proving $S_y$ is a singleton.

**Resolution**: In fact, for general convex $L$-smooth $f$, $\nabla f$ need NOT be injective. Example: $f(x_1, x_2) = \frac{L}{2}x_1^2$ is convex with $L$-Lipschitz gradient $\nabla f = (Lx_1, 0)$, and $\nabla f(0, a) = (0,0)$ for all $a$.

So $\partial f^*(0,0) = \{(0, a) : a \in \mathbb{R}\}$, which is not a singleton. Therefore $f^*$ is NOT differentiable at $(0,0)$.

**Conclusion**: The full result as stated (differentiability of $f^*$ everywhere) requires additional assumptions. The standard statement assumes $f$ is *essentially smooth* (meaning $f$ is differentiable on $\text{int}(\text{dom}(f))$ and $\|\nabla f(x_k)\| \to \infty$ whenever $x_k \to \partial(\text{dom}(f))$) or, more commonly, that $f$ is *supercoercive* (or *essentially strictly convex*).

The standard clean version: If $f$ is **$L$-smooth** and **supercoercive** (i.e., $\lim_{\|x\|\to\infty} f(x)/\|x\| = +\infty$), then $\text{dom}(f^*) = \mathbb{R}^n$, $f^*$ is differentiable, $\nabla f^* = (\nabla f)^{-1}$, and $f^*$ is $(1/L)$-strongly convex.

Even cleaner: the duality works perfectly when we state it as:

> $f$ is $\mu$-strongly convex and $L$-smooth $\Leftrightarrow$ $f^*$ is $(1/L)$-strongly convex and $(1/\mu)$-smooth.

With $\mu > 0$, all domain issues vanish.

**For our proof, we will work with the most general correct statement**: $f$ is closed convex, $\text{dom}(f) = \mathbb{R}^n$, $L$-smooth. Then $f^*$ is $(1/L)$-strongly convex on its effective domain $\text{dom}(f^*) = \text{range}(\nabla f)$ (which is a convex set), and differentiable on $\text{int}(\text{dom}(f^*))$ with $\nabla f^* = (\nabla f)^{-1}$.

When $f$ is additionally **strictly convex**, $\nabla f$ is injective and (combined with surjectivity from supercoercivity of strictly convex $L$-smooth functions) $\nabla f$ is a bijection $\mathbb{R}^n \to \mathbb{R}^n$, so $f^*$ is differentiable everywhere.

---

## This route identified critical domain issues. The proof will be completed and cleaned up using insights from all routes.
