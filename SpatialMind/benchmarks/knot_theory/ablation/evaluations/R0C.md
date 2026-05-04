# Condition R0C — R + C, no Transform (knot_theory)

## 数据分析
**R 信号**：sign pair (+1,−1) 100/100；signature/det/Alex/writhe 全部 100/100 守恒。

**C 信号**（3 critical CFs）：
- boundary_relaxation：同号 sign pair → writhe ±2、Alexander 变、determinant 变（signature 在这个例子里恰好不变）
- operation_perturbation：crossing flip → 所有不变量变
- condition_removal：planarity 破坏 → 不变量变

## 论证尝试

**关键组合：R 显示 pattern + C 定位 load-bearing 条件**。

**论证链**：
1. **观察** (R, 100/100)：R2 always 添加 sign pair (+1, −1)。
2. **观察** (R, 100/100)：在所有 100 case 上，signature, determinant, Alexander, writhe 全部守恒。
3. **CF 反事实** (boundary_relaxation)：把 sign pair 改成同号 ((-1,-1) 或 (+1,+1))，则
   - writhe 变 ±2（合理：sum of signs 变了）
   - determinant 变（在 3_1 上从 3 → 7）
   - Alexander 变（[1,−1,1] → [2,−3,2]）
   - signature 在这个例子上不变（巧合，不一般）
4. **CF 反事实** (operation_perturbation)：翻转一个原 crossing 的 over/under（不是 R-move），所有不变量变。
5. **结合** (1)+(2)+(3)+(4)：critical condition = "R2 添加的 sign pair 必须互补 (+1,−1)，而且不能修改原 crossings"。
6. **结论**：R2（合法 R-move）满足 (5)，故守恒所有 invariants。

**剩余 gap**：
- 第 2 → 第 6 没有 *机制* 链接。我观察到 sign pair 决定 invariants，但没有用 Seifert matrix 或类似工具解释 *为什么*。
- CF (boundary) 显示 "signature_delta = 0"，意味着 signature **可能不依赖**于 sign pair。这是个 sub-observation：不是所有 invariants 都通过 writhe 与 R2 联系。

## 自评
**评分：ARGUMENT（3）**

理由：R + C 组合构成了一条 *partial chain*：
- **观察** R2 sign pair (+1,−1)（R）
- **联系到** 不变量守恒（R 直接验证）
- **由 CF 确认** sign pair 是 load-bearing（C）
- **细节缺口**：sign pair → invariants 的代数机制（Seifert matrix）未给出。

跨过了 PATTERN → ARGUMENT 的门槛，因为 CF 让 "(+1,−1) 是关键" 从猜测变成了被反证支持的命题。但 ARGUMENT−，未到 PROOF。
