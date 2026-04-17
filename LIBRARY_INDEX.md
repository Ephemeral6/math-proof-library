# Library Proof Index (B/C-Class)

> 基础引理和工具箱：经典结果、标准教科书定理、可被 research 级证明引用的基础设施

## Optimization

### Convergence
| Theorem | Source | Class | Date | Path |
|---------|--------|-------|------|------|
| Frank-Wolfe O(1/k) convergence rate | Jaggi 2013 (ICML) | B | 2026-04-11 | proofs/library/optimization/convergence/frank-wolfe-convergence-rate/ |
| Nesterov AGD O(1/k^2) convergence | Nesterov 1983 | B | 2026-04-11 | proofs/library/optimization/convergence/nesterov-accelerated-gradient-convergence/ |
| GD Polyak-Lojasiewicz linear convergence | Karimi et al. 2016 | B | 2026-04-11 | proofs/library/optimization/convergence/gd-polyak-lojasiewicz-linear-rate/ |
| GD strongly convex linear convergence | Nesterov 2004 | C | 2026-04-11 | proofs/library/optimization/convergence/gd-strongly-convex-linear-convergence/ |
| GD non-convex stationary point convergence | Nesterov 2004 | C | 2026-04-11 | proofs/library/optimization/convergence/gd-nonconvex-stationary-point/ |
| Coordinate descent O(nL/e) rate | Nesterov 2012 | B | 2026-04-11 | proofs/library/optimization/convergence/coordinate-descent-smooth-convex/ |
| OGD regret bound with lower bound | Zinkevich 2003 | B | 2026-04-09 | proofs/library/optimization/convergence/ogd-regret-bound/ |
| Bellman optimality contraction | Bellman 1957 | C | 2026-04-12 | proofs/library/optimization/convergence/bellman-optimality-contraction/ |
| Gradient flow KL convergence rates | Bolte et al. 2007 | B | 2026-04-12 | proofs/library/optimization/convergence/gradient-flow-kl-convergence/ |
| Policy gradient theorem | Sutton et al. 1999 | B | 2026-04-12 | proofs/library/optimization/convergence/policy-gradient-theorem/ |
| Proximal point convergence (monotone) | Rockafellar 1976 | B | 2026-04-12 | proofs/library/optimization/convergence/proximal-point-monotone-operators/ |

### Stochastic
| Theorem | Source | Class | Date | Path |
|---------|--------|-------|------|------|
| SGD O(1/sqrt(T)) convex convergence | Bubeck 2015 | C | 2026-04-12 | proofs/library/optimization/stochastic/sgd-convex-convergence-rate/ |
| SVRG linear convergence (ABC) | Johnson & Zhang 2013 | B | 2026-04-08 | proofs/library/optimization/stochastic/svrg-linear-convergence-abc-framework/ |

### Adaptive Methods
| Theorem | Source | Class | Date | Path |
|---------|--------|-------|------|------|
| AdaGrad sparse gradient regret | Duchi et al. 2011 | B | 2026-04-12 | proofs/library/optimization/adaptive-methods/adagrad-sparse-regret/ |

### Lower Bounds
| Theorem | Source | Class | Date | Path |
|---------|--------|-------|------|------|
| Nesterov first-order lower bound | Nesterov 2004 | B | 2026-04-11 | proofs/library/optimization/lower-bounds/nesterov-first-order-lower-bound/ |

### Mirror Descent
| Theorem | Source | Class | Date | Path |
|---------|--------|-------|------|------|
| Mirror Descent online regret bound | Standard | B | 2026-04-07 | proofs/library/optimization/mirror-descent/mirror-descent-online-regret-bound/ |

## Learning Theory

### Generalization
| Theorem | Source | Class | Date | Path |
|---------|--------|-------|------|------|
| Online-to-batch conversion | Cesa-Bianchi et al. 2004 | B | 2026-04-12 | proofs/library/learning-theory/generalization/online-to-batch-conversion/ |
| FTRL/Hedge O(√(T ln d)) regret bound | Vovk 1990 / Freund & Schapire 1997 | B | 2026-04-15 | proofs/library/learning-theory/generalization/ftrl-hedge-regret-bound/ |

### PAC
| Theorem | Source | Class | Date | Path |
|---------|--------|-------|------|------|
| McAllester PAC-Bayes bound | McAllester 1999 | B | 2026-04-08 | proofs/library/learning-theory/pac/mcallester-pac-bayes-bound/ |
| Sauer-Shelah Lemma | Sauer 1972 | B | 2026-04-11 | proofs/library/learning-theory/pac/sauer-shelah-lemma/ |
| VC dimension generalization bound | Vapnik & Chervonenkis 1971 | B | 2026-04-12 | proofs/library/learning-theory/pac/vc-dimension-generalization-bound/ |

### Rademacher
| Theorem | Source | Class | Date | Path |
|---------|--------|-------|------|------|
| Rademacher generalization bound | Bartlett & Mendelson 2002 | B | 2026-04-11 | proofs/library/learning-theory/rademacher/rademacher-generalization-bound/ |
| Rademacher complexity of linear classifiers | Bartlett & Mendelson 2002 | B | 2026-04-12 | proofs/library/learning-theory/rademacher/rademacher-linear-classifiers/ |

## Convex Analysis

### Duality
| Theorem | Source | Class | Date | Path |
|---------|--------|-------|------|------|
| Fenchel smoothness-strong convexity duality | Rockafellar 1970 | B | 2026-04-12 | proofs/library/convex-analysis/duality/fenchel-smoothness-strong-convexity/ |
| Strong duality via Slater's condition | Slater 1950 | C | 2026-04-11 | proofs/library/convex-analysis/duality/slater-strong-duality/ |

### Subgradient / Proximal
| Theorem | Source | Class | Date | Path |
|---------|--------|-------|------|------|
| ADMM ergodic O(1/K) convergence | He & Yuan 2012 | B | 2026-04-11 | proofs/library/convex-analysis/subgradient/admm-ergodic-convergence-full-rank/ |
| Extragradient O(1/K) convex-concave minimax | Korpelevich 1976 | B | 2026-04-09 | proofs/library/convex-analysis/subgradient/extragradient-convex-concave-minimax/ |
| Moreau envelope smoothness | Moreau 1965 | B | 2026-04-11 | proofs/library/convex-analysis/subgradient/moreau-envelope-smoothness/ |
| Proximal gradient O(1/T) convergence | Standard | C | 2026-04-08 | proofs/library/convex-analysis/subgradient/proximal-gradient-convergence-rate/ |
| Proximal point convergence (monotone) | Rockafellar 1976 | B | 2026-04-12 | proofs/library/convex-analysis/subgradient/proximal-point-convergence-monotone/ |
| Douglas-Rachford splitting convergence | Lions & Mercier 1979 | B | 2026-04-15 | proofs/library/convex-analysis/subgradient/douglas-rachford-splitting-convergence/ |

## Statistics

### Concentration
| Theorem | Source | Class | Date | Path |
|---------|--------|-------|------|------|
| Sub-Gaussian covariance concentration | Vershynin 2018 | B | 2026-04-02 | proofs/library/statistics/concentration/sub-gaussian-covariance-concentration/ |
| Matrix Bernstein inequality | Tropp 2012 | B | 2026-04-09 | proofs/library/statistics/concentration/matrix-bernstein-inequality/ |
| McDiarmid bounded differences | McDiarmid 1989 | B | 2026-04-09 | proofs/library/statistics/concentration/mcdiarmid-bounded-differences-inequality/ |
| Hoeffding's inequality | Hoeffding 1963 | C | 2026-04-11 | proofs/library/statistics/concentration/hoeffding-inequality/ |
| Bernstein's inequality | Bernstein 1924 | C | 2026-04-12 | proofs/library/statistics/concentration/bernstein-inequality/ |
| Sub-Gaussian maximal inequality | Vershynin 2018 | C | 2026-04-12 | proofs/library/statistics/concentration/sub-gaussian-maximal-inequality/ |

### High-Dimensional
| Theorem | Source | Class | Date | Path |
|---------|--------|-------|------|------|
| RIP sparse recovery guarantee | Candes & Tao 2005 | B | 2026-04-11 | proofs/library/statistics/high-dimensional/rip-sparse-recovery/ |

## Linear Algebra
| Theorem | Source | Class | Date | Path |
|---------|--------|-------|------|------|
| Johnson-Lindenstrauss Lemma | JL 1984 / Dasgupta 2003 | B | 2026-04-09 | proofs/library/linear-algebra/johnson-lindenstrauss-lemma/ |

## Probability
| Theorem | Source | Class | Date | Path |
|---------|--------|-------|------|------|
| Langevin KL convergence (log-Sobolev) | MCMC theory | B | 2026-04-05 | proofs/library/probability/langevin-kl-convergence-log-sobolev/ |
| Azuma-Hoeffding inequality | Azuma 1967 | C | 2026-04-11 | proofs/library/probability/azuma-hoeffding-inequality/ |
| MLSI implies exponential KL mixing | Diaconis & Saloff-Coste 1996 | B | 2026-04-15 | proofs/library/probability/mlsi-kl-mixing-time/ |

---

## Statistics
- Library proofs: 42 (B: 32, C: 10)
- Last updated: 2026-04-15
