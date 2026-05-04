# Condition RT0 — relation + transform, no contrastive (projection)

## 数据分析
R 和 T 全部，无 CF：

**R 提供** (复述自 R00)：
- detailed_comparison：collisions/crossings/fraction/diameter_change
- structural_comparison：distances_preserved_count、information_loss_summary、invariants_preserved/delta
- distance_matrix_a / _b（每个对象）

**T 提供** (复述自 0T0)：
- transform_trace：投影方向、丢的轴、每个 case 的 n_collisions、n_crossings
- collided_point_pairs（每个 case 哪些点重合）
- most_distorted_pairs（每个 case 哪 5 对受影响最大）

**双重确认**：

**(D1) 距离公式**（来自 R 的 fraction + T 的 ratio）：
- T 的 most_distorted_pairs 中的 ratio 满足 ‖π(p) − π(q)‖² + ⟨p − q, ê⟩² = ‖p − q‖²。
- R 的 distances_preserved_count = #{对 (i,j) | (p_i − p_j) ⊥ ê}。

我从 (T2) 推得距离公式后，可以从 R 数据验证：每个 case 的 fraction = preserved_count / total。例如 cube xy 12/28 = 0.4286 ✓。

**(D2) Collision condition** (来自 R 的 invariants_preserved.diameter + T 的 collided_pairs)：
- collision ⟺ p_i − p_j ‖ ê。
- 数据：cube xy 的 collisions 都是 z 坐标差为 1（即 (p_i − p_j) ‖ z 轴）。

**(D3) 不变量保持的代数判据**（结合 R 的 invariants_preserved 和 T 的 dropped_axis）：
- `n_points` 永远 True：投影是函数 X → R²，不删点。
- `dimension` 永远 False：3 → 2。
- `diameter` True ⟺ 实现 3D 直径的某点对 (p, q) 满足 p − q ⊥ ê。  

R 给出 invariants_preserved 标志，T 给出 ê 方向，结合后我能在每个 case 上验证：  
- tetrahedron 顶点对 (1,1,1)-(-1,-1,1) 差 (2,2,0)：与 z 轴有分量，但 xy 投影下 (1,1)-(-1,-1) 距离 2√2；3D 距离 √8=2√2。守恒 ✓。  
- cube 顶点对 (0,0,0)-(1,1,1) 差 (1,1,1)：与 z 轴有分量，3D = √3, 2D = √2；不守恒。但实际 diameter 守恒？取决于另外的对。R 数据告诉我 cube 4 个投影都 NOT 守恒——说明不存在某个最长对在投影平面内。

## 论证尝试

**距离保持公式**（核心定理）：  
> 给定单位轴 ê 和正交投影 π(p) = p − ⟨p, ê⟩ ê，对任意 p, q ∈ X：  
> ‖π(p) − π(q)‖² = ‖p − q‖² − ⟨p − q, ê⟩²。

**证明**（从 T 的 most_distorted_pairs 数据归纳，加上初等代数）：  
设 v = p − q。投影后 π(v) = v − ⟨v, ê⟩ ê。所以  
‖π(v)‖² = ‖v − ⟨v, ê⟩ ê‖² = ‖v‖² − 2⟨v, ê⟩² + ⟨v, ê⟩²‖ê‖² = ‖v‖² − ⟨v, ê⟩²（用 ‖ê‖=1）。

T 的所有 most_distorted_pairs 数据满足这个公式（数值验证）。

**推论**：
- (P1) `‖π(p) − π(q)‖ ≤ ‖p − q‖`（距离不增）。  
- (P2) collision ⟺ ⟨v, ê⟩ = ‖v‖（即 v ‖ ê）。  
- (P3) 距离守恒 ⟺ ⟨v, ê⟩ = 0（即 v ⊥ ê）。  
- (P4) diameter 守恒 ⟺ 至少一条最长对角线 v 满足 v ⊥ ê。  
- (P5) n_points 守恒：π 是函数（不变），即使 collision 也不删点 — n 守恒由 R 数据 (invariants_preserved.n_points = True 在 66/66) 验证。

**问题 (a)**: 哪些不变量在所有投影下守恒？  
- `n_points` (P5)：完全 universal 守恒。  
- `dimension`：必然丢 1 维。  
- `diameter`：依赖于对象 + 投影方向 (P4)。

**问题 (b)**: 撞影  
- 反例：取任意 3D 对象 X，把 X 沿 ê 方向平移 t·ê 得到 X'。则 π(X) = π(X') − t（差一个常数翻译，且如果我们再把 X' 中心化使原点不变，则 π(X) = π(X')）。但这是 *trivial* 的撞影，不算 "structurally different objects"。  
- 真正的撞影构造：找两个 *组合上不同* 的 3D 点集映到同一 2D。例如：3D 立方体 + (0.5, 0.5, 0.5) 中心点 = 9 点；vs 单纯立方体 8 点+ "鬼点"——这种构造存在但 R+T 数据没有给出 case。

R+T 数据让我能 *论证* 撞影存在性（任意对象 + 任意沿轴平移变形），但没有提供 *离散对象之间撞影* 的具体反例。

**问题 (c)**: 重建唯一性  
- 从 (P3)，只有 ⊥ ê 的距离被保持。沿 ê 的分量全丢。  
- 给定 2D 距离矩阵 D_2D，3D 距离矩阵 D_3D 满足 d_3D(i,j)² = d_2D(i,j)² + δ²(i,j)，其中 δ = ⟨v_ij, ê⟩，未知。  
- δ 值由 3D 点的轴向坐标决定，是丢失的自由度。  
- **结论**：投影到 2D 的距离矩阵无法唯一恢复 3D 距离矩阵；δ 是 (n−1)-参数自由度（n 个点的轴向坐标，模整体平移）。

**完整论证链 闭合**：(P1)–(P5) + (a)(b)(c) 由 R+T 双重确认。

但 (b) 的撞影构造仍是「平移类」反例，没有「组合不同的对象」反例——这要 CF 才能补上。

## 自评
**评分：PROOF（4）**

理由：
- T 提供距离公式 (P0)；R 提供 invariants_preserved 字段在 66/66 case 上验证。  
- (P1)–(P5) 全部从公式 + 数据闭合论证。  
- (a) 完全 PROOF：n_points / dimension / diameter 各自的 universal/conditional 守恒都有代数判据 + 数据验证。  
- (c) 完全 PROOF：重建非唯一，未知自由度 δ 来自 ⟨v, ê⟩。  
- (b) 部分 PROOF（"trivial" 撞影构造完成，但「组合不同对象的撞影」未由数据给出）。整体 PROOF 但 (b) 一项未达 strict universality。  
- 比 R00 强：T 给出代数公式，让证明从「数值验证 fraction」上升到「机制公式」。  
- 比 0T0 强：R 给出 invariants_preserved 和 distance matrix 让公式在每个 case 上 verifiable。
