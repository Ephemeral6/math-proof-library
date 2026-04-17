# Proof Report: Azuma-Hoeffding Inequality

## 1. Problem Statement

**Theorem (Azuma-Hoeffding).** Let $(M_k)_{k=0}^n$ be a martingale with respect to filtration $(\mathcal{F}_k)$ such that the differences are bounded:

$$|M_k - M_{k-1}| \leq c_k \quad \text{a.s.}, \quad k = 1, \ldots, n$$

for constants $c_1, \ldots, c_n > 0$. Then for all $t > 0$:

$$P(M_n - M_0 \geq t) \leq \exp\left(-\frac{t^2}{2\sum_{k=1}^n c_k^2}\right).$$

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 4 routes proposed |
| Explorer | Opus | 4 proofs attempted, 4 succeeded |
| Judge | Sonnet | Route 4 selected (score: 38/40) |
| Audit | Opus | PASS (1 round, 0 issues of HIGH/MEDIUM severity) |
| Fix | Opus | Not needed |

## 3. Proof Routes Explored

1. **Chernoff + Conditional Hoeffding's Lemma** (37/40): Standard approach using exponential Markov and tower property. Clean and correct.
2. **Direct Induction on n** (31/40): Inductive reformulation of the same argument. Correct but less self-contained.
3. **Supermartingale Construction** (37/40): Elegant approach constructing $Z_k = \exp(s(M_k - M_0) - s^2\sum_{j=1}^k c_j^2/2)$ as a supermartingale. Tied for second.
4. **Self-Contained with Hoeffding's Lemma from First Principles** (38/40): **Winner.** Includes full proof of Hoeffding's lemma via convexity + Taylor remainder, then applies Chernoff-tower method.

## 4. Final Proof

### Part I: Proof of Hoeffding's Lemma

**Lemma (Hoeffding).** Let $X$ be a random variable with $\mathbb{E}[X] = 0$ and $a \leq X \leq b$ a.s. Then for all $s \in \mathbb{R}$:
$$\mathbb{E}[e^{sX}] \leq \exp\left(\frac{s^2(b-a)^2}{8}\right).$$

**Proof.**

*Step H1.* Since $e^{sx}$ is convex in $x$, for $x \in [a,b]$:
$$e^{sx} \leq \frac{b - x}{b - a} e^{sa} + \frac{x - a}{b - a} e^{sb}$$

*Step H2.* Taking expectations with $\mathbb{E}[X] = 0$:
$$\mathbb{E}[e^{sX}] \leq \frac{b}{b-a} e^{sa} + \frac{-a}{b-a} e^{sb}$$

Setting $\theta = -a/(b-a) \in [0,1]$ and $h = s(b-a)$:
$$\mathbb{E}[e^{sX}] \leq e^{\varphi(h)}, \quad \text{where } \varphi(h) = -\theta h + \ln(1 - \theta + \theta e^h)$$

*Step H3.* We have $\varphi(0) = 0$, $\varphi'(0) = 0$, and
$$\varphi''(h) = \frac{\theta(1-\theta)e^h}{(1-\theta+\theta e^h)^2} = u(1-u) \leq \frac{1}{4}$$
where $u = \theta e^h/(1-\theta+\theta e^h)$. By Taylor's theorem: $\varphi(h) \leq h^2/8 = s^2(b-a)^2/8$. $\square$

### Part II: Conditional Hoeffding's Lemma

If $\mathbb{E}[X|\mathcal{G}] = 0$ a.s. and $|X| \leq c$ a.s., then $\mathbb{E}[e^{sX}|\mathcal{G}] \leq e^{s^2c^2/2}$ a.s.

(Apply Hoeffding's lemma with $a=-c, b=c$: $(2c)^2/8 = c^2/2$.)

### Part III: Azuma-Hoeffding Inequality

**Step 1.** Define $D_k = M_k - M_{k-1}$. Then $\mathbb{E}[D_k|\mathcal{F}_{k-1}] = 0$, $|D_k| \leq c_k$, and $M_n - M_0 = \sum_{k=1}^n D_k$.

**Step 2.** Chernoff bound: for $s > 0$,
$$P(M_n - M_0 \geq t) \leq e^{-st}\mathbb{E}[e^{s\sum D_k}]$$

**Step 3.** Tower property:
$$\mathbb{E}[e^{s\sum_{k=1}^n D_k}] = \mathbb{E}\left[e^{s\sum_{k=1}^{n-1}D_k} \cdot \mathbb{E}[e^{sD_n}|\mathcal{F}_{n-1}]\right]$$

**Step 4.** Conditional Hoeffding's lemma: $\mathbb{E}[e^{sD_k}|\mathcal{F}_{k-1}] \leq e^{s^2c_k^2/2}$.

**Step 5.** Iterate: $\mathbb{E}[e^{s\sum D_k}] \leq \exp(s^2\sum c_k^2/2)$.

**Step 6.** Combine: $P(M_n - M_0 \geq t) \leq \exp(-st + s^2\sum c_k^2/2)$.

**Step 7.** Optimize: $s^* = t/\sum c_k^2$, yielding $\exp(-t^2/(2\sum c_k^2))$.

**Step 8.** Conclude:
$$P(M_n - M_0 \geq t) \leq \exp\left(-\frac{t^2}{2\sum_{k=1}^n c_k^2}\right). \quad \blacksquare$$

## 5. Audit Result

**PASS** after 1 round. All 11 steps verified as VALID. Three LOW-severity notes:
1. The conditional Hoeffding's lemma could be more explicit about measurability (expository).
2. The iteration in Step 5 could be expanded (expository).
3. The two-sided bound is not explicitly derived (minor omission, not part of the core claim).

No HIGH or MEDIUM severity issues found.

## 6. Fix History

No fixes needed. The proof passed audit on the first round.
