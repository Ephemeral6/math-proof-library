# Fragment: gibbs-variational-entropy

## Statement
For any vector $z \in \mathbb{R}^n$ and the simplex $\Delta_n$:
$$\mathrm{LSE}(z) \;=\; \log \sum_i e^{z_i} \;=\; \max_{\pi \in \Delta_n}\Bigl\{\sum_i \pi_i z_i + H(\pi)\Bigr\},$$
where $H(\pi) := -\sum_i \pi_i \log \pi_i$ is the Shannon entropy. The unique maximizer is the **Gibbs distribution**:
$$\pi^*_i = \frac{e^{z_i}}{\sum_j e^{z_j}}.$$

More generally (Donsker-Varadhan / change-of-measure form), for any function $f: \mathcal{A} \to \mathbb{R}$ and base distribution $p$:
$$\log \sum_a p(a) e^{f(a)} \;=\; \max_{q \in \Delta_A}\Bigl\{\sum_a q(a) f(a) - \mathrm{KL}(q\|p)\Bigr\},$$
with maximizer $q^*(a) = p(a) e^{f(a)} / Z$ where $Z = \sum_{a'} p(a') e^{f(a')}$.

## Proof
The objective $\pi \mapsto \sum_i \pi_i z_i + H(\pi)$ is strictly concave on the open simplex (the Hessian of $-H$ is $\mathrm{diag}(1/\pi_i) \succ 0$ on the tangent space). The Lagrangian KKT condition for $\sum \pi_i = 1$ is $z_i - \log\pi_i - 1 - \lambda = 0$, giving $\pi_i \propto e^{z_i}$. Normalization yields the Gibbs distribution. Substituting back:
$$\sum_i \pi^*_i z_i + H(\pi^*) = \sum_i \pi^*_i \bigl(z_i - \log \pi^*_i\bigr) = \sum_i \pi^*_i \log Z = \log Z = \mathrm{LSE}(z). \qquad \square$$

## Source
- `proofs/research/optimization/convergence/entropy-regularized-value-iteration/proof.md` — Lemma 2.
- `proofs/research/optimization/convergence/npg-softmax-tabular-convergence/proof.md` — Lemma 4 (Donsker-Varadhan form).

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (foundational for soft-policy iteration and MI-based bounds)
- **Potential applications**:
  - Maximum-entropy RL (soft Q-learning, SAC) — derives optimal policy in closed form
  - Mirror-descent / FTRL analyses with entropy regularization
  - Gibbs-posterior derivation in statistical mechanics and PAC-Bayes
  - Variational inference (ELBO derivation)
  - Connecting Q-values to log-policies in NPG

## Tags
gibbs, variational, entropy, log-sum-exp, soft-Q, donsker-varadhan
