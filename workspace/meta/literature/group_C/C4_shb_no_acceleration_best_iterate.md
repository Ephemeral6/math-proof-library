# C4 — SHB best-iterate LB

**Path**: `proofs/research/optimization/lower-bounds/shb-no-acceleration-best-iterate/`
**Verdict**: **PARTIAL PASS — flagged honestly** (NOVEL bias result; variance DISPROVED)

## Our statement (two-part)

**Theorem 1 (BIAS, PROVED).** For every $(\beta,\eta) \in \mathcal{F}$, the OP-2 deterministic construction satisfies, for all $T \ge 1$:
$$
\min_{0 \le t \le T} f_0(x_t) - f_0^\star \ge \frac{\kappa(\beta,\eta) L D^2}{4} \ge \frac{\kappa/4 \cdot LD^2}{T}.
$$
**Constant: identical to OP-2 last-iterate** $c = \kappa/4$.

**Theorem 2 (VARIANCE, DISPROVED for OP-2 construction).** The 1-D Le Cam construction for the variance term, when evaluated at the best iterate, has
$$
\mathbb{E}[\min_t g_y(y_t) - \min g_y] = O(1/T) \text{ or faster, NOT } \Omega(\sigma D/\sqrt T).
$$
For $T \ge T_0 \asymp D^2(1-\beta)^2/(\sigma^2\eta^2)$, the random walk's minimum drifts low enough that the lower bound provably fails.

## Literature

### GPT 2023 (arXiv:2307.11291)
- Cycling theorem for last iterate, not best iterate.
- Does NOT address best-iterate metric.

### OP-2 (sibling proof C1)
- Last-iterate LB $\Omega(LD^2/T + \sigma D/\sqrt T)$.

### Harvey et al. 2019 (arXiv:1810.03415)
- Best-iterate vs last-iterate lower bounds for **SGD with averaging** on non-SC.
- They show $\Theta(\log T)$ gap between last-iterate and best-iterate for SGD; here the structure is different (cycling on deterministic part).

## Novelty assessment

### Bias part (PROVED)
The deterministic cycling argument transfers to best iterate **trivially**: since every iterate $x_t$ lies on the cycle of radius $D/\sqrt 2$, every iterate has the same function value $\frac{\kappa LD^2}{4}$. So $\min_t = \kappa LD^2/4$, identical to last iterate.

This **transfers OP-2 to the best-iterate metric** — natural and useful but not technically deep.

### Variance part (DISPROVED — surprising)
The 1-D auxiliary $g_y(y) = \alpha_s y + \text{wall}(y)$ has the property that the SHB iterate $y_t$ does a random walk with drift $\alpha_s$ and noise $\sigma$. Over $T$ steps, the **best** iterate $\min_t y_t$ drifts to within $O(\sigma\sqrt T \cdot \eta/(1-\beta))$ of the optimum, achieving function gap that **decreases** in $T$ rather than the $1/\sqrt T$ floor of Le Cam.

This is a genuine **failure** of Le Cam-type lower bounds for the best-iterate metric: Le Cam gives last-iterate distinguishability, not best-iterate.

## Verdict

**NOVEL extension, with an honest PARTIAL PASS flag.** The bias result extends OP-2 to best-iterate metric trivially. The variance DISPROOF is meaningful — it shows that **adding "best iterate" weakens the Nemirovski-Yudin lower bound** for the OP-2 construction, requiring a fundamentally different variance lower bound (e.g., trajectory-anticoncentration argument).

Combined claim: OP-2's iterate-type extension to best-iterate is bias-only.

The proof's labelling as "PARTIAL PASS" rather than "PASS" is exemplary: it explicitly carves out which part fails.
