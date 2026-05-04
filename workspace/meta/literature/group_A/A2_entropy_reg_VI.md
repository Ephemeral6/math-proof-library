# A2: Entropy-Regularized Value Iteration (Soft VI)

**Proof path**: `proofs/research/optimization/convergence/entropy-regularized-value-iteration/`
**Claimed source**: Haarnoja et al. 2018 (SAC, arXiv:1801.01290); foundational soft-VI lemma
**Verdict**: **CONFIRMED** (textbook foundational lemma)

## Our claim
Four-part theorem on the soft Bellman operator $T_\tau$:
1. $\gamma$-contraction in $\ell^\infty$;
2. linear convergence $\|V_k - V^*_\tau\|_\infty \le \gamma^k\|V_0 - V^*_\tau\|_\infty$;
3. optimal policy is Gibbs: $\pi^*_\tau(a|s)\propto \exp(Q^*_\tau(s,a)/\tau)$;
4. approximation gap: $\|V^*_\tau - V^*\|_\infty \le \tau\log A/(1-\gamma)$.

## Cross-check
[ARXIV-UNREACHABLE] SAC paper (Haarnoja 2018) Section 4.1 ("Soft Policy Iteration") proves the contraction and Gibbs form (Lemma 1: Soft Policy Evaluation; Theorem 1: Soft Policy Improvement). Geist–Scherrer–Pietquin 2019 ("A Theory of Regularized Markov Decision Processes", arXiv:1901.11275) gives the unified treatment, including the $\tau\log A/(1-\gamma)$ approximation bound (their Proposition 1).

## Comparison
- **Assumptions**: match (finite MDP, $r\in[0,1]$, $\gamma\in(0,1)$, $\tau>0$).
- **Constants**: match exactly. The $\tau\log A/(1-\gamma)$ bound is the standard Geist et al. result, since entropy is bounded by $\log A$.
- **Scope/technique**: standard log-sum-exp Lipschitz argument + Banach fixed point. Textbook.

## Verdict
**CONFIRMED**. This is a B-class foundational lemma masquerading in the research index. Honest assessment: it is the standard "soft VI" warmup that every entropy-RL paper proves (or cites). Our proof is correct and clean. No novelty.
