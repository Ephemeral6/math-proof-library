# 三原语 Ablation 结果 — boundary_interior, 87 cases

**Date**: 2026-05-01
**Domain**: boundary_interior（Pick's theorem：A = I + B/2 − 1）
**Cases**: 87 个 (P, P') pair（8 个预制多边形 × {add_vertex, translate, shear, scale_non_uniform} + 10 个 cross-pair compare）
**Counterfactual**: 3 个，全部 critical（boundary_relaxation = 非 lattice；operation_perturbation = unimodular shear vs non-uniform scale；condition_removal = 自交多边形）
**Evaluator**: Claude Opus 4.7（self-rating），单次评估
**Target theorem**: Pick 定理 + "边界决定内部"的离散 Stokes/Green 论断

---

## 评分量表

| 分数 | 标签 | 操作化 |
|-----:|------|-------|
| 0 | NO_SIGNAL     | 没从数据中提取关于机制的 hypothesis |
| 1 | WRONG_PATTERN | 提出被数据反驳的 pattern |
| 2 | PATTERN       | 正确的结构观察，无论证 |
| 3 | ARGUMENT      | 条件 → 结论的推理链 |
| 4 | PROOF         | 完整可验证证明 |

---

## 结果矩阵

```
                        Contrastive OFF          Contrastive ON
                    ┌─────────────────────┬─────────────────────┐
Transform OFF       │                     │                     │
  Relation OFF      │  000: 1 PATTERN−    │  00C: 3 ARGUMENT    │
  Relation ON       │  R00: 3 ARGUMENT    │  R0C: 4 PROOF       │
                    ├─────────────────────┼─────────────────────┤
Transform ON        │                     │                     │
  Relation OFF      │  0T0: 3 ARGUMENT    │  0TC: 3 ARGUMENT    │
  Relation ON       │  RT0: 4 PROOF       │  RTC: 4 PROOF       │
                    └─────────────────────┴─────────────────────┘
```

详细评估见 `evaluations/{条件}.md`。

---

## 主效应

| 因子 | ON 平均 | OFF 平均 | 主效应 |
|------|--------:|---------:|-------:|
| **R**  | (R00+R0C+RT0+RTC)/4 = (3+4+4+4)/4 = **3.75** | (000+0T0+00C+0TC)/4 = (1+3+3+3)/4 = **2.50** | **+1.25** |
| **T**  | (0T0+0TC+RT0+RTC)/4 = (3+3+4+4)/4 = **3.50** | (000+R00+00C+R0C)/4 = (1+3+3+4)/4 = **2.75** | **+0.75** |
| **C**  | (00C+R0C+0TC+RTC)/4 = (3+4+3+4)/4 = **3.50** | (000+R00+0T0+RT0)/4 = (1+3+3+4)/4 = **2.75** | **+0.75** |

**结论**：R 主效应显著最强（+1.25）；T 和 C 等强（+0.75）。R 是 Pick 定理证明的关键原语。

---

## 交互效应

- **R × T**: RT0 − max(R00, 0T0) = 4 − 3 = **+1**（**超加性！**）
- **R × C**: R0C − max(R00, 00C) = 4 − 3 = **+1**（**超加性！**）
- **T × C**: 0TC − max(0T0, 00C) = 3 − 3 = **0**
- **R × T × C**: RTC − max(RT0, R0C, 0TC) = 4 − 4 = **0**

> **两个超加性：R × T 和 R × C，都是 +1**。R 单独是 ARGUMENT；任何与 R 配对（无论 T 还是 C）都跨过 PROOF 门槛。

但 T × C 没有超加性——0T0 和 00C 都是 ARGUMENT，0TC 仍然是 ARGUMENT（不到 PROOF）。这说明**没有 R 时，T 和 C 互补但都缺一个关键信号**：边界结构（per-edge gcd 分解）。

---

## 关键发现

### 1. R 是 Pick 的"门槛原语"

Pick 定理的核心是**边界数据 → 内部计数**。要构造完整证明，需要：
- (a) Shoelace 公式：边界 → A（顶点坐标 → 面积）。
- (b) gcd 求和：边界 → B（每条边的 gcd → 边界格点数）。
- (c) Pick 公式：A、B → I。

(a) 和 (b) 都是**结构推导**——需要 R 提供顶点坐标、每条边的 direction 和 gcd。T 给的是 trace 的 (A, B, I) 数值，*不暴露边界结构*；C 给的是应用域和 det 准则，*也不暴露边界结构*。

因此：
- 没有 R 时（000, 0T0, 00C, 0TC），最多只能 *经验验证* Pick 公式，达 ARGUMENT。
- 有 R 时（R00, RT0, R0C, RTC），可以 *结构推导* 边界 → A、B，加上三角剖分归纳 → PROOF。

### 2. T × C 不超加 = Pick 是"结构性"而非"等价性"命题

knot_theory 中 T × C 不超加（C 主效应 +0.75 但与 T 配对无增益），因为 knot 的核心问题（R2 invariance）需要 R 提供的代数结构。
graph_connectivity 中 T × C 超加 +1，因为 bridge ⇔ disconnect 是经验等价命题，T 给标签 + C 给概念定义就够了。
boundary_interior 中 T × C 不超加，因为 Pick 是结构等式，T 给数值 + C 给应用域仍然不够——必须有 R 给的边界几何结构才能 *推导* 而非 *验证*。

| Domain | T × C 超加性 | 原因 |
|---|---|---|
| graph_connectivity | +1 | bridge 是 *经验等价*；T 标签 + C 概念定义足够 |
| knot_theory        | 0  | R2 invariance 是 *代数命题*；T 退化为 R 的冗余 |
| boundary_interior  | 0  | Pick 是 *结构等式*；T 数值 + C 应用域仍缺 R 的边界几何 |

### 3. R × T 和 R × C 都超加 = R 提供 ceiling 但需要 secondary signal

R 单独是 ARGUMENT（看到边界 → A、B 的结构推导，但缺应用域和操作不变性的精确判据）：
- 加 T → 加上 87-case (A, B, I) 数值验证 + 操作分类 → 跨到 PROOF。
- 加 C → 加上 lattice/simple 应用域定义 + det 操作准则 → 跨到 PROOF。

T 和 C 在补足 R 的"应用域缺失"上各自独立有效。这与 knot_theory（C 唯一关键，T 退化）和 graph_connectivity（R 单独到顶，T、C 都冗余）形成三种不同的依赖结构。

### 4. 87 个 case 的多源一致性是 RTC 的特点

RTC 给出三条独立路径计算 A 并发现一致：
- (i) area_from_shoelace（R 用 Shoelace 公式直接算）
- (ii) area_from_pick = I + B/2 − 1（R 反推）
- (iii) trace.before_state.area（T 直接读）

三者在 87 case 上都相等。这是经验多重交叉验证，给 PROOF 提供独立证据。

但 RTC 的评分 = max(RT0, R0C) = 4，没有 3-way 超加性——因为 R 的 ceiling 已经在 RT0 / R0C 达到，多一个原语无法进一步提升评分（评分 4 是评分量表的上限）。

### 5. 数据原语角色总结（boundary_interior）

| 原语 | 角色 | boundary_interior 强度 |
|---|---|---|
| **R** | 提供边界几何（顶点 + 每条边 gcd） | **门槛原语**：单独到 ARGUMENT；与 T 或 C 配对 → PROOF |
| **T** | 提供 (A, B, I) 数值 + 操作分类 | **数值验证**：单独 ARGUMENT；与 R 配对 → PROOF |
| **C** | 提供应用域 + 操作判据 | **应用域定义**：单独 ARGUMENT；与 R 配对 → PROOF |

R 是必要原语；T 和 C 是 R 的补全器（任选一个即可）。这是 boundary_interior 区别于其他两个 domain 的关键。

---

## 跨 domain 比较（terminal 5 + terminal 6 + terminal 8）

| | graph_connectivity (Term5) | knot_theory | boundary_interior (Term8) |
|---|---|---|---|
| 目标定理 | bridge ⇔ connectivity loss | R2 invariance | Pick formula |
| 数学深度 | 等价定义 | 代数不变量 | 结构等式 |
| 000 评分 | 1 (PATTERN−) | 1 (PATTERN−) | 1 (PATTERN−) |
| RTC 评分 | 4 (PROOF) | 3 (ARGUMENT) | 4 (PROOF) |
| R 主效应 | +1.25 | +0.75 | +1.25 |
| T 主效应 | +0.75 | +0.25 | +0.75 |
| C 主效应 | +0.75 | +0.75 | +0.75 |
| 关键超加性 | T × C (+1) | R × C (+1) | R × T (+1) 和 R × C (+1) |
| 单原语到顶 | R 单独 = PROOF | 无 | 无（R 单独 = ARGUMENT） |

**核心模式**：
- **graph_connectivity**：R 占绝对主导（结构数据 *是* 答案）。
- **knot_theory**：R + C 必须配合（代数不变量需要应用域和反例的概念锚定）。
- **boundary_interior**：R 是必要门槛，T 或 C 都能补全（结构推导需要数值验证 *或* 应用域）。

这三个 domain 跨越了"维度 2 (continuous deformation)"、"维度 1 (discrete invariant)"、"维度 6 (boundary determines interior)"三种认知任务，展现了三原语依赖结构对任务结构的*敏感性*。

---

## Caveat

1. **单次自评**，未取中位数。
2. **PROOF 评分依赖外部数学知识**: Pick 公式归纳证明用三角剖分论证，这是标准结果但不在数据里。这与 graph_connectivity 的 PROOF（双向论证完全可由数据驱动）有质的区别——boundary_interior 的 PROOF 是"数据 + 经典证明"组合。
3. **CF 只在 rectangle_4x3 上**: 与 graph_connectivity / knot_theory 同样的工程取舍。
4. **没有自交多边形 / 非 lattice 多边形 case**: 87 case 都在 Pick 应用域内。CF (1)、CF (3) 是仅有的 out-of-domain 数据点。
5. **8 个预制多边形是凸 + 简单的代表，缺更复杂的非凸+多孔多边形**: Pick 在带孔多边形上有变体（A = I + B/2 − χ，χ 是欧拉示性数）。本实验未覆盖这一推广。

---

## 完成情况

- [x] Step 1: BoundaryInteriorEngine + PolygonObject 实现 + 自测（8 presets 全部通过 Pick）
- [x] Step 2: PolygonCounterfactualGenerator (boundary_relaxation, operation_perturbation, condition_removal)
- [x] Step 3: 87 cases benchmark 生成（5 levels）
- [x] Step 4: 8 条件 ablation 数据 + 8 prompt 生成
- [x] Step 5: 8 条件 self-evaluation + 主效应 / 交互分析 + 跨 domain 对比

下一步：与其他维度的实验（terminal 1-4, 6, 7）合并到统一 SpatialMind 报告中。
