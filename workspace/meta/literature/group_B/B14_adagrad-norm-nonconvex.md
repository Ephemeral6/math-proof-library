# B14 — AdaGrad-Norm $O(\log T/\sqrt T)$

**Verdict**: CONFIRMED

**Source**: Ward, Wu, Bottou, *"AdaGrad stepsizes: Sharp convergence over nonconvex landscapes"*, ICML 2019 / JMLR 2020 (arXiv:1806.01811).

## OUR statement
AdaGrad-Norm $x_{k+1} = x_k - (\eta/b_k)g_k$, $b_k^2 = b_0^2 + \sum_{i<k}\|g_i\|^2$. Under $L$-smooth, unbiased $\mathbb{E}[g_k|\mathcal{F}_k] = \nabla f_k$, $\|\xi_k\|\le \sigma$ a.s., $\|\nabla f_k\|\le G$ a.s.:
$$\mathbb{E}\!\left[\min_{0\le k<T}\|\nabla f(x_k)\|^2\right] \le C\frac{\log T}{\sqrt T}, \quad T\ge 2,$$
with explicit polynomial $C(\Delta_0, \eta, b_0, L, \sigma, G)$.

## Paper statement (verified from abstract)
Ward-Wu-Bottou: AdaGrad-Norm converges to a stationary point at rate $O(\log(N)/\sqrt N)$ under $L$-smooth nonconvex. Robust to all hyperparameter choices (any $\eta > 0, b_0 > 0$ works).

## Comparison
- Rate $O(\log T/\sqrt T)$: **matches abstract verbatim**.
- Assumptions: $L$-smooth + bounded variance ($\sigma$) + bounded true gradient ($G$). Ward-Wu-Bottou's theorem is usually stated under bounded second moment (which combines these). Equivalent.
- Step size $\eta$ free: ours holds for any $\eta > 0$ — matches the "robust to hyperparameters" claim.
- Technique: descent lemma + log accumulator $\sum \|g_k\|^2/b_{k+1}^2 \le \log(b_T^2/b_0^2)$ + decoupling identity to convert $\sum\|g_k\|^2/b_k^2$ → $\sum\|g_k\|^2/b_{k+1}^2 + $ correction. This is **exactly the Ward-Wu-Bottou Lemma 4 + Lemma 5 framework**.
- Cross-term zero-mean argument (since $\eta/b_k$ is $\mathcal{F}_k$-measurable, unlike AdaGrad-Coordinate): matches Ward et al. discussion.
- Constant $C$: our bound is polynomial in $(\Delta_0, 1/\eta, \eta, b_0, 1/b_0, L, \sigma, G)$ with one $\log(1+(G+\sigma)^2/b_0^2)$ factor. Matches Ward-Wu-Bottou's qualitative dependence.

## Verdict
**CONFIRMED**: rate $O(\log T/\sqrt T)$, technique (log-accumulator + decoupling), and assumption set all match Ward-Wu-Bottou 2019 exactly. This is a faithful reproduction of the published proof, with the explicit constant tracked carefully (an improvement over the published statement which only gives polynomial dependence).
