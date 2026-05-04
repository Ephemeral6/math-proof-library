# Research Proof Index (A-Class)

> 高价值研究级证明：来自 2015+ 论文，证明技巧有新意，非教科书内容

## Optimization

### Convergence
| Theorem | Source | Difficulty | Date | Path |
|---------|--------|------------|------|------|
| NPG softmax tabular O(1/K) convergence | Agarwal et al. 2021 / Cen et al. 2022 | conjecture | 2026-04-08 | proofs/research/optimization/convergence/npg-softmax-tabular-convergence/ |
| Entropy-regularized value iteration | Soft VI / SAC foundations | research | 2026-04-09 | proofs/research/optimization/convergence/entropy-regularized-value-iteration/ |
| SGD last-iterate averaged baseline | Koren & Segal, COLT 2020 (open problem) | conjecture | 2026-04-11 | proofs/research/optimization/convergence/sgd-last-iterate-averaged-baseline/ |
| Heavy Ball instability on smooth strongly convex | Lessard, Recht, Packard 2016 | conjecture | 2026-04-11 | proofs/research/optimization/convergence/heavy-ball-instability/ |
| SAM convergence to flat minima | Foret et al. 2021 (ICLR) | research | 2026-04-12 | proofs/research/optimization/convergence/sam-convergence-flat-minima/ |
| Lookahead optimizer convergence | Zhang et al. 2019 | research | 2026-04-12 | proofs/research/optimization/convergence/lookahead-optimizer-convergence/ |
| Synchronous Q-learning finite-time convergence | Li et al. 2021 / Wainwright 2019 | research | 2026-04-15 | proofs/research/optimization/convergence/synchronous-q-learning-finite-time/ |
| OGDA bilinear last-iterate O(1/T) convergence | Golowich et al. 2020 / Mokhtari et al. 2020 | research | 2026-04-15 | proofs/research/optimization/convergence/ogda-bilinear-last-iterate/ |
| TD(0) linear approximation O(1/T) rate | Bhandari et al. 2018 / Srikant & Ying 2019 | research | 2026-04-15 | proofs/research/optimization/convergence/td0-linear-approximation-convergence/ |
| Entropy-regularized NPG linear convergence (variant, rate 1-cητ(1-γ)) | Cen, Cheng, Chen, Wei, Chi 2022 (Oper. Res.) | research | 2026-04-17 | proofs/research/optimization/convergence/entropy-regularized-npg-linear-convergence-variant/ |
| GDA nonconvex-strongly-concave O(κ²ε⁻²) stationarity | Lin, Jin, Jordan 2020 (ICML) | research | 2026-04-18 | proofs/research/optimization/convergence/gda-nonconvex-strongly-concave-convergence/ |
| Softmax PG sublinear O(1/t) convergence (honest restatement) | Mei, Xiao, Szepesvári, Schuurmans 2020 (ICML) | research | 2026-04-18 | proofs/research/optimization/convergence/softmax-pg-sublinear-convergence/ |
| UCB-Hoeffding Q-learning $\tilde O(\sqrt{H^4 SAT})$ regret | Jin, Allen-Zhu, Bubeck, Jordan 2018 (NeurIPS) | research | 2026-04-18 | proofs/research/optimization/convergence/q-learning-ucb-hoeffding-regret/ |
| SVRG non-SC last-iterate $\Theta(\log m)$ gap (disproof + matched bounds) | Allen-Zhu & Yuan ICML 2016; Harvey et al. COLT 2019 | research | 2026-04-26 | proofs/research/optimization/convergence/svrg-non-sc-last-iterate-gap/ |
| Polyak-Ruppert weighted average defeats SHB cycling: $O(LD^2/T^2)$ bias on Goujaud's hard instance (disproof of $\Omega(1/T)$ LB) | Iterate-type extension of OP-2 / Goujaud-Taylor-Dieuleveut 2023 | research (original) | 2026-04-26 | proofs/research/optimization/convergence/polyak-ruppert-shb-defeats-cycling/ |

### Stochastic
| Theorem | Source | Difficulty | Date | Path |
|---------|--------|------------|------|------|
| SPS-SGD convergence rate | Loizou et al. 2021 (AISTATS) | advanced | 2026-04-02 | proofs/research/optimization/stochastic/sps-sgd-convergence-rate/ |
| Clipped SGD heavy-tail convergence | Zhang et al. 2020 / Gorbunov et al. 2020 | research | 2026-04-05 | proofs/research/optimization/stochastic/clipped-sgd-heavy-tail-convergence/ |
| SGD PL+interpolation two-phase convergence | PL + strong growth + averaging | conjecture | 2026-04-08 | proofs/research/optimization/stochastic/sgd-pl-interpolation-averaging/ |
| Momentum SGD interpolation linear convergence | Loizou et al. 2021 / Vaswani et al. 2019 | advanced | 2026-04-12 | proofs/research/optimization/stochastic/momentum-sgd-interpolation-linear-convergence/ |
| Momentum SGD interpolation contraction | Vaswani et al. 2019; Liu & Belkin 2020 | advanced | 2026-04-12 | proofs/research/optimization/stochastic/momentum-sgd-interpolation-contraction/ |
| Momentum SGD interpolation convergence (split co-coercivity) | Vaswani et al. 2019; Liu & Belkin 2020 | conjecture | 2026-04-12 | proofs/research/optimization/stochastic/momentum-sgd-interpolation-convergence/ |
| Momentum SGD spectral analysis convergence | Loizou et al. 2021; Vaswani et al. 2019 | advanced | 2026-04-12 | proofs/research/optimization/stochastic/momentum-sgd-spectral-analysis-convergence/ |
| SPIDER non-convex gradient complexity | Fang et al. 2018 (NeurIPS) | research | 2026-04-12 | proofs/research/optimization/stochastic/spider-nonconvex-gradient-complexity/ |
| SPIDER/SARAH variance reduction non-convex | Fang 2018 / Nguyen 2017 | research | 2026-04-12 | proofs/research/optimization/stochastic/spider-variance-reduction-nonconvex/ |
| STORM non-convex convergence rate | Cutkosky & Orabona 2019 (NeurIPS) | research | 2026-04-16 | proofs/research/optimization/stochastic/storm-nonconvex-convergence/ |
| PAGE optimal gradient complexity | Li, Huo, Chen 2021 (ICML Best Paper) | research | 2026-04-17 | proofs/research/optimization/stochastic/page-optimal-gradient-complexity/ |

### Adaptive Methods
| Theorem | Source | Difficulty | Date | Path |
|---------|--------|------------|------|------|
| Adam non-convex convergence | Defossez et al. 2022 (TMLR) | advanced | 2026-04-02 | proofs/research/optimization/adaptive-methods/adam-nonconvex-convergence/ |
| AMSGrad non-convex convergence | Reddi, Kale, Kumar 2018 (ICLR) | research | 2026-04-16 | proofs/research/optimization/adaptive-methods/amsgrad-nonconvex-convergence/ |
| AdaGrad-Norm non-convex O(log T / √T) convergence | Ward, Wu, Bottou 2019 (ICML/JMLR) | research | 2026-04-18 | proofs/research/optimization/adaptive-methods/adagrad-norm-nonconvex-convergence/ |
| AdaGrad coordinate-wise complexity (PARTIAL — original COLT 2025 conjecture REFUTED under variance-only oracle; matched pair T ≍ dσ²/ε proved instead) | COLT 2025 conjecture / refutation | conjecture | 2026-04-27 | proofs/research/optimization/adaptive-methods/adagrad-complexity-improvement-partial-refutation/ |
| Coord-wise AdaGrad under (L0,L1)-smoothness + affine noise: PARTIAL — proves $\widetilde O(d^{7/8}\sigma_0^{1/2}(\Delta_0 L_0)^{1/4}T^{-1/4})$; benchmark conjecture's $d^{1/3}T^{-1/3}$ NOT achieved by 6 explorer frames (Construction, Naive, Adversarial, Orthodox, Reduction, Compositional all converge on $T^{-1/4}$ honestly); JMM COLT 2025 reportedly uses extra structure not in problem.md | Jiang-Maladkar-Mokhtari COLT 2025 (benchmark, paper not read) | conjecture | 2026-04-27 | proofs/research/optimization/adaptive/adagrad-coordwise-improvement-benchmark/ |

### Minimax / Saddle-point
| Theorem | Source | Difficulty | Date | Path |
|---------|--------|------------|------|------|
| First-order convergence to (general, non-strict) local minimax under inner-PL: PARTIAL — Outcome 3 of CKK 2023 only; two-timescale GDA achieves $T = O(L^3/(\mu^2\varepsilon^2))$ under inner-PL with separation gap (Karimi-Nutini-Schmidt 2016). Construction explicit-instance impossibility numerically refuted (cusp-set trajectory converges at $t^{-1/2}$); Adversarial Le Cam proves stronger statement than literal CKK question. Literal CKK COLT 2023 question REMAINS OPEN. | Chae-Kim-Kim COLT 2023 (open problem) | conjecture | 2026-04-27 | proofs/research/optimization/minimax/first-order-local-minimax-convergence/ |

### Lower Bounds
| Theorem | Source | Difficulty | Date | Path |
|---------|--------|------------|------|------|
| SHB no-acceleration on $\mathcal{F}\subsetneq$stability region (∀-∃, restricted) | OP-2 downgraded; built on Goujaud-Taylor-Dieuleveut 2023/2025 (arXiv:2307.11291); tight vs Ghadimi et al. 2015 | research (original) | 2026-04-18 | proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/ |
| SHB cycling critical momentum $\beta^\star = (\sqrt{13}-3)/2$ sharp (over $K \geq 3$) | Meta-result on Goujaud-Taylor-Dieuleveut 2023 (arXiv:2307.11291); companion to OP-2 | research (original) | 2026-04-26 | proofs/research/optimization/lower-bounds/shb-cycling-critical-momentum/ |
| SHB interpolation-regime LB: bias $\Omega(LD^2/T)$ survives, variance $\Omega(\sigma D/\sqrt T)$ provably absent | Noise-model extension of OP-2; Bach 2014 / Vaswani et al. 2019 for variance impossibility | research (original) | 2026-04-26 | proofs/research/optimization/lower-bounds/shb-interpolation-regime-lb/ |
| SHB best-iterate LB on $\mathcal{F}$: bias $\Omega(\kappa LD^2/T)$ proved (cycle-symmetric), variance $\Omega(\sigma D/\sqrt T)$ disproved (random-walk visits optimum) | Iterate-type extension of OP-2 / Goujaud-Taylor-Dieuleveut 2023 | research (original) | 2026-04-26 | proofs/research/optimization/lower-bounds/shb-no-acceleration-best-iterate/ |
| Guzmán Lp/Lq oracle complexity at $p^*=4/3$: PARTIAL TWO-PART — Theorem A: $\mathrm{Comp}^{\rm stoch}_{4/3,4} = \Omega(d^{1/3}\sqrt{L/\varepsilon})$ TIGHT in stochastic-oracle model (LB confirmed via Le Cam two-point with Gaussian noise on $f_s = -\alpha\langle s,x_S\rangle + (L/4)\sum x_i^4$, $m = d^{1/3}$). Theorem B: $\mathrm{Comp}^{\rm det}_{4/3,4} = O(\sqrt{L/\varepsilon})$ dim-free in deterministic-oracle model via accelerated MD with Ball-Carlen-Lieb 1994 regularizer $\frac{1}{2(p-1)}\|x\|_p^2$; refutes Guzmán's $d^{1/3}$ UB conjecture in deterministic model. First known stochastic-vs-deterministic complexity gap at interior $p \in (1,2)$. | Guzmán COLT 2015 (open conjecture); Ball-Carlen-Lieb 1994 Inventiones 115:463-482 | conjecture | 2026-04-27 | proofs/research/optimization/lower-bounds/lp-lq-oracle-complexity/ |
| SHB Polyak-Ruppert κ-blow-up on SC quadratics: $f(\tilde x_T)\ge C_2\kappa/(T^4\eta^2 L)$ (κ-amplified PR LB) + $f(x_T)\le C_1\beta^T f(x_0)$ (geometric last-iterate UB); analytic ratio κ-exponent c=1 at natural crossover; empirical κ^{2.94} diagnosed as machine-precision-floor artifact (c≈2 in FP-floor, residual 0.94 unproven). Companion to / dual of I5 (PR averaging double-edged sword) | Internal Proposer Rank-1 (2026-04-27); Mode B anomaly A-6; companion of `polyak-ruppert-shb-defeats-cycling` | research (original) | 2026-04-27 | proofs/research/optimization/lower-bounds/shb-pr-average-kappa-blowup/ |
| SHB Polyak–Ruppert κ²-amplification over Cesàro (over-damped slow mode): $f(\tilde x_T)/f(\bar x_T) = 4(1-β)²κ²/(T·ηL)²·(1+o(1))$ as $T\to\infty$ with $T·ηµ/(1-β)\to\infty$. Hence f(Cesàro)=Θ(κ²/T²) and f(PR)=Θ(κ⁴/T⁴) — PR averaging is κ² worse than Cesàro on SC quadratics. Verified numerically at 50-digit precision across 14400 (β,ηL,κ,T) settings (R²=1.000), within 5% at κ≥100 | Internal Proposer (2026-04-27); proven via Vieta + over-damped slow-root expansion 1-r₁,μ ≈ ηµ/(1-β); cousin of `shb-pr-average-kappa-blowup` and `polyak-ruppert-shb-defeats-cycling` | research (original) | 2026-04-27 | proofs/research/optimization/lower-bounds/shb-pr-cesaro-kappa-separation/ |
| Fixed-momentum SHB stationary-point LB on L-smooth non-convex (A2 / OP-2 v6): $\max_s\E_s[\|\nabla f^{(s)}(x_T)\|^2] \geq \max\{\sigma^2/(27T),\ B_\mathrm{NC}(\beta,\eta)\}$ with $B_\mathrm{NC}=3D^2(1+\beta+\beta^2)/(2\eta^2)$ — algorithm-specific, **constant in $T$**, $\mu$-independent; orthogonal to Arjevani 2019 minimax (which decays as $1/T$). Hard instance: orthogonal-non-convexity construction $f=f_0(x)+\alpha_s y+w(y)+h(z)$ with $h(z)=(L/2)z^2 e^{-z^2/D^2}$; SHB iterate stays at $z=0$ forever (sidesteps Sun 2019 strict-saddle escape). Numerical gate 19/19 PASS at 100-digit precision. | Internal A2 / OP-2 v6 (2026-04-29); built on Goujaud-Taylor-Dieuleveut 2023/2025 (arXiv:2307.11291) cycling skeleton, OP-2 v5 wall, Arjevani-Carmon-Duchi-Foster-Srebro-Woodworth 2019/2023 (arXiv:1912.02365) baseline | research (original) | 2026-04-29 | proofs/research/optimization/lower-bounds/shb-stationary-point-orthogonal-nonconvex/ |

## Learning Theory

### Generalization
| Theorem | Source | Difficulty | Date | Path |
|---------|--------|------------|------|------|
| NTK Gram matrix positive definiteness | Du et al. 2019 (ICML) | research | 2026-04-02 | proofs/research/learning-theory/generalization/ntk-gram-matrix-positive-definiteness/ |
| Transformer attention Lipschitz bound | Transformer theory 2020-2021 | research | 2026-04-02 | proofs/research/learning-theory/generalization/transformer-attention-lipschitz/ |
| Denoising score matching equivalence | Vincent 2011 / diffusion models | research | 2026-04-02 | proofs/research/learning-theory/generalization/denoising-score-matching-equivalence/ |
| NTK infinite-width convergence rate | Du et al. 2019 / NTK theory | research | 2026-04-07 | proofs/research/learning-theory/generalization/ntk-infinite-width-convergence/ |
| Quantitative ReLU universal approximation | Yarotsky 2017 / Bach 2017 | research | 2026-04-11 | proofs/research/learning-theory/generalization/relu-universal-approximation-quantitative/ |
| Implicit bias of GD: max margin convergence | Soudry et al. 2018 (JMLR) | research | 2026-04-12 | proofs/research/learning-theory/generalization/implicit-bias-gd-max-margin/ |
| Depth separation: exponential width for 2-layer ReLU | Eldan & Shamir 2016 / Daniely 2017 | conjecture | 2026-04-15 | proofs/research/learning-theory/generalization/depth-separation-relu-exponential-width/ |
| EXP3 adversarial bandit O(√(KT log K)) regret | Auer, Cesa-Bianchi et al. 2002 (SIAM) | research | 2026-04-15 | proofs/research/learning-theory/generalization/exp3-adversarial-bandit-regret/ |
| Tweedie's formula for diffusion score matching | Robbins 1956 / Song & Ermon 2019 (NeurIPS) | research | 2026-04-15 | proofs/research/learning-theory/generalization/tweedies-formula-diffusion-score/ |
| OFUL linear bandit O(d√T) regret | Abbasi-Yadkori, Pal & Szepesvari 2011 (NeurIPS) | research | 2026-04-16 | proofs/research/learning-theory/generalization/oful-linear-bandit-regret/ |
| Catoni PAC-Bayes bound (inverse-KL form) | Catoni 2007 (IMS Lect. Notes); Alquier et al. 2016 (JMLR) | research | 2026-04-17 | proofs/research/learning-theory/generalization/catoni-pac-bayes-bound/ |
| Thompson Sampling O(√(KT log T)) Bernoulli bandit regret | Agrawal & Goyal 2017 (JACM) | research | 2026-04-18 | proofs/research/learning-theory/generalization/thompson-sampling-bernoulli-regret/ |
| Xu-Raginsky MI generalization bound (incl. BZV 2020 per-sample refinement) | Xu & Raginsky 2017 (NeurIPS); Bu-Zou-Veeravalli 2020 | research | 2026-04-18 | proofs/research/learning-theory/generalization/xu-raginsky-mi-generalization-bound/ |
| Matrix CE vs Standard CE generalization gap (conditional, low effective rank + spectral floor) | Zhang, Tan, Yang, Huang, Yuan 2024 (ICML) | research | 2026-04-26 | proofs/research/learning-theory/generalization/matrix-ce-vs-standard-ce-generalization/ |
| Spectral gap controls InfoNCE downstream projection error (1/δ rate) | Tan, Zhang, Yang, Yuan 2024 (ICLR); HaoChen et al. 2021 (NeurIPS) | research | 2026-04-26 | proofs/research/learning-theory/generalization/spectral-gap-infonce-downstream/ |
| SSL augmentation phase transition: σ_aug* = Θ(Δ_min/√d) PASS, but second-order (NOT first-order, conjecture's discontinuity claim REFUTED) | Internal Problem 7.8 — autonomous-research conjecture set 2026 | conjecture | 2026-04-26 | proofs/research/learning-theory/generalization/ssl-augmentation-phase-transition/ |
| Matrix Rényi entropy collapse detection: (a),(b) PASS, (c) PASS conditional on explicit (H1)–(H3) hypotheses on L_MSSL (concrete losses like ‖K-I/n‖²/2 verified) | Internal Problem 7.5 — Matrix-SSL spectral entropy line | research | 2026-04-26 | proofs/research/learning-theory/generalization/matrix-renyi-collapse-detection/ |
| SSL InfoNCE minimax downstream LB: $C \cdot d^2 / (n \cdot I(X;X'\mid A))$ up to log factors (PARTIAL — requires sup over $(f^*, w^*)$ jointly with $\|w^*\|^2 \le d$, n_down→∞) | Internal Problem 7.3 — Yang-Barron SO(d) packing + Schur-complement linear-probe gap | research | 2026-04-26 | proofs/research/learning-theory/generalization/ssl-infonce-minimax-lower-bound/ |
| OT characterization of contrastive representations (Problem 7.1): PARTIAL — literal conjecture REFUTED by n=4 ε=0.3 counterexample (argmin L_spec ≠ argmin J_OT under non-block W); refined theorem PROVED under (H1) block-diagonal W + (H2) spectral gap + (H3) regular blocks with uniform within-cluster prior, giving J_OT(F^spec)=0 with z_c proportional to rows of U_k R | Internal Problem 7.1 — HaoChen et al. 2021 spectral contrastive + Brenier OT-to-Dirac + Eckart-Young/Ky Fan + Ding-He k-means relaxation | conjecture | 2026-04-26 | proofs/research/learning-theory/generalization/ot-contrastive-representation-characterization/ |

### Stability
| Theorem | Source | Difficulty | Date | Path |
|---------|--------|------------|------|------|
| SGD uniform stability generalization | Hardt, Recht, Singer 2016 (ICML) | advanced | 2026-04-02 | proofs/research/learning-theory/stability/sgd-uniform-stability-generalization/ |
| DP implies generalization | Dwork et al. 2015 (NeurIPS) / Bassily et al. 2016 (STOC) | research | 2026-04-16 | proofs/research/learning-theory/stability/dp-implies-generalization/ |
| SGD signal-noise generalization decomposition (Claim 1; Claim 2 honest scope-restriction) | Zhang, Yifan et al. 2022 (ICLR) | research | 2026-04-26 | proofs/research/learning-theory/stability/sgd-signal-noise-generalization-decomposition/ |
| Generalization-robustness tradeoff in trajectory framework (Problem 7.10): Penalty(r)=O(r·H·√(Tη)) PASS via certified-Lipschitz × curvature × trajectory chain; T*_adv < T*_clean strict PASS via argmin-shift lemma; literal T*_clean/(1+r²H²η) PARTIAL (natural-parameterization exact ratio (β/(β+crH))^{2/3}; literal form is asymptotic/up-to-units only) | Trajectory-stability + adversarial perturbation synthesis; Hardt-Recht-Singer 2016, Madry et al. 2018, Zhang et al. 2022 ICLR | research | 2026-04-26 | proofs/research/learning-theory/stability/adversarial-trajectory-tradeoff/ |
| Heavy-tailed trajectory decomposition (Problem 7.6): SGD generalization under E\|grad L\|^p ≤ G^p for p∈(1,2) splits as G_S^(p)(T)=O(\|grad L_S\|^p η^p T^{p-1}/m) (signal: convexity-non-expansive swap-event drift) + G_N^(p)(T)=O(G^p η^{p/2} T^{(p-2)/2}/m^{(2-p)/2}) (noise: one-sided BDG/Marcinkiewicz–Zygmund for p∈(1,2)); clipping at τ=G·T^{1/p−1/2} (averaged-SGD optimum) yields O(G·T^{1−1/p}/√m) matching minimax. Honest caveat: un-averaged optimum is τ=G·T^{1/p}; the T^{−1/2} suppression requires Polyak-Ruppert averaging. SymPy verified algebra and step-size schedule; NumPy m-slope = −0.472 vs predicted −0.5 (Pareto noise α=1.7, p=1.5) | von Bahr–Esseen 1965, Burkholder 1973; Hardt-Recht-Singer 2016; Wang-Mao 2021, Vural et al. 2022 (heavy-tailed minimax); Zhang et al. 2022 ICLR (signal-noise framework) | research | 2026-04-26 | proofs/research/learning-theory/stability/heavy-tailed-trajectory-decomposition/ |

## Statistics

### High-Dimensional
| Theorem | Source | Difficulty | Date | Path |
|---------|--------|------------|------|------|
| Double descent interpolation threshold | Proportional asymptotics / ridgeless regression | research | 2026-04-04 | proofs/research/statistics/high-dimensional/double-descent-interpolation-threshold/ |
| LASSO prediction error under RE condition | Bickel, Ritov, Tsybakov 2009 (Annals of Statistics) | research | 2026-04-15 | proofs/research/statistics/high-dimensional/lasso-re-prediction-error/ |

## Convex Analysis

### Subgradient / Splitting
| Theorem | Source | Difficulty | Date | Path |
|---------|--------|------------|------|------|
| Douglas-Rachford splitting O(1/k) convergence | Lions & Mercier 1979 / Davis & Yin 2016 | research | 2026-04-15 | proofs/research/convex-analysis/subgradient/douglas-rachford-splitting-rate/ |
| Chambolle-Pock PDHG O(1/N) ergodic convergence | Chambolle & Pock 2011/2016 (JMIV / Math. Prog.) | research | 2026-04-16 | proofs/research/convex-analysis/subgradient/chambolle-pock-pdhg-ergodic-convergence/ |
| Davis-Yin 3-op splitting ergodic rate (variant, γ≤1/β) | Davis & Yin 2017 (SIOPT) | research | 2026-04-17 | proofs/research/convex-analysis/subgradient/davis-yin-three-operator-splitting-ergodic-variant/ |
| ADMM ergodic O(1/T) convergence (feasible test point, no full-rank) | He & Yuan 2012 (SIAM J. Numer. Anal.) | research | 2026-04-18 | proofs/research/convex-analysis/subgradient/admm-ergodic-convergence/ |

## Probability

### Sampling / MCMC
| Theorem | Source | Difficulty | Date | Path |
|---------|--------|------------|------|------|
| ULA KL convergence under LSI | Vempala & Wibisono 2019 (NeurIPS) | research | 2026-04-17 | proofs/research/probability/sampling/ula-kl-convergence-lsi/ |

## Low-Dimensional Topology

### Curve Complex
| Theorem | Source | Difficulty | Date | Path |
|---------|--------|------------|------|------|
| Lemma 3.4''-clean / OP-1 closure on S_{1,2}: DL(α) at i(γ_0,α)=2 config (b) is JOIN K_2∨G_outer (parallel arcs case) or G* = K_4+4 paired leaves (non-parallel case) — full topological proof via Bonahon intersection formula + half-twist symmetry; verified 33/33 DB α | OP-1 / Hatcher 1991 / Bestvina-Brady 1997 / Bonahon 1986 | research | 2026-05-02 | proofs/research/low-dimensional-topology/curve-complex/op1-s12-lemma34-clean-config-b/ |

## Multi-Agent / Verification

### Verification
| Theorem | Source | Difficulty | Date | Path |
|---------|--------|------------|------|------|
| Multi-agent verification error propagation: $(1-\varepsilon)^T$ vs $(1-\varepsilon^k)^T$ Auditor–Fixer reliability | Inspired by Zhang–Yang–Yuan–Yao 2023 (Cumulative Reasoning, arXiv:2308.04371) | research | 2026-04-26 | proofs/research/multi-agent/verification/multi-agent-verification-error-propagation/ |
| Categorical foundation: functorial error propagation, Lawvere-enriched [C,D], $\|\eta\|_\infty^k$ Auditor-Fixer near-retraction, discrete reduces to Problem 4.1 | Internal Problem 7.2 — Lawvere 1973 + Kelly enriched cat + Cumulative Reasoning multi-agent framework | conjecture | 2026-04-26 | proofs/research/multi-agent/categorical-functorial-error-propagation/ |
| Compositional CR reuse (Problem 7.7): tree-unfolding $(1-\delta)^{N(d,\Delta)}$ with $N=\frac{\Delta^{d+1}-1}{\Delta-1}$ vs per-lemma retry $(1-\delta^k)^m$ — exponential gap justifies P3 library-first reuse; honest correction of user-stated $(1-\delta)^{\Delta^d}$ form | User research framework Problem 7.7 (CR-style multi-agent compositionality, arXiv:2308.04371 lineage) | research | 2026-04-26 | proofs/research/multi-agent/cumulative-reasoning-compositional-reuse/ |
| CR depth lower bound (Problem 7.9): (a) $T \ge d\log(1/\delta)/\log(1/\varepsilon)$ PASS via Yao + Bayes-error tail; (b) PARTIAL — no-parallelization under transcript-dependency model only; (c) PARTIAL — formula correct, claimed "≈18 steps" is arithmetic error (true value 3.9) | Internal Problem 7.9 — CR-style multi-agent depth bound (arXiv:2308.04371 lineage) | conjecture | 2026-04-26 | proofs/research/multi-agent/cumulative-reasoning-depth-lower-bound/ |
| CR non-stationary verifier (Problem 7.4): (a) sub-linear $\alpha<1$ PASS via integral-test + $\log(1-x)\ge -x-x^2$ giving $P_T \ge \exp(-3\cdot 2^\alpha\varepsilon_0 T^{\alpha+1}/((\alpha+1)T_0^\alpha))$; (b) linear $\alpha=1$ PASS-with-clarification (threshold $T^{**}=(1-1/e)T_0/\varepsilon_0$ where marginal log-decrement reaches 1; with benefit closed form $T^*_\beta=T_0(\sqrt{1+4\beta/(\varepsilon_0 T_0)}-1)/2$); (c) super-linear $\alpha>1$ PASS-with-correction (correct $T_{\text{div}}=((\alpha+1)T_0^\alpha/\varepsilon_0)^{1/(\alpha+1)}$, problem's $T_0^{\alpha/(\alpha-1)}\varepsilon_0^{-1/(\alpha-1)}$ identified as dimensional typo); (d) optimum $T^*(\alpha)=(\beta T_0^\alpha/\varepsilon_0)^{1/(\alpha+1)}\cdot(1+o(1))$ asymptotic with closed form for $\alpha\in\{0,1\}$ | Internal Problem 7.4 — CR-style multi-agent context-dependent verifier (arXiv:2308.04371 lineage) | research | 2026-04-26 | proofs/research/multi-agent/cumulative-reasoning-nonstationary-verifier/ |

---

## Statistics
- Research proofs: 78
- Last updated: 2026-05-02
