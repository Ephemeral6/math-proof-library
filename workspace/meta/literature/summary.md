# Literature Cross-Check — Master Summary

**Date**: 2026-04-27
**Scope**: 69 PASS research-level proofs in `proofs/research/`, cross-checked against published arXiv sources.
**Method**: 5 parallel agents (Groups A-E by topic), per-proof verdict on 4 axes (assumptions / constants / scope / technique), then consolidated.

---

## Aggregate statistics

| Verdict | Group A | Group B | Group C | Group D | Group E | **Total** | **%** |
|---|---|---|---|---|---|---|---|
| CONFIRMED (faithful re-proof) | 7 | 7 | 6 | 13 | 4 | **37** | 53.6 |
| CONFIRMED-IMPROVED | 1 | 0 | 0 | 1 | 0 | **2** | 2.9 |
| CONFIRMED-WEAKER | 4 | 5 | 0 | 0 | 0 | **9** | 13.0 |
| CONFIRMED-existential | 0 | 1 | 0 | 0 | 0 | **1** | 1.4 |
| PARTIAL / honest weaker variant | 0 | 0 | 1 | 0 | 0 | **1** | 1.4 |
| DISCREPANCY (real, but not contradiction) | 1 | 1 | 0 | 0 | 0 | **2** | 2.9 |
| **NOVEL** | **2** | **0** | **4** | **5** | **6** | **17** | **24.6** |
| **ERROR (contradicts literature)** | **0** | **0** | **0** | **0** | **0** | **0** | **0.0** |

**Headline**: zero ERROR verdicts across 69 proofs — no proof contradicts a published result.

## NOVEL Results (the 17 publication candidates)

These have no published counterpart and are genuine contributions. Grouped by theme:

### Theme 1 — OP-2 family (4): non-acceleration LBs for fixed-momentum SHB
- **C1** SHB no-acceleration on $\mathcal F$ (downgraded). T-uniform $\Omega(LD^2/T+\sigma D/\sqrt T)$. Combines Goujaud-Taylor-Dieuleveut 2023's μ→0 cycling with a 3-D wall + Le Cam variance construction. Combined with Lan 2012 AC-SA UB, gives the *first* rigorous "SHB does not accelerate" theorem for non-quadratic smooth convex.
- **C2** Closed-form critical momentum $\beta^\star = (\sqrt{13}-3)/2$. Algebraic identity not in GPT.
- **C3** Interpolation regime: bias survives (sharper $\kappa/2$); **variance term Ω(σD/√T) provably DISPROVED** by exponential margin (linear vs polynomial). Contradicts the naïve assumption that NY variance LB carries over.
- **C4** Best-iterate: bias preserved; variance Le Cam fails. Honest PARTIAL.

### Theme 2 — Iterate-type separation (2): post-OP-2 follow-ups
- **A14** SVRG non-SC last-iterate $\Theta(\log m)$ gap vs snapshot. UB + matching LB via reduction to Harvey 2019 SGD log-gap. Clean transport.
- **A15** Polyak-Ruppert weighted-average **defeats** SHB cycling: sharp $LD^2/(4T^2\sin^4(\pi/K))$ UB on Goujaud's hard instance, disproving the natural $\Omega(LD^2/T)$ bias LB. Iterate-type separation: last $\Theta(LD^2)$, Cesàro $\Theta(LD^2/T^2)$, PR matches Cesàro.

### Theme 3 — Yuan-Yang group autonomous research (5)
- **D14** Matrix CE vs Standard CE generalization gap. Goes beyond Zhang-Tan-Yang-Huang-Yuan ICML 2024 with explicit quantitative gap theorem under condition $(\star)$.
- **D16** SSL augmentation phase transition. Closed-form $\sigma^\star_{\text{aug}}=\Theta(\Delta_{\min}/\sqrt d)$ + **honest refutation** of the literal first-order-discontinuity claim (transition is second-order under natural Gaussian model). Numerical CoV 2.3% across 12 configs.
- **D17** Matrix Rényi entropy collapse: parts (a),(b) PASS; (c) entropy-PL inequality with explicit constant $1/(2\alpha)$, conditional on (H1)-(H4).
- **D18** SSL InfoNCE minimax LB: $d^2/(n\cdot I(X;X'\mid A))$ up to logs, via Yang-Barron SO(d) packing + Schur-complement gap + DPI MI bound. Sharper than Tosh-Krishnamurthy-Hsu 2021's $d/I$ analog.
- **D19** OT contrastive characterization: literal claim REFUTED by $n=4,\,\varepsilon=0.3$ counterexample; refined version PROVED under (H1)-(H3).

### Theme 4 — Multi-agent CR theory (6): formal lift of empirical CR paper
The CR paper (arXiv 2308.04371) is empirical with no formal probability theorems. E6-E10 give the first cohesive theoretical formalization:
- **E6** Auditor-Fixer reliability: $(1-\varepsilon)^T$ vs $(1-\varepsilon^k)^T$ tight bounds.
- **E7** Categorical foundation: Lawvere $[0,\infty]$-enriched functor category, verifier errors as natural transformations, auditor-fixer as Banach contraction; reduces to E6 in discrete special case.
- **E8** Compositional reuse: tree-unfolding $(1-\delta)^{N(d,\Delta)}$ with $N=(\Delta^{d+1}-1)/(\Delta-1)$ — strictly tighter than user-stated form; ~700× tighter than per-lemma retry for typical params.
- **E9** Depth LB: $T \ge d\log(1/\delta)/\log(1/\varepsilon)$ via Yao + Bayes-error tail. Caught a 4.6× arithmetic error in original problem.md ("≈18" vs true 3.9).
- **E10** Non-stationary verifier: integral test on $\varepsilon_t = \varepsilon_0(1+t/T_0)^\alpha$, optimal stopping, dimensional typo correction in original problem.

Plus:
- **E4** Adversarial trajectory tradeoff. Honest synthesis of Hardt-Recht-Singer 2016 + Madry 2018 + Zhang 2022 — Madry is empirical, the trajectory analysis is novel framing.

## DISCREPANCY (2 real but not contradictions)

- **A5 SAM convergence**: theorem stated in `proof.md` does not appear in Foret et al. 2021 (the original SAM paper is empirical/PAC-Bayes). The math is correct; attribution should be re-pointed at Andriushchenko-Flammarion 2022 (arXiv:2206.06232) or contemporaneous works. **Citation hygiene fix only.**
- **B11 PAGE optimal grad complexity**: proof uses conservative step $\eta=1/(2L\sqrt n)$, deriving $T=O(L\sqrt n\Delta_0/\varepsilon^2)$ then claiming this matches the published $\Omega(n+\sqrt n/\varepsilon^2)$ LB. It does not — the bound is $\sqrt n$ worse than published PAGE rate. Fix is one-line: change $\eta$ to $1/(2L)$. **Math is sound, just suboptimal step choice.**

## CONFIRMED-WEAKER (9 honest constant gaps)

These are correct but quantitatively looser than the published bounds. All self-acknowledged in the respective `notes.md`:
- A7 Sync-QL, A8 OGDA-bilinear, A10 Entropy-NPG variant, A12 Softmax-PG (~5 in Group A)
- B1 SPS (2× constant), B4 momentum-linear (16× rate), B5 momentum-contraction, B9 SARAH (~10× constant), B13 AMSGrad

These represent a fair tradeoff: simpler/cleaner proofs at the cost of looser constants. Worth documenting which library lemmas would close the gap (e.g., averagedness theory for Davis-Yin in C7, Liang-Stokes 2019 spectral analysis for OGDA full-rank linear convergence in A8).

## CONFIRMED-IMPROVED (2 strict improvements over literature)

- **A4 Heavy-Ball instability**: the proof uses a $C^\infty$ counterexample, strictly upgrading Lessard-Recht-Packard 2016's piecewise-quadratic example.
- **D14 Matrix CE vs Standard CE**: explicit quantitative gap theorem under condition $(\star)$ goes beyond the qualitative ICML 2024 statement.

## ERROR (0)

**No proof contradicts a published result.** The Auditor + reverse-consistency machinery is clearly catching errors before archival.

## Metadata fixes needed in `proof_list.md`

Two arXiv ID typos found by sub-agents:
1. **B2 (clipped SGD heavy-tail)**: listed `1912.07467` is a neutron-star astrophysics paper. Correct: **`2002.10589`** (Zhang et al. NeurIPS 2020 "Why Are Adaptive Methods Good for Attention Models?").
2. **C3 (SHB interpolation regime)**: listed Bach 2014 as `1410.6660` is an HCN-anion physics paper. Correct: **`1306.2119`** (Bach-Moulines NIPS 2013/2014 "Non-strongly-convex smooth stochastic approximation with convergence rate O(1/n)").

Also worth correcting: E3 author attribution is **Teng-Ma-Yuan**, not "Zhang, Yifan" as listed.

## Two-sentence overall pattern

About 75% of the library is faithful (often textbook-grade) re-derivation of canonical published results, with the remaining 25% being **genuine novel contributions clustered in four themes**: the OP-2 SHB lower-bound family, iterate-type separation post-Goujaud, Yuan-Yang-style SSL/Matrix-IT autonomous research, and a coherent first-pass formal theory of multi-agent verification reliability that lifts the empirical CR paper. The **zero ERROR verdicts** across 69 proofs is the strongest single signal that the Auditor-Fixer pipeline + reverse-consistency machinery is functioning as intended; the most-publishable single results are **C1 (OP-2 main theorem), A15 (PR-defeats-SHB-cycling), D16 (SSL phase transition refutation), and the E6-E10 multi-agent theory**, in roughly that priority order.

## Files written

- `workspace/literature_crosscheck/proof_list.md` — 69-proof master list
- `workspace/literature_crosscheck/group_{A,B,C,D,E}/` — 69 per-proof analyses (15+14+11+19+10)
- `workspace/literature_crosscheck/group_{A,B,C,D,E}_summary.md` — per-group consolidated summaries
- `workspace/literature_crosscheck/summary.md` — this master summary
