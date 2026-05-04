# 证明库分类 (Proof Classification)

Generated: 2026-04-13

## 分类标准

| 类别 | 标准 | 后续策略 |
|------|------|----------|
| **A 类** | 2015年后研究论文，证明技巧有新意，非教科书 | 优先验证、优先出题 |
| **B 类** | 经典论文但证明有深度，或重要基础设施定理 | 保留但不优先 |
| **C 类** | 本科教科书标准结果，证明是标准套路 | 基础层，不再投入资源 |

---

## 完整分类表

| # | 定理名 | 分类 | 理由 |
|---|--------|------|------|
| 1 | Fenchel Smoothness-Strong Convexity Duality | **B** | 经典凸分析基石，证明非平凡（6 引理），但属 1970 年代结果 |
| 2 | Slater's Condition Strong Duality | **C** | Boyd & Vandenberghe 教科书标准内容，每门凸优化课都教 |
| 3 | ADMM Ergodic O(1/K) Convergence | **B** | He & Yuan 2012 变分不等式框架，ADMM 收敛率理论基础 |
| 4 | Extragradient Convex-Concave Minimax | **B** | Korpelevich 1976 经典方法，但 minimax 分析有深度且近年热门 |
| 5 | Moreau Envelope Smoothness | **B** | 1965 年结果但近端算法核心工具，证明精巧 |
| 6 | Proximal Gradient Convergence Rate | **C** | 标准复合优化收敛分析，教科书套路 |
| 7 | Proximal Point Convergence (Monotone) | **B** | Rockafellar 1976 基础迭代，单调算子理论基石 |
| 8 | Denoising Score Matching Equivalence | **A** | Vincent 2011，score-based 生成模型理论基础，DDPM 前置 |
| 9 | Implicit Bias of GD → Max Margin | **A** | Soudry et al. 2018 JMLR，深度学习隐式正则化开创性结果 |
| 10 | NTK Gram Matrix Positive Definiteness | **A** | Du et al. 2019 ICML，过参数化 NN 全局收敛的关键引理 |
| 11 | NTK Infinite-Width Convergence Rate | **A** | Du/Arora 2019，NTK 理论定量收敛界 |
| 12 | Online-to-Batch Conversion | **B** | Cesa-Bianchi 2004，连接 online regret 与统计保证的桥梁定理 |
| 13 | ReLU Universal Approximation (Quantitative) | **A** | Yarotsky 2017，量化逼近误差与网络规模关系 |
| 14 | Transformer Attention Lipschitz Bound | **A** | 2020-2021，Transformer 理论分析前沿 |
| 15 | McAllester PAC-Bayes Bound | **B** | McAllester 1999 开创性结果，PAC-Bayes 理论基础，证明有巧妙的 grid+union bound |
| 16 | Sauer-Shelah Lemma | **B** | 1972 经典，但证明需要精巧的组合归纳，非平凡 |
| 17 | VC Dimension Generalization Bound | **B** | VC 理论核心，对称化+覆盖数论证有深度 |
| 18 | Rademacher Generalization Bound | **B** | Bartlett & Mendelson 2002，现代泛化理论基础框架 |
| 19 | Rademacher Complexity of Linear Classifiers | **B** | 应用 Rademacher 框架的重要实例，Cauchy-Schwarz+Jensen 技巧 |
| 20 | SGD Uniform Stability Generalization | **A** | Hardt et al. 2016 ICML，首次严格连接 SGD 速度与泛化 |
| 21 | Johnson-Lindenstrauss Lemma | **B** | JL 1984/Dasgupta 2003，降维理论基石，χ² 集中论证有技术性 |
| 22 | AdaGrad Sparse Regret Bound | **B** | Duchi et al. 2011 JMLR，自适应学习率开山之作，但已是标准结果 |
| 23 | Adam Non-Convex Convergence | **A** | Defossez et al. 2022 TMLR，首个简洁的 Adam 非凸收敛证明 |
| 24 | Bellman Optimality Contraction | **C** | Bellman 1957，RL/MDP 入门教科书内容 |
| 25 | Coordinate Descent (Smooth Convex) | **B** | Nesterov 2012，坐标级 Lipschitz 常数分析有技巧性 |
| 26 | Entropy-Regularized Value Iteration | **A** | 2017-2022 多源，SAC/soft Q-learning 理论基础，RL+优化交叉 |
| 27 | Frank-Wolfe Convergence Rate | **B** | Jaggi 2013 ICML 复兴经典，projection-free 优化重要参考 |
| 28 | GD Non-Convex Stationary Point | **C** | Nesterov 2004 第一章，非凸优化最基础的结果 |
| 29 | GD with PL Condition Linear Rate | **B** | Karimi et al. 2016，PL 条件统一视角，连接凸/非凸理论 |
| 30 | GD Strongly Convex Linear Convergence | **C** | Nesterov 教科书定理 2.1.15，优化课第一个收敛定理 |
| 31 | Gradient Flow KL Convergence | **B** | Bolte et al. 2007，KL 不等式框架，收敛三分类精巧 |
| 32 | Heavy Ball Instability | **A** | Lessard et al. 2016，用显式反例推翻直觉——动量可能发散 |
| 33 | Lookahead Optimizer Convergence | **A** | Zhang et al. 2019 NeurIPS，现代 optimizer wrapper 分析 |
| 34 | Nesterov Accelerated Gradient O(1/k²) | **B** | Nesterov 1983 经典，证明精巧但已是研究生标准课程内容 |
| 35 | NPG Softmax Tabular Convergence | **A** | Agarwal/Cen 2021-2022，NPG 作为 mirror descent 的 RL 理论 |
| 36 | OGD Regret Bound O(√T) | **B** | Zinkevich 2003，在线学习基础但含匹配下界 |
| 37 | Policy Gradient Theorem | **B** | Sutton et al. 1999 NeurIPS，RL 理论基石，推导有深度 |
| 38 | Proximal Point (Monotone Operators) | **B** | Rockafellar 1976，与 #7 重复但归入优化分支 |
| 39 | SAM Convergence to Flat Minima | **A** | Foret et al. 2021 ICLR，agent 独立推导了论文未证的收敛率 |
| 40 | SGD Last-Iterate (Averaged Baseline) | **A** | Koren & Segal COLT 2020 Open Problem，前沿研究 |
| 41 | Nesterov First-Order Lower Bound | **B** | Nesterov 2004，信息论下界，Krylov 子空间论证非平凡 |
| 42 | Mirror Descent Online Regret | **B** | Shalev-Shwartz/Hazan，Bregman 散度框架，在线学习基础 |
| 43 | Clipped SGD Heavy-Tail Convergence | **A** | Zhang/Gorbunov 2020，重尾噪声下 clipping 的非凸收敛 |
| 44 | Momentum SGD Interpolation (Contraction) | **A** | Vaswani/Liu 2019-2020，插值条件下 Polyak 动量线性收敛 |
| 45 | Momentum SGD Interpolation Convergence | **A** | 同上，方差缩减视角分析动量 SGD |
| 46 | Momentum SGD Interpolation Linear Convergence | **A** | Loizou/Vaswani 2019-2021，PL+Lyapunov 联合分析 |
| 47 | Momentum SGD Spectral Analysis Convergence | **A** | 2019-2021，谱分析路线，Kronecker 积算子方法，939 行最长证明 |
| 48 | SGD Convex Convergence Rate O(1/√T) | **C** | 经典 SGD 收敛，Bubeck survey 标准内容 |
| 49 | SGD PL+Interpolation Averaging | **A** | 多源综合，两阶段 SGD 分析，标记为 conjecture |
| 50 | SPIDER Non-Convex Gradient Complexity | **A** | Fang et al. 2018 NeurIPS，非凸有限和最优梯度复杂度 |
| 51 | SPIDER/SARAH Variance Reduction | **A** | Fang 2018/Nguyen 2017，递归方差缩减的非凸分析 |
| 52 | SPS-SGD Convergence Rate | **A** | Loizou et al. 2021 AISTATS，自适应 Polyak 步长分析 |
| 53 | SVRG Linear Convergence (ABC Framework) | **B** | Johnson & Zhang 2013，方差缩减开山之作，ABC 框架有技巧 |
| 54 | Azuma-Hoeffding Inequality | **C** | Azuma 1967，鞅集中不等式教科书标准内容 |
| 55 | Langevin KL Convergence (Log-Sobolev) | **B** | 基础 MCMC 理论，log-Sobolev 不等式技巧有深度 |
| 56 | Bernstein's Inequality | **C** | Bernstein 1924，集中不等式教科书标准内容 |
| 57 | Hoeffding's Inequality | **C** | Hoeffding 1963，概率论教科书最基础的集中不等式 |
| 58 | Matrix Bernstein Inequality | **B** | Tropp 2012，矩阵集中不等式，Lieb 凹性定理技巧精巧 |
| 59 | McDiarmid's Bounded Differences | **B** | McDiarmid 1989，Lipschitz 集中，鞅方法有技术性 |
| 60 | Sub-Gaussian Covariance Concentration | **B** | Vershynin 2018，高维统计核心工具 |
| 61 | Sub-Gaussian Maximal Inequality | **C** | Vershynin 2018 教科书，union bound + 集中标准组合 |
| 62 | Double Descent Interpolation Threshold | **A** | ~2019 现象，Belkin/Hastie 无脊回归相变分析 |
| 63 | RIP Sparse Recovery | **B** | Candes & Tao 2005，压缩感知基石，δ₂ₛ 条件精细 |

---

## 统计汇总

| 类别 | 数量 | 占比 |
|------|------|------|
| **A 类** — 高价值 | **24** | 38.1% |
| **B 类** — 中等价值 | **29** | 46.0% |
| **C 类** — 低价值 | **10** | 15.9% |
| 总计 | **63** | 100% |

---

## A 类清单（后续资源优先投入）

| # | 定理名 | 来源 | 年份 | 特色 |
|---|--------|------|------|------|
| 8 | Denoising Score Matching Equivalence | Vincent 2011 | 2011 | Score-based 生成模型理论根基 |
| 9 | Implicit Bias GD → Max Margin | Soudry et al. 2018 | 2018 | 深度学习隐式正则化开山 |
| 10 | NTK Gram Matrix PD | Du et al. 2019 | 2019 | 过参数化全局收敛关键引理 |
| 11 | NTK Infinite-Width Convergence | Du/Arora 2019 | 2019 | NTK 定量集中界 |
| 13 | ReLU Universal Approximation | Yarotsky 2017 | 2017 | 量化逼近理论 |
| 14 | Transformer Attention Lipschitz | Kim/Vuckovic 2020-2021 | 2021 | Transformer 理论前沿 |
| 20 | SGD Uniform Stability | Hardt et al. 2016 | 2016 | 优化速度↔泛化 首次严格连接 |
| 23 | Adam Non-Convex Convergence | Defossez et al. 2022 | 2022 | 首个简洁 Adam 非凸证明 |
| 26 | Entropy-Regularized Value Iteration | Geist/Cen 2019-2022 | 2022 | SAC/soft RL 理论基础 |
| 32 | Heavy Ball Instability | Lessard et al. 2016 | 2016 | 反直觉：动量可能发散 |
| 33 | Lookahead Optimizer | Zhang et al. 2019 | 2019 | 现代 optimizer wrapper |
| 35 | NPG Softmax Tabular | Agarwal/Cen 2021-2022 | 2022 | NPG as mirror descent in RL |
| 39 | SAM Convergence | Foret et al. 2021 | 2021 | Agent 独立推导了论文未证的结果 |
| 40 | SGD Last-Iterate | Koren & Segal 2020 | 2020 | COLT Open Problem |
| 43 | Clipped SGD Heavy-Tail | Zhang/Gorbunov 2020 | 2020 | 重尾噪声前沿 |
| 44 | Momentum SGD Interpolation (Contraction) | Vaswani/Liu 2019-2020 | 2020 | 插值+动量线性收敛 |
| 45 | Momentum SGD Interpolation Convergence | Vaswani/Liu 2019-2020 | 2020 | 方差缩减视角 |
| 46 | Momentum SGD Interpolation Linear | Loizou/Vaswani 2021 | 2021 | PL+Lyapunov 联合 |
| 47 | Momentum SGD Spectral Analysis | 2019-2021 | 2021 | 谱分析+Kronecker，939 行 |
| 49 | SGD PL+Interpolation Averaging | 综合多源 | — | 两阶段分析，conjecture 级 |
| 50 | SPIDER Non-Convex | Fang et al. 2018 | 2018 | 非凸最优梯度复杂度 |
| 51 | SPIDER/SARAH Variance Reduction | Fang/Nguyen 2017-2018 | 2018 | 递归方差缩减非凸 |
| 52 | SPS-SGD Convergence | Loizou et al. 2021 | 2021 | 自适应 Polyak 步长 |
| 62 | Double Descent | Belkin/Hastie ~2019 | 2019 | 插值阈值相变现象 |

## C 类清单（基础层，不再投入）

| # | 定理名 | 理由 |
|---|--------|------|
| 2 | Slater Strong Duality | 凸优化教科书标准 |
| 6 | Proximal Gradient Convergence | 复合优化标准分析 |
| 24 | Bellman Optimality Contraction | RL/MDP 入门内容 |
| 28 | GD Non-Convex Stationary Point | Nesterov 教科书第一章 |
| 30 | GD Strongly Convex Linear Convergence | 优化课第一个收敛定理 |
| 48 | SGD Convex O(1/√T) | 经典 SGD 入门结果 |
| 54 | Azuma-Hoeffding Inequality | 鞅集中教科书标准 |
| 56 | Bernstein's Inequality | 集中不等式教科书标准 |
| 57 | Hoeffding's Inequality | 最基础的集中不等式 |
| 61 | Sub-Gaussian Maximal Inequality | Union bound + 集中标准组合 |
