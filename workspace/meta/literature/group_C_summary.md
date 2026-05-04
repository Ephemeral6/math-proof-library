# Group C Literature Cross-Check Summary

**Date**: 2026-04-27
**Owner**: Agent 3
**Scope**: 11 PASS proofs in lower-bounds / convex-analysis / probability / statistics

---

## Verdict tally

| Verdict | Count | Proofs |
|---|---|---|
| **NOVEL** (extension or new result) | 4 | C1, C2, C3, C4 (the entire OP-2 family) |
| **MATCH** (faithful reproduction of canonical paper) | 6 | C5, C6, C8, C9, C10, C11 |
| **PARTIAL / HONEST WEAKER VARIANT** | 1 | C7 (DYS variant with documented discrepancies) |
| **ERROR** | 0 | — |

**No proof is in error.** All claims are rigorous; the OP-2 family (C1-C4) is honestly downgraded from the original problem statements (which were over-broad).

---

## Top novel results

### 1. **C1: SHB no-acceleration on $\mathcal{F}$** (genuinely new lower bound)
First T-uniform $\Omega(LD^2/T + \sigma D/\sqrt T)$ lower bound for stochastic SHB on the Goujaud cycling region $\mathcal{F}$, with explicit constants $c(\beta,\eta) = \kappa(\beta,\eta)/4$ and $c_{NY} = 1/(8\sqrt 2)$. Combined with Lan 2012 AC-SA upper bound $O(LD^2/T^2 + \sigma D/\sqrt T)$, this gives the **first rigorous "SHB does not accelerate" theorem** for non-quadratic smooth convex problems.

### 2. **C2: Closed-form threshold $\beta^\star = (\sqrt{13}-3)/2$**
Sharp threshold for cycling feasibility in the κ→0 limit, attained at $K=3$. Beautiful algebraic identity $(1+c)Q_c(\beta) \ge 0$ extracts a clean closed-form constant from the GPT 2023 cycling inequality. Not in GPT, Ghadimi, or LRP.

### 3. **C3: Bias survives interpolation, variance disproved**
The OP-2 bias $\Omega(LD^2/T)$ extends to the interpolation noise class with sharper constant $\kappa/2$; the variance $\Omega(\sigma D/\sqrt T)$ is **provably impossible** to add — explicit counterexample achieves $\rho^T D^2$ with $\rho = \sigma^2/(L^2+\sigma^2) < 1$ via tuned $(\beta=0, \eta = L/(L^2+\sigma^2))$.

### 4. **C4: Best-iterate bias preserved, variance Le Cam fails**
Bias term constant transfers identically to best-iterate (since every cycling iterate has the same value); variance Le Cam construction fails for best-iterate metric (random walk minimum decays in $T$). Honest PARTIAL PASS labeling.

---

## Discrepancies (none flagged ERROR)

### C7 (DYS variant, four documented gaps)
The proof file's preamble explicitly tabulates four discrepancies vs Davis-Yin 2017:
- Step-size range: $(0, 1/\beta]$ vs $(0, 2/\beta)$;
- Constant: $1/(2\gamma)$ vs $1/(2\gamma\alpha)$;
- Iterate norm: $\|z^0-x^*\|^2$ vs $\|z^0-z^*\|^2$;
- Objective: $f(\bar x^K) + g(\bar y^K) + h(\bar x^K)$ (split) vs $F(\bar x^K)$ (single).

This is exemplary scholarship: not a hidden weakness but a tabled-up-front gap analysis with explanation that the elementary algebraic framework cannot extract the missing 1/α factor (which requires DYS averagedness theory).

### C10 (Double descent bias correction)
The original `problem.md` had bias $\|\beta^*\|^2/(\gamma-1)$, which is wrong. The proof corrects it to the canonical $(\gamma-1)/\gamma \cdot b^2$ matching HMRT 2019. Flagged in a remark.

### Master list arXiv ID error
`proof_list.md` lists Bach 2014 as arXiv:1410.6660, which is actually a physics paper on HCN anion. The correct arXiv ID for "Non-strongly-convex smooth stochastic approximation with convergence rate O(1/n)" by Bach-Moulines is **arXiv:1306.2119**. Not a proof error, but a metadata error in the master list.

---

## OP-2 family novelty — answering "how many of the OP-2 family qualify as NOVEL"

**All 4 of C1, C2, C3, C4 qualify as NOVEL extensions.**

- **C1** is the foundational result: GPT 2023 only handles strongly convex μ > 0; the μ→0 honest restatement with the 3-D wall construction (Goujaud cycling on x-coord + Le Cam on y-coord with quadratic wall) is new.
- **C2** extracts a closed-form threshold not in GPT.
- **C3** characterizes the interpolation regime (bias survives, variance disproved) — neither half is in the literature.
- **C4** extends to best-iterate metric (PARTIAL — bias yes, variance no).

The OP-2 family is internally coherent: each result builds on a well-defined framework (the Goujaud cycling region $\mathcal{F}$, the κ-feasibility constant $\kappa(\beta,\eta)$) and extends it in a different direction (last-iterate vs best-iterate; deterministic vs stochastic; bounded variance vs interpolation noise).

---

## Two-sentence pattern

The OP-2 family (C1–C4) takes the strongly-convex GPT 2023 cycling theorem to its μ→0 limit and combines it with classical Le Cam variance constructions, producing a cluster of novel non-SC SHB lower bounds with explicit constants and honest scoping (each result clearly delineates what it does and does not prove). The convex-analysis/probability/statistics proofs (C5–C11) are faithful reconstructions of canonical results (Davis-Yin, Chambolle-Pock, He-Yuan, Vempala-Wibisono, BRT, double-descent) with no significant discrepancies — the one weakened variant (C7) is documented up front with a four-row gap table.
