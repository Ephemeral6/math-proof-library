# McDiarmid's Bounded Differences Inequality — Proof via Exponential Supermartingale

**Theorem.** Let $X_1, \ldots, X_n$ be independent random variables taking values in $\mathcal{X}$, and let $f: \mathcal{X}^n \to \mathbb{R}$ satisfy the bounded differences condition with constants $c_1, \ldots, c_n$. Then for all $t > 0$,

$$\Pr[f(X) - \mathbb{E}[f(X)] \geq t] \leq \exp\!\left(-\frac{2t^2}{\sum_{k=1}^n c_k^2}\right).$$

---

## Step 1: Doob Martingale Construction

Let $F = f(X_1, \ldots, X_n)$ and $\mu = \mathbb{E}[F]$. Define:

$$Z_k = \mathbb{E}[F \mid X_1, \ldots, X_k], \quad k = 0, 1, \ldots, n,$$

with $Z_0 = \mu$ and $Z_n = F$. By the tower property, $(Z_k)_{k=0}^n$ is a martingale with respect to $\mathcal{F}_k = \sigma(X_1, \ldots, X_k)$.

The martingale differences $D_k = Z_k - Z_{k-1}$ satisfy:

$$F - \mu = \sum_{k=1}^n D_k, \quad \mathbb{E}[D_k \mid \mathcal{F}_{k-1}] = 0.$$

## Step 2: Bounding the Martingale Differences

Define $g_k(x_1, \ldots, x_k) = \mathbb{E}[f(x_1, \ldots, x_k, X_{k+1}, \ldots, X_n)]$. Then $Z_k = g_k(X_1, \ldots, X_k)$ and:

$$D_k = g_k(X_1, \ldots, X_k) - \mathbb{E}[g_k(X_1, \ldots, X_{k-1}, X_k) \mid \mathcal{F}_{k-1}].$$

By the bounded differences condition and Jensen's inequality:

$$|g_k(\ldots, x_k) - g_k(\ldots, x_k')| \leq c_k.$$

So $x_k \mapsto g_k(\ldots, x_k)$ has range of width $\leq c_k$, and $D_k$ lies in an interval of length $\leq c_k$ given $\mathcal{F}_{k-1}$, with conditional mean zero.

## Step 3: Hoeffding's Lemma

**Lemma.** If $Y$ has $\mathbb{E}[Y] = 0$ and $Y \in [a, b]$ a.s., then $\mathbb{E}[e^{sY}] \leq \exp(s^2(b-a)^2/8)$.

*Proof.* By convexity of $e^{sy}$: $e^{sy} \leq \frac{b-y}{b-a}e^{sa} + \frac{y-a}{b-a}e^{sb}$. Taking expectations with $\mathbb{E}[Y]=0$ and setting $h = s(b-a)$, $p = -a/(b-a)$:

$$\ln\mathbb{E}[e^{sY}] \leq \varphi(h) = -ph + \ln(1-p+pe^h).$$

Since $\varphi(0) = \varphi'(0) = 0$ and $\varphi''(h) = q(1-q) \leq 1/4$ where $q = pe^h/(1-p+pe^h)$, Taylor's theorem gives $\varphi(h) \leq h^2/8$. $\blacksquare$

## Step 4: Exponential Supermartingale

Fix $\lambda > 0$. Define:

$$M_k = \exp\!\left(\lambda Z_k - \frac{\lambda^2}{8}\sum_{j=1}^k c_j^2\right).$$

**Claim:** $(M_k)$ is a supermartingale.

*Proof.* 
$$\mathbb{E}[M_k \mid \mathcal{F}_{k-1}] = M_{k-1} \cdot e^{-\lambda^2 c_k^2/8} \cdot \mathbb{E}[e^{\lambda D_k} \mid \mathcal{F}_{k-1}] \leq M_{k-1} \cdot e^{-\lambda^2 c_k^2/8} \cdot e^{\lambda^2 c_k^2/8} = M_{k-1},$$

where Hoeffding's Lemma is applied conditionally to $D_k$ (centered, in interval of length $\leq c_k$). $\blacksquare$

## Step 5: Conclusion

Since $(M_k)$ is a supermartingale: $\mathbb{E}[M_n] \leq \mathbb{E}[M_0] = e^{\lambda\mu}$, giving:

$$\mathbb{E}[e^{\lambda(F-\mu)}] \leq \exp(\lambda^2 C/8), \quad C = \sum_{k=1}^n c_k^2.$$

By Markov's inequality: $\Pr[F - \mu \geq t] \leq \exp(-\lambda t + \lambda^2 C/8)$.

Optimizing at $\lambda^* = 4t/C$:

$$-\frac{4t^2}{C} + \frac{2t^2}{C} = -\frac{2t^2}{C}.$$

$$\boxed{\Pr[f(X) - \mathbb{E}[f(X)] \geq t] \leq \exp\!\left(-\frac{2t^2}{\sum_{k=1}^n c_k^2}\right).} \quad \blacksquare$$
