# 证明技巧汇总报告

> 基于 27 道已完成证明的 notes.md 和 problem.md 自动生成  
> 生成日期：2026-04-11

---

## 第一部分：证明技巧词典

扫描所有 notes.md 的 Proof technique 和 Key steps，提取核心数学工具，按使用频率排序。

| # | 技巧名称 | 使用次数 | 使用的证明 |
|---|---------|---------|-----------|
| 1 | **Telescoping Sum（望远镜求和）** | 13 | SPS-SGD, Adam, Mirror Descent, OGD, Proximal Gradient, ADMM-FR, ADMM-Ergodic, Extragradient, SVRG, NPG, Clipped SGD, SGD-PL, Nesterov LB |
| 2 | **Convexity + Subgradient Inequality（凸性+次梯度不等式）** | 8 | SPS-SGD, Proximal Gradient, Extragradient, ADMM-FR, ADMM-Ergodic, OGD, Mirror Descent, SVRG |
| 3 | **Descent Lemma / L-smoothness（下降引理）** | 6 | SPS-SGD, Adam, Clipped SGD, SVRG, SGD-PL, Proximal Gradient |
| 4 | **Lyapunov Function / Potential（Lyapunov 函数）** | 5 | SVRG, Proximal Gradient, ADMM-FR, ADMM-Ergodic, OGD |
| 5 | **Chernoff / MGF Bound（矩母函数+Chernoff界）** | 5 | JL Lemma, Matrix Bernstein, McDiarmid, Sub-Gaussian Covariance, PAC-Bayes |
| 6 | **KL Divergence / Entropy Regularization（KL散度/熵正则）** | 4 | NPG, Entropy-Reg VI, PAC-Bayes, Langevin |
| 7 | **Jensen's Inequality + Ergodic Averaging（Jensen+遍历平均）** | 4 | Extragradient, ADMM-FR, ADMM-Ergodic, SGD-PL |
| 8 | **Union Bound / ε-net（联合界/ε网）** | 4 | PAC-Bayes, JL Lemma, Sub-Gaussian Covariance, Matrix Bernstein |
| 9 | **Hoeffding's Lemma（Hoeffding引理）** | 3 | PAC-Bayes, NPG, McDiarmid |
| 10 | **Bregman Divergence / Three-Point Identity（Bregman散度/三点恒等式）** | 3 | Mirror Descent, NPG, ADMM-FR |
| 11 | **Polarization Identity（极化恒等式）** | 3 | Adam, ADMM-FR, ADMM-Ergodic |
| 12 | **Young's Inequality（Young不等式）** | 3 | Mirror Descent, Clipped SGD, Extragradient |
| 13 | **Strong Convexity / PL Condition（强凸/PL条件）** | 3 | SVRG, SGD-PL, SGD Stability |
| 14 | **Projection Non-expansiveness（投影非扩张性）** | 2 | OGD, Extragradient |
| 15 | **Donsker-Varadhan Variational Formula（DV变分公式）** | 2 | PAC-Bayes, NPG |
| 16 | **Variational Inequality（变分不等式）** | 2 | Extragradient, ADMM-FR |
| 17 | **Bias-Variance Decomposition（偏差-方差分解）** | 2 | Double Descent, Clipped SGD |
| 18 | **Induction（数学归纳法）** | 2 | Nesterov LB, SGD-PL |
| 19 | **Rotational / Gaussian Invariance（旋转不变性）** | 2 | Double Descent, JL Lemma |
| 20 | **Lipschitz Composition（Lipschitz 复合）** | 2 | Transformer Attention, Entropy-Reg VI |
| 21 | **Softmax Spectral Analysis（Softmax 谱分析）** | 2 | Transformer Attention, NPG |
| 22 | **Matrix Bernstein Inequality（矩阵Bernstein不等式）** | 2 | Matrix Bernstein, NTK Infinite-Width |
| 23 | **Supermartingale / Doob Martingale（超鞅/Doob鞅）** | 1 | McDiarmid |
| 24 | **Log-Sobolev Inequality + Gronwall（LSI+Gronwall）** | 1 | Langevin |
| 25 | **De Bruijn Identity（De Bruijn恒等式）** | 1 | Langevin |
| 26 | **Lieb's Concavity Theorem（Lieb凹性定理）** | 1 | Matrix Bernstein |
| 27 | **Schur Product Lemma（Schur乘积引理）** | 1 | NTK Infinite-Width |
| 28 | **Wishart Inverse Moments（Wishart逆矩）** | 1 | Double Descent |
| 29 | **Log-Sum-Exp Contraction（LSE压缩性）** | 1 | Entropy-Reg VI |
| 30 | **Performance Difference Lemma（策略差引理）** | 1 | NPG |
| 31 | **Bayes' Rule / Score-of-Mixture（贝叶斯/混合分布得分）** | 1 | Denoising Score Matching |
| 32 | **Hyperplane Arrangement（超平面排列）** | 1 | NTK Gram Matrix |
| 33 | **Tridiagonal Construction（三对角构造）** | 1 | Nesterov LB |
| 34 | **Recursive Coupling（递归耦合）** | 1 | SGD Stability |
| 35 | **Kuhn Triangulation（Kuhn三角剖分）** | 1 | ReLU Universal Approximation |
| 36 | **Abel Summation（Abel求和）** | 1 | OGD |

---

## 第二部分：按技巧分类的证明地图

### 高频技巧组合（跨多道题反复出现的套路）

**套路 A：Descent Lemma + Telescoping（下降引理+望远镜）**
> 出现在 6 道优化题：SPS-SGD, Adam, Clipped SGD, SVRG, SGD-PL, Proximal Gradient

这是优化分析的"面包黄油"组合。L-smoothness 给出每步下降量的下界，望远镜求和把单步界叠成全局界。变体包括：
- 加 Lyapunov 函数 → Proximal Gradient, SVRG
- 加 bias-variance 分解 → Clipped SGD
- 加 polarization identity → Adam

**套路 B：Lyapunov + Telescoping + Ergodic Averaging（Lyapunov+望远镜+遍历平均）**
> 出现在 5 道题：Proximal Gradient, ADMM-FR, ADMM-Ergodic, Extragradient, SVRG

凸优化的标准"Lyapunov 三件套"：构造距离势函数 → 证单步不等式 → 望远镜求和 → Jensen 遍历平均。ADMM 两版证明和 Extragradient 都遵循这个框架。

**套路 C：Bregman Divergence + Three-Point Identity + KL/Entropy（Bregman+三点+熵）**
> 出现在 3 道题：Mirror Descent, NPG, ADMM-FR

Mirror descent 家族的标志性工具。三点恒等式把内积分解为 Bregman 散度之差，产生望远镜结构。NPG 将此与 Donsker-Varadhan 结合实现精确消去。

**套路 D：MGF/Chernoff + Union Bound / ε-net（矩母函数+覆盖网）**
> 出现在 5 道概率/统计题：JL Lemma, Matrix Bernstein, McDiarmid, Sub-Gaussian Covariance, PAC-Bayes

浓度不等式的标准范式：对单个方向/假设/矩阵做 Chernoff 界，再用 union bound 或 ε-net 覆盖全空间。

**套路 E：Donsker-Varadhan + Hoeffding's Lemma（DV变分+Hoeffding引理）**
> 出现在 2 道题，横跨 2 个分支：PAC-Bayes (learning-theory/pac), NPG (optimization/convergence)

这是一个意外的跨领域联系。PAC-Bayes 用 DV 处理"对所有后验 Q 一致成立"，NPG 用 DV 处理"advantage 的指数矩"。两者的 Hoeffding 界都利用了 bounded loss/advantage 的性质。

### 跨分支技巧关联图

```
Optimization ←→ Statistics/Probability
  Descent Lemma          Chernoff/MGF
  Telescoping            Union Bound / ε-net
  Lyapunov               Supermartingale
  Young's ineq           Hoeffding's Lemma
       ↕                      ↕
       └──── KL Divergence ────┘  (PAC-Bayes, NPG, Langevin, Entropy-Reg VI)
             Donsker-Varadhan      (PAC-Bayes ↔ NPG)
```

### 单技巧多定理的详细列表

| 技巧 | 涉及分支 | 定理列表 |
|------|---------|---------|
| Telescoping | optimization (×8), convex-analysis (×4), learning-theory (×1) | 几乎所有优化+凸分析证明 |
| Descent Lemma | optimization/stochastic (×3), optimization/adaptive (×1), optimization/convergence (×1), convex-analysis (×1) | 所有梯度下降类证明 |
| Chernoff/MGF | statistics/concentration (×3), linear-algebra (×1), learning-theory/pac (×1) | 所有浓度不等式+JL+PAC-Bayes |
| KL Divergence | optimization/convergence (×2), learning-theory/pac (×1), probability (×1) | 跨4个分支的"桥梁技巧" |
| Lyapunov | optimization/stochastic (×1), optimization/convergence (×1), convex-analysis/subgradient (×3) | 分裂法+近端法的核心 |

---

## 第三部分：每道题的证明摘要卡片

### [1] SGD with Stochastic Polyak Step-size Convergence
- **分支：** optimization/stochastic
- **难度：** advanced
- **获胜路线：** Route 1 — Descent Lemma + Telescoping Sum
- **核心技巧：** Descent Lemma, SPS substitution, Interpolation condition
- **一句话总结：** SPS 步长通过 γ²‖∇f‖² = γf/c 替换，在插值条件下产生自然消去，望远镜求和得 O(1/T) 率。
- **Audit 结果：** PASS round 1，无 Fixer

### [2] NTK Gram Matrix Positive Definiteness
- **分支：** learning-theory/generalization
- **难度：** research
- **获胜路线：** Route 4 — Quadratic Form + Hyperplane Arrangement Adjacency
- **核心技巧：** Quadratic form = E[‖v(w)‖²], Hyperplane arrangement, Adjacent cell lemma
- **一句话总结：** 将 c^T H^∞ c 写成 E[‖v(w)‖²] 保证 PSD，再利用超平面排列的邻接结构逐个隔离 c_k=0。
- **Audit 结果：** PASS round 1，无 Fixer

### [3] Adam Non-Convex Convergence
- **分支：** optimization/adaptive-methods
- **难度：** advanced
- **获胜路线：** Descent Lemma + Polarization Identity + Horizon-dependent LR
- **核心技巧：** Polarization identity, β₁²≤β₂ condition, Horizon-dependent step size
- **一句话总结：** 极化恒等式巧妙地将自适应内积分解为梯度范数减去动量误差，避免了混乱的动量展开。
- **Audit 结果：** PASS round 1，无 Fixer

### [4] Sub-Gaussian Covariance Concentration
- **分支：** statistics/concentration
- **难度：** research
- **获胜路线：** ε-net + Sub-exponential Bernstein
- **核心技巧：** ε-net covering, Sub-exponential Bernstein, Two-regime analysis
- **一句话总结：** 1/4-net 上逐方向做 Bernstein 界，max(δ,δ²) 自然从 Bernstein 的 min(s²/σ², s/b) 中浮现。
- **Audit 结果：** PASS，无 Fixer

### [5] SGD Uniform Stability and Generalization
- **分支：** learning-theory/stability
- **难度：** advanced
- **获胜路线：** Recursive Coupling (Hardt-Recht-Singer)
- **核心技巧：** Co-coercivity, Recursive coupling, Bousquet-Elisseeff symmetrization
- **一句话总结：** 在相邻数据集上运行两份 SGD，凸性保证梯度步非扩张，差异点以 1/n 概率命中，递推得稳定性界。
- **Audit 结果：** PASS，无 Fixer

### [6] Transformer Attention Lipschitz
- **分支：** learning-theory/generalization
- **难度：** research
- **获胜路线：** Three-stage Composition
- **核心技巧：** Softmax 1/2-Lipschitz, Product rule decomposition, Bilinear score perturbation
- **一句话总结：** 将 attention 拆为 logit→softmax→value aggregation 三阶段，softmax 的 Jacobian 谱范数恰为 1/2。
- **Audit 结果：** PASS，无 Fixer

### [7] Denoising Score Matching Equivalence
- **分支：** learning-theory/generalization
- **难度：** research
- **获胜路线：** Expand + Score-of-Mixture Identity
- **核心技巧：** Score-of-mixture identity, Bayes' rule integration order swap
- **一句话总结：** 展开两个目标函数，θ-无关项相消后，通过贝叶斯交换积分顺序证明 θ-相关交叉项相等。
- **Audit 结果：** 未明确列出（notes.md 中无 Audit 节，推测 PASS）

### [8] Double Descent — Interpolation Threshold
- **分支：** statistics/high-dimensional
- **难度：** research
- **获胜路线：** Route 3 — Direct Bias-Variance + Wishart Inverse Moments
- **核心技巧：** Bias-variance via pseudoinverse, Wishart inverse moments, Haar invariance
- **一句话总结：** 利用 Wishart 逆矩精确公式 E[(Z^TZ)^{-1}]=I/(n-d-1)，当 n→d 时最小特征值趋零导致发散。
- **Audit 结果：** PASS round 1，无 Fixer

### [9] Langevin KL Convergence via Log-Sobolev
- **分支：** probability
- **难度：** research
- **获胜路线：** Route 1 — Entropy Dissipation: De Bruijn + LSI + Gronwall
- **核心技巧：** De Bruijn identity, Log-Sobolev inequality, Gronwall's inequality
- **一句话总结：** Fokker-Planck 推出 KL 的时间导数等于负 Fisher 信息，LSI 给出 I≥2αKL，Gronwall 闭合得指数衰减。
- **Audit 结果：** PASS round 1，无 Fixer

### [10] Clipped SGD Heavy-Tail Convergence
- **分支：** optimization/stochastic
- **难度：** research
- **获胜路线：** Descent Lemma + Bias-Variance + Case Analysis
- **核心技巧：** Clipping bias decomposition, Case analysis (small/large gradient), ‖∇‖² recovery via telescoping
- **一句话总结：** 引入代理平稳性度量 φ=min(‖∇‖²,τ‖∇‖)，对梯度大小分情况讨论，再通过单独的望远镜论证恢复全 ‖∇‖² 界。
- **Audit 结果：** PASS（数值验证 O(T^{-1/3}) 率误差<8%），无 Fixer

### [11] Online Mirror Descent Regret Bound
- **分支：** optimization/mirror-descent
- **难度：** research
- **获胜路线：** Route 1 — Telescoping Bregman Decomposition
- **核心技巧：** Bregman three-point identity, Fenchel-Young inequality, σ-strong convexity cancellation
- **一句话总结：** 三点恒等式将梯度内积转为 Bregman 散度之差，Young 参数选 α=σ 与强凸下界精确消去残差项。
- **Audit 结果：** PASS round 1，无 Fixer

### [12] NTK Infinite-Width Convergence Rate
- **分支：** learning-theory/generalization
- **难度：** research
- **获胜路线：** Route 4 — Schur Product + Matrix Bernstein
- **核心技巧：** Schur product lemma, Matrix Bernstein inequality
- **一句话总结：** Schur 乘积引理 ‖M∘G‖≤‖M‖ 将 Gram 矩阵完全吸收，Matrix Bernstein 给出 O(n/√m) 收敛率。
- **Audit 结果：** PASS round 1，无 Fixer

### [13] SVRG Linear Convergence (ABC Framework)
- **分支：** optimization/stochastic
- **难度：** advanced
- **获胜路线：** Route 5 — Semi-Stochastic / ABC Framework
- **核心技巧：** Nesterov variance bound, Distance-to-optimum Lyapunov, Strong convexity coupling
- **一句话总结：** 以‖x_t-x*‖²为 Lyapunov 量推导单步递推，内循环求和后用强凸性将 ΣΦ 转为 Σδ，output averaging 得每 epoch 1/2 压缩。
- **Audit 结果：** PASS，无 Fixer

### [14] McAllester's PAC-Bayes Bound
- **分支：** learning-theory/pac
- **难度：** research
- **获胜路线：** Route 1 — Donsker-Varadhan + MGF + Union Bound
- **核心技巧：** Donsker-Varadhan variational formula, Hoeffding's lemma, λ-grid union bound
- **一句话总结：** DV 变分将"对所有 Q 一致"归结为控制固定先验 P 下的 MGF，Hoeffding 界+λ-grid 使后验优化合法。
- **Audit 结果：** FAIL round 1 → PASS round 2（需要显式 λ-grid union bound 修复）

### [15] Proximal Gradient O(1/T) Convergence
- **分支：** convex-analysis/subgradient
- **难度：** research
- **获胜路线：** Route 2 — Lyapunov Potential
- **核心技巧：** Proximal optimality, Descent lemma + convexity + subgradient, Lyapunov = same expression
- **一句话总结：** F(x_{t+1})-F(x*) 的上界和 Lyapunov 下降量恰好是同一个表达式，单步不等式直接成立，望远镜+单调性升级为末迭代界。
- **Audit 结果：** PASS round 1，无 Fixer

### [16] SGD under PL + Interpolation with Iterate Averaging
- **分支：** optimization/stochastic
- **难度：** conjecture
- **获胜路线：** Route 5 — Direct Recursion + Induction
- **核心技巧：** PL condition, Strong growth + interpolation, Polynomial induction
- **一句话总结：** 插值条件使方差∝f(x)-f*（无加性 σ²），乘性噪声结构让单迭代达到 1/t² 率，Jensen 平均得 O(1/T)。
- **Audit 结果：** PASS round 1，无 Fixer

### [17] NPG Softmax Tabular Convergence
- **分支：** optimization/convergence
- **难度：** conjecture
- **获胜路线：** Route 1 — Mirror Descent + PDL + Donsker-Varadhan
- **核心技巧：** Performance Difference Lemma, KL three-point identity, Donsker-Varadhan + Hoeffding, Exact KL cancellation
- **一句话总结：** PDL 将值函数差表为加权 advantage，NPG=KL-mirror descent 的三点分解与 DV-Hoeffding 界精确消去 KL(π_{k+1}‖π_k)。
- **Audit 结果：** PASS round 2（round 1 需 revisions: 符号错误+代数修正）

### [18] Extragradient Convex-Concave Minimax
- **分支：** convex-analysis/subgradient
- **难度：** research
- **获胜路线：** Route 2 — VI Reformulation + EG Cancellation
- **核心技巧：** Monotone operator VI, EG cancellation (extrapolation ↔ update), Jensen ergodic averaging
- **一句话总结：** THE insight: extrapolation 步和 update 步产生的 ‖z^k-z^{k+1}‖² 项正负抵消，Lipschitz 误差在 η≤1/L 时被吸收。
- **Audit 结果：** PASS round 2（round 1 需 D² 定义澄清）

### [19] Entropy-Regularized Value Iteration
- **分支：** optimization/convergence
- **难度：** research
- **获胜路线：** Route 1 — Operator Theory via LSE Properties
- **核心技巧：** LSE 1-Lipschitz, Variational LSE = max + entropy, Super-fixed-point argument
- **一句话总结：** 将 T_τ 分解为 τ·LSE∘L，LSE 的 ℓ^∞-1-Lipschitz 直接给出 γ-压缩，变分形式推出 Gibbs 策略最优。
- **Audit 结果：** PASS with minor fixes（3处一行补充），无 Fixer

### [20] Matrix Bernstein Inequality
- **分支：** statistics/concentration
- **难度：** research
- **获胜路线：** Route 3 — Lieb's Theorem + Lemma-based Architecture
- **核心技巧：** Scalar Bernstein MGF lift, Lieb's concavity theorem, Iterative peeling, Chernoff optimization
- **一句话总结：** Lieb 凹性定理实现逐一"剥离"独立矩阵的迭代化简，保持完整矩阵方差结构得到 sharp σ² 界。
- **Audit 结果：** PASS，无 Fixer

### [21] OGD Regret Bound with Matching Lower Bound
- **分支：** optimization/convergence
- **难度：** research
- **获胜路线：** Route 4 — Potential Function + Combinatorial Lower Bound
- **核心技巧：** Projection non-expansiveness, Distance potential telescoping, Khintchine L¹ bound, Derandomization
- **一句话总结：** 上界用 ‖x_t-u‖² 势函数+投影非扩张性，下界用 Rademacher 随机线性损失+Khintchine 不等式+去随机化。
- **Audit 结果：** PASS with minor fixes，无 Fixer

### [22] McDiarmid's Bounded Differences Inequality
- **分支：** statistics/concentration
- **难度：** research
- **获胜路线：** Exponential Supermartingale
- **核心技巧：** Doob martingale, Hoeffding's lemma, Supermartingale + Markov
- **一句话总结：** Doob 鞅将 f(X)-Ef(X) 分解为有界差分和，Hoeffding 引理的 sub-Gaussian MGF 与补偿子精确抵消构成超鞅。
- **Audit 结果：** PASS round 1，无 Fixer

### [23] Johnson-Lindenstrauss Lemma
- **分支：** linear-algebra
- **难度：** research
- **获胜路线：** Route 1 — Sub-Gaussian MGF + Union Bound
- **核心技巧：** Gaussian rotational invariance → χ² concentration, Asymmetric Chernoff tails, Union bound over pairs
- **一句话总结：** 高斯旋转不变性将问题化为 χ²(k) 浓度，Chernoff 优化给出 e^{-kε²/12}，union bound 覆盖所有 C(n,2) 对。
- **Audit 结果：** PASS round 1，无 Fixer

### [24] Quantitative Universal Approximation for ReLU Networks
- **分支：** learning-theory/generalization
- **难度：** research
- **获胜路线：** Kuhn Triangulation + CPL-to-ReLU
- **核心技巧：** Kuhn (Freudenthal) triangulation, Piecewise affine interpolation, CPL representation theorem
- **一句话总结：** 在 [0,1]^d 上建 Kuhn 三角剖分（每个网格立方体切 d! 个单纯形），分片仿射插值达到 Lδ≤ε 误差，CPL 定理转为 ReLU 网络。
- **Audit 结果：** PASS (confidence 9/10)，无 Fixer（从 Explorer 1 嫁接了 conformality 和 weight bounds）

### [25] ADMM Ergodic O(1/K) Convergence (Full Rank)
- **分支：** convex-analysis/subgradient
- **难度：** research
- **获胜路线：** Lyapunov + Telescoping (He-Yuan Framework)
- **核心技巧：** Variational inequality, Three-point + polarization identity, Perfect square cancellation, λ-optimization
- **一句话总结：** 子问题最优性导出变分不等式，三点恒等式+极化恒等式产生完美望远镜结构，残差项合并为非正完全平方 -ρ/2‖s^{k+1}‖²。
- **Audit 结果：** PASS round 1，无 Fixer

### [26] ADMM Ergodic O(1/K) Convergence (General)
- **分支：** convex-analysis/subgradient
- **难度：** research
- **获胜路线：** Route 5 — Direct Summation via Optimality Conditions
- **核心技巧：** Optimality conditions, Double polarization identity, Completion of the square
- **一句话总结：** 对 B-空间项和对偶项分别做极化恒等式，交叉项合并为完全平方 ρ/2‖Ax+Bz-c‖²≥0 可丢弃，望远镜+Jensen 得 O(1/K)。
- **Audit 结果：** PASS round 1，无 Fixer

### [27] Nesterov's First-Order Lower Bound
- **分支：** optimization/lower-bounds
- **难度：** research
- **获胜路线：** Route 1 — Tridiagonal Construction + Induction
- **核心技巧：** Tridiagonal Hessian construction, Subspace restriction by induction, Schur complement
- **一句话总结：** 三对角矩阵使信息每步只传播一个坐标方向，k 步后方法未"看到"后半坐标，Schur 补给出精确下界 3L‖x*‖²/(32(k+1)²)。
- **Audit 结果：** PASS round 1，无 Fixer

---

## 第四部分：洞察与模式

### 1. "万能工具"（出现在 3 个以上不同分支）

| 技巧 | 涉及分支数 | 分支列表 |
|------|-----------|---------|
| **Telescoping Sum** | 4 | optimization, convex-analysis, learning-theory, statistics |
| **Convexity + Subgradient Inequality** | 3 | optimization, convex-analysis, learning-theory |
| **Chernoff / MGF Bound** | 3 | statistics, linear-algebra, learning-theory |
| **KL Divergence** | 4 | optimization, learning-theory, probability, convex-analysis (via entropy-reg) |
| **Descent Lemma** | 3 | optimization, convex-analysis, (implicit in learning-theory stability) |

**KL 散度是最"跨界"的工具**——它同时出现在优化（NPG, Entropy-Reg VI）、学习理论（PAC-Bayes）、概率（Langevin）四个不同分支，充当了信息论与优化之间的桥梁。

**Telescoping 是绝对的基础设施**——13/27 道题使用，覆盖 4 个分支。不会望远镜求和等于不会做优化证明。

### 2. 分支风格相似度

**最相似的一对：optimization/convergence ↔ convex-analysis/subgradient**
- 共享技巧：Lyapunov, Telescoping, Convexity, Jensen averaging, Polarization identity
- 两者的证明结构几乎同构：构造势函数 → 单步递推 → 望远镜 → 遍历平均
- ADMM 和 Proximal Gradient 的证明几乎可以互换框架

**第二相似：optimization/stochastic ↔ optimization/convergence**
- 共享 Descent Lemma + Telescoping 核心
- 区别在于：stochastic 需要额外的方差控制（interpolation, clipping, variance reduction）

**风格独特的分支：**
- **probability**（Langevin）：使用 PDE 工具（Fokker-Planck, De Bruijn, LSI），与其他分支几乎不共享技巧
- **linear-algebra**（JL Lemma）：核心是旋转不变性+χ² 浓度，更接近 statistics 而非 optimization
- **learning-theory/generalization**（NTK, Transformer, ReLU, Score Matching）：技巧最多样化，每道题用不同工具，没有统一范式

### 3. 攻克新题最值得优先尝试的 3 个技巧组合

**组合 1（适用于：优化收敛率证明）：**
> **Descent Lemma + Lyapunov Function + Telescoping**

成功率最高的组合。6/27 道题直接使用此套路。对任何涉及光滑目标函数的迭代算法收敛率问题，这是默认起手式。

**组合 2（适用于：概率/统计界、高维分析）：**
> **MGF/Chernoff Bound + ε-net / Union Bound + Sub-Gaussian/Sub-exponential Analysis**

5/27 道题使用此框架。只要问题涉及"以高概率控制某个随机量的范数"，这个组合几乎必用。

**组合 3（适用于：在线学习、策略优化、分裂法）：**
> **Bregman Divergence / Three-Point Identity + Donsker-Varadhan / KL + Telescoping**

这是 Mirror Descent 家族的"核武器"组合，已在 Mirror Descent、NPG、ADMM 中验证。特别适合涉及 KL 正则化或熵结构的问题。PAC-Bayes 的证明也可以用此视角理解。

---

## 附录：统计摘要

| 指标 | 值 |
|------|-----|
| 总证明数 | 27 |
| 难度分布 | research: 21, advanced: 4, conjecture: 2 |
| 首轮 PASS 率 | 22/27 (81%) |
| 需要 Fixer 的 | 0/27 (0%) — 所有修正在 audit round 2 完成 |
| 需要 2 轮 audit 的 | 3/27 — PAC-Bayes, NPG, Extragradient |
| 不同核心技巧数 | 36 |
| 最高频技巧 | Telescoping (13次), Convexity (8次), Descent Lemma (6次) |
| 跨分支最广技巧 | KL Divergence (4个分支), Telescoping (4个分支) |

---

*报告自动生成于 2026-04-11，基于 proofs/ 下 27 个证明文件夹的 notes.md 和 problem.md。*
