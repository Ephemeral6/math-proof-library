# Condition R0C — Relation + Counterfactual (no Transform)

## 数据分析

R 提供 100 个 case 的结构数据：`deleted_edge_was_bridge`, `n_bridges_pre/post`, `components_pre/post`, `articulation_points_pre/post`。
CF 提供 2 个 critical case：boundary_relaxation（删非桥 vs 删桥）+ operation_perturbation（删 vs 加）。

R 让我直接验证 100/100 的 1-1 对应（同 R00）：
- 17 case `deleted_edge_was_bridge=true` ⇔ 17 case `connectivity_lost=true` ⇔ `components_post` 分成 2 块。
- 83 case 反之。

CF 提供两条独立信息：
1. boundary CF 的 explanation 文字给出 bridge 的图论意义：「no alternative path between endpoints」。
2. operation CF 揭示删边/加边的**方向不对称**——删边只能不变或增加 components，加边只能不变或减少。

## 论证尝试

**定理（与 R00 同）**：G 连通，e ∈ E(G)。G−e 不连通 ⇔ e 是桥。

**证明（结构版）**：
- (⇐) e 桥 ⇒ 唯一 u-v 路径就是 e；删 e 切断；G−e 中 u, v 不可达。
- (⇒) G−e 不连通；G 连通；删边不删点 ⇒ 存在的不连通对必涉及 e 的两端 ⇒ e 桥。

**100-case 验证**：R 给的 `components_post` 在每个 disconnect case 恰好分两块，u, v 各属一块（双向都验证）。

**CF 提供的额外深度**：
- CF (1) 把"桥"从 R 的标签升级成图论概念："无替代路径的边"。这让证明的逻辑链更紧凑——不再依赖"is_bridge"作为黑盒标签，而是直接用"u, v 之间的路径数"作为论据。
- CF (2) 暗示主定理的*单向版本对加边不成立*：加边可以*减少* components 但不能保证。这区分了"加边 vs 删边"作为对偶操作的不对称性，与主定理"删 ⇒ 增"互补。

**强化结论**：bridge ⇔ disconnect 这个等价是关于"边的存在为连通提供必要保障"的命题。CF (1) 给出"必要"方向（删则断），R 的 100-case 给出"充分"方向（不是桥则不断）。两者拼出完整 iff。CF (2) 进一步说明这种"保障"不能通过加边复制——bridge 是删边特有的概念，无加边对偶。

## 自评

**评分：PROOF（4）**

理由：
- 定理与 R00 同；证明结构同；100-case 验证同；
- CF 的额外贡献是把"bridge"从标签升级到结构概念，让证明更"图论化"，但不增加新论证步骤；
- CF (2) 给出方向不对称的副定理（删 vs 加的非对偶性），是补充结果，不是主定理的必要部分；
- 因此 R0C 与 R00 同分（PROOF），CF 的边际贡献是*概念化*而非*论证强度*。

**与 knot_theory R0C 的对比**：在 knot_theory 中 R0C 是 R + CF 一起从 PATTERN 跨到 ARGUMENT 的关键组合（R × C 超加性 +1）。在 graph_connectivity 中 R 单独已经够 PROOF，CF 的边际贡献变小——这是因为 graph 数据的结构信号（`components_pre/post`）比 knot 数据的代数信号（signature/det/Alex）更接近"答案"。
