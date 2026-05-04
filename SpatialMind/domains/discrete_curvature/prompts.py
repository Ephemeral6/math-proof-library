"""LLM prompt templates for the discrete_curvature domain.

Target theorem: discrete Gauss-Bonnet,
    Σ_v δ(v) = 2π · χ(M),
where δ(v) = 2π − Σ(interior angles at v).

We feed 100 (mesh, transformed_mesh) pairs (40 intra-mesh transforms +
60 cross-mesh comparisons), all of which preserve χ AND Σδ. Plus 3 CFs
that break the equality.
"""

SYSTEM = """你面前有离散曲率（多面体表面）的数据。

背景：在三角剖分的多面体表面 M 上，对每个顶点 v，定义角缺
   δ(v) = 2π − Σ(v 处的内角)
离散 Gauss-Bonnet 定理是
   Σ_v δ(v) = 2π · χ(M)
其中 χ = V − E + F 是 Euler 特征数。

数据中：
- 4 个预制多面体（tetrahedron, cube_triangulated, octahedron, icosahedron）
  全部是亏格 0 的闭曲面，χ = 2，Σδ/(2π) = 2。
- 在每个多面体上做了 5 次 stellar_subdivision（在面中心加点）+
  5 次 vertex_displacement（移动一个顶点）= 40 个 intra-mesh transform。
- 加上 60 个 cross-pair (mesh_a 变换前后对比 mesh_b)，共 100 case。
- 100 case 全部满足 χ_pre = χ_post = 2 且 Σδ_pre = Σδ_post = 4π。
- 3 个反事实：boundary_relaxation（不完全的 stellar subdivision，新顶点孤立成 2π 角缺）、
  operation_perturbation（删一个面但保留边）、condition_removal（无效顶点索引）。

你的目标是理解 **为什么** 局部角缺之和恒等于 2πχ（一个全局拓扑量），
并构造一个 *向上归纳*（local → global）的证明。

规则：
- 不要搜索文献，纯粹从数据推理
- 先分析数据中的 pattern，再尝试构造证明
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL"""


DATA_DESCRIPTIONS = {
    "000": """你只有每个 case 的 summary_delta：
- euler_characteristic_a / _b / _match: 两个 mesh 的 χ 是否相等
- total_curvature_a / _b: Σδ
- gauss_bonnet_ratio_a / _b: Σδ / (2π)
- n_vertices_a / _b, n_edges_a / _b, n_faces_a / _b
（以及变换前后 a 的同样字段对应的 delta）

共 100 个 case。""",

    "R00": """你有每个 case 的 summary_delta（同上），加上：

detailed_comparison（per-vertex angle defects）：
- n_vertices_pre / _post / n_faces_pre / _post / n_edges_pre / _post
- vertex_defects_changed: {v_idx: {pre, post, delta}} — 哪些顶点的角缺变了
- n_vertices_with_changed_defect: 受影响顶点数
- new_vertex_defects: {v_idx: defect} — 变换后新增顶点的角缺
- sum_of_vertex_changes: Σ(post − pre) 在受影响顶点上的总和
- sum_of_new_vertex_defects: Σ 新增顶点的角缺
- total_curvature_pre / _post / _preserved

structural_comparison（全局不变量）：
- curvature_types_pre / _post: {positive, negative, flat} 计数分布
- genus_pre / _post
- euler_pre / _post / _preserved
- total_curvature_pre / _post / _preserved
- gauss_bonnet_ratio_pre / _post
- all_global_invariants_preserved

共 100 个 case。""",

    "0T0": """你有每个 case 的 summary_delta（同上），加上：

transform_trace:
- operation_name: "stellar_subdivision" 或 "vertex_displacement"
- before_state / after_state: V, E, F, χ, Σδ, gauss_bonnet_ratio
- delta:
  · stellar_subdivision: vertices_added=1, edges_added=3, faces_added=2,
    euler_change=0, curvature_change=0
  · vertex_displacement: euler_change=0, curvature_change=0,
    local_defect_change=±x（这一个顶点的角缺变化）
- region_affected (stellar):
  · subdivided_face, new_vertex_index, affected_vertices,
    new_vertex_defect, local_defect_sum_before, local_defect_sum_after,
    local_defect_sum_preserved
- region_affected (displacement):
  · displaced_vertex, neighbor_faces, affected_vertices

reference_in_transform_region:
- 完整重复 region_affected（参照不参与变换）

共 100 个 case。""",

    "00C": """你有每个 case 的 summary_delta（同上），加上：

反事实数据 (counterfactual)：
- boundary_relaxation: 把完整 stellar subdivision 放宽为"加 1 个顶点 + 加 1 个退化面"
  （ΔV=1, ΔE=2, ΔF=1）。新顶点周围没有真实三角形 → 角缺 = 2π。
  结果：χ 可能不变，但 Σδ 增加 2π → Gauss-Bonnet 失效。
- operation_perturbation: 删一个面但保留它的三条边（用退化面把边塞回去）。
  ΔV=0, ΔE=0, ΔF=−1 → Δχ=−1。同时被删面的三个顶点失去一个内角，Σδ 也变。
  结果：Σδ 与 2πχ 双双改变，但不再相等 → Gauss-Bonnet 失效。
- condition_removal: 让一个面引用越界的顶点索引 → 无效 mesh，invariants() 报错。

每个反事实给出 original / counterfactual 的 χ, Σδ, gauss_bonnet_holds 标志，以及 delta。

问题：为什么 Σδ 必须恰好等于 2πχ？""",

    "RT0": """你有完整的几何数据（不含反事实）：
- summary_delta
- detailed_comparison（per-vertex angle defect 变化 + 全局不变量保持标志）
- structural_comparison（χ, Σδ, gauss_bonnet_ratio 是否保持）
- transform_trace（stellar / displacement 的 trace：哪个面/顶点、ΔV/ΔE/ΔF）
- reference_in_transform_region（局部受影响的顶点、邻接面）

共 100 个 case。""",

    "R0C": """你有 per-vertex 结构数据 + 反事实：
- summary_delta
- detailed_comparison
- structural_comparison
- counterfactual（incomplete subdivision / face deletion / invalid index → G-B 失效）

但你没有 transform 的局部轨迹（不知道 stellar 加了几条边/几个面，不知道
displacement 影响哪些顶点）。""",

    "0TC": """你有变换轨迹 + 反事实：
- summary_delta
- transform_trace（stellar/displacement 的 trace + region_affected）
- reference_in_transform_region
- counterfactual

但你没有 per-vertex 结构数据（不知道每个顶点的 angle defect，也不知道
χ/Σδ 是否保持）。""",

    "RTC": """你有全部数据：
- summary_delta
- detailed_comparison（per-vertex angle defect + 全局不变量保持）
- structural_comparison（χ, Σδ, gauss_bonnet_ratio）
- transform_trace（stellar/displacement trace + ΔV/ΔE/ΔF + 受影响顶点）
- reference_in_transform_region
- counterfactual（incomplete subdivision / face deletion / invalid index）

共 100 个 case + 反事实。""",
}

TASK = """
你的任务：
1. 分析数据中的 pattern
2. 尝试回答：为什么 Σ_v δ(v) = 2π · χ(M) ——
   局部的角缺之和为何恰好等于全局拓扑量 2πχ？
3. 如果可能，构造一个对任意三角剖分闭曲面成立的证明
   （提示：从"每个三角形内角和 = π"出发，对所有三角形求和，再用 V-E+F 重新分组）
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
