# Math Agent 架构与能力报告 v2

> 生成日期：2026-04-16
> 数据来源：skills 文件、评估报告、证明库文件系统、迭代日志
> 扫描范围：6 个 skills、74 道证明、5 轮迭代记录、全部质量报告

---

## 1. 当前版本概述

| 项目 | 值 |
|------|-----|
| 系统版本 | V2（第 5 轮迭代后） |
| 最近更新日期 | 2026-04-15 |
| Skills 数量 | 6 (dispatcher, proof-agent, prover, constructor, verifier, problem-generator) |
| 证明库规模 | 70 道（目录实际）/ 73 道（INDEX 声明） |
| 评分体系 | 5 维度 100 分制 |
| 基线分数 | 54.91/100 |
| 预估当前分数 | 71.85/100（+16.94，待实际验证） |

### 相比 V1 的核心变化

1. **证明库分层**：从单一 `proofs/` 拆分为 `proofs/research/`（A 类）+ `proofs/library/`（B/C 类），支持引理复用
2. **Scout 三段检索**：新增 Step 0（技巧库 + 引理库 + 应用规则），路线推荐前先检索已有证明和失败模式
3. **Explorer 引理引用**：新增 `[REF: path]` 机制，复用 library/ 中已有证明，避免重复推导
4. **Auditor 交叉验证**：新增与 library/research 中同类结果的常数/率对比
5. **失败模式库扩容**：从 4 条扩充到 17 条，覆盖 9 道定理的失败路线

---

## 2. Skills 架构

### 2.1 总览

| Skill | 角色 | 模型分配 | 最后修改 | 状态 |
|-------|------|---------|---------|------|
| math-dispatcher | 中央调度 | 当前模型 | 2026-04-02 | 稳定 |
| math-proof-agent | 五阶段证明（规范源） | Scout/Judge: Sonnet, Explorer/Auditor/Fixer: Opus | 2026-04-15 | 活跃迭代 |
| math-prover | proof-agent 增强别名 | 同 proof-agent | 2026-04-02 | 稳定（委托） |
| math-constructor | 数学对象构造 | Opus | 2026-04-02 | 稳定 |
| math-verifier | 三模式验证 | Sonnet（脚本生成） | 2026-04-02 | 稳定 |
| math-problem-generator | 自动刷题引擎 | 混合 | 2026-04-15 | 活跃迭代 |

### 2.2 各 Skill 当前状态

#### math-dispatcher（调度器）
- 4 步协议：问题分析 → 执行计划 → 执行 → 合成
- 分类维度：类型（proof/construction/verification/computation）× 难度（standard/advanced/research/conjecture）× 数学域
- 路由规则：纯证明 → proof-agent，纯构造 → constructor，纯验证 → verifier，混合 → proof-agent + CALL markers
- **未改动**，基础架构已稳定

#### math-proof-agent（核心证明引擎）
- 五阶段工作流：Scout → Explorer(并行) → Judge → Audit → Fix(循环)
- **迭代 1 改动**：
  - Scout: Step 0 升级为 0a/0b/0c 三段检索（技巧库 + 引理库 + 应用规则）
  - Explorer: 新增引理引用规则 `[REF: proofs/library/xxx/proof.md]`
- **迭代 3 改动**：
  - Auditor: 新增交叉验证规则（对比 library/ 和 research/ 同类结果）
- **Step F**（归档后）：自动提取失败模式到 failure_patterns.md

#### math-constructor（构造器）
- 4 步协议：读取 prompt → Opus 构造 → Python/SymPy 验证 → 报告
- 输出三部分：LaTeX 定义 + 条件验证论证 + SymPy 验证代码
- 最大 2 轮修订
- **未改动**

#### math-verifier（验证器）
- 三模式：SymPy 符号验证、Z3 不等式验证、NumPy 数值验证（10000+ 样本）
- 自动模式选择：等式 → SymPy，不等式 → Z3 → NumPy 回退
- 优雅处理 z3 缺失
- **未改动**

#### math-problem-generator（自动出题引擎）
- 6 个轮转方向：优化/收敛、学习理论、深度学习理论、概率/统计、凸分析/对偶、强化学习理论
- **迭代 2 改动**：
  - 读取 RESEARCH_INDEX.md + LIBRARY_INDEX.md（替代旧 INDEX.md）
  - A 类优先（70% research / 30% conjecture），禁止教科书经典
  - 要求标注来源论文信息
  - 新增新颖性要求（2019-2025 论文、推广猜想、交叉定理）

### 2.3 Prompt 文件最新版本特性

| Prompt 文件 | 核心功能 | 迭代后新增特性 |
|-------------|---------|---------------|
| scout.md | 路线分析 | Step 0 三段检索（0a 技巧库、0b 引理库检索、0c 应用规则：40%+ 路线基于已验证技巧） |
| explorer.md | 证明撰写 | 引理引用规则 `[REF:]`，B/C 引理自动归档，CALL markers（verifier/constructor） |
| judge.md | 评估打分 | completeness/correctness/elegance/gaps 各 1-10，总分 /40，输出 Winner 路线号 |
| auditor.md | 严格审计 | 强制数值验证（≥2 组参数）、常数追踪表、交叉验证表、验证注解标签 |
| fixer.md | 修复缺陷 | 保持证明结构，针对 audit 指出的 INVALID 步骤修复 |
| verifier.md | 生成验证脚本 | SymPy/Z3/NumPy 三模式，自包含脚本，10000+ 样本 |
| constructor.md | 对象构造 | 三部分输出：LaTeX 定义 + 条件验证 + SymPy 代码 |

---

## 3. 证明库现状

### 3.1 分层结构

```
proofs/
├── research/              # A 类：研究级，2015+ 论文
│   ├── optimization/
│   │   ├── convergence/       (9 proofs)
│   │   ├── stochastic/        (9 proofs)  ← 含 SPIDER 2 variants
│   │   └── adaptive-methods/  (1 proof)
│   ├── learning-theory/
│   │   ├── generalization/    (9 proofs)  ← 含 NTK, Transformer, Diffusion
│   │   └── stability/         (1 proof)
│   ├── statistics/
│   │   └── high-dimensional/  (2 proofs)
│   └── convex-analysis/
│       └── subgradient/       (1 proof)
│
└── library/               # B/C 类：经典/基础结果
    ├── optimization/
    │   ├── convergence/       (10 proofs)
    │   ├── stochastic/        (2 proofs)
    │   ├── adaptive-methods/  (1 proof)
    │   ├── lower-bounds/      (1 proof)
    │   └── mirror-descent/    (1 proof)
    ├── learning-theory/
    │   ├── generalization/    (2 proofs)
    │   ├── pac/               (3 proofs)
    │   └── rademacher/        (2 proofs)
    ├── convex-analysis/
    │   ├── duality/           (2 proofs)
    │   └── subgradient/       (6 proofs)
    ├── statistics/
    │   ├── concentration/     (6 proofs)
    │   └── high-dimensional/  (1 proof)
    ├── linear-algebra/        (1 proof)
    └── probability/           (3 proofs)
```

### 3.2 A/B/C 分类统计

| 类别 | 数量 | 占比 | 存储位置 |
|------|------|------|---------|
| A 类（研究级） | 24 | 38.1% | proofs/research/ |
| B 类（经典重要） | 29 | 46.0% | proofs/library/ |
| C 类（教科书级） | 10 | 15.9% | proofs/library/ |
| **合计** | **63** | 100% | — |

> 注：proof_classification.md 记录 63 道已分类证明。目录实际含 70 道（research 32 + library 38），差异来自分类后新增的证明尚未更新分类表。INDEX 文件声称 73 道（research 31, library 42），存在计数不一致。

### 3.3 分支覆盖分布

| 一级分支 | 数量 | 占比 | 覆盖评价 |
|----------|------|------|---------|
| optimization | 33 | 52.4% | **过度集中** |
| learning-theory | 13 | 20.6% | 中等 |
| statistics | 8 | 12.7% | 偏低 |
| convex-analysis | 7 | 11.1% | 偏低 |
| probability | 2 | 3.2% | **严重不足** |
| linear-algebra | 1 | 1.6% | **严重不足** |

变异系数 CV = 1.008 → 分布极不均匀（C2 子项 = 0 分）

### 3.4 文献验证覆盖率

| 验证结果 | 数量 |
|---------|------|
| MATCH（完全一致） | 16 |
| STRONGER（比论文更强） | 2 |
| WEAKER（比论文更弱） | 3 |
| PARTIAL（部分匹配） | 2 |
| DIFFER（不同） | 1 |
| **已验证** | **24** |
| 未验证 | ~39 |

覆盖率：24/63 = 38.1%（仅 A 类近完全覆盖）

---

## 4. 五阶段流程现状

### 4.1 各阶段规则汇总

| 阶段 | 模型 | 核心规则 | V2 新增机制 |
|------|------|---------|------------|
| **Scout** | Sonnet | 提出 3-5 条路线，不写证明 | Step 0 三段检索：0a 技巧库、0b 引理库 `[REF:]`、0c 40%路线基于已验证技巧 |
| **Explorer** | Opus×N 并行 | 按分配路线写完整证明 | 引理引用 `[REF:]`、CALL markers（verifier/constructor）、BC 引理自动归档 |
| **Judge** | Sonnet | 4 维度打分 /40，选出 Winner | 输出 "**Winner: Route N**"，orchestrator 复制 best_proof.md |
| **Audit** | Opus | 逐步 VALID/INVALID | 强制数值验证（≥2 组参数）、常数追踪表、交叉验证（对比 library/research）、验证注解 |
| **Fix** | Opus | 修复 INVALID 步骤 | 循环 Audit→Fix，按难度限制最大轮数 |

### 4.2 难度自适应参数

| 难度 | Explorer 数 | 最大 Audit 轮数 |
|------|------------|----------------|
| standard | 2 | 1 |
| advanced | 3 | 2 |
| research | 4 | 3 |
| conjecture | 5 | 3 |

### 4.3 V2 新增机制详解

**CALL Marker 机制**
- Explorer 和 Auditor 中可嵌入 `[CALL:math-verifier] {payload}` 或 `[CALL:math-constructor] {payload}`
- Orchestrator 扫描输出，即时执行对应 skill，将结果注入回流程

**REF 引用机制**
- Explorer 写证明时搜索 library/ 已有引理
- 找到 → `[REF: proofs/library/xxx/proof.md]`，不重新证明
- 未找到但 BC 级 → 完整证明后自动归档到 library/

**交叉验证机制**
- Auditor 对每个最终结论，搜索 library/ 和 research/ 中同类结果
- 标记 `[ATTENTION]`（不一致）、`[NO-BASELINE]`（无可比对象）、`CONSISTENT`

**验证注解标签**
- `[VERIFIED:sympy]`, `[VERIFIED:z3]`, `[VERIFIED:numerical]`, `[NEEDS-VERIFY]`, `[UNVERIFIABLE]`

**Step F: 失败模式提取**
- 归档后自动从 failed_attempts/ 提取失败教训
- 写入 workspace/failure_patterns.md

---

## 5. 评估得分

### 5.1 基线分数（Round 0）

| 维度 | 满分 | 得分 | 占满分% |
|------|------|------|---------|
| A 证明正确性 | 30 | 24.51 | 81.7% |
| B 证明效率 | 20 | 9.80 | 49.0% |
| C 知识积累质量 | 20 | 8.60 | 43.0% |
| D 系统自主性 | 15 | 2.00 | 13.3% |
| E 研究潜力 | 15 | 10.00 | 66.7% |
| **总分** | **100** | **54.91** | **54.9%** |

### 5.2 迭代后预估分数（Round 5）

| 维度 | 基线 | 预估 | 变化 |
|------|------|------|------|
| A 证明正确性 | 24.51 | 25.10 | +0.59 |
| B 证明效率 | 9.80 | 13.00 | +3.20 |
| C 知识积累质量 | 8.60 | 11.50 | +2.90 |
| D 系统自主性 | 2.00 | 11.25 | +9.25 |
| E 研究潜力 | 10.00 | 11.00 | +1.00 |
| **总分** | **54.91** | **71.85** | **+16.94** |

> **重要说明**：预估分数基于 skill 文件修改推断，尚未通过实际运行新证明验证。

### 5.3 子项维度变化趋势

| 子项 | 基线 | 预估 | 变化 | 改进来源 |
|------|------|------|------|---------|
| A1 文献一致性 | 7.50/10 | 7.50 | 0 | 需新证明验证 |
| A2 无跳步 | 8.15/10 | 8.50 | +0.35 | Auditor 交叉验证 |
| A3 常数追踪 | 4.79/5 | 4.90 | +0.11 | 交叉验证辅助 |
| A4 技术条件 | 4.07/5 | 4.20 | +0.13 | 交叉验证辅助 |
| B1 首轮审计 | 8.15/10 | 8.50 | +0.35 | Auditor 强化 |
| B2 Explorer 成功率 | 1.65/5 | 2.00 | +0.35 | 引理引用减少重复 |
| B3 引理复用率 | 0.00/5 | 2.50 | **+2.50** | library/ 引用机制 |
| C1 A 类占比 | 3.05/8 | 4.80 | +1.75 | Generator A 类优先 |
| C2 分支覆盖 | 0.00/4 | 0.70 | +0.70 | Generator 轮转 |
| C3 文献验证 | 2.67/4 | 3.12 | +0.45 | — |
| C4 技巧词典 | 2.88/4 | 2.88 | 0 | — |
| D1 出题质量 | 1.00/5 | 4.00 | **+3.00** | Generator 规则升级 |
| D2 Scout 库利用 | 0.00/5 | 3.00 | **+3.00** | Scout 引理检索 |
| D3 失败模式 | 1.00/5 | 4.25 | **+3.25** | 17 条失败模式 |
| E1 STRONGER 数 | 5.00/5 | 5.00 | 0 | 已满分 |
| E2 Conjecture 通过率 | 4.00/5 | 4.00 | 0 | — |
| E3 障碍分析 | 1.00/5 | 2.00 | +1.00 | 失败模式中含障碍 |

### 5.4 当前最弱的 3 个子项

| 排名 | 子项 | 预估得分 | 满分 | 占比 | 瓶颈 |
|------|------|---------|------|------|------|
| 1 | **C2 分支覆盖均匀度** | 0.70 | 4 | 17.5% | optimization 独占 52%，probability/linear-algebra 严重不足 |
| 2 | **B2 Explorer 成功率** | 2.00 | 5 | 40.0% | 仅 ~33% 路线成功，高难度题尤其低 |
| 3 | **E3 障碍分析深度** | 2.00 | 5 | 40.0% | 无结构化 open problem 分析 skill |

---

## 6. 知识积累

### 6.1 技巧词典

- **规模**：36 种不同技巧
- **目标**：50 种（当前完成度 72%）
- **高频 Top 5**：

| 技巧 | 使用次数 | 覆盖分支数 |
|------|---------|-----------|
| Telescoping Sum | 13 | 4 |
| Convexity + Subgradient | 8 | 2 |
| Descent Lemma | 6 | 2 |
| Lyapunov Function | 5 | 2 |
| Chernoff/MGF Bound | 5 | 2 |

- **跨分支通用工具**：KL Divergence（4 分支）、Telescoping（4 分支）
- **高频组合模式**：Descent+Telescoping、Lyapunov+Averaging、Bregman+Three-Point、MGF+Union Bound、DV+Hoeffding

### 6.2 失败模式库

- **规模**：17 条（目标 20 条，完成度 85%）
- **覆盖定理数**：9 道
- **日期范围**：2026-04-04 到 2026-04-12
- **典型失败模式**：

| 定理 | 失败路线 | 核心教训 |
|------|---------|---------|
| Coordinate Descent | Weighted norm route | 加权范数到欧几里得范数转换丢失 n 倍因子 |
| Implicit Bias | Gradient direction route | 梯度方向收敛不够，需 per-data-point margin 追踪 |
| SAM Convergence | Lyapunov on perturbation | 在 $\tilde{x}_t$ 上构建 Lyapunov 导致常数松 10-20 倍 |
| Gradient Clipping | Standard descent lemma | 标准 descent lemma 对 clipping 失效，需 proxy stationarity |
| NTK Infinite-Width | Direct convergence routes | Schur product lemma 是关键结构洞察 |

### 6.3 交叉引用网络

- **当前状态**：未启用
- 技巧词典中记录了 proof→technique 映射，但尚未建立 proof→proof 的引用关系图
- Explorer 的 `[REF:]` 机制已就绪，但尚无实际引用记录（需运行新证明后才会产生）

---

## 7. 与 V1 的对比

### 7.1 有效改进

| 改进 | 影响维度 | 预估收益 | 评价 |
|------|---------|---------|------|
| library/ 分层 + 引理复用机制 | B3, D2 | +5.50 | **高效**：从双零到有分，基础设施改进 |
| 失败模式库扩容 4→17 | D3 | +3.25 | **高效**：回溯提取成本低，收益大 |
| Generator A 类优先规则 | D1, C1 | +4.75 | **高效**：仅修改规则文本即可改变行为 |
| Auditor 交叉验证 | A2-A4, B1 | +0.94 | **中效**：锦上添花，A 维度已高 |

### 7.2 效果低于预期的改进

| 改进 | 原因 |
|------|------|
| Scout Step 0 检索 | 技巧库和引理库内容尚少，检索收益有限；需更多积累后才能体现 |
| 迭代 5 math-explorer skill | 未完成创建，仅有障碍分析数据但无独立 skill |

### 7.3 接近上限的维度

| 维度/子项 | 当前 | 上限 | 余量 | 说明 |
|-----------|------|------|------|------|
| A3 常数追踪 | 4.79/5 | 5.0 | 0.21 | 95.8% TIGHT，接近天花板 |
| E1 STRONGER 数 | 5.00/5 | 5.0 | 0 | **已满分** |
| A2 无跳步 | 8.15/10 | 10.0 | 1.85 | 81.5% 无跳步，提升空间小 |
| A1 文献一致性 | 7.50/10 | 10.0 | 2.50 | 受限于 PDF 可获取性 |

---

## 8. 下一轮迭代建议

### 优先级 1：C2 分支覆盖（当前 0.70/4）

**问题**：optimization 占 52%，probability 和 linear-algebra 严重不足
**建议**：
- Generator 增加分支配额规则：每轮转至少 2 道 probability/linear-algebra/reinforcement-learning 题目
- 或新增"弱分支补偿"模式：连续 3 道同分支后强制切换到最弱分支

### 优先级 2：B2 Explorer 成功率（当前 2.00/5）

**问题**：仅 ~33% 路线成功
**建议**：
- Explorer 增加"checkpoint + 回退"机制：每 N 步自检，发现卡住时尝试备选子路线
- Scout 为每条路线提供"关键步骤提示"（不是完整证明，而是 2-3 个关键中间结果的方向）
- 利用失败模式库在 Explorer 启动前注入已知 pitfalls

### 优先级 3：E3 障碍分析（当前 2.00/5）

**问题**：无系统化的 open problem 分析
**建议**：
- 完成迭代 5 中未完成的 math-explorer skill 创建
- 为 conjecture 级失败案例生成结构化障碍报告（卡在哪步、已尝试了什么、可能的新方向）

### 优先级 4：实际验证

**问题**：所有预估分数（71.85）均未通过实际证明验证
**建议**：
- 立即运行 `start grinding` 生成 5-10 道新证明
- 重新评估获得实际分数
- 对比预估 vs 实际，分析哪些 skill 改动真正生效

### 优先级 5：计数一致性修复

**问题**：INDEX 声称 73 道，分类表记录 63 道，目录实际 70 道
**建议**：
- 重新扫描 proofs/ 目录，对齐 RESEARCH_INDEX.md、LIBRARY_INDEX.md、proof_classification.md 的计数
- 为新增的证明补充分类标签

---

## 附录：文件清单

### 评估文件
| 文件 | 内容 | 状态 |
|------|------|------|
| workspace/eval_round_0.md | 基线评估 54.91/100 | 完成 |
| workspace/eval_round_0_post.md | 重组后验证（无回退） | 完成 |
| workspace/eval_round_1_5.md | 迭代 1-5 综合评估 | 完成（预估） |
| workspace/iteration_log.md | 5 轮迭代日志 | 完成 |

### 质量文件
| 文件 | 内容 | 状态 |
|------|------|------|
| workspace/literature_verification.md | 24 道 PDF 文献验证 | 完成 |
| workspace/deep_audit_report.md | 4 维度深度审计 | 完成 |
| workspace/quality_report.md | 修复后质量验证 | 完成 |
| workspace/proof_classification.md | 63 道 A/B/C 分类 | 需更新（+7 道未分类） |

### 知识库文件
| 文件 | 内容 | 状态 |
|------|------|------|
| workspace/proof_techniques_summary.md | 36 种技巧 + 27 道证明卡片 | 完成 |
| workspace/failure_patterns.md | 17 条失败模式 | 活跃（目标 20） |

### 未启用的机制
| 机制 | 描述 | 所需工作 |
|------|------|---------|
| math-explorer skill | 独立探索/open problem 分析 | 需用 skill-creator 创建 |
| proof→proof 引用图 | 证明间的依赖关系网络 | 需运行新证明产生 [REF:] 记录 |
| 分支配额规则 | Generator 弱分支补偿 | 需修改 problem-generator SKILL.md |
| Explorer checkpoint 机制 | 步内自检与回退 | 需修改 explorer.md prompt |
