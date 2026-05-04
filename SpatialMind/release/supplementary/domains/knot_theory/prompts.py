"""LLM prompt templates for the knot-theory domain.

Mirrors surface_topology's prompt structure but uses R2 invariance as the
target theorem.
"""

SYSTEM = """你面前有纽结论的数据。

背景：对一个纽结 K，Reidemeister R2 move 在 K 的图上添加两个新交叉点。
我们验证了 100 个 R2 move 后纽结的拓扑不变量保持不变（signature, determinant, Alexander polynomial, writhe）。
你的目标是理解 **为什么** R2 保持这些不变量，并构造证明。

规则：
- 不要搜索文献，纯粹从数据推理
- 先分析数据中的 pattern，再尝试构造证明
- 最后诚实自评：PROOF / ARGUMENT / PATTERN / WRONG_PATTERN / NO_SIGNAL"""

DATA_DESCRIPTIONS = {
    "000": """你只有每个 (K, K') pair 的 summary_delta：
- crossing_count_a: 交叉数变化（R2 应该 +2）
- writhe_a / writhe_b / writhe_delta: writhe 变化
- linking_number: 链接数（单分量纽结 = 0）

共 100 个 R2 pair（10 个纽结 × 10 次 R2）。""",

    "R00": """你有每个 pair 的 summary_delta（同上），加上：

detailed_comparison（per-crossing data）：
- crossings_a_before / _after: 交叉数
- added_crossing_count: R2 添加的交叉数
- added_crossing_signs: 新增交叉点的 sign 列表
- added_crossing_signs_pair: 排序后的 sign pair（如 (-1, +1)）
- writhe_change_a: writhe 变化
- signs_count_pos_pre / signs_count_neg_pre: K 的正负 sign 计数
- signs_count_pos_post / signs_count_neg_post: K' 的正负 sign 计数

structural_comparison（拓扑不变量）：
- signature_pre / signature_post / signature_preserved
- determinant_pre / determinant_post / determinant_preserved
- alexander_pre_normalized / alexander_post_normalized / alexander_preserved
- writhe_pre / writhe_post / writhe_preserved
- all_topological_invariants_preserved

共 100 个 pair。""",

    "0T0": """你有每个 pair 的 summary_delta（同上），加上：

transform_trace:
- operation_name: "R2"
- before_state / after_state: PD code、writhe、signs
- delta: crossing_count_delta（= +2）, writhe_delta（= 0）
- region_affected.added_crossing_labels: 新增 crossing 的标签（如 ['new1','new2']）
- region_affected.added_crossing_signs: 新增 sign 列表
- region_affected.added_crossing_signs_pair: 排序后的 pair
- region_affected.persistent_crossing_count: 保留下来的原 crossing 数
- region_affected.persistent_crossing_labels: 原 crossing 的标签

reference_in_transform_region:
- persistent_crossing_count / labels: K 的哪些原 crossing 在 K' 中保留
- added_crossing_labels: K' 中新增的 crossing 标签

共 100 个 pair。""",

    "00C": """你有每个 pair 的 summary_delta（同上），加上：

反事实数据 (counterfactual)：
- boundary_relaxation: 把合法 R2 的 sign 约束 (+1,-1) 放宽到同号 → 不变量被破坏
- operation_perturbation: 翻转一个原 crossing 的 sign → 不变量被破坏
- condition_removal: 去掉 planarity 约束 → diagram 失效或不变量改变

每个反事实给出 original / counterfactual 的 signature, determinant, Alexander，以及 delta。

问题：为什么必须是 sign pair (+1,-1)？""",

    "RT0": """你有完整的几何数据（不含反事实）：
- summary_delta
- detailed_comparison（per-crossing sign + 不变量保持标志）
- structural_comparison（signature / determinant / Alexander 是否保持）
- transform_trace（R2 的轨迹：哪两个 crossing 添加、sign pair）
- reference_in_transform_region（保留的原 crossing 标签）

共 100 个 pair。""",

    "R0C": """你有 per-crossing 结构数据 + 反事实：
- summary_delta
- detailed_comparison
- structural_comparison
- counterfactual（同号 R2 / crossing flip / planarity off → 不变量破坏）

但你没有 transform 的局部轨迹（不知道哪两个 crossing 是 R2 添加的）。""",

    "0TC": """你有变换轨迹 + 反事实：
- summary_delta
- transform_trace（R2 添加哪些 crossing，sign pair）
- reference_in_transform_region
- counterfactual

但你没有 per-crossing 结构数据（不知道 K 和 K' 的全部 sign 列表，也不知道 signature/determinant/Alexander 是否保持）。""",

    "RTC": """你有全部数据：
- summary_delta
- detailed_comparison（per-crossing sign + 不变量保持）
- structural_comparison（signature / determinant / Alexander）
- transform_trace（R2 trace + 新旧 crossing 标签）
- reference_in_transform_region
- counterfactual（同号 R2 / crossing flip / planarity off）

共 100 个 pair + 反事实。""",
}

TASK = """
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
"""


def build_prompt(condition: str) -> str:
    return f"{SYSTEM}\n\n## 你拥有的数据\n\n{DATA_DESCRIPTIONS[condition]}\n{TASK}"
