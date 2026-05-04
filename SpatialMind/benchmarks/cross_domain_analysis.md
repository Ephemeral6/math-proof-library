# 跨 Domain 分析：空间认知原语的普适性

**文件类型**: 人工撰写的 narrative 报告。
**自动统计部分见**: `cross_domain_stats_auto.md`（由 `scripts/cross_domain_analysis.py` 生成，每次有新数据后重跑覆盖）。
**最近更新**: 2026-05-01（S_{1,2} 数据完整填入；S_{2,1} 等终端 1，Knot 等终端 2）。

---

## 0. 状态卡片

| Domain | 数据状态 | 来源 |
|--------|----------|------|
| **S_{1,2}**（曲面拓扑，亏格 1，2 个 puncture） | ✅ 完整（8/8 条件，1,563 cases） | `benchmarks/surface_topology/ablation/ablation_results.md` |
| **S_{2,1}**（曲面拓扑，亏格 2，1 个 puncture） | ⏳ 待终端 1 | `benchmarks/surface_topology_s21/ablation/ablation_results.md`（尚未生成） |
| **Knot Theory**（纽结论） | ⏳ 待终端 2 | `benchmarks/knot_theory/ablation/ablation_results.md`（尚未生成） |

> **如何刷新**：
> 1. 等终端 1 / 终端 2 把对应 domain 的 `ablation_results.md` 写好。
> 2. 跑 `python3 SpatialMind/scripts/cross_domain_analysis.py` → 更新 `cross_domain_stats_auto.md`。
> 3. 把 auto 文件里的数字搬到本文件对应 [TBD] 处，并补上 narrative 解读。

---

## 1. 三个 Domain 的 Ablation 结果

| 条件 | S_{1,2} | S_{2,1} | Knot | 平均 |
|------|--------:|--------:|-----:|-----:|
| 000  | 0       | [TBD]   | [TBD] | [TBD] |
| R00  | 2       | [TBD]   | [TBD] | [TBD] |
| 0T0  | 0       | [TBD]   | [TBD] | [TBD] |
| 00C  | 2       | [TBD]   | [TBD] | [TBD] |
| RT0  | 2       | [TBD]   | [TBD] | [TBD] |
| R0C  | 2 (PATTERN+) | [TBD]   | [TBD] | [TBD] |
| 0TC  | 2       | [TBD]   | [TBD] | [TBD] |
| RTC  | 3       | [TBD]   | [TBD] | [TBD] |

**评分量表**：0 NO_SIGNAL · 1 WRONG_PATTERN · 2 PATTERN · 3 ARGUMENT · 4 PROOF。

**S_{1,2} 注释**：
- R0C 实质是 PATTERN+（接近 ARGUMENT 但未跨阈值），这里记 2.0；半级处理见原始 ablation_results.md。
- 唯一跨过 PATTERN→ARGUMENT 阈值的条件是 RTC（3 分），所有二元和单因子组合 ≤ 2。

---

## 2. 主效应对比（ON 平均 − OFF 平均）

| 原语 | S_{1,2} | S_{2,1} | Knot | 跨 domain 平均 | 一致性 |
|------|--------:|--------:|-----:|---------------:|--------|
| R    | **+1.25** | [TBD]   | [TBD] | [TBD] | [TBD] |
| T    | **+0.25** ⚠ | [TBD]   | [TBD] | [TBD] | [TBD] |
| C    | **+1.25** | [TBD]   | [TBD] | [TBD] | [TBD] |

**Cohen's d (effect size)**：S_{1,2} 计算 R = +1.41, T = +0.22, C = +1.41。R 和 C 的效应都属"大"（d > 0.8 by Cohen 标准），T 的效应"小"（d < 0.5）。

**S_{1,2} 解读**：
- R 与 C 主效应等强（+1.25）。两个原语都把 NO_SIGNAL 升到 PATTERN，但单独都不够 ARGUMENT。
- T 的 +0.25 是 *已知退化* —— S_{1,2} 三角剖分太小（4 个三角形），surgery region 永远 = 整个曲面，"区域内 vs 区域外"对比消失。**这不是 T 原语本身的失败**，是 S_{1,2}-specific artifact。终端 1 (S_{2,1}) 的关键作用就是验证 T 在不退化的曲面上是否有效。

**预测**：
- S_{2,1} 上 T 主效应应当显著上升（预测 +1.0 ~ +2.0），R/C 大致维持（+1.0 ~ +1.5）。
- Knot 上三个原语应当 *都* 接近 +1.0 ~ +1.5（knot 的 R-move 自然是局部操作，T 不应退化）。

---

## 3. 交互效应对比（superadditivity）

| 交互 | S_{1,2} | S_{2,1} | Knot | 一致性 |
|------|--------:|--------:|-----:|--------|
| R × C   | **+0**  | [TBD]   | [TBD] | [TBD] |
| R × T   | **+0**  | [TBD]   | [TBD] | [TBD] |
| T × C   | **+0**  | [TBD]   | [TBD] | [TBD] |
| **R × T × C** | **+1**  | [TBD]   | [TBD] | [TBD] |

公式：interaction = combo_score − max(sub-component scores)。正值 = 超加性。

**S_{1,2} 解读**：
- 所有 *二元* 组合都没有超加性。这意味着两个原语共存时，最强的那个"主导"，第二个原语没有边际贡献。
- *三元* 组合 RTC 跨过 PATTERN→ARGUMENT 阈值（+1）。这是论文最重要的发现 —— **三个原语相乘而非相加**。

**机制假说**（详见 paper §5.3）：
1. C 把候选假设缩小到 critical bound（i ≤ 1）。
2. R 在该 bound 下提供不变量观察（all bigons contain puncture）。
3. T 给出 operation locality，让 R 的事实可以局部传播到论证步骤。
4. 任意一个缺位，论证链就断在那一步。

**预测**：
- S_{2,1} 上 R×T×C 应当复现 +1（如果 T 退化得到解决，可能会出现 R×T 或 T×C 的二元超加性，使 RTC 上升到 PROOF 边缘）。
- Knot 上 R×T×C 也应当为正。如果不为正（甚至为负），三原语理论需要修正。

---

## 4. Spearman 排序相关

把 8 条件评分排序，比较两个 domain 之间的 rank 一致性。

| 对比 | ρ | p-value | 解释 |
|------|---:|--------:|------|
| S_{1,2} ↔ S_{2,1} | [TBD] | [TBD] | 同 domain 不同曲面 → 上界 / sanity check |
| S_{1,2} ↔ Knot    | [TBD] | [TBD] | 跨 domain |
| S_{2,1} ↔ Knot    | [TBD] | [TBD] | 跨 domain |

**期望**：
- 同 domain 内（S_{1,2} ↔ S_{2,1}）ρ ≥ 0.85 — 证明评分协议稳定。
- 跨 domain（任一对含 Knot）ρ ≥ 0.6 — 证明三原语贡献不依赖具体 domain。
- 如果跨 domain ρ < 0.4，说明 R/T/C 的 *排序* 是 domain-specific，论文 thesis 需要弱化。

**重要 caveat**：n = 8 条件 → ρ 的 p-value 计算高度近似（自由度 = 6）。要做严格统计推断需要更大的 n（例如多次重复评估、或扩展到更多 domain）。

---

## 5. 关键结论

> 本节只能在所有三个 domain 数据齐全后写完。当前只能写 S_{1,2} 单 domain 的发现。

### 5.1 [TBD: 三个原语的主效应排序是否跨 domain 一致？]

S_{1,2} 给出 R = C >> T（T 退化）。等 S_{2,1} 数据看 T 是否抬升；等 Knot 数据看跨 domain 一致性。

**预期最终结论**（如果数据如预测填入）：
- R 和 C 的主效应在所有 domain 都属"大"（d > 0.8）。
- T 在不退化的 domain 上达到 R/C 同量级（+1.0 ~ +1.5）。
- *排序* 可能是 R ≈ C > T 或 R ≈ T ≈ C（取决于 domain），但三者都为正、都显著。

### 5.2 [TBD: 三重交互（RTC superadditivity）是否跨 domain 复现？]

S_{1,2} 给 +1（PATTERN→ARGUMENT 跨阈值）。这是 paper 的核心 claim。要确认这不是 S_{1,2} 的 idiosyncrasy，必须看到至少 *两个其他 domain* 也复现正的 R×T×C。

**预期最终结论**：所有三个 domain R×T×C ≥ +0.5。如果有任何一个 domain R×T×C ≤ 0，三原语理论被部分证伪。

### 5.3 [TBD: T 的主效应在不退化的曲面上是否增大？]

S_{1,2} T = +0.25。S_{2,1} 预测 T ≥ +1.0。

**这是终端 1 的关键 falsifier**：
- 如果 S_{2,1} T 主效应 ≥ +1.0 → 证实"T 退化是 surface-specific" → 三原语理论保持完整。
- 如果 S_{2,1} T 主效应仍 < +0.5 → "T 原语" 概念可能根本就有问题，需要重新思考 transform 数据是否能为 LLM 提供独立信号。

---

## 6. 写论文时的引用点

- **§4.2 (S_{1,2} results)**: 引用本文 §1 + §2 + §3 表格。
- **§4.3 (S_{2,1} results)**: 等终端 1 数据后从本文搬。
- **§4.4 (Knot results)**: 等终端 2 数据后从本文搬。
- **§4.5 (cross-domain)**: 引用本文 §4 (Spearman) + §5（结论）。
- **§5 (analysis)**: §5.1–5.3 的 narrative 分析直接复用到 paper。

---

## Appendix: 解读 cross_domain_stats_auto.md 的字段

`cross_domain_stats_auto.md` 是 `scripts/cross_domain_analysis.py` 输出的纯统计版。它只保证：
- 8 × N domain 评分矩阵（直接从 ablation_results.md 解析）。
- 主效应、交互效应、Cohen's d、Spearman 的数值。

它 *不包含* narrative 解读、机制假说、跨 domain 对比的定性结论 —— 这些都在本文件里手写。
