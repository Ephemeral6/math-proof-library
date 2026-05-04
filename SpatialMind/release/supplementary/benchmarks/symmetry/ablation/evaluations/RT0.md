# Condition RT0 — relation + transform, no contrastive (symmetry_combinatorics)

## 数据分析
R 和 T 全部，无 CF：

**R 提供** (复述自 R00)：  
- `connecting_pre = stabilizer_a_size_pre` 在 same-orbit 上 100/100 一致 (orbit-stabilizer 构造性证据)。  
- `(|Stab|, |Orbit|) ∈ {(1,6), (2,3), (3,2), (6,1)}`，乘积全等于 6。  
- `fixed_point_counts = {0:729, 1:3, 2:9, 3:27, 4:9, 5:3}`，sum/6 = 130 = total_orbits。  

**T 提供** (复述自 0T0)：  
- 每个 g 的具体 cycle 结构（permutation = [shift k]）。  
- `is_fixed_point` 在 a 和 g 上验证 g·a == a。  
- `vertices_changed` 严格匹配 cycle 结构：阶 d 旋转下未固定的 a 移动 d 的倍数个顶点。

**双重确认（R 与 T 互证）**：  

(D1) `Fix(g)` 大小（来自 R）和 g 的 cycle 数（来自 T）满足 `|Fix(g)| = 3^(cycle_count)`：  
- g=0 (id, 6 cycles): 3^6 = 729 ✓  
- g=1,5 (1 cycle): 3^1 = 3 ✓  
- g=2,4 (2 cycles): 3^2 = 9 ✓  
- g=3 (3 cycles): 3^3 = 27 ✓

(D2) Stab(a) 与 a 的循环上颜色配置一致：  
当 (n_distinct=1, |Stab|=6) 时 a 是单色（被所有旋转固定）。  
当 (n_distinct=2, |Stab|=2) 时 a 是周期为 3 的着色（如 010101，被 g=3 固定）。  
T 让我看到具体的 a 着色和 g 的 cycle，验证「Stab 元素正是把 a 投影到 cycle 内同色的那些 g」。

## 论证尝试

**完整证明 — Burnside 引理**：

**步骤 1：等价关系**。群封闭性给出。

**步骤 2：orbit-stabilizer**。  
- 关键事实 (来自 R)：对 same-orbit (a, b)，`#{g: g·a = b} = |Stab(a)|`。  
- 证明：如果 g₀·a = b，则集合 {g : g·a = b} = g₀·Stab(a)（左陪集），大小 = |Stab(a)|。  
- 把 G 按 g·a 落点分组：G = ⨆_{b ∈ Orbit(a)} {g : g·a = b}。  
- 取大小：|G| = |Orbit(a)| · |Stab(a)|。

数据 200/200 验证 |Stab|·|Orbit| = 6（来自 R）。

**步骤 3：Fix(g) = 3^(cycle_count(g))**。  
- T 显示每个 g 是 6 个顶点上的循环置换。  
- a 被 g 固定 ⟺ a 在 g 的每个 cycle 上常值。  
- 设 g 把顶点分成 c 个 cycle，每个 cycle 上独立选 1 种颜色（共 3 种），所以 |Fix(g)| = 3^c。  
- 数据 (D1) 在 6 个 g 上全部验证。

**步骤 4：双重计数（Burnside）**。  
定义 P = {(g, a) ∈ G × X : g·a = a}。  
- 按 g 求和：|P| = Σ_g |Fix(g)|。  
- 按 a 求和：|P| = Σ_a |Stab(a)| = Σ_{O orbit} Σ_{a∈O} |Stab(a)|。  
- 用步骤 2：对 a ∈ O，|Stab(a)| = |G|/|O|。所以 Σ_{a∈O} |Stab(a)| = |O| · (|G|/|O|) = |G|。  
- 求和 over orbits：|P| = |G| · #orbits。  
- 联立：#orbits = (1/|G|) Σ_g |Fix(g)|。

**数据验证**：  
(1/6)(729 + 3 + 9 + 27 + 9 + 3) = 780/6 = 130 = total_orbits ✓（来自 R）。

**步骤 5（细节自洽）**：  
代入 |Fix(g)| = 3^(cycle_count)：  
#orbits = (1/|G|) Σ_g 3^(cycle_count(g))  
= (1/6) Σ_{k=0}^{5} 3^(gcd(k,6))  
= (1/6) (3^6 + 3^1 + 3^2 + 3^3 + 3^2 + 3^1)  
= 130 ✓。

这是 Pólya 计数的标准化结果。

**全部论证闭合，且每一步都有数据 200/200 验证 + R 与 T 互相校对。**

## 自评
**评分：PROOF（4）**

理由：  
- 步骤 2 的 `n_connecting = |Stab|` 数据是构造性证据（来自 R）。  
- 步骤 3 的 cycle 结构 → Fix(g) 公式（来自 T）。  
- 步骤 4 的双重计数把两块拼接，给出 Burnside。  
- R 和 T 的双重确认（D1, D2）排除了「巧合 fitting」的可能。  
- 比 R00 的优势：T 给出 |Fix(g)| 的代数公式（3^(cycle count)），让证明从「数值验证 130」上升到「机制解释 130」。
