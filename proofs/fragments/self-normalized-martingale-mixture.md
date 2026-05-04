# Fragment: self-normalized-martingale-mixture

## Statement
Let $a_1, a_2, \ldots \in \mathbb{R}^d$ be a predictable sequence (each $a_t$ measurable w.r.t. $\mathcal{F}_{t-1}$) and let $\eta_t$ be conditionally $R$-sub-Gaussian: $\mathbb{E}[e^{s\eta_t} | \mathcal{F}_{t-1}] \le e^{s^2 R^2/2}$. Define $S_t := \sum_{s=1}^t \eta_s a_s$ and $V_t := \lambda I + \sum_{s=1}^t a_s a_s^\top$ for any $\lambda > 0$. Then with probability $\ge 1 - \delta$, simultaneously for all $t \ge 0$:
$$\|S_t\|_{V_t^{-1}}^2 \;\le\; R^2 \log\!\Bigl(\tfrac{\det(V_t)}{\lambda^d \delta^2}\Bigr) = R^2\Bigl[\log\tfrac{\det(V_t)}{\lambda^d} + 2\log\tfrac{1}{\delta}\Bigr].$$

## Proof
For each $\theta \in \mathbb{R}^d$ define $L_t(\theta) := \exp\bigl(\langle\theta, S_t\rangle/R^2 - \|\theta\|_{A_t}^2/(2R^2)\bigr)$ where $A_t = \sum_s a_s a_s^\top$. By sub-Gaussianity of $\eta_t$:
$$\mathbb{E}[L_t(\theta) | \mathcal{F}_{t-1}] = L_{t-1}(\theta) \cdot \mathbb{E}\bigl[e^{\eta_t\langle a_t,\theta\rangle/R^2 - \langle a_t,\theta\rangle^2/(2R^2)} | \mathcal{F}_{t-1}\bigr] \le L_{t-1}(\theta).$$
So $(L_t(\theta))$ is a non-negative supermartingale with $L_0(\theta) = 1$. Integrating against the Gaussian prior $p(\theta) = \mathcal{N}(0, (R^2/\lambda)I)$ (Robbins' method of mixtures):
$$M_t := \int L_t(\theta) p(\theta) d\theta = \frac{\lambda^{d/2}}{\det(V_t)^{1/2}} \exp\!\Bigl(\tfrac{\|S_t\|_{V_t^{-1}}^2}{2R^2}\Bigr).$$
By Fubini, $M_t$ inherits the supermartingale property. By Ville's inequality, $\Pr(\sup_t M_t \ge 1/\delta) \le \delta$. Inverting the relation for $M_t$ gives the bound. $\square$

## Source
- `proofs/research/learning-theory/generalization/oful-linear-bandit-regret/proof.md` — Lemma 1.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (self-normalized concentration for confidence ellipsoid)
- **Potential applications**:
  - Confidence ellipsoids for ridge regression with adversarial design (Abbasi-Yadkori-Pál-Szepesvári)
  - Linear / generalized-linear bandits, MDPs
  - Linear stochastic approximation analysis
  - Online ridge regression
  - Adaptive confidence sets in active learning
  - Anytime-valid concentration via the method of mixtures

## Tags
self-normalized, martingale, sub-gaussian, mixture, ville, confidence-ellipsoid
