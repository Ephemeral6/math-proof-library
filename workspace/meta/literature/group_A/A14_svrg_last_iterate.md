# A14: SVRG Non-SC Last-Iterate $\Theta(\log m)$ Gap

**Proof path**: `proofs/research/optimization/convergence/svrg-non-sc-last-iterate-gap/`
**Claimed source**: Allen-Zhu-Yuan 2016 ICML (arXiv:1506.01972); Harvey et al. 2019 (arXiv:1810.03415)
**Verdict**: **NOVEL** (publication candidate)

## Our claim
For non-SC SVRG with $\eta = 1/(3L)$ and epoch length $m$: the **last iterate** $x_T$ within epoch $S$ satisfies
$$\mathbb{E}[f(x_T) - f^*] = \Theta\!\left(\frac{\log m \cdot LD^2}{Sm}\right)$$
**not** $\Theta(LD^2/(Sm))$. The standard snapshot rate is $O(LD^2/(Sm))$ — there is a literal $\Theta(\log m)$ separation between snapshot and last iterate.

Upper bound proved rigorously; lower bound via reduction to the Harvey-Liang-Liaw-Randhawa 2019 SGD non-SC last-iterate lower bound.

## Cross-check
[ARXIV-UNREACHABLE] Allen-Zhu–Yuan 2016 ("Improved SVRG for Non-Strongly-Convex or Sum-of-Non-Convex Objectives"): the published rate is on the **snapshot** $\tilde x_s$, namely $O(LD^2/(Sm))$. They do not analyze the within-epoch last iterate. **Harvey et al. 2019** ("Tight analyses for non-smooth stochastic gradient descent", COLT/SIOPT) prove $\Omega(\log T/\sqrt T)$ lower bound on the last iterate of vanilla SGD on convex Lipschitz, contrasting with $O(1/\sqrt T)$ for the average iterate.

The transfer of the Harvey-style log-gap to the SVRG setting is, to my knowledge, **not in the published literature in this exact form**. The reduction-based lower bound argument (treating SVRG inside an epoch as SGD with biased variance) is plausible and natural.

## Comparison
- **Assumptions**: standard non-SC + $L$-smooth + sum-of-individual-functions. Matches.
- **Constants**: matches snapshot rate to within constants; the $\log m$ factor on top of last iterate is the new claim.
- **Scope**: NEW — the literature analyzes the snapshot, not the within-epoch last iterate.
- **Technique**: upper bound is Allen-Zhu-Yuan style epoch progression + Harvey-style averaging argument; lower bound is a reduction to the SGD lower bound.

## Verdict
**NOVEL**. The $\Theta(\log m)$ separation between SVRG's snapshot and last iterate is, as far as I can determine, not in the published literature. The argument is honest (upper bound + matching lower-bound reduction). **This is a candidate for a short note / SIOPT communication / NeurIPS workshop paper.**

**Action item**: this should be flagged as a publication candidate.
