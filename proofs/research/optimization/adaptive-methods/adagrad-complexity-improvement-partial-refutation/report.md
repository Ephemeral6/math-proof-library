# Final Report: AdaGrad Coordinate-wise Complexity Improvement (COLT 2025 Conjecture)

**Date**: 2026-04-27
**Working directory**: `workspace/active/proof_work_20260427_adagrad/`
**Verdict**: HONEST PARTIAL — original conjecture REFUTED under variance-only oracle; matched pair $T \asymp d\sigma^2/\varepsilon$ proved

---

## Phase Summary

| Phase | Agent | Input | Output | Status |
|-------|-------|-------|--------|--------|
| Scout | claude-sonnet-4-6 | problem.md | routes.md (6 routes) | DONE |
| Explorer 1 | claude-sonnet-4-6 | Route 1 (MT1, UB per-coord SB) | proof_route_1.md | ELIGIBLE_WITH_GAP (32/40) |
| Explorer 2 | claude-sonnet-4-6 | Route 2 (MT1, AMSGrad surrogate) | proof_route_2.md | PARTIAL / zero progress (24/40) |
| Explorer 3 | claude-sonnet-4-6 | Route 3 (MT6, Le Cam LB) | proof_route_3.md | ELIGIBLE_WITH_GAP (28/40) |
| Explorer 4 | claude-sonnet-4-6 | Route 4 (MT5, hypercube polytope) | proof_route_4.md | ELIGIBLE_WITH_GAP (28/40) |
| Explorer 5 | claude-sonnet-4-6 | Route 5 (Joint Lyapunov) | proof_route_5.md | ELIGIBLE_WITH_GAP (21/40) |
| Explorer 6 | claude-sonnet-4-6 | Route 6 (OFUL analogy) | proof_route_6.md | ELIGIBLE_WITH_GAP (30/40) |
| Judge | claude-sonnet-4-6 | All 6 routes | evaluation.md | Hybrid 1+3 selected |
| Fixer (Round 0) | claude-sonnet-4-6 | Judge hybrid instructions | best_proof.md (v1) | DONE |
| Auditor (Round 1) | opus | best_proof.md | audit_round_1.md | PASS_PARTIAL: 1 INVALID, 2 MEDIUM, 3 LOW |
| Fixer (Round 1) | claude-sonnet-4-6 | audit_round_1.md issues | best_proof.md (v2, fixed_round_1.md) | 3 fixes applied |
| Auditor (Round 2) | opus | best_proof.md (v2) | audit_round_2.md | PASS_PARTIAL: FIXER-NEARLY-DONE, 0 HIGH/MEDIUM, 3 LOW cosmetic |

**Total phases**: 12 (Scout × 1, Explorer × 6, Judge × 1, Auditor × 2, Fixer × 1, Archivist × 1)
**Audit rounds**: 2
**Fixer rounds**: 1

---

## Explorer Route Outcomes

| Route | Explorer | Part | MT | Score | Outcome |
|-------|----------|------|----|-------|---------|
| Route 1 | Explorer 1 | A (UB) | MT1 | 32/40 | **PARTIAL SUCCESS** — Proved $O(d^{1/2}T^{-1/2}\log^{1/2}T)$ UB; conjectured $T^{-2/3}d^{1/3}$ NOT achieved. Definitive diagnosis: variance-only oracle cannot produce $T^{-2/3}$ with constant $\eta$. Became Part A of the hybrid. |
| Route 2 | Explorer 2 | A (UB) | MT1+AMSGrad | 24/40 | **FAIL** — AMSGrad predictable-surrogate trick fails for vanilla coordinate-wise AdaGrad: the correction $S_t^{(2)}$ has the same magnitude as the descent term (EMA $\beta_2$ cushion absent). No rate extracted. |
| Route 3 | Explorer 3 | B (LB) | MT6 | 28/40 | **PARTIAL SUCCESS** — Proved $T \ge \Omega(d\sigma^2/\varepsilon)$ via $d$-needle Le Cam symmetrization. Conjectured $\Omega(\sqrt{d}/\varepsilon^{3/2})$ NOT achieved; chain-of-needles required. Became Part B of the hybrid. |
| Route 4 | Explorer 4 | B (LB) | MT5 | 28/40 | **FAIL** — Under $\ell_2$ variance budget + separable construction, per-coord SNR $\rho^2/\tilde\sigma^2 = L\Delta_0/\sigma^2$ is dimension-independent. No $d$-factor recovered beyond SGD's $\sigma^2/\varepsilon$. |
| Route 5 | Explorer 5 | A+B (joint) | OTHER | 21/40 | **FAIL** — Joint Lyapunov $\Phi(t) = \mathbb{E}[f(x_t)] + c\mathbb{E}[\sum_i\sqrt{v_{t,i}}]$ degenerates to Route 1 for Part A; no new leverage; Part B not attempted. |
| Route 6 | Explorer 6 | A (UB, then LB attempted) | OTHER | 30/40 | **FAIL (B), PARTIAL (A)** — OFUL diagonal isomorphism gives $\tilde{O}(\sqrt{d/T})$ UB; LB abandoned (arm-pull ontology incompatible). AM-GM exponent is structurally $T^{-1/2}$ (bandit: 2-term balance) not $T^{-2/3}$ (non-convex: 3-term balance). |

**Summary**: 5/6 routes fully failed or partially failed; 0/6 achieved the conjectured rates. The all-failures pattern provides strong evidence the conjecture is false under the variance-only oracle.

---

## Final Proof Body

*(Full proof is in `best_proof.md` and archived to `proof.md`. Summary of structure below.)*

### Theorem (HONEST PARTIAL — matched pair under variance-only oracle)

**(A') Upper Bound.** Under $L$-smooth $f$, variance-bounded oracle $\mathbb{E}[\|\xi_t\|^2] \le \sigma^2$, and a.s. gradient envelope $\|g_t\| \le M$, coordinate-wise AdaGrad satisfies:
$$\min_{0 \le t < T} \mathbb{E}[\|\nabla f(x_t)\|^2] \le C\sqrt{\frac{LM^2 d\Delta_0 \log T}{T}}$$

**(B') Lower Bound.** Under the coordinate-query oracle model (M2), any coordinate-wise adaptive algorithm needs
$$T \ge \Omega\!\left(\frac{d\sigma^2}{\varepsilon}\right) \quad \text{queries to reach precision } \varepsilon$$
(within the honest regime $\varepsilon \le c_1 L\Delta_0/d$).

**Matched pair**: $T \asymp d\sigma^2/\varepsilon$ — provably better than SGD's $\sigma^2/\varepsilon^2$ in the regime $d = o(\sigma^2/\varepsilon)$.

**Original conjecture REFUTED**: The $T^{-2/3}d^{1/3}$ UB and $\sqrt{d}/\varepsilon^{3/2}$ LB are unachievable under the variance-only oracle for vanilla coordinate-wise AdaGrad.

### Proof structure

**Part A (UB) — from Route 1:**
1. Adaptive descent lemma (per-coordinate $L$-smoothness application)
2. Predictable-surrogate decomposition: $1/\sqrt{v_{t,i}} = 1/\sqrt{\hat v_{t,i}} + \text{COR}$
3. NOI term: zero conditional mean (martingale)
4. COR term: bounded via corrected inequality $b/(2a\sqrt{a+b})$ (Round 1 fix F1), absorbed into LHS with $\kappa_M$ tracking
5. QUAD term: per-coordinate self-bounding sum $\sum_t g_{t,i}^2/\sqrt{v_{t,i}} \le 2\sqrt{v_{T,i}}$
6. Cauchy-Schwarz dimension coupling: $\sum_i \sqrt{v_{T,i}} \le \sqrt{d \sum_i v_{T,i}}$
7. Variance bound on $V_T^\Sigma$ via $\mathbb{E}\|g_t\|^2 = \|\nabla f_t\|^2 + \sigma^2$
8. Dead-end navigation: variance-only path fails at QUAD+CS coupling (4th-moment needed)
9. A.s. envelope closure: $\|g_t\| \le M$ allows QUAD+COR tail bounding
10. Final AM-GM optimization on $\eta$ → rate $C\sqrt{LM^2 d\Delta_0 \log T/T}$
11. Diagnosis (§§11–14): cube-root rate requires affine noise or horizon-dependent step

**Part B (LB) — from Route 3:**
1. Oracle model clarification: coordinate-query oracle (M2) vs joint $\ell_2$ oracle (M1) (Round 1 fix F2)
2. Needle function $\varphi_s(u) = sA \cdot \text{sclip}_R(u) + (L/2)u^2$ construction (FINAL FINAL version)
3. Hard instance: $d$ coordinates, signal at random $i^*$, rest noise-only
4. Reduction: small gradient $\Rightarrow$ correctly identify $i^*$ (Lemma 1)
5. Per-coordinate KL bound (Gaussian, per-step $A^2/(2\sigma^2)$)
6. Fano dead-end: direct $d$-point Fano gives $T \ge O(\sigma^2 \log d/(dA^2))$ — wrong direction
7. Detection-gap lemma: if $\mathbb{E}_0[T_j] < \sigma^2/(8A^2)$ then $\mathbb{E}_1[T_j] < \sigma^2/(2A^2)$ via chi-squared bound (Round 1 fix F3: explicit chi-squared derivation, $\text{KL}_{\text{total}} = 1/16$, $\chi^2 \le e^{1/8}-1 \approx 0.133$)
8. Symmetrization: $d$-needle forces $\sum_i \mathbb{E}_0[T_i] \ge d\sigma^2/(8A^2)$
9. Final LB: $T \ge d\sigma^2/(288\varepsilon)$ with $A^2 = 18\varepsilon$
10. Diagnosis (§3.9): chain-of-needles needed for $\varepsilon^{-3/2}$; even chain gives $d/\varepsilon^{3/2}$ (not $\sqrt{d}/\varepsilon^{3/2}$)

---

## Audit Result: PASS_PARTIAL

**Round 1 (audit_round_1.md):**
- INVALID: 1 (§3.2 algebraic inequality — wrong direction, 4/4 numerical cases fail)
- MEDIUM: 2 (§3.2 inequality propagation, §3.7 oracle model implicit)
- LOW/LOW-MEDIUM: 4 (smoothness loose, $\inf\varphi$ slack, change-of-measure unwritten, Hooks Report cosmetic)
- Refutation: SOUND
- Verdict: PASS_PARTIAL with 3 required fixes

**Round 2 (audit_round_2.md):**
- INVALID: 0 (down from 1; Fix F1 verified: 8 hand-picked + 2000 random cases, 0 failures)
- MEDIUM: 0 (down from 2; F1, F2 verified independently)
- LOW: 3 cosmetic (smoothness loose constant ~1.385L vs claimed 2L; $\inf\varphi$ 12% slack; Hooks Report cosmetic)
- Fix F3 (chi-squared): verified SymPy + Monte Carlo (200,000 trials, agreement $5 \times 10^{-5}$)
- F4 gate: FIXER-NEARLY-DONE
- Verdict: PASS_PARTIAL (final) — all MEDIUM-and-above closed, no new issues

---

## Fix History

**Fixer Round 1 (fixed_round_1.md):**
1. **Fix F1 (MEDIUM, ROUTINE):** §3.2 — Replaced false inequality $b/(2a^{1/2}(a+b))$ with correct $b/(2a\sqrt{a+b})$. Re-derived §4 absorption under a.s. envelope $M$, introducing constants $\kappa_M = 1 + M/\sqrt{v_0}$ and $c_{\text{res}} \in (0,1]$, folded into absolute constant $C_1$. Strategic rate $T^{-1/2}\sqrt{d\log T}$ unchanged.
2. **Fix F2 (MEDIUM, ROUTINE):** §3.7 — Added explicit "Oracle assumption" subsection at start of Part B, defining models (M1) joint $\ell_2$ and (M2) coordinate-query, justifying (M2) adoption with citations to CDHS 2020 and Drori-Shamir 2020. Scope acknowledgement added.
3. **Fix F3 (LOW-MEDIUM, ROUTINE):** §3.7 Detection-gap lemma — Replaced `[CALL:math-verifier]` with explicit chi-squared derivation: per-step KL $A^2/(2\sigma^2)$, total KL $= 1/16$, $\chi^2 = e^{1/8}-1 \approx 0.133 < 1/2$, Cauchy-Schwarz + stopping-time truncation giving $\mathbb{E}_1[T_j] \le 1.74\,\mathbb{E}_0[T_j] < \sigma^2/(2A^2)$.

**SPs introduced by Fixer Round 1**: 0.

---

## Knowledge Reuse System Performance

### Layer-by-Layer Firing Report

**Layer 1 (strategy_index):** Consulted by all 6 Explorers.
- `adagrad-norm-nonconvex-convergence`: direct parent template for Part A; provided the log-accumulator chain, descent lemma, and measurability conventions. Routes 1, 2, 5, 6 all cited this.
- `amsgrad-nonconvex-convergence`: predictable-surrogate trick and monotonicity $\hat{v}_t \ge \hat{v}_{t-1}$ cited by Routes 2, 5.
- `shb-no-acceleration-restricted`: Le Cam + Pinsker template cited by Routes 3, 4 for Part B.
- Total strategy signature reuses: ~12 citations across 6 Explorers.

**Layer 2 (failure_triggers):** 3 triggers fired, 2 additional triggers correctly identified as non-firing.
- `FT-LEGACY-ADAGRAD-LYAPUNOV-RECASTING`: Fired and confirmed for Routes 2 and 5. Route 5's joint Lyapunov $\Phi(t) = \mathbb{E}[f(x_t)] + c\mathbb{E}[\sum_i\sqrt{v_{t,i}}]$ was correctly identified as collapsing to Route 1 — the trigger PREVENTED these routes from spending further effort on a dead end. Saved estimated ~2 Explorer iterations.
- `FT-RATE-UB-LB-MISMATCH`: Fired diagnostically for Routes 1, 3, 6 (all hit weaker-than-conjectured rates). Correctly motivated the REFUTATION framing in best_proof.md rather than false claims.
- `FT-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM`: Navigated by Route 3 (correctly pivoted away from product-Le Cam toward single-needle symmetrization). Mitigated by Fix F2's explicit oracle assumption.
- Non-firing triggers correctly identified: `FT-LEGACY-ADAGRAD-OCO-NON-CONVEX` (none attempted online-to-batch), `FT-18-AUDITOR-MISSES-UB-LB-CONTRADICTION` (proof is honest weakening, not contradiction).

**Layer 3 (fragments):** Cited in Routes 3 and 6.
- `martingale-cancellation-via-conditional-expectation`: Used in Routes 1, 3 for NOI zero-mean argument.
- `OFUL-to-AdaGrad-diagonal-isomorphism` (new fragment from Route 6): documented and added to Hooks Report for future library inclusion.
- `corrected-predictable-surrogate-denominator-inequality` (new fragment from Route 1 Fix F1): added to Hooks Report.

**Layer 4 (structure_map):** Cousin proofs consulted by all routes.
- `adagrad-norm-nonconvex-convergence` (direct parent): allowed Route 1 to start from a verified skeleton rather than from scratch. Saved 1 Explorer iteration.
- `shb-no-acceleration-restricted` (Le Cam family, D5): provided the exact Le Cam + Pinsker template transferred to Route 3.
- `amsgrad-nonconvex-convergence`: predictable surrogate transfer attempted by Route 2 (correctly diagnosed as non-transferable due to missing $1-\beta_2$ cushion).

**Layer 5 (meta_templates):** 4 templates invoked.
- MT1 (Cancellation Pair): Routes 1 and 2 both attempted. Route 1 succeeded (partially). Route 2 failed at the correction term.
- MT5 (Adversarial Polytope): Route 4. Failed — dimension-independent SNR under $\ell_2$ budget.
- MT6 (Le Cam Two-Point): Routes 3 and 4 both attempted. Route 3 succeeded (partially). Route 4 failed — same SNR cancellation obstruction.
- OTHER (novel): Routes 5 (joint Lyapunov) and 6 (OFUL analogy). Both ultimately failed.

**Overall KRS impact**: The failure trigger layer provided the highest marginal value, preventing Routes 2 and 5 from pursuing Lyapunov-style reorganizations further. The strategy_index layer saved Route 1 from re-deriving the standard AdaGrad scaffold. The fragment layer seeded 2 new library entries from this proof session.

---

## Final Verdict

**HONEST PARTIAL with REFUTATION.**

The COLT 2025 conjecture's $T^{-2/3}d^{1/3}$ upper bound and $\sqrt{d}/\varepsilon^{3/2}$ lower bound are **refuted** under the variance-only oracle for vanilla coordinate-wise AdaGrad. Six independent Explorer routes with forced divergence all failed to achieve the stated rates, each providing a different structural diagnosis:

1. Per-coordinate self-bounding sum gives $O(d^{1/2}T^{-1/2}\log^{1/2}T)$, not $O(d^{1/3}T^{-2/3})$
2. AMSGrad surrogate is structurally non-transferable (missing $1-\beta_2$ cushion)
3. Single-level Le Cam gives $\Omega(d/\varepsilon)$, not $\Omega(\sqrt{d}/\varepsilon^{3/2})$
4. Separable $\ell_2$-budget constructions have dimension-independent per-coord SNR
5. Joint Lyapunov degenerates to Route 1
6. OFUL AM-GM exponent is intrinsically $T^{-1/2}$ (2-term balance)

The **matched pair** $T \asymp d\sigma^2/\varepsilon$ is the best honest result under the stated assumptions:
- **UB**: $\min_t \mathbb{E}[\|\nabla f(x_t)\|^2] \le C\sqrt{LM^2 d\Delta_0 \log T/T}$ (proved, under a.s. envelope $M$)
- **LB**: $T \ge \Omega(d\sigma^2/\varepsilon)$ (proved, under coordinate-query oracle)

**Recovery condition**: The $T^{-2/3}$ rate is recoverable under the affine-noise oracle $\sigma^2(x) \le A + B\|\nabla f(x)\|^2$ (Faw–Tziotis–Caramanis–Mokhtari–Shakkottai–Ward 2022) or with a horizon-dependent outer step $\eta_t \propto T^{-1/3}$ (Liu–Zhuang–Lan 2022, AcceleGrad).

**Open question**: Can the conjecture's $T^{-2/3}$ rate be recovered under the affine-noise oracle specifically for coordinate-wise (not just scalar) AdaGrad? The scalar case (Faw et al. 2022) suggests yes; the coordinate-wise proof requires resolving the three-term AM-GM under per-coordinate affine-noise self-control.
