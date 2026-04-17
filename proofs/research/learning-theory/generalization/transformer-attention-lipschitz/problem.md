# Transformer Attention is Lipschitz

## Source
Fundamental result in Transformer theory, related to Kim et al. (2021), Vuckovic et al. (2020).

## Statement
For single-head self-attention Attn(X) = softmax(XW_QW_K^TX^T/√d_k)·XW_V, prove the Lipschitz bound for row i:

Lip(f_i) ≤ ||W_V|| + 2√2 · n · ||W_V|| · ||W_QW_K^T|| · max_j ||X_j|| / √d_k

## Difficulty
research
