# Route 3: Bennett's Function + Convexity Approach

## Theorem

Let $X_1, \ldots, X_n$ be independent random variables with $\mathbb{E}[X_i] = 0$ and $|X_i| \leq M$ a.s. Let $V = \sum_{i=1}^n \mathbb{E}[X_i^2]$. Then for all $t > 0$:

$$P\!\left(\sum_{i=1}^n X_i > t\right) \leq \exp\!\left(-\frac{t^2/2}{V + Mt/3}\right).$$

## Proof

Let $S = \sum_{i=1}^n X_i$ and $\sigma_i^2 = \mathbb{E}[X_i^2]$.

### Step 1: Chernoff Bound

As standard: for $\lambda > 0$,

$$P(S > t) \leq e^{-\lambda t} \prod_{i=1}^n \mathbb{E}[e^{\lambda X_i}]. \tag{1}$$

### Step 2: MGF via Convexity of $e^x$

Since $-M \leq X_i \leq M$ and $e^{\lambda x}$ is convex in $x$, we can write for any $x \in [-M, M]$:

$$e^{\lambda x} \leq \frac{M - x}{2M} e^{-\lambda M} + \frac{M + x}{2M} e^{\lambda M}.$$

Taking expectations and using $\mathbb{E}[X_i] = 0$:

$$\mathbb{E}[e^{\lambda X_i}] \leq \frac{1}{2} e^{-\lambda M} + \frac{1}{2} e^{\lambda M} = \cosh(\lambda M). \tag{2}$$

However, this gives Hoeffding's bound, not Bernstein's. We need to use variance information.

### Step 2 (Revised): Taylor Approach with Variance

Instead of convexity, expand $e^{\lambda X_i}$:

$$e^{\lambda X_i} = 1 + \lambda X_i + \sum_{k=2}^{\infty} \frac{(\lambda X_i)^k}{k!}.$$

Taking expectations:

$$\mathbb{E}[e^{\lambda X_i}] = 1 + \sum_{k=2}^{\infty} \frac{\lambda^k \mathbb{E}[X_i^k]}{k!}.$$

Now split even and odd terms. For $k \geq 2$, using $|X_i| \leq M$ and $\mathbb{E}[X_i^2] = \sigma_i^2$:

$$\mathbb{E}[X_i^k] \leq \mathbb{E}[|X_i|^k] \leq M^{k-2} \sigma_i^2.$$

(This works for all $k \geq 2$ since we also have $|\mathbb{E}[X_i^k]| \leq \mathbb{E}[|X_i|^k] \leq M^{k-2} \sigma_i^2$.)

But we need to be careful: the sum includes $\mathbb{E}[X_i^k]$, not $|\mathbb{E}[X_i^k]|$. However:

$$\sum_{k=2}^{\infty} \frac{\lambda^k \mathbb{E}[X_i^k]}{k!} \leq \sum_{k=2}^{\infty} \frac{\lambda^k |\mathbb{E}[X_i^k]|}{k!} \leq \sum_{k=2}^{\infty} \frac{\lambda^k M^{k-2} \sigma_i^2}{k!} = \frac{\lambda^2 \sigma_i^2}{M^2} \sum_{k=2}^{\infty} \frac{(\lambda M)^k}{k!} \cdot M^{-k} \cdot M^k$$

Wait, let me redo this more carefully. For $\lambda > 0$ and $k$ odd, $\mathbb{E}[X_i^k]$ could be negative. But since we want an upper bound:

$$\frac{\lambda^k \mathbb{E}[X_i^k]}{k!} \leq \frac{\lambda^k |\mathbb{E}[X_i^k]|}{k!} \leq \frac{\lambda^k M^{k-2} \sigma_i^2}{k!}.$$

So:

$$\mathbb{E}[e^{\lambda X_i}] \leq 1 + \sum_{k=2}^{\infty} \frac{\lambda^k M^{k-2} \sigma_i^2}{k!}.$$

This is identical to what Route 2 obtains. Then applying $k! \geq 2 \cdot 3^{k-2}$ and proceeding as in Route 2:

$$\mathbb{E}[e^{\lambda X_i}] \leq 1 + \frac{\lambda^2 \sigma_i^2/2}{1 - \lambda M/3} \leq \exp\!\left(\frac{\lambda^2 \sigma_i^2/2}{1 - \lambda M/3}\right).$$

### Steps 3-5: Same as Route 2

The product bound, substitution $\lambda^* = t/(V + Mt/3)$, and final computation are identical to Route 2, yielding:

$$P(S > t) \leq \exp\!\left(-\frac{t^2/2}{V + Mt/3}\right). \quad \blacksquare$$

## Assessment

This route attempted to use convexity of $e^x$ more directly but found that the pure convexity approach (Hoeffding-style) loses variance information. It necessarily falls back to the Taylor series method of Route 2. This route does not offer a genuinely different proof technique.
