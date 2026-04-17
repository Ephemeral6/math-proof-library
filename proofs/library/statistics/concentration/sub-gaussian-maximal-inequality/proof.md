# Proof: Sub-Gaussian Maximal Inequality

## Theorem

Let $X_1, \ldots, X_n$ be random variables (not necessarily independent) that are sub-Gaussian with parameter $\sigma > 0$, i.e., for each $i$ and all $\lambda \in \mathbb{R}$:
$$\mathbb{E}[e^{\lambda X_i}] \leq e^{\lambda^2 \sigma^2 / 2}.$$

Then:

**(a)** For all $t > 0$: $\;P\!\left(\max_{1 \leq i \leq n} X_i > t\right) \leq n \exp\!\left(-\frac{t^2}{2\sigma^2}\right).$

**(b)** $\;\mathbb{E}\!\left[\max_{1 \leq i \leq n} X_i\right] \leq \sigma\sqrt{2 \log n}.$

---

## Proof of (a): Tail Bound

**Step 1 (Union bound).** By sub-additivity of probability:
$$P\!\left(\max_i X_i > t\right) = P\!\left(\bigcup_{i=1}^n \{X_i > t\}\right) \leq \sum_{i=1}^n P(X_i > t). \tag{1}$$

**Step 2 (Chernoff bound).** For each $i$ and any $\lambda > 0$, Markov's inequality applied to $e^{\lambda X_i} > 0$ gives:
$$P(X_i > t) = P(e^{\lambda X_i} > e^{\lambda t}) \leq e^{-\lambda t}\,\mathbb{E}[e^{\lambda X_i}] \leq \exp\!\left(\frac{\lambda^2 \sigma^2}{2} - \lambda t\right). \tag{2}$$

**Step 3 (Optimize).** The exponent $g(\lambda) = \frac{\lambda^2\sigma^2}{2} - \lambda t$ is minimized at $\lambda^* = t/\sigma^2 > 0$:
$$g(\lambda^*) = \frac{t^2}{2\sigma^2} - \frac{t^2}{\sigma^2} = -\frac{t^2}{2\sigma^2}.$$

So $P(X_i > t) \leq \exp\!\left(-\frac{t^2}{2\sigma^2}\right)$.

**Step 4 (Combine).** Substituting into (1):
$$P\!\left(\max_i X_i > t\right) \leq n\exp\!\left(-\frac{t^2}{2\sigma^2}\right). \qquad \blacksquare$$

---

## Proof of (b): Expectation Bound

**Step 1 (Log-sum-exp upper bound).** For any $\lambda > 0$ and reals $a_1, \ldots, a_n$:
$$\max_i\, a_i \leq \frac{1}{\lambda}\log\!\sum_{i=1}^n e^{\lambda a_i}. \tag{3}$$

*Proof:* $e^{\lambda \max_i a_i} = \max_i e^{\lambda a_i} \leq \sum_i e^{\lambda a_i}$. Dividing by $\lambda > 0$ after taking $\log$ preserves the inequality. $\square$

**Step 2 (Take expectation and apply Jensen).** Inequality (3) holds pointwise for the random variables $X_i$. Taking expectations:
$$\mathbb{E}\!\left[\max_i X_i\right] \leq \frac{1}{\lambda}\,\mathbb{E}\!\left[\log\!\sum_{i=1}^n e^{\lambda X_i}\right]. \tag{4}$$

Since $\log$ is concave, Jensen's inequality gives:
$$\mathbb{E}\!\left[\log\!\sum_{i=1}^n e^{\lambda X_i}\right] \leq \log\!\left(\sum_{i=1}^n \mathbb{E}[e^{\lambda X_i}]\right). \tag{5}$$

**Step 3 (Sub-Gaussian MGF bound).** By linearity of expectation and the sub-Gaussian hypothesis:
$$\log\!\left(\sum_{i=1}^n \mathbb{E}[e^{\lambda X_i}]\right) \leq \log\!\left(n\, e^{\lambda^2\sigma^2/2}\right) = \log n + \frac{\lambda^2\sigma^2}{2}. \tag{6}$$

**Step 4 (Combine).** From (4)-(6):
$$\mathbb{E}\!\left[\max_i X_i\right] \leq \frac{\log n}{\lambda} + \frac{\lambda\sigma^2}{2}. \tag{7}$$

**Step 5 (Optimize over $\lambda > 0$).** Let $h(\lambda) = \frac{\log n}{\lambda} + \frac{\lambda\sigma^2}{2}$. Then $h'(\lambda) = -\frac{\log n}{\lambda^2} + \frac{\sigma^2}{2}$, which vanishes at:
$$\lambda^* = \frac{\sqrt{2\log n}}{\sigma} > 0 \quad (\text{for } n \geq 2).$$

Since $h''(\lambda) = \frac{2\log n}{\lambda^3} > 0$, this is a global minimum on $(0,\infty)$.

Substituting:
$$h(\lambda^*) = \frac{\sigma\log n}{\sqrt{2\log n}} + \frac{\sigma\sqrt{2\log n}}{2} = \frac{\sigma\sqrt{\log n}}{\sqrt{2}} + \frac{\sigma\sqrt{\log n}}{\sqrt{2}} = \sigma\sqrt{2\log n}.$$

Therefore:
$$\mathbb{E}\!\left[\max_{1 \leq i \leq n} X_i\right] \leq \sigma\sqrt{2\log n}. \qquad \blacksquare$$

---

## Remarks

1. **No independence required.** Only the individual sub-Gaussian MGF conditions are used. The union bound and Jensen's inequality hold for arbitrary (possibly dependent) random variables.

2. **Tightness.** For i.i.d. $\mathcal{N}(0,\sigma^2)$, $\mathbb{E}[\max_i X_i] \sim \sigma\sqrt{2\log n}$ as $n \to \infty$, so the constant $\sqrt{2}$ is optimal.

3. **Edge case $n=1$.** The MGF condition implies $\mathbb{E}[X_1] \leq 0$ (by Jensen: $e^{\lambda\mathbb{E}[X_1]} \leq e^{\lambda^2\sigma^2/2}$, divide by $\lambda$ and let $\lambda \to 0^+$), consistent with $\sigma\sqrt{2\log 1} = 0$.
