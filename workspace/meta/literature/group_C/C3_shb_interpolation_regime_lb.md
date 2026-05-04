# C3 — SHB interpolation-regime LB

**Path**: `proofs/research/optimization/lower-bounds/shb-interpolation-regime-lb/`
**Verdict**: **NOVEL** — bias survives, variance disproved (counterexample)

## Our statement (two-part theorem)

**Part (A) Bias survives interpolation.** For every $(\beta,\eta) \in \mathcal{F}$, every continuous $\rho$ with $\rho(0) = 0$, and every $\sigma \ge 0$, there exists an $L$-smooth, κL-strongly convex $f_{\beta,\eta} : \mathbb{R}^2 \to \mathbb{R}$ and an oracle $\mathcal{O} \in \mathcal{N}_{\rm int}(\sigma^2; \rho)$ (the noiseless oracle is in every interpolation class!) such that for all $T \ge 1$:
$$
\mathbb{E}[f(x_T) - f^\star] \ge \frac{\kappa(\beta,\eta)}{2}\cdot\frac{LD^2}{T}.
$$
Note constant $\kappa/2$ vs OP-2's $\kappa/4$ (no $D$-budget split needed without $y$-coordinate).

**Part (B) Variance term DISPROVED.** No constant $c > 0$ uniform in $T$ satisfies $\mathbb{E}[f(x_T)-f^\star] \ge c\sigma D/\sqrt T$ for all interpolation oracles. Explicit counterexample: $f(x) = (L/2)\|x\|^2$, multiplicative-noise $\xi_t = \sigma\|x_t\|\varepsilon_t$, SHB at $(\beta=0, \eta=L/(L^2+\sigma^2))$ achieves linear convergence $\rho^T D^2$ where $\rho = \sigma^2/(L^2+\sigma^2) < 1$.

## Literature

### Bach-Moulines 2014 (true arXiv:1306.2119, not 1410.6660 as listed in proof_list.md)
- "Non-strongly-convex smooth stochastic approximation with convergence rate O(1/n)"
- Shows averaged SGD on **least-squares** achieves $O(1/n)$ on non-SC convex problems.
- Does NOT cover SHB; does NOT prove a lower bound.

### Vaswani et al. 2019 (arXiv:1810.07288) — "Fast and Faster Convergence of SGD for Over-parameterized Models"
- Proves **upper bounds** for SGD/SHB under interpolation: linear convergence under PL + interpolation, $O(1/T)$ under convex + interpolation.
- Does NOT prove a lower bound for SHB.

### Loizou et al. 2021 (AISTATS) — Polyak step
- Linear convergence under interpolation (B-class result we already have at B1).
- Confirms variance term collapses to 0 under interpolation; consistent with our Part (B).

## Novelty assessment

**Part (A) is a clean extension** of OP-2 (C1) to the interpolation noise class $\mathcal{N}_{\rm int}(\sigma^2; \rho)$ with the observation that the noiseless oracle is a member, so the OP-2 bias construction transfers directly with a sharper constant.

**Part (B) is the genuinely surprising result.** The naïve expectation would be that $\Omega(\sigma D/\sqrt T)$ Nemirovski-Yudin lower bound survives any noise-class restriction, but interpolation noise — which vanishes at the optimum — provably defeats the $\sigma D/\sqrt T$ floor by **exponential margin** (linear rate $\rho^T$ vs polynomial $1/\sqrt T$). This explicitly contradicts the naive "OP-2 survives interpolation" reading.

This dichotomy (bias $\Omega(LD^2/T)$ survives; variance $\Omega(\sigma D/\sqrt T)$ collapses) is **not in the literature**:
- Vaswani et al. give upper bounds, not lower bounds.
- Loizou et al. show linear convergence (consistent with our (B)) but don't address whether OP-2-style bias survives.
- Bach-Moulines is for averaged SGD on least-squares, not last-iterate SHB.

## Verdict

**NOVEL.** Part (A) is a routine but explicit extension; Part (B) is a meaningful **disproof** with explicit closed-form rate. Together they sharpen OP-2 by characterizing exactly which OP-2 conclusions extend to the interpolation regime.

The proof's honest **(B)-disproof** with a worked-out counterexample is exemplary — it would have been easy to overstate and claim "OP-2 extends to interpolation". The honest restatement reveals the bias/variance dichotomy.
