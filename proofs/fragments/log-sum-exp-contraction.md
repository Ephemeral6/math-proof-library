# Fragment: log-sum-exp-contraction

## Statement
The log-sum-exp function $\mathrm{LSE}(x) := \log\bigl(\sum_i e^{x_i}\bigr)$ is $1$-Lipschitz in the $\ell_\infty$ norm:
$$\bigl|\mathrm{LSE}(x) - \mathrm{LSE}(y)\bigr| \;\le\; \|x - y\|_\infty.$$

## Proof
Let $\delta := \|x - y\|_\infty$. Then $x_i \le y_i + \delta$ for all $i$, so $\sum_i e^{x_i} \le e^\delta \sum_i e^{y_i}$, giving $\mathrm{LSE}(x) \le \mathrm{LSE}(y) + \delta$. By symmetry the reverse inequality holds. $\square$

**Corollary** (entropy-regularized Bellman is a contraction). For finite-action MDP with entropy temperature $\tau > 0$, the entropy-regularized Bellman operator
$$(T_\tau V)(s) := \tau \log \sum_a \exp\!\bigl((r(s,a) + \gamma\,\mathbb{E}_{s'}[V(s')])/\tau\bigr)$$
is a $\gamma$-contraction in $\|\cdot\|_\infty$. (Apply LSE 1-Lipschitzness with the $1/\tau$ scaling, then note the $\gamma$ factor on the value function part. The temperature $\tau$ cancels.)

## Source
- `proofs/research/optimization/convergence/entropy-regularized-value-iteration/proof.md` — Lemma 1, plus the $\gamma$-contraction application that follows.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (foundation of soft Q-learning / SAC theory)
- **Potential applications**:
  - Convergence of soft Q-learning, SAC, MIRL
  - Contractions in maximum-entropy RL
  - Exponential averaging arguments (Hedge, Exp3)
  - Regret analysis of online learning with KL regularization
  - Smoothing the max function for differentiable optimization

## Tags
log-sum-exp, contraction, max-entropy, bellman, soft-Q-learning
