# Notes: Double Descent — Interpolation Threshold

## Proof technique
Route 3 (Direct Bias-Variance Decomposition + Wishart Inverse Moments) won. This approach uses exact finite-sample Wishart inverse moment formulas rather than Marchenko-Pastur asymptotics, making the argument more elementary and self-contained.

## Key steps
1. **Bias-variance decomposition** via pseudoinverse: $\hat\beta - \beta^* = -(I-X^+X)\beta^* + X^+\epsilon$, with orthogonality of bias and variance terms.
2. **Inverse Wishart moments**: $\mathbb{E}[(Z^TZ)^{-1}] = \frac{1}{n-d-1}I_d$ for $Z^TZ \sim W_d(n,I_d)$, applied to both the $d\times d$ Gram matrix (underparameterized) and the $n\times n$ Gram matrix (overparameterized).
3. **Haar invariance for bias**: Rotational invariance of Gaussian $X$ implies $\mathbb{E}[P_{X^\perp}] = \frac{d-n}{d}I_d$.
4. **Divergence mechanism**: The Wishart inverse moment $d/(n-d-1)$ diverges as $n \to d$, corresponding to the smallest eigenvalue of $X^TX$ approaching zero at the interpolation threshold.

## Audit result
PASS on first round. All 4 steps validated. Only presentation-level issues found (implicit idempotency, implicit independence assumption).

## Related results
- Marchenko-Pastur law provides the spectral mechanism for the divergence
- The result generalizes to non-isotropic covariance (Hastie, Montanari, Rosset, Tibshirani 2022)
- The bias formula $(\gamma-1)/\gamma \cdot b^2$ differs from the common (but incorrect) folklore formula $b^2/(\gamma-1)$

## Correction to problem statement
The original problem stated the overparameterized bias as $|\beta^*|^2 \cdot 1/(\gamma-1)$. All three independent proof routes confirm the correct bias is $(\gamma-1)/\gamma \cdot b^2$ where $b^2 = \|\beta^*\|^2/d$. The key difference: the correct bias vanishes at $\gamma = 1$ and increases monotonically, while the incorrect formula diverges at $\gamma = 1$.
