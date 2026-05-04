你面前有离散曲率（多面体表面）的数据。

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
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL

## 你拥有的数据

你有全部数据：
- summary_delta
- detailed_comparison（per-vertex angle defect + 全局不变量保持）
- structural_comparison（χ, Σδ, gauss_bonnet_ratio）
- transform_trace（stellar/displacement trace + ΔV/ΔE/ΔF + 受影响顶点）
- reference_in_transform_region
- counterfactual（incomplete subdivision / face deletion / invalid index）

共 100 个 case + 反事实。

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
