# 三原语 Ablation 结果 — knot_theory, 100 cases

**Date**: 2026-05-01
**Domain**: knot_theory（Reidemeister R2 invariance）
**Cases**: 100 个 R2 move pair（10 prime knots × 10 trials）
**Counterfactual**: 3 个，全部 critical（boundary_relaxation = 同号 R2; operation_perturbation = crossing flip; condition_removal = planarity off）
**Evaluator**: Claude Opus 4.7（self-rating），单次评估

---

## 评分量表（同 surface_topology）

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
  Relation OFF      │  000: 1 PATTERN−    │  00C: 2 PATTERN     │
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
| **R**  | (R00+R0C+RT0+RTC)/4 = (2+3+2+3)/4 = **2.50**  | (000+0T0+00C+0TC)/4 = (1+2+2+2)/4 = **1.75**  | **+0.75** |
| **T**  | (0T0+0TC+RT0+RTC)/4 = (2+2+2+3)/4 = **2.25**  | (000+00C+R00+R0C)/4 = (1+2+2+3)/4 = **2.00**  | **+0.25** |
| **C**  | (00C+R0C+0TC+RTC)/4 = (2+3+2+3)/4 = **2.50**  | (000+R00+0T0+RT0)/4 = (1+2+2+2)/4 = **1.75**  | **+0.75** |

**结论**：R 和 C 主效应等强（+0.75）；T 主效应弱（+0.25）。

---

## 交互效应

- **R × C**: R0C − max(R00, 00C) = 3 − 2 = **+1**（**超加性！**）
- **R × T**: RT0 − max(R00, 0T0) = 2 − 2 = **0**
- **T × C**: 0TC − max(0T0, 00C) = 2 − 2 = **0**
- **R × T × C**: RTC − max(RT0, R0C, 0TC) = 3 − 3 = **0**（R0C 已经达到 ARGUMENT，3-way 没多）

> **唯一显著超加性是 R × C**。R 提供"每个 case 上 invariants 全保留" + sign pair = (+1,−1) 的 universal pattern；C 提供 boundary CF 反证"同号 R2 会破坏 invariants"。两者拼起来形成完整论证链。

---

## 关键发现

### 1. PATTERN → ARGUMENT 的关键杠杆是 R × C 组合

R 单独（R00 = 2）+ C 单独（00C = 2）= 都是 PATTERN。
R0C = 3 = ARGUMENT，跨过门槛。
T 不加任何组合都没让我跨过门槛（RT0, 0TC 都是 2）。

### 2. T 在 knot_theory 上 *不退化*，但与 R 高度冗余

T 给出的 sign pair (+1, −1) 恰好与 R 给出的 sign pair 是同一信号（不同视角）。T 的 *额外* 信号是 *locality*（原 crossings 未动），但这个信号在 R+C 已能闭合论证的情况下没有显著加分。

→ T 的弱主效应（+0.25）不是因为它 degenerate，而是因为它与 R 共享核心信号。

### 3. CF 揭示了一个微妙之处：signature 不被 sign-pair 决定

boundary_relaxation CF 的 delta 显示：同号 R2 改变 determinant + Alexander，但 signature_delta = 0（在 3_1 这个例子上）。这说明：
- writhe / determinant / Alexander 三者都通过 "sign pair sum" 与 R2 联系；
- signature 通过 Seifert matrix 的不同机制；
- 因此一个 *complete* 证明需要分别处理 signature 和其他三个不变量。

这是 RTC 评估中我观察到但无法填补的 gap。

### 4. RTC 与 R0C 同分（3）的解读

R0C 已经形成 ARGUMENT；RTC 的额外 T 数据是 *冗余确认 + locality nuance*，没有增加新论证步骤。这与 surface_topology 上 RTC > 任何 2-way（+1 三重交互）形成对比——在 knot_theory 上信息密度更高，2-way 已经足够。

---

## Caveat

1. **单次自评**，未取中位数。
2. **Seifert-matrix-based invariants**：signature/det/Alex 都是从同一个底层结构（Seifert matrix S + S^T）派生的，所以它们之间存在隐含关联——这可能让评估者误判某些信号的独立性。
3. **CF 只在 1 个 knot (3_1) 上**。理想情况是每个 knot 都有 CF，但 boundary_relaxation 的 PD-code rewriting 工程开销使我们用了一个代表点。
4. **信号在 R 和 T 之间高度冗余**（sign pair）。如果 T 数据未来加入 *Seifert matrix transformation trace* 这种独立信号，T 主效应应当显著上升。

---

## 完成情况

- [x] Step 1: KnotEngine + KnotObject 实现
- [x] Step 2: 三种 counterfactual 策略实现
- [x] Step 3: 8 个 prompt 模板
- [x] Step 4: 12 个单元测试全部通过
- [x] Step 5: 100 个 R2 pair benchmark 生成（5 levels）
- [x] Step 6: 8 条件 ablation 数据 + 8 prompt 生成
- [x] Step 7: 8 条件 self-evaluation + 主效应 / 交互分析

下一步在统一的跨 domain 报告中。
