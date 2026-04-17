# Sub-Gaussian Maximal Inequality

## Source
- Paper: Vershynin 2018 (HDP Ch.2); Boucheron et al. 2013
- Context: Fundamental concentration inequality bounding the expected maximum and tail probability of the maximum of sub-Gaussian random variables. Core tool in high-dimensional probability and statistics.

## Statement

Let $X_1, \ldots, X_n$ be random variables (not necessarily independent) that are sub-Gaussian with parameter $\sigma > 0$, i.e., for each $i$ and all $\lambda \in \mathbb{R}$:
$$\mathbb{E}[e^{\lambda X_i}] \leq e^{\lambda^2 \sigma^2 / 2}.$$

Then:

**(a)** For all $t > 0$:
$$P\!\left(\max_{1 \leq i \leq n} X_i > t\right) \leq n \exp\!\left(-\frac{t^2}{2\sigma^2}\right).$$

**(b)**
$$\mathbb{E}\!\left[\max_{1 \leq i \leq n} X_i\right] \leq \sigma\sqrt{2 \log n}.$$

## Difficulty
research
