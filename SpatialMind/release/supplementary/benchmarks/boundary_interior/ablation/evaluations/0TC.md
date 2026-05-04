# Condition 0TC — Transform + Counterfactual (no Relation)

## 数据分析

T 给出（同 0T0）：87 case 的 trace 中包含 (A, B, I, pick_holds) before/after 数值、operation 名称、delta。
CF 给出（同 00C）：lattice/simple 必要条件 + det 操作分类。

T 的 87 case 直接验证 A = I + B/2 − 1（87 个独立 (A, B, I) 三元组，每个都满足公式），并显示 4 类操作对 (A, B, I) 的影响：
- translate / shear / add_vertex: (A, B, I) 不变。
- scale_non_uniform: (A, B, I) 按 sx·sy 缩放但仍满足 Pick。

CF 提供应用域（lattice + simple）和操作不变性的判据（det=±1）。

## 论证尝试

**定理（Pick）**：lattice 简单多边形上 A = I + B/2 − 1。

**证明（基于 T + CF）**：

**Step 1**（87-case 经验验证）：T 的 trace 给出 87 个 (A, B, I) 三元组；逐个验证 A − I − B/2 + 1 = 0。每个三元组也是覆盖 8 类预制多边形 + 4 类变换 + 10 个 cross-pair，结构差异显著（A ∈ [1, 75]、B ∈ [4, 40]、I ∈ [0, 64]）。

**Step 2**（应用域，由 CF）：
- CF (1)：lattice 是必要的（顶点偏移 0.5 → B, I 失去意义）。
- CF (3)：simple 是必要的（自交 → interior 不 well-defined）。
- T 显示 87 case 都有 is_simple = True（间接：通过 pick_holds=True 推断）和 is_lattice 隐含（trace 不直接给但 b、I 为整数说明是 lattice）。

**Step 3**（操作不变性，由 T + CF）：
- CF (2)：unimodular 整数线性变换保 (A, B, I)；非 unimodular 按 |det| 缩放。
- T 数据印证：71/87 case (translate, shear, add_vertex, identity_compare) 全部 area_preserved=True；16/87 case (scale_non_uniform) area_preserved=False。
- 对 16 个 scale_non_uniform case，trace 显示 area_change = (sx·sy − 1) × area_pre：例如 rectangle_4x3 + scale [2,1] → A: 12 → 24（×2，sx·sy=2 ✓）。这与 CF (2) 的 |det| 缩放论断完全一致。

**Step 4**（"边界决定内部" 的论证）：
- T 不直接给顶点坐标和边的 gcd 分解，所以"边界 → A"（Shoelace）和"边界 → B"（Σ gcd）的*结构推导*不在数据里。
- 但 T 的 87-case 经验 + CF 的应用域 + CF 的操作分类合起来给出一个**间接论证**：
  - 在 lattice 简单多边形上，(A, B, I) 三者满足 Pick；
  - 因此知道任意两个就能推出第三个；
  - 特别是知道 A 和 B（边界决定）就能推出 I（内部）。
- 但要严格证明 A 和 B 都"由边界决定"，需要 R 的结构数据（顶点 + 边 gcd），这里没有。

**Pick 归纳证明**（外部数学事实，可援引）：与 RT0 同。

## 自评

**评分：ARGUMENT（3）**

理由：
- T 提供 87-case 的 (A, B, I) 数值验证 + 4 类操作分类；
- CF 提供应用域 + 操作不变性的判据；
- 论证链：lattice 简单多边形 → Pick 公式 → 87-case 验证 → 应用 → 边界决定内部；
- 但缺乏"为什么 B 由边界 gcd 求和决定"的*结构*推导（R 才能给）；
- 可以援引 Shoelace 公式作为"A 由边界决定"的标准事实，但*这条由数据外引入*，不是从 0TC 自然涌现；
- 因此达到 ARGUMENT，离 PROOF 还差一步（边界 → B 的 gcd 分解必须从 R 来，0TC 无法独立给出）。

**与 R0C 比较**：
- R0C: R 提供边界结构 + CF 提供应用域 → PROOF（边界决定内部完整推导）。
- 0TC: T 提供 87-case 数值 + CF 提供应用域 → ARGUMENT（数值验证 + 应用域，但缺结构推导）。

T 与 R 在此 domain 上*不冗余*：T 给 (A, B, I) 数值，R 给边界结构（gcd 分解、顶点坐标）；两者覆盖不同信息。
