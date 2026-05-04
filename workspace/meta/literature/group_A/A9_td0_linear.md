# A9: TD(0) Linear Function Approximation O(1/T)

**Proof path**: `proofs/research/optimization/convergence/td0-linear-approximation-convergence/`
**Claimed source**: Bhandari-Russo-Singal 2018 (arXiv:1806.02450); Srikant-Ying 2019 (arXiv:1902.00923)
**Verdict**: **CONFIRMED**

## Our claim
TD(0) with linear features $\|\phi(s)\|\le 1$, i.i.d. sampling, step size $\alpha_t = c/(c+t)$:
$$\mathbb{E}[\|\theta_T - \theta^*\|^2] \le \frac{C}{T},\quad C = O(\sigma^2/\mu^2),\, \mu = (1-\gamma)\lambda_{\min}(\Phi^T D_\pi\Phi).$$

## Cross-check
[ARXIV-UNREACHABLE] Bhandari–Russo–Singal 2018 ("A Finite Time Analysis of Temporal Difference Learning With Linear Function Approximation", COLT/JMLR), Theorem 2: for i.i.d. sampling with constant or rescaled-linear step size $\alpha_t = c/(c+t)$, mean-square error of the projected/averaged TD iterate is $O(1/T)$ with constant $\propto \sigma^2/\mu^2$ where $\mu \ge (1-\gamma)\lambda_{\min}(\Phi^T D_\pi\Phi)$. Srikant–Ying 2019 (arXiv:1902.00923) extends to Markovian sampling.

## Comparison
- **Assumptions**: match (i.i.d. samples, $\|\phi\|\le 1$, full-rank features). The "i.i.d." assumption is the easier setting; under Markovian sampling Srikant-Ying needs additional mixing conditions.
- **Constants**: $C = O(\sigma^2/\mu^2)$ matches Bhandari et al. 2018 Theorem 3.
- **Scope**: matches.
- **Technique**: drift-style analysis using positive definiteness of $A = \Phi^T D_\pi(I - \gamma P_\pi)\Phi$ with $\lambda_{\min}(A_{\mathrm{sym}}) \ge (1-\gamma)\lambda_{\min}(\Phi^T D_\pi\Phi)$ — exactly the BRS 2018 approach.

## Verdict
**CONFIRMED**. Faithful reproduction of Bhandari-Russo-Singal 2018 Theorem 3 (i.i.d. case). No novelty.
