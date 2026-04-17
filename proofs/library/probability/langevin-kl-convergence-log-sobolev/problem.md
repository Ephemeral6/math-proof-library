# Langevin Diffusion Exponential Convergence via Log-Sobolev Inequality

## Source
- Context: Convergence of Langevin dynamics to target distribution, foundational result in MCMC theory and sampling

## Statement

Consider the Langevin diffusion $dX_t = -\nabla V(X_t) dt + \sqrt{2} dB_t$ with target distribution $\pi(x) \propto e^{-V(x)}$. Assume $\pi$ satisfies a log-Sobolev inequality with constant $\alpha > 0$:

$$\text{Ent}_\pi(f^2) \leq \frac{2}{\alpha} \mathbb{E}_\pi[|\nabla f|^2]$$

for all smooth $f$, where $\text{Ent}_\pi(g) = \mathbb{E}_\pi[g \log g] - \mathbb{E}_\pi[g]\log\mathbb{E}_\pi[g]$.

Prove that the KL divergence from the law $\mu_t$ of $X_t$ to the target $\pi$ contracts exponentially:

$$\text{KL}(\mu_t \| \pi) \leq e^{-2\alpha t} \cdot \text{KL}(\mu_0 \| \pi)$$

## Difficulty
research
