# D2: Transformer attention Lipschitz

**Source claimed**: Kim, Papamakarios, Mnih 2021 "The Lipschitz Constant of Self-Attention", arXiv 2006.04710 (ICML 2021).

**Local proof**: Three-stage composition giving
$$\mathrm{Lip}(f_i) \le \|W_V\| + \frac{n\|W_V\|\|W_Q W_K^\top\|R^2}{\sqrt{d_k}}, \quad R=\max_j\|X_j\|.$$

**Literature**: Kim et al. show that *standard dot-product self-attention is NOT globally Lipschitz on unbounded domains* (their Theorem 3.1). Their main positive result is for L2-self-attention (a modified variant where $X_iMX_j^\top$ is replaced by $-\|X_i M - X_j M\|^2$), for which they derive a bound of order $O(\sqrt{n}\|W_QW_K^\top\| + \cdots)$.

The local proof bounds dot-product attention but **assumes inputs are bounded** ($R<\infty$). With this caveat, dot-product attention IS locally Lipschitz on a bounded set; the paper does not dispute this — it only objects to global Lipschitzness. The local bound is consistent with what one obtains by combining Step 4 (bilinear softmax score perturbation) with the standard $\frac12$-Lipschitz softmax. The $n/\sqrt{d_k}$ factor is qualitatively the same as Kim et al.'s bounded-domain estimate.

**Verdict**: REPRODUCED (with bounded-input caveat). The result is correctly proved in the bounded-input regime; this is the only regime where dot-product attention has a finite Lipschitz constant. **Discrepancy/clarification**: the proof should explicitly state it bounds the *local* Lipschitz constant on $\{X: \max_j\|X_j\|\le R\}$, not a global Lipschitz constant — Kim et al.'s headline negative result still applies.

**Classification**: This is a B-class technical computation (basically the chain rule + softmax Jacobian); novelty zero.
