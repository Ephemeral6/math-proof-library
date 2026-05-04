"""LLM prompt templates for boundary_interior (terminal 8, dimension 6).

Goal: agent should discover that the boundary data of a lattice polygon
suffices to compute its interior — culminating in Pick's theorem
A = I + B/2 - 1.
"""

SYSTEM = """你面前有格点多边形 (lattice polygon) 的数据。

背景：一个二维多边形的顶点都在整数格点上。我们对 8 个预制多边形做了
4 类变换（add_vertex / translate / unimodular shear / non-uniform scale）和
若干 cross-pair 对比，共 87 个 case。

每个 case 给出多边形的：
- area（面积，由 shoelace 公式算）
- B（边界格点数）
- I（内部格点数）
- pick_holds（A 是否等于 I + B/2 - 1）

你的目标是理解：**为什么边界数据足以决定内部？** 进而构造 Pick 定理 A = I + B/2 − 1 的证明（或论证）。

规则：
- 不要搜索文献，纯粹从数据推理
- 先分析数据中的 pattern（A、B、I 的关系），再尝试构造证明
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL"""

DATA_DESCRIPTIONS = {
    "000": """你只有每个 (P, P') pair 的 summary_delta：
- area_a / area_b: pre / post 的 shoelace 面积
- perimeter_a / perimeter_b: pre / post 的周长
- n_vertices_a / n_vertices_b: 顶点数
- B_a / B_b: 边界格点数
- I_a / I_b: 内部格点数
- pick_holds_a / pick_holds_b: A == I + B/2 − 1 是否成立

共 87 个 case（8 个预制多边形 × 多种变换 + 10 个 cross-pair）。""",

    "R00": """你有每个 case 的 summary_delta（同上），加上：

detailed_comparison：
- area_preserved（变换是否保面积）
- B_change / I_change（边界/内部格点数变化）
- edges_pre / edges_post（每条边的方向、长度、gcd、边上的格点数）

structural_comparison（拓扑结构）：
- pick_holds_pre / pick_holds_post / pick_preserved
- area_from_pick_pre = I + B/2 - 1（pre）
- area_from_pick_post = I + B/2 - 1（post）
- area_from_shoelace_pre / area_from_shoelace_post
- is_lattice_pre / is_lattice_post
- is_simple_pre / is_simple_post

共 87 个 case。""",

    "0T0": """你有每个 case 的 summary_delta（同上），加上：

transform_trace：
- operation_name: add_vertex / translate / shear / scale_non_uniform / identity_compare
- operation_params: 详细参数
- before_state / after_state: area, B, I, pick_holds, n_vertices
- delta:
    - area_change（数值）
    - B_change / I_change
    - area_preserved（bool）
    - pick_preserved（bool）
- region_affected: 操作类型、顶点数变化

reference_in_transform_region: 同 region_affected。

共 87 个 case。""",

    "00C": """你有每个 case 的 summary_delta（同上），加上：

反事实数据 (counterfactual)：
- boundary_relaxation: 正例用格点坐标（Pick 成立），反事实把一个顶点偏移 0.5（非格点）→ Pick 不再适用。
- operation_perturbation: 正例 unimodular shear（保面积），反事实 non-uniform scale（不保面积）→ 两者都还是 lattice 多边形，但面积比为 det。
- condition_removal: 正例简单多边形，反事实自交（bowtie）→ Pick 不适用。

每个反事实给出 original / counterfactual 的 area, B, I, pick_holds，以及 delta 和 explanation。

问题：什么条件保证 Pick 定理成立？变换在什么条件下保持面积？""",

    "RT0": """你有完整的几何数据（不含反事实）：
- summary_delta
- detailed_comparison（边数据、面积/B/I 变化）
- structural_comparison（pick_holds、area_from_pick vs area_from_shoelace、is_lattice、is_simple）
- transform_trace（变换的轨迹：操作名、before/after state、delta）
- reference_in_transform_region

共 87 个 case。""",

    "R0C": """你有结构数据 + 反事实：
- summary_delta
- detailed_comparison
- structural_comparison
- counterfactual

但你没有 transform 的局部 trace（不知道变换前后 area/B/I 的具体数值变化轨迹）。""",

    "0TC": """你有变换轨迹 + 反事实：
- summary_delta
- transform_trace（每个变换的 area_change, B_change, I_change, area_preserved 等）
- reference_in_transform_region
- counterfactual

但你没有 per-edge 数据和 pick_holds 详细对比。""",

    "RTC": """你有全部数据：
- summary_delta
- detailed_comparison（per-edge data, B/I changes）
- structural_comparison（pick formula 双边比对）
- transform_trace
- reference_in_transform_region
- counterfactual（boundary_relaxation / operation_perturbation / condition_removal 三类）

共 87 个 case + 3 个反事实。""",
}

TASK = """
你的任务：
1. 分析数据中的 pattern：A、B、I 三者之间是什么关系？变换如何影响这些量？
2. 尝试回答：
   (a) 为什么对所有 lattice 多边形都有 A = I + B/2 − 1？
   (b) 哪些变换保持面积，哪些不保？为什么？
   (c) 为什么边界数据（顶点列表 / 每条边的 gcd）就足以决定内部格点数 I？
3. 如果可能，构造 Pick 定理的证明或论证
4. 诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL

输出格式：
## 数据分析
[你从数据中观察到什么 pattern]

## 论证尝试
[你的证明尝试，如果有的话]

## 自评
评分：[PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL]
理由：[为什么给自己这个分数]
"""


def build_prompt(condition: str) -> str:
    return f"{SYSTEM}\n\n## 你拥有的数据\n\n{DATA_DESCRIPTIONS[condition]}\n{TASK}"
