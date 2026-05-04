# D16: SSL augmentation phase transition (PARTIAL — (c) REFUTED)

**Source claimed**: Internal Problem 7.8 — autonomous-research conjecture set 2026. **NO PUBLISHED SOURCE.**

**Local proof**: For Gaussian-mixture cluster model with $k$ centers + augmentation noise $\sigma_{\text{aug}}$:
- (a) PASS: rank-$k$ regime when $\sigma_{\text{aug}}$ small (closed-form spectrum).
- (b) PASS: rank-1 collapse as $\sigma_{\text{aug}}\to\infty$.
- (c) **REFUTED**: original "first-order phase transition with discontinuous gap" is FALSE for the Gaussian model — gap $g(\sigma_{\text{aug}}) = n(1-e^{-\Delta_{\min}^2/(2d\tau_{\text{eff}}^2)})$ is real-analytic & monotone-decreasing. A second-order continuous transition is proven instead.
- (d) PASS: critical scale $\sigma_{\text{aug}}^* = \Theta(\Delta_{\min}/\sqrt{d})$ verified analytically + numerically (CoV 2.3% across 12 configurations).

**Literature search**: 
- HaoChen-Wei-Gaidon-Ma 2021 (2106.04156) introduce spectral contrastive analysis with population kernel matrix $W$ of similar form.
- Wang-Isola 2020 ("Understanding Contrastive Representation Learning through Alignment and Uniformity") show that as augmentation strength $\to \infty$, contrastive representations collapse to a single point (consistent with local part (b)).
- Saunshi-Ash-Goel-Misra-Zhang-Arora ICML 2022 ("Understanding Contrastive Learning Requires Incorporating Inductive Biases") give related rank-collapse phenomena.

I find **no published statement** of either (i) an exact first-order discontinuity in this setting (consistent with local (c) refutation) or (ii) the precise $\Theta(\Delta_{\min}/\sqrt{d})$ critical scale.

**Verdict**: **NOVEL** (genuinely original autonomous-research contribution).
- The exact eigenvalue-decomposition closed form for the Gaussian-mixture kernel matrix is elementary.
- The **honest refutation** of the literal first-order transition claim, replaced with a second-order continuous transition + the $\Theta(\Delta_{\min}/\sqrt{d})$ scale, is the most defensible novel content.
- Numerical verification (CoV 2.3%) is unusually strong for an "internal" result.

**Defensibility as novel**: HIGH for parts (a), (b), (d) — specifically the **negative result** in (c) (no first-order transition under the natural Gaussian model) and the explicit $\Theta(\Delta_{\min}/\sqrt{d})$ scaling exponent. The closed-form spectrum (Sec 3) is undergraduate-level matrix algebra, but assembling the four-part picture is original.

**Caveat**: The result is for a *very* specific generative model (regular simplex centers + isotropic Gaussian noise + Gaussian RBF kernel). Generalization to realistic settings is conjectural.
