# Condition R0C — relation + counterfactual, no transform (symmetry_combinatorics)

## 数据分析

**R 提供**（同 R00）：  
- `n_connecting = |Stab|` 在 same-orbit 上 100/100 一致；  
- `(|Stab|, |Orbit|)` 乘积恒为 6；  
- `fixed_point_counts = {0:729, 1:3, 2:9, 3:27, 4:9, 5:3}`；  
- `burnside_count = total_orbits = 130`。

**C 提供** 三个反事实（同 00C）：  
- CF-1 Z_6 → D_6: `total_orbits 130 → 92`，相同 pair `same_orbit` 不变。  
- CF-2 Z_6 → {e}: `total_orbits 130 → 729`，`same_orbit` 退化为 ==。critical。  
- CF-3 非群置换 swap(0,1): same_orbit(a, swap·a) = False。critical。

## 论证尝试

**主证明** 与 R00 相同——R 单独足够给出 Burnside 的完整论证：

1. orbit-stabilizer 来自 `n_connecting = |Stab|`（陪集分解）。  
2. Burnside 数值验证：Σ|Fix(g)|/|G| = 130 = #orbits。  
3. 双重计数：Σ_g |Fix(g)| = Σ_a |Stab(a)| = Σ_{orbit O} |O|·(|G|/|O|) = |G|·#orbits。

**CF 的增益**——CF 给出几个 R 单独无法回答的问题的答案：

(C1') Q：「群结构是必要的吗？」  
A：CF-2 (Z_6 → {e}) 直接展示——去掉群，等价关系退化为相等。**这是「群是必要前提」的明确证据**。

(C2') Q：「Burnside 公式 (1/|G|)Σ|Fix(g)| 中的 |G| 是关键的吗？」  
A：CF-1 (Z_6 → D_6) 给出 |G|=12 时 #orbits=92。验证：(1/12)·X = 92，其中 X 是 D_6 的 Σ|Fix(g)|。这暗示 Burnside 在不同群下都成立——不是 Z_6 的特殊巧合。  
（精确点说：CF-1 不直接告诉我 D_6 的 Fix 数据，但 92 这个数字是「同一个 Burnside 公式在更大群下的实例」，一致性验证。）

(C3') Q：「为什么必须是群元素而非任意置换？」  
A：CF-3 (swap(0,1) ∉ Z_6) 直接展示——非群置换破坏 orbit equivalence。**也就是说，证明里「g·a 与 a 同轨道」依赖于 g 是群元素**。

**CF 没补的洞**：  
- T 缺位意味着我看不到 g 的 cycle 结构。在 R00 + T 时我能从 cycle 数推 |Fix(g)| = 3^(6/order)；这里我只能从 R 的数值验证 |Fix(g)|，不能给出代数公式。  
- 例如 CF-1 把 G 换成 D_6，但 R 里的 fixed_point_counts 仍是 Z_6 的 6 个 g，**没有** D_6 的 12 个 g 的 Fix 数据。所以 CF-1 给出 92 这个数字，但我不能用 R 数据**推**出 92。

## 自评
**评分：PROOF（4）**

理由：  
- 主证明（双重计数 → Burnside）在 R 上闭合，与 R00 同等强度。  
- CF 在「是否、必要性、稳健性」三个维度做反事实校验，把证明从「在 Z_6 上数值正确」上升到「这套机制是关键且不能去掉」。  
- 缺 T 仍意味着无法用 cycle structure 推 |Fix(g)| 的代数表达——但这是「机制的细节」，不是 Burnside 本身。  
- 与 R00 比，多了 CF 的 robustness 信号；与 RT0 比，少了 cycle structure 的 algebraic 推导。两条路都到 PROOF，但走的路径不同。
