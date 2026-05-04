# Fragment: bregman-three-point-kl

## Statement
For probability distributions $p, q, r$ on a finite set $\mathcal{A}$ (with full support):

$$\sum_a (p(a) - r(a))(\log q(a) - \log r(a)) \;=\; \mathrm{KL}(p\|r) - \mathrm{KL}(p\|q) + \mathrm{KL}(r\|q).$$

This is the standard Bregman three-point identity for the negative entropy $\phi(p) = \sum_a p(a)\log p(a)$ (whose Bregman divergence is KL).

## Proof
Direct expansion. The LHS:
$$\sum_a p \log q - \sum_a p \log r - \sum_a r \log q + \sum_a r \log r.$$
The RHS:
$$\bigl[\sum p\log p - \sum p\log r\bigr] - \bigl[\sum p\log p - \sum p\log q\bigr] + \bigl[\sum r\log r - \sum r\log q\bigr]$$
$$= \sum p\log q - \sum p\log r + \sum r\log r - \sum r\log q.$$
The two are identical. $\square$

Equivalent form via Bregman geometry: $\langle \nabla\phi(q) - \nabla\phi(r), p - r\rangle = D_\phi(p,r) - D_\phi(p,q) + D_\phi(r,q)$.

## Source
- `proofs/research/optimization/convergence/npg-softmax-tabular-convergence/proof.md` — Phase 3, "Three-Point Identity for KL Divergence" (Remark before Lemma 3).

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (foundational for the per-state mirror descent bound in NPG analysis)
- **Potential applications**:
  - Any mirror descent / online mirror descent analysis using KL regularization
  - Natural policy gradient (NPG), TRPO, PPO regret bounds
  - Multiplicative weights / Hedge regret bounds
  - Information-geometric proximal methods
  - PAC-Bayes / online-to-batch arguments using KL

## Tags
bregman, three-point, KL, mirror-descent, entropy
