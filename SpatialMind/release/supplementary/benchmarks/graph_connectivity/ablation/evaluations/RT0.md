# Condition RT0 — Relation + Transform (no Counterfactual)

## 数据分析

R 提供：每个 case 的 `detailed_comparison.deleted_edge_was_bridge`、`n_bridges_pre/post`，以及 `structural_comparison.components_pre/post`、`articulation_points_pre/post`。
T 提供：`transform_trace.delta.is_bridge` / `connectivity_lost` / `components_change`、`endpoint_degrees_*`。

R 和 T 给出的 `is_bridge` 标签是**同一个**信号——逐 case 比较两者完全一致。100/100 case 满足：
- R 的 `deleted_edge_was_bridge = T 的 is_bridge`
- 都 ⇔ `connectivity_lost`
- 都 ⇔ `components_change == +1`

R 提供的额外信息（T 没有）：
- 每个图的总桥边数 `n_bridges_pre`（让我看到 17 个 connectivity-lost case 来自 13 个不同的图，且每个图的桥数与 trial 中删到的桥次数一致）。
- `components_post` 的具体分裂（u 在一边、v 在另一边）。
- `articulation_points_*`：观察到一个有趣的副作用——删非桥后关节点*可能增加*（如 `R00_n8-t0` 中 [7] → [1, 2, 7]），这是因为破坏了一个环让原本的内部点变成关节点。

T 提供的额外信息（R 没有）：
- 端点的度数变化（删边后 u, v 的度数都 −1）。
- "操作前后状态"的 trace 视角，强调这是单一的局部操作。

## 论证尝试

**定理**：设 G 连通，e=(u,v)∈E(G)。则 G−e 不连通当且仅当 e 是 G 的桥。

**证明**：
- (⇐) e 是桥 ⇔ G 中除 e 外没有 u→v 路径。删 e 后，原来通过 e 连接的一切 u-v 通信失效；G−e 中 u 和 v 的连通分量分别为 G−e 中各自可达点的集合，且彼此不相交。
- (⇒) G−e 不连通。G 删一条边只可能影响这条边端点之间的连通性（不删点；其他点对的路径若不过 e 仍然存在；过 e 的 u-v 路径在 G−e 中由 e 的不存在而需要绕路）。所以 G−e 不连通 ⇒ u, v 在 G−e 中不连通 ⇒ e 是桥。

**100-case 数据验证**：
- R 的 `components_post` 在每个 connectivity_lost case 上恰好分成 2 块，u, v 各自一边；非 connectivity_lost case 中 components 不变。这是 (⇐) 的 case-by-case 验证。
- T 的 `is_bridge=true ⇔ connectivity_lost=true` 在 100/100 case 上成立。这是双向同时验证。
- R 的 `n_bridges_pre` 与 case 中 bridge 删除次数一致（每图删的 bridges 数 ≤ `n_bridges_pre`）。

**额外结构观察**：
- `articulation_points` 在删非桥后可以*增加*——这反映另一个事实："删非桥不影响连通性，但可以让原本的环边变成桥"。这是 *iff bridge ⇔ disconnect* 之外的补充事实，与主定理无冲突。

## 自评

**评分：PROOF（4）**

理由：
- 定理双向陈述清晰；
- 双向证明仅用"路径=连通的定义"和"删边只影响端点之间的连通"两个标准事实；
- 数据 100/100 一致，且 components 的分裂结构在每个 connectivity-lost case 中可见——这是 *case-level* 验证；
- R 和 T 信号高度冗余（同一个 is_bridge 标签），但 R 提供 components 视角让 (⇐) 的"u, v 各自一边"在数据中可视化，这是 PROOF 级别的支撑；
- 与 R00 相比，T 的额外贡献（端点度数）对主证明无关键作用，但确认了"局部操作"框架。

**与 R00 比较**：RT0 ≈ R00（都是 PROOF）。T 在此处与 R 高度冗余，与 knot_theory 的发现一致。
