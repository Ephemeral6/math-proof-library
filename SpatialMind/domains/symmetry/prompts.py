"""LLM prompt templates for the symmetry-combinatorics domain.

Mirrors the structure of knot_theory/prompts.py and surface_topology
prompts. The target theorem is Burnside's lemma:

    |X / G| = (1/|G|) Σ_{g ∈ G} |Fix(g)|

The benchmark gives 200 colorings of the 6-vertex hexagon with 3 colors
under the cyclic group Z_6, plus the result of applying a random group
element to each first coloring. We want the LLM to discover from data
that:

  (1) "same orbit" is the equivalence relation induced by group action;
  (2) Stabilizer × orbit = group order (orbit-stabilizer theorem);
  (3) The number of orbits equals (1/|G|) Σ |Fix(g)| (Burnside).
"""

SYSTEM = """你面前有一组 6 顶点正六边形 3 着色的对称性数据。

背景：考虑正 6 边形的 3 色着色，共 3^6 = 729 种着色。Z_6 旋转群作用在着色上：
两个着色 a, b 称为「同一轨道」当且仅当存在 r ∈ Z_6 使得 r·a = b。
我们提供了 200 对 (a, b)，其中 100 对同轨道、100 对不同轨道，并对每对的 a
施加一个随机非恒等群元素 g 得到 σ_a = g·a。

你的目标是：
- 理解「同轨道」这个等价关系的代数本质；
- 发现 |X/G| = (1/|G|) Σ |Fix(g)| 这条 Burnside 引理；
- 构造证明。

规则：
- 不要搜索文献，纯粹从数据推理
- 先分析数据中的 pattern，再尝试构造证明
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL"""

DATA_DESCRIPTIONS = {
    "000": """你只有每个 (a, b) pair 的 summary_delta：
- hamming_distance: 两个着色在多少顶点处颜色不同
- same_orbit: a, b 是否同轨道（True/False）
- orbit_size_a / orbit_size_b: 各自轨道的大小
对每个 a 还施加了一个随机群元素 g 得到 σ_a，summary_delta 给出 σ_a 与 b 之间这些量的变化。

共 200 个 pair（100 同轨道 + 100 不同轨道）。""",

    "R00": """你有每个 pair 的 summary_delta（同上），加上：

detailed_comparison（per-element data）：
- connecting_pre / connecting_post: 把 a → b 或 σ_a → b 的群元素个数
- hamming_pre / hamming_post: 变换前后 a 与 b 的 hamming 距离
- same_orbit_pre / same_orbit_post: 变换前后 same_orbit 标志

structural_comparison（群论结构数据）：
- stabilizer_a_size_pre / stabilizer_a_size_post: a 和 σ_a 的稳定子大小
- orbit_stabilizer_holds_pre / _post: |Stab| × |Orbit| 是否等于 |G|
- fixed_point_counts: dict {group_element_index: how many colorings it fixes}
- burnside_count: (1/|G|) Σ |Fix(g)|，作为参考值
- total_orbits: 实际轨道数（应当与 burnside_count 一致）
- group_order: |G|

共 200 个 pair。""",

    "0T0": """你有每个 pair 的 summary_delta（同上），加上：

transform_trace（群作用 g·a = σ_a 的轨迹）：
- operation_name: "group_action"
- operation_params.permutation: g 作为顶点置换的形式（如 [2,3,4,5,0,1] 表示旋转 4 步）
- operation_params.is_rotation: 是否为旋转（Z_6 全是旋转）
- operation_params.order: g 在群中的阶
- before_state / after_state: a 和 σ_a 的着色
- delta.vertices_changed: σ_a 与 a 在多少个顶点处颜色不同
- delta.is_fixed_point: a 是否被 g 固定
- region_affected.moved_vertices / fixed_vertices: 哪些顶点动了 / 没动

reference_in_transform_region:
- moved_vertices / fixed_vertices: 同上
- b_colors_at_moved / b_colors_at_fixed: b 在这些位置的颜色

共 200 个 pair。""",

    "00C": """你有每个 pair 的 summary_delta（同上），加上：

反事实数据 (counterfactual)：
- boundary_relaxation: 把 G = Z_6 放大成 D_6（加上 6 个反射）→ 看 same_orbit 是否变化
- condition_removal: 把 G = Z_6 缩小成 {e} → same_orbit 退化为 a == b
- operation_perturbation: 用一个非群元素的置换（swap 顶点 0,1）作用在 a 上 → 结果不再与 a 同轨道

每个反事实给出 original / counterfactual 的 same_orbit 标志、轨道总数变化（orbit_count_change），以及 condition_is_critical。

问题：为什么轨道数恰好是 130？为什么 |Stab(a)| × |Orbit(a)| = |G|？""",

    "RT0": """你有完整的几何数据（不含反事实）：
- summary_delta
- detailed_comparison（n_connecting、hamming、same_orbit pre/post）
- structural_comparison（stabilizer 大小、orbit-stabilizer 是否成立、fixed_point_counts、burnside_count、total_orbits、group_order）
- transform_trace（群元素作用的具体置换、阶、moved/fixed 顶点）
- reference_in_transform_region（b 在 moved/fixed 顶点上的颜色）

共 200 个 pair。""",

    "R0C": """你有结构数据 + 反事实：
- summary_delta
- detailed_comparison
- structural_comparison（stabilizer、orbit-stabilizer、fixed_point_counts、burnside_count）
- counterfactual（Z_6→D_6、Z_6→{e}、非群置换）

但你没有 transform 的局部轨迹（不知道每个 g 的具体置换、moved 顶点）。""",

    "0TC": """你有变换轨迹 + 反事实：
- summary_delta
- transform_trace（g 的置换、阶、moved/fixed 顶点）
- reference_in_transform_region
- counterfactual（Z_6→D_6、Z_6→{e}、非群置换）

但你没有 per-element 结构数据（不知道 stabilizer 大小、fixed_point_counts、burnside_count、轨道总数）。""",

    "RTC": """你有全部数据：
- summary_delta
- detailed_comparison（n_connecting、hamming、same_orbit pre/post）
- structural_comparison（stabilizer、orbit-stabilizer、fixed_point_counts、burnside_count、total_orbits）
- transform_trace（群作用置换、阶、moved/fixed 顶点）
- reference_in_transform_region（b 在 moved/fixed 上的颜色）
- counterfactual（Z_6→D_6、Z_6→{e}、非群置换）

共 200 个 pair + 反事实。""",
}

TASK = """
你的任务：
1. 分析数据中的 pattern
2. 尝试回答：
   (a) 为什么 same_orbit 是一个等价关系？
   (b) 为什么 |Stab(a)| × |Orbit(a)| = |G|？（轨道-稳定子定理）
   (c) 为什么轨道数 = (1/|G|) Σ_{g ∈ G} |Fix(g)|？（Burnside 引理）
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
