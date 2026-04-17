# Route 4 — Fenchel Duality + KKT Residuals

## Proof of Chambolle-Pock PDHG O(1/N) Saddle-Point Convergence

**Theorem.** Let $X, Y$ be finite-dimensional real Hilbert spaces, $K: X \to Y$ bounded linear with $\|K\| = L$, and $g: X \to \mathbb{R} \cup \{+\infty\}$, $f^*: Y \to \mathbb{R} \cup \{+\infty\}$ proper convex lsc. Consider the PDHG iterates with $\tau\sigma L^2 < 1$:

$$y^{n+1} = \mathrm{prox}_{\sigma f^*}(y^n + \sigma K\bar{x}^n)$$
$$x^{n+1} = \mathrm{prox}_{\tau g}(x^n - \tau K^* y^{n+1})$$
$$\bar{x}^{n+1} = 2x^{n+1} - x^n$$

With ergodic averages $X^N = \frac{1}{N}\sum_{n=1}^N x^n$, $Y^N = \frac{1}{N}\sum_{n=1}^N y^n$, we have for all $(x,y) \in B$:

$$\mathcal{G}_B(X^N, Y^N) \leq \frac{1}{N}\left(\frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma}\right).$$

---

## Step 1: Fenchel Duality Connection

The saddle-point problem is:

$$\min_x \max_y \; \langle Kx, y \rangle + g(x) - f^*(y). \tag{SP}$$

This arises from the Fenchel-Rockafellar primal problem:

$$\min_x \; g(x) + f(Kx) \tag{P}$$

where $f$ is the convex conjugate of $f^*$, i.e., $f(u) = \sup_y \{\langle u, y\rangle - f^*(y)\}$.

Indeed, substituting the conjugate representation of $f$:

$$\min_x \; g(x) + \sup_y \{\langle Kx, y\rangle - f^*(y)\} = \min_x \sup_y \; \langle Kx, y\rangle + g(x) - f^*(y)$$

which is exactly (SP). The Fenchel dual is:

$$\max_y \; -g^*(-K^*y) - f^*(y). \tag{D}$$

A saddle point $(\hat{x}, \hat{y})$ of (SP) satisfies the optimality (KKT) conditions:

$$K^*\hat{y} \in \partial g(\hat{x}), \qquad K\hat{x} \in \partial f^*(\hat{y}). \tag{KKT}$$

The **restricted primal-dual gap** (or restricted saddle-point gap) for a pair $(x', y')$ over a bounded set $B = B_x \times B_y$ is:

$$\mathcal{G}_B(x', y') = \max_{\hat{y} \in B_y}\left[\langle Kx', \hat{y}\rangle + g(x') - f^*(\hat{y})\right] - \min_{\hat{x} \in B_x}\left[\langle K\hat{x}, y'\rangle + g(\hat{x}) - f^*(y')\right].$$

Define the Lagrangian $\mathcal{L}(x, y) = \langle Kx, y\rangle + g(x) - f^*(y)$. Then:

$$\mathcal{G}_B(x', y') = \max_{\hat{y} \in B_y} \mathcal{L}(x', \hat{y}) - \min_{\hat{x} \in B_x} \mathcal{L}(\hat{x}, y').$$

For any fixed $(x, y) \in B$, the gap satisfies:

$$\mathcal{G}_B(x', y') \geq \mathcal{L}(x', y) - \mathcal{L}(x, y')$$

so it suffices to bound $\mathcal{L}(x', y) - \mathcal{L}(x, y')$ from above for all $(x, y) \in B$.

---

## Step 2: KKT / Optimality Conditions for Each Prox Step

We now extract the optimality conditions from each proximal step.

**Prox step for $y^{n+1}$:**

$$y^{n+1} = \mathrm{prox}_{\sigma f^*}(y^n + \sigma K\bar{x}^n) = \arg\min_y \left\{\frac{1}{2}\|y - (y^n + \sigma K\bar{x}^n)\|^2 + \sigma f^*(y)\right\}.$$

The optimality condition (setting the subdifferential of the objective to contain zero) gives:

$$y^{n+1} - (y^n + \sigma K\bar{x}^n) + \sigma \partial f^*(y^{n+1}) \ni 0$$

which rearranges to:

$$\frac{y^n - y^{n+1}}{\sigma} + K\bar{x}^n \in \partial f^*(y^{n+1}). \tag{OC-y}$$

**Prox step for $x^{n+1}$:**

$$x^{n+1} = \mathrm{prox}_{\tau g}(x^n - \tau K^* y^{n+1}) = \arg\min_x \left\{\frac{1}{2}\|x - (x^n - \tau K^* y^{n+1})\|^2 + \tau g(x)\right\}.$$

The optimality condition gives:

$$x^{n+1} - (x^n - \tau K^* y^{n+1}) + \tau \partial g(x^{n+1}) \ni 0$$

which rearranges to:

$$\frac{x^n - x^{n+1}}{\tau} - K^* y^{n+1} \in \partial g(x^{n+1}). \tag{OC-x}$$

---

## Step 3: Per-Iteration Contribution to the Gap via Prox Residuals

Fix an arbitrary $(x, y) \in B$. We bound the per-iteration saddle-point residual:

$$\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1}) = \left[\langle Kx^{n+1}, y\rangle + g(x^{n+1}) - f^*(y)\right] - \left[\langle Kx, y^{n+1}\rangle + g(x) - f^*(y^{n+1})\right].$$

**Using (OC-x) and convexity of $g$:**

From (OC-x), there exists $\xi^{n+1} \in \partial g(x^{n+1})$ such that:

$$\xi^{n+1} = \frac{x^n - x^{n+1}}{\tau} - K^* y^{n+1}.$$

By convexity of $g$, for any $x$:

$$g(x) \geq g(x^{n+1}) + \langle \xi^{n+1}, x - x^{n+1}\rangle$$

$$g(x^{n+1}) - g(x) \leq -\langle \xi^{n+1}, x - x^{n+1}\rangle = -\left\langle \frac{x^n - x^{n+1}}{\tau} - K^* y^{n+1},\; x - x^{n+1}\right\rangle.$$

Therefore:

$$g(x^{n+1}) - g(x) \leq \left\langle \frac{x^{n+1} - x^n}{\tau} + K^* y^{n+1},\; x - x^{n+1}\right\rangle. \tag{G1}$$

**Using (OC-y) and convexity of $f^*$:**

From (OC-y), there exists $\eta^{n+1} \in \partial f^*(y^{n+1})$ such that:

$$\eta^{n+1} = \frac{y^n - y^{n+1}}{\sigma} + K\bar{x}^n.$$

By convexity of $f^*$, for any $y$:

$$f^*(y) \geq f^*(y^{n+1}) + \langle \eta^{n+1}, y - y^{n+1}\rangle$$

$$f^*(y^{n+1}) - f^*(y) \leq -\langle \eta^{n+1}, y - y^{n+1}\rangle = -\left\langle \frac{y^n - y^{n+1}}{\sigma} + K\bar{x}^n,\; y - y^{n+1}\right\rangle.$$

Therefore:

$$-f^*(y) + f^*(y^{n+1}) \leq \left\langle \frac{y^{n+1} - y^n}{\sigma} - K\bar{x}^n,\; y - y^{n+1}\right\rangle. \tag{G2}$$

**Assembling the gap bound:**

We compute:

$$\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})$$
$$= \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle + g(x^{n+1}) - g(x) - f^*(y) + f^*(y^{n+1}).$$

Using (G1) and (G2):

$$\leq \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle + \left\langle \frac{x^{n+1} - x^n}{\tau} + K^* y^{n+1},\; x - x^{n+1}\right\rangle + \left\langle \frac{y^{n+1} - y^n}{\sigma} - K\bar{x}^n,\; y - y^{n+1}\right\rangle.$$

Now expand the inner products. For the $x$-part:

$$\left\langle \frac{x^{n+1} - x^n}{\tau},\; x - x^{n+1}\right\rangle + \langle K^* y^{n+1}, x - x^{n+1}\rangle$$

$$= \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle + \langle y^{n+1}, K(x - x^{n+1})\rangle.$$

For the $y$-part:

$$\left\langle \frac{y^{n+1} - y^n}{\sigma},\; y - y^{n+1}\right\rangle - \langle K\bar{x}^n, y - y^{n+1}\rangle$$

$$= \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle - \langle K\bar{x}^n, y - y^{n+1}\rangle.$$

Combining with the bilinear terms $\langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle$:

$$\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1}) \leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle + \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle$$

$$+ \langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle + \langle y^{n+1}, K(x - x^{n+1})\rangle - \langle K\bar{x}^n, y - y^{n+1}\rangle. \tag{*}$$

Let us simplify the four bilinear/coupling terms (the last line). We have:

$$\langle Kx^{n+1}, y\rangle - \langle Kx, y^{n+1}\rangle + \langle Kx, y^{n+1}\rangle - \langle Kx^{n+1}, y^{n+1}\rangle - \langle K\bar{x}^n, y - y^{n+1}\rangle$$

$$= \langle Kx^{n+1}, y\rangle - \langle Kx^{n+1}, y^{n+1}\rangle - \langle K\bar{x}^n, y - y^{n+1}\rangle$$

$$= \langle Kx^{n+1}, y - y^{n+1}\rangle - \langle K\bar{x}^n, y - y^{n+1}\rangle$$

$$= \langle K(x^{n+1} - \bar{x}^n), y - y^{n+1}\rangle.$$

Recalling $\bar{x}^n = 2x^n - x^{n-1}$ (for $n \geq 1$, with $\bar{x}^0 = x^0$), we get:

$$x^{n+1} - \bar{x}^n = x^{n+1} - 2x^n + x^{n-1} = (x^{n+1} - x^n) - (x^n - x^{n-1}).$$

So the coupling term becomes:

$$\langle K(x^{n+1} - \bar{x}^n), y - y^{n+1}\rangle = \langle K[(x^{n+1} - x^n) - (x^n - x^{n-1})], y - y^{n+1}\rangle. \tag{C}$$

Now $(\ast)$ becomes:

$$\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1}) \leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle + \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle + \langle K(x^{n+1} - \bar{x}^n), y - y^{n+1}\rangle. \tag{**}$$

---

## Step 4: Handling the Extrapolation and Telescoping

**Algebraic identity for the metric terms.**

We use the polarization identity: for any $a, b, c$ in a Hilbert space,

$$2\langle a - b, c - a\rangle = \|c - b\|^2 - \|a - b\|^2 - \|c - a\|^2.$$

This follows from expanding both sides (alternatively: $\|c - b\|^2 = \|(c-a) + (a-b)\|^2 = \|c-a\|^2 + 2\langle c-a, a-b\rangle + \|a-b\|^2$).

Applying with $a = x^{n+1}$, $b = x^n$, $c = x$:

$$\frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle = \frac{1}{2\tau}\left[\|x - x^n\|^2 - \|x^{n+1} - x^n\|^2 - \|x - x^{n+1}\|^2\right]. \tag{T-x}$$

Similarly, with $a = y^{n+1}$, $b = y^n$, $c = y$:

$$\frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle = \frac{1}{2\sigma}\left[\|y - y^n\|^2 - \|y^{n+1} - y^n\|^2 - \|y - y^{n+1}\|^2\right]. \tag{T-y}$$

**Handling the coupling term (C).**

We rewrite the coupling term from (C) in a way that telescopes. Write $d^n = x^{n+1} - x^n$ for the primal step. Then $x^{n+1} - \bar{x}^n = d^n - d^{n-1}$, and the coupling is:

$$\langle K(d^n - d^{n-1}), y - y^{n+1}\rangle = \langle Kd^n, y - y^{n+1}\rangle - \langle Kd^{n-1}, y - y^{n+1}\rangle.$$

We decompose the first term:

$$\langle Kd^n, y - y^{n+1}\rangle = \langle Kd^n, y - y^{n+2}\rangle + \langle Kd^n, y^{n+2} - y^{n+1}\rangle.$$

This decomposition does not directly telescope cleanly. Instead, let us use a more direct approach: bound the coupling term using Young's inequality and absorb it into the metric terms.

**Alternative direct approach for the coupling.**

We bound the coupling term $\langle K(x^{n+1} - \bar{x}^n), y - y^{n+1}\rangle$ differently. Split $y - y^{n+1} = (y - y^n) + (y^n - y^{n+1})$:

Actually, let us take a cleaner path. We return to $(\ast\ast)$ and handle the coupling more carefully by a direct telescoping argument.

**Refined telescoping approach.**

Rather than decomposing the coupling term, we use a single unified Lyapunov-type argument. Define:

$$\Phi_n = \frac{1}{2\tau}\|x - x^n\|^2 + \frac{1}{2\sigma}\|y - y^n\|^2.$$

From (T-x) and (T-y), equation $(\ast\ast)$ becomes:

$$\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1}) \leq \Phi_n - \Phi_{n+1} - \frac{\|x^{n+1} - x^n\|^2}{2\tau} - \frac{\|y^{n+1} - y^n\|^2}{2\sigma} + \langle K(x^{n+1} - \bar{x}^n), y - y^{n+1}\rangle. \tag{***}$$

Now we must bound the coupling term. We split $y - y^{n+1}$ as follows. Note that the coupling involves $x^{n+1} - \bar{x}^n = (x^{n+1} - x^n) - (x^n - x^{n-1})$. We handle this by introducing a **cross term** in the Lyapunov function.

Define the augmented Lyapunov function:

$$\Psi_n = \Phi_n + \langle K(x^n - x^{n-1}), y - y^n\rangle = \frac{1}{2\tau}\|x - x^n\|^2 + \frac{1}{2\sigma}\|y - y^n\|^2 + \langle Kd^{n-1}, y - y^n\rangle$$

where $d^{n-1} = x^n - x^{n-1}$.

However, this approach requires controlling the cross term and complicates the analysis. Let us instead use the most classical and clean route.

---

**Clean approach: bound coupling via Young's inequality.**

We return to $(\ast\ast\ast)$. The coupling term is:

$$\langle K(x^{n+1} - \bar{x}^n), y - y^{n+1}\rangle.$$

Since $\bar{x}^n = 2x^n - x^{n-1}$, we have $x^{n+1} - \bar{x}^n = (x^{n+1} - x^n) - (x^n - x^{n-1})$. Write $\delta^n = x^{n+1} - x^n$. Then:

$$\langle K(\delta^n - \delta^{n-1}), y - y^{n+1}\rangle.$$

We separate the $y$ part from the $y^{n+1}$ part. For the $y^{n+1}$ part, we use Young's inequality. But first, let us try the most direct path.

**Key manipulation: replace $y - y^{n+1}$ with $y^n - y^{n+1}$ plus $y - y^n$.**

$$\langle K(\delta^n - \delta^{n-1}), y - y^{n+1}\rangle = \langle K(\delta^n - \delta^{n-1}), y - y^n\rangle + \langle K(\delta^n - \delta^{n-1}), y^n - y^{n+1}\rangle.$$

For the second term, by Cauchy-Schwarz and $\|K\| = L$:

$$|\langle K(\delta^n - \delta^{n-1}), y^n - y^{n+1}\rangle| \leq L\|\delta^n - \delta^{n-1}\| \cdot \|y^n - y^{n+1}\|.$$

This leads to complicated cross-iteration terms. The cleanest classical proof actually avoids explicit bounding of the coupling term and instead uses a **direct summation with telescoping** that naturally cancels the extrapolation. Let us carry this out.

---

## Step 4 (Revised): Direct Summation and Telescoping

We return to the inequality before applying the polarization identity, i.e., $(\ast\ast)$:

$$\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1}) \leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle + \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle + \langle K(x^{n+1} - \bar{x}^n), y - y^{n+1}\rangle.$$

**Rewrite the coupling term using $\bar{x}^n = 2x^n - x^{n-1}$:**

$$\langle K(x^{n+1} - \bar{x}^n), y - y^{n+1}\rangle = \langle K(x^{n+1} - x^n), y - y^{n+1}\rangle - \langle K(x^n - x^{n-1}), y - y^{n+1}\rangle.$$

Now split the last term by inserting $y^n$:

$$-\langle K(x^n - x^{n-1}), y - y^{n+1}\rangle = -\langle K(x^n - x^{n-1}), y - y^n\rangle - \langle K(x^n - x^{n-1}), y^n - y^{n+1}\rangle.$$

Define:

$$R_n := \langle K(x^n - x^{n-1}), y - y^n\rangle. \tag{Rn}$$

Then the coupling in $(\ast\ast)$ becomes:

$$\langle K(x^{n+1} - x^n), y - y^{n+1}\rangle - R_n - \langle K(x^n - x^{n-1}), y^n - y^{n+1}\rangle.$$

Note that $R_{n+1} = \langle K(x^{n+1} - x^n), y - y^{n+1}\rangle$. So:

$$\text{coupling} = R_{n+1} - R_n - \langle K(x^n - x^{n-1}), y^n - y^{n+1}\rangle.$$

Substituting back into $(\ast\ast)$:

$$\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1}) \leq \frac{1}{\tau}\langle x^{n+1} - x^n, x - x^{n+1}\rangle + \frac{1}{\sigma}\langle y^{n+1} - y^n, y - y^{n+1}\rangle$$

$$+ R_{n+1} - R_n - \langle K(x^n - x^{n-1}), y^n - y^{n+1}\rangle. \tag{4.1}$$

**Apply the polarization identity** (T-x) and (T-y) to the first two terms:

$$\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1}) \leq \frac{1}{2\tau}\left[\|x - x^n\|^2 - \|x - x^{n+1}\|^2 - \|x^{n+1} - x^n\|^2\right]$$

$$+ \frac{1}{2\sigma}\left[\|y - y^n\|^2 - \|y - y^{n+1}\|^2 - \|y^{n+1} - y^n\|^2\right]$$

$$+ R_{n+1} - R_n - \langle K(x^n - x^{n-1}), y^n - y^{n+1}\rangle. \tag{4.2}$$

**Bound the remaining cross term** $-\langle K(x^n - x^{n-1}), y^n - y^{n+1}\rangle$ using Young's inequality:

$$|\langle K(x^n - x^{n-1}), y^n - y^{n+1}\rangle| \leq \|K(x^n - x^{n-1})\| \cdot \|y^n - y^{n+1}\| \leq L\|x^n - x^{n-1}\| \cdot \|y^n - y^{n+1}\|.$$

By Young's inequality with parameters $\frac{1}{2\tau}$ and $\frac{1}{2\sigma}$: for any $\alpha > 0$,

$$L\|x^n - x^{n-1}\| \cdot \|y^n - y^{n+1}\| \leq \frac{\alpha L^2}{2}\|x^n - x^{n-1}\|^2 + \frac{1}{2\alpha}\|y^n - y^{n+1}\|^2.$$

Choose $\alpha = \tau/1$ so that the first term pairs with the $x$-step squared norm. Actually, let us choose $\alpha = \sigma$ to get:

$$L\|x^n - x^{n-1}\| \cdot \|y^n - y^{n+1}\| \leq \frac{\sigma L^2}{2}\|x^n - x^{n-1}\|^2 + \frac{1}{2\sigma}\|y^n - y^{n+1}\|^2.$$

So:

$$-\langle K(x^n - x^{n-1}), y^n - y^{n+1}\rangle \leq \frac{\sigma L^2}{2}\|x^n - x^{n-1}\|^2 + \frac{1}{2\sigma}\|y^n - y^{n+1}\|^2.$$

Substituting into (4.2):

$$\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})$$

$$\leq \frac{1}{2\tau}\|x - x^n\|^2 - \frac{1}{2\tau}\|x - x^{n+1}\|^2 - \frac{1}{2\tau}\|x^{n+1} - x^n\|^2$$

$$+ \frac{1}{2\sigma}\|y - y^n\|^2 - \frac{1}{2\sigma}\|y - y^{n+1}\|^2 - \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2$$

$$+ R_{n+1} - R_n + \frac{\sigma L^2}{2}\|x^n - x^{n-1}\|^2 + \frac{1}{2\sigma}\|y^n - y^{n+1}\|^2.$$

The terms $-\frac{1}{2\sigma}\|y^{n+1} - y^n\|^2 + \frac{1}{2\sigma}\|y^{n+1} - y^n\|^2 = 0$ cancel! So:

$$\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1}) \leq \left(\frac{1}{2\tau}\|x - x^n\|^2 + \frac{1}{2\sigma}\|y - y^n\|^2\right) - \left(\frac{1}{2\tau}\|x - x^{n+1}\|^2 + \frac{1}{2\sigma}\|y - y^{n+1}\|^2\right)$$

$$- \frac{1}{2\tau}\|x^{n+1} - x^n\|^2 + \frac{\sigma L^2}{2}\|x^n - x^{n-1}\|^2 + R_{n+1} - R_n. \tag{4.3}$$

---

## Step 5: Summation and Ergodic Convergence

**Sum (4.3) from $n = 0$ to $N-1$:**

$$\sum_{n=0}^{N-1}\left[\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})\right]$$

$$\leq \left(\frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma}\right) - \left(\frac{\|x - x^N\|^2}{2\tau} + \frac{\|y - y^N\|^2}{2\sigma}\right)$$

$$+ \sum_{n=0}^{N-1}\left[-\frac{1}{2\tau}\|x^{n+1} - x^n\|^2 + \frac{\sigma L^2}{2}\|x^n - x^{n-1}\|^2\right] + R_N - R_0.$$

**Telescoping the step-size terms:**

$$\sum_{n=0}^{N-1}\left[-\frac{1}{2\tau}\|\delta^n\|^2 + \frac{\sigma L^2}{2}\|\delta^{n-1}\|^2\right]$$

where $\delta^n = x^{n+1} - x^n$ and $\delta^{-1} = x^0 - x^{-1}$. Since $\bar{x}^0 = x^0$, which in the algorithm means we initialize with $x^{-1} = x^0$ (so $\delta^{-1} = 0$):

$$= -\frac{1}{2\tau}\sum_{n=0}^{N-1}\|\delta^n\|^2 + \frac{\sigma L^2}{2}\sum_{n=0}^{N-1}\|\delta^{n-1}\|^2$$

$$= -\frac{1}{2\tau}\sum_{n=0}^{N-1}\|\delta^n\|^2 + \frac{\sigma L^2}{2}\sum_{n=-1}^{N-2}\|\delta^n\|^2$$

$$= -\frac{1}{2\tau}\sum_{n=0}^{N-1}\|\delta^n\|^2 + \frac{\sigma L^2}{2}\|\delta^{-1}\|^2 + \frac{\sigma L^2}{2}\sum_{n=0}^{N-2}\|\delta^n\|^2$$

$$= -\frac{1}{2\tau}\|\delta^{N-1}\|^2 + \left(\frac{\sigma L^2}{2} - \frac{1}{2\tau}\right)\sum_{n=0}^{N-2}\|\delta^n\|^2 + 0$$

since $\delta^{-1} = 0$. Because $\tau\sigma L^2 < 1$, we have $\sigma L^2 < 1/\tau$, hence $\frac{\sigma L^2}{2} - \frac{1}{2\tau} < 0$. Therefore:

$$\sum_{n=0}^{N-1}\left[-\frac{1}{2\tau}\|\delta^n\|^2 + \frac{\sigma L^2}{2}\|\delta^{n-1}\|^2\right] \leq 0. \tag{S1}$$

**Boundary term $R_N - R_0$:**

$R_0 = \langle K(x^0 - x^{-1}), y - y^0\rangle = \langle K \cdot 0, y - y^0\rangle = 0$ since $x^{-1} = x^0$.

$R_N = \langle K(x^N - x^{N-1}), y - y^N\rangle$. We need to show this is non-positive, or handle it.

Actually, $R_N$ need not be non-positive. Let us bound it using Young's inequality:

$$R_N = \langle K\delta^{N-1}, y - y^N\rangle \leq L\|\delta^{N-1}\| \cdot \|y - y^N\|.$$

By Young's: $\leq \frac{\sigma L^2}{2}\|\delta^{N-1}\|^2 + \frac{1}{2\sigma}\|y - y^N\|^2$.

Substituting everything back:

$$\sum_{n=0}^{N-1}\left[\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})\right]$$

$$\leq \frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma} - \frac{\|x - x^N\|^2}{2\tau} - \frac{\|y - y^N\|^2}{2\sigma}$$

$$\underbrace{- \frac{1}{2\tau}\|\delta^{N-1}\|^2 + \frac{\sigma L^2}{2}\|\delta^{N-1}\|^2}_{= -\frac{1}{2}(\frac{1}{\tau} - \sigma L^2)\|\delta^{N-1}\|^2 \leq 0} + \left(\frac{\sigma L^2}{2} - \frac{1}{2\tau}\right)\sum_{n=0}^{N-2}\|\delta^n\|^2 + \frac{\sigma L^2}{2}\|\delta^{N-1}\|^2 + \frac{1}{2\sigma}\|y - y^N\|^2.$$

Wait, let me redo this more carefully. Collecting all terms:

$$\sum_{n=0}^{N-1}[\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})]$$

$$\leq \frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma} - \frac{\|x - x^N\|^2}{2\tau} - \frac{\|y - y^N\|^2}{2\sigma} + (\text{step terms}) + R_N$$

$$\leq \frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma} - \frac{\|x - x^N\|^2}{2\tau} - \frac{\|y - y^N\|^2}{2\sigma} + R_N$$

using (S1). Now bound $R_N$:

$$R_N \leq \frac{\sigma L^2}{2}\|\delta^{N-1}\|^2 + \frac{1}{2\sigma}\|y - y^N\|^2.$$

But we also have the leftover $-\frac{1}{2\tau}\|\delta^{N-1}\|^2$ from (S1). Let me be more precise.

From the step terms computation: the sum is

$$-\frac{1}{2\tau}\|\delta^{N-1}\|^2 + \left(\frac{\sigma L^2}{2} - \frac{1}{2\tau}\right)\sum_{n=0}^{N-2}\|\delta^n\|^2 \leq -\frac{1}{2\tau}\|\delta^{N-1}\|^2$$

since $\sigma L^2 < 1/\tau$. So in total:

$$\sum_{n=0}^{N-1}[\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})]$$

$$\leq \frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma} - \frac{\|x - x^N\|^2}{2\tau} - \frac{\|y - y^N\|^2}{2\sigma} - \frac{1}{2\tau}\|\delta^{N-1}\|^2 + R_N.$$

Now:

$$-\frac{1}{2\tau}\|\delta^{N-1}\|^2 + R_N \leq -\frac{1}{2\tau}\|\delta^{N-1}\|^2 + \frac{\sigma L^2}{2}\|\delta^{N-1}\|^2 + \frac{1}{2\sigma}\|y - y^N\|^2$$

$$= -\frac{1}{2}\left(\frac{1}{\tau} - \sigma L^2\right)\|\delta^{N-1}\|^2 + \frac{1}{2\sigma}\|y - y^N\|^2$$

$$\leq \frac{1}{2\sigma}\|y - y^N\|^2$$

since $\tau\sigma L^2 < 1$ implies $\frac{1}{\tau} - \sigma L^2 > 0$. Substituting:

$$\sum_{n=0}^{N-1}[\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})] \leq \frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma} - \frac{\|x - x^N\|^2}{2\tau} - \frac{\|y - y^N\|^2}{2\sigma} + \frac{\|y - y^N\|^2}{2\sigma}$$

$$= \frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma} - \frac{\|x - x^N\|^2}{2\tau}$$

$$\leq \frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma}. \tag{5.1}$$

**Apply Jensen's inequality (convexity) for ergodic averages.**

Define $\mathcal{L}(x, y) = \langle Kx, y\rangle + g(x) - f^*(y)$.

Since $g$ is convex and $f^*$ is convex, the function $x \mapsto \mathcal{L}(x, y)$ is convex for each fixed $y$, and $y \mapsto -\mathcal{L}(x, y)$ is convex for each fixed $x$ (equivalently, $y \mapsto \mathcal{L}(x, y)$ is concave).

For the ergodic averages $X^N = \frac{1}{N}\sum_{n=1}^N x^n$ and $Y^N = \frac{1}{N}\sum_{n=1}^N y^n$:

By convexity of $x \mapsto \mathcal{L}(x, y)$:

$$\mathcal{L}(X^N, y) = \mathcal{L}\!\left(\frac{1}{N}\sum_{n=1}^N x^n, y\right) \leq \frac{1}{N}\sum_{n=1}^N \mathcal{L}(x^n, y).$$

By concavity of $y \mapsto \mathcal{L}(x, y)$:

$$\mathcal{L}(x, Y^N) = \mathcal{L}\!\left(x, \frac{1}{N}\sum_{n=1}^N y^n\right) \geq \frac{1}{N}\sum_{n=1}^N \mathcal{L}(x, y^n).$$

Therefore, using both directions (note the index shift: the sum in (5.1) is $\sum_{n=0}^{N-1}$ with iterates $(x^{n+1}, y^{n+1})$, which equals $\sum_{n=1}^{N}$ over $(x^n, y^n)$):

$$\mathcal{L}(X^N, y) - \mathcal{L}(x, Y^N) \leq \frac{1}{N}\sum_{n=1}^{N}\mathcal{L}(x^n, y) - \frac{1}{N}\sum_{n=1}^{N}\mathcal{L}(x, y^n)$$

$$= \frac{1}{N}\sum_{n=0}^{N-1}\left[\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})\right]$$

$$\leq \frac{1}{N}\left(\frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma}\right). \tag{5.2}$$

**From pointwise to the restricted gap.**

Inequality (5.2) holds for all $(x, y) \in B = B_x \times B_y$. Taking the supremum:

$$\mathcal{G}_B(X^N, Y^N) = \sup_{(x,y) \in B}\left[\mathcal{L}(X^N, y) - \mathcal{L}(x, Y^N)\right]$$

and from (5.2), for each $(x, y) \in B$:

$$\mathcal{L}(X^N, y) - \mathcal{L}(x, Y^N) \leq \frac{1}{N}\left(\frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma}\right).$$

Therefore:

$$\boxed{\mathcal{G}_B(X^N, Y^N) \leq \frac{1}{N}\left(\frac{\|x - x^0\|^2}{2\tau} + \frac{\|y - y^0\|^2}{2\sigma}\right) \quad \forall\, (x,y) \in B.}$$

This is the desired $O(1/N)$ ergodic convergence rate. $\blacksquare$

---

## Summary of the Route

1. **Fenchel duality**: Connected the saddle-point problem to $\min_x g(x) + f(Kx)$ and identified the gap functional.
2. **KKT/Prox optimality**: Extracted subgradient membership from each proximal step.
3. **Per-iterate gap bound**: Used convexity of $g$ and $f^*$ with the prox subgradients to bound $\mathcal{L}(x^{n+1}, y) - \mathcal{L}(x, y^{n+1})$.
4. **Extrapolation handling**: Introduced the telescoping quantity $R_n = \langle K(x^n - x^{n-1}), y - y^n\rangle$ to manage the overrelaxation $\bar{x}^n = 2x^n - x^n$. Used Young's inequality on the boundary term $R_N$, with the condition $\tau\sigma L^2 < 1$ ensuring the squared step norms are absorbed.
5. **Ergodic averaging**: Applied Jensen's inequality (convexity in $x$, concavity in $y$) to pass from per-iterate bounds to the ergodic average, yielding the $O(1/N)$ rate.

**Key condition used:** $\tau\sigma L^2 < 1$ ensures $\frac{1}{\tau} - \sigma L^2 > 0$, which is needed to absorb the coupling terms arising from the extrapolation step.
