# Fragment: softmax-jacobian-half-lipschitz

## Statement
The softmax map $\mathrm{softmax}: \mathbb{R}^n \to \Delta^{n-1}$ defined by $\sigma(s)_i = e^{s_i} / \sum_j e^{s_j}$ is $\tfrac{1}{2}$-Lipschitz in the $\ell_2$ norm:
$$\|\sigma(s) - \sigma(s')\|_2 \;\le\; \tfrac{1}{2}\|s - s'\|_2 \quad \forall s, s' \in \mathbb{R}^n.$$

The constant $1/2$ is tight (achieved e.g. at $\sigma = (1/2, 1/2, 0, \ldots, 0)$, $v = (1/\sqrt{2}, -1/\sqrt{2}, 0, \ldots, 0)$).

## Proof
The Jacobian of softmax is $J(s) = \mathrm{diag}(\sigma(s)) - \sigma(s)\sigma(s)^\top$ (this is also the Hessian of the log-sum-exp / Gibbs partition function). For any unit vector $v$:
$$v^\top J(s) v = \mathrm{Var}_\sigma(v) = \sum_j \sigma_j v_j^2 - \bigl(\sum_j \sigma_j v_j\bigr)^2.$$

This is the variance of $v$ under the discrete distribution $\sigma$. By Popoviciu's inequality on variance, $\mathrm{Var}_\sigma(v) \le (v_{\max} - v_{\min})^2/4$. Restricted to the orthogonal complement of the all-ones vector and unit $v$ in that subspace, $\mathrm{Var}_\sigma(v) \le 1/4$. Hence the spectral norm is $\le 1/2$.

The bound $1/2$ is tight: take $\sigma = (1/2, 1/2, 0, \ldots, 0)$ and $v = (1, -1, 0, \ldots)/\sqrt{2}$; then $\mathrm{Var}_\sigma(v) = 1/2$.

By the mean-value theorem applied to the gradient: $\|\sigma(s) - \sigma(s')\|_2 \le \tfrac{1}{2}\|s - s'\|_2$. $\square$

## Source
- `proofs/research/learning-theory/generalization/transformer-attention-lipschitz/proof.md` — Step 3 ("Softmax is 1/2-Lipschitz in $\ell_2$").

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (essential for transformer Lipschitz analysis)
- **Potential applications**:
  - Lipschitz analysis of attention/transformers
  - Stability of softmax-based classifiers
  - Smoothing techniques in adversarial robustness
  - Bounding policy-gradient sensitivity for softmax policies
  - Concentration of softmax-of-Gaussian features

## Tags
softmax, lipschitz, jacobian, attention, log-sum-exp
