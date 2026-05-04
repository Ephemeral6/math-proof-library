# Condition RTC — All primitives (graph_connectivity)

## 数据分析

完整数据：
- R: `deleted_edge_was_bridge`, `n_bridges_pre/post`, `components_pre/post`, `articulation_points_pre/post`。
- T: `delta.is_bridge` / `connectivity_lost` / `components_change`、`endpoint_degrees_*`。
- C: boundary_relaxation + operation_perturbation。

100 case 满足三重等价：
> R 的 `deleted_edge_was_bridge` ⇔ T 的 `is_bridge` ⇔ R 的 `components_post` 分成 2 块 ⇔ T 的 `components_change=+1` ⇔ R 和 T 的 `connectivity_lost`。

R 和 T 给出的 bridge 标签是同一信号（操作上等价），但 R 给的是结构视角（components 列表），T 给的是过程视角（before/after state）。CF 给出图论定义和方向不对称。

## 论证尝试

**定理**：G 连通图，e=(u,v)∈E(G)。G−e 不连通 ⇔ e 是 G 的桥。

**桥的等价定义**（由 CF + R 综合）：
- (def-1) e 删除后 components 数 +1。
- (def-2) e 删除后 u 和 v 不在同一连通分量。
- (def-3) G\{e} 中没有 u→v 路径（=唯一 u-v 路径就是 e）。

由 R 的 `components_post`（看到分量列表）和 T 的 `components_change`（看到数量变化），def-1 和 def-2 在数据中等价；def-3 由 CF (1) 的 explanation 给出。

**证明（双向）**：
- (⇐) e 桥（def-3）：G\{e} 中无 u-v 路径。删 e 后 u, v 不可达 ⇒ G−e 中 u, v 在不同分量 ⇒ G−e 不连通。
- (⇒) G−e 不连通：G 连通 ⇒ G 中有 u-v 路径。删 e 不影响其他点对不经 e 的路径，也不删任何点。故"G−e 不连通"必出现在原本经 e 的某条路径被切断，且无替代——即 e 是 u-v 唯一路径，e 是桥（def-3）。

**100-case 经验验证**（这是 RTC 比 R00/0TC 的优势）：
- R 的 `components_post` 在 17 个 disconnect case 中肉眼可见分成 (C_u, C_v) 两块（u, v 各属其一）。
- T 的 `is_bridge=true` 与 R 的 `deleted_edge_was_bridge=true` 在 100/100 case 上同步。
- 跨 graph_idx：每个图的 `n_bridges_pre`（R 给出）= 该图中所有 case 内 `is_bridge=true` 的最大可能数（trial 是无放回采样，bridge 在 5 个 trial 中可能被采到也可能不被采到）。一致性检验通过。

**关于操作非对称（CF 2）**：
- 删边：components 单调不减（保持或 +1）；
- 加边：components 单调不增（保持或 −1）。
- bridge 是删边场景下"严格增加 components"的判据；其加边对偶是"merging edge"（连接两个不同分量的边），但加边对偶不对称——加边不能创造新的分量，所以 bridge 概念在加边场景下退化为"是否合并"。

## 自评

**评分：PROOF（4）**

理由：
- 定理双向证明完整、依赖标准事实（路径=连通定义、删边不删点）；
- 双向 case-level 验证（R 提供 components 分裂结构，T 提供变化数）；
- CF 提供 bridge 的图论定义（不依赖 trace 标签）；
- 100/100 一致性确认。

**RTC vs R00 / RT0 / R0C / 0TC**：四者都是 PROOF，RTC 的额外信息（同时 R+T+C）是冗余的——R 单独足够给出 PROOF。这是 graph_connectivity 与 knot_theory 的关键差异：在 knot_theory 中需要 R+C 才能跨过 ARGUMENT 门槛，PROOF 难以达到（因为 signature 通过 Seifert 矩阵机制独立于 sign pair）；在 graph_connectivity 中 R 单独已经能 PROOF。

**结论**：graph_connectivity 的"phase transition criticality"问题在结构层（R）已经完全编码，T 和 C 是冗余确认。这反映被研究的数学事实本身的复杂度：bridge ⇔ disconnect 是一个**初等等价**，不像 R2 invariance 涉及多个独立代数不变量。
