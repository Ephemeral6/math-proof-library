# Final Report: Online-to-Batch Conversion

## Result: PASS

## Problem Statement

Prove that if an online learning algorithm achieves worst-case regret $\text{Reg}_T \leq R(T)$, then on i.i.d. data the randomized averaged predictor $\bar{h}_T = \text{Uniform}(h_1, \ldots, h_T)$ satisfies $\mathbb{E}[R(\bar{h}_T)] - R(h^*) \leq R(T)/T$.

## Routes Attempted

| Route | Strategy | Result |
|-------|----------|--------|
| 1 | Direct regret decomposition | Correct, but has mid-proof self-correction |
| 2 | Formal filtration-based argument | Correct, clean and concise |
| 3 | General + convex refinement | Correct, most complete |

## Best Proof: Route 3

Selected for combining a clean general proof with a valuable convex refinement (Jensen-based deterministic averaging).

### Core Argument (4 key steps)
1. **Sequential independence**: $h_t$ depends on $z_1, \ldots, z_{t-1}$ only; with i.i.d. data, $\mathbb{E}[\ell(h_t, z_t)] = \mathbb{E}[R(h_t)]$.
2. **Regret bound in expectation**: Worst-case bound holds a.s., so take expectations.
3. **Comparator relaxation**: $\mathbb{E}[\min_h \sum_t \ell(h, z_t)] \leq T \cdot R(h^*)$, giving $\sum_t \mathbb{E}[R(h_t)] - T R(h^*) \leq R(T)$.
4. **Randomized predictor**: $R(\bar{h}_T) = \frac{1}{T}\sum_t R(h_t)$ by definition, divide by $T$.

### Convex Bonus
Under convexity, Jensen's inequality gives the same bound for the deterministic average $\hat{h}_T = \frac{1}{T}\sum_t h_t$.

## Audit Summary

- **Round 1**: PASS. All steps verified line-by-line. Sign manipulations in the comparator bound checked carefully. No errors found.
- **Minor note**: Existence of $h^* = \arg\min R(h)$ is assumed. Standard and acceptable.

## Difficulty Assessment
- **Rated**: research
- **Actual**: The core argument is elegant but not deeply technical. The difficulty lies in correctly handling the sequential independence and the sign of the comparator bound. Appropriate for a research-level proof library.
