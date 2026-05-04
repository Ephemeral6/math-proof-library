# D4: NTK infinite-width convergence (Schur + matrix Bernstein)

**Source claimed**: Du et al. 2019 (1810.02054).

**Local proof**: $\|\hat\Theta_m - \Theta^\infty\|_{op} \le C \|\sigma'\|_\infty^2 n \sqrt{\log(n/\delta)/m}$ via Schur product theorem + matrix Bernstein.

**Literature**: Du et al. 2019 prove an analogous concentration: their Lemma 3.1 (and refinements in Arora et al. 2019, "Fine-Grained Analysis of Optimization and Generalization for Overparameterized Two-Layer Neural Networks", arXiv 1901.08584) show $\|H - H^\infty\|_2 \le \epsilon$ with high probability provided $m = \Omega(n^2 \log(n/\delta) / \epsilon^2)$ — equivalent to $\epsilon = O(n\sqrt{\log(n/\delta)/m})$, matching the local bound. The constant scaling with $\|\sigma'\|_\infty^2$ is the standard one. Du et al.'s technique is via Hoeffding row-by-row; the matrix Bernstein + Schur route here is a cleaner alternative used in later NTK papers (e.g., Allen-Zhu-Li-Liang 2019).

**Verdict**: REPRODUCED. Known to literature; the dependence $n/\sqrt{m}$ is the standard rate, possibly suboptimal vs. $\sqrt{n/m}$ which can be obtained with sharper Hanson-Wright concentration (e.g., Mei-Misiakiewicz-Montanari 2022).

**Discrepancies**: None.

**Honest classification**: B-class — standard concentration with off-the-shelf matrix Bernstein. The Schur lemma trick is a known shortcut.
