# PASS Research Proofs — Master List for Literature Cross-Check

**Date generated**: 2026-04-27
**Source**: `RESEARCH_INDEX.md` (70 research-level proofs as of 2026-04-26)
**Convention**: PARTIAL/DISPROVED entries are flagged separately; the cross-check still runs on them so we can compare both the literal claim and the honest restatement.

---

## Group A — Optimization / Convergence (15 proofs)
**Owner**: Agent 1

| # | Theorem | Source paper (claimed) | arXiv | Path |
|---|---|---|---|---|
| A1 | NPG softmax tabular O(1/K) convergence | Agarwal et al. 2021 / Cen et al. 2022 | 1908.00261 / 2007.06558 | proofs/research/optimization/convergence/npg-softmax-tabular-convergence/ |
| A2 | Entropy-regularized value iteration | Soft VI / SAC foundations (Haarnoja et al. 2018) | 1801.01290 | proofs/research/optimization/convergence/entropy-regularized-value-iteration/ |
| A3 | SGD last-iterate averaged baseline | Koren & Segal 2020 (COLT) | (open problem) | proofs/research/optimization/convergence/sgd-last-iterate-averaged-baseline/ |
| A4 | Heavy Ball instability on smooth strongly convex | Lessard, Recht, Packard 2016 | 1408.3595 | proofs/research/optimization/convergence/heavy-ball-instability/ |
| A5 | SAM convergence to flat minima | Foret et al. 2021 (ICLR) | 2010.01412 | proofs/research/optimization/convergence/sam-convergence-flat-minima/ |
| A6 | Lookahead optimizer convergence | Zhang et al. 2019 (NeurIPS) | 1907.08610 | proofs/research/optimization/convergence/lookahead-optimizer-convergence/ |
| A7 | Synchronous Q-learning finite-time convergence | Li et al. 2021 / Wainwright 2019 | 2102.06548 / 1905.06265 | proofs/research/optimization/convergence/synchronous-q-learning-finite-time/ |
| A8 | OGDA bilinear last-iterate O(1/T) | Golowich et al. 2020 / Mokhtari et al. 2020 | 2002.00057 / 2002.00057 | proofs/research/optimization/convergence/ogda-bilinear-last-iterate/ |
| A9 | TD(0) linear approx O(1/T) rate | Bhandari et al. 2018 / Srikant & Ying 2019 | 1806.02450 / 1902.00923 | proofs/research/optimization/convergence/td0-linear-approximation-convergence/ |
| A10 | Entropy-regularized NPG linear convergence (variant) | Cen, Cheng, Chen, Wei, Chi 2022 (Oper. Res.) | 2007.06558 | proofs/research/optimization/convergence/entropy-regularized-npg-linear-convergence-variant/ |
| A11 | GDA nonconvex-strongly-concave O(κ²ε⁻²) | Lin, Jin, Jordan 2020 (ICML) | 1906.00331 | proofs/research/optimization/convergence/gda-nonconvex-strongly-concave-convergence/ |
| A12 | Softmax PG sublinear O(1/t) (honest restatement) | Mei, Xiao, Szepesvári, Schuurmans 2020 (ICML) | 2005.06392 | proofs/research/optimization/convergence/softmax-pg-sublinear-convergence/ |
| A13 | UCB-Hoeffding Q-learning regret | Jin, Allen-Zhu, Bubeck, Jordan 2018 (NeurIPS) | 1807.03765 | proofs/research/optimization/convergence/q-learning-ucb-hoeffding-regret/ |
| A14 | SVRG non-SC last-iterate Θ(log m) gap | Allen-Zhu & Yuan 2016; Harvey et al. 2019 | 1506.01972 / 1810.03415 | proofs/research/optimization/convergence/svrg-non-sc-last-iterate-gap/ |
| A15 | Polyak-Ruppert weighted average defeats SHB cycling | Iterate-type extension of OP-2 / GPT 2023 | 2307.11291 | proofs/research/optimization/convergence/polyak-ruppert-shb-defeats-cycling/ |

## Group B — Optimization / Stochastic + Adaptive (14 proofs)
**Owner**: Agent 2

### Stochastic
| # | Theorem | Source paper | arXiv | Path |
|---|---|---|---|---|
| B1 | SPS-SGD convergence rate | Loizou et al. 2021 (AISTATS) | 2002.10542 | proofs/research/optimization/stochastic/sps-sgd-convergence-rate/ |
| B2 | Clipped SGD heavy-tail convergence | Zhang et al. 2020 / Gorbunov et al. 2020 | 2002.10589 / 2005.10785 | proofs/research/optimization/stochastic/clipped-sgd-heavy-tail-convergence/ |
| B3 | SGD PL+interpolation two-phase | PL+strong-growth+averaging composite | (folklore composite) | proofs/research/optimization/stochastic/sgd-pl-interpolation-averaging/ |
| B4 | Momentum SGD interpolation linear convergence | Loizou et al. 2021 / Vaswani et al. 2019 | 2002.10542 / 1810.07288 | proofs/research/optimization/stochastic/momentum-sgd-interpolation-linear-convergence/ |
| B5 | Momentum SGD interpolation contraction | Vaswani 2019; Liu & Belkin 2020 | 1810.07288 / 2003.00307 | proofs/research/optimization/stochastic/momentum-sgd-interpolation-contraction/ |
| B6 | Momentum SGD interpolation convergence (split co-coercivity) | Vaswani 2019; Liu & Belkin 2020 | 1810.07288 / 2003.00307 | proofs/research/optimization/stochastic/momentum-sgd-interpolation-convergence/ |
| B7 | Momentum SGD spectral analysis convergence | Loizou 2021; Vaswani 2019 | 2002.10542 / 1810.07288 | proofs/research/optimization/stochastic/momentum-sgd-spectral-analysis-convergence/ |
| B8 | SPIDER non-convex gradient complexity | Fang et al. 2018 (NeurIPS) | 1807.01695 | proofs/research/optimization/stochastic/spider-nonconvex-gradient-complexity/ |
| B9 | SPIDER/SARAH variance reduction non-convex | Fang 2018 / Nguyen 2017 | 1807.01695 / 1703.00102 | proofs/research/optimization/stochastic/spider-variance-reduction-nonconvex/ |
| B10 | STORM non-convex convergence rate | Cutkosky & Orabona 2019 (NeurIPS) | 1905.10018 | proofs/research/optimization/stochastic/storm-nonconvex-convergence/ |
| B11 | PAGE optimal gradient complexity | Li, Huo, Chen 2021 (ICML Best Paper) | 2008.10898 | proofs/research/optimization/stochastic/page-optimal-gradient-complexity/ |

### Adaptive
| # | Theorem | Source | arXiv | Path |
|---|---|---|---|---|
| B12 | Adam non-convex convergence | Defossez et al. 2022 (TMLR) | 2003.02395 | proofs/research/optimization/adaptive-methods/adam-nonconvex-convergence/ |
| B13 | AMSGrad non-convex convergence | Reddi, Kale, Kumar 2018 (ICLR) | 1904.09237 | proofs/research/optimization/adaptive-methods/amsgrad-nonconvex-convergence/ |
| B14 | AdaGrad-Norm O(log T/√T) | Ward, Wu, Bottou 2019 (ICML/JMLR) | 1806.01811 | proofs/research/optimization/adaptive-methods/adagrad-norm-nonconvex-convergence/ |

## Group C — Lower Bounds + Convex Analysis + Probability + Statistics (11 proofs)
**Owner**: Agent 3

### Lower Bounds (OP-2 family)
| # | Theorem | Source | arXiv | Path |
|---|---|---|---|---|
| C1 | SHB no-acceleration on F (OP-2 downgraded) | Built on Goujaud-Taylor-Dieuleveut 2023; tight vs Ghadimi 2015 | 2307.11291 / 1412.7457 | proofs/research/optimization/lower-bounds/shb-no-acceleration-restricted/ |
| C2 | SHB cycling critical momentum β*=(√13-3)/2 | Meta-result on GPT 2023 | 2307.11291 | proofs/research/optimization/lower-bounds/shb-cycling-critical-momentum/ |
| C3 | SHB interpolation-regime LB | Bach 2014 / Vaswani 2019 | 1306.2119 / 1810.07288 | proofs/research/optimization/lower-bounds/shb-interpolation-regime-lb/ |
| C4 | SHB best-iterate LB | OP-2 iterate-type extension; GPT 2023 | 2307.11291 | proofs/research/optimization/lower-bounds/shb-no-acceleration-best-iterate/ |

### Convex Analysis / Subgradient
| # | Theorem | Source | arXiv | Path |
|---|---|---|---|---|
| C5 | Douglas-Rachford O(1/k) | Lions & Mercier 1979 / Davis & Yin 2016 | 1409.5237 | proofs/research/convex-analysis/subgradient/douglas-rachford-splitting-rate/ |
| C6 | Chambolle-Pock PDHG O(1/N) ergodic | Chambolle & Pock 2011/2016 | (JMIV/Math.Prog.) | proofs/research/convex-analysis/subgradient/chambolle-pock-pdhg-ergodic-convergence/ |
| C7 | Davis-Yin 3-op splitting ergodic (variant γ≤1/β) | Davis & Yin 2017 (SIOPT) | 1504.01032 | proofs/research/convex-analysis/subgradient/davis-yin-three-operator-splitting-ergodic-variant/ |
| C8 | ADMM ergodic O(1/T) (no full-rank) | He & Yuan 2012 (SIAM J. Numer. Anal.) | (no arXiv preprint, journal-only) | proofs/research/convex-analysis/subgradient/admm-ergodic-convergence/ |

### Probability
| # | Theorem | Source | arXiv | Path |
|---|---|---|---|---|
| C9 | ULA KL convergence under LSI | Vempala & Wibisono 2019 (NeurIPS) | 1903.08568 | proofs/research/probability/sampling/ula-kl-convergence-lsi/ |

### Statistics / High-Dimensional
| # | Theorem | Source | arXiv | Path |
|---|---|---|---|---|
| C10 | Double descent interpolation threshold | Proportional asymptotics / ridgeless regression | 1903.08560 (Belkin et al.) | proofs/research/statistics/high-dimensional/double-descent-interpolation-threshold/ |
| C11 | LASSO RE prediction error | Bickel-Ritov-Tsybakov 2009 (Ann. Stat.) | 0801.1095 | proofs/research/statistics/high-dimensional/lasso-re-prediction-error/ |

## Group D — Learning Theory / Generalization (17 proofs)
**Owner**: Agent 4

| # | Theorem | Source | arXiv | Path |
|---|---|---|---|---|
| D1 | NTK Gram matrix positive definiteness | Du et al. 2019 (ICML) | 1810.02054 | proofs/research/learning-theory/generalization/ntk-gram-matrix-positive-definiteness/ |
| D2 | Transformer attention Lipschitz | Transformer theory 2020-2021 | 2006.04710 (Kim et al.) | proofs/research/learning-theory/generalization/transformer-attention-lipschitz/ |
| D3 | Denoising score matching equivalence | Vincent 2011 / diffusion models | (NECO 2011) | proofs/research/learning-theory/generalization/denoising-score-matching-equivalence/ |
| D4 | NTK infinite-width convergence rate | Du et al. 2019 / NTK theory | 1810.02054 | proofs/research/learning-theory/generalization/ntk-infinite-width-convergence/ |
| D5 | Quantitative ReLU universal approximation | Yarotsky 2017 / Bach 2017 | 1610.01145 / 1611.01491 | proofs/research/learning-theory/generalization/relu-universal-approximation-quantitative/ |
| D6 | Implicit bias of GD: max margin | Soudry et al. 2018 (JMLR) | 1710.10345 | proofs/research/learning-theory/generalization/implicit-bias-gd-max-margin/ |
| D7 | Depth separation: exponential width 2-layer ReLU | Eldan & Shamir 2016 / Daniely 2017 | 1512.03965 / 1702.08489 | proofs/research/learning-theory/generalization/depth-separation-relu-exponential-width/ |
| D8 | EXP3 adversarial bandit O(√(KT log K)) regret | Auer, Cesa-Bianchi et al. 2002 (SIAM) | (Cesa-Bianchi-Lugosi book) | proofs/research/learning-theory/generalization/exp3-adversarial-bandit-regret/ |
| D9 | Tweedie's formula for diffusion score matching | Robbins 1956 / Song & Ermon 2019 | 1907.05600 | proofs/research/learning-theory/generalization/tweedies-formula-diffusion-score/ |
| D10 | OFUL linear bandit O(d√T) regret | Abbasi-Yadkori, Pal, Szepesvari 2011 (NeurIPS) | (NeurIPS 2011) | proofs/research/learning-theory/generalization/oful-linear-bandit-regret/ |
| D11 | Catoni PAC-Bayes (inverse-KL) | Catoni 2007 / Alquier et al. 2016 | 1606.01799 | proofs/research/learning-theory/generalization/catoni-pac-bayes-bound/ |
| D12 | Thompson Sampling O(√(KT log T)) Bernoulli | Agrawal & Goyal 2017 (JACM) | 1209.3353 | proofs/research/learning-theory/generalization/thompson-sampling-bernoulli-regret/ |
| D13 | Xu-Raginsky MI generalization (incl BZV) | Xu & Raginsky 2017; Bu-Zou-Veeravalli 2020 | 1705.07809 / 1901.04609 | proofs/research/learning-theory/generalization/xu-raginsky-mi-generalization-bound/ |
| D14 | Matrix CE vs Standard CE generalization | Zhang, Tan, Yang, Huang, Yuan 2024 (ICML) | 2404.18814 | proofs/research/learning-theory/generalization/matrix-ce-vs-standard-ce-generalization/ |
| D15 | Spectral gap controls InfoNCE downstream | Tan, Zhang, Yang, Yuan 2024 (ICLR); HaoChen et al. 2021 | 2106.04156 (HaoChen) | proofs/research/learning-theory/generalization/spectral-gap-infonce-downstream/ |
| D16 | SSL augmentation phase transition (PARTIAL — (c) REFUTED) | Internal Problem 7.8 — autonomous-research conjecture set | (no published source) | proofs/research/learning-theory/generalization/ssl-augmentation-phase-transition/ |
| D17 | Matrix Rényi entropy collapse (PARTIAL — (c) conditional) | Internal Problem 7.5 — Matrix-SSL spectral entropy | (no published source) | proofs/research/learning-theory/generalization/matrix-renyi-collapse-detection/ |
| D18 | SSL InfoNCE minimax LB (PARTIAL up to logs) | Internal Problem 7.3 — Yang-Barron + Schur-complement | (no published source) | proofs/research/learning-theory/generalization/ssl-infonce-minimax-lower-bound/ |
| D19 | OT contrastive characterization (PARTIAL — literal REFUTED) | Internal Problem 7.1 — HaoChen 2021 + Brenier OT | 2106.04156 + Brenier (textbook) | proofs/research/learning-theory/generalization/ot-contrastive-representation-characterization/ |

## Group E — Stability + Multi-Agent (9 proofs)
**Owner**: Agent 5

### Stability
| # | Theorem | Source | arXiv | Path |
|---|---|---|---|---|
| E1 | SGD uniform stability generalization | Hardt, Recht, Singer 2016 (ICML) | 1509.01240 | proofs/research/learning-theory/stability/sgd-uniform-stability-generalization/ |
| E2 | DP implies generalization | Dwork et al. 2015 / Bassily et al. 2016 | 1502.04701 / 1511.02513 | proofs/research/learning-theory/stability/dp-implies-generalization/ |
| E3 | SGD signal-noise generalization decomposition | Teng, Ma, Yuan 2022 (ICLR) | 2106.06153 | proofs/research/learning-theory/stability/sgd-signal-noise-generalization-decomposition/ |
| E4 | Adversarial trajectory tradeoff (Problem 7.10, PARTIAL) | Internal — synthesis with Hardt 2016 + Madry 2018 + Zhang 2022 | 1706.06083 (Madry) | proofs/research/learning-theory/stability/adversarial-trajectory-tradeoff/ |
| E5 | Heavy-tailed trajectory decomposition (Problem 7.6) | Internal — synthesis with Wang-Mao 2021 / Vural 2022 | 2102.04259 (Wang-Mao) | proofs/research/learning-theory/stability/heavy-tailed-trajectory-decomposition/ |

### Multi-Agent / Verification
| # | Theorem | Source | arXiv | Path |
|---|---|---|---|---|
| E6 | Multi-agent verification error propagation (Problem 4.1) | Inspired by Zhang-Yang-Yuan-Yao 2023 (Cumulative Reasoning) | 2308.04371 | proofs/research/multi-agent/verification/multi-agent-verification-error-propagation/ |
| E7 | Categorical foundation of multi-agent verification (Problem 7.2) | Internal — Lawvere 1973 + Kelly enriched cat + CR | (no direct source) | proofs/research/multi-agent/categorical-functorial-error-propagation/ |
| E8 | Compositional CR reuse (Problem 7.7, corrected) | Internal — CR multi-agent compositionality | 2308.04371 | proofs/research/multi-agent/cumulative-reasoning-compositional-reuse/ |
| E9 | CR depth lower bound (Problem 7.9, PARTIAL) | Internal — CR-style depth bound | 2308.04371 | proofs/research/multi-agent/cumulative-reasoning-depth-lower-bound/ |
| E10 | CR non-stationary verifier (Problem 7.4, corrected) | Internal — context-dependent verifier | 2308.04371 | proofs/research/multi-agent/cumulative-reasoning-nonstationary-verifier/ |

---

## Total counts

- Group A (Convergence): 15
- Group B (Stochastic + Adaptive): 14
- Group C (Lower Bounds + Convex + Prob + Stats): 11
- Group D (Generalization): 19
- Group E (Stability + Multi-Agent): 10

**Grand total: 69 proofs.**

> Note: RESEARCH_INDEX.md states 70; the discrepancy is one row that is likely double-counted across `multi-agent/` subfolders. We treat 69 as the working count for this exercise.
