# C7 — Davis-Yin 3-op splitting (variant γ ≤ 1/β)

**Path**: `proofs/research/convex-analysis/subgradient/davis-yin-three-operator-splitting-ergodic-variant/`
**Verdict**: **HONEST PARTIAL — proves a documented variant**

## Our statement
For the Davis-Yin three-operator splitting on $\min f(x) + g(x) + h(x)$ with $h$ being $\beta$-smooth:
$$
y^k = \text{prox}_{\gamma g}(z^k),\quad x^k = \text{prox}_{\gamma f}(2y^k - z^k - \gamma\nabla h(y^k)),\quad z^{k+1} = z^k + x^k - y^k,
$$
**Theorem (variant, proved).** For $\gamma \in (0, 1/\beta]$ and all $K \ge 1$:
$$
\widetilde F(\bar x^K, \bar y^K) - F(x^*) \le \frac{\|z^0 - x^*\|^2}{2\gamma K},
$$
where $\widetilde F(\bar x^K, \bar y^K) = f(\bar x^K) + g(\bar y^K) + h(\bar x^K)$ (split-iterate objective).

## Literature

### Davis-Yin 2017 (SIOPT, arXiv:1504.01032) — "A Three-Operator Splitting Scheme and its Optimization Applications"
- Original DYS paper. Proves convergence for $\gamma \in (0, 2/\beta)$ (full range).
- Ergodic rate: $F(\bar x^K) - F(x^*) \le \|z^0-z^*\|^2 / (2\gamma\alpha K)$ where $\alpha = 2 - \gamma\beta$ (from averagedness coefficient).
- Uses operator-theoretic (averagedness) framework.

## Comparison: OUR variant vs DY 2017 (ORIG)

| Aspect | DY 2017 (ORIG) | OUR (VAR) |
|---|---|---|
| Step-size range | $\gamma \in (0, 2/\beta)$ | $\gamma \in (0, 1/\beta]$ |
| Constant | $1/(2\gamma\alpha)$ | $1/(2\gamma)$ |
| Iterate norm | $\|z^0 - z^*\|^2$ | $\|z^0 - x^*\|^2$ |
| Objective | $F(\bar x^K)$ (single) | $\widetilde F(\bar x^K, \bar y^K)$ (split) |

The proof file **explicitly documents these four discrepancies in a table** at the top, then proves the weakened variant via elementary algebra (subgradient inequalities + descent lemma + telescoping).

The four discrepancies arise because the elementary algebraic framework cannot extract:
1. The $\gamma$ range extension to $(1/\beta, 2/\beta)$ — needs DYS averagedness.
2. The $1/\alpha$ improvement — needs $(\alpha/2)$-averaged contraction.
3. Closing the $g(\bar y^K)$ vs $g(\bar x^K)$ gap — needs further Lipschitz/summability.
4. The norm $\|z^0-z^*\|^2$ vs $\|z^0-x^*\|^2$ is technical.

## Verdict

**HONEST PARTIAL.** The proof faithfully reconstructs a documented WEAKER variant of DY 2017 Theorem 3.1 using only first-principles convex analysis (no operator averagedness theory). The discrepancies are tabulated up front; the bound (VAR) is not the (ORIG) bound, but is a meaningful intermediate result.

This is exemplary scholarship: the proof's preface explicitly flags the gap and explains why the elementary framework cannot close it. The (ORIG) bound is true (per DY 2017) and verified empirically, but no rigorous derivation in the elementary framework is known.

**Scientific assessment**: This proof is well-documented and rigorous for what it claims; the four-row discrepancy table is an excellent example of honest reporting. Not novel vs literature, but a clean reproduction of a weakened variant.
