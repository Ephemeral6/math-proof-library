# Fragment: performance-difference-lemma

## Statement (Kakade-Langford 2002)
For any two policies $\pi, \pi'$ on a discounted MDP with $\gamma \in [0, 1)$ and initial distribution $\rho$:
$$V^{\pi'}(\rho) - V^\pi(\rho) \;=\; \frac{1}{1 - \gamma}\,\mathbb{E}_{s \sim d^{\pi'}_\rho}\!\Bigl[\sum_a \pi'(a|s)\, A^\pi(s, a)\Bigr],$$
where $A^\pi(s, a) := Q^\pi(s, a) - V^\pi(s)$ is the advantage and $d^{\pi'}_\rho(s) := (1 - \gamma)\sum_{t \ge 0} \gamma^t \Pr_{\pi'}(s_t = s | s_0 \sim \rho)$ is the discounted state visitation.

Equivalently, using $A^\pi(s, a) = Q^\pi(s, a) - V^\pi(s)$ and $V^\pi(s) = \sum_a \pi(a|s)Q^\pi(s, a)$:
$$V^{\pi'}(\rho) - V^\pi(\rho) \;=\; \frac{1}{1-\gamma}\sum_s d^{\pi'}_\rho(s)\sum_a (\pi'(a|s) - \pi(a|s))Q^\pi(s, a).$$

## Proof
Let $\delta(s) := V^{\pi'}(s) - V^\pi(s)$. By the Bellman equation under $\pi'$:
$$V^{\pi'}(s) = \sum_a \pi'(a|s)\bigl[r(s,a) + \gamma\,\mathbb{E}_{s'|s,a}[V^{\pi'}(s')]\bigr].$$
Using $V^\pi(s) = \sum_a \pi'(a|s) V^\pi(s)$ (since $\sum_a \pi'(a|s) = 1$) and $A^\pi(s, a) = Q^\pi(s, a) - V^\pi(s)$:
$$\delta(s) = \sum_a \pi'(a|s)\bigl[A^\pi(s, a) + \gamma\,\mathbb{E}_{s'|s,a}[\delta(s')]\bigr].$$
Iterating starting from $s_0 \sim \rho$:
$$\sum_s \rho(s)\delta(s) = \sum_{t \ge 0} \gamma^t\,\mathbb{E}_{s_t \sim \pi', \rho}\!\Bigl[\sum_a \pi'(a|s_t) A^\pi(s_t, a)\Bigr].$$
Recognize the sum as $\tfrac{1}{1-\gamma}\sum_s d^{\pi'}_\rho(s)\sum_a \pi'(a|s)A^\pi(s, a)$. $\square$

## Source
- `proofs/research/optimization/convergence/npg-softmax-tabular-convergence/proof.md` — Lemma 1.
- `proofs/research/optimization/convergence/softmax-pg-sublinear-convergence/proof.md` — Lemma 3.

## Status
- **Correctness**: VERIFIED (classical, used in 2+ proofs)
- **Used in final proof**: YES (foundational for all policy gradient convergence proofs)
- **Potential applications**:
  - All policy gradient / NPG / TRPO / PPO convergence analyses
  - CPI (conservative policy iteration) bounds
  - Distribution-mismatch arguments via $d^{\pi^*}_\rho/d^\pi_\rho$
  - Any RL proof relating two policies' values via advantage
  - Off-policy evaluation error decomposition

## Tags
performance-difference, policy-gradient, advantage, value-function, RL, MDP
