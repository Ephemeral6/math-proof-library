# Fragment: bias-variance-projection-min-norm

## Statement
Let $X \in \mathbb{R}^{n \times d}$ have full column rank if $d \le n$, full row rank if $d > n$, and let $\hat\beta = X^+ y$ be the **minimum-norm pseudoinverse** estimator with $y = X\beta^* + \epsilon$, $\epsilon \sim (0, \sigma^2 I_n)$. Define $P_{\mathrm{row}} := X^+ X$ (orthogonal projection onto the row space of $X$). Then the estimation error decomposes orthogonally as:
$$\hat\beta - \beta^* \;=\; \underbrace{-(I_d - P_{\mathrm{row}})\beta^*}_{\text{lies in } \ker(X)} \;+\; \underbrace{X^+ \epsilon}_{\text{lies in } \mathrm{row}(X)},$$
yielding
$$\mathbb{E}\|\hat\beta - \beta^*\|^2 \;=\; \underbrace{\|(I_d - P_{\mathrm{row}})\beta^*\|^2}_{\text{Bias}^2} \;+\; \underbrace{\sigma^2\,\mathrm{tr}\bigl((X^\top X)^+\bigr)}_{\text{Variance}}.$$

## Proof
Since $\hat\beta = X^+ y = X^+ X \beta^* + X^+ \epsilon = P_{\mathrm{row}}\beta^* + X^+ \epsilon$, we have
$$\hat\beta - \beta^* = (P_{\mathrm{row}} - I_d)\beta^* + X^+ \epsilon = -(I_d - P_{\mathrm{row}})\beta^* + X^+ \epsilon.$$
The first term lies in $\ker(X) = \mathrm{row}(X)^\perp$ (as the kernel of $P_{\mathrm{row}}$); the second lies in $\mathrm{row}(X)$ (the range of $X^+$). These subspaces are orthogonal, so the squared norms add. The variance contribution simplifies as $\mathbb{E}\|X^+ \epsilon\|^2 = \sigma^2 \mathrm{tr}(X^+ X^{+\top}) = \sigma^2 \mathrm{tr}((X^\top X)^+)$. $\square$

## Source
- `proofs/research/statistics/high-dimensional/double-descent-interpolation-threshold/proof.md` — Step 1.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (basis for double-descent risk decomposition)
- **Potential applications**:
  - Double-descent risk analysis (under- and over-parameterized regimes)
  - Min-norm interpolator / ridgeless regression
  - Random-feature regression
  - Kernel ridgeless regression
  - Compressed sensing recovery error
  - Any pseudoinverse-based estimator's risk

## Tags
bias-variance, pseudoinverse, min-norm, projection, double-descent, regression
