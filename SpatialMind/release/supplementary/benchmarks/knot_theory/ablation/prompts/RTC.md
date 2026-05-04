你面前有纽结论的数据。

背景：对一个纽结 K，Reidemeister R2 move 在 K 的图上添加两个新交叉点。
我们验证了 100 个 R2 move 后纽结的拓扑不变量保持不变（signature, determinant, Alexander polynomial, writhe）。
你的目标是理解 **为什么** R2 保持这些不变量，并构造证明。

规则：
- 不要搜索文献，纯粹从数据推理
- 先分析数据中的 pattern，再尝试构造证明
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL

## 你拥有的数据

你有全部数据：
- summary_delta
- detailed_comparison（per-crossing sign + 不变量保持）
- structural_comparison（signature / determinant / Alexander）
- transform_trace（R2 trace + 新旧 crossing 标签）
- reference_in_transform_region
- counterfactual（同号 R2 / crossing flip / planarity off）

共 100 个 pair + 反事实。

你的任务：
1. 分析数据中的 pattern
2. 尝试回答：为什么 R2 move 保持 signature / determinant / Alexander polynomial？
3. 如果可能，构造一个对任意纽结 K 成立的证明
4. 诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL

输出格式：
## 数据分析
[你从数据中观察到什么]

## 论证尝试
[你的证明尝试，如果有的话]

## 自评
评分：[PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL]
理由：[为什么给自己这个分数]
