# LASSO Prediction Error under Restricted Eigenvalue Condition

## Source
- Paper: Bickel, Ritov, Tsybakov (2009), "Simultaneous analysis of Lasso and Dantzig selector", Annals of Statistics
- Extended: Negahban, Ravikumar, Wainwright, Yu (2012), "A Unified Framework for High-Dimensional Analysis of M-Estimators with Decomposable Regularizers", Statistical Science
- Context: Foundational result in high-dimensional sparse estimation theory

## Statement

Consider the linear model $y = X\beta^* + w$ where:
- $X \in \mathbb{R}^{n \times p}$ is the design matrix with $p \gg n$
- $\beta^* \in \mathbb{R}^p$ is $s$-sparse (at most $s$ nonzero entries), with support $S = \mathrm{supp}(\beta^*)$, $|S| = s$
- $w \in \mathbb{R}^n$ has i.i.d. entries $w_i \sim \mathcal{N}(0, \sigma^2)$

The LASSO estimator is:
$$\hat{\beta} = \arg\min_{\beta \in \mathbb{R}^p} \left\{ \frac{1}{2n} \|y - X\beta\|_2^2 + \lambda \|\beta\|_1 \right\}$$

**Restricted Eigenvalue (RE) Condition**: The matrix $X$ satisfies $\mathrm{RE}(s, 3)$ if there exists $\kappa > 0$ such that:
$$\frac{1}{n}\|X\Delta\|_2^2 \geq \kappa \|\Delta\|_2^2 \quad \text{for all } \Delta \in \mathcal{C}(S, 3)$$
where the cone $\mathcal{C}(S, c_0) = \{\Delta \in \mathbb{R}^p : \|\Delta_{S^c}\|_1 \leq c_0 \|\Delta_S\|_1\}$.

**Theorem**: Suppose $X$ satisfies $\mathrm{RE}(s, 3)$ with constant $\kappa > 0$. Set $\lambda = 2\sigma\sqrt{\frac{2\log p}{n}}$. Then with probability at least $1 - 2p^{-1}$:

1. **Prediction error**:
$$\frac{1}{n}\|X(\hat{\beta} - \beta^*)\|_2^2 \leq \frac{16\sigma^2 s \log p}{\kappa n}$$

2. **Estimation error** ($\ell_2$):
$$\|\hat{\beta} - \beta^*\|_2 \leq \frac{4\sigma}{\kappa}\sqrt{\frac{2s\log p}{n}}$$

3. **Estimation error** ($\ell_1$):
$$\|\hat{\beta} - \beta^*\|_1 \leq \frac{4\sigma s}{\kappa}\sqrt{\frac{2\log p}{n}}$$

## Difficulty
research

## Key Intermediate Results to Prove

1. **Basic inequality**: Show that the LASSO optimality implies $\frac{1}{2n}\|X\hat{\Delta}\|_2^2 \leq \frac{1}{n}\langle X^T w, \hat{\Delta}\rangle + \lambda(\|\beta^*\|_1 - \|\hat{\beta}\|_1)$ where $\hat{\Delta} = \hat{\beta} - \beta^*$.

2. **Cone constraint**: Show that when $\lambda \geq \frac{2}{n}\|X^T w\|_\infty$, the error $\hat{\Delta}$ lies in the restricted cone $\mathcal{C}(S, 3)$, i.e., $\|\hat{\Delta}_{S^c}\|_1 \leq 3\|\hat{\Delta}_S\|_1$.

3. **Sub-Gaussian maximal inequality**: Show that $\frac{1}{n}\|X^T w\|_\infty \leq \sigma\sqrt{\frac{2\log p}{n}}$ with probability at least $1 - 2p^{-1}$, justifying the choice of $\lambda$.

4. **RE to bound**: Apply the RE condition on the cone to convert $\frac{1}{n}\|X\hat{\Delta}\|_2^2 \geq \kappa\|\hat{\Delta}\|_2^2$ and close the bound.

5. **$\ell_1$/$\ell_2$ conversion**: Use Cauchy-Schwarz on the support to convert between $\ell_1$ and $\ell_2$ bounds: $\|\hat{\Delta}_S\|_1 \leq \sqrt{s}\|\hat{\Delta}_S\|_2$.
