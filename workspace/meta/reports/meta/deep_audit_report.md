# 深度质量审计报告

> 审计对象：proofs/ 下 27 道已完成证明（INDEX.md 中 29 道，其中 Hoeffding 和 Azuma-Hoeffding 未在扫描范围内）  
> 审计日期：2026-04-11  
> 审计方法：纯数学推理审查，不查阅文献

---

## 审计 1：测度论和技术条件检查

| # | 证明 | 评级 | 问题说明 |
|---|------|------|---------|
| 1 | SPS-SGD | **CLEAN** | Tower property E_{i_k}[f_{i_k}(x_k)\|x_k]=f(x_k) 正确使用，Jensen 基于 f 凸性（已声明） |
| 2 | NTK Gram PD | **CLEAN** | 有限求和与期望交换无问题；开锥的正高斯测度由高斯的全支撑保证 |
| 3 | Adam | **MINOR** | Step 4 动量误差界 δ² 仅用 "By Jensen + L-smoothness" 带过，完整推导涉及 path length 的 Σ||D_r|| 估计未展开 |
| 4 | Sub-Gaussian Covariance | **CLEAN** | Bernstein 不等式作为已知工具使用；union bound 计 9^d 个点正确 |
| 5 | SGD Stability | **MINOR** | (1) Co-coercivity (Baillon-Haddad 定理) 作为已知结论使用未证；(2) Bousquet-Elisseeff 稳定性→泛化仅给 proof sketch |
| 6 | Transformer Attention | **CLEAN** | 所有范数链 \|\|a_i\|\|_1=1、\|\|X'\|\|_{op} ≤ \|\|X'\|\|_F 合法 |
| 7 | Denoising Score Matching | **GAP** | (1) Score-of-mixture identity ∇log q_σ(x)=E_{p(y\|x)}[∇log p(x\|y)] 需要 Leibniz 规则交换 ∇ 和 ∫，未声明正则性条件；(2) Bayes swap 需 Fubini/Tonelli，未显式说明 |
| 8 | Double Descent | **MINOR** | Inverse Wishart moment formula E[(Z^TZ)^{-1}]=I/(n-d-1) 以 "classical result" 引用，给了密度论证但未完整证明正则化条件 |
| 9 | Langevin KL | **MINOR** | (1) Step 2 "differentiate under the integral sign" 需要 DCT 条件，未声明；(2) 分部积分的边界项"在足够快衰减下消失"——已承认但未证明 |
| 10 | Clipped SGD | **CLEAN** | E[\|\|ξ_t\|\| \| x_t] ≤ (E[\|\|ξ_t\|\|^p \| x_t])^{1/p} 由 Jensen（凹函数 x^{1/p}）正确推出；条件期望和 tower property 全部正确 |
| 11 | Mirror Descent | **CLEAN** | 三点恒等式由展开证明；有限望远镜和，无极限交换问题 |
| 12 | NTK Infinite-Width | **CLEAN** | \|\|E[Z₁²]\|\| ≤ E[\|\|Z₁\|\|²] 由 Jensen（算子范数凸）正确；Schur 乘积引理完整证明 |
| 13 | SVRG | **CLEAN** | Lemma 5 方差界推导完整（\|\|a+b\|\|² ≤ 2\|\|a\|\|²+2\|\|b\|\|²，Var ≤ E[X²]，Lemma 2 链）；Jensen 用于 output averaging 且声明 f 凸 |
| 14 | PAC-Bayes | **MINOR** | Step 3b 显式引用 Tonelli 定理（正确）；Step 6 grid approximation 声称 O(1/n) suboptimality 但未完整证明（由 g 的凸性+grid spacing 可推，但跳了一步） |
| 15 | Proximal Gradient | **CLEAN** | prox 的存在性由 g proper closed convex + 强制二次项保证；所有代数恒等式验证完整 |
| 16 | SGD PL+Interpolation | **CLEAN** | 归纳法的多项式不等式 P(s)≥0 验证详细；∑1/(t+t₀)² 的积分上界推导正确 |
| 17 | NPG Softmax | **CLEAN** | 三点恒等式由两种方法证明（Bregman + 直接计算）；PDL 由迭代递推推出；无穷级数 ∑γ^t 标准收敛 |
| 18 | Extragradient | **CLEAN** | 投影性质完整证明；argmax/argmin 存在由 Z 紧性保证（显式声明）；Jensen 基于凸-凹性 |
| 19 | Entropy-Reg VI | **CLEAN** | Banach 不动点定理条件满足（完备度量空间 + γ-压缩）；LSE 的严格递增性由 softmax > 0 证明 |
| 20 | Matrix Bernstein | **CLEAN** | Lieb 凹性定理和算子 log 单调性引用文献；迭代 peeling 利用独立性正确；trace-exp 单调性内联证明 |
| 21 | OGD | **CLEAN** | 投影非扩张性证明完整；Abel 求和界 1/√t ≤ 2(√t-√(t-1)) 由有理化验证；去随机化论证正确 |
| 22 | McDiarmid | **CLEAN** | Hoeffding 引理完整证明（φ'' ≤ 1/4）；超鞅性质用条件 Hoeffding 界，可测性条件由 D_k 关于 F_{k-1} 适应保证 |
| 23 | JL Lemma | **CLEAN** | 高斯旋转不变性 → χ²(k) 标准；union bound 计 C(n,2) ≤ n²/2 对正确 |
| 24 | ReLU Universal | **CLEAN** | Kuhn 三角剖分 conformality 证明完整；CPL 表示定理作为 black box 引用（Wang & Sun 2005） |
| 25 | ADMM Full-Rank | **CLEAN** | 三点恒等式、极化恒等式均由展开证明；Jensen 用于遍历平均（f,g 凸） |
| 26 | ADMM Ergodic | **CLEAN** | 结构类似 #25，Lyapunov 下降和望远镜求和自洽 |
| 27 | Nesterov LB | **CLEAN** | 三对角矩阵特征值公式引用标准结论；归纳法证子空间限制严格；Schur 补计算有数值验证 |

### 审计 1 汇总

| 评级 | 数量 | 占比 |
|------|------|------|
| CLEAN | 21 | 78% |
| MINOR | 5 | 19% |
| GAP | 1 | 4% |

**唯一 GAP：Denoising Score Matching** — score-of-mixture identity 的 Leibniz 规则交换和 Fubini 条件未声明。~~修复方法：在 Step 3 前加一段说明 q_σ(x)>0 和 ∇_x p(x|y) 被 Gaussian kernel 控制从而满足 DCT 条件。~~ **已修复 (2026-04-11)**：在 Step 3 前补充了 Leibniz/DCT 正则性说明。

---

## 审计 2：短证明深度检查

### Matrix Bernstein (28 行)

**评定：完整**

每一步推导链：
- Lemma A：Taylor 积分余项 → k! ≥ 2·3^{k-2}（归纳证明）→ 幂级数控制 → E[Y]=0 取期望 → 1+x≤e^x 提升。**全部显式。**
- Lemma B：谱函数演算将标量不等式逐特征值提升到 Loewner 序。关键步 I+M⪯e^M 由 1+x≤e^x 提升。**正确但压缩（一句话覆盖了谱分解论证）。**
- Lemma C：Lieb 凹性定理（引用）+ Jensen。**依赖外部定理，但引用明确。**
- Lemma D：迭代 peeling 过程描述完整（剥离 X_n→...→X_1），trace-exp 单调性内联证明（导数 ≥ 0）。**完整。**
- Lemma E：直接代入计算。**完整。**
- 主定理：||S|| = max(λ_max(S), λ_max(-S)) → 2 tail union bound → Markov + trace bound → 组合。**完整。**

**结论：没有关键步骤被跳过。** 最大的"压缩"是 Lemma B 的谱函数演算一行带过，但这是标准工具。

### Denoising Score Matching (31 行)

**评定：有跳步**

跳步清单：
1. **A(θ) 等价性跳过**：Step 1 和 Step 2 的 A(θ) = ½E_{q_σ}[||s_θ||²] 相同，但第一个是对 q_σ 取期望，第二个是对 p(y)N(ε) 取期望。等价性需要变量替换 x=y+σε 将 q_σ(x)dx 变为 p_data(y)N(ε)dydε。**未显式说明。**
2. **Score-of-mixture identity 跳过**：∇_x log q_σ(x) = E_{p(y|x)}[∇_x log p(x|y)] 仅标注 "by Bayes' rule"。完整推导需要：(a) ∇_x 与 ∫ 交换（Leibniz/DCT），(b) Bayes 公式 q_σ(x)p(y|x) = p_data(y)p(x|y)。**两步均被跳过。**
3. **B(θ) 计算跳过**：从 E_{q_σ}[⟨s_θ, ∇log q_σ⟩] 变为 E_{p(y)p(x|y)}[⟨s_θ, ∇log p(x|y)⟩] 需要将 score-of-mixture 代入后交换积分顺序（Fubini）。**隐式使用。**

**结论：三处跳步。** 证明的核心 idea 完全正确，但 measure-theoretic 的合理性说明缺失。这是 31 行证明中唯一的实质性短板。

### NTK Infinite-Width (33 行)

**评定：完整**

逐步检查：
- Step 1 分解：标准。
- Step 2 Schur 乘积引理：完整自证（quadratic form → 分解为 Σ_ℓ q_ℓ^T M q_ℓ → Σ||q_ℓ||²=1 → 三角不等式）。
- Step 3 算子范数界：由 Step 2 + 三角不等式。**完整。**
- Step 4 方差界：||E[Z₁²]|| ≤ E[||Z₁||²] ≤ R²。第一个不等式是 Jensen（凸函数），第二个是 a.s. bound。**完整。**
- Step 5 Matrix Bernstein 应用：引用本库已证结论。方差主导区域的化简跳了一步代数但可追踪。
- Step 6 简化：log(2n/δ) ≤ 3log(n/δ) 的条件 n/δ ≥ √2 已声明。

**结论：没有关键跳步。**

### Sub-Gaussian Covariance (34 行)

**评定：有跳步**

跳步清单：
1. **ε-net lemma 跳过**：Step 1 声称 1/4-net 上 ||M|| ≤ 2 sup_{u∈N} |u^T M u|。这是一个需要 4-5 行推导的标准结论（取 sup，用 net 近似，几何级数收敛），但此处直接声明。
2. **Sub-exponential 表征跳过**：Step 2 声称 (u^T a_i)² 的 ψ₁-norm ≤ CK²。这需要证明 sub-Gaussian 平方是 sub-exponential 并追踪范数常数。**未展开。**
3. **两区间分析有混乱**：Step 3 中 "Small deviation" 的公式有自我更正痕迹（"actually $s = K²δ₀$, uses..."），表明证明在写作时有过修订。最终结论正确但行文不够干净。

**结论：两处跳步 + 一处行文混乱。** 核心论证正确但不够自洽。

### SGD Uniform Stability (49 行)

**评定：完整（有 minor jump）**

逐步检查：
- Step 1 非扩张性：使用 co-coercivity，给出公式但引用为已知结论。**Minor jump**（co-coercivity 由凸 β-smooth 推出，是 Baillon-Haddad 定理的直接推论，但证明需要约 3 行）。
- Step 2 有界扰动：三角不等式 + Lipschitz。**完整。**
- Step 3 递推：全期望的 tower property + 分情况讨论 (i_t=j 和 i_t≠j)。**完整。**
- Step 4 望远镜：δ₀=0 直接得到。**完整。**
- Step 5 稳定性：Lipschitz → function value gap。**完整。**
- Step 6 泛化界：Bousquet-Elisseeff 给了 proof sketch（add/subtract + 对称性）而非完整证明。**Minor jump。**

**结论：没有关键步骤被跳过**，两处 minor jump 是引用已知结论（co-coercivity、Bousquet-Elisseeff）。

---

## 审计 3：常数追踪检查

| # | 证明 | 最终常数 | 评级 | 说明 |
|---|------|---------|------|------|
| 1 | SPS-SGD | 2cL/T | **LOOSE** | 问题声称 cL/(2T)，证明得到 2cL/T，差 4×。证明已承认差异并解释为 smoothness 约定不同。证明内部自洽。 |
| 2 | NTK Gram PD | (定性) | **N/A** | 正定性是定性结论，无常数 |
| 3 | Adam | O(d log T/√T) | **TIGHT** | d 来自 ||D_t||²≤d，log T 来自动量误差的调和级数。隐含维度 d 依赖是本质的（已显式写出） |
| 4 | Sub-Gaussian | K²max(δ,δ²) | **TIGHT** | C, c 是 K 的函数，吸收了 net/Bernstein 的常数。框架自洽 |
| 5 | SGD Stability | 2L²αT/n | **TIGHT** | 2 来自 Step 2 的 2α_t L，L² 来自 Lipschitz 转换。可完整追踪 |
| 6 | Transformer | n R²\|\|M\|\|\|\|W_V\|\|/√d_k | **TIGHT** | 证明的自然界比问题声称的 2√2n R/√d_k 更紧。Remark 中已说明 |
| 7 | Score Matching | (无常数) | **N/A** | 等价关系，不涉及数值常数 |
| 8 | Double Descent | σ²γ/(1-γ) exact | **TIGHT** | Wishart 逆矩精确公式，非渐近近似。可完整追踪 |
| 9 | Langevin | e^{-2αt} | **TIGHT** | 2α 直接从 LSI 常数 α 和 Fisher 信息的 1/4 因子推出。完整追踪 |
| 10 | Clipped SGD | (9/2)√(Δ_fL)σ/T^{1-1/p} | **TIGHT** | 9/2 = 3 (term 1) + 3/2 (term 3)。O 记号隐含 AM-GM 常数。可追踪 |
| 11 | Mirror Descent | G√(2D_ψT/σ) | **TIGHT** | η 优化后的 AM-GM 直接给出 |
| 12 | NTK Infinite-Width | C=2√6 | **TIGHT** | √8·√3 = 2√6。从 log(2n/δ)≤3log(n/δ) 推出 |
| 13 | SVRG | 7/18 < 1/2 | **TIGHT** | 50/(9·20) + 1/9 = 5/18 + 2/18 = 7/18。精确计算 |
| 14 | PAC-Bayes | √((KL+ln(n/δ))/(2n)) | **TIGHT** | AM-GM 优化 A/λ+λ/(8n) → √(A/(2n))。grid 误差 O(1/n) 被主项吸收 |
| 15 | Proximal Gradient | L\|\|x₀-x*\|\|²/(2T) | **TIGHT** | 由 T·(F(x_T)-F(x*)) ≤ Φ₀ = L/2·\|\|x₀-x*\|\|² 直接得出 |
| 16 | SGD PL | 4ρL/(μT)·e₀ | **TIGHT** | 2t₀/T = 4ρL/(μT)。问题声称 O(ρL/(μT))，常数 4 在 O 内。自洽 |
| 17 | NPG | log A/(η(1-γ)K) + η/(8(1-γ)³) | **TIGHT** | 1/8 来自 Hoeffding 的 advantage range 1/(1-γ) → (1/(1-γ))²/8 |
| 18 | Extragradient | 2LD²/K | **TIGHT** | η=1/(2L)，两次 per-comparator 界相加。D² = sup\|\|z⁰-u\|\|² |
| 19 | Entropy-Reg VI | τlog A/(1-γ) | **TIGHT** | per-step bound τlog A 由几何级数 1/(1-γ) 放大 |
| 20 | Matrix Bernstein | 2d·exp(-t²/(2(σ²+Lt/3))) | **TIGHT** | 2d = 2 (symmetry) × d (trace ≤ d·max eigenvalue)。Chernoff θ* 精确计算 |
| 21 | OGD | Upper DG√T, Lower DG√T/(2√2) | **TIGHT** | Upper: D²/(2η)+ηG²T/2 = DG√T。Lower: GD/2·√(T/2) = GD√T/(2√2) |
| 22 | McDiarmid | exp(-2t²/C) | **TIGHT** | λ*=4t/C → -4t²/C + 16t²/(8C) = -4t²/C + 2t²/C = -2t²/C |
| 23 | JL | k ≥ 36 ln n/ε² | **TIGHT** | n²·2·e^{-kε²/12} ≤ 1/n → k ≥ 36 ln n/ε²。每一步代数可追踪 |
| 24 | ReLU Universal | N ≤ d!·⌈L/ε⌉^d | **TIGHT** | d! 来自 Kuhn 三角剖分每个 cube 有 d! 个单纯形。O 记号隐含 d! |
| 25 | ADMM Full-Rank | C = f(ρ,\|\|λ⁰-λ*\|\|,...) | **TIGHT** | 常数从 KEY 不等式的 Lyapunov 初始值完整追踪 |
| 26 | ADMM Ergodic | C₀ = W⁰ + ... | **TIGHT** | 同上，常数由初始 Lyapunov 量定义 |
| 27 | Nesterov LB | 3L\|\|x*\|\|²/(32(k+1)²) | **TIGHT** | Schur 补 v^TSv=1/(2(k+1)) → L/(16(k+1)) → 与 \|\|x*\|\|² 比较后得 3/32 |

### 审计 3 汇总

| 评级 | 数量 | 占比 |
|------|------|------|
| TIGHT | 23 | 85% |
| LOOSE | 1 | 4% |
| ERROR | 0 | 0% |
| N/A | 3 | 11% |

**O(·) 隐藏维度依赖注意：** Adam 的 O(d log T/√T) 显式包含 d（正确）；ReLU Universal 的 O((L/ε)^d) 隐含 d! 在常数中（这是本质的 curse of dimensionality，非隐藏缺陷）。

---

## 审计 4：自动出题质量检查

根据 INDEX.md 时间排序，2026-04-09 及之后的证明（第 18 道起）由 generator 自动生成：

| # | 题目 | 自洽性 | 题-证一致性 | 难度评级合理性 | 问题 |
|---|------|--------|------------|---------------|------|
| 18 | Entropy-Reg VI | **OK** | **OK** — 4 个 Part 全部证明 | research — 合理 | 无 |
| 19 | OGD + Lower Bound | **OK** | **OK** — 上下界均证明 | research — 偏宽松（此为教科书级结论），但库内一致 | 无 |
| 20 | Matrix Bernstein | **OK** | **OK** — 精确匹配 | research — 合理 | 无 |
| 21 | Extragradient | **OK** | **OK** — Gap ≤ 2LD²/K 精确匹配 | research — 合理 | 无 |
| 22 | McDiarmid | **OK** | **OK** — 精确匹配 | research — 合理 | 无 |
| 23 | JL Lemma | **OK** | **OK** — k=O(log n/ε²) | research — 合理 | 无 |
| 24 | Nesterov LB | **OK** | **OK** — Ω(1/k²) 精确匹配 | research — 合理 | 无 |
| 25 | ReLU Universal | **OK** | **OK** — N=O((L/ε)^d) | research — 合理 | 无 |
| 26 | ADMM Full-Rank | **OK** | **OK** — O(1/K) | research — 合理 | **重复问题**：与 #27 高度重叠 |
| 27 | ADMM Ergodic | **OK** | **OK** — O(1/K) | research — 合理 | **重复问题**：与 #26 高度重叠 |

### 自动出题发现的问题

**问题 1：ADMM 两题几乎重复**
- ADMM-FR（#26）假设 B full column rank
- ADMM-Ergodic（#27）不假设 full column rank
- 两者结论完全相同（O(1/K) ergodic convergence），证明结构高度相似
- **建议：** 合并为一道题，full rank 作为可选加强假设

**问题 2：难度标注偏均匀**
- 10 道自动题中 10 道标注 "research"
- 实际难度跨度较大：McDiarmid 和 Hoeffding 是本科级，而 Matrix Bernstein 和 Nesterov LB 确实是 research 级
- **建议：** 区分 standard / advanced / research

**问题 3：无 conjecture 级别的挑战题**
- 手动出题包含 2 道 conjecture（SGD-PL、NPG），自动出题全部是已有定理的复现
- **建议：** generator 应能生成推广性猜想（如"将 X 推广到 Y 假设下"）

**非问题（确认通过的项）：**
- 所有 10 道自动题的定理陈述自洽，假设条件与结论之间无矛盾
- 所有 10 道证明的结论与题目要求一致（无"证了一个不同的东西"的情况）
- 除 SPS-SGD（手动题）外，没有题目声称的常数与证明得到的常数不一致的情况

---

## 总结

### 总体统计

| 维度 | 结果 |
|------|------|
| 测度论/技术条件 CLEAN | 21/27 (78%) |
| 测度论/技术条件 MINOR | 5/27 (19%) |
| 测度论/技术条件 GAP | **1/27 (4%)** — Denoising Score Matching |
| 短证明完整性 | 3/5 完整, 2/5 有跳步 (Score Matching, Sub-Gaussian Covariance) |
| 常数 TIGHT | 23/27 (85%) |
| 常数 LOOSE | 1/27 (4%) — SPS-SGD (4× gap, 已承认) |
| 常数 ERROR | **0/27 (0%)** |
| 自动出题自洽 | 10/10 (100%) |
| 自动出题题-证一致 | 10/10 (100%) |

### 需要修复的项

| 优先级 | 证明 | 问题 | 修复建议 |
|--------|------|------|---------|
| ~~HIGH~~ **DONE** | Denoising Score Matching | ~~Score-of-mixture identity 缺 Leibniz/DCT 条件~~ | **已修复**：补充了 DCT domination 论证和 q_σ>0 的严格正性说明 |
| MEDIUM | Sub-Gaussian Covariance | ε-net lemma 和 sub-exponential 表征跳过 | 增加 Lemma 0 (net approximation) 和 Lemma 1 (sub-Gaussian product → sub-exponential) |
| LOW | SPS-SGD | 问题声称 cL/(2T) vs 证明 2cL/T | 更新 problem.md 的常数为 2cL/T 以匹配证明 |
| ~~LOW~~ **DONE** | ADMM 重复 | ~~两道几乎相同的 ADMM 题~~ | **已合并**：保留 full-rank 版本，general case 作为 alternative proof 附于 proof.md 末尾，INDEX.md 已更新 |

### 整体可信度评级

## **HIGH**

理由：
- 0 道常数 ERROR
- 仅 1 道 GAP（且是 presentation 层面，不是数学错误）
- 78% 的证明在测度论层面完全 CLEAN
- 85% 的常数可严格追踪
- 所有自动出题的定理陈述和证明结论完全一致
- 5 道 MINOR 瑕疵均是引用已知结论未展开证明，不影响正确性

库的主要弱点不在数学正确性，而在两个方面：(1) 短证明为了简洁牺牲了 measure-theoretic 的严格性声明；(2) 自动出题的难度标注过于均匀。这些都是 presentation 层面的改进空间，不影响证明的数学可靠性。

---

*报告由纯数学推理审查生成于 2026-04-11。*
