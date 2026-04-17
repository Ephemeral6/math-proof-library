# VC Dimension Generalization Bound

## Source
- Paper: Vapnik & Chervonenkis 1971; Blumer et al. 1989
- Context: Fundamental uniform convergence bound in statistical learning theory. Establishes that the sample complexity of uniform convergence is controlled by VC dimension.

## Statement

For a hypothesis class $\mathcal{H}$ with VC dimension $d$ and $n$ i.i.d. samples drawn from distribution $\mathcal{D}$, for any $\delta > 0$, with probability $\geq 1-\delta$:

$$\sup_{h \in \mathcal{H}} |R(h) - \hat{R}(h)| \leq O\left(\sqrt{\frac{d \log(n/d) + \log(1/\delta)}{n}}\right)$$

where $R(h) = \mathbb{E}_{(x,y)\sim\mathcal{D}}[\ell(h(x),y)]$ is the true risk (with 0-1 loss) and $\hat{R}(h) = \frac{1}{n}\sum_{i=1}^n \ell(h(x_i),y_i)$ is the empirical risk.

## Difficulty
research
