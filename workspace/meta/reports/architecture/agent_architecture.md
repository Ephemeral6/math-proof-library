# Math Agent System — 完整架构报告

> 生成日期：2026-04-11  
> 数据来源：~/.claude/skills/math-* SKILL.md、prompts/*、CLAUDE.md、INDEX.md、proofs/、workspace/ 审计报告

---

## 1. 系统总览

Math Agent 是一个基于 Claude Code 的自动化数学证明系统，专注于 AI/ML 理论方向的研究级定理证明。系统由 6 个 Claude Code Skills 组成，以五阶段证明流程（Scout → Explorer → Judge → Auditor → Fixer）为核心引擎，配合对象构造器、符号验证器和自动出题引擎，形成完整的"出题→证明→审计→归档"闭环。所有编排通过 Claude Code 的 Agent tool 实现上下文隔离和并行执行，不使用任何外部脚本或子进程。

**当前状态：** 证明库包含 36 道已完成证明，覆盖 6 个数学分支，整体可信度 HIGH（0 常数错误，78% 测度论 CLEAN，85% 常数可追踪）。系统从 2026-04-02 开始运行，最近一次大规模自动出题在 2026-04-11（单日 13 道）。

---

## 2. Skills 架构图

### 2.1 Skills 总览

```
                          用户输入
                            │
                   ┌────────▼────────┐
                   │  math-dispatcher │  ← 中央路由器
                   │  (当前模型)       │
                   └──┬─────┬─────┬──┘
                      │     │     │
           ┌──────────▼┐  ┌▼──────────┐  ┌▼──────────────┐
           │math-prover│  │math-      │  │math-verifier   │
           │(alias)    │  │constructor│  │(Sonnet+Python) │
           └─────┬─────┘  │(Opus)    │  └───────▲────────┘
                 │        └──▲───────┘          │
                 ▼           │                  │
        ┌────────────────┐   │   [CALL:math-constructor]
        │math-proof-agent│───┘   [CALL:math-verifier]
        │(五阶段核心引擎) │─────────────────────┘
        └───────▲────────┘
                │
     ┌──────────┴──────────┐
     │math-problem-generator│  ← 自动刷题引擎
     │(无限循环)             │
     └──────────────────────┘
```

### 2.2 各 Skill 详情

| Skill | 触发条件 | 功能 | 模型 | 调用关系 |
|-------|---------|------|------|---------|
| **math-dispatcher** | 任何数学问题（proof/construction/verification） | 分类问题类型和难度，路由到对应引擎 | 当前模型 | 调用 → proof-agent, constructor, verifier |
| **math-proof-agent** | "prove/proof/theorem/lemma/conjecture/derivation" | 五阶段证明流程（核心引擎） | Sonnet + Opus（见下表） | 被 dispatcher/generator 调用；通过 CALL markers 调用 → verifier, constructor |
| **math-prover** | 显式调用 "math-prover" | math-proof-agent 的别名/增强入口 | 同 proof-agent | 委托给 → proof-agent |
| **math-constructor** | "construct/find/build 数学对象" | 构造满足条件的数学对象（反例、Lyapunov 函数等） | Opus（构造）+ Python（验证） | 被 proof-agent 通过 `[CALL:math-constructor]` 调用 |
| **math-verifier** | "verify/check/validate 数学声明" | SymPy 符号验证 / Z3 不等式验证 / NumPy 数值实验 | Sonnet（生成脚本）+ Python（执行） | 被 proof-agent 通过 `[CALL:math-verifier]` 调用 |
| **math-problem-generator** | "start grinding/开始刷题/auto prove/启动出题器" | 自动生成 research/conjecture 级题目并调用五阶段流程 | 继承 proof-agent 的模型分配 | 调用 → proof-agent |

### 2.3 CALL Marker 机制

Explorer 和 Auditor 阶段的 Agent 输出可以包含内联调用标记：

- `[CALL:math-verifier] {表达式或声明}` → 主编排器拦截，生成验证脚本并执行，注入结果为 `[RESULT from math-verifier]: PASS/FAIL - {details}`
- `[CALL:math-constructor] {构造规格}` → 主编排器拦截，构造对象并验证，注入结果为 `[RESULT from math-constructor]: {定义} - Verified: PASS/FAIL`

**验证模式自动选择：**
- 等式/恒等式/极限/级数 → SymPy 符号验证
- 不等式/约束 → Z3（失败回退 NumPy）
- 一般声明 → SymPy + NumPy（≥10,000 样本）

---

## 3. 五阶段证明流程详解

### Phase 1: SCOUT（路线分析）

| 属性 | 值 |
|------|---|
| **Prompt 文件** | `~/.claude/skills/math-proof-agent/prompts/scout.md` |
| **模型** | Sonnet（快速分析） |
| **输入** | 问题陈述（problem.md） |
| **输出** | `work_dir/routes.md` — 3-5 条多样化证明路线 |
| **Agent 数量** | 1 |

**每条路线包含：** Route name、Key idea（2-3 句核心思路）、Required tools（需要的数学工具）、Estimated difficulty（easy/medium/hard/very hard）、Potential pitfalls

**关键规则：**
- 只分析路线，不尝试证明
- 路线必须多样化（不同方法/工具）
- 最有希望的路线排在前面

**Scout 完成后进行难度评估，决定后续资源分配：**

| 难度 | Explorer 并行数 | 最大 Audit 轮数 |
|------|----------------|----------------|
| standard | 2 | 1 |
| advanced | 3 | 2 |
| research | 4 | 3 |
| conjecture | 5 | 3 |

### Phase 2: EXPLORE（证明撰写）

| 属性 | 值 |
|------|---|
| **Prompt 文件** | `~/.claude/skills/math-proof-agent/prompts/explorer.md` |
| **模型** | Opus（深度推理） |
| **输入** | 问题陈述 + 分配的路线（来自 Scout） |
| **输出** | `work_dir/proof_route_N.md`（N = 1, 2, 3, ...） |
| **Agent 数量** | 2-5（按难度，**全部并行启动**） |

**关键规则：**
1. 严格遵循分配的路线，不能切换
2. 每一步必须有充分的 justification
3. 所有关键不等式和等式需要详细推导
4. 引用定理时必须标注名称和条件
5. 路线失败时，说明障碍所在
6. 可通过 `[CALL:math-verifier]` 和 `[CALL:math-constructor]` 请求中途验证/构造

**成功输出格式：** `## Proof` + 逐步推导 + Q.E.D.  
**失败输出格式：** `## Route Failure Report` + 失败位置 + 障碍说明

### Phase 3: JUDGE（评估选拔）

| 属性 | 值 |
|------|---|
| **Prompt 文件** | `~/.claude/skills/math-proof-agent/prompts/judge.md` |
| **模型** | Sonnet（快速比较） |
| **输入** | 所有 Explorer 的证明尝试 |
| **输出** | `work_dir/evaluation.md` + `work_dir/best_proof.md` |
| **Agent 数量** | 1 |

**评分标准（每项 /10，总分 /40）：**
- Completeness（完整性）
- Correctness（正确性）
- Elegance（优雅性）
- Gaps（缺口，越少越好）

**关键规则：**
- **必须**在 "## Best proof full text" 部分粘贴完整的最佳证明原文（不是摘要）
- 如果所有路线全部失败：提取建议的新方向，回到 Phase 1 重试（最多 1 次重试）

### Phase 4: AUDIT（严格审计）

| 属性 | 值 |
|------|---|
| **Prompt 文件** | `~/.claude/skills/math-proof-agent/prompts/auditor.md` |
| **模型** | Opus（严格检查） |
| **输入** | 最佳证明（best_proof.md） |
| **输出** | `work_dir/audit_round_N.md` |
| **Agent 数量** | 1 |

**审计输出：**
- 每步标记 VALID 或 INVALID + 理由
- 问题按严重性分级：HIGH / MEDIUM / LOW
- 即使正确，也要识别至少 3 个需要确认的点

**验证标注系统：**
- `[VERIFIED:sympy]` — 通过 SymPy 验证
- `[VERIFIED:z3]` — 通过 Z3 验证
- `[VERIFIED:numerical]` — 通过数值验证
- `[NEEDS-VERIFY]` → 触发 `[CALL:math-verifier]`
- `[UNVERIFIABLE]` — 需要纯逻辑审查

**决策：**
- 全部 VALID 且无 HIGH/MEDIUM 问题 → **PASS**，生成 Final Report
- 任何 INVALID 或 HIGH/MEDIUM 问题 → 进入 Phase 5

### Phase 5: FIX（修复）

| 属性 | 值 |
|------|---|
| **Prompt 文件** | `~/.claude/skills/math-proof-agent/prompts/fixer.md` |
| **模型** | Opus（深度推理） |
| **输入** | 最佳证明 + 最新审计报告 |
| **输出** | `work_dir/fixed_round_N.md`（更新 best_proof.md） |
| **Agent 数量** | 1 |

**关键规则：**
1. 修复审计中的每个问题
2. 不引入新错误
3. 保持整体结构
4. 输出完整的修复后证明

**循环：** Fix → Audit → Fix → ...（最多按难度等级限制的轮数）  
**超出轮数：** 使用当前最佳版本生成 Final Report

### 模型分配总表

| 阶段 | 角色 | 模型 | 理由 |
|------|------|------|------|
| Scout | 路线分析 | **Sonnet** | 快速，分析性任务 |
| Explorer | 证明撰写 | **Opus** | 需要深度数学推理 |
| Judge | 评估选拔 | **Sonnet** | 快速比较评估 |
| Auditor | 严格审计 | **Opus** | 需要严格检查 |
| Fixer | 修复缺陷 | **Opus** | 需要深度推理修复 |

### 输出文件清单

| 文件 | 描述 |
|------|------|
| `problem.md` | 输入问题副本 |
| `routes.md` | Scout 输出：3-5 条路线 |
| `proof_route_1.md` ... `proof_route_N.md` | Explorer 输出 |
| `evaluation.md` | Judge 评分报告 |
| `best_proof.md` | 提取的最佳证明（Fix 后更新） |
| `audit_round_N.md` | 各轮审计输出 |
| `fixed_round_N.md` | 各轮修复输出（如有） |
| `final_report.md` | 最终综合报告 |

---

## 4. 自动刷题引擎

### 4.1 触发方式

- "start grinding" / "开始刷题"
- "auto prove" / "自动证明"
- "start generator" / "启动出题器"

### 4.2 出题范围（6 个方向轮换）

| # | 方向 | 子方向 |
|---|------|-------|
| 1 | **优化/收敛分析** | GD/SGD/momentum/Nesterov 收敛率，Adam/AdaGrad/AMSGrad 分析，非凸一阶方法，分布式/联邦优化，SVRG/SAGA/SPIDER/STORM |
| 2 | **学习理论** | PAC/VC/Rademacher，泛化界，在线学习 regret，Bandit regret，核方法/RKHS |
| 3 | **深度学习理论** | NTK 结果，过参数化全局收敛，Transformer/Attention 数学性质，近似理论定量版/depth separation，隐式正则化 |
| 4 | **概率与统计** | 集中不等式（Bernstein/sub-Gaussian/matrix），高维估计（LASSO/sparse recovery），随机矩阵，Langevin/MCMC 采样收敛 |
| 5 | **凸分析与对偶** | Fenchel/Lagrangian 对偶，近端/分裂方法（ADMM/Douglas-Rachford），Bregman/镜面下降，鞍点/minimax |
| 6 | **强化学习理论** | 策略梯度收敛，Q-learning/TD 有限时间分析，探索-利用 regret，线性 MDP 样本复杂度 |

### 4.3 难度分布

- **70% research**（研究级已知定理）
- **30% conjecture**（开放或近开放问题）
- **绝不出** standard 或 advanced

### 4.4 执行流程

```
初始化: problem_count=0, success_count=0, fail_count=0, direction=1

循环:
  1. 读 INDEX.md，检查已有证明（去重）
  2. 选择方向：
     - 正常：按 direction 轮流 1→2→3→4→5→6→1→...
     - 连续失败 3 道：跳到下一个不同方向
     - 优先填充 INDEX.md 中证明较少的方向
  3. 生成 research/conjecture 级题目（完整定理陈述，LaTeX，自包含）
  4. 创建 workspace/active/proof_work_YYYYMMDD_HHMMSS/
  5. 调用 math-proof-agent 五阶段流程
     - research: 4 Explorer 并行, 最多 3 轮 Audit
     - conjecture: 5 Explorer 并行, 最多 3 轮 Audit
  6. 成功 → CLAUDE.md 归档流程 → proofs/ + INDEX.md
     失败 → workspace/archive/failed_*
  7. 更新计数，每 5 道打印完整进度
  8. 回到 1
```

### 4.5 去重机制

出题前读 INDEX.md，不出与已有证明重复或过于相似的题。

### 4.6 约束

- **绝对禁止搜索任何文献/论文/网页**，所有证明纯靠数学推理
- 每道题限时 1 小时
- 单个 Explorer 超过 10 分钟无响应视为失败
- 所有文件 UTF-8 编码

### 4.7 已知问题（来自深度审计）

1. **ADMM 两题几乎重复** — full-rank 版本和一般版本结论相同，证明结构高度相似
2. **难度标注过于均匀** — 10 道自动题全标 research，实际跨度从本科级（Hoeffding）到真正的 research 级（Matrix Bernstein）
3. **无 conjecture 级挑战** — 自动题全部是已有定理复现，未生成推广性猜想

---

## 5. 目录管理与归档

### 5.1 完整工作流（CLAUDE.md 定义）

```
用户输入 "prove [theorem]"
        │
        ▼
[1] 创建 workspace/active/proof_work_YYYYMMDD_HHMMSS/
[2] 保存 problem.md
[3] 执行五阶段证明流程
[4] 证明完成后 → 自动归档（不询问）
        │
        ├── 成功路径：
        │   [A] 确定分支（optimization/convergence 等 17 个分支）
        │   [B] 创建 proofs/{branch}/{kebab-case-name}/
        │       ├── problem.md   （定理陈述 + Source + Difficulty）
        │       ├── proof.md     （最终干净证明）
        │       ├── report.md    （五阶段完整报告）
        │       ├── notes.md     （证明技巧 + 关键步骤 + 相关结果）
        │       └── failed_attempts/  （失败路线的证明）
        │   [C] 更新 INDEX.md（添加行 + 更新 total）
        │   [D] 移动工作目录到 workspace/archive/
        │   [E] 打印归档确认
        │
        └── 失败路径：
            移动到 workspace/archive/failed_*
            不创建 proofs/ 条目
            打印失败原因和建议
```

### 5.2 分支分类体系

| 大分支 | 子分支 |
|--------|-------|
| optimization | convergence, adaptive-methods, lower-bounds, stochastic, mirror-descent |
| learning-theory | generalization, pac, rademacher, stability |
| convex-analysis | duality, kkt, subgradient |
| statistics | concentration, high-dimensional |
| linear-algebra | （无子分支） |
| probability | （无子分支） |

### 5.3 指令映射

| 用户指令 | 动作 |
|---------|------|
| "prove [theorem]" / "证明 [定理]" | 启动完整证明工作流 |
| "archive this" | 手动触发最近证明的归档 |
| "show index" / "看看目录" | 显示 INDEX.md |
| "what have we proved about [topic]" | 搜索 proofs/ 中相关定理 |
| "clean up" | 将 workspace/active/ 中的过期目录移至 archive/ |

### 5.4 文件约定

- 文件名：kebab-case 英文
- 文件内容：中英文均可
- 编码：UTF-8
- 路径：文档中使用正斜杠
- 工作目录：`proof_work_YYYYMMDD_HHMMSS` 格式

---

## 6. 证明库现状

### 6.1 总量

- **proofs/ 目录实际文件夹数：36**
- **INDEX.md 记录条目数：36**
- **INDEX.md 声明 total：36**
- **一致性：完全一致**

### 6.2 各分支分布

| 分支 | 数量 | 占比 |
|------|------|------|
| optimization/convergence | 6 | 17% |
| learning-theory/generalization | 5 | 14% |
| optimization/stochastic | 4 | 11% |
| convex-analysis/subgradient | 4 | 11% |
| statistics/concentration | 4 | 11% |
| statistics/high-dimensional | 2 | 6% |
| probability | 2 | 6% |
| learning-theory/pac | 2 | 6% |
| optimization/mirror-descent | 1 | 3% |
| optimization/lower-bounds | 1 | 3% |
| optimization/adaptive-methods | 1 | 3% |
| linear-algebra | 1 | 3% |
| learning-theory/stability | 1 | 3% |
| learning-theory/rademacher | 1 | 3% |
| convex-analysis/duality | 1 | 3% |
| **Total** | **36** | **100%** |

**大分支汇总：**
- Optimization: 13 (36%)
- Learning Theory: 9 (25%)
- Statistics: 6 (17%)
- Convex Analysis: 5 (14%)
- Probability: 2 (6%)
- Linear Algebra: 1 (3%)

### 6.3 难度分布

| 难度 | 数量 | 占比 |
|------|------|------|
| research | 29 | 81% |
| advanced | 5 | 14% |
| conjecture | 2 | 6% |

### 6.4 时间分布

| 日期 | 数量 | 备注 |
|------|------|------|
| 2026-04-02 | 7 | 首批手动证明 |
| 2026-04-04 | 1 | |
| 2026-04-05 | 2 | |
| 2026-04-07 | 2 | |
| 2026-04-08 | 5 | 含首批 generator 输出 |
| 2026-04-09 | 6 | generator 高产出 |
| 2026-04-11 | 13 | 最大单日产出 |

### 6.5 质量指标（来自深度审计，基于 27 道被审计的证明）

| 维度 | 结果 |
|------|------|
| 测度论/技术条件 CLEAN | 21/27 (78%) |
| 测度论/技术条件 MINOR | 5/27 (19%) |
| 测度论/技术条件 GAP | 1/27 (4%) — 已修复 |
| 常数 TIGHT | 23/27 (85%) |
| 常数 LOOSE | 1/27 (4%) — SPS-SGD (4x gap, 已承认) |
| 常数 ERROR | 0/27 (0%) |
| 自动出题自洽性 | 10/10 (100%) |
| 自动出题题-证一致性 | 10/10 (100%) |
| **整体可信度** | **HIGH** |

---

## 7. 已知问题清单

### 来自深度审计报告（deep_audit_report.md）

| 优先级 | 问题 | 证明 | 状态 |
|--------|------|------|------|
| ~~HIGH~~ | ~~Score-of-mixture identity 缺 Leibniz/DCT 条件~~ | ~~Denoising Score Matching~~ | **已修复 (2026-04-11)** |
| MEDIUM | epsilon-net lemma 和 sub-exponential 表征跳过 | Sub-Gaussian Covariance | 未修复 |
| LOW | problem.md 声称 cL/(2T) vs 证明得到 2cL/T | SPS-SGD | 未修复（已在证明中承认差异） |
| LOW | 两道几乎相同的 ADMM 题 | ADMM Full-Rank / ADMM Ergodic | 未修复（建议合并） |

### 来自质量报告（quality_report.md）

| 优先级 | 问题 | 数量 | 状态 |
|--------|------|------|------|
| ~~CRITICAL~~ | ~~denoising problem.md/report.md 严重不足~~ | ~~1~~ | **已修复** |
| ~~MODERATE~~ | ~~proof.md 缺少 QED 标记~~ | ~~5~~ | **已修复** |
| ~~MINOR~~ | ~~langevin 缺 failed_attempts/ 目录~~ | ~~1~~ | **已修复** |
| LOW | report.md 偏短（<25 行） | 4 | 未修复（功能性内容存在） |
| INFO | matrix-bernstein proof.md 27 行（压缩格式） | 1 | 无需修复（完整证明在 report.md 252 行） |

### 系统层面问题

| 优先级 | 问题 | 说明 |
|--------|------|------|
| MEDIUM | Generator 难度标注过于均匀 | 10 道自动题全标 research，实际难度跨度大 |
| MEDIUM | Generator 未产出 conjecture 级题 | 仅复现已有定理，未生成推广性猜想 |
| LOW | 9 道新证明（4/11 批次）未经深度审计 | deep_audit 覆盖 27/36，最新 9 道待审 |

---

## 8. 改进路线图

### P0 — 短期（下次会话即可做）

1. **深度审计覆盖补全**：对 2026-04-11 新增的 9 道证明运行深度审计（测度论检查 + 常数追踪）
2. **Sub-Gaussian Covariance 补充**：增加 epsilon-net lemma 和 sub-exponential 表征的显式推导
3. **SPS-SGD 常数对齐**：更新 problem.md 中的常数以匹配证明

### P1 — 中期（系统改进）

4. **Generator 难度校准**：根据证明所需技巧的复杂度，对自动出题实施更细粒度的难度评估（standard: 教科书；advanced: 研究生；research: 论文级；conjecture: 开放问题）
5. **Generator 出 conjecture**：增加"将定理 X 推广到假设 Y 下"的出题模式，生成真正的猜想级题目
6. **ADMM 合并**：将两道 ADMM 证明合并为一道，full-rank 作为可选加强假设
7. **短 report.md 补全**：对 transformer-attention-lipschitz、svrg-linear-convergence 等偏短的 report.md 补充完整五阶段格式

### P2 — 长期（架构演进）

8. **分支覆盖均衡化**：learning-theory/rademacher (1)、convex-analysis/duality (1)、optimization/adaptive-methods (1) 等单证明分支需要扩展
9. **交叉引用网络**：在 notes.md 的 Related results 中添加库内交叉链接（如 "see also: proofs/statistics/concentration/matrix-bernstein-inequality"）
10. **验证覆盖率追踪**：记录每道证明中有多少步经过了 SymPy/Z3/NumPy 验证，建立量化的"验证覆盖率"指标
11. **失败分析数据库**：从 workspace/archive/failed_* 中提取失败模式，用于改进 Scout 的路线推荐

---

*报告基于实际文件扫描生成，所有数字从 proofs/、INDEX.md、SKILL.md、quality_report.md、deep_audit_report.md 中实时读取。*
