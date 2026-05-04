"""LLM prompt templates for graph_connectivity (terminal 5, dimension 2).

Goal of the experiment: agent should identify the **critical point** in an
edge-deletion sequence — i.e. which edges, when deleted, break connectivity.
The mathematical content is: a deletion increases the component count iff
the deleted edge is a bridge.
"""

SYSTEM = """你面前有图论的数据。

背景：给定一个连通图 G 和一个边 e。删除 e 之后，图可能仍然连通，也可能分裂成两个连通分量。
我们生成了 100 个 (G, e) pair 并记录了删边的效果。
你的目标是理解 **什么决定了删一条边会破坏连通性**，并构造一个判定规则的证明。

规则：
- 不要搜索文献，纯粹从数据推理
- 先分析数据中的 pattern（哪些 case 连通性被破坏，哪些没有），再尝试构造证明
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL"""

DATA_DESCRIPTIONS = {
    "000": """你只有每个 (G, e) pair 的 summary_delta：
- n_components_a: 删边前后连通分量数变化
- is_connected_a: 删边前后是否连通（{"pre": ..., "post": ...} 或 "unchanged"）
- n_edges_a: 边数变化（恒为 -1）
- n_vertices_a: 顶点数变化（恒为 0）

共 100 个 (G, e) pair（20 个图 × 5 次删边）。""",

    "R00": """你有每个 pair 的 summary_delta（同上），加上：

detailed_comparison（结构数据）：
- n_edges_pre / n_edges_post: 边数
- n_bridges_pre / n_bridges_post: **桥边数量**（删掉后会增加分量的边）
- deleted_edge_was_bridge: 这次删的边是不是桥边
- connectivity_lost: 这次删边是否破坏了连通性
- n_components_pre / n_components_post: 分量数

structural_comparison（拓扑结构）：
- components_pre / components_post: 分量列表
- articulation_points_pre / articulation_points_post: 关节点（割点）
- is_connected_pre / is_connected_post / is_connected_preserved
- n_components_preserved

共 100 个 pair。""",

    "0T0": """你有每个 pair 的 summary_delta（同上），加上：

transform_trace:
- operation_name: "delete_edge"
- before_state / after_state: n_edges, n_components, is_connected
- delta:
    - n_edges_delta: -1
    - components_change: +0 或 +1
    - is_bridge: 这条边是不是桥边
    - connectivity_lost: 是否破坏连通性
- region_affected:
    - deleted_edge: [u, v]
    - endpoint_degrees_before / endpoint_degrees_after: 端点的度数变化

reference_in_transform_region: 同 region_affected。

共 100 个 pair。""",

    "00C": """你有每个 pair 的 summary_delta（同上），加上：

反事实数据 (counterfactual)：
- boundary_relaxation: 正例删非桥边（连通性保持），反事实删桥边（连通性破坏）
- operation_perturbation: 正例删边（分量数增加或不变），反事实加边（分量数减少或不变）

每个反事实给出 original / counterfactual 的 components 数、connectivity_lost，以及 delta。

问题：什么决定了一次删边会破坏连通性？""",

    "RT0": """你有完整的几何数据（不含反事实）：
- summary_delta
- detailed_comparison（桥边数 + 是否破坏连通性的 flag）
- structural_comparison（分量列表 + 关节点）
- transform_trace（删边的 trace：删了哪条边、是不是桥、是否破坏连通性）
- reference_in_transform_region（端点度数变化）

共 100 个 pair。""",

    "R0C": """你有结构数据 + 反事实：
- summary_delta
- detailed_comparison
- structural_comparison
- counterfactual（删非桥 vs 删桥；删边 vs 加边）

但你没有 transform 的局部 trace（不知道删的具体是哪条边、端点度数怎么变）。""",

    "0TC": """你有变换轨迹 + 反事实：
- summary_delta
- transform_trace（删了哪条边、is_bridge、connectivity_lost、端点度数）
- reference_in_transform_region
- counterfactual

但你没有结构数据（不知道每个图的桥边总数、关节点、分量列表）。""",

    "RTC": """你有全部数据：
- summary_delta
- detailed_comparison（桥边数、connectivity_lost 标志、分量数）
- structural_comparison（分量列表、关节点）
- transform_trace（删边轨迹 + is_bridge + connectivity_lost）
- reference_in_transform_region（端点度数变化）
- counterfactual（删非桥 vs 删桥、删 vs 加）

共 100 个 pair + 反事实。""",
}

TASK = """
你的任务：
1. 分析数据中的 pattern：哪些删边操作破坏了连通性？哪些没有？
2. 尝试回答：什么决定了一次删边会破坏连通性？（提示：找到一个图论性质 P，使得"删边 e 破坏连通性 ⇔ P(e) 成立"）
3. 如果可能，构造一个证明（双向论证）
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
