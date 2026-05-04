你面前有图论的数据。

背景：给定一个连通图 G 和一个边 e。删除 e 之后，图可能仍然连通，也可能分裂成两个连通分量。
我们生成了 100 个 (G, e) pair 并记录了删边的效果。
你的目标是理解 **什么决定了删一条边会破坏连通性**，并构造一个判定规则的证明。

规则：
- 不要搜索文献，纯粹从数据推理
- 先分析数据中的 pattern（哪些 case 连通性被破坏，哪些没有），再尝试构造证明
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL

## 你拥有的数据

你有变换轨迹 + 反事实：
- summary_delta
- transform_trace（删了哪条边、is_bridge、connectivity_lost、端点度数）
- reference_in_transform_region
- counterfactual

但你没有结构数据（不知道每个图的桥边总数、关节点、分量列表）。

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
