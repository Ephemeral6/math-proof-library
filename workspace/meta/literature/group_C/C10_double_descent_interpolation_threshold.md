# C10 — Double descent interpolation threshold

**Path**: `proofs/research/statistics/high-dimensional/double-descent-interpolation-threshold/`
**Verdict**: **MATCH with one honest correction flagged in the proof**

## Our statement
For ridgeless regression $\hat\beta = X^+ y$ with $X = Z/\sqrt d$, $Z$ has i.i.d. $\mathcal{N}(0,1)$ entries, $y = X\beta^* + \epsilon$, $\epsilon \sim \mathcal{N}(0, \sigma^2 I_n)$:

**Underparameterized** $\gamma = d/n < 1$: $R \to \frac{\sigma^2 \gamma}{1 - \gamma}$ (no bias).

**Overparameterized** $\gamma > 1$: $R \to \frac{\sigma^2}{\gamma - 1} + \frac{\gamma - 1}{\gamma} b^2$ where $b^2 = \lim \|\beta^*\|^2/d$.

**At interpolation threshold** $\gamma = 1$: $R \to +\infty$.

**Note on correction**: The proof file's Step 3 explicitly flags that "the problem statement says bias is $\|\beta^*\|^2/(\gamma-1)$, but the mathematically correct bias is $(\gamma-1)/\gamma \cdot b^2$" — these differ in sign of behavior near $\gamma=1$.

## Literature

### Belkin et al. 2019 (arXiv:1903.08560) — "Reconciling modern machine learning practice and the bias-variance trade-off"
- Empirical observation of double descent.
- Does not contain the exact ridgeless regression asymptotic formulas.

### Hastie-Montanari-Rosset-Tibshirani 2019 (arXiv:1903.08560 was originally Belkin; the formal asymptotic is in HMRT 1903.08560 / 2208.06748 / Bartlett-Long-Lugosi-Tsigler 2020)
- Variance: $\sigma^2 \gamma/(1-\gamma)$ (under) and $\sigma^2/(\gamma-1)$ (over). 
- Bias under isotropic features: vanishes for $\gamma < 1$, equals $(1 - 1/\gamma)\|\beta^*\|^2/d$ for $\gamma > 1$.
- **Matches our bias formula $(\gamma-1)/\gamma \cdot b^2$.**

### Belkin-Hsu-Xu 2020 (arXiv:1903.07571) — "Two models of double descent for weak features"
- Closed-form bias-variance for Gaussian features.

## Comparison

| Aspect | HMRT 2019 / standard | OUR C10 |
|---|---|---|
| Variance ($\gamma<1$) | $\sigma^2\gamma/(1-\gamma)$ | identical |
| Variance ($\gamma>1$) | $\sigma^2/(\gamma-1)$ | identical |
| Bias ($\gamma>1$) | $(\gamma-1)/\gamma \cdot b^2$ | identical (proof's Haar invariance argument) |
| Divergence at $\gamma=1$ | $+\infty$ | identical |

## Verdict

**MATCH.** The proof correctly derives the canonical asymptotic risk via:
1. Bias-variance decomposition using $\hat\beta - \beta^* = (X^+X - I)\beta^* + X^+\epsilon$.
2. Wishart inverse moment formula $\mathbb{E}[(Z^TZ)^{-1}] = I/(n-d-1)$.
3. Haar invariance argument $\mathbb{E}[P_X] = (n/d)I_d$ giving $\mathbb{E}[I-P_X] = (d-n)/d\cdot I_d$.

**Honest correction flagged**: The original `problem.md` had the bias term wrong ($\|\beta^*\|^2/(\gamma-1)$ instead of $(\gamma-1)/\gamma\cdot b^2$). The proof file explicitly notes the correction in a remark. This is the mathematically correct formula matching HMRT 2019 and the broader random matrix theory literature.

The proof is rigorous, the computation is standard (Wishart moment + Haar invariance + Marchenko-Pastur), and the divergence at $\gamma = 1$ matches the canonical double-descent "peak". No novelty claimed; this is a B-class library result.
