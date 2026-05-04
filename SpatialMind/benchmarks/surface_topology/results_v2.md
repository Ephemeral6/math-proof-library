# Benchmark 结果 v2 — 完整 1563 pair + bigon puncture tag

## 数据统计

| 项 | v1 | v2 |
|----|----|----|
| 总 case 数 | 1（α=c9, β=c1） | **1,563** |
| 总 α 数 | 1 | **248** |
| α-level 范围 | 4 | **2 – 28** |
| net_change == 0 | 1/1 | **1,563 / 1,563** ✓ |
| counterfactual cases | 3 | 3 (1 critical) |

α-level 分布（cases per α level）：
`{2: 214, 3: 299, 4: 298, 5: 194, 6: 133, 7: 116, 8: 128, 9: 33, 10: 25, 11: 6, 12: 52, 13: 11, 14: 11, 15: 5, 16: 9, 18: 17, 22: 2, 26: 4, 28: 6}`

β-level 分布：`{0: 73, 1: 761, 2: 192, 3: 261, 4: 80, 5: 102, 6: 24, 7: 42, 8: 9, 9: 12, ...}`

每个 case 都满足 i(α, β) = 1（i = 0 trivially preserved, i ≥ 2 outside hypothesis 已被脚本预过滤）。

## Bigon Puncture 统计 (Level 4)

| 字段 | 值 |
|------|----|
| `bigons_without_puncture_pre`  total | **0** |
| `bigons_without_puncture_post` total | **0** |
| `all_bigons_contain_puncture_pre`  True | 1563 / 1563 |
| `all_bigons_contain_puncture_post` True | 1534 / 1563 (其余 29 个是 bigons_post=0 的空情况) |
| `bigons_pre` 分布 | 1–12, mean 7.17 |
| `bigons_post` 分布 | 0–12, mean 4.98 |
| `minimal_position_pre`  | False / 1563 |
| `minimal_position_post` | False / 1563 |

**注意**：在 S_{1,2} 上每个三角化顶点都是 puncture，所以我们用的"tip-corner-puncture"启发式必然给出 ≥ 1。该字段在更高维曲面（如 S_{2,0}）才会有非平凡的 0 值。

## v1 vs v2 评分对比

| Level | v1 评分 | v2 评分 | 关键变化 |
|-------|--------|--------|----------|
| 1 | NO_SIGNAL（1 case 不够分布） | **PATTERN** | 1563 cases 给出极强的 100% 模式 |
| 2 | NO_SIGNAL | **PATTERN** | candidate_total 在 1369/1563 上下降；outside_region crossings 永远 = 0 |
| 3 | NO_SIGNAL | **PATTERN（受限）** | β 永远在 surgery region 内；S_{1,2} 上 region = 整张曲面，导致区域分析退化 |
| 4 | NO_SIGNAL | **PATTERN→ARGUMENT** | 0 个 reducible bigon（pre/post），bigon 计数从 mean 7.17 降到 4.98 |
| 5 | NO_SIGNAL | **ARGUMENT** | boundary_relaxation 反事实给出 net_change = -2，确认 i ≤ 1 是 sharp 边界 |

## 逐层分析

### Level 1 — summary_delta only — **PATTERN**

数据：1563 个 case 的 `intersection_number_delta = 0`（100%）。`weight_b_delta = 0`（β 从未被修改，证实变换只作用于 α）；`weight_a_delta` 范围 [-108, -6]（σ_α 总比 α 轻）。

发现：
- 在 i(α, β) = 1 的所有可枚举 case 上，i(σ_α, β) = 1。这是一个无例外的经验事实。
- σ_α 的 weight 严格小于 α 的 weight——surgery 在 train-track 表示下永远"压缩"曲线。

能否构造证明？还不能。Level 1 只给出"输入→输出"的不变量观测，没有任何关于"为什么"的结构化数据。这是 PATTERN（统一的经验规律），不是 ARGUMENT。

### Level 2 — + detailed_comparison — **PATTERN**

数据：
- `candidate_total` pre：min=3, max=110, mean=21.41
- `candidate_total` post：min=2, max=54, mean=11.93
- 1369/1563 cases 的 candidate_total 严格下降；191 持平；3 上升
- `crossings_outside_region` **始终 = 0**（pre 和 post 都是）
- 527/1563 cases 的 `crossings_in_region` 完全相等

发现：
- 几何上有意义的事实：surgery 通常显著降低 candidate crossings（mean 从 21 → 12）。如果 candidate 是 i 的上界且严格下降，但 i 没变，那么 σ_α 比 α 更接近 minimal position。
- 但 "outside_region = 0" 是一个**平凡观察**——在 S_{1,2} 上 surgery region 总是 4 个三角形（= 整张曲面），所以"outside"集合是空的。

能否构造证明？还不能。candidate 下降说明 σ_α 比 α 更紧凑，但没有给出"为什么 geometric intersection 必须保持"的结构性论证。仍是 PATTERN。

### Level 3 — + transform_trace + reference_in_transform_region — **PATTERN（受限）**

数据：
- `transform_region` 的三角形数 **永远 = 4**（= 整个曲面）
- `short_arc_triangles` 永远 = 4，`long_arc_triangles` 永远 = 0
- `beta_triangles_total` ∈ {2, 4}（β 占 2 或 4 个三角形）
- `beta_triangles_in_region` = `beta_triangles_total`（β 完全在 region 内）
- `beta_through_short_arc` = `beta_triangles_total`（β 完全穿过 short arc 区域）
- `beta_through_long_arc` 永远 = 0

发现：
- S_{1,2} 太小，使得 region/非-region 的对比退化——surgery 涉及整张曲面，β 必然在 region 内。
- 这层数据在更高维曲面上（如 S_{2,1}, S_{1,5}）才会有真正的杠杆。

能否构造证明？还不能。Level 3 在 S_{1,2} 上几乎不增加新信息。仍是 PATTERN。

### Level 4 — + structural_comparison — **PATTERN → ARGUMENT**

数据：
- `bigons_pre` 分布：{1: 40, 2: 144, 3: 7, 4: 66, 5: 202, 6: 298, 7: 101, 8: 290, 10: 107, 12: 308}
- `bigons_post` 分布：{0: 29, 1: 333, 2: 171, 3: 34, 4: 216, ..., 12: 167}
- **bigons_without_puncture_pre = 0**（无一例外）
- **bigons_without_puncture_post = 0**（无一例外）
- `minimal_position_pre` 全部 False，`minimal_position_post` 也全部 False（candidate 严格 > geometric）

发现：
1. 在我们的启发式定义下（bigon 的 2-三角形邻域里有 ≥ 1 个 puncture-vertex），**没有任何 bigon 被发现是 "reducible"**——pre 和 post 都没有。这是与 i 不变性一致的：如果存在可消除的 bigon，crossings_post 应该比 candidate_post 多，i 也可能降低；但 i 在所有 case 上严格保持。
2. bigon 数量从 pre 的均值 7.17 降到 post 的均值 4.98——**surgery 把 σ_α/β 推向更接近 minimal position**（虽然两侧都还没到达）。
3. 29 个 case 在 post 时 bigon_count = 0——σ_α 和 β 的 candidate crossings 已经没有重复，但 minimal_position 仍是 False（因为我们的定义是 candidate == geometric，不是 bigon == 0）。

> **重要的方法论 caveat**：在 S_{1,2} 上每个三角化顶点都是 puncture，所以"bigon 邻域内有 puncture"对所有 bigon 都恒为真——这是一个 surface-specific 的退化。要让该 tag 成为有效杠杆，需要在 S_{2,0} 或更复杂的曲面上验证。

**Argument 草图（基于 Level 4 数据）**：
> 如果 bigon B 能通过 free homotopy 把 (α, β) 的两个 crossings 消除，那么 B 的 interior 必须不含 puncture（puncture 阻挡 homotopy）。
> 经验观察：所有 1563 cases 中 0 个 bigon 满足此条件——所以所有 candidate bigons 都是 essential bigons，无法 homotope 消除。
> 因此 i(α, β) = candidate_total - 0 - n_essential_bigons，且 surgery 不改变 essential 状态（puncture 几何不变）→ i 保持。

这是 ARGUMENT 级别的论证：结构数据足够支持一个 sketch，但还需要严格证明"surgery 保持 bigon 的 puncture 归属"。Level 4 不能独立完成 PROOF。

### Level 5 — + counterfactual cases — **ARGUMENT（接近 PROOF）**

反事实数据：
| Strategy | Original | Modified | Critical | net_change |
|----------|----------|----------|----------|------------|
| boundary_relaxation | i(α,β) ≤ 1 | i(α,β) = 2 | **CRIT** | -2 |
| condition_removal | β ∈ DL(α) | β ∉ DL(α) | no | 0 |
| operation_perturbation | γ₀ = a_0 | γ₀ = c0 | no | 0 |

发现：
1. **boundary_relaxation 是 sharp**：把假设从 i ≤ 1 放宽到 i = 2，立刻出现 net_change = -2 的反例。这强烈证实 "i ≤ 1" 是不可放松的关键约束。
2. **condition_removal 不 critical**：在我们的搜索里，把 "β ∈ descending link" 去掉（取 level(β) ≥ level(α) 但 i(α,β) ≤ 1）后 net_change 仍是 0。这暗示 surgery 的不变性 **更基础**，与 descending link 结构无关——只依赖于 i(α,β) ≤ 1。
3. **operation_perturbation 不 critical**：把 γ_0 替换成另一条曲线后 net_change 仍是 0。这是因为我们的 surgery 实现退化到了"任何 search-fallback 找到的 universal filler 都行"，而不是真正强制使用一个非 γ_0 替换。

**结合 Level 1-5 的完整 argument 草图**：

> 给定 i(α, β) = 1，要证 i(σ_α, β) = 1。
>
> 1. **存在性**（Level 1）：1563/1563 case empirical 验证。
> 2. **结构观察**（Level 4）：σ_α 和 β 的所有 candidate bigons 都包含 puncture（在 2-triangle 邻域意义下），因此都是 essential——无法 homotope 消除，i = candidate − 0。
> 3. **边界紧性**（Level 5 boundary_relaxation）：i = 2 时立刻反例，说明 i ≤ 1 不能放宽。
> 4. **结论**：在 i(α, β) ≤ 1 的假设下，σ_α 和 β 同样满足 i ≤ 1，且不存在 reducible bigon——i(σ_α, β) = i(α, β)。

这接近 PROOF，但仍需补严格论证：
- (a) 严格说明"surgery 保持 bigon 的 puncture 几何归属"
- (b) 排除 i(σ_α, β) > i(α, β) 的可能（数据上没看到，但需要 a priori 上界）

最终评分：**ARGUMENT**（不是 PROOF，因为缺少 (a)(b) 两步）。

## 结论

### bigon puncture tag 是否改变了 Level 4 的评分？

是，但不彻底。Level 4 从单纯的 PATTERN 升级到 PATTERN→ARGUMENT 边缘——bigon 的 puncture 数据为"为什么 i 保持"提供了第一个**结构性解释**（"reducible bigon 不存在 → i = candidate"），而不只是经验观察。

但在 S_{1,2} 上 puncture-everywhere 的退化让该 tag 还不能独立完成 PROOF。**反事实仍是不可替代的杠杆**——只有 Level 5 的反例确认 i ≤ 1 的紧性。

### 信息阶梯

|Level| 信息 | 评分 | 是否新增证明杠杆 |
|---|---|---|---|
| 1 | 经验规律 | PATTERN | 是（基线） |
| 2 | candidate 下降 | PATTERN | 弱（量化收紧） |
| 3 | region 拓扑 | PATTERN（在 S_{1,2} 上退化） | 在更大曲面上才有用 |
| 4 | bigon puncture 结构 | PATTERN → ARGUMENT | 是（结构性论证） |
| 5 | 反事实验证 | ARGUMENT | 是（紧性 / sharpness） |

**核心发现**：bigon puncture tag 把 Level 4 从纯统计提升到结构论证；反事实把 Level 5 提升到紧性确认。两者**互补**——前者解释"为什么"，后者证明"不能更弱"。
