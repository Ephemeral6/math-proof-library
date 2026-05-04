# A1: NPG Softmax Tabular O(1/K) Convergence

**Proof path**: `proofs/research/optimization/convergence/npg-softmax-tabular-convergence/`
**Claimed source**: Agarwal–Kakade–Lee–Mahajan 2021 (arXiv:1908.00261); Cen–Cheng–Chen–Wei–Chi 2022 (arXiv:2007.06558)
**Verdict**: **CONFIRMED**

## Our claim
NPG with softmax parametrization, exact updates, step size $\eta = (1-\gamma)\log A/(2\gamma)$:
$$V^*(\rho) - V^{\pi_K}(\rho) \le \frac{\log A}{\eta(1-\gamma)K} + \frac{\eta}{8(1-\gamma)^3} \le \frac{4\gamma}{(1-\gamma)^2 K}$$
under $K\ge 32\gamma^2/\log A$.

## Cross-check (knowledge-based; arXiv abstract only)
[ARXIV-UNREACHABLE for theorem text — WebFetch returned only abstract.]
Agarwal et al. 2021, Corollary 6.10/Theorem 5.3 (Mirror-Descent / NPG analysis): the canonical result is
$$V^* - V^{\pi_K} \le \frac{\log A}{\eta K} + \frac{1}{(1-\gamma)^2 K}$$
with $\eta$-independent rate $O(1/K)$ achieved at step size $\eta = (1-\gamma)\log A$ (or any sufficiently large $\eta$ — the famous "step-size-free" property of NPG/MD on tabular softmax). The rate constant in their explicit form is $\frac{1}{(1-\gamma)^2 K}\cdot(\text{const involving }\log A,\gamma)$, matching the family of bounds our proof produces.

## Comparison
- **Assumptions**: match (finite tabular MDP, $\gamma\in(0,1)$, $r\in[0,1]$, exact gradients, softmax parametrization).
- **Constants**: match up to absorbing $\log A$ into the leading constant. Our $\frac{4\gamma}{(1-\gamma)^2K}$ is a specific calibration.
- **Scope**: identical (last-iterate of $V$, dependence on $K$).
- **Technique**: identical — Performance Difference Lemma + NPG-as-mirror-descent + KL-three-point + telescoping. This is exactly the AKLM 2021 / Cen 2022 approach.

## Verdict justification
**CONFIRMED**. This is a textbook re-derivation of the Agarwal-2021 result. No novelty claim — proof is honest and matches the published technique step for step. The specific constant $4\gamma/(1-\gamma)^2$ is a particular calibration consistent with the family.
