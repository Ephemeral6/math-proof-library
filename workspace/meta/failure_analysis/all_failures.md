# All Failures — Complete Inventory of Non-PASS Problems

**Date generated**: 2026-04-27
**Scope**: every problem from `proofs/research/`, `workspace/archive/`, `workspace/failure_patterns.md`, and the named batches that did **not** result in a clean PASS.

> Note on terminology
> - **FAIL** — no proof produced; protocol terminated without an archived theorem.
> - **PARTIAL** — proof archived under `proofs/research/`, but with explicit qualifications (subset of claims proved, weakened constants, missing log factors, or hidden hypotheses surfaced).
> - **DISPROVED** — claim proved false; archived as honest negative result.
> - **TIMEOUT** — agent reached the configured cap without verdict.
> - **INTERRUPTED** — protocol stopped mid-pipeline (status not definitive).
>
> A DISPROVED result is *not* a pipeline failure: it is the correct outcome when the original conjecture is wrong. It is included for completeness and because every DISPROVED result was preceded by some attempted proof.

---

## Tier A — Hard FAILs (no archived theorem)

| # | ID | Topic | Source / Batch | Date | Working dir |
|---|---|---|---|---|---|
| A1 | Heavy-tail clipping (initial) | Clipped SGD convergence under bounded p-th moment noise | early heavy-tail series | 2026-04-04 | `archive/failed_proof_work_20260404_100000/` |
| A2 | BLLT 2020 — Benign Overfitting | Min-norm interpolator excess risk; bias bound never closed | OP-style attempt | 2026-04-17 | `archive/failed_proof_work_20260417_203157/` |
| A3 | OP-2 sharp ∃f∀(β,η_t) | SHB no-acceleration in original (un-downgraded) form | OP-2 original | 2026-04-17 | `archive/failed_proof_work_20260417_op2/` |
| A4 | OP-2 / I4 (suffix-average LB) | SHB suffix-average iterate-type extension | OP-2 Iterate-Type | 2026-04-26 | `archive/failed_proof_work_op2_I4_20260426_120000/` |

## Tier B — INTERRUPTED (later superseded)

| # | ID | Topic | Source / Batch | Date | Resolution |
|---|---|---|---|---|---|
| B1 | Mei et al. 2020 (linear-rate softmax PG) | Original linear-rate target | early RL pass | 2026-04-16 | INTERRUPTED at Explorer Route 2; later closed in **honest restated form** as `softmax-pg-sublinear-convergence/` (2026-04-18). Original linear-rate claim still open. |

## Tier C — PARTIAL / DISPROVED (archived in `proofs/research/`)

These are honest negative or qualified results: the conjecture as literally stated did not survive, but a refined version did, or the failure itself is an informative result.

| # | Problem | Branch | Verdict | What survives | Date |
|---|---|---|---|---|---|
| C1 | **3.1** SVRG non-SC last-iterate | optimization/convergence | DISPROVED + matched bounds | Snapshot rate $LD^2/(Sm)$ FAILS for last iterate; tight $\Theta(\log m)$ gap proven (UB + LB). | 2026-04-26 |
| C2 | **7.1** OT contrastive characterization | LT/generalization | LITERAL REFUTED, refined PROVED | $n=4,\,\varepsilon=0.3$ counterexample under non-block $W$; refined theorem holds under (H1) block-diagonal + (H2) spectral gap + (H3) regular blocks. | 2026-04-26 |
| C3 | **7.2** Categorical foundation of multi-agent verification | multi-agent | PARTIAL | $\alpha$-contracting near-retraction (true retraction only in the limit); discrete special case strictly recovers Problem 4.1. | 2026-04-26 |
| C4 | **7.3** SSL InfoNCE minimax LB | LT/generalization | PARTIAL (up to log factors) | $C\cdot d^2/(n\cdot I)$ proven up to logs; requires sup over $(f^\star,w^\star)$ jointly with $\|w^\star\|^2\le d$, $n_{\text{down}}\to\infty$. | 2026-04-26 |
| C5 | **7.4** CR non-stationary verifier | multi-agent | PASS-WITH-CORRECTIONS | (a) sub-linear PASS; (b) PASS-with-clarification ($T^{**}$ identified); (c) super-linear PASS-with-correction (problem's $T_0^{\alpha/(\alpha-1)}\varepsilon_0^{-1/(\alpha-1)}$ is a dimensional typo); (d) asymptotic optimum closed-form. | 2026-04-26 |
| C6 | **7.5** Matrix Rényi entropy collapse | LT/generalization | PARTIAL (conditional) | (a),(b) PASS; (c) gradient-flow monotonicity PASS only under explicit (H1)–(H3) hypotheses on $L_{\text{MSSL}}$. | 2026-04-26 |
| C7 | **7.6** Heavy-tailed trajectory decomposition | LT/stability | PASS-WITH-CAVEAT | The $T^{-1/2}$ noise suppression requires Polyak–Ruppert averaging together with $\eta=c_p T^{(p-2)/(2p)}m^{(2-p)/(2p)}$; un-averaged optimum is $\tau=G\cdot T^{1/p}$. | 2026-04-26 |
| C8 | **7.7** CR compositional reuse | multi-agent | PASS-WITH-CORRECTION | User-stated $(1-\delta)^{\Delta^d}$ form is wrong by induction; honest tighter form $(1-\delta)^{N(d,\Delta)}$ with $N=(\Delta^{d+1}-1)/(\Delta-1)$ proved. | 2026-04-26 |
| C9 | **7.8** SSL augmentation phase transition | LT/generalization | PARTIAL — claim (c) REFUTED | (a),(b),(d) PASS; (c) "first-order discontinuous" REFUTED — transition is **second-order** smooth under natural Gaussian model. | 2026-04-26 |
| C10 | **7.9** CR depth lower bound | multi-agent | PARTIAL | (a) PASS; (b) PARTIAL — no-parallelization holds only under transcript-dependency model; (c) PARTIAL — formula correct but problem's claimed "≈18 steps" is an arithmetic error (true value $\approx 3.9$). | 2026-04-26 |
| C11 | **7.10** Adversarial trajectory tradeoff | LT/stability | PARTIAL | Penalty($r$) and strict $T^*_{\text{adv}}<T^*_{\text{clean}}$ PASS; literal formula $T^*_{\text{clean}}/(1+r^2H^2\eta)$ PARTIAL — natural-parameterization exact ratio is $(\beta/(\beta+crH))^{2/3}$, **linear** in $rH$ not quadratic. | 2026-04-26 |
| C12 | **I3** SHB best-iterate LB | optimization/lower-bounds | PARTIAL — variance DISPROVED | Bias $\Omega(\kappa LD^2/T)$ PROVED; variance $\Omega(\sigma D/\sqrt T)$ DISPROVED via random-walk-visit counterexample. | 2026-04-26 |
| C13 | **I5** Polyak–Ruppert defeats SHB cycling | optimization/convergence | DISPROVED + matching UB | Targeted $\Omega(LD^2/T)$ FALSE; matching UB $O(LD^2/T^2)$ proved on Goujaud's hard instance. Polyak–Ruppert achieves AC-SA bias rate where last iterate is stuck at $\Theta(1)$. | 2026-04-26 |
| C14 | **S4** SHB interpolation-regime LB | optimization/lower-bounds | PARTIAL — variance impossible | Bias $\Omega(LD^2/T)$ survives; variance $\Omega(\sigma D/\sqrt T)$ provably absent under interpolation noise (multiplicative / gradient-magnitude-scaled). | 2026-04-26 |

## Tier D — OP-2 ablation studies (recorded only as `failure_patterns.md` entries, no `proofs/` folder)

These were exploration runs around OP-2 to test how far the lower-bound technique extends. Each ended in DISPROVED or PARTIAL but the working dir was not promoted to a research proof.

| # | ID | Source / Batch | Verdict | failure_patterns.md tag |
|---|---|---|---|---|
| D-OP2-Cesaro | OP-2 New Construction approach: Cesàro-average extension | OP-2 New Construction | DISPROVED | `FP-OP2-SYMMETRIC-CYCLE-AVERAGING-COLLAPSE-2026-04-26` |
| D-OP2-Init | OP-2 Upgrade B: zero-momentum init extension | OP-2 Upgrade (B-series) | PARTIAL — only $\mathcal F_{\text{usable}}\subsetneq \mathcal F$ | `FP-OP2-CYCLING-INIT-BASIN-DEPENDENCE-2026-04-26` |
| D-OP2-PEP | OP-2 Upgrade B2: PEP-based explicit witness extraction | OP-2 Upgrade (B-series) | TIMEOUT — reverse-engineering inexplicit | `FP-PEP-WITNESS-INEXPLICITNESS-2026-04-26` |
| D1 | Adam / RMSProp extension of OP-2 | OP-2 Divergent (D-series) | DISPROVED — Adam reaches optimum on the OP-2 instance | `FP-OP2-ADAM-COORDWISE-SCALING-BREAKS-CYCLING-2026-04-26` |
| D4 | High-dim variance scaling $\Omega(\sigma D\sqrt{d-2}/\sqrt T)$ | OP-2 Divergent (D-series) | DISPROVED under $\ell_2$-bounded oracle | `FP-OP2-CAUCHY-SCHWARZ-CANCELLATION-IN-PRODUCT-LECAM-2026-04-26` |
| D5 | Polyak vs Nesterov rate separation on OP-2 instance | OP-2 Divergent (D-series) | PARTIAL — cycling specific to Polyak; Nesterov has its own non-converging behavior, no clean separation | `FP-OP2-NESTEROV-LOOKAHEAD-OFF-VERTEX-2026-04-26` |

## Tier E — Problem-statement validation failures (caught by reverse-consistency)

| # | ID | What broke | Resolution |
|---|---|---|---|
| E1 | AdaGrad-Norm last-iterate (blind test, 2026-04-17) | `problem.md` simultaneously demanded UB $O(1/N^{1/4})$ and LB $\Omega(1/N^{1/4})$, but Route 3 produced UB $O(\log N/\sqrt N)$ — strictly stronger; an asymptotic contradiction with the LB, missed by every phase. | Auditor prompt patched (Step 0.5 reverse-consistency); Judge given REJECT_ALL branch. Logged as `FP-18`. |
| E2 | ADMM ergodic O(1/T) — `problem.md` missing feasibility | Original problem claimed bound for *any* test point; 4 parallel Explorers independently surfaced "needs $A\tilde x+B\tilde z=c$". | Restated with feasibility requirement; later passed. |
| E3 | Q-learning UCB-Hoeffding — `problem.md` bonus scale wrong | Stated $b_t=cH\sqrt{\iota/t}$, target $\sqrt{H^4SAT}$; routes B and C independently identified bonus needed at least $cH^{3/2}\sqrt{\iota/t}$ (the actual JABJ 2018 setting). | Restated; later passed. |

## Tier F — Multi-route inner failures (problem ultimately PASSED via a different route)

These are recorded in `failure_patterns.md` as route-level failures. The problem itself was eventually closed; they are listed here only because the prompt asks for *every non-PASS attempt*. Each entry is a route, not a problem.

| Theorem | Failed routes (winning route in parens) | Date |
|---|---|---|
| Coordinate Descent O(nL̄/ε) | Route 1 (Euclidean Lyapunov), Route 3 (Estimate Sequence) — won via Route 2/4 | 2026-04-11 |
| Implicit Bias of GD Max Margin | Routes 2 (dual), 3 (gradient align), 4 (cosine Lyapunov) — won via Route 1 (per-data-point margin) | 2026-04-12 |
| Fenchel Smoothness–SC Duality | Routes 1 (surjectivity), 3 (domain analysis) — won via cocoercivity | 2026-04-12 |
| Bernstein's Inequality | Route 1 (Bennett's lemma), Route 3 (independent attempt) — won via standard MGF | 2026-04-12 |
| SAM Convergence | Route 2 ($\tilde x_t$-Lyapunov) — won via direct descent on $f^{\text{SAM}}$ | 2026-04-12 |
| NTK Infinite-Width Convergence | Routes 1-3 (entry-wise / Markov / ε-net) — won via Route 4 (Schur product) | 2026-04-07 |
| PAC-Bayes Bound | Route 1 first attempt (uniform-in-Q λ optimization) — fixed via λ-grid union bound | 2026-04-07 |
| SGD PL + Interpolation Averaging | Routes 1-4 (uniform analysis) — won via Route 5 (polynomial induction) | 2026-04-08 |
| STORM Non-Convex | Routes 1 (Young), 2 (Direct Variance Recursion), 3 (Biased SGD framework) — won via joint Lyapunov | 2026-04-16 |
| Softmax PG O(1/t) | Routes 2 (PDL+MV), 3 (KL potential), 4 (mirror+NPG comparison) — won via Route 1; also Route 1 fix Round 1 had constant-redefinition bug | 2026-04-18 |
| AdaGrad-Norm O(log T/√T) | Routes 3 ($V_k$ Lyapunov), 4 (online-to-batch) — won via Routes 1/2 | 2026-04-18 |
| Xu–Raginsky MI Bound | Route C (PAC-Bayes reduction) — won via Routes A/D (DV per-sample) | 2026-04-18 |
| ADMM ergodic O(1/T) (He–Yuan 2012) | Route 2 (DR-on-dual), Route 4 (proximal-point in semi-norm) — won via Route 3 (VI + telescope + Jensen) | 2026-04-18 |
| UCB-Hoeffding Q-learning Regret | Routes B (martingale-first), C (advantage decomposition), D (online-to-batch / expert) — won via Route A | 2026-04-18 |
| SHB sharp version (OP-2) | Routes A (log-cosh), B (PEP), C (Goujaud at $\mu\to 0$) — all 3 falsified by simulation; survived only as the *downgraded* OP-2 | 2026-04-17 |
| Spiral knot genus formula | FP-SPIRAL family (Kauffman convention, basis change in Burau, skein non-uniformity, principal-minor mis-framing, param-swap mixed-case L1) — multiple route deaths before Burau succeeded | 2026-04-20/21 |

## Cross-reference summary

| Tier | Count |
|---|---|
| A — Hard FAIL | 4 |
| B — Interrupted | 1 |
| C — Archived PARTIAL/DISPROVED in research/ | 14 |
| D — OP-2 ablation (failure-pattern only) | 6 |
| E — Problem-statement validation failures | 3 |
| F — Inner route failures (problem PASSED via other route) | 16 named theorems, ~45 individual route failures |

**Problem-level non-PASS attempts (excluding F)**: **28** (4 + 1 + 14 + 6 + 3).
