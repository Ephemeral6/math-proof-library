# Fragment: schur-product-hadamard-norm

## Statement
Let $M \in \mathbb{R}^{n \times n}$ be symmetric and let $G \in \mathbb{R}^{n \times n}$ be PSD with diagonal entries $G_{ii} = 1$ for all $i$. Then the Hadamard (entrywise) product satisfies:
$$\|M \circ G\|_{\mathrm{op}} \;\le\; \|M\|_{\mathrm{op}}.$$

## Proof
Since $G$ is PSD with unit diagonal, write $G = X X^\top$ where $\|x_i\| = 1$ (rows of $X$). For any unit vector $v \in \mathbb{R}^n$:
$$v^\top (M \circ G) v = \sum_{i,j} M_{ij}\, G_{ij}\, v_i v_j = \sum_{i,j} M_{ij}\, v_i v_j \sum_\ell (x_i)_\ell (x_j)_\ell = \sum_\ell q_\ell^\top M q_\ell,$$
where $(q_\ell)_i := v_i (x_i)_\ell$. Now $\sum_\ell \|q_\ell\|^2 = \sum_i v_i^2 \|x_i\|^2 = \sum_i v_i^2 = 1$. Therefore:
$$|v^\top (M\circ G) v| \le \|M\|_{\mathrm{op}} \sum_\ell \|q_\ell\|^2 = \|M\|_{\mathrm{op}}. \qquad \square$$

## Source
- `proofs/research/learning-theory/generalization/ntk-infinite-width-convergence/proof.md` — Step 2 ("Schur Product Lemma").

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (key step in matrix-Bernstein-based NTK convergence)
- **Potential applications**:
  - Concentration of Hadamard-product random matrices (NTK, attention kernels)
  - Operator-norm bounds on entrywise products with correlation matrices
  - Matrix Schur multipliers and completely-bounded norms
  - Bounding NN kernel deviations from infinite-width limit
  - Spectral analysis of empirical Gram matrices with entrywise transforms

## Tags
schur, hadamard, operator-norm, matrix-inequality, NTK
