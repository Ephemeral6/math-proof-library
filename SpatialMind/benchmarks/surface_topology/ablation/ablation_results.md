# 三原语 Ablation 结果 — S_{1,2}, 1563 cases

**Date**: 2026-05-01
**Domain**: surface_topology, S_{1,2} 三角剖分
**Cases**: 1563 个 (α, β) pair, 全部 i(α, β) = 1, 全部 surgery 后 net_change = 0
**Counterfactual**: 3 个（boundary_relaxation = critical, condition_removal & operation_perturbation 非 critical）
**Evaluator**: Claude Opus 4.7（self-rating），单次评估，未取中位数

---

## 评分量表

| 分数 | 标签 | 操作化 |
|-----:|------|-------|
| 0    | NO_SIGNAL     | 没有从数据中提取关于机制的 hypothesis |
| 1    | WRONG_PATTERN | 提出被数据反驳的 pattern |
| 2    | PATTERN       | 正确的结构观察，无论证 |
| 3    | ARGUMENT      | 条件→结论的推理链，关键步骤正确 |
| 4    | PROOF         | 完整可验证证明 |

---

## 结果矩阵（2³ factorial）

```
                        Contrastive OFF          Contrastive ON
                    ┌─────────────────────┬─────────────────────┐
Transform OFF       │                     │                     │
  Relation OFF      │  000: 0 NO_SIGNAL   │  00C: 2 PATTERN     │
  Relation ON       │  R00: 2 PATTERN     │  R0C: 2 PATTERN+    │
                    ├─────────────────────┼─────────────────────┤
Transform ON        │                     │                     │
  Relation OFF      │  0T0: 0 NO_SIGNAL   │  0TC: 2 PATTERN     │
  Relation ON       │  RT0: 2 PATTERN     │  RTC: 3 ARGUMENT    │
                    └─────────────────────┴─────────────────────┘
```

每条评分的完整文本见 `evaluations/{条件}.md`。

---

## 主效应

| 因子 | ON 平均 | OFF 平均 | 主效应 |
|------|--------:|---------:|-------:|
| **R (Relation)**     | (R00+R0C+RT0+RTC)/4 = (2+2+2+3)/4 = **2.25** | (000+0T0+00C+0TC)/4 = (0+0+2+2)/4 = **1.00** | **+1.25** |
| **T (Transform)**    | (0T0+0TC+RT0+RTC)/4 = (0+2+2+3)/4 = **1.75** | (000+00C+R00+R0C)/4 = (0+2+2+2)/4 = **1.50** | **+0.25** |
| **C (Contrastive)**  | (00C+R0C+0TC+RTC)/4 = (2+2+2+3)/4 = **2.25** | (000+R00+0T0+RT0)/4 = (0+2+0+2)/4 = **1.00** | **+1.25** |

**初步结论**：在 S_{1,2} 上，R 和 C 主效应等强（+1.25），T 主效应弱（+0.25）。这与「H1: C 是关键杠杆」不完全一致——R 与 C 同等重要，二者各自能把 NO_SIGNAL 升到 PATTERN。

---

## 交互效应

- **R × C 交互**：R0C − max(R00, 00C) = 2 − 2 = **0**（叠加，无超加性）。
  - 但定性上 R0C 接近 ARGUMENT 边界（"PATTERN+"）；如果用 5 级浮点细分，可记 +0.5。
- **R × T 交互**：RT0 − max(R00, 0T0) = 2 − 2 = **0**（T 退化的预期结果）。
- **T × C 交互**：0TC − max(0T0, 00C) = 2 − 2 = **0**（T 退化的预期结果）。
- **R × T × C 三重交互**：RTC − max(RT0, R0C, 0TC) = 3 − 2 = **+1**。

> **唯一显著的超加性出现在三重组合**。R + T + C 联合时，跨过了 PATTERN → ARGUMENT 的门槛；任何二元组合都未跨过。

---

## 关键发现

### 1. 哪个原语是 PATTERN → ARGUMENT 的关键杠杆？

**没有单个原语单独够，也没有任何二元组合够**。在 S_{1,2} 上，PATTERN → ARGUMENT 的跨越只在 RTC 实现。这与原假设 H1（"C 单独就是关键杠杆"）冲突：C 单独（00C）只能 *定位* 关键约束（i ≤ 1），但缺 R 提供的结构观察、缺 T 提供的局部机制 step，无法形成论证链。

### 2. 三个原语是否有交互效应？

**仅在 3-way 组合上有显著超加性**（+1）。所有 2-way 组合 = max(单因子)，没有超加性。这暗示三个原语的角色互补、非冗余：
- C 定位 *which constraint matters*
- R 提供 *static structural fact* 支撑论证步骤
- T 提供 *operation locality*，让论证链能闭合

任何一个缺位，论证链就在那一步断掉。

### 3. S_{1,2} 上的退化效应

**T 在 S_{1,2} 上严重退化**：
- region_affected.triangles 总是 4（= 整个三角剖分）
- long_arc_triangles 总是 0
- β 总是 100% 在区域内
- punctures_in_region 总是 2

这意味着所有"区域内 vs 区域外"的对比 * 完全消失 *。RTC 中的 Step 7（surgery 局部分析）也因此缺失，使 RTC 评分卡在 ARGUMENT 而不到 PROOF。

**R 信号在 S_{1,2} 上很强**（universal facts: bigons_without_puncture = 0; crossings_outside_region = 0），但缺局部 surgery 行为分析时仍只到 PATTERN。

### 4. C 在 S_{1,2} 上的具体表现

C 给出 1 个 critical CF（boundary_relaxation, i=2 → net=−2）和 2 个 non-critical CF。这个 *鉴别力* 本身有信号——它把假设候选缩小到 i ≤ 1。但 CF 只提供 summary delta（net_change），**没有反事实 case 的 R 或 T 数据**，所以即便在 RTC 里，C 与 R/T 的耦合度被限制。

---

## Caveat

1. **单次评估，未取中位数**。受评估者的状态、解读方式影响。要做正式实验需 ≥3 次重复。
2. **S_{1,2} 三角剖分太小**（4 个三角形）。T 原语没有发挥空间。R 和 C 的信号也可能因此被低估或高估。
3. **所有正例 i = 1**。我没法看到 i = 0（trivial）的对比，也没看到 i = 1 内部的差异。
4. **CF 信号粗糙**。CF 只给 summary delta；缺 CF 上的 R/T 数据。如果 CF 也提供完整 R/T 数据，R0C 和 0TC 应该能更上一层。
5. **Evaluator self-bias**：我（Claude）在做 self-rating；可能存在系统性高估或低估。在 S_{2,1} 实验前应当固定 evaluator policy（同温度、同 prompt）。

---

## 预测：S_{2,1} 上的结果

S_{2,1}（亏格 2、1 个 puncture）三角剖分约有 16 个三角形（远大于 S_{1,2} 的 4 个），surgery 区域不再是全曲面。预测：

| 因子 | S_{1,2} 主效应 | S_{2,1} 预测 | 理由 |
|------|--------------:|-------------:|------|
| R    | +1.25 | +1.0 ~ +1.5 | bigon 的 puncture 归属不再恒为 true（只 1 个 puncture），R 信号更精细但单调性减弱 |
| T    | +0.25 | **+1.0 ~ +2.0** | surgery region ⊊ 整个曲面，β 区域内 vs 区域外可分，T 不再退化 |
| C    | +1.25 | +1.0 ~ +1.5 | 反事实定位 critical condition 的能力与曲面大小弱相关 |

**关键预测**：T 主效应在 S_{2,1} 上应显著上升。如果观察到 0TC ≈ ARGUMENT、RTC 接近 PROOF，则三原语理论得到强支持；如果 T 主效应仍小，说明 T 数据需要重设计。

---

## 完成情况

- [x] Step 1: `scripts/generate_ablation.py` 生成 8 个 JSON
- [x] Step 2: `scripts/generate_ablation_prompts.py` 生成 8 个 prompt
- [x] Step 3: 8 条件全部完成 self-evaluation（详见 `evaluations/{条件}.md`）
- [x] Step 4: 本文件，主效应 / 交互 / 预测 已分析

## Phase 1.2 完成

下一步（按 SpatialMind v2 路线图）：Phase 2 KnotEngine 或 S_{2,1} 验证 T 退化 hypothesis。
