# Notes: Bellman Optimality Contraction and Uniqueness

## Proof technique
Route 1 (direct contraction via max-nonexpansiveness) was selected. The proof isolates the key algebraic fact -- that the max operator is nonexpansive -- then combines it with probability normalization to establish the contraction. The Banach fixed-point theorem delivers existence, uniqueness, and the convergence rate in one stroke.

## Key steps
1. **Max-nonexpansiveness lemma:** $|\max f - \max g| \leq \max |f - g|$, proved by a symmetric two-line argument.
2. **Contraction bound:** Cancel the reward term, apply triangle inequality with non-negative transition probabilities, apply the lemma, then use $\sum_{s'} P(s'|s,a) = 1$.
3. **Banach FPT:** Finite-dimensional space is complete; contraction constant $\gamma < 1$; conclude unique fixed point and geometric convergence.

## Audit result
PASS. All steps verified line-by-line with no gaps or errors. Key checks included:
- Correctness of the max-nonexpansiveness argument in both directions
- Proper use of probability normalization
- Applicability of Banach FPT (self-map, complete space, strict contraction)
- Validity of inductive convergence rate argument

## Related results
- **Bellman policy evaluation operator** $\mathcal{T}^\pi Q(s,a) = r(s,a) + \gamma \sum_{s'} P(s'|s,a) \sum_{a'} \pi(a'|s') Q(s',a')$ is also a $\gamma$-contraction (simpler proof since there is no max).
- **Entropy-regularized Bellman operator** (soft VI / SAC): also a contraction, proved in our library at `proofs/optimization/convergence/entropy-regularized-value-iteration/`.
- **NPG softmax convergence**: uses the Bellman optimality structure, proved at `proofs/optimization/convergence/npg-softmax-tabular-convergence/`.
- **Weighted sup-norm contraction** (Hernandez-Lerma & Lasserre 1996): extends to countable state spaces with unbounded rewards using Lyapunov weight functions (explored in Route 3).
- The contraction rate $\gamma$ is tight: there exist MDPs where $\|\mathcal{T}^*Q_1 - \mathcal{T}^*Q_2\|_\infty = \gamma\|Q_1 - Q_2\|_\infty$.
