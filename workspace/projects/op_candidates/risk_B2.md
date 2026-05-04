# Risk Assessment: B2 — Min-Max Last-Iterate Lower Bound

## Date: 2026-04-28

---

## 1. Scoop check: is the original envisioned gap already closed?

### Original vision (from brief):
"For smooth convex-concave saddle-point problems, last-iterate LB for GDA/EG/OGDA — gap between averaged O(1/T) and last-iterate. Possibly extend OGDA bilinear analysis to general C-C."

### Status assessment: SUBSTANTIALLY CLOSED for the stated goal

**EG last-iterate (unconstrained smooth C-C)**: CLOSED. Golowich 2020 gave tight Θ(1/√T).

**EG and OGDA last-iterate (constrained smooth C-C / monotone VI)**: CLOSED. Cai-Oikonomou-Zheng 2022 (NeurIPS) gave tight O(1/√T) LB and UB for both algorithms, arbitrary convex sets. This is the most direct "extend bilinear to general C-C" result — it was already done in 2022.

**OGDA bilinear specifically**: In the library (`ogda-bilinear-last-iterate`). This is the O(1/T) upper bound. The LB side (Ω(1/T) for bilinear) follows from the eigenvalue spectrum argument and is part of the same folklore.

**Conclusion**: The "obvious" version of B2 as stated — extending the OGDA bilinear analysis to smooth C-C — was done by Cai-Oikonomou 2022. **EARLY-EXIT RULE TRIGGERED for the original question.**

The 2024–2026 wave has continued to advance:
- Anchored GDA achieves O(1/T) (2026, AI-discovered, Lean-verified): the positive side of what was an open problem.
- Cai NeurIPS 2024 (forgetful algorithms): lower bound for memory-full algorithms in discrete game setting.
- Cai NeurIPS 2025 (average-to-last reduction): positive result, further closing the gap.

**The area is extremely active with the Daskalakis/Cai group publishing 2-3 major papers per year precisely on this topic.**

---

## 2. Remaining open problems and their scoop risk

### Open problem B2a: Stochastic EG/OGDA last-iterate LB in smooth C-C
- **Status**: Appears open as of 2026-04. The stochastic saddle-point literature (unbounded gradients, NeurIPS 2024; revisiting SGD last-iterate, ICLR 2024) has not addressed the *stochastic EG/OGDA* last-iterate LB specifically.
- **Scoop risk**: HIGH. This is a natural follow-on to Cai-Oikonomou 2022. The Daskalakis/Cai/Luo group almost certainly has this on their agenda. Gorbunov (now at MBZUAI) is also active here.
- **Timeline to scoop**: 3–12 months, estimated.

### Open problem B2b: Is O(1/T) optimal for any first-order method?
- **Status**: Open. Anchored GDA achieves O(1/T) last-iterate; no matching lower bound for "all algorithms."
- **Scoop risk**: VERY HIGH. The anchored GDA paper (arXiv 2604.03782) was posted April 2026 and almost certainly has follow-up lower bound work in the pipeline by the same or competing groups.
- **Timeline to scoop**: 1–6 months.

### Open problem B2c: GDA (constant stepsize) quantitative non-convergence LB
- **Status**: Known that GDA diverges in bilinear. No quantitative lower bound on *how* the last iterate diverges for smooth C-C beyond bilinear (e.g., does ‖z_T - z*‖² diverge at rate Ω(1)? Ω(T)? Polynomially?).
- **Scoop risk**: MEDIUM. Less glamorous; possibly a note-level result.

---

## 3. Top 3 risks

### Risk 1: SCOOPED by Cai/Daskalakis group (CRITICAL)
- Probability: 70%+ within 6 weeks for B2a.
- The Cai-Yale group (Yang Cai, Weiqiang Zheng, Gabriele Farina) has published *three* major last-iterate papers in 2024–2025 and is the dominant force in this area. Their NeurIPS 2025 reduction paper (2506.03464) shows they are actively working on reducing "average-to-last" gaps, and a stochastic lower bound is a very natural next step.
- Mitigation: None reliable. If this direction is chosen, there must be a concrete new angle that departs from the Cai group's trajectory.

### Risk 2: Technical depth insufficient in 6 weeks
- Probability: 50–60% for B2b; 35% for B2a.
- B2b (all-methods LB) requires a fundamentally new hard instance that is resistant to anchoring. This is a frontier problem that would take 3–6 months minimum even for an expert team.
- B2a is more tractable but still requires careful coupling of noise lower bounds with cycling arguments — novel territory.
- The pipeline has Le Cam (OP-2), cycling (ogda-bilinear), and noise analysis tools. But *combining* them for saddle-point last-iterate is non-trivial.
- Mitigation: Scope down to a specific algorithm class or specific noise model. Restrict to OGDA (not all methods). Fix noise as bounded zero-mean sub-Gaussian.

### Risk 3: Under-differentiation from Cai-Oikonomou 2022
- Probability: HIGH if the goal is not carefully redefined.
- A proof that "extends OGDA bilinear to general C-C" would simply reproduce Cai-Oikonomou 2022 (tight O(1/√T) for constrained monotone VI). There is no publication value.
- Any B2 project MUST clearly identify which aspect of the problem is NOT covered by Cai-Oikonomou 2022 before starting.
- Mitigation: Focus exclusively on (a) stochastic setting, (b) new algorithm class (e.g., regularized methods), or (c) the all-methods LB.

---

## 4. Six-week feasibility assessment

| Sub-problem | 6-week verdict | Bottleneck |
|---|---|---|
| Original B2 (EG/OGDA LB, C-C) | NOT FEASIBLE — already done | Cai-Oikonomou 2022 |
| B2a (stochastic EG/OGDA LB) | RISKY — 30% success probability | Novel coupling + scoop risk |
| B2b (all-methods O(1/T) LB) | NOT FEASIBLE in 6 weeks | Frontier open problem |
| B2c (GDA divergence quantification) | MARGINAL — low impact | Medium difficulty, note-level |

**Overall 6-week verdict**: The original B2 direction as stated should be SKIPPED. A narrowly scoped B2a (stochastic OGDA LB) is possible but carries high scoop risk and would need immediate start with no pivots.

---

## 5. EARLY-EXIT RECOMMENDATION

**SKIP the original B2 formulation.**

The core gap ("last-iterate LB for EG/OGDA in smooth C-C") was closed by Cai-Oikonomou 2022. The 2024-2026 Cai/Daskalakis group has continued to dominate this exact space with 3+ major papers. The risk of working in their shadow is prohibitive for a 6-week PhD project.

**Exception**: If the specific angle is "stochastic EG/OGDA last-iterate LB with Le Cam (B2a)" and there is confirmed evidence this is open AND the OP-2 Le Cam machinery transfers cleanly, this is a reasonable gamble — but must be verified against Gorbunov's EUROPT 2024 talk (which may contain unpublished results in this direction).
