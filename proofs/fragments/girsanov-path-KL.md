# Fragment: girsanov-path-KL

## Statement
Consider two Itô SDEs on the interval $[0, T]$ driven by the same Brownian motion $B_t$, both started from the same initial condition:
$$d\tilde X_t = b^{(1)}_t\, dt + \sqrt{2}\, dB_t, \qquad dY_t = b^{(2)}_t\, dt + \sqrt{2}\, dB_t.$$
Let $P_{\tilde X}$, $P_Y$ denote their path laws, and $\Delta_t := b^{(1)}_t - b^{(2)}_t$ (evaluated on the $\tilde X$ trajectory). Under Novikov's condition $\mathbb{E}\exp(\tfrac{1}{4}\int_0^T \|\Delta_t\|^2 dt) < \infty$:
$$\mathrm{KL}(P_{\tilde X} \| P_Y) \;=\; \tfrac{1}{4}\,\mathbb{E}\!\int_0^T \|b^{(1)}_t - b^{(2)}_t\|^2\, dt.$$

## Proof
By Girsanov's theorem, the Radon-Nikodym derivative is
$$\frac{dP_Y}{dP_{\tilde X}}\bigg|_{\mathcal{F}_T} = \exp\!\Bigl(\tfrac{1}{\sqrt{2}}\int_0^T \Delta_t \cdot dB_t - \tfrac{1}{4}\int_0^T \|\Delta_t\|^2 dt\Bigr).$$
Novikov's condition makes the density a true martingale (not just a local martingale). Take logarithm:
$$\log\frac{dP_{\tilde X}}{dP_Y} = -\tfrac{1}{\sqrt{2}}\int_0^T \Delta_t\cdot dB_t + \tfrac{1}{4}\int_0^T \|\Delta_t\|^2 dt.$$
Take expectation under $P_{\tilde X}$. Under Novikov, the stochastic integral $\int \Delta_t \cdot dB_t$ is also a true martingale with mean 0, so its expectation vanishes:
$$\mathrm{KL}(P_{\tilde X}\|P_Y) = \mathbb{E}_{P_{\tilde X}}\log\frac{dP_{\tilde X}}{dP_Y} = \tfrac{1}{4}\mathbb{E}\int_0^T \|\Delta_t\|^2 dt. \qquad \square$$

## Source
- `proofs/research/probability/sampling/ula-kl-convergence-lsi/proof.md` — Lemma 1.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (key for ULA discretization-error analysis)
- **Potential applications**:
  - Discretization-error analysis for SDE-based samplers (ULA, SGLD, MALA)
  - Diffusion-based generative model analysis (DDPM error bounds)
  - Path-space large deviations
  - Importance sampling between SDEs
  - Comparing exact vs. approximate Langevin dynamics

## Tags
girsanov, path-KL, SDE, langevin, novikov, diffusion
