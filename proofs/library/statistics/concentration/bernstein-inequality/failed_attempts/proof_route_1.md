# Route 1: MGF + Bennett's Lemma (Classical)

## Theorem

Let $X_1, \ldots, X_n$ be independent random variables with $\mathbb{E}[X_i] = 0$ and $|X_i| \leq M$ a.s. Let $V = \sum_{i=1}^n \mathbb{E}[X_i^2]$. Then for all $t > 0$,

$$P\!\left(\sum_{i=1}^n X_i > t\right) \leq \exp\!\left(-\frac{t^2/2}{V + Mt/3}\right).$$

## Proof

**Step 1: Chernoff Bound.**

Let $S = \sum_{i=1}^n X_i$. For any $\lambda > 0$, by Markov's inequality applied to $e^{\lambda S}$:

$$P(S > t) = P(e^{\lambda S} > e^{\lambda t}) \leq e^{-\lambda t} \mathbb{E}[e^{\lambda S}].$$

Since the $X_i$ are independent:

$$\mathbb{E}[e^{\lambda S}] = \prod_{i=1}^n \mathbb{E}[e^{\lambda X_i}].$$

**Step 2: Bennett's Lemma — Bounding each MGF.**

**Lemma (Bennett).** If $X$ is a random variable with $\mathbb{E}[X] = 0$, $|X| \leq M$ a.s., and $\mathbb{E}[X^2] = \sigma^2$, then for all $\lambda > 0$:

$$\mathbb{E}[e^{\lambda X}] \leq \exp\!\left(\frac{\sigma^2}{M^2}\left(e^{\lambda M} - 1 - \lambda M\right)\right). \tag{*}$$

*Proof of Lemma.* Define $\varphi(\lambda) = \log \mathbb{E}[e^{\lambda X}]$. We have $\varphi(0) = 0$ and $\varphi'(0) = \mathbb{E}[X] = 0$.

For the second derivative: $\varphi''(\lambda) = \frac{\mathbb{E}[X^2 e^{\lambda X}]}{\mathbb{E}[e^{\lambda X}]} - \left(\frac{\mathbb{E}[X e^{\lambda X}]}{\mathbb{E}[e^{\lambda X}]}\right)^2 = \text{Var}_\mu(X)$, where $\mu$ is the tilted distribution $d\mu = e^{\lambda X}/\mathbb{E}[e^{\lambda X}] \, dP$.

Under $\mu$, we still have $|X| \leq M$, so $\text{Var}_\mu(X) \leq \mathbb{E}_\mu[X^2]$. We also claim:

$$\mathbb{E}_\mu[X^2] \leq \frac{\sigma^2}{M^2} \cdot M^2 \cdot \frac{e^{\lambda M}}{\mathbb{E}[e^{\lambda X}]} \cdot \frac{\mathbb{E}[e^{\lambda X}]}{\mathbb{E}[e^{\lambda X}]} \ldots$$

Actually, let us use a more direct approach. We prove $(*)$ by Taylor expansion.

**Direct proof of $(*)$.** We write $e^{\lambda X} = 1 + \lambda X + \sum_{k=2}^{\infty} \frac{(\lambda X)^k}{k!}$. Taking expectations and using $\mathbb{E}[X] = 0$:

$$\mathbb{E}[e^{\lambda X}] = 1 + \sum_{k=2}^{\infty} \frac{\lambda^k \mathbb{E}[X^k]}{k!}.$$

For $k \geq 2$, since $\mathbb{E}[X] = 0$ and $|X| \leq M$:

$$|\mathbb{E}[X^k]| \leq \mathbb{E}[|X|^k] = \mathbb{E}[|X|^2 \cdot |X|^{k-2}] \leq M^{k-2} \mathbb{E}[X^2] = \sigma^2 M^{k-2}.$$

Therefore:

$$\mathbb{E}[e^{\lambda X}] \leq 1 + \sum_{k=2}^{\infty} \frac{\lambda^k \sigma^2 M^{k-2}}{k!} = 1 + \frac{\sigma^2}{M^2} \sum_{k=2}^{\infty} \frac{(\lambda M)^k}{k!} = 1 + \frac{\sigma^2}{M^2}(e^{\lambda M} - 1 - \lambda M).$$

Using $1 + x \leq e^x$ for all $x \in \mathbb{R}$:

$$\mathbb{E}[e^{\lambda X}] \leq \exp\!\left(\frac{\sigma^2}{M^2}(e^{\lambda M} - 1 - \lambda M)\right). \quad \square$$

**Step 3: Combining.**

From Steps 1 and 2, with $\sigma_i^2 = \mathbb{E}[X_i^2]$:

$$P(S > t) \leq e^{-\lambda t} \prod_{i=1}^n \exp\!\left(\frac{\sigma_i^2}{M^2}(e^{\lambda M} - 1 - \lambda M)\right) = \exp\!\left(-\lambda t + \frac{V}{M^2}(e^{\lambda M} - 1 - \lambda M)\right),$$

where $V = \sum_{i=1}^n \sigma_i^2$.

**Step 4: Key Elementary Inequality.**

**Claim:** For all $u > 0$:

$$e^u - 1 - u \leq \frac{u^2/2}{1 - u/3}. \tag{**}$$

Wait — this inequality is NOT true for all $u > 0$; it holds for $u \in (0, 3)$ but we need a version valid for all $u$. Actually, we need a different approach.

**Corrected approach.** We use the inequality: for $u \geq 0$,

$$e^u - 1 - u \leq \frac{u^2}{2} e^u.$$

But this gives a weaker result. Let us instead optimize directly.

**Step 4 (Corrected): Direct moment approach.**

Going back, from the moment bound $|\mathbb{E}[X^k]| \leq \sigma^2 M^{k-2}$ for $k \geq 2$, we have:

$$\mathbb{E}[e^{\lambda X}] \leq 1 + \sum_{k=2}^{\infty} \frac{(\lambda M)^{k-2}}{k!} \lambda^2 \sigma^2.$$

Now we use the sharper inequality: for $k \geq 2$,

$$\frac{1}{k!} \leq \frac{1}{2} \cdot \frac{1}{3^{k-2}} \cdot \frac{1}{1} \quad \text{?}$$

Actually, let's verify: $\frac{1}{k!} \leq \frac{1}{2 \cdot 3^{k-2}}$ for $k \geq 2$.

- $k=2$: $\frac{1}{2} \leq \frac{1}{2}$. ✓
- $k=3$: $\frac{1}{6} \leq \frac{1}{6}$. ✓
- $k=4$: $\frac{1}{24} \leq \frac{1}{18}$. ✓
- For $k \geq 3$: $k! = k \cdot (k-1) \cdots 3 \cdot 2 \geq 3^{k-2} \cdot 2$ since each factor from $3$ to $k$ is $\geq 3$. ✓

So $\frac{1}{k!} \leq \frac{1}{2 \cdot 3^{k-2}}$ for all $k \geq 2$.

Therefore:

$$\sum_{k=2}^{\infty} \frac{(\lambda M)^{k-2}}{k!} \leq \sum_{k=2}^{\infty} \frac{(\lambda M)^{k-2}}{2 \cdot 3^{k-2}} = \frac{1}{2} \sum_{j=0}^{\infty} \left(\frac{\lambda M}{3}\right)^j.$$

For $\lambda M < 3$, this equals $\frac{1}{2} \cdot \frac{1}{1 - \lambda M/3}$.

So:

$$\mathbb{E}[e^{\lambda X}] \leq 1 + \frac{\lambda^2 \sigma^2}{2} \cdot \frac{1}{1 - \lambda M/3} \leq \exp\!\left(\frac{\lambda^2 \sigma^2/2}{1 - \lambda M/3}\right),$$

using $1 + x \leq e^x$.

**Step 5: Product bound.**

$$P(S > t) \leq \exp\!\left(-\lambda t + \frac{\lambda^2 V/2}{1 - \lambda M/3}\right), \quad \text{for } 0 < \lambda < 3/M.$$

**Step 6: Optimize over $\lambda$.**

We minimize $f(\lambda) = -\lambda t + \frac{\lambda^2 V/2}{1 - \lambda M/3}$.

Set $f'(\lambda) = 0$:

$$f'(\lambda) = -t + \frac{V}{2} \cdot \frac{2\lambda(1 - \lambda M/3) + \lambda^2 M/3}{(1 - \lambda M/3)^2} = -t + \frac{V\lambda(2 - \lambda M)}{2(1 - \lambda M/3)^2 \cdot 3/3}$$

This is getting complicated. Instead, let us substitute $\lambda = \frac{t}{V + Mt/3}$ and verify it gives the claimed bound.

**Substituting** $\lambda^* = \frac{t}{V + Mt/3}$:

First, check $\lambda^* < 3/M$: $\frac{t}{V + Mt/3} < \frac{3}{M}$ iff $Mt < 3V + Mt$, i.e., $3V > 0$. ✓ (assuming $V > 0$).

Compute $1 - \lambda^* M/3 = 1 - \frac{Mt/3}{V + Mt/3} = \frac{V}{V + Mt/3}$.

Compute $\frac{(\lambda^*)^2 V/2}{1 - \lambda^* M/3}$:

$$= \frac{V/2 \cdot t^2/(V + Mt/3)^2}{V/(V + Mt/3)} = \frac{t^2/2}{(V + Mt/3)^2} \cdot (V + Mt/3) = \frac{t^2/2}{V + Mt/3}.$$

So:

$$f(\lambda^*) = -\frac{t^2}{V + Mt/3} + \frac{t^2/2}{V + Mt/3} = -\frac{t^2/2}{V + Mt/3}.$$

Therefore:

$$P(S > t) \leq \exp\!\left(-\frac{t^2/2}{V + Mt/3}\right). \quad \blacksquare$$

## Summary

The proof uses: (1) Chernoff bound, (2) moment bound $|\mathbb{E}[X^k]| \leq \sigma^2 M^{k-2}$, (3) factorial inequality $k! \geq 2 \cdot 3^{k-2}$, (4) $1+x \leq e^x$, (5) specific choice of $\lambda$.
