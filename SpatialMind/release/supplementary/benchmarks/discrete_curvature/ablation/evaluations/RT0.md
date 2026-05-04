# Condition RT0 — Relation + Transform (discrete_curvature)

## 数据分析

R + T 双管：

**R 数据**:
- 每个 case 的 per-vertex defects（变化量）+ 全局 invariants（χ, Σδ, ratio 全部 100/100 守恒）
- 所有 stellar 的 `vertex_defects_changed = {}`、`new_vertex_defect = 0`
- displacement 有 `sum_of_vertex_changes = 0`：局部重分布
- `curvature_types`: 所有 mesh 都是 positive 顶点（亏格 0）+ 偶尔 flat（新加的中心点）

**T 数据**:
- stellar: ΔV=1, ΔE=3, ΔF=2, Δχ=0
- displacement: ΔV=ΔE=ΔF=0
- `local_defect_sum_before = local_defect_sum_after`（stellar 在被分割面区域的角缺总量守恒）
- 完整的 before_state / after_state V/E/F/χ/Σδ

R + T 一起，我能看到：
- **组合恒等式 1-3+2=0**（T）⟺ **Σδ 也不变**（R）—— 双重确认 χ 守恒和 Σδ 守恒同步发生。
- 跨 4 个 preset 的 ratio 都是 2.0：tetrahedron, cube_tri, octahedron, icosahedron — 不同 V 不同 F 但 Σδ/(2π)=χ 始终成立。

## 论证尝试

R + T 给我了 **不变性的双重证据**，但没给我 **等式起源的机制**。

我能写：
```
Stellar 的 1-3+2=0  ⟺  ΔV - ΔE + ΔF = 0  ⟺  Δχ = 0
Stellar 的 ΔΣδ = 0  （R 直接观测）
Displacement: ΔV=ΔE=ΔF=0 ⟹ Δχ=0; 局部 defect 变化 sum=0 ⟹ ΔΣδ=0
```

这告诉我：**χ 和 Σδ 都是这两个变换的不变量**。但要 *证明等式* Σδ = 2πχ，我需要：
- 起点：每个 mesh 的 χ 和 Σδ 之间的等式
- 论证：从局部"每三角形角和 π"出发，全局求和

R+T 不给我前者（只给变化量、不给绝对值的来源），也不给我"每三角形角和 = π"的证据。我只看到 invariance、不看到 etiology。

我能 hand-wave："因为变换让两边都不动，且对所有 4 个 preset 等式都成立，所以等式是普遍的。"但这是 induction 不是 proof，且没解释 *为什么*。

## 自评

**评分：PATTERN（2）**

理由：R+T 让我清楚看到双重不变性、跨 preset 一致性，但没有 CF 来揭示"每面贡献 π / defect 表示完全角缺"的机制。没有这块拼图，我只能停在 "Σδ 和 2πχ 都不变并且数值相等" 的观察层，写不出推理链。
