# Fragment: td-fixed-point-positive-definiteness

## Statement
Let $\Phi \in \mathbb{R}^{|\mathcal{S}| \times d}$ be a feature matrix and $D_\pi = \mathrm{diag}(d_\pi)$ where $d_\pi$ is the stationary distribution of an ergodic Markov chain with transition matrix $P_\pi$. Define the **TD design matrix**
$$A := \mathbb{E}_{s \sim d_\pi, s' \sim P_\pi(\cdot|s)}\bigl[\phi(s)(\phi(s) - \gamma\phi(s'))^\top\bigr] \;=\; \Phi^\top D_\pi \Phi - \gamma\, \Phi^\top D_\pi P_\pi \Phi.$$
If $\Phi^\top D_\pi \Phi \succ 0$ (full column rank weighted by the stationary distribution), then the symmetric part of $A$ satisfies:
$$A_s := \tfrac{1}{2}(A + A^\top) \;\succeq\; (1 - \gamma)\,\Phi^\top D_\pi \Phi.$$
Hence $A$ is positive definite (in the sense $x^\top A x > 0$ for $x \ne 0$) and the TD fixed point $\theta^* = A^{-1}b$ is well-defined.

## Proof
Let $\mathcal{P} := \Phi^\top D_\pi P_\pi \Phi$. For any unit $u \in \mathbb{R}^d$, set $f := \Phi u \in \mathbb{R}^{|\mathcal{S}|}$ (so $f(s) = \phi(s)^\top u$) and $g := P_\pi \Phi u$ (so $g(s) = \mathbb{E}_{s'|s}[\phi(s')^\top u]$). Then $u^\top \mathcal{P} u = \langle f, g\rangle_{d_\pi}$ where $\langle \cdot, \cdot\rangle_{d_\pi}$ is the $d_\pi$-weighted inner product.

By Cauchy-Schwarz and Jensen (using $g(s)^2 = (\mathbb{E}_{s'|s}[\phi(s')^\top u])^2 \le \mathbb{E}_{s'|s}[(\phi(s')^\top u)^2]$):
$$\|g\|_{d_\pi}^2 = \sum_s d_\pi(s) g(s)^2 \le \sum_s d_\pi(s) \mathbb{E}_{s'|s}[(\phi(s')^\top u)^2] = \sum_{s'} d_\pi(s') (\phi(s')^\top u)^2 = \|f\|_{d_\pi}^2,$$
where the second equality uses **stationarity** of $d_\pi$. By Cauchy-Schwarz:
$$|u^\top \mathcal{P} u| = |\langle f, g\rangle_{d_\pi}| \le \|f\|_{d_\pi} \|g\|_{d_\pi} \le \|f\|_{d_\pi}^2 = u^\top \Phi^\top D_\pi \Phi u.$$
Hence $\tfrac{1}{2}(\mathcal{P} + \mathcal{P}^\top) \preceq \Phi^\top D_\pi \Phi$, and:
$$A_s = \Phi^\top D_\pi \Phi - \tfrac{\gamma}{2}(\mathcal{P} + \mathcal{P}^\top) \succeq (1 - \gamma)\Phi^\top D_\pi \Phi. \qquad \square$$

## Source
- `proofs/research/optimization/convergence/td0-linear-approximation-convergence/proof.md` — Lemma 1.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (ensures TD fixed-point exists; underpins TD(0)/TD($\lambda$) finite-time analysis)
- **Potential applications**:
  - TD(0), TD($\lambda$), GTD, GTD2 convergence under linear function approximation
  - Two-timescale stochastic approximation analyses
  - Q-learning with linear function approximation (under behavioral-policy stationarity)
  - LSTD / LSPI sample complexity
  - Showing projected Bellman residuals are well-defined
  - More generally: stationary-distribution + Jensen ⇒ self-adjoint contraction

## Tags
TD-learning, design-matrix, positive-definite, stationary, cauchy-schwarz, RL
