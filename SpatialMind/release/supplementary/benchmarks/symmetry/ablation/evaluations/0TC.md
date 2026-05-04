# Condition 0TC — transform + counterfactual, no relation (symmetry_combinatorics)

## 数据分析

**T 提供**（同 0T0）：  
- 每个 g 的 permutation 形式（[shift k]）和阶；  
- 每个 case 的 moved/fixed vertices；  
- 但**没有** `stabilizer_size`、`n_connecting`、`fixed_point_counts`、`burnside_count` 等结构数据。

**C 提供**（同 00C）：  
- CF-1 Z_6 → D_6：130 → 92 轨道；  
- CF-2 Z_6 → {e}：130 → 729 轨道；  
- CF-3 swap(0,1)：破坏轨道等价。

## 论证尝试

T 单独不知道轨道总数（CF 透露了 130，但 T 自己看不到）。我能从 T 推：

**(T1') Cycle structure 决定 Fix(g) 的代数形式**：  
g 把 6 顶点分成 cycle_count(g) 个 cycle，a 被 g 固定 ⟺ 每 cycle 上同色 ⟹ |Fix(g)| = 3^(cycle_count)。

**(T2') Stab(a) ≤ G 由 a 在 cycle 上的颜色一致性决定**：  
g ∈ Stab(a) ⟺ a 在 g 的每个 cycle 上常值。这是个**结构性观察**，没有具体的 |Stab| 数据。

**CF 提供的额外信号**：  
- CF-2 给出「{e} → 729 轨道」: 这等价于「无群作用时每个着色独占一个轨道」，告诉我 |X| = 3^6 = 729。  
- CF-1 给出「D_6 → 92 轨道」：让我可以**对照** Z_6 下的 #orbits 应有不同。  
- CF-3 给出「非群置换破坏等价」：印证 G 闭包必要。

但 CF 没有给我 Z_6 下的 #orbits — 那个在 CF 里只作为 `total_orbits=130` 出现在 original_condition 字段里。如果我把这个当作给定的常数，那么：

**论证构造**：  
- 从 (T1') 我推得 |Fix(id)|=729, |Fix(阶6)|=3, |Fix(阶3)|=9, |Fix(阶2)|=27。  
- Σ|Fix(g)| = 729 + 2·3 + 2·9 + 27 = 780。  
- 780/6 = 130，这正好等于 CF 里给出的 `total_orbits=130`。  
- **数值上一致**，暗示 (1/|G|)Σ|Fix(g)| = #orbits。

但「数值一致」 ≠ 「证明 Burnside」。要证明 Burnside 我需要：
1. orbit-stabilizer 定理：|Stab|·|Orbit|=|G|。  
2. 双重计数 Σ|Fix(g)| = Σ|Stab(a)|。  
3. 把 Σ|Stab(a)| 按 orbit 分组。

**(1) 我没有 |Stab| 数据**（R 缺位），只能从 (T2') 的结构观察推：a 的 stabilizer = 「保持 a 在 cycle 上常值的 g 集合」。这是定性陈述。  
**(2) 双重计数原则我作为外部知识有**，但数据里没有 Σ|Stab(a)| 的值，无法验证。  
**(3) 同上**。

**结论**：T 给出 Fix(g) 的代数公式（来自 cycle 结构）；CF 让我看到「群结构必要 + Z_6 下 130 是关键」；但缺 R 让我看不到 stabilizer 和双重计数所需的 Σ|Stab(a)|。我只能 **数值验证** Burnside (780/6 = 130 ≅ CF 给的 total_orbits)，不能给出 **结构证明**。

## 自评
**评分：ARGUMENT（3）**

理由：  
- T 提供 cycle structure → |Fix(g)| 的代数公式（这是 RT0 比 R00 多的部分）。  
- CF 把「Z_6 下 130」作为外部常数注入，我可以做数值一致性检验。  
- 但缺 R 意味着没有 |Stab| 数据，不能跑双重计数论证。Burnside 的「证明」退化为「Σ|Fix(g)|/|G| 的值与 CF 给的轨道数相等」这种巧合验证。  
- 比 0T0 强：CF 让我把数值结果与外部常数对齐；比 RT0 弱：缺乏构造性 orbit-stabilizer 证据。
