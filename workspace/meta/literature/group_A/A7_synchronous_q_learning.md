# A7: Synchronous Q-Learning Finite-Time

**Proof path**: `proofs/research/optimization/convergence/synchronous-q-learning-finite-time/`
**Claimed source**: Li-Cai-Chen et al. 2021 (arXiv:2102.06548); Wainwright 2019 (arXiv:1905.06265)
**Verdict**: **CONFIRMED-WEAKER** (correct rate, but the paper achieves a sharper one)

## Our claim
With $\alpha_t = (H+1)/(H+t)$, $H = 1/(1-\gamma)$, optimistic init $Q_0 = 1/(1-\gamma)$, total samples (with $T$ iterations $\times SA$ per-iter samples)
$$T = \frac{C}{(1-\gamma)^4 \varepsilon^2}\log\frac{SA}{(1-\gamma)\delta},\quad \mathbb{P}[\|Q_T - Q^*\|_\infty \le \varepsilon] \ge 1 - \delta.$$
Total complexity $\widetilde O(SA/((1-\gamma)^4\varepsilon^2))$.

## Cross-check
[ARXIV-UNREACHABLE] **Wainwright 2019** ("Stochastic approximation with cone-contractive operators: Sharp $\ell_\infty$-bounds for $Q$-learning") proves $\widetilde O(SA/((1-\gamma)^5\varepsilon^2))$. **Li-Cai-Chen-Wei-Chi 2021** ("Sample Complexity of Asynchronous Q-Learning: Sharper Analysis and Variance Reduction", arXiv:2006.03041 / 2102.06548) sharpens to $\widetilde O(SA/((1-\gamma)^4\varepsilon^2))$ for synchronous QL with rescaled linear step sizes (their Theorem 1). The minimax-optimal rate is $\widetilde O(SA/((1-\gamma)^3\varepsilon^2))$ achieved by **variance-reduced QL** (Wainwright 2019 Thm 4 — VR-QL — matches the model-based lower bound of Azar-Munos-Kappen 2013).

## Comparison
- **Assumptions**: match (generative model, finite tabular MDP, synchronous updates).
- **Constants**: $(1-\gamma)^{-4}$ matches Li et al. 2021 sharper analysis. Note this is **not** the minimax-optimal $(1-\gamma)^{-3}$, which requires variance reduction.
- **Scope**: vanilla synchronous QL (not VR-QL). Correct.
- **Technique**: standard recursive error bound + Azuma-Hoeffding union bound across coordinates.

## Verdict
**CONFIRMED**. Matches Li-Cai-Chen-Wei-Chi 2021 Theorem 1 in rate. Note we are CONFIRMED-WEAKER relative to the variance-reduced minimax rate of $(1-\gamma)^{-3}$, but that requires a different algorithm (VR-QL). For vanilla synchronous QL the $(1-\gamma)^{-4}$ rate is sharp (Wainwright 2019 Thm 1 lower bound).
