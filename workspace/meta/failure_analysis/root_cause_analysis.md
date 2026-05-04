# Root Cause Analysis — Per-Problem Reports

**Date**: 2026-04-27
**Convention**: each report follows the structured template requested. Root-cause classes:
- **RC1** — Problem statement was wrong (claim is false)
- **RC2** — Problem was correct but beyond current framework capability
- **RC3** — Wrong proof strategy chosen by Explorer
- **RC4** — Right strategy but technical execution error
- **RC5** — Missing prerequisite technique (not in library)
- **RC6** — Numerical / computational limitation
- **RC7** — Insufficient context or ambiguous problem statement

---

## TIER A — Hard FAILs

### Problem: A1 — Heavy-tail Clipping (initial attempt 2026-04-04)
**Source**: early heavy-tail series
**Status**: FAIL (later superseded by `proofs/research/optimization/stochastic/clipped-sgd-heavy-tail-convergence/` 2026-04-05)
**Original claim**: Clipped SGD with $\tau=O(T^{1/p-1/2})$ achieves $\frac{1}{T}\sum\mathbb{E}\|\nabla f\|^2 = O(T^{-(1-1/p)})$ under bounded $p$-th moment noise, $p\in(1,2]$.

#### What happened
All 5 initial routes (descent + bias-var, second-moment Lyapunov, martingale, Young interpolation, coupling) failed in the scout/explore phase; none identified the proxy stationarity measure $\varphi=\min(\|\nabla f\|^2,\tau\|\nabla f\|)$.

#### Where exactly did it break
Step 1 of every route: standard descent lemma + telescoping cannot absorb the clipping bias because it does not telescope cleanly. Without the proxy measure, residual terms blow up.

#### Root cause classification
**RC5** — Missing prerequisite technique (proxy stationarity measure $\varphi$ was not in the library and was not proposed by Scout).

#### What would fix it
Add the proxy stationarity measure to the library so Scout can retrieve it. (This was effectively what happened the next day: a fresh attempt with $\varphi$ as the analytic target succeeded.)

#### Salvageable parts
The 5 route sketches in `routes.md` are useful as a negative knowledge inventory.

#### Retry recommendation
**ARCHIVE as superseded** — the 2026-04-05 PASS already covers this problem with the correct framing.

---

### Problem: A2 — Benign Overfitting (Bartlett-Long-Lugosi-Tsigler 2020)
**Source**: 2026-04-17 sweep
**Status**: FAIL (variance half FULLY proved; bias half un-closeable in framework)
**Original claim**: Min-norm interpolator $\hat\beta$ has excess risk $\le C_1[\|\beta^\star\|_\Sigma^2\cdot\max\{\sqrt{r_0/n},r_0/n,\sqrt{\log n/n}\} + \sigma^2(k^\star/n + n/R_{k^\star})]$ w.p. $\ge 1-e^{-n/C_2}$.

#### What happened
4 routes attempted (Matrix Bernstein, whitening + Hanson-Wright, Weyl + Woodbury, Leave-One-Out). Route 2 produced a fully self-contained proof of the variance half. Bias half blocked in every route. Route 4 was dimensionally ill-posed in the overparameterized regime.

#### Where exactly did it break
The bias bound $\beta^{*\top}(I-P)\Sigma(I-P)\beta^* \le C\|\beta^\star\|_\Sigma^2\cdot\sqrt{r_0/n}$ requires Gordon-Slepian Gaussian comparison (Bartlett et al. 2020 Lemma 11). Operator-norm and Hanson-Wright bounds give only $\|\beta^\star\|_\Sigma^2\cdot B^2$ (factor $\sqrt{r_0/n}$ lost).

#### Root cause classification
**RC5** — Gordon comparison machinery is not in `proofs/library/`. Without it, the bias bound is unreachable from concentration alone.

#### What would fix it
Add Gordon-Slepian comparison theorem (or BLLT 2020 Lemma 11 directly) to the library as a black-box lemma; then a targeted Explorer run can close the bias half.

#### Salvageable parts
- **Variance half** is COMPLETE (Route 2 Steps 5a-5h, including Woodbury-based head-variance bound). Worth archiving as a standalone theorem.
- Tail Gram concentration $(s/2)I\preceq H\preceq (3s/2)I$ via Hanson-Wright + ε-net (Route 2 Step 2, Route 1) is a reusable lemma.

#### Retry recommendation
**RETRY with library augmentation**: (1) add Gordon-Slepian as a B-class library lemma; (2) launch a targeted single-route Explorer focused exclusively on the bias bound following BLLT Lemma 11 + Lemma 10 + Theorem 4 chain. Variance is done — do not reprove.

---

### Problem: A3 — OP-2 Sharp ($\exists f\,\forall(\beta,\eta_t)$ original)
**Source**: OP-2 original (un-downgraded)
**Status**: FAIL — genuinely open problem since 2015
**Original claim**: $\exists$ smooth convex $f:\mathbb R^2\to\mathbb R$ s.t. for *every* fixed $\beta\in[0,1)$ and every $(\eta_t)$, SHB last iterate $\ge c(LD^2/T+\sigma D/\sqrt T)$.

#### What happened
3 candidate hard instances (Nesterov tridiagonal quadratic, log-cosh hyperbola, Goujaud cycling at $\mu\to 0$) each falsified by direct SHB simulation. Plain GD reaches machine zero by $T=100$ on all three.

#### Where exactly did it break
The hard instance must simultaneously be (i) non-quadratic, (ii) $\nabla^2 f(x^\star)=0$ globally near $x^\star$, (iii) hard enough that plain GD does not beat $\Omega(LD^2/T)$. No such function is currently known in the literature; Goujaud cycling degenerates at $\mu=0$.

#### Root cause classification
**RC2** — Beyond current framework capability. Three independent constructive attempts failed; the obstruction is a genuine open research problem (Goujaud et al. 2025 explicitly leaves it open).

#### What would fix it
A new hard-instance idea outside the cycling family. Possible directions: (a) randomized smoothing oracle that prevents Chebyshev annihilation; (b) exotic non-quadratic with vanishing Hessian designed via PEP reverse-engineering; (c) infinite-dimensional construction.

#### Salvageable parts
- **Variance term $\Omega(\sigma D/\sqrt T)$** is clean (Le Cam two-point on 1-D linear).
- **Generic Krylov LB $\Omega(LD^2/T^2)$** is too weak but algebraically clean.
- The downgraded version $\forall(\beta,\eta)\in\mathcal F\,\exists f_{\beta,\eta}$ closed successfully and is archived under `proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/`.

#### Retry recommendation
**ARCHIVE as open problem**: the downgraded version is the right working theorem. Genuine sharp version requires a new mathematical idea, not a framework upgrade.

---

### Problem: A4 — OP-2 / I4 (Suffix-Average Lower Bound)
**Source**: OP-2 Iterate-Type extension
**Status**: DISPROVED (within Goujaud-construction framework)
**Original claim**: For every $(\beta,\eta)\in\mathcal F$, $\exists L$-smooth convex $f_{\beta,\eta}$ such that $f_{\beta,\eta}(\widehat y_{T,\sqrt T}) - f^\star \ge cLD^2/T$ for all $T\ge K$, where $\widehat y_{T,k}=(1/k)\sum_{t=T-k+1}^T x_t$ and $k=\lceil\sqrt T\rceil$.

#### What happened
Direct disproof in the framework. For Goujaud K-gons, $K$ is bounded above by $K_{\max}(\beta,\eta)$ (cycling inequality fails as $K\to\infty$). At resonant $T_j=(jK)^2$, suffix sum collapses to zero by rotational symmetry, hence $f(\widehat y)=f^\star$ exactly. Numerical: at $(\beta,\eta L,K)=(0.9,3,3)$, suffix-norm at $T\in\{9,36,81,144,225,900\}$ is $\sim 10^{-16}$ (machine zero).

#### Where exactly did it break
Step 1: the only known smooth-convex stability-region cycling family (Goujaud) has bounded period $K\le K_{\max}(\beta,\eta)<\infty$. Any averaging window of length $\ge K$ on a $K$-gon collapses by symmetry of $K$-th roots of unity.

#### Root cause classification
**RC1** — Problem statement was wrong as literally stated. The bound is provably FALSE on Goujaud constructions.

#### What would fix it
- Restate as "for almost every $T$" (excluding the resonance subsequence $T=(jK)^2$).
- Or restate with a different averaging horizon $k<K$ (defeats the asymptotic interpretation).
- Or find a non-Goujaud, $T$-dependent-period smooth convex construction (open since 2015).

#### Salvageable parts
- The disproof itself is a contribution: it identifies a fundamental asymmetry between last-iterate and suffix-average iterate-type lower bounds.
- Off-resonance, the bound *would* hold uniformly with $c\approx 1/2$ — useful for a "for almost every $T$" theorem.

#### Retry recommendation
**RETRY with weaker claim**: state the LB as "for $T\not\in K\mathbb N^2$" or equivalently "for a positive-density set of $T$, with $c$ uniform off resonance"; this is provably true on Goujaud and matches the spirit of the original question.

---

## TIER B — Interrupted

### Problem: B1 — Mei et al. 2020 Linear-Rate Softmax PG (original)
**Source**: 2026-04-16 RL pass
**Status**: INTERRUPTED — superseded by sublinear honest restatement
**Original claim**: $V^\star(\rho)-V^{\pi_{\theta_t}}(\rho) \le \frac{1}{1-\gamma}\exp(-\frac{\eta(1-\gamma)^2\Delta_{\min}}{2A}\cdot t)$ — a *linear* rate.

#### What happened
Scout completed (4 routes); Explorer Route 1 (Logit-Growth) completed; Route 2 (Value-Gap PL) partially completed but unverified; Routes 3, 4 not started; Judge/Audit not started.

#### Where exactly did it break
Process-level: the run was halted before Phase 3 (Judge). Subsequent attempts (2026-04-18) found that the literal linear rate is NOT what Mei et al. 2020 prove; the honest theorem is sublinear $O(1/t)$ via NU-Łojasiewicz, archived as `softmax-pg-sublinear-convergence/`.

#### Root cause classification
**RC1** + **RC7** — The linear-rate claim as stated above is *not the actual Mei et al. 2020 theorem*; it conflates the NPG result with vanilla PG. Insufficient context in the original problem statement.

#### What would fix it
Restate as the sublinear $O(1/t)$ result (already done at `proofs/research/optimization/convergence/softmax-pg-sublinear-convergence/`).

#### Salvageable parts
Route 1 (Logit-Growth + Ascent + Gradient Dominance) was high quality and forms part of the eventual sublinear proof.

#### Retry recommendation
**ARCHIVE as superseded** — the honest sublinear restatement is already in research/.

---

## TIER C — PARTIAL / DISPROVED (archived in research/)

### Problem: C1 — 3.1 SVRG Non-SC Last-Iterate
**Source**: Yuan Yang Batch (Problem 3.1)
**Status**: DISPROVED + matched bounds (PASS as honest negative result)
**Original claim**: SVRG last iterate satisfies snapshot rate $\mathbb E[f(x_T)-f^\star]\le CLD^2/(sm)$.

#### What happened
Disproof + matched UB/LB. UB: $C_1\log(m+1)LD^2/(Sm)$ via Harvey et al. 2019 last-iterate-vs-average inequality. LB: hard instance Huber+linear-tail with $b_i\in\{\pm 1\}, c_i\in\{\pm 3\}$, reduced to Harvey 2019 SGD non-SC LB, gives $\Omega(\log m\cdot LD^2/(Sm))$.

#### Where exactly did it break
The standard Lyapunov $\Phi_t = r_t^2+2\eta(m-t)(f(x_t)-f^\star)$ telescopes only after summing — i.e., averaging is essential. Without averaging, weighted variance accumulates a $\log m$ term.

#### Root cause classification
**RC1** — Original snapshot-rate claim for last iterate is FALSE. The PASS result is the honest disproof + matched bounds.

#### What would fix it
N/A — already produced the correct theorem (tight $\Theta(\log m)$ gap).

#### Salvageable parts
Full archived proof. Retry not required.

#### Retry recommendation
**ARCHIVE as negative result** — done.

---

### Problem: C2 — 7.1 OT Contrastive Representation
**Source**: Yuan Yang Batch 3 (Problem 7.1)
**Status**: PARTIAL — literal REFUTED, refined PROVED
**Original claim**: Spectral contrastive loss minimizers coincide with OT-to-cluster-Dirac minimizers under arbitrary $W$.

#### What happened
$n=4,\,\varepsilon=0.3$ counterexample under non-block $W$: $F^{\text{spec}}$ gives $L_{\text{spec}}=1.2613,\,J_{\text{OT}}=0.6545$; $F^{\text{alt}}$ gives $L_{\text{spec}}=1.9351,\,J_{\text{OT}}=0$ — argmin differ. Refined theorem proven under (H1) block-diagonal $W$, (H2) spectral gap, (H3) regular blocks + uniform within-cluster prior.

#### Where exactly did it break
The conjecture's universality fails for non-block $W$: spectral contrastive prefers the dominant eigenvector direction even when this is not cluster-aligned.

#### Root cause classification
**RC1** + **RC7** — Conjecture missing the (H1)–(H3) hypotheses.

#### Salvageable parts / Retry
Refined version archived; counterexample is a contribution. **ARCHIVE as negative result + refined positive theorem** — done.

---

### Problem: C3 — 7.2 Categorical Foundation of Multi-Agent Verification
**Source**: Yuan Yang Batch 3 (Problem 7.2)
**Status**: PARTIAL — α-contracting near-retraction (true retraction only in limit)
**Original claim**: Auditor-Fixer is a true retraction in functor category $[\mathcal C,\mathcal D]$.

#### What happened
True retraction holds only in the limit; for finite $k$, only an $\alpha$-contracting near-retraction with $\|\eta\|_\infty^k$ residual.

#### Root cause classification
**RC4** — Right strategy but the conjecture's claim "true retraction" was algebraically too strong; the proof yielded a weaker but still useful contracting-retraction theorem.

#### Salvageable parts / Retry
Discrete special case strictly recovers Problem 4.1 bounds. **ARCHIVE as PARTIAL** — done.

---

### Problem: C4 — 7.3 SSL InfoNCE Minimax Lower Bound
**Source**: Yuan Yang Batch 3 (Problem 7.3)
**Status**: PARTIAL (up to log factors)
**Original claim**: Downstream risk $\ge C\cdot d^2/(n\cdot I(X;X'\mid A))$.

#### What happened
Routes 1-3 hit the $d/(n\cdot I)$ ceiling; correct $d^2$ rate requires *joint* sup over $(f^\star,w^\star)$, not just $w^\star$. Final result up to log factors.

#### Where exactly did it break
The literal "sup_{w^\star}" notation is misleading; needs $\sup_{(f^\star,w^\star)}$ jointly. Also requires $\|w^\star\|^2\le d$ normalization (vs unit ball).

#### Root cause classification
**RC7** — Ambiguous problem statement (sup notation unclear); plus partial **RC5** (Assouad's hypercube method needed to remove log gap, not used).

#### What would fix it
- Clarify "sup over the full minimax adversary" in problem.md.
- Add Assouad's hypercube to library and rerun a focused Explorer to close the log gap.

#### Retry recommendation
**RETRY with weaker claim** (already archived) — the log-gap version is a strong PARTIAL; sharpening is a separate retry.

---

### Problem: C5 — 7.4 CR Non-Stationary Verifier
**Source**: Yuan Yang Batch 3 (Problem 7.4)
**Status**: PASS-WITH-CORRECTIONS
**Original claim**: 4-part theorem about $\varepsilon_t = \varepsilon_0(1+t/T_0)^\alpha$ verifier.

#### What happened
(a) sub-linear PASS; (b) PASS-with-clarification ($T^{**}$ identified); (c) super-linear PASS-with-correction (problem's $T_0^{\alpha/(\alpha-1)}\varepsilon_0^{-1/(\alpha-1)}$ is dimensional typo; correct $T_{\text{div}}=((\alpha+1)T_0^\alpha/\varepsilon_0)^{1/(\alpha+1)}$); (d) closed-form for special $\alpha$.

#### Root cause classification
**RC1** (part (c) typo) + **RC7** (parts (b),(d) ambiguous formulation).

#### Salvageable parts / Retry
Already PASS-with-correction. **ARCHIVE** — done.

---

### Problem: C6 — 7.5 Matrix Rényi Entropy Collapse
**Source**: Yuan Yang Batch 3 (Problem 7.5)
**Status**: PARTIAL — (c) conditional on (H1)–(H3)
**Original claim**: Gradient-flow monotonicity $\frac{dS_\alpha}{dt}\ge c(S_\alpha^{\max}-S_\alpha)\lambda_{\min}(\nabla^2 L_{\text{MSSL}})$ universally.

#### What happened
(a),(b) PASS unconditionally. (c) PASS only under explicit (H1)–(H3) hypotheses on $L_{\text{MSSL}}$. Concrete losses like $\|K-I/n\|^2/2$ verified.

#### Root cause classification
**RC7** — Original statement of (c) lacked the structural hypotheses on $L_{\text{MSSL}}$ that make the bound true.

#### Salvageable parts / Retry
Already archived. **ARCHIVE** — done.

---

### Problem: C7 — 7.6 Heavy-Tailed Trajectory Decomposition
**Source**: Yuan Yang Batch 3 (Problem 7.6)
**Status**: PASS-WITH-CAVEAT
**Original claim**: SGD generalization under $E\|\nabla L\|^p\le G^p$, $p\in(1,2)$, splits into signal + noise pieces; clipping at $\tau=G\cdot T^{1/p-1/2}$ matches minimax.

#### What happened
PASS for the algebra. Caveat: the $T^{-1/2}$ noise suppression requires Polyak-Ruppert averaging; un-averaged optimum is $\tau=G\cdot T^{1/p}$.

#### Root cause classification
**RC7** — Original problem implicitly assumed averaging.

#### Salvageable parts / Retry
**ARCHIVE** — done with explicit caveat.

---

### Problem: C8 — 7.7 CR Compositional Reuse
**Source**: Yuan Yang Batch 3 (Problem 7.7)
**Status**: PASS-WITH-CORRECTION
**Original claim**: User-stated form $(1-\delta)^{\Delta^d}$.

#### What happened
Honest correction: induction yields strictly tighter $(1-\delta)^{N(d,\Delta)}$ with $N=(\Delta^{d+1}-1)/(\Delta-1)$.

#### Root cause classification
**RC1** — User's stated exponent is wrong; the proof gave a stronger correct form.

#### Salvageable parts / Retry
**ARCHIVE** — done.

---

### Problem: C9 — 7.8 SSL Augmentation Phase Transition
**Source**: Yuan Yang Batch 3 (Problem 7.8)
**Status**: PARTIAL — claim (c) REFUTED
**Original claim**: 4-part theorem; (c) asserts a *first-order discontinuous* gap at $\sigma^\star_{\text{aug}}$.

#### What happened
(a) rank-$k$ below $\sigma^\star$ PASS; (b) rank-1 collapse above $\sigma^\star$ PASS; (d) $\sigma^\star_{\text{aug}}=\Theta(\Delta_{\min}/\sqrt d)$ PASS (CoV 2.3% across 12 configs). (c) REFUTED — under natural smooth Gaussian model, transition is **second-order** (gap $g(\sigma_{\text{aug}})$ is real-analytic, no jump).

#### Where exactly did it break
The conjecture conflated "structural rank change" (real, first-order in the discrete eigenstructure) with "objective discontinuity" (false, the loss is smooth).

#### Root cause classification
**RC1** — Conjecture's "first-order" framing is wrong for the natural model.

#### Salvageable parts / Retry
True first-order would need $d\to\infty$ scaling limit or non-analytic structure. **ARCHIVE as PARTIAL with refutation** — done.

---

### Problem: C10 — 7.9 CR Depth Lower Bound
**Source**: Yuan Yang Batch 3 (Problem 7.9)
**Status**: PARTIAL
**Original claim**: 3-part theorem; (c) asserts numerical answer "≈18 steps" at $\varepsilon=0.14, k=3, d=5, \delta=0.01$.

#### What happened
(a) $T\ge d\log(1/\delta)/\log(1/\varepsilon)$ PASS via Yao + Bayes-error tail; (b) PARTIAL — no-parallelization holds only under transcript-dependency model; (c) PARTIAL — formula is correct, but problem's "≈18" is an arithmetic error of $\sim 4.6\times$ (true value 3.9).

#### Root cause classification
- (b): **RC7** — model-dependence not specified in problem.
- (c): **RC1** — arithmetic error in problem statement.

#### Salvageable parts / Retry
**ARCHIVE** — done with explicit corrections.

---

### Problem: C11 — 7.10 Adversarial Trajectory Tradeoff
**Source**: Yuan Yang Batch 3 (Problem 7.10)
**Status**: PARTIAL
**Original claim**: 2-part theorem; Claim 2's *literal* formula $T^*_{\text{adv}}=T^*_{\text{clean}}/(1+r^2H^2\eta)$.

#### What happened
Claim 1 (Penalty bound) PASS. Claim 2 strict $T^*_{\text{adv}}<T^*_{\text{clean}}$ PASS via argmin-shift. Literal formula PARTIAL — under natural parameterization (G_S=α/T, G_N=β√(Tη)), exact ratio is $(\beta/(\beta+crH))^{2/3}$, which linearizes to $1-(2/3)crH/β$ — **linear in $rH$**, not quadratic.

#### Root cause classification
**RC1** — Literal formula's $r^2$ scaling is wrong; correct dependence is linear $rH$ at leading order.

#### Salvageable parts / Retry
**ARCHIVE** — done with explicit honest scope.

---

### Problem: C12 — I3 SHB Best-Iterate Lower Bound
**Source**: OP-2 Iterate-Type extension (I3)
**Status**: PARTIAL — bias PROVED, variance DISPROVED
**Original claim**: $\mathbb E[\min_{0\le t\le T}f(x_t)-f^\star]\ge c(\beta,\eta)\cdot LD^2/T + c'\sigma D/\sqrt T$.

#### What happened
Bias proven via direct transfer of OP-2's deterministic Lemma AP. Variance term disproved: SHB random walk on linear-with-wall $g_y$ has stationary variance $\Theta(\sigma^2\eta^2/((1-\beta^2)L^2))$, visits optimum's neighborhood $\Theta(T)$ times, so $\min_t g_y(y_t)-\min g_y = O(L\cdot V/T)=O(1/T)$, NOT $\Omega(\sigma D/\sqrt T)$.

#### Where exactly did it break
The Le Cam two-point test $\hat s=-\text{sign}(y_{t^*})$ achieves NEAR-PERFECT classification because $y_{t^*}$ is by definition near the optimum on the side $-s$. Le Cam consistent but cannot be used to derive the gap LB.

#### Root cause classification
**RC1** — Variance Ω(σD/√T) is a property of algorithm OUTPUT, not best iterate; literal claim was wrong.

#### Salvageable parts / Retry
Bias half + variance disproof both archived. **ARCHIVE as honest negative + asymmetry observation** — done.

---

### Problem: C13 — I5 Polyak-Ruppert Defeats SHB Cycling
**Source**: OP-2 Iterate-Type extension (I5)
**Status**: DISPROVED + matched UB
**Original claim**: PR weighted average $\tilde x_T$ satisfies $\Omega(LD^2/T)$ on Goujaud cycling region.

#### What happened
Heuristic: $|\sum_{t=1}^T t\omega^t| = O(T/(1-\omega)) = O(TK)$ for $\omega=e^{2\pi i/K}\ne 1$. Dividing by $W_T=T(T+1)/2$ gives $\|\tilde x_T-x^\star\|=O(K/T)$, hence $f(\tilde x_T)-f^\star=O(LD^2K^2/T^2)$. Disproof + matching UB $LD^2/(4T^2\sin^4(\pi/K))$ archived.

#### Root cause classification
**RC1** — Targeted LB is FALSE. PR achieves AC-SA acceleration on Goujaud's instance.

#### Salvageable parts / Retry
**ARCHIVE as positive result for PR** — done.

---

### Problem: C14 — S4 SHB Interpolation-Regime Lower Bound
**Source**: OP-2 Noise Model extension (S4)
**Status**: PARTIAL — bias survives, variance impossible
**Original claim**: Both bias and variance LBs survive under interpolation noise.

#### What happened
Bias survives trivially ($\sigma=0$ subcase). Variance term provably ABSENT under interpolation noise: $f(x)=(\mu/2)\|x\|^2$ with multiplicative noise $\xi_t=N(0,\sigma^2\|x_t-x^\star\|^2)$ gives geometric convergence $\mathbb E[f(x_T)-f^\star]\le e^{-cT}LD^2$ — beats any polynomial $\Omega(\sigma D/\sqrt T)$.

#### Root cause classification
**RC1** — Variance LB literally false under interpolation; expected outcome (Vaswani 2019, Bach 2014).

#### Salvageable parts / Retry
**ARCHIVE** — done as honest split theorem.

---

## TIER D — OP-2 Ablation Failures (failure_patterns only)

### Problem: D-OP2-Cesaro — Cesàro Average Extension
**Source**: OP-2 New Construction
**Status**: DISPROVED
**Original claim**: $\Omega(LD^2/T)$ on $\bar x_T=(1/T)\sum x_t$.

#### What happened
For Goujaud cycling, $\sum_{t=0}^{K-1}e_t=0$ exactly (regular polygon vertex sum). Hence $\bar x_T\to 0$ deterministically, $f_0(\bar x_T)\le LD^2/T^2$ — AC-SA bias rate, not $\Omega(LD^2/T)$.

#### Root cause classification
**RC1** — Birkhoff ergodic theorem + rotational symmetry says any orbit on a $\mu$-SC Goujaud polytope has barycenter at $x^\star$. Time averages converge to spatial average = barycenter. Adding stochastic A3 only gives $\Omega(\sigma_x^2/T)$, dominated by $\sigma D/\sqrt T$.

#### Retry recommendation
**ABANDON** — cycling-style hard instances cannot be averaged-iterate-extended without breaking rotational symmetry, but the cycling identity is rotation-equivariant. Genuine breakthrough requires a non-cycling LB technique.

---

### Problem: D-OP2-Init — Zero-Momentum Init Extension (B-series)
**Source**: OP-2 Upgrade B
**Status**: PARTIAL — only $\mathcal F_{\text{usable}}\subsetneq \mathcal F$
**Original claim**: OP-2 LB extends to standard zero-momentum init $x_0=x_{-1}$.

#### What happened
9×5 = 45 grid sweep over $(\beta,\eta L)\in\mathcal F_{K=3}$: 26/45 DECAY (geometric to $x^\star$, LB fails); 4/45 ATTRACT (LB holds); 15/45 OTHER (bounded-away orbit, LB holds).

#### Where exactly did it break
The cycling orbit may or may not be attracting depending on spectral linearization at the origin. Decay regime dominates at low $\beta$ and $\eta L$ near $\gamma_{\text{crit}}$.

#### Root cause classification
**RC1** + **RC7** — LB does not hold *for all* $\mathcal F$ under generic init; problem statement should specify $\mathcal F_{\text{attract}}$.

#### Retry recommendation
**RETRY with weaker claim**: state OP-2 with $\forall\exists$ initialization (current) AND a separate weaker theorem on $\mathcal F_{\text{usable}}$ with zero-momentum init.

---

### Problem: D-OP2-PEP — PEP Witness Extraction (B2)
**Source**: OP-2 Upgrade B2
**Status**: TIMEOUT
**Original claim**: Use PEP-tight bound to construct explicit witness function for HB-with-zero-momentum-init achieving $\Omega(LD^2/T)$.

#### What happened
PEP gives algorithm-tight worst-case bounds via convex SDP whose optimal solution corresponds to an *implicit* worst-case function. Reverse-engineering an explicit, named function family (quadratic, piecewise-quadratic) is a non-trivial separate research problem.

#### Root cause classification
**RC2** — Beyond current framework capability. PEP witness reverse-engineering is a separate research project.

#### Retry recommendation
**ABANDON** for now. If pursued: target Drori–Teboulle's worst-case quadratic for GD as a template; expect substantial effort.

---

### Problem: D1 — Adam / RMSProp Extension of OP-2
**Source**: OP-2 Divergent (D-series)
**Status**: DISPROVED — Adam REACHES OPTIMUM on OP-2 instance
**Original claim**: OP-2 LB extends to fixed-hyperparameter Adam/RMSProp.

#### What happened
Cycling broken at iteration 1 in three ways: (i) per-coord $g_t^2$ rotates with up to 27:1 ratio, breaking coord-wise homogeneity; (ii) bias correction $\hat v_1=g_0^2$ at $t=1$ regardless of $\beta_2$, jumping $\|x_1\|\approx 3.78$ from cycle radius 0.71; (iii) $\beta_2=0,\epsilon=0$ gives sign-SGD which destroys affine equivariance.

#### Root cause classification
**RC1** — OP-2 LB is algorithm-specific to fixed-momentum SHB; it is genuinely FALSE for Adam.

#### Retry recommendation
**ABANDON the bias term**; **RETRY only the variance term** with decoupled $y$-coordinate Le Cam construction (constants depend on $(\beta_1,\beta_2,\epsilon,\eta L)$).

---

### Problem: D4 — High-Dim Variance Scaling $\sqrt{d-2}$
**Source**: OP-2 Divergent (D-series)
**Status**: DISPROVED under $\ell_2$-bounded oracle
**Original claim**: Variance $\Omega(\sigma D\sqrt{d-2}/\sqrt T)$ in dim $d\ge 3$.

#### What happened
Cauchy-Schwarz: $\sum_i\alpha_i D_i\le \|\alpha\|_2\|D\|_2 = (\sigma/(2\sqrt{2T}))\cdot(D/\sqrt 2) = \sigma D/(4\sqrt T)$ — dimension-independent. The $\sqrt{d-2}$ from $d-2$ tests cancels with $1/\sqrt{d-2}$ from per-coord variance dilution.

#### Root cause classification
**RC1** — Under $\ell_2$-bounded variance oracle, naive product extensions of single-coord Le Cam do NOT scale with dim.

#### Retry recommendation
**RETRY with stronger oracle**: $\ell_\infty$-bounded oracle ($\|\xi_t\|_\infty\le\sigma$) allows total variance $d\sigma^2$ and gives $\sqrt d$ scaling. Or use coupled hypothesis classes (Nemirovski-Yudin / Agarwal $\sqrt{\log d}$).

---

### Problem: D5 — Polyak vs Nesterov Rate Separation
**Source**: OP-2 Divergent (D-series)
**Status**: PARTIAL — cycling specific to Polyak; no clean separation
**Original claim**: Nesterov accelerates on the OP-2 instance where Polyak is stuck.

#### What happened
(a) Nesterov's lookahead $y_t$ is not a vertex of $\widetilde P$ (e.g., $\|y_0\|=1.275$ vs vertex 0.49), so GTD23 projection identity fails; cycling closure fails. (b) Nesterov on $f_0$ does NOT converge geometrically either — has its own non-zero attractors at different $(\beta,\eta)$. So $\liminf f_0(x_t)>0$ in cases A, B; bias also $\Omega(1)$ asymptotically.

#### Root cause classification
**RC1** + **RC2** — Cycling LBs are inherently algorithm-specific to vertex-querying methods. Nesterov has its own non-cycling-but-non-converging behavior on the same instance.

#### Retry recommendation
**RETRY with different separator**: positive convergence proof for Nesterov on a *different* instance designed for its lookahead structure. The Polyak-vs-Nesterov gap as a *qualitative observation* is worth a remark.

---

## TIER E — Problem-Statement Validation Failures

### Problem: E1 — AdaGrad-Norm Last-Iterate (Blind Test)
**Source**: 2026-04-17 blind test (`workspace/active/proof_work_20260417_adagrad_norm_last_iterate`)
**Status**: FAIL — internal contradiction never flagged
**Original claim**: UB $O(1/N^{1/4})$ AND LB $\Omega(1/N^{1/4})$, claimed tight.

#### What happened
Explorer Route 3 produced UB $O(\log N/\sqrt N)$ — strictly stronger than the claimed UB, but ASYMPTOTICALLY CONTRADICTS the LB ($\log N/\sqrt N \ll 1/N^{1/4}$). Judge selected Route 3 (21/30); Auditor numerically verified algorithm convergence and accepted. No phase did reverse-consistency check.

#### Where exactly did it break
Route 3 misapplied Shamir-Zhang suffix averaging (valid for averaged iterate) to the last iterate. This is a classical trap. Compounded by the framework's lack of UB-vs-LB consistency check at any stage.

#### Root cause classification
**RC4** (Route 3 misapplication of suffix averaging) + **RC1** (problem.md UB and LB are mutually inconsistent — at most one holds).

#### What would fix it
- Auditor Step 0.5 reverse-consistency check (DONE — already deployed).
- Judge REJECT_ALL branch (DONE).
- Sweep all `proofs/research/` proofs of UB+LB+tightness theorems for the same blind spot.

#### Retry recommendation
**RETRY**: Re-state the problem with *only* the LB (which is provably the correct asymptotic, $\Omega(1/N^{1/4})$ for last iterate). Drop the UB. Then prove the LB cleanly.

---

### Problem: E2 — ADMM Ergodic O(1/T) Missing Feasibility
**Source**: 2026-04-18 ADMM run
**Status**: Detected and resolved
**Original claim**: Bound holds for *any* test point.

#### What happened
4 parallel Explorers independently surfaced "needs feasibility $A\tilde x+B\tilde z=c$"; Route 3 gave an explicit counterexample.

#### Root cause classification
**RC7** — Implicit feasibility assumption hidden in the ergodic-PP template.

#### Retry recommendation
**ARCHIVE** — already resolved by restating with feasibility; passed.

---

### Problem: E3 — Q-learning UCB-Hoeffding Bonus Scale
**Source**: 2026-04-18 Q-learning run
**Status**: Detected and resolved
**Original claim**: $b_t = cH\sqrt{\iota/t}$ achieves $\sqrt{H^4SAT}$.

#### What happened
Routes B, C independently identified bonus too small; needs $cH^{3/2}\sqrt{\iota/t}$ (the actual JABJ 2018 setting).

#### Root cause classification
**RC7** — Problem statement misspecified the bonus.

#### Retry recommendation
**ARCHIVE** — already resolved by restating bonus; passed.

---

## Summary table by Root Cause

| RC | Count | Examples |
|---|---|---|
| RC1 (false claim) | 11 | A4, C1, C8, C9 (c), C10 (c), C11, C12, C13, C14, D-OP2-Cesaro, D-OP2-Init (partial), D1, D4, D5, E1 (mixed with RC4) |
| RC2 (beyond capability) | 3 | A3, D-OP2-PEP, D5 |
| RC3 (wrong strategy) | 0 | (No problem-level RC3; route-level RC3s in Tier F are recovered by other routes) |
| RC4 (execution error) | 2 | C3, E1 (Route 3 misapplication) |
| RC5 (missing technique) | 2 | A1 (proxy stationarity), A2 (Gordon comparison) |
| RC6 (computational) | 0 | — |
| RC7 (ambiguous statement) | 7 | B1, C2, C4, C5, C6, C7, C9 (b), C10 (b), D-OP2-Init, E2, E3 |

Total problem-level non-PASS reports: **28**.
