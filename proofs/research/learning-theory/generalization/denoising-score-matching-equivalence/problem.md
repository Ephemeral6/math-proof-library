# Denoising Score Matching Equivalence

## Source
- Paper: Vincent, "A Connection Between Score Matching and Denoising Autoencoders" (2011)
- Context: Foundation for score-based generative models (Song & Ermon 2019, Ho et al. 2020). Shows that explicit score matching (requiring intractable $\nabla_x \log q_\sigma(x)$) can be replaced by denoising score matching (requiring only the corruption kernel).

## Statement

Let $p_{\text{data}}$ be a data distribution and $q_\sigma(x) = \int p_{\text{data}}(y)\mathcal{N}(x;y,\sigma^2 I)\,dy$ the noise-corrupted distribution. Define:

- **Explicit score matching (ESM):**
$$J_{\text{ESM}}(\theta) = \frac{1}{2}\mathbb{E}_{q_\sigma}\left[\|s_\theta(x) - \nabla_x \log q_\sigma(x)\|^2\right]$$

- **Denoising score matching (DSM):**
$$J_{\text{DSM}}(\theta) = \frac{1}{2}\mathbb{E}_{p_{\text{data}}(y)\,\mathcal{N}(\varepsilon)}\left[\left\|s_\theta(y + \sigma\varepsilon) + \frac{\varepsilon}{\sigma}\right\|^2\right]$$

**Prove:** $J_{\text{ESM}}(\theta) = J_{\text{DSM}}(\theta) + C$, where $C$ is a constant independent of $\theta$.

## Difficulty
research
