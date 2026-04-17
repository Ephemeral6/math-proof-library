# Score Function Estimation via Denoising: Tweedie's Formula and Diffusion Models

## Source
- Paper: Robbins (1956), "An Empirical Bayes Approach to Statistics" (Tweedie's formula)
- Modern: Song & Ermon (2019), "Generative Modeling by Estimating Gradients of the Data Distribution", NeurIPS
- Context: Tweedie's formula connects the score function ∇ log p_σ(x) to the denoising posterior mean, forming the theoretical basis for score-based diffusion models (DDPM, score matching).

## Statement

Let $p_{\mathrm{data}}$ be a data distribution on $\mathbb{R}^d$ with finite second moment. Define the noise-perturbed distribution:

$$p_\sigma(x) = \int p_{\mathrm{data}}(y) \cdot \frac{1}{(2\pi\sigma^2)^{d/2}} \exp\!\left(-\frac{\|x-y\|^2}{2\sigma^2}\right) dy$$

i.e., $p_\sigma$ is the distribution of $X = Y + \sigma\varepsilon$ where $Y \sim p_{\mathrm{data}}$, $\varepsilon \sim N(0, I_d)$.

**Theorem (Tweedie's Formula for Gaussian Perturbation)**: For all $x$ where $p_\sigma(x) > 0$:

$$\nabla_x \log p_\sigma(x) = \frac{1}{\sigma^2}\left(\mathbb{E}[Y | X = x] - x\right)$$

Equivalently, the score function equals the negative of the expected noise direction scaled by $1/\sigma$:

$$\nabla_x \log p_\sigma(x) = -\frac{1}{\sigma}\mathbb{E}[\varepsilon | X = x]$$

**Corollary (Score Matching Objective)**: The denoising score matching loss

$$\mathcal{L}(\theta) = \mathbb{E}_{Y \sim p_{\mathrm{data}}, \varepsilon \sim N(0,I)}\!\left[\left\|s_\theta(Y + \sigma\varepsilon) + \frac{\varepsilon}{\sigma}\right\|^2\right]$$

is minimized when $s_\theta(x) = \nabla_x \log p_\sigma(x)$ for $p_\sigma$-a.e. $x$.

## Difficulty
research

## Key Intermediate Results to Prove

1. **Regularity**: Show $p_\sigma(x) > 0$ for all $x \in \mathbb{R}^d$ (Gaussian convolution is strictly positive).

2. **Differentiation under the integral**: Justify $\nabla_x p_\sigma(x) = \int p_{\mathrm{data}}(y) \nabla_x \phi_\sigma(x-y) dy$ where $\phi_\sigma$ is the Gaussian density.

3. **Gaussian score identity**: Show $\nabla_x \phi_\sigma(x-y) = -\frac{x-y}{\sigma^2}\phi_\sigma(x-y)$.

4. **Bayes' rule connection**: Express $\nabla_x \log p_\sigma(x) = \frac{\nabla_x p_\sigma(x)}{p_\sigma(x)} = \frac{\mathbb{E}[Y|X=x] - x}{\sigma^2}$ by recognizing the posterior mean.

5. **Score matching equivalence**: Show the denoising loss equals the explicit score matching loss plus a constant.
