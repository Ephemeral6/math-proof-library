# 三原语 Ablation 结果 — symmetry_combinatorics, 200 cases

**Date**: 2026-05-01
**Domain**: symmetry_combinatorics（Burnside 引理 / 轨道-稳定子定理）
**Setup**: 6 顶点正六边形的 3 着色 (3^6 = 729 个着色) 在 Z_6 旋转群下的 130 个轨道
**Cases**: 200 个 (a, b) pair（100 same-orbit + 100 diff-orbit）；每对 a 施加随机非恒等 g ∈ Z_6
**Counterfactual**: 3 个，2 个 critical（condition_removal: Z_6 → {e}; operation_perturbation: 非群置换 swap(0,1)）；1 个 non-critical（boundary_relaxation: Z_6 → D_6）
**Evaluator**: Claude Opus 4.7（self-rating），单次评估

---

## 评分量表（同 surface_topology / knot_theory）

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
  Relation ON       │  R00: 4 PROOF       │  R0C: 4 PROOF       │
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
| **R**  | (R00+R0C+RT0+RTC)/4 = (4+4+4+4)/4 = **4.00**  | (000+0T0+00C+0TC)/4 = (2+3+2+3)/4 = **2.50**  | **+1.50** |
| **T**  | (0T0+0TC+RT0+RTC)/4 = (3+3+4+4)/4 = **3.50**  | (000+00C+R00+R0C)/4 = (2+2+4+4)/4 = **3.00**  | **+0.50** |
| **C**  | (00C+R0C+0TC+RTC)/4 = (2+4+3+4)/4 = **3.25**  | (000+R00+0T0+RT0)/4 = (2+4+3+4)/4 = **3.25**  | **0.00** |

**结论**：在维度 4（对称性识别 + Burnside 引理）上，**R 主效应压倒性领先**（+1.50），T 居中（+0.50），C 主效应为 **0**——CF 在所有 4 对组合上都没有改变结论。

---

## 交互效应

- **R × T**: RT0 − max(R00, 0T0) = 4 − 4 = **0**（R 单独已 PROOF，T 加上去无新证明步骤）
- **R × C**: R0C − max(R00, 00C) = 4 − 4 = **0**（同上）
- **T × C**: 0TC − max(0T0, 00C) = 3 − 3 = **0**
- **R × T × C**: RTC − max(RT0, R0C, 0TC) = 4 − 4 = **0**

> **没有显著超加性**。R 单独已经把分数推到 PROOF（4），所以任何包含 R 的组合都是 4，包含 R 的 2-way / 3-way 交互全部为 0。

---

## 关键发现

### 1. R 是这个维度的「单点突破」原语

R 单独（R00 = 4 PROOF）跨越门槛，直接给出 Burnside 完整证明。两个关键数据字段做了重活：

- `n_connecting = stabilizer_a_size`（在 100 个 same-orbit pair 上 100/100 一致）：直接给出陪集分解的构造性证据，从而证明 orbit-stabilizer 定理。
- `fixed_point_counts = {0:729, 1:3, 2:9, 3:27, 4:9, 5:3}` + `burnside_count = total_orbits = 130`：直接验证 (1/|G|) Σ |Fix(g)| = #orbits。

这些是 **结构层（detail_level=3）** 字段，不是 summary 字段。

### 2. T 给出 |Fix(g)| 的代数公式，但与 R 数值冗余

T 让我看到 g 的具体置换形式（旋转 k 步 → cycle 数 = gcd(k,6)），从而能推 |Fix(g)| = 3^(cycle_count)。这是对 R 中 fixed_point_counts 数值的**机制解释**——但不是新的证明步骤。

→ T 主效应 +0.50：把 OFF 的 0T0/0TC 从 PATTERN(2) 抬到 ARGUMENT(3)，但 ON 的 R00/R0C 已经在 PROOF，T 加进去推不到「PROOF+」（没有这一档）。

### 3. C 在这个维度上是「空因子」

CF 测试三个条件：(i) 群放大 (Z_6 → D_6)；(ii) 群缩小 (Z_6 → {e})；(iii) 非群置换。其中 (ii) 和 (iii) 是 critical 的，但**关于的是「群是否必要」这个 meta-问题，不是 Burnside 引理本身**。

具体来说：
- CF-2 (Z_6 → {e}) 告诉我「等价关系 = 相等」当 G 平凡 → 验证 G 必要前提；
- CF-3 (swap ∉ Z_6) 告诉我非群置换破坏轨道等价 → 验证 g ∈ G 前提；
- CF-1 (Z_6 → D_6) 给出 D_6 下 92 个轨道 → 一致性信号但 non-critical。

这些信号 *不构成* Burnside 双重计数论证的任何一步。所以 C 主效应 = 0。

> 与 knot_theory 对比：在 knot_theory 上 C 主效应 +0.75，因为 CF 直接刻画了「sign pair (+1,−1) 是 R2 守恒不变量的关键」——CF 落在证明的 *关键步* 上。
> 在 symmetry 上 CF 落在 *外围前提*（群必要）上，不在证明的关键步（双重计数）上。

### 4. 维度 1 vs 维度 4 的对比

- 维度 1（surface_topology, knot_theory）：求「变换后什么没变」。CF 用「条件放宽 / 修改」对应「破坏不变量」，CF 是 *证明的反面验证*。
- 维度 4（symmetry, 本实验）：求「什么变换让对象不变」。CF 修改的是 *群本身*，对应「整个对称结构改变」。这是对前提的扰动，不是对核心机制的扰动。

→ 这或许是 C 主效应在维度 4 上消失的**结构性原因**，而非 prompt 设计问题。

### 5. 「PROOF」的两条路径

R00 和 RT0 都到 PROOF，但路径不同：

- **R00 路径**：完全数值。Burnside 公式按 (1/|G|) Σ Fix = 130 = total_orbits 数值闭合。
- **RT0 路径**：数值 + 代数。T 提供 |Fix(g)| = 3^(gcd(k,6)) 的代数公式，把数值结果上升到机制解释。

R0C 路径：数值 + 反事实稳健性（剔除「Z_6 巧合」假说）。

**RTC 是三条路径的并集**，但因为 R 单独已闭合证明，多余信号没改变 PROOF 分数。

---

## Caveat

1. **单次自评**，未取中位数。
2. **正方案过强**：所有 200 case 都满足 orbit_stabilizer_holds=True、burnside_count=total_orbits=130。这是 *算出来的真值*，不是抽样。所以 R 单独闭合证明是 by design，而不是实验上的「发现」。
3. **CF 只在 1 个代表 pair 上**（same-orbit pair[0]）。如果对每个 pair 都生成 CF，能否让 C 主效应 > 0？理论上不太可能——CF 修改的是群结构，与具体 pair 无关。
4. **T 的 cycle structure 信号 vs R 的 fixed_point_counts 信号高度冗余**。如果只关心「证 Burnside」，R 是 minimal sufficient；T 加进去主要是 redundancy。如果关心「为什么 fixed_point_counts 长这样」，T 才有独立价值。
5. **C 在这个维度上无效不等于 CF 框架失效**。在维度 1 (knot_theory) 上 CF 是关键杠杆。CF 的有效性依赖于「修改了什么 → 是否落在证明关键步上」这个 alignment。

---

## 完成情况

- [x] Step 1: SymmetryEngine + ColoringObject 实现 + 自测
- [x] Step 2: 三种 counterfactual 策略实现 (boundary_relaxation, condition_removal, operation_perturbation)
- [x] Step 3: 8 个 prompt 模板
- [x] Step 4: 200 个 (a, b) pair benchmark 生成（5 levels）
- [x] Step 5: 8 条件 ablation 数据 + 8 prompt 生成
- [x] Step 6: 8 条件 self-evaluation + 主效应 / 交互分析

---

## 与其他维度的对比快查

| 维度 | Domain | R 主效应 | T 主效应 | C 主效应 | 主导原语 |
|-----:|--------|---------:|---------:|---------:|----------|
| 1 (不变量) | knot_theory | +0.75 | +0.25 | +0.75 | R + C 协同 |
| 4 (对称性) | symmetry | **+1.50** | +0.50 | **0** | **R 单独** |

→ 在「证 Burnside」这个维度 4 的目标上，R 提供的结构层数据（stabilizer + fixed_point_counts）是「直接证据」，而 CF 退化为「外围前提验证」。这与 R/T/C 三原语在不同数学维度上的角色变化是一致的。
