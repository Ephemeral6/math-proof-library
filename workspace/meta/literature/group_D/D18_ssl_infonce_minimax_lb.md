# D18: SSL InfoNCE minimax lower bound (PARTIAL up to logs)

**Source claimed**: Internal Problem 7.3 — Yang-Barron + Schur-complement. **NO PUBLISHED SOURCE.**

**Local proof**: Under structural assumptions on the augmentation kernel (assumption 2: marginals are $f^*$-independent, only the *coupling* depends on $f^*$):
$$\inf_{f_\theta}\sup_{(f^*,w^*)} \mathbb{E}[\text{risk}] - \text{Bayes} \;\ge\; \frac{C\,d^2}{n\,I(X;X'|A)\cdot \text{polylog}}.$$
Six steps: σ-loss to linear-loss reduction (1/16 factor), Schur complement gap formulation, packing of SO(d) with $\log M \ge cd^2\log(1/\delta)$, MI bound $I(V; \text{samples}) \le n\,I(X;X'|A)$, Fano inequality, assembly.

**Literature search**:
- Yang-Barron 1999 ("Information-theoretic determination of minimax rates of convergence", Annals of Stat): canonical Fano-on-packing minimax framework.
- Tosh-Krishnamurthy-Hsu 2021 (arXiv 2008.10150, "Contrastive learning, multi-view redundancy, and linear models"): give a sample-complexity lower bound for contrastive learning related to mutual information. Their bound is of the form $n \ge \Omega(d/I(X;X'|A))$ — qualitatively similar but the **rate** is $d$ not $d^2$, and the Schur-complement / SO(d)-packing technique is different.
- Saunshi et al. 2019 / Arora et al. 2019 ("A theoretical analysis of contrastive unsupervised representation learning") give upper bounds, not minimax lower bounds.

The **specific** $d^2/(n\,I(X;X'|A))$ rate from a joint adversary (over both $f^*$ and $w^*$, the latter contributing the second factor of $d$ via $\|w^*\|^2 \le d$ scaling) does not appear in published SSL lower-bound literature.

**Verdict**: **NOVEL** (conditional). The combination Yang-Barron Fano framework + SO(d) packing + Schur complement + joint $f^*$-and-$w^*$ adversary giving the $d^2$ rate is a defensibly original contribution. The qualifier "up to logs" (acknowledged in the local writeup) and the specific assumption 2 (marginals $f^*$-independent) are restrictive but reasonable for highlighting *one* mechanism.

**Defensibility as novel**: MEDIUM-HIGH. The proof template (Fano + packing + DPI) is textbook, but:
1. Identifying the right packing (rotations of feature subspace) for SSL with an augmentation kernel.
2. The Schur-complement reformulation of probe error as $w^*{}^\top \Delta w^*$ gap.
3. Achieving the $d^2$ rate (one $d$ from packing, one from probe norm).

These three together do not appear in published SSL theory. Numerical verification (empirical risk·n·I/d² $\in [0.12, 0.19]$ across $d=4..64$, $n=500..5000$) gives empirical support for the rate.

**Caveats**: 
- "Up to log factors" — i.e., $\log(d^2/(nI))$ factor not closed; would need Assouad-type hypercube embedding.
- Assumption 2 (only the coupling depends on $f^*$) is strong — for general SSL it's not satisfied.
- The lower bound matches the *form* of upper bounds in Tosh et al. but not their rate, suggesting either bound could be loose.
