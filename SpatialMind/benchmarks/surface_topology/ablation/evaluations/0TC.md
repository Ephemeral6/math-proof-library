# Condition 0TC — T + C (no Relation)

## 数据分析
**T 信号（在 S_{1,2} 退化）**：region = 全部 4 个三角形；long_arc = 空；β 完全在区域内；punctures_in_region = 2 for all。

**C 信号**：i ≤ 1 critical；descending link 和 γ₀ 不 critical。

## 论证尝试

C 给出了「问题简化到 i = 1 vs i = 2 的边界」。
T 在这个边界两侧应该展示 *不同的局部行为*——例如 i = 2 case 中 β 与 surgery region 的重叠模式应该不同。

但是：
- 我只有正例（i = 1）的 T 数据。反事实只给了 summary delta（net = −2），**没有反事实 case 的 T 数据**。
- 在所有正例上，T 数据近乎相同（degenerate）：β 总是覆盖区域 2–4 个三角形，long_arc = 0。

所以我看不到 T 在 i = 1 vs i = 2 的对比——T 在正例侧已经 saturated，反事实侧无 T 数据。

没有 R 数据，我也不知道 bigon 结构是否随 i 变化。

最终我能说的不超过 00C：知道 i ≤ 1 是 load-bearing，但不知道在 i = 1 时 surgery 的局部行为为什么 *能* 守住 invariant。

## 自评
**评分：PATTERN（2，等于 00C，T 没有给额外信号）**

理由：T 在 S_{1,2} 上退化，所以 0TC ≈ 00C。C 的反事实信号是这两条件下唯一的「认知抓手」。

> 这是另一个 *预期退化*：在 S_{2,1} 上 0TC 应该明显高于 00C（T 不再退化，能展示局部 surgery 行为）。
