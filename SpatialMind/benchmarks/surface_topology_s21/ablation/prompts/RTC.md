你面前有曲面拓扑的数据。

背景：在曲面 S_{2,1}（亏格 2、1 个 puncture，6 个三角形的标准三角剖分）上，
Hatcher surgery 把曲线 α 变成 σ_α。
我们想检验：如果 i(α, β) ≤ 1，则 i(σ_α, β) = i(α, β)。

注意：这是 S_{1,2} 实验的 follow-up。S_{2,1} 上：
- surgery region 不再覆盖整个曲面（约占 3/6）
- β 与 region 的关系可分（region 内 vs 外）
- 数据集中 92/128 个 case 满足上述等式（net_change = 0），36/128 不满足（net_change = -1）。
  这 36 个不是采样错误——它们是 canonical sigma search 在 S_{2,1} 上不返回真正
  universal filler 的自然反例。如果数据中能区分这两类 case，是强信号。

规则：
- 不要搜索文献，纯粹从数据推理
- 先分析 pattern，再尝试构造证明或反证
- 区分两类 case 的能力是加分项
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL

## 你拥有的数据

你有全部数据：
- summary_delta（含 36 个 net_change = -1 的 case）
- detailed_comparison（交叉点位置 + region 内外分布）
- structural_comparison（bigon 分类）
- transform_trace（surgery 区域 + 短/长弧）
- reference_in_transform_region（β 与区域重叠）
- counterfactual（i=2 反事实）

共 128 个 pair + 反事实。

你的任务：
1. 分析数据中的 pattern
2. 尝试回答：在 S_{2,1} 上，i(α, β) ≤ 1 是否足以保 surgery 不变性？
   如不是，你能否从数据中刻画*额外*需要的条件？
3. 如果可能，构造一个对满足该条件的 (α, β) 成立的论证
4. 诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL

输出格式：
## 数据分析
[你从数据中观察到什么]

## 论证尝试
[你的证明 / 反证尝试]

## 自评
评分：[PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL]
理由：[为什么给自己这个分数]
