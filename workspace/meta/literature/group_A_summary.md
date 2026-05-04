# Group A — Optimization/Convergence Cross-Check Summary

**Owner**: Agent 1
**Date**: 2026-04-27
**Scope**: 15 PASS proofs in `proofs/research/optimization/convergence/`
**Note**: All arXiv WebFetch returned only abstracts (no theorem text); comparisons rely on knowledge of the published papers. Marked `[ARXIV-UNREACHABLE]` per protocol.

---

## Verdict tally

| Verdict | Count | IDs |
|---|---|---|
| CONFIRMED | 7 | A1, A2, A3, A6, A9, A11, A13 |
| CONFIRMED-IMPROVED | 1 | A4 |
| CONFIRMED-WEAKER | 4 | A7, A8, A10, A12 |
| DISCREPANCY | 1 | A5 (attribution only — math is correct) |
| NOVEL | 2 | A14, A15 |
| ERROR | 0 | — |

**Total**: 15. **No ERROR-class verdicts** (no proof contradicts a published result).

---

## Top NOVEL results (publication candidates)

### A15: Polyak-Ruppert weighted average defeats SHB cycling — **STRONG candidate**
- Sharp upper bound $LD^2/(4T^2\sin^4(\pi/K))$ on Goujaud's hard instance.
- Disproves the natural $\Omega(LD^2/T)$ bias lower bound for linearly-weighted Polyak-Ruppert.
- Clean Fourier-sum proof, sharp leading constant. Natural follow-up to GPT 2023.
- **Recommendation**: publish as short note or part of larger iterate-type-separation paper.

### A14: SVRG non-SC last-iterate $\Theta(\log m)$ gap — **publication candidate**
- New $\Theta(\log m)$ separation between SVRG snapshot and last-iterate.
- Upper bound rigorous; lower bound by reduction to Harvey-Liang-Liaw-Randhawa 2019.
- **Recommendation**: short paper / SIOPT communication; bridges SVRG to the Harvey-style last-iterate-vs-average gap.

---

## DISCREPANCY / ERROR results requiring action

### A5: SAM Convergence — DISCREPANCY (attribution)
- The claimed source **Foret et al. 2021** does **not** prove the cited convergence theorem; the bound corresponds to **Andriushchenko-Flammarion 2022** (arXiv:2206.06232) or contemporaneous works.
- The math is correct.
- **Action**: re-attribute in `notes.md` and `RESEARCH_INDEX.md`; this is a citation hygiene fix, not a math fix.

### No ERROR-class verdicts.

---

## Notes on "WEAKER" verdicts

- **A7** (Synchronous QL): $(1-\gamma)^{-4}$ rate matches Li-Cai-Chen-Wei-Chi 2021 sharper analysis (CONFIRMED for vanilla QL); minimax-optimal $(1-\gamma)^{-3}$ requires variance-reduced QL (Wainwright VR-QL).
- **A8** (OGDA bilinear): $O(\kappa^2/T)$ is correct but linear convergence is known for full-rank bilinear (Liang-Stokes 2019).
- **A10** (Entropy-reg NPG): rate $(1-\eta\tau(1-\gamma))$ is honestly slower than Cen 2022's $(1-\eta\tau)$ for $\eta < (1-\gamma)/\tau$; matches at the largest allowed step.
- **A12** (Softmax PG): honest convention difference for $c_\infty$; mathematically equivalent in spirit to Mei 2020 Theorem 4.

---

## Overall pattern (2 sentences)

Most of Group A consists of careful textbook re-derivations of canonical RL/optimization convergence theorems (Agarwal NPG, Bhandari TD, Lin-Jin-Jordan GDA, Jin-Allen-Zhu-Bubeck-Jordan UCB-QL) where our proofs faithfully reproduce the published technique and constants. The two genuinely novel results are both in the SHB / SVRG iterate-type-separation niche (A14, A15) — both clean, short, and answering natural open questions following recent lower-bound works (GPT 2023, Harvey 2019).

---

## File index

| ID | File |
|---|---|
| A1 | `group_A/A1_npg_softmax.md` |
| A2 | `group_A/A2_entropy_reg_VI.md` |
| A3 | `group_A/A3_sgd_last_iterate_avg.md` |
| A4 | `group_A/A4_heavy_ball_instability.md` |
| A5 | `group_A/A5_sam_convergence.md` |
| A6 | `group_A/A6_lookahead.md` |
| A7 | `group_A/A7_synchronous_q_learning.md` |
| A8 | `group_A/A8_ogda_bilinear.md` |
| A9 | `group_A/A9_td0_linear.md` |
| A10 | `group_A/A10_entropy_reg_npg_linear.md` |
| A11 | `group_A/A11_gda_nonconvex_sc.md` |
| A12 | `group_A/A12_softmax_pg_sublinear.md` |
| A13 | `group_A/A13_q_learning_ucb.md` |
| A14 | `group_A/A14_svrg_last_iterate.md` |
| A15 | `group_A/A15_polyak_ruppert_shb.md` |
