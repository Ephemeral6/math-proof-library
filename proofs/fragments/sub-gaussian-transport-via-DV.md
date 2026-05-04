# Fragment: sub-gaussian-transport-via-DV

## Statement
Let $P \ll Q$ on a measurable space $(\Omega, \mathcal{F})$, and let $f: \Omega \to \mathbb{R}$ be measurable. Suppose $f$ is $\sigma$-sub-Gaussian under $Q$:
$$\log \mathbb{E}_Q[e^{\lambda(f - \mathbb{E}_Q f)}] \le \tfrac{\lambda^2 \sigma^2}{2}, \quad \forall \lambda \in \mathbb{R}.$$

Then (assuming $\mathbb{E}_P[|f|] < \infty$):
$$\bigl|\mathbb{E}_P[f] - \mathbb{E}_Q[f]\bigr| \;\le\; \sqrt{2\sigma^2\, D_{\mathrm{KL}}(P\|Q)}.$$

## Proof
Apply Donsker-Varadhan to the test function $\lambda(f - \mathbb{E}_Q f)$ for any $\lambda \in \mathbb{R}$:
$$\lambda(\mathbb{E}_P f - \mathbb{E}_Q f) \le \log\mathbb{E}_Q[e^{\lambda(f-\mathbb{E}_Q f)}] + D_{\mathrm{KL}}(P\|Q) \le \tfrac{\lambda^2\sigma^2}{2} + D_{\mathrm{KL}}(P\|Q).$$
Optimize over $\lambda \in \mathbb{R}$: the LHS is linear in $\lambda$, the RHS is concave-quadratic. The optimum gives $\lambda^* = (\mathbb{E}_P f - \mathbb{E}_Q f)/\sigma^2$, yielding $|\mathbb{E}_P f - \mathbb{E}_Q f|^2/(2\sigma^2) \le D_{\mathrm{KL}}(P\|Q)$. $\square$

## Source
- `proofs/research/learning-theory/generalization/xu-raginsky-mi-generalization-bound/proof.md` — Lemma 2.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (engine of Xu-Raginsky and Bu-Zou-Veeravalli MI-generalization bounds)
- **Potential applications**:
  - MI-based generalization bounds for any sub-Gaussian loss
  - Wasserstein / transport bounds for sub-Gaussian functionals
  - Adaptive data analysis bounds (Russo-Zou)
  - Privacy-to-generalization conversions where the loss is sub-Gaussian under the prior
  - Mutual-information bounds for sample complexity in active learning

## Tags
sub-gaussian, KL, transport, mutual-information, generalization
