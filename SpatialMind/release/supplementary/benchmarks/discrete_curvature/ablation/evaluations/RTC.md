# Condition RTC — full data (discrete_curvature)

## 数据分析

全部三种原语：

**R**:
- per-vertex defects 表（包括变化和新增）
- 每个 case 的 χ_pre = χ_post = 2，Σδ_pre = Σδ_post = 4π，全部 100/100 守恒
- curvature_types 在 4 个 preset 上都是 "all positive" 的亏格 0 模式

**T**:
- ΔV-ΔE+ΔF = 0 的组合恒等式（stellar: 1-3+2=0; displacement: 0-0-0=0）
- before/after V/E/F/χ/Σδ 数值 → 横跨 preset 验证 3F=2E
- region_affected 显示 stellar 的 local_defect_sum 守恒 + new vertex defect = 0

**C**:
- CF1: defect = 2π - 顶点周围角度和（孤立顶点 defect = 2π）
- CF2: 删一面 → Σδ +π → **每三角形角和 = π**
- CF3: manifold 一致性必需

**双重确认**: T 显示 stellar 操作满足 ΔV-ΔE+ΔF=0；R 显示 ΔΣδ=0；CF2 解释了为什么 R 的观测必然成立（每三角形 π 的强约束）。

## 论证尝试

**完整论证链**：

1. **每个三角形 T 内角和 = π** (C: CF2 直接证据 — 删去一个三角形让 Σδ 增加 π).
   - R 验证：在 stellar subdivision 中，新顶点周围的 3 段虽各自不是 π/3 但加起来恰好 2π（new_vertex_defect = 0），与原三角形 π 角对应分割一致。

2. **每个顶点 v 周围的角度和 = 2π - δ(v)** (C: CF1 定义 — 孤立顶点 defect = 2π).
   - R 在 100 个 case 上 per-vertex 验证；displacement 中 sum_of_vertex_changes = 0 直接用了"defect = 2π - sum of angles"。

3. **双重计数**: 把"全部三角形的全部内角"按面、按顶点求和：
   - 按面：Σ_T (3 angles in T) = π · F
   - 按顶点：Σ_v (angles at v) = Σ_v (2π - δ(v)) = 2πV - Σδ
   - 相等：**πF = 2πV - Σδ**

4. **闭曲面三角剖分**: 每边恰被 2 三角形共享，每三角形 3 边 ⟹ 3F = 2E.
   - T 的 before_state 给 V/E/F 绝对值横跨 4 preset：
     - tetrahedron 4/6/4: 3·4=12=2·6 ✓
     - cube_tri 8/18/12: 3·12=36=2·18 ✓
     - octahedron 6/12/8: 3·8=24=2·12 ✓
     - icosahedron 12/30/20: 3·20=60=2·30 ✓
   - 所以 χ = V - E + F = V - 3F/2 + F = V - F/2.

5. **合并 (3) 和 (4)**: 2πχ = 2π(V - F/2) = 2πV - πF = Σδ ✓

6. **Critical conditions (C)** 验证三处必要前提:
   - CF1: 退化拼接破坏"每面 π"约束 → Σδ 跳 +2π 而 χ 不变 → 等式失效。
   - CF2: 删面破坏"每边在 2 面"约束 → 3F ≠ 2E，χ 变 -1 但 Σδ 只变 +π → 等式失效。
   - CF3: 引用越界顶点破坏 mesh 一致性 → 整个推导框架失效。

**剩余 gap**:
- Step 1 的"每三角形角和 = π" 在 CF2 上是 *单点* 证据。我没显式验证它对每个面都成立（数据里没每三角形的逐角列表）。但这个引理是 Euclidean geometry 标准事实，agent 可以引用。
- Step 4 的 3F=2E 在我数据里只对 4 个 preset 验证，对 stellar 后的 mesh 没显式验证（虽然我可以从 ΔV=1, ΔE=3, ΔF=2 推断它仍成立: 3(F+2)=3F+6, 2(E+3)=2E+6 → 保持）。
- 没构造一个对 *任意* 三角剖分闭曲面的形式化证明，仍是"用关键引理 + 双重计数"的非形式化论证。

## 自评

**评分：ARGUMENT（3）**

理由：R + T + C 三者拼起来给我一个 *完整的*本地→全局推理链，比 R0C 更密（多了 T 的 V/E/F 绝对值 + 操作的 ΔV-ΔE+ΔF 验证），所有关键步骤都有数据 *和* 反事实双重支撑。但没跨过 PROOF 的门槛：(a) "每三角形角和 = π" 是从 CF 单点 + 几何常识引入的，不是数据闭环；(b) 我没形式化"所有三角形的所有内角等于按面求和等于按顶点求和"的双重计数，仍依赖直觉。这两点让我停在 ARGUMENT 而非 PROOF。

与 R0C 比，RTC 的额外信号是 T 的"组合不变性双重确认"（ΔV-ΔE+ΔF=0 ⟺ Δχ=0 ⟺ ΔΣδ=0 三联）和 V/E/F 的 *绝对* 值；R0C 已经跨过门槛、RTC 主要是冗余加固。
