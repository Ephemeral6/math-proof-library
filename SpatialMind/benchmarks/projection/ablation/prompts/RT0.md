你面前有三维点集（多面体顶点）的二维投影数据。

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
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL

## 你拥有的数据

你有完整的几何数据（不含反事实）：
- summary_delta
- detailed_comparison（collisions, crossings, fraction_preserved, diameter_change）
- structural_comparison（distance preserved 比例、information_loss_summary、invariants_preserved/delta）
- transform_trace（投影方向、丢的轴、before/after state、delta、collided/crossing pairs）
- reference_in_transform_region

共 66 个 case。

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
