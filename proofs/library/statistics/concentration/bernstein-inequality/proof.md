# Proof of Bernstein's Inequality

## Theorem

Let $X_1, \ldots, X_n$ be independent random variables with $\mathbb{E}[X_i] = 0$ and $|X_i| \leq M$ a.s. for all $i$. Let $V = \sum_{i=1}^n \mathbb{E}[X_i^2]$. Then for all $t > 0$,

$$P\!\left(\sum_{i=1}^n X_i > t\right) \leq \exp\!\left(-\frac{t^2/2}{V + Mt/3}\right).$$

## Proof

Let $S = \sum_{i=1}^n X_i$ and write $\sigma_i^2 = \mathbb{E}[X_i^2]$.

### Step 1: Chernoff Bound

For any $\lambda > 0$, by Markov's inequality:

$$P(S > t) \leq e^{-\lambda t} \mathbb{E}[e^{\lambda S}] = e^{-\lambda t} \prod_{i=1}^n \mathbb{E}[e^{\lambda X_i}], \tag{1}$$

where the product factorization uses independence.

### Step 2: Moment Bound

For $k \geq 2$, since $|X_i| \leq M$ and $\mathbb{E}[X_i^2] = \sigma_i^2$:

$$|\mathbb{E}[X_i^k]| \leq \mathbb{E}[|X_i|^k] = \mathbb{E}[|X_i|^2 \cdot |X_i|^{k-2}] \leq M^{k-2} \sigma_i^2. \tag{2}$$

### Step 3: MGF Bound for Individual Variables

Using the Taylor expansion $e^{\lambda X_i} = 1 + \lambda X_i + \sum_{k=2}^{\infty} \frac{(\lambda X_i)^k}{k!}$ and $\mathbb{E}[X_i] = 0$:

$$\mathbb{E}[e^{\lambda X_i}] = 1 + \sum_{k=2}^{\infty} \frac{\lambda^k \mathbb{E}[X_i^k]}{k!}.$$

Since $\lambda > 0$ and $\frac{\lambda^k \mathbb{E}[X_i^k]}{k!} \leq \frac{\lambda^k |\mathbb{E}[X_i^k]|}{k!}$, applying (2):

$$\mathbb{E}[e^{\lambda X_i}] \leq 1 + \sum_{k=2}^{\infty} \frac{\lambda^k \sigma_i^2 M^{k-2}}{k!} = 1 + \lambda^2 \sigma_i^2 \sum_{k=2}^{\infty} \frac{(\lambda M)^{k-2}}{k!}. \tag{3}$$

### Step 4: Key Factorial Inequality

**Claim.** For all integers $k \geq 2$: $k! \geq 2 \cdot 3^{k-2}$.

*Proof by induction.*
- Base case $k = 2$: $2! = 2 = 2 \cdot 3^0$. ✓
- Inductive step: Assume $k! \geq 2 \cdot 3^{k-2}$ for some $k \geq 2$. Then $(k+1)! = (k+1) \cdot k! \geq (k+1) \cdot 2 \cdot 3^{k-2} \geq 3 \cdot 2 \cdot 3^{k-2} = 2 \cdot 3^{k-1}$, using $k + 1 \geq 3$. $\square$

### Step 5: Geometric Series Bound

Applying $k! \geq 2 \cdot 3^{k-2}$ to (3), for $0 < \lambda < 3/M$:

$$\sum_{k=2}^{\infty} \frac{(\lambda M)^{k-2}}{k!} \leq \sum_{k=2}^{\infty} \frac{(\lambda M)^{k-2}}{2 \cdot 3^{k-2}} = \frac{1}{2} \sum_{j=0}^{\infty} \left(\frac{\lambda M}{3}\right)^j = \frac{1}{2(1 - \lambda M/3)}.$$

Substituting back:

$$\mathbb{E}[e^{\lambda X_i}] \leq 1 + \frac{\lambda^2 \sigma_i^2 / 2}{1 - \lambda M/3}. \tag{4}$$

### Step 6: Exponentiation

Since $1 + x \leq e^x$ for all $x \in \mathbb{R}$:

$$\mathbb{E}[e^{\lambda X_i}] \leq \exp\!\left(\frac{\lambda^2 \sigma_i^2 / 2}{1 - \lambda M/3}\right). \tag{5}$$

### Step 7: Product Bound

Taking the product over $i = 1, \ldots, n$ and combining with (1):

$$P(S > t) \leq \exp\!\left(-\lambda t + \frac{\lambda^2 V / 2}{1 - \lambda M/3}\right), \quad 0 < \lambda < \frac{3}{M}. \tag{6}$$

### Step 8: Choosing $\lambda$

Set $\lambda^* = \dfrac{t}{V + Mt/3}$.

**Validity:** $\lambda^* > 0$ since $t > 0$. Also $\lambda^* < 3/M$ since $V > 0$ implies $V + Mt/3 > Mt/3$.

**Computation:**

$$1 - \frac{\lambda^* M}{3} = 1 - \frac{Mt/3}{V + Mt/3} = \frac{V}{V + Mt/3}. \tag{7}$$

$$\frac{(\lambda^*)^2 V/2}{1 - \lambda^* M/3} = \frac{t^2 V/2}{(V + Mt/3)^2} \cdot \frac{V + Mt/3}{V} = \frac{t^2}{2(V + Mt/3)}. \tag{8}$$

$$-\lambda^* t + \frac{(\lambda^*)^2 V/2}{1 - \lambda^* M/3} = -\frac{t^2}{V + Mt/3} + \frac{t^2}{2(V + Mt/3)} = -\frac{t^2}{2(V + Mt/3)}. \tag{9}$$

### Step 9: Conclusion

Substituting (9) into (6):

$$\boxed{P\!\left(\sum_{i=1}^n X_i > t\right) \leq \exp\!\left(-\frac{t^2/2}{V + Mt/3}\right).} \quad \blacksquare$$
