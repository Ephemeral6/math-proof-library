# D13: Xu-Raginsky MI generalization (incl BZV)

**Source claimed**: Xu-Raginsky 2017 (1705.07809) + Bu-Zou-Veeravalli 2020 (1901.04609).

**Local proof**: Proves the *strictly stronger* BZV per-sample bound first:
$$|\mathbb{E}[R_\mathcal{D}(W) - R_S(W)]| \le \frac{1}{n}\sum_i \sqrt{2\sigma^2 I(W;Z_i)}.$$
Then derives Xu-Raginsky $\sqrt{2\sigma^2 I(W;S)/n}$ as a corollary via Jensen + chain-rule inequality $\sum_i I(W;Z_i) \le I(W;S)$.

**Literature**:
- Xu-Raginsky 2017 (NeurIPS, arXiv 1705.07809): original "Information-theoretic analysis of generalization capability". Their Thm 1 is exactly the XR bound.
- Bu-Zou-Veeravalli 2020 (IEEE JSAIT, arXiv 1901.04609): "Tightening Mutual Information-Based Bounds on Generalization Error". Their Thm 1 is the per-sample (ISMI) bound — the local proof's Theorem 1.

The local proof's construction (DV variational + sub-Gaussian transport lemma + iid chain rule with KL convexity) matches BZV's exposition. Lemma 3 (sum of marginal MI ≤ joint MI under iid inputs) is precisely BZV's key insight; the proof using KL joint convexity is standard.

**Verdict**: REPRODUCED (matches XR 2017 + BZV 2020). The strategy of proving BZV first and deriving XR as corollary is exactly BZV's exposition.

**Discrepancies**: None. The local proof correctly identifies that BZV is strictly tighter (gives a $\sqrt{n}$ improvement when only $k\ll n$ samples influence $W$).

**Honest classification**: A-class for XR; A-class for BZV refinement. Faithful reproduction.
