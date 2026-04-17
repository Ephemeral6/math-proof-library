# Double Descent — Interpolation Threshold Phenomenon

## Proof via Direct Bias-Variance Decomposition + Wishart Inverse Moments

**Setup.** Write $X = Z/\sqrt{d}$ where $Z \in \mathbb{R}^{n \times d}$ has i.i.d. $\mathcal{N}(0,1)$ entries. The model is $y = X\beta^* + \epsilon$ with $\epsilon \sim \mathcal{N}(0, \sigma^2 I_n)$. The prediction risk for a new test point $x_{\text{new}} \sim \mathcal{N}(0, I_d/d)$ is:

$$R(\hat\beta) = \mathbb{E}[(x_{\text{new}}^T(\hat\beta - \beta^*))^2] = \frac{1}{d}\mathbb{E}\|\hat\beta - \beta^*\|^2$$

---

## Step 1: Bias-Variance Decomposition

Since $y = X\beta^* + \epsilon$ and $\hat\beta = X^+y$:

$$\hat\beta - \beta^* = (X^+X - I_d)\beta^* + X^+\epsilon$$

The matrix $P = X^+X$ is the orthogonal projection onto the row space of $X$, so $(X^+X - I_d)\beta^* = -(I_d - P)\beta^*$ lies in $\ker(X)$, while $X^+\epsilon$ lies in $\text{row}(X)$. These terms are orthogonal, giving:

$$\mathbb{E}\|\hat\beta - \beta^*\|^2 = \underbrace{\mathbb{E}\|(I_d - X^+X)\beta^*\|^2}_{\text{Bias}^2} + \underbrace{\sigma^2 \mathbb{E}[\text{tr}((X^TX)^+)]}_{\text{Variance}}$$

where we used $\mathbb{E}[\|X^+\epsilon\|^2 | X] = \sigma^2 \text{tr}(X^+(X^+)^T) = \sigma^2 \text{tr}((X^TX)^+)$.

---

## Step 2: Underparameterized Case ($\gamma < 1$, i.e., $d < n$)

When $d < n$, $X$ has rank $d$ a.s. (continuous distribution), so $X^+X = I_d$ and the **bias is zero**.

**Variance computation.** Since $X^TX = Z^TZ/d$, we have $(X^TX)^{-1} = d(Z^TZ)^{-1}$, and:

$$\text{tr}((X^TX)^{-1}) = d \cdot \text{tr}((Z^TZ)^{-1})$$

The matrix $Z^TZ \sim W_d(n, I_d)$ is a $d$-dimensional Wishart matrix with $n$ degrees of freedom. By the **inverse Wishart moment formula** (valid for $n > d + 1$):

$$\mathbb{E}[(Z^TZ)^{-1}] = \frac{1}{n - d - 1} I_d$$

**Proof of this classical result:** The density of $W \sim W_d(n, I_d)$ is $p(W) \propto |W|^{(n-d-1)/2} e^{-\text{tr}(W)/2}$. The inverse $S = W^{-1}$ has the inverse Wishart distribution $\text{IW}_d(n, I_d)$ with density $p(S) \propto |S|^{-(n+d+1)/2} e^{-\text{tr}(S^{-1})/2}$. The mean of $S$ under this distribution is $\mathbb{E}[S] = \frac{I_d}{n - d - 1}$ for $n > d + 1$, which follows from the normalizing constant of the inverse Wishart.

Therefore:

$$\mathbb{E}[\text{tr}((Z^TZ)^{-1})] = \frac{d}{n - d - 1}$$

The risk is:

$$R = \frac{1}{d} \cdot \sigma^2 \cdot d \cdot \frac{d}{n - d - 1} = \frac{\sigma^2 d}{n - d - 1}$$

Taking $n, d \to \infty$ with $d/n \to \gamma < 1$:

$$\frac{d}{n - d - 1} = \frac{d/n}{1 - d/n - 1/n} \to \frac{\gamma}{1 - \gamma}$$

$$\boxed{R(\hat\beta) \to \frac{\sigma^2 \gamma}{1 - \gamma}} \quad (\gamma < 1)$$

---

## Step 3: Overparameterized Case ($\gamma > 1$, i.e., $d > n$)

When $d > n$, $X$ has rank $n$ a.s., and $X^+ = X^T(XX^T)^{-1}$.

### Variance term

The nonzero eigenvalues of $X^TX$ coincide with the eigenvalues of $XX^T$. Since $XX^T = ZZ^T/d$:

$$(XX^T)^{-1} = d(ZZ^T)^{-1}$$

The matrix $ZZ^T \sim W_n(d, I_n)$ is an $n$-dimensional Wishart with $d$ degrees of freedom. For $d > n + 1$:

$$\mathbb{E}[(ZZ^T)^{-1}] = \frac{1}{d - n - 1} I_n$$

$$\mathbb{E}[\text{tr}((ZZ^T)^{-1})] = \frac{n}{d - n - 1}$$

Since $\text{tr}((X^TX)^+) = \text{tr}((XX^T)^{-1}) = d \cdot \frac{n}{d - n - 1}$:

$$\frac{1}{d} \cdot \sigma^2 \cdot d \cdot \frac{n}{d - n - 1} = \frac{\sigma^2 n}{d - n - 1}$$

Taking $d/n \to \gamma > 1$:

$$\frac{n}{d - n - 1} = \frac{1}{d/n - 1 - 1/n} \to \frac{1}{\gamma - 1}$$

$$\text{Variance} \to \frac{\sigma^2}{\gamma - 1}$$

### Bias term

$I_d - X^+X = I_d - P_X$ is the orthogonal projection onto $\ker(X)$, which has dimension $d - n$.

**Claim:** $\mathbb{E}[I_d - P_X] = \frac{d - n}{d} I_d$.

**Proof:** The distribution of $X$ (equivalently $Z$) is invariant under right-multiplication by any orthogonal matrix $Q \in O(d)$: since $Z$ has i.i.d. $\mathcal{N}(0,1)$ entries, $ZQ \stackrel{d}{=} Z$. This means $P_{XQ} \stackrel{d}{=} P_X$, but $P_{XQ} = Q^T P_X Q$. Hence $\mathbb{E}[P_X] = Q^T \mathbb{E}[P_X] Q$ for all $Q \in O(d)$, which forces $\mathbb{E}[P_X] = c I_d$ for some scalar $c$. Taking traces: $cd = \mathbb{E}[\text{tr}(P_X)] = \mathbb{E}[\text{rank}(X)] = n$, so $c = n/d$ and $\mathbb{E}[I_d - P_X] = \frac{d-n}{d} I_d$. $\square$

Therefore:

$$\mathbb{E}\|(I_d - P_X)\beta^*\|^2 = \beta^{*T} \mathbb{E}[I_d - P_X] \beta^* = \frac{d - n}{d} \|\beta^*\|^2$$

The bias contribution to risk:

$$\frac{1}{d} \cdot \frac{d - n}{d} \|\beta^*\|^2 = \frac{d - n}{d^2} \|\beta^*\|^2$$

In the proportional limit with $\|\beta^*\|^2/d \to b^2$ (normalized signal strength):

$$\text{Bias} \to \frac{\gamma - 1}{\gamma} b^2$$

**Total overparameterized risk:**

$$\boxed{R(\hat\beta) \to \frac{\sigma^2}{\gamma - 1} + \frac{\gamma - 1}{\gamma} b^2} \quad (\gamma > 1)$$

where $b^2 = \lim_{d \to \infty} \|\beta^*\|^2/d$.

**Remark on the problem statement:** The problem states the bias as $|\beta^*|^2/(\gamma - 1)$. The mathematically correct bias from the Haar invariance calculation is $(\gamma-1)/\gamma \cdot b^2$. These differ: $(\gamma-1)/\gamma$ is bounded and vanishes at $\gamma = 1$, while $1/(\gamma-1)$ diverges. The variance term $\sigma^2/(\gamma-1)$ is the sole source of divergence in the overparameterized regime near $\gamma = 1$.

---

## Step 4: Divergence at $\gamma = 1$ (Interpolation Threshold)

**From the underparameterized side ($\gamma \nearrow 1$):**

$$R = \frac{\sigma^2 d}{n - d - 1}$$

The denominator $n - d - 1 \to 0^+$ as $d/n \to 1^-$, so $R \to +\infty$.

**From the overparameterized side ($\gamma \searrow 1$):**

$$R \geq \frac{\sigma^2 n}{d - n - 1}$$

The denominator $d - n - 1 \to 0^+$ as $d/n \to 1^+$, so $R \to +\infty$.

**Physical interpretation:** At $\gamma = 1$, the system is exactly determined ($d = n$). The matrix $X^TX = Z^TZ/d$ is square and its smallest eigenvalue approaches zero (the Marchenko-Pastur law at $\gamma = 1$ has support $[0, 4]$). The pseudoinverse amplifies noise in the direction of the smallest singular values without bound, causing the risk to diverge.

$$\boxed{\lim_{\gamma \to 1} R(\hat\beta) = +\infty}$$

This divergence at the interpolation threshold is the **double descent peak**. $\blacksquare$
