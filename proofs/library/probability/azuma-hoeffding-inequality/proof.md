# Proof of the Azuma-Hoeffding Inequality

A self-contained proof including Hoeffding's Lemma from first principles.

---

## Part I: Hoeffding's Lemma

**Lemma (Hoeffding).** Let $X$ be a random variable with $\mathbb{E}[X] = 0$ and $a \leq X \leq b$ a.s. Then for all $s \in \mathbb{R}$:
$$\mathbb{E}[e^{sX}] \leq \exp\left(\frac{s^2(b-a)^2}{8}\right).$$

**Proof.**

*Step H1: Convexity bound.* Since $e^{sx}$ is convex in $x$, for any $x \in [a, b]$:
$$e^{sx} \leq \frac{b - x}{b - a} e^{sa} + \frac{x - a}{b - a} e^{sb}$$

*Step H2: Take expectations.* Using $\mathbb{E}[X] = 0$:
$$\mathbb{E}[e^{sX}] \leq \frac{b}{b-a} e^{sa} + \frac{-a}{b-a} e^{sb}$$

Set $\theta = -a/(b-a) \in [0,1]$ and $h = s(b-a)$. Then $sa = -\theta h$ and $sb = (1-\theta)h$, giving:
$$\mathbb{E}[e^{sX}] \leq (1-\theta)e^{-\theta h} + \theta e^{(1-\theta)h} = e^{\varphi(h)}$$

where $\varphi(h) = -\theta h + \ln(1 - \theta + \theta e^h)$.

*Step H3: Bound via Taylor's theorem.* We compute:
- $\varphi(0) = 0$
- $\varphi'(h) = -\theta + \frac{\theta e^h}{1-\theta+\theta e^h}$, so $\varphi'(0) = 0$
- $\varphi''(h) = \frac{\theta(1-\theta)e^h}{(1-\theta+\theta e^h)^2}$

Setting $u = \theta e^h/(1-\theta+\theta e^h) \in (0,1)$, we get $\varphi''(h) = u(1-u) \leq 1/4$.

By Taylor's theorem with Lagrange remainder:
$$\varphi(h) = \frac{\varphi''(\xi)}{2}h^2 \leq \frac{h^2}{8} = \frac{s^2(b-a)^2}{8}$$

Therefore $\mathbb{E}[e^{sX}] \leq \exp(s^2(b-a)^2/8)$. $\square$

---

## Part II: Conditional Hoeffding's Lemma

**Corollary.** If $\mathbb{E}[X | \mathcal{G}] = 0$ a.s. and $|X| \leq c$ a.s., then:
$$\mathbb{E}[e^{sX} | \mathcal{G}] \leq e^{s^2 c^2/2} \quad \text{a.s.}$$

**Proof.** Apply Hoeffding's lemma to the regular conditional distribution of $X$ given $\mathcal{G}$, with $a = -c$, $b = c$: $(b-a)^2/8 = (2c)^2/8 = c^2/2$. The bound $e^{s^2c^2/2}$ is deterministic, hence trivially $\mathcal{G}$-measurable. $\square$

---

## Part III: Azuma-Hoeffding Inequality

**Step 1: Martingale differences.** Define $D_k = M_k - M_{k-1}$ for $k = 1, \ldots, n$. By the martingale property, $\mathbb{E}[D_k | \mathcal{F}_{k-1}] = 0$. By hypothesis, $|D_k| \leq c_k$ a.s. We have $M_n - M_0 = \sum_{k=1}^n D_k$.

**Step 2: Chernoff bound.** For any $s > 0$, by Markov's inequality applied to the non-negative random variable $e^{s(M_n - M_0)}$:
$$P(M_n - M_0 \geq t) = P(e^{s(M_n - M_0)} \geq e^{st}) \leq e^{-st} \cdot \mathbb{E}[e^{s(M_n - M_0)}]$$

**Step 3: Tower property decomposition.** By iterated conditioning:
$$\mathbb{E}[e^{s\sum_{k=1}^n D_k}] = \mathbb{E}\left[e^{s\sum_{k=1}^{n-1} D_k} \cdot \mathbb{E}[e^{sD_n} | \mathcal{F}_{n-1}]\right]$$

where $e^{s\sum_{k=1}^{n-1} D_k}$ factors out of the inner conditional expectation since it is $\mathcal{F}_{n-1}$-measurable.

**Step 4: Apply conditional Hoeffding's lemma.** Since $\mathbb{E}[D_k | \mathcal{F}_{k-1}] = 0$ and $|D_k| \leq c_k$:
$$\mathbb{E}[e^{sD_k} | \mathcal{F}_{k-1}] \leq e^{s^2 c_k^2/2}$$

**Step 5: Iterate.** Applying Steps 3-4 for $k = n, n-1, \ldots, 1$:
$$\mathbb{E}[e^{s\sum_{k=1}^n D_k}] \leq \prod_{k=1}^n e^{s^2 c_k^2/2} = \exp\left(\frac{s^2}{2}\sum_{k=1}^n c_k^2\right)$$

**Step 6: Combine.** From Steps 2 and 5:
$$P(M_n - M_0 \geq t) \leq \exp\left(-st + \frac{s^2}{2}\sum_{k=1}^n c_k^2\right)$$

**Step 7: Optimize over $s > 0$.** Let $\sigma^2 = \sum_{k=1}^n c_k^2$. Minimizing $f(s) = -st + s^2\sigma^2/2$:
$$f'(s) = -t + s\sigma^2 = 0 \implies s^* = \frac{t}{\sigma^2} > 0$$

Substituting: $f(s^*) = -t^2/\sigma^2 + t^2/(2\sigma^2) = -t^2/(2\sigma^2)$.

**Step 8: Conclude.**
$$\boxed{P(M_n - M_0 \geq t) \leq \exp\left(-\frac{t^2}{2\sum_{k=1}^n c_k^2}\right)}$$

$\blacksquare$

**Remark (two-sided bound).** Since $(-M_k)$ is also a martingale with the same bounded differences, applying the above to $-M$ gives $P(M_0 - M_n \geq t) \leq \exp(-t^2/(2\sum c_k^2))$. By the union bound: $P(|M_n - M_0| \geq t) \leq 2\exp(-t^2/(2\sum_{k=1}^n c_k^2))$.
