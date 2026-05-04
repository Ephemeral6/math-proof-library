你面前有格点多边形 (lattice polygon) 的数据。

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
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL

## 你拥有的数据

你有完整的几何数据（不含反事实）：
- summary_delta
- detailed_comparison（边数据、面积/B/I 变化）
- structural_comparison（pick_holds、area_from_pick vs area_from_shoelace、is_lattice、is_simple）
- transform_trace（变换的轨迹：操作名、before/after state、delta）
- reference_in_transform_region

共 87 个 case。

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
