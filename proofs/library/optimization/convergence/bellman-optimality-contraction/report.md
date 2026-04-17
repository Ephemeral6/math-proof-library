# Final Report: Bellman Optimality Contraction and Uniqueness

## Result: PASS

## Problem Statement

Prove that the Bellman optimality operator $\mathcal{T}^*Q(s,a) = r(s,a) + \gamma \sum_{s'} P(s'|s,a)\max_{a'} Q(s',a')$ is a $\gamma$-contraction in $\|\cdot\|_\infty$ and has a unique fixed point $Q^*$. Conclude that value iteration converges: $\|Q_k - Q^*\|_\infty \leq \gamma^k \|Q_0 - Q^*\|_\infty$.

## Routes Attempted

| Route | Approach | Status |
|-------|----------|--------|
| 1 | Direct contraction via max-nonexpansiveness | Complete, selected as best |
| 2 | Monotonicity + shift property via V-function reduction | Complete |
| 3 | Weighted sup-norm / Lyapunov framework | Complete |

## Best Proof Summary (Route 1)

The proof proceeds in three clean steps:

**Lemma (Max-nonexpansiveness).** $|\max_a f(a) - \max_a g(a)| \leq \max_a |f(a) - g(a)|$. Proved by a symmetric argument: let $a^*$ achieve the max of $f$; then $\max f - \max g \leq f(a^*) - g(a^*) \leq \max|f-g|$, and swap roles.

**Theorem ($\gamma$-contraction).** For any $(s,a)$:
$$|(\mathcal{T}^*Q_1 - \mathcal{T}^*Q_2)(s,a)| \leq \gamma \sum_{s'} P(s'|s,a) |\max_{a'} Q_1(s',a') - \max_{a'} Q_2(s',a')| \leq \gamma \|Q_1-Q_2\|_\infty,$$
using the lemma and $\sum_{s'} P(s'|s,a) = 1$. Taking sup over $(s,a)$ gives the result.

**Theorem (unique fixed point, convergence).** $(\mathbb{R}^{|\mathcal{S}||\mathcal{A}|}, \|\cdot\|_\infty)$ is a Banach space. By the Banach Fixed-Point Theorem, $\mathcal{T}^*$ has a unique fixed point $Q^*$. Iterating the contraction inequality yields $\|Q_k - Q^*\|_\infty \leq \gamma^k \|Q_0 - Q^*\|_\infty$.

## Audit Summary

All steps verified line-by-line. No gaps or errors found. Key checks:
- Max-nonexpansiveness lemma: both directions verified
- Probability normalization correctly applied
- Banach FPT applicability confirmed (complete metric space, self-map, contraction)
- Inductive convergence rate derivation verified

## Source
Bellman 1957 (Dynamic Programming); Puterman 1994 (Markov Decision Processes, Chapter 6)
