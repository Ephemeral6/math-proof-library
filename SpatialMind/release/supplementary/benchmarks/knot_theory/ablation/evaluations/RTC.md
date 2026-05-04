# Condition RTC — full data (knot_theory)

## 数据分析
全部三种原语：

**R**: sign pair (+1,−1) 100/100；signature/det/Alex/writhe 全部 100/100 守恒。
**T**: R2 是 additive，原 crossings 不动；trace 也显示 sign pair (+1,−1) 100/100。
**C**: 3 critical CFs（boundary, operation, condition）。

**从 R 和 T 双重确认**：sign pair = (+1,−1) 在两条独立的数据通路上都看到，互相验证。

**关键细节** (CF boundary):
- 同号 R2 → writhe ±2，determinant 变（3 → 7），Alexander 变（[1,−1,1] → [2,−3,2]）
- 但 **signature 在这个例子上不变**——意味着 signature 不直接由 writhe / sign pair 决定。

## 论证尝试

**完整论证链**：

1. **R2 是 purely additive** (T): 原 K 的所有 crossings 在 K' 中保留 (`persistent_crossing_count` = 原 n)。
2. **R2 添加的两个 crossing sign 互补** (R + T): 100/100 都是 (+1, −1)。
3. **Sign pair sum = 0** ⟹ writhe 守恒 (summary 直接验证 100/100)。
4. **在所有 100 case 上，signature, determinant, Alexander 也守恒** (R 直接验证)。
5. **Critical condition (C)**: 把 sign pair 改成同号 → writhe ±2，determinant + Alexander 变 (boundary CF 直接展示)。
6. **Critical condition (C)**: 翻转一个原 crossing → 不是 R-move，所有不变量变 (operation CF)。
7. **Critical condition (C)**: 破坏 planarity → 不变量变 (condition CF)。
8. **结合 (5)+(6)+(7)**: R2 的 *合法性* = (purely additive) ∧ (sign pair (+1, −1)) ∧ (planarity preserved) → 全部守恒。
9. **细微 nuance**: signature_delta = 0 在 boundary CF 中说明 signature 不直接由 sign pair 决定——sign pair → writhe → determinant/Alexander，但 signature 通过其他机制 (Seifert matrix 的 sig(S+S^T)) 进入。

**剩余 gap**：
- 第 (3) → 第 (4) 没有给出代数机制：为什么 (+1,−1) 添加保持 Seifert matrix 的关键不变量？这需要 R2 在 Seifert surface 上对应 stable equivalence 的 step，我没有显式的 Seifert matrix 演算数据可用。
- 因此到 ARGUMENT，未到 PROOF。

## 自评
**评分：ARGUMENT（3）**

理由：R + T + C 给出的论证链比 R0C 略强（多了 T 的 locality 信号 + 双重确认）。但门槛已经在 R0C 跨过，R+T+C 主要是冗余确认 + nuance，没有跨到 PROOF。
