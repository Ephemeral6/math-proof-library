# D3: Denoising Score Matching Equivalence

**Source claimed**: Vincent 2011, Neural Computation, "A Connection Between Score Matching and Denoising Autoencoders". [NO ARXIV]

**Local proof**: Direct expansion of $J_\text{ESM}$ and $J_\text{DSM}$, score-of-mixture identity $\nabla_x \log q_\sigma(x) = \mathbb{E}_{p(y|x)}[\nabla_x\log p(x|y)]$, conclude $J_\text{ESM} = J_\text{DSM} + C$.

**Literature**: This is exactly Vincent 2011's Proposition 1 (the ESM-DSM equivalence), with the same proof structure. Vincent's argument is also a Leibniz/DCT exchange + Bayes' rule. The local proof matches Vincent's almost line-by-line, except Vincent uses general transition kernels $p(x|y)$ while the local version specializes to Gaussian (which is the case used in modern diffusion).

**Verdict**: REPRODUCED (exact match to Vincent 2011 Prop 1). This is C-class textbook material in the diffusion-models era.

**Discrepancies**: None.

**Honest classification**: Foundational lemma underlying all score-based generative modeling; should be filed as B/C-class library infrastructure, not A-class research.
