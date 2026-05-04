# D7: Depth separation, exponential width 2-layer ReLU

**Source claimed**: Eldan & Shamir 2016 (1512.03965) / Daniely 2017 (1702.08489).

**Local proof**: Two theorems.
- Thm A: $f^*(x) = \frac{1}{\sqrt{2d}}(\|x\|^2-d)$ requires $m\ge\Omega(\sqrt{d})$ (warm-up, fully rigorous).
- Thm B: $f^*(x) = \mathbf{1}[\|x\|^2\le d]$ requires $m \ge \exp(\Omega(\sqrt{d}\log d))$. Uses Hermite spectrum + Funk-Hecke + Cauchy-Schwarz bottleneck.

**Literature**:
- Eldan-Shamir 2016 prove that there exists a 3-layer-computable function on $\mathbb{R}^d$ that requires exponential width $e^{\Omega(d)}$ to approximate by 2-layer networks (under suitable activation classes including ReLU). Their counterexample is a radial function defined via specific oscillating Bessel-like primitives.
- Daniely 2017 sharpens to a clean ReLU-specific bound: 2-layer ReLU networks of width $\le e^{c\sqrt{d}}$ cannot approximate certain radial functions in $L_2(\mathcal{N}(0,I_d))$.
- Safran-Shamir 2017 (arXiv 1610.09887) prove the **ball indicator** is hard for 2-layer ReLU networks at exponential width — *exactly the function used in the local proof*.

**Verdict**: REPRODUCED (matches Safran-Shamir 2017 / Daniely 2017 sketch). The local proof's "energy of ball indicator at degree $\Theta(\sqrt{d})$" estimate is correctly attributed (the proof itself acknowledges this is "semi-rigorous, requires Plancherel-Rotach Laguerre asymptotics"). The Funk-Hecke / $1/\sqrt{N(d,2k)}$ argument matches Daniely.

**Discrepancies**: The local proof gets $\exp(\Omega(\sqrt{d}\log d))$ which is *stronger* than Eldan-Shamir's original $e^{\Omega(d)}$? No: Eldan-Shamir get exponential in $d$ for a more sophisticated function; Safran-Shamir / Daniely get $\exp(\sqrt{d})$ for the ball indicator. The local rate matches Safran-Shamir. Acceptable.

**Honest classification**: A-class historical; the local proof is faithful but explicitly conditional on the Laguerre energy estimate (which appears in literature but is not derived from scratch).
