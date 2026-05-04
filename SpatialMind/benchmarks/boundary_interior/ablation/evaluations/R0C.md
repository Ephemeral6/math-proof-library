# Condition R0C — Relation + Counterfactual (no Transform)

## 数据分析

R 给出（同 R00）：87 个 case 的 per-edge gcd 数据、Pick 公式两边对照、is_lattice / is_simple 标志。
CF 给出（同 00C）：lattice 失效、unimodular vs scale 操作分类、自交多边形失效。

R 单独已经能验证 Pick 公式跨 87 case，并展示 B = Σ gcd 的边界分解。
CF 单独提供 Pick 的*应用域*（lattice + simple）和*操作不变性的判据*（det=±1）。

R + CF 联合：
- R 的 87-case 验证 + CF 的应用域定义 = "Pick 在 lattice 简单多边形上恒成立"（87 case 落在域内 + CF 显示域外失败）。
- R 的 per-edge gcd 分解给出 B = Σ gcd；这是 CF 没明说但隐含在"is_lattice 是 Pick 必要条件"中的结构。

## 论证尝试

**定理（Pick）**：lattice 简单多边形上 A = I + B/2 − 1。

**证明（基于 R + CF）**：

**Step 1**（Shoelace + 边界 gcd 求和）：A 由顶点坐标通过 Shoelace 公式确定（R 验证 87 case）；B 由 Σ_e gcd(|Δx|, |Δy|) 确定（R 的 per-edge gcd 列表求和 = B，每个 case 验证）。

**Step 2**（域 = lattice 简单）：CF (1) 显示偏移 0.5 后 B、I 失去意义（"makes B and I (counts of integer points on/in the polygon) ambiguous"），故 lattice 是必要条件。CF (3) 显示自交多边形失去 well-defined "interior"，故 simple 是必要条件。

**Step 3**（公式 A = I + B/2 − 1）：R 在 87 case 上验证 area_from_pick == area_from_shoelace。CF (1) 给 (A=12, B=14, I=6) 和 CF (2) 给 (12, 14, 6) → (24, 22, 14) 都满足 Pick。

**Step 4**（操作不变性）：CF (2) 的 explanation 给出：
- |det|=1 unimodular 整数线性变换 → 保 (A, B, I)。
- |det|≠1 整数线性变换 → 仍 lattice，A 按 |det| 缩放，B、I 协同改变使 Pick 仍成立。

R 数据 case-level 印证：
- shear 16 case 全部 (A, B, I) 不变；R 的 edge gcd 列表是原列表的*重排*（unimodular 在格上是 GL₂(ℤ) 双射，保持每条边的 gcd 类型）。
- scale_non_uniform 16 case 全部 (A, B, I) 按 sx·sy 缩放；R 的 edge gcd 列表按 gcd(sx·Δx, sy·Δy) 重新计算。

**Step 5**（核心论证：边界决定内部）：
- A 从边界决定（Shoelace）。
- B 从边界决定（Σ gcd）。
- I 由 Pick 反推：I = A − B/2 + 1。
- CF (1) 和 CF (3) 给出反向证据：违反 lattice 或 simple 时，从边界数据反推 I 失效。

**Pick 公式本身的归纳证明**（援引外部几何事实，数据未直接展示）：
- 任意 lattice 简单多边形可三角剖分为基本三角形（B=3, I=0, A=1/2）。
- 沿对角线切分时 A、B、I 满足兼容关系，使 Pick 公式可逐步展开。
- 这一步骤的形式细节同 RT0 评估。

## 自评

**评分：PROOF（4）**

理由：
- R 给出"为什么"（per-edge 结构、87-case 公式验证）；
- CF 给出"在什么条件下"（lattice + simple）和"操作分类"（det 准则）；
- 两者拼出: 应用域 + 公式 + 不变性 + 边界决定内部的精确推导链；
- Pick 公式归纳证明仍需援引标准三角剖分（数据外），但与 RT0 同等水平；
- 唯一缺口：T 给的 (A, B, I) 直接数值可以让 87-case 验证更直接，但 R 的 area_from_pick == area_from_shoelace 已经实质等价。

**与 R00 比较**：R00 是 ARGUMENT（PROOF 缺 CF 提供的应用域/操作分类）；R0C 把这两个填上 → PROOF。

**与 RT0 比较**：RT0 通过 T 直接读 (A, B, I)；R0C 通过 CF explanation + R 推断同样结论。两者*殊途同归*达到 PROOF。
