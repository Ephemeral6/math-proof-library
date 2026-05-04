"""为 S_{2,1} 上的 8 个 ablation 条件各生成一个 prompt 文件。

镜像 generate_ablation_prompts.py，但叙事调整为：
- 6 个三角形 (S_{2,1} 三角剖分)
- surgery region ⊊ 整个曲面（不再退化）
- 95% case 有 region 外的 crossing
- 128 个 case，其中 36 个 net_change ≠ 0（自然反例混入正例池）
- 引导 agent 关注 region 内/外对比、net_change == 0 vs ≠ 0 的 T 信号差异
"""

from pathlib import Path

ROOT = Path(__file__).parent.parent
BD = ROOT / "benchmarks" / "surface_topology_s21" / "ablation"

SYSTEM = """你面前有曲面拓扑的数据。

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
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL"""

DATA_DESCRIPTIONS = {
    "000": """你只有每个 (α, β) pair 的 summary_delta：
- intersection_number: surgery 前后交叉数的变化
  （92 个 case 为 0，36 个 case 为 -1）
- weight_a: α 的权重变化
- weight_b: β 的权重变化（全部为 0，β 不参与 surgery）

共 128 个 pair。""",

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
  （注：S_{2,1} 三角剖分只有 1 个 puncture vertex，
   每个三角形 corner 都落在该 puncture 上，所以 all_*_contain_puncture
   恒为 true——这是 curver 模型的结构特性，不是数据信号。）

共 128 个 pair。""",

    "0T0": """你有每个 pair 的 summary_delta（同上），加上：

transform_trace:
- operation_name: "hatcher_surgery"
- region_affected.triangles: surgery 影响的三角形列表
  （S_{2,1} 总共 6 个三角形；region 通常是其中 3 个，**不是全部**）
- region_affected.punctures_in_region: 区域内 puncture 数
- region_affected.short_arc_triangles / long_arc_triangles: 短弧/长弧三角形
- delta.level_shift: α level 的变化
- delta.weight_shift: α weight 的变化

reference_in_transform_region:
- beta_triangles_total: β 经过的三角形总数
- beta_triangles_in_region: β 在变换区域内的三角形数
- beta_through_short_arc: β 和短弧重叠的三角形数
- beta_through_long_arc: β 和长弧重叠的三角形数

提示：T 数据在 S_{2,1} 上不退化。可以问：
- region 占曲面的几分之几？
- β 落在 region 内 vs 外的比例？
- net_change = 0 的 case 和 net_change = -1 的 case，
  在 region/beta 关系上是否有可分的特征？

共 128 个 pair。""",

    "00C": """你有每个 pair 的 summary_delta（同上），加上：

反事实数据（counterfactual 块，3 个）：
- 正例条件：i(α, β) ≤ 1
- 放宽条件：i(α, β) = 2
- 各 CF 给出 strategy + delta 值

注意：S_{2,1} 上正例池 *本身* 已含 36 个 net_change = -1 的 case。
i ≤ 1 的边界并不像 S_{1,2} 那样把不变性完全保住。

问题：(a) 为什么 i ≤ 1 仍有失败？(b) i = 2 的反事实告诉了你什么？""",

    "RT0": """你有完整的几何数据（不含反事实）：
- summary_delta（含 36 个 net_change = -1 的 case）
- detailed_comparison（交叉点位置 + 候选数 + region 内外分布）
- structural_comparison（bigon 分类）
- transform_trace（surgery 区域 + 短/长弧三角形）
- reference_in_transform_region（β 与区域重叠）

共 128 个 pair。

引导：现在你能联合看 R 和 T。重点对比：
- 92 个 net_change = 0 的 case 与 36 个 net_change = -1 的 case
  在 (R, T) 联合特征上是否能分类？
- 区域外 crossing 的存在 / β 与 region 的重叠模式
  是否预测 net_change？""",

    "R0C": """你有交叉点结构数据 + 反事实：
- summary_delta（含 36 个 net_change = -1 的 case）
- detailed_comparison（交叉点位置 + region 内外分布）
- structural_comparison（bigon 分类）
- counterfactual（i=2 反事实）

但你没有 surgery 的局部轨迹（不知道 surgery 影响了哪些三角形、β 和区域的关系）。""",

    "0TC": """你有变换轨迹 + 反事实：
- summary_delta（含 36 个 net_change = -1 的 case）
- transform_trace（surgery 区域 + 短/长弧）
- reference_in_transform_region（β 与区域重叠）
- counterfactual（i=2 反事实）

但你没有交叉点的精确位置和 bigon 结构。""",

    "RTC": """你有全部数据：
- summary_delta（含 36 个 net_change = -1 的 case）
- detailed_comparison（交叉点位置 + region 内外分布）
- structural_comparison（bigon 分类）
- transform_trace（surgery 区域 + 短/长弧）
- reference_in_transform_region（β 与区域重叠）
- counterfactual（i=2 反事实）

共 128 个 pair + 反事实。""",
}

TASK = """
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

    print(f"\n8 prompts written to {prompt_dir}")


if __name__ == "__main__":
    main()
