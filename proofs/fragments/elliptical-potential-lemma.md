# Fragment: elliptical-potential-lemma

## Statement
Let $V_t = \lambda I + \sum_{s=1}^t a_s a_s^\top$ where each $a_s \in \mathbb{R}^d$ satisfies $\|a_s\| \le L$, and $\lambda \ge L^2$. Then:
$$\sum_{t=1}^T \|a_t\|_{V_{t-1}^{-1}}^2 \;\le\; 2d \log\!\Bigl(1 + \tfrac{T L^2}{\lambda d}\Bigr).$$

## Proof
Let $x_t := \|a_t\|_{V_{t-1}^{-1}}^2$.
- **Determinant lemma**: $\det(V_t) / \det(V_{t-1}) = 1 + x_t$ (matrix determinant lemma applied to rank-1 update).
- **Telescoping**: $\sum_{t=1}^T \log(1 + x_t) = \log \det(V_T) - \log \det(V_0) \le d \log(1 + T L^2/(\lambda d))$ (by AM-GM on the eigenvalues of $V_T$ vs. its trace).
- **Linearization**: Since $\lambda \ge L^2$, we have $x_t = a_t^\top V_{t-1}^{-1} a_t \le \|a_t\|^2 / \lambda \le 1$. For $x \in [0,1]$, $x \le 2\log(1+x)$ (since $\log(1+x) - x/2$ has derivative $1/(1+x) - 1/2 \ge 0$ on $[0,1]$ with value $0$ at $0$).

Combining: $\sum_t x_t \le 2 \sum_t \log(1+x_t) \le 2d\log(1 + TL^2/(\lambda d))$. $\square$

## Source
- `proofs/research/learning-theory/generalization/oful-linear-bandit-regret/proof.md` — Lemma 4.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (it is the regret-summation engine of OFUL/LinUCB)
- **Potential applications**:
  - All linear-bandit / contextual-bandit regret analyses (OFUL, LinUCB, GLM-UCB)
  - Bayesian optimization / Gaussian-process bandits (Srinivas et al.)
  - Information-gain bounds in active learning
  - $\sqrt{T}$ regret rates with self-normalizing martingales
  - Online ridge regression confidence sets

## Tags
elliptical-potential, design-matrix, linear-bandit, OFUL, log-determinant
