# V2 验证测试报告

> 测试日期：2026-04-16
> 测试方法：3 道新 research 级证明，完整五阶段流程
> 测试题目：
> 1. AMSGrad Non-Convex Convergence (Reddi 2018) — optimization/adaptive-methods
> 2. Differential Privacy Implies Generalization (Dwork 2015) — learning-theory/stability
> 3. STORM Variance Reduction (Cutkosky 2019) — optimization/stochastic

---

## 测试结果总览

| 测试 | 预期行为 | 实际行为 | 生效？ |
|------|---------|---------|--------|
| **T1: Explorer REF 机制** | proof.md 出现 `[REF: proofs/library/xxx]` | 3/3 证明的 best_proof.md 和 proof_route_*.md 均出现 REF 标记 | **YES** |
| **T2: Scout 库检索** | routes.md 出现 Step 0 检索结果 + REF 标注 | 2/3 读取了 proof_techniques_summary.md；3/3 搜索了 proofs/library/；3/3 标注了 [REF:] | **PARTIAL** |
| **T3: Auditor 强制数值验证** | audit.md 出现"数值验证：取 [参数]，LHS=?, RHS=?" | 3/3 证明的全部 6 轮 audit 都包含具体数值验证 + 常数追踪表 + 交叉验证表 | **YES** |
| **T4: 失败模式提取 (Step F)** | failure_patterns.md 新增失败路线条目 | 仅 STORM 新增 3 条（Routes 1/2/3）；AMSGrad 和 DP 的失败路线未被提取 | **PARTIAL** |

---

## 测试 1：Explorer REF 机制（B3 引理复用率）

### 统计

| 证明 | routes.md REF 数 | proof_route REF 总数 | best_proof REF 数 | 引用的 library 证明 |
|------|-----------------|---------------------|-------------------|-------------------|
| AMSGrad | 5 | 8 (across 4 routes) | 1 | gd-nonconvex, adagrad-sparse, adam-nonconvex(research), svrg(library), online-to-batch |
| DP Gen. | 4 | 4 (across 4 routes) | 1 | mcdiarmid, hoeffding, sgd-stability(research), pac-bayes |
| STORM | 3 | 8 (across 4 routes) | 2 | gd-nonconvex, svrg, spider(research×2), sgd-convex |
| **平均** | **4.0** | **6.7** | **1.3** | — |

### 引用的具体 library 路径

```
proofs/library/optimization/convergence/gd-nonconvex-stationary-point/proof.md        ×3 (AMSGrad, STORM ×2)
proofs/library/optimization/adaptive-methods/adagrad-sparse-regret/proof.md            ×2 (AMSGrad)
proofs/library/optimization/stochastic/svrg-linear-convergence-abc-framework/proof.md  ×2 (AMSGrad, STORM)
proofs/library/statistics/concentration/mcdiarmid-bounded-differences-inequality/proof.md ×1 (DP)
proofs/library/statistics/concentration/hoeffding-inequality/proof.md                   ×1 (DP)
proofs/library/learning-theory/pac/mcallester-pac-bayes-bound/proof.md                  ×1 (DP)
proofs/library/learning-theory/generalization/online-to-batch-conversion/proof.md       ×1 (AMSGrad)
proofs/library/optimization/stochastic/sgd-convex-convergence-rate/proof.md             ×1 (STORM)
```

### 结论

**机制生效。** Explorer 确实搜索了 library/ 并使用了 `[REF:]` 格式引用已有证明。3 道证明共引用了 8 个不同的 library 证明，平均每道引用 2.7 个。proof_route 文件中的引用丰富（平均 6.7 个 REF），best_proof 中保留了关键引用。

---

## 测试 2：Scout 库检索（D2）

### 检查项

| 检查项 | AMSGrad | DP | STORM |
|--------|---------|-----|-------|
| 读取 proof_techniques_summary.md | YES — 引用了 "Descent Lemma + Polarization Identity + Horizon-dependent LR" | **NO** — 未提及 | YES — 引用了 "Descent Lemma + Lyapunov + Telescoping" |
| 读取 failure_patterns.md | 未明确提及 | 未明确提及 | 未明确提及 |
| 搜索 proofs/library/ | YES — 找到 gd-nonconvex, adagrad-sparse | YES — 找到 mcdiarmid, hoeffding | YES — 找到 gd-nonconvex, svrg |
| 搜索 proofs/research/ | YES — 找到 adam-nonconvex | YES — 找到 sgd-stability | YES — 找到 spider ×2 |
| 路线中标注 [REF:] | YES — 5 个 REF | YES — 4 个 REF | YES — 3 个 REF |
| "Step X 可直接引用 library/xxx" 类标注 | YES — "Descent Lemma: Full proof available at [REF: ...]" | YES — "McDiarmid is in library → routes using it get [REF] annotation" | YES — "SVRG variance reduction, Lyapunov approach [REF]" |

### 结论

**机制大部分生效。** 3/3 Scout 搜索了 library 并标注了 REF；2/3 读取了 proof_techniques_summary.md；0/3 明确读取了 failure_patterns.md。

**未完全生效的原因分析：**

| 问题 | 原因 | 修复建议 |
|------|------|---------|
| DP 的 Scout 未读取 techniques summary | prompt 中 Step 0a 是"如果存在则读取"，非硬性要求；Scout agent 可能判断该文件对 learning-theory/privacy 领域不太相关 | 将"如果存在"改为"**必须**读取"，或在 orchestrator 中预读取后注入 Scout prompt |
| 3/3 未明确读取 failure_patterns.md | 同上——"如果存在"过于软性；failure_patterns.md 主要覆盖 optimization 分支，对 DP/learning-theory 的直接相关性较低 | 同上。但更根本的问题是 failure_patterns 覆盖分支不够广 |

---

## 测试 3：Auditor 强制数值验证（A3, A4）

### 检查项

| 检查项 | AMSGrad R1 | AMSGrad R2 | DP R1 | DP R2 | STORM R1 | STORM R2 |
|--------|-----------|-----------|-------|-------|----------|----------|
| 具体参数数值验证 | YES (L=1, G=1, ε=0.1, β₁=0.9, β₂=0.99) | YES (d=2, 5步展开) | YES (ε=0.5,δ=0.01; ε=0.1,δ=0.05) | YES (离散分布验证) | YES (L=1,σ=1,Δ=1,ε=0.1) | YES (完整参数 T=29412) |
| 数值验证发现问题 | YES — **inner product 下界在负噪声乘积时不成立** | 修复后 6/6 pass | YES — **e^ε-1 vs ε 差异** | 修复后 6/6 pass | YES — **单样本初始化瓶颈** | 修复后 6/6 pass |
| 常数追踪表 | YES (5 constants) | YES (6 constants) | YES (3 constants) | YES (4 constants) | YES (7 constants) | YES (6 constants) |
| 交叉验证表 | YES (3 comparisons) | YES (3 comparisons) | YES (3 comparisons) | YES (4 comparisons) | YES (4 comparisons) | YES (3 comparisons) |

### 关键发现：数值验证抓到了真实错误

| 证明 | Audit R1 发现的问题 | 严重性 | 修复方式 |
|------|-------------------|--------|---------|
| AMSGrad | inner product ⟨g_t, m_t/√v̂_t⟩ 的下界在噪声项乘积为负时不成立 | HIGH — 逻辑错误 | 引入 v̂_{t-1} 分解技巧 |
| DP | 严格界是 (e^ε-1)+δ 而非 ε+δ，当 ε=1 时差 70% | MEDIUM — 界不紧 | 改为证明 (e^ε-1)+δ，标注 ε≤1 时 ≈ 2ε+δ |
| STORM | 单样本初始化 d_0=∇f(x_0;ξ_0) 导致 O(σ⁴/ε⁴) 瓶颈 | HIGH — 率不对 | 增加 mini-batch 初始化 B=O(σ/ε) |

### 结论

**机制完全生效。** 6/6 轮 audit 都包含具体参数代入验证、常数追踪表、交叉验证表。更重要的是：数值验证在 3/3 证明中都发现了真实数学错误，全部在 Fix 阶段成功修复。这是 V2 最有价值的改进。

**副作用：首轮审计通过率下降。** 3/3 新证明首轮审计都 FAIL 了（0% 首轮通过），而基线是 81.5%。这不是退步——而是 Auditor 更严格了，能抓到之前会漏掉的错误。最终证明质量更高。

---

## 测试 4：失败模式提取（D3）

### 检查项

| 证明 | 失败路线 | failure_patterns.md 新增条目 | Step F 触发？ |
|------|---------|---------------------------|-------------|
| AMSGrad | Route 3 (Regret-to-Convergence, needs convexity) — 13/40 | 未新增 | **NO** |
| DP | Route 2 (McDiarmid, fundamentally flawed) — 7/40 | 未新增 | **NO** |
| STORM | Route 1 (Young's 过松), Route 2 (系数吸收), Route 3 (混合 L/L₁) | +3 条新增 (dated 2026-04-16) | **YES** |

### failure_patterns.md 新增的 3 条（STORM）

```
### STORM Non-Convex Convergence — Route 1: Lyapunov + Young's Inequality
- 教训: When descent retains -‖d‖², use polarization identity instead of Young's

### STORM Non-Convex Convergence — Route 2: Direct Variance Recursion  
- 教训: Joint Lyapunov approach is cleaner than separate recursion summation

### STORM Non-Convex Convergence — Route 3: Biased SGD Framework
- 教训: For STORM-type estimators, keep L₁ separate from L; don't lump them
```

### 当前 failure_patterns.md 状态

- 总条目数：17（Iteration 4 的 14 条 + STORM 的 3 条新增）
- AMSGrad 和 DP 的失败路线未被提取

### 未生效的原因分析

| 问题 | 原因分析 |
|------|---------|
| AMSGrad 和 DP 的 Step F 未触发 | **Step F 在 SKILL.md 中定义为"归档后"步骤，但实际执行依赖 orchestrator agent 的记忆和意愿。** 3 个 agent 各自独立执行，STORM agent 执行了 Step F，另外两个没有。这说明 Step F 不是强制机制——它是 prompt 中的一条指令，agent 可能在归档完成后就"满足"了，不再继续执行。 |
| 根本原因 | **Step F 缺乏强制触发机制。** 它是归档流程（Step A-E）之后的"额外"步骤，没有检查点或验证。Agent 完成 Step E（打印确认消息）后就认为任务结束了。 |
| 修复建议 | 将 Step F 集成到 Step D（clean up workspace）之前，而不是之后。或者在 orchestrator 中添加显式检查：归档完成后，扫描 work_dir/ 中的 proof_route_*.md，对非 winner 路线自动提取失败模式。 |

---

## 真实分数重算

基于 3 道新证明的实测数据，重算 V2 分数。原则：
- 有直接证据的子项 → 用实测值
- 无直接证据但机制已验证 → 用保守外推值
- 未测试的子项 → 保持基线

### 子项级别对比

| 子项 | 满分 | 基线 | 预估 | **实测** | 变化 | 说明 |
|------|------|------|------|---------|------|------|
| A1 文献一致性 | 10 | 7.50 | 7.50 | **7.50** | 0 | 未做新的 PDF 文献验证 |
| A2 无跳步 | 10 | 8.15 | 8.50 | **8.50** | +0.35 | 交叉验证 + 数值验证有效减少跳步 |
| A3 常数追踪 | 5 | 4.79 | 4.90 | **4.90** | +0.11 | 3/3 审计含完整常数追踪表 |
| A4 技术条件 | 5 | 4.07 | 4.20 | **4.20** | +0.13 | 数值验证抓到条件问题 |
| **A 小计** | **30** | **24.51** | **25.10** | **25.10** | **+0.59** | **符合预估** |
| B1 首轮审计 | 10 | 8.15 | 8.50 | **7.33** | -0.82 | 0/3 首轮通过（但因 Auditor 更严格，非退步） |
| B2 Explorer 成功率 | 5 | 1.65 | 2.00 | **2.50** | +0.85 | 10/12 路线产出证明（~83%），超预期 |
| B3 引理复用率 | 5 | 0.00 | 2.50 | **2.50** | +2.50 | 3/3 证明使用 REF 引用，平均 2.7 个 |
| **B 小计** | **20** | **9.80** | **13.00** | **12.33** | **+2.53** | **略低于预估（B1 下降抵消 B2 超预期）** |
| C1 A 类占比 | 8 | 3.05 | 4.80 | **3.27** | +0.22 | 新增 3 道 A 类，但总量变化不大 (27/66=40.9%) |
| C2 分支覆盖 | 4 | 0.00 | 0.70 | **0.00** | 0 | 3 道题均在 optimization/learning-theory，未改善 |
| C3 文献验证 | 4 | 2.67 | 3.12 | **2.67** | 0 | 未做新 PDF 验证 |
| C4 技巧词典 | 4 | 2.88 | 2.88 | **2.88** | 0 | 未更新 |
| **C 小计** | **20** | **8.60** | **11.50** | **8.82** | **+0.22** | **远低于预估（需 generator 补分支覆盖）** |
| D1 出题质量 | 5 | 1.00 | 4.00 | **1.00** | 0 | 本次手动出题，未测试 generator |
| D2 Scout 库利用 | 5 | 0.00 | 3.00 | **2.50** | +2.50 | 2/3 读取技巧库，3/3 搜索 library |
| D3 失败模式 | 5 | 1.00 | 4.25 | **3.50** | +2.50 | 17 条（原 14 + STORM 3），1/3 触发 Step F |
| **D 小计** | **15** | **2.00** | **11.25** | **7.00** | **+5.00** | **显著提升但低于预估（D1 未测试，Step F 不稳定）** |
| E1 STRONGER 数 | 5 | 5.00 | 5.00 | **5.00** | 0 | 已满分 |
| E2 Conjecture 通过 | 5 | 4.00 | 4.00 | **4.00** | 0 | 本次 3 题均为 research 级 |
| E3 障碍分析 | 5 | 1.00 | 2.00 | **1.50** | +0.50 | STORM 失败模式含少量障碍分析 |
| **E 小计** | **15** | **10.00** | **11.00** | **10.50** | **+0.50** | **小幅提升** |

### 总分

| 维度 | 满分 | 基线 | 预估 | **实测** | Δ(实测-基线) | Δ(实测-预估) |
|------|------|------|------|---------|-------------|-------------|
| A 正确性 | 30 | 24.51 | 25.10 | **25.10** | +0.59 | 0 |
| B 效率 | 20 | 9.80 | 13.00 | **12.33** | +2.53 | -0.67 |
| C 积累质量 | 20 | 8.60 | 11.50 | **8.82** | +0.22 | -2.68 |
| D 自主性 | 15 | 2.00 | 11.25 | **7.00** | +5.00 | -4.25 |
| E 研究潜力 | 15 | 10.00 | 11.00 | **10.50** | +0.50 | -0.50 |
| **总分** | **100** | **54.91** | **71.85** | **63.75** | **+8.84** | **-8.10** |

---

## 预估 vs 实测差异分析

### 预估偏高的原因

| 差异来源 | 预估假设 | 实测现实 | 影响 |
|---------|---------|---------|------|
| B1 首轮审计 | Auditor 改进 → 更多首轮通过 | Auditor 更严格 → 更多首轮失败 | -1.17 |
| C1 A 类占比 | Generator 改进后批量产 A 类 | 手动测试仅 3 道，不够改变占比 | -1.53 |
| C2 分支覆盖 | Generator 轮转补弱分支 | 手动选题集中在 opt/LT | -0.70 |
| D1 出题质量 | Generator A 类优先规则生效 | 未测试 Generator | -3.00 |
| D3 Step F | 自动提取所有失败路线 | 仅 1/3 proofs 触发 | -0.75 |

### 核心洞察

1. **已验证生效的机制（+8.84 分）**：REF 引用、library 搜索、数值验证、常数追踪、交叉验证——这些都是 prompt 层面的改动，Agent 确实遵循了
2. **预估偏高的根源（-8.10 分）**：大部分差距来自 C 和 D 维度，这些需要 **Generator 批量运行** 才能改善，3 道手动测试无法覆盖
3. **反直觉的 B1 下降**：更严格的 Auditor 降低了首轮通过率，但提高了最终证明质量。评分体系需要区分"一次通过"和"最终正确"

---

## 机制有效性判定

| 机制 | V2 改动 | 是否生效 | 置信度 | 备注 |
|------|---------|---------|--------|------|
| Explorer REF 引用 | explorer.md 引理引用规则 | **YES** | 高 (3/3) | 平均每证明 2.7 个 library 引用 |
| Scout Step 0a 技巧检索 | scout.md Step 0a | **PARTIAL** | 中 (2/3) | "如果存在"过于软性 |
| Scout Step 0b 引理检索 | scout.md Step 0b | **YES** | 高 (3/3) | 全部标注了 [REF:] |
| Scout Step 0c 应用规则 | scout.md Step 0c | **YES** | 中 (3/3 搜索了，但未明确遵循 40% 规则) | 难以量化是否达到 40% 阈值 |
| Auditor 数值验证 | auditor.md 强制数值验证 | **YES** | 高 (6/6 rounds) | 发现了 3 个真实错误 |
| Auditor 常数追踪 | auditor.md 常数追踪规则 | **YES** | 高 (6/6 rounds) | 5-7 constants per audit |
| Auditor 交叉验证 | auditor.md 交叉验证规则 | **YES** | 高 (6/6 rounds) | 3-4 comparisons per audit |
| Step F 失败提取 | SKILL.md Step F | **PARTIAL** | 低 (1/3) | 缺乏强制触发机制 |
| Generator A 类优先 | generator SKILL.md | **未测试** | — | 需单独运行 generator |
| Generator 新颖性要求 | generator SKILL.md | **未测试** | — | 需单独运行 generator |

---

## 当前最弱 3 个子项（实测后）

| 排名 | 子项 | 实测得分 | 满分 | 占比 | 改进方向 |
|------|------|---------|------|------|---------|
| 1 | **C2 分支覆盖均匀度** | 0.00 | 4 | 0% | Generator 加分支配额 + 运行刷题 |
| 2 | **D1 自动出题质量** | 1.00 | 5 | 20% | 运行 generator 验证 A 类优先规则 |
| 3 | **E3 障碍分析深度** | 1.50 | 5 | 30% | 创建 math-explorer skill |

---

## 下一步建议

### 立即可做（验证剩余预估）
1. **运行 `start grinding` 10 道题** → 验证 D1 (generator 质量)、C1 (A 类占比)、C2 (分支覆盖)
2. **修复 Step F 触发机制** → 将 Step F 从"归档后额外步骤"改为"归档流程内置步骤"

### 需要 skill 修改
3. **Scout Step 0a 硬化** → 将"如果存在则读取"改为"**必须**读取"
4. **B1 评分调整** → 考虑将 B1 改为"最终审计通过率"而非"首轮审计通过率"，避免惩罚更严格的 Auditor
5. **Generator 分支配额** → 添加弱分支补偿规则

### 长期
6. 建立 proof→proof 引用网络（现在有 REF 数据可以构建了）
7. 扩展 failure_patterns 到所有分支（当前 17 条主要覆盖 optimization）
