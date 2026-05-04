# Condition 0TC — Transform + Contrastive

## 数据分析

128 cases，按 `intersection_number`（= net_change）分层：92 个 net=0，36 个 net=-1。所有 case `i(α,β)=1`，`region_size=3`（恒为 3/6 三角形），`long_arc_tri=0`（短弧主导），σ ∈ {σ_c1, σ_c6, σ_c16}。

**T 关键特征 1：β 与 region 的位置关系**

| beta 位置 | 总数 | net=0 | net=-1 |
|---|---|---|---|
| fully outside region | 10 | 7 | 3 |
| partial overlap (0.5) | 112 | 85 | 27 |
| **fully inside region (1.0)** | **6** | **0** | **6** |

β 完全包含在 surgery region 内 → 100% 失败（6/6 都是 net=-1）。这是确定性子集。

**T 关键特征 2：short_arc_triangles 大小 (4 vs 6)**

| (short_arc_tri, β 位置) | net=0 | net=-1 |
|---|---|---|
| (4, outside) | **7** | **0** |
| (4, partial) | 30 | 4 |
| (4, full) | 0 | 2 |
| (6, outside) | **0** | **3** |
| (6, partial) | 55 | 23 |
| (6, full) | 0 | 4 |

短弧覆盖 4 个三角形（局部）且 β 位于 region 外 → 100% 保持 (7/0)。短弧覆盖 6 个三角形（铺满整面）且 β 位于 region 外 → 100% 失败 (0/3)。"短弧 = 全曲面"时 σ 不再 local，β "外部"是个错觉。

**CF 数据**

- CF0 (boundary_relaxation, i≤1 → i=2)：net 从 -1 滑到 -2，`condition_is_critical=False`，但 `delta=-1` 表明放松约束确实让结果继续恶化——边界 i≤1 不是充分（已有 36 个反例），但是个真实拐点。
- CF1 (condition_removal, descending link)：net 从 -1 → 0，`delta=+1`。这是最强的信号：移除"β 在下降链中"的约束，反例消失了。
- CF2 (operation_perturbation, γ_0 → c0)：net 不变 (-1)。换 surgery 曲线但保留拓扑类型，结果一致——失败不是 γ_0 选取的偶然。

## 论证尝试

**Locality（来自 T）**：surgery 在 region (3 个三角形) 上进行，理论上不应触动外部交点。`(short_arc=4, outside) → net=0` 严格验证了这点：当 σ 真正 local 且 β 远离时，`i(σ_α,β)=i(α,β)`。这建立了 locality 的"清洁版本"。

**Boundary（来自 CF + T）**：但 locality 在两类情况下失效：

1. **β 完全嵌入 region**（6 例）：surgery 重写了 β 经过的所有三角形，原来的交点结构被销毁，候选 σ 选了不同的 isotopy class，少了一个相交。这正是"i ≤ 1 不充分"的几何根源——边界 `i=1` 的 case，只要 β 三角形预算 ≤ region 预算，β 就可能被吞没。
2. **short_arc 占满 6 个三角形**（30/36 失败）：σ 的支撑虽然名义在 3 个三角形，短弧却横跨整个曲面。CF1 印证了这点：`descending link` 约束（β 处于 σ 短弧的某个 level 之下）一旦放开，反例消失。换言之，surgery 的"代数局部性"被"拓扑非局部性"（短弧绕了一圈）破坏。

**联合论证**：T 给出 locality 的反例样本（outside+short=4 全保），CF1 用消去验证 descending-link 是真正的"额外条件"。可以试探性地刻画：

> 若 (a) β 三角形不全部落入 region 且 (b) short_arc_triangles 真正 ≤ 4（局部），则 i(σ_α,β)=i(α,β)。

这个条件在数据中无反例 (7/7)。但样本量小，且没有 bigon/sign 信息验证机制——只能算 patterned conjecture，不是 proof。

## 自评

**评分：PATTERN (2)**

理由：T 非退化，给出两个清晰几何分层（β 位置 + 短弧支撑），与 CF1（descending-link critical）互证，把"locality+boundary"故事讲得自洽。但 (a) 没有交点位置/bigon，无法做 surgery 步骤的真正机制证明；(b) "short_arc=6"是数据级特征不是概念级条件，只是相关；(c) 36 个失败中 partial overlap 占 27 例，我无法在 partial 类内进一步分离。比 S_{1,2} 的 PATTERN(2) 强（因为 T 此处确实分了组），但仍未到 ARGUMENT——缺乏真正构造性的 surgery 计算。
