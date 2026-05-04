# D9: Tweedie's formula for diffusion score

**Source claimed**: Robbins 1956 (Tweedie's formula original); Song-Ermon 2019 (1907.05600) for the diffusion-models connection.

**Local proof**: Direct computation: $\nabla_x \log p_\sigma(x) = (\mathbb{E}[Y|X=x] - x)/\sigma^2 = -\mathbb{E}[\varepsilon|X=x]/\sigma$. Then DSM equivalence follows by completing the square.

**Literature**: This is the classical Tweedie formula:
- Robbins 1956 ("An Empirical Bayes Approach to Statistics") gave the original $\mathbb{E}[\theta|x] = x + \sigma^2 \nabla\log p_\sigma(x)$ for Gaussian noise.
- Efron 2011 ("Tweedie's Formula and Selection Bias", JASA) popularized in modern stats.
- Song-Ermon 2019 (NCSN) and Song et al. 2021 (1907.05600 → 2011.13456 score-SDE) use this identity to define the score-matching objective.

The local proof is the standard direct calculation using $\nabla_x \varphi_\sigma(x-y) = -(x-y)/\sigma^2 \cdot \varphi_\sigma(x-y)$ + Bayes rule.

**Verdict**: REPRODUCED (textbook identity). The DSM-equivalence Step 6 overlaps with D3 (Vincent 2011).

**Discrepancies**: None. **Note**: D3 and D9 are essentially the same theorem stated two different ways. They could be merged.

**Honest classification**: C-class direct computation.
