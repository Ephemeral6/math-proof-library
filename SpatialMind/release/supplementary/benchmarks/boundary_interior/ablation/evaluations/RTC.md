# Condition RTC — All primitives (boundary_interior)

## 数据分析

完整数据：
- R: per-edge gcd / length / direction，pick formula 双侧验证，is_lattice / is_simple / is_convex。
- T: trace 的 (A, B, I, pick_holds) before/after 数值、operation 名称、delta、region_affected。
- C: lattice/simple 必要条件、unimodular vs scale 操作分类、bowtie 自交反例。

87 case 上的多重一致性：
- A_shoelace = A_pick = I + B/2 − 1（R 双侧 + T 数值，独立两路验证 87 case）。
- B = Σ_e gcd(|Δx_e|, |Δy_e|)（R 的 per-edge gcd 求和 = trace 的 B）。
- 4 类操作的 (A, B, I) 行为与 CF (2) 的 det 准则完全一致。
- pick_holds = True 在所有 87 case 上恒成立；CF 给出失败案例（非 lattice / 自交）。

## 论证尝试

**定理（Pick）**：设 P ⊂ ℝ² 是顶点都在 ℤ² 上的简单多边形。则
$$A(P) = I(P) + \frac{B(P)}{2} - 1$$

**完整证明（基于 RTC 三类数据 + 标准三角剖分）**：

**(A) 边界数据完全决定 A 和 B**

(A.1) **Shoelace formula** (R 数据 case-level 验证): 对顶点序列 (x_0, y_0), …, (x_{n-1}, y_{n-1})，
$$A = \frac{1}{2}\left|\sum_{i=0}^{n-1}(x_i y_{i+1} - x_{i+1} y_i)\right|$$
仅依赖顶点坐标，没有内部信息。R 的 `vertices_a / vertices_b` 与 `area_from_shoelace` 给出 87 case 的端到端验证。

(A.2) **B = Σ gcd** (R 的 per-edge gcd 数据 case-level 验证): 对每条边 (u, v)，边上的格点（含两端）数 = gcd(|Δx|, |Δy|) + 1。在闭环上每条边贡献 gcd(|Δx|, |Δy|) 个不重复格点，故
$$B = \sum_{e \in \partial P} \gcd(|\Delta x_e|, |\Delta y_e|)$$
R 的 `edge_gcd_decomposition_a` 求和 = `B_a` 在 87 case 上验证。

(A.3) **A 和 B 都仅依赖边界数据**——不需要任何关于 P 内部的信息。

**(B) Pick 公式 A = I + B/2 − 1 (内部 I 由 A、B 反推)**

(B.1) **三角剖分归纳** (外部数学事实): 任意 lattice 简单多边形 P 可三角剖分为基本三角形（B=3, I=0, A=1/2）。
- 基础情形：基本三角形满足 1/2 = 0 + 3/2 − 1 ✓。
- 归纳步：若 P = P₁ ∪ P₂ 沿对角线 D 切分，D 上有 k 个 lattice 内部点（不含端点），则
  - $A = A_1 + A_2$（面积可加）
  - $B = B_1 + B_2 - 2(k+1)$（D 上 k 个内点和 2 个端点都被两个子多边形数过）
  - $I = I_1 + I_2 + k$（D 上 k 个内部点合并到 P 的 interior）
  - 代入 P₁、P₂ 的 Pick 公式（归纳假设）+ 整理 → P 的 Pick 公式。

(B.2) **R 数据的内部一致性验证**: `area_from_pick = I + B/2 − 1` 在 87 case 上等于 `area_from_shoelace`（独立计算）。这是 Pick 公式的端到端验证（用 R 的两个独立路径同时算 A）。

(B.3) **T 数据的数值验证**: trace 给出 87 case 的 (A, B, I) 三元组——独立验证 A − I − B/2 + 1 = 0。

**(C) 应用域和操作不变性 (由 CF)**

(C.1) **必要条件**:
- CF (1): lattice 失效 → B、I 没意义 → Pick 不适用。
- CF (3): simple 失效 → interior 不 well-defined → Pick 不适用。
- 因此 Pick 的成立条件是 {lattice, simple}，这两个是必要的。

(C.2) **操作不变性的判据**: CF (2) + R + T 的操作分类:
- |det|=±1 整数线性变换（包括 translate, identity, unimodular shear）和"add_vertex 在边的内部格点上"——这些操作让 (A, B, I) 完全不变。
  - 数据印证：71/87 case area_preserved=True，且 R 的 edge gcd 分解保持 multiset（unimodular 在格上 GL₂(ℤ) 双射）。
- |det|>1 整数线性变换（如 scale_non_uniform）——A 按 |det| 缩放，B 和 I 协同改变使 Pick 在新多边形上仍成立。
  - 数据印证：16/87 case area_preserved=False；R 的 edge gcd 在 scale 后按 sx·dx, sy·dy 重算；T 的 (A, B, I) 三元组依然满足 A = I + B/2 − 1。

**(D) 综合：边界决定内部**

由 (A): 给定边界（顶点坐标），可算出 A 和 B。
由 (B): 给定 A 和 B，由 Pick 反推 I = A − B/2 + 1。
由 (C): 这一切的前提是 lattice + simple。

故在应用域内，**边界数据完全决定内部格点数 I**——这是离散版 Stokes / Green 定理的核心：
> ∮_{∂P} (boundary information) → ∫_P (interior measure)

## 自评

**评分：PROOF（4）**

理由：
- 完整双向证明：边界 → A（Shoelace）+ 边界 → B（Σ gcd）+ Pick 反推 I（A、B → I），由三个独立 routes 验证 87 case。
- 应用域由 CF 严格规定（lattice + simple）。
- 操作不变性由 CF 的 det 准则 + R 的 gcd multiset 不变 + T 的 (A, B, I) 数值变化交叉验证。
- Pick 公式归纳证明的外部援引（三角剖分）与 RT0 / R0C 同等水平——这是该 domain 的硬上限，不是 RTC 的局限。
- 87 case 的多源一致性（R 双侧 + T 数值 + CF 应用域）给出"完整可验证证明"水平的支持。

**与 RT0 / R0C 比较**：
- RT0: R + T，达到 PROOF。
- R0C: R + CF，达到 PROOF。
- RTC: R + T + C，仍是 PROOF（顶到上限）。RTC 比 RT0/R0C 多的不是新论证步骤，而是**多源验证**——同一个结论被三种数据独立确认，提升 *证据强度* 但不升评分。

**与 0TC 比较**：0TC 是 ARGUMENT（缺 R 的边界 → A、B 结构推导）；R 进入后跨过 PROOF 门槛。这是 R × C 或 R × T 的关键作用：R 把 "boundary determines interior" 从经验 fact 变成 structural theorem。
