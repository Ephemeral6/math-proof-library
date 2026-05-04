# Fragment: score-of-mixture-via-leibniz

## Statement
Let $q_\sigma(x) = \int p(y)\,p_\sigma(x|y)\,dy$ be the marginal of a smooth conditional kernel $p_\sigma(\cdot|y)$ (e.g. $\mathcal{N}(y, \sigma^2 I)$). Under standard regularity (Leibniz applies; $q_\sigma > 0$):
$$\nabla_x \log q_\sigma(x) \;=\; \mathbb{E}_{p(y|x)}\bigl[\nabla_x \log p_\sigma(x|y)\bigr],$$
i.e., the score of the marginal equals the **posterior-expected** score of the conditional.

## Proof
Differentiate under the integral (justified by Leibniz/DCT — for the Gaussian kernel the dominating function is $p(y) \cdot \frac{\|x-y\|}{\sigma^2} p_\sigma(x|y)$, which is integrable when $p$ has finite first moment):
$$\nabla_x q_\sigma(x) = \int p(y) \nabla_x p_\sigma(x|y) dy = \int p(y) p_\sigma(x|y) \nabla_x \log p_\sigma(x|y) dy.$$
Divide by $q_\sigma(x) > 0$ and recognize the posterior $p(y|x) = p(y) p_\sigma(x|y)/q_\sigma(x)$:
$$\nabla_x \log q_\sigma(x) = \int p(y|x) \nabla_x \log p_\sigma(x|y) dy = \mathbb{E}_{p(y|x)}[\nabla_x \log p_\sigma(x|y)]. \qquad \square$$

**Corollary** (Tweedie's formula): for the Gaussian kernel $p_\sigma(x|y) = \mathcal{N}(x; y, \sigma^2 I)$ with score $\nabla_x \log p_\sigma(x|y) = -(x - y)/\sigma^2$:
$$\nabla_x \log q_\sigma(x) = \frac{\mathbb{E}[Y | X = x] - x}{\sigma^2} = -\frac{1}{\sigma}\mathbb{E}[\varepsilon | X = x].$$

## Source
- `proofs/research/learning-theory/generalization/denoising-score-matching-equivalence/proof.md` — Step 3.
- `proofs/research/learning-theory/generalization/tweedies-formula-diffusion-score/proof.md` — Step 4.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (key identity tying ESM to DSM and underlying Tweedie's formula)
- **Potential applications**:
  - Denoising score matching equivalence (ESM = DSM up to constant)
  - Tweedie's formula for empirical Bayes denoising
  - Score-based diffusion models (DDPM, NCSN, EDM)
  - Posterior mean estimation in Gaussian-noise inverse problems
  - Stein's identity / Stein discrepancy applications

## Tags
score-matching, tweedie, leibniz, mixture, diffusion, bayes
