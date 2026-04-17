# Final Report: Rademacher Complexity of Linear Classifiers

## Result: PASS ✅

## Theorem Statement

For the function class $\mathcal{F}_B = \{x \mapsto \langle w, x \rangle : \|w\| \leq B\}$ with sample $S = \{x_1, \ldots, x_n\} \subset \mathbb{R}^d$:

**Part 1 (Exact expression):**
$$\hat{\mathfrak{R}}_n(\mathcal{F}_B) = \frac{B}{n}\mathbb{E}\left[\left\|\sum_{i=1}^n \sigma_i x_i\right\|\right]$$

**Part 2 (Upper bound):**
$$\hat{\mathfrak{R}}_n(\mathcal{F}_B) \leq \frac{B\sqrt{\text{tr}(\hat{\Sigma})}}{n^{1/2}}$$

where $\hat{\Sigma} = \frac{1}{n}\sum_{i=1}^n x_ix_i^\top$.

## Proof Summary (Route 1: Direct Cauchy-Schwarz)

### Part 1
1. Substitute parametric form into Rademacher definition
2. Use bilinearity to write $\sum_i \sigma_i\langle w, x_i\rangle = \langle w, \sum_i \sigma_i x_i\rangle$
3. Compute $\sup_{\|w\|\leq B}\langle w, z\rangle = B\|z\|$ via Cauchy-Schwarz with explicit maximizer $w^* = Bz/\|z\|$
4. Conclude $\hat{\mathfrak{R}}_n(\mathcal{F}_B) = \frac{B}{n}\mathbb{E}[\|\sum_i \sigma_i x_i\|]$

### Part 2
5. Apply Jensen's inequality ($\sqrt{\cdot}$ is concave): $\mathbb{E}[\|z\|] \leq \sqrt{\mathbb{E}[\|z\|^2]}$
6. Expand $\mathbb{E}[\|\sum_i \sigma_i x_i\|^2] = \sum_{i,j}\mathbb{E}[\sigma_i\sigma_j]\langle x_i, x_j\rangle$
7. By Rademacher independence: $\mathbb{E}[\sigma_i\sigma_j] = \delta_{ij}$, giving $\sum_i \|x_i\|^2$
8. Identify $\sum_i \|x_i\|^2 = n\,\text{tr}(\hat{\Sigma})$ via $\text{tr}(xx^\top) = \|x\|^2$
9. Combine: $\frac{B}{n}\sqrt{n\,\text{tr}(\hat{\Sigma})} = \frac{B\sqrt{\text{tr}(\hat{\Sigma})}}{\sqrt{n}}$

## Routes Explored

| Route | Method | Verdict |
|-------|--------|---------|
| 1 | Direct Cauchy-Schwarz + Jensen | ✅ PASS (selected) |
| 2 | Support function / Fenchel conjugate | ✅ Correct |
| 3 | Lagrange multipliers + eigendecomposition | ✅ Correct |

## Audit Results

- **Round 1**: PASS. All 9 steps verified line-by-line. Edge cases ($z=0$) handled. Measurability and integrability confirmed. Jensen direction verified. No errors found.

## Source Attribution

- Bartlett, P. L. & Mendelson, S. (2002). Rademacher and Gaussian Complexities: Risk Bounds and Structural Results. JMLR.
- Kakade, S., Sridharan, K., & Tewari, A. (2009). On the Complexity of Linear Prediction: Risk Bounds, Margin Bounds, and Regularization. NeurIPS.
- Mohri, M., Rostamizadeh, A., & Talwalkar, A. (2018). Foundations of Machine Learning, 2nd ed. MIT Press.
