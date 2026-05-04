# Condition RTC — full data (symmetry_combinatorics)

## 数据分析
全部三种原语：

**R**: `n_connecting = |Stab|` 100/100；`(|Stab|, |Orbit|)` 乘积恒为 6；`fixed_point_counts = {0:729, 1,5:3, 2,4:9, 3:27}`；`burnside_count = total_orbits = 130`。

**T**: g 的 cycle 结构 (旋转 k 步 → gcd(k,6) 个 cycle)；`is_fixed_point` 与 `vertices_changed` 严格匹配 cycle 模式。

**C**: 3 个 critical CFs：  
- Z_6 → D_6: 轨道数 130 → 92（不critical 但量化压缩）；  
- Z_6 → {e}: 轨道数 130 → 729（critical: 群必要）；  
- swap(0,1) ∉ Z_6: 破坏 orbit equivalence（critical: 必须群元素）。

**双重和三重确认**：  
- (D1) R 给的 |Fix(g)| 与 T 推的 3^(cycle_count) 完全吻合（6/6 个 g）。  
- (D2) R 给的 |Stab(a)| 与 T 给的 a 在 cycle 上颜色配置吻合：  
  - 单色 a：|Stab|=6，T 中 6 个 g 都让 vertices_changed=0；  
  - 周期 3 a (010101)：|Stab|=2，T 中 g=3 (阶 2) vertices_changed=0；  
  - 周期 2 a (012012)：|Stab|=3，T 中 g=2,4 (阶 3) vertices_changed=0。  
- (D3) C 否决了「轨道数 130 是 Z_6 特殊偶然」：D_6 下 92 = (1/12) Σ_{D_6} |Fix(g)|，是同一公式在不同群下的实例。

## 论证尝试

**完整证明链（汇总自 R00、0T0、R0C、0TC、RT0）**：

**步骤 1（等价关系）**：群封闭性 + 单位元 + 逆元 ⟹ 自反、对称、传递。**论证不依赖数据，但 R 的 same_orbit 列在 100/100 same-pair 上一致验证。**

**步骤 2（orbit-stabilizer 定理）**：  
- R 提供 `n_connecting = |Stab|`（100/100 same-orbit pair）。  
- 证明：陪集分解 {g : g·a = b} = g₀·Stab(a)，对 b ∈ Orbit(a) 求和得 |G| = |Orbit|·|Stab|。  
- R 数据 (|Stab|, |Orbit|) ∈ {(1,6), (2,3), (3,2), (6,1)}，乘积 200/200 = 6。

**步骤 3（|Fix(g)| 的代数公式）**：  
- T 给出 g = 旋转 k 步 → cycle 数 = gcd(k, 6)。  
- a ∈ Fix(g) ⟺ a 在每 cycle 上常值 ⟹ |Fix(g)| = 3^(cycle_count)。  
- R 数据 (D1) 在所有 6 个 g 上验证。  
- 在 200 case 上 `is_fixed_point` 的统计也与 T 推的 cycle 模式一致。

**步骤 4（双重计数）**：  
P = {(g, a) : g·a = a}。  
- 按 g 求和：|P| = Σ_g |Fix(g)|。  
- 按 a 求和：|P| = Σ_a |Stab(a)| = Σ_{O orbit} Σ_{a∈O} (|G|/|O|) = |G|·#orbits（用步骤 2）。  
- 联立：#orbits = (1/|G|) Σ_g |Fix(g)|。

**步骤 5（C 给出的稳健性）**：  
- CF-2 (Z_6 → {e})：群必要前提（不能去掉）。  
- CF-3 (swap ∉ Z_6)：g 必须 ∈ G。  
- CF-1 (Z_6 → D_6 → 92 轨道)：Burnside 公式在不同群下都成立，不是 Z_6 特殊巧合。

**步骤 6（数值闭合）**：  
代入 |Fix(g)| = 3^(gcd(k,6))：  
#orbits = (1/6)(3^6 + 3^1 + 3^2 + 3^3 + 3^2 + 3^1) = (1/6)(729 + 3 + 9 + 27 + 9 + 3) = 780/6 = 130 ✓。  
等于 R 中 `total_orbits` 字段，等于 C 中 `original_condition.total_orbits`。

**与 R00 / RT0 / R0C 对比**：  
- R00 的 PROOF：双重计数 + 数值验证。  
- RT0 的 PROOF：双重计数 + cycle structure → 代数 |Fix(g)| 公式。  
- R0C 的 PROOF：双重计数 + 反事实稳健性。  
- **RTC = R0C ∪ RT0**：两条独立证据通路（cycle algebraic + counterfactual robustness）+ 主链。

## 自评
**评分：PROOF（4）**

理由：  
- 主证明在 R00 / R0C / RT0 任一上已经 PROOF。  
- RTC 没有把分数推到「PROOF+」（没有「PROOF+」这一档），主要价值是：  
  (a) 双重确认（R 与 T 互证 |Fix(g)| 公式）；  
  (b) 反事实排除 Z_6 巧合；  
  (c) 一条完全闭合的、每一步有数据验证 + 机制解释的论证。  
- 跨过 PROOF 的门槛已经在 R00（数值）或 R0C（数值+稳健）或 RT0（数值+代数）上发生；RTC 只是加固。
