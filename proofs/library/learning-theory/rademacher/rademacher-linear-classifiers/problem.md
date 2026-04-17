# Rademacher Complexity of Linear Classifiers

## Source
- Paper: Bartlett & Mendelson 2002 (JMLR); Kakade et al. 2009 (NeurIPS)
- Context: Fundamental result in learning theory connecting Rademacher complexity of linear function classes to the geometry of the data via the empirical covariance trace.

## Statement

Let $S = \{x_1, \ldots, x_n\} \subset \mathbb{R}^d$ and define the linear function class $\mathcal{F}_B = \{x \mapsto \langle w, x \rangle : \|w\|_2 \leq B\}$. Let $\sigma_1, \ldots, \sigma_n$ be i.i.d. Rademacher random variables. Then:

**Part 1 (Exact expression):**
$$\hat{\mathfrak{R}}_n(\mathcal{F}_B) = \frac{B}{n}\mathbb{E}\left[\left\|\sum_{i=1}^n \sigma_i x_i\right\|_2\right]$$

**Part 2 (Upper bound):**
$$\hat{\mathfrak{R}}_n(\mathcal{F}_B) \leq \frac{B\sqrt{\mathrm{tr}(\hat{\Sigma})}}{n^{1/2}}$$

where $\hat{\Sigma} = \frac{1}{n}\sum_{i=1}^n x_i x_i^\top$ is the empirical second moment matrix.

## Difficulty
research
