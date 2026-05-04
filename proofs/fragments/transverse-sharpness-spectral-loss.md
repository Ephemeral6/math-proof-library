# Fragment: transverse-sharpness-spectral-loss

## Statement
Consider the spectral contrastive loss $\mathcal{L}_{\mathrm{spec}}(F) = -2\,\mathrm{tr}(F^\top W F) + \tfrac{1}{n^2}\|F^\top F\|_F^2$ on $F \in \mathbb{R}^{n \times k}$, where $W$ is a symmetric PSD matrix with spectrum $\lambda_1 \ge \cdots \ge \lambda_n \ge 0$ and top-$k$ eigenvectors $U_k$. Let $P_k = U_k U_k^\top$ and assume the **spectral gap** $\delta := \lambda_k - \lambda_{k+1} > 0$. Then for every $F$ in a sublevel set $\{\mathcal{L}_{\mathrm{spec}} \le 0\}$ with $\|(I - P_k)F\|_F^2 \le \delta n^2$:
$$\mathcal{L}_{\mathrm{spec}}(F) - \min \mathcal{L}_{\mathrm{spec}} \;\ge\; \delta\,\|(I - P_k) F\|_F^2.$$

(In worst-case directions the constant $2\delta$ is achievable.)

## Proof (sketch)
Decompose $F = U_k A + U_\perp B$ with $A \in \mathbb{R}^{k \times k}$, $B \in \mathbb{R}^{(n-k) \times k}$. Then $\|(I - P_k) F\|_F = \|B\|_F$. Using $U_k^\top W U_k = \mathrm{diag}(\lambda_1, \ldots, \lambda_k)$, $U_\perp^\top W U_\perp = \mathrm{diag}(\lambda_{k+1}, \ldots, \lambda_n)$, $U_k^\top W U_\perp = 0$:
$$\mathcal{L}_{\mathrm{spec}}(F) = -2\sum_j \lambda_j(A^\top A)_{jj} - 2\,\mathrm{tr}(B^\top \Lambda_\perp B) + \tfrac{1}{n^2}\|A^\top A + B^\top B\|_F^2.$$

Minimize over $A$ (assume diagonal WLOG by unitary invariance): the optimum at fixed $B$ is $\alpha_j^2 = n^2 \lambda_j - \beta_j^2$ where $\beta_j^2 = (B^\top B)_{jj}$. Substituting back and using $\lambda_j - \lambda_{k+1} \ge \delta$ for $j \le k$:
$$\mathcal{L}_{\mathrm{spec}}(F) - \min \mathcal{L}_{\mathrm{spec}} \;\ge\; 2\sum_j (\lambda_j - \lambda_{k+1})\beta_j^2 - \tfrac{1}{n^2}\sum_j \beta_j^4 \;\ge\; 2\delta \|B\|_F^2 - \tfrac{1}{n^2}\|B\|_F^4.$$
For $\|B\|_F^2 \le \delta n^2$ the last term is $\le \delta\|B\|_F^2$, leaving $\delta\|B\|_F^2$. $\square$

## Source
- `proofs/research/learning-theory/generalization/spectral-gap-infonce-downstream/proof.md` — Lemma 3 ("Transverse sharpness").

## Status
- **Correctness**: LIKELY-CORRECT (verified numerically in the source proof)
- **Used in final proof**: YES (drives the $1/\delta$ rate for InfoNCE downstream guarantees)
- **Potential applications**:
  - SimCLR / spectral contrastive learning analysis
  - Eigenvector recovery rates (Davis-Kahan style)
  - Quadratic-growth conditions on PCA / matrix factorization losses
  - Phase-retrieval / low-rank recovery sharpness
  - Any argument bounding deviation from the top-$k$ eigenspace via the spectral gap

## Tags
spectral-gap, contrastive, infonce, transverse-sharpness, eigenspace, davis-kahan
