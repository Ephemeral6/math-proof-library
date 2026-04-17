# Route 2: Entropy / Direct MGF Summation

## Setup

Same definitions as Route 1. We prove the same theorem using a slightly different approach for Part (b) that avoids Jensen's inequality, instead directly bounding $\mathbb{E}[\max_i X_i]$ via the tail integral formula.

---

## Part (a): Tail Bound (Same as Route 1)

By union bound and Chernoff/sub-Gaussian MGF optimization:
$$P\!\left(\max_i X_i > t\right) \leq \sum_{i=1}^n P(X_i > t) \leq n \exp\!\left(-\frac{t^2}{2\sigma^2}\right). \quad \blacksquare$$

(Full details in Route 1, Steps 1-4.)

---

## Part (b): Expectation Bound via Tail Integration

**Step 1: Layer cake (tail integral) representation.**

For any random variable $Z$, if we split at a threshold $u$:
$$\mathbb{E}[Z] = \mathbb{E}[Z \cdot \mathbf{1}_{Z \leq u}] + \mathbb{E}[Z \cdot \mathbf{1}_{Z > u}] \leq u + \mathbb{E}[(Z - u)^+]$$

where $(Z-u)^+ = \max(Z-u, 0)$. By the tail integral formula:
$$\mathbb{E}[(Z-u)^+] = \int_0^\infty P(Z - u > s)\, ds = \int_0^\infty P(Z > u + s)\, ds. \tag{1}$$

So:
$$\mathbb{E}[Z] \leq u + \int_0^\infty P(Z > u + s)\, ds. \tag{2}$$

**Step 2: Apply Part (a).**

Let $Z = \max_i X_i$. From Part (a):
$$P(Z > t) \leq n e^{-t^2/(2\sigma^2)}.$$

Choose $u = \sigma\sqrt{2\log n}$ (we'll see this is natural). Then:
$$\mathbb{E}[Z] \leq \sigma\sqrt{2\log n} + \int_0^\infty n \exp\!\left(-\frac{(\sigma\sqrt{2\log n} + s)^2}{2\sigma^2}\right) ds.$$

**Step 3: Evaluate the integral.**

$$\int_0^\infty n \exp\!\left(-\frac{(\sigma\sqrt{2\log n} + s)^2}{2\sigma^2}\right) ds.$$

Let $a = \sigma\sqrt{2\log n}$. Then:
$$= n \int_0^\infty e^{-(a+s)^2/(2\sigma^2)}\, ds = n \int_a^\infty e^{-v^2/(2\sigma^2)}\, dv \quad (v = a + s)$$

Using the Gaussian tail bound: for $v \geq a > 0$,
$$\int_a^\infty e^{-v^2/(2\sigma^2)}\, dv \leq \frac{\sigma^2}{a} e^{-a^2/(2\sigma^2)}.$$

(This is the standard bound $\int_a^\infty e^{-v^2/(2c)}\, dv \leq \frac{c}{a} e^{-a^2/(2c)}$, which follows from $\int_a^\infty e^{-v^2/(2c)} dv \leq \int_a^\infty \frac{v}{a} e^{-v^2/(2c)} dv = \frac{c}{a} e^{-a^2/(2c)}$.)

With $a = \sigma\sqrt{2\log n}$ and $a^2/(2\sigma^2) = \log n$:
$$n \cdot \frac{\sigma^2}{\sigma\sqrt{2\log n}} \cdot e^{-\log n} = n \cdot \frac{\sigma}{\sqrt{2\log n}} \cdot \frac{1}{n} = \frac{\sigma}{\sqrt{2\log n}}.$$

**Step 4: Combine.**

$$\mathbb{E}\!\left[\max_i X_i\right] \leq \sigma\sqrt{2\log n} + \frac{\sigma}{\sqrt{2\log n}}.$$

**Problem:** This gives $\sigma\sqrt{2\log n} + \frac{\sigma}{\sqrt{2\log n}}$, which is strictly *larger* than the stated bound $\sigma\sqrt{2\log n}$.

This means the tail integration approach with threshold $u = \sigma\sqrt{2\log n}$ overshoots. The issue is that the splitting $\mathbb{E}[Z] \leq u + \int_0^\infty P(Z > u+s)\,ds$ is an equality only when $Z \geq u$ a.s., but in general it's $\mathbb{E}[Z] = u \cdot P(Z > u) + \mathbb{E}[Z \mathbf{1}_{Z \leq u}] + \int_0^\infty P(Z > u+s)\,ds$... Actually wait:

Let me redo: $\mathbb{E}[Z] = \int_0^\infty P(Z > t)\,dt - \int_0^\infty P(Z < -t)\,dt$ (for general $Z$, using the signed tail formula). Actually, for centered sub-Gaussian variables ($\mathbb{E}[X_i] = 0$), we can assume $\mathbb{E}[Z] \geq 0$ so:

$$\mathbb{E}[Z] = \int_0^\infty P(Z > t)\, dt \leq \int_0^\infty \min\{1, n e^{-t^2/(2\sigma^2)}\}\, dt.$$

The bound $n e^{-t^2/(2\sigma^2)} = 1$ when $t = \sigma\sqrt{2\log n}$. So:
$$\mathbb{E}[Z] \leq \int_0^{\sigma\sqrt{2\log n}} 1\, dt + \int_{\sigma\sqrt{2\log n}}^\infty n e^{-t^2/(2\sigma^2)}\, dt = \sigma\sqrt{2\log n} + \frac{\sigma}{\sqrt{2\log n}}.$$

This still gives the extra term. So the tail integration method yields a *slightly weaker* bound. The log-sum-exp method of Route 1 is tighter.

**Conclusion for Route 2:** This route establishes $\mathbb{E}[\max_i X_i] \leq \sigma\sqrt{2\log n} + \frac{\sigma}{\sqrt{2\log n}}$, which is asymptotically equivalent but has a worse additive constant. **Route 2 does NOT achieve the exact stated bound.** It proves a weaker version.

The tail bound (Part a) is fine. But Part (b) with the exact constant requires the log-sum-exp / Jensen approach of Route 1.
