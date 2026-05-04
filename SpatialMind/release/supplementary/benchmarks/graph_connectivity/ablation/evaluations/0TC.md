# Condition 0TC — Transform + Counterfactual (no Relation)

## 数据分析

T 提供：每个 case 的 `transform_trace.delta.is_bridge` / `connectivity_lost` / `components_change`、`region_affected.endpoint_degrees_*`。
CF 提供：boundary_relaxation（删非桥 vs 删桥）+ operation_perturbation（删 vs 加）。

T 给出的 1-1 对应：100/100 case 满足 `is_bridge ⇔ connectivity_lost`。
CF (1) 的 explanation 给出 bridge 的图论意义："no alternative path between endpoints"。

## 论证尝试

T 单独（0T0）只能给出 *operational* equivalence：is_bridge 和 connectivity_lost 这两个 trace 标签同步出现。但 trace 不暴露"bridge"的图论定义。

CF (1) 弥补这一缺口：通过 explanation 文字定义 bridge = "u, v 之间无替代路径的边"，这是图论意义上的定义。

**定理**：G 连通，e=(u,v)∈E(G)。G−e 不连通 ⇔ e 是桥（=u, v 在 G\{e} 中不连通的边）。

**证明（结合 T 数据 + CF 概念）**：
- 由 CF：bridge ≝ u, v 在 G−e 中不可达 ⇒ G−e 必有 u, v 各自分量 ⇒ G−e 不连通。
- 反向：G−e 不连通；G 连通 ⇒ 唯一被破坏的连通是经过 e 的 u-v 通信（删边不影响其他点对的不经 e 路径）⇒ u, v 在 G−e 不连通 ⇒ e 桥。

T 的 100-case 数据给出经验验证：100/100 case 的标签一致。CF 给出概念基础。两者拼出可证明的 iff。

**额外信息**：
- T 的 `endpoint_degrees_before` 显示某些 bridge case 的端点是叶子（deg=1），删后变成 deg=0 孤立点——是 disconnect 最简单的形式。但也有非叶子 bridge case（两端度数都≥2 仍然是 bridge），所以"叶子"是 bridge 的子情况。
- CF (2) 说明删/加方向不对称：删边只能让 components 不变或 +1，加边只能让 components 不变或 -1。

## 自评

**评分：PROOF（4）**

理由：
- T 单独是 ARGUMENT（缺 bridge 的定义）；
- CF 把 bridge 从黑盒标签升级到图论概念；
- 两者结合后能写出完整双向证明；
- 100-case 数据 100/100 一致，提供 case-level empirical 支撑（虽然不是 *components 分裂* 那种结构级证据——T 没暴露分量列表，所以严格说不能在 case level 看到"分成 2 块"，只能看到"components_change=+1"）。

**与 0T0 比较**：0T0 → 0TC 是真实的 +1 跃迁（ARGUMENT → PROOF），关键贡献是 CF 提供 bridge 的概念定义。

**与 R0C 比较**：T 看不到 components 列表，所以 R0C 在 case-level 验证强度上略胜（R 的 components_post 显示分裂；T 的 components_change 只显示数量）。但两者都达到 PROOF 门槛。
