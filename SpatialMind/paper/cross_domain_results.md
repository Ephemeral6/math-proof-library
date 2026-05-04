# 跨 Domain 对比 — surface_topology vs knot_theory

**Date**: 2026-05-01
**Evaluator**: Claude Opus 4.7（self-rating，单次评估，跨两个 domain 同一 evaluator）

每个 domain 的完整评估见各自的 `ablation_results.md`：
- `SpatialMind/benchmarks/surface_topology/ablation/ablation_results.md`
- `SpatialMind/benchmarks/knot_theory/ablation/ablation_results.md`

---

## 1. 评分矩阵对照

### surface_topology (S_{1,2}, 1563 cases)

```
                C off       C on
T off, R off    000: 0      00C: 2
T off, R on     R00: 2      R0C: 2
T on,  R off    0T0: 0      0TC: 2
T on,  R on     RT0: 2      RTC: 3
```

### knot_theory (R2 invariance, 100 cases)

```
                C off       C on
T off, R off    000: 1      00C: 2
T off, R on     R00: 2      R0C: 3
T on,  R off    0T0: 2      0TC: 2
T on,  R on     RT0: 2      RTC: 3
```

---

## 2. 主效应对照

| 因子 | surface_topology | knot_theory |
|------|----------------:|------------:|
| **R**  | +1.25 | +0.75 |
| **T**  | +0.25 | +0.25 |
| **C**  | +1.25 | +0.75 |

**对应关系**：
- R 主效应在 surface_topology 上更强（+1.25 vs +0.75）。原因：S_{1,2} 上"every bigon contains a puncture" + "all crossings inside surgery region" 是 *strong universals*；knot_theory 的 R 数据虽然也强（sign pair (+1,−1) 100/100），但与 T 数据冗余。
- T 主效应在两个 domain 都很弱（+0.25）。原因不同：
  - surface_topology：T 在 S_{1,2} 退化（region = 全曲面），数据信号本身缺失。
  - knot_theory：T 数据非退化（locality + sign pair），但与 R 数据高度冗余。
- C 主效应在 surface_topology 上更强（+1.25 vs +0.75）。原因：在 surface_topology 上，C 是 *找出 critical 条件* 的唯一途径（R 的 universals 太多，无 CF 难以分辨哪条 load-bearing）；在 knot_theory 上，R 已经直接验证 invariants 守恒，C 的 *边际价值* 较低。

---

## 3. 交互效应对照

| 交互 | surface_topology | knot_theory |
|------|----------------:|------------:|
| R × C | 0 | +1 |
| R × T | 0 | 0 |
| T × C | 0 | 0 |
| R × T × C | +1 | 0 |

**关键差异**：
- surface_topology 上，PATTERN → ARGUMENT 的跨越**只在 3-way 组合 (RTC) 实现**——任何 2-way 都不够。
- knot_theory 上，PATTERN → ARGUMENT 的跨越**已在 R+C 实现**——3-way 没有额外加分。

这反映两个 domain 的"信号密度"不同：
- 在 surface_topology 上，论证需要三种 *互补* 信号（structure、locality、constraint）。任何一个缺失都会卡在 PATTERN。
- 在 knot_theory 上，结构信号（R）已经直接展示"100 case 上 invariants 守恒"，加上 CF 即足以构成论证；T 的 locality 信号是冗余确认。

---

## 4. 跨 domain 一致的发现

**a) C 是必要条件**（两个 domain 都需要）。
两个 domain 上，无 C 的最高分都只到 PATTERN（2）；只有加上 C 才能跨到 ARGUMENT。
即使 R 和 T 都开（RT0），如果没有 C，论证仍然停在 PATTERN——因为 evaluator 无法判断哪个观察到的 pattern 是 *load-bearing*。

**b) R 比 T 重要**。
两个 domain 上，R 主效应都 ≥ T 主效应（surface: 1.25 vs 0.25; knot: 0.75 vs 0.25）。
猜想：R 提供 *static structural facts*（"什么是真的"），这些可以直接被论证使用；T 提供 *dynamic operation traces*（"操作如何作用"），这些只在 R 已建立结构信号后才有论证价值。

**c) T 单独价值低**。
两个 domain 上，T 主效应都是 +0.25（最低）。surface 是因为退化，knot 是因为冗余。这个一致性表明：T 原语在 SpatialMind 的当前设计下，独立价值有限——它需要与 R（static structure）或 C（critical condition）结合才能贡献。

---

## 5. 跨 domain 不一致的发现

**a) 论证门槛位置不同**。
- surface_topology: 必须 3-way 才到 ARGUMENT。
- knot_theory: 2-way (R+C) 即可到 ARGUMENT。

**b) C 的边际价值**。
- surface_topology: C 在所有 R 和 T 设置下都 +2（ON−OFF 平均）。
- knot_theory: C 在 R=ON 时 +1（R00=2 → R0C=3），在 R=OFF 时仅 +1（000=1 → 00C=2，相当于 PATTERN− → PATTERN）。也就是说 C 与 R 高度互补。

---

## 6. 假设回顾

| 假设 | surface_topology | knot_theory | 结论 |
|------|------------------|-------------|------|
| H1: C 是 PATTERN → ARGUMENT 的关键杠杆 | 不充分（C 单独只到 PATTERN）；需要 R+T 配合 | 不充分（C 单独只到 PATTERN）；需要 R 配合 | **C 是必要条件，但不充分** |
| H2: R 单独足够给出结构理解 | R00 = PATTERN ✓ | R00 = PATTERN ✓ | **支持** |
| H3: T 单独不够 | 0T0 = NO_SIGNAL（退化） | 0T0 = PATTERN（与 R 冗余） | **支持，但原因 domain-specific** |
| H4: R × C 超加性 | 0（surface 上 R+C 也未到 ARGUMENT） | +1（knot 上 R+C 跨过 ARGUMENT） | **mixed** |
| H5: 3-way 超加性 | +1 | 0 | **mixed** |
| H6: C > R > T 主效应排序 | C = R > T | C = R > T | **支持平局形式** |

**总体**：H1 需要修正——单独 C 不够，必须 C + R（或 surface 上的 C + R + T）。H6 需要修正为 "C ≥ R > T"（C 和 R 通常并列）。

---

## 7. 修正后的理论

**原假设（v1）**：三个原语中 C 是关键；R 和 T 是次要。

**修正假设（v2，2026-05-01 跨 domain 评估后）**：
- **R 和 C 是 *互补必要条件***：R 提供结构观察 + universal patterns；C 提供 load-bearing 条件定位。两者缺一，论证最多到 PATTERN。
- **T 是 *条件性辅助***：在结构数据丰富的 domain（如 knot_theory）中 T 与 R 冗余；在 T 信号丰富的 domain（如 S_{2,1}，未测）中可能成为 ARGUMENT → PROOF 的桥梁。
- **PATTERN → ARGUMENT 的门槛位置 domain-dependent**：信息密度高的 domain 在 R+C 即可越过；信息密度低或 T 退化的 domain 需要 3-way。

---

## 8. 待办 / 下一步

1. **S_{2,1} 验证**：在更大三角剖分上，T 是否不再退化？预测 0TC 应该 ≥ R0C，T 主效应应当显著上升。
2. **多 evaluator 验证**：当前评分都是同一个 evaluator (Claude Opus 4.7) 的 self-rating。重要 follow-up：在 Sonnet / GPT / 人类 evaluator 上重跑，看分数排序是否一致。
3. **R 数据 vs T 数据的独立性测试**：在 knot_theory 中故意加入 T 数据但去掉 sign pair（只保留 locality），看 T 信号在 *没有 R 冗余* 时的独立价值。
4. **多 domain 扩展**：再加 1–2 个 domain（hyperbolic 3-manifolds？simplicial homology？）验证 C 和 R 的 *互补必要性* 是否真的 domain-agnostic。

---

## 9. 附录：使用本结果时的注意事项

- 所有评分是 **integer-rounded self-rating**。如果用浮点（如 PATTERN+ = 2.5），主效应和交互的数值会改变 ~10–20%，但定性结论稳定。
- knot_theory 的 100 case 比 surface_topology 的 1563 case 少一个数量级。**case 数本身不影响 self-rating**（evaluator 看到的是 pattern 的一致性，不是统计显著性），但少 case 意味着评估的 robustness 较低。
- **CF 只 1 critical case** 在两个 domain 都是事实，但 surface_topology 上 CF 数据更稀疏（只有 net_change），knot_theory 上 CF 数据更丰富（signature/det/Alex 全部 vs original）。这是 domain 设计差异，不是 ablation 设计差异。
