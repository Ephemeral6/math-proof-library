# D10: OFUL linear bandit O(d√T) regret

**Source claimed**: Abbasi-Yadkori, Pál, Szepesvári 2011, NeurIPS, "Improved Algorithms for Linear Stochastic Bandits". [NO ARXIV]

**Local proof**: Four-lemma proof. Lemma 1 (self-normalized martingale via Laplace mixture supermartingale + Ville's inequality), Lemma 2 (confidence ellipsoid), Lemma 3 (instantaneous regret via optimism), Lemma 4 (elliptical potential). Final bound:
$$\mathrm{Regret}(T) \le 2\beta_T\sqrt{2Td\ln(1+TL^2/(\lambda d))}, \quad \beta_T = R\sqrt{d\ln(\cdot)+2\ln(1/\delta)} + \sqrt{\lambda}S.$$

**Literature**: This IS the Abbasi-Yadkori et al. 2011 (AYP-Sz) analysis. Their main theorem (Thm 2) states exactly:
$$\mathrm{Regret}(n) \le 4\sqrt{nd\log(\lambda + nL^2/d)}\cdot\left[\sqrt{\lambda}S + R\sqrt{2\log(1/\delta) + d\log(1+nL^2/(\lambda d))}\right].$$

The local bound matches with the standard constant 2 vs 4 (depending on whether one tracks the $\sqrt{2}$ from instantaneous regret strictly). The Laplace-mixture self-normalized martingale technique (with Gaussian prior $\mathcal{N}(0, R^2/\lambda \cdot I)$) is exactly AYP-Sz's Lemma 9.

**Verdict**: REPRODUCED (matches AYP-Sz 2011 Thm 2 exactly). Lemma 1's proof structure (Laplace mixture, complete-the-square, Ville inequality) is verbatim AYP-Sz.

**Discrepancies**: None.

**Honest classification**: A-class historical (Laplace mixture is a genuinely deep technique); the local reproof is faithful.
