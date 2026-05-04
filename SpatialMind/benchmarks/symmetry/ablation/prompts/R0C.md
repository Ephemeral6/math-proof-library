你面前有一组 6 顶点正六边形 3 着色的对称性数据。

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
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL

## 你拥有的数据

你有结构数据 + 反事实：
- summary_delta
- detailed_comparison
- structural_comparison（stabilizer、orbit-stabilizer、fixed_point_counts、burnside_count）
- counterfactual（Z_6→D_6、Z_6→{e}、非群置换）

但你没有 transform 的局部轨迹（不知道每个 g 的具体置换、moved 顶点）。

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
