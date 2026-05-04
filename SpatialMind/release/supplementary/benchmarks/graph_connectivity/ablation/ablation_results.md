# 三原语 Ablation 结果 — graph_connectivity, 100 cases

**Date**: 2026-05-01
**Domain**: graph_connectivity（连通性在边删除下的相变）
**Cases**: 100 个 (G, e) pair（20 个图 × 5 次删边）。Bridge 删除 17，非 bridge 删除 83。
**Counterfactual**: 2 个，全部 critical（boundary_relaxation = 删 bridge vs 删非 bridge；operation_perturbation = 删边 vs 加边）。
**Evaluator**: Claude Opus 4.7（self-rating），单次评估。
**Target theorem**: G 连通图，e ∈ E(G)。G−e 不连通 ⇔ e 是 G 的桥。

---

## 评分量表

| 分数 | 标签 | 操作化 |
|-----:|------|-------|
| 0 | NO_SIGNAL     | 没从数据中提取关于机制的 hypothesis |
| 1 | WRONG_PATTERN | 提出被数据反驳的 pattern |
| 2 | PATTERN       | 正确的结构观察，无论证 |
| 3 | ARGUMENT      | 条件→结论的推理链 |
| 4 | PROOF         | 完整可验证证明 |

---

## 结果矩阵

```
                        Contrastive OFF          Contrastive ON
                    ┌─────────────────────┬─────────────────────┐
Transform OFF       │                     │                     │
  Relation OFF      │  000: 1 PATTERN−    │  00C: 3 ARGUMENT    │
  Relation ON       │  R00: 4 PROOF       │  R0C: 4 PROOF       │
                    ├─────────────────────┼─────────────────────┤
Transform ON        │                     │                     │
  Relation OFF      │  0T0: 3 ARGUMENT    │  0TC: 4 PROOF       │
  Relation ON       │  RT0: 4 PROOF       │  RTC: 4 PROOF       │
                    └─────────────────────┴─────────────────────┘
```

详细评估见 `evaluations/{条件}.md`。

---

## 主效应

| 因子 | ON 平均 | OFF 平均 | 主效应 |
|------|--------:|---------:|-------:|
| **R**  | (R00+R0C+RT0+RTC)/4 = (4+4+4+4)/4 = **4.00** | (000+0T0+00C+0TC)/4 = (1+3+3+4)/4 = **2.75** | **+1.25** |
| **T**  | (0T0+0TC+RT0+RTC)/4 = (3+4+4+4)/4 = **3.75** | (000+R00+00C+R0C)/4 = (1+4+3+4)/4 = **3.00** | **+0.75** |
| **C**  | (00C+R0C+0TC+RTC)/4 = (3+4+4+4)/4 = **3.75** | (000+R00+0T0+RT0)/4 = (1+4+3+4)/4 = **3.00** | **+0.75** |

**结论**：R 主效应最强（+1.25）；T 和 C 等强（+0.75）。

---

## 交互效应

- **R × T**: RT0 − max(R00, 0T0) = 4 − 4 = **0**
- **R × C**: R0C − max(R00, 00C) = 4 − 4 = **0**
- **T × C**: 0TC − max(0T0, 00C) = 4 − 3 = **+1**（**超加性！**）
- **R × T × C**: RTC − max(RT0, R0C, 0TC) = 4 − 4 = **0**

> **唯一显著超加性是 T × C**。T 单独（0T0）只能给出*operational* equivalence（is_bridge 和 connectivity_lost 这两个 trace 标签同步出现），缺少 bridge 的*结构定义*。C 单独（00C）给出 bridge 的图论概念但缺少 case-level 验证。两者合一：T 提供 100-case 等价性数据，C 提供 bridge 的结构概念，拼出完整证明。

R 不参与超加性——因为 R 单独已经达到 PROOF 上限（structural data 中的 `components_pre/post` 直接显示分裂结构）。

---

## 关键发现

### 1. R 的"先到达 ceiling"现象

R 单独就给出 PROOF，因为 `components_pre/post` 在每个 disconnect case 上**直接展示**(C_u, C_v) 的分裂——这是定理 (⇐) 方向的图形化证据。R 的存在让其他原语的边际贡献被压缩到 0。

**与 knot_theory 的对比**：knot_theory 中 R 单独只给 PATTERN（2），需要 R + C 才能 ARGUMENT（3），因为 knot 的代数不变量（signature/det/Alex）即使全保留也不能直接说明*为什么*保留。graph_connectivity 中 R 直接给出*为什么*（u, v 各在一边），所以 R 单步到顶。

### 2. T × C 超加性是 graph_connectivity 特有的发现

T 单独：只看 trace，bridge 是黑盒标签 → ARGUMENT。
C 单独：CF explanation 给概念但 1 个 demo 图覆盖不了 100 case → ARGUMENT。
T × C：T 给 100 case 等价数据，C 给 bridge 的结构定义 → PROOF。

这是 knot_theory 没观察到的交互（knot_theory 中 R × C 是唯一超加性）。原因：

| | knot_theory | graph_connectivity |
|---|---|---|
| 主信号在哪 | R 中（不变量数值） | R 中（components 列表） |
| R 单独能否到顶 | 不能（PATTERN） | 能（PROOF） |
| 关键交互 | R × C（+1） | T × C（+1） |

### 3. T 在 graph_connectivity 上*非冗余*

knot_theory 上 T 主效应弱（+0.25），因为 T 的核心信号（sign pair）与 R 的核心信号高度重叠。
graph_connectivity 上 T 主效应中等（+0.75），因为 T 与 C 的组合（T × C 超加性）实质性地推动论证。但 T 与 R 仍然冗余（R 单独达顶 ⇒ T 加上去无增益）。

→ T 的边际价值是**有 R 时为零，无 R 时为 +1（与 C 配合）**。这是一个清晰的数据原语角色：T 是 R 的廉价替代品，但需要 C 来弥补结构定义。

### 4. 数据原语角色总结

| 原语 | 角色 | graph_connectivity 强度 |
|---|---|---|
| **R** | 提供结构对象（components, bridges, articulation points） | **支配性**：单独到 PROOF |
| **T** | 提供变化轨迹（before/after, delta flags） | **辅助性**：与 C 配对到 PROOF |
| **C** | 提供概念定义和反向证据 | **概念锚定**：与 T 配对到 PROOF |

### 5. 与 knot_theory 的范式对比

graph_connectivity 测试的是"**形变过程中识别临界点**"——bridge 是删边导致 components +1 的判据。这是 dimension 2（连续形变）的核心问题。

knot_theory 测试的是"**变换下识别不变量**"——R2 保持 signature/det/Alex/writhe。这是 dimension 1（离散变换）的核心问题。

两个 domain 在数据原语的*组合方式*上展现出不同的依赖结构：
- **graph_connectivity**: structural data (R) is the answer; T+C is the alternate route.
- **knot_theory**: structural data (R) is necessary but not sufficient; R+C is the canonical route, T 退化为冗余信号。

这说明三原语框架对不同认知任务的**敏感性**不同——R 在结构判定问题上单独足够，在不变量保持问题上需要反事实补强。

---

## Caveat

1. **单次自评**，未取中位数。
2. **100 个 case 中 17 个是 bridge（17%）**：分布偏斜但足以做经验验证。如果 bridge 比例更高（如 50%），summary-only 条件 (000) 的 outcome split 会更显眼，但仍无法识别 *why*。
3. **CF 只在 1 个 demo 图（n=6）上**：与 knot_theory 同样的工程取舍。100 case 的 R/T 数据足以做 case-level 验证。
4. **数学本身简单**：bridge ⇔ disconnect 是 undergraduate 图论结果，不是 research-level。这导致评分容易饱和到 PROOF。如果换更深的 graph 性质（如 k-edge-connectivity、Whitney's theorem），评分分布会更分散，原语角色分析也会更细粒度。

---

## 完成情况

- [x] Step 1: GraphEngine + GraphObject 实现 + 自测
- [x] Step 2: GraphCounterfactualGenerator (boundary + operation_perturbation)
- [x] Step 3: 100 个 (G, e) pair benchmark 生成（5 levels）
- [x] Step 4: 8 条件 ablation 数据 + 8 prompt 生成
- [x] Step 5: 8 条件 self-evaluation + 主效应 / 交互分析

下一步：与 surface_topology, knot_theory 在跨 domain 报告中比较"形变维度"对原语依赖的影响。
