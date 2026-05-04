# Fragment: donsker-varadhan-variational

## Statement
Let $P, Q$ be probability measures on a common measurable space with $P \ll Q$. Then for every measurable $f$ with $\mathbb{E}_Q[e^f] < \infty$ and $\mathbb{E}_P[|f|] < \infty$:

$$\mathbb{E}_P[f] \;\le\; \log \mathbb{E}_Q[e^f] + D_{\mathrm{KL}}(P\|Q),$$

with equality (in the variational form) achieved at the tilted measure $dP^* = e^f / \mathbb{E}_Q[e^f] \, dQ$. Equivalently:

$$D_{\mathrm{KL}}(P\|Q) \;=\; \sup_f\{\mathbb{E}_P[f] - \log \mathbb{E}_Q[e^f]\}.$$

## Proof
Define the tilted measure $dQ_f = e^f / \mathbb{E}_Q[e^f]\,dQ$ (a genuine probability since $e^f/\mathbb{E}_Q e^f \ge 0$ and integrates to $1$). Since $P \ll Q \sim Q_f$:
$$\log\frac{dP}{dQ_f} = \log\frac{dP}{dQ} - f + \log\mathbb{E}_Q[e^f].$$
Taking $\mathbb{E}_P$ and using $D_{\mathrm{KL}}(P\|Q_f) \ge 0$ (Gibbs):
$$0 \le D_{\mathrm{KL}}(P\|Q_f) = D_{\mathrm{KL}}(P\|Q) - \mathbb{E}_P[f] + \log\mathbb{E}_Q[e^f]. \qquad \square$$

## Source
- `proofs/research/learning-theory/generalization/xu-raginsky-mi-generalization-bound/proof.md` — Lemma 1.
- `proofs/research/optimization/convergence/npg-softmax-tabular-convergence/proof.md` — Lemma 4.
- `proofs/research/learning-theory/generalization/catoni-pac-bayes-bound/proof.md` — Lemma 4.

## Status
- **Correctness**: VERIFIED (used in 3+ research proofs)
- **Used in final proof**: YES (it's the cornerstone of MI-based generalization, PAC-Bayes, large deviations)
- **Potential applications**:
  - Information-theoretic generalization bounds (Russo-Zou, Xu-Raginsky, Bu-Zou-Veeravalli, Steinke-Zakynthinou)
  - PAC-Bayes (Catoni, Maurer)
  - Large deviations / Cramér-Chernoff bounds
  - Variational inference (ELBO is one-sided DV)
  - Soft-Q learning / entropy-regularized RL

## Tags
KL, donsker-varadhan, variational, PAC-Bayes, mutual-information, large-deviations
