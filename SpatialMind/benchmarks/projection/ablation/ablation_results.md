# 三原语 Ablation 结果 — projection, 66 cases

**Date**: 2026-05-01
**Domain**: projection（三维点集的二维投影 — 维度感知）
**Setup**: 5 个三维多面体 × 4 个投影平面（xy/xz/yz/对角）；3 类比较：self_projection (20)、cross_projection (30)、cross_object (16)
**Cases**: 66 个 case（注：spec 上"约 100"，实际由组合限制 — 所有同 n_points 对象的 cross_object case 全部生成）
**Counterfactual**: 3 个，**全部 critical**（boundary_relaxation = 不投影; operation_perturbation = z 轴 ×0.5 而非丢掉; condition_removal = dedupe collisions）
**Evaluator**: Claude Opus 4.7（self-rating），单次评估

---

## 评分量表（同 surface_topology / knot_theory / symmetry）

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
  Relation OFF      │  000: 2 PATTERN     │  00C: 2 PATTERN     │
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
| **R**  | (R00+R0C+RT0+RTC)/4 = (3+4+4+4)/4 = **3.75**  | (000+0T0+00C+0TC)/4 = (2+3+2+3)/4 = **2.50**  | **+1.25** |
| **T**  | (0T0+0TC+RT0+RTC)/4 = (3+3+4+4)/4 = **3.50**  | (000+00C+R00+R0C)/4 = (2+2+3+4)/4 = **2.75**  | **+0.75** |
| **C**  | (00C+R0C+0TC+RTC)/4 = (2+4+3+4)/4 = **3.25**  | (000+R00+0T0+RT0)/4 = (2+3+3+4)/4 = **3.00**  | **+0.25** |

**结论**：R 主导（+1.25），T 居中（+0.75），C 偏弱（+0.25）。  
关于这个维度（投影 / 维度感知）：**R 提供 invariants_preserved 字段 + distance matrix 是论证的主轴；T 的距离公式是核心 building block；C 起反事实因果作用但单独不足以闭合论证**。

---

## 交互效应

- **R × T**: RT0 − max(R00, 0T0) = 4 − 3 = **+1**（**超加性**：T 给公式 + R 给 per-case 验证）
- **R × C**: R0C − max(R00, 00C) = 4 − 3 = **+1**（**超加性**：C 给因果 + R 给 per-case 数据）
- **T × C**: 0TC − max(0T0, 00C) = 3 − 3 = **0**（CF 没补 T 缺的 invariants 字段）
- **R × T × C**: RTC − max(RT0, R0C, 0TC) = 4 − 4 = **0**（双 PROOF 已饱和）

> **R 与 T、R 与 C 都各有 +1 超加性；T 与 C 无交互**。这反映了「R 是必要 broker」的角色——T 的公式或 C 的反事实，都需要 R 的逐 case 数据来 anchored 到 PROOF。

---

## 关键发现

### 1. 距离公式 ‖π(v)‖² = ‖v‖² − ⟨v, ê⟩² 是这个维度的"主线索"

T 的 most_distorted_pairs 数据让我能 *induce* 这个公式。一旦有了它：
- (a) 距离守恒 ⟺ v ⊥ ê。  
- (P2) collision ⟺ v ‖ ê。  
- (P3) diameter 守恒 ⟺ 至少一条最长对角线 ⊥ ê。  
- (P4) 重建非唯一：未知自由度 δ = ⟨v, ê⟩。  

这个公式从 T 的 ratio 数据*几乎纯代数*地涌现，不需要 R 或 C。但要在 66 个 case 上 *verify* 公式，需要 R 的 per-case fraction、distance matrix、invariants_preserved 字段。

→ R × T 超加性来自此处。

### 2. CF 在这个维度上是「机制因果」工具，不是「数据 anchored」工具

CF 给出三个机制陈述：  
- CF-1: 维度降低 ⟹ 距离信息丢（因果独立性）；  
- CF-2: 零化 ≠ 压缩（限制 vs 缩放的拓扑差异）；  
- CF-3: collision 编码 3D 信息（信息保留分析）。  

这些是 *因果机制* 的反事实证据。但 CF 单独（00C）只有 PATTERN——因为 3 条 CF 不能在 66 个 case 上验证 *任何* 模式的 universality。

→ R × C 超加性：CF 给因果信号，R 给逐 case 验证。

### 3. cross_object 案例没有改变结论

数据里 16 个 cross_object case 的 structural_comparison 字段仍然是「a 投影前后的距离失真」（因为 compare(a, b, π(a)) 比较 pre = relate(a, b) 与 post = relate(π(a), b)）。所以 cross_object 的 case 级 R 数据 *没有直接* 给出「a 投影 vs b 是否撞影」的 distance matrix 比较。

→ 这意味着「撞影」问题（题目 (b)）的论证退化为 *逻辑推理 + 平移类构造*，而不是 *从 cross_object 数据 induce*。这是数据设计的局限——下一版可以让 cross_object 的 structural_comparison 直接比较 distance_matrix(π(a)) vs distance_matrix(b)。

### 4. 「PROOF」的三条独立路径

R0C、RT0、RTC 都到 PROOF：

- **RT0 路径**：T 的距离公式 + R 的 per-case 验证 → 代数 + 数值闭合。
- **R0C 路径**：R 的 per-case 数据 + CF 的反事实因果 → 数值 + 机制闭合。
- **RTC 路径**：三种证据并行，是 RT0 ∪ R0C 的 union。

每条独立到 PROOF。这与 symmetry domain（R 单独到 PROOF）形成对比——symmetry 上 R 的 fixed_point_counts 字段已经把核心 building block 直接给出，不需要 T 或 C 加持。

---

## 与其他维度的对比快查

| 维度 | Domain | R 主效应 | T 主效应 | C 主效应 | 主导原语 | 关键交互 |
|-----:|--------|---------:|---------:|---------:|----------|---------|
| 1 (不变量) | knot_theory | +0.75 | +0.25 | +0.75 | R + C 协同 | R × C = +1 |
| 4 (对称性) | symmetry | **+1.50** | +0.50 | 0 | R 单独 | 全部 = 0 |
| 5 (维度感知) | projection | **+1.25** | +0.75 | +0.25 | R 主导 + T/C 各加成 | R × T = +1, R × C = +1 |

### 跨维度模式

- **维度 1（不变量识别）**：R 给 invariants 数据，C 给反事实让 invariants 的 *关键性* 凸显。R 与 C 协同。
- **维度 4（对称性识别）**：R 单独给 fixed_point_counts + 轨道-稳定子数据，已闭合 Burnside 证明。CF 落在外围前提（群本身），不在证明关键步。
- **维度 5（维度感知）**：T 的距离公式 + R 的 per-case 数据双重必要。CF 给因果加固但不是 critical。R × T 和 R × C 都超加性。

→ 三原语 R/T/C 在不同数学维度上扮演不同角色，没有 universal 的 "T 是补语" 或 "C 是补语" 模式。这意味着：**ablation 实验的设计对应于"哪个原语承载这个维度的核心证据"**，三原语的角色由数学结构本身决定。

---

## Caveat

1. **单次自评**，未取中位数。
2. **66 cases 而非 ~100**：组合限制（同 n_points 才能做 cross_object 的 distance comparison）。Spec 写"约 100"，实际能保证有意义的 case 数是 66。
3. **CF 只在 1 个代表 case (cube × xy)**。3 种 CF 都 critical，但 critical 在 cube × xy 不一定 generalize 到其他对象。下一版应每个 case 一组 CF。
4. **cross_object case 的 structural_comparison 不是「a 投影 vs b 直接比较」**——这是数据设计的局限。下一版应让 cross_object 直接给出 distance_matrix(π(a)) vs distance_matrix(b) 的 pairwise diff。
5. **diagonal 投影的 ratio 分布与坐标平面投影显著不同**：cube diagonal 给 fraction=21%（最低），squared_antiprism diagonal 给 25%。这是因为 diagonal 投影方向与对象主轴不对齐，dropped_axis 在多个 vertex pair 上有非零分量。详细模式没在评估中展开。

---

## 完成情况

- [x] Step 1: ProjectionEngine + PointCloudObject 实现 + 自测
- [x] Step 2: 三种 counterfactual 策略（boundary/operation/condition）
- [x] Step 3: 8 个 prompt 模板
- [x] Step 4: 66-case benchmark 生成（5 levels）
- [x] Step 5: 8 条件 ablation 数据 + 8 prompt 生成
- [x] Step 6: 8 条件 self-evaluation + 主效应 / 交互分析
