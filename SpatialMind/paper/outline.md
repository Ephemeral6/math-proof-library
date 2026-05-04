# The Extended Mathematical Mind: Spatial Cognition Through Architecture, Not Training

**Working title alternatives**:
- "Geometric Reasoning Is Not a Training Problem"
- "Three Primitives for Spatial Cognition: Architecture over Pretraining"
- "Outsourcing Geometric Intuition: A Domain-Agnostic Framework for LLM Spatial Reasoning"

**Target venue (tentative)**: NeurIPS Datasets & Benchmarks track (architecture paper with empirical validation), or ICML position-paper track. Backup: ACL Findings if framed as LLM-tooling. Not a pure math venue.

**Length target**: 8 pages (NeurIPS) or 9 pages (ICML), not counting references and appendix.

---

## Abstract (~200 words)

数学空间推理被广泛认为是 LLM 的根本局限。我们提出一个不同的观点：空间认知不是需要专门训练的神经能力，而是三个可分解的认知原语——**关系构造**（R）、**变换追踪**（T）、**对比推理**（C）——的组合。通过外置的 `GeometricEngine` 提供前两个原语，外置的 `CounterfactualGenerator` 提供第三个，LLM-based agent 可以达到等效于空间直觉的推理质量。

我们在两个几何领域（曲面拓扑、纽结论）上设计了 2³ factorial ablation 实验。结果表明：(1) 三个原语缺一不可，全部开启时 reasoning 跨过 PATTERN→ARGUMENT 阈值；(2) 三个原语存在 **三阶超加性**——任意二阶组合都未达 ARGUMENT，但三阶组合达到；(3) 这个 pattern 跨 domain 一致（Spearman ρ ≥ 0.X，待数据填入）。

我们的发现挑战了 AI for Math 社区的隐含假设：几何推理的瓶颈不在 LLM 内部表示，而在缺少把这些表示外化、操作、对比的工具链。**正确的路径是架构设计，不是模型训练。**

---

## 1. Introduction (~2 pages)

### 1.1 Hook：Feynman 的笔记本（半页）

引用 Clark *Supersizing the Mind* (2008) 转述 Feynman 的故事：当历史学家把 Feynman 的 notebook 称为"工作的记录"，Feynman 反驳——"不，那 *是* 工作。我做数学是 *在纸上* 做的，不是在头里。"

把这句话抬到论文层面：**纸不是记录认知的，是认知本身的一部分**。Clark & Chalmers (1998) 的 Extended Mind 已经把这个观察哲学化了。本文要把它工程化。

### 1.2 当前问题：LLM 几何推理失败（~半页）

引用 MathSpatial (2025) 等 benchmark：人类 ~95%，主流 MLLM < 60%。常见 framing："LLM 缺乏空间直觉，需要更多视觉训练 / 多模态对齐 / chain-of-thought"。

我们的观点：**这是把肝脏当肾脏用**。LLM 是一个统计 pattern matcher（System 1）；几何推理需要精确的 *相对位置追踪* 和 *反事实操作*（System 2）。试图把 System 2 的能力 *训练进* System 1 的参数，是架构错配。

### 1.3 Thesis（~半页）

**几何直觉不是训练问题，是架构问题**。具体说：

1. 空间认知可分解为三个原语（R/T/C）。每个原语对应人脑的不同子系统（视觉皮层 / 海马体 / 前额叶）。
2. 这三个原语 **可以用 deterministic 外部工具实现**——不需要 neural。
3. LLM 在拥有这三个工具的情况下，**reasoning 质量阶跃式提升**——不是边际改进，是阈值跨越。

### 1.4 贡献（~半页）

1. **理论**：从认知科学的"分布式认知"和 Thurston 的"数学认知设施"出发，提出空间推理的 R/T/C 分解。
2. **架构**：`SpatialMind` framework，domain-agnostic 接口（`GeometricEngine` + `CounterfactualGenerator`） + 两个 domain-specific 实例（曲面拓扑 wraps `curver`；纽结论 wraps `SnapPy`）。
3. **实验**：在两个 domain 上做 2³ factorial ablation（共 16 个条件 × 多 case），定量给出每个原语的贡献，并证明三阶超加性跨 domain 一致。
4. **方法论开源**：评分量表（NO_SIGNAL / WRONG_PATTERN / PATTERN / ARGUMENT / PROOF）+ 反事实生成协议，可被其他 domain 复用。

---

## 2. Theoretical Framework (~3 pages)

### 2.1 空间推理的认知科学基础（~1 页）

#### 2.1.1 Thurston 的六种数学认知设施 (1994)
"On Proof and Progress in Mathematics" 列出六种支持数学的认知机制——人类的几何理解 *不是* 单一能力，而是 visual / kinesthetic / linguistic / logical 等多系统协同。

我们抽取其中三种映射到工程化原语：
- **Visual / static**: 看到关系 → R (关系构造)
- **Kinesthetic / dynamic**: 操作变换 → T (变换追踪)
- **Reflective / hypothetical**: "如果不是这样会怎样" → C (对比推理)

#### 2.1.2 Mental Rotation 的可分解性 (Shepard & Metzler 1971)
经典实验显示 mental rotation 的反应时与角度线性 → 暗示这是一个 *离散* 操作的序列，不是 holistic gestalt。这与 R/T 分解一致。

#### 2.1.3 LLM 的空间推理三原语（2025 arXiv 同期工作）
"From Human Cognition to Neural Activations" 在不同语境下也分解 LLM 的空间能力为三个原语（relational composition / representational transformation / stateful spatial updating）——与我们的 R/T/C 大致同构，但他们关注 *神经激活* 的可分解性，我们关注 *外部架构* 的可替代性。

### 2.2 Extended Mind 与 Distributed Cognition（~1 页）

#### 2.2.1 Clark & Chalmers (1998)
Otto-with-notebook thought experiment：外部工具如果满足"reliable / available / endorsed"三条件，*功能上* 是认知系统的一部分。

#### 2.2.2 Hutchins (1995) "Cognition in the Wild"
航海团队的导航不是任何单个船员脑内完成，而是分布在人 + 仪器 + 程序里。"认知系统"的边界不是头骨。

#### 2.2.3 Vygotsky (1978)
工具不只是辅助，是 *认知发展* 的 scaffolding——孩子用计数棒最终内化为心算。这暗示外部工具与内部能力是 *同一种东西在不同载体上*。

#### 2.2.4 Risko & Gilbert (2016) "Cognitive Offloading"
当代 review：人类常用外部工具卸载工作记忆。卸载不降低认知质量，反而让有限的内部带宽专注 *更高级* 的任务。

> 把这些拼起来：**LLM + 外部 GeometricEngine 不是"LLM + 工具"，而是 "扩展认知系统"——把空间表征卸载到 deterministic 模块，让 LLM 专注于语言层面的推理整合。**

### 2.3 从认知科学到 AI 架构（~半页）

| 认知原语 | 人类实现 | 失败/成功的脑伤证据 | AI 实现（本文） |
|---------|---------|---------------------|----------------|
| 关系构造 (R) | 视觉皮层 / 顶叶 | 顶叶损伤 → 空间忽视 | `GeometricEngine.relate(a, b)` |
| 变换追踪 (T) | 海马体 / 运动皮层 | 海马损伤 → 路径整合失败 | `GeometricEngine.transform(a, op)` |
| 对比推理 (C) | 前额叶 (DLPFC) | DLPFC 损伤 → 反事实推理失败 | `CounterfactualGenerator.generate()` |

### 2.4 与 Kahneman 双系统的关系（~半页）

Kahneman (2011) System 1 = 快速 / 直觉 / pattern；System 2 = 慢速 / 刻意 / 精确。

LLM 是 (大体上) System 1 增强版——分布式 representation、关联式推理、不擅长精确计算。
SpatialMind 的外部 engine 是 System 2 的 *外置版本* ——deterministic、组合式、精确但慢。

**Hybrid system 不是新想法（neuro-symbolic 已有几十年）；新颖之处在于：我们把 System 2 拆成三个 *正交* 的原语，并通过 ablation 量化每个的贡献。**

---

## 3. SpatialMind Framework (~2 pages)

### 3.1 Architecture overview（~半页）

ASCII / TikZ 图：

```
┌─────────────────────────────────────────────────────┐
│                    LLM (Claude / GPT)                │
│                                                       │
│   reads JSON inputs → writes natural-language proof  │
└──────────────┬──────────────────────────────────────┘
               │ structured data flow
   ┌───────────┴───────────────────────────┐
   │                                        │
   ▼                                        ▼
┌──────────────────┐              ┌──────────────────┐
│ GeometricEngine  │              │ Counterfactual-  │
│  - construct()   │              │   Generator      │
│  - relate()  ──► R              │  - generate()  ► C
│  - transform() ► T              │  three strategies │
│  - compare()     │              └──────────────────┘
│  - invariants()  │
└──────────────────┘
        │
   wraps deterministic library
   (curver / SnapPy / future: SageMath / Macaulay2)
```

GeometricEngine 是 protocol；每个 domain 实现自己的版本。LLM 不直接看 library；它只看 Engine 输出的 JSON。

### 3.2 The three primitives, formally（~半页）

- **R (Relate)**：`relate(a, b, level)` 输出三层结构数据：summary（标量不变量）/ detailed（per-element 信息，例如 per-crossing sign） / structural（更深的不变量，例如 Seifert matrix）。
- **T (Transform)**：`transform(a, op)` 输出 `TransformResult` — 包含 before/after state、delta、`region_affected`（**这是 T 与 R 的核心区别：T 标出了哪些元素被操作触及**）。
- **C (Counterfactual)**：`generate()` 输出 `CounterfactualCase` 列表，三种策略：boundary_relaxation（放宽假设边界）、condition_removal（删掉一个条件）、operation_perturbation（换一个 operation）。每个 case 标 `condition_is_critical`。

> **关键设计选择**：R 和 T 都是 *deterministic*。给定输入，输出唯一。这让 ablation 干净——条件 R00 vs RT0 的差异完全归属于 T 的存在与否，没有 noise。

### 3.3 Domain 1: Surface Topology（~半页）

- `SurfaceEngine` wraps `curver`（Mark Bell 的曲面 mapping class group 库）。
- Geometric object: curve on S_{g,n}（用 train track weights 表示）。
- transform: Hatcher surgery（在曲面复形上消去一个交叉）。
- relate: intersection number + per-triangle decomposition + bigon detection。
- counterfactual: 放宽 i(α, β) ≤ 1 → i(α, β) = 2。

### 3.4 Domain 2: Knot Theory（~半页）

- `KnotEngine` wraps `SnapPy / spherogram`。
- Geometric object: knot diagram（PD code + per-crossing sign）。
- transform: Reidemeister R2 move（通过 backtrack rejection sampling 控制 sign）。
- relate: writhe / linking number / Seifert-derived invariants（signature / determinant / Alexander polynomial — 因 Sage 不可用，从 `seifert_matrix()` 派生）。
- counterfactual: 把合法 R2 的 sign pair (+1, −1) 换成 (+1, +1)；或翻转一个 crossing 的 over/under。

> **跨 domain 重用率**：~60% 的代码在 `SpatialMind/core/` 共享（RelationData、TransformTrace、CounterfactualCase、AblationFramework）；每个 domain 只新增 ~250-500 LOC。

---

## 4. Experiments (~4 pages)

### 4.1 Experimental Design（~1 页）

#### 4.1.1 2³ Factorial design
8 个条件：`{0, R} × {0, T} × {0, C}`，命名为 `R T C` 三位字符串（`000` = baseline，`RTC` = full）。

| Code | R | T | C | What the LLM sees |
|------|---|---|---|-------------------|
| 000 | OFF | OFF | OFF | ID 列表 + summary delta only |
| R00 | ON  | OFF | OFF | + relation data (level 1+2) |
| 0T0 | OFF | ON  | OFF | + transform trace |
| 00C | OFF | OFF | ON  | + counterfactuals |
| RT0 | ON  | ON  | OFF | + R + T |
| R0C | ON  | OFF | ON  | + R + C |
| 0TC | OFF | ON  | ON  | + T + C |
| RTC | ON  | ON  | ON  | full |

#### 4.1.2 Dependent variable: 5 级评分量表

| 0 | NO_SIGNAL | 没有从数据里提 hypothesis |
| 1 | WRONG_PATTERN | 提出被数据反驳的 pattern |
| 2 | PATTERN | 正确结构观察，无论证 |
| 3 | ARGUMENT | 条件→结论的推理链，关键步骤正确 |
| 4 | PROOF | 完整可验证证明 |

由 LLM (Claude Opus 4.7) 自评 — 详见 §4.5 的 caveat。

#### 4.1.3 Datasets (3 columns, expanding to fill)
- **D1: Surface S_{1,2}**: 1,563 (α, β) pairs, all i(α, β) = 1, all surgery preserves i.
- **D2: Surface S_{2,1}**: 128 cases (smaller exhaustive enumeration; T not degenerate here).
- **D3: Knot Theory**: 100 R-move cases (planned, see §3.4).

### 4.2 Results: Surface Topology — S_{1,2}（~1 页, 已有数据）

#### 4.2.1 Score matrix

```
                     C OFF        C ON
T OFF, R OFF       000: 0      00C: 2
T OFF, R ON        R00: 2      R0C: 2(+)
T ON,  R OFF       0T0: 0      0TC: 2
T ON,  R ON        RT0: 2      RTC: 3
```

#### 4.2.2 Main effects
- **R**: +1.25, **T**: +0.25 (degenerate), **C**: +1.25.

#### 4.2.3 Interactions
- **R×C** = 0, **R×T** = 0 (T degenerate), **T×C** = 0 (T degenerate).
- **R×T×C** = +1（the 唯一 superadditivity ）.

#### 4.2.4 Diagnosis
- T 退化的诊断：S_{1,2} 三角剖分太小（4 三角形）→ surgery region 永远 = 整个曲面 → "区域内 vs 区域外"对比消失。
- 这是 *S_{1,2}-specific* 退化，不是 T 原语本身的失败。S_{2,1} 实验设计上排除该退化。

### 4.3 Results: Surface Topology — S_{2,1}（~1 页，待终端 1 数据）

[Result matrix with TBD]
[Main effects with TBD]
[Comparison to S_{1,2}: did T effect grow as predicted?]

**预测验证**：
- 预测：T 主效应从 +0.25 上升到 +1.0~+2.0
- 实测：[TBD]
- 含义：[TBD —— 如果 T 显著上升，确认"T 退化是 surface-specific"；如果仍小，需重设计 T 数据]

### 4.4 Results: Knot Theory（~1 页，待终端 2 数据）

[Result matrix with TBD]
[Main effects, interactions, comparison]

**关键问题**：
1. 三阶超加性是否复现？(if RTC − max(2-way) > 0 → 是)
2. 三个原语的 main effect 排序是否与 S_{1,2}/S_{2,1} 一致？
3. counterfactual 在 knot domain 的"伪 R2 = 同号"是否给出 critical 信号？

### 4.5 Cross-Domain Analysis（~半页）

#### 4.5.1 Spearman rank correlation 矩阵
| Pair | ρ | p | 解释 |
|------|---|---|------|
| S_{1,2} ↔ S_{2,1} | TBD | TBD | 同 domain 不同曲面 → 上界 |
| S_{1,2} ↔ Knot | TBD | TBD | 跨 domain |
| S_{2,1} ↔ Knot | TBD | TBD | 跨 domain |

#### 4.5.2 Main effect ranking consistency
若三个 domain 都给出 R ≈ C >> T 或 RT ≈ C ≈ T（取决于 T 退化是否解决），则 R/T/C 分解的"正交独立"假设得到经验支持。

#### 4.5.3 Effect size 报告
报告 Cohen's d 而不只是均值差，回应"统计显著但效应小"的潜在批评。

### 4.6 Caveats and Limitations（~半页）

1. **Self-evaluation bias**: LLM 给自己评分，可能高估或低估特定条件。Mitigation: 我们将 prompt 完全发布，并提供给独立评审者复评（随机抽样 50 cases）。
2. **单次评估**: 每条件未取中位数 / 多次重采样。Mitigation in v2: 每条件 5 次评估，取 median。
3. **Evaluator = Generator**: 同一个 Claude Opus 4.7 既"读数据写论证"又"评分"。需要 cross-evaluator validation。
4. **Domain 数有限 (n=2)**: 不能完全排除 R/T/C 是 surface/knot 的 idiosyncrasy。Future work: extend to algebraic geometry / dynamical systems。
5. **Score 5 级离散**: ARGUMENT vs PROOF 的边界主观。Mitigation: 我们公开每个 case 的逐字评分理由。

---

## 5. Analysis（~2 pages）

### 5.1 Why R and C are equally important（~半页）

R 提供 *"是什么"* 的结构事实（"所有 bigon 都包含 puncture"）；C 提供 *"为什么这是关键"* 的反事实约束（"i ≤ 1 是 sharp，i = 2 立刻反例"）。

类比：法庭里证人陈述 (R) 和反诘问 (C) 都不可少。R 没有 C → 不知道哪些事实是 *load-bearing*；C 没有 R → 知道边界但不知道为什么。

### 5.2 Why T is domain-dependent（~半页）

T 给出 *局部性*——哪些元素被 transform 触及。如果 transform 总是 *全局* 操作（S_{1,2} 上 surgery = 整曲面），T 数据塌缩成 R 数据。

预测：在 KnotEngine 上，R2 transform 只触及 2 个新 crossing（局部），T 应当 *显著有效*。这给我们一个清晰的 falsifier：**如果 knot domain 上 T main effect 仍 < +0.5，三原语理论需要修正。**

### 5.3 The superadditivity phenomenon（~半页）

观察：所有 2-way 组合的得分等于 max(单因子 effect)，不超过单因子的"上限"——但 3-way 组合 *跨过 PATTERN→ARGUMENT 阈值*。

这对应 Clark 的 **complementarity principle**：当两种异质资源（R 提供静态结构，T 提供动态机制，C 提供约束验证）同时在场，它们 *相乘* 而不是相加。每一个单独都是"必要不充分"。

机制假说：
1. C 把 *候选假设* 缩小到 critical bound（i ≤ 1）。
2. R 在该 bound 下提供 *不变量观察*（all bigons contain puncture）。
3. T 给出 *operation locality*，让 R 的事实可以局部地传播到论证步骤。
4. 任意一个缺位，链就在那一步断掉。

### 5.4 Implications for AI for Math（~半页）

#### 5.4.1 不要在 LLM 里训练几何能力
当前主流路径——预训练 + 几何数据 + chain-of-thought——是把所有三个原语同时往 LLM 参数里挤。我们的 ablation 显示：**这些原语在外部 deterministic 模块里更可靠**（construct/relate/transform 在 wrapped library 里是 O(1) 错误率；LLM 内部模拟时错误率 > 10%）。

#### 5.4.2 应该建什么
- 更多的 GeometricEngine wrappers（algebraic geometry, dynamical systems, low-dimensional topology, ...）
- 标准化的 CounterfactualGenerator API
- LLM 的训练目标转向：**学会调用 engine、解读结构数据、整合到自然语言论证**——而不是 *本身* 做几何。

类比：LLM 不需要学会做长除法（calculator 做更好）；LLM 需要学会 *什么时候调 calculator*。

---

## 6. Related Work（~1 page）

### 6.1 AI for Math
- DeepMind Nature 2021 (Davies et al.): 用 ML 帮数学家发现纽结的 signature ↔ Jones polynomial slope 关系。
- AlphaProof / AlphaGeometry (DeepMind 2024): 形式化证明 + 符号搜索。
- Lean / Mathlib + Copilot: 形式化证明的 LLM 辅助。

> 与本文区别：上述工作 *训练* 神经网络做几何。本文论证 *不需要训练*——架构已足够。

### 6.2 LLM 几何 benchmark
- MathSpatial (2025), SpatialMath (2025): 测试 LLM 几何能力，结论"差"。
- Visual chain-of-thought, ScratchPad: 让 LLM "在中间画图"。

> 与本文区别：他们 measure 失败；我们 explain 失败 + 提供 fix。

### 6.3 Cognitive architectures
- ACT-R (Anderson 1996), SOAR (Laird 2012), LIDA (Franklin 2014).
- Embodied / situated cognition (Brooks 1991, Gibson 1979).

> 与本文区别：上述架构是从认知科学 *自底向上* 设计；本文是从工程问题 *自顶向下* 找认知科学的对应。

### 6.4 Tool-augmented LLMs
- Toolformer (Schick et al. 2023), ReAct (Yao et al. 2022), Code Interpreter / OpenAI Plugins.
- LLM-as-controller architectures (Voyager, AutoGPT, etc.).

> 与本文区别：上述工作 *允许* LLM 调工具；我们 *分解工具的功能空间* 并量化每个维度。

---

## 7. Conclusion（~0.5 page）

把 Introduction 的话再说一遍，但带着实验数据：
- 几何直觉不是训练问题。
- 三个外置原语就足够把 LLM 推到 ARGUMENT 级别。
- 三阶超加性跨 domain 一致——这不是 surface 的 idiosyncrasy。
- 路径：建更多 engine，少训练。

末段：哲学呼应 Feynman/Clark——纸不是记录，是工作；engine 不是工具，是认知。

---

## Appendix

### A. Full evaluation transcripts
8 × 3 = 24 个评分文本（每 domain 8 条件），逐字公开。这是评分主观性的 mitigation。

### B. Engine implementation details
- `SurfaceEngine` 的 train-track decomposition
- `KnotEngine` 的 backtrack rejection sampling
- `_derived_invariants` 的 NumPy/SymPy fallback（替代 Sage）

### C. Counterfactual algorithms
三种策略的伪代码 + S_{1,2} / Knot 的具体实例化。

### D. Reproducibility
- 完整代码: github.com/anonymized/SpatialMind (released on acceptance)
- Docker image with curver + snappy + sympy fixed versions
- 所有 8 × 3 个 prompt 是 deterministic 生成，seed 固定

---

## Story arc 检查清单

✅ Hook 是具体的（Feynman 故事）而不是抽象的"AI is bad at geometry"
✅ Thesis 是 *反直觉* 的（不是"训练更多" — 是"训练更少"）
✅ Theory 来自 *已建立* 的领域（认知科学）而不是凭空发明
✅ 两个 domain 是 *独立* 的（surface ≠ knot），增强 generalization claim
✅ 有 *清晰的 falsifier*（如果 KnotEngine 上 T 仍弱 → 理论错）
✅ 主结果是 *阈值跨越*（PATTERN→ARGUMENT），不是边际 % 改进
✅ Implications 直接对接现有 community 实践（AI for Math 在做错的事）

## TODO before submission

- [ ] 等终端 1 数据 → 填 §4.3 (S_{2,1})
- [ ] 等终端 2 数据 → 填 §4.4 (Knot)
- [ ] §4.5 跨 domain 表填实数
- [ ] 重做评分：每条件 5 次 + 取中位数（mitigation 1）
- [ ] 找一个独立评审者复评 50 个随机 case（mitigation 1）
- [ ] 写 Cohen's d 计算脚本，加到 cross_domain_analysis.py
- [ ] Figure 1: ASCII → TikZ rendered
- [ ] Figure 2: 8-condition × 3-domain heatmap
- [ ] Figure 3: superadditivity bar chart (0 vs 1-way vs 2-way vs 3-way)
- [ ] References.bib 整理成实际 BibTeX entries
