# D6: Implicit bias of GD: max margin

**Source claimed**: Soudry, Hoffer, Nacson, Gunasekar, Srebro 2018, JMLR, "The Implicit Bias of Gradient Descent on Separable Data", arXiv 1710.10345.

**Local proof**: Eight steps showing GD on logistic loss with separable data converges in direction to $L_2$-max-margin SVM solution: $w_t/\|w_t\| \to w^*/\|w^*\|$, with $\|w_t\| = \Theta(\log t)$ and $L(w_t) = O(1/t)$. Uses descent lemma, no-finite-critical-points, telescoping with $e^{-m_i}$ exponential decay, and SVM KKT conditions.

**Literature**: Soudry et al. 2018 prove exactly this (their Theorem 3): under separability + smoothness, GD with constant step size converges in direction to the max-margin (hard-margin SVM) classifier. Their proof structure matches: (i) loss decay $O(1/t)$, (ii) margin growth $\log t$, (iii) iterate $w_t = \log(t) w^* + O(\log\log t)$ identification with KKT.

**Verdict**: REPRODUCED (matches Soudry et al. 2018 Thm 3). The key rates ($L(w_t)\sim 1/t$, $\|w_t\|\sim\log t$, $m_{\min}\sim\log t$) and the SVM-KKT identification mechanism are exactly Soudry's. The local proof omits the $O(\log\log t)$ second-order correction Soudry et al. derive but matches the leading-order result.

**Discrepancies**: Minor — local Step 7 KKT derivation is sketchier than Soudry's (which carefully handles the residual $r_T$). Substantively correct.

**Classification**: A-class historical; this paper opened the implicit-bias line. The local reproof is faithful.
