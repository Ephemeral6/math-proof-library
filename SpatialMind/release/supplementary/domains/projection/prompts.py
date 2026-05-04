"""LLM prompt templates for the projection domain.

Target: dimensional awareness — agent should recognize information loss in
projection, identify which 3D properties are recoverable from 2D, and
articulate when two different 3D objects can produce identical 2D shadows.
"""

SYSTEM = """你面前有三维点集（多面体顶点）的二维投影数据。

背景：5 个三维多面体（cube、tetrahedron、octahedron、triangular_prism、square_antiprism）
分别投影到 4 个平面（xy / xz / yz / 沿 (1,1,1) 对角方向）。我们提供 66 个 case，
分三类：
- self_projection (20)：同一个对象与自身投影的对照，看丢了什么；
- cross_projection (30)：同一对象的两个不同投影，看不同投影丢的信息是否对称；
- cross_object (16)：两个 *不同* 对象（同 n_points）投影到同一平面，看投影后能否区分。

你的任务：
- 理解投影中哪些信息被丢失、哪些被保留；
- 判断哪些三维性质在所有投影下都不变（拓扑级不变量）、哪些依赖于投影方向；
- 判断不同三维对象在某投影下是否可能"撞影"（信息无法区分）；
- 回答：能否从投影的距离矩阵恢复原始三维对象？

规则：
- 不要搜索文献，纯粹从数据推理
- 先观察 pattern，再尝试论证
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL"""

DATA_DESCRIPTIONS = {
    "000": """你只有每个 case 的 summary_delta：
- n_points_a / n_points_b: a 和 b 的点数（projection 之前的 n_points 不变）
- dimension_a / dimension_b: 维度（投影前后差 1）
- diameter_a / diameter_b: 各自最远两点的距离
- edge_crossings_a / _b（仅 2D 对象）：投影后边的交叉数

metadata 给出 case 类型、对象名、投影平面（plane / plane_a/b）、n_points/n_edges。

共 66 个 case。""",

    "R00": """你有每个 pair 的 summary_delta（同上），加上：

detailed_comparison（信息损失摘要）：
- collisions_introduced：投影后有多少对点重合
- crossings_introduced：投影后有多少对边交叉
- fraction_distances_preserved：所有点对距离中，投影后保持的比例
- diameter_change：直径变化

structural_comparison：
- distances_preserved_count / distances_total：保持的距离对数 / 总数
- dimension_before / dimension_after: 3 / 2
- information_loss_summary: {collisions, crossings, distance_distortion}
- invariants_preserved: 哪些不变量被保持
- invariants_delta: 不变量的数值变化

每对的 detailed level 还包含 distance_matrix_a / _b（5×5 到 8×8 不等）。

共 66 个 case。""",

    "0T0": """你有每个 case 的 summary_delta，加上：

transform_trace（投影变换的轨迹）：
- operation_name: "projection"
- operation_params.plane / dropped_axis: 哪个平面 / 丢掉了哪个轴
- before_state: dimension=3, n_points, diameter
- after_state: dimension=2, n_points, diameter, edge_crossings
- delta:
  - dimension_lost = 1
  - n_point_collisions: 投影后重合的点对数
  - n_edge_crossings_introduced: 投影后边的交叉
  - fraction_distances_preserved
  - distances_total / distances_preserved
  - diameter_change

reference_in_transform_region:
- collided_point_pairs: [(i, j), ...]
- most_distorted_pairs: 最被扭曲的 5 对
- n_collisions, n_crossings

共 66 个 case。""",

    "00C": """你有每个 case 的 summary_delta，加上：

反事实数据（在 cube × xy 投影上）：
- boundary_relaxation: 不投影（保持 3D）→ 100% 距离保持，0 collision；vs 投影 43% 保持，4 collisions。
- operation_perturbation: 把 z 轴 ×0.5 而不是丢掉 → 距离保持率不变（43%）但 collisions 0；vs 投影 4 collisions。
- condition_removal: 投影后合并重合点 → 8→4 点，0 crossings；vs 投影保留 8 点 8 crossings。

每个反事实给出 original / counterfactual 的关键数值，以及 condition_is_critical。

问题：投影丢了什么是结构必然，什么可避免？""",

    "RT0": """你有完整的几何数据（不含反事实）：
- summary_delta
- detailed_comparison（collisions, crossings, fraction_preserved, diameter_change）
- structural_comparison（distance preserved 比例、information_loss_summary、invariants_preserved/delta）
- transform_trace（投影方向、丢的轴、before/after state、delta、collided/crossing pairs）
- reference_in_transform_region

共 66 个 case。""",

    "R0C": """你有结构数据 + 反事实：
- summary_delta
- detailed_comparison
- structural_comparison
- counterfactual（不投影 / 部分压缩 / 合并重合点）

但你没有 transform 的局部轨迹（不知道每个 case 的 collided_point_pairs、most_distorted_pairs）。""",

    "0TC": """你有变换轨迹 + 反事实：
- summary_delta
- transform_trace（投影方向、丢的轴、collided pairs、most_distorted_pairs）
- reference_in_transform_region
- counterfactual（不投影 / 部分压缩 / 合并重合点）

但你没有结构层的距离矩阵和 invariants_preserved 字段。""",

    "RTC": """你有全部数据：
- summary_delta
- detailed_comparison（collisions, crossings, fraction_preserved, diameter_change）
- structural_comparison（distance 矩阵保持比例、信息损失摘要、invariants_preserved/delta）
- transform_trace（投影方向、丢的轴、collided pairs、most_distorted_pairs）
- reference_in_transform_region
- counterfactual（不投影 / 部分压缩 / 合并重合点）

共 66 个 case + 反事实。""",
}

TASK = """
你的任务：
1. 分析数据中的 pattern
2. 尝试回答以下三个问题中至少一个：
   (a) 哪些三维性质在所有投影下都不变（拓扑级不变量）？哪些依赖于投影方向？
   (b) 两个不同的三维对象在某投影下能否产生完全相同的 2D 影子？
       如果不能，需要哪些数据来排除这种"撞影"？
   (c) 给定 2D 投影的距离矩阵，能否唯一重建原始 3D 对象？为什么？
3. 如果可能，构造证明
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


def build_prompt(condition: str) -> str:
    return f"{SYSTEM}\n\n## 你拥有的数据\n\n{DATA_DESCRIPTIONS[condition]}\n{TASK}"
