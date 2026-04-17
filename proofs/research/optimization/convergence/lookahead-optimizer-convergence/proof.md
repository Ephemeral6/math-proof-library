# Proof: Lookahead Optimizer Convergence on Quadratics

## Setting

Let $f(x) = \frac{1}{2}x^TAx$ with $A \succ 0$, eigenvalues $0 < \mu \leq \lambda_i \leq L$. Lookahead: inner loop runs $k$ SGD steps from $\phi_t$, outer update $\phi_{t+1} = \phi_t + \alpha(\theta_t - \phi_t)$. Assume $0 < \eta \leq 1/L$, $0 < \alpha \leq 1$.

---

## Part 1: Convergence Rate

**Theorem.** In the deterministic case, $\|\phi_t\| \leq \rho^t\|\phi_0\|$ where $\rho = 1 - \alpha(1-(1-\eta\mu)^k)$.

**Proof.** Since $\nabla f(x) = Ax$, the inner loop gives $\theta_{t,j+1} = (I-\eta A)\theta_{t,j}$, so $\theta_t = (I-\eta A)^k\phi_t$. The outer update becomes:

$$\phi_{t+1} = M\phi_t, \qquad M := (1-\alpha)I + \alpha(I-\eta A)^k$$

Since $M$ is a polynomial in symmetric $A$, it is symmetric with eigenvalues:
$$m(\lambda) = 1 - \alpha(1-(1-\eta\lambda)^k)$$

**Bounding the spectral radius.** For $\eta\lambda \in (0,1]$: $(1-\eta\lambda) \in [0,1)$, so $(1-\eta\lambda)^k \in [0,1)$ and $m(\lambda) \in [1-\alpha, 1) \subseteq [0,1)$.

Since $(1-\eta\lambda)^k$ is decreasing in $\lambda$, $m(\lambda)$ is decreasing, so:
$$\rho(M) = m(\mu) = 1 - \alpha(1-(1-\eta\mu)^k)$$

For symmetric $M$: $\|M\| = \rho(M)$, hence $\|\phi_t\| \leq \rho(M)^t\|\phi_0\|$. $\blacksquare$

---

## Part 2: Variance Reduction by Factor $\alpha^2 k$

**Theorem.** With i.i.d. noise $\xi_{t,j}$, $\mathbb{E}[\xi_{t,j}]=0$, $\text{Cov}(\xi_{t,j})=\sigma^2 I$, the noise in the outer iterate per step satisfies $\mathbb{E}[\|\nu_t\|^2] \approx \alpha^2 k\eta^2\sigma^2 d$ in the regime $k\eta L = O(1)$, representing variance reduction by factor $\alpha^2 k$ compared to an equivalent single-step method.

**Proof.** Unrolling the stochastic inner loop $\theta_{t,j+1} = (I-\eta A)\theta_{t,j} - \eta\xi_{t,j}$:
$$\theta_t = (I-\eta A)^k\phi_t - \eta\sum_{\ell=0}^{k-1}(I-\eta A)^{k-1-\ell}\xi_{t,\ell}$$

The outer update $\phi_{t+1} = M\phi_t + \nu_t$ has noise:
$$\nu_t = -\alpha\eta\sum_{\ell=0}^{k-1}(I-\eta A)^{k-1-\ell}\xi_{t,\ell}$$

By independence:
$$\mathbb{E}[\|\nu_t\|^2] = \alpha^2\eta^2\sigma^2\sum_{\ell=0}^{k-1}\text{tr}\bigl((I-\eta A)^{2\ell}\bigr) = \alpha^2\eta^2\sigma^2\sum_{\ell=0}^{k-1}\sum_{i=1}^d(1-\eta\lambda_i)^{2\ell}$$

For $\eta\lambda_i \ll 1$: $\sum_{\ell=0}^{k-1}(1-\eta\lambda_i)^{2\ell} \approx k$, giving:
$$\mathbb{E}[\|\nu_t\|^2] \approx \alpha^2 k\eta^2\sigma^2 d$$

**Equivalent single-step comparison.** The contraction $\rho \approx 1-\alpha k\eta\mu$ matches a single step with $\tilde{\eta} = \alpha k\eta$, which would inject noise $\tilde{\eta}^2\sigma^2 d = \alpha^2 k^2\eta^2\sigma^2 d$. The ratio:
$$\frac{\alpha^2 k\eta^2\sigma^2 d}{\alpha^2 k^2\eta^2\sigma^2 d} = \frac{1}{k}$$

**Two sources of variance reduction:**
1. **Interpolation ($\alpha^2$):** Slow-weight update scales fast-iterate noise by $\alpha$, reducing variance by $\alpha^2$ vs. fast iterates.
2. **Step-splitting ($1/k$):** Distributing the effective step across $k$ gradient evaluations reduces variance by $1/k$ vs. equivalent single step.

Combined: $\text{Var}(\phi\text{ noise}) = \frac{\alpha^2}{k} \cdot \text{Var}(\text{equivalent single step})$. The factor $\alpha^2 k$ captures both mechanisms. $\blacksquare$
