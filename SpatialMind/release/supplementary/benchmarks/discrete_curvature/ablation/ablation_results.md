# 三原语 Ablation 结果 — discrete_curvature, 100 cases

**Date**: 2026-05-01
**Domain**: discrete_curvature（离散 Gauss-Bonnet 定理：Σδ = 2πχ）
**Cases**: 100 个 case（4 preset 多面体 × {5 stellar + 5 displacement} = 40 intra-transform + 60 cross-pair = 100）
**Counterfactual**: 3 个，全部 critical（boundary_relaxation = 退化拼接；operation_perturbation = 删面留边；condition_removal = 越界顶点索引）
**Evaluator**: Claude Opus 4.7（self-rating），单次评估
**实验维度**: 维度 3 — 局部到全局推理（local → global）

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
  Relation OFF      │  000: 2 PATTERN     │  00C: 2 PATTERN     │
  Relation ON       │  R00: 2 PATTERN     │  R0C: 3 ARGUMENT    │
                    ├─────────────────────┼─────────────────────┤
Transform ON        │                     │                     │
  Relation OFF      │  0T0: 2 PATTERN     │  0TC: 2 PATTERN     │
  Relation ON       │  RT0: 2 PATTERN     │  RTC: 3 ARGUMENT    │
                    └─────────────────────┴─────────────────────┘
```

详细评估见 `evaluations/{条件}.md`。

---

## 主效应

| 因子 | ON 平均 | OFF 平均 | 主效应 |
|------|--------:|---------:|-------:|
| **R**  | (R00+R0C+RT0+RTC)/4 = (2+3+2+3)/4 = **2.50** | (000+0T0+00C+0TC)/4 = (2+2+2+2)/4 = **2.00** | **+0.50** |
| **T**  | (0T0+0TC+RT0+RTC)/4 = (2+2+2+3)/4 = **2.25** | (000+00C+R00+R0C)/4 = (2+2+2+3)/4 = **2.25** | **0.00** |
| **C**  | (00C+R0C+0TC+RTC)/4 = (2+3+2+3)/4 = **2.50** | (000+R00+0T0+RT0)/4 = (2+2+2+2)/4 = **2.00** | **+0.50** |

**结论**：R 和 C 主效应等强（+0.50）；T 主效应 = 0（完全退化）。

---

## 交互效应

- **R × C**: R0C − max(R00, 00C) = 3 − 2 = **+1**（**超加性！**）
- **R × T**: RT0 − max(R00, 0T0) = 2 − 2 = **0**
- **T × C**: 0TC − max(0T0, 00C) = 2 − 2 = **0**
- **R × T × C**: RTC − max(RT0, R0C, 0TC) = 3 − 3 = **0**（R0C 已达 ARGUMENT，T 没新加）

> **唯一显著超加性是 R × C**。和 knot_theory（surface_topology 系列）惊人的一致：在两个完全不同的几何 domain 上，"相关结构 + 反事实" 是跨过 PATTERN→ARGUMENT 门槛的关键杠杆。

---

## 关键发现

### 1. R × C 是跨域稳定的"argument lever"

跨 domain 对比（discrete_curvature vs knot_theory）：

| 域 | R 主效应 | T 主效应 | C 主效应 | R×C 超加 |
|----|---------:|---------:|---------:|---------:|
| knot_theory          | +0.75 | +0.25 | +0.75 | +1 |
| discrete_curvature   | +0.50 | +0.00 | +0.50 | +1 |

R 和 C 主效应在两个域都 *相等且等于* R×C 超加量 ÷ 2 + something。但 **R×C 超加 = +1 是跨域稳定的**。这强烈暗示：要从"看到 pattern"跨到"做出 argument"，需要 **per-element 结构（R）+ 反例（C）** 的协同。两者各自只是观察、合起来才形成 *条件 → 结论* 的逻辑链。

### 2. T 在这个 domain 完全退化（主效应 0.00）

为什么？因为 **T 与 R 高度信息冗余**（同 knot_theory）：
- T 的 ΔV-ΔE+ΔF=0 关系 R 也能从 detailed_comparison 的 V/E/F 数字看出来。
- T 的 `local_defect_sum_preserved` R 也在 `vertex_defects_changed = {}` + `sum_of_new_vertex_defects ≈ 0` 里看到。
- T 没暴露任何 R 没暴露的独立信号。

但 T 不是无用的：T 给了 *绝对* V/E/F 数字（before_state/after_state），让 3F=2E 的验证更直接。在 R0C 里我得从 detailed_comparison 翻 V/E/F；在 RT0/0TC 里 T 直接给。

### 3. PATTERN→ARGUMENT 的关键 pivot 是 CF2

CF2 的解释里有一句 "**deleting a face removes its three interior angles which sum to π**" —— 这是 G-B 证明里的 *核心引理*（每个三角形角和 = π）。**没有 CF，agent 看到的所有数据都是"等式成立"的实例验证；CF2 反向暴露了"打破等式时损失了什么"，而损失量 = π 直接给出关键引理。**

这个 pattern（"CF 暴露关键代数引理"）在 knot_theory 上对应 boundary_relaxation 揭示 sign pair (+1,-1) 的 writhe 守恒角色。两个 domain 的 *pivot CF* 都是 boundary 类型——巧合，但很有启发：**"放宽边界条件"的 CF 比"完全删去条件"的 CF 携带更多机制信息**，因为它揭示的是"少了 1 个就破"的精细 quantization，而非"全部缺失"的笼统。

### 4. RTC = R0C 的解读

R0C 已经形成 ARGUMENT（评分 3）；RTC 的额外 T 数据是 *冗余 + 量化加固*（V/E/F 绝对值让 3F=2E 的横向验证更直接），但没添加新论证步骤——T 的 region_affected 是 *局部* 的，证明 G-B 需要 *全局* 求和，T 不直接赋能这一步。

这与 surface_topology 上 "RTC > 任何 2-way" 的三阶超加形成对比：在那里 T 提供的 surgery region 信号是独立必要的；在这里 T 与 R 共享核心信号。

---

## Caveat

1. **单次自评**，未取中位数。Score 距离阈值 (3 vs 2) 较小时容易翻转。
2. **几何 vs 拓扑数据混合**：discrete_curvature 的 R 字段同时包含几何（角缺数值）和拓扑（χ、curvature_types 分布），这可能让 R 的"信息密度"高于 knot_theory 的纯 PD-code+不变量结构。R 主效应 +0.50（vs knot 的 +0.75）的差异可能来自这里——本 domain 的 R 单独就接近"够用"，所以 R+C 的提升只有 +1 而非 +1.5。
3. **CF 只在 1 个 mesh (tetrahedron) 上**。理想是每个 preset 都有 CF，但工程开销大；用一个代表点。
4. **"local→global"的实验意图通过了**：R 是 per-vertex 局部数据、需要 C 的"per-face π"才能闭合到全局求和。这正是 G-B 定理的本质——局部曲率求和 = 全局拓扑量。两者缺一不可，与 ablation 矩阵一致。

---

## 完成情况

- [x] Step 1: DiscreteCurvatureEngine + MeshObject 实现，自测通过（4 preset 都 χ=2、Σδ/(2π)=2）
- [x] Step 2: 三种 counterfactual 策略实现，3/3 critical
- [x] Step 3: 100 个 case benchmark 生成（5 levels），0 G-B 违例
- [x] Step 4: 8 个 prompt 模板（domains/discrete_curvature/prompts.py）
- [x] Step 5: 8 条件 ablation 数据 + 8 prompt 生成
- [x] Step 6: 8 条件 self-evaluation + 主效应 / 交互分析

下一步：跨 domain 报告 — 把 surface_topology / knot_theory / symmetry / discrete_curvature 的 ablation 矩阵叠在一起，看 R×C 超加是否在所有 domain 都成立。
