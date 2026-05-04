# Generalization Bound Gap Between Matrix and Standard Cross-Entropy

## Source
- Paper: Zhang, Tan, Yang, Huang, Yuan, ICML 2024 — "Matrix Information Theory for Self-Supervised Learning"
- Direction: Self-supervised learning / Matrix information theory (Yang Yuan group)

## Statement

Let $\widehat{\mathcal{L}}_{\mathrm{MCE}}(\theta) = -\mathrm{tr}(\rho_* \log \widehat{\rho}_\theta)$ denote the matrix cross-entropy loss (matrix KL on the empirical Gram-density of representations) and $\widehat{\mathcal{L}}_{\mathrm{CE}}(\theta) = \tfrac{1}{m}\sum_i \ell_{\mathrm{CE}}(W f_\theta(x_i), y_i)$ the standard per-sample cross-entropy. For ERM solutions $\theta^*_{\mathrm{MCE}}, \theta^*_{\mathrm{CE}}$ over $m$ i.i.d. samples from $\mathcal D$ on a hypothesis class $\mathcal H = \{f_\theta\}_{\theta\in\Theta}$, find conditions on $\mathcal H$ and $\mathcal D$ such that
$$|\mathcal L_{\mathrm{MCE}}(\theta^*_{\mathrm{MCE}}) - \widehat{\mathcal L}_{\mathrm{MCE}}(\theta^*_{\mathrm{MCE}})| \;<\; |\mathcal L_{\mathrm{CE}}(\theta^*_{\mathrm{CE}}) - \widehat{\mathcal L}_{\mathrm{CE}}(\theta^*_{\mathrm{CE}})|$$
with high probability.

## Difficulty
research
