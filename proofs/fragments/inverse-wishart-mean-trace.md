# Fragment: inverse-wishart-mean-trace

## Statement
Let $W \sim W_d(n, I_d)$ denote a $d$-dimensional Wishart matrix with $n$ degrees of freedom and identity scale (i.e., $W = Z^\top Z$ where $Z \in \mathbb{R}^{n \times d}$ has i.i.d. $\mathcal{N}(0, 1)$ entries). For $n > d + 1$:
$$\mathbb{E}[W^{-1}] \;=\; \frac{1}{n - d - 1}\, I_d, \qquad \mathbb{E}[\mathrm{tr}(W^{-1})] \;=\; \frac{d}{n - d - 1}.$$

## Proof (sketch)
The inverse $S := W^{-1}$ has the inverse-Wishart distribution $\mathrm{IW}_d(n, I_d)$ with density $p(S) \propto |S|^{-(n+d+1)/2} e^{-\mathrm{tr}(S^{-1})/2}$. The mean of $S$ under this distribution is $I_d/(n - d - 1)$, derivable from:
1. Right-rotation invariance: $W \overset{d}{=} Q^\top W Q$ for any $Q \in O(d)$, so $\mathbb{E}[W^{-1}] = c I_d$.
2. The trace constant $cd = \mathbb{E}[\mathrm{tr}(W^{-1})]$ is computed via the normalizing constant of the inverse-Wishart density (or by integration in eigenvalue coordinates against the joint Wishart eigenvalue density).
The classical evaluation gives $c = 1/(n - d - 1)$. $\square$

## Source
- `proofs/research/statistics/high-dimensional/double-descent-interpolation-threshold/proof.md` — Step 2 (variance computation).

## Status
- **Correctness**: VERIFIED (classical result; cited textbook formula)
- **Used in final proof**: YES (gives the variance term that explains the $\sigma^2/(\gamma - 1)$ blow-up)
- **Potential applications**:
  - Variance of OLS estimator in linear regression
  - Variance of min-norm interpolator (overparameterized regime)
  - Random matrix theory: trace of inverse Wishart
  - Bayesian linear regression with conjugate normal-inverse-Wishart prior
  - Ridge/ridgeless regression risk computation

## Tags
wishart, inverse-wishart, random-matrix, trace, double-descent, regression
