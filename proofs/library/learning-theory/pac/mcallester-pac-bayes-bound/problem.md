# McAllester's PAC-Bayes Bound

## Source
- Paper: McAllester (1999), "PAC-Bayesian Model Averaging"
- Context: Fundamental result in PAC-Bayes learning theory relating posterior expected loss to empirical loss plus KL complexity

## Statement

Let $\mathcal{H}$ be a hypothesis space, $P$ be a prior distribution over $\mathcal{H}$ fixed before seeing data, and $Q$ be any posterior distribution over $\mathcal{H}$ (possibly data-dependent). Let $S = \{(x_1,y_1), \ldots, (x_n,y_n)\}$ be $n$ i.i.d. samples from distribution $D$.

For any $h \in \mathcal{H}$, define:
- Population loss: $L_D(h) = \mathbb{E}_{(x,y) \sim D}[\ell(h(x), y)]$ where $\ell \in [0,1]$
- Empirical loss: $L_S(h) = \frac{1}{n} \sum_{i=1}^{n} \ell(h(x_i), y_i)$

**Theorem.** For any $\delta \in (0,1)$, with probability at least $1 - \delta$ over the draw of $S$, simultaneously for ALL distributions $Q$ on $\mathcal{H}$:

$$\mathbb{E}_{h \sim Q}[L_D(h)] \leq \mathbb{E}_{h \sim Q}[L_S(h)] + \sqrt{\frac{\mathrm{KL}(Q \| P) + \ln(n/\delta)}{2n}}$$

where $\mathrm{KL}(Q \| P) = \mathbb{E}_{h \sim Q}\left[\ln \frac{dQ}{dP}(h)\right]$ is the KL divergence.

## Difficulty
research
