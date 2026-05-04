# Condition RT0 — R + T (no Contrastive)

## 数据分析
拥有 R00 的所有 R 信号 + 0T0 的所有 T 信号。

**R 复述**：bigons_without_puncture 恒为 0；crossings_outside_region 恒为 0；minimal_position 恒为 false；candidate crossings 多变（3–16），常下降。

**T 复述（在 S_{1,2} 退化）**：region = 整个三角剖分（4 三角形），long_arc 为空，β 完全在区域内，所有 case 几乎相同。

**联合观察**：
- R 告诉我「所有候选交叉点都在变换区域内」（crossings_outside_region = 0）。
- T 告诉我「变换区域 = 整个曲面」。
- ⟹ 这两个信号一致——交叉点在区域内，因为区域就是全曲面。T 的 trivially-true 没有 *额外* 增强 R 的信号。

- bigon_puncture_classification 中，每个 bigon 的 (triangle_a, triangle_b, shared_edge) 都在整个三角剖分中。但 region 也是整个剖分，所以"bigon 在区域内 vs 区域外"的对比同样退化。

## 论证尝试
我有了 R 的 hypothesis（每个 bigon 都含 puncture，候选交叉全在 surgery 区域）但仍然：
- 没有 i(α, β) ≤ 1 是关键约束的信号——所有 case 的 i 都是 1，我无法区分它和 i = 2 的差别。
- T 的局部性退化，所以无法分析「哪些 bigon 被 surgery 操作消去 / 创建」。
- 候选数量的变化（11.91 → 8.74）+ bigon 数量的变化（pre 11204 → post 7790）暗示「surgery 整合了一些 bigon」，但我看不出代数守恒律。

仍然停留在 R 的 PATTERN 层级：观察清晰，但没有论证。

## 自评
**评分：PATTERN（2）**

理由：与 R00 比无实质提升，因为 T 在 S_{1,2} 上退化。没有 C 我也无从知道哪条假设是 load-bearing。预测在 S_{2,1} 上 RT0 会显著高于 R00（T 不再退化）。
