# B13 — AMSGrad nonconvex convergence

**Verdict**: CONFIRMED-WEAKER

**Source**: Reddi, Kale, Kumar, *"On the Convergence of Adam and Beyond"*, ICLR 2018 (arXiv:1904.09237 reposting). Original AMSGrad paper proves convex regret $O(\sqrt T)$. The non-convex AMSGrad analysis is in subsequent work (Chen, Liu, Sun, Hong "On the Convergence of A Class of Adam-Type Algorithms for Non-Convex Optimization", ICLR 2019, arXiv:1808.02941; Zhou, Tang, Yang, et al. "On the convergence of adaptive gradient methods for nonconvex optimization", arXiv:1808.05671). [ARXIV-UNREACHABLE for theorem detail.]

## OUR statement
$L$-smooth nonconvex $f$, $\|g_t\|_\infty \le G$, bounded variance $\sigma^2$, $\alpha_t = \alpha/\sqrt T$, $\beta_1 < \sqrt{\beta_2} < 1$:
$$\frac{1}{T}\sum_{t=1}^T \mathbb{E}\|\nabla f(x_t)\|^2 \le \underbrace{O\!\left(\tfrac{1}{\sqrt T}\right)}_{\text{Term 1+2}} + \underbrace{O\!\left(\tfrac{\beta_1}{1-\beta_1}\right)}_{\text{Term 3}} + \underbrace{O(\sqrt{1-\beta_2})}_{\text{Term 4}}.$$

## Paper statement
Chen-Liu-Sun-Hong 2019 / Zhou et al. 2018: AMSGrad nonconvex achieves $O(\log T/\sqrt T)$ to a stationary point under $L$-smooth + bounded gradients, with non-vanishing momentum bias terms.

## Comparison
- Rate of vanishing terms $O(1/\sqrt T)$ — **matches** Chen et al. (modulo $\log T$ factor; our analysis avoids the log via different telescoping).
- Non-vanishing momentum bias $O(\beta_1/(1-\beta_1))$: matches.
- Non-vanishing adaptive correction $O(\sqrt{1-\beta_2})$: matches Chen et al. (called "denominator drift" term).
- Constants: ours uses crude $\|D_t\|^2 \le dG^2/\varepsilon^2$ (very loose, dimension factor $d$); published proofs use coordinate-wise telescoping with tighter dependence.
- Technique: $\hat v_{t-1}$ trick for the noise cross-term (martingale argument) — **this matches** Chen et al. and is the key device that distinguishes AMSGrad from Adam (Adam has no $\hat v_t$ monotonicity).
- Proof's own table at the end honestly admits gaps in coefficient constants vs target bound.

## Verdict
**CONFIRMED-WEAKER**: $O(1/\sqrt T)$ rate plus non-vanishing momentum/adaptive bias structure matches the standard nonconvex AMSGrad result (Chen et al. 2019). Constants are looser by $\sqrt d$ and $1/\varepsilon^2$ factors; proof acknowledges this. The qualitative structure — three-term bound — matches the published Reddi/Chen analysis exactly. No errors in technique or scope.
