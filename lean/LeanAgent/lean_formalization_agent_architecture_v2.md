# Lean Formalization Agent 完整架构设计

**作者**：潘冠成（浙江大学竺可桢学院）
**日期**：2026-04-28
**版本**：v2.0

---

## 一、设计哲学

### 1.1 第一原则

本系统的第一原则不是"证明某个定理"，而是**搭建可持续增长的形式化数学基础设施**。每一次形式化运行的产出，不仅是一段能编译的 Lean 代码，更是一批符合 Mathlib 标准的、可被未来任意证明 import 复用的数学组件。

### 1.2 三条核心约束

1. **最小假设原则**：每个 lemma 只假设它真正需要的最少条件，最大化适用范围
2. **最大抽象原则**：用 typeclass 泛型而非具体类型，确保 `ℝⁿ` 上证的东西在任意 `InnerProductSpace` 上也能用
3. **库级质量原则**：产出的代码不只是"能编译"，而是符合 Mathlib 命名约定、文档标准、lint 规范，可直接提 PR

### 1.3 与 Math Agent 的关系

本系统（Lean Agent）与已有的多智能体数学证明系统（Math Agent）是**独立但可对接的两个系统**。

**当前阶段（MVP）**：完全割裂。两个系统各自独立运行、独立评测。Lean Agent 的输入是任意自然语言证明（不一定来自 Math Agent），输出是 Lean 代码。Math Agent 不知道下游会不会做形式化，Lean Agent 不知道上游是谁。

**未来目标**：深度集成。Math Agent 产出证明 → Lean Agent 形式化验证 → 编译失败反馈回 Math Agent 修正 → 端到端闭环。但集成深度取决于 MVP 阶段的数据（详见第十七节）。

**接口约定**：两个系统之间的唯一连接是一个标准化的 markdown 格式结构化证明文件。格式定义见附录 A。

---

## 二、整体流水线

```
输入：结构化自然语言证明（markdown 格式）

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        Lean Formalization Agent
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Stage 0: Architect        ← 纯自然语言，不碰 Lean
Stage 1: Decomposer       ← 纯自然语言，不碰 Lean
Stage 2: Aligner          ← NL → Lean 签名
Stage 3: Skeleton Builder ← Lean 骨架（全 sorry）
Stage 4: Tactic Filler    ← 逐个关闭 sorry
Stage 5: Verifier         ← 三重硬性检查
Stage 6: Linter           ← Mathlib PR 标准检查

    ↓ 产出
沉淀层（持久化知识资产）
Maintenance Agent（后台守护）
Metrics Dashboard（度量看板）

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

输出：
  - 编译通过、零 sorry、语义对齐的 Lean 代码
  - 沉淀的可复用知识资产
  - 度量数据
  - [RESERVED] 失败反馈文件（供未来与 Math Agent 对接）
```

---

## 三、Stage 0：Architect（架构师）

**输入**：结构化自然语言证明
**输出**：模块化证明蓝图（DAG + 文件结构 + 并行标注 + 复用性评估）
**环境**：纯自然语言，不启动 Lean 编译器

### 3.1 依赖分析

扫描证明中引用的所有外部定理，对每个定理做三路判定：

| 判定 | 含义 | 动作 |
|------|------|------|
| `[MATHLIB]` | Mathlib 中已有 | 记录全限定名，直接 import |
| `[REGISTRY]` | 本项目 registry 中已有 | 记录路径，直接 import |
| `[NEW]` | 两处都没有 | 标记为需新建的 lemma |

判定方式：
- LLM 语义搜索 Mathlib 文档
- 对 registry 中已有 lemma 的自然语言摘要做向量检索
- 对不确定的，在 Lean 中用 `exact?` 试探性测试

### 3.2 模块拆分

将证明拆成独立 lemma。每个 lemma 的设计遵循**复用优先**原则：

**最小假设**：如果 lemma 只需要 `LipschitzWith L (gradient f)` 就够了，不要加 `ConvexOn ℝ univ f`，即使当前证明碰巧是凸的。假设越少，lemma 能被调用的场景越多。

**最大抽象**：不写 `f : ℝ³ → ℝ`，写 `{E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]`。这样同一个 lemma 既能用在 ℝⁿ 上也能用在 Hilbert 空间上。

**自包含接口**：每个 lemma 的 statement 不依赖于其他 lemma 的内部构造细节，只依赖于它们的 signature。

**复用潜力评估**：对每个 `[NEW]` lemma，评估其独立复用价值：

```
lemma_1: descent_lemma
  statement: L-smooth 函数的二次上界
  假设: [LipschitzWith L (gradient f)]
  结论: f(y) ≤ f(x) + ⟨∇f(x), y-x⟩ + (L/2)‖y-x‖²
  抽象层级: InnerProductSpace ℝ E（泛型）
  复用潜力: [高] — 几乎所有一阶优化证明都需要
  Mathlib 状态: 无精确等价；Mathlib 有 Convex.norm_image_sub_le_of_norm_deriv_le 但假设更强
```

### 3.3 DAG 构建与并行标注

将 lemma 之间的依赖关系建成有向无环图（DAG）。标注每条边的类型：

- **hard dependency**：B 的 statement 中直接引用了 A 的结论 → 必须先证 A
- **soft dependency**：B 的证明中用到了 A 的某个中间技巧，但可以用其他方式替代 → 可以并行

对 DAG 做拓扑排序，标注哪些 lemma 处于同一层级（无相互依赖），可以并行处理。

输出示例：

```
DAG:
  Layer 0: [lemma_A, lemma_B, lemma_C]   ← 并行
  Layer 1: [lemma_D (dep: A, B)]          ← 等 A, B 完成
  Layer 2: [main_theorem (dep: all)]      ← 最后

并行标注:
  lemma_A ∥ lemma_B ∥ lemma_C    # 完全独立
  lemma_D ← lemma_A, lemma_B     # 串行等待
```

### 3.4 文件结构规划

根据 DAG 决定 Lean 项目布局：

```
ProjectName/
  Basic/
    Definitions.lean     -- 基础定义（函数类、oracle 模型等）
    Properties.lean      -- 定义的基本性质
  Lemmas/
    LemmaA.lean          -- 独立 lemma，import Basic
    LemmaB.lean          -- 独立 lemma，import Basic
    LemmaC.lean          -- 依赖 LemmaA，import Basic + LemmaA
  Main.lean              -- 主定理，import 所有 Lemmas
```

约束：
- 单文件不超过 300 行（避免 Lean 编译超时，M2F 的经验教训）
- import 链严格线性或树形，禁止循环
- namespace 与文件名一致

### 3.5 质量门

- DAG 无循环依赖
- 每个 lemma 的假设确实是最小的（尝试逐条去除，看 statement 是否仍然有意义）
- 没有遗漏证明中隐式使用的中间步骤
- 每个 `[NEW]` lemma 有复用潜力评估

---

## 四、Stage 1：Decomposer（分解器）

**输入**：Stage 0 的 DAG + 原始证明
**输出**：每个 lemma 的原子步骤序列
**环境**：纯自然语言，不启动 Lean 编译器

### 4.1 原子步骤拆解

对 DAG 中每个 lemma，将其证明拆成原子步骤。粒度标准：每个原子步骤大致对应 1-3 个 Lean tactic。

对每个步骤，显式回答四个问题：

1. **前提**：用到了哪些已知的 have？
2. **结论**：这步得到什么？
3. **方法**：直接计算 / 应用定理 / 反证 / 分情况讨论？
4. **外部定理**：如果引用了外部定理，完整前提是什么？本题是否满足？

输出示例：

```
lemma_2 (Le Cam two-point) 证明步骤：

  step 1: 定义 P+ = N(α, σ²), P- = N(-α, σ²)
    前提: α, σ 已给定
    结论: 两个概率测度 P+, P-
    方法: 直接构造

  step 2: 计算 KL(P+ ‖ P-) = 2α²/σ²
    前提: step 1 的 P+, P-
    结论: KL 散度的精确值
    方法: 高斯分布 KL 的闭式公式
    外部定理: KL of Gaussians
      完整前提: P+, P- 是同方差的高斯分布
      验证: ✓（两者方差都是 σ²）

  step 3: TV(P+, P-) ≤ √(KL/2)
    前提: step 2 的 KL 值
    结论: 总变差的上界
    方法: 应用 Pinsker 不等式
    外部定理: Pinsker inequality
      完整前提: P+, P- 是概率测度
      验证: ✓

  step 4: Le Cam 下界 ...
```

### 4.2 模板匹配

检索 Decomposition Templates 库，看当前 lemma 的证明结构是否匹配已有模板：

| 模板 | 典型结构 | 对应 Math Agent MT |
|------|----------|--------------------|
| Lyapunov + Telescope | 定义势函数 → 单步下降 → telescope 求和 → 除以 T | MT1 |
| Le Cam Two-Point | 定义两分布 → 算 KL → Pinsker → 误判概率 → 下界 | MT6 |
| Contradiction | 假设结论不成立 → 推出矛盾 → 得证 | — |
| Induction | base case → inductive step → 结论 | — |
| Spectral Decomposition | 分解到特征空间 → 逐分量分析 → 合并 | MT8 |

命中模板 → 直接填参数，跳过大部分拆解工作。未命中 → 从零拆解，完成后评估是否应存为新模板。

### 4.3 质量门

- 拆解后的步骤序列能重组回原始证明（无遗漏、无跳步）
- 每个"应用外部定理"的步骤显式验证了前提条件
- 任何一步如果预估对应超过 5 个 Lean tactic → 标记为"需进一步拆分"

---

## 五、Stage 2：Aligner（对齐器）

**输入**：Stage 0 的 DAG + Stage 1 的原子步骤
**输出**：所有 lemma 的 Lean theorem 签名（proof = sorry）
**环境**：启动 Lean 编译器

### 5.1 签名生成

对每个 lemma，生成 Lean theorem 声明。关键决策：

- 变量用 implicit `{}` 还是 explicit `()`
- typeclass instance 用 `[]` 自动推断
- 假设用 `(h : ...)` 具名（方便后续 have 链引用）
- 结论类型精确匹配 Stage 0 的 statement

### 5.2 Back-Translation 对齐检查

对每个 Lean theorem 声明，执行双向验证：

```
原始 NL statement
       ↓ LLM 翻译
Lean theorem 签名
       ↓ 另一个 LLM 翻译回 NL
Back-translated NL statement
       ↓ 逐条对比
原始 NL statement
```

检查点：
- 假设是否多加了？（如偷加 `[FiniteDimensional ℝ E]`）
- 假设是否遗漏了？
- 结论是否弱化了？（如 `∀` 变成 `∃`）
- 结论是否强化了？（可能导致不可证）
- 类型是否正确？（如实数写成自然数）

不一致 → LLM 修正 → 重新编译 → 重新 back-translate → 循环直到对齐。

### 5.3 编译验证

全部签名写入对应 `.lean` 文件，`lake build` 编译。只允许 sorry warning，不允许任何 error。

### 5.4 质量门

- `lake build` 零 error
- back-translation 全部对齐
- 所有 typeclass instance 能自动推断

---

## 六、Stage 3：Skeleton Builder（骨架构建器）

**输入**：Stage 2 编译通过的签名 + Stage 1 的原子步骤
**输出**：每个 lemma 的 have 链骨架（全 sorry）
**环境**：Lean 编译器

### 6.1 Have 链生成

将每个原子步骤翻译成 Lean 的 `have` 语句：

```lean
theorem example_lemma (h1 : ...) (h2 : ...) : conclusion := by
  -- step 1: [自然语言描述作为注释]
  have h3 : [step 1 结论的 Lean 类型] := by sorry
  -- step 2: [自然语言描述]
  have h4 : [step 2 结论] := by sorry
  -- final: 组装最终结论
  exact sorry
```

每个 `have` 的自然语言注释保留，方便后续调试和人工审查。

### 6.2 类型推断修复循环

编译 → 类型错误 → 根据 error message 修正 have 的类型 → 重新编译 → 循环。

常见问题及修复模式：
- `type mismatch` → 检查 have 的类型声明与实际推断类型的差异
- `unknown identifier` → 检查 import 或变量名拼写
- `failed to synthesize` → 补 typeclass instance 或添加 `[CompleteSpace E]` 等

### 6.3 质量门

- `lake build` 通过，warning 只有 sorry
- have 链的顺序与 Stage 1 的原子步骤一一对应
- 每个 have 的注释与对应原子步骤的自然语言描述一致

---

## 七、Stage 4：Tactic Filler（策略填充器）

**输入**：Stage 3 的骨架
**输出**：零 sorry 的完整证明
**环境**：Lean 编译器

### 7.1 调度策略

**跨 Lemma**：按 DAG 拓扑序。同一层级的独立 lemma 并行处理，有依赖关系的串行等待。

**Lemma 内部**：按 have 链顺序串行填充（因为后续 sorry 的 goal state 可能依赖前面的结果）。

### 7.2 Goal Classifier

对每个 sorry 的 goal state，先做分类，选择最可能成功的策略顺序：

| Goal 模式 | 首选策略 |
|-----------|---------|
| 等式 `⊢ a = b` | `ring` → `field_simp; ring` → `simp` → LLM |
| 不等式 `⊢ a ≤ b` | `linarith` → `gcongr` → `positivity` → LLM |
| 存在性 `⊢ ∃ x, P x` | `exact ⟨..., ...⟩` → `use ...` → LLM |
| 集合/元素 `⊢ x ∈ S` | `simp` → `exact mem_of_...` → LLM |
| 逻辑连接 `⊢ P ∧ Q` | `constructor` → 拆分后递归 |
| 函数性质 `⊢ Continuous f` | `fun_prop` → `exact ...` → LLM |
| 其他 | 查 Playbook → LLM |

分类器基于 goal state 的 pattern matching + 历史 Playbook 统计。

### 7.3 四轮尝试

**第一轮：自动搜索**

```
exact? → apply? → simp? → omega → linarith → ring →
norm_num → positivity → fun_prop → aesop
```

直接关掉 → 记录到 Playbook → 下一个 sorry。

**第二轮：LLM 生成**

将以下信息喂给 Claude：
- 当前 goal state（Lean 编译器提供）
- Stage 1 对应的自然语言原子步骤描述（hint）
- Playbook 中类似 goal 的历史成功 tactic（few-shot）
- Mathlib 中可能相关的 lemma（语义搜索结果）

Claude 生成 tactic 序列 → 编译 → 报错 → 根据 error message 修正 → 再编译。最多 5 次迭代。

**第三轮：递归拆分**

将当前 sorry 拆成两个更小的 `have` + `sorry`：

```lean
-- 原来：
have h : A := by sorry  -- gap 太大

-- 拆成：
have h_mid : B := by sorry  -- 中间步骤
have h : A := by            -- 用 h_mid 证 A
  sorry                      -- gap 更小
```

对新产生的 sorry 递归回到第一轮。最大递归深度 3 层。

**第四轮：标记 STUCK**

如果递归拆分也失败：
1. 标记该 sorry 为 `STUCK`
2. 记录完整失败信息：goal state、尝试过的所有 tactic、每次的 error message
3. 存入 Failure Registry
4. 输出失败反馈文件（标准化格式）
5. 跳过，继续处理下一个 sorry
6. `[RESERVED — 阶段三决定是否启用]` 将反馈文件发送给 Math Agent 触发重新 Explore

### 7.4 计算预算控制

每个 sorry 的 Filler 有计算预算：

| 轮次 | 预算 | 超时动作 |
|------|------|---------|
| 第一轮（自动搜索） | ≤ 30 秒 | 进入第二轮 |
| 第二轮（LLM 5 次迭代） | ≤ 5 分钟 | 进入第三轮 |
| 第三轮（递归拆分 3 层） | ≤ 15 分钟 | 进入第四轮 |
| 第四轮（标记 STUCK） | 即时 | 跳过 |

### 7.5 质量门

- 全部 sorry 关闭（或标记为 STUCK）
- `lake build` 零 error
- STUCK 数量报告（0 STUCK = 完全成功）

---

## 八、Stage 5：Verifier（验证器）

**输入**：Stage 4 的代码
**输出**：CERTIFIED / PARTIAL（有 STUCK）/ FAIL
**环境**：Lean 编译器 + LLM

### 8.1 三重硬性检查

**检查 1：零 sorry**
```bash
grep -rn "sorry" ProjectName/ | grep -v "^--"  # 排除注释
# 结果必须为空
```

**检查 2：零非标准 axiom**
```lean
#print axioms main_theorem
-- 只允许：propext, Classical.choice, Quot.sound
-- 任何额外 axiom → FAIL
```

**检查 3：语义对齐复核**

在最终代码上重新跑 Stage 2 的 back-translation 检查。确保 Stage 4 的 Filler 没有在修 sorry 的过程中偷偷改动了 theorem 签名。

### 8.2 判定逻辑

```
三检全过 + 0 STUCK     → CERTIFIED
三检全过 + N STUCK > 0  → PARTIAL（报告 STUCK 列表）
任一检查失败            → FAIL（报告失败原因）
```

---

## 九、Stage 6：Linter（代码规范检查）

**输入**：CERTIFIED 的代码
**输出**：符合 Mathlib PR 标准的代码 + PR 就绪报告
**环境**：Lean 编译器

### 9.1 自动检查

```bash
lake lint  # Mathlib 官方 linter
```

检查项：
- `simp` lemma 是否标注了 `@[simp]`
- docstring 是否存在且格式正确
- 命名是否符合 `snake_case` + statement 缩写约定
- unused variable warning
- 不必要的 `open` 或 `import`
- 代码风格（缩进、空行、行长度）

### 9.2 自动修复

对 linter 报出的问题，LLM 自动修复：
- 缺 docstring → 根据 statement 自动生成
- 命名不规范 → 按 Mathlib 约定重命名（同时更新所有引用）
- 缺 `@[simp]` → 根据 lemma 形式判断是否应该加

### 9.3 PR 就绪评估

最终确认：
- 代码能否独立于当前项目存在（不依赖项目特有定义）→ 可提 PR
- 是否填补了 Mathlib 的已知空白 → 有 PR 价值
- 是否与 Mathlib 已有 lemma 重复 → 不提 PR

符合条件的 lemma 标记为 `[PR-READY]`，输出 PR 草稿（含 commit message + 说明文档）。

---

## 十、沉淀层（持久化知识资产）

每次形式化运行完成后，以下资产自动存入持久化存储：

### 10.1 Definition Registry（定义库）

```
registry/definitions/
  LSmooth.lean              -- L-smooth 函数定义 + 基本性质
  StronglyConvex.lean       -- 强凸函数
  StochasticOracle.lean     -- 随机梯度 oracle 模型
  HeavyBall.lean            -- SHB 迭代定义
```

每个定义文件包含：
- Lean 定义代码
- 自然语言摘要（用于语义搜索）
- 与 Mathlib 已有定义的关系（扩展 / 特化 / 独立）
- 使用记录（被哪些证明引用过）

### 10.2 Lemma Registry（引理库）

```
registry/lemmas/
  descent_lemma.lean
  pinsker_inequality.lean
  kl_gaussian.lean
```

每个 lemma 包含：
- 完整 Lean 证明
- 自然语言摘要
- 最小假设列表
- 抽象层级标注
- 复用记录
- PR 状态（`[PR-READY]` / `[SUBMITTED]` / `[MERGED]` / `[NOT-PR-WORTHY]`）

### 10.3 Decomposition Templates（分解模板库）

```
templates/
  le_cam_two_point/
    template.md            -- 自然语言分解模板
    skeleton.lean           -- 对应的 Lean 骨架（have 链 + sorry）
    params.json             -- 可填充的参数槽位
    usage_count: 5          -- 被使用次数
  lyapunov_telescope/
    ...
```

与 Math Agent 的 meta_templates 一一对应，但额外包含 Lean 骨架。

### 10.4 Translation Pairs（翻译配对库）

```
pairs/
  pair_001.json:
    { "nl": "若 f 是 L-smooth 的，则 f(y) ≤ f(x) + ⟨∇f(x), y-x⟩ + (L/2)‖y-x‖²",
      "lean": "theorem descent_lemma {E : Type*} [NormedAddCommGroup E] ...",
      "difficulty": "medium",
      "domain": "convex_optimization",
      "tactic_count": 15 }
```

用于新翻译的 few-shot 检索。按 domain 和 difficulty 索引。

### 10.5 Tactic Playbook（策略手册）

```
playbook/
  entries.jsonl:
    { "goal_pattern": "⊢ ‖a + b‖ ≤ ‖a‖ + ‖b‖",
      "successful_tactic": "exact norm_add_le a b",
      "success_count": 15,
      "fail_count": 0,
      "domain": "analysis",
      "avg_time_ms": 200 }
```

按 goal pattern 索引，附成功/失败统计供 Goal Classifier 使用。

### 10.6 Failure Registry（失败记录库）

```
failures/
  fail_001.json:
    { "goal": "⊢ Measurable (fun x => f (x + t))",
      "tried": [
        {"tactic": "exact Measurable.comp hf measurable_add_const",
         "error": "type mismatch: expected Borel measurable, got Lebesgue measurable"},
        {"tactic": "simp [Measurable]",
         "error": "simp made no progress"}
      ],
      "root_cause": "Mathlib 中 Measurable.comp 要求 Borel 可测而非 Lebesgue 可测",
      "workaround": "先用 ae_measurable 再 lift",
      "resolved": true,
      "date": "2026-04-28" }
```

---

## 十一、Maintenance Agent（维护代理）

后台守护进程，保障沉淀层资产的长期健康。

### 11.1 Mathlib 版本兼容性检查

```
频率：每周一次

流程：
  1. 更新 Mathlib 到最新 commit
  2. 对 registry/ 中所有 .lean 文件跑 lake build
  3. 编译失败的文件 → 收集 error messages
  4. LLM 搜索 Mathlib git log，定位 API 变更记录
  5. 自动修复（改名、调整参数、更新 import）
  6. 修复成功 → 更新 registry + 记录变更
  7. 修复失败 → 标记为 [BROKEN]，输出报告
```

### 11.2 Registry 去重与清理

```
频率：每月一次

流程：
  1. 对 registry 中所有 lemma 做语义相似度检查
  2. 高度相似的 → 标记为候选合并项
  3. 与 Mathlib 新增 lemma 对比
  4. 如果 Mathlib 已收录等价 lemma → 标记为 [DEPRECATED]，改为 import Mathlib 版本
  5. 输出清理报告
```

### 11.3 Playbook 统计更新

```
频率：每次形式化运行后

流程：
  1. 更新每个 tactic pattern 的成功率和平均耗时
  2. 成功率持续为 0 的条目 → 标记为 [INEFFECTIVE]
  3. 新发现的高频成功模式 → 提升 Goal Classifier 优先级
  4. 更新 Goal Classifier 的分类规则
```

---

## 十二、Metrics Dashboard（度量看板）

### 12.1 核心指标

| 指标 | 定义 | 目标趋势 |
|------|------|----------|
| **复用率** | 新证明中从 registry import 的 lemma / 总 lemma 数 | ↑ |
| **首轮通过率** | Stage 4 第一轮自动搜索关闭的 sorry / 总 sorry 数 | ↑ |
| **平均递归深度** | sorry 需要的平均递归拆分层数 | ↓ |
| **NL 回退率** | 需要标记为 STUCK 的 sorry / 总 sorry 数 | ↓ |
| **Mathlib 覆盖率** | registry 覆盖目标数学领域 Mathlib lemma 的比例 | ↑ |
| **端到端时间** | 从 NL 证明输入到 CERTIFIED 的总时钟时间 | ↓ |
| **PR-READY 率** | 产出的 lemma 中符合 Mathlib PR 标准的比例 | ↑ |

### 12.2 飞轮效应预期

```
证明 #1:   复用率  0%,  首轮通过 20%,  端到端 ~8h,   STUCK 30%
证明 #5:   复用率 30%,  首轮通过 35%,  端到端 ~5h,   STUCK 20%
证明 #10:  复用率 50%,  首轮通过 45%,  端到端 ~3h,   STUCK 12%
证明 #20:  复用率 70%,  首轮通过 55%,  端到端 ~2h,   STUCK  5%
证明 #50:  复用率 85%,  首轮通过 65%,  端到端 ~1h,   STUCK  2%
```

### 12.3 报告格式

每次形式化运行结束后自动生成一份 metrics 报告，包含：
- 本次运行的各项指标
- 与历史平均值的对比
- 趋势图（如果有足够历史数据）
- 新增的沉淀资产清单
- STUCK 清单及建议修复方式

---

## 十三、并行化策略

### 13.1 跨 Lemma 并行（Stage 4）

```
DAG Layer 0: [A, B, C]   → 并行启动 3 个 Filler
DAG Layer 1: [D(←A,B)]   → A, B 完成后启动
DAG Layer 2: [Main(←all)] → 全部完成后启动
```

### 13.2 跨证明并行

多个证明同时形式化时：
- Stage 0-3 完全并行（各自独立）
- Stage 4 中共享的 `[NEW]` lemma 只证一次，其他证明等待结果后 import
- 沉淀层写入加锁（避免并发写冲突）

### 13.3 计算预算汇总

| 资源 | 单个 sorry | 单个 lemma（~10 sorry） | 单个证明（~5 lemma） |
|------|-----------|----------------------|-------------------|
| 第一轮 | ≤ 30s | ≤ 5min | ≤ 25min |
| 第二轮 | ≤ 5min | ≤ 50min | ≤ 4h |
| 第三轮 | ≤ 15min | ≤ 2.5h | ≤ 12h |
| 含并行优化 | — | — | ≤ 4h（3x 加速） |

---

## 十四、与现有系统的对比

| 特性 | DSP | APOLLO | ALA | HILBERT | M2F | **本系统** |
|------|-----|--------|-----|---------|-----|-----------|
| 输入来源 | LLM 草稿 | LLM 代码 | LLM | LLM | 教科书 LaTeX | **任意 NL 证明** |
| NL 架构设计 | 无 | 无 | 无 | 无 | 原子块排序 | **DAG + 文件规划** |
| NL 分解阶段 | 草稿级 | 无 | 无 | 子目标 | 无 | **原子步骤 + 模板** |
| 复用性设计 | 无 | 无 | 无 | 无 | 无 | **最小假设 + 泛型** |
| 声明对齐 | 无 | 无 | 无 | 无 | 人工 | **自动 back-trans** |
| 失败处理 | 无 | 修复 | 有 | 递归 | VeriRefine | **四轮 + STUCK 标记** |
| 跨证明学习 | 无 | 无 | 无 | 无 | 无 | **六层沉淀** |
| 并行化 | 无 | 无 | 无 | 无 | 无 | **DAG 驱动** |
| 版本维护 | 无 | 无 | 无 | 无 | 无 | **Maintenance Agent** |
| 库级质量 | 无 | 无 | 无 | 无 | 无 | **Linter + PR-READY** |
| 度量体系 | 无 | 无 | 无 | 无 | 无 | **7 指标 Dashboard** |
| 自我进化 | 无 | 无 | 无 | 无 | 无 | **飞轮效应** |

---

## 十五、实施路线图

### Phase 1：MVP（2 周）

**目标**：证明 pipeline 端到端可行

**实现**：
- Stage 2 (Aligner) + Stage 3 (Skeleton) + Stage 4 (Filler，仅第一二轮) + Stage 5 (Verifier)
- 不实现 Stage 0, 1（手动提供原子步骤）
- 不实现沉淀层（不做持久化）

**测试**：optlib 已有的 GD 收敛率证明（有 ground truth 对比）

**成功标准**：能从手动提供的原子步骤生成编译通过、零 sorry 的 Lean 代码

### Phase 2：完整 Pipeline（4 周）

**目标**：端到端自动化 + 初始沉淀

**实现**：
- 加入 Stage 0 (Architect) + Stage 1 (Decomposer)
- 加入沉淀层前三项（Definition Registry + Lemma Registry + Tactic Playbook）
- Stage 4 加入第三轮（递归拆分）

**测试**：optlib 已有的 5 个不同证明，观察复用率变化

**成功标准**：
- 5 个证明全部 CERTIFIED
- 证明 #5 的复用率 > 证明 #1

### Phase 3：基础设施增强（4 周）

**目标**：库级质量 + 维护能力

**实现**：
- Stage 6 (Linter) + Maintenance Agent
- 完整沉淀层（六层全部）
- 并行化调度
- Metrics Dashboard

**测试**：OP-2 的某个子 lemma（如 descent lemma 或 Goujaud cycling）

**成功标准**：
- 产出 PR-READY 的代码
- Maintenance Agent 能自动适配 Mathlib 更新

### Phase 4：Research-Level + 集成评估（持续）

**目标**：处理 research-level 证明 + 评估与 Math Agent 的集成价值

**实现**：
- 用完整 pipeline 形式化 OP-2
- 收集 STUCK 数据，评估 NL 回退的价值
- 根据数据决定是否启用与 Math Agent 的反馈回路

**成功标准**：
- OP-2 完整形式化
- 集成决策有数据支撑

---

## 十六、开放问题

1. **Goal Classifier 冷启动**：Playbook 为空时依赖硬编码规则。可能从 Mathlib 的 tactic 使用统计中 bootstrap。

2. **递归拆分终止条件**：什么时候该停止拆分、承认当前能力做不了？需要一个基于 goal 复杂度的难度估计。

3. **Back-translation 可靠性**：LLM 做 Lean→NL 翻译也可能出错。可用两个独立 LLM 做 back-translation 后交叉对比。

4. **跨项目复用**：registry 资产如何在不同 Lean 项目之间共享？长期可能需要发布为独立的 Lean package（类似 optlib）。

5. **与 Mathlib 的关系**：长期目标是贡献 lemma 到 Mathlib，但 review 标准极高且流程慢。策略：先在独立 registry 积累，定期批量提 PR。

6. **多模型协作**：当前底座是 Claude，但 Goal Classifier 可能受益于专用的 Lean prover 模型（如 Goedel-Prover）。是否引入双模型架构（通用 LLM + 专用 prover）？参考 HILBERT 和 ALA 的双模型设计。

---

## 十七、与 Math Agent 的集成策略

### 17.1 当前阶段：完全割裂

两个系统独立运行、独立评测。唯一的连接是标准化的 markdown 证明文件。

**Lean Agent 独立评测方案**：
- 输入：optlib 已有证明的自然语言版本
- 输出：Lean 代码
- 评测：与李晨毅手写版本对比（编译成功率、代码行数、tactic 选择）

**Math Agent 独立评测方案**：
- 输入：IMProofBench 题目
- 输出：自然语言证明
- 评测：作者人工评分（0-3 分）

### 17.2 松耦合对接阶段

Math Agent 输出 → 标准化 markdown → Lean Agent 输入。

观察数据：
- Lean Agent 的 STUCK 率是否与 Math Agent 的 NL Auditor PASS 率相关？
- STUCK 的 sorry 对应的自然语言步骤，NL Auditor 是否标记为可疑？
- 将 STUCK 信息手动反馈给 Math Agent 后，修正成功率多高？

### 17.3 深度集成决策

根据松耦合阶段的数据，做以下决策：

| 观察结果 | 决策 |
|---------|------|
| STUCK 频繁 + 反馈修正成功率高 | 启用自动反馈回路，深度集成 |
| STUCK 频繁 + 反馈修正成功率低 | 问题在 Lean 翻译层面，强化 Lean Agent 内部能力 |
| STUCK 很少 | NL Auditor 已经足够好，保持松耦合 |

### 17.4 深度集成架构（预留）

```
Math Agent                          Lean Agent
                                    
Scout → Explorer ×6 → Judge         
    ↓                                
NL Auditor (快速初筛)                
    ↓ PASS                           
    ├─────────────────────→ Architect → ... → Filler
    │                                    ↓
    │                               编译成功 → CERTIFIED
    │                               编译失败 → 反馈文件
    │                                    ↓
    ← ← ← ← ← ← ← ← ← ← ← ← ← 反馈回路
    ↓                                
Fixer (根据 Lean 反馈修正)           
    ↓                                
重新进入 NL Auditor                  
    ↓ PASS                           
    ├─────────────────────→ 重新进入 Lean Agent
    ...                              
```

反馈文件格式：

```json
{
  "type": "STUCK",
  "lean_goal": "⊢ Measurable (fun x => f (x + t))",
  "nl_step": "由 f 的可测性和平移不变性得 x ↦ f(x+t) 可测",
  "attempts": [...],
  "diagnosis": "NL 步骤跳过了 Borel vs Lebesgue 可测性的区分",
  "suggestion": "请在自然语言证明中显式区分 Borel 可测和 Lebesgue 可测"
}
```

**此架构仅为预留设计，MVP 阶段不实现。**

---

## 附录 A：标准化证明文件格式

两个系统之间传递的 markdown 文件必须遵循以下格式：

```markdown
# [定理名称]

## Statement

[定理的精确自然语言陈述，包含所有假设和结论]

## Assumptions

- [假设 1]
- [假设 2]
- ...

## Conclusion

[精确结论]

## Proof

### Step 1: [步骤标题]

[步骤内容]

**Uses**: [引用的外部定理或前面的步骤编号]

### Step 2: [步骤标题]

...

## External Theorems Referenced

- [定理 1 名称]: [完整陈述]
- [定理 2 名称]: [完整陈述]
```

此格式确保 Lean Agent 能从中提取所有形式化所需的信息，不依赖于上游是 Math Agent 还是人工撰写。
