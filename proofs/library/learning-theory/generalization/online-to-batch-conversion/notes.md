# Notes: Online-to-Batch Conversion

## Proof technique
The winning route (Route 3) combines a direct regret decomposition argument with a convex refinement. The core technique is exploiting the sequential independence structure of online learning: since $h_t$ is chosen before $z_t$ is revealed, and data are i.i.d., we get $\mathbb{E}[\ell(h_t, z_t)] = \mathbb{E}[R(h_t)]$. This decoupling is the key insight.

## Key steps
1. **Sequential independence**: The online protocol ensures $h_t \perp z_t$ under i.i.d. data, enabling the identity $\mathbb{E}[\ell(h_t, z_t)] = \mathbb{E}[R(h_t)]$.
2. **Worst-case to expected**: The deterministic regret bound holds a.s. for the random sequence, so taking expectations is free.
3. **Comparator relaxation**: $\min_h \sum_t \ell(h, z_t) \leq \sum_t \ell(h^*, z_t)$ connects the empirical best-in-class to the population optimum.
4. **Randomized predictor identity**: $R(\bar{h}_T) = \frac{1}{T}\sum_t R(h_t)$ holds by definition without any convexity.
5. **Jensen refinement** (convex case): Gives the same bound for a deterministic hypothesis.

## Audit result
PASS on first audit round. All steps verified line-by-line. The sign manipulation in the comparator bound (Step 3) was checked carefully. No errors found. Minor note: existence of $h^* = \arg\min R(h)$ is assumed (standard).

## Related results
- **OGD regret bound** (already in library): Provides $R(T) = O(\sqrt{T})$, which combined with this result gives $O(1/\sqrt{T})$ excess risk for stochastic convex optimization.
- **Mirror Descent online regret bound** (already in library): Another source of regret bounds that can be converted via this result.
- **SGD convergence rates** (various in library): The online-to-batch conversion provides an alternative route to SGD convergence by viewing SGD as an online algorithm.
- **Rademacher generalization bound** (already in library): An alternative approach to generalization that goes through complexity measures rather than online learning.
- **Cesa-Bianchi et al. 2004** also proves a high-probability version using Markov's inequality or more refined concentration.
