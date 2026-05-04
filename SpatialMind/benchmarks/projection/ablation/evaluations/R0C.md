# Condition R0C — relation + counterfactual, no transform (projection)

## 数据分析

**R 提供** (同 R00)：  
- detailed_comparison：collisions/crossings/fraction/diameter_change  
- structural_comparison：distances_preserved_count、information_loss_summary、invariants_preserved/delta  
- distance_matrix_a / _b

**C 提供** (同 00C)：  
- CF-1 不投影：fraction 100%，0 collisions（critical）  
- CF-2 z 轴 ×0.5：fraction 43%（与投影相同），0 collisions（critical）  
- CF-3 dedupe：8→4 点，0 crossings（critical）

## 论证尝试

**主证明**：与 R00 相同——R 数据给出 invariants_preserved + distance matrix + collision 列表，可以在每个 case 上验证：
- (a) n_points 恒守恒，dimension 必丢，diameter 视方向；
- (c) fraction < 0.5 → 重建非唯一。

**CF 的增益**：

CF-1 让我把 R 中的 fraction = 43% 与 CF 中的 fraction = 100% 对比：  
> *如果不投影*，所有距离保持。投影后 fraction 下降的 ΔPercent 直接量化 "维度降低" 的代价。  

这把「distance distortion」从"现象"上升到"机制陈述"：  
> Information loss 由 ⟨v, ê⟩² ≥ 0 这一项贡献；不丢轴 ⟹ ê 不存在 ⟹ ⟨v, ê⟩ = 0 vacuously ⟹ 公式 collapses 到 ‖v‖² 自身。

CF-2 让我把 collision 与 distance distortion 解耦：  
> Squash 0.5 仍然是连续映射（双射 R³ → R³），所以 0 collision；但仍是 distance metric distortion（因为 ‖squash(v)‖ ≠ ‖v‖）。  
> 投影是把 ⟨v, ê⟩ → 0，squash 是把 ⟨v, ê⟩ → 0.5⟨v, ê⟩；前者是 collision-causing limit，后者只是 metric scale。  

CF-3 让我把 collision 的「数据保留」价值提取：  
> 投影保留 8 点 8 crossings = 「投影前是 8 点，沿 z 轴对齐」的数据载体。  
> Dedupe 后 4 点 = 完全丢失 "z 方向重数" 信息。  
> 这意味着 collision 数据是 "投影非单射的可观测痕迹"，对重建 3D 结构 *有部分价值*。

**问题 (b) 撞影**：

CF-3 数据 critical 这条事实告诉我「dedupe 改变了结构」——这意味着 *保留 collision 信息的 2D 投影* 含有比 *dedupe 后的 2D 形状* 更多 3D 信息。换句话说，"两个不同对象映到同一 2D 点集" 在 *记 collision* 的视角下要求更强的等同条件。

但即便如此，**仍然存在 *组合不同对象* 的撞影**：取 3D 对象 A，把 A 沿 ê 平移得到 A'，然后在 A' 的某些点上加 ê 方向的扰动（对 dedupe 不影响）。这构造了 distance matrix 不同但 2D 投影 + collision 模式相同的 A 和 A''。但这种构造没在 R+C 数据里。

## 自评
**评分：PROOF（4）**

理由：
- 主证明在 R 上闭合（与 R00 同等）。  
- CF-1 给出「维度降低 ⟹ 距离信息丢」的因果机制——不只是数据正相关，而是反事实独立性证据。  
- CF-2 让 collision 和 distance distortion 解耦——这是有用的概念区分。  
- CF-3 让 "collision 是结构信号" 的论证有了反事实基础。  
- 与 R00 比，CF 把「一些不变量条件成立 / 不成立」上升到「这些条件 *因为* 维度降低成立 / 不成立」。  
- 与 RT0 比，缺 T 让我没有距离公式 (P0) 作为代数 building block——只能用 R 的数据 *拟合* 距离公式，但无法直接 *induce* 它。  
- 整体到 PROOF 是因为 R + CF 的组合让 (a)(c) 都可以在数据 + 反事实双重视角下闭合。
