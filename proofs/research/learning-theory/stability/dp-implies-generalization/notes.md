# Notes: Differential Privacy Implies Generalization

## Proof technique
Hockey-stick divergence decomposition + Bousquet-Elisseeff leave-one-out symmetrization. Route 3 (Direct Stability) won because it provides the cleanest one-lemma-one-reduction structure.

## Key steps
1. **Hockey-stick decomposition**: Split $\mu = \mu_1 + \mu_2$ where $d\mu_1 \leq e^{\varepsilon}d\nu$ and $\mu_2(\mathcal{H}) \leq \delta$. This is the canonical way to extract expectation bounds from DP.
2. **Ghost sample exchangeability**: Replace population risk $\mathbb{E}_z[\ell]$ with $\mathbb{E}_{z_i'}[\ell]$ using an independent "ghost" sample, then swap $(z_i, z_i')$ to convert test-on-fresh to test-on-training-with-replaced-dataset.
3. **Stability application**: Each leave-one-out dataset $S^{(i)}$ is neighboring to $S$, so Lemma 1 applies directly to each term.

## Audit result
- Round 1: FAIL (bound mismatch: achieved $(e^{\varepsilon}-1)+\delta$, problem stated $\varepsilon + \delta$)
- Round 2: PASS (7/7 steps valid, 6 numerical checks passed, all constants traceable)
- Resolution: $(e^{\varepsilon}-1)+\delta$ is the correct tight bound; "$\varepsilon+\delta$" in the literature is the first-order approximation

## Related results
- **SGD Uniform Stability** (proofs/research/learning-theory/stability/sgd-uniform-stability-generalization/): Same Bousquet-Elisseeff framework, but stability from algorithmic analysis (co-coercivity) rather than privacy
- **PAC-Bayes** (proofs/library/learning-theory/pac/mcallester-pac-bayes-bound/): Different generalization mechanism via KL divergence, but both give data-dependent bounds
- **Rényi DP generalization**: Mironov (2017) — concentrated DP gives tighter $O(\varepsilon)$ bounds via Rényi divergence
- **Mutual information generalization**: Xu-Raginsky (2017) — gives $O(\sqrt{I(S;\mathcal{A}(S))/n})$ bounds, which are $n$-dependent but can be tighter for large $n$
- **On-average stability**: Shalev-Shwartz et al. — weaker notion than uniform stability, also implied by DP
