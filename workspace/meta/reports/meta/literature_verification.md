# 文献验证报告 (Literature Verification)

Generated: 2026-04-13

对所有有 PDF 的 PAPER 类证明，将 problem.md / proof.md 与论文原文对比。

## 评级标准

| 评级 | 含义 |
|------|------|
| **MATCH** | 结论一致，关键步骤对齐（允许不同证明方法） |
| **DIFFER** | 结论不同 |
| **STRONGER** | agent 证了更强的结果 |
| **WEAKER** | agent 证了更弱的结果 |
| **PARTIAL** | 结论一致但 agent 跳了某些关键步骤，或只证了部分 |

---

## 汇总表

| # | 定理 | 论文 PDF | 评级 | 说明 |
|---|------|----------|------|------|
| 1 | Adam Non-Convex Convergence | defossez-2022 | **MATCH** | 定理陈述一致，证明技巧相同 |
| 2 | AdaGrad Sparse Regret | duchi-2011 | **MATCH** | 标准 OGD 分析路线，sqrt(2) 常数已注明 |
| 3 | SAM Convergence | foret-2021 | **STRONGER** | 论文只证 PAC-Bayes 泛化界，proof 额外推导了收敛率 |
| 4 | Lookahead Optimizer | zhang-2019 | **MATCH** | 二次函数收敛率和方差缩减均吻合 |
| 5 | Heavy Ball Instability | lessard-2016 | **MATCH** | 论文用 IQC/SDP 框架，proof 用显式反例，结论相同 |
| 6 | GD PL Linear Rate | karimi-2016 | **MATCH** | 定理和证明逐步一致 |
| 7 | Frank-Wolfe Convergence | jaggi-2013 | **MATCH** | O(1/t) 率和下降递推一致 |
| 8 | Gradient Flow KL | bolte-2007 | **MATCH** | KL 不等式框架下的收敛三分类一致 |
| 9 | SPS-SGD Convergence | loizou-2021 | **MATCH** | O(1/T) 插值条件下凸收敛一致 |
| 10 | SPIDER Non-Convex | fang-2018 | **MATCH** | O(n+sqrt(n)/ε²) 梯度复杂度一致 |
| 11 | SARAH/SPIDER Variance Reduction | nguyen-2017 | **MATCH** | 非凸有限和复杂度一致（技术路线略不同） |
| 12 | Momentum SGD Interpolation Convergence | vaswani-2019 | **WEAKER** | proof 用 Polyak 动量得 1-O(1/κ)，论文用 Nesterov 得加速率 |
| 13 | Clipped SGD Heavy-Tail | zhang-2020 | **DIFFER** | PDF 论 relaxed smoothness 下 clipping，proof 论 heavy-tail 噪声下 clipping，场景不同 |
| 14 | NTK Gram Matrix PD | du-2019 | **MATCH** | 正定性条件和邻接论证一致 |
| 15 | NTK Infinite-Width Convergence | du-2019 | **PARTIAL** | proof 只证了核集中一步，未覆盖论文的完整 GD 收敛结论 |
| 16 | SGD Uniform Stability | hardt-2016 | **MATCH** | Theorem 3.8 的递推耦合论证完全一致 |
| 17 | Implicit Bias GD Max Margin | soudry-2018 | **MATCH** | 方向收敛到最大间距解，KKT 论证一致 |
| 18 | ReLU Universal Approximation | yarotsky-2017 | **WEAKER** | proof 证浅层网络 O((L/ε)^d)，论文主贡献是深层网络指数更优 |
| 19 | SVRG Linear Convergence | johnson-2013 (via nguyen-2017) | **MATCH** | ABC 框架下线性收敛率一致 |
| 20 | ADMM Ergodic Convergence | he-2012 | **WEAKER** | proof 证 O(1/K) 遍历率，PDF 证线性收敛（假设更强） |
| 21 | Matrix Bernstein Inequality | tropp-2012 | **MATCH** | Theorem 1.4 对应，Laplace 变换+Lieb 定理路线一致 |
| 22 | RIP Sparse Recovery | candes-2005 | **STRONGER** | proof 用 δ_{2s}<√2-1 更锐条件（来自 Candes 2008），比 2005 论文更强 |
| 23 | Momentum SGD Interpolation (Contraction) | vaswani-2019 | **PARTIAL** | proof 用 Polyak 动量，论文用 Nesterov 动量，算法不同 |
| 24 | NPG Softmax Tabular | agarwal-2021 | **MATCH** | 定理陈述与 NPG mirror descent 分析一致（PDF 已修正） |

---

## 详细验证

### 1. Adam Non-Convex Convergence → MATCH

**论文**: Defossez, Bottou, Bach, Usunier (2022), "A Simple Convergence Proof of Adam and Adagrad", TMLR

- **定理陈述**: proof 与论文 Theorem 2 一致——β₁²≤β₂ 条件下 Adam 非凸收敛 O(d log T / √T)
- **关键步骤**: Jensen 不等式处理二阶矩、内积极化分解、EMA 比率和 ≤ log(T) 引理、步长调优——与论文 Section 5 一致
- **常数差异**: proof 中 √2 常数与论文略有出入，渐近率相同

### 2. AdaGrad Sparse Regret → MATCH

**论文**: Duchi, Hazan, Singer (2011), "Adaptive Subgradient Methods", JMLR

- **定理陈述**: 坐标级 regret bound Σᵢ√(Σₜ g²ₜ,ᵢ) 一致
- **关键步骤**: OGD 分解 → Abel 求和 → 关键引理 Σ(aₜ/√Sₜ) ≤ 2√Sₜ → η = D/√2 优化
- **注**: proof 正确区分了 OGD (常数√2) 和 FTRL (常数1) 的差异

### 3. SAM Convergence → STRONGER

**论文**: Foret et al. (2021), "Sharpness-Aware Minimization", ICLR 2021

- **定理陈述**: proof 推导了 min‖∇f^SAM‖² ≤ 16L(f₀-f*)/T + 12L²ρ²，但**论文中没有此收敛定理**
- **论文贡献**: PAC-Bayesian 泛化界（Theorem 1/2），不是优化收敛率
- **结论**: proof 独立推导了一个论文未证的收敛结果，数学上正确且与 SAM 算法一致

### 4. Lookahead Optimizer → MATCH

**论文**: Zhang et al. (2019), "Lookahead Optimizer", NeurIPS 2019

- **定理陈述**: 二次函数上 ρ = 1 - α(1-(1-ημ)ᵏ) 与论文 Proposition 1 一致
- **方差缩减**: α²k 因子与论文 Proposition 2 / Lemma 1 一致

### 5. Heavy Ball Instability → MATCH

**论文**: Lessard, Recht, Packard (2016), "Analysis and Design of Optimization Algorithms via IQC", SIAM

- **定理陈述**: 二次函数最优率 (√κ-1)/(√κ+1) 一致；一般光滑强凸函数上不稳定性一致
- **技巧差异**: 论文用 SDP 可行性失败；proof 构造了 κ=100 的显式 period-4 极限环——更直观

### 6. GD PL Linear Rate → MATCH

**论文**: Karimi et al. (2016), "Linear Convergence of Gradient and Proximal-Gradient Methods Under PL", ECML

- **定理陈述**: Theorem 1 完全一致——f(xₖ)-f* ≤ (1-μ/L)ᵏ(f₀-f*)
- **证明**: 4 步推导逐行一致，最干净的匹配之一

### 7. Frank-Wolfe Convergence → MATCH

**论文**: Jaggi (2013), "Revisiting Frank-Wolfe", ICML

- **定理陈述**: γₜ=2/(t+2) 步长下 O(LD²/(t+2)) 率与 Theorem 1 一致
- **关键步骤**: 下降引理 → 线性极小化 → 递推 → 归纳法验证

### 8. Gradient Flow KL → MATCH

**论文**: Bolte, Daniilidis, Lewis (2007), "Characterizations of Lojasiewicz Inequalities"

- **定理陈述**: KL 不等式下梯度流收敛三分类（有限时间 / 指数 / 多项式）一致
- **关键步骤**: 能量耗散 → KL 下界 → 微分不等式 → 比较 ODE

### 9. SPS-SGD Convergence → MATCH

**论文**: Loizou et al. (2021), "Stochastic Polyak Step-size for SGD", AISTATS

- **定理陈述**: 凸+插值条件下 O(1/T) 收敛与 Theorem 3.4 / Corollary 3.2 一致
- **常数差异**: 2cL vs 论文公式中的 1/(αK)，proof 备注中已解释

### 10. SPIDER Non-Convex → MATCH

**论文**: Fang et al. (2018), "SPIDER", NeurIPS 2018

- **定理陈述**: O(n + √n·LΔ/ε²) 梯度复杂度与 Theorem 2 一致
- **关键步骤**: SPIDER 递归方差追踪 + 极化恒等式（非 Young 不等式）——正确识别了论文关键创新

### 11. SARAH/SPIDER Variance Reduction → MATCH

**论文**: Nguyen et al. (2017), "SARAH", ICML 2017 + Fang et al. (2018)

- **定理陈述**: O(n + √n/ε²) 非凸有限和复杂度一致
- **技巧差异**: proof 用 Young 不等式 + 自约束论证，论文用极化——同一结论

### 12. Momentum SGD Interpolation Convergence → WEAKER

**论文**: Vaswani et al. (2019), "Fast and Faster Convergence of SGD"

- **定理陈述**: proof 证 Polyak 动量 1-O(1/κ) 率；论文证 Nesterov 动量 1-O(1/√κ) 加速率
- **差异**: 算法不同（Polyak vs Nesterov），率更弱，problem.md 标注为 "conjecture"

### 13. Clipped SGD Heavy-Tail → DIFFER

**论文**: Zhang et al. (2020), arXiv:1905.11881, "Why Gradient Clipping Accelerates Training"

- **proof 主题**: 标准 L-光滑 + heavy-tail p 阶矩噪声下 clipped SGD 收敛
- **论文主题**: (L₀,L₁)-relaxed smoothness 下 gradient clipping 的效果
- **结论**: 讨论的是 gradient clipping 的**不同方面**，proof 的正确参考应为 Gorbunov et al. (2020)

### 14. NTK Gram Matrix PD → MATCH

**论文**: Du et al. (2019), "Gradient Descent Provably Optimizes Over-parameterized Neural Networks"

- **定理陈述**: Theorem 3.1 一致——单位范数输入 xᵢ≠±xⱼ 时 NTK Gram 矩阵正定
- **关键步骤**: 超平面排列邻接论证一致

### 15. NTK Infinite-Width Convergence → PARTIAL

**论文**: Du et al. (2019), 同上

- **proof 范围**: 只证了经验 NTK → 无穷宽极限的集中不等式 ‖Θ̂ₘ - Θ∞‖ ≤ O(n√(log n/m))
- **论文范围**: 完整的 GD 全局收敛定理（Theorem 4.1），核集中只是一个引理
- **结论**: proof 只覆盖了论文的一个子步骤

### 16. SGD Uniform Stability → MATCH

**论文**: Hardt, Recht, Singer (2016), "Train Faster, Generalize Better", ICML

- **定理陈述**: Theorem 3.8 完全一致——ε_stab ≤ (2L²/n)Σαₜ
- **关键步骤**: 邻近数据集上的递推耦合论证完全一致

### 17. Implicit Bias GD Max Margin → MATCH

**论文**: Soudry et al. (2018), "The Implicit Bias of Gradient Descent on Separable Data", JMLR

- **定理陈述**: Theorem 3 一致——wₜ/‖wₜ‖ → w*/‖w*‖（L2 最大间距方向）
- **关键步骤**: 无有限临界点 → 间距发散 → 对数增长 → KKT 条件

### 18. ReLU Universal Approximation → WEAKER

**论文**: Yarotsky (2017), "Error Bounds for Approximations with Deep ReLU Networks"

- **proof 结论**: 浅层 ReLU 网络 N=O((L/ε)^d) 逼近 Lipschitz 函数
- **论文贡献**: **深层**网络 O(ε^{-d/n} polylog(1/ε)) 逼近 W^{n,∞} 函数——指数级更优
- **差异**: proof 证的是论文提到的 baseline 结果，不是论文的主要贡献

### 19. SVRG Linear Convergence → MATCH

**论文**: Johnson & Zhang (2013) via Nguyen et al. (2017)

- **定理陈述**: SVRG 每 epoch 收缩 < 1/2（proof 得 7/18）一致
- **技巧**: proof 用 ABC/Lyapunov 框架，原论文用直接方差界——同一结论

### 20. ADMM Ergodic Convergence → WEAKER

**论文**: He & Yuan (2012) / Hong & Luo (2012), arXiv:1208.3922

- **proof 结论**: O(1/K) 遍历收敛率（弱假设：鞍点存在 + B 满秩）
- **PDF 结论**: 线性收敛（强假设：多面体结构 + 强凸 + 满秩）
- **注**: proof 的正确参考是 He & Yuan 2012 "On the O(1/n) convergence rate"，不是此 PDF

### 21. Matrix Bernstein Inequality → MATCH

**论文**: Tropp (2012), "User-Friendly Tail Bounds for Sums of Random Matrices"

- **定理陈述**: Theorem 1.4 一致——P(‖ΣXᵢ‖ ≥ t) ≤ 2d exp(-t²/(2σ²+2Lt/3))
- **关键步骤**: 矩阵 Laplace 变换 + Lieb 凹性定理 + CGF 次可加性

### 22. RIP Sparse Recovery → STRONGER

**论文**: Candes & Tao (2005), "Decoding by Linear Programming"

- **proof 条件**: δ₂ₛ < √2-1（来自 Candes 2008 更锐结果）
- **论文条件**: δ_S + θ_{S,S} + θ_{S,2S} < 1（更弱条件）
- **结论**: proof 用了论文之后（2008）的更强结果，对偶证书 → 块分解技术

### 23. Momentum SGD Interpolation (Contraction) → PARTIAL

**论文**: Vaswani et al. (2019), 同 #12

- **差异**: proof 分析 Polyak 动量，论文分析 Nesterov 动量——算法本质不同
- **Lyapunov 函数**: ‖eₜ‖² + γ²‖vₜ‖² 更接近 Liu & Belkin (2020) 风格

### 24. NPG Softmax Tabular → MATCH

**论文**: Agarwal, Kakade, Lee, Mahajan (2021), arXiv:1908.00261

- **定理陈述**: NPG softmax 策略参数化下 O(1/K) → 线性收敛一致
- **注**: 原始下载的 PDF 是错误的物理论文(arXiv:1903.08668)，已修正为正确的 RL 论文

---

## 统计汇总

| 评级 | 数量 | 占比 |
|------|------|------|
| **MATCH** | 16 | 66.7% |
| **STRONGER** | 2 | 8.3% |
| **WEAKER** | 3 | 12.5% |
| **PARTIAL** | 2 | 8.3% |
| **DIFFER** | 1 | 4.2% |
| **总计** | **24** | 100% |

### 关键发现

1. **16/24 MATCH (66.7%)**: 大多数证明与论文原文结论和方法一致
2. **2 STRONGER**: SAM 收敛（论文只证泛化，proof 额外推导收敛率）和 RIP（proof 用了 2008 更锐条件）
3. **3 WEAKER**:
   - Momentum SGD Interpolation: 非加速率 vs 论文加速率
   - ReLU Approximation: 浅层 baseline vs 论文深层主结果
   - ADMM: O(1/K) 遍历 vs PDF 中线性收敛（但 proof 的参考来源不同）
4. **2 PARTIAL**:
   - NTK Infinite-Width: 只证了核集中一步，缺完整 GD 收敛
   - Momentum SGD Contraction: 分析的是不同算法（Polyak vs Nesterov 动量）
5. **1 DIFFER**: Clipped SGD 的 proof 和 PDF 讨论的是 gradient clipping 的不同方面

### PDF 匹配质量

- 22/24 PDF 与对应证明主题匹配
- 1 个 PDF 初始下载错误（NPG → 物理论文），已修正
- 1 个 PDF 主题不对应（Clipped SGD: relaxed smoothness ≠ heavy-tail noise）

### 建议

1. **Clipped SGD**: 补充下载 Gorbunov et al. (2020, arXiv:2012.02039) 作为正确参考
2. **ADMM**: 补充下载 He & Yuan (2012) "On the O(1/n) convergence rate of the Douglas-Rachford alternating direction method" 作为直接参考
3. **NTK Infinite-Width**: 考虑补全 GD 收敛定理的完整证明
4. **ReLU Universal Approximation**: 考虑补充深层网络的量化结果以匹配 Yarotsky 2017 主贡献
