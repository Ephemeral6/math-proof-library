# D15: Spectral gap controls InfoNCE downstream

**Source claimed**: Tan-Zhang-Yang-Yuan ICLR 2024; HaoChen-Wei-Gaidon-Ma 2021 (arXiv 2106.04156, NeurIPS).

**Local proof**: Under spectral gap $\lambda_k - \lambda_{k+1} \ge \delta > 0$, the InfoNCE minimizer $F^*$ satisfies $\|F^* - P_k F^*\|_F^2 \le C(n,\tau)/\delta^2$. Three steps:
- Lemma 1 (cited): InfoNCE-vs-spectral-contrastive approximation, $|\tau \mathcal{L}^{NCE}_\tau(F/\sqrt{c_\tau}) - \mathcal{L}_{\text{spec}}(F) - \alpha| \le \eta(\tau,n,M)$.
- Lemma 2: Coercivity & global minimum $\min\mathcal{L}_{\text{spec}} = -n^2\sum_{i=1}^k \lambda_i^2$ at $F^*_0 = nU_k\Lambda_k^{1/2}$.
- Lemma 3 (transverse sharpness): excess $\ge \delta\|(I-P_k)F\|_F^2$.
Final: $\|F^* - P_kF^*\|_F^2 \le 2\eta/\delta \le C(n,\tau)/\delta^2$.

**Literature**:
- HaoChen-Wei-Gaidon-Ma 2021 (arXiv 2106.04156, NeurIPS): "Provable Guarantees for Self-Supervised Deep Learning with Spectral Contrastive Loss". They define $\mathcal{L}_{\text{spec}}(F) = -2\,\mathrm{tr}(F^\top WF) + \|F^\top F\|_F^2$ and prove Eckart-Young-style optimal-rank-$k$ recovery. Their Thm 4.2 / 4.4 give downstream-task error bounds in terms of spectral gap.
- Tan-Zhang-Yang-Yuan ICLR 2024 ("InfoNCE-Spectral Contrastive Equivalence"): formalizes the InfoNCE-spectral approximation lemma (the local Lemma 1).

The **transverse sharpness $\delta\|B\|_F^2$** (Lemma 3) is a careful Hessian-style argument deriving an *explicit* PL-type lower bound on spectral-loss excess in terms of subspace deviation. HaoChen et al. give similar projection bounds (their Lemma 4.3 / Thm 4.4 are eigenspace alignment bounds via Davis-Kahan), but the local proof uses a more direct quadratic-growth argument.

**Verdict**: REPRODUCED + minor refinement. The Davis-Kahan-style $\sin\Theta \le \|\text{perturbation}\|/\delta$ result (giving $1/\delta^2$) is well-known. The local proof gives a clean, more elementary derivation. The combination "InfoNCE → spectral → eigenspace via gap" is exactly what Tan et al. ICLR 2024 + HaoChen 2021 establish.

**Discrepancies**:
- Local Lemma 3 has a messy bookkeeping issue (Cases 1/2 need handling for $\beta_j^2 > n^2\lambda_j$); resolved at end with conservative $\delta$ vs. $2\delta$ distinction. Substantively correct.
- The final $1/\delta^2$ vs natural $1/\delta$ rate is acknowledged in Remark (i).

**Honest novelty assessment**: This is essentially Tan et al. ICLR 2024 + HaoChen 2021 stitched together with a clean transverse sharpness argument. Marginal novelty in the explicit constant tracking; main result is in the cited literature. Modest contribution.
