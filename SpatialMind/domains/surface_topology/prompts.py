"""Surface topology benchmark prompts."""

from SpatialMind.core.prompt import BenchmarkPrompt, LEVEL_DESCRIPTIONS


DOMAIN_DESCRIPTION = """在曲面 S_{1,2}（亏格 1、2 个 puncture）上，有一组简单闭曲线。
Hatcher surgery 把曲线 α 沿参考曲线 γ₀ 变换为新曲线 σ_α。
我们验证了 99 个 (α, β) pair 上 i(σ_α, β) = i(α, β)（geometric intersection number 不变）。
你的目标是理解 **为什么** 不变，并构造一个对任意 (α, β) with i(α, β) ≤ 1 成立的证明。"""


DATA_GUIDE = """数据字段说明：
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
- structural_comparison.all_bigons_contain_puncture_*: 是否所有 bigon 都含 puncture"""


LEVEL_TASKS = {
    1: """1. 统计 99 个 case 的 summary_delta.intersection_number 分布
2. 为什么所有值都是 0？
3. 能否构造证明？""",

    2: """1. 交叉点数量（candidate count）在变换前后怎么变化？
2. 变换区域内外的交叉点分别怎么变？
3. 能否从交叉点的位置变化中发现对消结构？
4. 能否构造证明？""",

    3: """1. β 和变换区域（surgery region）的重叠关系是什么？
2. 当 i(α,β) = 0 时，β 在变换区域内有多少三角形？
3. 当 i(α,β) = 1 时呢？
4. β 穿过变换区域的次数和 i(α,β) 有什么关系？
5. 能否构造证明？""",

    4: """1. 变换前后 bigon 数量怎么变化？
2. 每个 bigon 是否包含 puncture？
3. 如果所有 bigon 都包含 puncture，这意味着什么？
   （提示：不含 puncture 的 bigon 可以通过 homotopy 消除）
4. surgery 是否改变了 bigon 的 puncture 归属？
5. 能否构造证明：surgery 不改变 bigon 的 puncture geography → 不改变 geometric intersection？""",

    5: """1. 反事实 case：i(α,β) = 2 时，surgery 后 net_change 是多少？
2. 对比正例（i≤1, net=0）和反事实（i=2, net≠0），关键区别在哪里？
3. 为什么 i(α,β) ≤ 1 是关键约束？
4. 构造一个完整的证明：如果 i(α,β) ≤ 1，则 i(σ_α, β) = i(α,β)。""",
}


CF_GUIDE = """数据中有反事实 case：条件 i(α,β) ≤ 1 被放宽为 i(α,β) = 2。
在放宽后，surgery 可能改变交叉数（net_change ≠ 0）。
对比正例和反事实：
- 正例中 β 和变换区域的关系 vs 反事实中的关系
- 正例中 bigon 的 puncture 归属 vs 反事实中的
- 为什么放宽条件后不变量被破坏？"""


def make_prompt(level: int) -> BenchmarkPrompt:
    p = BenchmarkPrompt(
        domain_description=DOMAIN_DESCRIPTION,
        level_description=LEVEL_DESCRIPTIONS[level],
        data_guide=DATA_GUIDE,
        task=LEVEL_TASKS[level],
    )
    if level == 5:
        p.counterfactual_guide = CF_GUIDE
    return p
