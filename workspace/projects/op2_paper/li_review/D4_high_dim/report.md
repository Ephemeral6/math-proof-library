# D4 — Higher-Dimensional Extension of OP-2

**Date:** 2026-04-26
**Status:** NEGATIVE (closed: dimension does not help under OP-2's oracle model)

## Verdict

**NO.** Under the standard $\ell_2$-bounded variance oracle of OP-2 §0.2 ($\mathbb{E}\|\xi_t\|^2 \le \sigma^2$ globally), the natural product extension of OP-2 to dimension $d$ does not give a $\sqrt{d-2}$ improvement. The variance term remains $\Omega(\sigma D/\sqrt T)$, dimension-independent. Even a weaker $\sqrt{\log d}$ improvement is achievable only via Agarwal-style algorithm-agnostic Fano arguments, but does not fit OP-2's separable wall construction.

## The fundamental obstruction: budget cancellation

The §0.2 oracle has *global* variance budget $\sigma^2$. Splitting over $d-2$ y-coords as $\sigma_i^2 = \sigma^2/(d-2)$ forces per-coord signal $\alpha_i = \sigma_i/(2\sqrt{2T}) = \sigma/(2\sqrt{2T(d-2)})$.

Per-coord Le Cam gap is $\alpha_i D_i$. Whether summed (independent tests) or via Hamming-distance recovery (Fano), the total contribution is bounded by Cauchy–Schwarz:
$$\sum_i \alpha_i D_i \;\leq\; \|\alpha\|_2\,\|D\|_2 \;=\; \frac{\sigma}{2\sqrt{2T}}\cdot\frac{D}{\sqrt 2} \;=\; \frac{\sigma D}{4\sqrt T}.$$

**This is dimension-independent.** Adding more coords tightens Cauchy–Schwarz at equality but never improves it. The $\sqrt{d-2}$ from extra tests cancels exactly with $1/\sqrt{d-2}$ from variance dilution.

## Detailed analysis (the four sub-questions)

### Sub-Q1: Variance budget allocation

Direct sum: per-test gap $\propto \sigma_i D_i/\sqrt T$, total $\sum \sigma_i D_i/\sqrt T \le \sigma D/(\sqrt 2 \sqrt T)$ via Cauchy–Schwarz. **Lagrangian-optimal allocation $\sigma_i \propto D_i$ achieves exactly this and concentrates on a single coord — i.e., recovers OP-2's $d=3$.**

### Sub-Q2: Le Cam product vs Fano

KL chain rule (joint): $\mathrm{KL}(\mathbb{P}_s^T \| \mathbb{P}_{s'}^T) = T \sum_{i: s_i \neq s'_i} 2\alpha_i^2/\sigma_i^2 = 2 c^2 \cdot d_H(s, s')$ for $\alpha_i = c\sigma_i/\sqrt T$. Fano gives $\mathbb{E}[d_H(\hat s, s)] \ge (d-2)/2 \cdot (1 - O(c^2))$, but per-coord gap is $\alpha_i D_i = O(\sigma D / ((d-2)\sqrt T))$, summed gives constant. **No Fano gain.**

### Sub-Q3: Bias-variance trade-off

Naive split: bias loses $1/(d-1)$ since cycling amplitude shrinks to $D/\sqrt{d-1}$. **No interior-optimal $d^\star > 3$.**

### Sub-Q5: Free-coordinate alternative

Keep cycling at $D/\sqrt 2$, distribute $D_y^2 \le D^2/2$ over $d-2$ y-coords. Bias preserved at $\kappa LD^2/(8T)$. Variance: same Cauchy–Schwarz bound, no improvement.

The classical $\sqrt{\log d}$ Nemirovski–Yudin / Agarwal et al. 2012 (arXiv:1009.0571) bound exists but is algorithm-agnostic and uses *coupled* hypothesis tests not realizable as a product of 1-D walls.

## When *would* $\sqrt{d-2}$ work?

Only under an $\ell_\infty$-bounded noise oracle: $\|\xi_t\|_\infty \le \sigma$ uniformly. This allows per-coord variance $\sigma^2$ without dilution, and Fano on $\{\pm 1\}^{d-2}$ then gives $\Omega(\sigma D \sqrt{d-2}/\sqrt T)$. **But this is a different problem class** — total noise variance is $d\sigma^2$, $d$ times larger than §0.2 admits.

## Theorem statement (negative result)

> **Theorem (D4, Negative).** Under the oracle model of OP-2 §0.2 ($\mathbb{E}\|\xi_t\|^2 \le \sigma^2$), for every $d \ge 3$ and every $(\beta, \eta) \in \mathcal{F}$, the natural product construction with any allocation $\sum \sigma_i^2 \le \sigma^2$, $\sum c_i^2 \le D^2/2$ yields
> $$\mathbb{E}[f^{(s^\star)}(z_T) - f^{(s^\star),\star}] \geq \frac{\kappa L D^2}{4 T} + c_{\mathrm{NY}}\frac{\sigma D}{\sqrt T},$$
> with the same $c_\mathrm{NY} = 1/112$ as $d = 3$. **No $\sqrt{d-2}$ or $\sqrt{\log d}$ factor appears.**

**Proof sketch.** Construction is product, decoupling holds (Claim 2.5 extends). $x$-bias unchanged. Variance term: KL chain rule joint over coords; Fano gives expected gap $\sum_i \alpha_i D_i$; Cauchy–Schwarz gives $\le \sigma D/(\sqrt 2 \sqrt T)$ regardless of $d$. Apply OP-2's chain (Pinsker + wall correction) for the constant. $\square$

## Recommendation

**Do not pursue.** The OP-2 framework is fundamentally 3-D (2-D Goujaud + 1-D Le Cam). Adding dimensions costs noise budget without gaining tests. Productive next directions:
1. Sharpen $c_\mathrm{NY}$ (D3 — done, $\sqrt 2/27 \approx 0.0524$)
2. Extend $\mathcal{F}$ within $d=3$
3. Re-design hard instance to couple cycling and noise (open)
