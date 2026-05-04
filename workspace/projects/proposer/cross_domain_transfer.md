# Cross-Domain Transfer — Step A4

> Source: `workspace/structure_map.md` (28 ANALOGY/SAME_TEMPLATE/GENERALIZATION blocks across 5 clusters).
> For each ANALOGY link, identify the unfilled direction of the transfer.
> Also: for each meta-template in `strategy_index.md`, list applied vs unapplied algorithms.
>
> Aim: 10-20 candidates.

Templates inventoried (from strategy_index.md vocabulary + master_discovery_report.md):

| Meta-template | Applied to | Not yet applied to |
|---|---|---|
| `cancellation_pair` | NPG, OGDA, SAM, Q-learning, ent-VI, ent-NPG, softmax-PG, PDHG, ADMM | SHB, GDA, SVRG/SPIDER/STORM/PAGE, Adam family, ULA, bandits |
| `couple_track` | Q-learning sync, ULA, HRS-SGD, signal-noise-SGD, adv-trajectory, heavy-tail-trajectory | NPG, SAM, OGDA, Adam, momentum-SGD, GDA |
| `exp_supermartingale` | EXP3, OFUL, Catoni, TS, Xu-Raginsky, Matrix CE, CR-compositional | Adaptive methods (Adam etc), VR methods, GDA, ULA |
| `polytope_construction` | SHB lower bounds (4), heavy-ball instability | Adam, AMSGrad, AdaGrad-Norm, VR methods, NPG, GDA, OGDA, ULA, PDHG, ADMM |
| `le_cam_testing` | SHB variance LB (2), SSL InfoNCE LB, CR depth LB, LASSO RE | Adam, AdaGrad-Norm, VR methods, NPG, GDA, ULA, ADMM, MCMC |

---

## Cluster A — ANALOGY-direction transfers from structure_map (4 candidates)

### Candidate: B2-style DP-translation for SAM stability
- **Problem statement**: SAM with sharpness-aware perturbation $\rho$ corresponds to an $\rho L$-DP mechanism on the gradient, hence has uniform stability $\le 2L\rho/n$ — translating Dwork-style DP guarantees to SAM-specific stability.
- **Setting**: SAM optimizer, smooth losses, leave-one-out stability.
- **Why it's a transfer**: B2 (DP-stability ANALOGY: divergence-based stability is divergence-agnostic) is applied to SGD; SAM has not been touched. The SAM perturbation is structurally similar to a DP noise injection.
- **Suggested proof strategy**: Hockey-stick decomposition (B2 chain) + Danskin's theorem on SAM's perturbed gradient (C2 chain).
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM-HIGH (existing literature on SAM-as-PAC-Bayes provides scaffolding).

### Candidate: C3↔C4 linearize-then-couple ANALOGY for Adam
- **Problem statement**: Adam's update $\Delta_t = \eta_t m_t/\sqrt{v_t}$ admits a linearization-coupling decomposition $\Delta_t = L_t + R_t$ where $L_t$ is the dominant martingale term (clean Azuma) and $R_t$ is a bounded EMA-coupling residual; this gives a finite-time concentration bound for Adam-type updates of the form $\sqrt T$-deviation from population gradient flow.
- **Setting**: smooth non-convex, Adam, finite-time concentration.
- **Why it's a transfer**: C3 (sync Q-learning linearize-then-couple) and C4 (OGDA skew-symmetric polarization) share the meta-pattern; Adam is the natural next algorithm.
- **Suggested proof strategy**: `couple_track` + Adam-specific EMA-residual bound.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: A6 ln-cosh ↔ Goujaud-Moreau ANALOGY for momentum-SGD
- **Problem statement**: Construct a smooth-convex hard instance $f(x) = \frac L2 x^2 - \lambda \ln\cosh(x)$ on which momentum-SGD with constant $\beta=0.9$ exhibits a stable period-3 limit cycle in expectation, refuting "momentum-SGD on smooth convex always converges in expectation."
- **Setting**: smooth convex, momentum-SGD with constant $\beta$.
- **Why it's a transfer**: A6 (heavy-ball instability via ln-cosh) ↔ A1 (Goujaud cycling via Moreau-conv) ANALOGY. Lifting to momentum-SGD (the stochastic version) is the natural transfer; sibling momentum-SGD interpolation has 3 PROOF VARIANTS but no instability counterpart.
- **Suggested proof strategy**: `polytope_construction` (Goujaud chain) + ln-cosh smoothing (A6 chain) + stochastic linearization.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: D3 LASSO cone ↔ D2 SO(d) packing transfer to GDA non-convex-non-concave
- **Problem statement**: For non-convex-non-concave GDA where the interaction matrix $B$ has bounded condition number, the iterate error decomposes into a "skew-symmetric cone" $C(\beta) = \{(\delta_x, \delta_y): |\langle\delta_x, B\delta_y\rangle| \le \beta\|\delta_x\|\|\delta_y\|\}$ on which GDA achieves $O(1/T)$ — restricted-geometry naming applied to minimax.
- **Setting**: non-convex-non-concave GDA, restricted geometry.
- **Why it's a transfer**: D3 (LASSO cone) and D2 (SO(d) packing) live in the "restricted-geometry" cluster; minimax is unfilled.
- **Suggested proof strategy**: `OTHER:cone_constraint` + skew-symmetric polarization (C4 OGDA chain).
- **Difficulty estimate**: research
- **Plausibility**: LOW-MEDIUM (cone might not exist as natural object).

---

## Cluster B — Meta-template transfer to "not yet applied to" algorithms (8 candidates)

### Candidate: cancellation_pair applied to GDA non-convex-strongly-concave
- **Problem statement**: For NCSC GDA with two-time-scale steps $(\eta_x, \eta_y) = (1/(2L\kappa), 1/L)$, there is a cancellation-pair identity between the envelope-descent inequality and the dual-residual concentration that gives $\kappa$-rate (not $\kappa^2$) iteration complexity $O(\kappa\varepsilon^{-2})$ — improving `gda-nonconvex-strongly-concave-convergence/` by a factor of $\kappa$.
- **Setting**: NCSC saddle, single-loop two-time-scale GDA.
- **Why it's a transfer**: `cancellation_pair` template is dominant (~26%), applied to 7 algorithms but not GDA. Sibling A11 (GDA NCSC) has $\kappa^2$ rate; the standing question is whether $\kappa$ is achievable single-loop.
- **Suggested proof strategy**: `cancellation_pair` (write envelope-descent + dual-residual two ways, cancel cross term).
- **Difficulty estimate**: research (this is a known open problem; published solutions exist via different routes).
- **Plausibility**: MEDIUM.

### Candidate: couple_track applied to Adam stability under interpolation
- **Problem statement**: For Adam in interpolation regime ($\nabla f_i(x^\star)=0$), the coupling between Adam runs on neighboring datasets satisfies $\mathbb E\|\theta_T - \theta'_T\|^2 \le C\eta^2T/((1-\beta_2)n^2)$ — strict $1/n^2$ improvement (vs HRS's $1/n$) from interpolation.
- **Setting**: interpolation regime, Adam.
- **Why it's a transfer**: `couple_track` template + interpolation. HRS chassis is the transfer target. Sibling: B3 (signal-noise SGD) shows interpolation-like decomposition gives strict improvements.
- **Suggested proof strategy**: `couple_track` + EMA-non-expansiveness (Adam-specific) + interpolation cancellation.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: exp_supermartingale applied to AdaGrad-Norm regret
- **Problem statement**: For OCO with sub-Gaussian losses, AdaGrad-Norm achieves regret bound $\Pr[\text{Reg}_T > C\sqrt{T \log(1/\delta)}] \le \delta$ via engineered exponential supermartingale on the per-step gain.
- **Setting**: OCO, AdaGrad-Norm.
- **Why it's a transfer**: `exp_supermartingale` (Catoni/OFUL/TS chain) untouched in adaptive-method context. AdaGrad-Norm OCO regret has only the Hazan-Levy expectation form.
- **Suggested proof strategy**: `exp_supermartingale` + AdaGrad-Norm denominator-as-test-function.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM-HIGH.

### Candidate: polytope_construction applied to OGDA bilinear LB
- **Problem statement**: For OGDA on bilinear saddle $f(x,y)=\langle x, By\rangle$ with $B$ skew-symmetric, there exists hard $B$ such that $\|z_T - z^\star\|^2 \ge \Omega(1/T)$, matching the upper bound `ogda-bilinear-last-iterate/` up to a constant.
- **Setting**: bilinear saddle, OGDA, lower bound.
- **Why it's a transfer**: `polytope_construction` (Goujaud chain) untouched in saddle-point context. Sibling: OGDA UB filled, no LB.
- **Suggested proof strategy**: `polytope_construction` + skew-symmetric matrix construction with cycling spectrum.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: le_cam_testing applied to ULA mixing-time LB
- **Problem statement**: For ULA targeting an LSI distribution with constant $\lambda$, the mixing-time satisfies $T_\text{mix}(\varepsilon) \ge c\log(1/\varepsilon)/(\lambda\eta)$ via Le Cam two-point on $\pi$ vs perturbed $\pi'$.
- **Setting**: LSI target, ULA, lower bound.
- **Why it's a transfer**: `le_cam_testing` (SHB/SSL chain) untouched in MCMC context. Sibling: ULA UB filled, no LB.
- **Suggested proof strategy**: `le_cam_testing` + Pinsker on stationary distribution + step-size-induced TV.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM-HIGH.

### Candidate: cancellation_pair applied to STORM
- **Problem statement**: For STORM on smooth non-convex, the EMA-correction Lyapunov coefficient $c=\eta/(2a)$ admits a *cancellation-pair* refinement that produces a tighter $O(1/T^{2/3})$ rate WITHOUT the standard $\sigma^{1/3}$ factor, when the noise variance is sub-Gaussian.
- **Setting**: STORM with sub-Gaussian noise.
- **Why it's a transfer**: `cancellation_pair` not yet applied to VR/streaming methods. Sibling: STORM UB has $\sigma^{1/3}$ factor; cancellation could remove it.
- **Suggested proof strategy**: `cancellation_pair` + STORM EMA chain.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM.

### Candidate: couple_track applied to GDA stability bound
- **Problem statement**: For NCSC GDA in the leave-one-out coupling, the parameter trajectories $(x_T, y_T)$ vs $(x'_T, y'_T)$ satisfy a joint contraction bound $\mathbb E\|x_T - x'_T\|^2 + \kappa\mathbb E\|y_T - y'_T\|^2 \le C\eta T\kappa/n$.
- **Setting**: NCSC saddle, GDA, generalization via stability.
- **Why it's a transfer**: `couple_track` (HRS chain) untouched in saddle-point context. Sibling: HRS-SGD covers single-objective; GDA is the saddle-point analog.
- **Suggested proof strategy**: `couple_track` + GDA two-time-scale Lyapunov.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM-HIGH.

### Candidate: exp_supermartingale applied to PAGE high-probability bound
- **Problem statement**: For PAGE on smooth non-convex finite-sum, the high-probability bound $\Pr[\text{best-iterate gradient norm}^2 > C\log(1/\delta)/T] \le \delta$ holds with explicit constants via engineered exponential supermartingale on the Bernoulli-reset chain.
- **Setting**: PAGE on finite-sum non-convex, high probability.
- **Why it's a transfer**: `exp_supermartingale` not yet applied to VR. Sibling: PAGE in-expectation rate is filled.
- **Suggested proof strategy**: `exp_supermartingale` + PAGE Bernoulli-reset chain.
- **Difficulty estimate**: research
- **Plausibility**: HIGH.

---

## Cluster C — DEPENDS-graph extension transfers (3 candidates)

### Candidate: B3 signal-noise framework applied to Adam-style algorithms (chain extension)
- **Problem statement**: For Adam on smooth non-convex with stochastic gradient $\nabla \ell(\theta_t, z_t) = \nabla L_S(\theta_t) + \nabla L_N(\theta_t)$ (signal-noise), the per-step recursion satisfies $\mathbb E\|\theta_T - \theta'_T\|^2 \le \eta T \cdot \mathbb E\|\nabla L_N\|^2/n + O(\eta^2)$ — strict improvement over generic HRS bound for Adam.
- **Setting**: Adam on smooth non-convex with signal-noise gradient decomposition.
- **Why it's a transfer**: B3 (signal-noise) DEPENDS B1 (HRS); the analogous extension to Adam DEPENDS the Adam-stability bound (Cluster B candidate above).
- **Suggested proof strategy**: `couple_track` + signal-noise decomposition (B3 chain).
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM-HIGH.

### Candidate: B5 heavy-tail decomposition applied to GDA stability under heavy-tailed gradients
- **Problem statement**: For NCSC GDA with $p$-th moment-bounded gradients ($p\in(1,2)$), the leave-one-out stability gap satisfies $\mathbb E\|θ_T-θ'_T\|^p \le C\eta^p T^{p-1}\kappa^{p-1}/n$, with explicit clipping at $\tau = G\cdot T^{1/p-1/2}\cdot\kappa^{1/2}$ matching minimax.
- **Setting**: NCSC saddle, GDA, heavy-tailed noise.
- **Why it's a transfer**: B5 chassis-extension explicitly transfers to "any HRS-style coupling proof"; GDA's two-time-scale coupling is the natural target.
- **Suggested proof strategy**: B5 (L^p lifting + Marcinkiewicz-Zygmund) + GDA coupling chassis.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM-HIGH.

### Candidate: E2 categorical lift applied to bandit feedback graphs
- **Problem statement**: For graph-feedback bandits with feedback graph $G$, EXP3 amplification under $k$-shot retry corresponds to a Lawvere $[0,\infty]$-enriched functor $F: G^{op} \to \text{Reg}(K)$ where the regret residual contracts at rate $\|\eta\|_\infty^k$ — categorical lift of E1 generalizes to arbitrary observation graphs.
- **Setting**: bandit with graph feedback.
- **Why it's a transfer**: E2 categorical foundation is currently abstract; concrete instantiation in bandit setting brings it down to applied land.
- **Suggested proof strategy**: E2 chain + graph-Bayes optimal observation analysis.
- **Difficulty estimate**: conjecture (dual concrete/abstract challenge)
- **Plausibility**: LOW (categorical lift may be decorative here too).

---

## Cluster D — Cross-cluster (multi-template) transfers (3 candidates)

### Candidate: Cancellation × Restricted-Geometry: NPG with restricted policy class
- **Problem statement**: For NPG restricted to a parameterized policy class (linear-softmax, neural), the cancellation between Bregman 3-pt and DV holds RESTRICTED to the cone of policy parameters that respect the $L$-smoothness; the rate is $O(1/k)$ on the cone but $\Omega(1)$ off.
- **Setting**: parameterized policy gradient, restricted policy class.
- **Why it's a transfer**: Cluster C (Cancellation Pair) ∩ Cluster D (Restricted Geometry). Two of the three meta-templates being combined have no overlap in current library.
- **Suggested proof strategy**: `cancellation_pair` (NPG chain) + cone-restricted KL bound.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM-HIGH.

### Candidate: Couple-and-track × Algorithm-design: design "CoupleSGD" with provably tight stability
- **Problem statement**: Construct an SGD variant that explicitly couples its randomness across runs (shared sampling, predictable noise). Prove that this variant achieves uniform stability $\le L\eta T/n$ — exactly tight, removing the constant gap in HRS.
- **Setting**: smooth convex/SC empirical risk, designed coupled SGD.
- **Why it's a transfer**: Cluster B (HRS chassis) ∩ AT-4 (algorithm-design-as-proof-simplification). The trick is: design the algorithm so the coupling is exact.
- **Suggested proof strategy**: `couple_track` + algorithm-design + shared-randomness coupling.
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM (might require a non-trivial coupling that breaks practical applicability).

### Candidate: Le Cam × Iteration-type: tight last-iterate LB for SGD on smooth convex
- **Problem statement**: For SGD with constant step $\eta$ on smooth convex $f$, the last-iterate satisfies $\mathbb E[f(x_T)-f^\star] \ge c\sigma D \cdot \log T/\sqrt T$ via Le Cam two-point on a 1-D linear-with-wall instance, MATCHING the HLL-R upper bound.
- **Setting**: smooth convex, SGD, last-iterate LB.
- **Why it's a transfer**: Cluster D (Le Cam) + AT-1 (iteration-type asymmetry). The matching LB to `sgd-last-iterate-averaged-baseline/` is currently missing.
- **Suggested proof strategy**: `le_cam_testing` + iterate-type-specific test function (sign of $x_T$).
- **Difficulty estimate**: research
- **Plausibility**: MEDIUM-HIGH.

---

## Summary

| Cluster | Source | # Candidates | Plausibility |
|---|---|---|---|
| A | ANALOGY-direction transfers | 4 | MED |
| B | Meta-template applied to "not yet" algorithms | 8 | MED-HIGH |
| C | DEPENDS-graph extensions | 3 | MED-HIGH |
| D | Cross-cluster combinations | 3 | MED |
| **Total** | | **18** | |

**Top picks**:
- B.1 cancellation_pair to GDA NCSC (would close $\kappa$-rate question)
- B.5 le_cam_testing to ULA mixing LB (clean unfilled spot)
- B.7 couple_track to GDA stability (HRS phylogeny extension)
- C.1 B3 signal-noise to Adam (high practitioner relevance)
- D.3 Le Cam × iteration-type for SGD last-iterate LB (matches HLL-R UB)
