# Tweedie's Formula for Gaussian Perturbation and Denoising Score Matching

## Proof

**Route**: Direct Computation + Bayes' Rule

---

### Setup and Notation

Let $p_{\text{data}}$ be a probability distribution on $\mathbb{R}^d$ with finite second moment: $\int \|y\|^2 \, p_{\text{data}}(y) \, dy < \infty$. Let $Y \sim p_{\text{data}}$, $\varepsilon \sim \mathcal{N}(0, I_d)$ independent, and $X = Y + \sigma\varepsilon$ for $\sigma > 0$.

The perturbed density is:
$$p_\sigma(x) = \int_{\mathbb{R}^d} p_{\text{data}}(y) \, \varphi_\sigma(x - y) \, dy$$
where $\varphi_\sigma(z) = (2\pi\sigma^2)^{-d/2} \exp\!\bigl(-\|z\|^2/(2\sigma^2)\bigr)$.

---

### Step 1: Strict Positivity of $p_\sigma(x)$

**Claim.** $p_\sigma(x) > 0$ for all $x \in \mathbb{R}^d$.

**Proof.** Since $p_{\text{data}}$ is a probability measure, there exists a measurable set $A$ with $\int_A p_{\text{data}}(y) \, dy > 0$. For every $x \in \mathbb{R}^d$ and every $y \in A$, the Gaussian density satisfies $\varphi_\sigma(x - y) > 0$. Therefore:
$$p_\sigma(x) \geq \int_A p_{\text{data}}(y) \, \varphi_\sigma(x-y) \, dy > 0. \quad \square$$

---

### Step 2: Differentiation Under the Integral Sign

**Claim.** $\nabla_x p_\sigma(x) = \int_{\mathbb{R}^d} p_{\text{data}}(y) \, \nabla_x \varphi_\sigma(x-y) \, dy$.

**Proof.** We verify the hypotheses of the Leibniz integral rule (dominated convergence form).

(a) For each $y$, $x \mapsto p_{\text{data}}(y) \, \varphi_\sigma(x-y)$ is differentiable since $\varphi_\sigma$ is $C^\infty$.

(b) We need an integrable dominating function. The partial derivative satisfies:
$$\left|\frac{\partial}{\partial x_j} \varphi_\sigma(x-y)\right| = \frac{|x_j - y_j|}{\sigma^2} \, \varphi_\sigma(x-y).$$

For $x'$ in a neighborhood of $x$, the standard Gaussian envelope argument gives a dominating function $g(y) \leq C_\sigma(1 + \|y\|) \exp(-c\|y\|^2)$ which satisfies $\int p_{\text{data}}(y) g(y) dy < \infty$ by the finite second moment assumption.

By the dominated convergence theorem, differentiation under the integral is justified. $\square$

---

### Step 3: Gaussian Score Identity

**Claim.** $\nabla_x \varphi_\sigma(x-y) = -\dfrac{x-y}{\sigma^2} \, \varphi_\sigma(x-y)$.

**Proof.** Direct computation:
$$\nabla_x \varphi_\sigma(x-y) = (2\pi\sigma^2)^{-d/2} \exp\!\left(-\frac{\|x-y\|^2}{2\sigma^2}\right) \cdot \left(-\frac{x-y}{\sigma^2}\right) = -\frac{x-y}{\sigma^2} \, \varphi_\sigma(x-y). \quad \square$$

---

### Step 4: Tweedie's Formula via Bayes' Rule

**Claim.** $\nabla_x \log p_\sigma(x) = \dfrac{\mathbb{E}[Y \mid X = x] - x}{\sigma^2}$.

**Proof.** Combining Steps 2 and 3:
$$\nabla_x p_\sigma(x) = \int p_{\text{data}}(y) \left(-\frac{x-y}{\sigma^2}\right) \varphi_\sigma(x-y) \, dy = -\frac{x}{\sigma^2} p_\sigma(x) + \frac{1}{\sigma^2} \int y \, p_{\text{data}}(y) \, \varphi_\sigma(x-y) \, dy.$$

The posterior density of $Y$ given $X = x$ is $p(y \mid x) = p_{\text{data}}(y) \varphi_\sigma(x-y) / p_\sigma(x)$, so:
$$\int y \, p_{\text{data}}(y) \, \varphi_\sigma(x-y) \, dy = p_\sigma(x) \cdot \mathbb{E}[Y \mid X = x].$$

Dividing by $p_\sigma(x) > 0$:
$$\nabla_x \log p_\sigma(x) = \frac{\mathbb{E}[Y \mid X = x] - x}{\sigma^2}. \quad \square$$

---

### Step 5: Equivalent Noise Form

**Claim.** $\nabla_x \log p_\sigma(x) = -\dfrac{1}{\sigma} \, \mathbb{E}[\varepsilon \mid X = x]$.

**Proof.** Since $Y = X - \sigma\varepsilon$:
$$\mathbb{E}[Y \mid X = x] = x - \sigma \, \mathbb{E}[\varepsilon \mid X = x].$$

Substituting into Step 4:
$$\nabla_x \log p_\sigma(x) = \frac{-\sigma \, \mathbb{E}[\varepsilon \mid X = x]}{\sigma^2} = -\frac{1}{\sigma} \, \mathbb{E}[\varepsilon \mid X = x]. \quad \square$$

---

### Step 6: Denoising Score Matching Equivalence

**Claim.** The loss $L(\theta) = \mathbb{E}_{Y, \varepsilon}\!\left[\left\|s_\theta(Y + \sigma\varepsilon) + \frac{\varepsilon}{\sigma}\right\|^2\right]$ is minimized by $s_\theta(x) = \nabla_x \log p_\sigma(x)$.

**Proof.** Let $X = Y + \sigma\varepsilon$. By the tower property, conditioning on $X$:

$$L(\theta) = \mathbb{E}_X\!\left[\|s_\theta(X)\|^2 + \frac{2}{\sigma}\langle s_\theta(X), \mathbb{E}[\varepsilon|X]\rangle + \frac{1}{\sigma^2}\mathbb{E}[\|\varepsilon\|^2|X]\right].$$

By Step 5, $\mathbb{E}[\varepsilon|X=x] = -\sigma \nabla_x \log p_\sigma(x)$. Substituting and completing the square:

$$L(\theta) = \mathbb{E}_X\!\left[\|s_\theta(X) - \nabla_X \log p_\sigma(X)\|^2\right] + C$$

where $C = \mathbb{E}_X\!\left[\frac{1}{\sigma^2}\mathbb{E}[\|\varepsilon\|^2|X] - \|\nabla \log p_\sigma(X)\|^2\right]$ is independent of $\theta$.

The first term is the Fisher divergence, minimized (at zero) iff $s_\theta = \nabla \log p_\sigma$ $p_\sigma$-a.e.

$$\boxed{s_\theta^*(x) = \nabla_x \log p_\sigma(x) = \frac{\mathbb{E}[Y|X=x] - x}{\sigma^2} = -\frac{1}{\sigma}\mathbb{E}[\varepsilon|X=x]}$$

$$\tag*{Q.E.D.}$$
