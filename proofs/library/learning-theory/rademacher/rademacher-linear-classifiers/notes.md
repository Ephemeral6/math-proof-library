# Notes: Rademacher Complexity of Linear Classifiers

## Proof technique
Route 1 (Direct Cauchy-Schwarz) was selected as the best route. The key insight is that the supremum of a linear functional over a Euclidean ball has a closed-form solution via Cauchy-Schwarz duality: $\sup_{\|w\|\leq B}\langle w,z\rangle = B\|z\|$. The bound then follows from Jensen's inequality and Rademacher orthogonality.

## Key steps
1. **Bilinearity reduction**: Rewriting $\sum_i \sigma_i\langle w, x_i\rangle = \langle w, \sum_i \sigma_i x_i\rangle$ decouples the optimization variable $w$ from the randomness $\sigma$.
2. **Cauchy-Schwarz supremum**: The support function of the Euclidean ball is the scaled dual norm, giving the exact expression.
3. **Rademacher orthogonality**: The cross terms $\mathbb{E}[\sigma_i\sigma_j] = 0$ for $i\neq j$ simplify the second moment to $\sum_i \|x_i\|^2$.
4. **Trace identity**: The connection $\sum_i \|x_i\|^2 = n\,\mathrm{tr}(\hat{\Sigma})$ via $\mathrm{tr}(xx^\top) = \|x\|^2$ produces the final bound.

## Audit result
Passed on first round. All 9 steps verified line-by-line. Edge cases (z=0) properly handled. Jensen direction confirmed correct (concave square root). Measurability and integrability of the supremum verified.

## Related results
- **Rademacher generalization bound** (already in library): This result feeds directly into $R(f) \leq \hat{R}(f) + 2\hat{\mathfrak{R}}_n(\mathcal{F}) + O(\sqrt{\log(1/\delta)/n})$.
- **Gaussian complexity**: Replacing Rademacher with Gaussian variables gives $\hat{\mathfrak{G}}_n(\mathcal{F}_B) = \frac{B}{n}\mathbb{E}[\|\sum_i g_i x_i\|]$ with $g_i \sim \mathcal{N}(0,1)$, and these are related by $\hat{\mathfrak{R}}_n \leq \sqrt{\pi/2}\,\hat{\mathfrak{G}}_n$.
- **Kernel extension**: For kernel methods, the trace bound becomes $B\sqrt{\mathrm{tr}(K)/n^2}$ where $K_{ij} = k(x_i,x_j)$.
- **$\ell_1$-constrained classes**: For $\|w\|_1 \leq B$, the Rademacher complexity is $\frac{B}{n}\mathbb{E}[\|\sum_i \sigma_i x_i\|_\infty]$ (dual norm changes to $\ell_\infty$).
- **Margin-based bounds**: Combined with Talagrand's contraction lemma, this gives generalization bounds for linear classifiers in terms of the margin.
