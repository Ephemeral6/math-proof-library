# Condition 0TC — Transform + Contrastive (discrete_curvature)

## 数据分析

T 数据（同 0T0）+ 3 个 critical CF（同 00C）。

**T 给我**:
- ΔV-ΔE+ΔF 的纯组合恒等式
- before_state / after_state V/E/F 的绝对值 → 横跨 preset 我能看到 4/6/4, 8/18/12, 6/12/8, 12/30/20
- 局部 defect 变化（subdivided face's three corners local_defect_sum 守恒 + new vertex defect = 0）

**CF 给我**:
- defect = 2π - (vertex 周围角度和) 的定义（CF1）
- 每个三角形角和 = π（CF2 蕴含）
- manifold 一致性是前提（CF3）

## 论证尝试

T + C 让我能写：

1. 每个三角形角和 = π（CF2 暗示）。求和得到全局总角 = π · F。
2. 每个顶点周围角和 = 2π - δ(v)（CF1 定义）。但是 **我没有 R 数据来验证这一点是 per-vertex 成立的**——T 只在 region_affected 里给出 *受影响顶点* 的 defect 信息，不给完整的 per-vertex defect 表。
3. 想用双重计数：π·F = 2πV - Σδ。但是 T 没直接给 Σδ；T 的 before_state 给了 total_curvature 数字（12.566 = 4π），所以我能算出每个 preset 的 V·2π - π·F:
   - tetrahedron: 4·2π - 4·π = 4π ✓
   - cube_tri: 8·2π - 12·π = 4π ✓
   - octahedron: 6·2π - 8·π = 4π ✓
   - icosahedron: 12·2π - 20·π = 4π ✓
4. 配合 χ = V - E + F 和 3F = 2E（从 T 的 V/E/F 数字验证横跨 preset），得到 Σδ = 2πχ。

我有 enough 数据 *拼出*论证，但骨架靠 CF2 的暗示填补——T 自己不告诉我"每三角形角和 = π"，要靠 CF。

T 的 *额外* 价值：直接给了我每个 preset 的 V/E/F 绝对值，让我能验证 3F=2E。这一步在 R0C 里没那么直接（R 的 detailed_comparison 也有 V/E/F 但要从 detailed 数据里翻找）。

## 自评

**评分：PATTERN（2）**

理由：我能拼出局部到全局的论证 *骨架*（T 的 V/E/F 数据 + CF2 的"每面 π"暗示），但缺少 R 数据来验证"per-vertex defect 与 Σδ 的关系"——T 的 region_affected 是局部的、不给整张表。所以我能 *相信* Σδ = 2πV - πF 但不能从数据 *验证* 它（CF2 是单点证据，R 才是全场证据）。论证不闭合，停在 PATTERN。
