# Condition 0TC — T + C, no Relation (knot_theory)

## 数据分析
**T 信号**：trace 显示 R2 添加 sign pair (+1, −1)，原 crossings 不动；persistent count = 原 K 的 crossing 数；100/100 case 上 writhe_delta = 0。

**C 信号**：3 critical CFs（同 R0C 的 C 部分）。

## 论证尝试

T 让我看到 R2 的 *局部 additive* 结构 + sign pair。C 让我看到 violation 会发生什么。但缺 R 数据：**我看不到正例的 signature / det / Alex 实际值，也看不到它们是否守恒**。

我能做的论证：
1. R2 = locally add (+1, −1) sign pair（T）。
2. CF：违反这个 sign pair 会破坏不变量（C）。
3. 因此 R2 守恒不变量。

**问题**：第 (3) 步是从反事实推断的，没有正例直接验证。CF 只在一个 K = 3_1 上展示 baseline；100 个正例的具体 invariant 值我看不到。我**假设** R2 在所有 100 case 上守恒 invariants（合理但未验证）。

如果对照 R0C：
- R0C 看到 100 个 case 的 invariants 全部守恒（直接验证）+ CF。
- 0TC 看到 trace 显示 sign pair 是 (+1,−1) + CF，但 invariants 守恒未直接看到。

这两条件在论证强度上的差异：R0C 有"100 个直接验证的 datapoints"，0TC 只有"trace 显示 sign pair 一致 + CF 暗示这就够了"。0TC 缺正例验证。

## 自评
**评分：PATTERN（2，弱于 R0C 的 3）**

理由：T+C 给出 sign pair 来自 trace + CF 定位关键条件，但缺 R 提供的正例 invariant 直接验证。论证靠的是"CF 反推 + trace 一致" 的间接推断，没有"100 个例子全保留"的直接证据。比 R0C 弱半步。
