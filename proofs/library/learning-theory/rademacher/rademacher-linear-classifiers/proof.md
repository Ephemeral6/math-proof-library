# Proof: Rademacher Complexity of Linear Classifiers

## Setup

Let $S = \{x_1, \ldots, x_n\} \subset \mathbb{R}^d$ be a fixed sample, $\sigma_1, \ldots, \sigma_n$ i.i.d. Rademacher random variables, and $\mathcal{F}_B = \{x \mapsto \langle w, x \rangle : \|w\|_2 \leq B\}$. The empirical Rademacher complexity is:

$$\hat{\mathfrak{R}}_n(\mathcal{F}_B) = \frac{1}{n} \mathbb{E}_\sigma \left[\sup_{f \in \mathcal{F}_B} \sum_{i=1}^n \sigma_i f(x_i)\right]$$

## Part 1: Exact Expression

**Step 1.** Substitute the parametric form:

$$\hat{\mathfrak{R}}_n(\mathcal{F}_B) = \frac{1}{n} \mathbb{E}_\sigma \left[\sup_{\|w\| \leq B} \sum_{i=1}^n \sigma_i \langle w, x_i \rangle \right]$$

**Step 2.** By bilinearity of the inner product:

$$\sum_{i=1}^n \sigma_i \langle w, x_i \rangle = \left\langle w, \sum_{i=1}^n \sigma_i x_i \right\rangle$$

**Step 3.** Define $z = \sum_{i=1}^n \sigma_i x_i$. Compute the supremum $\sup_{\|w\| \leq B} \langle w, z \rangle$:

- **Upper bound**: By Cauchy-Schwarz, $\langle w, z \rangle \leq \|w\| \cdot \|z\| \leq B\|z\|$.
- **Attainment**: If $z \neq 0$, set $w^* = Bz/\|z\|$. Then $\|w^*\| = B$ and $\langle w^*, z \rangle = B\|z\|$. If $z = 0$, the supremum is $0 = B\|z\|$.

Therefore $\sup_{\|w\| \leq B} \langle w, z \rangle = B\|z\|$.

**Step 4.** Conclude:

$$\hat{\mathfrak{R}}_n(\mathcal{F}_B) = \frac{1}{n} \mathbb{E}_\sigma \left[B \left\|\sum_{i=1}^n \sigma_i x_i\right\|\right] = \frac{B}{n} \mathbb{E}_\sigma \left[\left\|\sum_{i=1}^n \sigma_i x_i\right\|\right] \qquad \blacksquare$$

## Part 2: Upper Bound

**Step 5.** Apply Jensen's inequality. Since $\varphi(t) = \sqrt{t}$ is concave on $[0, \infty)$:

$$\mathbb{E}\left[\left\|\sum_{i=1}^n \sigma_i x_i\right\|\right] = \mathbb{E}\left[\sqrt{\left\|\sum_{i=1}^n \sigma_i x_i\right\|^2}\right] \leq \sqrt{\mathbb{E}\left[\left\|\sum_{i=1}^n \sigma_i x_i\right\|^2\right]}$$

**Step 6.** Expand the second moment:

$$\mathbb{E}\left[\left\|\sum_{i=1}^n \sigma_i x_i\right\|^2\right] = \sum_{i=1}^n \sum_{j=1}^n \mathbb{E}[\sigma_i \sigma_j] \langle x_i, x_j \rangle$$

Since $\sigma_1, \ldots, \sigma_n$ are independent with $\mathbb{E}[\sigma_i] = 0$ and $\mathbb{E}[\sigma_i^2] = 1$:

$$\mathbb{E}[\sigma_i \sigma_j] = \delta_{ij} \implies \mathbb{E}\left[\left\|\sum_{i=1}^n \sigma_i x_i\right\|^2\right] = \sum_{i=1}^n \|x_i\|^2$$

**Step 7.** Connect to the empirical covariance. With $\hat{\Sigma} = \frac{1}{n}\sum_{i=1}^n x_i x_i^\top$:

$$\mathrm{tr}(\hat{\Sigma}) = \frac{1}{n}\sum_{i=1}^n \mathrm{tr}(x_i x_i^\top) = \frac{1}{n}\sum_{i=1}^n \|x_i\|^2$$

Hence $\sum_{i=1}^n \|x_i\|^2 = n \cdot \mathrm{tr}(\hat{\Sigma})$.

**Step 8.** Combine:

$$\hat{\mathfrak{R}}_n(\mathcal{F}_B) = \frac{B}{n}\mathbb{E}\left[\left\|\sum_{i=1}^n \sigma_i x_i\right\|\right] \leq \frac{B}{n}\sqrt{n \cdot \mathrm{tr}(\hat{\Sigma})} = \frac{B\sqrt{\mathrm{tr}(\hat{\Sigma})}}{\sqrt{n}} \qquad \blacksquare$$
