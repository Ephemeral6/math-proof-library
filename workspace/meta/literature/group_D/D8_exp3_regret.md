# D8: EXP3 adversarial bandit O(√(KT log K)) regret

**Source claimed**: Auer, Cesa-Bianchi, Freund, Schapire 2002, SIAM J. Computing, "The Nonstochastic Multiarmed Bandit Problem". [NO ARXIV]

**Local proof**: Standard exponential-weights potential argument with importance-weighted estimators. Five steps: (1) unbiasedness, (2) exp-weights potential bound, (3) variance control $\le K/(1-\gamma)$, (4) mixing cost $\gamma T$, (5) parameter tuning $\eta=\sqrt{\ln K/(KT)}, \gamma = K\eta$ giving $\mathbb{E}[\mathrm{Regret}] \le 3\sqrt{KT\ln K}$.

**Literature**: This is the canonical EXP3 analysis from Auer et al. 2002. Modern textbook treatments (Cesa-Bianchi & Lugosi 2006, "Prediction, Learning, and Games", Ch. 6; Lattimore-Szepesvári 2020 "Bandit Algorithms", Ch. 11) present essentially this same proof, sometimes with $\gamma = 0$ (no explicit exploration mixing) and a sharper constant via $e^{-x} \le 1 - x + x^2/2$ used here exactly. The local constant 3 matches the standard textbook value.

**Verdict**: REPRODUCED (textbook). Identical to Auer et al. 2002 / Cesa-Bianchi-Lugosi 2006 exposition.

**Discrepancies**: None.

**Honest classification**: B/C-class textbook material. Mis-classified as A-class research.
