# Rademacher Complexity Generalization Bound

## Source
- Paper: Bartlett & Mendelson 2002 (JMLR); Koltchinskii & Panchenko 2002
- Context: Fundamental tool in statistical learning theory for data-dependent generalization bounds

## Statement

**Theorem.** Let $\mathcal{F}$ be a class of functions $f: \mathcal{X} \to [0,1]$, and let $S = (X_1, \ldots, X_n)$ be i.i.d. samples from distribution $\mathcal{D}$. Define the empirical Rademacher complexity:

$$\hat{\mathfrak{R}}_n(\mathcal{F}) = \mathbb{E}_\sigma\left[\sup_{f \in \mathcal{F}} \frac{1}{n}\sum_{i=1}^n \sigma_i f(X_i)\right]$$

where $\sigma_1, \ldots, \sigma_n$ are i.i.d. Rademacher random variables ($P(\sigma_i = \pm 1) = 1/2$).

Then with probability at least $1 - \delta$ over $S$:

$$\sup_{f \in \mathcal{F}} \left(\mathbb{E}[f(X)] - \frac{1}{n}\sum_{i=1}^n f(X_i)\right) \leq 2\hat{\mathfrak{R}}_n(\mathcal{F}) + \sqrt{\frac{\ln(2/\delta)}{2n}}.$$

Furthermore, $\mathbb{E}[\hat{\mathfrak{R}}_n(\mathcal{F})] = \mathfrak{R}_n(\mathcal{F})$ and:

$$\sup_{f \in \mathcal{F}} \left(\mathbb{E}[f(X)] - \frac{1}{n}\sum_{i=1}^n f(X_i)\right) \leq 2\mathfrak{R}_n(\mathcal{F}) + 3\sqrt{\frac{\ln(2/\delta)}{2n}}.$$

## Difficulty
research
