# Math Proof Library Index

> This file is a top-level pointer. The proof library is split into two tiers:

## Index Files

- **[RESEARCH_INDEX.md](RESEARCH_INDEX.md)** — A-class proofs (78): research-level results from 2015+ papers
- **[LIBRARY_INDEX.md](LIBRARY_INDEX.md)** — B/C-class proofs (42): classic results, foundational lemmas, toolbox

## Directory Structure

```
proofs/
├── research/       ← A-class (research-level, novel techniques)
│   ├── optimization/
│   │   ├── convergence/
│   │   ├── stochastic/
│   │   ├── adaptive-methods/
│   │   └── lower-bounds/
│   ├── learning-theory/
│   │   ├── generalization/
│   │   └── stability/
│   ├── statistics/
│   │   └── high-dimensional/
│   └── multi-agent/
│       └── verification/
└── library/        ← B/C-class (foundational tools, citable lemmas)
    ├── optimization/
    │   ├── convergence/
    │   ├── stochastic/
    │   ├── adaptive-methods/
    │   ├── lower-bounds/
    │   └── mirror-descent/
    ├── learning-theory/
    │   ├── generalization/
    │   ├── pac/
    │   └── rademacher/
    ├── convex-analysis/
    │   ├── duality/
    │   └── subgradient/
    ├── statistics/
    │   ├── concentration/
    │   └── high-dimensional/
    ├── linear-algebra/
    └── probability/
```

## Statistics
- Total proofs: 120 (Research: 78, Library: 42)
- Last updated: 2026-05-02
- Added Lemma 3.4''-clean / OP-1 closure on S_{1,2} on 2026-05-02: For α at i(γ_0,α)=2 config (b) on S_{1,2}, the descending link DL(α) is either a JOIN K_2∨G_outer (cones at α's arc class, when α has parallel arcs on Σ_{0,4}) or G* = K_4+4-paired-leaves (when α has non-parallel arcs). Topological proof via cut-along-γ_0 → Σ_{0,4} arc decomposition + Bonahon's piecewise-linear intersection formula i(α, T_{γ_0}^t(β)) = max(c, |2t-d|) + half-twist symmetry argument forcing d odd in Case J / d even for diagonals in Case G. Empirical verification: 33/33 DB α match the dichotomy via depth-3 BFS arc-class enumeration (88 arc classes). This **closes OP-1 on S_{1,2}**: combined with k≥3 (Hatcher pigeonhole) and k=2 config(a) (puncture-free face), C^1(S_{1,2}) is contractible. Path: proofs/research/low-dimensional-topology/curve-complex/op1-s12-lemma34-clean-config-b/
- Added A2 / OP-2 v6 on 2026-04-29: Fixed-momentum SHB stationary-point LB on L-smooth non-convex — algorithm-specific constant-in-T separation from Arjevani 2019 minimax via Goujaud cycling on convex polytope ⊕ orthogonal non-convex bump h(z)=(L/2)z²exp(-z²/D²); evades Sun 2019 strict-saddle escape (z=0 path-wise invariance), Okamura 2024 Lipschitz-Hessian UB (Goujaud is C¹·¹ not C²), Wang-Abernethy 2020 benign UB. Closed-form B_NC(β,η)=3D²(1+β+β²)/(2η²) is μ-independent, T-independent. Numerical gate 19/19 PASS at 100-digit precision. Path: proofs/research/optimization/lower-bounds/shb-stationary-point-orthogonal-nonconvex/
- Added 3 problems on 2026-04-27 via 6-frame-divergence pipeline (full Scout → 6 Explorers → Judge → Audit×2 → Fix → Integrator → Archive):
  - P1 (BENCHMARK): Coord-wise AdaGrad under (L0,L1)-smoothness + affine noise — PARTIAL, $\widetilde O(d^{7/8} T^{-1/4})$; conjectured $T^{-1/3}$ NOT achieved by 6 frames; JMM COLT 2025 noted as future bridge. Path: proofs/research/optimization/adaptive/adagrad-coordwise-improvement-benchmark/
  - P2 (OPEN, Chae-Kim-Kim COLT 2023): First-order convergence to non-strict local minimax — PARTIAL Outcome 3 only (under inner-PL); Construction explicit-instance impossibility numerically refuted; literal CKK question REMAINS OPEN. Path: proofs/research/optimization/minimax/first-order-local-minimax-convergence/
  - P3 (OPEN, Guzmán COLT 2015): Lp/Lq oracle complexity — PARTIAL TWO-PART: TIGHT LB $\Omega(d^{1/3}\sqrt{L/\varepsilon})$ at $p^*=4/3$ in stochastic-oracle model + dim-free UB $O(\sqrt{L/\varepsilon})$ in deterministic model via BCL; first known stochastic-vs-deterministic gap at interior $p$. Path: proofs/research/optimization/lower-bounds/lp-lq-oracle-complexity/
- Added Problem PR-κ on 2026-04-27: SHB Polyak-Ruppert κ-blow-up on SC quadratics (Proposer Rank-1; companion to / dual of I5; analytic c=1, FP-floor c≈2, empirical κ^{2.94} diagnosed as machine-precision artifact; Compositional frame won 6-route divergence, all 6 explorers agreed except Route 2 which was verified-as-counterexample-to-itself)
- Restructured from flat to tiered layout on 2026-04-15 (Iteration 0)
- Added new branch `multi-agent/verification` on 2026-04-26 (Problem 4.1, Auditor–Fixer reliability theorem)
- Added Problem 1.2 on 2026-04-26: Matrix CE vs Standard CE generalization gap (Yang Yuan ICML 2024)
- Added Problem 3.1 on 2026-04-26: SVRG non-SC last-iterate Θ(log m) gap (disproof + matched bounds)
- Added Problem 2.1 on 2026-04-26: SGD signal-noise generalization decomposition (Zhang et al. ICLR 2022; honest scope)
- Added Problem M3 on 2026-04-26: SHB cycling critical momentum β* = (√13-3)/2 sharp threshold (companion to OP-2)
- Added Problem I5 on 2026-04-26: Polyak-Ruppert weighted average defeats SHB cycling — $\Omega(LD^2/T)$ LB DISPROVED with $O(LD^2/T^2)$ matching UB (iterate-type extension of OP-2)
- Added Problem S4 on 2026-04-26: SHB interpolation-regime LB — bias $\Omega(LD^2/T)$ survives, variance $\Omega(\sigma D/\sqrt T)$ provably absent (noise-model extension of OP-2)
- Added Problem I3 on 2026-04-26: SHB best-iterate LB — bias $\Omega(\kappa LD^2/T)$ proved (cycle-symmetric, no transient); variance $\Omega(\sigma D/\sqrt T)$ DISPROVED (random walk visits optimum at rate $1/T$)
- Added Problem 7.2 on 2026-04-26: Categorical foundation of multi-agent verification — Lawvere-enriched functor category formalism; sup-norm of natural transformation = functor-category distance; Auditor-Fixer is α-contracting near-retraction (true retraction in limit); discrete special case strictly recovers Problem 4.1 bounds (SymPy + Monte-Carlo verified)
- Added Problem 7.8 on 2026-04-26: SSL augmentation phase transition — PARTIAL; (a) rank-k below σ*, (b) rank-1 collapse above σ*, (d) σ_aug* = Θ(Δ_min/√d) numerically confirmed (CoV 2.3% across 12 (d, Δ_min) configs); (c) "first-order discontinuous gap" REFUTED — transition is second-order under natural smooth Gaussian model
- Added Problem 7.7 on 2026-04-26: Compositionality of CR — tree-unfolding $(1-\delta)^{N(d,\Delta)}$ with $N=\frac{\Delta^{d+1}-1}{\Delta-1}$ vs per-lemma retry $(1-\delta^k)^m$; exponential gap justifies P3 library-first reuse; honest correction of user-stated $(1-\delta)^{\Delta^d}$ form (induction yields strictly tighter $(1-\delta)^{N(d,\Delta)}$); audit passed in 1 round (SymPy + Z3 + numerical 10000-sample)
- Added Problem 7.9 on 2026-04-26: CR depth lower bound — (a) PASS $T \ge d\log(1/\delta)/\log(1/\varepsilon)$ via Yao + Bayes-error tail; (b) PARTIAL — no-parallelization holds only under transcript-dependency model; (c) PARTIAL — formula correct (cluster-step interpretation), but claimed numerical answer "≈ 18 steps" is arithmetic error (true value 3.9 at $\varepsilon=0.14, k=3, d=5, \delta=0.01$). SymPy+Z3 verified.
- Added Problem 7.3 on 2026-04-26: SSL InfoNCE minimax downstream lower bound — PARTIAL; proved $C \cdot d^2 / (n \cdot I(X;X'\mid A))$ up to log factors via Yang-Barron packing on $SO(d)$ + Schur-complement linear-probe gap + DPI-based MI bound $I(V;\text{data}^n) \le n \cdot I(X;X'|A)$. Honest caveats: requires sup over $(f^*, w^*)$ jointly (sup over $w^*$ alone gives only $d/(n \cdot I)$); $\|w^*\|^2 \le d$ normalization; n_down→∞ assumption. NumPy verified empirical $d^2$ scaling: risk·n·I/d² ∈ [0.118, 0.194] across d ∈ {4,...,64} (constant up to logs).
- Added Problem 7.5 on 2026-04-26: Matrix Rényi entropy and representation collapse — (a) $S_\alpha(K)=0 \iff \mathrm{rank}(K)=1$ PASS via spectral reduction; (b) $S_\alpha(K) \le \log n$ with equality at $K = I/n$ PASS via Jensen on $x^\alpha$; (c) gradient-flow monotonicity $\frac{dS_\alpha}{dt} \ge c (S_\alpha^{\max}-S_\alpha)\lambda_{\min}(\nabla^2 L_{\mathrm{MSSL}})$ PASS conditional on explicit (H1)–(H3) hypotheses; leading PL constant $1/(2\alpha)$ verified by SymPy Taylor + Z3 polynomial inequality + NumPy gradient flow (0/199 monotonicity violations, $\alpha\in\{0.5, 2, 3\}$).
- Added Problem 7.10 on 2026-04-26: Generalization-robustness tradeoff in trajectory framework — Penalty(r) = O(r·H·√(Tη)) PASS via certified-Lipschitz × curvature × trajectory chain; T*_adv < T*_clean strict PASS via argmin-shift lemma; literal T*_clean/(1+r²H²η) PARTIAL (natural-parameterization exact ratio = (β/(β+crH))^{2/3}, linearizes to 1−(2/3)crH/β, NOT 1−r²H²η). NumPy SGD-on-quadratic verified T*_adv=386<T*_clean=396; SymPy+Z3 verified the strict inequality and the algebraic chain.
- Added Problem 7.4 on 2026-04-26: Cumulative-reasoning convergence under non-stationary verifier ε_t = ε₀(1+t/T₀)^α — (a) sub-linear α<1 PASS via integral-test + log(1-x)≥-x-x² giving P_T ≥ exp(-3·2^α·ε₀T^(α+1)/((α+1)T₀^α)); (b) linear α=1 PASS-with-clarification (T**=(1-1/e)T₀/ε₀ where marginal log-decrement reaches 1; with benefit closed form T*_β=T₀(√(1+4β/(ε₀T₀))-1)/2); (c) super-linear α>1 PASS-with-correction (correct T_div=((α+1)T₀^α/ε₀)^(1/(α+1)); problem's stated T₀^(α/(α-1))ε₀^(-1/(α-1)) is dimensional typo); (d) optimum T*(α)=(βT₀^α/ε₀)^(1/(α+1))·(1+o(1)). SymPy verified integral identity; numerical (α∈{0.5,1,2}, T₀=100, ε₀=0.1) confirmed bounds and thresholds within 5-30% (continuum-discrete error).
- Added Problem 7.6 on 2026-04-26: Heavy-tailed trajectory decomposition — under E\|grad L\|^p ≤ G^p for p∈(1,2), gen gap splits as G_S^(p)(T)=O(\|grad L_S\|^p η^p T^{p-1}/m) + G_N^(p)(T)=O(G^p η^{p/2} T^{(p-2)/2}/m^{(2-p)/2}); via convexity-non-expansive lemma + one-sided Burkholder/Marcinkiewicz–Zygmund for p∈(1,2). Clipping at τ=G·T^{1/p−1/2} (averaged-SGD optimum) yields O(G·T^{1−1/p}/√m) matching minimax (Wang–Mao 2021, Vural et al. 2022). Honest caveat: un-averaged optimum is τ=G·T^{1/p}; the T^{−1/2} suppression requires Polyak-Ruppert averaging together with eta=c_p T^{(p-2)/(2p)} m^{(2-p)/(2p)}. SymPy verified algebra; NumPy m-slope = −0.472 vs predicted −0.5 (Pareto α=1.7, p=1.5).
- Added Problem 7.1 on 2026-04-26: OT characterization of contrastive representations — PARTIAL (CONJECTURE-level). Literal claim REFUTED by n=4, ε=0.3 numerical counterexample showing argmin L_spec ≠ argmin J_OT under non-block W (F_spec gives L=1.2613 / J_OT=0.6545; F_alt gives L=1.9351 / J_OT=0.0000). Refined theorem PROVED under (H1) block-diagonal W, (H2) spectral gap, (H3) regular blocks + uniform within-cluster prior: F^spec is constant on each cluster, J_OT = 0, z_c proportional to rows of (U_k R) with explicit factor sqrt(λ_c^*/π_c). Underlying lemmas (Brenier OT-to-Dirac identity; Eckart-Young/Ky Fan trace inequality) verified in SymPy + Z3 + NumPy.
- Added AdaGrad coordinate-wise complexity on 2026-04-27: HONEST PARTIAL — COLT 2025 conjecture (T^{-2/3}d^{1/3} UB and sqrt(d)/ε^{3/2} LB) REFUTED under variance-only oracle by 6 independent Explorer routes; matched pair T ≍ dσ²/ε proved via per-coordinate self-bounding sum UB (Route 1, MT1) + d-needle Le Cam LB (Route 3, MT6). Audit PASS_PARTIAL after 1 fix round (3 ROUTINE fixes). Path: proofs/research/optimization/adaptive-methods/adagrad-complexity-improvement-partial-refutation/
- Added SHB Polyak–Ruppert κ²-amplification over Cesàro on 2026-04-27: PASS in 1 round. Proves $f(\tilde x_T)/f(\bar x_T) = 4(1-β)²κ²/(T·ηL)²(1+o(1))$ in over-damped slow-mode regime via Vieta + slow-root expansion $1-r_{1,μ} ≈ ηµ/(1-β)$. All 6 Explorer routes converged on same final constant. Numerically verified at 50-digit mpmath across 14400 (β,ηL,κ,T) settings (R²=1.000), within 5% at κ≥100. PR averaging is κ² **worse** than Cesàro on SC quadratics. Path: proofs/research/optimization/lower-bounds/shb-pr-cesaro-kappa-separation/
