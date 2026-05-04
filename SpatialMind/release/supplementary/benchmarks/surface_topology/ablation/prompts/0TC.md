你面前有曲面拓扑的数据。

背景：在曲面 S_{1,2} 上，Hatcher surgery 把曲线 α 变成 σ_α。
我们想证明：如果 i(α, β) ≤ 1，则 i(σ_α, β) = i(α, β)。

规则：
- 不要搜索文献，纯粹从数据推理
- 先分析数据中的 pattern，再尝试构造证明
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL

## 你拥有的数据

你有变换轨迹 + 反事实：
- summary_delta
- transform_trace（surgery 区域 + 轨迹）
- reference_in_transform_region（β 与区域重叠）
- counterfactual（i=2 时 net_change ≠ 0）

但你没有交叉点的精确位置和 bigon 结构。

你的任务：
1. 分析数据中的 pattern
2. 尝试回答：为什么 Hatcher surgery 保持 intersection number？
3. 如果可能，构造一个对任意 (α, β) with i(α, β) ≤ 1 成立的证明
4. 诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL

输出格式：
## 数据分析
[你从数据中观察到什么]

## 论证尝试
[你的证明尝试，如果有的话]

## 自评
评分：[PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL]
理由：[为什么给自己这个分数]
