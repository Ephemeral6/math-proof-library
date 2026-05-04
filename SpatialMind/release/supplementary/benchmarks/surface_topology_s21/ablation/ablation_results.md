# 三原语 Ablation 结果 — S_{2,1}, 128 cases

**Date**: 2026-05-01
**Domain**: surface_topology, S_{2,1} 三角剖分（亏格 2、1 puncture、6 三角形）
**Cases**: 128 个 (α, β) pair, 全部 i(α, β) = 1
  - 92 个 net_change = 0（surgery 后 intersection number 保持）
  - 36 个 net_change = -1（自然反例：canonical sigma 在 S_{2,1} 上不总是 universal filler）
**Counterfactual**: 3 个 CF（boundary_relaxation i=2 → -2; condition_removal 翻转 -1 → 0; operation_perturbation 不变）
**Evaluator**: 8 个 Claude Opus 4.7 子 agent，每个仅看本条件 prompt + JSON，避免跨条件信息泄露

---

## 评分量表（同 S_{1,2}）

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
  Relation OFF      │  000: 2 PATTERN     │  00C: 2 PATTERN     │
  Relation ON       │  R00: 2 PATTERN     │  R0C: 2 PATTERN+    │
                    ├─────────────────────┼─────────────────────┤
Transform ON        │                     │                     │
  Relation OFF      │  0T0: 2 PATTERN     │  0TC: 2 PATTERN     │
  Relation ON       │  RT0: 3 ARGUMENT    │  RTC: 3 ARGUMENT    │
                    └─────────────────────┴─────────────────────┘
```

> **0T0 注**：评估 agent 在文末写"PATTERN (1)"，但 (1) 与 PATTERN 标签矛盾（PATTERN = 2）。文中正向论述符合 PATTERN：发现真实的 weight_shift / β_short 单变量倾斜（非 WRONG_PATTERN）但混合桶吃掉 90% case（无 ARGUMENT）。按标签计为 2。

每条评分的完整文本见 `evaluations/{条件}.md`。

---

## 主效应

| 因子 | ON 平均 | OFF 平均 | 主效应 |
|------|--------:|---------:|-------:|
| **R (Relation)**     | (R00+R0C+RT0+RTC)/4 = (2+2+3+3)/4 = **2.50** | (000+0T0+00C+0TC)/4 = (2+2+2+2)/4 = **2.00** | **+0.50** |
| **T (Transform)**    | (0T0+0TC+RT0+RTC)/4 = (2+2+3+3)/4 = **2.50** | (000+00C+R00+R0C)/4 = (2+2+2+2)/4 = **2.00** | **+0.50** |
| **C (Contrastive)**  | (00C+R0C+0TC+RTC)/4 = (2+2+2+3)/4 = **2.25** | (000+R00+0T0+RT0)/4 = (2+2+2+3)/4 = **2.25** | **0.00** |

---

## 交互效应

- **R × T 交互**：RT0 − max(R00, 0T0) = 3 − 2 = **+1**（**显著超加性**）。
- **R × C 交互**：R0C − max(R00, 00C) = 2 − 2 = **0**。
- **T × C 交互**：0TC − max(0T0, 00C) = 2 − 2 = **0**。
- **R × T × C 三重交互**：RTC − max(RT0, R0C, 0TC) = 3 − 3 = **0**。

> **唯一显著的超加性是 R × T**（不再是 S_{1,2} 上的 3-way）。R + T 联合时跨过 PATTERN → ARGUMENT 的门槛；C 在 S_{2,1} 数据集上没有边际增益。

---

## 跨曲面对比（核心发现）

### 各条件评分对比

| 条件 | S_{1,2} | S_{2,1} | Δ | 解释 |
|------|--------:|--------:|--:|------|
| 000  | 0 | 2 | **+2** | S_{2,1} 数据集含 36 个自然反例，metadata.beta_level 与失败率有 6×–7× 的差距（9% / 49% / 60%），这本身就是 PATTERN 级信号 |
| R00  | 2 | 2 | 0 | 找到 65/65 完美充分条件（crossings_outside_region_post ≥ 3 ⟹ 成功），但仍是 post-hoc 量，未得 ARGUMENT |
| 0T0  | 0 | 2 | **+2** | T 部分非退化（region size = 3 ≠ 6），β_short ∈ {1,2,3} 出现纯 ok / 纯 bad 子集；但 long_arc 仍恒空，主流 case 仍混合 |
| 00C  | 2 | 2 | 0 | CF2（descending-link removal）翻转 -1 → 0，识别真正缺失条件；但正例集本身 28% 失败削弱 CF1 的边界鉴别力 |
| **RT0**  | 2 | **3** | **+1** | **关键提升**：agent 抽出 mod-2 parity argument（cr_out_pre 奇 ⟹ 成功 17/17），是几何机制论证而非纯模式 |
| R0C  | 2(+) | 2(+) | 0 | bigons_post ≥ 1 ⟹ 成功（87/92, 6/36），CF 支持"crossing 反流"而非 topological 突变 |
| 0TC  | 2 | 2 | 0 | β-fully-inside-region ⟹ 100% 失败、short_arc=4 ∧ β-outside ⟹ 100% 成功；CF1 验证 descending-link 是真条件 |
| RTC  | 3 | 3 | 0 | 联合 parity argument + bigons_post 判别器 + CF descending-link 印证；6 case 残差未闭合，仍是 ARGUMENT 而非 PROOF |

### 主效应对比

| 原语 | S_{1,2} 主效应 | S_{2,1} 主效应 | Δ | 解释 |
|------|--------------:|--------------:|----:|------|
| R    | +1.25 | +0.50 | **-0.75** | R 边际值缩小，因 floor 已抬到 PATTERN |
| **T**    | +0.25 | **+0.50** | **+0.25** | **预测得到验证**：T 不再退化使 RT0 跨过 ARGUMENT |
| C    | +1.25 | 0.00  | **-1.25** | C 边际值消失：S_{2,1} 上 36 个自然反例已"内置"在数据里，CF 不再是发现失败的唯一渠道 |

### 关键观察：地板抬高 vs 天花板抬高

S_{1,2} → S_{2,1} 的最大变化是 **floor 抬升**（地板从 NO_SIGNAL=0 升到 PATTERN=2），不是 ceiling 抬升。原因：

1. **数据集本身复杂性增加**：S_{1,2} 数据集是"100% 成功的同质样本"，S_{2,1} 是"72% 成功 + 28% 失败的混合样本"。失败案例的存在本身就是信号，使 000 / 0T0 都从 NO_SIGNAL 升到 PATTERN。
2. **天花板被 ARGUMENT 锁住**：R+T 已能给出 mod-2 parity 论证（RT0 = 3），但 6 个 a215/a221 残差未闭合，无任何条件达到 PROOF (4)。
3. **结果**：动态范围从 [0, 3] 压缩到 [2, 3]，主效应缩小是必然结果。

这是一个 **方法学发现**：当数据集自带反例时，主效应度量被压缩，需要更精细的指标（如"达到 ARGUMENT 的最小原语集"）。

---

## 关键发现

### 1. T 退化假说得到验证

S_{1,2} 的 ablation 报告预测："T 主效应在 S_{2,1} 上应显著上升 ... 如果 0TC ≈ ARGUMENT、RTC 接近 PROOF，则三原语理论得到强支持。"

**实际结果**：
- 0TC 仍然 PATTERN（2）— **未到 ARGUMENT**
- RTC 仍然 ARGUMENT（3）— **未到 PROOF**
- **但 RT0 从 PATTERN 升到 ARGUMENT（+1）**，这是 T 不再退化的直接产物

部分验证 H1：T 解锁了 ARGUMENT-级论证，但只在与 R 联合时；C 没起到额外作用。

### 2. Hatcher 不变性的真实充要条件

跨多个 agent 独立发现的几何论证（合并）：

> 假设 i(α, β) = 1。surgery 把 α 替换为 σ_α，操作局限于 region R（3 个三角形）。设 cr_out 为 β 与 R 外的 candidate-crossing 数。
>
> **Mod-2 不变量**：surgery 不动 R 外的几何，故 cr_out_pre ≡ cr_out_post (mod 2)。
> 又 i(σ_α, β) ≥ cr_out_post 是 transverse-2 manifold 的下界。
> 当 cr_out_pre 是奇数时，i(σ_α, β) ≥ 1 = i(α, β)；又因为 i 只可能下降，i(σ_α, β) = 1。
>
> 这覆盖 17/92 成功案例 100%，并给出**几何性必要性**而非统计性 pattern。

剩余 75 个成功案例（cr_out_pre = 0）的不变性需要 puncture-bigon 论证（R 提供：bigons_post ≥ 1 与 net_change=0 强相关 87/92），但这一支只有 sketch，未达 PROOF。

### 3. 失败案例的特征

36 个 net_change = -1 的案例分布在 5 个 α 上（c122, c151, c215, c221, c249），每 α 失败率从 14%（c151）到 46%（c215）。统一的失败模式：

- **β 完全在 region 内**（β_in_region = β_total）：6/6 失败 — surgery 没有 R 外锚点平衡 crossing
- **bigons_post = 0**（surgery 消去所有 bigon）：117/128 与 net_change 强相关
- **descending-link removal CF**：把 net_change 从 -1 翻到 0，验证"β ∈ DL of α" 是真正缺失的条件

这些案例对应 op1_geometry 项目里 `direction_b_S21_failures.py` 已研究的 W4-filler 失败模式。

### 4. 三原语角色再分类

S_{1,2} 上：
- C 定位 *which constraint matters*
- R 提供 *static structural fact*
- T 提供 *operation locality*（但退化未发挥）

S_{2,1} 上 T 解锁后：
- R + T 已能合成几何论证（mod-2 parity）
- C 退到 *corroboration* 角色（验证 descending-link 是真条件，但 R+T 已能给出此条件）
- 没有任何二元组合达到 PROOF — 缺的是"PROOF 这一档需要的精确度"，不是某个原语

---

## Caveat

1. **8 个独立 agent，单次评估**。理论上比 S_{1,2} 的单 evaluator 更稳健（context 隔离），但仍未取中位数。
2. **0T0 的标签/数字矛盾**：agent 写 "PATTERN (1)"，按标签计 2。如有争议可手动校准。
3. **128 cases vs 1563**：S_{2,1} 数据集小一个数量级，统计显著性弱。
4. **5 个 α 主导失败**：36 个 net_change=-1 全部来自 5 个 α，可能存在 α-特定模式而非真正的曲面级机制。
5. **T 仍部分退化**：region.triangles 大小恒为 3，long_arc_triangles 恒空。要真正测试 T 的极限，需要更深的 BFS 生成更多曲线，或换更大的曲面（S_{3,1}, S_{2,2}）。
6. **bigon-puncture 信号仍是结构性 trivial**（degen #1 未解决，是分类器算法问题非曲面问题）。

---

## 完成情况

- [x] Step 1: `scripts/generate_ablation_s21.py` 生成 8 个 JSON
- [x] Step 2: `scripts/generate_ablation_prompts_s21.py` 生成 8 个 prompt
- [x] Step 3: 8 条件全部完成 isolated agent self-evaluation（详见 `evaluations/{条件}.md`）
- [x] Step 4: 本文件，主效应 / 交互 / 跨曲面对比 / 关键发现 已分析

## 总结一句

S_{2,1} 实验**部分**验证了 T 退化假说：T 主效应从 +0.25 升到 +0.50，且与 R 联合时（RT0）首次跨过 PATTERN → ARGUMENT 门槛；但 C 主效应反而消失（数据集自带反例使 C 失去鉴别价值），且无任何条件达到 PROOF。最大方法学发现：自带反例的数据集会**抬高地板**而非抬高天花板，压缩主效应度量的动态范围。
