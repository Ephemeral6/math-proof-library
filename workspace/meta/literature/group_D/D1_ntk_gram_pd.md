# D1: NTK Gram matrix positive definiteness

**Source claimed**: Du et al. 2019 (ICML) "Gradient Descent Finds Global Minima of Deep Neural Networks", arXiv 1810.02054.

**Local proof**: `proofs/research/learning-theory/generalization/ntk-gram-matrix-positive-definiteness/proof.md`. Quadratic-form + hyperplane-arrangement adjacency argument. Conclusion: $H^\infty \succ 0$ iff $x_i \neq \pm x_j$ for $i \ne j$ and $\|x_i\|=1$.

**Literature**: Du et al. (1810.02054, ICML 2019) prove exactly this lemma (their Theorem 3.1 / Proposition C.1 in the appendix), with the same hypothesis ($x_i \not\parallel x_j$, unit norms). The proof technique in Du et al. is essentially what is reproduced here: for the 2-layer ReLU NTK $H^\infty_{ij} = \mathbb{E}_w[x_i^\top x_j \mathbf{1}\{w^\top x_i \ge 0, w^\top x_j \ge 0\}]$, $\lambda_{\min}(H^\infty)>0$ when no two inputs are parallel.

**Verdict**: REPRODUCED (exact match). Well-known result in NTK theory; first appeared in Xie-Liang-Song 2017 (arXiv 1611.03131, "Diverse Neural Network Learns True Target Functions") in essentially the same form, popularized by Du et al.

**Discrepancies**: None. The local proof is a clean reproduction.

**Honest classification**: This is a B-class infrastructure lemma underpinning all NTK-convergence results, mis-classified as A-class. The proof technique (hyperplane arrangement + adjacency) is standard; novelty is zero.
