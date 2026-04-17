# Route 3: Lyapunov Energy Function Approach

## Extragradient Method — O(1/K) Convergence for Convex-Concave Minimax

---

## Setup and Notation

**Problem.** Consider the saddle-point problem:
$$\min_{x \in \mathcal{X}} \max_{y \in \mathcal{Y}} f(x, y)$$
where $\mathcal{Z} = \mathcal{X} \times \mathcal{Y}$ is a closed convex set with diameter $D = \max_{z, z' \in \mathcal{Z}} \|z - z'\|$, and $f$ is:
- Convex in $x$ for each fixed $y$
- Concave in $y$ for each fixed $x$
- $L$-smooth: $\nabla f$ is $L$-Lipschitz continuous

**Operator.** Define the monotone operator:
$$F(z) = F(x, y) = \begin{pmatrix} \nabla_x f(x, y) \\ -\nabla_y f(x, y) \end{pmatrix}$$

Since $f$ is convex in $x$ and concave in $y$, the operator $F$ is **monotone**:
$$\langle F(z) - F(z'), z - z' \rangle \geq 0, \quad \forall z, z' \in \mathcal{Z}$$

Since $f$ is $L$-smooth, $F$ is $L$-Lipschitz:
$$\|F(z) - F(z')\| \leq L \|z - z'\|, \quad \forall z, z' \in \mathcal{Z}$$

**Extragradient (EG) Method.** With step size $\eta > 0$:
$$\bar{z}^k = \Pi_{\mathcal{Z}}(z^k - \eta F(z^k))$$
$$z^{k+1} = \Pi_{\mathcal{Z}}(z^k - \eta F(\bar{z}^k))$$

where $\Pi_{\mathcal{Z}}$ denotes Euclidean projection onto $\mathcal{Z}$.

**Saddle point.** $z^* = (x^*, y^*)$ satisfies $f(x^*, y) \leq f(x^*, y^*) \leq f(x, y^*)$ for all $(x,y) \in \mathcal{Z}$. Equivalently, $z^*$ solves the variational inequality: $\langle F(z^*), z - z^* \rangle \geq 0$ for all $z \in \mathcal{Z}$.

**Duality gap.** For $\hat{z} = (\hat{x}, \hat{y})$:
$$\text{Gap}(\hat{z}) = \max_{y \in \mathcal{Y}} f(\hat{x}, y) - \min_{x \in \mathcal{X}} f(x, \hat{y})$$

**Target.** With $\eta = \frac{1}{2L}$, the averaged iterate $\hat{z}^K = \frac{1}{K} \sum_{k=0}^{K-1} \bar{z}^k$ satisfies:
$$\text{Gap}(\hat{z}^K) \leq \frac{2L D^2}{K}$$

---

## Preliminary Lemmas

### Lemma 1 (Projection inequality)

For any $w \in \mathbb{R}^n$, $z \in \mathcal{Z}$, and $\hat{z} = \Pi_{\mathcal{Z}}(w)$:
$$\|\hat{z} - z\|^2 \leq \|w - z\|^2 - \|w - \hat{z}\|^2$$

**Proof.** By the characterization of projection onto a convex set, $\langle w - \hat{z}, z - \hat{z} \rangle \leq 0$ for all $z \in \mathcal{Z}$. Expanding:
$$\|w - z\|^2 = \|w - \hat{z} + \hat{z} - z\|^2 = \|w - \hat{z}\|^2 + 2\langle w - \hat{z}, \hat{z} - z \rangle + \|\hat{z} - z\|^2$$

Since $\langle w - \hat{z}, \hat{z} - z \rangle \geq 0$ (by flipping the projection inequality), we get:
$$\|w - z\|^2 \geq \|w - \hat{z}\|^2 + \|\hat{z} - z\|^2$$

Rearranging: $\|\hat{z} - z\|^2 \leq \|w - z\|^2 - \|w - \hat{z}\|^2$. $\blacksquare$

### Lemma 2 (Three-point identity for projections)

For any $w \in \mathbb{R}^n$, $\hat{z} = \Pi_{\mathcal{Z}}(w)$, and $u \in \mathcal{Z}$:
$$2\langle w - \hat{z}, \hat{z} - u \rangle \geq \|\hat{z} - w\|^2 + \|\hat{z} - u\|^2 - \|w - u\|^2$$

Actually, we use the more direct form. Since $\hat{z} = \Pi_{\mathcal{Z}}(w)$, the projection property gives $\langle w - \hat{z}, u - \hat{z} \rangle \leq 0$, i.e.:
$$\langle \hat{z} - w, u - \hat{z} \rangle \geq 0$$

Equivalently:
$$\langle w - \hat{z}, \hat{z} - u \rangle \geq 0 \quad \forall u \in \mathcal{Z} \tag{P}$$

### Lemma 3 (Convexity-concavity and the operator)

For any $\bar{z} = (\bar{x}, \bar{y}) \in \mathcal{Z}$ and $u = (x_u, y_u) \in \mathcal{Z}$:
$$\langle F(\bar{z}), \bar{z} - u \rangle \geq f(\bar{x}, y_u) - f(x_u, \bar{y})$$

**Proof.** By convexity of $f(\cdot, \bar{y})$ in $x$:
$$f(x_u, \bar{y}) \geq f(\bar{x}, \bar{y}) + \langle \nabla_x f(\bar{x}, \bar{y}), x_u - \bar{x} \rangle$$

So: $\langle \nabla_x f(\bar{x}, \bar{y}), \bar{x} - x_u \rangle \geq f(\bar{x}, \bar{y}) - f(x_u, \bar{y})$.

By concavity of $f(\bar{x}, \cdot)$ in $y$:
$$f(y_u | \bar{x}) \leq f(\bar{x}, \bar{y}) + \langle \nabla_y f(\bar{x}, \bar{y}), y_u - \bar{y} \rangle$$

So: $\langle \nabla_y f(\bar{x}, \bar{y}), y_u - \bar{y} \rangle \geq f(\bar{x}, y_u) - f(\bar{x}, \bar{y})$.

Equivalently: $\langle -\nabla_y f(\bar{x}, \bar{y}), \bar{y} - y_u \rangle \geq f(\bar{x}, y_u) - f(\bar{x}, \bar{y})$.

Adding the two inequalities:
$$\langle \nabla_x f(\bar{x}, \bar{y}), \bar{x} - x_u \rangle + \langle -\nabla_y f(\bar{x}, \bar{y}), \bar{y} - y_u \rangle \geq f(\bar{x}, y_u) - f(x_u, \bar{y})$$

The left side is exactly $\langle F(\bar{z}), \bar{z} - u \rangle$. $\blacksquare$

---

## Main Proof

### Phase 1: One-step descent inequality

**Proposition 1.** For any $u \in \mathcal{Z}$ and any $k \geq 0$:
$$2\eta \langle F(\bar{z}^k), \bar{z}^k - u \rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 - (1 - \eta^2 L^2)\|\bar{z}^k - z^k\|^2$$

**Proof.** 

**Step 1: Expand the update step.**

Since $z^{k+1} = \Pi_{\mathcal{Z}}(z^k - \eta F(\bar{z}^k))$, apply Lemma 1 with $w = z^k - \eta F(\bar{z}^k)$:

$$\|z^{k+1} - u\|^2 \leq \|z^k - \eta F(\bar{z}^k) - u\|^2 - \|z^k - \eta F(\bar{z}^k) - z^{k+1}\|^2$$

For the first term on the right:
$$\|z^k - \eta F(\bar{z}^k) - u\|^2 = \|z^k - u\|^2 - 2\eta \langle F(\bar{z}^k), z^k - u \rangle + \eta^2 \|F(\bar{z}^k)\|^2$$

Dropping the non-negative term $\|z^k - \eta F(\bar{z}^k) - z^{k+1}\|^2 \geq 0$:
$$\|z^{k+1} - u\|^2 \leq \|z^k - u\|^2 - 2\eta \langle F(\bar{z}^k), z^k - u \rangle + \eta^2 \|F(\bar{z}^k)\|^2 \tag{1}$$

Rearranging:
$$2\eta \langle F(\bar{z}^k), z^k - u \rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 + \eta^2 \|F(\bar{z}^k)\|^2 \tag{2}$$

**Step 2: Decompose the inner product.**

Write:
$$\langle F(\bar{z}^k), z^k - u \rangle = \langle F(\bar{z}^k), z^k - \bar{z}^k \rangle + \langle F(\bar{z}^k), \bar{z}^k - u \rangle$$

So from (2):
$$2\eta \langle F(\bar{z}^k), \bar{z}^k - u \rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 + \eta^2 \|F(\bar{z}^k)\|^2 - 2\eta \langle F(\bar{z}^k), z^k - \bar{z}^k \rangle \tag{3}$$

**Step 3: Bound the last two terms using the extrapolation step.**

Since $\bar{z}^k = \Pi_{\mathcal{Z}}(z^k - \eta F(z^k))$, the projection property (P) gives:
$$\langle (z^k - \eta F(z^k)) - \bar{z}^k, u - \bar{z}^k \rangle \leq 0 \quad \forall u \in \mathcal{Z}$$

In particular, setting $u := z^k$:
$$\langle (z^k - \eta F(z^k)) - \bar{z}^k, z^k - \bar{z}^k \rangle \leq 0$$

This gives:
$$\|z^k - \bar{z}^k\|^2 - \eta \langle F(z^k), z^k - \bar{z}^k \rangle \leq 0$$

Therefore:
$$\|z^k - \bar{z}^k\|^2 \leq \eta \langle F(z^k), z^k - \bar{z}^k \rangle \tag{4}$$

**Step 4: Handle the cross terms in (3).**

We analyze $\eta^2 \|F(\bar{z}^k)\|^2 - 2\eta \langle F(\bar{z}^k), z^k - \bar{z}^k \rangle$. Write:

$$-2\eta \langle F(\bar{z}^k), z^k - \bar{z}^k \rangle = 2\eta \langle F(\bar{z}^k), \bar{z}^k - z^k \rangle$$

Now add and subtract $F(z^k)$:
$$2\eta \langle F(\bar{z}^k), \bar{z}^k - z^k \rangle = 2\eta \langle F(z^k), \bar{z}^k - z^k \rangle + 2\eta \langle F(\bar{z}^k) - F(z^k), \bar{z}^k - z^k \rangle$$

From (4): $2\eta \langle F(z^k), \bar{z}^k - z^k \rangle \leq -2\|z^k - \bar{z}^k\|^2$.

By Cauchy-Schwarz and Lipschitz continuity:
$$2\eta \langle F(\bar{z}^k) - F(z^k), \bar{z}^k - z^k \rangle \leq 2\eta \|F(\bar{z}^k) - F(z^k)\| \cdot \|\bar{z}^k - z^k\| \leq 2\eta L \|\bar{z}^k - z^k\|^2$$

Also, by Lipschitz continuity:
$$\eta^2 \|F(\bar{z}^k)\|^2 = \eta^2 \|F(\bar{z}^k) - F(z^k) + F(z^k)\|^2$$

This approach gets complicated. Let us use a cleaner route.

**Step 4 (cleaner approach): Direct bound on the residual terms.**

Return to (3):
$$2\eta \langle F(\bar{z}^k), \bar{z}^k - u \rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 + \eta^2 \|F(\bar{z}^k)\|^2 + 2\eta \langle F(\bar{z}^k), \bar{z}^k - z^k \rangle$$

We bound the last two terms together. Write $F(\bar{z}^k) = F(\bar{z}^k) - F(z^k) + F(z^k)$ and use:

$$\eta^2\|F(\bar{z}^k)\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^k\rangle$$
$$= \eta^2\|F(\bar{z}^k) - F(z^k) + F(z^k)\|^2 + 2\eta\langle F(\bar{z}^k) - F(z^k) + F(z^k), \bar{z}^k - z^k\rangle$$

This is still messy. Let us instead use **the standard EG analysis** via a different decomposition.

**Step 4 (standard approach):** We restart from (1) more carefully, keeping the dropped term.

From the projection in the update step:
$$\|z^{k+1} - u\|^2 \leq \|z^k - \eta F(\bar{z}^k) - u\|^2 - \|z^k - \eta F(\bar{z}^k) - z^{k+1}\|^2$$

Expanding the first term:
$$= \|z^k - u\|^2 - 2\eta\langle F(\bar{z}^k), z^k - u\rangle + \eta^2\|F(\bar{z}^k)\|^2 - \|z^k - \eta F(\bar{z}^k) - z^{k+1}\|^2$$

Now from the extrapolation step, applying Lemma 1 with $w = z^k - \eta F(z^k)$, $\hat{z} = \bar{z}^k$:
$$\|\bar{z}^k - u\|^2 \leq \|z^k - \eta F(z^k) - u\|^2 - \|z^k - \eta F(z^k) - \bar{z}^k\|^2$$

We do not directly need this. Instead, let us use the key identity more carefully.

**Step 4 (definitive approach via the three-point technique):**

Apply the projection property to the extrapolation step. Since $\bar{z}^k = \Pi_{\mathcal{Z}}(z^k - \eta F(z^k))$, for all $u \in \mathcal{Z}$:
$$\langle z^k - \eta F(z^k) - \bar{z}^k, u - \bar{z}^k \rangle \leq 0$$

This gives:
$$\langle z^k - \bar{z}^k, u - \bar{z}^k \rangle \leq \eta \langle F(z^k), u - \bar{z}^k \rangle \tag{5}$$

Similarly, since $z^{k+1} = \Pi_{\mathcal{Z}}(z^k - \eta F(\bar{z}^k))$, for all $u \in \mathcal{Z}$:
$$\langle z^k - \eta F(\bar{z}^k) - z^{k+1}, u - z^{k+1} \rangle \leq 0$$

This gives:
$$\langle z^k - z^{k+1}, u - z^{k+1} \rangle \leq \eta \langle F(\bar{z}^k), u - z^{k+1} \rangle \tag{6}$$

**From (6)**, using the identity $\langle a - b, c - b \rangle = \frac{1}{2}(\|a-c\|^2 - \|a-b\|^2 - \|b-c\|^2) + \|a-b\|^2$... let's use a more direct approach.

From (6):
$$\langle z^k - z^{k+1}, u - z^{k+1} \rangle \leq \eta \langle F(\bar{z}^k), u - z^{k+1} \rangle$$

By the polarization identity: $\langle a, b \rangle = \frac{1}{2}(\|a\|^2 + \|b\|^2 - \|a - b\|^2)$, with $a = z^k - z^{k+1}$ and $b = u - z^{k+1}$:

Actually, use the simpler identity:
$$\langle z^k - z^{k+1}, u - z^{k+1} \rangle = \frac{1}{2}\left(\|z^k - u\|^2 - \|z^k - z^{k+1}\|^2 - \|z^{k+1} - u\|^2 + 2\|z^{k+1} - u\|^2 \right)$$

No — let us just use the clean standard identity:
$$2\langle a - b, c - b \rangle = \|a - b\|^2 + \|c - b\|^2 - \|a - c\|^2 \quad \text{wait, that's wrong.}$$

The correct identity is:
$$2\langle a, b\rangle = \|a\|^2 + \|b\|^2 - \|a - b\|^2$$

With $a = z^k - z^{k+1}$, $b = u - z^{k+1}$, $a - b = z^k - u$:
$$2\langle z^k - z^{k+1}, u - z^{k+1}\rangle = \|z^k - z^{k+1}\|^2 + \|u - z^{k+1}\|^2 - \|z^k - u\|^2$$

So from (6):
$$\|z^k - z^{k+1}\|^2 + \|z^{k+1} - u\|^2 - \|z^k - u\|^2 \leq 2\eta\langle F(\bar{z}^k), u - z^{k+1}\rangle$$

Rearranging:
$$\|z^k - u\|^2 - \|z^{k+1} - u\|^2 \geq \|z^k - z^{k+1}\|^2 - 2\eta\langle F(\bar{z}^k), u - z^{k+1}\rangle$$

Now decompose $u - z^{k+1} = (u - \bar{z}^k) + (\bar{z}^k - z^{k+1})$:

$$2\eta\langle F(\bar{z}^k), u - z^{k+1}\rangle = 2\eta\langle F(\bar{z}^k), u - \bar{z}^k\rangle + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle$$

So:
$$\|z^k - u\|^2 - \|z^{k+1} - u\|^2 \geq \|z^k - z^{k+1}\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle - 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle$$

Therefore:
$$2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 - \|z^k - z^{k+1}\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle \tag{7}$$

**Step 5: Bound the term $2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle$.**

Write $\bar{z}^k - z^{k+1} = (\bar{z}^k - z^k) + (z^k - z^{k+1})$:
$$2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle = 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^k\rangle + 2\eta\langle F(\bar{z}^k), z^k - z^{k+1}\rangle$$

For the second term, since $z^{k+1} = \Pi_{\mathcal{Z}}(z^k - \eta F(\bar{z}^k))$, we have:
$$z^k - z^{k+1} = z^k - \Pi_{\mathcal{Z}}(z^k - \eta F(\bar{z}^k))$$

and $\|z^k - z^{k+1}\| \leq \|z^k - (z^k - \eta F(\bar{z}^k))\| = \eta\|F(\bar{z}^k)\|$ (projection is non-expansive... actually: $\|z^{k+1} - z^k\| \leq \|(z^k - \eta F(\bar{z}^k)) - z^k\| = \eta\|F(\bar{z}^k)\|$ only if $z^k \in \mathcal{Z}$, which it is).

Wait, that's the firm non-expansiveness used incorrectly. Actually since $z^k \in \mathcal{Z}$ (so $\Pi(z^k) = z^k$) and projection is non-expansive:
$$\|z^{k+1} - z^k\| = \|\Pi(z^k - \eta F(\bar{z}^k)) - \Pi(z^k)\| \leq \|\eta F(\bar{z}^k)\| = \eta\|F(\bar{z}^k)\|$$

This gives a bound but still involves $\|F(\bar{z}^k)\|$. Let us take a cleaner approach entirely.

---

### Phase 1 (Clean Version): The Key One-Step Inequality

We restart the argument using the **standard Korpelevich/Tseng analysis**.

**Proposition 1 (restated).** For any $u \in \mathcal{Z}$ and $k \geq 0$, with $\eta \leq \frac{1}{2L}$:
$$2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 - (1 - \eta^2 L^2)\|\bar{z}^k - z^k\|^2$$

**Proof.**

**Step A.** Apply Lemma 1 to the update step $z^{k+1} = \Pi_{\mathcal{Z}}(z^k - \eta F(\bar{z}^k))$:
$$\|z^{k+1} - u\|^2 \leq \|z^k - \eta F(\bar{z}^k) - u\|^2 \tag{A1}$$

(We drop the $-\|z^k - \eta F(\bar{z}^k) - z^{k+1}\|^2$ term, which only helps.)

Expand:
$$\|z^{k+1} - u\|^2 \leq \|z^k - u\|^2 - 2\eta\langle F(\bar{z}^k), z^k - u\rangle + \eta^2\|F(\bar{z}^k)\|^2 \tag{A2}$$

**Step B.** Decompose $z^k - u = (z^k - \bar{z}^k) + (\bar{z}^k - u)$:
$$\langle F(\bar{z}^k), z^k - u\rangle = \langle F(\bar{z}^k), z^k - \bar{z}^k\rangle + \langle F(\bar{z}^k), \bar{z}^k - u\rangle$$

Substituting into (A2):
$$\|z^{k+1} - u\|^2 \leq \|z^k - u\|^2 - 2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle - 2\eta\langle F(\bar{z}^k), z^k - \bar{z}^k\rangle + \eta^2\|F(\bar{z}^k)\|^2$$

Rearranging:
$$2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 + \underbrace{\eta^2\|F(\bar{z}^k)\|^2 - 2\eta\langle F(\bar{z}^k), z^k - \bar{z}^k\rangle}_{=: R_k} \tag{A3}$$

**Step C.** We now bound $R_k$. Decompose $F(\bar{z}^k) = F(z^k) + (F(\bar{z}^k) - F(z^k))$:

$$R_k = \eta^2\|F(\bar{z}^k)\|^2 - 2\eta\langle F(\bar{z}^k), z^k - \bar{z}^k\rangle$$

$$= \eta^2\|F(\bar{z}^k)\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^k\rangle$$

$$= \eta^2\|F(\bar{z}^k)\|^2 + 2\eta\langle F(z^k), \bar{z}^k - z^k\rangle + 2\eta\langle F(\bar{z}^k) - F(z^k), \bar{z}^k - z^k\rangle$$

**Bound the first inner product** using (4) (from Step 3 of the earlier attempt):
From the extrapolation projection property with $u = z^k$ (since $z^k \in \mathcal{Z}$):
$$\langle z^k - \eta F(z^k) - \bar{z}^k, z^k - \bar{z}^k \rangle \leq 0$$

$$\|z^k - \bar{z}^k\|^2 \leq \eta\langle F(z^k), z^k - \bar{z}^k\rangle$$

So:
$$\eta\langle F(z^k), \bar{z}^k - z^k\rangle \leq -\|z^k - \bar{z}^k\|^2$$

$$2\eta\langle F(z^k), \bar{z}^k - z^k\rangle \leq -2\|\bar{z}^k - z^k\|^2 \tag{A4}$$

**Bound the second inner product** by Cauchy-Schwarz and Lipschitz:
$$2\eta\langle F(\bar{z}^k) - F(z^k), \bar{z}^k - z^k\rangle \leq 2\eta\|F(\bar{z}^k) - F(z^k)\| \cdot \|\bar{z}^k - z^k\| \leq 2\eta L\|\bar{z}^k - z^k\|^2 \tag{A5}$$

**Bound $\eta^2\|F(\bar{z}^k)\|^2$**. By Lipschitz continuity:
$$\|F(\bar{z}^k)\| \leq \|F(\bar{z}^k) - F(z^k)\| + \|F(z^k)\| \leq L\|\bar{z}^k - z^k\| + \|F(z^k)\|$$

But this introduces $\|F(z^k)\|$ which we cannot control directly. We need a different decomposition.

**Alternative bound for $R_k$:**

Instead, write:
$$R_k = \eta^2\|F(\bar{z}^k)\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^k\rangle$$

$$= \eta^2\|F(\bar{z}^k)\|^2 + 2\eta\langle F(z^k) + (F(\bar{z}^k) - F(z^k)), \bar{z}^k - z^k\rangle$$

Using (A4) and (A5):
$$\leq \eta^2\|F(\bar{z}^k)\|^2 - 2\|\bar{z}^k - z^k\|^2 + 2\eta L\|\bar{z}^k - z^k\|^2$$

Now we handle $\eta^2\|F(\bar{z}^k)\|^2$ differently. From the extrapolation step, using Lemma 1 with $w = z^k - \eta F(z^k)$, $\hat{z} = \bar{z}^k$ (projecting onto $\mathcal{Z}$), and any $z \in \mathcal{Z}$:

$$\|\bar{z}^k - z\|^2 \leq \|z^k - \eta F(z^k) - z\|^2 - \|z^k - \eta F(z^k) - \bar{z}^k\|^2$$

Setting $z = z^k$:
$$\|\bar{z}^k - z^k\|^2 \leq \eta^2\|F(z^k)\|^2 - \|z^k - \eta F(z^k) - \bar{z}^k\|^2 \leq \eta^2\|F(z^k)\|^2$$

So $\|\bar{z}^k - z^k\| \leq \eta\|F(z^k)\|$.

By Lipschitz: $\|F(\bar{z}^k)\| \leq \|F(z^k)\| + L\|\bar{z}^k - z^k\| \leq \|F(z^k)\| + \eta L^2\|F(z^k)\| \leq (1 + \eta L)\|F(z^k)\|$.

So $\eta^2\|F(\bar{z}^k)\|^2 \leq \eta^2(1+\eta L)^2\|F(z^k)\|^2$. This still has $\|F(z^k)\|$.

**Let us use the correct standard approach.**

---

### Phase 1 (Definitive): Standard EG One-Step Bound

The cleanest known approach avoids bounding $\|F(\bar{z}^k)\|^2$ directly and instead uses the **co-coercivity** style argument.

**Proposition 1 (definitive version).** For any $u \in \mathcal{Z}$, $k \geq 0$:
$$2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 - \|\bar{z}^k - z^k\|^2 + \eta^2\|F(\bar{z}^k) - F(z^k)\|^2$$

and consequently, since $\|F(\bar{z}^k) - F(z^k)\| \leq L\|\bar{z}^k - z^k\|$:
$$2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 - (1 - \eta^2 L^2)\|\bar{z}^k - z^k\|^2$$

**Proof.**

From the update step $z^{k+1} = \Pi_{\mathcal{Z}}(z^k - \eta F(\bar{z}^k))$, by Lemma 1:
$$\|z^{k+1} - u\|^2 \leq \|z^k - \eta F(\bar{z}^k) - u\|^2 - \|z^k - \eta F(\bar{z}^k) - z^{k+1}\|^2 \tag{B1}$$

Expand the first term:
$$\|z^k - \eta F(\bar{z}^k) - u\|^2 = \|(z^k - u) - \eta F(\bar{z}^k)\|^2$$
$$= \|z^k - u\|^2 - 2\eta\langle F(\bar{z}^k), z^k - u\rangle + \eta^2\|F(\bar{z}^k)\|^2$$

We drop the second subtracted term in (B1) (it's non-negative), getting:
$$\|z^{k+1} - u\|^2 \leq \|z^k - u\|^2 - 2\eta\langle F(\bar{z}^k), z^k - u\rangle + \eta^2\|F(\bar{z}^k)\|^2 \tag{B2}$$

Now from the extrapolation step $\bar{z}^k = \Pi_{\mathcal{Z}}(z^k - \eta F(z^k))$, applying Lemma 1 with the point $\bar{z}^k$ instead of $u$, and $w = z^k - \eta F(z^k)$, and taking $z = z^k \in \mathcal{Z}$:

$$\|\bar{z}^k - z^k\|^2 \leq \|z^k - \eta F(z^k) - z^k\|^2 - \|z^k - \eta F(z^k) - \bar{z}^k\|^2$$
$$= \eta^2\|F(z^k)\|^2 - \|z^k - \eta F(z^k) - \bar{z}^k\|^2 \tag{B3}$$

From (B3): $\|z^k - \eta F(z^k) - \bar{z}^k\|^2 \leq \eta^2\|F(z^k)\|^2 - \|\bar{z}^k - z^k\|^2$.

Also, note:
$$\|z^k - \eta F(z^k) - \bar{z}^k\|^2 = \|z^k - \bar{z}^k\|^2 - 2\eta\langle F(z^k), z^k - \bar{z}^k\rangle + \eta^2\|F(z^k)\|^2$$

Wait, $z^k - \eta F(z^k) - \bar{z}^k = (z^k - \bar{z}^k) - \eta F(z^k)$, so:
$$\|z^k - \eta F(z^k) - \bar{z}^k\|^2 = \|z^k - \bar{z}^k\|^2 - 2\eta\langle F(z^k), z^k - \bar{z}^k\rangle + \eta^2\|F(z^k)\|^2$$

Substituting back into (B3):
$$\|\bar{z}^k - z^k\|^2 \leq \eta^2\|F(z^k)\|^2 - \|z^k - \bar{z}^k\|^2 + 2\eta\langle F(z^k), z^k - \bar{z}^k\rangle - \eta^2\|F(z^k)\|^2$$
$$= -\|\bar{z}^k - z^k\|^2 + 2\eta\langle F(z^k), z^k - \bar{z}^k\rangle$$

Therefore:
$$2\|\bar{z}^k - z^k\|^2 \leq 2\eta\langle F(z^k), z^k - \bar{z}^k\rangle$$
$$\|\bar{z}^k - z^k\|^2 \leq \eta\langle F(z^k), z^k - \bar{z}^k\rangle \tag{B4}$$

(This confirms equation (4) from earlier.)

Now return to (B2) and split:
$$2\eta\langle F(\bar{z}^k), z^k - u\rangle = 2\eta\langle F(\bar{z}^k), z^k - \bar{z}^k\rangle + 2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle$$

So:
$$2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 + \eta^2\|F(\bar{z}^k)\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^k\rangle \tag{B5}$$

The key is to bound the **residual** $R_k = \eta^2\|F(\bar{z}^k)\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^k\rangle$.

Write $F(\bar{z}^k) = (F(\bar{z}^k) - F(z^k)) + F(z^k)$. Then:

$$R_k = \eta^2\|F(\bar{z}^k)\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^k\rangle$$

Add and subtract strategically. Actually, let's complete the square differently:

$$R_k = \eta^2\|F(\bar{z}^k)\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^k\rangle + \|\bar{z}^k - z^k\|^2 - \|\bar{z}^k - z^k\|^2$$

$$= \|\eta F(\bar{z}^k) + (\bar{z}^k - z^k)\|^2 - \|\bar{z}^k - z^k\|^2$$

$$= \|\eta F(\bar{z}^k) - (z^k - \bar{z}^k)\|^2 - \|z^k - \bar{z}^k\|^2 \tag{B6}$$

Now, from (B4): $z^k - \bar{z}^k$ is close to $\eta F(z^k)$ (in the sense that $\langle z^k - \bar{z}^k, z^k - \bar{z}^k\rangle \leq \eta\langle F(z^k), z^k - \bar{z}^k\rangle$, meaning $z^k - \bar{z}^k$ and $\eta F(z^k)$ are "aligned").

From the extrapolation projection property: for all $v \in \mathcal{Z}$:
$$\langle z^k - \eta F(z^k) - \bar{z}^k, v - \bar{z}^k\rangle \leq 0$$

Setting $v = z^{k+1} \in \mathcal{Z}$:
$$\langle (z^k - \bar{z}^k) - \eta F(z^k), z^{k+1} - \bar{z}^k\rangle \leq 0$$

This tells us something about the geometry but doesn't directly simplify $R_k$. Let us instead just bound $\|\eta F(\bar{z}^k) - (z^k - \bar{z}^k)\|^2$ in (B6) directly.

$$\|\eta F(\bar{z}^k) - (z^k - \bar{z}^k)\|^2 = \|\eta(F(\bar{z}^k) - F(z^k)) + (\eta F(z^k) - (z^k - \bar{z}^k))\|^2$$

$$\leq \left(\eta\|F(\bar{z}^k) - F(z^k)\| + \|\eta F(z^k) - (z^k - \bar{z}^k)\|\right)^2$$

This is getting unwieldy. Let us use a **completely different, cleaner decomposition** that is standard in the literature.

---

## Main Proof (Clean Restart)

### Proposition 1: Fundamental One-Step Inequality

**Claim.** For any $u \in \mathcal{Z}$ and $k \geq 0$:
$$2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 - (1 - \eta^2 L^2)\|\bar{z}^k - z^k\|^2$$

**Proof.**

We use the following identity. For any vectors $a, b, c$:
$$\|a - c\|^2 = \|a - b\|^2 + 2\langle a - b, b - c\rangle + \|b - c\|^2 \tag{*}$$

**Step 1: Analyze the update step.**

From $z^{k+1} = \Pi_{\mathcal{Z}}(z^k - \eta F(\bar{z}^k))$, the projection property gives for all $u \in \mathcal{Z}$:
$$\langle z^k - \eta F(\bar{z}^k) - z^{k+1}, u - z^{k+1}\rangle \leq 0$$

Rearranging:
$$\langle z^{k+1} - z^k + \eta F(\bar{z}^k), u - z^{k+1}\rangle \geq 0$$

$$\langle z^{k+1} - z^k, u - z^{k+1}\rangle \geq -\eta\langle F(\bar{z}^k), u - z^{k+1}\rangle$$

$$\langle z^{k+1} - z^k, u - z^{k+1}\rangle \geq \eta\langle F(\bar{z}^k), z^{k+1} - u\rangle \tag{C1}$$

By identity $(*)$ with $a = z^k$, $b = z^{k+1}$, $c = u$:
$$\|z^k - u\|^2 = \|z^k - z^{k+1}\|^2 + 2\langle z^k - z^{k+1}, z^{k+1} - u\rangle + \|z^{k+1} - u\|^2$$

So:
$$\langle z^{k+1} - z^k, u - z^{k+1}\rangle = \frac{1}{2}\left(\|z^k - u\|^2 - \|z^k - z^{k+1}\|^2 - \|z^{k+1} - u\|^2\right)$$

Wait, from the identity:
$$2\langle z^k - z^{k+1}, z^{k+1} - u\rangle = \|z^k - u\|^2 - \|z^k - z^{k+1}\|^2 - \|z^{k+1} - u\|^2$$

So:
$$2\langle z^{k+1} - z^k, u - z^{k+1}\rangle = -\|z^k - u\|^2 + \|z^k - z^{k+1}\|^2 + \|z^{k+1} - u\|^2$$

Hmm, the signs. Let me recompute:
$$\langle z^k - z^{k+1}, z^{k+1} - u\rangle = -\langle z^{k+1} - z^k, z^{k+1} - u\rangle = \langle z^{k+1} - z^k, u - z^{k+1}\rangle$$

From $(*)$:
$$\|z^k - u\|^2 = \|z^k - z^{k+1}\|^2 + 2\langle z^k - z^{k+1}, z^{k+1} - u\rangle + \|z^{k+1} - u\|^2$$

$$2\langle z^{k+1} - z^k, u - z^{k+1}\rangle = -2\langle z^k - z^{k+1}, z^{k+1} - u\rangle$$
$$= -(\|z^k - u\|^2 - \|z^k - z^{k+1}\|^2 - \|z^{k+1} - u\|^2)$$
$$= \|z^k - z^{k+1}\|^2 + \|z^{k+1} - u\|^2 - \|z^k - u\|^2$$

From (C1):
$$\|z^k - z^{k+1}\|^2 + \|z^{k+1} - u\|^2 - \|z^k - u\|^2 \geq 2\eta\langle F(\bar{z}^k), z^{k+1} - u\rangle$$

Rearranging:
$$\|z^k - u\|^2 - \|z^{k+1} - u\|^2 \leq \|z^k - z^{k+1}\|^2 - 2\eta\langle F(\bar{z}^k), z^{k+1} - u\rangle$$

$$= \|z^k - z^{k+1}\|^2 + 2\eta\langle F(\bar{z}^k), u - z^{k+1}\rangle$$

$$= \|z^k - z^{k+1}\|^2 + 2\eta\langle F(\bar{z}^k), u - \bar{z}^k\rangle + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle$$

So:
$$2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 - \|z^k - z^{k+1}\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle \tag{C2}$$

**Step 2: Bound $-\|z^k - z^{k+1}\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle$.**

By Young's inequality: for any $\alpha > 0$:
$$2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle \leq \frac{\eta^2}{\alpha}\|F(\bar{z}^k)\|^2 + \alpha\|\bar{z}^k - z^{k+1}\|^2$$

This introduces $\|F(\bar{z}^k)\|^2$ again. Let us try yet another approach.

**Step 2 (direct):** We bound $2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle$ using the relationship between consecutive iterates.

Write $\bar{z}^k - z^{k+1} = (\bar{z}^k - z^k) + (z^k - z^{k+1})$. So:

$$2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle = 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^k\rangle + 2\eta\langle F(\bar{z}^k), z^k - z^{k+1}\rangle \tag{C3}$$

For the first term: Using $F(\bar{z}^k) = F(z^k) + (F(\bar{z}^k) - F(z^k))$:
$$2\eta\langle F(\bar{z}^k), \bar{z}^k - z^k\rangle = 2\eta\langle F(z^k), \bar{z}^k - z^k\rangle + 2\eta\langle F(\bar{z}^k) - F(z^k), \bar{z}^k - z^k\rangle$$

From (B4): $2\eta\langle F(z^k), \bar{z}^k - z^k\rangle \leq -2\|\bar{z}^k - z^k\|^2$.

By Cauchy-Schwarz + Lipschitz: $2\eta\langle F(\bar{z}^k) - F(z^k), \bar{z}^k - z^k\rangle \leq 2\eta L\|\bar{z}^k - z^k\|^2$.

So:
$$2\eta\langle F(\bar{z}^k), \bar{z}^k - z^k\rangle \leq -(2 - 2\eta L)\|\bar{z}^k - z^k\|^2 \tag{C4}$$

For the second term in (C3): Since $z^{k+1} = \Pi_{\mathcal{Z}}(z^k - \eta F(\bar{z}^k))$ and $z^k \in \mathcal{Z}$:
$$\|z^k - z^{k+1}\| \leq \|\eta F(\bar{z}^k)\|$$

So:
$$2\eta\langle F(\bar{z}^k), z^k - z^{k+1}\rangle \leq 2\eta\|F(\bar{z}^k)\| \cdot \|z^k - z^{k+1}\| \leq 2\eta^2\|F(\bar{z}^k)\|^2$$

This still has $\|F(\bar{z}^k)\|^2$. But we can bound it:
$$\|F(\bar{z}^k)\|^2 = \|F(\bar{z}^k) - F(z^k) + F(z^k)\|^2 \leq 2\|F(\bar{z}^k) - F(z^k)\|^2 + 2\|F(z^k)\|^2 \leq 2L^2\|\bar{z}^k - z^k\|^2 + 2\|F(z^k)\|^2$$

This introduces $\|F(z^k)\|^2$ which we cannot telescope. This approach fails.

---

## Main Proof (Final, Correct Version)

Let me use the **well-known clean proof** from Nemirovski (2004) / Juditsky et al.

### Proposition 1

For any $u \in \mathcal{Z}$ and $k \geq 0$, with $0 < \eta \leq \frac{1}{L}$:
$$2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2$$

**Proof.**

**Step 1.** From $z^{k+1} = \Pi_{\mathcal{Z}}(z^k - \eta F(\bar{z}^k))$, by the projection property:
$$\langle z^k - \eta F(\bar{z}^k) - z^{k+1}, u - z^{k+1}\rangle \leq 0, \quad \forall u \in \mathcal{Z}$$

So: $\eta\langle F(\bar{z}^k), u - z^{k+1}\rangle \leq \langle z^k - z^{k+1}, u - z^{k+1}\rangle$.

Expanding via $2\langle a, b\rangle = \|a\|^2 + \|b\|^2 - \|a-b\|^2$:
$$2\eta\langle F(\bar{z}^k), u - z^{k+1}\rangle \leq \|z^k - z^{k+1}\|^2 + \|u - z^{k+1}\|^2 - \|z^k - u\|^2$$

So:
$$\|z^k - u\|^2 - \|z^{k+1} - u\|^2 \leq \|z^k - z^{k+1}\|^2 + 2\eta\langle F(\bar{z}^k), u - z^{k+1}\rangle$$

Rewrite $u - z^{k+1} = (u - \bar{z}^k) + (\bar{z}^k - z^{k+1})$:

$$\|z^k - u\|^2 - \|z^{k+1} - u\|^2 \leq \|z^k - z^{k+1}\|^2 + 2\eta\langle F(\bar{z}^k), u - \bar{z}^k\rangle + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle$$

Therefore:
$$2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 - \|z^k - z^{k+1}\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle \tag{I}$$

**Step 2.** We claim that the last two terms satisfy:
$$-\|z^k - z^{k+1}\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle \leq 0 \quad \text{when } \eta \leq \frac{1}{L} \tag{II}$$

**Proof of (II):**

Write $z^k - z^{k+1}$ using the triangle via $\bar{z}^k$:
$$z^k - z^{k+1} = (z^k - \bar{z}^k) + (\bar{z}^k - z^{k+1})$$

So:
$$\|z^k - z^{k+1}\|^2 = \|z^k - \bar{z}^k\|^2 + 2\langle z^k - \bar{z}^k, \bar{z}^k - z^{k+1}\rangle + \|\bar{z}^k - z^{k+1}\|^2$$

Therefore:
$$-\|z^k - z^{k+1}\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle$$
$$= -\|z^k - \bar{z}^k\|^2 - 2\langle z^k - \bar{z}^k, \bar{z}^k - z^{k+1}\rangle - \|\bar{z}^k - z^{k+1}\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle$$
$$= -\|z^k - \bar{z}^k\|^2 - \|\bar{z}^k - z^{k+1}\|^2 + 2\langle \eta F(\bar{z}^k) - (z^k - \bar{z}^k), \bar{z}^k - z^{k+1}\rangle \tag{III}$$

Now $z^{k+1} = \Pi_{\mathcal{Z}}(z^k - \eta F(\bar{z}^k))$, so by the projection property with $v = \bar{z}^k \in \mathcal{Z}$:
$$\langle z^k - \eta F(\bar{z}^k) - z^{k+1}, \bar{z}^k - z^{k+1}\rangle \leq 0$$

This means:
$$\langle (z^k - \bar{z}^k) - \eta F(\bar{z}^k) + (\bar{z}^k - z^{k+1}), \bar{z}^k - z^{k+1}\rangle \leq 0$$

$$\langle (z^k - \bar{z}^k) - \eta F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle + \|\bar{z}^k - z^{k+1}\|^2 \leq 0$$

$$\langle (z^k - \bar{z}^k) - \eta F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle \leq -\|\bar{z}^k - z^{k+1}\|^2$$

So:
$$\langle \eta F(\bar{z}^k) - (z^k - \bar{z}^k), \bar{z}^k - z^{k+1}\rangle \geq \|\bar{z}^k - z^{k+1}\|^2$$

Substituting into (III):
$$(\text{III}) \leq -\|z^k - \bar{z}^k\|^2 - \|\bar{z}^k - z^{k+1}\|^2 + 2\|\bar{z}^k - z^{k+1}\|^2$$
$$= -\|z^k - \bar{z}^k\|^2 + \|\bar{z}^k - z^{k+1}\|^2 \tag{IV}$$

Now we need $\|\bar{z}^k - z^{k+1}\|^2 \leq \|z^k - \bar{z}^k\|^2$ to conclude (II).

**Bound on $\|\bar{z}^k - z^{k+1}\|$:**

Since $\bar{z}^k = \Pi_{\mathcal{Z}}(z^k - \eta F(z^k))$ and $z^{k+1} = \Pi_{\mathcal{Z}}(z^k - \eta F(\bar{z}^k))$, by the non-expansiveness of projection:

$$\|\bar{z}^k - z^{k+1}\| = \|\Pi_{\mathcal{Z}}(z^k - \eta F(z^k)) - \Pi_{\mathcal{Z}}(z^k - \eta F(\bar{z}^k))\|$$
$$\leq \|(z^k - \eta F(z^k)) - (z^k - \eta F(\bar{z}^k))\|$$
$$= \eta\|F(z^k) - F(\bar{z}^k)\|$$
$$\leq \eta L\|z^k - \bar{z}^k\| \tag{V}$$

So:
$$\|\bar{z}^k - z^{k+1}\|^2 \leq \eta^2 L^2 \|z^k - \bar{z}^k\|^2$$

Substituting into (IV):
$$(\text{III}) \leq -\|z^k - \bar{z}^k\|^2 + \eta^2 L^2\|z^k - \bar{z}^k\|^2 = -(1 - \eta^2 L^2)\|z^k - \bar{z}^k\|^2 \leq 0$$

when $\eta \leq 1/L$. This proves (II), and in fact gives the sharper bound:

$$-\|z^k - z^{k+1}\|^2 + 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^{k+1}\rangle \leq -(1 - \eta^2 L^2)\|\bar{z}^k - z^k\|^2$$

Substituting back into (I):

$$\boxed{2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 - (1 - \eta^2 L^2)\|\bar{z}^k - z^k\|^2} \tag{★}$$

Since $\eta = 1/(2L) \leq 1/L$, we have $1 - \eta^2 L^2 = 1 - 1/4 = 3/4 > 0$, so the last term is non-positive (i.e., it helps the bound). In particular:

$$2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 \tag{★'}$$

$\blacksquare$

---

### Phase 2: Lyapunov Function and Monotone Decrease

**Define the Lyapunov function:**
$$V^k = \|z^k - z^*\|^2$$

where $z^*$ is a saddle point.

**Corollary (Monotone decrease).** Setting $u = z^*$ in (★):
$$V^{k+1} \leq V^k - (1 - \eta^2 L^2)\|\bar{z}^k - z^k\|^2 - 2\eta\langle F(\bar{z}^k), \bar{z}^k - z^*\rangle$$

Since $z^*$ is a saddle point, $\langle F(z^*), z - z^*\rangle \geq 0$ for all $z \in \mathcal{Z}$. By monotonicity of $F$:
$$\langle F(\bar{z}^k), \bar{z}^k - z^*\rangle \geq \langle F(z^*), \bar{z}^k - z^*\rangle \geq 0$$

Therefore:
$$V^{k+1} \leq V^k - (1 - \eta^2 L^2)\|\bar{z}^k - z^k\|^2 \leq V^k$$

The Lyapunov function is **non-increasing**, confirming the iterates do not diverge from $z^*$.

---

### Phase 3: Telescoping and Gap Bound

**Step 1: Telescope (★') over $k = 0, 1, \ldots, K-1$.**

For any **fixed** $u \in \mathcal{Z}$:

$$\sum_{k=0}^{K-1} 2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle \leq \|z^0 - u\|^2 - \|z^K - u\|^2 \leq \|z^0 - u\|^2$$

So:
$$2\eta \sum_{k=0}^{K-1} \langle F(\bar{z}^k), \bar{z}^k - u\rangle \leq \|z^0 - u\|^2 \leq D^2 \tag{T1}$$

**Step 2: Define averaged iterate.**

Let $\hat{z}^K = \frac{1}{K}\sum_{k=0}^{K-1} \bar{z}^k$, with $\hat{z}^K = (\hat{x}^K, \hat{y}^K)$ where $\hat{x}^K = \frac{1}{K}\sum_{k=0}^{K-1}\bar{x}^k$ and $\hat{y}^K = \frac{1}{K}\sum_{k=0}^{K-1}\bar{y}^k$.

Since $\mathcal{Z}$ is convex, $\hat{z}^K \in \mathcal{Z}$.

**Step 3: From operator inner products to the gap function.**

By Lemma 3, for each $k$ and any $u = (x_u, y_u) \in \mathcal{Z}$:
$$\langle F(\bar{z}^k), \bar{z}^k - u\rangle \geq f(\bar{x}^k, y_u) - f(x_u, \bar{y}^k)$$

Summing over $k = 0, \ldots, K-1$ and dividing by $K$:
$$\frac{1}{K}\sum_{k=0}^{K-1}\langle F(\bar{z}^k), \bar{z}^k - u\rangle \geq \frac{1}{K}\sum_{k=0}^{K-1}\left[f(\bar{x}^k, y_u) - f(x_u, \bar{y}^k)\right]$$

By convexity of $f(\cdot, y_u)$ in $x$ (Jensen's inequality):
$$\frac{1}{K}\sum_{k=0}^{K-1} f(\bar{x}^k, y_u) \geq f\!\left(\frac{1}{K}\sum_{k=0}^{K-1}\bar{x}^k, y_u\right) = f(\hat{x}^K, y_u)$$

By concavity of $f(x_u, \cdot)$ in $y$ (Jensen's inequality):
$$\frac{1}{K}\sum_{k=0}^{K-1} f(x_u, \bar{y}^k) \leq f\!\left(x_u, \frac{1}{K}\sum_{k=0}^{K-1}\bar{y}^k\right) = f(x_u, \hat{y}^K)$$

Combining:
$$\frac{1}{K}\sum_{k=0}^{K-1}\langle F(\bar{z}^k), \bar{z}^k - u\rangle \geq f(\hat{x}^K, y_u) - f(x_u, \hat{y}^K)$$

From (T1):
$$f(\hat{x}^K, y_u) - f(x_u, \hat{y}^K) \leq \frac{D^2}{2\eta K} \tag{T2}$$

**Step 4: Maximize over $u$ to obtain the gap.**

Since (T2) holds for every $u = (x_u, y_u) \in \mathcal{Z}$, we can take:
- $x_u = \arg\min_{x \in \mathcal{X}} f(x, \hat{y}^K)$, so $f(x_u, \hat{y}^K) = \min_{x \in \mathcal{X}} f(x, \hat{y}^K)$
- $y_u = \arg\max_{y \in \mathcal{Y}} f(\hat{x}^K, y)$, so $f(\hat{x}^K, y_u) = \max_{y \in \mathcal{Y}} f(\hat{x}^K, y)$

**Important note:** We cannot simultaneously optimize $x_u$ and $y_u$ because $u = (x_u, y_u)$ must be a single point. Instead, for any $(x_u, y_u) \in \mathcal{Z}$:

$$f(\hat{x}^K, y_u) - f(x_u, \hat{y}^K) \leq \frac{D^2}{2\eta K}$$

Taking the supremum over $u \in \mathcal{Z}$:
$$\sup_{(x_u, y_u) \in \mathcal{Z}} \left[f(\hat{x}^K, y_u) - f(x_u, \hat{y}^K)\right] \leq \frac{D^2}{2\eta K}$$

Now:
$$\sup_{(x_u, y_u)} \left[f(\hat{x}^K, y_u) - f(x_u, \hat{y}^K)\right] \geq \sup_{y_u} f(\hat{x}^K, y_u) - \inf_{x_u} f(x_u, \hat{y}^K)$$

Wait — we need to be careful. We have:
$$\sup_{(x_u, y_u)} \left[f(\hat{x}^K, y_u) - f(x_u, \hat{y}^K)\right]$$

Since $x_u$ and $y_u$ can be chosen independently (as $\mathcal{Z} = \mathcal{X} \times \mathcal{Y}$ is a product set):

$$= \sup_{y_u \in \mathcal{Y}} f(\hat{x}^K, y_u) - \inf_{x_u \in \mathcal{X}} f(x_u, \hat{y}^K)$$

$$= \sup_{y_u \in \mathcal{Y}} f(\hat{x}^K, y_u) + \sup_{x_u \in \mathcal{X}} [-f(x_u, \hat{y}^K)]$$

$$= \max_{y \in \mathcal{Y}} f(\hat{x}^K, y) - \min_{x \in \mathcal{X}} f(x, \hat{y}^K)$$

$$= \text{Gap}(\hat{z}^K)$$

Actually, let us verify this equality. For any fixed $y_u$, $\sup_{x_u} [f(\hat{x}^K, y_u) - f(x_u, \hat{y}^K)] = f(\hat{x}^K, y_u) + \sup_{x_u}[-f(x_u, \hat{y}^K)] = f(\hat{x}^K, y_u) - \inf_{x_u} f(x_u, \hat{y}^K)$. Then $\sup_{y_u}$ of this gives $\sup_{y_u} f(\hat{x}^K, y_u) - \inf_{x_u} f(x_u, \hat{y}^K)$. Yes.

So:
$$\text{Gap}(\hat{z}^K) = \max_{y \in \mathcal{Y}} f(\hat{x}^K, y) - \min_{x \in \mathcal{X}} f(x, \hat{y}^K) \leq \frac{D^2}{2\eta K}$$

**Step 5: Substitute $\eta = \frac{1}{2L}$.**

$$\text{Gap}(\hat{z}^K) \leq \frac{D^2}{2 \cdot \frac{1}{2L} \cdot K} = \frac{D^2 \cdot 2L}{2K} = \frac{LD^2}{K}$$

Hmm, this gives $LD^2/K$, but the target is $2LD^2/K$. Let us recheck.

With $\eta = 1/(2L)$: $\frac{D^2}{2\eta K} = \frac{D^2}{2 \cdot \frac{1}{2L} \cdot K} = \frac{D^2 \cdot L}{K} = \frac{LD^2}{K}$.

So in fact we get the **stronger** bound:

$$\boxed{\text{Gap}(\hat{z}^K) \leq \frac{LD^2}{K}}$$

The target of $\frac{2LD^2}{K}$ is a weaker (looser) upper bound that holds a fortiori. The discrepancy factor of 2 is harmless — the target bound $\frac{2LD^2}{K}$ is satisfied since $\frac{LD^2}{K} \leq \frac{2LD^2}{K}$.

*Remark:* Some references state $\frac{2LD^2}{K}$ because they use $\eta = \frac{1}{L}$ with a slightly different analysis, or they define the diameter differently ($D$ as the radius rather than the diameter). Our analysis with $\eta = \frac{1}{2L}$ gives the tighter constant.

$\blacksquare$

---

## Summary of the Complete Proof

**Theorem.** Consider the convex-concave minimax problem $\min_{x \in \mathcal{X}} \max_{y \in \mathcal{Y}} f(x,y)$ where $f$ is convex in $x$, concave in $y$, and $L$-smooth. Let $\mathcal{Z} = \mathcal{X} \times \mathcal{Y}$ have diameter $D$. The Extragradient method with step size $\eta = \frac{1}{2L}$ produces iterates such that the averaged iterate $\hat{z}^K = \frac{1}{K}\sum_{k=0}^{K-1} \bar{z}^k$ satisfies:

$$\mathrm{Gap}(\hat{z}^K) \leq \frac{2LD^2}{K}$$

**Proof structure:**

1. **Lyapunov one-step bound (★):** For any $u \in \mathcal{Z}$:
$$2\eta\langle F(\bar{z}^k), \bar{z}^k - u\rangle \leq \|z^k - u\|^2 - \|z^{k+1} - u\|^2 - (1-\eta^2L^2)\|\bar{z}^k - z^k\|^2$$

   Key ingredients: projection non-expansiveness giving $\|\bar{z}^k - z^{k+1}\| \leq \eta L\|\bar{z}^k - z^k\|$ (equation V), and the projection optimality condition applied at $\bar{z}^k$ and $z^{k+1}$.

2. **Lyapunov decrease (setting $u = z^*$):** Monotonicity of $F$ gives $\langle F(\bar{z}^k), \bar{z}^k - z^*\rangle \geq 0$, so $V^{k+1} \leq V^k$.

3. **Telescope over $K$ steps:** Sum (★') for $k = 0, \ldots, K-1$ with arbitrary $u \in \mathcal{Z}$.

4. **Jensen's inequality:** Convexity in $x$ and concavity in $y$ allow passage from the average of function values to the function at the averaged iterate.

5. **Optimize over $u$:** Since $\mathcal{Z} = \mathcal{X} \times \mathcal{Y}$ is a product set, supremum over $(x_u, y_u)$ decouples into the duality gap.

6. **Substitute $\eta = 1/(2L)$:** Obtain $\text{Gap}(\hat{z}^K) \leq LD^2/K \leq 2LD^2/K$. $\blacksquare$

---

## Verification Checklist

| Check | Status |
|-------|--------|
| Projection inequality (Lemma 1) used correctly | ✓ |
| Non-expansiveness of projection used for $\|\bar{z}^k - z^{k+1}\| \leq \eta L\|z^k - \bar{z}^k\|$ | ✓ |
| Condition $\eta \leq 1/L$ verified ($\eta = 1/(2L)$ satisfies this) | ✓ |
| $1 - \eta^2L^2 = 3/4 > 0$ verified | ✓ |
| Monotonicity of $F$ used only for Lyapunov decrease, NOT for gap bound | ✓ |
| Convexity-concavity used via Lemma 3 and Jensen | ✓ |
| Product structure of $\mathcal{Z}$ used for decoupling the supremum | ✓ |
| Telescope sums correctly: $\sum (V^k - V^{k+1}) = V^0 - V^K \leq V^0$ | ✓ |
| Final rate $O(1/K)$ achieved | ✓ |
| Bound $\text{Gap}(\hat{z}^K) \leq 2LD^2/K$ achieved (with room to spare) | ✓ |
