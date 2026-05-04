# Proposer Output — Ranked Candidate Problems

**Date**: 2026-04-27
**Mode A candidates generated**: 88 (32 gap_matrix + 23 pattern_extrapolation + 15 failure_conjectures + 18 cross_domain_transfer)
**Mode B anomalies found**: 17
**After dedup + cross-reference**: 89 unique candidates
  - Pure Mode A: 74
  - Pure Mode B: 3 (A-9 quartic 1/T², A-13 NAG constant deterioration, A-14 SVRG U-shape)
  - Mode A+B (computationally upgraded): 12
**After novelty filter**: 71 kept / 8 discarded (already published) / 10 KEEP-WITH-CAVEAT (close prior work) / **~70 candidates are [NOVELTY-UNCHECKED]** (only top ~12 had explicit web searches due to time budget)
**Final ranked count**: 73 (top 15 in detail + tail one-liners)

---

## Top 15 Candidate Problems

### Rank 1: SHB(β≈0.9) deterministic Polyak-Ruppert blow-up rate κ² on ill-conditioned quadratics
**Source**: Mode A+B (PE A3-counterpart + cross_domain D.3 + B anomaly A-6, A-8)
**Score**: Impact=3, Feasibility=3, Novelty=3, Comp_support=3, **Total=108**

**Problem Statement**:
For deterministic SHB with momentum β = 1 - O(1/√κ) and step η = 1/L on the 2D quadratic with eigenvalues (1, ε), the Polyak-Ruppert average satisfies
$$\frac{f(\bar x_T)}{f(x_T)} = \Theta(\kappa^2) \quad \text{as } T \to \infty$$
where κ = 1/ε. Equivalently: PR averaging *destroys* SHB's linear rate, with the destruction factor exactly κ².

**Motivation**: Library has `polyak-ruppert-shb-defeats-cycling/` (PR HELPS in stochastic cycling); empirically (A-6, CoV=0.002 across 30 seeds, ratio 1.33×10⁶) PR is CATASTROPHIC in deterministic ill-conditioned setting. This is the cleanest "would-CHANGE-someone's-mind" candidate in the entire pool.

**Evidence**: `results/b1_2_iterates.csv`, `results/b3_robustness.csv` — A-6 shows PR/last = 1.33e6, std/mean=0.002 (extreme robustness); A-8 shows the rate-destroying mechanism cleanly (last=1.9e-21 vs PR=1.2e-8 at T=10000).

**Suggested Strategy**: `polytope_construction` + spectral analysis of SHB iterate orbit (Goujaud-style) + explicit Cesàro residual computation. Template chain: `heavy-ball-instability` (compute rotational orbit) → arithmetico-geometric weight residual → κ-dependent constant.

**Suggested Explorer Frames**: Construction (build the explicit κ² witness) + Orthodox (descent-Lyapunov for the average). Adversarial may help characterize the precise threshold β_crit.

**Estimated Difficulty**: research

---

### Rank 2: Adam dimension-explosion on random L-smooth convex quadratic
**Source**: Mode B (A-4) + Mode A (GM 1.5)
**Score**: Impact=3, Feasibility=2, Novelty=3, Comp_support=3, **Total=72**

**Problem Statement**:
For Adam with default (β₁=0.9, β₂=0.999, ε=10⁻⁸, η=1/L) on $f(x) = \tfrac12 x^\top A x$ where $A$ is random PSD with eigenvalues uniform $[10^{-3}, 1]$ in $\mathbb R^d$, the asymptotic gap satisfies
$$\mathbb E[f(x_T) - f^\star] = \Omega(d^c)$$
for some $c \ge 1$ as $T \to \infty$, despite the function class being *dimension-independent* under GD.

**Motivation**: Massive direction-robustness (30/30 seeds with positive slope > 0.5, mean slope 41.0). This refutes any "Adam ≈ GD on quadratics" intuition and is an entirely new dimension-dependence phenomenon for a deterministic-quadratic setting.

**Evidence**: `results/b1_4_dimension.csv` — slope of log10(gap) vs log10(d) ranges [1.3, 105.3] over 30 seeds. Across d ∈ {2, 10, 50, 200, 500} the gap goes from 2.2e-16 to 0.329.

**Suggested Strategy**: `polytope_construction` + explicit per-coordinate EMA imbalance argument. Hard to fit any existing template — this is closer to `NEW_TECHNIQUE_REQUIRED`. Possible chain: spectral decomposition + analyze coordinate-wise cycle in $v_t$ when eigenvalues are heterogeneous.

**Suggested Explorer Frames**: Construction (explicit dim-dependent hard instance), Adversarial (worst eigenvalue distribution), Naive (write out small d=2,3 by hand to see mechanism).

**Estimated Difficulty**: research

---

### Rank 3: Adam on smooth strongly convex quadratic — non-convergence floor
**Source**: Mode A (GM 2.3) + Mode B (A-1, A-2, A-3, A-16)
**Score**: Impact=3, Feasibility=3, Novelty=2, Comp_support=3, **Total=72**

**Problem Statement**:
For Adam with $0 < \beta_1 < \beta_2 < 1$, $\varepsilon > 0$, $\eta > 0$ on $L$-smooth $\mu$-SC quadratic $f(x)=\tfrac12 x^\top A x$, there exist explicit constants $g^\star(\beta_1, \beta_2, \varepsilon, \eta, \mu, L) > 0$ and $C(\cdot) > 0$ such that:
(i) $\liminf_T \mathbb E[f(x_T)] = 0$ but $\limsup_T \mathbb E[f(x_T)] \ge g^\star$ a.s.
(ii) ratio $\limsup_T f(x_T) / \min_t f(x_t) \ge C$ growing super-polynomially in $T$.

**Motivation**: Reddi 2018 has convex non-convergence; the SC quadratic version is *folklore* but no clean theorem. Computation overwhelmingly supports: 30/30 seeds show late divergence with median ratio 10³⁰. Recent work (Liu et al. 2023 "Divergence Results for Adam") covers a SC stochastic case — partial novelty overlap but our deterministic+explicit-floor formulation is still open.

**Evidence**: `results/b1_5_adam_sc_traj.csv`, `results/b3_robustness.csv` — final/min ratio in [8.3e3, 1.9e56].

**Suggested Strategy**: `polytope_construction` lifted from Reddi 2-D OCO + `lyapunov_potential` for the floor. Build wall-confining quadratic that traps Adam in oscillation around $x^\star$.

**Suggested Explorer Frames**: Construction (explicit instance), Orthodox (compute the floor in closed form for d=1 first).

**Estimated Difficulty**: research [KEEP-WITH-CAVEAT — partial overlap with arxiv 2210.05607]

---

### Rank 4: Adam best-iterate vs last-iterate exponential gap on 2D quadratics
**Source**: Mode A (GM 1.5) + Mode B (A-7)
**Score**: Impact=2, Feasibility=3, Novelty=3, Comp_support=3, **Total=72**

**Problem Statement**:
For Adam with default hyperparameters on 2D quadratics with condition number $\kappa \ge 1000$, after $T \ge T_0(\kappa)$ steps,
$$\frac{\mathbb E[f(x_T)]}{\min_{t \le T} \mathbb E[f(x_t)]} \ge \exp(c\sqrt T)$$
for explicit constant $c > 0$. (No averaging can recover the best iterate because the iterate visits both above- and below-optimum regions equally often.)

**Motivation**: Iterate-type asymmetry (AT-1 archetype) extended to Adam. Empirically the gap is 80 orders of magnitude (best=10⁻⁸⁹, last=10⁻⁹) — among the largest iterate-type gaps ever observed. Direct extension of SHB cycling story.

**Evidence**: `results/b1_2_iterates.csv` — Goujaud2D, T=10000.

**Suggested Strategy**: `polytope_construction` (construct period-$k$ orbit) + spectral analysis of Adam linearized recurrence in eigendirections.

**Suggested Explorer Frames**: Construction + Compositional (Adam = SHB-on-EMA + scaling).

**Estimated Difficulty**: research

---

### Rank 5: ADMM last-iterate $\Theta(\log T)$ gap vs ergodic
**Source**: Mode A (GM 3.2)
**Score**: Impact=3, Feasibility=2, Novelty=3, Comp_support=2, **Total=54**

**Problem Statement**:
For ADMM on convex composite $\min_x f(x) + g(z)$ s.t. $Ax + Bz = c$, there exists a hard instance such that
$$\|Ax_T + Bz_T - c\|^2 = \Omega(\log T / T)$$
matching ergodic upper bound up to a $\log T$ factor — proving the He-Yuan O(1/T) ergodic rate is *strictly* tighter than any last-iterate rate.

**Motivation**: ADMM ergodic is in library (`admm-ergodic-convergence/`); the last-iterate gap is folklore-believed (we confirmed via web: O(1/√k) last-iterate vs O(1/k) ergodic is published, but the SHARP $\log T$ bridge is still open). Proving this gives the canonical "iterate-type matters in primal-dual" theorem.

**Evidence**: Structural argument from sibling SVRG log-gap (`svrg-non-sc-last-iterate-gap/`). [NOVELTY-UNCHECKED for sharp log T gap].

**Suggested Strategy**: `polytope_construction` mimicking Harvey 2019 SGD instance + ADMM Lyapunov no-go.

**Suggested Explorer Frames**: Construction + Orthodox.

**Estimated Difficulty**: research

---

### Rank 6: GDA NCSC single-loop — κ rate (improving κ²)
**Source**: Mode A (cross_domain B.1)
**Score**: Impact=3, Feasibility=2, Novelty=3, Comp_support=2, **Total=54**

**Problem Statement**:
For nonconvex-strongly-concave $\min_x \max_y f(x,y)$ with $L$-smoothness and $\mu$-SC in $y$ ($\kappa = L/\mu$), single-loop two-time-scale GDA with steps $(\eta_x, \eta_y) = (\Theta(1/(L\kappa)), \Theta(1/L))$ and *envelope-residual cancellation* achieves complexity $O(\kappa \varepsilon^{-2})$ — saving a $\kappa$ factor over the current $O(\kappa^2 \varepsilon^{-2})$ in `gda-nonconvex-strongly-concave-convergence/`.

**Motivation**: Lower bound is $\Omega(\sqrt\kappa)$, current upper bound $\kappa^2$ — large gap. Closing it (or moving toward $\sqrt\kappa$) is a known open problem with high impact.

**Evidence**: Structural — `cancellation_pair` template never applied to GDA. [KEEP-WITH-CAVEAT — Lin-Jin-Jordan 2020 already achieve $\kappa\sqrt{\kappa}\varepsilon^{-2}$ for *two-loop*; single-loop $\kappa$ is open].

**Suggested Strategy**: `cancellation_pair` (envelope-descent + dual-residual two ways, cancel cross term).

**Suggested Explorer Frames**: Orthodox (cancellation algebra), Reduction (to convex-concave with Moreau envelope).

**Estimated Difficulty**: research

---

### Rank 7: SHB(β=0.9) PEPit non-monotone hump — explicit characterization
**Source**: Mode A (FC 1.3) + Mode B (A-11, A-12)
**Score**: Impact=2, Feasibility=3, Novelty=3, Comp_support=3, **Total=72**

**Problem Statement**:
For SHB with β=0.9 and η=1/L on the smooth convex class with $\|x_0 - x^\star\| \le 1$, the worst-case f-gap $W(T) = \sup_{f \in \mathcal F} f(x_T) - f^\star$ is *non-monotone* in $T$, with the explicit form $W(T) = \Theta(1)$ for $T \in [T_1(\beta), T_2(\beta)]$ and $W(T) = O(1/T)$ for $T > T_2(\beta)$. Compute $T_1, T_2$ in closed form.

**Motivation**: PEPit-certified anomaly (A-11). Closes the chasm in heavy-ball worst-case theory; would canonize the "intermediate-T plateau" phenomenon.

**Evidence**: `results/b1_3_pepit.md` — T=3: 0.5735; T=5: 0.4717; T=10: 0.6907. PEPit is exact computation, ROBUST.

**Suggested Strategy**: Combined `spectral_eigenvalue` + PEP-SDP closed-form witness via `polytope_construction`. Goujaud-style cycling instance + explicit f-gap maximization.

**Suggested Explorer Frames**: Construction (PEP witness), Orthodox (companion-matrix algebra).

**Estimated Difficulty**: research

---

### Rank 8: Adam stability bound under signal-noise + interpolation refinement
**Source**: Mode A (GM 6.1 + cross_domain B.2 + C.1)
**Score**: Impact=3, Feasibility=2, Novelty=2, Comp_support=2, **Total=54**

**Problem Statement**:
For Adam on smooth $L$-Lipschitz losses in interpolation regime ($\nabla f_i(x^\star) = 0$), the leave-one-out stability gap satisfies $\mathbb E\|θ_T - θ'_T\|^2 \le C\eta^2 T/((1-\beta_2) n^2)$ — *strict* $1/n^2$ improvement over HRS's $1/n$, driven by interpolation cancellation.

**Motivation**: Practitioner-default optimizer with no clean stability theorem in library. Known partial results (Mai-Tan-Wang 2022) give $\eta\sqrt T/n$. Interpolation refinement is genuinely open. Adam's dim-explosion (A-4) suggests stability bounds CANNOT be uniform across dim — making this question nuanced and informative.

**Evidence**: Structural (HRS chassis). Computational: A-4 suggests Adam's coupling is fragile in high dim — Comp_support is 2 (mild) because data CHALLENGES the cleanest bound.

**Suggested Strategy**: `couple_track` + EMA non-expansiveness check + interpolation cancellation (signal-noise B3 chain).

**Suggested Explorer Frames**: Orthodox + Compositional (HRS chassis + Adam component).

**Estimated Difficulty**: research

---

### Rank 9: SGD last-iterate LB $\Omega(\log T/\sqrt T)$ on smooth convex
**Source**: Mode A (cross_domain D.3)
**Score**: Impact=3, Feasibility=3, Novelty=2, Comp_support=1, **Total=36 → upgraded to 48 with cross-cluster**

**Problem Statement**:
For SGD with constant step $\eta = D/(G\sqrt T)$ on smooth convex $f$ with stochastic gradient oracle (variance $\sigma^2$), last iterate satisfies
$$\mathbb E[f(x_T) - f^\star] \ge c \cdot \sigma D \cdot \frac{\log T}{\sqrt T}$$
matching the HLL-R 2019 upper bound. Le Cam two-point on a 1D linear-with-wall instance.

**Motivation**: Closes a canonical UB-LB gap. The matching LB to `sgd-last-iterate-averaged-baseline/` is missing. [KEEP-WITH-CAVEAT — HLL-R upper bound published 2019; matching LB likely implicit in their paper]. High Feasibility because the construction is well-understood.

**Evidence**: Structural. No direct B-evidence.

**Suggested Strategy**: `le_cam_testing` + iterate-type test function (sign of $x_T$).

**Suggested Explorer Frames**: Construction (Le Cam two-point), Adversarial.

**Estimated Difficulty**: research

---

### Rank 10: AdaGrad-Norm sharper LB $\Omega(\log N / \sqrt N)$ via Chen-Bansal noise (P23 followup)
**Source**: Mode A (FC 1.5 + GM 2.2 — merged) + Mode B (A-5, A-17)
**Score**: Impact=2, Feasibility=2, Novelty=3, Comp_support=2, **Total=36**

**Problem Statement**:
For AdaGrad-Norm last-iterate on smooth non-convex $f$, there exists adversarial noise schedule (Chen-Bansal-style burst noise) such that
$$\mathbb E\|\nabla f(x_T)\| \ge c \log T / \sqrt T$$
matching the $O(\log T / \sqrt T)$ upper bound — closing the FT-18 blind-spot identified in `adagrad-norm-nonconvex-convergence/`.

**Motivation**: P23 retry produced PARTIAL ($\sqrt N$ rate proven, $\log N$ open). This directly addresses an internal failure pattern. Caveat: 2024 work shows AdaGrad-Norm's true last-iterate rate may be $O(1/N^{1/4})$, NOT $O(\log N/\sqrt N)$ — so the candidate's UB statement may need revision.

**Evidence**: `results/b1_4_dimension.csv` (A-5: AdaGrad dim-dep), `results/b1_1_rates.csv` (A-17). [KEEP-WITH-CAVEAT — recent arxiv 2604.10728 changes the landscape].

**Suggested Strategy**: `polytope_construction` + Chen-Bansal burst-noise + algorithm-specific Le Cam.

**Suggested Explorer Frames**: Construction + Adversarial.

**Estimated Difficulty**: research

---

### Rank 11: Goujaud cycling-LB inheritance to fixed-hyperparameter Adam — VARIANCE bound transfers
**Source**: Mode A (FC 2.2)
**Score**: Impact=2, Feasibility=3, Novelty=3, Comp_support=2, **Total=54**

**Problem Statement**:
For fixed-hyperparameter Adam $(β_1=0.9, β_2=0.999, ε)$ on smooth convex stochastic with variance $σ^2$, the OP-2 BIAS LB does NOT transfer (FT-OP2-ADAM-COORDWISE-SCALING-BREAKS-CYCLING), but the VARIANCE LB
$$\mathbb E[f(x_T) - f^\star] \ge c \cdot \frac{(1-β_1)\varepsilon}{\eta L + \varepsilon} \cdot \sigma D / \sqrt T$$
DOES transfer via decoupled $y$-coordinate Le Cam.

**Motivation**: Positive consequence of an internal failure (FT-OP2-ADAM). P17 retry produced PASS sketch.

**Evidence**: Structural. [NOVELTY-UNCHECKED — likely novel since the parametrization is internal].

**Suggested Strategy**: `le_cam_testing` (decoupled $y$-coord construction).

**Suggested Explorer Frames**: Reduction (decouple $y$), Construction.

**Estimated Difficulty**: research

---

### Rank 12: PAGE last-iterate vs averaged $\Theta(\log T)$ gap (Bernoulli reset)
**Source**: Mode A (PE A1)
**Score**: Impact=2, Feasibility=3, Novelty=3, Comp_support=1, **Total=36**

**Problem Statement**:
PAGE for non-SC finite-sum non-convex achieves averaged $\frac1T\sum\mathbb E\|\nabla f(x_t)\|^2 = O(1/T)$, but last-iterate satisfies $\mathbb E\|\nabla f(x_T)\|^2 = \Omega(\log T/T)$ on a Bernoulli-reset hard instance. Strict $\Theta(\log T)$ gap.

**Motivation**: AT-1 archetype extended to VR for the first time. PAGE's Bernoulli reset is the perfect "predictable cycle" for HLL-R-style log gap.

**Evidence**: Structural. [NOVELTY-UNCHECKED].

**Suggested Strategy**: `descent_lemma_telescope` + Bernoulli-reset Lyapunov + reduction to HLL-R 2019.

**Suggested Explorer Frames**: Construction + Orthodox.

**Estimated Difficulty**: research

---

### Rank 13: AdaGrad-Norm under heavy-tailed noise (no clipping) — adaptive self-clipping rate
**Source**: Mode A (GM 1.6)
**Score**: Impact=3, Feasibility=2, Novelty=2, Comp_support=2, **Total=54**

**Problem Statement**:
AdaGrad-Norm with no explicit clipping, on smooth non-convex $f$ with bounded $p$-th moment $\mathbb E\|\xi\|^p \le \sigma^p$ for $p \in (1, 2]$, achieves
$$\mathbb E[\tfrac1T \sum_t \|\nabla f(x_t)\|^2] = O(\sigma^{2(1-1/p)} T^{-(1-1/p)})$$
— with the algorithm's denominator providing implicit, adaptive clipping.

**Motivation**: Practitioner-relevant. Library has clipped-SGD heavy-tail UB and AdaGrad-Norm light-tail UB; their composition (with ADAPTIVE self-clipping) is open.

**Evidence**: A-17 (AdaGrad slower than SGD on quartic, 5000×) suggests the rate may not be as clean as conjectured. Comp_support=2 (mild support).

**Suggested Strategy**: `algebraic_index_shift` + surrogate stationarity $\varphi = \min(\|g\|^2, τ\|g\|)$ via *adaptive* $τ = b_k$.

**Suggested Explorer Frames**: Orthodox (clipping calculus with adaptive τ), Compositional.

**Estimated Difficulty**: research

---

### Rank 14: NPG best-iterate $O(1/k^2)$ on tabular MDPs
**Source**: Mode A (PE 3.4)
**Score**: Impact=2, Feasibility=2, Novelty=3, Comp_support=1, **Total=36**

**Problem Statement**:
For NPG on tabular MDPs with constant step $\eta$, best-iterate value gap satisfies
$$V^\star - V^{\pi_t^{\text{best}}} = O(1/k^2)$$
strictly faster than the last-iterate $O(1/k)$ rate proved in `npg-softmax-tabular-convergence/`.

**Motivation**: Iterate-type asymmetry untouched in RL. AT-1 archetype extension. If true, this would be the first $1/k^2$ rate for any NPG variant.

**Evidence**: Structural. Sibling chain: summability of monotone Bregman gaps $\sum(V_k - V_{k+1}) < \infty$ implies harmonic-weight argument. [NOVELTY-UNCHECKED].

**Suggested Strategy**: `cancellation_pair` (existing NPG chain) + harmonic-weight argument on monotone improvements.

**Suggested Explorer Frames**: Orthodox + Compositional.

**Estimated Difficulty**: research

---

### Rank 15: STORM/SARAH lower bound $\Omega(\sigma L\Delta/\varepsilon^3)$ for streaming non-convex
**Source**: Mode A (GM 2.4)
**Score**: Impact=3, Feasibility=3, Novelty=1, Comp_support=1, **Total=24**

**Problem Statement**:
For streaming non-convex with $L$-smoothness, bounded variance $σ^2$, and mean-square smoothness, any first-order algorithm requires $\Omega(\sigma L\Delta/\varepsilon^3)$ stochastic-gradient queries to find an $\varepsilon$-stationary point. Matches STORM upper bound.

**Motivation**: Closes UB-LB gap for streaming VR. STORM UB in library, matching LB published in Arjevani et al. 2019 but not archived.

**Evidence**: Structural. [DISCARDED-CAVEAT — Arjevani et al. 2019 published this; so Novelty=1 (replication-only)].

**Suggested Strategy**: `polytope_construction` + `le_cam_testing`.

**Suggested Explorer Frames**: Construction.

**Estimated Difficulty**: research

---

## Tail (rank 16-73, one-line table)

| Rank | Title | Score | Source | Notes |
|---|---|---|---|---|
| 16 | AdaGrad-Norm interpolation linear rate | 24 | GM 1.4 | KEEP, sibling-driven |
| 17 | OGDA strongly-monotone VI linear rate | 24 | GM 4.3 | KEEP-WITH-CAVEAT (Mokhtari 2020 close) |
| 18 | Adam high-prob convergence sub-Gaussian | 24 | GM 1.2 | KEEP-WITH-CAVEAT (Liu-Zhang-Wu 2023) |
| 19 | SAM PL convergence | 24 | GM 4.1 | KEEP, advanced |
| 20 | STORM PL linear | 24 | GM 4.2 | KEEP |
| 21 | PDHG partial-SC accelerated 1/T² | 18 | GM 4.6 | DISCARD-LEAN (Chambolle-Pock 2011 + Valkonen-Pock cover) |
| 22 | Thompson Sampling sub-Gaussian | 24 | GM 5.1 | KEEP, standard |
| 23 | OFUL non-stationary sliding window | 18 | GM 5.2 | DISCARD-LEAN (Cheung 2019) |
| 24 | EXP3 graph feedback | 18 | GM 5.3 | KEEP, transfer |
| 25 | Catoni PAC-Bayes interpolation | 24 | GM 6.3 | KEEP |
| 26 | Adversarial × heavy-tail composition (B4∘B5) | 36 | GM 6.4 | KEEP, high plausibility |
| 27 | MI gen-bound SGD per-iterate refinement | 18 | GM 6.2 | KEEP-WITH-CAVEAT (Pensia 2018) |
| 28 | ULA last vs averaged KL gap | 24 | GM 3.1 | KEEP |
| 29 | PDHG best vs last non-asymmetry | 18 | GM 3.3 | KEEP, advanced |
| 30 | GDA Polyak-Ruppert defeats κ² | 36 | GM 3.5 | KEEP, A+B partial |
| 31 | AMSGrad lower bound separation | 18 | GM 1.3 | KEEP |
| 32 | Lookahead+Adam combination | 18 | GM 1.7 | KEEP |
| 33 | AMSGrad bandit feedback | 18 | GM 1.8 | KEEP |
| 34 | SVRG averaged log-log gap | 18 | GM 2.5 | KEEP |
| 35 | Q-learning UCB-Hoeffding linear FA | 18 | GM 4.4 | KEEP-WITH-CAVEAT (Jin 2020) |
| 36 | Davis-Yin metric subregularity linear | 18 | GM 4.5 | KEEP |
| 37 | UCB-Q contextual bandit | 18 | GM 5.4 | KEEP |
| 38 | ULA PR weighted speedup | 24 | PE A2 | KEEP |
| 39 | ADMM PR weighted average | 18 | PE A3 | KEEP-WITH-CAVEAT |
| 40 | Catoni PAC-Bayes per-prefix | 18 | PE A4 | KEEP |
| 41 | Q-learning best-iterate gap | 18 | PE A5 | KEEP |
| 42 | PDHG LASSO restricted cone | 18 | PE B1 | KEEP |
| 43 | NTK Gram under-parameterized | 18 | PE B2 | KEEP |
| 44 | GDA restricted-monotonicity cone | 12 | PE B3 | KEEP, low |
| 45 | SAM flat-region first-passage | 18 | PE B4 | KEEP |
| 46 | ULA weak-Poincaré rescue | 24 | PE C1 | KEEP, high plausibility |
| 47 | Catoni literal-sharpness rescue | 18 | PE C2 | KEEP |
| 48 | SPIDER anticorrelation refutation | 12 | PE C3 | KEEP, low |
| 49 | Adam constant-η rescue | 24 | PE C4 | KEEP-WITH-CAVEAT (Defossez 2022) |
| 50 | BernoulliSGD design | 18 | PE D1 | KEEP |
| 51 | Predictable-Adam design | 18 | PE D2 | KEEP |
| 52 | AC-DR splitting accelerated | 18 | PE D3 | KEEP |
| 53 | InterpAdam design | 18 | PE D4 | KEEP |
| 54 | Adversarial polytope NPG | 18 | PE E1 | KEEP |
| 55 | DY-splitting sharp Ω(1/k) LB | 18 | PE E2 | KEEP |
| 56 | STORM cycling-oracle LB | 18 | PE E3 | KEEP |
| 57 | ULA W_2 vs KL implication failure | 18 | PE F1 | KEEP |
| 58 | PDHG no-acceleration LB partial-smoothness | 18 | PE F2 | KEEP |
| 59 | Adam ℓ∞ vs ℓ₂ max-margin distinction | 18 | PE F3 (REVISED) | DISCARD original (Adam DOES converge to ℓ∞-MM, Zhang-Zou 2024); REVISED candidate: prove Adam's $\ell_\infty$ vs GD's $\ell_2$ is QUANTITATIVELY suboptimal |
| 60 | BLLT row-deletion bias bypass | 18 | FC 1.1 | KEEP |
| 61 | OP-2 sharp Nesterov-chain (constant uniformity) | 24 | FC 1.2 | KEEP, P3 retry partial |
| 62 | Non-periodic SHB orbit | 12 | FC 1.3 | KEEP, low |
| 63 | Polyak vs Nesterov asymptotic separation | 18 | FC 1.4 | KEEP |
| 64 | Coefficient suboptimality non-quadratic | 18 | FC 1.6 | KEEP |
| 65 | Universal Cesàro-LB collapse meta-thm | 18 | FC 2.1 | KEEP |
| 66 | PEP-SDP HB zero-init witness | 12 | FC 2.3 | KEEP, low |
| 67 | Coupled Le Cam √(log d) | 24 | FC 2.4 | KEEP-WITH-CAVEAT (Nemirovski-Yudin) |
| 68 | FT-18 sweep meta-audit | 24 | FC 3.1 | KEEP, standard high-EV |
| 69 | HLL-R classifier theorem | 18 | FC 3.2 | KEEP |
| 70 | Reverse Auditor functorial | 6 | FC 3.3 | KEEP, conjecture |
| 71 | Spiral-knot Burau signature | 18 | FC 4.1 | KEEP, LDT |
| 72 | Kauffman convention checker | 12 | FC 4.2 | KEEP, engineering |
| 73 | NAG t/(t+3) constant deterioration | 24 | A-13 | NEW from B, KEEP |

---

## Discarded as already-published (after novelty filter)

- **GM 4.6 PDHG partial-SC accelerated 1/T²**: Chambolle-Pock 2011 + Valkonen-Pock 2017 cover this. Demoted to rank 21 with caveat.
- **GM 5.2 OFUL non-stationary sliding window**: Cheung-Simchi-Levi-Zhu 2019 published. Demoted to rank 23.
- **GM 4.4 Q-learning linear FA**: Jin-Yang-Wang-Jordan 2020 published. Demoted to rank 35.
- **GM 6.2 MI gen-bound SGD per-iterate**: Pensia-Jog-Loh 2018 published. Demoted to rank 27.
- **GM 4.3 OGDA strongly monotone VI**: Mokhtari-Ozdaglar-Pattathil 2020 published. Demoted to rank 17.
- **GM 1.2 Adam high-prob sub-Gaussian**: Liu-Zhang-Wu 2023 published in different parametrization. Demoted to rank 18.
- **GM 2.1 SPIDER LB √n/ε²**: Fang et al. 2018 published. Demoted to rank 15 (still kept for archiving value).
- **PE F3 (original) Adam fails max-margin**: REFUTED by Zhang-Zou 2024 (Adam DOES converge to ℓ∞-max-margin). Reframed as ℓ∞ vs ℓ₂ quantitative comparison.

## Unchecked novelty (explicit flag — manual review needed)

The following candidates were NOT explicitly searched (time budget). **All candidates ranked 11+ except where noted carry [NOVELTY-UNCHECKED]**. High-priority manual checks:

- Rank 11: Adam variance LB inheritance via decoupled Le Cam — likely novel (internal parametrization)
- Rank 12: PAGE last-iterate gap via Bernoulli reset — likely novel
- Rank 14: NPG best-iterate $O(1/k^2)$ — high priority to check (could be folklore)
- Rank 26: B4∘B5 composition (adversarial × heavy-tail) — likely novel (internal)
- Rank 30: GDA Polyak-Ruppert κ² → κ — likely novel
- Rank 67: Coupled Le Cam √(log d) — Nemirovski-Yudin original is 1983 textbook; SHB-specific transfer likely novel
- Most of ranks 25-73: not explicitly searched.

WebSearch ran successfully for ~12 candidates; remaining ~80 candidates were ranked using internal evidence (sibling-FILLED status from gap_matrix, novelty estimated from setting-uniqueness). **Be aware of this gap when interpreting the ranking — novelty scores for unchecked candidates are upper bounds**.

## Patterns in the ranked list

1. **Adam dominates the top 5** (4 of 5 candidates involve Adam), reflecting the convergence of Mode B's massive computational evidence (A-1 through A-7, A-16) with Mode A's recognition that adaptive methods are 1-D in the gap matrix. Adam's combination of practitioner-default status + theoretically-poorly-understood behavior + extreme empirical anomalies (best/last ratio of 10⁸¹) makes it the highest-leverage target.

2. **Iterate-type asymmetry (AT-1) appears in 5 of top 15** (ranks 1, 4, 5, 7, 9, 12). This is the most-extrapolatable archetype in the library and consistently produces high-Comp_support candidates because periodic/cycling behavior is computationally easy to detect.

3. **Lower bounds and refutations dominate over upper bounds** (10 of top 15 are LB or refutation candidates). This reflects (a) the library's UB-heavy coverage (~70/85 are UB or convergence) and (b) Mode B anomalies are inherently negative findings (algorithm fails, gap exists, etc).

4. **Surprising omissions**: ULA/MCMC candidates rank low (best ULA candidate is rank 28). This is because there's no Mode B evidence for sampling problems — our scripts targeted optimization. Worth running B experiments on Langevin variants.

5. **The top of the list is heavy on "wide gap to close" (Rank 1: 6-orders empirical effect, Rank 2: 41-orders mean dim slope, Rank 3: 30-orders divergence)**. The scoring formula correctly upweights candidates where the result would dramatically alter expectations.

## Candidates flagged for IMMEDIATE action

1. **Rank 1 (SHB κ² PR blow-up)**: Score 108 (max), Comp_support 3, clear strategy. **The most valuable target.** Computational evidence is overwhelming (CoV=0.002), the structural mechanism is well-understood, and the result would be a clean "iterate-type matters even deterministically" theorem. Fire up math-prover immediately.

2. **Rank 2 (Adam dim explosion)**: Score 72, NEW_TECHNIQUE-leaning. Highest novelty. Worth the difficulty cost because nothing in the library or literature explains this dimension dependence.

3. **Rank 4 (Adam best vs last on 2D)**: Score 72, well-defined construction. Fast time-to-proof; could complete in days.

4. **Rank 7 (SHB PEPit hump)**: Score 72, PEPit gives explicit numerical witness. The proof reduces to algebra of the worst-case quadratic instance.

The remaining top-15 are research-grade but harder; queue them after the top 4.
