# Group D — Learning Theory / Generalization — Cross-Check Summary

**Date**: 2026-04-27
**Owner**: Agent 4
**Total proofs cross-checked**: 19 (D1-D19)
**Time used**: within 75-min cap.

---

## Verdict tally

| Verdict | Count | Proofs |
|---|---|---|
| REPRODUCED (faithful re-proof of established result) | 13 | D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13 |
| REPRODUCED + minor refinement | 1 | D15 |
| NOVEL extension / refinement | 1 | D14 |
| NOVEL (autonomous-research) | 4 | D16, D17, D18, D19 |
| ERROR | 0 | — |
| Mis-classified (B/C library, not A research) | 6 | D1, D2, D3, D4, D5, D8, D9 |

No literal-claim ERRORs. D16 and D19 explicitly REFUTE their original Internal-Problem statements and replace them with honest restricted/refined versions — these are flagged within the proofs, not as errors.

---

## Per-proof one-liners

| # | Theorem | Verdict | Source matched |
|---|---|---|---|
| D1 | NTK Gram PD | REPRODUCED | Du et al. 2019 / Xie-Liang-Song 2017 |
| D2 | Transformer attention Lipschitz | REPRODUCED (bounded-input caveat) | Kim et al. 2021 |
| D3 | DSM equivalence | REPRODUCED | Vincent 2011 Prop 1 |
| D4 | NTK ∞-width concentration | REPRODUCED | Du 2019 / Arora 2019 |
| D5 | Quantitative ReLU UAT | REPRODUCED | Yarotsky 2017 |
| D6 | Implicit bias GD max margin | REPRODUCED | Soudry et al. 2018 Thm 3 |
| D7 | Depth separation exp width | REPRODUCED | Safran-Shamir 2017 / Daniely 2017 |
| D8 | EXP3 √(KT log K) | REPRODUCED (textbook) | Auer et al. 2002 |
| D9 | Tweedie's formula | REPRODUCED | Robbins 1956 / Efron 2011 |
| D10 | OFUL d√T regret | REPRODUCED | Abbasi-Yadkori et al. 2011 Thm 2 |
| D11 | Catoni inverse-KL PAC-Bayes | REPRODUCED | Catoni 2007 / Alquier 2016 |
| D12 | TS √(KT log T) Bernoulli | REPRODUCED | Agrawal-Goyal 2017 Thm 2 |
| D13 | Xu-Raginsky + BZV MI bounds | REPRODUCED | XR 2017 + BZV 2020 |
| D14 | Matrix CE < CE generalization | NOVEL extension | Beyond Zhang et al. ICML 2024 |
| D15 | Spectral gap controls InfoNCE | REPRODUCED + minor | Tan et al. ICLR 2024 + HaoChen 2021 |
| D16 | SSL augmentation phase transition | NOVEL (refutes literal, proves second-order) | No published source |
| D17 | Matrix Rényi collapse PL | (a)(b) textbook; (c) NOVEL conditional | No published source |
| D18 | SSL InfoNCE minimax LB | NOVEL (up to logs) | No published source for d² rate |
| D19 | OT contrastive characterization | NOVEL refutation + restricted theorem | Beyond HaoChen 2021 |

---

## Top novel results

Ranked by defensibility:

1. **D16 (SSL augmentation phase transition)**: HIGH defensibility. Closed-form spectrum + honest refutation of "first-order discontinuity" claim + proven $\Theta(\Delta_{\min}/\sqrt{d})$ critical scale with strong numerical agreement (CoV 2.3% across 12 configs). The negative result on (c) is itself a non-trivial finding — the original conjecture was incorrect for the natural Gaussian model.

2. **D18 (SSL InfoNCE minimax LB)**: MEDIUM-HIGH defensibility. The $d^2/(n\,I(X;X'|A))$ rate (vs. Tosh-Krishnamurthy-Hsu 2021's $d/I$ for related setup) is genuinely new, achieved by joint $f^*$-and-$w^*$ adversary + Schur-complement reduction + SO(d) packing. "Up to log factors" caveat is acknowledged.

3. **D19 (OT contrastive characterization)**: MEDIUM defensibility. The counterexample (n=4, ε=0.3 inter-cluster edge giving strict $L_{\text{spec}} \ne L_{\text{OT}}$ minimizers) is a clean, useful negative result clarifying when spectral contrastive ≠ centroid clustering. The restricted positive theorem under (H1)+(H2)+(H3) is mostly textbook (Perron-Frobenius + Eckart-Young).

4. **D14 (Matrix CE < Standard CE)**: MEDIUM defensibility. Beyond Zhang-Tan-Yang-Huang-Yuan ICML 2024 in providing explicit quantitative comparison theorem under condition $(\star)$. The ingredients (matrix Bernstein with intrinsic dim, log-Lipschitz of matrix log) are textbook (Tropp 2015), but the assembled comparison theorem is not in the published paper.

5. **D17 (Matrix Rényi collapse — part (c))**: MEDIUM defensibility. Properties (a)(b) are folklore. Part (c) — entropy-PL inequality with constant $1/(2\alpha)$ near max-entropy state — is plausibly original but heavily conditional on hypotheses (H1)-(H4) that are not derived from any specific SSL loss.

---

## Discrepancies and cautions

| Proof | Issue | Severity |
|---|---|---|
| D2 | Bounds *local* Lipschitz only; should explicitly cite Kim et al.'s headline negative result (no global Lip on unbounded domain). | LOW (caveat needed in title) |
| D6 | Step 7 KKT identification sketchier than Soudry's; omits the $O(\log\log t)$ second-order correction. | LOW (substantively correct) |
| D7 | Energy-of-ball-indicator estimate explicitly "semi-rigorous" (relies on classical Laguerre asymptotics). | MEDIUM (acknowledged) |
| D9 | Substantively duplicates D3 — both prove DSM equivalence via Vincent 2011 identity. Could be merged. | LOW (cataloging issue) |
| D14 | Condition $(\star)$ is restrictive; lower bound on CE gap uses CLT (asymptotic), constants loose. | MEDIUM |
| D15 | Lemma 3 case-analysis bookkeeping has a textually rough patch (Cases 1/2). Substantively correct. | LOW |
| D16 | Result for *very* specific Gaussian-mixture model only; generalization conjectural. | MEDIUM |
| D17(c) | Hypothesis (H3) "geometric coupling" is essentially what should be derived; conditional on it, result holds. | MEDIUM |
| D18 | "Up to log factors" not closed; assumption 2 (only coupling depends on $f^*$) restrictive. | MEDIUM |

**No ERROR verdicts in this group.** The PARTIAL/REFUTED status of D16, D19 reflects honest restatements where the original literal conjectures fail, not errors in the proofs themselves.

---

## Pattern summary

1. **D1-D13 are predominantly reprovings of known results** with no literature-comparison errors. The proof techniques used match the original papers' approaches faithfully. ~10 of 13 should arguably be re-classified as B/C-class library infrastructure (D1, D2, D3, D4, D5, D8, D9 in particular — these are foundational lemmas, not novel research-level theorems). D6, D10, D11, D12, D13 are correctly A-class as faithful re-derivations of historically important results (Soudry implicit bias, OFUL Laplace mixture, Catoni thermodynamic, Agrawal-Goyal posterior dominance, BZV per-sample MI).

2. **D14, D15 are Yuan Yang-group papers (ICML 2024 / ICLR 2024)** examined carefully:
   - D14 goes *beyond* Zhang et al. ICML 2024 with an explicit quantitative MCE-vs-CE gap comparison theorem; defensibly novel as a small theory contribution.
   - D15 is essentially Tan et al. ICLR 2024 + HaoChen 2021 stitched together with a clean transverse-sharpness argument; marginal novelty in explicit constants.

3. **D16-D19 are autonomous-research internal conjectures** with the most interesting outcomes:
   - **D16, D19 honestly REFUTE their literal claims** (no first-order transition for Gaussian mixture; no spectral=OT correspondence without block-diagonality) and replace with restricted positive results. These honest refutations are themselves the most defensible novel contributions.
   - **D17(c), D18** prove conditional novel results under heavy hypotheses; useful as theory-development sketches but not yet algorithm-level guarantees.

4. **A clear failure pattern is absent.** No proof produces a quantitative bound that contradicts the cited paper. The most common minor issue is over-classifying B/C library results as A-class research.

5. **The most surprising single finding**: **D16's part (c) refutation**. The agent system was able to recognize that an internal conjecture about a "first-order phase transition with discontinuous gap" was false under the natural Gaussian model, and reformulate to a continuous second-order transition with explicit $\Theta(\Delta_{\min}/\sqrt{d})$ scaling — backed by tight numerical agreement (CoV 2.3% across 12 configurations). This is exactly the kind of "honest negative result" that an autonomous-research system should be expected to deliver but rarely does.

---

## Counts vs. claims

- All 19 proofs from `proof_list.md` Group D were located in the expected paths and successfully read.
- All 19 cross-check files were written to `workspace/literature_crosscheck/group_D/`.
