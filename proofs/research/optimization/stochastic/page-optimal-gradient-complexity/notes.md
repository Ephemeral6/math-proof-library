# Notes: PAGE Optimal Gradient Complexity

## Proof technique
Route 3 (Unrolled Recursion) won — instead of tracking variance via a Lyapunov function (STORM-style) or within epochs (SPIDER-style), the proof unrolls the variance recursion to get an explicit geometric-decay formula, then swaps summation order to bound the total variance. This reveals the structural reason for PAGE's efficiency: Bernoulli resets act as exponential memory decay with effective horizon O(1/p) = O(√n).

## Key steps
1. **Variance recursion:** $V_{t+1} \leq (1-p)V_t + \frac{L^2\eta^2}{b'}\mathbb{E}[\|g_t\|^2]$ — the (1-p) contraction from probabilistic resets is the key difference from SPIDER.
2. **Unroll + swap:** $\mathcal{V} \leq \frac{L^2\eta^2}{pb'}\mathcal{H} = \frac{1}{4n}\mathcal{H}$ — geometric series bounded by 1/p.
3. **Self-absorption:** Descent lemma's negative $\|g_t\|^2$ term absorbs the variance's $\|g_t\|^2$ dependence. Condition: $1 - L\eta - 1/(4n) > 0$.

## Audit result
PASS in 1 round. All 5 components VALID. 11 numerical checks passed. Constants fully traced (4 = 2 × 2 from polarization and step size).

## Related results
- **SPIDER** (proofs/research/optimization/stochastic/spider-nonconvex-gradient-complexity/): Uses deterministic epoch structure with inner loop of length √n. PAGE replaces this with random Bernoulli resets.
- **STORM** (proofs/research/optimization/stochastic/storm-nonconvex-convergence/): Uses momentum-based recursion with parameter a. PAGE uses p (reset probability) instead, and has no additive σ² noise in finite-sum setting.
- **SVRG** (proofs/library/optimization/stochastic/svrg-linear-convergence-abc-framework/): The original epoch-based variance reduction. PAGE can be seen as an epoch-free generalization.

## Key insight
PAGE unifies SPIDER (deterministic epochs) and STORM (momentum + single-sample) through a probabilistic mechanism: at each step, flip a coin to decide between full gradient reset and SPIDER-style correction. The analysis is cleaner because the Bernoulli structure gives a natural (1-p) contraction in the variance recursion, whereas SPIDER needs epoch-level telescoping.

## Modification from original statement
The original PAGE paper uses minibatch resets (size b = √n), but for clean analysis without bounded variance assumption, full gradient resets (b = n) are used. This does NOT affect the complexity: reset cost is amortized at p·n = √n per step, same as correction cost.
