你面前有几何变换的数据。你的目标是：
1. 从数据中发现变换为什么保持（或不保持）某个不变量
2. 构造一个对任意输入成立的证明

规则：
- 不要搜索文献，纯粹从数据推理
- 诚实评估你的发现：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL
- 先分析数据，再尝试构造证明

## 问题背景
在曲面 S_{1,2}（亏格 1、2 个 puncture）上，有一组简单闭曲线。
Hatcher surgery 把曲线 α 沿参考曲线 γ₀ 变换为新曲线 σ_α。
我们验证了 99 个 (α, β) pair 上 i(σ_α, β) = i(α, β)（geometric intersection number 不变）。
你的目标是理解 **为什么** 不变，并构造一个对任意 (α, β) with i(α, β) ≤ 1 成立的证明。

## 数据层级
Level 2: 在 Level 1 的基础上，你还有 per-element 的位置数据（detailed_comparison）。例如每个交叉点在哪个三角形、涉及哪些 arc。

## 数据字段说明
数据字段说明：
- summary_delta.intersection_number: 变换后交叉数的变化（0 = 不变）
- detailed_comparison.crossings_pre_count / crossings_post_count: 候选交叉点数量变化
- detailed_comparison.crossings_in_transform_region_*: 变换区域内的交叉点数量
- detailed_comparison.crossings_outside_region_*: 变换区域外的交叉点数量
- transform_trace.region_affected.triangles: surgery 影响的三角形列表
- transform_trace.region_affected.punctures_in_region: 变换区域内的 puncture 数
- reference_in_transform_region.beta_triangles_in_region: β 在变换区域内的三角形数
- reference_in_transform_region.beta_through_short_arc: β 穿过短弧三角形的次数
- reference_in_transform_region.beta_through_long_arc: β 穿过长弧三角形的次数
- structural_comparison.bigons_pre / bigons_post: bigon 数量变化
- structural_comparison.bigons_with_puncture_*: 含 puncture 的 bigon 数量
- structural_comparison.all_bigons_contain_puncture_*: 是否所有 bigon 都含 puncture

## 你的任务
1. 交叉点数量（candidate count）在变换前后怎么变化？
2. 变换区域内外的交叉点分别怎么变？
3. 能否从交叉点的位置变化中发现对消结构？
4. 能否构造证明？