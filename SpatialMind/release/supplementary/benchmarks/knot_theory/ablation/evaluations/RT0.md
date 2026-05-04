# Condition RT0 — R + T, no Contrastive (knot_theory)

## 数据分析
拥有 R00 的 R 信号 + 0T0 的 T 信号。

**R 复述**：sign pair (+1,−1) 100/100；signature/det/Alex/writhe 全部 100/100 守恒。

**T 复述**：R2 是 additive；persistent crossings 全保留；trace 显示新增 (+1,−1) 对。

**联合观察**：
- R 和 T 都给出 sign pair = (+1,−1) — 这是同一个数据从两个角度。
- T 多出的信息：**locality**（原 crossings 不被动）。
- R 多出的信息：**signature/det/Alex 守恒在正例上被直接验证**。

合起来：
- R2 在 K 的某条弧上 *添加* 一对 (+1, −1) crossing；不影响其他 crossing；K' 与 K 的 signature/det/Alex 全部相等。

## 论证尝试
比 R00 / 0T0 单独多了一点：现在我知道 R2 = "局部 add (+1,−1) pair, no other change"，加上"全部 invariants 守恒"的直接验证。

可能的论证链：
1. R2 是 *局部 additive* 操作（T 显示）。
2. 添加的 sign pair = (+1, −1)，sum = 0（R 和 T 都显示）。
3. 因此 writhe 守恒。
4. 在 100 个 case 上，signature / det / Alex 也都守恒（R 显示）。
5. **缺**: 为什么 (3) 蕴含 (4)? 没有 CF 告诉我哪个条件 (locality vs sign-pair) 是 load-bearing。

我能不能不用 CF 推断"sign pair (+1,−1) 是关键"？反思一下：
- 如果只是 "locality" 关键，那同号 R2 也应当守恒（因为也是局部）。
- 如果 "sign pair (+1,−1)" 关键，则同号 R2 应当破坏。
- 但我没有同号 R2 的数据，所以无法在 R+T 内部分辨。

## 自评
**评分：PATTERN（2）**

理由：信息量比 R00 / 0T0 单独略多（locality + 直接 invariant 验证），但仍然停留在结构观察层面。无法分辨 sign-pair 和 locality 哪个才是 load-bearing 条件——这正是 CF 应当回答的问题。
