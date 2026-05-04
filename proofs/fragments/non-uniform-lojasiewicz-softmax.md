# Fragment: non-uniform-lojasiewicz-softmax

## Statement
For a softmax-parameterized policy $\pi_\theta(a|s) \propto e^{\theta_{s,a}}$ on a finite tabular MDP with discount $\gamma$, initial state distribution $\rho$, and policy gradient $\nabla_\theta V^{\pi_\theta}(\rho)$:
$$\|\nabla_\theta V^{\pi_\theta}(\rho)\|_2 \;\ge\; \frac{\min_s \pi_\theta(a^*(s)|s)}{\sqrt{|\mathcal{S}|}\,\|d^{\pi^*}_\rho/d^{\pi_\theta}_\rho\|_\infty}\,\bigl(V^*(\rho) - V^{\pi_\theta}(\rho)\bigr).$$
Using $d^{\pi_\theta}_\rho \ge (1-\gamma)\rho$ and $d^{\pi^*}_\rho \le \mathbf{1}$:
$$\|\nabla_\theta V^{\pi_\theta}(\rho)\|_2 \;\ge\; \frac{c_*\,(1-\gamma)\,\rho_{\min}}{\sqrt{|\mathcal{S}|}}\,\bigl(V^*(\rho) - V^{\pi_\theta}(\rho)\bigr),$$
where $c_* := \min_s \pi_\theta(a^*(s)|s)$.

This is a **non-uniform Łojasiewicz** inequality (the constant depends on $c_*$, which itself depends on $\theta$).

## Proof
By the policy gradient theorem, $\nabla_{\theta_{s, a^*(s)}} V^{\pi_\theta}(\rho) = \tfrac{1}{1-\gamma} d^{\pi_\theta}_\rho(s)\pi_\theta(a^*(s)|s)A^{\pi_\theta}(s, a^*(s))$. Restrict the Euclidean norm to the $|\mathcal{S}|$ coordinates indexed by $\{(s, a^*(s))\}_s$:
$$\|\nabla V^{\pi_\theta}(\rho)\|_2^2 \ge \frac{1}{(1-\gamma)^2}\sum_s \bigl(d^{\pi_\theta}_\rho(s)\pi_\theta(a^*(s)|s)\bigr)^2 A^{\pi_\theta}(s, a^*(s))^2.$$

Apply Cauchy-Schwarz with weights $w_s = d^{\pi^*}_\rho(s)$ (note both factors are squared, so signs of $A$ don't matter):
$$\Bigl(\sum_s d^{\pi^*}_\rho(s) A^{\pi_\theta}(s, a^*(s))\Bigr)^2 \le \Bigl(\sum_s \tfrac{d^{\pi^*}_\rho(s)^2}{(d^{\pi_\theta}_\rho(s)\pi_\theta(a^*(s)|s))^2}\Bigr)\cdot \Bigl(\sum_s (d^{\pi_\theta}_\rho(s)\pi_\theta(a^*(s)|s))^2 A^{\pi_\theta}(s, a^*(s))^2\Bigr).$$
The first factor is $\le |\mathcal{S}|\cdot\|d^{\pi^*}_\rho/(d^{\pi_\theta}_\rho c_*)\|_\infty^2 = |\mathcal{S}|\|d^{\pi^*}_\rho/d^{\pi_\theta}_\rho\|_\infty^2 / c_*^2$. By the performance difference lemma, the LHS equals $((1-\gamma)(V^*(\rho) - V^{\pi_\theta}(\rho)))^2$. Combine. $\square$

## Source
- `proofs/research/optimization/convergence/softmax-pg-sublinear-convergence/proof.md` — Lemma 5.

## Status
- **Correctness**: VERIFIED (sign-robust, no pointwise advantage assumption)
- **Used in final proof**: YES (drives $O(1/t)$ rate for softmax PG)
- **Potential applications**:
  - Softmax policy gradient convergence (Mei-Xiao-Szepesvári-Schuurmans 2020)
  - Natural policy gradient analyses
  - $O(1/t)$ rates for non-uniformly Łojasiewicz objectives
  - Generalization to entropy-regularized policy optimization
  - Distribution-mismatch coefficients in PG bounds

## Tags
lojasiewicz, softmax, policy-gradient, non-uniform, distribution-mismatch
