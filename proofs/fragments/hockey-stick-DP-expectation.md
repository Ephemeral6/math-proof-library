# Fragment: hockey-stick-DP-expectation

## Statement
Let $\mu, \nu$ be probability measures with $\mu(E) \le e^\varepsilon \nu(E) + \delta$ for all measurable $E$ (i.e., the standard $(\varepsilon, \delta)$-DP indistinguishability). Then for any measurable $f: \mathcal{H} \to [0,1]$:
$$\bigl|\mathbb{E}_\mu[f] - \mathbb{E}_\nu[f]\bigr| \;\le\; (e^\varepsilon - 1) + \delta.$$

## Proof
Define the hockey-stick decomposition $d\mu_1 := \min(d\mu, e^\varepsilon d\nu)$ and $d\mu_2 := (d\mu - e^\varepsilon d\nu)_+$. Then $\mu = \mu_1 + \mu_2$, $d\mu_1 \le e^\varepsilon d\nu$ pointwise, and
$$\mu_2(\mathcal{H}) = \int (d\mu - e^\varepsilon d\nu)_+ = \sup_E\bigl[\mu(E) - e^\varepsilon \nu(E)\bigr] \le \delta.$$
Therefore
$$\mathbb{E}_\mu[f] = \int f\, d\mu_1 + \int f\, d\mu_2 \le e^\varepsilon \mathbb{E}_\nu[f] + \delta.$$
Subtracting $\mathbb{E}_\nu[f]$ and using $f \le 1$: $\mathbb{E}_\mu[f] - \mathbb{E}_\nu[f] \le (e^\varepsilon - 1)\mathbb{E}_\nu[f] + \delta \le (e^\varepsilon - 1) + \delta$. The reverse inequality is symmetric. $\square$

## Source
- `proofs/research/learning-theory/stability/dp-implies-generalization/proof.md` — Lemma 1.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (key step in Dwork-Feldman-Hardt-Pitassi-Reingold-Roth "DP implies generalization")
- **Potential applications**:
  - Differential-privacy-to-generalization conversions
  - Adaptive data analysis (statistical-query lower bounds)
  - Robustness analysis of DP mechanisms
  - Group-DP and Rényi-DP analogues

## Tags
differential-privacy, hockey-stick, post-processing, indistinguishability
