# C9 — ULA KL convergence under LSI

**Path**: `proofs/research/probability/sampling/ula-kl-convergence-lsi/`
**Verdict**: **MATCH (Vempala-Wibisono 2019 Theorem 1)**

## Our statement
For $\pi \propto e^{-f}$ on $\mathbb{R}^d$ with $f$ being $L$-smooth and $\pi$ satisfying $\alpha$-LSI, the ULA iterates $x_{k+1} = x_k - h\nabla f(x_k) + \sqrt{2h}\,\xi_k$ ($\xi_k \sim \mathcal{N}(0, I_d)$ i.i.d.) with $h \le \alpha/(4L^2)$ satisfy:
$$
\mathrm{KL}(\rho_k\|\pi) \le e^{-\alpha h k}\,\mathrm{KL}(\rho_0\|\pi) + \frac{8 h d L^2}{\alpha}.
$$

## Literature

### Vempala-Wibisono 2019 (arXiv:1903.08568, NeurIPS) — "Rapid Convergence of the Unadjusted Langevin Algorithm: Isoperimetry Suffices" (also appeared as "Log-Sobolev Suffices" in v1)
- **Main result (Theorem 1)**: Under $L$-smooth $f$ and $\alpha$-LSI, ULA with step $h \le \alpha/(4L^2)$ satisfies
$$
\mathrm{KL}(\rho_k\|\pi) \le e^{-\alpha h k}\,\mathrm{KL}(\rho_0\|\pi) + \frac{8 h d L^2}{\alpha}.
$$
- **Identical to our bound, with the same constant 8.**
- They do NOT assume convexity, only the LSI (which can hold for non-log-concave distributions).

## Comparison

| Aspect | VW 2019 | OUR C9 |
|---|---|---|
| Assumptions | $L$-smooth, $\alpha$-LSI | identical |
| Step-size | $h \le \alpha/(4L^2)$ | identical |
| Contraction rate | $e^{-\alpha h}$ | identical |
| Bias term | $8 h d L^2 / \alpha$ | identical |
| Technique | Girsanov + Langevin contraction + LSI gradient bound | identical (Route 2) |

The proof's Route 2 (Girsanov + KL Decomposition) is exactly Vempala-Wibisono's approach: 
1. Lemma 1 (Girsanov for path-KL between ULA and Langevin),
2. Lemma 2 (Langevin contraction in KL via LSI: $\frac{d}{dt}\mathrm{KL} = -\mathrm{FI} \le -2\alpha\mathrm{KL}$),
3. Lemma 3 (discretization moment bound),
4. one-step recursion $\mathrm{KL}(\rho_{k+1}\|\pi) \le e^{-\alpha h}\mathrm{KL}(\rho_k\|\pi) + 2L^2 dh^2$,
5. Telescoping → final bound.

The constant 8 is exactly VW's constant. The LSI-gradient bound $\mathbb{E}_\rho\|\nabla f\|^2 \le 2L d + (4L^2/\alpha)\mathrm{KL}(\rho\|\pi)$ in §3 of VW is reproduced in remark 2.

## Verdict

**MATCH.** This is a faithful reproduction of Vempala-Wibisono 2019 Theorem 1 with identical constants and identical proof technique. The Auditor's flagged minor issues at the top of the file (Bakry-Emery $\alpha \le 2L$, constant 8 verification, KL chain rule, Novikov) are addressed in the proof's technical remarks. No discrepancy.

This is an A-class paper (NeurIPS 2019) but the proof itself is faithful to the original — no novelty claimed.
