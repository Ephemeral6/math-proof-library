# Condition RTC — full data (projection)

## 数据分析
全部三种原语：

**R**: detailed/structural — fraction、distance matrix、invariants_preserved 在 66/66 case 上。  
**T**: 投影方向、collided_pairs、most_distorted_pairs、ratio。  
**C**: 3 critical CFs — 不投影 / squash / dedupe。

**双重和三重确认**：

**(D1) 距离公式三重确认**：
- T 的 most_distorted ratios 满足 ‖π(v)‖² + ⟨v, ê⟩² = ‖v‖² ✓。
- R 的 fraction = preserved_count / total = #{v ⊥ ê 对} / C(n,2)，与公式一致 ✓。
- CF-1 (identity)：⟨v, 0⟩² = 0，公式 collapses 到 ‖v‖² 自身，fraction = 100% ✓。

**(D2) 不变量守恒判据三重确认**：
- R 的 invariants_preserved 字段直接告诉我每个 case 的 n_points/dimension/diameter 是否守恒。
- T 的 dropped_axis 让我能从 invariants 字段反推「diameter 守恒 ⟺ 最长对角线 ⊥ ê」的代数判据。
- CF-1 显示如果 ê 不存在（identity），所有 invariants 都守恒 — 反事实独立性。

**(D3) Collision 与维度的因果关系**：
- T 的 collided_point_pairs 在 cube xy 上恰是 z 坐标差为 1 的点对。
- R 的 information_loss_summary.collisions 数与 T 一致。
- CF-2 (squash) 把 ⟨v, ê⟩ 设为 0.5⟨v, ê⟩，collision 消失：从 0.5 ≠ 0 看出 collision 是 limit 过程的结果。

## 论证尝试

**完整证明链（综合 RT0 + R0C + 0TC）**：

**步骤 1（距离公式）**：  
‖π(p) − π(q)‖² = ‖p − q‖² − ⟨p − q, ê⟩²。  
- 推导：T 的代数 (T2) + 数据归纳。  
- 验证：R 的 distance matrix 与公式比对 (D1)。  
- 因果：CF-1 反事实地隔离 ⟨v, ê⟩² 项 (D3)。

**步骤 2（不变量守恒判据）**：  
- n_points: 完全守恒（投影是函数）。  
- dimension: 必丢 1。  
- diameter: 守恒 ⟺ 实现 3D 直径的某点对 v 满足 ⟨v, ê⟩ = 0。

R 的 invariants_preserved 标志让 (P5) 在 66/66 case 验证。T 的 dropped_axis 让代数判据 *machinery* 化。CF-1 反事实加固 "ê 是因果原因"。

**步骤 3（撞影存在性）**：  
- 平移类反例：A → A + tê 在 ê 方向是 same projection。  
- 组合不同对象的撞影：取 X ∈ R³，把 X 沿 ê 方向施加 *任意* 双射变形 f(z) → z'，得到 X'，则 π(X) = π(X') 在 (x, y) 坐标下相同（点序意义下）。如果允许 collision 消除（dedupe），则 X 的非平凡 z-fiber 可以被多个 X' 复刻。  
- CF-3 (dedupe) 验证："collision 携带的 z-fiber 信息" 被 dedupe 抹掉，所以 dedupe 后撞影更普遍。

**步骤 4（重建非唯一性）**：  
- 公式逆命题：d_3D² = d_2D² + δ²，其中 δ = ⟨v, ê⟩，未知。  
- δ 是 (n−1)-参数自由度（或更多，取决于 z 坐标共动结构）。  
- R 的 fraction < 0.5 在 66/66 case 上 → 至少一半距离对 δ ≠ 0 → 不可重建。  
- T 的 most_distorted_pairs 的 ratio < 1 给出每个未知 δ 的 magnitude bound。  
- CF-1 反事实加固：如果保留 ê 方向（不投影），重建 trivial。

**步骤 5（n_points 守恒证明）**：  
- R: invariants_preserved.n_points = True 在 66/66。  
- T: trace 中 before_state.n_points = after_state.n_points 在 66/66。  
- 数学事实：投影是函数 R³ → R² —— 一个点必映到一个点。即使两点 collide 也都 *存在* 在 image。  
- CF-3 反向证据：dedupe 后 n_points 减少，违反 invariant — CF-3 critical 印证保留点数是默认行为。

## 自评
**评分：PROOF（4）**

理由：
- 步骤 1–5 全部闭合，每一步都有 R + T + C 三重证据。  
- 与 RT0 / R0C / 0TC 比，RTC 没把分数推到「PROOF+」（没有这一档），主要价值是：  
  (a) 三重确认（公式从代数 + 数据 + 反事实三个角度验证）；  
  (b) 撞影构造的反事实基础（CF-3 提供 dedupe 视角）；  
  (c) 重建非唯一性的 magnitude bound（来自 T 的 ratios）。  
- 跨过 PROOF 门槛已经在 RT0（R+T 给出公式 + 验证）或 R0C（R+CF 给出数值 + 因果）发生；RTC 是加固。
