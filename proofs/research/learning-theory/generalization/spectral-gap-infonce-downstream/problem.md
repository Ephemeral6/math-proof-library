# Spectral Gap and Downstream Performance in Contrastive Learning

## Source
- Paper: Tan, Zhang, Yang, Yuan (ICLR 2024) — "Contrastive learning is spectral clustering on similarity graph"
- Context: Self-supervised learning theory (Yang Yuan group). Connects InfoNCE
  / SimCLR to spectral clustering on the augmentation graph, and links
  spectral-gap of the similarity matrix to representation quality.

## Statement
Let $W \in \mathbb{R}^{n \times n}$ be the augmentation-induced similarity
matrix (symmetric, non-negative, row-normalized; we interpret this as the
symmetric PSD normalization $D^{-1/2}AD^{-1/2}$ of the augmentation kernel),
with eigenvalues $\lambda_1 \ge \lambda_2 \ge \cdots \ge \lambda_n$. The
InfoNCE loss of SimCLR at temperature $\tau \to 0$ is equivalent (in the
$\Gamma$-convergence sense, as established in Tan et al. 2024 and HaoChen
et al. 2021) to spectral clustering on $W$.

Prove: If the spectral gap satisfies $\lambda_k - \lambda_{k+1} \ge \delta > 0$
(for $k$ clusters), then the globally optimal representation
$f^* \in \mathbb{R}^{n\times d}$ ($d \ge k$) of InfoNCE satisfies
$$
\|f^* - P_k f^*\|_F^2 \;\le\; \frac{C}{\delta^2},
$$
where $P_k$ is the projection onto the top-$k$ eigenspace of $W$, and $C$
depends only on $n$ and $\tau$.

## Difficulty
research
