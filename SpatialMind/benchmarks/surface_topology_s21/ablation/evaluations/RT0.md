# Condition RT0 — Relation + Transform

## 数据分析

128 个 case 全部满足 i(α,β)=1。按 `summary_delta.intersection_number` 分层：success=92（i(σ,β)=1 保住），failure=36（i(σ,β)=0，β 与 σ 可同伦至不交）。

R/T 联合特征跨两组的对比（关键者）：

| 特征 | success (n=92) | failure (n=36) |
|---|---|---|
| `crossings_outside_region_pre` (cr_out_pre) | {2:1, 3:7, 4:21, 5:8, 6:47, 8:1, 9:1, 10:5, 11:1} | {0:6, 2:18, 4:2, 6:5, 10:5} |
| cr_out_pre **奇偶** | even 75, **odd 17** | even 36, **odd 0** |
| `beta_in_region == beta_total` (β 完全在 region 内) | **0/92** | **6/36** |
| `crossings_pre_count == crossings_in_pre`（β 全部交点都在 region 内） | 0/92 | 6/36（与上一条同集） |
| `minimal_position_post` | 0/92 | **9/36** |
| `bigons_post ≥ 1` | 87/92 | 6/36 |
| `bigons_without_puncture_*` | 全 0 | 全 0（结构平凡，被 prompt 警告过） |
| region 三角形数 | 全 3 | 全 3 |
| short_arc_triangles 大小 | {4:37, 6:55} | {4:6, 6:30} |
| long_arc_triangles 大小 | 全 0 | 全 0（"β through long_arc" 信号在该 fixture 下死亡） |

衍生观察：
- `cr_out_post = cr_pre_count - cr_in_post` 守恒；`cr_post = cr_in_post + cr_out_post`（验证 sanity）。
- 9 个 minpos_post=True 的 failure ⊃ 6 个 β 全在 region 内的 failure（前者是后者的真超集）。
- weight_a / level_shift 与 β 无关（surgery 只动 α），不能区分。
- candidate_count 与 realized 在 post 永远相等（cand_post − cr_post = 0），pre 端有 0–22 的 gap，但与 success/failure 无单调关系。

## 论证尝试

**候选判别 1（先验充分→success）**：cr_out_pre 为奇 ⟹ net_change=0。
- 数据：17/92 succ, 0/36 fail，**单边 100%**。
- 几何理由：σ_α 与 β 在 region 外的弧段构成的相对同伦类被 region 外的几何完全决定。region 外 i(α|_out, β|_out) ≡ cr_out_pre mod 2（mod-2 几何相交数是同伦不变量；region 是亚紧带状区域，β 进出 region 的次数决定 mod-2 配对的奇偶）。surgery 只在 region 内重排 α，因此 cr_out_post ≡ cr_out_pre (mod 2)。若 cr_out_pre 为奇，则 i(σ,β) ≥ cr_out_post ≥ 1，无法降到 0，从而 net_change=0。
- 这是一个**真**的 sufficient 条件，且论证（mod-2 相交数同伦不变 + surgery 局部于 region）站得住。

**候选判别 2（先验充分→failure）**：β 完全位于 region 内（`beta_triangles_in_region == beta_triangles_total`）⟹ net_change=−1。
- 数据：6/36 fail, 0/92 succ。**100% 单边**。
- 几何理由：若 β 整支被 surgery region 吞掉，则 β 与 σ_α 的相交数完全由 region 内的几何决定；canonical Hatcher surgery 在 region 内本来就是把 α 推开，被推开的弧若没有 region 外的"锚"把它拉回来，就会同伦消去 β 上的最后一个交点。
- 但只覆盖 6/36 failure（小但干净）。

**未能完全分类的部分（剩下 105 个）**：
- 75 succ 与 30 fail 同时落在 "cr_out_pre 偶 ∧ β 部分在外"。这一带需要更精细的局部信息（例如 β 在 short_arc 上各 candidate 的 sign，或 region 在 fundamental polygon 上的相对扭转），数据未直接暴露。
- 一个**后验**的近完美判别：`bigons_post ≥ 1` ⟹ success（87/92, 6/36）。在 S_{2,1} 上 bigon-with-puncture 是结构平凡的，不能减少 i；但 bigons_post 的存在说明 σ 与 β 仍有"伪 bigon"几何持续，这与 i 守恒高度相关。这不是 a-priori 判别（需要先做 surgery 才能数 bigons_post），但作为联合 (R, T) 数据的一致性检验有用。

**综合候选条件**：

> 在 S_{2,1} 上，若 i(α,β) ≤ 1 且 β 在 surgery region 外的 α-交点数为奇，则 i(σ_α, β) = i(α, β)。
> 反之若 β ⊂ region，则 surgery 必把 i 降到 0。

第一条有 mod-2 几何相交数论证支持；第二条有"无外部锚"论证支持。两条对 23/128 个 case 给出确定性预测，准确率 100%；剩下 105 个 case 处于灰区。

## 自评

**评分：ARGUMENT (3)**

理由：
- 任务核心要求是给出能区分 92 vs 36 的 (R, T) 联合判别。我找到两个**单边干净（100% 准确）**的判别（cr_out_pre 奇偶 + β 是否完全 in region），且对每条都给出了几何论证（mod-2 相交数不变 / 缺乏外部锚），不只是相关性。
- 但两个判别加起来只覆盖 23/128 case；剩下 105 case 在已暴露的 (R, T) 特征上看起来不可分（75 succ vs 30 fail 处于完全相同的离散特征槽内）。这意味着完整的判别需要数据未提供的局部 sign / twist 信息，我无法构造覆盖全部的 PROOF。
- 比 S_{1,2} 的 PATTERN(2) 上一档：T 在 S_{2,1} 上不再退化（region≠surface, beta_in_region 可变），且我能从 R 的 "cr_out_pre" 与 T 的 "beta_in_region/beta_total" 联合提取出几何意义清晰的判别。但未达到 PROOF——既没有覆盖全部 case，也没有给出 i(σ,β) 的精确公式。
- 诚实降级 hint：long_arc 数据全 0，所以 prompt 提示的 "β through long_arc" 路径在本 fixture 上不可用；我没法验证那条线索。
