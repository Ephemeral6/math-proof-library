# D12: Thompson Sampling O(√(KT log T)) Bernoulli

**Source claimed**: Agrawal & Goyal 2017, JACM, "Near-Optimal Regret Bounds for Thompson Sampling", arXiv 1209.3353.

**Local proof**: Good-event decomposition ($N_k(T) = N_k^{(a1)} + N_k^{(a2)} + N_k^{\text{bad}}$), with Beta-Binomial duality, sub-Gaussian Beta concentration, posterior dominance / inflation lemma (3.1), and Agrawal-Goyal 2013 Lemma 4 imported as a sub-sub-lemma. Final: $\mathcal{R}(T) \le C\sqrt{KT\log T}$.

**Literature**: Agrawal-Goyal 2017 (= arXiv 1209.3353 v3, building on AAAI 2012 / ICML 2013) prove:
- Problem-dependent: $\mathbb{E}[N_k(T)] \le O(\log T/\Delta_k^2 + 1)$ — matches local (3.3).
- Problem-independent: $\mathcal{R}(T) \le O(\sqrt{KT\log T})$ — matches local target.

Their proof structure: posterior dominance (a.k.a. "$p_t/(1-p_t)$" inflation) + per-arm bound + small-gap/large-gap split. The local proof is faithful, with the technical Lemma 4 (the explicit moment bound on $1/p_{(n)}$) imported by name.

**Verdict**: REPRODUCED (matches Agrawal-Goyal 2017 Thm 2). The bound $C\sqrt{KT\log T}$ is one $\sqrt{\log K}$ factor *worse* than the EXP3-style minimax lower bound $\Omega(\sqrt{KT})$ for Bernoulli — this gap (the extra $\sqrt{\log T}$) is a known artifact of TS analysis, only closed by Bubeck-Liu 2013 / Russo-Van Roy 2014 type Bayes regret bounds (which don't apply here as a frequentist statement).

**Discrepancies**: None substantive. Local proof correctly imports the AG 2013 Lemma 4 as a black box.

**Honest classification**: A-class (TS analysis was a genuine breakthrough). Reproof faithful.
