# Online-to-Batch Conversion

## Source
- Paper: Cesa-Bianchi et al. 2004
- Context: Fundamental result connecting online learning regret bounds to statistical learning guarantees. Shows that any online learner with sublinear regret yields a consistent statistical learner.

## Statement

Let $\mathcal{H}$ be a hypothesis class and $\ell$ a loss function. Suppose an online learning algorithm produces hypotheses $h_1, h_2, \ldots, h_T$ achieving worst-case regret

$$\text{Reg}_T = \sum_{t=1}^T \ell(h_t, z_t) - \min_{h \in \mathcal{H}} \sum_{t=1}^T \ell(h, z_t) \leq R(T)$$

for every sequence $z_1, \ldots, z_T$. When run on i.i.d. data $z_1, \ldots, z_T \sim \mathcal{D}^T$, the randomized predictor $\bar{h}_T = \text{Uniform}(h_1, \ldots, h_T)$ satisfies:

$$\mathbb{E}[R(\bar{h}_T)] - R(h^*) \leq \frac{R(T)}{T},$$

where $R(h) = \mathbb{E}_{z \sim \mathcal{D}}[\ell(h, z)]$ is the population risk and $h^* = \arg\min_{h \in \mathcal{H}} R(h)$.

**Convex refinement**: If additionally $\ell(\cdot, z)$ is convex for all $z$ and $\mathcal{H}$ is convex, then the deterministic averaged hypothesis $\hat{h}_T = \frac{1}{T}\sum_{t=1}^T h_t$ also satisfies the same bound.

## Difficulty
research
