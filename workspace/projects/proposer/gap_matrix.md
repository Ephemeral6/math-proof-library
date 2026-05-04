# Gap Matrix — Step A1

> Implicit (algorithm × result_type × function_class) matrix.
> Rows: 14 algorithms (SGD, SHB, Nesterov, NPG, SAM, Lookahead, Adam, AMSGrad, AdaGrad-Norm, SVRG, SPIDER, STORM, PAGE, OGDA).
> Cols: 14 result types (last-iterate UB, last-iterate LB, averaged UB, averaged LB, best-iterate UB, best-iterate LB, high-prob UB, high-prob LB, sample complexity, oracle complexity, generalization, stability, mixing/regret, instability/divergence).
> 3rd axis: 6 function classes (smooth-convex, smooth-SC, non-convex, PL, interpolation, heavy-tailed-noise).
>
> Total cell count: 14 × 14 × 6 = 1176. Below: 32 well-justified GAPs grouped by theme.
> Each GAP gives a sibling-FILLED reference proof so the gap is "near, not random."

---

## Theme 1 — Adaptive methods × iterate-type × function-class (8 gaps)

The library has **3 adaptive proofs** (Adam, AMSGrad, AdaGrad-Norm) all covering **non-convex / averaged-iterate UB** only. SHB has 4-tier iterate-type analysis (last/averaged/best/PR-weighted), VR has 4-tier algorithm-type analysis (SVRG/SPIDER/STORM/PAGE), but adaptive methods are 1-D in the matrix.

### Candidate: AdaGrad-Norm last-iterate convergence (smooth convex)
- **Problem statement**: For smooth convex $f$ with $\sigma$-bounded variance, AdaGrad-Norm with $b_0>0$ achieves $\mathbb E[f(x_T)-f^\star] = O(\log T/\sqrt T)$ — without averaging.
- **Setting**: smooth convex, stochastic i.i.d., last iterate, AdaGrad-Norm with scalar denominator $b_k$.
- **Why it's a gap**: Sibling FILLED — `adagrad-norm-nonconvex-convergence/` proves $O(\log T/\sqrt T)$ via averaged $\frac1T\sum\|\nabla f\|^2$; the *last-iterate* form is the source of the FT-18 blind-test failure. Sibling A1 (SHB last-iterate vs averaged) shows iterate-type can flip the rate.
- **Suggested proof strategy**: `algebraic_index_shift` (existing AdaGrad chain) + Harvey-Liaw-Lu-Randhawa 2019 last-iterate-vs-average inequality + suffix-averaging *only when valid*.
- **Difficulty estimate**: research
- **Plausibility**: HIGH. The averaged proof is in the library; HLL-R is in the library.

### Candidate: Adam high-probability convergence under sub-Gaussian noise (non-convex)
- **Problem statement**: Adam with $\beta_1^2 \le \beta_2$ and sub-Gaussian noise satisfies $\Pr[\frac1T\sum\|\nabla f(x_t)\|^2 > C\log(1/\delta)/\sqrt T] \le \delta$.
- **Setting**: non-convex, stochastic with sub-Gaussian noise, high-probability bound.
- **Why it's a gap**: Adam in-expectation rate is `adam-nonconvex-convergence/` — but the corresponding high-probability statement is missing. Sibling FILLED: `clipped-sgd-heavy-tail-convergence/` produces high-probability bounds via Freedman.
- **Suggested proof strategy**: `exp_supermartingale` + Freedman + Adam-specific Jensen-on-EMA-weights.
- **Difficulty estimate**: research
- **Plausibility**: HIGH (Liu-Zhang-Wu 2023 already do this in a different parameterization).

### Candidate: AMSGrad lower bound: separation from Adam in non-convex regime
- **Problem statement**: There exists a non-convex stochastic instance on which Adam diverges (Reddi-style), but AMSGrad converges with rate $O(1/\sqrt T)$, and on a *different* non-convex instance AMSGrad's monotone $\hat v$ provably *slows* convergence by a factor of $\Omega(\log T)$ vs Adam in expectation.
- **Setting**: non-convex stochastic with engineered noise.
- **Why it's a gap**: AMSGrad's monotone surrogate is reported as universally helpful, but no separation instance exists in either direction.
- **Suggested proof strategy**: `polytope_construction` + `algorithm_existential_refutation` (template from SHB lower-bound family).
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (the slow-down direction is non-obvious; existence is very plausible).

### Candidate: AdaGrad-Norm interpolation linear convergence
- **Problem statement**: Under $L$-smoothness + $\mu$-PL + interpolation ($f^\star_i = f^\star$ a.s.), AdaGrad-Norm with $b_0=O(1)$ achieves $\mathbb E[f(x_T)-f^\star] \le (1-c\mu/L)^T (f(x_0)-f^\star)$.
- **Setting**: PL + interpolation, stochastic, last iterate, AdaGrad-Norm.
- **Why it's a gap**: Sibling FILLED — momentum-SGD interpolation linear convergence (3 variants: spectral, contraction, split co-coercivity) is fully covered. AdaGrad-Norm in the same regime is open in the library.
- **Suggested proof strategy**: `algebraic_index_shift` (telescoping `1/b_k^2`) + interpolation cancellation à la `momentum-sgd-interpolation-linear-convergence`.
- **Difficulty estimate**: advanced
- **Plausibility**: HIGH. Three sibling proofs already do the analogous thing for SHB/momentum-SGD.

### Candidate: Adam best-iterate vs averaged-iterate gap
- **Problem statement**: For Adam on smooth non-convex $f$, the best-iterate $\min_t \mathbb E\|\nabla f(x_t)\|^2$ converges at rate $\Theta(1/\sqrt T)$ while averaged $\frac1T\sum$ matches; show no gap (against SHB-type asymmetry).
- **Setting**: smooth non-convex, stochastic, comparing iterate types under Adam.
- **Why it's a gap**: SHB shows $\Theta(\log m)$ gap (SVRG) and even disproof scenarios; for Adam this is open. Sibling A4 (`shb-no-acceleration-best-iterate`) shows iterate-type matters.
- **Suggested proof strategy**: `descent_lemma_telescope` with EMA-aware Lyapunov.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (could go either way; both directions are publishable).

### Candidate: AdaGrad-Norm under heavy-tailed noise (p ∈ (1, 2])
- **Problem statement**: AdaGrad-Norm with no clipping and bounded $p$-th moment $\mathbb E\|\xi\|^p \le \sigma^p$ achieves $\mathbb E[\frac1T\sum\|\nabla f\|^2] = O(\sigma^{2(1-1/p)} T^{-(1-1/p)})$.
- **Setting**: heavy-tailed noise with $p$-th moment only, $p\in(1,2]$, non-convex.
- **Why it's a gap**: Sibling FILLED — `clipped-sgd-heavy-tail-convergence/` (clipped SGD, $p\in(1,2)$) and `adagrad-norm-nonconvex-convergence/` exist in isolation. Their composition is open: does AdaGrad-Norm self-clip enough to handle heavy tails without explicit clipping?
- **Suggested proof strategy**: `algebraic_index_shift` + surrogate stationarity $\varphi=\min(\|g\|^2, \tau\|g\|)$ via *adaptive* $\tau = b_k$.
- **Difficulty estimate**: research
- **Plausibility**: HIGH. Practitioner-relevant; the algorithm's denominator IS an adaptive clip-like quantity.

### Candidate: Lookahead + Adam combination convergence
- **Problem statement**: Lookahead-Adam (outer Lookahead wrapping Adam as inner optimizer) achieves $O(1/\sqrt T)$ on non-convex with strictly smaller constant than Adam alone iff $\alpha_k > \alpha^\star$.
- **Setting**: non-convex stochastic, Lookahead outer, Adam inner.
- **Why it's a gap**: `lookahead-optimizer-convergence/` is SHB-only; Lookahead-Adam is the practitioner default but unanalyzed.
- **Suggested proof strategy**: `spectral_eigenvalue` (Lookahead chassis) + Adam EMA inside.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (algebra is plausible; clean closed-form for $\alpha^\star$ less clear).

### Candidate: AMSGrad under bandit feedback (bandit AMSGrad regret bound)
- **Problem statement**: AMSGrad applied as adversarial bandit algorithm (with importance-weighted gradient estimates) achieves regret $\tilde O(\sqrt{T \log K})$.
- **Setting**: adversarial bandit, AMSGrad.
- **Why it's a gap**: EXP3 covers OCO-bandit; AMSGrad covers stochastic non-convex; their hybrid is open. Adaptive methods are entirely missing from the bandit literature in this library.
- **Suggested proof strategy**: `exp_supermartingale` (EXP3 chassis) + monotone-EMA correction.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

---

## Theme 2 — Lower bounds for adaptive / variance-reduced methods (5 gaps)

The library has **4 lower-bound proofs total** (all SHB family). Adaptive methods + VR methods are entirely missing on the lower-bound side. Sibling FILLED: SPIDER UB and the matching $\Omega(\sqrt n/\varepsilon^2)$ LB in Fang et al. 2018 — but the LB proof is NOT in the library.

### Candidate: SPIDER lower bound $\Omega(\sqrt n/\varepsilon^2)$ matching the upper bound
- **Problem statement**: For finite-sum non-convex with $n$ components and $L$-smoothness, any first-order algorithm with at most $K$ stochastic-gradient queries from a single batch oracle requires $K = \Omega(\sqrt n/\varepsilon^2)$ queries to find an $\varepsilon$-stationary point.
- **Setting**: finite-sum non-convex, oracle complexity.
- **Why it's a gap**: SPIDER UB filled (`spider-nonconvex-gradient-complexity/`); LB is in Fang et al. but not archived.
- **Suggested proof strategy**: `polytope_construction` (chain-quadratic à la Carmon-Duchi) + `le_cam_testing`.
- **Difficulty estimate**: research
- **Plausibility**: HIGH (Fang et al. 2018 published this).

### Candidate: AdaGrad-Norm lower bound $\Omega(\log N/\sqrt N)$ for last iterate
- **Problem statement**: There exists smooth non-convex $f$ and noise such that AdaGrad-Norm last-iterate satisfies $\mathbb E\|\nabla f(x_T)\| \ge c\log T/\sqrt T$.
- **Setting**: non-convex, stochastic, last iterate, AdaGrad-Norm.
- **Why it's a gap**: Listed as PARTIAL in retry_results (P23). Genuinely open in current framework. Sibling FILLED: `adagrad-norm-nonconvex-convergence/` UB matches.
- **Suggested proof strategy**: Chen-Bansal-style adversarial noise schedule + `polytope_construction`.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (P23 retry produced PARTIAL: $\sqrt N$ rate proven, $\log N$ factor open).

### Candidate: Adam non-convergence on smooth strongly convex (variance-only)
- **Problem statement**: There exists $\mu$-SC, $L$-smooth $f$ and noise model such that Adam with default $\beta_1=0.9, \beta_2=0.999$ has $\liminf_T \mathbb E[f(x_T)-f^\star] \ge c > 0$ — strict non-convergence in expectation.
- **Setting**: $\mu$-SC, fixed-hyperparameter Adam (no scheduling).
- **Why it's a gap**: Reddi 2018 has the convex non-convergence example for Adam; non-convergence on SMOOTH SC is folklore but no clean theorem in the library. Adam's UB only covers non-convex.
- **Suggested proof strategy**: `polytope_construction` adapted from Reddi's 2-D OCO instance, lifted to SC via wall-confining quadratic.
- **Difficulty estimate**: research
- **Plausibility**: HIGH. This is widely believed; just no clean formal statement in library.

### Candidate: STORM/SARAH lower bound $\Omega(1/\varepsilon^3)$ for streaming non-convex
- **Problem statement**: For streaming (no finite-sum structure) non-convex problems with $L$-smoothness and bounded variance, any first-order algorithm requires $\Omega(\sigma^2 L\Delta/\varepsilon^4)$ queries; under additional mean-square smoothness ($\mathbb E\|\nabla f_i(x)-\nabla f_i(y)\|^2 \le L^2\|x-y\|^2$), $\Omega(\sigma L\Delta/\varepsilon^3)$ is tight.
- **Setting**: streaming non-convex with mean-square smooth oracle.
- **Why it's a gap**: STORM UB exists (`storm-nonconvex-convergence/`); the matching $\varepsilon^{-3}$ lower bound (Arjevani et al. 2019) is not in library.
- **Suggested proof strategy**: `polytope_construction` (worst-case chain) + `le_cam_testing` with mean-square noise.
- **Difficulty estimate**: research
- **Plausibility**: HIGH.

### Candidate: SVRG averaged-iterate lower bound (matching $\Theta(\log m)$ gap)
- **Problem statement**: For SVRG on non-strongly-convex finite-sum, last-iterate has gap $\Theta(\log m)$ vs snapshot (PROVED). Show: averaged-iterate has gap $\Theta(\log\log m)$ vs snapshot — strictly smaller but nonzero.
- **Setting**: finite-sum non-SC, SVRG, averaged iterate.
- **Why it's a gap**: `svrg-non-sc-last-iterate-gap/` proves the last-iterate side. Averaged side asymptotically smaller but unstudied.
- **Suggested proof strategy**: `polytope_construction` (Huber + decoupled $c_i$, modified) + Jensen + careful weight allocation.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (could be zero gap; would CHANGE someone's mind either way).

---

## Theme 3 — Iterate-type asymmetry × non-OP-2 algorithms (5 gaps)

Discovery archetype "Iteration-type asymmetry" has 4 instances (last-vs-averaged), all in SHB family. Sibling extension to other algorithms.

### Candidate: ULA last-iterate vs averaged-iterate KL gap
- **Problem statement**: Under LSI, ULA averaged iterate has $\text{KL}(\bar\rho_T\|\pi) = O(1/T)$ while last iterate has $\text{KL}(\rho_T\|\pi) = O(\log T/T)$, a strict $\log T$ gap.
- **Setting**: LSI target distribution, ULA sampler, last vs averaged.
- **Why it's a gap**: `ula-kl-convergence-lsi/` is ergodic (averaged-style). Last-iterate KL is open in library.
- **Suggested proof strategy**: `couple_track` + Girsanov + HLL-R last-iterate-of-stochastic-process inequality.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (the existence of a gap is not certain; both directions publishable).

### Candidate: ADMM last-iterate vs ergodic-iterate gap
- **Problem statement**: For ADMM with feasible test point, the last iterate satisfies $\|Ax_T+Bz_T-c\|^2 = \Omega(\log T/T)$ on a hard instance, while ergodic iterate matches the $O(1/T)$ He-Yuan rate — a sharp $\Theta(\log T)$ gap.
- **Setting**: convex composite, ADMM.
- **Why it's a gap**: `admm-ergodic-convergence/` is ergodic. Sibling C1 (SVRG log-gap) shows the pattern. ADMM last-iterate is folklore-believed but unresolved.
- **Suggested proof strategy**: `polytope_construction` (mimicking Harvey 2019 SGD instance) + Lyapunov no-go.
- **Difficulty estimate**: research
- **Plausibility**: HIGH.

### Candidate: PDHG best-iterate vs last-iterate non-asymmetry
- **Problem statement**: For PDHG on convex-concave saddle with $\tau\sigma L^2 < 1$, best-iterate $\min_t [F(x_t,y^\star)-F(x^\star,y_t)]$ matches last-iterate rate $O(1/T)$, with NO gap (in contrast to SHB/SVRG).
- **Setting**: convex-concave saddle, PDHG.
- **Why it's a gap**: `chambolle-pock-pdhg-ergodic-convergence/` is ergodic. Sibling claim that "iterate-type matters" has counterexamples — PDHG's averaged structure may be self-eliminating.
- **Suggested proof strategy**: `cancellation_pair` + descent on PDHG Lyapunov + monotonicity.
- **Difficulty estimate**: advanced
- **Plausibility**: MEDIUM (could go either way; non-asymmetry is a notable result).

### Candidate: NPG best-iterate convergence rate $O(1/k^2)$ acceleration
- **Problem statement**: For NPG on tabular MDPs, best-iterate value-gap satisfies $V^\star - V^{\pi_t^{\text{best}}} = O(1/k^2)$, strictly faster than the last-iterate $O(1/k)$ rate.
- **Setting**: tabular MDP, softmax NPG.
- **Why it's a gap**: `npg-softmax-tabular-convergence/` is $O(1/k)$. Best-iterate is the natural candidate for $O(1/k^2)$ via summability of monotone Bregman gaps.
- **Suggested proof strategy**: `cancellation_pair` (existing chain) + summability $\sum (V_k - V_{k+1}) < \infty$ + harmonic-weight argument.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: GDA Polyak-Ruppert defeats nonconvex-strongly-concave $\kappa^2$ rate
- **Problem statement**: For nonconvex-strongly-concave saddle with $\kappa = L/\mu$, single-loop GDA has rate $O(\kappa^2/\varepsilon^2)$ on the envelope (PROVED, `gda-nonconvex-strongly-concave-convergence/`). Polyak-Ruppert weighted-average achieves $O(\kappa/\varepsilon^2)$ — saving a factor of $\kappa$.
- **Setting**: NC-SC saddle, single-loop GDA, PR-weighted average iterate.
- **Why it's a gap**: Sibling A5 (`polyak-ruppert-shb-defeats-cycling/`) shows PR can drop a polynomial factor. The same trick should apply to GDA's two-time-scale envelope.
- **Suggested proof strategy**: `lyapunov_potential` (envelope) + complexification on residual oscillations + arithmetico-geometric weighted sum (template from A5).
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

---

## Theme 4 — Function-class extension (smooth-convex → PL → smooth-SC) for sibling-FILLED algorithms (6 gaps)

### Candidate: SAM convergence under PL condition
- **Problem statement**: For PL functions with $\mu$-PL constant and $L$-smoothness, SAM with $\rho = \rho_0/\sqrt T$ achieves $f(x_T)-f^\star = O((1-\mu/L)^T) + O(L^2\rho_0^2)$.
- **Setting**: PL non-convex, deterministic SAM.
- **Why it's a gap**: `sam-convergence-flat-minima/` is non-convex. PL is a sweet spot between SC and non-convex.
- **Suggested proof strategy**: `descent_lemma_telescope` (existing chain) + PL-driven contraction.
- **Difficulty estimate**: advanced
- **Plausibility**: HIGH.

### Candidate: STORM under PL condition: linear convergence with bias term
- **Problem statement**: For $\mu$-PL with mean-square smoothness, STORM achieves $\mathbb E[f(x_T)-f^\star] = O(e^{-\mu T/L} + \sigma^2/(\mu T))$.
- **Setting**: PL streaming, STORM.
- **Why it's a gap**: `storm-nonconvex-convergence/` is non-convex (sublinear). PL→linear is a standard bridge.
- **Suggested proof strategy**: `descent_lemma_telescope` (STORM chain) + PL substitution + EMA-aware Lyapunov.
- **Difficulty estimate**: advanced
- **Plausibility**: HIGH.

### Candidate: OGDA bilinear → strongly-monotone variational inequality
- **Problem statement**: For strongly-monotone variational inequalities with monotonicity modulus $\mu$ and Lipschitz $L$, OGDA last-iterate achieves linear rate $\|z_T-z^\star\|^2 \le (1-c\mu/L)^T \|z_0-z^\star\|^2$.
- **Setting**: strongly-monotone VI, OGDA.
- **Why it's a gap**: `ogda-bilinear-last-iterate/` is bilinear. Strongly-monotone is the canonical SC analog.
- **Suggested proof strategy**: `cancellation_pair` (existing skew-symmetry identity) + monotonicity = polarization-positive cross term.
- **Difficulty estimate**: advanced
- **Plausibility**: HIGH (Mokhtari-Ozdaglar-Pattathil 2020 cover this; transfer is standard).

### Candidate: Q-learning UCB-Hoeffding under linear function approximation
- **Problem statement**: UCB-style Q-learning with $d$-dim linear features and $\sqrt{d}$-scaled bonus achieves regret $\tilde O(\sqrt{d^3 H^4 T})$ in linear MDPs.
- **Setting**: linear MDPs, online RL.
- **Why it's a gap**: `q-learning-ucb-hoeffding-regret/` is tabular. Linear FA is the standard scaling.
- **Suggested proof strategy**: `couple_track` + LinUCB self-normalized concentration + bonus calibration.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (Jin-Yang-Wang-Jordan 2020 do this in published form).

### Candidate: Davis-Yin three-op splitting under metric subregularity
- **Problem statement**: For maximal monotone $A,B,C$ with $C$ co-coercive and metric-subregular sum, Davis-Yin achieves linear rate $\|z_{k+1}-z^\star\|^2 \le (1-c)^k\|z_0-z^\star\|^2$.
- **Setting**: monotone inclusion + subregularity, DY-splitting.
- **Why it's a gap**: `davis-yin-three-operator-splitting-ergodic-variant/` is sublinear. Subregularity is the standard linear-rate trigger.
- **Suggested proof strategy**: `fixed_point_contraction` (existing variant) + Lyapunov-style metric subregularity $\langle Tz-z^\star, z-z^\star\rangle \ge c\|z-z^\star\|^2$.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: Chambolle-Pock PDHG under partial strong convexity
- **Problem statement**: For convex-concave $F(x,y) = G(x) + \langle Kx, y\rangle - F^\star(y)$ with $G$ $\mu$-SC but $F^\star$ only convex, PDHG with adapted step sizes achieves $O(1/T^2)$ on the primal — accelerated despite asymmetric SC.
- **Setting**: partial strong convexity, PDHG.
- **Why it's a gap**: `chambolle-pock-pdhg-ergodic-convergence/` is $O(1/N)$. Chambolle-Pock 2011 itself notes the $O(1/T^2)$ accelerated regime under partial SC.
- **Suggested proof strategy**: `cancellation_pair` (existing chain) + adaptive step sizes $\tau_k\sigma_k = \tau_0\sigma_0$ with $\tau_k = \tau_0/k$.
- **Difficulty estimate**: advanced
- **Plausibility**: HIGH (in the original Chambolle-Pock paper, just not archived).

---

## Theme 5 — Bandits / online learning extensions (4 gaps)

### Candidate: Thompson Sampling regret under sub-Gaussian rewards (not Bernoulli)
- **Problem statement**: For sub-Gaussian rewards with proxy variance $\sigma^2$, Gaussian-prior Thompson Sampling achieves regret $O(\sigma\sqrt{KT\log T})$.
- **Setting**: sub-Gaussian bandit, Thompson Sampling with Gaussian prior.
- **Why it's a gap**: `thompson-sampling-bernoulli-regret/` is Bernoulli. Sub-Gaussian is the standard generalization.
- **Suggested proof strategy**: `exp_supermartingale` (existing chain) + Gaussian conjugate posterior.
- **Difficulty estimate**: advanced
- **Plausibility**: HIGH.

### Candidate: OFUL under non-stationary rewards (sliding-window or restart)
- **Problem statement**: For linear bandits with unknown drift $\|\theta_t-\theta_{t-1}\| \le b$, sliding-window OFUL with window $W$ achieves dynamic regret $\tilde O(d\sqrt{TW} + bT/W)$, optimized at $W \propto T^{2/3}b^{-2/3}$.
- **Setting**: non-stationary linear bandit, OFUL with restarts.
- **Why it's a gap**: `oful-linear-bandit-regret/` is stationary. Non-stationary OFUL is standard but missing.
- **Suggested proof strategy**: `exp_supermartingale` (existing) + window-based confidence resets.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (Cheung-Simchi-Levi-Zhu 2019 published; would establish the template here).

### Candidate: EXP3 under partial / graph feedback
- **Problem statement**: For adversarial bandits with feedback-graph $G$ (independence number $\alpha$), EXP3 modified with graph-aware exploration achieves regret $O(\sqrt{\alpha T \log K})$.
- **Setting**: adversarial bandit with graph feedback.
- **Why it's a gap**: `exp3-adversarial-bandit-regret/` is full bandit feedback. Graph feedback bridges to expert.
- **Suggested proof strategy**: `exp_supermartingale` (existing) + graph-aware importance weighting.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: UCB-Hoeffding Q-learning under contextual bandits (CB-Q)
- **Problem statement**: Contextual UCB-Q with linear value function achieves regret $\tilde O(\sqrt{d^2 T})$ matching LinUCB up to log factors, but using an off-policy Q-update.
- **Setting**: contextual bandit, off-policy Q-learning.
- **Why it's a gap**: `q-learning-ucb-hoeffding-regret/` is online RL. Bandit specialization missing.
- **Suggested proof strategy**: `couple_track` + LinUCB self-normalized concentration.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

---

## Theme 6 — Generalization × algorithm class crosses (4 gaps)

### Candidate: Adam stability bound + generalization
- **Problem statement**: Adam with $\beta_1, \beta_2 \in (0,1)$ on $L$-smooth losses has uniform stability $\varepsilon_\text{stab} \le 2L^2\eta T(\beta_2-\beta_1^2)^{-1/2}/n$ and hence generalization gap $\le 2\varepsilon_\text{stab}$.
- **Setting**: smooth empirical risk, Adam, leave-one-out stability.
- **Why it's a gap**: `sgd-uniform-stability-generalization/` covers SGD; `sgd-signal-noise-generalization-decomposition/` covers SGD signal-noise. Adam is the practitioner default with no stability bound in library.
- **Suggested proof strategy**: `couple_track` (HRS chassis) + Adam-specific EMA non-expansiveness check (probably FAILS at first attempt — Adam is famously *not* non-expansive — leading to a refined claim).
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (Adam stability is known to be weaker than SGD; the published bound by Mai-Tan-Wang 2022 has form $\eta\sqrt T/n$ not $\eta T/n$).

### Candidate: MI generalization bound for SGD with sub-Gaussian noise (per-iterate refinement)
- **Problem statement**: For SGD with sub-Gaussian noise (proxy $\sigma^2$), the per-iterate MI bound gives gen-gap $\le \sqrt{2\sigma^2 \cdot I(W_t; S)/n}$ where $I(W_t; S)$ telescopes and the resulting per-step contribution is $O(\eta_t^2 L^2 d/n)$.
- **Setting**: SGD, sub-Gaussian noise.
- **Why it's a gap**: `xu-raginsky-mi-generalization-bound/` is general algorithm. SGD specialization with telescoped MI is open.
- **Suggested proof strategy**: `expand_then_match` + per-step MI decomposition + Donsker-Varadhan on sub-Gaussian.
- **Difficulty estimate**: research
- **Plausibility**: HIGH (Pensia-Jog-Loh 2018).

### Candidate: PAC-Bayes for SGD under interpolation
- **Problem statement**: For interpolating SGD on $L$-smooth empirical risk, the Catoni PAC-Bayes bound gives $\Pr[\text{gen-gap} \le c\sqrt{\log(1/\delta)/n}] \ge 1-\delta$ — *no* dependence on iteration count $T$.
- **Setting**: interpolation regime, SGD, Catoni PAC-Bayes.
- **Why it's a gap**: `catoni-pac-bayes-bound/` is generic. Interpolation specialization removing $T$-dependence is open.
- **Suggested proof strategy**: `exp_supermartingale` (Catoni chain) + interpolation-induced posterior concentration.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: Adversarial-trajectory tradeoff with heavy-tailed gradients
- **Problem statement**: Combining `adversarial-trajectory-tradeoff` (Penalty $\propto rH\sqrt{T\eta}$) with `heavy-tailed-trajectory-decomposition` ($p$-th moment): $T^\star_{\text{adv}}/T^\star_{\text{clean}} = (1+crH/G)^{-p/(p+1)}$ for $p\in(1,2)$.
- **Setting**: adversarial training, heavy-tailed gradients.
- **Why it's a gap**: B4 and B5 in stability cluster are independent; their composition is open.
- **Suggested proof strategy**: `couple_track` (HRS chassis) + mixed-Hessian bridge (B4) + L^p lifting (B5).
- **Difficulty estimate**: research
- **Plausibility**: HIGH (the techniques compose cleanly; B5 explicitly absorbs new ingredients into the chassis).

---

## Summary of GAP counts

| Theme | # GAPs | Mean plausibility |
|---|---|---|
| 1 — Adaptive × iterate-type × function-class | 8 | HIGH/MED |
| 2 — Lower bounds for adaptive/VR | 5 | HIGH/MED |
| 3 — Iterate-type asymmetry × non-OP-2 | 5 | MEDIUM |
| 4 — Function-class extension | 6 | HIGH/MED |
| 5 — Bandit/OL extensions | 4 | MEDIUM |
| 6 — Generalization × algorithm class | 4 | MEDIUM/HIGH |
| **Total** | **32** | |

**Top plausibility GAPs**: 1.1 (AdaGrad-Norm last-iterate), 1.2 (Adam high-prob), 2.1 (SPIDER LB), 4.6 (PDHG accelerated under partial SC), 6.4 (B4∘B5 composition).

**Most "would-CHANGE-someone's-mind"**: 1.5 (Adam best-vs-averaged gap), 3.4 (NPG best-iterate $1/k^2$), 6.1 (Adam stability — high prior of disappointment).
