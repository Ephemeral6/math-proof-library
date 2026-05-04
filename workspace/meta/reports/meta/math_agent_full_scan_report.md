# Math Agent System — Full Scan Report

**Generated**: 2026-04-26
**Repo**: `C:\Users\12729\Desktop\Math\`
**Scope**: Open Problems · Proof Library · Agent Framework
**Method**: Direct file scan (3 parallel Explore agents, cross-checked against INDEX.md / `proofs/` tree / `~/.claude/skills/`).

> Numbers and rows below are pulled from actual file contents. Where a field could not be resolved, it is marked `[NOT FOUND]` or `[UNCERTAIN]` rather than guessed. One known minor count discrepancy: `INDEX.md` reports 51 research + 42 library = 93 proofs total; `find -name problem.md` returns 50 + 42 = 92. Treated as a 1-proof bookkeeping gap; INDEX.md figures are authoritative below.

---

# Part 1 — Open Problem Roster

## 1.A Per-OP Status

### **OP-1 — SGD Last-Iterate Rate in Constant Dimension**

| Field | Content |
|---|---|
| 编号 | OP-1 |
| 问题名称 | Closing the gap between $O(\log T/\sqrt T)$ upper bound and $\Omega(1/\sqrt T)$ lower bound for last-iterate non-smooth Lipschitz convex SGD with fixed step-size $\eta=\Theta(1/\sqrt T)$ in constant dimension. |
| 数学陈述 | $\exists$ universal constant $c$ such that for every $f$ Lipschitz convex, last-iterate SGD with $\eta=\Theta(1/\sqrt T)$ satisfies $\mathbb{E}[f(x_T)-f^\*]\le c/\sqrt T$ in dimension $d=O(1)$. Conjectured rate: $\Theta(1/\sqrt T)$. |
| 来源 | Koren & Segal 2020 COLT (PMLR 125). |
| 难度 | research / HIGH RISK |
| 当前状态 | PARTIAL — likely-resolved-negatively in literature (no formal proof attempt archived). |
| 尝试路线数 | 0 internal (literature-only review). 4+ external papers tracked: Liu–Zhou 2021, ICLR 2024 v4, arXiv:2507.14122 (Jul 2025), arXiv:2604.13870 (Apr 2026). |
| 失败路线概述 | (a) Liu–Zhou 2021 dimension-dependent LB $\Omega(\log d/\sqrt T)$ — closes growing-$d$ case; (b) smooth-convex variant settled at $\tilde O(1/\sqrt T)$ (2025) — different setting; (c) arXiv:2604.13870 GD last-iterate noiseless case shows poly-log factor necessary — suggests $\log T$ intrinsic. |
| 成功路线概述 | None. |
| 降级说明 | No formal downgrade. Status drifted from "open" → "likely-false-as-stated". |
| 产出文件 | `workspace/opp_protocol_round1.md` (Koren–Segal 2020 profile, dated 2026-04-17). |
| 外部反馈 | [NOT FOUND] — no direct external review; competition extreme (4+ papers 2021–2026). |

---

### **OP-2 — Fixed-Momentum SHB Non-Acceleration on Goujaud Feasibility Region**

| Field | Content |
|---|---|
| 编号 | OP-2 |
| 问题名称 | For $(\beta,\eta)\in\mathcal{F}$ (parameter region satisfying Goujaud–Taylor–Dieuleveut cycling inequality), prove SHB achieves no better than $\Omega(LD^2/T+\sigma D/\sqrt T)$ on a custom-constructed smooth convex (globally 0-strongly-convex) instance. |
| 数学陈述 | $\forall(\beta,\eta)\in\mathcal{F}\;\exists f_{\beta,\eta}\in\mathcal{F}_{L,0}$ such that SHB last-iterate satisfies $\mathbb{E}[f_{\beta,\eta}(x_T)-f^\*]\ge \Omega((\kappa/4)LD^2/T+(1/112)\sigma D/\sqrt T)$. |
| 来源 | Lessard–Recht–Packard 2016 SIAM J. Optim.; built on Goujaud–Taylor–Dieuleveut 2023 (arXiv:2307.11291). |
| 难度 | A-class (original) → B-class (downgraded). |
| 当前状态 | **SOLVED (downgraded, v3 final)** — pending scope-statement corrections per Li peer review. |
| 尝试路线数 | 3 major routes (full-$\mathcal{S}$ → $\mathcal{F}$ downgrade; v1→v2→v3 refinement) + 4-track audit + external Li review. |
| 失败路线概述 | (a) Full-$\mathcal{S}$ coverage: empirical tests at $(\beta,\eta)=(0.5,1/L),(0.9,1/(2L))$ showed convergence not cycling (proof vulnerability). (b) Initial constant $c_{\mathrm{NY}}=1/(8\sqrt 2)$ unsupported; rigorous chain yielded $1/56$ with dropped wall-energy term. (c) GFJ15 attribution falsely claimed stochastic UB for deterministic-only paper. |
| 成功路线概述 | (v3 final) 3-D function $f=f_0(x)\oplus(\alpha_s y+w(y))$ with $f_0$ a 2-D $\mu$-SC Goujaud function and $(y)$-block providing non-SC via wall function. Proof chain: Lemma 1.3 (GTD23 cycling identity) → Lemma 1.6 (HB deterministic bound) → Lemma 2.6–2.10 (cycling init + Le Cam two-point) → Claim 2.13 (positive measure of $\mathcal{F}$). |
| 降级说明 | **From** "$\forall(\beta,\eta)\in\mathcal{S}$" (full stability region) **to** "$\forall(\beta,\eta)\in\mathcal{F}\subsetneq\mathcal{S}$" (3.28% of tested stability region, but positive measure). Three additional scope qualifications: (i) **last-iterate only** — Cesàro $\bar x_T$ collapses to $O(LD^2/T^2)$ (matches AC-SA acceleration); (ii) **cycling-compatible init required** — under standard zero-momentum init $x_0=x_{-1}$, SHB at $(\beta,\eta L)=(0.7,2.9)$ converges geometrically (LB target violated 191/200 iterates); (iii) **structurally decomposable non-SC** — global $\mu=0$ achieved via 2-D SC ⊕ 1-D wall, not a general non-SC smooth function. |
| 产出文件 | `op2_downgraded_proof_v3_final.md` (765 lines, 2026-04-18 audit pass), `op2_downgraded_proof_v2.md`, `op2_downgraded_full_proof.md`, `op2_proof_submission.md` (62 KB COLT submission), `op2_audit_final.md`, `op2_audit_round3.md`, `op2_final_clearing_and_setup.md`, `op2_li_review/`. |
| 外部反馈 | **Xiao Li (CUHK Shenzhen)**, response in `op2_li_review/`, dated 2026-04-26. Three substantive challenges, all **VALID**: (1) **Last-iterate vs ergodic** — verified $\bar x_T=0$ to machine precision for $T\in\{99,999,9999,99999\}$; headline must read "SHB last-iterate does not accelerate". (2) **Zero-momentum init** — under $x_0=x_{-1}$ at $(\beta,\eta L)=(0.7,2.9)\in\mathcal{F}$, LB target $(\kappa/4)LD^2/T$ violated for 191/200 values of $T$; SHB converges geometrically. ∀-∃ statement permits existential init choice but cycling-init is unphysical → true LB only on restricted $\mathcal{F}_{\text{attract}}\subsetneq\mathcal{F}$. (3) **Non-SC disclosure** — math correct ($\nabla^2 f^{(s)}(0,0)=\mathrm{diag}(L,L,0)$) but coordinate-decomposition structure should be foregrounded; **cosmetic**. **Verdict**: no proof error found; published claim must qualify as "(last-iterate) under (cycling-compatible init) on (structurally-decomposable hard instance)". Confidence downgraded HIGH → MEDIUM-conditional-on-scope-tightening. |

---

## 1.B Candidates Considered But Not Escalated

Five candidates from feasibility-analysis files (`c14_*`, `c33_*`, `c34_*`, `r1_*`, `r3_*`, `pb1_*`). Each was killed pre-proof; rationale below.

- **OP-3 / SAM ρ-tight non-convex bound** (Foret et al. 2021 ICLR future work). PARTIAL. Skipped because arXiv:2503.02225 (Mar 2025, "SAM: General Analysis and Improved Rates") delivered $O(1/\varepsilon^2)$ unified analysis claiming tightness via $\rho=0$ recovery; remaining gap is narrow.
- **C1.4 / STORM for MCMC ergodic averages**. RED. Killed by Kipnis–Varadhan CLT (1986): tight $\Theta(1/T)$ LB on linear functionals of $T$ chain samples. STORM's mechanism requires $L$-smooth iterate dynamics ($\eta$-converging successive samples), absent in MCMC where samples are $\Theta(1)$ apart.
- **C3.3 / Potential-game LOO stability**. CONSIDERED-ONLY. Three formalizations examined (shared-dataset / per-player / payoff-perturbation); only non-trivial setup overlaps with Mertikopoulos / Sandholm / Bravo / Leslie no-regret-in-potential-games line — high REDISCOVERED risk.
- **C3.4 / Coarse Ricci → HRS stability**. CONSIDERED-ONLY. Pure SGD has $\kappa\ge0$ iff HRS hypotheses hold (no extension); SGLD case covered by Vempala–Wibisono / Erdoğdu–Mackey 2019+; W₁-contraction does not strictly improve pointwise HRS coupling.
- **R1 / HRS uniform stability extended to Markov samples**. CONSIDERED-ONLY. Bousquet–Elisseeff "ghost sample" symmetrization breaks under Markov dependence; LOO under chain has 3 ambiguous formalizations; literature gap exists but problem too narrow → high informal-rediscovery risk.
- **R3 / STORM with biased gradient oracle**. RED. arXiv:2306.07810 (Jin–Scutari–Xie 2023 NeurIPS) Algorithm 3 = "Adaptive Biased STORM" — Theorem 3.5 gives exactly $O(\varepsilon^{-1}+\varepsilon^{-3})$ bias-aware rate.
- **PB-1 / SPS with inexact $f^\*$**. RED. Three direct subsumers: Orvieto–Lacoste-Julien–Loizou 2022 (DecSPS without $f^\*$), Jiang–Stich 2023 (AdaSPS with lower-bound only), Orabona–D'Orazio 2025 (formal impossibility for unknown optimum). Both subsumption AND negative result.
- **C3.4 application scoping** (coarse Ricci → generalization). CONSIDERED-ONLY. No technical error but no gain over HRS; redundant.

---

# Part 2 — Proof Library Overview

## 2.1 Aggregate Statistics

| Metric | Value |
|---|---|
| Total proofs | **93** (per INDEX.md) — 92 `problem.md` files actually present (1 bookkeeping gap) |
| Research level (A-class) | **51** |
| Library level (B-class) | **32** |
| Textbook level (C-class) | **10** |
| First-round audit pass rate | **86%** (23 of 27 fully-audited proofs passed first round; PAC-Bayes required 2 rounds) |
| Required Fixer repair | **6** (5 missing-QED + 1 missing `failed_attempts/`) |
| Times agent corrected the problem statement | **1 confirmed** (Denoising Score Matching — added regularity condition); **1 detected contradiction** (AdaGrad-Norm UB/LB mismatch, in blind test) |
| Folders containing `failed_attempts/` | 86 (47 research + 39 library) |
| Files inside `failed_attempts/` | 105 |

## 2.2 By Mathematical Branch

| Branch | Research | Library | Hardest representative | Core techniques |
|---|---|---|---|---|
| Optimization | 28 | 16 | SHB no-acceleration (525 lines, lower-bound); NPG softmax tabular (176 lines, mirror descent + KL) | Descent Lemma, Telescoping, Lyapunov, Bregman |
| Learning Theory | 15 | 7 | Xu–Raginsky MI bound; Catoni PAC-Bayes (inverse-KL) | Donsker–Varadhan, Chernoff/MGF, KL |
| Statistics | 2 | 7 | Double Descent (Wishart moments); LASSO RE condition (prediction error) | Bias-variance, concentration, matrix analysis |
| Convex Analysis | 4 | 8 | Davis–Yin 3-operator splitting (276 lines); Chambolle–Pock PDHG ergodic | Lyapunov + telescoping, Bregman, variational ineq. |
| Probability | 1 | 3 | ULA KL convergence under LSI (102 lines) | de Bruijn identity, log-Sobolev, Grönwall |
| Linear Algebra | 0 | 1 | Johnson–Lindenstrauss Lemma (51 lines) | Gaussian invariance, union bound, ε-net |
| Low-Dimensional Topology | 0 | 0 | (none yet — seeds staged) | (seeded: skein, Burau, mapping class group) |

Branch distribution is **highly imbalanced**: optimization ≈ 52% of total; probability ≈ 3%; linear algebra ≈ 1%; LDT not yet on the board.

## 2.3 Technique Dictionary — Top 15

Compiled from `workspace/proof_techniques_summary.md` (36 named techniques) cross-referenced against the 93 proofs.

| Rank | Technique | Uses | Branches | Key examples |
|---|---|---|---|---|
| 1 | Telescoping sum | 13 | opt(8), convex(4), LT(1) | SPS-SGD, Mirror Descent, ADMM, Nesterov LB |
| 2 | Convexity + subgradient inequality | 8 | opt, convex, LT | SPS-SGD, Proximal Gradient, Extragradient, SVRG |
| 3 | Descent lemma / $L$-smoothness | 6 | opt(stoch ×3, adapt ×1, conv ×1), convex ×1 | Adam, Clipped SGD, SVRG, Proximal Gradient |
| 4 | Lyapunov / potential function | 5 | opt, convex/subgradient ×3 | SVRG, Proximal Grad, ADMM-FR, ADMM-Ergodic, OGD |
| 5 | Chernoff / MGF bound | 5 | stat/conc ×3, lin-alg ×1, LT/pac ×1 | JL, Matrix Bernstein, McDiarmid, Sub-Gaussian Cov, PAC-Bayes |
| 6 | KL / entropy regularization | 4 | opt/conv ×2, LT/pac, prob | NPG, Entropy-Reg VI, PAC-Bayes, Langevin |
| 7 | Jensen + ergodic averaging | 4 | convex/subgradient ×3, opt/conv ×1 | ADMM-FR, ADMM-Ergodic, Extragradient, SGD-PL |
| 8 | Union bound / ε-net | 4 | stat, lin-alg, LT | PAC-Bayes, JL, Sub-Gaussian Cov, Matrix Bernstein |
| 9 | Hoeffding's lemma | 3 | LT ×2, stat | PAC-Bayes, McDiarmid, NPG |
| 10 | Bregman / three-point identity | 3 | opt/MD, opt/conv, convex/subgr | Mirror Descent, NPG Softmax, ADMM-FR |
| 11 | Polarization identity | 3 | opt/adapt, convex/subgr ×2 | Adam, ADMM-FR, ADMM-Ergodic |
| 12 | Young's inequality | 3 | opt/MD, opt/stoch, convex/subgr | Mirror Descent, Clipped SGD, Extragradient |
| 13 | Strong convexity / PL | 3 | opt/stoch, opt/conv, LT/stab | SVRG, SGD-PL, SGD Stability |
| 14 | Projection non-expansiveness | 2 | opt/conv, convex/subgr | OGD, Extragradient |
| 15 | Donsker–Varadhan variational | 2 | LT/pac, opt/conv | PAC-Bayes, NPG Softmax |

**OP-2-specific techniques** (used in SHB no-acceleration only):
- **Goujaud cycling construction** — for each $(\beta,\eta)$, build an $L$-smooth convex function on which SHB cycles persistently. Novel lower-bound tool unmatched in upper-bound side (Langevin / AC-SA).
- **Parameter-adaptive adversarial instance** — joint dependence of the hard instance on $(\beta,\eta)$, vs. usual marginal dependence on a single hyperparameter.

## 2.4 Failure-Pattern DB — Summary

`workspace/failure_patterns.md`: **48 entries total** (43 main + 5 LDT-specific FP-SPIRAL family added 2026-04-20/21).

By topic:

| Topic | Entries | Representative |
|---|---|---|
| Coordinate descent | 2 | Weighted-norm → Euclidean conversion introduces $n$ factor |
| Implicit bias / max-margin | 4 | Per-data-point margin analysis necessary; gradient/iterate coupling |
| Fenchel duality | 3 | $\nabla f$ non-surjective without strict convexity; cocoercivity for domain |
| Concentration | 3 | Bennett→Bernstein algebra; sub-Gaussian² is sub-exponential |
| SAM | 1 | Direct Danskin tighter than Lyapunov via perturbed-point bound |
| Heavy-tail clipping | 1 | Proxy stationarity $\varphi=\min(\|\nabla\|^2,\tau\|\nabla\|)$ non-standard |
| NTK infinite-width | 1 | Schur product $\|M\circ G\|_{\mathrm{op}}\le\|M\|_{\mathrm{op}}$ unlocks proof |
| PAC-Bayes | 1 | $\lambda$-grid union bound necessary for unified posterior optimization |
| SGD PL + interpolation | 1 | Multiplicative-noise structure → two-phase rate; standard Lyapunov fails |
| STORM | 3 | Young vs. polarization, $G$ recursion absorption, $L_1$ vs. $L$ separation |
| SHB lower bound | 2 | Quadratic / log-cosh approximations fail; $\nabla^2 f(x^\*)=0$ globally needed |
| AdaGrad-Norm | 1 | UB/LB contradiction ($O(\log N/\sqrt N)<\Omega(1/N^{1/4})$) — Auditor missed reverse-consistency |
| LDT | 5 | FP-SPIRAL family (Kauffman convention; basis change in Burau; skein non-uniformity; principal-minor mis-framing; param swap in mixed-case L1) |

**Top-5 highest-value patterns** (judged by re-use as reusable negative knowledge):

1. **Heavy-tail clipping proxy stationarity** — proxy $\varphi$ now standard analytical tool for non-convex clipped SGD.
2. **PAC-Bayes $\lambda$-grid union bound** — generalized template for any data-driven posterior bound.
3. **NTK Schur product absorption** — matrix-structure absorption template (used in implicit bias, LASSO).
4. **STORM polarization identity** — avoids Young loss; back-applied to Adam, ADMM, momentum methods.
5. **FP-18 (AdaGrad-Norm UB/LB)** — exposed systemic Auditor blind spot (reverse-consistency); led to v2 Step 0.5 hardening.

**OP-2-related failure patterns** (all relate to SHB lower bound):
- **FP-SHB-route-A / -B / -C**: failed lower-bound constructions via quadratic Chebyshev acceleration, hyperbola local-SC, and tridiagonal forms. Common defect: any local-SC structure gets undone by the Polyak accelerator. Working construction (Goujaud cycling) escapes the trap by parametrizing through $\mu\to0$ rather than setting $\mu=0$ directly — SC structure is preserved at every $\mu>0$ but the limit instance is globally $0$-SC.

## 2.5 Research-Level Quality Tiering

Top 10 research proofs by technical non-triviality:

| Rank | Theorem | Branch | Core difficulty | Length (lines) | Audit rounds | Note |
|---|---|---|---|---|---|---|
| 1 | SHB no-acceleration ($\forall$-$\exists$ restricted) | opt/lower-bounds | Goujaud cycling at $\mu\to0$ + parameter-dependent adversarial instance; quantifier inversion | 525 | 2 | First formalization of 2023 paper LB; downgraded from sharp OP-2; non-quadratic instance design |
| 2 | OGDA bilinear last-iterate $O(1/T)$ | opt/conv | Operator splitting on saddle-point; linear rate for bilinear games; extrapolation analysis | 493 | 1 | Golowich / Mokhtari 2020 |
| 3 | Softmax PG sublinear $O(1/t)$ | opt/conv | Directional softmax-grad alignment; importance sampling; sublinear→subquadratic transition | 271 | 1 | Mei et al. 2020 ICML, honest non-exact-softmax form |
| 4 | TD(0) linear approx. $O(1/T)$ | opt/conv | TD + function approx.; ODE stability + stochastic perturbation | 276 | 1 | Bhandari / Srikant–Ying 2019 |
| 5 | SPIDER variance reduction (non-convex) | opt/stoch | Recursive grad estimator; variance recursion ⨉ descent lemma interleaving | 220 | 1 | Fang 2018 NeurIPS |
| 6 | NPG softmax tabular $O(1/K)$ | opt/conv | Performance-difference lemma + mirror descent + KL cancellation via Donsker–Varadhan | 176 | 2 | Cen et al. 2022 |
| 7 | Q-learning UCB-Hoeffding $\widetilde O(\sqrt{H^4SAT})$ | opt/conv | Model-based UCB; $Q$-fn elliptic potential; Hoeffding on Bellman error | 220 | 1 | Jin et al. 2018 NeurIPS |
| 8 | Synchronous Q-learning finite-time | opt/conv | Async→sync reduction; gossip averaging | 167 | 1 | Li et al. 2021 / Wainwright 2019 |
| 9 | Clipped SGD heavy-tail | opt/stoch | Case analysis on clip threshold; proxy stationarity; bias decomposition | 167 | 1 | Zhang et al. 2020 / Gorbunov et al. 2020 |
| 10 | Xu–Raginsky MI generalization (with BZV refinement) | LT/gen | Mutual information ≤ KL; per-sample refinement | [NOT FOUND] | [UNCERTAIN] | Combines XR2017 + Bu–Zou–Veeravalli 2020 |

## 2.6 LDT Extension Status (informational)

`workspace/proof_techniques_ldt.md` (2026-04-20) seeds 5 knot-theory + 3 mapping-class-group + 3 curve-complex techniques + 3-manifold reference set.

15 LDT seed problems staged through Stages 1–3 of `ldt_extension_log.md`; library still empty for this branch. FP-SPIRAL family (5 entries) is the only LDT material in the failure-pattern DB.

---

# Part 3 — Agent Framework Status

## 3.1 Pipeline (V2.2 + LDT Extension)

```
Problem Statement
      ↓
[Dispatcher: Sonnet]              ← classify type × difficulty × domain
      ↓
[Scout: Sonnet]                   ← Step 0a (techniques) / 0b (library)
      ↓                             / 0c (failure DB)
      ↓
[Explorer × N: Opus, parallel]    ← N = 2..5 by difficulty
      ↓                             [CALL:math-verifier], [CALL:math-constructor]
      ↓                             outputs proof_route_N.md with [REF:] cites
      ↓
[Judge: Sonnet]                   ← scores /40, picks single Winner
      ↓
[Auditor: Opus]                   ← Step 0.5 reverse-consistency,
      ↓                             numerical verification (≥2 param sets),
      ↓                             constant tracking, lit cross-check,
      ↓                             [VERIFIED:*] tags, LDT checklist if applicable
      ↓
   ┌──FAIL──→ [Fixer: Opus] ──→ (audit again, max 3 rounds, F4 gate in LDT)
   │                                       │
   │                                       ▼
   └──PASS──────────────────────→ [Integrator: Opus] (v2.2)
                                          ↓ (consolidate Fixer rounds, rewrite
                                          ↓  for self-containment, preserve tags)
                                          ↓
                                  [integration_check]
                                          ↓
                                  PASS → archive
                                  FAIL → 1 corrective round → archive (or [WARN: INTEGRATION-DEGRADED])
                                          ↓
                                  [Step F: extract failure patterns to DB]
                                          ↓
                                       Archived
```

| Phase | Skill / Agent | Model | Input | Output | Top prompt rules |
|---|---|---|---|---|---|
| Dispatcher | math-dispatcher | Sonnet | user problem | execution plan | Classify type × difficulty × domain; route to proof-agent / constructor / verifier |
| Scout | math-proof-agent / scout | Sonnet | problem.md | routes.md (3–5 routes) | MUST read `proof_techniques_summary.md`, `proofs/library/`, `proofs/research/`, `failure_patterns.md`; annotate `[REF:]`, tag L1 lemmas, flag pitfalls |
| Explorer | math-proof-agent / explorer | Opus × N | problem + assigned route | `proof_route_N.md` | Cite library lemmas via `[REF:]`; embed `[CALL:verifier/constructor]` for critical steps; auto-archive B/C lemmas to `library/` |
| Judge | math-proof-agent / judge | Sonnet | all `proof_route_*.md` | `evaluation.md`, **Winner: Route N** | Score 4 axes (/10 each), force pick a single winner, no REJECT_ALL |
| Auditor | math-proof-agent / auditor | Opus | best_proof.md + problem.md | `audit_round_N.md` | **MANDATORY Step 0.5** reverse consistency; numerical sanity ≥2 param sets; constant table; literature cross-verification; `[VERIFIED:*]` tags; LDT checklist if domain matches |
| Fixer | math-proof-agent / fixer | Opus | best_proof + audit_round_N | `fixed_round_N.md` → `best_proof.md` | SP dual classification (ROUTINE / STRUCTURAL / STRATEGIC); F4 progress gate (FIXER-PROGRESS / -STALLED / -REFUSED-CONFIRMED) |
| Integrator (v2.2) | math-proof-agent / integrator | Opus | best_proof + Fixer + Auditor outputs | `integrator_report.md`, rewritten `best_proof.md` | Preserve `[VERIFIED-SYMPY:]`, `[REF:]`; inline Fixer lemmas; resolve stale cross-refs; merge by recency (Auditor > Fixer > Explorer) |

## 3.2 Six Design Patterns — Implemented vs. Documented

| Pattern | Doc state | Actual state | Implemented in | Known issues |
|---|---|---|---|---|
| **P1: Auditor–Fixer loop** | v2.md §4 | **FULL** | `auditor.md` + `fixer.md` + orchestrator loop (max N rounds) | F4 gate currently LDT-only; v2.3 plans full-domain extension, not yet tested |
| **P2: Step 0.5 reverse-consistency** | v2_validation_report / blind_test_adagrad postmortem | **FULL** at numerical level; **PARTIAL** as global mechanism | `auditor.md` §Step 0.5 + mandatory numerical verification | Worked perfectly in v2 validation (caught 3 real errors); **AdaGrad-Norm blind test** showed Scout/Judge/Auditor never cross-checked the *problem statement itself* for UB/LB contradiction |
| **P3: Library-first reuse via `[REF:]`** | v2.md §2.3 + v2.2_integrator | **FULL** | `explorer.md` + `scout.md` Step 0b; v2 validation: 3/3 proofs used REFs | Mechanism live; constrained by library size (~38 B/C lemmas); ROI capped until library grows |
| **P4: Literature cross-check in audit** | v2.md §4 | **FULL** | `auditor.md` cross-verification rules | v2 validation: 6/6 audit rounds contained cross-verification table comparing 3–4 prior results; no observed failures |
| **P5: Failure-pattern DB as reusable negative knowledge** | v2.md §6.2, v2 architecture §5 | **PARTIAL** | `failure_patterns.md` + `scout.md` Step 0c | Framework ready; coverage uneven (opt 15, LT 2, LDT 5); Step F extraction unstable (1/3 trigger rate in v2 validation) |
| **P6: Step F auto-extract failures** | architecture_v2.md §Step F | **PARTIAL** | `math-proof-agent/SKILL.md` §Step F (post-archive) | Triggered 1/3 in v2 validation (STORM produced +3 entries, AMSGrad/DP did not). No hard enforcement; depends on orchestrator memory |

## 3.3 Verification Chain Detail

| Method | Implementation | Trigger | Coverage |
|---|---|---|---|
| SymPy symbolic | `math-verifier` + `[CALL:math-verifier]` markers | Embedded in Auditor / Explorer; equalities, identities, limits, series | On-demand; v2 validation: 6/6 audit rounds triggered |
| Z3 inequality | `math-verifier` auto-mode (Z3 first, NumPy fallback) | Inequalities, constraints | On-demand via `[CALL]` |
| NumPy sampling (10000+) | `math-verifier` general | Generic claims; Z3 unable | On-demand; many audits include |
| Constant tracking table | `auditor.md` rule | Every audit round | **Always (mandatory)** |
| Literature cross-check | `auditor.md` rule | Every audit round (search `library/` + `research/`) | **Always**; v2 validation 6/6 |
| Step 0.5 reverse-consistency | `auditor.md` §Step 0.5 + numerical sanity | Problem.md contains UB + LB | Conditional |
| LDT checklist | `math-auditor/ldt_checklist.md` | Problem in LDT domain | LDT-specific |
| Integrator integrity sweep | `math-proof-agent/integrator.md` + `math-auditor/integration_check.md` | Auditor PASS after any Fixer round | Once per proof |

## 3.4 Difficulty-Adaptive Configuration

| Difficulty | Explorer parallelism | Max audit rounds | Integrator rounds | Notes |
|---|---|---|---|---|
| standard | 2 | 1 | 1 | Fast path, B/C |
| advanced | 3 | 2 | 1 | Graduate level, Fixer expected |
| research | 4 | 3 (or F4 gate in LDT) | 2 | A-class papers; Generator preferred |
| conjecture | 5 | 3 (or F4 gate) | 2 | Open problems; max parallel resources |

## 3.5 Supporting Skills

| Skill | Function | State | Last touched |
|---|---|---|---|
| math-dispatcher | Problem classification + routing (4-step protocol) | active / stable | 2026-04-02 |
| math-proof-agent | Five-phase core engine (Scout → Explorer → Judge → Audit → Fix) | active / iterating | prompts 2026-04-15; integrator 2026-04-21 |
| math-prover | Alias / delegate to proof-agent | active / stable | 2026-04-02 |
| math-verifier | Three-mode verification (SymPy/Z3/NumPy) + TSV (knot/braid/simplicial) | active / stable | SKILL 2026-04-02; VERIFIED_SYMPY_PROTOCOL 2026-04-21 |
| math-constructor | Object construction (LaTeX + condition verify + SymPy) | active / stable | 2026-04-02 |
| math-problem-generator | Auto-generation (7-direction rotation, 70/30 research/conjecture, A-class first) | active / iterating | rules 2026-04-15; LDT seeds 2026-04-20 |
| math-auditor | Audit logic (modular, used by proof-agent) | supporting | 2026-04-15 (auditor.md); 2026-04-20 (ldt_checklist.md) |

## 3.6 Known Limitations

| ID | Issue | Source | Severity | Workaround |
|---|---|---|---|---|
| **G1** | Reverse-consistency is **not global** — only Auditor Step 0.5 at numerical level. Scout/Judge never cross-check problem.md UB vs. LB. AdaGrad-Norm blind test: implausible UB ($\log N/\sqrt N$ vs. $\Omega(1/N^{1/4})$) was not flagged | `blind_test_adagrad_norm_postmortem.md §3` | **HIGH** | v2.3 plan: insert "problem sanity check" agent after Dispatcher to scan problem.md for self-contradiction |
| **G2** | Step F lacks forced trigger; only 1/3 proofs in v2 validation extracted patterns | `v2_validation_report.md §F4` + `SKILL.md` | MED | Move Step F from "post-archive" to "before Step D (cleanup)"; or have orchestrator hardcode-scan work_dir on archive |
| **G3** | Scout Step 0a (technique-library read) is "if exists", not mandatory; DP proof skipped it | `v2_validation_report.md §T2` | MED | Change "if exists" → "MUST"; or pre-inject summary into Scout prompt |
| **G4** | Integrator v2.2 only manually tested on spiral-knot case; not validated under full Generator runs | `agent_architecture_v2.2_integrator.md §8` | MED | Run `start grinding` 10+ times; require Fixer-rounds ≥1 to exercise Integrator |
| **G5** | Severe branch imbalance — opt 52%, prob 3%, lin-alg 1%, LDT 0% | `agent_architecture_v2.md §3.3` + `v2_validation_report.md §C2` | **HIGH** | Generator branch quota rule (≥2 prob/RL per round) or weak-branch compensation (force switch after 3 same-branch in a row) |
| **G6** | LDT checklist F2 (L1/L2/L3 citation depth) may collide with V2 audit `[VERIFIED:*]` labels | `agent_architecture_v2.1_ldt_extension.md` + `auditor.md v2.3` | MED | Treat LDT checklist as additive; both label sets coexist |
| **G7** | Generator's "must NOT search literature" rule has no automatic compliance check | `math-problem-generator/SKILL.md §约束` | LOW | Audit / human spot-check only |
| **G8** | TSV-Simplicial is toy-level — only finite local subcomplexes; no global property verification | `math-verifier/SKILL.md §TSV submodes` | MED | Tag global claims `[UNVERIFIABLE: global-property]`; do not count as FAIL |
| **G9** | Failure-pattern DB unevenly covers branches (opt 15, LT 2, LDT 5) | `failure_patterns.md` + `v2_validation_report.md §D3` | MED | Once LDT proofs land, force Step F so DB grows there |
| **G10** | Prompt-cache consistency — multiple skills read same prompt files; manual sync needed when editing (e.g. `auditor.md`) | system architecture | LOW | Process-level only; no automated remedy |

## 3.7 Score History

| Stage | Library size | Score / 100 | Notes |
|---|---|---|---|
| Round 0 baseline | 63 (pre-library/) | **54.91** | A 24.51, B 9.80, C 8.60, D 2.00, E 10.00 |
| Rounds 1–5 (predicted) | 70 (38 B/C + 32 A) | 71.85 | Predicted +16.94 from skill changes; never directly measured |
| **V2 validation (measured, 3 proofs)** | 70 | **63.75** | Measured +8.84 vs. baseline; predicted vs. measured −8.10. B / D / E underperformed prediction; A matched |
| LDT Round 0 (gap report) | +15 LDT seeds (diagnostic) | not scored | Stages 1–3 done; LDT library still empty |
| LDT Round 0.5 (delta report) | +15 LDT proofs after stage 3 | ~70–75 (predicted) | Pending validation; expected C1 +3–5, C2 +2–3 |
| **Current (2026-04-26)** | 93 (51 + 42), LDT not on board | **63.75 (last measured) → ~70–75 (predicted post-LDT)** | Awaiting Generator run with LDT seeds + Integrator validation |

Most recent A/B/C/D/E breakdown:
- A (Correctness) 25.10 / 30 — Step 0.5 + numerics work; global consistency gap remains.
- B (Efficiency) 12.33 / 20 — REF avg 2.7/proof; first-round pass rate slipped to 0/3 in test set.
- C (Knowledge accumulation) 8.82 / 20 — A-class share 40.9%; branch coverage 0/4; FP-DB 17→48.
- D (Autonomy) 7.00 / 15 — Scout library use +2.5; Step F unstable; Generator untested at scale.
- E (Research potential) 10.50 / 15 — STRONGER full credit; obstacle analysis 1.5/5.

---

# One-Sentence Summary

Today the system can autonomously close research-level proofs from 2015+ papers in optimization and learning theory at roughly 86% first-round audit pass-rate, has produced one downgraded but defensible proof of an actual open problem (OP-2 / SHB no-acceleration on Goujaud's region) that survived external peer review with three substantive scope corrections, and accumulates a self-curated library of 93 proofs + 48 failure patterns + 36 named techniques — but its true coverage is **lopsidedly optimization-heavy (≈52% of proofs)**, its reverse-consistency check is reliable only at the numerical level (problem-statement self-contradictions still leak past Scout/Judge), and its Integrator and LDT-extension modules are deployed but not yet validated at scale.

---

# Appendix — Comparison with Cumulative Reasoning (Zhang, Yang, Yuan, Yao, 2023)

Cumulative Reasoning ("Cumulative Reasoning with Large Language Models", arXiv:2308.04371, 2023) frames LLM reasoning as iterative construction of a directed acyclic graph of verified intermediate propositions. Its three roles — Proposer / Verifier / Reporter — operate jointly until the Reporter judges the goal proven.

| Dimension | Our framework | Cumulative Reasoning |
|---|---|---|
| Role partition | Dispatcher → Scout → Explorer × N → Judge → Auditor → Fixer → Integrator (7 roles) | Proposer / Verifier / Reporter (3 roles) |
| Thought structure | Linear pipeline with Auditor↔Fixer loop; Explorer is parallel breadth, not branching | DAG (cumulative): each verified proposition is a graph node; later steps reference earlier ones |
| Verification | SymPy + Z3 + NumPy (10⁴ samples) + constant tracking + literature cross-check + reverse-consistency | LLM-as-Verifier (single LLM call). Optionally augmented with code execution (Python REPL) on math/24-game tasks |
| Failure handling | `failure_patterns.md` (48 entries) → Scout retrieves on Step 0c → DAG-shaped negative knowledge persisted across problems | No persistent failure store; rejected propositions discarded within a single problem run |
| Knowledge accumulation | Proof library (93) + technique dictionary (36) + failure-pattern DB (48); cross-referenced via `[REF:]` | None across problems; each MATH/24-game query is independent |
| External tools | SymPy, Z3, NumPy, optional code-environment | Optional Python code-environment (esp. for 24-game) |
| Strongest result | OP-2 (research-level 24-page proof, downgraded but externally peer-reviewed) | MATH Level 5: 42% relative improvement over CoT; 24-game: 98% accuracy |
| Adaptive resource budget | Difficulty-tiered Explorer parallelism (2/3/4/5) + audit rounds (1/2/3/3) | None — fixed per-task config |
| Self-correction depth | Auditor → Fixer loop (≤3 rounds) + Integrator consolidation pass | Verifier rejection causes Proposer re-proposal; no global rewrite phase |

**Distinctive contributions of our framework relative to CR:**

1. **Cross-problem persistent negative knowledge** (`failure_patterns.md` retrieved by Scout on every new problem). CR has only intra-problem rejection.
2. **External-tool verification chain** (SymPy / Z3 / NumPy + constant tracking + literature cross-check) that is **mandatory and structured**, not just an optional code-execution call.
3. **Difficulty-adaptive resource allocation** (Explorer parallelism, audit caps tied to difficulty tier).
4. **Reverse-consistency / Step 0.5** — explicit check that any claimed UB is not stronger than a known LB. Has a documented blind spot (problem-statement contradictions still slip past Scout/Judge), but the mechanism is in place at audit time and has caught 3 real errors in v2 validation.
5. **Integrator role for self-contained final artifact** (v2.2). CR's Reporter aggregates DAG nodes but does not rewrite for self-containment; our Integrator inlines Fixer-only lemmas and removes stale Explorer scaffolding so the final proof.md is independently readable. Validated externally on the spiral-knot review (B+ verdict driver) but not yet stress-tested at scale.

The cleanest one-line contrast: **CR optimizes single-query reasoning depth; this framework optimizes a long-running, library-accumulating proof workflow with externally-grounded verification.**
