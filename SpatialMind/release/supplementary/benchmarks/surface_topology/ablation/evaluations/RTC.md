# Condition RTC — full data (R + T + C)

## 数据分析

汇总所有信号：

**R**
- bigons_without_puncture 恒 = 0（pre & post）。
- crossings_outside_region 恒 = 0。
- minimal_position 恒 false。
- candidate crossings 平均 11.91 → 8.74，bigon 总数 11204 → 7790——surgery 整合 / 消去 bigon。

**T（退化于 S_{1,2}）**
- region 总是 = 整个三角剖分（4 三角形）。
- β 总是 100% 在 region 内。
- long_arc 为空。

**C**
- i = 2 → net = −2（critical）。
- descending link、γ₀ 不 critical。

**联合衍生事实**
- 「crossings_outside_region = 0」+「region = 全曲面」⟹ 这两条互相蕴含，T 没有为 R 加层。
- bigons_without_puncture 在 surgery 前后都 = 0 ⟹ surgery 不会创建无 puncture 的 bigon（这是新意：post 也成立，意味着 surgery 不破坏 bigon 的 puncture 性质）。
- 当 i = 2 时（反事实），net = −2 暗示「两个相对的 essential 交叉点被 surgery 消去」；当 i ≤ 1 时（正例），不会出现这种过剩配对。

## 论证尝试

我尝试构造完整论证：

> **Claim**: 若 i(α, β) ≤ 1，则 i(σ_α, β) = i(α, β)。
>
> **Step 1（C 给的）**: i(α, β) ≤ 1 是 critical 边界（boundary_relaxation 反事实）；descending link 和 γ₀ 选择不 critical（前两条可去）。所以证明应当只用 i ≤ 1 这一个假设。
>
> **Step 2（R 给的）**: 在所有 1563 个 i = 1 的正例中，每个 α–β bigon 都包含 puncture，且 surgery 后仍如此。Puncture 阻止 isotopy 把 bigon 缩掉，所以每个 bigon 都对应一个 *essential* 的几何相交对。
>
> **Step 3（i ≤ 1 的角色）**: 当 i = 1，α 和 β 几何上恰好一次 essential 相交。bigon（含 puncture）是「pseudo-redundant」配对——它们存在于三角剖分表示，但不影响 minimal-position intersection number。
>
> **Step 4（surgery 局部性，由 T 应当提供，但在 S_{1,2} 退化）**: 因为 region = 全曲面，我无法把 surgery 拆成「区域内变 / 区域外不变」。我只能依赖：surgery 不创造无 puncture 的 bigon（R 显示 post 仍满足 bigons_without_puncture = 0）。
>
> **Step 5（推断）**: surgery 改变了 α 的弧路径（从 11.91 平均候选交叉降到 8.74），但每次它消去的两个候选交叉总是配对的「punctured-bigon 边」，因此对 minimal-position intersection number 没贡献。结合 i = 1 的紧约束，net change = 0。
>
> **Step 6（i = 2 的反事实如何符合）**: 当 i = 2，存在两对 essential 相交（不是 pseudo-redundant），surgery 在简化 α 时把其中一对 essential 相交消去（净 −2），不被 puncture 保护。
>
> **Step 7（缺失）**: 第 5 步「surgery 消去的总是 punctured-bigon 配对」只是 *从数据上看见*，没有证明 surgery 算法 *为什么* 必然这样。这正是 T 应当提供的局部分析——但 T 在 S_{1,2} 上退化。

我有一个 *partial chain*：Step 1–6 形成连贯的论证骨架；Step 7 是 gap。

## 自评
**评分：ARGUMENT（3）**

理由：组合 R + C 给出了主论证链（i 是 critical → bigon 都 essential → punctured-bigon 配对消去 ⟹ net = 0）；T 退化使 Step 7 局部分析缺失，所以不到 PROOF。比起 R0C / 0TC 单独，组合显著更接近完整论证（多出 R∧C 的"冗余 vs essential"区分 + 反事实对 i=2 行为的解释）。
