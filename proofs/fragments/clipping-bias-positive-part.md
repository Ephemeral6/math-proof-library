# Fragment: clipping-bias-subadditive-positive-part

## Statement
For the clipping operator $\mathrm{clip}(g, \tau) := g \cdot \min(1, \tau/\|g\|)$, the residual satisfies $g - \mathrm{clip}(g, \tau) = g(1 - \tau/\|g\|)_+$ with $\|g - \mathrm{clip}(g, \tau)\| = (\|g\| - \tau)_+$. Combined with the **sub-additivity of the positive part** ($a \in \mathbb{R}$, $b \ge 0$):
$$(a + b)_+ \;\le\; a_+ + b,$$
this gives the key "clipping bias bound" used in heavy-tailed SGD analysis. For $g_t = \nabla f(x_t) + \xi_t$:
$$(\|g_t\| - \tau)_+ \;\le\; (\|\nabla f(x_t)\| - \tau)_+ + \|\xi_t\|.$$

Therefore, taking conditional expectation under $p$-th moment bound on noise ($\mathbb{E}[\|\xi_t\|^p | \mathcal{F}_t] \le \sigma^p$) and Jensen ($\mathbb{E}[\|\xi_t\|] \le (\mathbb{E}\|\xi_t\|^p)^{1/p} \le \sigma$):
$$\mathbb{E}[(\|g_t\| - \tau)_+ | \mathcal{F}_t] \;\le\; (\|\nabla f(x_t)\| - \tau)_+ + \sigma.$$

## Proof
**Residual identity**: When $\|g\| \le \tau$, $\mathrm{clip}(g, \tau) = g$ so residual $= 0$. When $\|g\| > \tau$, $\mathrm{clip}(g, \tau) = \tau g/\|g\|$, residual $= g(1 - \tau/\|g\|)$ with norm $\|g\| - \tau$.

**Sub-additivity of $(\cdot)_+$**: If $a \ge 0$, $(a+b)_+ = a + b = a_+ + b$. If $a < 0$, $(a+b)_+ \le b = a_+ + b$ (using $a_+ = 0$).

**Application**: $\|g_t\| \le \|\nabla f(x_t)\| + \|\xi_t\|$, so $\|g_t\| - \tau \le (\|\nabla f(x_t)\| - \tau) + \|\xi_t\|$. Apply sub-additivity with $a = \|\nabla f(x_t)\| - \tau$, $b = \|\xi_t\| \ge 0$. $\square$

## Source
- `proofs/research/optimization/stochastic/clipped-sgd-heavy-tail-convergence/proof.md` — Step 3, Lemma ("Sub-additivity of $(\cdot)_+$") and Fact B.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (key for clipped SGD under heavy-tailed noise)
- **Potential applications**:
  - Clipped SGD / SignSGD heavy-tail convergence analysis
  - Differentially private optimization (gradient clipping is the DP mechanism)
  - Robust statistics: bounded influence under heavy-tailed contamination
  - Adaptive gradient clipping methods (AGC)
  - Trust-region / step-size capping arguments

## Tags
clipping, heavy-tail, positive-part, sub-additivity, sgd, robust
