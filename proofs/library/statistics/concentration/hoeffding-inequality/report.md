# Proof Report: Hoeffding's Inequality

## 1. Problem Statement

**Theorem (Hoeffding's Inequality).** Let $X_1, \ldots, X_n$ be independent random variables with $X_i \in [a_i, b_i]$ almost surely. Let $S_n = \sum_{i=1}^n X_i$. Then for all $t > 0$:

$$P(S_n - \mathbb{E}[S_n] \geq t) \leq \exp\left(-\frac{2t^2}{\sum_{i=1}^n (b_i - a_i)^2}\right).$$

**Corollary.** If $X_1, \ldots, X_n$ are i.i.d. with $X_i \in [a, b]$, then:

$$P\left(\bar{X}_n - \mathbb{E}[\bar{X}_n] \geq t\right) \leq \exp\left(-\frac{2nt^2}{(b-a)^2}\right).$$

Source: Hoeffding 1963, "Probability Inequalities for Sums of Bounded Random Variables"

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 4 routes proposed |
| Explorer | Opus | 4 proofs attempted, 3 succeeded (Route 4 failed) |
| Judge | Sonnet | Route 1 selected (score: 39/40) |
| Audit | Opus | PASS (1 round, 0 issues) |
| Fix | Opus | Not needed |

## 3. Proof Routes Explored

1. **Route 1: Classical MGF + Chernoff Bound** (39/40) — Standard approach using convexity of exp to prove Hoeffding's Lemma, then Chernoff bound + independence + optimization. Clean and complete. **SELECTED.**

2. **Route 2: Taylor Expansion of CGF** (35/40) — Alternative proof of Hoeffding's Lemma using the cumulant generating function and Popoviciu's variance bound under exponential tilting. Correct but slightly less self-contained due to reliance on Popoviciu's inequality.

3. **Route 3: φ Function Analysis** (39/40) — Nearly identical to Route 1 with slightly different presentation. Both use the φ(u) = -pu + ln(1-p+pe^u) ≤ u²/8 approach.

4. **Route 4: Symmetrization + Rademacher** (FAILED) — Cannot recover the sharp constant 2 in the exponent. The symmetrization technique introduces a factor that weakens the bound.

## 4. Final Proof

### Step 1: Reduction to Zero-Mean Variables

Define $Y_i = X_i - \mathbb{E}[X_i]$ for $i = 1, \ldots, n$. Then:
- $Y_i \in [a_i - \mathbb{E}[X_i],\; b_i - \mathbb{E}[X_i]]$ almost surely
- $\mathbb{E}[Y_i] = 0$
- $S_n - \mathbb{E}[S_n] = \sum_{i=1}^n Y_i$
- The $Y_i$ are independent

Denote $c_i = b_i - a_i$. It suffices to prove: for independent zero-mean random variables $Y_i$ with $Y_i \in [\alpha_i, \beta_i]$ where $\beta_i - \alpha_i = c_i$,

$$P\left(\sum_{i=1}^n Y_i \geq t\right) \leq \exp\left(-\frac{2t^2}{\sum_{i=1}^n c_i^2}\right).$$

### Step 2: Hoeffding's Lemma

**Lemma (Hoeffding).** Let $Y$ be a random variable with $\mathbb{E}[Y] = 0$ and $Y \in [\alpha, \beta]$ a.s. Then for all $s > 0$:

$$\mathbb{E}[e^{sY}] \leq \exp\left(\frac{s^2(\beta - \alpha)^2}{8}\right).$$

**Proof of Lemma.** By convexity of $e^{sx}$, for $y \in [\alpha, \beta]$:

$$e^{sy} \leq \frac{\beta - y}{\beta - \alpha} e^{s\alpha} + \frac{y - \alpha}{\beta - \alpha} e^{s\beta}.$$

Taking expectations with $\mathbb{E}[Y] = 0$:

$$\mathbb{E}[e^{sY}] \leq \frac{\beta}{\beta - \alpha} e^{s\alpha} + \frac{-\alpha}{\beta - \alpha} e^{s\beta}.$$

Let $p = \frac{-\alpha}{\beta - \alpha} \in [0, 1]$ and $u = s(\beta - \alpha)$. Then $s\alpha = -pu$, $s\beta = (1-p)u$, and:

$$\mathbb{E}[e^{sY}] \leq e^{\varphi(u)}, \quad \text{where } \varphi(u) = -pu + \ln(1 - p + pe^u).$$

We show $\varphi(u) \leq u^2/8$:
- $\varphi(0) = 0$, $\varphi'(0) = 0$.
- $\varphi''(u) = q(1-q)$ where $q = pe^u/(1-p+pe^u) \in (0,1)$.
- Since $q(1-q) \leq 1/4$, Taylor's theorem gives $\varphi(u) = \frac{\varphi''(\xi)}{2}u^2 \leq \frac{u^2}{8}$.

Therefore $\mathbb{E}[e^{sY}] \leq \exp(s^2(\beta-\alpha)^2/8)$. $\blacksquare_{\text{Lemma}}$

### Step 3: Chernoff Bound

For $s > 0$, by Markov's inequality:

$$P\left(\sum_i Y_i \geq t\right) \leq e^{-st}\,\mathbb{E}\left[e^{s\sum_i Y_i}\right].$$

### Step 4: Independence Factorization

$$\mathbb{E}\left[e^{s\sum_i Y_i}\right] = \prod_{i=1}^n \mathbb{E}[e^{sY_i}].$$

### Step 5: Apply Hoeffding's Lemma

$$P\left(\sum_i Y_i \geq t\right) \leq \exp\left(-st + \frac{s^2}{8}\sum_i c_i^2\right).$$

### Step 6: Optimize over $s > 0$

Setting $s^* = 4t/\sum_i c_i^2$:

$$P(S_n - \mathbb{E}[S_n] \geq t) \leq \exp\left(-\frac{2t^2}{\sum_{i=1}^n (b_i - a_i)^2}\right). \quad \blacksquare$$

### Step 7: Corollary

For i.i.d. $X_i \in [a,b]$: $P(\bar{X}_n - \mathbb{E}[\bar{X}_n] \geq t) \leq \exp(-2nt^2/(b-a)^2)$.

## 5. Audit Result

**PASS** — Round 1. All 7 steps marked VALID. No issues found (HIGH: 0, MEDIUM: 0, LOW: 0). Three confirmation points checked and all verified:
1. Boundary cases ($\alpha = 0$ or $\beta = 0$) handled correctly
2. $\varphi$ is $C^\infty$ on $\mathbb{R}$ (Taylor's theorem applicable)
3. Optimal $s^* > 0$ confirmed

Numerical verification (Python/NumPy, $10^6$ samples) confirmed:
- Hoeffding's Lemma holds for multiple $(a,b)$ pairs and $s$ values
- $\varphi(u) \leq u^2/8$ for $p \in \{0.1, 0.25, 0.5, 0.75, 0.9\}$, $u \in [-5, 5]$
- Hoeffding's Inequality holds empirically for $n=20$ with various parameters

## 6. Fix History

No fixes needed. Audit passed on first round.
