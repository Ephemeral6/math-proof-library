# Fragment: polarization-identity-gradient-error

## Statement
Let $v$ be any (possibly stochastic) gradient estimate, $\nabla f(x)$ the true gradient, and $e := v - \nabla f(x)$ the estimator error. Then the following exact identity holds:

$$\langle \nabla f(x), v\rangle \;=\; \tfrac{1}{2}\bigl(\|v\|^2 + \|\nabla f(x)\|^2 - \|e\|^2\bigr).$$

Substituted into the descent inequality $f(x_{t+1}) \le f(x_t) - \eta\langle\nabla f(x_t), v_t\rangle + \tfrac{L\eta^2}{2}\|v_t\|^2$ for $\eta < 1/L$, this yields:

$$f(x_{t+1}) \;\le\; f(x_t) - \tfrac{\eta}{2}\|\nabla f(x_t)\|^2 + \tfrac{\eta}{2}\|e_t\|^2 - \tfrac{\eta(1 - L\eta)}{2}\|v_t\|^2.$$

The crucial feature: the $\|v_t\|^2$ term has a **negative** coefficient. This avoids the typical Young-inequality loss of $\sqrt{q}$ that converts SVRG's $n^{3/4}$ rate into SPIDER's $\sqrt{n}$ rate.

## Proof
From $e = v - \nabla f(x)$:
$$\|e\|^2 = \|v\|^2 - 2\langle v, \nabla f(x)\rangle + \|\nabla f(x)\|^2,$$
which rearranges to the identity. The descent inequality follows by substitution.

## Source
- `proofs/research/optimization/stochastic/spider-nonconvex-gradient-complexity/proof.md` — Lemma 2 ("Per-step descent via polarization"). Identical identity reused in:
- `proofs/research/optimization/stochastic/storm-nonconvex-convergence/proof.md` — Lemma 2.
- `proofs/research/optimization/stochastic/page-optimal-gradient-complexity/proof.md` — Lemma 3.

## Status
- **Correctness**: VERIFIED (passed Auditor in 3 separate proofs)
- **Used in final proof**: YES (it is the central technical step in SPIDER/PAGE/STORM)
- **Potential applications**:
  - Any variance-reduced stochastic optimization analysis (SVRG, SARAH, SPIDER, STORM, PAGE, MARINA)
  - Bias-variance decompositions where $v$ is a biased estimate
  - Any descent lemma where one wants to retain the negative $\|v\|^2$ term instead of losing it via Young

## Tags
polarization, descent-lemma, variance-reduction, SPIDER, gradient-estimator
