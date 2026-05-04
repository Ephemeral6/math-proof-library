"""为 8 个 ablation 条件各生成一个 prompt 文件。"""

from pathlib import Path

ROOT = Path(__file__).parent.parent
BD = ROOT / "benchmarks" / "surface_topology" / "ablation"

SYSTEM = """你面前有曲面拓扑的数据。

背景：在曲面 S_{1,2} 上，Hatcher surgery 把曲线 α 变成 σ_α。
我们想证明：如果 i(α, β) ≤ 1，则 i(σ_α, β) = i(α, β)。

规则：
- 不要搜索文献，纯粹从数据推理
- 先分析数据中的 pattern，再尝试构造证明
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL"""

DATA_DESCRIPTIONS = {
    "000": """你只有每个 (α, β) pair 的 summary_delta：
- intersection_number: surgery 前后交叉数的变化（全部为 0）
- weight_a: α 的权重变化
- weight_b: β 的权重变化（全部为 0，β 不参与 surgery）

共 1563 个 pair。""",

    "R00": """你有每个 pair 的 summary_delta（同上），加上：

detailed_comparison:
- crossings_pre_count / crossings_post_count: 候选交叉点数量变化
- crossings_in_transform_region_pre/post: 变换区域内的候选交叉点
- crossings_outside_region_pre/post: 变换区域外的候选交叉点
- crossings_pre_locations / crossings_post_locations: 每个交叉点在哪个三角形

structural_comparison:
- bigons_pre / bigons_post: bigon 数量
- bigons_with_puncture_pre / bigons_with_puncture_post: 含 puncture 的 bigon 数
- bigons_without_puncture_pre / bigons_without_puncture_post: 不含 puncture 的 bigon 数
- all_bigons_contain_puncture_pre/post: 是否所有 bigon 都含 puncture

共 1563 个 pair。""",

    "0T0": """你有每个 pair 的 summary_delta（同上），加上：

transform_trace:
- operation_name: "hatcher_surgery"
- region_affected.triangles: surgery 影响的三角形列表
- region_affected.punctures_in_region: 区域内 puncture 数
- region_affected.short_arc_triangles / long_arc_triangles: 短弧/长弧三角形
- delta.level_shift: α level 的变化
- delta.weight_shift: α weight 的变化

reference_in_transform_region:
- beta_triangles_total: β 经过的三角形总数
- beta_triangles_in_region: β 在变换区域内的三角形数
- beta_through_short_arc: β 和短弧重叠的三角形数
- beta_through_long_arc: β 和长弧重叠的三角形数

共 1563 个 pair。""",

    "00C": """你有每个 pair 的 summary_delta（同上），加上：

反事实数据：
- 正例条件：i(α, β) ≤ 1
- 放宽条件：i(α, β) = 2
- 正例中 surgery 的 net_change = 0
- 反事实中 surgery 的 net_change ≠ 0
- 反事实的具体数值在 counterfactual 块中

问题：为什么放宽 i ≤ 1 到 i = 2 后不变量被破坏？""",

    "RT0": """你有完整的几何数据（不含反事实）：
- summary_delta
- detailed_comparison（交叉点位置 + bigon puncture）
- structural_comparison（bigon 分类）
- transform_trace（surgery 区域 + 轨迹）
- reference_in_transform_region（β 与区域重叠）

共 1563 个 pair。""",

    "R0C": """你有交叉点结构数据 + 反事实：
- summary_delta
- detailed_comparison（交叉点位置）
- structural_comparison（bigon puncture 分类）
- counterfactual（i=2 时 net_change ≠ 0）

但你没有 surgery 的局部轨迹（不知道 surgery 影响了哪些三角形、β 和区域的关系）。""",

    "0TC": """你有变换轨迹 + 反事实：
- summary_delta
- transform_trace（surgery 区域 + 轨迹）
- reference_in_transform_region（β 与区域重叠）
- counterfactual（i=2 时 net_change ≠ 0）

但你没有交叉点的精确位置和 bigon 结构。""",

    "RTC": """你有全部数据：
- summary_delta
- detailed_comparison（交叉点位置 + 候选数量变化）
- structural_comparison（bigon puncture 分类）
- transform_trace（surgery 区域 + 轨迹）
- reference_in_transform_region（β 与区域重叠）
- counterfactual（i=2 时 net_change ≠ 0）

共 1563 个 pair + 反事实。""",
}

TASK = """
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
"""


def main():
    BD.mkdir(parents=True, exist_ok=True)
    prompt_dir = BD / "prompts"
    prompt_dir.mkdir(parents=True, exist_ok=True)

    for cond in DATA_DESCRIPTIONS:
        text = f"{SYSTEM}\n\n## 你拥有的数据\n\n{DATA_DESCRIPTIONS[cond]}\n{TASK}"
        path = prompt_dir / f"{cond}.md"
        path.write_text(text, encoding="utf-8")
        print(f"  {cond}.md written ({len(text)} chars)")

    print(f"\n8 个 prompt 已生成到 {prompt_dir}")


if __name__ == "__main__":
    main()
