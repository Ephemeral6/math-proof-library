# Condition R0C — R + C (no Transform)

## 数据分析
**R 信号**（同 R00）：
- 每个 bigon 都含 puncture（bigons_without_puncture 恒 = 0）。
- 所有候选交叉都在变换区域内（crossings_outside_region 恒 = 0）。
- minimal_position 恒 false。
- candidate crossings 通常下降。

**C 信号**：i(α, β) ≤ 1 是 critical 边界（i = 2 时 net = −2）；descending link 和 γ₀ 选择都不 critical。

## 论证尝试

**关键组合**：现在我可以把 R 的 *结构观察* 与 C 的 *约束定位* 拼起来：

> hypothesis：「i(α, β) ≤ 1」是 critical，因为它限制了 α 与 β 之间 essential bigon 的数量；
> 而 R 显示每个 bigon 都含 puncture（即每个 bigon 都是 essential 的）；
> 在 i = 1 时，α 和 β 几何上至多形成有限个 essential bigon，且这些 bigon 的 puncture 结构在 surgery 下保持。

但即使把 R 和 C 拼起来，我仍然缺一个核心环节：

> **surgery 怎样作用于 α**？ 它替换了 α 的哪段弧？哪些 bigon 因此被消去 / 保留？

这个环节需要 T 数据。R 给了我 *static structure*，C 给了我 *which condition matters*，但 *how the operation acts* 仍是空白。

我能给出的论证最多到：
1. i(α, β) = 1 ⟹ 至多一个 essential 几何相交点。
2. 每个候选 bigon 含 puncture（R）⟹ 每个 bigon 都 essential，无法 isotopy 消去。
3. C 反事实：i = 2 时 net 减 2 ⟹ 多出来的两个 bigon 在 i = 2 时无法被「保护」。
4. 因此 i ≤ 1 是「bigon 数 ≤ 某阈值，所有都是 essential」的边界。
5. ?? surgery 如何作用 ??

第 1–4 步是真实的论证链；第 5 步缺失。

## 自评
**评分：PATTERN（2，靠近 ARGUMENT 边界）**

理由：相比 R00 和 00C 单独，R0C 给出了一条 *partial* 论证链——结构观察 + 约束定位。但缺 T 提供的「surgery 怎样作用」环节，所以没法闭合。诚实地说这是 strong PATTERN，半步靠近 ARGUMENT 但还没到。

> 严格用整数评分时记 2；如果用 5 级浮点细分，给 2.5。
