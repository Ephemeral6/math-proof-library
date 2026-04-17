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

### Stability
| Theorem | Source | Difficulty | Date | Path |
|---------|--------|------------|------|------|
| SGD uniform stability generalization | Hardt, Recht, Singer 2016 (ICML) | advanced | 2026-04-02 | proofs/research/learning-theory/stability/sgd-uniform-stability-generalization/ |
| DP implies generalization | Dwork et al. 2015 (NeurIPS) / Bassily et al. 2016 (STOC) | research | 2026-04-16 | proofs/research/learning-theory/stability/dp-implies-generalization/ |

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

## Probability

### Sampling / MCMC
| Theorem | Source | Difficulty | Date | Path |
|---------|--------|------------|------|------|
| ULA KL convergence under LSI | Vempala & Wibisono 2019 (NeurIPS) | research | 2026-04-17 | proofs/research/probability/sampling/ula-kl-convergence-lsi/ |

---

## Statistics
- Research proofs: 43
- Last updated: 2026-04-17
