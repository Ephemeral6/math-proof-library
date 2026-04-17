# Proof of Hoeffding's Inequality

## Step 1: Reduction to Zero-Mean Variables

Define $Y_i = X_i - \mathbb{E}[X_i]$ for $i = 1, \ldots, n$. Then:
- $Y_i \in [a_i - \mathbb{E}[X_i],\; b_i - \mathbb{E}[X_i]]$ almost surely
- $\mathbb{E}[Y_i] = 0$
- $S_n - \mathbb{E}[S_n] = \sum_{i=1}^n Y_i$
- The $Y_i$ are independent (each $Y_i$ is a deterministic function of $X_i$)

Denote $c_i = b_i - a_i$. It suffices to prove: for independent zero-mean random variables $Y_i$ with $Y_i \in [\alpha_i, \beta_i]$ where $\beta_i - \alpha_i = c_i$,

$$P\left(\sum_{i=1}^n Y_i \geq t\right) \leq \exp\left(-\frac{2t^2}{\sum_{i=1}^n c_i^2}\right).$$

## Step 2: Hoeffding's Lemma

**Lemma (Hoeffding).** Let $Y$ be a random variable with $\mathbb{E}[Y] = 0$ and $Y \in [\alpha, \beta]$ a.s. Then for all $s > 0$:

$$\mathbb{E}[e^{sY}] \leq \exp\left(\frac{s^2(\beta - \alpha)^2}{8}\right).$$

**Proof of Lemma.** Since $Y \in [\alpha, \beta]$, by convexity of $x \mapsto e^{sx}$, for any $y \in [\alpha, \beta]$:

$$e^{sy} \leq \frac{\beta - y}{\beta - \alpha} e^{s\alpha} + \frac{y - \alpha}{\beta - \alpha} e^{s\beta}.$$

Taking expectations (using $\mathbb{E}[Y] = 0$):

$$\mathbb{E}[e^{sY}] \leq \frac{\beta}{\beta - \alpha} e^{s\alpha} + \frac{-\alpha}{\beta - \alpha} e^{s\beta}.$$

Let $p = \frac{-\alpha}{\beta - \alpha} \in [0, 1]$ (valid since $\alpha \leq 0 \leq \beta$ when $\mathbb{E}[Y] = 0$) and $u = s(\beta - \alpha)$. Then $s\alpha = -pu$, $s\beta = (1-p)u$, and:

$$\mathbb{E}[e^{sY}] \leq (1-p) e^{-pu} + p \, e^{(1-p)u} = e^{\varphi(u)},$$

where $\varphi(u) = -pu + \ln(1 - p + pe^u)$.

**Claim:** $\varphi(u) \leq u^2/8$ for all $u \in \mathbb{R}$ and $p \in [0,1]$.

**Proof of claim:**
- $\varphi(0) = 0$, $\varphi'(0) = -p + p/(1-p+p) = 0$.
- $\varphi''(u) = \frac{pe^u(1-p)}{(1-p+pe^u)^2}$.

Setting $q = \frac{pe^u}{1-p+pe^u} \in (0, 1)$, we get $\varphi''(u) = q(1-q) \leq \frac{1}{4}$, by the elementary bound $x(1-x) \leq 1/4$ for $x \in [0,1]$.

By Taylor's theorem with Lagrange remainder: there exists $\xi$ between 0 and $u$ such that

$$\varphi(u) = \varphi(0) + \varphi'(0)u + \frac{\varphi''(\xi)}{2}u^2 = \frac{\varphi''(\xi)}{2}u^2 \leq \frac{u^2}{8}.$$

Since $u = s(\beta - \alpha)$: $\mathbb{E}[e^{sY}] \leq \exp(s^2(\beta-\alpha)^2/8)$. $\blacksquare_{\text{Lemma}}$

## Step 3: Chernoff Bound

For any $s > 0$, by Markov's inequality:

$$P\left(\sum_{i=1}^n Y_i \geq t\right) = P\left(e^{s\sum_i Y_i} \geq e^{st}\right) \leq e^{-st}\,\mathbb{E}\left[e^{s\sum_i Y_i}\right].$$

## Step 4: Independence Factorization

Since $Y_1, \ldots, Y_n$ are independent:

$$\mathbb{E}\left[e^{s\sum_i Y_i}\right] = \prod_{i=1}^n \mathbb{E}[e^{sY_i}].$$

## Step 5: Apply Hoeffding's Lemma

Each $Y_i$ has zero mean and is bounded in an interval of length $c_i$, so:

$$P\left(\sum_i Y_i \geq t\right) \leq \exp\left(-st + \frac{s^2}{8}\sum_{i=1}^n c_i^2\right).$$

## Step 6: Optimize over $s > 0$

Minimizing $f(s) = -st + \frac{s^2}{8}\sum_i c_i^2$: $f'(s) = 0$ gives $s^* = \frac{4t}{\sum_i c_i^2}$.

$$f(s^*) = -\frac{4t^2}{\sum_i c_i^2} + \frac{2t^2}{\sum_i c_i^2} = -\frac{2t^2}{\sum_i c_i^2}.$$

Therefore:

$$\boxed{P(S_n - \mathbb{E}[S_n] \geq t) \leq \exp\left(-\frac{2t^2}{\sum_{i=1}^n (b_i - a_i)^2}\right).}$$

## Step 7: Corollary (i.i.d. Case)

For i.i.d. $X_i \in [a, b]$: $P(\bar{X}_n - \mathbb{E}[\bar{X}_n] \geq t) = P(S_n - \mathbb{E}[S_n] \geq nt) \leq \exp(-2n^2t^2/(n(b-a)^2)) = \exp(-2nt^2/(b-a)^2)$.

$\blacksquare$
