# A5: SAM Convergence to Flat Minima

**Proof path**: `proofs/research/optimization/convergence/sam-convergence-flat-minima/`
**Claimed source**: Foret et al. 2021 ICLR (arXiv:2010.01412)
**Verdict**: **DISCREPANCY** — bound is correct in form but wrong attribution

## Our claim
For $L$-smooth $f$, SAM iterates with $\eta = 1/(2L)$, $\rho \le 1/(2L)$:
$$\min_{0\le t<T}\|\nabla f^{\mathrm{SAM}}(x_t)\|^2 \le \frac{16L(f(x_0) - f^*)}{T} + 12L^2\rho^2$$
With $\rho = \rho_0/\sqrt T$: $O(1/T)$.

## Cross-check
[ARXIV-UNREACHABLE for theorem statement] **Important**: Foret et al. 2021 (the original SAM paper) does NOT prove a non-convex stationary-point convergence theorem. Their paper is empirical and PAC-Bayes-flavored (the "convergence theorem" cited in popular accounts is an upper bound on the SAM objective derived informally). The actual non-convex SAM convergence theorem of the form above appears in **Andriushchenko & Flammarion 2022** (arXiv:2206.06232) and **Mi-Shen-Ren-Chen 2022** ("Make Sharpness-Aware Minimization Stronger", arXiv:2210.06077), as well as Si-Yun 2023.

The bound's structure — descent on $f$ at rate $1/T$ plus an $L^2\rho^2$ bias from the perturbation step — is consistent with Andriushchenko-Flammarion 2022 Theorem 3.1 (they give $\min_t \|\nabla f(x_t)\|^2 \le O(1/T) + O(L^2\rho^2)$, modulo constants).

## Comparison
- **Assumptions**: standard ($L$-smooth, bounded below).
- **Constants**: $16L\Delta_0/T + 12L^2\rho^2$ — these are achievable explicit constants; AF 2022 has different but order-equivalent constants.
- **Scope**: matches the modern SAM convergence theory.
- **Technique**: descent lemma + Young's inequality + bound on perturbation gradient — standard SAM analysis.

## Verdict
**DISCREPANCY (attribution)**: result is correct as a statement about SAM convergence, but **attribution to Foret 2021 is wrong**. Foret 2021 does not contain this theorem; the correct citation is Andriushchenko-Flammarion 2022 (or one of the contemporaneous works). The math itself is fine and matches the literature.

**Action item**: re-attribute in `notes.md` and `RESEARCH_INDEX.md`.
