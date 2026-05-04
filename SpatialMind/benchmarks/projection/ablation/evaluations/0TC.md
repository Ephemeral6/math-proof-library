# Condition 0TC — transform + counterfactual, no relation (projection)

## 数据分析

**T 提供** (同 0T0)：
- transform_trace：投影方向、丢的轴、collisions/crossings/fraction
- collided_point_pairs（每个 case）
- most_distorted_pairs（每个 case 的 5 对，含 ratio）

**C 提供** (同 00C)：
- CF-1 不投影：fraction 100%
- CF-2 z 轴 ×0.5：collisions 0
- CF-3 dedupe：8→4 点

## 论证尝试

**T 给出代数公式**（同 0T0）：  
‖π(v)‖² = ‖v‖² − ⟨v, ê⟩²

从 most_distorted_pairs 数据归纳并代数验证。

**CF 的额外信号**：

CF-1（不投影）确认：把 ⟨v, ê⟩² 项加回去 ⟹ ‖π‖² 还原为 ‖v‖²。**反事实地验证公式的依赖性**。

CF-2（squash）：  
> 把投影 ⟨v, ê⟩ → 0 的 limiting 操作改为 ⟨v, ê⟩ → 0.5⟨v, ê⟩。  
> 距离公式从 ‖v‖² − ⟨v, ê⟩² 改为 ‖v_⊥‖² + (0.5⟨v, ê⟩)² = ‖v‖² − 0.75⟨v, ê⟩²。  
> 但 CF-2 的 fraction = 43%（与投影相同）：这意味着 CF-2 的数据并不区分 squash 和投影在 *距离守恒数*（因为 "守恒" 阈值是 ±1%，0.75 系数仍让大多数距离脱离守恒区）。  
> Collision 0：因为 ⟨v, 0.5ê⟩ ≠ 0 即使 v ∥ ê，所以两点不重合。

CF-3（dedupe）：让我看到「保留 collision 是有结构信息的」——和 0T0 中讨论一样。

**问题 (a)、(b)、(c)** 的论证：与 0T0 + 一些 CF 加固。

但缺 R 仍然意味着：
- 没有 invariants_preserved 字段。我能从 before/after_state 看到 dimension 减 1, n_points 不变；但 diameter 守恒条件需要逐 case 推算（diameter_change 在 trace 中给出，但不直接给「diameter_preserved」标志）。
- 没有 distance matrix 作为完整 view。只能看 5 对 most_distorted。
- 没有 distances_preserved_count 在每个 case 上。

## 自评
**评分：ARGUMENT（3）**

理由：
- T 给出距离公式（核心），CF 给出反事实因果验证（消除 ⟨v, ê⟩² 项的因果效应）。  
- 但缺 R 让我没法在每个 case 上 verify invariants_preserved 字段，整体 case-by-case 验证退化为「从公式 + 部分数据外推」。  
- 比 0T0 多了 CF 的因果信号；比 RT0 少了 invariants 字段。  
- (a)(c) 论证骨架在，但 strict per-case verification 缺失，所以 ARGUMENT 而非 PROOF。
