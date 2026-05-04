# Condition R0C — Relation + Contrastive (discrete_curvature)

## 数据分析

R 数据 + 3 个 critical CF（同 R00 + 同 00C 的并集）。关键拼图：

**R 给我**:
- 100 个 case 全部满足 `total_curvature_pre = total_curvature_post = 12.566... = 4π`
- `euler_pre = euler_post = 2`
- per-vertex defects 的变化和分布（包括"显式空集"或"零和重分布"）
- curvature_types: 多面体所有顶点都是 positive（defect > 0）

**CF 给我两条机制线索**:
- **CF1 (boundary_relaxation)**: 退化拼接让新顶点周围有 0 度角 → defect = 2π。这等价于"defect = 2π - 顶点周围角度和"。
- **CF2 (operation_perturbation)**: 删一个面让 Σδ 增 π，χ 减 1，G-B 失效。**关键**：被删面的 3 个角加起来正好是 π —— 即 **每个三角形内角和 = π** 是 G-B 等式的核心引理。

## 论证尝试

R + C 拼起来给我完整的本地 → 全局推导链：

**Step 1（C 提供 + R 验证）**: 每个三角形 T 的内角和 = π。
- CF2 直接证据：删除一个三角形让 Σδ 增加 π（因为 3 个角的总和 π 之前是从顶点的"完整 2π"中扣除的；删掉这个三角形等于把这 π 还给"角缺"账户）。
- R 数据间接验证：在 stellar subdivision 中 `local_defect_sum_before = local_defect_sum_after`，新 vertex 的 defect = 0（其周围 3 段共面 = 2π），且原 3 顶点的 defects 不变 — 都说明角度账户严格按"每三角形 π"分配。

**Step 2（R 提供）**: 每个顶点 v 周围的角度和 = 2π - δ(v)（这就是 defect 的定义，从 CF1 直接给出）。

**Step 3（双重计数）**: 把"所有三角形的所有内角"分别按面、按顶点求和：
- 按面：Σ_T (sum of 3 angles in T) = π · F
- 按顶点：Σ_v (sum of angles at v) = Σ_v (2π - δ(v)) = 2πV - Σδ
- 相等：**π · F = 2π · V - Σδ**，即 **Σδ = 2πV - πF**

**Step 4（闭曲面三角剖分的边-面恒等式）**: 每条边恰被 2 个三角形共享，每个三角形 3 条边，所以 3F = 2E ⟹ E = 3F/2，从而 χ = V - E + F = V - F/2。

**Step 5（合并）**: 2πχ = 2πV - πF = Σδ ✓

**剩余 gap**: Step 4 中 "每条边恰被 2 个三角形共享" 不是 R 或 C 直接证据—— prompt 说了"closed manifold"但数据没专门验证 3F=2E。从 4 个 preset 的 V/E/F (4/6/4, 8/18/12, 6/12/8, 12/30/20) 我可验证 3F = 2E 在每个 case 都成立 (12=12, 36=36, 24=24, 60=60)。这其实在 R 的 detailed_comparison 里有 V/E/F 数字，所以可以验证。

## 自评

**评分：ARGUMENT（3）**

理由：R + C 双重确认形成了完整的论证链：
- CF2 提供"每三角形角和 = π"这条 G-B 的关键引理（论证里的 pivot）；
- R 提供 per-vertex defect 的定义与全局求和；
- R 的 V/E/F 数字横跨 4 个 preset 都满足 3F=2E。
我能写出一个 *条件 → 结论* 的推理链 + 跨 preset 验证，但没构造严格 PROOF（没有完全形式化"双重计数"的几何对偶性）。
